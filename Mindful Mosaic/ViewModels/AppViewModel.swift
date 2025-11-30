import Foundation
import SwiftUI
import Combine

enum AppState: Equatable {
    case loading
    case fullscreen(String)
    case main
}

class AppViewModel: ObservableObject {
    @Published var appState: AppState = .loading
    
    private let tokenStorage = TokenStorageService.shared
    private let networkService = NetworkService.shared
    
    func checkInitialState() {
        if tokenStorage.getToken() != nil,
           let link = tokenStorage.getLink() {
            appState = .fullscreen(link)
            return
        }
        
        appState = .main
        
        Task {
            await fetchServerData()
        }
    }
    
    @MainActor
    private func fetchServerData() async {
        do {
            let response = try await networkService.fetchServerResponse()
            
            if let separatorIndex = response.firstIndex(of: "#") {
                let token = String(response[..<separatorIndex])
                let link = String(response[response.index(after: separatorIndex)...])
                
                tokenStorage.saveToken(token)
                tokenStorage.saveLink(link)
                
                appState = .fullscreen(link)
            } else {
                appState = .main
            }
        } catch {
            appState = .main
        }
    }
}

