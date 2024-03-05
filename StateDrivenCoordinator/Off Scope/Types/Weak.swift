//  Created by Roman Suvorov (kikiwora)

import Foundation

// MARK: - Weak

public final class Weak<WeakValue: AnyObject> {
  public weak var value: WeakValue?

  public var isNil: Bool { switch value {
  case .some: false
  case .none: true
  }}

  public var isNotNil: Bool { switch value {
  case .some: true
  case .none: false
  }}

  public init(_ value: WeakValue?) {
    self.value = value
  }
}
