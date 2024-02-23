//
//  AddQuestCoordinator.swift
//  PartyQuest_iOS
//
//  Created by Harry on 2024/01/25.
//

import UIKit

protocol AddQuestCoordinatorType: Coordinator {}

final class AddQuestCoordinator: AddQuestCoordinatorType {
    var navigationController: UINavigationController?
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = AddQuestViewModel(coordinator: self)
        let addQuestViewController = AddQuestViewController(viewModel: viewModel)
        
        navigationController?.present(addQuestViewController, animated: true)
    }
    
    func toQuestList() {
        finish()
        navigationController?.dismiss(animated: true)
    }
}
