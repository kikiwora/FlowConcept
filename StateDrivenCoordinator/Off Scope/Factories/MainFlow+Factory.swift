//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators

// MARK: - MainFlow.Factory

extension MainFlow {
  enum Factory {
    static func makeSubFlow(by screen: Screen, withNavigation navigationController: UINavigationController) -> AnyFlow { switch screen {
    case .scores: ScoresFlow(with: navigationController)
    case .favourites: FavouritesFlow(with: navigationController)
    case .profile: ProfileFlow(with: navigationController)
    }}

    public static func makeKindaTabController(flow: MainTabNavProtocol) -> KindaTabController<MainFlow.Screen.RawValue> {
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
      ]) => {
        $0.navigation = flow
      }
    }
  }
}
