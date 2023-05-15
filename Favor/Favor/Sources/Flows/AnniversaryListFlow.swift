//
//  AnniversaryListFlow.swift
//  Favor
//
//  Created by 이창준 on 2023/05/16.
//

import UIKit

import FavorKit
import RxFlow

final class AnniversaryListFlow: Flow {

  // MARK: - Properties

  var root: Presentable { self.rootViewController }
  let rootViewController: BaseNavigationController

  // MARK: - Initializer

  init(rootViewController: BaseNavigationController) {
    self.rootViewController = rootViewController
  }

  // MARK: - Navigate

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? AppStep else { return .none }

    switch step {
    case .anniversaryListIsRequired:
      return self.navigateToAnniversaryList()

    case .anniversaryListIsComplete:
      return self.navigateToMyPage()

    default:
      return .none
    }
  }
}

// MARK: - Navigates

private extension AnniversaryListFlow {
  func navigateToAnniversaryList() -> FlowContributors {


    return .none
  }

  func navigateToMyPage() -> FlowContributors {
    DispatchQueue.main.async {
      self.rootViewController.popViewController(animated: true)
    }
    return .end(forwardToParentFlowWithStep: AppStep.anniversaryListIsComplete)
  }
}
