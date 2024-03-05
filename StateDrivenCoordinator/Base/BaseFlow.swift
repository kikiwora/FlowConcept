//  Created by Roman Suvorov (kikiwora)

import UIKit
import OSLog
import Convenient_Operators
import Convenient_Collections

// MARK: - Protocols

public typealias AnyFlow = BaseFlow & ChildAwareFlowProtocol

public typealias FlowPath = TaggedType<String, FlowPathTag>; public enum FlowPathTag {}
public typealias FlowID = BaseFlow.ID

// MARK: - BaseFlow

open class BaseFlow: ClassNameProtocol {
  public typealias ID = TaggedType<String, BaseFlow>
  open var id: ID { .init(value: className) }

  open weak var sharedNavigationController: UINavigationController?

  public var childFlowsByID: OrderedDictionary<ID, Weak<BaseFlow>> = .empty

  open var onDecomission: (() -> Void)?

  public init(with navigationController: UINavigationController) {
    sharedNavigationController = navigationController
  }

  open func start() {
    Logger.flowLifeCycle.debug("\(self.id.value) started") // swiftformat:disable: redundantSelf
  }

  deinit {
    // TODO: ❓ It make have sense for Flows to notify parents on deinit
    // ⚠️ NOTE: Flows actually use a Weak collection, so this is not strictly required, but may be useful for event-driven approach
    Logger.flowLifeCycle.debug("\(self.id.value) decommissioned")
    onDecomission?()
  }
}

// MARK: - ChildAwareFlowProtocol

public protocol ChildAwareFlowProtocol: AnyObject {
  associatedtype Screen: Hashable

  typealias FlowFactory = () -> BaseFlow
  typealias ModuleFactory = () -> UIViewController

  // MARK: - Subflow graph

  var screenStack: [Screen] { get }
  var currentScreen: Screen { get }
  var initialScreen: Screen { get }

  var path: [FlowPath] { get }
  var currentChildFlow: (any AnyFlow)? { get }

  var childFlowsByScreen: OrderedDictionary<Screen, Weak<BaseFlow>> { get }

  var shouldIgnoreInitialPath: Bool { get }
  var isNotOnInitialScreen: Bool { get }

  // MARK: - Flow factories

  var flowFactories: [Screen: FlowFactory] { get }
  var moduleFactories: [Screen: ModuleFactory] { get }

  func navigate(by path: [FlowPath])
}

// MARK: - ChildAwareFlowProtocol mixins

public extension ChildAwareFlowProtocol {
  var shouldIgnoreInitialPath: Bool { true }
  var isNotOnInitialScreen: Bool { currentScreen != initialScreen }

  var currentChildFlow: (any AnyFlow)? { childFlowsByScreen[currentScreen]?.value as? (any AnyFlow) }

  private var shouldReportOwnPath: Bool {
    isNotOnInitialScreen || !shouldIgnoreInitialPath
  }

  var path: [FlowPath] {
    guard let currentScreenTag = (currentScreen as? any RawRepresentable)?.rawValue as? (any AnyTaggedType) else {
      fatalError("Screen must be a RawRepresentable<TaggedType>")
    }

    guard let currentScreenName = currentScreenTag.value as? String else {
      fatalError("Screen.RawValue must be a TaggedType<String>")
    }

    let currentScreenPath = [FlowPath(value: currentScreenName)]

    guard let currentChildFlow, currentChildFlow.shouldReportOwnPath else {
      return currentScreenPath
    }

    return currentScreenPath + currentChildFlow.path
  }
}

extension [FlowPath] {
  private enum Constants {
    static let pathSeparator: String = " / "
  }

  static func make(from string: String) -> [FlowPath] {
    let components = string.split(separator: Constants.pathSeparator).map { String($0) }
    return components.map { FlowPath(value: $0) }
  }
  
  func asString() -> String {
    map(\.value).joined(separator: Constants.pathSeparator)
  }
}
