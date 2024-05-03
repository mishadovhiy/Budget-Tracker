//
//  WatchConectivityService.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 03.05.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchConectivityService:WCSessionDelegate {
    var messageReceived:((_ data:[String : Any])->())? = nil
    
    init(messageReceived:@escaping (_ data:[String : Any])->()) {
        WCSession.default.delegate = self
        self.messageReceived = messageReceived
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message, " watchosfweqwe ")
        messageReceived?(message)
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
            
    }
    
    func isEqual(_ object: Any?) -> Bool {
        true
    }
    
    var hash: Int = 0
    
    var superclass: AnyClass?
    
    func `self`() -> Self {
        self
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        .none
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        .none
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        .none
    }
    
    func isProxy() -> Bool {
        true
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        true
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        true
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        true
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        true
    }
    
    var description: String = ""
    
    func askUsername() {
        if WCSession.default.isReachable {
            let message = ["wait": "username"]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
            print(message, " rtegfwergthry")
        } else {
            fatalError()
        }
    }
}

