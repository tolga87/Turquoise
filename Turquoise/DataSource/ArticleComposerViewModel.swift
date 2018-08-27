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
    var subject: String? { get }
    var body: String? { get }
    var referenceMessageIds: [String] { get }
    var referenceMessageSender: String? { get }
    var completionBlock: (() -> Void)? { get set }

    func accept(subject: String, body: String)
    func cancel()
}

class ArticleComposerViewModel: ArticleComposerViewModelInterface {
    let groupManager: GroupManager
    let subject: String?
    let body: String?
    let referenceMessageIds: [String]
    let referenceMessageSender: String?

    var completionBlock: (() -> Void)?

    fileprivate static let subjectSectionHeight: CGFloat = 60
    fileprivate var subjectField: UITextField!
    fileprivate var bodyField: UITextView!

    init(groupManager: GroupManager, subject: String? = nil, body: String? = nil, referenceMessageIds: [String] = [], referenceMessageSender: String? = nil) {
        self.groupManager = groupManager
        self.subject = subject
        self.body = body
        self.referenceMessageIds = referenceMessageIds
        self.referenceMessageSender = referenceMessageSender
    }

    func cancel() {
        self.completionBlock?()
    }

    func accept(subject: String, body: String) {
        self.postMessage(subject: subject, body: body)
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

        var headers: [String : String] = [
            "Subject" : subject,
            "From" : userInfoString,
            "Newsgroups": self.groupManager.groupId
        ]

        let referencesString = self.referenceMessageIds.joined(separator: " ")
        if !referencesString.isEmpty {
            headers["References"] = referencesString
        }

        self.groupManager.postMessage(headers: headers, body: body) { messagePosted in
            print("Message posted: \(messagePosted)")
            self.completionBlock?()
        }
    }
}
