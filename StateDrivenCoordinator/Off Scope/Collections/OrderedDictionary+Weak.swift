//  Created by Roman Suvorov (kikiwora)

import Foundation
import Convenient_Collections

public extension OrderedDictionary where Value: AnyObject {
  var strongCount: Int {
    guard Value.Type.self == Weak<AnyObject>.Type.self else { return count }

    // NOTE: force cast is safe here because we have checked that Value shall be Weak<Class>
    // doing compactMap every time is OK because essentially it is no different from how native .count works, which counts elements every time
    return dictionary.values.compactMap { ($0 as! Weak<AnyObject>).value }.count  // swiftlint:disable:this force_cast
  }

  init<WeakValue>(dictionaryLiteral elements: (Key, Value)...) where Value == Weak<WeakValue> {
    for (key, value) in elements { guard value.isNotNil else { continue }
      keys.append(key)
      dictionary[key] = value
    }
  }

  subscript<WeakValue>(key: Key) -> WeakValue? where Value == Weak<WeakValue> {
    get {
      dictionary[key]?.value
    }
    set {
      if let newValue { // new value is of type WeakValue, which is the real values stored in a Weak wrapper
        if !keys.contains(key) {
          keys.append(key)
        } else if dictionary[key]?.isNil == true {  // case when key is present but value is not
          keys.remove(key)                          // first, remove old key from array, which has a value of nil
          keys.append(key)                          // then, append a new key to array
        }
        dictionary[key] = Weak(newValue)            // and store new non-nil value
      } else {
        if let index = keys.firstIndex(of: key) {
          keys.remove(at: index)
          dictionary[key] = nil
        }
      }
    }
  }

  subscript<WeakValue>(index: Int) -> (key: Key, weakValue: WeakValue?) where Value == Weak<WeakValue> {
    let key = keys[index]
    let weakValue = dictionary[key]?.value
    return (key, weakValue)
  }

  mutating func removeValue<WeakValue>(forKey key: Key) -> WeakValue? where Value == Weak<WeakValue> {
    if let index = keys.firstIndex(of: key) {
      keys.remove(at: index)
      return dictionary.removeValue(forKey: key)?.value
    } else {
      return nil
    }
  }

  mutating func prune<WeakValue>() where Value == Weak<WeakValue> {
    dictionary.forEach { key, value in guard value.isNil else { return }
      keys.remove(key)
      dictionary.removeValue(forKey: key)
    }
  }
}
