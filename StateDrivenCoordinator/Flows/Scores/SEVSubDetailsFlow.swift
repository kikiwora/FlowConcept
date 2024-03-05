//  Created by Roman Suvorov (kikiwora)

import UIKit
import OSLog
import Convenient_Operators
import Convenient_Collections
import Convenient_Concurrency

// MARK: - SEVSubDetailsFlow

final class SEVSubDetailsFlow: AnyFlow { typealias ScreenID = TaggedType<String, SEVSubDetailsFlow>
  enum Screen: ScreenID, CaseIterable {
    case microTab1
    case microTab2
    case microTab3
  }

  // MARK: - Subflow graph

  var initialScreen: Screen = .microTab1
  var screenStack: [Screen] = [.microTab1] { didSet {
    NotificationCenter.default.post(name: .didChangePath, object: nil)
  }}

  var currentScreen: Screen { screenStack.last! } // swiftlint:disable:this force_unwrapping

  private(set) var childFlowsByScreen: OrderedDictionary<Screen, Weak<BaseFlow>> = .empty

  var shouldIgnoreInitialPath: Bool { false }

  // MARK: - Child controllers

  private weak var pagingContainer: TabbedContainerController<ScreenID>?

  // MARK: - Life cycle

  public func containerController() -> UIViewController {
    let newPagingSubDetails = TabbedContainerController<ScreenID>( // swiftlint:disable:this trailing_closure
      with: Screen.allCases.reduce(into: [(SEVSubDetailsFlow.ScreenID, String)]()) { result, screen in
        result.append((screen.rawValue, screen.rawValue.value))
      },
      controllerProvider: { [weak self] screenID in guard let self else { fatalError("Attempt to create child flow of a nil flow") }
        return self.tabController(by: Screen(rawValue: screenID)!)() // swiftlint:disable:this force_unwrapping
      }
    ) => {
      $0.navigation = self
    }
    pagingContainer = newPagingSubDetails
    return newPagingSubDetails
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

  private func navigate(to screen: Screen) {
    // NOTE: This is a Mock

    guard screenStack != [screen] else { return }

    pagingContainer?.setActiveTab(byID: screen.rawValue)
    screenStack = [screen]
  }

  // MARK: - Flow factories

  private(set) lazy var flowFactories: [Screen: FlowFactory] = .empty
  private(set) lazy var moduleFactories: [Screen: ModuleFactory] = .empty

  private func tabController(by screen: Screen) -> () -> UIViewController {
    return { UIViewController() => {
      $0.view.backgroundColor = .yellow
      $0.addLabel("Screen: \(screen.rawValue.value)")
    } }
  }
}

// MARK: - SEVSubDetailsNavProtocol

extension SEVSubDetailsFlow: TabbedContainerNavProtocol {
  func didScrollToTab(by id: any AnyTaggedType) {
    guard let id = id as? ScreenID, let nextScreen = Screen(rawValue: id) else {
      fatalError("Incorrect ScreenID type")
    }

    guard screenStack != [nextScreen] else { return }
    screenStack = [nextScreen]
  }

  func didSelectTab(by id: any AnyTaggedType) {
    guard let id = id as? ScreenID, let nextScreen = Screen(rawValue: id) else {
      fatalError("Incorrect ScreenID type")
    }

    guard screenStack != [nextScreen] else { return }
    screenStack = [nextScreen]
  }
}
