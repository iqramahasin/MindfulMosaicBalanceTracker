import SwiftUI
import UIKit

struct MainTabView: View {
    var body: some View {
        TabView {
            MosaicView()
                .tabItem {
                    Label("Mosaic", systemImage: "square.grid.3x3")
                }
            
            CheckInView()
                .tabItem {
                    Label("Check-In", systemImage: "plus.circle")
                }
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar")
                }
            
            PatternsView()
                .tabItem {
                    Label("Patterns", systemImage: "sparkles")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .supportedOrientations(.portrait)
        .onAppear {
            AppDelegate.orientationLock = .portrait
            OrientationManager.shared.setOrientation(.portrait)
            forcePortraitOrientation()
        }
    }
    
    private func forcePortraitOrientation() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let currentOrientation = windowScene.interfaceOrientation
            if currentOrientation != .portrait {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
    }
}

