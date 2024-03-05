//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators
import Convenient_Collections
import Convenient_Concurrency
import OSLog

// MARK: - FavouritesFlow

final class FavouritesFlow: AnyFlow { typealias ScreenID = TaggedType<String, FavouritesFlow>
  enum Screen: ScreenID {
    case favourites
  }

  private(set) var initialScreen: Screen = .favourites
  private(set) lazy var screenStack: [Screen] = [initialScreen] { didSet {
    NotificationCenter.default.post(name: .didChangePath, object: nil)
  }}

  var currentScreen: Screen { screenStack.last! } // swiftlint:disable:this force_unwrapping

  private(set) var childFlowsByScreen: OrderedDictionary<Screen, Weak<BaseFlow>> = .empty

  private(set) var flowFactories: [Screen: FlowFactory] = .empty
  private(set) var moduleFactories: [Screen: ModuleFactory] = .empty

  override func start() { super.start()
    let newFavourites = FavouritesController() => { $0.navigation = self }
    sharedNavigationController?.setViewControllers([newFavourites], animated: false)
  }

  func navigate(by path: [FlowPath]) {

  }
}

// MARK: - FavouritesNavDelegate

extension FavouritesFlow: FavouritesNavProtocol {
// Template
}
