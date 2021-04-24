//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Provides supporting functions for setting up a live view.
//

import SwiftUI
import PlaygroundSupport

/// Instantiates a new instance of a live view.
///
/// By default, this loads an instance of `LiveViewController` from a SwiftUI view `ContentView`.
public func instantiateLiveView<IncomingView>(from newLiveView: IncomingView) -> UIViewController where IncomingView : View {

    let viewController = UIHostingController(rootView: newLiveView)

    return viewController
}
