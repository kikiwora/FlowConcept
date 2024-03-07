//  Created by Roman Suvorov (kikiwora)

import UIKit

// MARK: - ProfileFlowScreen

enum ProfileFlowScreen: ScreenID, ScreenEnumType {
  case profile
}

// MARK: - ProfileFlow

final class ProfileFlow: BaseFlow<ProfileFlowScreen> {
  override var initialScreen: Screen { .profile }

  override func start() { super.start()
    placeInitialController(into: sharedNavigationController)
  }

  private func placeInitialController(into sharedNavigationController: UINavigationController) {
    let newInitial = Factory.makeModule(by: initialScreen, flow: self)

    switch initialScreen {
    case .profile:
      sharedNavigationController.setViewControllers([newInitial], animated: false)
    }

    super.didStartSubModule(newInitial, for: initialScreen, presentationType: .replace)
  }
}

// MARK: - ProfileNavProtocol

extension ProfileFlow: ProfileNavProtocol {
  // Template
}
