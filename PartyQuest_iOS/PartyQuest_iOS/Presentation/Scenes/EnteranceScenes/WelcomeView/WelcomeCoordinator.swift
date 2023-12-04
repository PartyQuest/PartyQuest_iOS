//
//  WelcomeCoordinator.swift
//  PartyQuest_iOS
//
//  Created by Harry on 2023/10/27.
//

import UIKit
import RxSwift

final class WelcomeCoordinator: BaseCoordinator {
    private let authenticationUseCaseProvider: AuthenticationUseCaseProvider
    private let socialUserDataUseCaseProvider: SocialUserDataUseCaseProvider
    private let serviceTokenUseCaseProvider: ServiceTokenUseCaseProvider
    private let isLoggedIn: PublishSubject<Bool>
    
    private let disposeBag: DisposeBag = .init()
    
    init(navigationController: UINavigationController,
         authenticationUseCaseProvider: AuthenticationUseCaseProvider,
         socialUserDataUseCaseProvider: SocialUserDataUseCaseProvider,
         serviceTokenUseCaseProvider: ServiceTokenUseCaseProvider,
         isLoggedIn: PublishSubject<Bool>) {
        self.authenticationUseCaseProvider = authenticationUseCaseProvider
        self.socialUserDataUseCaseProvider = socialUserDataUseCaseProvider
        self.serviceTokenUseCaseProvider = serviceTokenUseCaseProvider
        self.isLoggedIn = isLoggedIn
        
        super.init(navigationController: navigationController)
        setBindings()
    }
    
    override func start() {
        let welcomeViewModel = WelcomeViewModel(
            coordinator: self,
            serviceTokenUseCase: serviceTokenUseCaseProvider.makeDefaultServiceTokenUseCase()
        )
        let welcomeViewController = WelcomeViewController(welcomeViewModel: welcomeViewModel)
        
        navigationController.pushViewController(welcomeViewController, animated: true)
    }
    
    override func didFinish(coordinator: Coordinator) {
        super.didFinish(coordinator: coordinator)
        navigationController.popViewController(animated: true)
    }
    
    func coordinateToLogin() {
        let loginCoordinator = LogInCoordinator(
            navigationController: navigationController,
            authenticationUseCaseProvider: authenticationUseCaseProvider,
            socialUserDataUseCaseProvider: socialUserDataUseCaseProvider,
            serviceTokenUseCaseProvider: serviceTokenUseCaseProvider,
            isLoggedIn: isLoggedIn
        )

        self.start(coordinator: loginCoordinator)
    }
    
    func coordinateToSignUp() {
        let signUpCoordinator = SignUpCoordinator(
            navigationController: navigationController,
            useCaseProvider: authenticationUseCaseProvider
        )
        
        self.start(coordinator: signUpCoordinator)
    }
}

extension WelcomeCoordinator {
    private func setBindings() {
        isLoggedIn
            .debug("Welcome logged in stream")
            .subscribe(with: self, onNext: { owner, isLoggedIn in
                if isLoggedIn {
                    owner.childCoordinators.forEach {
                        owner.didFinish(coordinator: $0)
                    }
                    owner.parentCoordinator?.didFinish(coordinator: self)
                }
            })
            .disposed(by: disposeBag)
    }
}
