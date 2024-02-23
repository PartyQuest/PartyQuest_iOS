//
//  AddQuestViewModel.swift
//  PartyQuest_iOS
//
//  Created by Harry on 2024/01/25.
//

import RxSwift
import RxCocoa

final class AddQuestViewModel {
    private let coordinator: AddQuestCoordinator
    
    let dateSubject: BehaviorSubject<Date?> = .init(value: nil)
    let timeSubject: BehaviorSubject<Date?> = .init(value: nil)
    
    init(coordinator: AddQuestCoordinator) {
        self.coordinator = coordinator
    }
}

extension AddQuestViewModel: ViewModelType {
    struct Input {
        let title: Observable<String>
        let description: Observable<String>
    }
    
    struct Output {
        let isAddButtonEnable: Driver<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        let contentInputs = Observable
            .combineLatest(input.title, input.description)
        let isContentEmpty = contentInputs
            .map { title, description in
                if title.isEmpty || description.isEmpty {
                    return true
                }
                
                return false
            }
        
        let dateInputs = Observable
            .combineLatest(dateSubject, timeSubject)
        let isDateEmpty = dateInputs
            .map { date, time in
                guard let _ = date,
                      let _ = time else {
                    return true
                }
                
                return false
            }
        
        let isAddButtonEnable = Observable
            .combineLatest(isContentEmpty, isDateEmpty)
            .map { isContentEmpty, isDateEmpty in
                return !(isContentEmpty || isDateEmpty)
            }
            .asDriver(onErrorJustReturn: false)
        
        return Output(
            isAddButtonEnable: isAddButtonEnable
        )
    }
}
