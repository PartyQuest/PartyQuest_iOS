//
//  UserAuthentificationUsecase.swift
//  PartyQuest_iOS
//
//  Created by Rowan on 2023/11/02.
//

import Foundation

protocol UserAuthentificationUsecase {
    func logIn(email: String, password: String)
    func signUp(email: String, password: String, nickname: String, birth: String)
}
