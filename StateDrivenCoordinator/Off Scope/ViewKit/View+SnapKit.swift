// swiftlint:disable:this file_name

//  Created by Roman Suvorov (kikiwora)

import UIKit
import SnapKit

extension UIView {
  func snapToSuperview() {
    snp.makeConstraints { make in
      make.edges.equalTo(superview!.safeAreaLayoutGuide)  // swiftlint:disable:this force_unwrapping
    }
  }
}
