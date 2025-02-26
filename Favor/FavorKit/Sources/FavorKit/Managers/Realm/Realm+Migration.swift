//
//  RealmMigration.swift
//  Favor
//
//  Created by 이창준 on 2023/06/05.
//

import Foundation

import RealmSwift

public class RealmMigration {

  // MARK: - Properties

  public var migrationBlock: MigrationBlock = { migration, oldVersion in
    guard oldVersion < RealmWorkbench.version else {
      fatalError("RealmDB versioning error.")
    }

    if oldVersion < 4 {
      migration.enumerateObjects(ofType: RecentSearchObject.className(), { oldObject, newObject in
        let searchText = oldObject!["searchText"] as! String
        let searchDate = oldObject!["searchDate"] as! Date
        newObject!["searchText"] = searchText
        newObject!["searchDate"] = searchDate
      })
    }
    if oldVersion < 5 {
      migration.enumerateObjects(ofType: UserObject.className(), { oldObject, newObject in
        let favorList = oldObject!["favorList"] as! [Int]
        newObject!["favorList"] = favorList
      })
    }
    if oldVersion < 6 {
      migration.enumerateObjects(ofType: UserObject.className(), { _, newObject in
        newObject!["anniversaryList"] = List<AnniversaryObject>()
      })
    }
    if oldVersion < 7 {
      migration.enumerateObjects(ofType: GiftObject.className(), { oldObject, newObject in
        let giftCategory = oldObject!["category"]
        let giftEmotion = oldObject!["emotion"]
        newObject!["category"] = giftCategory
        newObject!["emotion"] = giftEmotion
      })
    }
    if oldVersion < 8 {
      migration.enumerateObjects(ofType: FriendObject.className()) { _, newObject in
        newObject!["anniversaryList"] = List<AnniversaryObject>()
        newObject!["favorList"] = List<String>()
      }
    }
    if oldVersion < 9 {
      migration.enumerateObjects(ofType: GiftObject.className()) { _, newObject in
        newObject!["privateCategory"] = "가벼운선물"
      }
    }
    if oldVersion < 10 {
      migration.enumerateObjects(ofType: GiftObject.className()) { _, newObject in
        newObject!["privateCategory"] = "가벼운선물"
      }
    }
  }

  // MARK: - Initializer

  public init() { }
}
