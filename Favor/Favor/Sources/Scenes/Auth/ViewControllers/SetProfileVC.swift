//
//  SetProfileVC.swift
//  Favor
//
//  Created by 이창준 on 2023/01/16.
//

import UIKit

import FavorKit
import ReactorKit
import RxCocoa
import RxGesture
import SnapKit

final class SetProfileViewController: BaseViewController, View {
  
  // MARK: - Constants

  private enum Metric {
    static let topSpacing = 56.0
    static let profileImageSize = 120.0
    static let plusImageSize = 48.0
    static let textFieldSpacing = 32.0
    static let bottomSpacing = 32.0
  }
  
  // MARK: - Properties
  
  // MARK: - UI Components

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    return scrollView
  }()
  
  private lazy var profileImageButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.line3)
    config.baseForegroundColor = .favorColor(.white)
    config.image = .favorIcon(.friend)?.withTintColor(.favorColor(.white))
    config.background.imageContentMode = .scaleAspectFill
    
    let button = UIButton(configuration: config)
    button.clipsToBounds = true
    button.layer.cornerRadius = Metric.profileImageSize / 2
    return button
  }()
  
  private lazy var plusImageView: UIButton = {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .favorColor(.line2)
    config.baseForegroundColor = .favorColor(.white)
    config.image = .favorIcon(.add)?.withTintColor(.favorColor(.white))
    config.background.cornerRadius = Metric.plusImageSize / 2
    
    let button = UIButton(configuration: config)
    button.isUserInteractionEnabled = false
    return button
  }()
  
  private lazy var nameTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "이름"
    textField.hasMessage = false
    textField.textField.textContentType = .nickname
    textField.textField.returnKeyType = .next
    return textField
  }()
  
  private lazy var idTextField: FavorTextField = {
    let textField = FavorTextField()
    textField.placeholder = "유저 아이디"
    textField.textField.keyboardType = .asciiCapable
    textField.textField.textContentType = .nickname
    textField.textField.returnKeyType = .done
    textField.updateMessageLabel(
      AuthValidationManager(type: .id).description(for: .empty),
      animated: false
    )
    
    let label = UILabel()
    label.text = "@"
    label.font = .favorFont(.regular, size: 16)
    label.textColor = .favorColor(.explain)
    label.textAlignment = .center
    textField.addLeftItem(item: label)
    
    return textField
  }()
  
  private lazy var textFieldStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = Metric.textFieldSpacing
    return stackView
  }()
  
  private lazy var nextButton: FavorLargeButton = {
    let button = FavorLargeButton(with: .main("다음"))
    button.isEnabled = false
    return button
  }()
  
  // MARK: - Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.layoutIfNeeded()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.nameTextField.becomeFirstResponder()
  }
  
  // MARK: - Binding
  
  func bind(reactor: SetProfileViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewNeedsLoaded }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.profileImageButton.rx.tapWithHaptic
      .map { Reactor.Action.profileImageButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.nameTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.nameTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.nameTextField.rx.editingDidEndOnExit
      .bind(with: self, onNext: { owner, _ in
        owner.idTextField.becomeFirstResponder()
        owner.scrollView.scroll(to: owner.idTextField.frame.maxY)
      })
      .disposed(by: self.disposeBag)

    self.idTextField.rx.editingDidBegin
      .bind(with: self, onNext: { owner, _ in
        owner.scrollView.scroll(to: owner.idTextField.frame.maxY)
      })
      .disposed(by: self.disposeBag)

    self.idTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .map { Reactor.Action.idTextFieldDidUpdate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.idTextField.rx.editingDidEndOnExit
      .do(onNext: { [weak self] _ in
        self?.scrollView.scroll(to: .zero)
      })
      .delay(.milliseconds(500), scheduler: MainScheduler.instance)
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.nextButton.rx.tapWithHaptic
      .delay(.milliseconds(500), scheduler: MainScheduler.instance)
      .map { Reactor.Action.nextFlowRequested }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.scrollView.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: {  owner, _ in
        owner.view.endEditing(true)
        owner.scrollView.scroll(to: .zero)
      })
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.profileImage }
      .skip(1)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, image in
        owner.profileImageButton.configuration?.image = image
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.userName }
      .take(until: { !$0.isEmpty })
      .concat(reactor.state.map { $0.userName }.take(1))
      .observe(on: MainScheduler.asyncInstance)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, name in
        owner.nameTextField.textField.text = name
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.userId }
      .take(until: { !$0.isEmpty })
      .concat(reactor.state.map { $0.userId }.take(1))
      .observe(on: MainScheduler.asyncInstance)
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, id in
        owner.idTextField.textField.text = id
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.idValidationResult }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .distinctUntilChanged()
      .skip(1)
      .drive(with: self, onNext: { owner, validationResult in
        switch validationResult {
        case .empty, .invalid:
          owner.idTextField.updateMessageLabel(
            AuthValidationManager(type: .id).description(for: validationResult),
            state: .error
          )
        case .valid:
          owner.idTextField.updateMessageLabel(
            AuthValidationManager(type: .id).description(for: .valid),
            state: .normal
          )
        }
      })
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.isNextButtonEnabled }
      .asDriver(onErrorRecover: { _ in return .empty()})
      .drive(with: self, onNext: { owner, isEnabled in
        owner.nextButton.isEnabled = isEnabled
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isLoading }
      .bind(to: self.rx.isLoading)
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  // MARK: - UI Setups
  
  override func setupLayouts() {
    [
      self.scrollView,
      self.nextButton
    ].forEach {
      self.view.addSubview($0)
    }

    [
      self.nameTextField,
      self.idTextField
    ].forEach {
      self.textFieldStack.addArrangedSubview($0)
    }
    
    [
      self.profileImageButton,
      self.plusImageView,
      self.textFieldStack
    ].forEach {
      self.scrollView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.scrollView.snp.makeConstraints { make in
      make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
    }

    self.profileImageButton.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.profileImageSize)
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(Metric.topSpacing)
    }
    
    self.plusImageView.snp.makeConstraints { make in
      make.width.height.equalTo(Metric.plusImageSize)
      make.bottom.trailing.equalTo(self.profileImageButton)
    }
    
    self.textFieldStack.snp.makeConstraints { make in
      make.top.equalTo(self.profileImageButton.snp.bottom).offset(56)
      make.directionalHorizontalEdges.equalToSuperview()
      make.width.equalToSuperview()
      make.bottom.equalTo(self.scrollView.snp.bottom)
    }
    
    self.nextButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalTo(self.view.layoutMarginsGuide)
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-Metric.bottomSpacing)
    }
  }  
}
