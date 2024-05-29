//
//  Keychain.swift
//  Budget Tracker
//
//  Created by Mikhailo Dovhyi on 31.01.2021.
//  Copyright © 2021 Misha Dovhiy. All rights reserved.
//

import UIKit

#if os(macOS)
import Cocoa
#endif
import Security

public class KeychainService: NSObject {
    static private let service = "BudgetTrackerApp"

    class func loadUsers() -> [String]? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        
        guard status == errSecSuccess else {
            print("Error retrieving keychain items: \(status)")
            return nil
        }
        
        var user:[String] = []
        if let keychainItems = items as? [[String: Any]] {
            for item in keychainItems {
                if let username = item[kSecAttrAccount as String] as? String {
                    print("Username: \(username)")
                    user.append(username)
                }
            }
        }
        return user.count == 0 ? nil : user
    }
    
    class func updatePassword(account:String, data: String) {
        if let dataFromString: Data = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [KeychainServiceKeys.kSecClassGenericPasswordValue, service, account], forKeys: [KeychainServiceKeys.kSecClassValue, KeychainServiceKeys.kSecAttrServiceValue, KeychainServiceKeys.kSecAttrAccountValue])
            
            let status = SecItemUpdate(keychainQuery as CFDictionary, [KeychainServiceKeys.kSecValueDataValue:dataFromString] as CFDictionary)
            
            if (status != errSecSuccess) {
                if let err = SecCopyErrorMessageString(status, nil) {
                    print("Read failed: \(err)")
                }
            }
            
            updateUsernameInKeychain(newUsername: account)
        }
    }
    
    
    static private func updateUsernameInKeychain(newUsername: String) {
        let account = AppDelegate.properties?.db.username ?? ""
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let existingItem = item as? [String: Any] else {
            print("Error retrieving keychain item: \(status)")
            return
        }
        
        let updateQuery: [String: Any] = [
            kSecAttrAccount as String: newUsername
        ]
        
        let updateStatus = SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary)
        
        if updateStatus == errSecSuccess {
            print("Username updated successfully")
        } else {
            print("Error updating username: \(updateStatus)")
        }
    }
    
    
    class func removePassword(account:String) {
        
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [KeychainServiceKeys.kSecClassGenericPasswordValue, service, account, kCFBooleanTrue], forKeys: [KeychainServiceKeys.kSecClassValue, KeychainServiceKeys.kSecAttrServiceValue, KeychainServiceKeys.kSecAttrAccountValue, KeychainServiceKeys.kSecReturnDataValue])
        
        let status = SecItemDelete(keychainQuery as CFDictionary)
        if (status != errSecSuccess) {
            if let err = SecCopyErrorMessageString(status, nil) {
                print("Remove failed: \(err)")
            }
        }
        
    }
    
    
    class func savePassword(account:String, data: String) {
        if let dataFromString = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [KeychainServiceKeys.kSecClassGenericPasswordValue, service, account, dataFromString], forKeys: [KeychainServiceKeys.kSecClassValue, KeychainServiceKeys.kSecAttrServiceValue, KeychainServiceKeys.kSecAttrAccountValue, KeychainServiceKeys.kSecValueDataValue])
            
            let status = SecItemAdd(keychainQuery as CFDictionary, nil)
            
            if (status != errSecSuccess) {
                if let err = SecCopyErrorMessageString(status, nil) {
                    print("Write failed: \(err)")
                }
            }
            
            updateUsernameInKeychain(newUsername: account)
            
        }
    }

    class func loadPassword(account:String) -> String? {
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [KeychainServiceKeys.kSecClassGenericPasswordValue, self.service, account, kCFBooleanTrue, KeychainServiceKeys.kSecMatchLimitOneValue], forKeys: [KeychainServiceKeys.kSecClassValue, KeychainServiceKeys.kSecAttrServiceValue, KeychainServiceKeys.kSecAttrAccountValue, KeychainServiceKeys.kSecReturnDataValue, KeychainServiceKeys.kSecMatchLimitValue])
        
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
