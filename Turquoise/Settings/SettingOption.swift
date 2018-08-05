//
//  SettingOption.swift
//  Turquoise
//
//  Created by tolga on 8/5/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

protocol SettingOptionProtocol {
    var title: String { get }
    var callback: (() -> Void) { get }
}

class SettingOption {
    let title: String
    let callback: (() -> Void)

    init(title: String, callback: @escaping (() -> Void)) {
        self.title = title
        self.callback = callback
    }
}
