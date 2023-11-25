//
//  UserDetailViewController.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/20/23.
//

import UIKit

class UserDetailViewController: UIViewController {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var bioLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    // Keep track of async tasks so they can be cancelled when appropriate.
    var imageRequestTask: Task<Void, Never>? = nil
    var userStatisticsRequestTask: Task<Void, Never>? = nil
    var habitLeadStatisticsRequestTask: Task<Void, Never>? = nil
    
    deinit {
        imageRequestTask?.cancel()
        userStatisticsRequestTask?.cancel()
        habitLeadStatisticsRequestTask?.cancel()
    }
    
    enum SectionHeader: String {
        case kind = "SectionHeader"
        case reuse = "HeaderView"
        
        var identifier: String {
            return rawValue
        }
    }

    
    
    // typealias the data source
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    // Declare the view model and model types
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case leading
            case category(_ category: Category)
            
            static func < (lhs: Section, rhs: Section) -> Bool {
                switch (lhs, rhs) {
                case (.leading, .category), (.leading, .leading):
                    return true
                case (.category, .leading):
                    return false
                case (category(let category1), category(let category2)):
                    return category1.name > category2.name
                }
            }
        }
        typealias Item = HabitCount
    }
  
    // Declare properties for the model and data source
    struct Model {
        var userStats: UserStatistics?
        var leadingStats: UserStatistics?
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    var user: User!
    // To display the habits that the user leads in a section at the top of the collection view, followed by sections for each category for the remaining habits.
    // Use HabitCount as the view model type for items in the collection view, since the properties of HabitCount map directly to the data you need to display in your cells, The model contains both sets of statistics.
    
    // Set uptimed API polling for this detail screen.
    var updateTimer: Timer?

    // Enable Segue action from the habit collection view controller
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    init?(coder: NSCoder, user: User) {
        self.user = user
        super.init(coder: coder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameLabel.text = user.name
        bioLabel.text = user.bio

        // Register a header view
        collectionView.register(NamedSectionHeaderView.self, forSupplementaryViewOfKind: SectionHeader.kind.identifier, withReuseIdentifier: SectionHeader.reuse.identifier)
        //"SectionHeader", withReuseIdentifier: "HeaderView")
        
        // Set up data source and collection view and call the update() method to populate your data source
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        
        update()
        
        
    }
    
    // start and stop the periodic updates
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        update()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.update()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateTimer?.invalidate()
        updateTimer = nil
    }
                                           

    // Configure your cells with habit log count information
    // (also, set the contentConfiguration to prefer side by side text and set the fonts appropriately)
    // and to configure section headers.
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { (collectionView, indexPath, habitStat) -> UICollectionViewCell?  in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitCount", for: indexPath) as! UICollectionViewListCell
            print("habitStat - \(habitStat)")
            var content = UIListContentConfiguration.subtitleCell()
            content.text = habitStat.habit.name
            content.secondaryText = "\(habitStat.count)"
            
            content.prefersSideBySideTextAndSecondaryText = true
            content.textProperties.font = .preferredFont(forTextStyle: .headline)
            content.secondaryTextProperties.font = .preferredFont(forTextStyle: .body)
            cell.contentConfiguration = content
            
            return cell
            
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, category, indexPath) in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: SectionHeader.kind.identifier, withReuseIdentifier: SectionHeader.reuse.identifier, for: indexPath) as! NamedSectionHeaderView
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .leading:
                header.nameLabel.text = "Leading"
            case .category(let category):
                header.nameLabel.text = category.name
            }
            
            return header
        }
        return dataSource
    }

    // For the copositinla layout
    func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: SectionHeader.kind.identifier, alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    
    func update() {
        userStatisticsRequestTask?.cancel()
        userStatisticsRequestTask = Task {
            if let userStats = try? await UserStatisticsRequest(userIDs: [user.id]).send(), userStats.count > 0 {
                self.model.userStats = userStats[0]
            } else {
                self.model.userStats = nil
            }
            self.updateCollectionView()
            
            userStatisticsRequestTask = nil
        }
        
        habitLeadStatisticsRequestTask?.cancel()
        habitLeadStatisticsRequestTask = Task {
            if let userStats = try? await HabitLeadStatisticsRequest(userID: user.id).send() {
                self.model.leadingStats = userStats
            } else {
                self.model.leadingStats = nil
            }
            self.updateCollectionView()
            
            habitLeadStatisticsRequestTask = nil
        }
        
    }
    
    func updateCollectionView() {
        guard let userStatistics = model.userStats, let leadingStatistics = model.leadingStats else {
            return }
        var itemsBySection = userStatistics.habitCounts.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) { partial, habitCount in
            let section: ViewModel.Section
            
            if leadingStatistics.habitCounts.contains(habitCount) {
                section = .leading
            } else {
                section = .category(habitCount.habit.category)
            }
            
            partial[section, default: []].append(habitCount)
        }
        itemsBySection = itemsBySection.mapValues { $0.sorted() }
        let sectionIDs = itemsBySection.keys.sorted()
        
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection)
        
    }

}
