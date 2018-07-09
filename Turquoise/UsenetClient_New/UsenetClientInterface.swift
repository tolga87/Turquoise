//
//  UsenetClientInterface.swift
//  Turquoise
//
//  Created by tolga on 7/8/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

typealias NNTPRequestCompletion = (NNTPResponse?) -> Void

protocol UsenetClientInterface : AnyObject {

    func makeRequest(_ request: NNTPRequest, completion: NNTPRequestCompletion?) -> Void
}
