//
//  MyPageVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable
import RxGesture
import SnapKit

final class MyPageViewController: BaseProfileViewController, View {
  
  // MARK: - Constants
  
  // MARK: - Properties

  // MARK: - UI Components

  private let editButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.edit)?.withRenderingMode(.alwaysTemplate)
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.white)

    let button = UIButton(configuration: config)
    return button
  }()
  
  private let settingButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = .favorIcon(.setting)?.withRenderingMode(.alwaysTemplate)
    config.background.backgroundColor = .clear
    config.baseForegroundColor = .favorColor(.white)

    let button = UIButton(configuration: config)
    return button
  }()
  
  // MARK: - Life Cycle
  
  // MARK: - Binding
  
  func bind(reactor: MyPageViewReactor) {
    // MARK: - Action
    // View 진입
    Observable.combineLatest(self.rx.viewDidLoad, self.rx.viewWillAppear)
      .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
      .map { _ in Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // 편집 버튼 Tap
    self.editButton.rx.tap
      .map { Reactor.Action.editButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // 설정 버튼 Tap
    self.settingButton.rx.tap
      .map { Reactor.Action.settingButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // 스크롤
    self.collectionView.rx.contentOffset
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, offset in
        owner.updateProfileViewLayout(by: offset)
      })
      .disposed(by: self.disposeBag)

    // Cell 선택

    self.collectionView.rx.itemSelected
      .map { indexPath -> Reactor.Action in
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return .doNothing }
        switch item {
        case .friends(let reactor):
          return reactor.currentState.isNewFriendCell ?
            .newFriendCellDidTap :
            .friendCellDidTap(reactor.currentState.friend)
        default:
          return .doNothing
        }
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // MARK: - State
    reactor.state.map { $0.userName }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, name in
        owner.profileView.rx.name.onNext(name)
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.userID }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, id in
        owner.profileView.rx.id.onNext(id)
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<ProfileSection, ProfileSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { idx, items in
          snapshot.appendItems(items, toSection: sectionData.sections[idx])
        }
        owner.dataSource.apply(snapshot, animatingDifferences: false)
        owner.collectionView.collectionViewLayout.invalidateLayout()
      })
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions

  override func setupNavigationBar() {
    super.setupNavigationBar()

    let rightBarItems = [self.settingButton.toBarButtonItem(), self.editButton.toBarButtonItem()]
    self.navigationItem.setRightBarButtonItems(rightBarItems, animated: false)
  }

  override func injectReactor(to view: UICollectionReusableView) {
    guard
      let view = view as? ProfileGiftStatsCollectionHeader,
      let reactor = self.reactor
    else { return }
    view.reactor = ProfileGiftStatsCollectionHeaderReactor(
      gift: reactor.currentState.user.giftList
    )
  }

  override func headerRightButtonDidTap(at section: ProfileSection) {
    guard let reactor = self.reactor else { return }

    reactor.action.onNext(.headerRightButtonDidTap(section))
  }

}
