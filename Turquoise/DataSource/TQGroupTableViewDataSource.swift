import Foundation
import UIKit

typealias TQGroupTableViewDataSourceUpdateCallback = () -> Void

protocol TQGroupTableViewDataSourceInterface : UITableViewDataSource, UITableViewDelegate {
    func numberOfArticles() -> Int
    func articleHeadersAtIndexPath(_ indexPath: IndexPath) -> ArticleHeaders
}

class TQGroupTableViewDataSource : NSObject {
    let groupManager: GroupManager
    var updateCallback: TQGroupTableViewDataSourceUpdateCallback?

    public init(groupManager: GroupManager) {
        self.groupManager = groupManager
        super.init()

        self.groupManager.groupHeadersUpdateCallback = { success in
            self.updateCallback?()
        }
        self.refreshGroup()
    }

    private func refreshGroup() {
        self.groupManager.downloadGroupHeaders()
    }
}

extension TQGroupTableViewDataSource: TQGroupTableViewDataSourceInterface {

    // MARK: - TQGroupTableViewDataSourceInterface

    func numberOfArticles() -> Int {
        return self.groupManager.articles?.count ?? 0
    }

    func articleHeadersAtIndexPath(_ indexPath: IndexPath) -> ArticleHeaders {
        guard
            let articleForest = self.groupManager.articleForest,
            indexPath.section == 0, indexPath.row < articleForest.count else {
                fatalError("Invalid index path in TQGroupTableViewDataSource.")
        }

        return articleForest[indexPath.row].headers
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfArticles()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TQArticleHeaderTableViewCell.reuseId,
                                                 for: indexPath) as! TQArticleHeaderTableViewCell
        let articleHeaders = self.articleHeadersAtIndexPath(indexPath)

        cell.articleTitleLabel.text = articleHeaders.subject
        cell.articleSenderLabel.text = articleHeaders.from

        let isEvenRow = (indexPath.row % 2 == 0)
        cell.backgroundColor = isEvenRow ? .articleHeaderDarkBackgroundColor : .articleHeaderLightBackgroundColor
        cell.paddingLevel = articleHeaders.references.count
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

