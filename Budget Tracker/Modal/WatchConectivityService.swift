//
//  WatchConectivityService.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 03.05.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import Foundation
import WatchConnectivity
#if os(watchOS)
import WatchKit
#else
import UIKit
#endif

class WatchConectivityService:NSObject, WCSessionDelegate {
#if os(watchOS)
#else
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    #endif
    private var message:[String:Any] = [:]
    
    var messageReceived:((_ data:[String : Any])->())? = nil
    var error:((_ error:String)->())?
    private let session: WCSession
    private var sendingData:[MessageType: String] = [:]

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
        } else {
            print(error, " activation error")
        }
        if !sendingData.isEmpty, activationState == .activated {
            self.sendMessage(sendingData)
            self.sendingData.removeAll()
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
    
    func sendUsername() {
        if let username = AppDelegate.properties?.db.username, username != "" {
            let username = username
            DispatchQueue.main.async {
                self.session.delegate = self
                self.sendMessage([.sendUsername:username])
            }
        } else {
            showError("Login to your account")
            #if os(iOS)
            DispatchQueue.main.async {
                UIApplication.shared.sceneKeyWindow?.rootViewController?.present(LoginViewController.configure())
            }
            #endif
        }
    }
    
    func askUsername() {
        sendMessage([.askUsername: "username"])
    }

    enum MessageType:String {
        case askUsername
        case sendUsername
        
        var successTitle:String? {
            return switch self {
            case .sendUsername: "Sent username"
            default: nil
            }
        }
    }
}

extension WatchConectivityService {
    private func showError(_ text:String) {
        showMessage(text, error: true)
    }
    
    private func showMessage(_ text:String, error:Bool = false) {
        #if os(watchOS)
        #else
        if Thread.isMainThread {
            AppDelegate.properties?.newMessage.show(title:text,type: error ? .error : .standart)
        } else {
            DispatchQueue.main.async {
                AppDelegate.properties?.newMessage.show(title:text,type: error ? .error : .standart)
            }
        }
        #endif
        if error {
            self.error?(text)
        }
    }
    
    private func sendMessage(_ message:[MessageType: String]) {
        print(session.isReachable, " erfwd")
        var result:[String:String] = [:]
        message.forEach {
            result.updateValue($0.value, forKey: $0.key.rawValue)
        }
        DispatchQueue.main.async {
            if self.session.isReachable {
                print(message, " rtegfwergthry ")
                #if os(watchOS)
                #else
                if !self.session.isPaired {
                    self.showError("Watch is not paired")
                }
                if !self.session.isWatchAppInstalled {
                    self.showError("WatchOS app is not installed")
                }
                #endif
                
                if self.session.activationState == .activated {
                    self.session.sendMessage(result, replyHandler: nil, errorHandler: { error in
                        print(error.localizedDescription, " erfwdsedwf ")
                    })
                    if let title = message.keys.first?.successTitle {
                        self.showMessage(title)
                    }
                } else {
                    self.session.delegate = self
                    self.session.activate()
                }
                
            } else if self.session.activationState == .notActivated {
                self.sendingData = message
                self.session.delegate = self
                self.session.activate()
            }
        }
    }

}
