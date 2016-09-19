//
//  ViewController.swift
//  ChatBot
//
//  Created by Alexandr on 14.09.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ViewController: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    let bot = Bot.sharedInstance
    let coreData = CoreDataStack.shared
    var robotId = "Robot"
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureComponents()
    }
    
    func configureComponents() {
        if senderId == nil {
            loadUserInfo()
        }
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        inputToolbar.contentView.leftBarButtonItem = nil
        
        automaticallyScrollsToMostRecentMessage = true
        
        title = "Bot chat"
        setupBubbles()
        
        let messages = coreData.fetch(amount: 10, from: user)
        fillMessages(messages: messages)
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ViewController.signOutAlert(sender:)))
        rightButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = rightButton
    }
    
    func loadUserInfo() {
        let defaults = UserDefaults.standard
        if let user = defaults.string(forKey: "user") {
            senderId = user
            senderDisplayName = user
            self.user = coreData.fetch(user: user)
            self.bot.user = self.user
        }
    }
    
    func fillMessages(messages: [Message]) {
        if messages.count > 0 {
            self.insertAtStart(messages: messages)
        }
        else {
            self.addMessage(id: robotId, displayName: robotId, text: "Yo!")
            self.addMessage(id: robotId, displayName: robotId, text: "Hello, \(senderDisplayName!)! I am your assistant. I am here to help you with your finances")
        }
        self.finishReceivingMessage()
    }
    
    func loadEarlierMessages() {
        let messages = coreData.fetch(amount: 5, from: user)
        
        guard messages.count > 0 else {
            return
        }
        self.insertAtStart(messages: messages)
        var indexPaths = [IndexPath]()
        var index = 0
        for _ in 0...messages.count-1 {
            indexPaths.append(IndexPath(row: index, section: 0))
            index += 1
        }
        DispatchQueue.main.async {
            self.collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: indexPaths)
                }, completion: nil)
        }

    }
    
    func addMessage(id: String, displayName: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: displayName, text: text)
        messages.append(message!)
        coreData.save(msg: text, id: id, user: user)
    }
    
    func insertAtStart(messages: [Message]) {
        for message in messages {
            let msg = JSQMessage(senderId: message.senderId, displayName: message.displayName, text: message.message)
            self.messages.insert(msg!, at: 0)
        }
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImageView = factory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }

    func responseRobot(text: String) {
        let msgtext = bot.message(text: text)
        addMessage(id: robotId, displayName: robotId, text: msgtext)
        finishReceivingMessage()
    }
    
    func signOutAlert(sender: AnyObject?) {
        let alert = UIAlertController(title: "Sign out", message: "Are you sure ?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {
            (UIAlertAction) in
            DispatchQueue.main.async {
                self.signOut()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "user")
        coreData.fetchedItems = 0
        performSegue(withIdentifier: "ToLogin", sender: self)
    }
    
}

