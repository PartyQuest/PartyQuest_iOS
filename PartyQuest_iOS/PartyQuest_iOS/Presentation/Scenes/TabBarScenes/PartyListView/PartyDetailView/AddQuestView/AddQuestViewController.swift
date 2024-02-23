//
//  AddQuestViewController.swift
//  PartyQuest_iOS
//
//  Created by Harry on 2024/01/25.
//

import UIKit
import RxSwift
import RxCocoa

enum DatePickerItem: Hashable {
    case header(Date?)
    case picker(Date?, UIAction)
}

enum TimePickerItem: Hashable {
    case header(Date?)
    case picker(Date?, UIAction)
}

enum DateSection {
    case date
    case time
}

final class AddQuestViewController: UIViewController {
    private let addQuestTitleView = {
        let addQuestTitleView = AddQuestTitleView()
        addQuestTitleView.translatesAutoresizingMaskIntoConstraints = false
        
        return addQuestTitleView
    }()
    
    private let addQuestContentView = {
        let addQuestContentView = AddQuestContentView()
        addQuestContentView.translatesAutoresizingMaskIntoConstraints = false
        
        return addQuestContentView
    }()
    
    private typealias DataSource = UICollectionViewDiffableDataSource<DateSection, AnyHashable>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<DateSection, AnyHashable>
    private typealias DateHeaderCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, DatePickerItem>
    private typealias TimeHeaderCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, TimePickerItem>
    private typealias DatePickerCellRegistration = UICollectionView.CellRegistration<DatePickerCell, DatePickerItem>
    private typealias TimePickerCellRegistration = UICollectionView.CellRegistration<TimePickerCell, TimePickerItem>
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: createCollectionViewLayout())
        collectionView.layer.cornerRadius = 10
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private var dataSource: DataSource!
    private let viewModel: AddQuestViewModel
    private let disposBag: DisposeBag
    
    init(viewModel: AddQuestViewModel) {
        self.viewModel = viewModel
        self.disposBag = .init()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureRootView()
        setSubViews()
        setConstraints()
        configureDataSource()
        applyInitialSnapshot()
        setBindings()
    }
    
    private func configureRootView() {
        view.backgroundColor = .systemGray6
    }
    
    private func setSubViews() {
        view.addSubview(addQuestTitleView)
        view.addSubview(addQuestContentView)
        view.addSubview(collectionView)
    }
    
    private func setConstraints() {
        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            addQuestTitleView.topAnchor.constraint(equalTo: safe.topAnchor, constant: 12),
            addQuestTitleView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 12),
            addQuestTitleView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -12),
            addQuestTitleView.bottomAnchor.constraint(equalTo: safe.topAnchor, constant: 40),
            
            addQuestContentView.topAnchor.constraint(equalTo: addQuestTitleView.bottomAnchor, constant: 20),
            addQuestContentView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 12),
            addQuestContentView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -12),
            
            collectionView.topAnchor.constraint(equalTo: addQuestContentView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 12),
            collectionView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -12),
            collectionView.bottomAnchor.constraint(equalTo: safe.bottomAnchor)
        ])
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            switch section {
            default:
                let config = UICollectionLayoutListConfiguration(appearance: .grouped)
                let listSection = NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
                listSection.contentInsets = .zero
                
                return listSection
            }
        }
        
        return layout
    }
    
    private func configureDataSource() {
        let dateHeaderCellRegistration = DateHeaderCellRegistration { cell, indexPath, item in
            if case let DatePickerItem.header(date) = item {
                var content = cell.defaultContentConfiguration()
                content.image = UIImage(named: "Calendar")
                content.text = "날짜"
                content.secondaryTextProperties.color = .systemBlue
                content.secondaryText = PQDateFormatter.shared.dateToDefaultString(from: date) ?? " "
                cell.contentConfiguration = content
            }
            
            let headerDisclosuerOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options: headerDisclosuerOption)]
            
        }
        
        let timeHeaderCellRegistration = TimeHeaderCellRegistration { cell, indexPath, item in
            if case let TimePickerItem.header(time) = item {
                var content = cell.defaultContentConfiguration()
                content.image = UIImage(named: "Clock")
                content.text = "시간"
                content.secondaryTextProperties.color = .systemBlue
                content.secondaryText = PQDateFormatter.shared.dateToTimeString(from: time) ?? " "
                cell.contentConfiguration = content
            }
            
            let headerDisclosuerOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options: headerDisclosuerOption)]
        }
        
        let datePickerCellRegistration = DatePickerCellRegistration { cell, indexPath, item in
            cell.item = item
        }
        
        let timePickerCellRegistration = TimePickerCellRegistration { cell, indexPath, item in
            cell.item = item
        }
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            if let datePickerItem = item as? DatePickerItem {
                switch datePickerItem {
                case .header(_):
                    return collectionView.dequeueConfiguredReusableCell(using: dateHeaderCellRegistration,
                                                                        for: indexPath,
                                                                        item: datePickerItem)
                case .picker(_, _):
                    return collectionView.dequeueConfiguredReusableCell(using: datePickerCellRegistration,
                                                                        for: indexPath,
                                                                        item: datePickerItem)
                }
            } else if let timePickerItem = item as? TimePickerItem {
                switch timePickerItem {
                case .header(_):
                    return collectionView.dequeueConfiguredReusableCell(using: timeHeaderCellRegistration,
                                                                        for: indexPath,
                                                                        item: timePickerItem)
                case .picker(_, _):
                    return collectionView.dequeueConfiguredReusableCell(using: timePickerCellRegistration,
                                                                        for: indexPath,
                                                                        item: timePickerItem)
                }
            }
            
            return UICollectionViewCell()
        }
    }
    
    private func applyInitialSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.date, .time])
        dataSource.apply(snapshot)
        
        var dateSectionSnapShot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
        let dateHeader = DatePickerItem.header(nil)
        dateSectionSnapShot.append([dateHeader])
        
        let datePickerAction = UIAction { [weak self] action in
            guard let picker = action.sender as? UIDatePicker else {
                return
            }
            
            self?.reloadDateHeader(with: picker.date)
        }
        
        let datePicker = DatePickerItem.picker(nil, datePickerAction)
        dateSectionSnapShot.append([datePicker], to: dateHeader)
        
        var timeSectionSnapShot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
        let timeHeader = TimePickerItem.header(nil)
        timeSectionSnapShot.append([timeHeader])
    
        let timePickerAction = UIAction { [weak self] action in
            guard let picker = action.sender as? UIDatePicker else {
                return
            }
            
            self?.reloadTimeHeader(with: picker.date)
        }
        
        let timePicker = TimePickerItem.picker(nil, timePickerAction)
        timeSectionSnapShot.append([timePicker], to: timeHeader)
        
        dataSource.apply(dateSectionSnapShot, to: .date, animatingDifferences: false)
        dataSource.apply(timeSectionSnapShot, to: .time, animatingDifferences: false)
    }
    
    private func reloadDateHeader(with date: Date) {
        let dateSectionSnapshot = dataSource.snapshot(for: .date)
        
        guard let olderHeaderItem = dateSectionSnapshot.rootItems.first,
              let datePickerItem = dateSectionSnapshot.snapshot(of: olderHeaderItem).items.first else {
            return
        }
        
        let newHeaderItem = DatePickerItem.header(date)
        
        var newDateSectionSnapshot = dateSectionSnapshot
        
        newDateSectionSnapshot.insert([newHeaderItem], before: olderHeaderItem)
        newDateSectionSnapshot.delete([olderHeaderItem])
        newDateSectionSnapshot.append([datePickerItem], to: newHeaderItem)
        newDateSectionSnapshot.expand([newHeaderItem])
        
        viewModel.dateSubject.onNext(date)
        dataSource.apply(newDateSectionSnapshot, to: .date, animatingDifferences: false)
    }
    
    private func reloadTimeHeader(with date: Date) {
        let timeSectionSnapshot = dataSource.snapshot(for: .time)
        
        guard let olderHeaderItem = timeSectionSnapshot.rootItems.first,
              let timePickerItem = timeSectionSnapshot.snapshot(of: olderHeaderItem).items.first else {
                  return
              }
        
        let newHeaderItem = TimePickerItem.header(date)
        
        var newTimeSectionSnapshot = timeSectionSnapshot
        
        newTimeSectionSnapshot.insert([newHeaderItem], before: olderHeaderItem)
        newTimeSectionSnapshot.delete([olderHeaderItem])
        newTimeSectionSnapshot.append([timePickerItem], to: newHeaderItem)
        newTimeSectionSnapshot.expand([newHeaderItem])
        
        viewModel.timeSubject.onNext(date)
        dataSource.apply(newTimeSectionSnapshot, to: .time, animatingDifferences: false)
    }
    
    private func setBindings() {
        let startEditingTextView = addQuestContentView.descriptionTextView.rx.didBeginEditing.asObservable()

        startEditingTextView
            .withUnretained(self)
            .subscribe { owner, _ in
                if owner.addQuestContentView.descriptionTextView.text == "설명을 입력하세요." {
                    owner.addQuestContentView.descriptionTextView.text = nil
                    owner.addQuestContentView.descriptionTextView.textColor = .black
                }
            }
            .disposed(by: disposBag)

        addQuestContentView.titleTextField.rx.text
            .orEmpty
            .scan("") { (previousText, newText) in
                let maxLength = 22

                return newText.count > maxLength ? previousText : newText
            }
            .bind(to: addQuestContentView.titleTextField.rx.text)
            .disposed(by: disposBag)

        addQuestContentView.descriptionTextView.rx.text
            .orEmpty
            .scan("") { (previousText, newText) in
                let maxLength = 130

                return newText.count > maxLength ? previousText : newText
            }
            .bind(to: addQuestContentView.descriptionTextView.rx.text)
            .disposed(by: disposBag)
        
        collectionView.rx.willDisplayCell.asObservable()
            .subscribe(with: self) { owner, emitter in
                if emitter.at == IndexPath(item: 0, section: 1) {
                    return
                }
                
                owner.collectionView.scrollToItem(at: emitter.at, at: .bottom, animated: true)
            }
            .disposed(by: disposBag)
        
        
        let title = addQuestContentView.titleTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
        let description = addQuestContentView.descriptionTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
        
        let input = AddQuestViewModel.Input(
            title: title, description: description
        )
        
        let output = viewModel.transform(input)
        
        output.isAddButtonEnable
            .drive(with: self) { owner, isAddButtonEnable in
                owner.addQuestTitleView.addButton.isEnabled = isAddButtonEnable
            }
            .disposed(by: disposBag)
        
        
    }
}

