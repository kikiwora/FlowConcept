//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators

// MARK: - FavouritesFlow.Factory

extension FavouritesFlow {
  enum Factory {
    static func makeModule(by screen: Screen, flow: AnyFlow) -> UIViewController {
      switch screen {
      case .favourites: Factory.makeFavouriteModule(flow: flow as! FavouritesNavProtocol)
      }
    }

    static func makeFavouriteModule(flow: FavouritesNavProtocol) -> UIViewController {
      FavouritesController() => { $0.navigation = flow }
    }
  }
}
