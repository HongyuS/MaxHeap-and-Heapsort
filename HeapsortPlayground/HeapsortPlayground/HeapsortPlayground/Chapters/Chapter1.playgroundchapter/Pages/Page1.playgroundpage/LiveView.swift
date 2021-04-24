//
//  LiveView.swift
//
//  Abstract:
//  Instantiates a live view and passes it to the PlaygroundSupport framework.
//

import SwiftUI
import BookCore
import MyFiles
import PlaygroundSupport

let contentView = ContentView()

// Instantiate a new instance of the live view from BookCore and pass it to PlaygroundSupport.
PlaygroundPage.current.liveView = instantiateLiveView(from: contentView)
