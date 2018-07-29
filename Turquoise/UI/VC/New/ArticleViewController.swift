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
    var groupLabel: TQLabel = {
        let label = ArticleViewController.label()
        label.textColor = Consts.subtitleColor
        label.fontSize = Consts.subtitleFontSize
        return label
    }()
    var senderLabel: TQLabel = {
        let label = ArticleViewController.label()
        label.textColor = Consts.subtitleColor
        label.fontSize = Consts.subtitleFontSize
        return label
    }()
    var bodyField: TQTextField = {
        let field = TQTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = UIFont(name: "dungeon", size: Consts.bodyTextFontSize)
        field.textColor = Consts.bodyTextColor
        field.contentVerticalAlignment = .top
        return field
    }()

    init(dataSource: ArticleViewDataSource) {
        self.dataSource = dataSource

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource.updateCallback = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.bodyField.text = strongSelf.dataSource.bodyString
        }

        self.view.backgroundColor = .gray

        self.view.addSubview(self.scrollView)
        self.scrollView.topAnchor.constraint(equalTo: self.view.safeTopAnchor).isActive = true
        self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor).isActive = true

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
                                                 constant: 4).isActive = true
        self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                  constant: -4).isActive = true
        self.titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        self.contentView.addSubview(self.groupLabel)
        self.groupLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor,
                                             constant: 2).isActive = true
        self.groupLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                 constant: 4).isActive = true
        self.groupLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                  constant: -4).isActive = true
        self.groupLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        self.contentView.addSubview(self.senderLabel)
        self.senderLabel.topAnchor.constraint(equalTo: self.groupLabel.bottomAnchor,
                                             constant: 2).isActive = true
        self.senderLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                 constant: 4).isActive = true
        self.senderLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                  constant: -4).isActive = true
        self.senderLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        self.contentView.addSubview(self.bodyField)
        self.bodyField.topAnchor.constraint(equalTo: self.senderLabel.bottomAnchor,
                                            constant: 2).isActive = true
        self.bodyField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                constant: 4).isActive = true
        self.bodyField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                 constant: -4).isActive = true
        self.bodyField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,
                                               constant: -4).isActive = true

        self.titleLabel.text = self.dataSource.titleString
        self.groupLabel.text = self.dataSource.newsgroupString
        self.senderLabel.text = self.dataSource.senderString
        self.bodyField.text = self.dataSource.bodyString
    }

    private struct Consts {
        static let titleColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let subtitleColor: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        static let bodyTextColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

        static let titleFontSize: CGFloat = 13
        static let subtitleFontSize: CGFloat = 10
        static let bodyTextFontSize: CGFloat = 12
    }
}
