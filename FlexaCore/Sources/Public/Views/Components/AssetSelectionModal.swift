import Foundation
import SwiftUI

public struct AssetSelectionModal: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.theme.views.sheet) var theme
    public typealias ClosureAsset = (AssetWrapper) -> Void
    @Binding public var isShowing: Bool
    @StateObject public var viewModelAsset: AssetSelectionViewModel
    public var updateAsset: UpdateAssetClosure

    public init(isShowing: Binding<Bool>,
                viewModelAsset: AssetSelectionViewModel,
                updateAsset: @escaping ClosureAsset) {
        _isShowing = isShowing
        _viewModelAsset = StateObject(wrappedValue: viewModelAsset)
        self.updateAsset = updateAsset
    }

    public var body: some View {
        SpendDragModalView("",
                           titleColor: .primary,
                           grabberColor: Color(UIColor.systemGray4),
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
