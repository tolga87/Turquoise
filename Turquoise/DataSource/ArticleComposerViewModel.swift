//
//  ArticleComposerViewModel.swift
//  Turquoise
//
//  Created by tolga on 7/28/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

protocol ArticleComposerViewModelInterface: UITableViewDataSource, UITableViewDelegate {
    var subject: String { get }
    var completionBlock: (() -> Void)? { get set }

    func accept()
    func cancel()
}

class ArticleComposerViewModel: NSObject, ArticleComposerViewModelInterface {
    let subject: String
    var completionBlock: (() -> Void)?

    fileprivate static let subjectSectionHeight: CGFloat = 60
    fileprivate var subjectField: UITextField!
    fileprivate var bodyField: UITextView!

    init(subject: String) {
        self.subject = subject.hasPrefix("Re:") ? subject
                                                : "Re: \(subject)"
    }

    func cancel() {
        self.completionBlock?()
    }

    func accept() {
        guard
            let subjectText = self.subjectField.text,
            !subjectText.tq_whitespaceAndNewlineStrippedString.isEmpty,
            !self.bodyField.text.tq_whitespaceAndNewlineStrippedString.isEmpty else {
                return
        }

        self.completionBlock?()
    }

}

private enum ArticleComposerTableViewSection: Int, CaseIterable {
    case subject = 0
    case body = 1
}

extension ArticleComposerViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = ArticleComposerTableViewSection(rawValue: indexPath.section) else {
            fatalError("Unknown row in ArticleComposerViewModel")
        }

        switch section {
        case .subject:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleComposerSubjectCell.reuseId,
                                                     for: indexPath) as! ArticleComposerSubjectCell
            self.subjectField = cell.subjectField
            if self.subjectField.text == nil || self.subjectField.text == "" {
                self.subjectField.text = self.subject
            }
            return cell

        case .body:
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleComposerBodyCell.reuseId,
                                                     for: indexPath) as! ArticleComposerBodyCell
            self.bodyField = cell.bodyField
            return cell
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return ArticleComposerTableViewSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension ArticleComposerViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = ArticleComposerTableViewSection(rawValue: indexPath.section) else {
            return 0
        }

        switch section {
        case .subject:
            return ArticleComposerViewModel.subjectSectionHeight
        case .body:
            // TODO: This is hacky. Find a better solution.
            return tableView.frame.height
                - (tableView.safeAreaInsets.top + tableView.safeAreaInsets.bottom)
                - ArticleComposerViewModel.subjectSectionHeight
        }
    }
}
