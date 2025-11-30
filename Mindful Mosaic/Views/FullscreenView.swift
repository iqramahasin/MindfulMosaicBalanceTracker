import SwiftUI
import WebKit
import UIKit

struct FullscreenView: View {
    let destinationAddress: String
    @State private var isInitialLoading = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            FullscreenWebContainer(destinationAddress: destinationAddress, isInitialLoading: $isInitialLoading)
                .ignoresSafeArea()
            
            if isInitialLoading {
                Color.black.ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .statusBarHidden(true)
        .background(StatusBarHider())
        .onAppear {
            AppDelegate.orientationLock = .allButUpsideDown
            OrientationManager.shared.setOrientation(.allButUpsideDown)
        }
        .onDisappear {
            AppDelegate.orientationLock = .portrait
            OrientationManager.shared.setOrientation(.portrait)
        }
    }
}

struct StatusBarHider: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> StatusBarHiddenController {
        StatusBarHiddenController()
    }
    
    func updateUIViewController(_ uiViewController: StatusBarHiddenController, context: Context) {}
}

final class StatusBarHiddenController: UIViewController {
    override var prefersStatusBarHidden: Bool { true }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .fade }
}

struct FullscreenWebContainer: UIViewControllerRepresentable {
    let destinationAddress: String
    @Binding var isInitialLoading: Bool
    
    func makeUIViewController(context: Context) -> FullscreenWebViewController {
        let controller = FullscreenWebViewController()
        controller.load(address: destinationAddress, coordinator: context.coordinator)
        return controller
    }
    
    func updateUIViewController(_ controller: FullscreenWebViewController, context: Context) {
        controller.load(address: destinationAddress, coordinator: context.coordinator)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isInitialLoading: $isInitialLoading)
    }
    
    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isInitialLoading: Bool
        private var hasSettled = false
        private var timeoutWorkItem: DispatchWorkItem?
        
        init(isInitialLoading: Binding<Bool>) {
            _isInitialLoading = isInitialLoading
        }
        
        func prepareForNewLoad() {
            hasSettled = false
            timeoutWorkItem?.cancel()
            DispatchQueue.main.async {
                self.isInitialLoading = true
            }
            
            let work = DispatchWorkItem { [weak self] in
                self?.finishLoading()
            }
            timeoutWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 8, execute: work)
        }
        
        func finishLoading() {
            guard !hasSettled else { return }
            hasSettled = true
            timeoutWorkItem?.cancel()
            timeoutWorkItem = nil
            DispatchQueue.main.async {
                self.isInitialLoading = false
            }
        }
        
        // MARK: WKNavigationDelegate
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            finishLoading()
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            finishLoading()
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            finishLoading()
        }
    }
}

final class FullscreenWebViewController: UIViewController {
    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private var currentAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .black
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.contentInset = .zero
        webView.scrollView.scrollIndicatorInsets = .zero
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func load(address: String, coordinator: FullscreenWebContainer.Coordinator) {
        webView.navigationDelegate = coordinator
        guard currentAddress != address else { return }
        currentAddress = address
        
        guard let url = URL(string: address) else {
            coordinator.finishLoading()
            return
        }
        
        coordinator.prepareForNewLoad()
        webView.load(URLRequest(url: url))
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        .fade
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .allButUpsideDown
    }
    
    override var shouldAutorotate: Bool {
        true
    }
}

final class OrientationManager {
    static let shared = OrientationManager()
    private init() {}
    
    func setOrientation(_ mask: UIInterfaceOrientationMask) {
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { _ in }
            windowScene.windows.first?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIDevice.current.setValue(mask.toUIInterfaceOrientation().rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

extension UIInterfaceOrientationMask {
    func toUIInterfaceOrientation() -> UIInterfaceOrientation {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        case .landscape: return .landscapeRight
        default: return .unknown
        }
    }
}

extension View {
    func supportedOrientations(_ orientations: UIInterfaceOrientationMask) -> some View {
        self.onAppear {
            OrientationManager.shared.setOrientation(orientations)
        }
    }
}

