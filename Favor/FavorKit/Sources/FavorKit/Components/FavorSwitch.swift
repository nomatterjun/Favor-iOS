//
//  FavorSwitch.swift
//  Favor
//
//  Created by 이창준 on 2023/03/15.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

public final class FavorSwitch: UIButton {
  public typealias SwitchColor = (bar: UIColor, thumb: UIColor)

  // MARK: - Constants

  // MARK: - Properties

  private let disposeBag = DisposeBag()

  private var animator: UIViewPropertyAnimator?

  fileprivate var isOn = BehaviorRelay<Bool>(value: false)

  /// Switch가 켜졌을 때의 색상
  public var onTintColor: SwitchColor = (.favorColor(.sub), .favorColor(.white))

  /// Switch가 꺼졌을 때의 색상
  public var offTintColor: SwitchColor = (.favorColor(.line3), .favorColor(.white))

  /// Thumb와 Bar의 top, bottom 간격
  public var thumbVerticalPadding: CGFloat = 1

  /// Thumb와 Bar의 leading, trailing 간격
  public var thumbHorizontalPadding: CGFloat = 1

  public var duration: TimeInterval = 0.2

  // MARK: - UI Components

  private lazy var barView = {
    let view = UIView()
    view.clipsToBounds = true
    return view
  }()

  private lazy var thumbView = {
    let view = UIView()
    view.clipsToBounds = true
    return view
  }()

  // MARK: - Initializer

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()

    self.isOn
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, isOn in
        owner.updateState(isOn)
      })
      .disposed(by: self.disposeBag)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.isOn.accept(!self.isOn.value)
  }

  public override func layoutSublayers(of layer: CALayer) {
    super.layoutSublayers(of: layer)
    self.updateShape()
    self.thumbView.snp.updateConstraints { make in
      make.centerX.equalTo(self.thumbView.bounds.width / 2 + self.thumbHorizontalPadding)
    }
  }
}

// MARK: - UI Setup

extension FavorSwitch: BaseView {
  public func setupStyles() {
    //
  }

  public func setupLayouts() {
    self.addSubview(self.barView)
    self.barView.addSubview(self.thumbView)
  }

  public func setupConstraints() {
    self.barView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    self.thumbView.snp.makeConstraints { make in
      make.directionalVerticalEdges.equalToSuperview().inset(self.thumbVerticalPadding)
      make.centerX.equalTo(self.thumbView.bounds.width / 2 + self.thumbHorizontalPadding)
      make.width.equalTo(self.thumbView.snp.height)
    }
  }
}

// MARK: - Privates

private extension FavorSwitch {
  func updateState(_ isOn: Bool) {
    let centerX = isOn
      ? self.frame.width - (self.thumbView.frame.width / 2) - self.thumbHorizontalPadding
      : (self.thumbView.frame.width / 2) + self.thumbHorizontalPadding
    self.animator = UIViewPropertyAnimator(
      duration: self.duration,
      curve: .easeInOut,
      animations: {
        self.updateColor(isOn)
        self.thumbView.snp.updateConstraints { make in
          make.centerX.equalTo(centerX)
        }
        self.layoutSubviews()
        self.barView.layoutSubviews()
      }
    )
    self.animator?.startAnimation()
  }

  func updateShape() {
    self.barView.layer.cornerRadius = self.barView.frame.height / 2
    self.thumbView.layer.cornerRadius = self.thumbView.frame.height / 2
  }

  func updateColor(_ isOn: Bool) {
    if isOn {
      self.barView.backgroundColor = self.onTintColor.bar
      self.thumbView.backgroundColor = self.onTintColor.thumb
    } else {
      self.barView.backgroundColor = self.offTintColor.bar
      self.thumbView.backgroundColor = self.offTintColor.thumb
    }
  }
}

// MARK: - Reactive

public extension Reactive where Base: FavorSwitch {
  var isOn: ControlProperty<Bool> {
    let source = base.isOn
    let bindingObserver = Binder(self.base) { favorSwitch, isOn in
      favorSwitch.isOn.accept(isOn)
    }
    return ControlProperty(values: source, valueSink: bindingObserver)
  }
}
