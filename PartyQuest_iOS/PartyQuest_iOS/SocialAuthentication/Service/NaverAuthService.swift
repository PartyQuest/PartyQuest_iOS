//
//  NaverAuthService.swift
//  PartyQuest_iOS
//
//  Created by Rowan on 2023/12/05.
//

import RxSwift
import Alamofire
import RxAlamofire
import NaverThirdPartyLogin

enum NaverLogInError: Error {
    case accessTokenExpired
    case tokenTypeNotFound
    case nilUserData
}

final class NaverAuthService: NSObject, SocialAuthService {
    typealias UserInfo = NaverUser
    
    private let logInInstance: NaverThirdPartyLoginConnection = NaverThirdPartyLoginConnection.getSharedInstance()
    private let accessToken: PublishSubject<String> = .init()
    
    func requestLogIn() -> Observable<Void> {
        logInInstance.requestThirdPartyLogin()

        return accessToken.asObservable()
            .map { _ in }
    }
    
    func getUserInfo() -> Observable<UserInfo> {
        return accessToken.asObservable()
            .withUnretained(self)
            .flatMap { owner, token in
                try owner.requestUserInfo(with: token)
            }
            .map { JSONData in
                guard let dictionary = JSONData as? [String: Any],
                      let email = dictionary["email"] as? String,
                      let nickName = dictionary["nickname"] as? String else {
                    throw NaverLogInError.nilUserData
                }
                
                return NaverUser(email: email, nickName: nickName)
            }
    }
    
    private func requestUserInfo(with token: String) throws -> Observable<Any> {
        if logInInstance.isValidAccessTokenExpireTimeNow() == false {
            throw NaverLogInError.accessTokenExpired
        }
        
        guard let tokenType = logInInstance.tokenType else {
            throw NaverLogInError.tokenTypeNotFound
        }
        
        let url = URL(string: "https://openapi.naver.com/v1/nid/me")!
        let authorization = "\(tokenType) \(token)"
        
        return RxAlamofire.json(.get,
                                url,
                                parameters: nil,
                                encoding: URLEncoding.default,
                                headers: ["Authorization": authorization])
    }
}

extension NaverAuthService: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Naver Logged In")
        accessToken.onNext(logInInstance.accessToken)
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("Naver Access Token Refreshed")
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("Naver Logged Out")
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("Naver LogIn Failed with Error: \(error.localizedDescription)")
        accessToken.onError(error)
    }
}
