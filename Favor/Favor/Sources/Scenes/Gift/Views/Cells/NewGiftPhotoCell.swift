//
//  PickedPictureCell.swift
//  Favor
//
//  Created by 김응철 on 2023/02/07.
//

import UIKit

import FavorKit
import ReactorKit
import Reusable

final class NewGiftPhotoCell: UICollectionViewCell, Reusable {
  
  // MARK: - UI
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.layer.masksToBounds = true
    iv.layer.cornerRadius = 8
    return iv
  }()
  
  private lazy var removeButton: UIButton = {
    let btn = UIButton()
    let removeImage: UIImage? = .favorIcon(.remove)?
      .withTintColor(.favorColor(.white))
      .resize(newWidth: 22)
    btn.setImage(removeImage, for: .normal)
    btn.addTarget(self, action: #selector(didTapRemoveButton), for: .touchUpInside)
    return btn
  }()
  
  // MARK: - PROPERTIES
  
  var removeButtonDidTap: (() -> Void)?
  
  // MARK: - INITIALIZER
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  // MARK: - SELECTORS
  
  @objc
  private func didTapRemoveButton() {
    self.removeButtonDidTap?()
  }
}

// MARK: - Setup

extension NewGiftPhotoCell: BaseView {
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.imageView,
      self.removeButton
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.removeButton.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(12)
    }
  }
}
