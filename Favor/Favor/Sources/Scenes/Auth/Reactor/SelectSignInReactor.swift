//
//  SelectSignInReactor.swift
//  Favor
//
//  Created by 이창준 on 2023/01/11.
//

import OSLog

import ReactorKit
import RxCocoa
import RxFlow

final class SelectSignInReactor: Reactor, Stepper {
  
  // MARK: - Properties
  
  var initialState: State
  var steps = PublishRelay<Step>()
  
  enum Action {
    case emailLoginButtonTap
    case signUpButtonTap
  }
  
  enum Mutation {
    
  }
  
  struct State {
    
  }
  
  // MARK: - Initializer
  
  init() {
    self.initialState = State()
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    default: return .empty()
    }
  }
  
}
