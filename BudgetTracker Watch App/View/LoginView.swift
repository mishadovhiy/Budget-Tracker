//
//  LoginView.swift
//  BudgetTracker Watch App
//
//  Created by Misha Dovhiy on 22.05.2024.
//  Copyright © 2024 Misha Dovhiy. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @Binding var loggedIn:Bool
    @State var email:String = "" {
        didSet {
            if error != nil {
                error = nil
            }
        }
    }
    @State var password:String = "" {
        didSet {
            if error != nil {
                error = nil
            }
        }
    }
    @State var error:String? = nil
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Login")
            VStack {
                TextField("Email or Nick", text: $email)
                TextField("Password", text: $password)
            }
            if error != nil {
                Text(error ?? "-")
                    .foregroundStyle(.red)
            }
            HStack {
                Spacer()
                Button("Login", action: performLogin)
            }
        }
        .onAppear(perform: {
            DispatchQueue(label:"db", qos: .userInitiated).async {
                let _ = AppDelegate.init()
                let username = AppDelegate.properties?.db.username
                print(username)
                if username != "" {
                    DispatchQueue.main.async {
                        loggedIn = true
                        print("settedsaddas ")
                    }
                }
            }
        })
    }
    
    
    private func performLogin() {
        Task {
            let load = LoadFromDB()
            load.login(username: email, password: password, forceLoggedOutUser: "", fromPro: false) { type in
                switch type {
                case .result(let error, let scs):
                    self.error = error
                case .hideAiDismiss(let goHome):
                    loggedIn = true
                    break
                default:break
                }
            }
        }
    }
}


