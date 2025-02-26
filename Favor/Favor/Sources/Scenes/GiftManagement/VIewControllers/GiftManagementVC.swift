//
//  GiftManagementVC.swift
//  Favor
//
//  Created by 이창준 on 2023/05/29.
//

import UIKit

import Composer
import FavorKit
import ReactorKit
import SnapKit

final class GiftManagementViewController: BaseViewController, View {
  typealias GiftManagementDataSource = UICollectionViewDiffableDataSource<GiftManagementSection, GiftManagementSectionItem>

  // MARK: - Constants

  public enum ViewType {
    case new, edit

    public var doneButtonTitle: String {
      switch self {
      case .new: return "등록"
      case .edit: return "완료"
      }
    }

    public var cancelButtonImage: UIImage.FavorIcon {
      switch self {
      case .new: return .down
      case .edit: return .left
      }
    }
  }

  public enum GiftType {
    case received, given

    var header: String {
      switch self {
      case .received: return "받은 사람"
      case .given: return "준 사람"
      }
    }
  }

  // MARK: - Properties

  private var dataSource: GiftManagementDataSource?

  private var giftType: GiftType?

  // MARK: - UI Components

  // NavigationBar
  private lazy var doneButton: UIButton = {
    var config = UIButton.Configuration.plain()

    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .disabled:
        button.configuration?.baseForegroundColor = .favorColor(.line2)
      case .normal:
        button.configuration?.baseForegroundColor = .favorColor(.icon)
      default:
        break
      }
    }
    return button
  }()
  private var cancelButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.baseForegroundColor = .favorColor(.icon)

    let button = UIButton(configuration: config)
    return button
  }()
  private let giftImageView = UIImageView(image: .favorIcon(.gift))

  // Contents
  private let collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: UICollectionViewLayout()
    )

    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(top: 16, left: .zero, bottom: 74, right: .zero)
    return collectionView
  }()

  private lazy var composer: Composer<GiftManagementSection, GiftManagementSectionItem> = {
    let composer = Composer(collectionView: self.collectionView, dataSource: self.dataSource)
    composer.configuration = Composer.Configuration(
      scrollDirection: .vertical,
      sectionSpacing: 40,
      header: .header(
        height: .absolute(65),
        contentInsets: NSDirectionalEdgeInsets(top: .zero, leading: 20, bottom: 40, trailing: 20),
        kind: GiftManagementCollectionHeaderView.identifier
      )
    )
    return composer
  }()

  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupDataSource()
    self.composer.compose()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.setupNavigationBar()
  }

  // MARK: - Binding

  func bind(reactor: GiftManagementViewReactor) {
    // Action
    self.cancelButton.rx.tap
      .map { Reactor.Action.cancelButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.doneButton.rx.tap
      .debug("Done Button")
      .map { Reactor.Action.doneButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.collectionView.rx.itemSelected
      .map { [weak self] indexPath in
        guard
          let self = self,
          let snapshot = self.dataSource?.snapshot()
        else { return .doNothing }
        let section = snapshot.sectionIdentifiers[indexPath.section]
        let item = snapshot.itemIdentifiers(inSection: section)[indexPath.item]
        switch section {
        case .photos:
          return .photoDidSelected(item)
        default:
          return .doNothing
        }
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    // State
    let sectionData = reactor.state.map { state in
      (sections: state.sections, items: state.items)
    }
    Observable.combineLatest(self.rx.viewDidLoad, sectionData)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, datas in
        let sectionData = datas.1
        var snapshot = NSDiffableDataSourceSnapshot<GiftManagementSection, GiftManagementSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { idx, items in
          snapshot.appendItems(items, toSection: sectionData.sections[idx])
        }

        DispatchQueue.main.async {
          owner.dataSource?.apply(snapshot)
        }
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.viewType }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, viewType in
        owner.doneButton.configuration?.updateAttributedTitle(
          viewType.doneButtonTitle,
          font: .favorFont(.bold, size: 18)
        )
        owner.cancelButton.configuration?.image = .favorIcon(viewType.cancelButtonImage)?
          .withRenderingMode(.alwaysTemplate)
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.giftType }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, giftType in
        owner.giftType = giftType
      })
      .disposed(by: self.disposeBag)
  }

  // MARK: - Functions

  // MARK: - UI Setups

  override func setupLayouts() {
    self.view.addSubview(self.collectionView)
  }

  override func setupConstraints() {
    self.collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  private func setupNavigationBar() {
    self.navigationItem.setRightBarButton(self.doneButton.toBarButtonItem(), animated: false)
    self.navigationItem.setLeftBarButton(self.cancelButton.toBarButtonItem(), animated: false)
    self.navigationItem.titleView = self.giftImageView
  }
}

// MARK: - DataSource

private extension GiftManagementViewController {
  func setupDataSource() {
    // Cells
    let titleCellRegistration = UICollectionView.CellRegistration
    <FavorTextFieldCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      guard let self = self, let reactor = self.reactor else { return }
      cell.delegate = self
      cell.bind(placeholder: "선물 이름 (최대 20자)")
      cell.bind(text: reactor.currentState.gift.name)
    }

    let categoryCellRegistration = UICollectionView.CellRegistration
    <GiftManagementCategoryViewCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      guard let self = self, let reactor = self.reactor else { return }
      cell.delegate = self
      cell.bind(with: reactor.currentState.gift.category)
    }

    let photoCellRegistration = UICollectionView.CellRegistration
    <GiftManagementPhotoCell, GiftManagementSectionItem> { [weak self] cell, _, itemIdentifier in
      guard let self = self, case let GiftManagementSectionItem.photo(image) = itemIdentifier else { return }
      cell.delegate = self
      cell.bind(with: image)
    }

    let friendCellRegistration = UICollectionView.CellRegistration
    <FavorSelectorCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      cell.delegate = self
    }

    let dateCellRegistration = UICollectionView.CellRegistration
    <FavorDateSelectorCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      guard let self = self, let reactor = self.reactor else { return }
      cell.delegate = self
      cell.bind(date: reactor.currentState.gift.date)
    }

    let memoCellRegistration = UICollectionView.CellRegistration
    <GiftManagementMemoCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      guard let self = self, let reactor = self.reactor else { return }
      cell.delegate = self
      cell.bind(with: reactor.currentState.gift.memo)
    }

    let pinCellRegistration = UICollectionView.CellRegistration
    <GiftManagementPinCell, GiftManagementSectionItem> { [weak self] cell, _, _ in
      guard let self = self, let reactor = self.reactor else { return }
      cell.delegate = self
      cell.bind(with: reactor.currentState.gift.isPinned)
    }

    self.dataSource = GiftManagementDataSource(
      collectionView: self.collectionView,
      cellProvider: { [weak self] collectionView, indexPath, item in
        guard self != nil else { return UICollectionViewCell() }
        switch item {
        case .title:
          return collectionView.dequeueConfiguredReusableCell(
            using: titleCellRegistration, for: indexPath, item: item)
        case .category:
          return collectionView.dequeueConfiguredReusableCell(
            using: categoryCellRegistration, for: indexPath, item: item)
        case .photo:
          return collectionView.dequeueConfiguredReusableCell(
            using: photoCellRegistration, for: indexPath, item: item)
        case .friends:
          return collectionView.dequeueConfiguredReusableCell(
            using: friendCellRegistration, for: indexPath, item: item)
        case .date:
          return collectionView.dequeueConfiguredReusableCell(
            using: dateCellRegistration, for: indexPath, item: item)
        case .memo:
          return collectionView.dequeueConfiguredReusableCell(
            using: memoCellRegistration, for: indexPath, item: item)
        case .pin:
          return collectionView.dequeueConfiguredReusableCell(
            using: pinCellRegistration, for: indexPath, item: item)
        }
      }
    )

    // Supplementary Views
    let collectionHeaderRegistration: UICollectionView.SupplementaryRegistration<GiftManagementCollectionHeaderView> =
    UICollectionView.SupplementaryRegistration(
      elementKind: GiftManagementCollectionHeaderView.identifier
    ) { [weak self] header, _, _ in
      guard let self = self else { return }
      header.delegate = self
    }

    let sectionHeaderRegistration: UICollectionView.SupplementaryRegistration<FavorSectionHeaderCell> =
    UICollectionView.SupplementaryRegistration(
      elementKind: UICollectionView.elementKindSectionHeader
    ) { [weak self] header, _, indexPath in
      guard
        let self = self,
        let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section]
      else { return }

      header.configurationUpdateHandler = { header, _ in
        guard
          let header = header as? FavorSectionHeaderCell,
          let giftType = self.giftType
        else { return }
        if case GiftManagementSection.friends = section {
          header.bind(title: giftType.header)
        } else {
          header.bind(title: section.header)
        }
      }
    }

    let sectionFooterRegistration: UICollectionView.SupplementaryRegistration<FavorSectionFooterView> =
    UICollectionView.SupplementaryRegistration(
      elementKind: UICollectionView.elementKindSectionFooter
    ) { _, _, _ in
      //
    }

    self.dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
      guard self != nil else { return UICollectionReusableView() }
      switch kind {
      case GiftManagementCollectionHeaderView.identifier:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: collectionHeaderRegistration, for: indexPath)
      case UICollectionView.elementKindSectionHeader:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: sectionHeaderRegistration, for: indexPath)
      case UICollectionView.elementKindSectionFooter:
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: sectionFooterRegistration, for: indexPath)
      default:
        return UICollectionReusableView()
      }
    }
  }
}

// MARK: - CollectionHeaderView

extension GiftManagementViewController: GiftManagementCollectionHeaderViewDelegate {
  func giftTypeButtonDidTap(isGiven: Bool) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.giftTypeButtonDidTap(isGiven: isGiven))
  }
}

// MARK: - Title Cell

extension GiftManagementViewController: FavorTextFieldCellDelegate {
  func textFieldDidUpdate(from cell: FavorKit.FavorTextFieldCell, _ text: String?) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.titleDidUpdate(text))
  }
}

// MARK: - CategoryView Cell

extension GiftManagementViewController: GiftManagementCategoryViewCellDelegate {
  func categoryDidUpdate(to category: FavorCategory) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.categoryDidUpdate(category))
  }
}

// MARK: - Photo Cell

extension GiftManagementViewController: GiftManagementPhotoCellDelegate {
  func removeButtonDidTap(from cell: GiftManagementPhotoCell) {
//    guard let reactor = self.reactor else { return }
    print("Remove")
    // TODO: 이미지 다중 선택 / 삭제
  }
}

// MARK: - Friends Cell

extension GiftManagementViewController: FavorSelectorCellDelegate {
  func selectorDidTap(from cell: FavorSelectorCell) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.friendsSelectorButtonDidTap)
  }
}

// MARK: - Date Cell

extension GiftManagementViewController: FavorDateSelectorCellDelegate {
  func dateSelectorDidUpdate(from cell: FavorKit.FavorDateSelectorCell, _ date: Date?) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.dateDidUpdate(date))
  }
}

// MARK: - Memo Cell

extension GiftManagementViewController: GiftManagementMemoCellDelegate {
  func memoDidUpdate(_ memo: String?) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.memoDidUpdate(memo))
  }
}

// MARK: - Pin Cell

extension GiftManagementViewController: GiftManagementPinCellDelegate {
  func pinButtonDidTap(from cell: GiftManagementPinCell, isPinned: Bool) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.pinButtonDidTap(isPinned))
  }
}
