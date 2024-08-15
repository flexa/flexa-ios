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

struct RemoteSvgView: View {
    private var url: URL
    @Injected(\.imageLoader) private var imageLoader

    @State var data: Data?

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        if let data {
            SVGView(data: data)
        } else {
            ProgressView().onAppear(perform: loadSvg)
        }
    }

    private func loadSvg() {
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
            }
        }
    }
}
