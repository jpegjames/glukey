//
//  Connectivity.swift
//  GluKey
//
//  Created by Abhimuralidharan on 6/28/18.
//  https://medium.com/@abhimuralidharan/checking-internet-connection-in-swift-3-1-using-alamofire-58ae45719f5
//

import Foundation
import Alamofire

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
