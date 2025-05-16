import Foundation
import SwiftUI
import FlexaUICore
import SVGView

public struct LegacyFlexcodeModal: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.theme) var theme
    @Environment(\.openURL) private var openURL

    public typealias Closure = () -> Void

    @Binding private var isShowing: Bool
    @State var showTransactionDetails: Bool = false
    @StateObject private var viewModel: LegacyFlexcodeViewModel

    public var didConfirm: Closure?
    public var didCancel: Closure?
    private var value: String
    private var brand: Brand?

    private var backgroundColor: Color {
        theme.views.sheet.backgroundColor
    }

    private var flexaSvgUrl: URL? {
        let svgName = colorScheme == .dark ? "flexa-white" : "flexa"
        return Bundle.coreBundle.svgBundle.url(forResource: svgName, withExtension: "svg")
    }

    public init(isShowing: Binding<Bool>,
                authorization: CommerceSessionAuthorization,
                value: String,
                brand: Brand?,
                didConfirm: Closure?,
                didCancel: Closure?
    ) {
        _isShowing = isShowing
        _viewModel = StateObject(
            wrappedValue: LegacyFlexcodeViewModel(
                brand: brand,
                authorization: authorization
            )
        )
        self.didConfirm = didConfirm
        self.didCancel = didCancel
        self.value = value
        self.brand = brand
    }

    public var body: some View {
        SpendDragModalView(
            isShowing: $isShowing,
            minHeight: 568,
            enableBlur: true,
            backgroundColor: backgroundColor,
            leftHeaderView: leftHeaderView,
            rightHeaderView: rightHeaderView,
            presentationMode: .card,
            didClose: { didCancel?() },
            contentView: LegacyFlexcodeContentView(
                value: value,
                didConfirm: didConfirm,
                viewModel: viewModel
            )
        )
    }

    @ViewBuilder
    var leftHeaderView: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4.6)
                .fill(AngularGradient(colors: [.white, viewModel.brandColor], center: .center, angle: .degrees(180)))
                .frame(width: 24, height: 24)
            if let flexaSvgUrl {
                SVGView(contentsOf: flexaSvgUrl)
                    .frame(width: 52, height: 17)
            } else {
                Text(CoreStrings.Global.flexa)
                    .font(.title2.bold())
            }
        }
    }

    @ViewBuilder
    var rightHeaderView: some View {
        if viewModel.showInfoButton {
            FlexaRoundedButton(.info) {
                if let url = FlexaLink.merchantList.url {
                    openURL(url)
                }
            }
        }
    }
}

public struct LegacyFlexcodeContentView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.theme) var theme

    public typealias Closure = () -> Void
    public var didSelect: Closure?
    var value: String
    var didConfirm: Closure?

    @StateObject var viewModel: LegacyFlexcodeViewModel
    @State private var shouldCreateFlexcode = true
    @State private var showHelp = false

    public init(didSelect: Closure? = nil,
                value: String,
                didConfirm: Closure? = nil,
                viewModel: LegacyFlexcodeViewModel,
                shouldCreateFlexcode: Bool = true,
                showHelp: Bool = false) {
        self.didSelect = didSelect
        self.value = value
        self.didConfirm = didConfirm
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.shouldCreateFlexcode = shouldCreateFlexcode
        self.showHelp = showHelp
    }

    public var body: some View {
        VStack(spacing: .stackSpacing) {
                ZStack(alignment: .center) {
                    RemoteImageView(
                        url: viewModel.merchantLogoUrl,
                        content: { image in
                            image.resizable()
                                .frame(width: .merchantLogoSize, height: .merchantLogoSize)
                                .cornerRadius(.cornerRadius)
                                .aspectRatio(contentMode: .fill)
                                .scaledToFit()
                        },
                        placeholder: {
                            RoundedRectangle(cornerRadius: .cornerRadius)
                                .fill(Color.gray)
                                .frame(width: .merchantLogoSize, height: .merchantLogoSize)
                        }
                    )
                }.padding(.bottom, .listItemSpacing)
                Text(CoreStrings.Payment.payMerchant(viewModel.brandName))
                    .multilineTextAlignment(.center)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary.opacity(.colorOpacity))
                Text(value)
                    .multilineTextAlignment(.center)
                    .font(.system(size: .titleExtra, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.bottom, .listItemSpacing)
                VStack {
                    ZStack {
                        if viewModel.hasCodeImages {
                            FlexcodeView(
                                pdf417Image: $viewModel.pdf417Image,
                                code128Image: $viewModel.code128Image,
                                gradientMiddleColor: viewModel.brandColor
                            ).preventScreenshot(backgroundColor: theme.views.sheet.backgroundColor) {
                                FlexcodeView(
                                    pdf417Image: $viewModel.privatePdf417Image,
                                    code128Image: $viewModel.privateCode128Image,
                                    gradientMiddleColor: viewModel.brandColor
                                ).offset(x: 0, y: 0)
                            }.offset(x: 0, y: 4)
                        } else {
                            FlexcodeView.placeholder
                            Button {
                                UIPasteboard.general.string = viewModel.authorization.number
                            } label: {
                                Text(viewModel.authorization.number)
                                    .font(.title.bold())
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundColor(.primary)
                            }.padding()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }.frame(width: .flexCodeWidth, height: .flexCodeHeight)

            Text(.init(viewModel.instructions))
                .font(.footnote.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary.opacity(.colorOpacity))
                .padding(.top, .listItemSpacing)
            Text(.init(viewModel.details))
                .foregroundColor(viewModel.brandColor)
                .bold()
        }.background(Color.clear)
                .listRowBackground(Color.clear)
                .padding(.top, .zero)
    }
}

private extension CGFloat {
    static let merchantLogoSize: CGFloat = 48
    static let merchantNameSize: CGFloat = 66
    static let cornerRadius: CGFloat = 6
    static let listItemSpacing: CGFloat = 10
    static let iconSpacing: CGFloat = 4
    static let stackSpacing: CGFloat = 8
    static let flexCodeWidth: CGFloat = 240
    static let flexCodeHeight: CGFloat = 210
    static let titleExtra: CGFloat = 48
}

private extension Double {
    static let colorOpacity: Double = 0.4
}
