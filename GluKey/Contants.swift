//
//  Contants.swift
//  GluKey
//
//  Created by James Pierce on 5/26/17.
//  Copyright © 2017 James Pierce. All rights reserved.
//

import Cocoa
import Foundation

struct Constants {
    
    // "Global" vars
    //
    static var popover                      = NSPopover()
    static var glucoseData:         Array   = [[String: Any]]()
    static let statusIconBase:      String  = "statusIcon-"
    static var errorMessage:        String  = ""
    static var sensorCalibration:   Bool    = false
    static var sensorExpired:       Bool    = false
    static var sensorOutOfRange:    Bool    = false
    
    
    // Notification vars
    //
    static var acceptedLevelNotice:     Bool = false
    static var acceptedOldDataNotice:   Bool = false
    static var shownLevelNotice:        Bool = false
    static var shownOldDataNotice:      Bool = false
    
    
    // Default UserDefaults values
    //
    static let userLowDefault:          Double = 70
    static let userHighDefault:         Double = 180
    static let useMmolDefault:          Bool   = false
    static let notificationHighDefault: Int = 1
    static let notificationLowDefault:  Int = 1
    static let notificationOldDefault:  Int = 1
    
    
    // Possible future settings:
    // - Animations
    // - use12HourClock

}
