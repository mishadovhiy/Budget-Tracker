//
//  WatchConectivityService.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 03.05.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit
//error:
//- sending from watch to iphone: ok
//- ios received and ios sent
//- error: watchos not received
///== delegate error
class WatchConectivityService:WKInterfaceController, WCSessionDelegate {
    var messageReceived:((_ data:[String : Any])->())? = nil
    
    init(messageReceived: @escaping (_: [String : Any]) -> Void) {
      //  self.messageReceived = messageReceived
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message, " watchosfweqwe ")
        messageReceived?(message)
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if error == nil {
            askUsername()
        } else {
            print(error)
        }
        
    }
    

    private var message:[String:Any] = [:]
    
    func askUsername() {
        DispatchQueue.main.async {
            if WCSession.default.isReachable {
                let message = ["wait": "username"]
                print(message, " rtegfwergthry ")
                //WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
                WCSession.default.delegate = self
             //   WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
                WCSession.default.sendMessage(message) { reply in
                    print(reply, " ythrtgerfed")
                }
                
            } else if WCSession.default.activationState == .notActivated {
                WCSession.default.delegate = self
                WCSession.default.activate()
            }
        }
    }
}

