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
        let addButtonTapped: Observable<Void>
    }
    
    struct Output {
        let isAddButtonEnable: Driver<Bool>
        let addQuest: Observable<Void>
    }
    
    func transform(_ input: Input) -> Output {
        let contentInputs = Observable
            .combineLatest(input.title, input.description)
        let isContentsEmpty = contentInputs
            .map { title, description in
                if title.isEmpty || description == "설명을 입력하세요." {
                    return true
                }
                
                return false
            }
        
        let dateInputs = Observable
            .combineLatest(dateSubject, timeSubject)
        let isBiggerThanNow = dateInputs
            .map { date, time in
                guard let selectedDate = date,
                      let selectedTime = time else {
                    return false
                }
                
                let calendar = Calendar.current
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: selectedTime)
                
                var combinedComponents = DateComponents()
                combinedComponents.year = dateComponents.year
                combinedComponents.month = dateComponents.month
                combinedComponents.day = dateComponents.day
                combinedComponents.hour = timeComponents.hour
                combinedComponents.minute = timeComponents.minute
                combinedComponents.second = timeComponents.second
                
                let combinedDate = calendar.date(from: combinedComponents)!
                
                if Date() < combinedDate {
                    return true
                } else {
                    return false
                }
            }
        
        let isAddButtonEnable = Observable
            .combineLatest(isContentsEmpty, isBiggerThanNow)
            .map { isContentsEmpty, isBiggerThanNow in
                return !(isContentsEmpty || !isBiggerThanNow)
            }
            .asDriver(onErrorJustReturn: false)
        
        let addQuest = input.addButtonTapped
            .withUnretained(self)
            .map { owner, _ in
                owner.coordinator.toQuestList()
            }
        
        return Output(
            isAddButtonEnable: isAddButtonEnable,
            addQuest: addQuest
        )
    }
}
