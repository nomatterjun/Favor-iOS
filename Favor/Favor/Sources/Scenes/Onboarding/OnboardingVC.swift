//
//  OnboardingViewController.swift
//  Favor
//
//  Created by 이창준 on 2023/01/09.
//

import UIKit

import SnapKit

final class OnboardingViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let pageControl: UIPageControl = {
    let pc = UIPageControl()
    pc.numberOfPages = 3
    pc.pageIndicatorTintColor = .favorColor(.box1)
    pc.currentPageIndicatorTintColor = .favorColor(.main)
    
    return pc
  }()
  
  private lazy var collectionView: UICollectionView = {
    let cv = UICollectionView(frame: .zero, collectionViewLayout: onboardingLayout())
    cv.register(
      OnboardingCell.self,
      forCellWithReuseIdentifier: OnboardingCell.reuseIdentifier
    )
    cv.isScrollEnabled = false
    cv.showsHorizontalScrollIndicator = false
    cv.dataSource = self
    cv.delegate = self
    
    return cv
  }()
  
  private lazy var onboardingSection: NSCollectionLayoutSection = {
    let size = NSCollectionLayoutSize(
      widthDimension: .absolute(view.frame.width),
      heightDimension: .absolute(collectionView.frame.height)
    )

    let item = NSCollectionLayoutItem(layoutSize: size)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .paging

    // PageControl currentPage 반응 Closure
    section.visibleItemsInvalidationHandler = { _, offset, _ in
      let width = self.collectionView.frame.width
      self.currentPage = Int(offset.x / width)
    }
    
    return section
  }()
  
  private let continueButton = LargeFavorButton(with: .white, title: "다음")
  
  private var currentPage: Int = 0 {
    didSet {
      self.pageControl.currentPage = currentPage
      let handler = UpdateHandlerManager.onboardingHandler(currentPage)
      continueButton.configurationUpdateHandler = handler
    }
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    [
      pageControl,
      collectionView,
      continueButton
    ].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    pageControl.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(view.safeAreaLayoutGuide).inset(66)
    }
    
    collectionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(pageControl.snp.bottom)
      make.bottom.equalTo(continueButton.snp.top)
    }
    
    continueButton.snp.makeConstraints { make in
      make.leading.trailing.equalTo(view.layoutMarginsGuide)
      make.bottom.equalToSuperview().inset(53)
    }
  }
}

// MARK: - Setup CollectionView

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: OnboardingCell.reuseIdentifier,
      for: indexPath
    ) as? OnboardingCell else {
      return UICollectionViewCell()
    }
    
    return cell
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return 3
  }
  
  private func onboardingLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { [weak self] _, _ in
      return self?.onboardingSection
    }
  }
}
