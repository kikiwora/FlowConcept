//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators
import Convenient_Concurrency
import OSLog

// MARK: - SceneDelegate

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  var mainFlow: MainFlow?

  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let scene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: scene) => { self.window = $0 }

    let rootNavigationController: UINavigationController = .init()
    window.rootViewController = rootNavigationController
    window.makeKeyAndVisible()

    mainFlow = MainFlow(with: rootNavigationController) => {
      $0.start()
    }

    addPathUpdateObserver()
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }
}

// MARK: - Events Listeners

extension Notification.Name {
  static let didChangePath = Notification.Name("didChangePath")
}

private extension SceneDelegate {
  func addPathUpdateObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleNavigationPathChange), name: .didChangePath, object: nil)
  }

  @objc func handleNavigationPathChange() {
    Logger.navigation.info("Path Changed: 📁 \(self.mainFlow!.path.asString())") // swiftlint:disable:this force_unwrapping
  }
}
