//
//  Keychain.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 31.01.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

#if !os(iOS)
import Cocoa
#endif
import Security

public class KeychainService: NSObject {
    
    
    class func updatePassword(service: String, account:String, data: String) {
        if let dataFromString: Data = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            
            // Instantiate a new default keychain query
            let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [KeychainServiceKeys.kSecClassGenericPasswordValue, service, account], forKeys: [KeychainServiceKeys.kSecClassValue, KeychainServiceKeys.kSecAttrServiceValue, KeychainServiceKeys.kSecAttrAccountValue])
            
            let status = SecItemUpdate(keychainQuery as CFDictionary, [KeychainServiceKeys.kSecValueDataValue:dataFromString] as CFDictionary)
            
            if (status != errSecSuccess) {
                if let err = SecCopyErrorMessageString(status, nil) {
                    print("Read failed: \(err)")
                }
            }
        }
    }
    
    
    class func removePassword(service: String, account:String) {
        
        // Instantiate a new default keychain query
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [KeychainServiceKeys.kSecClassGenericPasswordValue, service, account, kCFBooleanTrue], forKeys: [KeychainServiceKeys.kSecClassValue, KeychainServiceKeys.kSecAttrServiceValue, KeychainServiceKeys.kSecAttrAccountValue, KeychainServiceKeys.kSecReturnDataValue])
        
        // Delete any existing items
        let status = SecItemDelete(keychainQuery as CFDictionary)
        if (status != errSecSuccess) {
            if let err = SecCopyErrorMessageString(status, nil) {
                print("Remove failed: \(err)")
            }
        }
        
    }
    
    
    class func savePassword(service: String, account:String, data: String) {
        if let dataFromString = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            
            // Instantiate a new default keychain query
            let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [KeychainServiceKeys.kSecClassGenericPasswordValue, service, account, dataFromString], forKeys: [KeychainServiceKeys.kSecClassValue, KeychainServiceKeys.kSecAttrServiceValue, KeychainServiceKeys.kSecAttrAccountValue, KeychainServiceKeys.kSecValueDataValue])
            
            // Add the new keychain item
            let status = SecItemAdd(keychainQuery as CFDictionary, nil)
            
            if (status != errSecSuccess) {    // Always check the status
                if let err = SecCopyErrorMessageString(status, nil) {
                    print("Write failed: \(err)")
                }
            }
        }
    }
    
    class func loadPassword(service: String, account:String) -> String? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [KeychainServiceKeys.kSecClassGenericPasswordValue, service, account, kCFBooleanTrue, KeychainServiceKeys.kSecMatchLimitOneValue], forKeys: [KeychainServiceKeys.kSecClassValue, KeychainServiceKeys.kSecAttrServiceValue, KeychainServiceKeys.kSecAttrAccountValue, KeychainServiceKeys.kSecReturnDataValue, KeychainServiceKeys.kSecMatchLimitValue])
        
        var dataTypeRef :AnyObject?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain: String?
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                contentsOfKeychain = String(data: retrievedData, encoding: String.Encoding.utf8)
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
    
}

public struct KeychainServiceKeys {
    static let kSecClassValue = NSString(format: kSecClass)
    static let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
    static let kSecValueDataValue = NSString(format: kSecValueData)
    static let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
    static let kSecAttrServiceValue = NSString(format: kSecAttrService)
    static let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
    static let kSecReturnDataValue = NSString(format: kSecReturnData)
    static let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
}
