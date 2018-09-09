//
//  TQArticleHeaderTableViewLoadingCell.swift
//  Turquoise
//
//  Created by tolga on 9/9/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class TQArticleHeaderTableViewLoadingCell : UITableViewCell {
    static let reuseId: String = "TQArticleHeaderTableViewLoadingCell"

    var title: String = "" {
        didSet {
            self.titleLabel.text = title
            self.spinner.startAnimating()
        }
    }

    private var spinner: UIActivityIndicatorView
    private var titleLabel: UILabel

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.spinner = UIActivityIndicatorView(style: .white)
        self.spinner.translatesAutoresizingMaskIntoConstraints = false
        self.spinner.startAnimating()

        self.titleLabel = UILabel()
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.textAlignment = .left
        self.titleLabel.font = UIFont.defaultFont(ofSize: 15)
        self.titleLabel.textColor = .readArticleTitleColor

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.spinner)
        self.contentView.addSubview(self.titleLabel)

        self.spinner.widthAnchor.constraint(equalToConstant: 20).isActive = true
        self.spinner.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.spinner.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        self.spinner.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true

        self.titleLabel.leadingAnchor.constraint(equalTo: self.spinner.trailingAnchor, constant: 10).isActive = true
        self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
