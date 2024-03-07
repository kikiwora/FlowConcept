//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators

// MARK: - SEVDetailsFlowScreen

enum SEVDetailsFlowScreen: ScreenID, ScreenEnumType {
  case tab1
  case tab2
  case tab3
}

// MARK: - SEVDetailsFlow

final class SEVDetailsFlow: BaseFlow<SEVDetailsFlowScreen> {
  override var initialScreen: Screen { .tab1 }
  override var shouldIgnoreInitialPath: Bool { false }

  // MARK: - Child controllers

  private unowned var pagingContainer: TabbedContainerController<ScreenID>! // swiftlint:disable:this implicitly_unwrapped_optional

  // MARK: - Life cycle

  override func start() { super.start()
    placeInitialController(into: sharedNavigationController)
  }

  override func navigate(to screen: Screen) {
    guard screenStack != [screen] else { return }

    pagingContainer.setActiveTab(byID: screen.rawValue)
    super.didReturnToRoot()
  }

  // MARK: - Private methods

  private func placeInitialController(into sharedNavigationController: UINavigationController) {
    // swiftlint:disable:next trailing_closure
    let newPagingDetails = TabbedContainerController<ScreenID>(
      with: Screen.allCases.reduce(into: [(ScreenID, String)]()) { result, screen in
        result.append((screen.rawValue, screen.rawValue.value))
      },
      // swiftlint:disable force_unwrapping
      controllerProvider: { [unowned self] screenID in let screen = Screen(rawValue: screenID)!
        let (controller, flow) = tabController(by: Screen(rawValue: screenID)!)

        switch screen {
        case .tab1:
          registerSubModule(controller, for: .tab1)

        case .tab2:
          registerSubFlow(flow!, for: .tab2)

        case .tab3:
          registerSubModule(controller, for: .tab3)
        }

        return controller
      }
      // swiftlint:enable force_unwrapping
    ) => {
      $0.navigation = self
      $0.title = "SEV Details"
    }
    pagingContainer = newPagingDetails
    sharedNavigationController.pushViewController(newPagingDetails, animated: false)
  }

  private func tabController(by screen: Screen) -> (UIViewController, AnyFlow?) {
    if let registeredModule = subModule(by: screen) {
      return (registeredModule, nil)
    }

    if case .tab2 = screen, let registeredFlow = subFlow(by: screen) as? SEVSubDetailsFlow {
      return (registeredFlow.containerController(), registeredFlow)
    }

    // swiftlint:disable force_unwrapping
    switch screen {
    case .tab2:
      let newSubDetailsFlow = Factory.makeFlow(by: screen, onDecommission: { _, _ in }) as! SEVSubDetailsFlow // swiftlint:disable:this force_cast
      return (newSubDetailsFlow.containerController(), newSubDetailsFlow)

    default:
      let controller: UIViewController = Factory.makeModule(by: screen, flow: self)
      return (controller, nil)
    }
    // swiftlint:enable force_unwrapping
  }
}

// MARK: - TabbedContainerNavProtocol

extension SEVDetailsFlow: TabbedContainerNavProtocol {
  func didScrollToTab(by id: any AnyTaggedType) {
    guard let id = id as? ScreenID, let nextScreen = Screen(rawValue: id) else { fatalError("Incorrect ScreenID type") }

    guard screenStack != [nextScreen] else { return }

    if nextScreen == .tab2 {
      super.didStartRegisteredSubFlow(for: nextScreen, presentationType: .replace)
    }

    super.didStartRegisteredSubModule(for: nextScreen, presentationType: .replace)
  }

  func didSelectTab(by id: any AnyTaggedType) {
    guard let id = id as? ScreenID, let nextScreen = Screen(rawValue: id) else { fatalError("Incorrect ScreenID type") }

    guard screenStack != [nextScreen] else { return }

    super.didStartRegisteredSubModule(for: nextScreen, presentationType: .replace)
  }
}
