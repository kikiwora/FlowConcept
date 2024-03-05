//  Created by Roman Suvorov (kikiwora)

import UIKit
import OSLog
import SnapKit
import Convenient_Operators

// MARK: - SEVControllerNavProtocol

protocol SEVControllerNavProtocol: AnyObject {
  func showDetails()

  /// ‼️ Statement about deinit order below is incorrect
  /// ⚠️ NOTE: The reason why this is requires in this controller but not in ScoresController is because ScoresController is an entry point to Scores Flow
  /// Meaning, when ScoresController is the first to init and last to deinit, and when it does later, all strong references to ScoresFlow will nil
  /// Thus, the ScoresFlow will automatically decommission itself. Though, it is probably a good idea for Flow to have a deinit notifier too, to notify parent?
  func decommissionSEVController()
}

// MARK: - SEVController

class SEVController: NiblessController {
  var navigation: SEVControllerNavProtocol?

  // MARK: - Child controllers

  private lazy var mockedList = MockedListController() => {
    $0.onDidSelectItem = { [weak self] in self?.onDidSelectItem() }
  }

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "SEV"

    initialLayoutSetup()
  }

  // TODO: ❓ Maybe there is a better way to handle controllers life cycle
  // ⚠️ NOTE: When flow operate child controllers, there is an issue that controller can be dismissed without flow knowing
  // Somehow we have to path information about controller being decommissioned to flow which manages it
  // Obviously, this is not an ideal solution, since it requires us to be couscous about retain cycle which will break Flows
  // The alternative, though, is worse — to become a delegate of a shared navigation controller and switch delegate between flows on start / decomission
  deinit {
    navigation?.decommissionSEVController()
  }

  // MARK: - Private methods

  private func onDidSelectItem() {
    navigation?.showDetails()
  }

  private func initialLayoutSetup() {
    addChild(mockedList)
    view.addSubview(mockedList.view)
    mockedList.didMove(toParent: self)
    mockedList.view.snapToSuperview()
  }
}
