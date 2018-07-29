//
//  ArticleComposerSubjectCell.swift
//  Turquoise
//
//  Created by tolga on 7/28/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class ArticleComposerSubjectCell: UITableViewCell {
    static let reuseId = "ArticleComposerSubjectCell"
    let subjectField: UITextField

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.subjectField = UITextField()
        self.subjectField.translatesAutoresizingMaskIntoConstraints = false
        self.subjectField.font = UIFont(name: "dungeon", size: 14)
        self.subjectField.textColor = .white

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .clear

        self.contentView.addSubview(self.subjectField)
        self.subjectField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                   constant: Consts.horizontalPadding).isActive = true
        self.subjectField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                    constant: -Consts.horizontalPadding).isActive = true
        self.subjectField.topAnchor.constraint(equalTo: self.contentView.topAnchor,
                                               constant: Consts.verticalPadding).isActive = true
        self.subjectField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,
                                                  constant: -Consts.verticalPadding).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.subjectField.text = nil
    }

    private struct Consts {
        static let horizontalPadding: CGFloat = 8
        static let verticalPadding: CGFloat = 4
    }
}
