//
//  NNTPResponse.swift
//  Turquoise
//
//  Created by tolga on 7/8/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

class NNTPResponse : NSObject {
    let string: String
    private(set) var code: Int = 0
    private(set) var body: String = ""

    init(string: String) {
        self.string = string
        super.init()
        self.parse()
    }

    func parse() {
        guard !self.string.isEmpty else {
            return
        }

        let components = self.string.components(separatedBy: .whitespacesAndNewlines)

        guard
            let firstComponent = components.first,
            let code = Int(firstComponent) else {
                return
        }

        self.code = code
        let bodyComponents = Array(components.dropFirst())
        self.body = bodyComponents.joined(separator: " ")
    }

    override var description: String {
        return "\(super.description) `\(self.string)`"
    }
}

protocol ResponseType {
    func informative() -> Bool
    func ok() -> Bool
    func okSoFar() -> Bool
    func failed() -> Bool
    func error() -> Bool
}

extension NNTPResponse : ResponseType {
    func informative() -> Bool {
        return self.code.firstDigit == 1
    }

    func ok() -> Bool {
        return self.code.firstDigit == 2
    }

    func okSoFar() -> Bool {
        return self.code.firstDigit == 3
    }

    func failed() -> Bool {
        return self.code.firstDigit == 4
    }

    func error() -> Bool {
        return self.code.firstDigit == 5
    }
}

extension Int {
    var firstDigit: Int {
        return (self / 100)
    }

}
