//
//  NNTPMultiLineResponse.swift
//  Turquoise
//
//  Created by tolga on 7/29/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

class NNTPMultiLineResponse: NNTPResponse {
    private(set) var lines: [String] = []

    override func parse() {
        super.parse()

        // Drop the "\r\n.\r\n" at the end.
        self.lines = Array(self.string.components(separatedBy: "\r\n").dropFirst().dropLast().dropLast())
    }
}
