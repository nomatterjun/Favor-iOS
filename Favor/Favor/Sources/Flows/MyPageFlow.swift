//
//  MyPageFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/02/10.
//

import UIKit

import FavorKit
import RxFlow

@MainActor
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

    case .anniversaryListIsRequired:
      return self.navigateToAnniversaryList()

    case .friendListIsRequired:
      return self.navigateToFriendList()
      
    case .friendPageIsRequired(let friend):
      return self.navigateToFriendPage(friend)

    default:
      return .none
    }
  }
}

extension MyPageFlow {
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

  private func navigateToAnniversaryList() -> FlowContributors {
    let anniversaryListFlow = AnniversaryFlow(rootViewController: self.rootViewController)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: anniversaryListFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.anniversaryListIsRequired(.mine))
    ))
  }

  private func navigateToFriendList() -> FlowContributors {
    let friendListFlow = FriendListFlow(rootViewController: self.rootViewController)

    return .one(flowContributor: .contribute(
      withNextPresentable: friendListFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.friendListIsRequired)
    ))
  }

  private func navigateToFriendPage(_ friend: Friend) -> FlowContributors {
    let friendPageFlow = FriendPageFlow(rootViewController: self.rootViewController)
    
    return .one(flowContributor: .contribute(
      withNextPresentable: friendPageFlow,
      withNextStepper: OneStepper(withSingleStep: AppStep.friendPageIsRequired(friend))
    ))
  }
}
