//
//  SpendDragModalView.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 8/30/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import Foundation
import SwiftUI

public struct SpendDragModalView<Content: View>: View {
    public typealias CloseClosure = () -> Void

    public enum PresentationMode {
        case sheet, card
    }

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
    @Environment(\.theme) var mainTheme

    public var minHeight: CGFloat {
        didSet {
            curHeight = minHeight
        }
    }

    private let contentView: Content
    private let maxHeight: CGFloat = UIScreen.main.bounds.size.height * 0.85
    private let startOpacity: Double = 0.4
    private let endOpacity: Double = 0.8
    private let duration: Double = 0.3
    private var title: String
    private var titleColor: Color
    private var grabberColor: Color
    private var closeButtonColor: Color
    private var closeButton: Bool = true
    private var enableHeader: Bool = true
    private var enableMargin: Bool = true
    private var enableBlur: Bool = false
    private var enableGrabber: Bool = false
    private var blurEffect: UIBlurEffect.Style
    private var leftHeaderView: (any View)?
    private var rightHeaderView: (any View)?
    private var didClose: CloseClosure?
    private var backgroundColor: Color
    private var presentationMode: PresentationMode

    private var dragPercentage: Double {
        let res = Double((curHeight - minHeight / (maxHeight - minHeight)))
        return max(0, min(1, res))
    }

    private var cardPadding: CGFloat {
        presentationMode == .card ? 16 : 0
    }

    private var contentHorizontalPadding: CGFloat {
        presentationMode == .card ? 20 : 0
    }

    private var contentBottomPadding: CGFloat {
        presentationMode == .card ? 22 : 0
    }

    private var cornerRadius: CGFloat {
        presentationMode == .sheet ? mainTheme.views.sheet.borderRadius : 30
    }

    public init(_ title: String = "",
                titleColor: Color = Color(UIColor.label.cgColor),
                grabberColor: Color = Color.primary.opacity(0.1),
                closeButtonColor: Color = Color.primary.opacity(0.1),
                isShowing: Binding<Bool>,
                minHeight: CGFloat = UIScreen.main.bounds.size.height * 0.45,
                closeButton: Bool = true,
                enableMargin: Bool = true,
                enableBlur: Bool = false,
                enableGrabber: Bool = false,
                enableHeader: Bool = true,
                blurEffect: UIBlurEffect.Style = .systemUltraThinMaterialDark,
                backgroundColor: Color = Color(.systemBackground),
                leftHeaderView: (any View)? = nil,
                rightHeaderView: (any View)? = nil,
                presentationMode: PresentationMode = .sheet,
                didClose: CloseClosure? = nil,
                contentView: Content
                ) {
        self.title = title
        self.titleColor = titleColor
        self.grabberColor = grabberColor
        self.closeButtonColor = closeButtonColor
        _isShowing = isShowing
        _curHeight = State(wrappedValue: minHeight)
        self.enableHeader = enableHeader
        self.minHeight = minHeight
        self.contentView = contentView
        self.closeButton = closeButton
        self.enableMargin = enableMargin
        self.enableBlur = enableBlur
        self.blurEffect = blurEffect
        self.backgroundColor = backgroundColor
        self.leftHeaderView = leftHeaderView
        self.rightHeaderView = rightHeaderView
        self.presentationMode = presentationMode
        self.didClose = didClose
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            backgroundView
            if isShowing {
                ZStack(alignment: .top) {
                    contentView
                    .frame(maxHeight: .infinity)
                    .padding(.top, enableHeader ? 54 : 0)
                    .padding(.bottom, contentBottomPadding)
                    .padding(.horizontal, contentHorizontalPadding)
                    if enableHeader {
                        headerView
                    }
                }.accessibility(addTraits: .isModal)
                .frame(height: curHeight)
                .frame(maxWidth: .infinity)
                .padding([.bottom, .horizontal], cardPadding)
                .background(
                   modalBackground
                )
                .animation(isDragging ? nil : .easeInOut(duration: duration))
                .zIndex(isShowing ? 2 : 1)
                .onDisappear { curHeight = minHeight }
                .transition(.move(edge: .bottom))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: duration))
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { val in
                if !isDragging {
                    isDragging = true
                }
                let dragAmount = val.translation.height - prevDragTranslation.height

                if curHeight > maxHeight || curHeight < minHeight {
                    curHeight -= dragAmount / 6
                } else {
                    curHeight -= dragAmount
                }
                prevDragTranslation = val.translation
            }
            .onEnded { _ in
                prevDragTranslation = .zero
                isDragging = false
                if curHeight > maxHeight {
                    curHeight = maxHeight
                } else if curHeight < minHeight {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if enableBlur {
            BlurVisualEffectView(effect: UIBlurEffect(style: blurEffect))
                .opacity(isShowing ? 1 : 0)
                .zIndex(isShowing ? 1 : 0)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isShowing = false
                }
        } else {
            Color.primary
                .opacity(isShowing ? 0.5 : 0)
                .zIndex(isShowing ? 1 : 0)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }
        }
    }

    private var headerView: some View {
        ZStack {
            if enableGrabber {
                Capsule().fill(grabberColor)
                    .frame(width: 57, height: 6).padding(.top, -14)
            }
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.body.weight(.semibold))
                .foregroundColor(titleColor).padding(.top, 20)
            if closeButton {
                HStack {
                    if let leftHeaderView {
                        AnyView(leftHeaderView)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        if let rightHeaderView {
                            AnyView(rightHeaderView)
                        }

                        FlexaRoundedButton(.close) {
                            isShowing = false
                        }
                    }
                }
            }
        }
        .padding([.horizontal, .top], 20)
        .frame(maxWidth: .infinity)
        .gesture(dragGesture)
    }

    private var modalBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
            if presentationMode == .sheet {
                // HACK for RoundedCorners only on top
                Spacer()
                Rectangle().padding(.top, 60)
            }
        }
        .padding([.bottom, .horizontal], cardPadding)
        .foregroundColor(backgroundColor)
    }
}
