//  Created by Roman Suvorov (kikiwora)

import Foundation
import Convenient_Collections

// MARK: - Sequence

extension OrderedDictionary: Sequence {
  public typealias Element = (Key, Value)

  public func makeIterator() -> Iterator {
    return Iterator(for: self)
  }

  public struct Iterator: IteratorProtocol {
    init(for dictionary: OrderedDictionary<Key, Value>) {
      collection = dictionary.keys.reduce(into: [Element]()) { collection, key in
        collection.append((key, dictionary[key]!))  // swiftlint:disable:this force_unwrapping
      }
      lastIndex = collection.count - 1
    }

    private var collection: [Element]
    private var current: Int = -1
    private let lastIndex: Int

    public mutating func next() -> Element? {
      guard current < lastIndex else { return nil }

      let next = current + 1
      let nextElement = collection[next]
      current = next

      return nextElement
    }
  }
}

public struct OrderedDictionary<Key: Hashable, Value> {
  internal var keys: [Key] = []
  internal var dictionary: [Key: Value] = [:]

  public var count: Int { keys.count }
  public var values: [Value] { Array(dictionary.values) }

  public init(dictionaryLiteral elements: (Key, Value)...) {
    for (key, value) in elements {
      keys.append(key)
      dictionary[key] = value
    }
  }

  public subscript(key: Key) -> Value? {
    get {
      dictionary[key]
    }
    set {
      if let newValue {
        if !keys.contains(key) {
          keys.append(key)
        }
        dictionary[key] = newValue
      } else {
        if let index = keys.firstIndex(of: key) {
          keys.remove(at: index)
          dictionary[key] = nil
        }
      }
    }
  }

  public subscript(index: Int) -> (key: Key, value: Value) {
    let key = keys[index]
    let value = dictionary[key]!  // swiftlint:disable:this force_unwrapping
    return (key, value)
  }

  public func index(forKey key: Key) -> Int? {
    keys.firstIndex(of: key)
  }

  @discardableResult
  public mutating func removeValue(forKey key: Key) -> Value? {
    if let index = keys.firstIndex(of: key) {
      keys.remove(at: index)
      return dictionary.removeValue(forKey: key)
    } else {
      return nil
    }
  }

  public mutating func removeAll() {
    keys.removeAll()
    dictionary.removeAll()
  }
}

extension OrderedDictionary: Emptyable {
  public static var empty: OrderedDictionary { .init() }
}

public extension OrderedDictionary {
  var firstValue: Value? {
    guard let firstKey = keys.first else { return nil }
    return dictionary[firstKey]
  }

  var lastValue: Value? {
    guard let lastKey = keys.last else { return nil }
    return dictionary[lastKey]
  }
}
