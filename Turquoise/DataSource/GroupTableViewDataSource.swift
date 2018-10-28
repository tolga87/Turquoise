import Foundation
import UIKit

typealias GroupTableViewDataSourceUpdateCallback = () -> Void
typealias GroupTableViewDataSourceProgressUpdateCallback = () -> Void
typealias GroupTableViewDataSourceArticleSelectionCallback = (ArticleHeaders, IndexPath) -> Void

protocol TQGroupTableViewDataSourceInterface : UITableViewDataSource, UITableViewDelegate {
    func numberOfArticles() -> Int
    func articleHeadersAtIndexPath(_ indexPath: IndexPath) -> ArticleHeaders
}

class GroupTableViewDataSource : NSObject {
    let groupManager: GroupManager
    var updateCallback: GroupTableViewDataSourceUpdateCallback?
    var progressUpdateCallback: GroupTableViewDataSourceProgressUpdateCallback?
    var articleSelectionCallback: GroupTableViewDataSourceArticleSelectionCallback?

    public init(groupManager: GroupManager) {
        self.groupManager = groupManager
        super.init()

        self.groupManager.groupHeadersUpdateCallback = {
            self.updateCallback?()
        }
        self.groupManager.groupHeadersProgressUpdateCallback = {
            self.progressUpdateCallback?()
        }

        self.refreshGroup()
    }

    private func refreshGroup() {
        self.groupManager.downloadGroupHeaders()
    }
}

extension GroupTableViewDataSource: TQGroupTableViewDataSourceInterface {

    // MARK: - TQGroupTableViewDataSourceInterface

    func numberOfArticles() -> Int {
        return self.groupManager.articles?.count ?? 0
    }

    func articleHeadersAtIndexPath(_ indexPath: IndexPath) -> ArticleHeaders {
        guard
            let articleForest = self.groupManager.articleForest,
            indexPath.section == 1, indexPath.row < articleForest.count else {
                fatalError("Invalid index path in TQGroupTableViewDataSource.")
        }

        return articleForest[indexPath.row].headers
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        // Section 0: "Loading" cell
        // Section 1: Article rows
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.groupManager.isLoading ? 1 : 0
        case 1:
            guard !self.groupManager.isLoading else {
                return 0
            }
            return self.groupManager.articles?.count ?? 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Loading...
            let cell = tableView.dequeueReusableCell(withIdentifier: TQArticleHeaderTableViewLoadingCell.reuseId,
                                                     for: indexPath) as! TQArticleHeaderTableViewLoadingCell
            cell.backgroundColor = .articleHeaderDarkBackgroundColor
            cell.selectionStyle = .none

            var progressString: String?
            if let progress = self.groupManager.downloadProgress {
                let numItems = progress.maxItemId - progress.minItemId + 1
                if numItems > 0 &&
                    progress.minItemId <= progress.maxItemId &&
                    progress.minItemId <= progress.currentItemId &&
                    progress.currentItemId <= progress.maxItemId {
                        let itemNo = progress.currentItemId - progress.minItemId + 1
                        progressString = "\(itemNo) of \(numItems)"
                }
            }

            if let progressString = progressString {
                cell.title = "Loading (\(progressString))..."
            } else {
                cell.title = "Loading..."
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: TQArticleHeaderTableViewCell.reuseId,
                                                 for: indexPath) as! TQArticleHeaderTableViewCell
        let articleHeaders = self.articleHeadersAtIndexPath(indexPath)

        cell.articleTitleLabel.text = articleHeaders.subject.tq_decodedString
        cell.articleSenderLabel.text = articleHeaders.from.tq_decodedString
        let isArticleRead = ReadArticleManager.sharedInstance.isArticleRead(articleHeaders.messageId)
        cell.articleTitleLabel.textColor = isArticleRead ? Consts.readArticleTitleColor : Consts.unreadArticleTitleColor

        let isEvenRow = (indexPath.row % 2 == 0)
        cell.backgroundColor = isEvenRow ? .articleHeaderDarkBackgroundColor : .articleHeaderLightBackgroundColor
        cell.paddingLevel = articleHeaders.references.count
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            // `Loading` cell.
            return nil
        }
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let articleHeaders = self.articleHeadersAtIndexPath(indexPath)
        self.articleSelectionCallback?(articleHeaders, indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

private extension GroupTableViewDataSource {
    struct Consts {
        static let unreadArticleTitleColor = UIColor.white
        static let readArticleTitleColor = UIColor(white: 0.5, alpha: 1)
    }
}
