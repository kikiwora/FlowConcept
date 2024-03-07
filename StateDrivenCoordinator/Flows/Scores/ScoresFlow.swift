//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators

// MARK: - ScoresFlowScreen

enum ScoresFlowScreen: ScreenID, ScreenEnumType {
  case scores
  case sev
  case details
}

// MARK: - ScoresFlow

final class ScoresFlow: BaseFlow<ScoresFlowScreen> {
  override var initialScreen: Screen { .scores }

  // MARK: - Child controllers

  private unowned var initialController: UIViewController! // swiftlint:disable:this implicitly_unwrapped_optional

  // MARK: - Life cycle

  override func start() { super.start()
    placeInitialController(into: sharedNavigationController)
  }

  override func navigate(to screen: Screen) {
    if screen == initialScreen && currentScreen != screen {
      returnToInitialScreen()
    }

    switch screen {
    case .details:
      // Flow is started because it defines how exactly
      startSubFlow(by: screen)

    default:
      // Module is pushed because this Flow defines that
      pushModule(by: screen)
    }
  }

  // MARK: - Private methods

  private func placeInitialController(into sharedNavigationController: UINavigationController) {
    let newInitial = Factory.makeModule(by: initialScreen, flow: self) => { self.initialController = $0 }

    switch initialScreen {
    case .scores:
      sharedNavigationController.setViewControllers([newInitial], animated: false)

    default:
      fatalError("\(initialScreen) cannot be entry point")
    }

    super.didStartSubModule(newInitial, for: initialScreen, presentationType: .replace)
  }

  private func startSubFlow(by screen: Screen) {
    let decommissionHandler: FlowDecommissionHandler = { [weak self] flowID, screen in
      self?.didDecommissionSubFlow(flowID, for: screen)
    }

    let newFlow = Factory.makeFlow(by: screen, withNavigation: sharedNavigationController, onDecommission: decommissionHandler)

    newFlow.start()
    super.didStartSubFlow(newFlow, for: screen, presentationType: .replace)
  }

  private func pushModule(by screen: Screen) {
    let newController = Factory.makeModule(by: screen, flow: self)

    sharedNavigationController.pushViewController(newController, animated: true)
    super.didStartSubModule(newController, for: screen, presentationType: .push)
  }

  private func returnToInitialScreen() {
    sharedNavigationController.popToViewController(initialController, animated: true)
    super.didReturnToRoot()
  }
}

// MARK: - ScoresNavProtocol

extension ScoresFlow: ScoresNavProtocol {
  func showSEV() {
    navigate(to: .sev)
  }

  func decommissionScoresController() {
    // Implementation is not required here because Scores Controller is the root controller of Scores Flow
    // Meaning, when it is gone, Scores Flow is gone too, due to Flows being retained by controllers
    // When no controllers of flow are left alive, the flow is automatically decommissioned
  }
}

// MARK: - SEVControllerNavProtocol

extension ScoresFlow: SEVControllerNavProtocol {
  func showDetails() {
    navigate(to: .details)
  }

  func decommissionSEVController() {
    super.didDecommissionSubModule(for: .sev)
  }
}
