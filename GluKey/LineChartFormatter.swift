//
//  LineChartFormatter.swift
//  Glookey
//
//  Created by James Pierce on 5/26/17.
//  Copyright © 2017 James Pierce. All rights reserved.
//


import Foundation
import Charts

@objc(LineChartFormatter)
public class LineChartFormatter: NSObject, IAxisValueFormatter{
    
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = NSDate(timeIntervalSince1970: value)
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.hour, .minute], from: date as Date)
        
        return formatDateToString(hour: comp.hour!, minute: comp.minute!)
    }
    
    
    
    // Returns formatted date
    // NOTE: Possibly move to reusable helper if needed elsewhere
    //
    public func formatDateToString(hour:Int, minute:Int) -> String {
        var hourString: String
        var minuteString: String
        var ampmString: String = ""
        
        // quick hack to add leading 0 to minutes
        if minute < 10 {
            minuteString = "0" + String(describing: minute)
        } else {
            minuteString = String(describing: minute)
        }
        
        // 12 Hour option
        if UserDefaults.standard.bool(forKey: "use12HourClock") {
            if hour > 12 {
                hourString = String(describing: (hour - 12))
                ampmString = " " + Calendar.current.pmSymbol
            } else {
                hourString = String(describing: hour)
                ampmString = " " + Calendar.current.amSymbol
            }
            
        } else {
            hourString = String(describing: hour)
        }
        
        return hourString + ":" + minuteString + ampmString
    }
}
