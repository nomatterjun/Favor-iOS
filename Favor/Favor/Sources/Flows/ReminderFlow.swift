//
//  ReminderFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/03/11.
//

import UIKit

import FavorKit
import RxFlow

final class ReminderFlow: Flow {

  var root: Presentable { self.rootViewController }

  let rootViewController = BaseNavigationController()

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }
    
    switch step {
    case .reminderIsRequired:
      return self.navigateToReminder()

    case .newReminderIsRequired:
      return self.navigateToNewReminder()

    case .newReminderIsComplete:
      return .end(forwardToParentFlowWithStep: AppStep.tabBarIsRequired)

    case .reminderDetailIsRequired(let reminder):
      return self.navigateToReminderDetail(reminder: reminder)

    case .reminderEditIsRequired(let reminder):
      return self.navigateToEditReminder(reminder: reminder)

    default: return .none
    }
  }
}

private extension ReminderFlow {
  func navigateToReminder() -> FlowContributors {
    let reminderVC = ReminderViewController()
    let reminderReactor = ReminderViewReactor()
    reminderVC.reactor = reminderReactor
    self.rootViewController.pushViewController(reminderVC, animated: true)

    return .one(
      flowContributor: .contribute(
        withNextPresentable: reminderVC,
        withNextStepper: reminderReactor
      ))
  }

  func navigateToNewReminder() -> FlowContributors {
    let newReminderVC = ReminderEditViewController()
    let newReminderReactor = ReminderEditViewReactor(.new)
    newReminderVC.reactor = newReminderReactor
    newReminderVC.isEditable = true
    self.rootViewController.pushViewController(newReminderVC, animated: true)

    return .one(
      flowContributor: .contribute(
        withNextPresentable: newReminderVC,
        withNextStepper: newReminderReactor
      ))
  }

  func navigateToReminderDetail(reminder: Reminder) -> FlowContributors {
    let reminderDetailVC = ReminderDetailViewController()
    let reminderDetailReactor = ReminderDetailViewReactor(reminder: reminder)
    reminderDetailVC.reactor = reminderDetailReactor
    reminderDetailVC.isEditable = false
    self.rootViewController.pushViewController(reminderDetailVC, animated: true)

    return .one(
      flowContributor: .contribute(
        withNextPresentable: reminderDetailVC,
        withNextStepper: reminderDetailReactor
      ))
  }

  func navigateToEditReminder(reminder: Reminder) -> FlowContributors {
    let reminderEditVC = ReminderEditViewController()
    let reminderEditReactor = ReminderEditViewReactor(reminder: reminder)
    reminderEditVC.reactor = reminderEditReactor
    reminderEditVC.isEditable = true
    self.rootViewController.pushViewController(reminderEditVC, animated: true)

    return .one(
      flowContributor: .contribute(
        withNextPresentable: reminderEditVC,
        withNextStepper: reminderEditReactor
      ))
  }
}
