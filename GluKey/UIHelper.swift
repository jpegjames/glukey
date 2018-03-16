//
//  UIHelper.swift
//  GluKey
//
//  Created by James Pierce on 3/16/18.
//  Copyright © 2018 James Pierce. All rights reserved.
//

import Foundation

class UIHelper {
    
    // -----------------------------
    // UI Helpers
    // -----------------------------
    // Return if UI is dark
    //
    static func isDarkUI() -> Bool {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
    }
}
