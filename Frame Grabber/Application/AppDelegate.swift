import InAppPurchase
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: Coordinator?
    let paymentsManager: StorePaymentsManager = .shared
    let fileManager = FileManager.default

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = {
            let storyboard = UIStoryboard(name: "Editor", bundle: nil)
            let videoController = VideoController(source: .url(URL.init(string: "http://www.exit109.com/~dnn/clips/RW20seconds_2.mp4")!), previewImage: nil)
            
            guard let controller = storyboard.instantiateInitialViewController(creator: {
                EditorViewController(videoController: videoController, delegate: nil, coder: $0)
            }) else { fatalError("Could not instantiate controller.") }
            return UINavigationController.init(rootViewController: controller)
        }()
        self.window?.makeKeyAndVisible()
        
        configureInAppPurchases()
        Style.configureAppearance(for: window)
//        configureCoordinator()
        
        if launchOptions?[.url] == nil {
            try? fileManager.clearTemporaryDirectories()
        }

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let openInPlace = options[.openInPlace] as? Bool == true
        let _url = try? fileManager.importFile(at: url, asCopy: true, deletingSource: !openInPlace)
        
        guard let url = _url,
              let coordinator = coordinator else { return false }
        
        return coordinator.open(videoUrl: url)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try? fileManager.clearTemporaryDirectories()
        paymentsManager.stopObservingPayments()
    }

    private func configureCoordinator() {
        guard let navigationController = window?.rootViewController as? UINavigationController else {
            fatalError("Wrong root view controller")
        }

        coordinator = Coordinator(navigationController: navigationController)
        coordinator?.start()
    }
    
    private func configureInAppPurchases() {
        paymentsManager.purchasedProductsStore = UserDefaults.standard
        paymentsManager.startObservingPayments()
        paymentsManager.flushFinishedTransactions()
    }
}
