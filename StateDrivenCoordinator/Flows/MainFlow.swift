//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators

// MARK: - GlobalNavigation

protocol GlobalNavigation: AnyObject {
  func goToSEVDetailsSub2()
}

// MARK: - MainFlowScreen

enum MainFlowScreen: ScreenID, ScreenEnumType {
  case scores
  case favourites
  case profile
}

// MARK: - MainFlow

final class MainFlow: BaseFlow<MainFlowScreen> {
  override var initialScreen: Screen { .scores }

  // MARK: - Child controllers

  private unowned var container: KindaTabController<Screen.RawValue>! // swiftlint:disable:this implicitly_unwrapped_optional
  private var contentNavigation: UINavigationController { container.containedNavigationController }

  // MARK: - Life cycle

  override func start() { super.start()
    // Container controller is placed into navigation controller from outside
    placeContainerController(into: sharedNavigationController)

    // After which, an initial subflow starts in contained navigation
    startSubFlow(for: initialScreen)
  }

  override func navigate(to screen: Screen) { guard currentScreen != screen else { return }
    startSubFlow(for: screen)
  }

  // MARK: - Private methods

  private func placeContainerController(into sharedNavigationController: UINavigationController) {
    let newContainer = Factory.makeKindaTabController(flow: self)

    self.container = newContainer
    sharedNavigationController.setViewControllers([newContainer], animated: false)
  }

  private func startSubFlow(for screen: Screen) {
    let newFlow = Factory.makeSubFlow(by: screen, withNavigation: contentNavigation)

    newFlow.start()
    super.didStartSubFlow(newFlow, for: screen, presentationType: .replace)
    container.setActiveTab(byID: screen.rawValue)
  }
}

// MARK: - MainTabNavProtocol for MainFlow

// ⚠️ NOTE: Delegate conformances are places outside of class itself to preserve clear separation of interfaces
// After all, controllers are not aware about Flow as concept, they do simply delegate intention

extension MainFlow: MainTabNavProtocol {
  func didSelectTab(by id: any AnyTaggedType) {
    guard let id = id as? ScreenID, let nextScreen = Screen(rawValue: id) else { fatalError("Incorrect ScreenID type") }

    navigate(to: nextScreen)
  }
}
