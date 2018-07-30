//
//  NNTPResponseFactory.swift
//  Turquoise
//
//  Created by tolga on 7/8/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

class NNTPResponseFactory {
    private static func getCodeFrom(string: String) -> Int? {
        guard
            let codeComponent = string.components(separatedBy: .whitespacesAndNewlines).first,
            let code = Int(codeComponent) else {
                return nil
        }

        return code
    }

    static func responseFrom(string: String) -> NNTPResponse? {
        guard let code = self.getCodeFrom(string: string) else {
            return nil
        }

        guard let responseCode = ResponseCode(rawValue: code) else {
            return NNTPResponse(string: string)
        }

        switch responseCode {
        case .Headers:
            return NNTPGroupResponse(string: string)

        case .MultiLine:
            return NNTPMultiLineResponse(string: string)

        case .Body:
            return NNTPBodyResponse(string: string)
        }

    }
}

enum ResponseCode: Int {
    case Headers = 211
    case MultiLine = 215
    case Body = 222
}
