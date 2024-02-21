//
//  SignUpViewController.swift
//  MobileAcebook
//
//  Created by Andre George on 20/02/2024.
//

import UIKit
import Foundation
import Combine

func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

func isValidPassword(password: String) -> Int {
    if password.count < 8 {
        return 1
    } else if !password.contains(/[a-zA-Z0-9]/) {
        return 2
    } else {
        return 0
    }
    
    
}







final class AuthenticationViewModel: ObservableObject {
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var hasEightChar = false
    @Published var hasSpacialChar = false
    @Published var hasOneDigit = false
    @Published var hasOneUpperCaseChar = false
    @Published var confirmationMatch = false
    @Published var areAllFieldsValid = false
    
    init() {
        validateSignUpFields()
    }
    
    private func validateSignUpFields() {
        /// Check password has minimum 8 characters
        $password
            .map { password in
                password.count >= 8
            }
            .assign(to: &$hasEightChar)
        /// Check password has minimum 1 special character
        $password
            .map { password in
                password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|:\"';<>,.?/~`")) != nil
            }
            .assign(to: &$hasSpacialChar)
        /// Check password has minimum 1 digit
        $password
            .map { password in
                password.contains { $0.isNumber }
            }
            .assign(to: &$hasOneDigit)
        /// Check password has minimum 1 uppercase letter
        $password
            .map { password in
                password.contains { $0.isUppercase }
            }
            .assign(to: &$hasOneUpperCaseChar)
        /// Check confirmation match password
        Publishers.CombineLatest($password, $confirmPassword)
            .map { [weak self] _, _ in
                guard let self else { return false}
                return self.password == self.confirmPassword
            }
            .assign(to: &$confirmationMatch)
        /// Check all fields match
        Publishers.CombineLatest($password, $confirmPassword)
            .map { [weak self] _, _ in
                guard let self else { return false}
                return self.hasEightChar && self.hasSpacialChar && self.hasOneDigit && self.hasOneUpperCaseChar && self.confirmationMatch
            }
            .assign(to: &$areAllFieldsValid)
    }
}
