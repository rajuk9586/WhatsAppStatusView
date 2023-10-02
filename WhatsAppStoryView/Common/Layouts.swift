//
//  Layouts.swift
//  iOS Assignment
//
//  Created by Raju Kumar on 07/09/23.
//

import Foundation
import UIKit

class Layouts {
    static let shared = Layouts()
    
     func statusListLayout() -> NSCollectionLayoutSection {
        //item
         let item_size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: item_size)
        
        //Group
         let group_size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.3))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: group_size, subitems: [item])
        
        //spacing between cells
//        group.interItemSpacing = .fixed(20)
        
        //Section
        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
         section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.1)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
        
        return section
    }
    
    func storyListLayout()-> NSCollectionLayoutSection  {
        //item
         let item_size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: item_size)
        
        //Group
        let group_size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: group_size, subitems: [item])
        
        //Section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        return section
    }
}
