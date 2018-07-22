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
        // NOTE This method will fail if glucoseData is empty, however it should not be called by the controller if it is empty
        //
        return Constants.glucoseData[0]
    }
    
    
    // Return if glucose reading is not old (i.e. valid)
    //
    static func validGuloseReading() -> Bool {
        if Constants.glucoseData.isEmpty == false {
            let validDatetimeRange = NSDate(timeIntervalSinceNow: Constants.oldDataSeconds)
            let currentReadingDate = currentGulcoseReading()["Date"] as! Date
            
            switch currentReadingDate.compare(validDatetimeRange as Date) {
            case .orderedAscending     :   return false   // value older than Date comparison
            case .orderedDescending    :   return true    // value less than Date comparison
            case .orderedSame          :   return true
            }
            
        } else {
            return false
        }
    }
    
}
