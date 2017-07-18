//
//  GlucoseGraphController.swift
//  Glookey
//
//  Created by James Pierce on 5/26/17.
//  Copyright © 2017 James Pierce. All rights reserved.
//

import Cocoa
import Charts

class GlucoseGraphController: NSViewController {
    // UI Variables
    //
    @IBOutlet weak var appMenuPopup:    NSPopUpButton!
    @IBOutlet weak var cgmChart:        LineChartView!
    @IBOutlet weak var glucoseValue:    NSTextField!
    @IBOutlet weak var glucoseTrend:    NSImageView!
    @IBOutlet weak var glucoseUnit:     NSTextField!
    @IBOutlet weak var timePopup:       NSPopUpButton!
    @IBOutlet weak var updatedAtLabel:  NSTextField!
    
    // Settings Storyboard View/Controller
    //
    let settingsStoryboard = NSStoryboard.init(name: "Main", bundle: nil)
    var settingsWindowController: NSWindowController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Nothing additional needed here at this time
    }
    
    
    override open func viewWillAppear() {
        // -----------------------------
        // Register UserDefaults
        // -----------------------------
        //
        UserDefaults.standard.register(defaults: [
            "useAnimations" : true,
            "userLow"       : Constants.userLowDefault,
            "userHigh"      : Constants.userHighDefault,
            "useMmol"       : Constants.useMmolDefault,
        ])
        
        
        // Set large glucose value and trend line
        //
        setLargeValue()
        
        
        // Build chart and set initial zoom
        //
        buildChart()
        setChartZoom()
        
        // Animate chart after popup
        // NOTE: animation should only be called on popup, not when building chart
        //
        if UserDefaults.standard.bool(forKey: "useAnimations") {
            cgmChart.animate(xAxisDuration: 1, easingOption: .easeInOutQuart)
        }
        
        // Set updated at value
        //
        setLastUpdateValue()
        
    }
    
    
    // -----------------------------
    // UI Event Handlers
    // -----------------------------
    
    // Handle zoom change
    //
    @IBAction func zoomPopupHandler(_ sender: Any) {
        setChartZoom()
    }
    
    
    // Handle app menu
    //
    @IBAction func appMenuHandler(_ sender: Any) {
        switch appMenuPopup.titleOfSelectedItem! {
        case "Settings…":
            settingsWindowController = settingsStoryboard.instantiateController(withIdentifier: "Settings") as! NSWindowController
            settingsWindowController.window?.makeKeyAndOrderFront(nil)
            
        case "Quit":
            NSApplication.shared().terminate(sender)
        default:
            print("unexpected case")
        }
        
    }
    
    
    
    // -----------------------------
    // Popover View Functions
    // -----------------------------
    
    // Sets large glucose value for popover
    // NOTE: This function is nearly identical to that in AppDelegate and should probably be refactored
    //
    func setLargeValue() {
        if Constants.glucoseData.isEmpty == false && GlucoseHelper.validGuloseReading() {
            if UserDefaults.standard.bool(forKey: "useMmol") {
                glucoseValue.stringValue = String(format:"%.01f", GlucoseHelper.currentGulcoseReading()["Value"] as! Double)
            } else {
                glucoseValue.stringValue = String(format:"%.f", GlucoseHelper.currentGulcoseReading()["Value"] as! Double)
            }
            
            self.glucoseTrend.image = NSImage(named: "popupIcon-\(GlucoseHelper.currentGulcoseReading()["Trend"]!)")
        } else {
            glucoseValue.stringValue = "---"
            self.glucoseTrend.image = nil // possibly change to question mark?
        }
        
        
        // Set proper unit
        //
        if UserDefaults.standard.bool(forKey: "useMmol") {
            glucoseUnit.stringValue = "mmol/l"
        } else {
            glucoseUnit.stringValue = "mg/dl"
        }
        
        // Dynamically move glucose units to edge of value
        //
        glucoseValue.sizeToFit()
        let defaultFrame = glucoseUnit.frame
        glucoseUnit.frame = CGRect(x: glucoseValue.frame.maxX, y: defaultFrame.minY, width: defaultFrame.width, height: defaultFrame.height)
    }
    
    
    // Builds and render chart
    //
    func buildChart() {
        // Colors
        //
        let warningColor        = NSUIColor.red
        let cautionColor        = NSUIColor.orange
        let safeColor           = NSUIColor(red: 0.051, green: 0.6275, blue: 0, alpha: 1.0)
        let endGradientColor    = NSUIColor(red: 0.051, green: 0.6275, blue: 0, alpha: 0) // or NSUIColor.clear
        
        
        // Chart settings
        //
        cgmChart.noDataText             = "No glucose data to display"
        cgmChart.gridBackgroundColor    = NSUIColor.white
        cgmChart.chartDescription?.text = "" // display nothing
        cgmChart.legend.enabled         = false
        cgmChart.xAxis.labelPosition    = .bottom
        cgmChart.leftAxis.enabled       = false
        cgmChart.rightAxis.enabled      = true
        cgmChart.rightAxis.spaceMin     = 10
        cgmChart.pinchZoomEnabled       = true // this is a little strange on macOS
        cgmChart.doubleTapToZoomEnabled = false
        cgmChart.scaleYEnabled          = false // prevent zooming in the Y direction
        cgmChart.autoScaleMinMaxEnabled = false // would prefer that it auto scales but has min range between min and max values
        
        // Define Y Axis height
        if UserDefaults.standard.bool(forKey: "useMmol") {
            cgmChart.rightAxis.axisMinimum = 0
            cgmChart.rightAxis.axisMaximum = 15 // Constants.userHigh + 5
        } else {
            cgmChart.rightAxis.axisMinimum = 40
            // cgmChart.rightAxis.axisMaximum = 250 // 210, 250, 300, or Constants.userHigh + 20
        }
        
        // Draw limit lines
        //
        let hLimitLine = ChartLimitLine(limit: UserDefaults.standard.double(forKey: "userHigh"))
        let lLimitLine = ChartLimitLine(limit: UserDefaults.standard.double(forKey: "userLow"))
        
        hLimitLine.lineWidth = 1
        lLimitLine.lineWidth = 1
        hLimitLine.lineColor = NSUIColor.yellow
        lLimitLine.lineColor = NSUIColor.red
        
        cgmChart.rightAxis.removeAllLimitLines()
        cgmChart.rightAxis.addLimitLine(hLimitLine)
        cgmChart.rightAxis.addLimitLine(lLimitLine)
        
        
        
        // Format x-axis labels
        //
        let formato:LineChartFormatter = LineChartFormatter()
        let xaxis:XAxis = XAxis()
        xaxis.valueFormatter = formato
        cgmChart.xAxis.valueFormatter = xaxis.valueFormatter
        
        
        // TODO: Add markers
        // https://github.com/PhilJay/MPAndroidChart/wiki/IMarker-Interface
        
        
        // Build arrays of ChartDataEntry
        // 
        var baseTimeStamp: Int   = Int(NSDate().timeIntervalSince1970)
        var baseDataArray: Array = [ChartDataEntry()]  // Easiest way to cast type in Array
        var cgmDataArray:  Array = [ChartDataEntry()]  // Easiest way to cast type in Array
        baseDataArray.remove(at: 0)                    // Clear empty ChartDataEntry
        cgmDataArray.remove(at: 0)                     // Clear empty ChartDataEntry
        
        // Build base array data so that 24 hours is always displayed on the x-axis
        for _ in 0 ... 288 {
            baseTimeStamp = baseTimeStamp - 300
            baseDataArray.append( ChartDataEntry(x: Double(baseTimeStamp), y: Double(0)) )
        }
        
        // Loop through glucose data to build array glucose ChartDataEntry
        // NOTE: the data must be entered in the correct order, so the array is reversed
        for datapoint in Constants.glucoseData.reversed() {
            cgmDataArray.append( ChartDataEntry(x: (datapoint["DT"] as! Double), y: (datapoint["Value"] as! Double)) )
        }
        
        
        // Create chart data sets from array
        let baseDataSet  = LineChartDataSet(values: baseDataArray, label: "")
        let cgmDataSet   = LineChartDataSet(values: cgmDataArray, label: "Glucose")
        
        
        // Data sets settings
        baseDataSet.axisDependency      = .right
        cgmDataSet.axisDependency       = .right
        cgmDataSet.colors               = [NSUIColor.black]
        cgmDataSet.circleColors         = [NSUIColor.black]
        cgmDataSet.circleRadius         = 2
        cgmDataSet.circleHoleRadius     = 1
        cgmDataSet.drawValuesEnabled    = false // turns off datapoint labels (possibly enable for 2 hours or less)

        
        // Draw gradient
        let gradientColors = [warningColor.cgColor, cautionColor.cgColor, safeColor.cgColor, endGradientColor.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.8, 0.4, 0.0] // Positioning of the gradient | NOTE: positions are relative to grid not area of line (this makes calculating the ratio MUCH easier)
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        cgmDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        cgmDataSet.drawFilledEnabled = true // Draw the Gradient
        
        
        // Apply data sets to chart (if any)
        if cgmDataSet.entryCount > 0 {
            let chartData = LineChartData()
            chartData.addDataSet(cgmDataSet)
            chartData.addDataSet(baseDataSet)
            cgmChart.data = chartData
            self.cgmChart.notifyDataSetChanged()
        }
        
    }
    
    
    // Sets chart zoom
    //
    func setChartZoom() {
        // Get numeric value (as Float) from selected popup option
        //
        let selectedRangeHours = Float(timePopup.titleOfSelectedItem!.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted))!
        
        // Determine chart scale by: 24 / selected hours
        //
        let scaleX = CGFloat(24 / selectedRangeHours)
        
        // Reset zoom
        //
        self.cgmChart.fitScreen()
        
        // Set zoom
        //
        self.cgmChart.zoom(scaleX: scaleX, scaleY: 1.0, x: 1000, y: 0)
    }
    
    
    // Sets the last updated value in popover
    //
    func setLastUpdateValue() {
        // Set string value
        //
        if Constants.glucoseData.isEmpty {
            updatedAtLabel.stringValue = ""
        } else {
            updatedAtLabel.stringValue = "updated " + TimeHelper.timeAgoSinceDate(date: GlucoseHelper.currentGulcoseReading()["Date"] as! NSDate, numericDates: true)
        }
        
        // Set string color
        //
        if GlucoseHelper.validGuloseReading() {
            updatedAtLabel.textColor = NSUIColor.black
        } else {
            updatedAtLabel.textColor = NSUIColor.red
        }
    }
    
}

