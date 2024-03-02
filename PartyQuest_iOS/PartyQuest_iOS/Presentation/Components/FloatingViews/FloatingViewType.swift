//
//  FloatingViewType.swift
//  PartyQuest_iOS
//
//  Created by Rowan on 2024/03/02.
//

import UIKit
import RxSwift
import RxCocoa

protocol FloatingViewType: UIView {
    associatedtype Value
    
    var changedValue: PublishRelay<Value> { get }
    
    var adjustButtonTapped: Driver<Void> { get }
}
