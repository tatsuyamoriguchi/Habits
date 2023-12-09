//
//  HomeCollectionViewController.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/20/23.
//

import UIKit

private let reuseIdentifier = "LeaderboardHabit"

class HomeCollectionViewController: UICollectionViewController {
    
    // Keep track of async tasks so they can be cancelled when appropriate
    var userRequestTask: Task<Void, Never>? = nil
    var habitRequestTask: Task<Void, Never>? = nil
    var combinedStatisticsRequestTask: Task<Void, Never>? = nil
    
    deinit {
        userRequestTask?.cancel()
        habitRequestTask?.cancel()
        combinedStatisticsRequestTask?.cancel()
    }
 
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable {
            case leaderboard
            case followedUsers
        }
        
        enum Item: Hashable {
            case leaderboardHabit(name: String, leadingUserRanking: String?, secondaryUserRanking: String?)
            case followedUser(_ user: User, message: String)
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .leaderboardHabit(let name,  _, _):
                    hasher.combine(name)
                case .followedUser(let User, _):
                    hasher.combine(User)
                }
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.leaderboardHabit(let lName, _, _), .leaderboardHabit(let rName, _, _)):
                    return lName == rName
                case (.followedUser(let lUser, _), .followedUser(let rUser, _)):
                    return lUser == rUser
                default:
                    return false
                }
            }
        }
    }
    
    
    struct Model {
        var usersByID = [String: User]()
        var habitsByName = [String: Habit]()
        var habitStatistics = [HabitStatistics]()
        var userStatistics = [UserStatistics]()
        
        var currentUser: User {
            return Settings.shared.currentUser
        }
        
        var users: [User] {
            return Array(usersByID.values)
        }
        
        var habits: [Habit] {
            return Array(habitsByName.values)
        }
        
        var followedUsers: [User] {
            return Array(usersByID.filter {
                Settings.shared.followedUserIDs.contains($0.key)
            }.values)
        }
        
        var favoriteHabits: [Habit] {
            return Settings.shared.favoriteHabits
        }
        
        var nonFavoriteHabits: [Habit] {
            return habits.filter { !favoriteHabits.contains($0) }
        }
    }
    
    var model = Model()
    var dataSource: DataSourceType!
    
    var updateTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        update()
        
        dataSource = createDateSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        userRequestTask = Task {
            if let users = try? await UserRequest().send() {
                self.model.usersByID = users
            }
            
            self.updateCollectionView()
            userRequestTask = nil
        }
        
        habitRequestTask = Task {
            if let habits = try? await HabitRequest().send() {
                self.model.habitsByName = habits
            }
            
            self.updateCollectionView()
            habitRequestTask = nil
        }
        
        
//         Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
    }
    
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

    func createDateSource() -> DataSourceType {

        let dataSource = DataSourceType(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .leaderboardHabit(let name, let leadingUserRanking, let secondaryUserRanking):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeaderboardHabit", for: indexPath) as! LeaderBoardHabitCollectionViewCell
                cell.habitNameLabel.text = name
                cell.leaderLabel.text = leadingUserRanking
                cell.secondaryLabel.text = secondaryUserRanking
                print("1item: \(item)")

                return cell
            default:
                print("2item: \(item)")

                return nil
            }
        }

        return dataSource
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            print("createLayout() was executed")
            switch self.dataSource.snapshot().sectionIdentifiers[sectionIndex] {
            case .leaderboard:
                let leaderboardItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.3))
                let leaderboardItem = NSCollectionLayoutItem(layoutSize: leaderboardItemSize)
                
                let verticalTrioSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .fractionalWidth(0.75))
                let leaderboardVerticalTrio = NSCollectionLayoutGroup.vertical(layoutSize: verticalTrioSize, subitem: leaderboardItem, count: 3)
                leaderboardVerticalTrio.interItemSpacing = .fixed(10)
                
                let leaderboardSection = NSCollectionLayoutSection(group: leaderboardVerticalTrio)
                leaderboardSection.interGroupSpacing = 20
                
                leaderboardSection.orthogonalScrollingBehavior = .continuous
                leaderboardSection.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 20, trailing: 20)
                
                return leaderboardSection
            default:
                return nil
            }
        }
        return layout
    }
    
    func update() {
        
        combinedStatisticsRequestTask?.cancel()
        combinedStatisticsRequestTask = Task {
            if let combinedStatistics = try? await CombinedStatisticsRequet().send() {
                self.model.userStatistics = combinedStatistics.userStatistics
                self.model.habitStatistics = combinedStatistics.habitStatistics
            } else {
                print("statistics are nil")
                self.model.userStatistics = []
                self.model.habitStatistics = []
            }
            self.updateCollectionView()
            
            combinedStatisticsRequestTask = nil
        }
    }
 
    static let formatter: NumberFormatter = {
        var f = NumberFormatter()
        f.numberStyle = .ordinal
        return f
        
    }()
    
    func ordinalString(from number: Int) -> String {
        return Self.formatter.string(from: NSNumber(integerLiteral: number + 1))!
    }

    
    func updateCollectionView() {
        var sectionIDs = [ViewModel.Section]()
        
        let leaderboardItems = model.habitStatistics.filter { statistics in
            return model.favoriteHabits.contains { $0.name == statistics.habit.name }
        }
            .sorted { $0.habit.name < $1.habit.name }
            .reduce(into: [ViewModel.Item]()) { partial, statistics in
                // Rank the user counts from the highest to lowest.
                let rankedUserCounts = statistics.userCounts.sorted { $0.count > $1.count }
                
                // find the index of the current user’s count, keeping in mind that it won’t exist if the user hasn’t logged that habit yet.
                let myCountIndex = rankedUserCounts.firstIndex { $0.user.id == self.model.currentUser.id
                }
                
                func userRankingString(from userCount: UserCount) -> String {
                    var name = userCount.user.name
                    var ranking = ""
                    
                    if userCount.user.id == self.model.currentUser.id {
                        name = "You"
                        ranking = " (\(ordinalString(from: myCountIndex!)))"
                    }
                    return "\(name) \(userCount.count)" + ranking
                }
                
                var leadingRanking: String?
                var secondaryRanking: String?
                
                // Examine the number of user counts for the statistic:
                switch rankedUserCounts.count {
                case 0:
                    // If 0, set the leader label to "Nobody Yet!" and leave the secondary label `nil`
                    leadingRanking = "Nobody Yet!"
                case 1:
                    // If 1, set the leader label to the only user and count
                    let onlyCount = rankedUserCounts.first!
                    leadingRanking = userRankingString(from: onlyCount)
                default:
                    // Otherwise, do the following:
                    // Set the leader label to the user count at index 0
                    leadingRanking = userRankingString(from: rankedUserCounts[0])
                    // Check whether the index of the current user's count exists　and is not 0
                    if let myCountIndex = myCountIndex, myCountIndex != rankedUserCounts.startIndex {
                        // If true, the user's count and ranking should be displayed in the secondary label
                        secondaryRanking = userRankingString(from: rankedUserCounts[myCountIndex])
                    } else {
                        // If false, the second-place user count should be displayed
                        secondaryRanking = userRankingString(from: rankedUserCounts[1])
                    }
                }
                
                let leaderboardItem = ViewModel.Item.leaderboardHabit(name: statistics.habit.name, leadingUserRanking: leadingRanking, secondaryUserRanking: secondaryRanking)
                
                partial.append(leaderboardItem)
            }
                
                sectionIDs.append(.leaderboard)
        
                var itemBySection = [ViewModel.Section.leaderboard: leaderboardItems]
                
                // Update the snapshot
                dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemBySection)
            
    }
 
}
