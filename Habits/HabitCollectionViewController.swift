//
//  HabitCollectionViewController.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/20/23.
//

import UIKit

private let reuseIdentifier = "Cell"
let favoriteHabitColor = UIColor(hue: 0.15, saturation: 1, brightness: 0.9, alpha: 1)

class HabitCollectionViewController: UICollectionViewController {
    

    // MVVM approach to separate
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum SectionHeader: String {
        case kind = "SectionHeader"
        case reuse = "HeaderView"
        
        var identifier: String {
            return rawValue
        }
    }

    // ViewModel Encapsulates everything the collection view needs to display its data.
    // ViewModel has no cases, creating a namespace to enclose the two types of view model objects
    // that will represent the section identifiers and item identifiers for the data source.
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case favorites
            case category(_ category: Category)
            
            static func < (lhs: Section, rhs: Section) -> Bool {
                switch (lhs, rhs) {
                case (.category(let l), .category(let r)):
                    return l.name < r.name
                case (.favorites, _):
                    return true
                case (_, .favorites):
                    return false
                 }
            }

            var sectionColor: UIColor {
                switch self {
                case .favorites:
                    return favoriteHabitColor
//               case .favorites:
//                    return UIColor(hue: 0.15, saturation: 1, brightness: 0.9, alpha: 1)
                case .category(let category):
                    return category.color.uiColor
                }
            }
        }
        // The habit view controller will contain a Favorite section at the top, followed by one section for each category of habits.
        // Each item will represent a habit, and since there's no meaningful distinction between the view model and model itself,
        // you'll use a typealias.
        typealias Item = Habit
    }
    
    // The Model struct isn't necessary, but useful as an explicit reference to the separation of the model from the view model.
    // Its sole property is the dictionary of habits you received from the API service.
    struct Model {
        var habitsByName = [String : Habit]()

        // A computed property for favorite habits to encapsulate the call to Settings
        var favoriteHabits: [Habit] {
            return Settings.shared.favoriteHabits
        }
        
    }
    
    // Inplicitly unwrap UICollectionViewDiffableDataSourde instance, to concisely declare it.
    var dataSource: DataSourceType!
    // To store the data model after it's fetched from the network
    var model = Model()
    // Notice that you don't have a viewModel property. You'll construct a new view model each time you receive an update from the API
    // and use it to create a snapshot, so there's no need for you to maintain your own copy
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.register(NamedSectionHeaderView.self, forSupplementaryViewOfKind: SectionHeader.kind.identifier, withReuseIdentifier: SectionHeader.reuse.identifier)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        update()
    }
    
    
    // Get habit objects from the server and an empty declaration for a method to update the collection view once the API has returned data.
    func update() {
        habitsRequestTask?.cancel()
        habitsRequestTask = Task {
            if let habits = try? await HabitRequest().send() {
                self.model.habitsByName = habits
            } else {
                self.model.habitsByName = [:]
            }
            self.updateCollectionView()
            
            habitsRequestTask = nil
        }
    }
    
    func updateCollectionView() {
        // Build a dictionary that maps each section to its associated array items using a call to reduce(into:_:). Create the appropriate item and add it to the dictionary.
        // Change let to var to sort itemsBySection
        var itemsBySection = model.habitsByName.values.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) {
            partial, habit in
            let item = habit
            let section: ViewModel.Section
            if model.favoriteHabits.contains(habit) {
                section = .favorites
            } else {
                section = .category(habit.category)
            }
            partial[section, default: []].append(item)
        }
        
        // Sort itemsBySection. mapValues(_:) is a handy method for dictionaries that applies the provided closure to each of the values in the dictionary.
        itemsBySection = itemsBySection.mapValues { $0.sorted() }
        
        // An array of section IDs for all the categories, sorted by name.
        // (Categories with no items - which would happen if the user adds all habits from a category to their favorites - have been automatically excluded from this dictionary above.)
        let sectionIDs = itemsBySection.keys.sorted()
        
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection)

    }
    
    // Keep track of async tasks so they can be cancelled when appropriate
    var habitsRequestTask: Task<Void, Never>? = nil
    // To make sure the task is cancelled if the instance of the class is no longer in use but the task has not completed.
    // deinit is called just before the instance is deallocated. The superclass's deinit method will also be called, automatically.
    deinit { habitsRequestTask?.cancel() }
    

    func configureCell(_ cell: UICollectionViewListCell, withItem item: HabitCollectionViewController.ViewModel.Item) {
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        cell.contentConfiguration = content
    }

    // Create createDataSource() method to feed data to the collection view.
    // Dequeue and set up UICollectionViewListCell’s according to the contents of the view model item from the snapshot.
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) {
            (colectionView, indexPath, item) in
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "Habit", for: indexPath) as! UICollectionViewListCell
            
            self.configureCell(cell, withItem: item)
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: SectionHeader.kind.identifier, withReuseIdentifier: SectionHeader.reuse.identifier, for: indexPath) as! NamedSectionHeaderView

            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]

            switch section {
            case .favorites:
                header.nameLabel.text = "Favorites"
            case .category(let category):
                header.nameLabel.text = category.name
            }

            header.backgroundColor = section.sectionColor

            return header

        }
        return dataSource
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: SectionHeader.kind.identifier, alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        // to create a context menu configuration to return from your delegate method, you'll pass an action provider closure that sets up and returns a UIMenu instance to the UIContextMenuConfiguration initializer
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let item = self.dataSource.itemIdentifier(for: indexPath)!
            
            let favoriteToggle = UIAction(title: self.model.favoriteHabits.contains(item) ? "Unfavorite" : "Favorite") { (action) in
                Settings.shared.toggleFavorite(item)
                self.updateCollectionView()
            }
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [favoriteToggle])
        }
        
        return config
    }
    
    
    @IBSegueAction func showHabitDetail(_ coder: NSCoder, sender: UICollectionViewCell?) -> HabitDetailViewController? {
        guard let cell = sender, let indexPath = collectionView.indexPath(for: cell), let item = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return HabitDetailViewController(coder: coder, habit: item)
    }
    
}
