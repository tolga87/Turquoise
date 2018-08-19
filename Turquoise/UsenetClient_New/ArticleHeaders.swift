//
//  ArticleHeader.swift
//  Turquoise
//
//  Created by tolga on 7/15/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

class ArticleHeaders: NSObject {
    static let requiredFields = ["From", "Subject", "Message-ID", "Newsgroups"]

    var fields: [String: Any] = [:]

    var from: String! { return self.fieldValue(forRequiredField: "From") }
    var subject: String! { return self.fieldValue(forRequiredField: "Subject") }
    var messageId: String! { return self.fieldValue(forRequiredField: "Message-ID") }
    var newsgroup: String! { return self.newsgroups.first! }

    private(set) var newsgroups: [String] = []
    private(set) var references: [String] = []

    // MARK: - JSONConvertible

    init?(json: JSON) {
        super.init()
        self.fields = json
        self.parseNewsgroups()
        self.parseReferences()
    }

    func convertToJson() -> JSON? {
        return self.fields
    }

    init?(response: NNTPResponse) {
        guard response.ok() else {
            return nil
        }

        super.init()

        let lineBreakSequence = "\r\n"
        let lines = response.string.components(separatedBy: lineBreakSequence)
        let fieldLines = lines[1...]

        for line in fieldLines {
            guard let separatorIndex = line.firstIndex(of: ":") else {
                continue
            }

            let fieldName = line.substring(to: separatorIndex)
            let fieldValue = line.substring(from: line.index(after: separatorIndex)).trimmingCharacters(in: .whitespacesAndNewlines)
            self.fields[fieldName] = fieldValue
        }

        // Make sure we have all the required fields.
        for requiredField in ArticleHeaders.requiredFields {
            guard let _ = self.fields[requiredField] else {
                return nil
            }
        }

        self.parseNewsgroups()
        self.parseReferences()

        guard !self.newsgroups.isEmpty else {
            return nil
        }
    }

    private func fieldValue(forRequiredField requiredField: String) -> String! {
        return (self.fields[requiredField] as? String)!
    }

    private func parseNewsgroups() {
        guard let newsgroupsString = self.fields["Newsgroups"] as? String, !newsgroupsString.isEmpty else {
            return
        }
        self.newsgroups = newsgroupsString.tq_newlineStrippedString.components(separatedBy: CharacterSet.whitespaces)
    }

    private func parseReferences() {
        if let referencesString = self.fields["References"] as? String, referencesString.count > 0 {
            self.references = referencesString.components(separatedBy: CharacterSet.whitespaces)
        }
    }

    override var description: String {
        var string = "\(super.description)\n"

        self.fields.forEach {
            let (key, value) = $0
            string += "\(key): `\(value)`\n"
        }
        return string
    }
}
