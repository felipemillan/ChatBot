//
//  Message+CoreDataProperties.swift
//  ChatBot
//
//  Created by Alexandr on 17.09.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import Foundation
import CoreData 

extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message");
    }

    @NSManaged public var message: String?
    @NSManaged public var senderId: String?
    @NSManaged public var displayName: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var owner: User?

}
