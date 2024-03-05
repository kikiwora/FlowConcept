//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators
import Convenient_Collections
import Convenient_Concurrency
import OSLog

// MARK: - ScoresFlow

final class ScoresFlow: AnyFlow { typealias ScreenID = TaggedType<String, ScoresFlow>
  enum Screen: ScreenID {
    case scores
    case sev
    case details
  }

  // MARK: - Subflow graph

  private(set) lazy var screenStack: [Screen] = [initialScreen] { didSet {
    NotificationCenter.default.post(name: .didChangePath, object: nil)
  }}

  var currentScreen: Screen { screenStack.last! } // swiftlint:disable:this force_unwrapping
  private(set) var initialScreen: Screen = .scores

  private(set) var childFlowsByScreen: OrderedDictionary<Screen, Weak<BaseFlow>> = .empty

  // MARK: - Child controllers

  private weak var initialController: UIViewController?

  // MARK: - Life cycle

  override func start() { super.start()
    guard let sharedNavigationController else {
      fatalError("Attempt to start ScoresFlow without parent navigation controller")
    }

    placeInitialController(into: sharedNavigationController)
  }

  private func placeInitialController(into sharedNavigationController: UINavigationController) {
    let newScores = ScoresController() => { $0.navigation = self }
    sharedNavigationController.setViewControllers([newScores], animated: false)
    initialController = newScores
  }

  // MARK: - Public interface

  func navigate(by path: [FlowPath]) {
    var path = path
    let first = path.removeFirst()

    if let screen = Screen(rawValue: ScreenID(value: first.value)) {
      navigate(to: screen)
    }

    currentChildFlow?.navigate(by: path)
  }

  // MARK: - Private methods

  private func navigate(to screen: Screen) {
    switch screen {
    case .scores:
      returnToInitialScreen()

    case .sev:
      pushController(by: .sev)

    case .details:
      startFlow(by: .details)
    }
  }

  private func returnToInitialScreen() {
    guard let initialController else { fatalError("Attempt to navigate to nil controller") }

    sharedNavigationController?.popToViewController(initialController, animated: true)
    screenStack = [.scores]
  }

  private func startFlow(by screen: Screen) {
    guard let newFlow: BaseFlow = flowFactories[screen]?() else {
      fatalError("\(self.className) have been unable to start a child flow for screen \(screen)")
    }

    let newFlowID = newFlow.id

    newFlow.onDecomission = { [weak self] in
      guard self?.initialController.isNotNil == true else { return }
      self?.childFlowsByID.removeValue(forKey: newFlowID)
      self?.screenStack.removeLast(screen)
    }

    childFlowsByID[newFlow.id] = newFlow
    childFlowsByScreen[screen] = newFlow

    newFlow.start()
    screenStack.append(screen)
  }

  private func pushController(by screen: Screen) {
    guard let newController: UIViewController = moduleFactories[screen]?() else {
      fatalError("No controller factory for \(screen.rawValue)")
    }

    sharedNavigationController?.pushViewController(newController, animated: true)
    screenStack.append(screen)
  }

  // MARK: - Flow factories

  private(set) lazy var flowFactories: [Screen: FlowFactory] = [
    .details: { [weak self] in
      guard let self else {
        fatalError("Attempt to launch a Child flow \(SEVDetailsFlow.className) in a nil \(ScoresFlow.className) ")
      }
      guard let sharedNavigationController = self.sharedNavigationController else {
        fatalError("Attempt to launch a Child flow \(SEVDetailsFlow.className) in a nil sharedNavigationController of \(ScoresFlow.className) without ")
      }

      return SEVDetailsFlow(with: sharedNavigationController)
    }
  ]
  private(set) lazy var moduleFactories: [Screen: ModuleFactory] = [
    .sev: { [weak self] in SEVController() => { $0.navigation = self } }
  ]
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
    // ⚠️ NOTE: This implementation is questionable
    guard initialController.isNotNil else { return }
    screenStack.removeLast(.sev)
  }
}
