//  Created by Roman Suvorov (kikiwora)

import OSLog

extension Logger {
  /// Using your bundle identifier is a great way to ensure a unique identifier.
  private static var subsystem = Bundle.main.bundleIdentifier! // swiftlint:disable:this force_unwrapping

  public static let viewLifeCycle = Logger(subsystem: subsystem, category: "View Life Cycle")
  public static let flowLifeCycle = Logger(subsystem: subsystem, category: "Flow Life Cycle")
  public static let navigation = Logger(subsystem: subsystem, category: "Navigation")
}
