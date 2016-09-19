//
//  Category+CoreDataProperties.swift
//  ChatBot
//
//  Created by Alexandr on 17.09.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import Foundation
import CoreData 

extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category");
    }

    @NSManaged public var name: String?
    @NSManaged public var cost: Int64
    @NSManaged public var owner: User?

}
