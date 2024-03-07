//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Concurrency

// MARK: - Protocols

public typealias FlowID = TaggedType<String, FlowTag>
public typealias ScreenID = TaggedType<String, ScreenTag>

public typealias FlowFactory = () -> AnyFlow
public typealias ModuleFactory = () -> UIViewController

// MARK: - AnyFlow

public typealias AnyFlow = (any FlowProtocol)

// MARK: - FlowProtocol

public protocol FlowProtocol: AnyObject {
  var id: FlowID { get }

  var onDecommission: EmptyClosure? { get set }

  var path: FlowPath { get }
  var isReportingOwnInitialPath: Bool { get }

  func start()
  func navigate(by path: FlowPath)
}

// MARK: - AnyFlowWrapper

/// This is a workaround to achieve `Weak<AnyFlow>`
final class AnyFlowWrapper {
  weak var anyFlow: AnyFlow?

  init(_ flow: AnyFlow) {
    anyFlow = flow
    setRetainAssociation(to: flow)
  }

  private func setRetainAssociation(to flow: AnyFlow) {
    objc_setAssociatedObject(flow as AnyObject, &AnyFlowWrapper.associatedObjectKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }

  private static var associatedObjectKey: Void?
}

extension Weak<AnyFlowWrapper> {
  var anyFlow: AnyFlow? { value?.anyFlow }
}

extension FlowProtocol {
  func wrap() -> AnyFlowWrapper {
    AnyFlowWrapper(self)
  }
}
