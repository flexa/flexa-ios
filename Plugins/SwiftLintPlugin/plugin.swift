//
//  Plugin.swift
//  Spend SDK
//
//  Created by Rodrigo Ordeix on 10/13/22.
//  Copyright © 2022 Flexa. All rights reserved.
//

import PackagePlugin

@main
struct SwiftLintPlugin: BuildToolPlugin {
    private func configPath(_ target: Target) -> String {
        let path = target.name == "Flexa" || target.name == "FlexaTests" ? "" : "../"
        return "/../\(path).swiftlint.yml"
    }

    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        return [
                .buildCommand(
                displayName: "Running SwiftLint for \(target.name)",
                executable: try context.tool(named: "swiftlint").path,
                arguments: [
                    "lint",
                    "--no-cache",
                    "--config",
                    "\(target.directory.string)\(configPath(target))",
                    target.directory.string
                ],
                environment: [:]
            )
        ]
    }
}
