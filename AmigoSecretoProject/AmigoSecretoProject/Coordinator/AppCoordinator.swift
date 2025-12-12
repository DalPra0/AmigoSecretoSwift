import SwiftUI

class AppCoordinator: ObservableObject {
    @Published var currentView: AppView = .main
    
    enum AppView {
        case main
        case settings
    }
    
    func navigateToMain() {
        currentView = .main
    }
    
    func navigateToSettings() {
        currentView = .settings
    }
}
