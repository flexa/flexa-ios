//
//  ExpiringCache.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 4/19/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import Foundation

public protocol IExpiringCache {
    associatedtype Key
    associatedtype Value

    func object(forKey: Key) -> Value?
    func setObject(_ object: Value?, forKey key: Key, expirationDate: Date?)
    func removeObject(forKey key: Key) -> Value?
    subscript(key: Key) -> Value? { get set }
}

public extension IExpiringCache {
    func setObject(_ object: Value?, forKey key: Key) {
        setObject(object, forKey: key, expirationDate: nil)
    }
}

public class ExpiringCache<Key: AnyObject, Value: Any>: IExpiringCache {
    private let defaultExpirationTimeInSeconds: TimeInterval = 180
    private let cache = NSCache<Key, CacheEntry<Value>>()
    private var defaultExpirationDate: Date {
        Date().addingTimeInterval(defaultExpirationTimeInSeconds)
    }

    public init() {
    }

    public func setObject(_ object: Value?, forKey key: Key, expirationDate: Date?) {
        if let object {
            let cacheEntry = CacheEntry(value: object, expirationDate: expirationDate ?? defaultExpirationDate)
            cache.setObject(cacheEntry, forKey: key)
        } else {
            removeObject(forKey: key)
        }
    }

    public func object(forKey key: Key) -> Value? {
        let cacheEntry: CacheEntry? = cache.object(forKey: key)
        if let cacheEntry = cacheEntry, cacheEntry.expired {
            removeObject(forKey: key)
            return nil
        }
        return cacheEntry?.value
    }

    @discardableResult
    public func removeObject(forKey key: Key) -> Value? {
        let cacheEntry = cache.object(forKey: key)
        cache.removeObject(forKey: key)
        return cacheEntry?.value
    }

    public subscript(key: Key) -> Value? {
        get {
            object(forKey: key)
        }
        set {
            setObject(newValue, forKey: key)
        }
    }

    public func removeAll() {
        cache.removeAllObjects()
    }
}

private extension ExpiringCache {
    class CacheEntry<CacheValue> {
        let value: CacheValue
        let expirationDate: Date

        var expired: Bool {
            expirationDate < Date()
        }

        init(value: CacheValue, expirationDate: Date) {
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}
