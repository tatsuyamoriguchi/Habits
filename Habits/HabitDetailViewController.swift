//
//  HabitDetailViewController.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/20/23.
//

import UIKit

class HabitDetailViewController: UIViewController {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    var habit: Habit!
    
    required init?(coder: NSCoder) {
        fatalError("init coder(coder:) has not been implemented.")
    }
    
    init?(coder: NSCoder, habit: Habit) {
        self.habit = habit
        super.init(coder: coder)
        
    }
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable {
            case leaders(count: Int)
            case remaining
        }
        
        enum Item: Hashable, Comparable {
            case single(_ stat: UserCount)
            case multiple(_ stats: [UserCount])
            
            static func < (_ lhs: Item, _ rhs: Item) -> Bool {
                switch (lhs, rhs) {
                case (.single(let lCount), .single(let rCount)):
                    return lCount.count < rCount.count
                case (.multiple(let lCounts), .multiple(let rCounts)):
                        return lCounts.first!.count < rCounts.first!.count
                case (.single, .multiple):
                    return false
                case (.multiple, .single):
                    return true
                }
            }
        }
    }
    
    struct Model {
        var habitStatistics: HabitStatistics?
        var userCounts: [UserCount] {
            habitStatistics?.userCount ?? []
        }
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = habit.name
        categoryLabel.text = habit.category.name
        infoLabel.text = habit.info

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
