//
//  UserCollectionViewController.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/20/23.
//

import UIKit

private let reuseIdentifier = "Cell"

class UserCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
//    While you're there, typealias your data source type, create your model type, and add declarations for the data source and model properties.
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section,ViewModel.Item>
    
    enum ViewModel {
        typealias Section = Int
        
        struct Item: Hashable {
            let user: User
            let isFollowed: Bool
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(user)
            }
            
            static func ==(_ lhs: Item, _ rhs: Item) -> Bool {
                return lhs.user == rhs.user
            }
        }
    }
    
    struct Model {
        var userByID = [String:User]()
        var followedUsers: [User] {
            return Array(userByID.filter {
                Settings.shared.followedUserIDs.contains($0.key)
            }.values)
        }
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    
//    While you could also just typealias Item to User, you're not maintaining a separate section for followed users in this screen as you did for habits. If you might later want to visually distinguish between followed and unfollowed users, you should include that information in the view model as part of the Item.
//    Note that you explicitly implemented hash(into:) and ==(_:_:) for the Item struct. (The free implementations of those two methods would have used both properties of Item in their calculations.) You want to make sure that, from the perspective of the collection view's data source, the identity of a user doesn't change when their followed status changes. If it did, your collection view would unnecessarily remove and add a cell.



}
