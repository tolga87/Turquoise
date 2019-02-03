//
//  SettingOption.swift
//  Turquoise
//
//  Created by tolga on 8/5/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

typealias SettingOptionCallback = ((UIViewController?) -> Void)

protocol SettingOptionProtocol {
    var title: String { get }
    var callback: SettingOptionCallback { get }
}

class SettingOption {
    let title: String
    let callback: SettingOptionCallback

    init(title: String, callback: @escaping SettingOptionCallback) {
        self.title = title
        self.callback = callback
    }
}
