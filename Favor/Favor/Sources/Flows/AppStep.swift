//
//  AppStep.swift
//  Favor
//
//  Created by 김응철 on 2023/01/27.
//

import Foundation

import FavorKit
import RxFlow

enum AppStep: Step {
  case imagePickerIsRequired(PHPickerManager)

  // MARK: - Root
  case rootIsRequired

  // MARK: - Auth
  case authIsRequired
  case findPasswordIsRequired
  case validateEmailCodeIsRequired(String)
  case newPasswordIsRequired
  case signUpIsRequired
  case signInIsRequired
  case setProfileIsRequired
  case termIsRequired(String)
  
  // MARK: - Onboarding
  case onboardingIsRequired
  case onboardingIsComplete
  
  // MARK: - Main
  case tabBarIsRequired
  
  // MARK: - Home
  case homeIsRequired
  
  // MARK: - Search
  case searchIsRequired
  case searchIsComplete
  case searchResultIsRequired(String)
  case searchResultIsComplete

  // MARK: - Reminder
  case reminderIsRequired
  case newReminderIsRequired
  case newReminderIsComplete
  case reminderDetailIsRequired(Reminder)
  case reminderEditIsRequired(Reminder)
  case reminderIsComplete
  
  // MARK: - MyPage
  case myPageIsRequired
  case editMyPageIsRequired(User)
  case editMyPageIsComplete
  case settingIsRequired

  // MARK: - FriendList
  case friendListIsRequired
  case editFriendIsRequired
  case friendListIsComplete
  
  // MARK: - FriendPage
  case friendManagementIsRequired(FriendManagementViewController.ViewControllerType)
  case friendPageIsRequired(Friend)
  
  // MARK: - AnniversaryList
  case anniversaryListIsRequired(AnniversaryListType)
  case anniversaryListIsComplete
  case editAnniversaryListIsRequired([Anniversary])
  case newAnniversaryIsRequired
  case anniversaryManagementIsRequired(Anniversary)
  case anniversaryManagementIsComplete(ToastMessage)
  
  // MARK: - Test
  case testIsRequired

  // MARK: - Gift
  case giftManagementIsRequired(Gift? = nil)
  case giftManagementIsCompleteWithNoChanges
  case newGiftIsComplete(Gift)
  case editGiftIsComplete(Gift)
  case newGiftFriendIsRequired
  case giftDetailIsRequired(Gift)
  case giftDetailIsComplete(Gift)
  case giftDetailPhotoIsRequired(Int, Int)
  case giftShareIsRequired(Gift)

  // MARK: - BottomSheet
  case memoBottomSheetIsRequired(String?)
  case memoBottomSheetIsComplete(String?)
  case filterBottomSheetIsRequired(SortType)
  case filterBottomSheetIsComplete(SortType)
  case anniversaryBottomSheetIsRequired(AnniversaryCategory?)
  case anniversaryBottomSheetIsComplete(AnniversaryCategory)
  
  // MARK: - Popup
  case alertPopupIsRequired(AlertPopup.PopupType)
  case alertPopupIsComplete(isConfirmed: Bool)
  
}
