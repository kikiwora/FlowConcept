//  Created by Roman Suvorov (kikiwora)

import Foundation

// MARK: - ClassNameProtocol

protocol ClassNameProtocol {
  static var className: String { get }
  var className: String { get }
}

extension ClassNameProtocol {
  static var className: String {
    String(describing: Self.self)
  }

  var className: String {
    String(describing: type(of: self))
  }

  var classNameWithoutGeneric: String {
    guard let range = className.range(of: "<") else { return className }
    return String(className[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
  }
}

// MARK: - ClassNameProtocol for NSObject

extension NSObject: ClassNameProtocol {}
