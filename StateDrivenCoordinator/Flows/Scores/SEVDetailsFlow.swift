//  Created by Roman Suvorov (kikiwora)

import UIKit
import OSLog
import Convenient_Operators
import Convenient_Collections
import Convenient_Concurrency

// MARK: - SEVDetailsFlow

final class SEVDetailsFlow: AnyFlow { typealias ScreenID = TaggedType<String, SEVDetailsFlow>
  enum Screen: ScreenID, CaseIterable {
    case tab1
    case tab2
    case tab3
  }

  // MARK: - Subflow graph

  private(set) var initialScreen: Screen = .tab1
  private(set) lazy var screenStack: [Screen] = [initialScreen] { didSet {
    NotificationCenter.default.post(name: .didChangePath, object: nil)
  }}

  var currentScreen: Screen { screenStack.last! } // swiftlint:disable:this force_unwrapping

  var shouldIgnoreInitialPath: Bool { false }

  private(set) var childFlowsByScreen: OrderedDictionary<Screen, Weak<BaseFlow>> = .empty

  // MARK: - Child controllers

  private weak var pagingContainer: TabbedContainerController<ScreenID>?

  // MARK: - Life cycle

  override func start() { super.start()
    let newPagingDetails = TabbedContainerController<ScreenID>( // swiftlint:disable:this trailing_closure
      with: Screen.allCases.reduce(into: [(SEVDetailsFlow.ScreenID, String)]()) { result, screen in
        result.append((screen.rawValue, screen.rawValue.value))
      },
      controllerProvider: { [weak self] screenID in guard let self else { fatalError("Attempt to create child flow of a nil flow") }
        return self.tabController(by: Screen(rawValue: screenID)!)() // swiftlint:disable:this force_unwrapping
      }
    ) => {
      $0.navigation = self
      $0.title = "SEV Details"
    }
    pagingContainer = newPagingDetails
    sharedNavigationController?.pushViewController(newPagingDetails, animated: false)
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

  private(set) lazy var flowFactories: [Screen: FlowFactory] = [
    .tab2: { [weak self] in
      guard let self else {
        fatalError("Attempt to launch a Child flow \(SEVSubDetailsFlow.className) in a nil \(SEVDetailsFlow.className) ")
      }

      let newSubDetailsFlow = SEVSubDetailsFlow(with: self.sharedNavigationController!) // swiftlint:disable:this force_unwrapping
      return newSubDetailsFlow
    }
  ]
  private(set) lazy var moduleFactories: [Screen: ModuleFactory] = [
    .tab1: { UIViewController() => {
      $0.view.backgroundColor = .red
      $0.addLabel("Tab 1")
    } },
    .tab3: { UIViewController() => {
      $0.view.backgroundColor = .red
      $0.addLabel("Tab 3")
    } }
  ]

  private func tabController(by screen: Screen) -> () -> UIViewController {
    switch screen {
    case .tab2:
      return { [weak self] in // swiftformat:disable redundantReturn
        guard let self else {
          fatalError("Attempt to launch a Child flow \(SEVSubDetailsFlow.className) in a nil \(SEVDetailsFlow.className) ")
        }
        guard let newSubDetailsFlow = self.flowFactories[screen]?() as? SEVSubDetailsFlow else {
          fatalError("\(self.className) have been unable to start a child flow for screen \(screen)")
        }

        childFlowsByID[newSubDetailsFlow.id] = newSubDetailsFlow
        childFlowsByScreen[screen] = newSubDetailsFlow

        return newSubDetailsFlow.containerController()
      }

    default:
      return moduleFactories[screen]! // swiftlint:disable:this force_unwrapping
    }
  }
}

// MARK: - TabbedContainerNavProtocol

extension SEVDetailsFlow: TabbedContainerNavProtocol {
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
