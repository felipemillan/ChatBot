//
//  LoginViewController.swift
//  ChatBot
//
//  Created by Alexandr on 17.09.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    let coreData = CoreDataStack.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        UserDefaults.standard.set(textField.text, forKey: "user")
        
        if coreData.fetch(user: textField.text!) == nil {
            coreData.save(user: textField.text!)
        }
        
        performSegue(withIdentifier: "ToChatSegue", sender: self)
        
        return true
    }

}
