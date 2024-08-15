//
//  FlexaLoad.swift
//  FlexaLoad
//
//  Created by Rodrigo Ordeix on 10/5/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

@_exported import FlexaCore
import SwiftUI

public final class FlexaLoad {
    private init() {
    }

    public func open() {
    }

    public func createView() -> some View {
        EmptyView()
    }
}

public extension FlexaLoad {
    final class Builder {
        private var load = FlexaLoad()

        fileprivate init() {
        }

        public func build() -> FlexaLoad {
            let load = self.load
            self.load = FlexaLoad()
            return load
        }

        public func open() {
            build().open()
        }

        public func createView() -> some View {
            build().createView()
        }
    }
}

public extension Flexa {
    static func buildLoad() -> FlexaLoad.Builder {
        FlexaLoad.Builder()
    }
}
