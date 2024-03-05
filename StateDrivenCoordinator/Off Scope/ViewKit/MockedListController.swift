//  Created by Roman Suvorov (kikiwora)

import UIKit
import SnapKit

// MARK: - MockedListController

class MockedListController: NiblessController, UITableViewDataSource, UITableViewDelegate {
  let tableView = UITableView()
  let items = (1...10).map { "Item \($0)" } // Generate item names

  var onDidSelectItem: (() -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Setup TableView
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

    // Layout TableView
    tableView.frame = view.bounds
    view.addSubview(tableView)
    tableView.snapToSuperview()
  }

  /// DataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = items[indexPath.row]
    return cell
  }

  /// Delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    onDidSelectItem?()
  }
}
