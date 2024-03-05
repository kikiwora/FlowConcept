//  Created by Roman Suvorov (kikiwora)

import Foundation

// MARK: - AnyTaggedType

public protocol AnyTaggedType: Codable, Hashable, Equatable {
  associatedtype ValueType: Codable & Hashable
  var value: ValueType { get }
}

// MARK: - TaggedType

public struct TaggedType<ValueType: Codable & Hashable, Tag>: AnyTaggedType {
  public typealias RawValue = ValueType

  public let value: ValueType

  public var rawValue: Self.RawValue { value }

  public init(value: ValueType) {
    self.value = value
  }

  public init?(rawValue: Self.RawValue) {
    value = rawValue
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    value = try container.decode(ValueType.self)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }

  public static func id(_ value: ValueType) -> Self {
    .init(value: value)
  }
}

// MARK: - ExpressibleByUnicodeScalarLiteral

extension TaggedType: ExpressibleByUnicodeScalarLiteral where ValueType == String {}

// MARK: - ExpressibleByExtendedGraphemeClusterLiteral

extension TaggedType: ExpressibleByExtendedGraphemeClusterLiteral where ValueType == String {}

// MARK: - ExpressibleByStringLiteral

extension TaggedType: ExpressibleByStringLiteral where ValueType == String {
  public typealias StringLiteralType = String

  public init(stringLiteral: StringLiteralType) {
    value = stringLiteral
  }
}

// MARK: - CustomDebugStringConvertible

extension TaggedType: CustomDebugStringConvertible {
  public var debugDescription: String { "\(String(describing: value))<\(Tag.self)>" }
}

// MARK: - Array

public extension Array where Element: AnyTaggedType {
  var values: [Element.ValueType] { map(\.value) }
}

public extension Optional where Wrapped: Collection, Wrapped.Element: AnyTaggedType {
  var values: [Wrapped.Element.ValueType]? {
    self?.map(\.value)
  }
}
