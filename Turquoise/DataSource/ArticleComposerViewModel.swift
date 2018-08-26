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
    let groupManager: GroupManager

    var completionBlock: (() -> Void)?

    fileprivate static let subjectSectionHeight: CGFloat = 60
    fileprivate var subjectField: UITextField!
    fileprivate var bodyField: UITextView!

    init(subject: String, groupManager: GroupManager) {
        self.subject = subject
        self.groupManager = groupManager
    }

    func cancel() {
        self.completionBlock?()
    }

    func accept(subject: String, body: String) {
        let sanitizedSubject = subject.tq_whitespaceAndNewlineStrippedString
        let sanitizedBody = body.tq_whitespaceAndNewlineStrippedString
        guard !sanitizedSubject.isEmpty, !sanitizedBody.isEmpty else {
            return
        }

        self.postMessage(subject: sanitizedSubject, body: sanitizedBody)
    }

    private func postMessage(subject: String, body: String) {
        let userInfoManager = TQUserInfoManager.sharedInstance

        let userInfoString: String
        if let email = userInfoManager.email, let fullName = userInfoManager.fullName {
            userInfoString = "\(email) (\(fullName))"
        } else if let email = userInfoManager.email {
            userInfoString = email
        } else if let fullName = userInfoManager.fullName {
            userInfoString = fullName
        } else {
            userInfoString = "<Unknown User>"
        }

        let headers: [String : String] = [
            "Subject" : subject,
            "From" : userInfoString,
            "Newsgroups": self.groupManager.groupId
        ]
        self.groupManager.postMessage(headers: headers, body: body) { messagePosted in
            print("Message posted: \(messagePosted)")
            self.completionBlock?()
        }
    }
}
