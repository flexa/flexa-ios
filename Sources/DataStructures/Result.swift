//
//  Result.swift
//  Flexa SDK
//
//  Created by Ash on 12/16/19.
//  Copyright © 2019 Flexa. All rights reserved.
//

import Foundation

enum Result<Value> {
  case success(Value)
  case failure(Error)

  var isSuccess: Bool {
    switch self {
    case .success:
      return true
    case .failure:
      return false
    }
  }

  var value: Value? {
    switch self {
    case .success(let value):
      return value
    case .failure:
      return nil
    }
  }

  var error: Error? {
    switch self {
    case .success:
      return nil
    case .failure(let error):
      return error
    }
  }
}

// MARK: - CustomStringConvertible

extension Result: CustomStringConvertible {
  var description: String {
    switch self {
    case .success:
      return "SUCCESS"
    case .failure:
      return "FAILURE"
    }
  }
}

// MARK: - CustomDebugStringConvertible

extension Result: CustomDebugStringConvertible {
  var debugDescription: String {
    switch self {
    case .success(let value):
      return "SUCCESS: \(value)"
    case .failure(let error):
      return "FAILURE: \(error)"
    }
  }
}

// MARK: - Functional APIs

extension Result {
  init(value: () throws -> Value) {
    do {
      self = try .success(value())
    } catch {
      self = .failure(error)
    }
  }

  func unwrap() throws -> Value {
    switch self {
    case .success(let value):
      return value
    case .failure(let error):
      throw error
    }
  }

  @discardableResult
  func onSuccess(_ closure: (Value) -> Void) -> Result {
    if let value = value {
      closure(value)
    }

    return self
  }

  @discardableResult
  func onFailure(_ closure: (Error) -> Void) -> Result {
    if let error = error {
      closure(error)
    }

    return self
  }
}
