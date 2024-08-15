import Foundation
import SwiftUI
import FlexaUICore

public struct AssetSelectionModal: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.theme.views.sheet) var theme
    typealias ClosureAsset = (AssetWrapper) -> Void
    @Binding private var isShowing: Bool
    @StateObject private var viewModelAsset: AssetSelectionViewModel
    private var updateAsset: UpdateAssetClosure

    init(isShowing: Binding<Bool>,
         viewModelAsset: AssetSelectionViewModel,
         updateAsset: @escaping ClosureAsset) {
        _isShowing = isShowing
        _viewModelAsset = StateObject(wrappedValue: viewModelAsset)
        self.updateAsset = updateAsset
    }

    public var body: some View {
        SpendDragModalView("",
                           titleColor: Asset.flexaIdTitle.swiftUIColor,
                           grabberColor: Asset.commonGrabber.swiftUIColor,
                           closeButtonColor: Asset.commonCloseButton.swiftUIColor,
                           isShowing: $isShowing,
                           minHeight: 420,
                           enableBlur: true,
                           enableHeader: false,
                           blurEffect: .dark,
                           backgroundColor: theme.backgroundColor,
                           didClose: { isShowing = false },
                           contentView:
                            AssetsNavigationView(
                                showAssetsModal: $isShowing,
                                viewModelAsset: _viewModelAsset,
                                updateAsset: updateAsset)
                                .cornerRadius(
                                    theme.borderRadius,
                                    corners: [.topLeft, .topRight]
                                )
        )
    }
}
