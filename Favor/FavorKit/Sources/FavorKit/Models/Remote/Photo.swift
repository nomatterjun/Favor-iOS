//
//  Photo.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import RealmSwift

public class Photo: Object {
  @Persisted(primaryKey: true) var photoNo: Int
}
