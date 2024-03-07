//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators

// MARK: - SEVSubDetailsFlowScreen

enum SEVSubDetailsFlowScreen: ScreenID, ScreenEnumType {
  case microTab1
  case microTab2
  case microTab3
}

// MARK: - SEVSubDetailsFlow

final class SEVSubDetailsFlow: BaseFlow<SEVSubDetailsFlowScreen> {
  override var initialScreen: Screen { .microTab1 }
  override var shouldIgnoreInitialPath: Bool { false }

  // MARK: - Child controllers

  private weak var pagingContainer: TabbedContainerController<ScreenID>? // swiftlint:disable:this implicitly_unwrapped_optional

  // MARK: - Life cycle

  override func start() {
    super.start()

    self.pagingContainer = containerController() as? TabbedContainerController<ScreenID>
  }

  // ⚠️
  // ⚠️
  // ⚠️
  // ⚠️              IGNORE THIS FILE — MOCK
  // ⚠️
  // ⚠️

  public func containerController() -> UIViewController {
    if let pagingContainer { return pagingContainer }

    let newPagingSubDetails = TabbedContainerController<ScreenID>( // swiftlint:disable:this trailing_closure
      with: Screen.allCases.reduce(into: [(ScreenID, String)]()) { result, screen in
        result.append((screen.rawValue, screen.rawValue.value))
      },
      controllerProvider: { [unowned self] screenID in
        tabController(by: Screen(rawValue: screenID)!)() // swiftlint:disable:this force_unwrapping
      }
    ) => {
      $0.navigation = self
    }
    pagingContainer = newPagingSubDetails
    return newPagingSubDetails
  }

  // MARK: - Public interface

  override func navigate(to screen: Screen) {
    guard screenStack != [screen] else { return }

    pagingContainer?.setActiveTab(byID: screen.rawValue)
    super.didStartRegisteredSubModule(for: screen, presentationType: .replace)
  }

  // MARK: - Flow factories

  private func tabController(by screen: Screen) -> () -> UIViewController {
    { UIViewController() => {
      $0.view.backgroundColor = .yellow
      $0.addLabel("Screen: \(screen.rawValue.value)")
    } }
  }
}

// MARK: - SEVSubDetailsFlow

extension SEVSubDetailsFlow: TabbedContainerNavProtocol {
  func didScrollToTab(by id: any AnyTaggedType) {
    guard let id = id as? ScreenID, let nextScreen = Screen(rawValue: id) else { fatalError("Incorrect ScreenID type") }

    guard screenStack != [nextScreen] else { return }

    super.didStartRegisteredSubModule(for: nextScreen, presentationType: .replace)
  }

  func didSelectTab(by id: any AnyTaggedType) {
    guard let id = id as? ScreenID, let nextScreen = Screen(rawValue: id) else { fatalError("Incorrect ScreenID type") }

    guard screenStack != [nextScreen] else { return }

    super.didStartRegisteredSubModule(for: nextScreen, presentationType: .replace)
  }
}
