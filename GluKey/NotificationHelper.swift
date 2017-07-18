//
//  NotificationHelper.swift
//  GluKey
//
//  Created by James Pierce on 5/26/17.
//  Copyright © 2017 James Pierce. All rights reserved.
//

import Foundation

class NotificationHelper {
    
    
    // -----------------------------
    // Notification Helpers
    // -----------------------------
    //
    
    // Determine if can display high notice (returns boolean)
    //
    static func canDisplayHighNotice() -> Bool {
        // Set default
        UserDefaults.standard.register(defaults: ["notifyHigh": Constants.notificationHighDefault])
        
        //return !Constants.acceptedLevelNotice && UserDefaults.standard.bool(forKey: "notifyHigh")
        return !Constants.shownLevelNotice && UserDefaults.standard.bool(forKey: "notifyHigh")
    }
    
    
    // Determine if can display low notice (returns boolean)
    //
    static func canDisplayLowNotice() -> Bool {
        // Set default
        UserDefaults.standard.register(defaults: ["notifyLow": Constants.notificationLowDefault])
        
        //return !Constants.acceptedLevelNotice && UserDefaults.standard.bool(forKey: "notifyLow")
        return !Constants.shownLevelNotice && UserDefaults.standard.bool(forKey: "notifyLow")
    }
    
    
    // Determine if can display old data notice (returns boolean)
    //
    static func canDisplayOldDataNotice() -> Bool {
        // Set default
        UserDefaults.standard.register(defaults: ["notifyOld": Constants.notificationOldDefault])
        
        // return !Constants.acceptedNoDataNotice && UserDefaults.standard.bool(forKey: "notifyOld")
        return !Constants.shownOldDataNotice && UserDefaults.standard.bool(forKey: "notifyOld")
    }
    
    
    // Displays old data notice (if allowed)
    //
    static func oldData(notification: NSUserNotification) {
        // Get current value
        //
        let lastDate:NSDate = GlucoseHelper.currentGulcoseReading()["Date"] as! NSDate
        
        // TODO: move to function to setup notification defaults
        //
        notification.identifier = "glukey-notice"
        notification.hasActionButton = false
        notification.otherButtonTitle = "Dismiss"
        
        // Setup notification
        //
        let notificationCenter = NSUserNotificationCenter.default
        
        if canDisplayOldDataNotice() {
            print("Should display no data notification")
            
            // Manually Display the notification
            //
            notification.title = "Glucose Signal Loss"
            notification.subtitle = "Check CGM setup and settings"
            notification.informativeText = "Last data received over \(TimeHelper.timeAgoSinceDate(date:lastDate, numericDates:true))"
            notificationCenter.deliver(notification)
            
            // Do not display alert again (unless value goes back into normal range and then out again
            // This is not ideal. If this variable was set when the "Dismiss" button is pressed, then the time would update.
            // Possibly another fix would be to check to see if the notification is still on the screen and then change the informativeText
            Constants.shownOldDataNotice = true
        }
    }
    
    
    // Displays old data notice (if allowed)
    //
    static func checkLowHigh(notification: NSUserNotification) {
        
        // Setup notification
        let notificationCenter = NSUserNotificationCenter.default
        
        
        // TODO: move to function to setup notification defaults
        notification.identifier = "glukey-notice"
        notification.hasActionButton = false
        notification.otherButtonTitle = "OK"
        // notification.actionButtonTitle = "Action!"
        // notification.soundName = NSUserNotificationDefaultSoundName
        
        
        // Get current value
        let current_value = GlucoseHelper.currentGulcoseReading()["Value"] as! Double
        
        
        // Check to see if value is low and can be displayed
        if current_value <= UserDefaults.standard.double(forKey: "userLow") && canDisplayLowNotice() {
            
            notification.title = "Low Glucose"
            notification.subtitle = "" // clear other subtitles that may have been set by another GluKey notification
            notification.informativeText = "Check your blood sugar before taking any corrective actions"
            notificationCenter.deliver(notification)
            
            // Do not display alert again (unless value goes back into normal range and then out again
            Constants.shownLevelNotice = true
        }
        
        
        // Check to see if value is high and can be displayed
        if current_value >= UserDefaults.standard.double(forKey: "userHigh") && canDisplayHighNotice() {
            
            notification.title = "High Glucose"
            notification.subtitle = "" // clear other subtitles that may have been set by another GluKey notification
            notification.informativeText = "Check your blood sugar before making insulin decisions"
            notificationCenter.deliver(notification)
            
            // Do not display alert again (unless value goes back into normal range and then out again
            Constants.shownLevelNotice = true
        }
        
        
        // Resets high/low notices
        if current_value > UserDefaults.standard.double(forKey: "userLow") && current_value < UserDefaults.standard.double(forKey: "userHigh") {
            // Reset accepted level notice so that next alert will be shown
            Constants.acceptedLevelNotice = false
            
            // Reset both shown notices
            Constants.shownLevelNotice = false
            Constants.shownOldDataNotice = false
            
            // Remove all past notifications
            notificationCenter.removeAllDeliveredNotifications()
        }
        
    }
}
