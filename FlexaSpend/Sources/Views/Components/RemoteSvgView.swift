//
//  RemoteSvgView.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 8/8/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import Factory
import SVGView

struct RemoteSvgView<Content>: View where Content: View {
    private class TaskWrapper: ObservableObject {
        var task: Task<(), Never>?
    }

    private var url: URL
    private var content: ((any View) -> any View)?
    private var placeholder: ((Bool) -> any View)?

    @StateObject private var taskWrapper = TaskWrapper()

    @Injected(\.imageLoader) private var imageLoader

    @State private var data: Data?
    @State private var failed: Bool = false

    public init<S, P>(
        url: URL,
        @ViewBuilder content: @escaping (any View) -> S,
        @ViewBuilder placeholder: @escaping (Bool) -> P
    ) where Content == _ConditionalContent<S, P>, S: View, P: View {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        ZStack {
            if let placeholder, data == nil {
                AnyView(placeholder(failed))
            }

            if let content {
                AnyView(content(SVGView(data: data ?? Data())))
            } else {
                SVGView(data: data ?? Data())
            }
        }.onAppear(perform: load)
            .onDisappear(perform: cancel)
    }

    private func load() {
        let data = imageLoader.cachedData(forUrl: url)

        if data != nil {
            self.data = data
            return
        }

        Task {
            if let data = await imageLoader.loadData(fromUrl: url, forceRefresh: false) {
                await MainActor.run {
                    self.data = data
                }
            } else {
                await MainActor.run {
                    self.data = data
                    self.failed = data == nil
                }
            }
        }
    }

    private func cancel() {
        taskWrapper.task?.cancel()
        taskWrapper.task = nil
    }
}
