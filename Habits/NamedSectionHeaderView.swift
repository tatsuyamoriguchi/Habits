//
//  NamedSectionHeaderView.swift
//  Habits
//
//  Created by Tatsuya Moriguchi on 11/22/23.
//

import UIKit

class NamedSectionHeaderView: UICollectionReusableView {
    
    var _centerYConstraint: NSLayoutConstraint?
    
    var centerYConstraint: NSLayoutConstraint {
        if _centerYConstraint == nil {
            _centerYConstraint = nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        }
        return _centerYConstraint!
    }
    
    var _topYConstaint: NSLayoutConstraint?
    var topYConstraint: NSLayoutConstraint {
        if _topYConstaint == nil {
            _topYConstaint = nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12)
        }
        return _topYConstaint!
    }
    
    func alignLabelToTop() {
        topYConstraint.isActive = true
        centerYConstraint.isActive = false
    }
    
    func alignLabelToYCenter() {
        topYConstraint.isActive = false
        centerYConstraint.isActive = true
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.boldSystemFont(ofSize: 17)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemGray5
        
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Use the new properties by removing the center Y anchor constraint and calling the Y Center alignment toggling method.
        NSLayoutConstraint.activate([nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12), ])
        alignLabelToYCenter()
    }
}
