import Foundation
import SwiftUI
import FlexaUICore

struct LegacyFlexcodeModal: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.theme) var theme

    public typealias Closure = () -> Void

    @Binding private var isShowing: Bool
    @State var showTransactionDetails: Bool = false
    @State var showInfo: Bool = false
    @StateObject private var viewModel: LegacyFlexcodeViewModel

    public var didConfirm: Closure?
    public var didCancel: Closure?
    private var value: String
    private var brand: Brand?

    private var gradientStops: [Gradient.Stop] {
        [
            Gradient.Stop(color: viewModel.brandColor, location: 0.0),
            Gradient.Stop(color: viewModel.brandColor, location: 0.5),
            Gradient.Stop(color: viewModel.brandColor.opacity(0), location: 0.5),
            Gradient.Stop(color: viewModel.brandColor.shiftingHue(by: 10).opacity(0.53), location: 1)
        ]
    }

    private var backgroundColor: Color {
        theme.views.sheet.backgroundColor
    }

    init(isShowing: Binding<Bool>,
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

    var body: some View {
        SpendDragModalView(
            titleColor: Asset.flexaIdTitle.swiftUIColor,
            grabberColor: Asset.commonGrabber.swiftUIColor,
            closeButtonColor: Asset.commonCloseButton.swiftUIColor,
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
        ).sheet(isPresented: $showInfo) { BrandView(brand).ignoresSafeArea() }
    }

    @ViewBuilder
    var leftHeaderView: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4.6)
                .fill(
                    AngularGradient(
                        stops: gradientStops,
                        center: .center,
                        startAngle: .degrees(-180),
                        endAngle: .degrees(540)
                    )
                )
                .frame(width: 24, height: 24)
            Text(L10n.Common.flexa)
                .font(.title2.weight(.bold))
        }

    }

    @ViewBuilder
    var rightHeaderView: some View {
        if viewModel.showInfoButton {
            FlexaRoundedButton(.info) {
                showInfo = true
            }
        }
    }
}

struct LegacyFlexcodeContentView: View {
    @Environment(\.presentationMode) var presentationMode

    public typealias Closure = () -> Void
    public var didSelect: Closure?
    var value: String
    var didConfirm: Closure?

    @StateObject var viewModel: LegacyFlexcodeViewModel
    @State private var shouldCreateFlexcode = true
    @State private var showHelp = false

    var body: some View {
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
                Text(L10n.Payment.payMerchant(viewModel.brandName))
                    .multilineTextAlignment(.center)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary.opacity(.colorOpacity))
                Text(value)
                    .multilineTextAlignment(.center)
                    .font(.system(size: .titleExtra, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.bottom, .listItemSpacing)
                VStack {
                    ZStack {
                        if viewModel.hasCodeImages {
                            FlexcodeView(
                                pdf417Image: $viewModel.pdf417Image,
                                code128Image: $viewModel.code128Image,
                                gradientMiddleColor: viewModel.brandColor
                            )
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

            Text(viewModel.instructions)
                .font(.footnote.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary.opacity(.colorOpacity))
                .padding(.top, .listItemSpacing)
            Text(viewModel.details)
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
