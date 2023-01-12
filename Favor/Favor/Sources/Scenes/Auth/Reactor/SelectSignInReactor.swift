//
//  SelectSignInReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import OSLog

import ReactorKit

final class SelectSignInReactor: Reactor {
  
  // MARK: - Properties
  
  weak var coordinator: AuthCoordinator?
  var initialState: State
  
  enum Action {
    case kakaoLoginButtonTap
    case idLoginButtonTap
    case signUpButtonTap
  }
  
  enum Mutation {
    
  }
  
  struct State {
    
  }
  
  // MARK: - Initializer
  
  init(coordinator: AuthCoordinator) {
    self.coordinator = coordinator
    self.initialState = State()
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .kakaoLoginButtonTap:
      os_log(.error, "KakaoSDK login service is not implemented yet.")
      return Observable<Mutation>.empty()
    case .idLoginButtonTap:
      self.coordinator?.showSignInFlow()
      return Observable<Mutation>.empty()
    case .signUpButtonTap:
      self.coordinator?.showSignUpFlow()
      return Observable<Mutation>.empty()
    }
  }
  
}
