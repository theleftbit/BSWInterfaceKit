//
//  PreviewHostAppApp.swift
//  PreviewHostApp
//
//  Created by Pierluigi Cifani on 6/2/23.
//

import SwiftUI

@main
struct PreviewHostAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    struct ContentView: View {
        var body: some View {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, world!")
            }
            .padding()
        }
    }
}
