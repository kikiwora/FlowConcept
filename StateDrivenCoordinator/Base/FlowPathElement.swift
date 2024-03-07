//  Created by Roman Suvorov (kikiwora)

import Foundation

public typealias FlowPath = [FlowPathElement]
public typealias FlowPathElement = TaggedType<String, FlowPathTag>

public extension ScreenEnumType {
  var asFlowPath: FlowPath { [FlowPathElement(value: rawValue.value)] }
}

public extension FlowPath {
  private enum Constants {
    static let pathSeparator: String = " / "
  }

  static func make(from string: String) -> FlowPath {
    let components = string.split(separator: Constants.pathSeparator).map { String($0) }
    return components.map { FlowPathElement(value: $0) }
  }

  func asString() -> String {
    map(\.value).joined(separator: Constants.pathSeparator)
  }
}
