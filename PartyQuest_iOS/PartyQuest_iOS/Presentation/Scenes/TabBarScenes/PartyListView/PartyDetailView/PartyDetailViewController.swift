//
//  PartyDetailViewController.swift
//  PartyQuest_iOS
//
//  Created by Harry on 2024/01/03.
//

import UIKit
import RxSwift
import RxCocoa

final class PartyDetailViewController: UIViewController {
    private lazy var sideBarButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let line3Image = UIImage(systemName: "line.3.horizontal", withConfiguration: imageConfig)
        let button = UIButton()
        button.setImage(line3Image, for: .normal)
        button.tintColor = .darkGray
        
        return button
    }()
    
    private let sideBarViewController: SideBarViewController = {
        let viewController = SideBarViewController()
        
        return viewController
    }()
    
    private lazy var dimmingView: UIView = {
        let view = UIView(frame: view.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.isHidden = true
        
        return view
    }()
    
    private lazy var segmentedControl: UnderlineSegmentedControl = {
        let segmentedControl = UnderlineSegmentedControl(items: ["예정", "진행중", "완료"])
        segmentedControl.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.gray],
            for: .normal
        )
        segmentedControl.setTitleTextAttributes(
            [
                NSAttributedString.Key.foregroundColor: PQColor.buttonMain,
                .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
            ],
            for: .selected
        )
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        return segmentedControl
    }()
    
    private let todoViewController: QuestListViewController = {
        let viewController = QuestListViewController(status: .todo)
        
        return viewController
    }()
    
    private let doingViewController: QuestListViewController = {
        let viewController = QuestListViewController(status: .doing)
        
        return viewController
    }()
    
    private let doneViewController: QuestListViewController = {
        let viewController = QuestListViewController(status: .done)
        
        return viewController
    }()
    
    private var pages: [UIViewController] {
        [todoViewController, doingViewController, doneViewController]
    }
    
    private var currentPage: Int = 0 {
        didSet {
            let direction: UIPageViewController.NavigationDirection = oldValue <= currentPage ? .forward : .reverse
            
            pageViewController.setViewControllers(
                [pages[currentPage]],
                direction: direction,
                animated: true,
                completion: nil
            )
        }
    }
    
    private lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                      navigationOrientation: .horizontal)
        pageViewController.setViewControllers([pages[0]],
                                              direction: .forward,
                                              animated: true)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        return pageViewController
    }()
    
    private let viewModel: PartyDetailViewModel
    private let disposeBag: DisposeBag
    
    init(viewModel: PartyDetailViewModel) {
        self.viewModel = viewModel
        self.disposeBag = .init()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureRootView()
        setSubviews()
        setConstraints()
        setBindings()
    }
    
    private func configureNavigationBar() {
        sideBarButton.addTarget(self, action: #selector(showSideBar), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sideBarButton)
    }
    
    private func configureRootView() {
        view.backgroundColor = .systemGray6
    }
    
    
    private func setSubviews() {
        view.addSubview(segmentedControl)
        view.addSubview(pageViewController.view)
        
        setDimmingView()
    }
    
    private func setConstraints() {
        let safe = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: safe.topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -10),
            segmentedControl.heightAnchor.constraint(equalTo: safe.widthAnchor, multiplier: 0.1),
            
            pageViewController.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor,
                                                         constant: 5),
            pageViewController.view.leadingAnchor.constraint(equalTo: safe.leadingAnchor,
                                                             constant: 10),
            pageViewController.view.trailingAnchor.constraint(equalTo: safe.trailingAnchor,
                                                              constant: -10),
            pageViewController.view.bottomAnchor.constraint(equalTo: safe.bottomAnchor)
        ])
    }
    
    private func setBindings() {
        segmentedControl.rx.value.changed.asDriver()
            .drive(with: self) { owner, index in
                owner.currentPage = index
            }
            .disposed(by: disposeBag)
        
        let viewWillAppearEvent = self.rx.viewWillAppear
        
        let input = PartyDetailViewModel.Input(viewWillAppearEvent: viewWillAppearEvent)
        
        let output = viewModel.transform(input)
        
        output.todoQeusts
            .withUnretained(self)
            .subscribe { owner, todoQeusts in
                owner.todoViewController.items.accept(todoQeusts)
            }
            .disposed(by: disposeBag)
        
        output.doingQeusts
            .withUnretained(self)
            .subscribe { owner, doingQeusts in
                owner.doingViewController.items.accept(doingQeusts)
            }
            .disposed(by: disposeBag)
        
        output.doneQeusts
            .withUnretained(self)
            .subscribe { owner, doneQeusts in
                owner.doneViewController.items.accept(doneQeusts)
            }
            .disposed(by: disposeBag)
    }
}

extension PartyDetailViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController),
              index - 1 >= 0 else {
            return nil
        }
        
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController),
              index + 1 < pages.count else {
            return nil
        }
        
        return pages[index + 1]
    }
}

extension PartyDetailViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = pageViewController.viewControllers?[0],
              let index = pages.firstIndex(of: viewController) else {
            return
        }
        
        segmentedControl.selectedSegmentIndex = index
        currentPage = index
    }
}

// MARK: - SideBar
extension PartyDetailViewController {
    private func setDimmingView() {
        view.addSubview(dimmingView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmingViewDidTap))
        dimmingView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dimmingViewDidTap() {
        let menuWidth = self.view.frame.width * 0.7
        
        UIView.animate(withDuration: 0.3, animations: {
            self.sideBarViewController.view.frame = CGRect(x: self.view.frame.width,
                                                      y: 0,
                                                      width: menuWidth,
                                                      height: self.view.frame.height)
            self.dimmingView.alpha = 0
        }) { _ in
            self.sideBarViewController.view.removeFromSuperview()
            self.sideBarViewController.removeFromParent()
            self.dimmingView.isHidden = true
            self.sideBarButton.isHidden = false
        }
    }
    
    @objc
    private func showSideBar() {
//        self.addChild(sideBarViewController)
//        self.view.addSubview(sideBarViewController.view)
        tabBarController?.addChild(sideBarViewController)
        tabBarController?.view.addSubview(sideBarViewController.view)
        
        let menuWidth = self.view.frame.width * 0.7
        let menuHeight = self.view.frame.height
        
        sideBarViewController.view.frame = CGRect(x: view.frame.width + menuWidth,
                                                  y: 0,
                                                  width: menuWidth,
                                                  height: menuHeight)
        dimmingView.isHidden = false
        dimmingView.alpha = 0.7
        sideBarButton.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.sideBarViewController.view.frame = CGRect(x: self.view.frame.width - menuWidth,
                                                      y: 0,
                                                      width: menuWidth,
                                                      height: menuHeight)
            
        }
    }
}
