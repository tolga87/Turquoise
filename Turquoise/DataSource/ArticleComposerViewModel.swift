//
//  ArticleComposerViewModel.swift
//  Turquoise
//
//  Created by tolga on 7/28/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

protocol ArticleComposerViewModelInterface: AnyObject {
    var subject: String { get }
    var completionBlock: (() -> Void)? { get set }

    func accept(subject: String, body: String)
    func cancel()
}

class ArticleComposerViewModel: ArticleComposerViewModelInterface {
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

    func accept(subject: String, body: String) {
        guard
            !subject.tq_whitespaceAndNewlineStrippedString.isEmpty,
            !body.tq_whitespaceAndNewlineStrippedString.isEmpty else {
                return
        }

        self.completionBlock?()
    }

}
