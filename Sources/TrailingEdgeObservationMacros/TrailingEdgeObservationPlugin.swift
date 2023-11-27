import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct TrailingEdgeObservationPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        TrailingEdgeObservableMacro.self,
        TrailingEdgeObservationIgnoredMacro.self,
        TrailingEdgeObservationTrackedMacro.self
    ]
}
