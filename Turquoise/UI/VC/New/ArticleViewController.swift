//
//  ArticleViewController.swift
//  Turquoise
//
//  Created by tolga on 7/22/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class ArticleViewController: UIViewController {
    let dataSource: ArticleViewDataSource
    let groupManager: GroupManager

    static func label() -> TQLabel {
        let label = TQLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        return scrollView
    }()

    var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black

        return view
    }()

    var titleLabel: TQLabel = {
        let label = ArticleViewController.label()
        label.textColor = Consts.titleColor
        label.fontSize = Consts.titleFontSize
        return label
    }()
    var metadataLabel: TQLabel = {
        let label = ArticleViewController.label()
        label.numberOfLines = 2
        label.textColor = Consts.subtitleColor
        label.fontSize = Consts.subtitleFontSize
        return label
    }()
    var bodyField: UITextView = {
        let field = UITextView()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isUserInteractionEnabled = false
        field.backgroundColor = .clear
        field.textColor = Consts.bodyTextColor
        field.font = UIFont(name: "dungeon", size: Consts.bodyTextFontSize)
        field.textContainerInset = .zero
        field.textContainer.lineFragmentPadding = 0
        return field
    }()
    var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .white)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()

    var bottomFillerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Consts.footerColor
        return view
    }()

    var footerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Consts.footerColor
        return view
    }()

    var replyField: TQLabel = {
        let field = TQLabel()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isUserInteractionEnabled = true
        field.numberOfLines = 1
        field.horizontalInset = 4
        field.fontSize = 12
        field.backgroundColor = Consts.replyBackgroundColor
        field.layer.borderColor = Consts.replyForegroundColor.cgColor
        field.textColor = Consts.replyForegroundColor
        field.layer.borderWidth = 1.0 / UIScreen.main.scale
        field.layer.cornerRadius = 2
        field.text = "Reply"
        return field
    }()

    var replyTapGestureRecognizer: UITapGestureRecognizer!

    init(dataSource: ArticleViewDataSource, groupManager: GroupManager) {
        self.dataSource = dataSource
        self.groupManager = groupManager
        super.init(nibName: nil, bundle: nil)

        self.replyTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapReply))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear

        self.dataSource.updateCallback = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.spinner.stopAnimating()
            strongSelf.bodyField.text = strongSelf.dataSource.bodyString
            strongSelf.replyTapGestureRecognizer.isEnabled = true
        }


        self.view.addSubview(self.bottomFillerView)
        self.bottomFillerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.bottomFillerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.bottomFillerView.topAnchor.constraint(equalTo: self.view.safeBottomAnchor).isActive = true
        self.bottomFillerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.view.addSubview(self.footerView)
        self.footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.footerView.bottomAnchor.constraint(equalTo: self.bottomFillerView.topAnchor).isActive = true
        self.footerView.heightAnchor.constraint(equalToConstant: Consts.footerHeight).isActive = true

        self.footerView.addSubview(self.replyField)
        self.replyField.topAnchor.constraint(equalTo: self.footerView.topAnchor,
                                             constant: Consts.replyFieldPadding).isActive = true
        self.replyField.leadingAnchor.constraint(equalTo: self.footerView.leadingAnchor,
                                                 constant: Consts.replyFieldPadding).isActive = true
        self.replyField.trailingAnchor.constraint(equalTo: self.footerView.trailingAnchor,
                                                  constant: -Consts.replyFieldPadding).isActive = true
        self.replyField.bottomAnchor.constraint(equalTo: self.footerView.bottomAnchor,
                                                constant: -Consts.replyFieldPadding).isActive = true
        self.replyField.addGestureRecognizer(self.replyTapGestureRecognizer)

        self.view.addSubview(self.scrollView)
        self.scrollView.topAnchor.constraint(equalTo: self.view.safeTopAnchor).isActive = true
        self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.footerView.topAnchor,
                                                constant: -4).isActive = true

        self.scrollView.addSubview(self.contentView)
        self.contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.contentView.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
        self.contentView.centerYAnchor.constraint(equalTo: self.scrollView.centerYAnchor).isActive = true

        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor,
                                             constant: 8).isActive = true
        self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                 constant: Consts.leadingPadding).isActive = true
        self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                  constant: -Consts.trailingPadding).isActive = true
        self.titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        self.contentView.addSubview(self.metadataLabel)
        self.metadataLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor,
                                             constant: 2).isActive = true
        self.metadataLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                 constant: Consts.leadingPadding).isActive = true
        self.metadataLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                  constant: -Consts.trailingPadding).isActive = true
        self.metadataLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        self.contentView.addSubview(self.bodyField)
        self.bodyField.topAnchor.constraint(equalTo: self.metadataLabel.bottomAnchor,
                                            constant: 2).isActive = true
        self.bodyField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                constant: Consts.leadingPadding).isActive = true
        self.bodyField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                 constant: -Consts.trailingPadding).isActive = true
        self.bodyField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,
                                               constant: -Consts.trailingPadding).isActive = true

        self.bodyField.addSubview(self.spinner)
        self.spinner.topAnchor.constraint(equalTo: self.bodyField.topAnchor,
                                          constant: 0).isActive = true
        self.spinner.centerXAnchor.constraint(equalTo: self.bodyField.centerXAnchor).isActive = true
        self.spinner.startAnimating()

        self.titleLabel.text = self.dataSource.titleString
        self.metadataLabel.text = "in \(self.dataSource.newsgroupString)\nby \(self.dataSource.senderString)"
        self.bodyField.text = self.dataSource.bodyString
    }

    @objc private func didTapReply() {
        let articleComposerViewModel = ArticleComposerViewModel(subject: self.dataSource.titleString)
        let articleComposer = ArticleComposerViewController(viewModel: articleComposerViewModel)
        let navController = UINavigationController(rootViewController: articleComposer)
        navController.navigationBar.barTintColor = .clear
        self.present(navController, animated: true, completion: nil)
    }

    private struct Consts {
        static let titleColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let subtitleColor: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        static let bodyTextColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let replyBackgroundColor = UIColor(black: 0.85)
        static let replyForegroundColor = UIColor(black: 0.45)
        static let footerColor = UIColor(black: 0.90)

        static let titleFontSize: CGFloat = 13
        static let subtitleFontSize: CGFloat = 10
        static let bodyTextFontSize: CGFloat = 12

        static let leadingPadding: CGFloat = 8
        static let trailingPadding: CGFloat = 8
        static let replyFieldPadding: CGFloat = 6
        static let footerHeight: CGFloat = 40
    }
}

extension UIColor {
    convenience init(black: CGFloat) {
        self.init(white: 1.0 - black, alpha: 1)
    }
}
