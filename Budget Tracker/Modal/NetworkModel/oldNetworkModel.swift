//
//  oldNetworkModel.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 24.12.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import Foundation

struct LoadFromDB {
    
    static var shared = LoadFromDB()

    private func load(urlPath: String, completion: @escaping (NSArray, ServerError?) -> ()) {
        AppDelegate.properties?.appData.threadCheck(shouldMainThread: false)
        print(urlPath, " urlPathurlPathurlPath")
        if let url: URL = URL(string: urlPath) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if error != nil {
                    completion([], .internet)
                    return
                } else {
                    var jsonResult = NSArray()
                    do{
                        jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                    } catch let error as NSError {
                        print(error.description, " bhgcftyuijknbvgcfjhj")
                        completion([], .internet)
                        return
                    }
                    AppDelegate.properties?.appData.threadCheck(shouldMainThread: false)
                    completion(jsonResult, nil)
                }
            }
            task.resume()
        } else {
            completion([], .other)
        }
        
    }
    
    var appData:AppProperties {
        return AppDelegate.properties ?? .init()
    }
    
    var db:DataBase {
        return AppDelegate.properties?.db ?? .init()
    }
    
    
    
    
    
    private func performAddCategory(otherUser: String? = nil, saveLocally: Bool = true, local:Bool = false, completion: @escaping ([NewCategories], ServerError) -> ()) {
        let user = otherUser == nil ? db.username : otherUser!
        if user == "" || local {
            let local = db.categories
            completion(local, .none)
        } else {
            var loadedData: [NewCategories] = []
            load(urlPath: Keys.dbURL + "NewCategories.php") { jsonResult, error in
                if let error = error {
                    let local = db.categories
                    completion(local, error)
                } else {
                    var jsonElement = NSDictionary()
                    let myNik = user
                    
                    for i in 0..<jsonResult.count {
                        jsonElement = jsonResult[i] as! NSDictionary
                        
                        if myNik == (jsonElement["Nickname"] as? String ?? "") {
                            if let new = NewCategories.create(dict: jsonElement as? [String : Any] ?? [:]) {
                                loadedData.append(new)
                            }
                            
                        }
                        
                    }
                    if otherUser == nil && saveLocally {
                        db.categories = loadedData
                    }
                    print(loadedData, " newCategoriesnewCategoriesnewCategories")
                    completion(loadedData, .none)
                }
            }
        }
    }
    
    
    

    
    
    func newCategories(otherUser: String? = nil, saveLocally: Bool = true, local:Bool = false, completion: @escaping ([NewCategories], ServerError) -> ()) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performAddCategory(otherUser: otherUser, saveLocally: saveLocally, local: local, completion: completion)
            }
        } else {
            performAddCategory(otherUser: otherUser, saveLocally: saveLocally, local: local, completion: completion)
        }
        
    }
    
    private func performnewTransactions(otherUser: String? = nil, saveLocally: Bool = true, completion: @escaping ([TransactionsStruct], ServerError) -> (), local:Bool = false) {
        let user = otherUser == nil ? db.username : otherUser!
        if user == "" || local {
            let local = db.transactions
            completion(local, .none)
        } else {
            var loadedData: [TransactionsStruct] = []
            load(urlPath: Keys.dbURL + "newTransactions.php") { jsonResult, error in
                if let error = error {
                    let local = db.transactions
                    completion(local, error)
                } else {
                    var jsonElement = NSDictionary()
                    let myNik = user
                    
                    for i in 0..<jsonResult.count {
                        jsonElement = jsonResult[i] as! NSDictionary
                        
                        if myNik == (jsonElement["Nickname"] as? String ?? "") {
                            if let new = TransactionsStruct.create(dictt: jsonElement as? [String : Any] ?? [:]) {
                                loadedData.append(new)
                            }
                            
                        }
                        
                    }
                    if otherUser == nil && saveLocally {
                        db.transactions = loadedData
                    }
                    
                    completion(loadedData, .none)
                }
            }
        }
    }
    
    func newTransactions(otherUser: String? = nil, saveLocally: Bool = true, completion: @escaping ([TransactionsStruct], ServerError) -> (), local:Bool = false) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performnewTransactions(otherUser: otherUser, saveLocally: saveLocally, completion: completion, local: local)

            }
        } else {
            self.performnewTransactions(otherUser: otherUser, saveLocally: saveLocally, completion: completion, local: local)
        }
        
    }
    
    private func performLoadUsers(completion: @escaping ([[String]], Bool) -> ()) {

        var loadedData: [[String]] = []
        let urlPath = Keys.dbURL + "users.php"
        if let url: URL = URL(string: urlPath) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                completion([], true)
                return
                
            } else {
                var jsonResult = NSArray()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                } catch let error as NSError {
                    print(error, "parseJSON - wrong db")
                    completion([], true)
                    return
                }
                
                var jsonElement = NSDictionary()
                
                for i in 0..<jsonResult.count {
                    jsonElement = jsonResult[i] as! NSDictionary

                    if let name = jsonElement["Nickname"] as? String,
                       let email = jsonElement["Email"] as? String,
                       let password = jsonElement["Password"] as? String,
                       let registrationDate = jsonElement["Registration_Date"] as? String,
                       let pro = jsonElement["ProVersion"] as? String, //(0,1)
                       let trialDate = jsonElement["trialDate"] as? String
                    {
                        loadedData.append([name, email, password, registrationDate, pro, trialDate])
                    }
                    
                }

                completion(loadedData, false)
            
            }
            
        }

        DispatchQueue.main.async {
            task.resume()
        }
        }
    }
    
    func Users(completion: @escaping ([[String]], Bool) -> ()) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performLoadUsers(completion: completion)
            }
        } else {
            performLoadUsers(completion: completion)
        }
        
    }
    
    enum LoginCompletion {
        case result(_ error:String?, _ success:Bool?)
        case userChanged
        case enteredEmailUsers(_ newValue:[String])
        case hideAiDismiss(_ toHome:Bool)
        case users(_ list:[String])
    }
    typealias LoginCompletionAction = (_ type:LoginCompletion)->()
    
    func login(username:String?,
               password:String?,forceLoggedOutUser:String, fromPro:Bool,
               completion:@escaping LoginCompletionAction) {
        LoadFromDB.shared.Users { (loadedData, Error) in
            if !Error {
                if let name = username,
                   let password = password {
                    if name != "" && password != "" {
                        if !name.contains("@") {
                           self.logIn(nickname: name, password: password, loadedData: loadedData, forceLoggedOutUser:forceLoggedOutUser, fromPro:fromPro, completion: completion)
                           // completion(.result(login, login == nil))
                        } else {
                            self.checkUsers(for: name, password: password, action: completion) { ok in
                                //
                            }
                        }
                        
                    } else {
//                        self.actionButtonsEnabled = true
//                        self.obthervValues = true
//                        DispatchQueue.main.async {
//                            self.newMessage?.show(title: "All fields are required".localize, type: .error)
//                            self.ai?.hide()
//                            self.showWrongFields()
//                        }
                        completion(.result("All fields are required", false))
                        
                    }
                }
            } else {
                print("error!!!")
                completion(.result(AppText.Error.InternetTitle, false))
             //   self.actionButtonsEnabled = true
//                DispatchQueue.main.async {
//                    self.showAlert(title: AppText.Error.InternetTitle, text: AppText.Error.internetDescription, error: true, goToLogin: true)
//                }
            }
        }

    }
    
    
    private func logIn(nickname: String, password: String, loadedData: [[String]], forceLoggedOutUser:String, fromPro:Bool, completion:@escaping LoginCompletionAction) {

        let checkPassword = LoadFromDB.checkPassword(from: loadedData, nickname: nickname, password: password)
        
        if let userExists = checkPassword.1 {
            let wrongPassword = checkPassword.0
            if !wrongPassword {
                performLoggin(userData: userExists, forceLoggedOutUser: forceLoggedOutUser, fromPro: fromPro, completion: completion)
            } else {
//                self.actionButtonsEnabled = true
                let messageTitle = "Wrong".localize + " " + "password".localize
//                DispatchQueue.main.async {
//                    self.showError(title: messageTitle)
//                }
                completion(.result(messageTitle, false))
            }
        } else {
//            self.actionButtonsEnabled = true
//            DispatchQueue.main.async {
//                self.showError(title: "User not found".localize)
//            }
            completion(.result("User not found", false))

        }
        

    }

    private func performLoggin(userData:[String], forceLoggedOutUser:String, fromPro:Bool, completion:@escaping LoginCompletionAction) {
        let nickname = userData[0]
        let password = userData[2]
        let email = userData[1]
        let isPro = userData[4]
        if let keycheinPassword = KeychainService.loadPassword(account: nickname) {
          //  if keycheinPassword != password {
                KeychainService.updatePassword(account: nickname, data: password)
           // }
        } else {
            KeychainService.savePassword(account: nickname, data: password)
        }
        let prevUserName = db.username
        
        
        if prevUserName != nickname {
            let dat = (self.db.categories, self.db.transactions)
            completion(.userChanged)
           // userChanged()
            db.db.updateValue(prevUserName, forKey: "prevUserName")
            
            if prevUserName == "" && forceLoggedOutUser == "" {
                let db = AppDelegate.properties?.db ?? .init()
                db.localCategories = dat.0
                db.localTransactions = dat.1
                
            }
            
            if forceLoggedOutUser == "" {
                AppDelegate.properties?.appData.fromLoginVCMessage = "Wellcome".localize + ", \(db.username)"
            }
            
        }
        db.username = nickname
        db.password = password
        db.userEmailHolder = email
        
        
        if !db.purchasedOnThisDevice {
            db.proVersion = isPro == "1" ? true : db.proVersion
        }
        AppDelegate.properties?.appData.needDownloadOnMainAppeare = true
        if fromPro || forceLoggedOutUser != "" {
//            DispatchQueue.main.async {
//                self.endAnimating()
//                self.dismiss(animated: true) {
//                    self.ai?.hide()
//                }
//            }
            completion(.hideAiDismiss(false))

        } else {
//            DispatchQueue.main.async {
//                self.endAnimating()
//                self.ai?.hide {
//                    self.performSegue(withIdentifier: "homeVC", sender: self)
//                }
//            }
            completion(.hideAiDismiss(true))
        }
    }

    
    func loadUsers(completion:@escaping (_ results:[[String]]?, _ error:String?) -> ()) {
      //  let load = LoadFromDB()
        DispatchQueue(label: "api", qos: .userInitiated).async {
            LoadFromDB.shared.Users { (users, error) in
                if !error {
                    completion(users, nil)
                } else {
//                    DispatchQueue.main.async {
//                        self.showAlert(title: AppText.Error.InternetTitle, text: AppText.Error.internetDescription, error: true, goToLogin: true)
//                    }
                    completion(nil, AppText.Error.InternetTitle)
                }
            }
        }
    }

    
    private func checkUsers(for email: String, password:String, action:@escaping LoginCompletionAction, completion:@escaping(Bool)-> ()) {
      //  DispatchQueue.main.async {
        //    self.ai?.show { _ in
        action(.enteredEmailUsers([]))
               // self.enteredEmailUsers.removeAll()
                var resultUsers: [String] = []
        self.loadUsers { users,error  in
                    
                    //check password for email
                    var passwordCurrect = false
                    var found = false
            for n in 0..<(users?.count ?? 0) {
                        if email == users?[n][1] {
                            found = true
                            if password == users?[n][2] {
                                passwordCurrect = true
                                break
                            }
                            
                        }
                        
                    }
                    if passwordCurrect {
                        for i in 0..<(users?.count ?? 0) {
                            if users?[i][1] == email {
                                resultUsers.append(users?[i][0] ?? "")
                            }
                        }
                       // self.enteredEmailUsers = resultUsers
                        action(.enteredEmailUsers(resultUsers))
                        completion(found)
                        print(resultUsers, " efrwd")
                        
//                        DispatchQueue.main.async {
//
//                            SelectValueVC.presentScreen(in: self, with: [], structData: [
//                                .init(sectionName: "Select User", cells: resultUsers.compactMap({ apiUser in
//                                    .init(name: apiUser, regular: .init(didSelect: {
//                                        self.navigationController?.popViewController(animated: true)
//                                        self.userSelected(user: apiUser)
//                                    }))
//                                }))
//                            ], title: "User List")
//                        }
                    } else {
                        let notFound = "Email not found".localize + "!"
                        let text = !found ? notFound : "Wrong password".localize
//                        DispatchQueue.main.async {
//                            self.showAlert(title: text, error: true)
//                        }
                        action(.result(text, false))
                        completion(false)
                    }

                    
                    
                }
         //   }
      //  }
        
    }

    
    static func checkPassword(from loadedData:[[String]], nickname:String?, password:String?) -> (Bool, [String]?) {
        guard let password, let nickname else {
            return (true, nil)
        }
        var wrongPassword = true
        var userData:[String]?
        for i in 0..<loadedData.count {
            if loadedData[i][0] == nickname {
                print(loadedData[i], "loadedData[i]loadedData[i]loadedData[i]")
                let psswordFromDB = loadedData[i][2]
                
                if password == psswordFromDB {
                    wrongPassword = false
                    userData = loadedData[i]
                    break
                } else {
                    userData = loadedData[i]
                }
            }
        }
        return (wrongPassword, userData)
    }
    
    
    
    
}




struct SaveToDB {
    var appData:AppData {
        return AppDelegate.properties?.appData ?? .init()
    }
    var db:DataBase {
        return AppDelegate.properties?.db ?? .init()
    }
    enum dataType {
        case transactions
        case categories
        case non
    }

    static var shared = SaveToDB()
    
    func performnewTransaction(_ transaction: TransactionsStruct, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if db.username == "" {
            db.transactions.append(transaction)
            completion(false)
        } else {

            let data = "&Nickname=\(db.username)" + "&CategoryId=\(transaction.categoryID)" + "&Amount=\(transaction.value)" + "&Date=\(transaction.date)" + "&Comment=\(transaction.comment)"
            save(dbFileURL: Keys.dbURL + "new-NewTransaction.php", toDataString: data, error: { (error) in
                if error {
                    if saveLocally {
                        db.unsendedData.append(["transactionNew": transaction.dict])
                    }
                    
                }
                if saveLocally {
                    db.transactions.append(transaction)
                }
                
                completion(error)
            })
        }
    }
    
    func newTransaction(_ transaction: TransactionsStruct, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performnewTransaction(transaction, saveLocally: saveLocally, completion: completion)
            }
        } else {
            performnewTransaction(transaction, saveLocally: saveLocally, completion: completion)
        }
    }
    
    private func performnewCategories(_ category: NewCategories, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if db.username == "" {
            DispatchQueue(label: "db", qos: .userInitiated).async {
                self.db.categories.append(category)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
            
        } else {
            let pupose = category.purpose.rawValue
            
            var amount:String {
                if let amount = category.amountToPay {
                    return "&AmountToPay=\(amount)"
                } else if let amount = category.monthLimit {
                    return "&AmountToPay=\(amount)"
                }
                return ""
            }
            
            var dueDate:String {
                if let date = category.dueDate {
                    if let result = date.toIsoString() {
                        return "&DueDate=" + result
                    }
                }
                return ""
            }
            let data = "&Nickname=\(db.username)" + "&Id=\(category.id)" + "&Name=\(category.name)" + "&Icon=\(category.icon)" + "&Color=\(category.color)" + "&Purpose=\(pupose)" + amount + dueDate
            save(dbFileURL: Keys.dbURL + "new-NewCategory.php", toDataString: data, error: { (error) in
                if error {
                    if saveLocally {
                        db.unsendedData.append(["categoryNew": category.dict])
                    }
                    
                }
                if saveLocally {
                    db.categories.append(category)
                }
               
                completion(error)
            })
        }
    }
    //param: dont append and dont send to unsended when toDataString!= nil
    func newCategories(_ category: NewCategories, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performnewCategories(category, saveLocally: saveLocally, completion: completion)
            }
        } else {
            self.performnewCategories(category, saveLocally: saveLocally, completion: completion)
        }
    }
    

    
    
    func Users(toDataString: String, completion: @escaping (Bool) -> ()) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.save(dbFileURL: Keys.dbURL + "new-user.php", toDataString: toDataString, error: { (error) in
                    completion(error)
                })
            }
        } else {
            save(dbFileURL: Keys.dbURL + "new-user.php", toDataString: toDataString, error: { (error) in
                completion(error)
            })
        }
    }
    
    func NewPassword(toDataString: String, completion: @escaping (Bool) -> ()) {
        save(dbFileURL: Keys.dbURL + "user-password.php", toDataString: toDataString, error: { (error) in
            completion(error)
        })
    }
    
    func sendCode(toDataString: String, completion: @escaping (Bool) -> ()) {
        save(dbFileURL: Keys.dbURL + "sendCode.php?\(toDataString)", toDataString: "", error: { (error) in
            completion(error)
        })
    }
    
    func sendAnalytics(data:String, completion:@escaping (Bool) -> ()) {
        let doDataString = "applicationName=BudgetTracker&data=\(data)"
        let url = Keys.analyticsURL + "newAnalytic.php?"
        save(dbFileURL: url, toDataString: doDataString, secretWord: false, error: completion)
    }

    private func save(dbFileURL: String, httpMethod: String = "POST", toDataString: String, secretWord:Bool = true, error: @escaping (Bool) -> ()) {
        if let urlData = dbFileURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        let url = NSURL(string: urlData)
        if let reqUrl = url as URL? {
        var request = URLRequest(url: reqUrl)
        request.httpMethod = httpMethod
            var dataToSend = secretWord ? ("secretWord=" + Keys.secretKey) : ""
                
        dataToSend = dataToSend + toDataString
            
        let dataD = dataToSend.data(using: .utf8)
        appData.needDownloadOnMainAppeare = true
        do {
            print("dbModel: dbFileURL", dbFileURL)
            print("dbModel: dataToSend", dataToSend)

            let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD) { data, response, errr in
                
                if errr != nil {
                    print("save: internet error")
                    error(true)
                    return
                    
                } else {
                    if let unwrappedData = data {
                        let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                        print(Thread.isMainThread, " apithreaddd")
                        AppDelegate.properties?.appData.threadCheck(shouldMainThread: false)

                        if returnedData == "1" {
                            print("save: sended \(dataToSend)")
                            error(false)
                        } else {
                            let r = returnedData?.trimmingCharacters(in: .whitespacesAndNewlines)
                            if r == "1" {
                                print("save: sended \(dataToSend)")
                                error(false)
                            } else {
                                print("save: db error for (cats, etc)")
                                error(true)
                            }
                            
                            
                        }
                        
                        
                    }
                    
                }
                
            }
            
            DispatchQueue.main.async {
                uploadJob.resume()
            }
        }
            } else {
                print("url data error")
                error(true)
            }
        } else {
            print("error creating url")
            error(true)
        }
            
    }
    
}






struct DeleteFromDB {
    var appData:AppData {
        return AppDelegate.properties?.appData ?? .init()
    }
    var db:DataBase {
        return AppDelegate.properties?.db ?? .init()
    }
    static var shared = DeleteFromDB()
    
    func User(toDataString: String, completion: @escaping (Bool) -> ()) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.delete(dbFileURL: Keys.dbURL + "delete-user.php", toDataString: toDataString, error: { (error) in
                       completion(error)
                   })
            }
        } else {
            delete(dbFileURL: Keys.dbURL + "delete-user.php", toDataString: toDataString, error: { (error) in
                   completion(error)
               })
        }
    }
    

    func performCategoriesNew(category: NewCategories, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        guard let data = category.apiData else {
            completion(false)
            return
        }
        if db.username == "" {
            deleteCategory(category: category)
            completion(false)
        } else {
            
            delete(dbFileURL: Keys.dbURL + "delete-NewCategory.php", toDataString: data, error: { (error) in
                if error {
                    if saveLocally {
                        db.unsendedData.append(["deleteCategoryNew": category.dict])
                    }
                    
                }
                if saveLocally {
                    deleteCategory(category: category)
                }
                
                completion(error)
            })
        }
    }
    
    
    func CategoriesNew(category: NewCategories, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performCategoriesNew(category: category, saveLocally: saveLocally, completion: completion)
            }
        } else {
            performCategoriesNew(category: category, saveLocally: saveLocally, completion: completion)
        }
    }
    private func deleteCategory(category: NewCategories) {
        let all = db.categories
        var new: [NewCategories] = []
        var deleted = false
        for i in 0..<all.count {
            if all[i].id != category.id || deleted {
                new.append(all[i])
            } else {
                deleted = true
            }
        }
        if !deleted {
            print("category:", category, " fvdsdaefwrg not found to delete")
        }
        db.categories = new
    }
    
    func performnewTransaction(_ transaction: TransactionsStruct, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if db.username == "" {
            db.deleteTransaction(transaction: transaction)
            completion(false)
        } else {

            let data = "&Nickname=\(db.username)" + "&CategoryId=\(transaction.categoryID)" + "&Amount=\(transaction.value)" + "&Date=\(transaction.date)" + "&Comment=\(transaction.comment)"
            delete(dbFileURL: Keys.dbURL + "delete-NewTransaction.php", toDataString: data, error: { (error) in
                if error {
                    if saveLocally {
                        db.unsendedData.append(["deleteTransactionNew": transaction.dict])
                    }
                    
                }
                if saveLocally {
                    db.deleteTransaction(transaction: transaction)
                }
                
                completion(error)
            })
        }
    }
    
    func newTransaction(_ transaction: TransactionsStruct, saveLocally: Bool = true, completion: @escaping (Bool) -> ()) {
        if Thread.isMainThread {
            DispatchQueue(label: "api", qos: .userInitiated).async {
                self.performnewTransaction(transaction, saveLocally: saveLocally, completion: completion)
            }
        } else {
            performnewTransaction(transaction, saveLocally: saveLocally, completion: completion)
        }
    }

    func deleteAccount(completion: @escaping (Bool) -> ()) {
        if db.username == "" {
            completion(false)
        } else {

          /*  let data = "&Nickname=\(db.username)" + "&CategoryId=\(transaction.categoryID)" + "&Amount=\(transaction.value)" + "&Date=\(transaction.date)" + "&Comment=\(transaction.comment)"
            delete(dbFileURL: Keys.dbURL + "delete-NewTransaction.php", toDataString: data, error: { (error) in
                if error {

                    
                }

                
                completion(error)
            })*/
        }
    }
    
    private func delete(dbFileURL: String, toDataString: String, error: @escaping (Bool) -> ()) {
        let url = NSURL(string: dbFileURL)
        if let reqUrl = url as URL? {
        var request = URLRequest(url: reqUrl)
        request.httpMethod = "POST"
        var dataString = "secretWord=" + Keys.secretKey
            appData.needDownloadOnMainAppeare = true
        dataString = dataString + toDataString
             print(dataString, "dataStringdataStringdataString delete")
        if let urlStringData = dataString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            let dataD = urlStringData.data(using: .utf8)
            do {
                let uploadJob = URLSession.shared.uploadTask(with: request, from: dataD) { data, response, errr in
                    
                    if errr != nil {
                        error(true)
                        return
                        
                    } else {
                        AppDelegate.properties?.appData.threadCheck(shouldMainThread: false)

                        if let unwrappedData = data {
                            let returnedData = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                            if returnedData == "1" {
                                print("ok")
                                error(false)
                                return
                            } else {
                                print("delete: db error for (cats, etc)")
                                error(true)
                                return
                            }
                            
                        }
                        
                    }
                    
                }
                DispatchQueue.main.async {
                    uploadJob.resume()
                }
                
            }
        } else {
            error(true)
        }
        } else {
            error(true)
        }
            
    }
    
}
