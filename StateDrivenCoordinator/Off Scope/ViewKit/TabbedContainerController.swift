//  Created by Roman Suvorov (kikiwora)

import UIKit
import Parchment
import Convenient_Operators
import Convenient_Collections

// MARK: - TabbedContainerNavProtocol

protocol TabbedContainerNavProtocol: AnyObject {
  func didSelectTab(by id: any AnyTaggedType)
  ///  func didScrollFromTab(by id: any AnyTaggedType)
  func didScrollToTab(by id: any AnyTaggedType)
}

// MARK: - TabbedContainerController

class TabbedContainerController<ScreenID: AnyTaggedType>: NiblessController, PagingViewControllerDataSource, PagingViewControllerDelegate {
  typealias ControllerProvider = (ScreenID) -> UIViewController

  // MARK: - State

  private var currentScreen: ScreenID! // swiftlint:disable:this implicitly_unwrapped_optional
  private var tabItemByID: OrderedDictionary<ScreenID, String> = .empty

  // MARK: - Child controllers

  private var pagingViewController: PagingViewController! // swiftlint:disable:this implicitly_unwrapped_optional

  // MARK: - Public properties

  var navigation: TabbedContainerNavProtocol?
  var controllerProvider: ControllerProvider

  // MARK: - Life cycle

  init(with screens: [(ScreenID, String)], controllerProvider: @escaping ControllerProvider) {
    self.controllerProvider = controllerProvider
    super.init()
    view.backgroundColor = .white

    tabItemByID = screens.reduce(into: .empty) { $0[$1.0] = $1.1 }
    let firstScreen = screens.first?.0
    currentScreen = firstScreen

    initTabbedContainer()
    renderActiveTab(animated: false)
  }

  // MARK: - Parchment Data Source

  func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
    tabItemByID.count
  }

  func pagingViewController(_ pagingViewController: PagingViewController, viewControllerAt index: Int) -> UIViewController {
    let screenID: ScreenID = tabItemByID[index].key
    return controllerProvider(screenID)
  }

  func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
    let tabTitle = tabItemByID[index].value
    return PagingIndexItem(index: index, title: tabTitle)
  }

  // MARK: - Parchment Delegate

  func pagingViewController(
    _ pagingViewController: PagingViewController,
    didScrollToItem pagingItem: PagingItem,
    startingViewController: UIViewController?,
    destinationViewController: UIViewController,
    transitionSuccessful: Bool
  ) {
    let indexedTabItem = pagingItem as! PagingIndexItem // swiftlint:disable:this force_cast
    let toTabID: ScreenID = tabItemByID[indexedTabItem.index].key
    navigation?.didScrollToTab(by: toTabID)
  }

  func pagingViewController(
    _ pagingViewController: PagingViewController,
    didSelectItem pagingItem: PagingItem
  ) {
    let indexedTabItem = pagingItem as! PagingIndexItem  // swiftlint:disable:this force_cast
    let selectedTabID: ScreenID = tabItemByID[indexedTabItem.index].key
    navigation?.didSelectTab(by: selectedTabID)
  }

  // MARK: - Public interface

  func setActiveTab(byID newScreen: ScreenID) {
    currentScreen = newScreen
    renderActiveTab()
  }

  // MARK: - Render

  func renderActiveTab(animated: Bool = true) {
    guard let tabIndex = tabItemByID.index(forKey: currentScreen) else {
      fatalError("Internal inconsistency — Attempt to render Tab for currentScreen with no corresponding Tab")
    }

    pagingViewController.select(index: tabIndex, animated: animated)
  }

  // MARK: - Layout

  private func initTabbedContainer() {
    let newPagingController: PagingViewController = .init() => {
      $0.dataSource = self
      $0.delegate = self
    }
    addChild(newPagingController)
    view.addSubview(newPagingController.view)
    newPagingController.view.snapToSuperview()
    pagingViewController = newPagingController
  }
}
