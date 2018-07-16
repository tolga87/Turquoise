//
//  ArticleHeader.swift
//  Turquoise
//
//  Created by tolga on 7/15/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

class ArticleHeaders {
    static let requiredFields = ["From", "Subject", "Message-ID"]

    var fields: [String: Any] = [:]

    var from: String! { return self.fieldValue(forRequiredField: "From") }
    var subject: String! { return self.fieldValue(forRequiredField: "Subject") }
    var messageId: String! { return self.fieldValue(forRequiredField: "Message-ID") }

    private(set) var references: [String] = []

    init?(response: NNTPResponse) {
        guard response.ok() else {
            return nil
        }

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

        if let referencesString = self.fields["References"] as? String, referencesString.count > 0 {
            self.references = referencesString.components(separatedBy: CharacterSet.whitespaces)
        }
    }

    private func fieldValue(forRequiredField requiredField: String) -> String! {
        return (self.fields[requiredField] as? String)!
    }
}
