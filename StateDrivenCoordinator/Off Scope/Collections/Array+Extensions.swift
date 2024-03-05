//  Created by Roman Suvorov (kikiwora)

import Foundation

public extension Array where Element: Equatable {
  mutating func removeLast(_ element: Element) {
    if let index = lastIndex(of: element) {
      remove(at: index)
    }
  }
}
