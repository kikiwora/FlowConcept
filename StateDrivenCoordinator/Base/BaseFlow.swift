//  Created by Roman Suvorov (kikiwora)

import UIKit
import OSLog
import Convenient_Operators
import Convenient_Collections

// MARK: - ScreenEnumType

public protocol ScreenEnumType: RawRepresentable<ScreenID> & Hashable & CaseIterable {}

// MARK: - FlowPresentationType

public enum FlowPresentationType {
  case push
  case replace
  case presentOver
}

// MARK: - BaseFlow

/// Basic `Flow` class to be inherited from by other `Flow`s.
/// Defines default shared behaviour for all `Flow`s to minimize required knowledge to use this pattern
open class BaseFlow<Screen: ScreenEnumType>: FlowProtocol, ClassNameProtocol { typealias Screen = Screen
  open var id: FlowID { .init(value: className) }

  /// Defines initial `Screen` for `Flow`. Shall be overridden by `Flow`s
  open var initialScreen: Screen {
    fatalError("initialScreen shall be overridden by Flows")
  }

  /// Defines if `Flow` should not report `initial` Screen as part of `path`.
  /// > Usually, `Flow` **should not** reports `initial` Screen in own `path`, because if the `Flow` is shown, this state is already accounted in its
  /// `superflow`
  open var shouldIgnoreInitialPath: Bool { true }

  /// For super `Flow` notification of its sub `Flow` decommission
  /// > super `Flow` must know that sub is no longer required to process `Flow` graph appropriately
  open var onDecommission: (() -> Void)?

  // MARK: - Navigation reference

  /// `UINavigationController` is shared between few different `Flow`s to allows for continuous **horizontal** navigation
  /// > If any `Flow` does the **vertical** navigation, it will provide its own `UINavigationController` to subflows
  public private(set) unowned var sharedNavigationController: UINavigationController

  // MARK: - Sub Flows graph

  private var subFlowsByID: OrderedDictionary<FlowID, Weak<AnyFlowWrapper>> = .empty
  private var subFlowsByScreen: OrderedDictionary<Screen, Weak<AnyFlowWrapper>> = .empty

  // MARK: - Sub Modules graph

  private var subModulesByScreen: OrderedDictionary<Screen, Weak<UIViewController>> = .empty

  // MARK: - Stack

  /// A history of navigation by-`Screen` for this specific `Flow`
  /// > Always has at least one element, because if `Flow` is started, it is started to display something.
  /// > And if `Flow` no longer displays anything, it will be immediately **deallocated**
  /// > Since `Flow` is **strongly retained** only by `UIViewController`s it displays
  public private(set) lazy var screenStack: [Screen] = [initialScreen] { didSet { guard screenStack != oldValue else { return }
    NotificationCenter.default.post(name: .didChangePath, object: nil)
  }}

  // MARK: - Life cycle

  public init(with navigationController: UINavigationController) {
    sharedNavigationController = navigationController
  }

  /// To be overridden by `Flow`s. Shall ensure an **initial** screen is to be displayed in `View` hierarchy
  open func start() {
    Logger.flowLifeCycle.debug("\(self.id.value) started") // swiftformat:disable: redundantSelf
  }

  /// To be overridden by `Flow`s if necessary
  open func navigate(by path: FlowPath) {
    var path = path
    let first = path.removeFirst()

    if let screen = Screen(rawValue: ScreenID(value: first.value)) {
      navigate(to: screen)
    }

    currentSubFlow?.navigate(by: path)
  }

  /// To be implemented by `Flow`s
  open func navigate(to screen: Screen) {
    // 🍌
  }

  deinit {
    Logger.flowLifeCycle.debug("\(self.id.value) decommissioned")
    onDecommission?()
  }

  // MARK: - Graph control

  public func registerSubFlow(_ flow: AnyFlow, for screen: Screen) {
    let wrap = flow.wrap()
    subFlowsByID[flow.id] = wrap
    subFlowsByScreen[screen] = wrap
  }

  /// To be invoked by `Flow`s when a new sub `Flow` is started
  /// Ensures that super-sub `Flow`s relations is actualized
  public func didStartSubFlow(_ flow: AnyFlow, for screen: Screen, presentationType: FlowPresentationType) {
    registerSubFlow(flow, for: screen)
    didStartRegisteredSubFlow(for: screen, presentationType: presentationType)
  }

  /// To be invoked by `Flow`s when a new sub `Flow` is started
  /// Ensures that super-sub `Flow`s relations is actualized
  public func didStartRegisteredSubFlow(for screen: Screen, presentationType: FlowPresentationType) {
    switch presentationType {
    case .push,
         .presentOver: // swiftlint:disable:this indentation_width
      screenStack.append(screen)

    case .replace:
      screenStack = [screen]
    }
  }

  /// To be invoked by `Flow`s when a  sub `Flow` is decommissioned
  /// Ensures that super-sub `Flow`s relations is actualized
  public func didDecommissionSubFlow(_ flowID: FlowID, for screen: Screen) {
    screenStack.removeLast(screen)
    subFlowsByID.removeValue(forKey: flowID)
    subFlowsByScreen.removeValue(forKey: screen)
  }

  public func registerSubModule(_ module: UIViewController, for screen: Screen) {
    subModulesByScreen[screen] = module
  }

  /// To be invoked by `Flow`s when a new sub `Flow` is started
  /// Ensures that super-sub `Flow`s relations is actualized
  public func didStartSubModule(_ module: UIViewController, for screen: Screen, presentationType: FlowPresentationType) {
    registerSubModule(module, for: screen)
    didStartRegisteredSubModule(for: screen, presentationType: presentationType)
  }

  /// To be invoked by `Flow`s when a new sub `Flow` is started
  /// Ensures that super-sub `Flow`s relations is actualized
  public func didStartRegisteredSubModule(for screen: Screen, presentationType: FlowPresentationType) {
    switch presentationType {
    case .push,
         .presentOver: // swiftlint:disable:this indentation_width
      screenStack.append(screen)

    case .replace:
      screenStack = [screen]
    }
  }

  /// To be invoked by `Flow`s when a  sub `Flow` is decommissioned
  /// Ensures that super-sub `Flow`s relations is actualized
  public func didDecommissionSubModule(for screen: Screen) {
    screenStack.removeLast(screen)
    subFlowsByScreen.removeValue(forKey: screen)
  }

  /// To be invoked by `Flow`s when it returns to initial state
  public func didReturnToRoot() {
    screenStack = [initialScreen]
    subFlowsByScreen.prune()
    subModulesByScreen.prune()
  }

  // MARK: - Graph interface

  public func subFlow(by id: FlowID) -> AnyFlow? {
    subFlowsByID[id]?.anyFlow
  }

  public func subFlow(by screen: Screen) -> AnyFlow? {
    subFlowsByScreen[screen]?.anyFlow
  }

  public func subModule(by screen: Screen) -> UIViewController? {
    subModulesByScreen[screen]
  }

  // MARK: - Computed properties

  // swiftlint:disable:next force_unwrapping
  public var currentScreen: Screen { screenStack.last! }
  public var currentSubFlow: AnyFlow? { subFlowsByScreen[currentScreen]?.anyFlow }

  public var isNotOnInitialScreen: Bool { currentScreen != initialScreen }
  public var isReportingOwnInitialPath: Bool { screenStack.isNotEmpty && (isNotOnInitialScreen || !shouldIgnoreInitialPath) }

  public var path: FlowPath {
    if let currentSubFlow, currentSubFlow.isReportingOwnInitialPath {
      currentScreen.asFlowPath + currentSubFlow.path
    } else {
      currentScreen.asFlowPath
    }
  }
}
