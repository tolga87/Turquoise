//
//  ArticleComposerBodyCell.swift
//  Turquoise
//
//  Created by tolga on 7/28/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class ArticleComposerBodyCell: UITableViewCell {
    static let reuseId = "ArticleComposerBodyCell"
    let bodyField: UITextView

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.bodyField = UITextView()
        self.bodyField.translatesAutoresizingMaskIntoConstraints = false
        self.bodyField.backgroundColor = .clear
        self.bodyField.font = UIFont(name: "dungeon", size: 12)
        self.bodyField.textColor = .white

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .clear

        self.contentView.addSubview(self.bodyField)
        self.bodyField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                constant: Consts.horizontalPadding).isActive = true
        self.bodyField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                constant: -Consts.horizontalPadding).isActive = true
        self.bodyField.topAnchor.constraint(equalTo: self.contentView.topAnchor,
                                                constant: Consts.verticalPadding).isActive = true
        self.bodyField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,
                                                constant: -Consts.verticalPadding).isActive = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.bodyField.text = ""
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private struct Consts {
        static let horizontalPadding: CGFloat = 8
        static let verticalPadding: CGFloat = 4
    }
}
