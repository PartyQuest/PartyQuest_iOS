//
//  FloatingViewController.swift
//  PartyQuest_iOS
//
//  Created by Rowan on 2024/03/02.
//

import UIKit
import RxSwift
import RxCocoa

final class FloatingViewController<FloatingView: FloatingViewType>: UIViewController {
    private let floatingView: FloatingView
    
    private let floatingViewWidthRatio: CGFloat
    private let floatingViewHeightRatio: CGFloat
    
    private var disposeBag: DisposeBag = .init()
    
    init(floatingView: FloatingView, widthRatio: CGFloat, heightRatio: CGFloat) {
        self.floatingView = floatingView
        self.floatingViewWidthRatio = widthRatio
        self.floatingViewHeightRatio = heightRatio
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposeBag = .init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSubviews()
        setConstraints()
    }
    
    private func setSubviews() {
        view.addSubview(floatingView)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            floatingView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: floatingViewWidthRatio),
            floatingView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: floatingViewHeightRatio),
            floatingView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            floatingView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
}
