//
//  ViewExtensions.swift
//  FlexaSpend
//
//  Created by Rodrigo Ordeix on 07/31/23.
//  Copyright © 2022 Flexa. All rights reserved.
//

import SwiftUI

extension View {
    func foregroundColor(_ color: ColorAsset) -> some View {
        foregroundColor(color.swiftUIColor)
    }
}
