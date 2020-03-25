//
//  UserReviewsVC.swift
//  JuggleTechnologies
//
//  Created by Nathaniel Remy on 2020-03-10.
//  Copyright © 2020 Nathaniel Remy. All rights reserved.
//

import UIKit

class UserReviewsVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    //MARK: Stored properties
    var reviews: [Review]? {
        didSet {
            guard let reviews = self.reviews else {
                self.showNoResultsFoundView()
                return
            }
            
            if reviews.count == 0 {
                self.showNoResultsFoundView()
                return
            }
            
            self.removeNoResultsView()
        }
    }
    
    let noResultsView: UIView = {
        let view = UIView.noResultsView(withText: "No hay evaluaciones en este momento.")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate func showNoResultsFoundView() {
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.collectionView?.addSubview(self.noResultsView)
            self.noResultsView.centerYAnchor.constraint(equalTo: (self.collectionView?.centerYAnchor)!).isActive = true
            self.noResultsView.centerXAnchor.constraint(equalTo: (self.collectionView?.centerXAnchor)!).isActive = true
        }
    }
    
    fileprivate func removeNoResultsView() {
        self.collectionView?.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
            self.noResultsView.removeFromSuperview()
            self.collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        
        navigationItem.title = "Evaluaciones"
        
        // Register all the collectionView's cells
        collectionView.register(ReviewCell.self, forCellWithReuseIdentifier: Constants.CollectionViewCellIds.reviewCell)
    }
    
    //MARK: CollectionViewDelegate methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.reviews?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let reviewCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCellIds.reviewCell, for: indexPath) as? ReviewCell else {
            return UICollectionViewCell()
        }
        
        if let reviews = self.reviews {
            reviewCell.review = reviews[indexPath.item]
        }
        
        return reviewCell
    }
}
