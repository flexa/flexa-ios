//
//  SSEClient.swift
//  FlexaNetworking
//
//  Created by Rodrigo Ordeix on 06/6/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import Foundation
import Factory
import os.log

public enum SSE {
    static let lfChar: UInt8 = 0x0A
    static let colonChar: UInt8 = 0x3A

    public enum ConnectionState {
        case connecting
        case open
        case closed
    }

    public enum Notification {
        case open
        case message(SSE.Event)
        case event(SSE.Event)
        case complete(responseStatus: Int?, shouldReconnect: Bool?, error: Error?)
    }
}

public protocol SSEClientProtocol {
    var onOpen: (() -> Void)? { get set }
    var onComplete: ((Int?, Bool?, Error?) -> Void)? { get set }
    var onMessage: ((SSE.Event) -> Void)? { get set }

    init(request: URLRequest, timeoutInterval: TimeInterval)
    init?(resource: APIResource, timeoutInterval: TimeInterval)

    func connect(lastEventId: String?)
    func connect(request: URLRequest, lastEventId: String?)
    func disconnect()

    func addListener(for event: String, handler: @escaping (SSE.Event) -> Void)
    func removeListener(for event: String)
}

class SSEClient: NSObject, SSEClientProtocol {
    var onOpen: (() -> Void)?
    var onComplete: ((Int?, Bool?, Error?) -> Void)?
    var onMessage: ((SSE.Event) -> Void)?

    var request: URLRequest
    var readyState: SSE.ConnectionState
    var lastEventId: String?
    var timeoutInterval: TimeInterval
    var urlSession: URLSession?
    var responseErrorStatusCode: Int?
    var listeners: [String: (SSE.Event) -> Void] = [:]
    var eventsParser = SSE.Parser()
    let customHeaders = ["Accept", "Cache-Control", "Last-Event-ID"]
    let logger = Logger(subsystem: ((Bundle.main.bundleIdentifier ?? "") + "-Flexa"), category: "SSE")

    required init(request: URLRequest, timeoutInterval: TimeInterval) {
        self.request = request
        self.readyState = .closed
        self.timeoutInterval = timeoutInterval
        super.init()
    }

    required convenience init?(resource: APIResource, timeoutInterval: TimeInterval) {
        guard let request = resource.request else {
            return nil
        }

        self.init(request: request, timeoutInterval: timeoutInterval)
    }

    func connect(lastEventId: String?) {
        logger.debug("SEEClient.connect")
        self.lastEventId = lastEventId
        urlSession = Container.shared.sseUrlSession((lastEventId, timeoutInterval, self))
        urlSession?.dataTask(with: request).resume()
        readyState = .connecting
    }

    func connect(request: URLRequest, lastEventId: String?) {
        logger.debug("SEEClient.connect withRequest")
        disconnect()
        self.request = request
        connect(lastEventId: lastEventId)
    }

    func disconnect() {
        logger.debug("SEEClient.disconnect")
        readyState = .closed
        urlSession?.invalidateAndCancel()
        urlSession = nil
    }

    func addListener(for event: String, handler: @escaping (SSE.Event) -> Void) {
        listeners[event] = handler
    }

    func removeListener(for event: String) {
        listeners.removeValue(forKey: event)
    }

    private func send(notification: SSE.Notification) {
        DispatchQueue.main.async { [weak self] in
            switch notification {
            case .open:
                self?.onOpen?()
            case .message(let event):
                self?.onMessage?(event)
            case .event(let event):
                guard let name = event.eventType else {
                    return
                }
                self?.listeners[name]?(event)
            case .complete(let status, let shouldReconnect, let error):
                self?.onComplete?(status, shouldReconnect, error)
            }
        }
    }

    private func send(notifications: [SSE.Event]) {
        if let lastEventId = notifications.last(where: { $0.id != nil })?.id {
            self.lastEventId = lastEventId
        }

        for event in notifications.filter({ !$0.isRetryOnly }) {
            if event.isMessage {
                send(notification: .message(event))
            }

            send(notification: .event(event))
        }
    }
}

extension SSEClient: URLSessionDataDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {

        var shouldReconnect = false
        var statusCode: Int?

        if let responseStatusCode = (task.response as? HTTPURLResponse)?.statusCode {
            statusCode = responseStatusCode
            if responseStatusCode == 204 || responseStatusCode == 200 && readyState == .closed {
                // Server indicates to close the connection, or the connection was closed by the client
                shouldReconnect = false
            } else {
                shouldReconnect = true
            }
        }

        send(notification: .complete(responseStatus: statusCode, shouldReconnect: shouldReconnect, error: error))
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        readyState = .open
        send(notification: .open)
        completionHandler(.allow)
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        guard readyState == .open else {
            return
        }

        if let string = String(data: data, encoding: .utf8) {
            if string.hasPrefix("data: keep-alive") {
                logger.debug("SSE Event\n\(string, privacy: .public)")
            }
            for event in listeners.keys {
                let prefix = "event: \(event)"
                if string.hasPrefix(prefix) {
                    logger.debug("SSE Event\n\(prefix, privacy: .public)")
                }
            }
        }
        let events = eventsParser.append(data: data)
        send(notifications: events)
    }
}
