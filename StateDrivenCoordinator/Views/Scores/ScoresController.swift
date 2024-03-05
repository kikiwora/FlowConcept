//  Created by Roman Suvorov (kikiwora)

import UIKit
import OSLog
import Convenient_Operators

// MARK: - ScoresNavProtocol

protocol ScoresNavProtocol: AnyObject {
  func showSEV()
  func decommissionScoresController()
}

// MARK: - ScoresController

class ScoresController: NiblessController {
  var navigation: ScoresNavProtocol?

  // MARK: - Child controllers

  private lazy var mockedList = MockedListController() => {
    $0.onDidSelectItem = { [weak self] in self?.onDidSelectItem() }
  }

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Scores"

    initialLayoutSetup()
  }

  // MARK: - Private methods

  private func onDidSelectItem() {
    navigation?.showSEV()
  }

  // MARK: - Layout

  private func initialLayoutSetup() {
    addChild(mockedList)
    view.addSubview(mockedList.view)
    mockedList.didMove(toParent: self)
    mockedList.view.snapToSuperview()
  }
}
