import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

		guard let windowScene = (scene as? UIWindowScene) else { return }

		self.window = .init(windowScene: windowScene)
		self.window?.makeKeyAndVisible()

		let vc = ViewController()
		let navVC = UINavigationController(rootViewController: vc)

		self.window?.rootViewController = navVC
	}
}

