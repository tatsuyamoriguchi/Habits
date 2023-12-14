//
//  FollowedUserCollectionViewCell.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 12/3/23.
//

import UIKit

class FollowedUserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var primaryTextLabel: UILabel!
    @IBOutlet var secondaryTextLabel: UILabel!
    @IBOutlet var separatorLineView: UIView!
    @IBOutlet var separatorLineHeightConstraint: NSLayoutConstraint?

    
    override func awakeFromNib() {
        // Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value
        separatorLineHeightConstraint?.constant = 1 / UITraitCollection.current.displayScale
    }
    
}
