//
//  SpendModalView.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 8/30/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

public struct SpendModalView<Content: View>: View {
    public typealias CloseClosure = () -> Void

    @ScaledMetric var scale: CGFloat = 1
    @Binding public var isShowing: Bool {
        didSet {
            if !isShowing {
                didClose?()
            }
        }
    }

    @State public var curHeight: CGFloat
    @State private var isDragging = false
    @State private var prevDragTranslation = CGSize.zero

    public let contentView: Content

    public var minHeight: CGFloat {
        didSet {
            curHeight = minHeight
        }
    }

    let maxHeight: CGFloat = UIScreen.main.bounds.size.height
    let startOpacity: Double = 0.4
    let endOpacity: Double = 0.8
    var title: String

    private var closeButton: Bool = true
    private var enableMargin: Bool = true
    private var enableBlur: Bool = false
    private var blurEffect: UIBlurEffect.Style
    private var image: Image?
    private var didClose: CloseClosure?

    public init(_ title: String = "",
                isShowing: Binding<Bool>,
                minHeight: CGFloat = UIScreen.main.bounds.size.height,
                closeButton: Bool = true,
                enableMargin: Bool = true,
                enableBlur: Bool = false,
                blurEffect: UIBlurEffect.Style = .systemUltraThinMaterialDark,
                image: Image? = nil,
                didClose: CloseClosure? = nil,
                contentView: Content
                ) {
        self.title = title
        _isShowing = isShowing
        _curHeight = State(wrappedValue: minHeight)
        self.minHeight = minHeight
        self.contentView = contentView
        self.closeButton = closeButton
        self.enableMargin = enableMargin
        self.enableBlur = enableBlur
        self.blurEffect = blurEffect
        self.image = image
        self.didClose = didClose
    }

    public var body: some View {
        ZStack(alignment: .top) {
            if isShowing {
                ZStack(alignment: .top) {
                    contentView
                    .frame(maxHeight: .infinity)
                    .padding(.top, 54)
                    .padding(.bottom, 24)
                    ZStack {
                        Capsule().fill(.black.opacity(0.1))
                            .frame(width: 57, height: 6).padding(.top, -14)
                        Text(title)
                            .multilineTextAlignment(.leading)
                            .font(.body.weight(.semibold))
                            .foregroundColor(.black).padding(.top, 20)
                        if closeButton {
                            HStack {
                                if let image = image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 80, height: 22, alignment: .center)
                                }
                                Spacer()
                                ZStack {
                                    FlexaRoundedButton(.close) {
                                        isShowing = false
                                    }
                                }
                            }.padding(.top, 24)
                            .padding(.horizontal, 16)
                        }
                    }
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.00001))
                }.accessibility(addTraits: .isModal)
                .frame(height: curHeight)
                .frame(maxWidth: .infinity)
                .background(
                    // HACK for RoundedCorners only on top
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                        Spacer()
                        Rectangle().padding(.top, 60)
                    }
                    .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.97))
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }
}
