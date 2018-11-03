//
//  BackgroundTimeManager.swift
//  Turquoise
//
//  Created by tolga on 11/3/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

typealias BackgroundTimeCallback = () -> Void

class BackgroundTimeManager {
    static let sharedInstance = BackgroundTimeManager()
    private var tasks: [DelayedTask] = []
    private var timers: [Timer] = []

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func addObserver(withDelay delay: TimeInterval, callback: @escaping BackgroundTimeCallback) {
        guard delay > 0 else { return }

        let task = DelayedTask(delay: delay, callback: callback)
        self.tasks.append(task)
    }

    @objc
    func didEnterBackground() {
        self.tasks.forEach { task in
            let timer = Timer.scheduledTimer(withTimeInterval: task.delay, repeats: false) { timer in
                DispatchQueue.main.async {
                    task.callback()
                }
            }
            self.timers.append(timer)
        }
    }

    @objc
    func didBecomeActive() {
        self.timers.forEach { timer in
            timer.invalidate()
        }
        self.timers = []
    }
}

private extension BackgroundTimeManager {
    struct DelayedTask {
        let delay: TimeInterval
        let callback: BackgroundTimeCallback

        init(delay: TimeInterval, callback: @escaping BackgroundTimeCallback) {
            self.delay = delay
            self.callback = callback
        }
    }
}
