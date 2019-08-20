//
//  File.swift
//  SearchTweet
//
//  Created by Priyam Dutta on 18/08/19.
//  Copyright © 2019 Priyam Dutta. All rights reserved.
//

import Foundation
import RxSwift

final class KeyboardUtility {
    class func keyboardHeightObservable() -> Observable<CGFloat> {
        return Observable
            .from([
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).map { notification -> CGFloat in
                    (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                },
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).map { _ -> CGFloat in 0 }
                ])
            .merge()
    }
}

final class DateFormattingUtility {
    
    static func getDateFromString(_ date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss +SSSS yyyy"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: date) ?? Date()
    }
    
    static func getIntervalDifference(_ date: Date) -> String {
        let now = Date()
        let deltaBetweenDates = now.timeIntervalSince(date)
        let minutesBetweenDates = deltaBetweenDates / 60
        let fullDay: Double = 24 * 60
        
        switch minutesBetweenDates{
        case 0 ..< 1:
            return "now"
        case 1 ..< 60:
            return "\(Int(minutesBetweenDates))min"
        case 60 ..< fullDay:
            return "\(Int(minutesBetweenDates / 60))h"
        default:
            return "\(Int(minutesBetweenDates / fullDay))days"
            
        }
    }
    
    static func addDays(_ date: Date, days: Int) -> Date {
        return (Calendar.current.date(byAdding: .day, value: days, to: date)!)
    }
}

final class Utility {
    static func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat{
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
}
