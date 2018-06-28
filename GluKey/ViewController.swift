//
//  ViewController.swift
//  GluKey
//
//  Created by James Pierce on 5/26/17.
//  Copyright © 2017 James Pierce. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var dexcomUsername: NSTextField!
    @IBOutlet weak var dexcomPassword: NSSecureTextField!
    @IBOutlet weak var lowInput: NSTextField!
    @IBOutlet weak var highInput: NSTextField!
    @IBOutlet weak var unitPopup: NSPopUpButton!
    @IBOutlet weak var notifyHigh: NSButton!
    @IBOutlet weak var notifyLow: NSButton!
    @IBOutlet weak var notifyOld: NSButton!
    
    @IBAction func saveSettings(_ sender: Any) {
        
        // -----------------------------
        // Save Setting Values
        // -----------------------------
        //
        
        // Dexcom Username/Password
        //
        let keychain = KeychainSwift()
        keychain.set(dexcomPassword.stringValue, forKey: "GluKey Password")
        UserDefaults.standard.set(dexcomUsername.stringValue, forKey: "dexcomUsername")
        DexcomHelper.resetAccountType()
        
        
        // Chart Settings
        //
        UserDefaults.standard.set(lowInput.stringValue,                         forKey: "userLow")
        UserDefaults.standard.set(highInput.stringValue,                        forKey: "userHigh")
        UserDefaults.standard.set((unitPopup.titleOfSelectedItem! == "mmol/l"), forKey: "useMmol")

        
        // Chart Settings
        //
        UserDefaults.standard.set(notifyHigh.stringValue, forKey: "notifyHigh")
        UserDefaults.standard.set(notifyLow.stringValue,  forKey: "notifyLow")
        UserDefaults.standard.set(notifyOld.stringValue,  forKey: "notifyOld")
        
        // Close Window
        //
        self.view.window?.close()
        
        // Reset timer and reload data in case settings affect graph
        //
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        appDelegate.timerInterval = 1
        appDelegate.resetGlucoseTimer()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidAppear() {
        // Close popover since the settings won't match until reopened / reloaded
        //
        if Constants.popover.isShown {
            Constants.popover.close()
        }
        
        // -----------------------------
        // Register UserDefaults
        // -----------------------------
        //
        UserDefaults.standard.register(defaults: [
            "useAnimations" : true,                         // future option
            "use12HourClock": true,                         // future option
            "userLow"       : Constants.userLowDefault,
            "userHigh"      : Constants.userHighDefault,
            "useMmol"       : Constants.useMmolDefault,
            "notifyHigh"    : Constants.notificationHighDefault,
            "notifyLow"     : Constants.notificationLowDefault,
            "notifyOld"     : Constants.notificationOldDefault
            ])
        
        
        
        
        // -----------------------------
        // Display Setting Values
        // -----------------------------
        //
        
        // Dexcom Username/Password
        //
        let keychain = KeychainSwift()
        
        if let username = UserDefaults.standard.object(forKey: "dexcomUsername") as? String {
            dexcomUsername.stringValue = username
        }
        
        if let password = keychain.get("GluKey Password") {
            dexcomPassword.stringValue = password
        }
        
        
        // Chart Settings
        //
        lowInput.stringValue    = UserDefaults.standard.string(forKey: "userLow")!
        highInput.stringValue   = UserDefaults.standard.string(forKey: "userHigh")!
        
        if UserDefaults.standard.bool(forKey: "useMmol") {
            unitPopup.selectItem(withTitle: "mmol/l")
        } else {
            unitPopup.selectItem(withTitle: "mg/dl")
        }
        
        
        // Notifications
        //
        notifyHigh.state    = UserDefaults.standard.integer(forKey: "notifyHigh")
        notifyLow.state     = UserDefaults.standard.integer(forKey: "notifyLow")
        notifyOld.state     = UserDefaults.standard.integer(forKey: "notifyOld")
        
      
    }


}

