//
//  Coordinator.swift
//  Turquoise
//
//  Created by tolga on 11/3/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator {
    func start()
    init(presenter: UIViewController)
}
