//
//  User.swift
//  Favor
//
//  Created by 이창준 on 2023/03/19.
//

import RealmSwift

public class User: Object {

  // MARK: - Properties

  /// 회원 번호
  @Persisted(primaryKey: true) var userNo: Int
  /// 회원 이메일 (로그인 시 사용)
  @Persisted var email: String
  /// 회원 아이디 (@)
  @Persisted var userID: String
  /// 회원 이름
  @Persisted var name: String
  /// 회원 취향 태그
  @Persisted var favorList: MutableSet<Int>
  /// 선물 목록
  @Persisted var giftList: List<Gift>
  /// 리마인더 목록
  @Persisted var reminderList: List<Reminder>
  /// 회원 친구 목록
  @Persisted var friendList: List<Friend>
  /// 회원 사진
  @Persisted var userPhoto: Photo?
  /// 회원 배경사진
  @Persisted var backgroundPhoto: Photo?

  public override class func propertiesMapping() -> [String: String] {
    [
      "userID": "userId"
    ]
  }

  // MARK: - Initializer

  /// - Parameters:
  ///   - userNo: ***PK*** 회원 번호
  ///   - email: 로그인 시 사용되는 회원 이메일
  ///   - userID: 검색 시 사용되는 회원 아이디 - *ex: @favor_281*
  ///   - name: 회원 이름
  ///   - userPhoto: *`Optioinal`* 회원 프로필 사진
  ///   - backgroundPhoto: *`Optional`* 회원 프로필 배경 사진
  public convenience init(
    userNo: Int,
    email: String,
    userID: String,
    name: String,
    favorList: [Int], // enum화?
    userPhoto: Photo? = nil,
    backgroundPhoto: Photo? = nil
  ) {
    self.init()
    self.userNo = userNo
    self.email = email
    self.userID = userID
    self.name = name
    self.favorList.insert(objectsIn: favorList)
    self.userPhoto = userPhoto
    self.backgroundPhoto = backgroundPhoto
  }
}
