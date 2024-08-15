//
//  ModalState.swift
//  FlexaUICore
//
//  Created by Rodrigo Ordeix on 8/30/23.
//  Copyright © 2023 Flexa. All rights reserved.
//

import SwiftUI

public class SpendModalState: ObservableObject {
    @Published public var visible: Bool = false

    public init() {
    }
}
