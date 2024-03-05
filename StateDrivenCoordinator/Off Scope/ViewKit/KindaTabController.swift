//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators
import Convenient_Collections

// MARK: - MainTabNavProtocol

protocol MainTabNavProtocol: AnyObject {
  func didSelectTab(by id: any AnyTaggedType)
}

// MARK: - KindaTabController

class KindaTabController<ScreenID: AnyTaggedType>: NiblessController {
  // MARK: - State

  private var currentScreen: ScreenID! // swiftlint:disable:this implicitly_unwrapped_optional

  // MARK: - Subviews

  private var tabItemByID: OrderedDictionary<ScreenID, UIView> = .empty
  private var tabContainer: UIView = .init() => {
    $0.backgroundColor = .white
  }

  // MARK: - Child controllers

  private(set) var containedNavigationController = UINavigationController()

  // MARK: - Public properties

  var navigation: MainTabNavProtocol?

  // MARK: - Life cycle

  init(with screens: [(ScreenID, UIView)]) {
    super.init()
    initContainedNavigation()
    initTabContainer()

    let firstScreen = screens.first?.0

    tabItemByID = screens.reduce(into: .empty) { $0[$1.0] = $1.1 }

    renderTabView()
    currentScreen = firstScreen
    renderActiveTab()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white
  }

  // MARK: - Public interface

  func setActiveTab(byID newScreen: ScreenID) {
    currentScreen = newScreen
    renderActiveTab()
  }

  // MARK: - Private Methods

  private func didTapTab(_ id: ScreenID) {
    navigation?.didSelectTab(by: id)
  }

  // MARK: - Render

  private func renderTabView() {
    tabContainer.subviews.forEach { $0.removeFromSuperview() }

    let stackView: UIStackView = .init() => {
      $0.axis = .horizontal
      $0.distribution = .equalCentering
      $0.alignment = .center
    }

    tabContainer.addSubview(stackView)
    stackView.snapToSuperview()

    func makeSpacerView() -> UIView {
      UIView() => { $0.snp.makeConstraints { make in
        make.size.equalTo(50).priority(.high)
      } }
    }

    stackView.addArrangedSubview(makeSpacerView())

    for (id, view) in tabItemByID {
      let tabButton = UIButton(type: .system) => {
        $0.addSubview(view)
        view.isUserInteractionEnabled = false
        view.snapToSuperview()

        let tabAction = UIAction { [weak self] _ in
          self?.didTapTab(id)
        }

        $0.addAction(tabAction, for: .touchUpInside)
      }

      stackView.addArrangedSubview(tabButton)
    }

    stackView.addArrangedSubview(makeSpacerView())
  }

  private func renderActiveTab() {
    tabItemByID.values.forEach { $0.alpha = 0.5 }
    tabItemByID[currentScreen]?.alpha = 1
  }

  // MARK: - Layout

  private func initContainedNavigation() {
    containedNavigationController.willMove(toParent: self)
    addChild(containedNavigationController)
    view.addSubview(containedNavigationController.view)
    containedNavigationController.view.snapToSuperview()
  }

  private func initTabContainer() {
    view.addSubview(tabContainer)
    tabContainer.snp.makeConstraints { make in
      make.left.bottom.right.equalTo(view!.safeAreaLayoutGuide) // swiftlint:disable:this force_unwrapping
      make.height.equalTo(60).priority(.high)
    }
  }
}

extension UIViewController {
  func addLabel(_ text: String) {
    let newLabel = UILabel() => { $0.text = text }

    view.addSubview(newLabel)
    newLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}
