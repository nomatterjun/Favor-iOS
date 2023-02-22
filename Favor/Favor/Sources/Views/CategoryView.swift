//
//  CategoryView.swift
//  Favor
//
//  Created by 김응철 on 2023/02/06.
//

import UIKit

import SnapKit

final class CategoryView: UIScrollView {
  
  // MARK: - Properties
  
  private let lightGiftButton = SmallFavorButton(with: .main("가벼운 선물", imageName: ""))
  private let birthButton = SmallFavorButton(with: .main("생일", imageName: ""))
  private let houseWarmingButton = SmallFavorButton(with: .main("집들이", imageName: ""))
  private let testButton = SmallFavorButton(with: .main("시험", imageName: ""))
  private let promotionButton = SmallFavorButton(with: .main("승진", imageName: ""))
  private let graduationButton = SmallFavorButton(with: .main("졸업", imageName: ""))
  private let etcButton = SmallFavorButton(with: .main("기타", imageName: ""))
  
  private let contentsView: UIView = {
    let view = UIView()
    view.backgroundColor = .favorColor(.background)
    
    return view
  }()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CategoryView: BaseView {
  func setupStyles() {
    self.backgroundColor = .favorColor(.background)
    self.showsHorizontalScrollIndicator = false
  }
  
  func setupLayouts() {
    self.addSubview(self.contentsView)
    
    [
      self.lightGiftButton,
      self.birthButton,
      self.houseWarmingButton,
      self.testButton,
      self.promotionButton,
      self.graduationButton,
      self.etcButton
    ].forEach {
      self.contentsView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.equalTo(32)
    }
    
    self.contentsView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.top.equalToSuperview()
    }
    
    self.lightGiftButton.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.top.bottom.equalToSuperview()
    }
    
    self.birthButton.snp.makeConstraints { make in
      make.leading.equalTo(self.lightGiftButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
    }
    
    self.houseWarmingButton.snp.makeConstraints { make in
      make.leading.equalTo(self.birthButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
    }
    
    self.testButton.snp.makeConstraints { make in
      make.leading.equalTo(self.houseWarmingButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
    }
    
    self.promotionButton.snp.makeConstraints { make in
      make.leading.equalTo(self.testButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
    }

    self.graduationButton.snp.makeConstraints { make in
      make.leading.equalTo(self.promotionButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
    }

    self.etcButton.snp.makeConstraints { make in
      make.leading.equalTo(self.graduationButton.snp.trailing).offset(10)
      make.top.bottom.equalToSuperview()
      make.trailing.equalToSuperview()
    }
  }
}
