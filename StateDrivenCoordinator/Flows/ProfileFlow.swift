//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators
import Convenient_Collections
import Convenient_Concurrency
import OSLog

// MARK: - ProfileFlow

final class ProfileFlow: AnyFlow { typealias ScreenID = TaggedType<String, ProfileFlow>
  enum Screen: ScreenID {
    case profile
  }

  private(set) var initialScreen: Screen = .profile
  private(set) lazy var screenStack: [Screen] = [initialScreen] { didSet {
    NotificationCenter.default.post(name: .didChangePath, object: nil)
  }}

  var currentScreen: Screen { screenStack.last! } // swiftlint:disable:this force_unwrapping

  private(set) var childFlowsByScreen: OrderedDictionary<Screen, Weak<BaseFlow>> = .empty

  private(set) var flowFactories: [Screen: FlowFactory] = .empty
  private(set) var moduleFactories: [Screen: ModuleFactory] = .empty

  override func start() { super.start()
    let newProfile = ProfileController() => { $0.navigation = self }
    sharedNavigationController?.setViewControllers([newProfile], animated: false)
  }

  func navigate(by path: [FlowPath]) {

  }
}

// MARK: - ProfileNavDelegate

extension ProfileFlow: ProfileNavProtocol {
// Template
}
