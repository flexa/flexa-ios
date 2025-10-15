//
//  FlexaUICore.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 10/10/25.
//

struct FlexaUICore {
#if FX_ENABLE_GLASS
    public static var supportsGlass: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }
#else
    public static let supportsGlass = false
#endif
}
