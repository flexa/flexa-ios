//
//  FlexcodeView.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 8/19/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import SwiftUI
import SVGView

struct FlexcodeView: View {
    @Binding var pdf417Image: UIImage
    @Binding var code128Image: UIImage
    var gradientMiddleColor: Color

    var gradientColors: [Color] {
        [
            gradientMiddleColor.shiftingHue(by: 10),
            gradientMiddleColor,
            gradientMiddleColor.shiftingHue(by: -10)
        ]
    }

    var body: some View {
        mainBlackBackgroundView {
            code128View
            codeBlackContainerView {
                codeWhiteContainerView {
                    pdf147CodeView
                        .padding(.leading, -13.5)
                    fuzzerViews
                        .padding(.leading, 5.5)
                }.padding(.leading, -9)
            }
            .padding(.leading, 29)
            flexaAndGradientView
        }
    }

    @ViewBuilder
    static var placeholder: some View {
        ZStack {
            Rectangle().foregroundStyle(Color(UIColor.systemGray6))
                .frame(width: 237, height: 207)
        }.frame(width: 237, height: 207)
            .mask(
                VStack(spacing: -1) {
                    svgViewFromBundle(.mainBackground)
                    svgViewFromBundle(.mainBackground)
                        .flippedVertically()
                }
            )
    }
}

private extension FlexcodeView {
    enum FlexcodeSVG: String {
        case flexa,
             mainBackground,
             codeMask,
             whiteBackground,
             blackBackground,
             topFuzzer,
             bottomFuzzer

        var fileName: String {
            "flexcode_\(rawValue)"
        }
    }
}

private extension FlexcodeView {
    @ViewBuilder
    var flexaAndGradientView: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
            Color.clear
            svgViewFromBundle(.flexa)
                .frame(width: 16, height: 50.5)
                .padding(.bottom, 19)
                .padding(.leading, 18)
            Rectangle()
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(
                            colors: gradientColors
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 6, height: 207)
                .padding(.leading, 42)
        }
    }

    @ViewBuilder
    func mainBlackBackgroundView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            Rectangle().foregroundStyle(.black)
                .frame(width: 237, height: 207)
            content()
        }.frame(width: 237, height: 207)
            .mask(
                VStack(spacing: -1) {
                    svgViewFromBundle(.mainBackground)
                    svgViewFromBundle(.mainBackground)
                        .flippedVertically()
                }
            )
    }

    @ViewBuilder
    var code128View: some View {
        VStack(alignment: .center) {
            HStack(alignment: .top) {
                ZStack {
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(width: 155, height: 36)
                    Image(uiImage: code128Image)
                        .resizable()
                        .frame(width: 165, height: 58)
                        .mask {
                            Rectangle().frame(width: 135, height: 36)
                        }
                }
                Spacer()
            }

            Spacer()
            HStack(alignment: .bottom) {
                ZStack {
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(width: 155, height: 36)
                    Image(uiImage: code128Image)
                        .resizable()
                        .frame(width: 165, height: 58)
                        .rotationEffect(.degrees(180))
                        .mask {
                            Rectangle().frame(width: 135, height: 36)
                        }
                }
                Spacer()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.leading, 43)
            .padding(.vertical, -11)
    }

    @ViewBuilder
    func codeWhiteContainerView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            VStack(spacing: -1) {
                Group {
                    svgViewFromBundle(.whiteBackground)
                    svgViewFromBundle(.whiteBackground)
                        .flippedVertically()
                }.frame(width: 165, height: 79.5)
            }
            content()

        }.frame(width: 166, height: 157)
    }

    @ViewBuilder
    func codeBlackContainerView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            VStack(spacing: -1) {
                Group {
                    svgViewFromBundle(.blackBackground)
                    svgViewFromBundle(.blackBackground)
                        .flippedVertically()
                }.frame(width: 171, height: 85.5)
            }
            content()

        }.frame(width: 172, height: 169)
    }

    @ViewBuilder
    var pdf147CodeView: some View {
        ZStack {
            Image(uiImage: pdf417Image)
                .resizable()
                .frame(width: 164.75, height: 150)
                .rotationEffect(.degrees(180))
                .mask {
                    VStack(spacing: -1) {
                        svgViewFromBundle(.codeMask)
                            .frame(width: 153, height: 68.5)
                        svgViewFromBundle(.codeMask)
                            .frame(width: 153, height: 68.5)
                            .flippedVertically()
                    }
                }
            HStack(spacing: 0) {
                Rectangle()
                    .foregroundStyle(.white)
                    .frame(width: 3)
                    .padding(.leading, 16)
                Spacer()
                Rectangle()
                    .foregroundStyle(.white)
                    .frame(width: 1)
                    .padding(.trailing, 62.5)
            }
        }
    }

    @ViewBuilder
    var fuzzerViews: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
            Color.clear
            VStack(alignment: .leading, spacing: 1) {
                svgViewFromBundle(.topFuzzer)
                    .frame(width: 97, height: 12)
                Spacer()
                svgViewFromBundle(.bottomFuzzer)
                    .frame(width: 97, height: 12)
            }.padding(.vertical, -0.5)
        }
    }

    func svgViewFromBundle(_ svg: FlexcodeSVG) -> some View {
        Self.svgViewFromBundle(svg)
    }

    static func svgViewFromBundle(_ svg: FlexcodeSVG) -> some View {
        guard let url = Bundle.spendBundle.svgBundle.url(forResource: svg.fileName, withExtension: "svg") else {
            return SVGView(string: "")
        }
        return SVGView(contentsOf: url)
    }
}

private extension View {
    func flippedVertically() -> some View {
        rotation3DEffect(
            .degrees(180),
            axis: (x: 1.0, y: 0.0, z: 0.0)
        )
    }
}
