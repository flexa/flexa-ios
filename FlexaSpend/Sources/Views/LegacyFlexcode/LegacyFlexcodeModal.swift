import Foundation
import SwiftUI
import FlexaUICore

struct LegacyFlexcodeModal: View {
    @Environment(\.colorScheme) var colorScheme
    public typealias Closure = () -> Void
    @Binding private var isShowing: Bool
    @State var showTransactionDetails: Bool = false
    @State var showInfo: Bool = false

    @StateObject fileprivate var viewModel: SpendView.ViewModel
    private var legacyFlexcodeViewModel: LegacyFlexcodeViewModel

    public var didConfirm: Closure?
    public var didCancel: Closure?
    private var value: String
    private var brand: Brand?

    var backgroundColor: Color {
        Color(colorScheme == .dark ? .systemBackground : .secondarySystemBackground)
    }

    private let gradientStops: [Gradient.Stop] = [
        Gradient.Stop(color: Color(hex: "#417D9B"), location: 0.5),
        Gradient.Stop(color: Color(hex: "#417D9B").opacity(0), location: 0.5),
        Gradient.Stop(color: Color(hex: "#22739C").opacity(0.53), location: 1)
    ]

    @ViewBuilder
    var leftHeaderView: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4.6)
                .fill(AngularGradient(gradient: Gradient(stops: gradientStops), center: .center))
                .frame(width: 24, height: 24)
            Text(L10n.Common.flexa)
                .font(.title2.weight(.bold))

        }
    }

    @ViewBuilder
    var rightHeaderView: some View {
        if legacyFlexcodeViewModel.showInfoButton {
            AnyView(FlexaRoundedButton(.info) {
                showInfo = true
            })
        } else {
            AnyView(EmptyView())
        }
    }

    @ViewBuilder
    var modal: some View {
        SpendDragModalView(titleColor: Asset.flexaIdTitle.swiftUIColor,
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
                           contentView:
                            LegacyFlexcodeContentView(value: value,
                                                      legacyFlexcodeViewModel: legacyFlexcodeViewModel,
                                                      didConfirm: didConfirm,
                                                      viewModel: viewModel)
        ).sheet(isPresented: $showInfo) { BrandView(brand).ignoresSafeArea() }
    }

    // MARK: - Initialization
    init(isShowing: Binding<Bool>,
         viewModel: SpendView.ViewModel,
         value: String,
         brand: Brand?,
         didConfirm: Closure?,
         didCancel: Closure?
    ) {
        _isShowing = isShowing
        _viewModel = StateObject(wrappedValue: viewModel)
        self.legacyFlexcodeViewModel = LegacyFlexcodeViewModel(brand: brand)
        self.didConfirm = didConfirm
        self.didCancel = didCancel
        self.value = value
        self.brand = brand
    }

    var body: some View {
        modal
    }

}

struct LegacyFlexcodeContentView: View {
    @Environment(\.presentationMode) var presentationMode

    public typealias Closure = () -> Void
    public var didSelect: Closure?
    var value: String
    var legacyFlexcodeViewModel: LegacyFlexcodeViewModel
    var didConfirm: Closure?

    @StateObject fileprivate var viewModel: SpendView.ViewModel
    @State private var shouldCreateFlexcode = true
    @State private var showHelp = false

    private let detailsColor = Color(hex: "#41819B")

    var body: some View {
        VStack(spacing: .stackSpacing) {
                ZStack(alignment: .center) {
                    RemoteImageView(
                        url: legacyFlexcodeViewModel.merchantLogoUrl,
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
                Text(L10n.Payment.payMerchant(legacyFlexcodeViewModel.brandName))
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
                        if let image = viewModel.legacyFlexcode {
                            Image(uiImage: image)
                                .resizable()
                        } else {
                            Rectangle().fill(Color(.systemGray6))
                            ProgressView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }.frame(width: .flexCodeWidth, height: .flexCodeHeight)

            Text(viewModel.commerceSession?.authorization?.instructions ?? "")
                .font(.footnote.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary.opacity(.colorOpacity))
                .padding(.top, .listItemSpacing)
            Text(viewModel.commerceSession?.authorization?.details ?? "")
                .foregroundColor(detailsColor)
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
