//
//  Anniversary.swift
//  Favor
//
//  Created by 이창준 on 2023/06/06.
//

import Foundation

import FavorKit
import FavorNetworkKit
import class RealmSwift.ThreadSafe

public struct Anniversary: Storable, Receivable {

  // MARK: - Properties

  public let identifier: Int
  public var name: String
  public var category: AnniversaryCategory
  public var date: Date
  public var isPinned: Bool

  // MARK: - Storable

  public init(realmObject: AnniversaryObject) {
    @ThreadSafe var rlmObjectRef = realmObject
    guard let realmObject = rlmObjectRef else { fatalError() }
    
    self.identifier = realmObject.anniversaryNo
    self.name = realmObject.title
    self.category = realmObject.category
    self.date = realmObject.date
    self.isPinned = realmObject.isPinned
  }

  public func realmObject() -> AnniversaryObject {
    AnniversaryObject(
      anniversaryNo: self.identifier,
      title: self.name,
      date: self.date,
      isPinned: self.isPinned
    )
  }

  // MARK: - Receivable

  public init(dto: AnniversaryResponseDTO) {
    self.identifier = dto.anniversaryNo
    self.name = dto.anniversaryTitle
    // TODO: DTO에 추가 후 수정
    self.category = .birth
    self.date = dto.anniversaryDate
    self.isPinned = dto.isPinned ?? false
  }

  public func requestDTO() -> AnniversaryRequestDTO {
    AnniversaryRequestDTO(
      anniversaryTitle: self.name,
      anniversaryDate: self.date.toDTODateString()
    )
  }

  // MARK: - Mock

  /// 비어있는 구조체를 생성합니다.
  ///
  /// > **⚠️ Warning** :
  ///   `identifier` 값을 -1로 줍니다. 값을 임시로 담을 때만 사용해주세요.
  public init() {
    self.identifier = -1
    self.name = ""
    self.category = .congrat
    self.date = .now
    self.isPinned = false
  }
}

// MARK: - PropertyValue

extension Anniversary {
  public enum PropertyValue: PropertyValueType {
    case identifier(Int)
    case name(String)
    case date(Date)
    case isPinned(Bool)

    public var propertyValuePair: PropertyValuePair {
      switch self {
      case .identifier(let identifier):
        return ("identifier", identifier)
      case .name(let name):
        return ("name", name)
      case .date(let date):
        return ("date", date)
      case .isPinned(let isPinned):
        return ("isPinned", isPinned)
      }
    }
  }
}

// MARK: - Hashable

extension Anniversary: Hashable {
  public static func == (lhs: Anniversary, rhs: Anniversary) -> Bool {
    return lhs.identifier == rhs.identifier
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.identifier)
  }
}

// MARK: - Array Extension

extension Array where Element == Anniversary {
  /// 기념일 배열을 등록순으로 정렬합니다.
  public func sort() -> Self {
    let anniversaries = Array(self.reversed())
    let pinnedAnniversaries = anniversaries.filter { $0.isPinned }
    let normalAnniversaries = anniversaries.filter { !$0.isPinned }
    
    return pinnedAnniversaries + normalAnniversaries
  }
}
