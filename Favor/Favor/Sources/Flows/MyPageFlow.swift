//
//  MyPageFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/02/10.
//

import UIKit

import FavorKit
import RxFlow

final class MyPageFlow: Flow {
  
  var root: Presentable { self.rootViewController }
  
  private let rootViewController: BaseNavigationController = {
    let navigationController = BaseNavigationController()
    navigationController.isNavigationBarHidden = true
    return navigationController
  }()
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .myPageIsRequired:
      return self.navigateToMyPage()

    case .editMyPageIsRequired(let user):
      return self.navigateToEditMyPage(with: user)

    case .editMyPageIsComplete:
      self.rootViewController.popViewController(animated: true)
      return .none

    case .settingIsRequired:
      return self.navigateToSetting()

    case .friendIsRequired:
      return self.navigateToFriend()

    case .editFriendIsRequired:
      return self.navigateToEditFriend()

    default:
      return .none
    }
  }
  
  private func navigateToMyPage() -> FlowContributors {
    let myPageVC = MyPageViewController()
    let myPageReactor = MyPageViewReactor()
    myPageVC.reactor = myPageReactor

    DispatchQueue.main.async {
      self.rootViewController.setViewControllers([myPageVC], animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: myPageVC,
      withNextStepper: myPageReactor
    ))
  }

  private func navigateToEditMyPage(with user: User) -> FlowContributors {
    let editMyPageVC = EditMyPageViewController()
    let editMyPageReactor = EditMyPageViewReactor(user: user)
    editMyPageVC.reactor = editMyPageReactor

    DispatchQueue.main.async {
      self.rootViewController.setupNavigationAppearance()
      self.rootViewController.pushViewController(editMyPageVC, animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: editMyPageVC,
      withNextStepper: editMyPageReactor
    ))
  }

  private func navigateToSetting() -> FlowContributors {
    return .none
  }

  private func navigateToFriend() -> FlowContributors {
    let friendVC = FriendViewController()
    let friendReactor = FriendViewReactor()
    friendVC.reactor = friendReactor
    friendVC.title = "내 친구"
    friendVC.viewType = .list

    DispatchQueue.main.async {
      self.rootViewController.setupNavigationAppearance()
      self.rootViewController.pushViewController(friendVC, animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: friendVC,
      withNextStepper: friendReactor
    ))
  }

  private func navigateToEditFriend() -> FlowContributors {
    let editFriendVC = EditFriendViewController()
    let editFriendReactor = EditFriendViewReactor()
    editFriendVC.reactor = editFriendReactor
    editFriendVC.title = "편집하기"
    editFriendVC.viewType = .edit

    DispatchQueue.main.async {
      self.rootViewController.pushViewController(editFriendVC, animated: true)
    }

    return .one(flowContributor: .contribute(
      withNextPresentable: editFriendVC,
      withNextStepper: editFriendReactor
    ))
  }
}
