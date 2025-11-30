import SwiftUI
import CoreData
import UIKit

@main
struct Mindful_MosaicApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var themeService = ThemeService.shared
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appViewModel)
                .environmentObject(themeService)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    appViewModel.checkInitialState()
                    AppDelegate.orientationLock = .portrait
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var themeService: ThemeService
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Group {
                switch appViewModel.appState {
                case .loading:
                    ZStack {
                        Color.black.ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    .preferredColorScheme(themeService.currentTheme.colorScheme)
                    .onAppear {
                        AppDelegate.orientationLock = .portrait
                        OrientationManager.shared.setOrientation(.portrait)
                    }
                case .fullscreen(let link):
                    FullscreenView(destinationAddress: link)
                        .preferredColorScheme(themeService.currentTheme.colorScheme)
                case .main:
                    MainTabView()
                        .preferredColorScheme(themeService.currentTheme.colorScheme)
                }
            }
        }
        .onChange(of: appViewModel.appState) { newState in
            switch newState {
            case .fullscreen:
                AppDelegate.orientationLock = .allButUpsideDown
                OrientationManager.shared.setOrientation(.allButUpsideDown)
            case .main, .loading:
                AppDelegate.orientationLock = .portrait
                OrientationManager.shared.setOrientation(.portrait)
            }
        }
    }
}

