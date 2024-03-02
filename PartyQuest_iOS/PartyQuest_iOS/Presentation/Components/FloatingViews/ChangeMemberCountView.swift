//
//  ChangeMemberCountView.swift
//  PartyQuest_iOS
//
//  Created by Rowan on 2024/03/02.
//

import UIKit
import RxSwift
import RxCocoa

final class ChangeMemberCountView: UIView, FloatingViewType {
    typealias Value = String
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "최대인원 변경하기"
        label.font = .preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        
        return label
    }()
    
    private let memberCountTextField: TitledTextField = {
        let textField = TitledTextField()
        textField.setTitle("변경 인원")
        textField.setTextFieldBorder(color: PQColor.buttonMain)
        
        return textField
    }()
    
    private let countSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 10
        slider.isContinuous = false
        
        return slider
    }()
    
    private let minimumValueLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.textAlignment = .left
        label.font = PQFont.xsmall
        label.textColor = .systemGray5
        
        return label
    }()
    
    private let maximumValueLabel: UILabel = {
        let label = UILabel()
        label.text = "10"
        label.textAlignment = .right
        label.font = PQFont.xsmall
        label.textColor = .systemGray5
        
        return label
    }()
    
    private let valueLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    private let sliderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        return stackView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = PQColor.buttonMain
        button.setTitle("취소", for: .normal)
        
        return button
    }()
    
    private let adjustButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = PQColor.white
        button.setTitle("적용하기", for: .normal)
        button.backgroundColor = PQColor.buttonMain
        button.layer.cornerRadius = 8
        
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        return stackView
    }()
    
    private let outterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    let changedValue: PublishRelay<Value> = .init()
    
    var adjustButtonTapped: Driver<Void> { adjustButton.rx.tap.asDriver() }
    
    private var disposeBag: DisposeBag = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubviews()
        setConstraints()
        setBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubviews() {
        [minimumValueLabel, maximumValueLabel].forEach {
            valueLabelStackView.addArrangedSubview($0)
        }
        
        [valueLabelStackView, countSlider].forEach {
            sliderStackView.addArrangedSubview($0)
        }
        
        [UIView(), cancelButton, adjustButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        
        [titleLabel, memberCountTextField,
         sliderStackView, buttonStackView].forEach {
            outterStackView.addArrangedSubview($0)
        }
        
        self.addSubview(outterStackView)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            outterStackView.topAnchor.constraint(equalTo: self.topAnchor),
            outterStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            outterStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            outterStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    private func setBindings() {
        countSlider.rx.value
            .map { String($0) }
            .bind(to: changedValue)
            .disposed(by: disposeBag)
    }
}
