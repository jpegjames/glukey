//
//  DexcomHelper.swift
//  GluKey
//
//  Created by James Pierce on 6/28/18.
//  Copyright © 2018 James Pierce. All rights reserved.
//

import Foundation

class DexcomHelper {
    // Default Dexcom variables
    //
    static let baseURLs:      Array = [
        "https://share1.dexcom.com/",
        "https://shareous1.dexcom.com/"
    ]
    static let maxAccountIndex: Int = baseURLs.count - 1    // max index for base URLs (2 URLs -> max index = 1)
    static var accountIndex:    Int = 0                     // accountIndex is increased by getSessionIdFromDexcom
    static var sessionID:    String = ""                    // stores sessionID for authenication from Dexcom
    
    
    // Returns Dexcom authenication URL for correct account type
    //
    static func authenticateURL() -> String {
        return "\(baseURL())ShareWebServices/Services/General/LoginPublisherAccountByName"
    }
    
    
    // Returns Dexcom URL for glucose values for correct account type
    //
    static func glucoseValuesURL() -> String {
        let maxCount:   Int = 288   // 24 * 60 / 5
        let minutes:    Int = 1440  // 24 * 60
        
        return "\(baseURL())ShareWebServices/Services/Publisher/ReadPublisherLatestGlucoseValues?sessionID=\(self.sessionID)&minutes=\(minutes)&maxCount=\(maxCount)"
    }
    
    
    // Returns Dexcom base URL determined by trying account type
    //
    static func baseURL() -> String {
        if accountIndex > maxAccountIndex {
            accountIndex = 0
        }
        
        print("Dexcom base url index: \(accountIndex)")
        return baseURLs[accountIndex]
    }
    
    
    // Resets accountIndex so that Glukey will check all base URLs (if necessary)
    //
    static func resetAccountType() {
        print("Resetting Dexcom base url index")
        accountIndex = 0
    }
}
