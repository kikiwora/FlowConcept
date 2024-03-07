//  Created by Roman Suvorov (kikiwora)

import UIKit

// MARK: - FavouritesFlowScreen

enum FavouritesFlowScreen: ScreenID, ScreenEnumType {
  case favourites
}

// MARK: - FavouritesFlow

final class FavouritesFlow: BaseFlow<FavouritesFlowScreen> {
  override var initialScreen: Screen { .favourites }

  override func start() { super.start()
    placeInitialController(into: sharedNavigationController)
  }

  private func placeInitialController(into sharedNavigationController: UINavigationController) {
    let newInitial = Factory.makeModule(by: initialScreen, flow: self)

    switch initialScreen {
    case .favourites:
      sharedNavigationController.setViewControllers([newInitial], animated: false)
    }

    super.didStartSubModule(newInitial, for: initialScreen, presentationType: .replace)
  }
}

// MARK: - FavouritesNavProtocol

extension FavouritesFlow: FavouritesNavProtocol {
  // Template
}
