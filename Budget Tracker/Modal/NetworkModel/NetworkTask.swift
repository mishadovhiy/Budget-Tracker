//
//  NetworkTask.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 24.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation

struct NetworkTask {
    @available(iOS 13.0, *)
    static func load(urlPath: String) async -> ServerResponse.ArrayType {
        guard let url:URL = URL(string: urlPath) else {
            print("grfdsff")
            return .init(error: .other)
        }
        do {
            let response = try await URLSession.shared.data(for: .init(url: url))
            guard let array = unparceData(response) else {
                return .init(error: .internet)
            }
            print("okkkkkkk ", array)

            return .init(array)
        } catch {
            print("grfdsff")

            return .init(error: .other)
        }
    }
    
    private static func unparceData(_ response: (Data, URLResponse)) -> NSArray? {
        var jsonResult = NSArray()
        print(response, " responseresponseresponse")
        do{
            guard let json = try JSONSerialization.jsonObject(with: response.0, options:.allowFragments) as? NSArray else {
                print(" bhgcftyuijknbvgcfjhj jsonss error")
                return nil
            }
            jsonResult = json
        } catch let error as NSError {
            print("grfdsff")

            print(error.description, " bhgcftyuijknbvgcfjhj")
            return nil
        }
        print("jsonResultjsonResult ", jsonResult)
        AppDelegate.properties?.appData.threadCheck(shouldMainThread: false)
        return jsonResult
    }
}
