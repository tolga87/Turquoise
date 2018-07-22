import Foundation
import UIKit

typealias TQGroupTableViewDataSourceUpdateCallback = () -> Void

protocol TQGroupTableViewDataSourceInterface : UITableViewDataSource, UITableViewDelegate {
    func numberOfArticles() -> Int
    func articleHeadersAtIndexPath(_ indexPath: IndexPath) -> ArticleHeaders
}

class TQGroupTableViewDataSource : NSObject {
    static let loadingCellReuseId = "LoadingCell"
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
        guard let articles = self.groupManager.articles else {
            // Loading...
            return 1
        }
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.groupManager.articles != nil else {
            // Loading...
            let cell = tableView.dequeueReusableCell(withIdentifier: TQGroupTableViewDataSource.loadingCellReuseId,
                                                     for: indexPath)
            cell.backgroundColor = .articleHeaderDarkBackgroundColor

            if let textLabel = cell.textLabel {
                textLabel.textAlignment = .center
                textLabel.textColor = .readArticleTitleColor
                textLabel.text = "Loading..."
            }
            cell.selectionStyle = .none
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: TQArticleHeaderTableViewCell.reuseId,
                                                 for: indexPath) as! TQArticleHeaderTableViewCell
        let articleHeaders = self.articleHeadersAtIndexPath(indexPath)

        cell.articleTitleLabel.text = articleHeaders.subject.tq_decodedString
        cell.articleSenderLabel.text = articleHeaders.from.tq_decodedString

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
