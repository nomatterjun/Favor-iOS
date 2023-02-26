//
//  AuthType.swift
//  Favor
//
//  Created by 이창준 on 2023/02/26.
//

enum AuthType {
  case email, password, confirmPassword

  var regex: String {
    switch self {
    case .email: return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    case .password: return "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}"
    case .confirmPassword: return ""
    }
  }

  var emptyDescription: String {
    switch self {
    case .email: return "실제 사용하는 이메일을 입력해주세요."
    case .password: return "영문, 숫자 혼용 8자 이상"
    case .confirmPassword: return "비밀번호를 한 번 더 입력해주세요."
    }
  }

  var invalidDescription: String {
    switch self {
    case .email: return "이메일 형식이 올바르지 않습니다."
    case .password: return "영문, 숫자 혼용 8자 이상"
    case .confirmPassword: return "비밀번호가 일치하지 않습니다."
    }
  }

  var validDescription: String {
    switch self {
    case .email: return "사용 가능한 이메일입니다."
    case .password: return "사용 가능한 비밀번호입니다."
    case .confirmPassword: return "비밀번호가 일치합니다."
    }
  }
}
