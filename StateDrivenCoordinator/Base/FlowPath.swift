// swiftlint:disable:this file_name
//  Created by Roman Suvorov (kikiwora)

import Foundation

public typealias FlowPathElement = TaggedType<String, FlowPathTag>; public enum FlowPathTag {}
public extension ScreenEnumType {
  var asFlowPath: [FlowPathElement] { [FlowPathElement(value: rawValue.value)] }
}

public extension [FlowPathElement] {
  private enum Constants {
    static let pathSeparator: String = " / "
  }

  static func make(from string: String) -> [FlowPathElement] {
    let components = string.split(separator: Constants.pathSeparator).map { String($0) }
    return components.map { FlowPathElement(value: $0) }
  }

  func asString() -> String {
    map(\.value).joined(separator: Constants.pathSeparator)
  }
}
