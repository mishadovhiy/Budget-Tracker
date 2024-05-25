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
class WatchConectivityService:NSObject, WCSessionDelegate {
    var messageReceived:((_ data:[String : Any])->())? = nil
    private let session: WCSession

    init(messageReceived: @escaping (_: [String : Any]) -> Void) {
        self.session = .default

        self.messageReceived = messageReceived
        super.init()
        do {
            try session.updateApplicationContext(["key": "value"])
        } catch {
            print("Failed to update application context: \(error)")
        }
        session.delegate = self
        session.activate()
    }
    
//    override func awake(withContext context: Any?) {
//        super.awake(withContext: context)
//        WCSession.default.delegate = self
//        WCSession.default.activate()
//    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message, " watchosfweqwe ")
        messageReceived?(message)
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print(error, " erfwd ", activationState.rawValue)
        session.transferUserInfo(["asas":"fd"])
        if error == nil {
            do {
                try session.updateApplicationContext(["key": "value"])
            } catch {
                print("Failed to update application context: \(error)")
            }
            
          //  session.delegate = self
        } else {
            print(error, " activation error")
        }
        
    }
    
    
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("applicationContext: ", applicationContext)
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("didReceiveMessageData ", messageData.base64EncodedString())

    }
    
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print(message, " didReceiveMessagedidReceiveMessagedidReceiveMessage")
        replyHandler(["reply":"value"])

    }

    private var message:[String:Any] = [:]
    
    func askUsername() {
        print(session.isReachable, " erfwd")
        DispatchQueue.main.async {
            if self.session.isReachable {
                let message = ["wait": "username"]
                print(message, " rtegfwergthry ")
                //WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
             //   self.session.delegate = self
                self.session.sendMessage(message, replyHandler: nil, errorHandler: { error in
                    print(error.localizedDescription, " erfwdsedwf ")
                })
//                self.session.sendMessage(message) { repl in
//                    print(repl, " replreplrepl")
//                } errorHandler: { err in
//                    print(err, " rfeewdqs")
//                }

                
            } else if self.session.activationState == .notActivated {
              //  self.session.delegate = self
                self.session.activate()
            }
        }
    }
}

