//
//  BotApiManager.swift
//  ChatBot
//
//  Created by Alexandr on 14.09.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import UIKit

class Bot: NSObject {
    
    static let sharedInstance = Bot()
    
    var user: User!
    var money: Double?
    var category: String?
    var moneyBool = false
    var categoryBool = false
    var earnBool = false
    var spentBool = false
    var token = [String]()
    let coreData = CoreDataStack.shared
    var responseSpent: String {
        get {
            user.money -= Int(self.money!)
            let cat = coreData.fetch(category: self.category!, user: self.user!)
            if cat == nil {
                coreData.save(category: self.category!, cost: Int(self.money!), user: self.user!)
            }
            else {
                cat?.cost += Int(self.money!)
            }
            
            return "Saved that you spent \(self.money!)$ on \(self.category!)"
        }
    }
    var responseEarn: String {
        get {
            user.money += Int(self.money!)
            return "Saved that you earned \(self.money!)$"
        }
    }
    
    enum Error: String {
        case error = "Sorry, I don't understand you"
        case errorMoney = "Error money"
    }
    
    func message(text: String) -> String {
        let msg = text.lowercased()
        
        if msg.contains(" ") {
            token = msg.components(separatedBy: " ")
            
            switch token.count {
            case 1:
                return oneWord(msg: token[0])
            case 2:
                return twoWords(msg: token[0])
            case 4:
                return fourWords(msg: token[0])
            default:
                return Error.error.rawValue
            }
        }
        else {
            return oneWord(msg: msg)
        }
    }
    
    func oneWord(msg: String) -> String {
        switch msg {
        case "hello", "hi", "yo":
            return "Hi"
        case "stat":
            let categories = coreData.fetchCategories(user: user)
            var stat = ""
            var index = 0
            stat += "Balance - \(user.money)$\n"
            for category in categories {
                stat += "\(category.name!) - \(category.cost)$"
                if index < categories.count-1 {
                    stat += "\n"
                }
                index += 1
            }
            return stat
        case "earn":
            moneyBool = true
            earnBool = true
            return "How much did you spent ?"
        case "spent":
            moneyBool = true
            return "How much did you spent ?"
        default:
            if moneyBool {
                let money = self.money(token: msg)
                if money != nil {
                    self.money = money
                    moneyBool = false
                    categoryBool = true
                    if earnBool {
                        earnBool = false
                        return responseEarn
                    }
                    return "You spent on what ?"
                }
                else {
                    return Error.error.rawValue
                }
            }
            else if categoryBool {
                self.category = msg
                moneyBool = false
                categoryBool = false
                return responseSpent
            }
            else {
                return Error.error.rawValue
            }
        }
    }
    
    func twoWords(msg: String) -> String {
        switch msg {
        case "earn":
            let money = self.money(token: token[1])
            if money != nil {
                self.money = money
                return responseEarn
            }
            else {
                return Error.errorMoney.rawValue
            }
        case "spent":
            self.money = money(token: token[1])
            categoryBool = true
            return "You spent on what ?"
        case "on":
            return oneWord(msg: token[1])
        default:
            return Error.error.rawValue
        }
    }
    
    func fourWords(msg: String) -> String {
        switch msg {
        case "spent":
            let money = self.money(token: token[1])
            self.category = token[3]
            if money != nil {
                self.money = money
                moneyBool = false
                categoryBool = false
                return responseSpent
            }
            else {
                return Error.errorMoney.rawValue
            }
        default:
            return Error.error.rawValue
        }
    }
    
    func money(token: String) -> Double? {
        var num: String
        if token.contains("$") {
            num = token.replacingOccurrences(of: "$", with: "")
        }
        else {
            num = token
        }
        if let money = Double(num) {
            return money
        }
        else {
            return nil
        }
    }
    
}
