import Foundation
import UIKit

class TQArticleHeaderTableViewCell : UITableViewCell {
    var paddingView: UIView
    var verticalBarView: UIView
    var articleTitleLabel: UILabel
    var articleSenderLabel: UILabel
    var paddingViewWidthConstraint: NSLayoutConstraint

    var paddingLevel: Int = 0 {
        didSet {
            self.paddingViewWidthConstraint.constant = CGFloat(4 * self.paddingLevel)
        }
    }

    static let reuseId: String = "TQArticleHeaderTableViewCell"

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.paddingView = UIView()
        self.paddingView.backgroundColor = .black

        self.verticalBarView = UIView()
        self.verticalBarView.backgroundColor = .articleHeaderCellVerticalBarColor

        self.articleTitleLabel = TQLabel(frame: .zero)
        // TODO: Implement read/unread colors.
        self.articleTitleLabel.textColor = .readArticleTitleColor

        self.articleSenderLabel = TQLabel(frame: .zero)
        self.articleSenderLabel.textColor = .articleSenderColor

        self.paddingViewWidthConstraint = self.paddingView.widthAnchor.constraint(equalToConstant: 0)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        for view in [paddingView, verticalBarView, articleTitleLabel, articleSenderLabel] {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(view)
        }

        self.paddingView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.paddingView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.paddingView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.paddingViewWidthConstraint.isActive = true

        self.verticalBarView.leadingAnchor.constraint(equalTo: self.paddingView.trailingAnchor).isActive = true
        self.verticalBarView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.verticalBarView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.verticalBarView.widthAnchor.constraint(equalToConstant: 4).isActive = true

        self.articleTitleLabel.leadingAnchor.constraint(equalTo: self.verticalBarView.trailingAnchor,
                                                        constant: 8).isActive = true
        self.articleTitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.articleTitleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.articleTitleLabel.bottomAnchor.constraint(equalTo: self.articleSenderLabel.topAnchor).isActive = true

        self.articleSenderLabel.leadingAnchor.constraint(equalTo: self.articleTitleLabel.leadingAnchor).isActive = true
        self.articleSenderLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.articleSenderLabel.topAnchor.constraint(equalTo: self.articleTitleLabel.bottomAnchor).isActive = true
        self.articleSenderLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true

        self.articleTitleLabel.heightAnchor.constraint(equalTo: self.articleSenderLabel.heightAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.paddingLevel = 0
    }
}
