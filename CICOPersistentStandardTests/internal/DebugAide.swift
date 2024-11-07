//
//  DebugAide.swift
//  CICOPersistent
//
//  Created by lucky.li on 2019/12/28.
//  Copyright © 2019 cico. All rights reserved.
//

import Foundation

public class DebugAide {
    public static func currentTime() -> Date {
        return Date()
    }

    public static func showDuration(startTime: Date, customKey: String? = nil) {
        let endTime: Date = Date.init()
        let durationInS = endTime.timeIntervalSince(startTime)
#if DEBUG
        print("[#\(customKey ?? "DEBUG")#]: duration = \(durationInS)")
#endif
    }

    public static func showDuration(closure: () -> Void, customKey: String? = nil) {
        let startTime = self.currentTime()
        closure()
        self.showDuration(startTime: startTime, customKey: customKey)
    }
}
