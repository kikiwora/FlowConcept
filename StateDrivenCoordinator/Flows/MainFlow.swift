//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators
import Convenient_Collections
import Convenient_Concurrency
import OSLog

protocol GlobalNavigation: AnyObject {
  func goToSEVDetailsSub2()
}

// MARK: - MainFlow

final class MainFlow: AnyFlow { typealias ScreenID = TaggedType<String, MainFlow>
  enum Screen: ScreenID, CaseIterable {
    case scores
    case favourites
    case profile
  }

  // MARK: - Subflow graph

  private(set) lazy var screenStack: [Screen] = [initialScreen] { didSet {
    NotificationCenter.default.post(name: .didChangePath, object: nil)
  }}

  var currentScreen: Screen { screenStack.last! } // swiftlint:disable:this force_unwrapping
  private(set) var initialScreen: Screen = .scores

  private(set) var childFlowsByScreen: OrderedDictionary<Screen, Weak<BaseFlow>> = .empty

  // MARK: - Child controllers

  private weak var container: KindaTabController<Screen.RawValue>?

  // MARK: - Shortcuts

  private var contentNavigation: UINavigationController? { container?.containedNavigationController }

  // MARK: - Life cycle

  override func start() { super.start()
    guard let sharedNavigationController else {
      fatalError("Attempt to start MainFlow without parent navigation controller")
    }

    placeContainerController(into: sharedNavigationController)
    startChildFlow(for: initialScreen)
  }

  private func placeContainerController(into sharedNavigationController: UINavigationController) {
    let newContainer = Factories.makeKindaTabController() => { $0.navigation = self }
    self.container = newContainer
    sharedNavigationController.setViewControllers([newContainer], animated: false)
  }

  // MARK: - Public interfaces

  func navigate(by path: [FlowPath]) {
    var path = path
    let first = path.removeFirst()

    if let screen = Screen(rawValue: ScreenID(value: first.value)) {
      navigate(to: screen)
    }

    currentChildFlow?.navigate(by: path)
  }

  // MARK: - Private methods

  private func navigate(to screen: Screen) { guard currentScreen != screen else { return }
    startChildFlow(for: screen)
  }

  private func startChildFlow(for screen: Screen) {
    guard let newFlow = flowFactories[screen]?() else {
      fatalError("\(self.className) have been unable to start a child flow for screen \(screen)")
    }

    childFlowsByID[newFlow.id] = newFlow
    childFlowsByScreen[screen] = newFlow

    newFlow.start()
    screenStack = [screen]
    container?.setActiveTab(byID: screen.rawValue)
  }

  // MARK: - Flow factories

  // ⚠️ NOTE: Factories are retained as closures to allow for dynamic behaviour and configuration
  // Technically, one Flow can have few instances too, though they should have unique ID each

  // swiftlint:disable force_unwrapping
  private(set) lazy var flowFactories: [Screen: FlowFactory] = [
    .scores: { [weak self] in
      guard let self else { fatalError("Attempt to create child flow of a nil flow") }
      return ScoresFlow(with: self.contentNavigation!)
    },
    .favourites: { [weak self] in
      guard let self else { fatalError("Attempt to create child flow of a nil flow") }
      return FavouritesFlow(with: self.contentNavigation!)
    },
    .profile: { [weak self] in
      guard let self else { fatalError("Attempt to create child flow of a nil flow") }
      return ProfileFlow(with: self.contentNavigation!)
    }
  ]
  private(set) var moduleFactories: [Screen: ModuleFactory] = .empty
  // swiftlint:enable force_unwrapping
}

// MARK: - Factories

// ⚠️ NOTE: This is placed outside of moduleFactories because it is not a Screen, but a part of Flow itself, meaning, not a Child?

private enum Factories {
  private typealias Screen = MainFlow.Screen

  public static func makeKindaTabController() -> KindaTabController<MainFlow.Screen.RawValue> {
    KindaTabController<Screen.RawValue>(with: [
      (
        Screen.scores.rawValue,
        UIImageView(image: UIImage(systemName: "soccerball")) => {
          $0.snp.makeConstraints { make in
            make.size.equalTo(50).priority(.high)
          }
        }
      ),
      (
        Screen.favourites.rawValue,
        UIImageView(image: UIImage(systemName: "star")) => {
          $0.snp.makeConstraints { make in
            make.size.equalTo(50).priority(.high)
          }
        }
      ),
      (
        Screen.profile.rawValue,
        UIImageView(image: UIImage(systemName: "person.crop.circle")) => {
          $0.snp.makeConstraints { make in
            make.size.equalTo(50).priority(.high)
          }
        }
      )
    ])
  }
}

// MARK: - MainTabNavProtocol

// ⚠️ NOTE: Delegate conformances are places outside of class itself to preserve clear separation of interfaces
// After all, controllers are not aware about Flow as concept, they do simply delegate intention

extension MainFlow: MainTabNavProtocol {
  func didSelectTab(by id: any AnyTaggedType) {
    guard let id = id as? ScreenID, let nextScreen = Screen(rawValue: id) else {
      fatalError("Incorrect ScreenID type")
    }

    navigate(to: nextScreen)
  }
}

extension MainFlow: GlobalNavigation {
  func goToSEVDetailsSub2() {
    let path: [FlowPath] = .make(from: "scores / sev / details / tab2 / microTab2")
    self.navigate(by: path)}
}
