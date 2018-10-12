//
//  FlowLayoutNew.swift
//  VicTmdb
//
//  Created by victory1908 on 10/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import UIKit

class FlowLayout: UICollectionViewFlowLayout {
    init(minimumInteritemSpacing: CGFloat = 10, minimumLineSpacing: CGFloat = 10, sectionInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) ) {
        super.init()
        
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
        
        if #available(iOS 10.0, *) {
            estimatedItemSize = CGSize(width: 300, height:  450)
            itemSize = UICollectionViewFlowLayout.automaticSize
        } else {
            // Fallback on earlier versions
            estimatedItemSize = CGSize(width: 300, height:  450)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        guard let collectionView = collectionView else { return nil }
        if #available(iOS 11.0, *) {
            layoutAttributes.bounds.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
        } else {
            // Fallback on earlier versions
            layoutAttributes.bounds.size.width = collectionView.frame.width - sectionInset.left - sectionInset.right
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superLayoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        guard scrollDirection == .vertical else { return superLayoutAttributes }
        
        let computedAttributes = superLayoutAttributes.compactMap { layoutAttribute in
            return layoutAttribute.representedElementCategory == .cell ? layoutAttributesForItem(at: layoutAttribute.indexPath) : layoutAttribute
        }
        
        return computedAttributes
    }
}
