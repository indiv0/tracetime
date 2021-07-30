//
//  Date.swift
//  Date
//
//  Created by Nikita Pekin on 2021-07-30.
//

import Foundation

extension Date {
    // https://stackoverflow.com/a/24090354
    init(_ string: String) {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        let date = fmt.date(from: string)!
        self.init(timeInterval: 0, since: date)
    }
    
    // https://gist.github.com/nbasham/c219d8c8c773d2c146c526dfccb4353b
    static func randomBetween(start: Date, end: Date) -> Date {
        var start1 = start
        var end1 = end
        if end < start {
            end1 = start
            start1 = end
        }
        let span = TimeInterval.random(in: start1.timeIntervalSinceNow...end1.timeIntervalSinceNow)
        return Date(timeIntervalSinceNow: span)
    }
}
