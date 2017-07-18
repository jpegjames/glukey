//
//  GlucoseHelper.swift
//  GluKey
//
//  Created by James Pierce on 5/26/17.
//  Copyright © 2017 James Pierce. All rights reserved.
//

import Foundation

class GlucoseHelper {
    
    // -----------------------------
    // Glucose Helpers
    // -----------------------------
    // Return current glucose value
    //
    static func currentGulcoseReading() -> Dictionary<String, Any> {
        if Constants.glucoseData.isEmpty == false {
            return Constants.glucoseData[0]
        } else {
            // This is incorrect
            return Constants.glucoseData[0]
        }
    }
    
    
    // Return if glucose reading is not old (i.e. valid)
    //
    static func validGuloseReading() -> Bool {
        if Constants.glucoseData.isEmpty == false {
            let twentyMinutesAgo = NSDate(timeIntervalSinceNow: -600) // 10 minutes
            let currentReadingDate = currentGulcoseReading()["Date"] as! Date
            
            switch currentReadingDate.compare(twentyMinutesAgo as Date) {
            case .orderedAscending     :   return false   // value older than 20 minutes
            case .orderedDescending    :   return true    // value less than 20 minutes
            case .orderedSame          :   return true
            }
            
            
        } else {
            return false
        }
    }
    
}
