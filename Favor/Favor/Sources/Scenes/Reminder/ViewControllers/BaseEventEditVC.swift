//
//  BaseEventEditVC.swift
//  Favor
//
//  Created by 이창준 on 2023/04/01.
//

import UIKit

import FavorKit

class BaseEventEditViewController: BaseViewController {
  func makeEditStack(
    title: String,
    itemView: UIView,
    isDividerNeeded: Bool = true
  ) -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.distribution = .fillProportionally

    // Title Label
    let titleLabel = self.makeTitleLabel(title: title)

    // Divider
    let divider = FavorDivider()
    divider.layer.opacity = isDividerNeeded ? 1.0 : 0.0

    [
      titleLabel,
      itemView,
      divider
    ].forEach {
      stackView.addArrangedSubview($0)
    }

    return stackView
  }

  func makeTitleLabel(title: String) -> UILabel {
    let label = UILabel()
    label.font = .favorFont(.bold, size: 18)
    label.textAlignment = .left
    label.text = title
    return label
  }
}
