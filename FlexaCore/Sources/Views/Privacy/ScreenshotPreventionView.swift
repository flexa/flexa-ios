//
//  ScreenshotPreventionView.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 13/5/25.
//  Copyright © 2025 Flexa. All rights reserved.
//

import SwiftUI
import Factory

struct ScreenshotPreventionView<Content: View>: UIViewRepresentable {
    @State var textField: UITextField
    @State var hostingController: UIHostingController<Content>

    private var secureView: UIView? {
        textField.subviews.first {
            type(of: $0).description().hasSuffix("CanvasView")
        }
    }

    init(backgroundColor: Color? = nil, content: @escaping () -> Content) {
        self.hostingController = UIHostingController(rootView: content())

        self.textField = UITextField()
        if let backgroundColor {
            self.hostingController.view.backgroundColor = UIColor(backgroundColor)
        }
        textField.isSecureTextEntry = true
        textField.isUserInteractionEnabled = false

        self.hostingController.loadViewIfNeeded()
        if let secureView, let view = hostingController.view {
            hostingController.view = secureView
            secureView.addSubview(view)
            view.pinToSuperview()
        }
    }

    func makeUIView(context: Context) -> UIView {
        hostingController.view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
