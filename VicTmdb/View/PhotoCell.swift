//
//  PhotoCell.swift
//  VicTmdb
//
//  Created by victory1908 on 8/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var constraintHeight: NSLayoutConstraint!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var releaseDateLbl: UILabel!
    @IBOutlet weak var overviewLbl: UILabel!
    
    //    private task
    
    // MARK: Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
    
//        self.translatesAutoresizingMaskIntoConstraints = false
//        // Code below is needed to make the self-sizing cell work when building for iOS 12 from Xcode 10.0:
//        let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
//        let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
//        let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
//        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        
    }
    
//    override func updateConstraints() {
//        // Set width constraint to superview's width.
//        widthConstraint?.constant = superview?.bounds.width ?? 0
//        widthConstraint?.isActive = true
//        super.updateConstraints()
//    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearAll()
    }
    
    func configure(forItem item: Movie) {
        if let path = item.posterPath, let posterUrl = URL(string: Constant.imageUrlString + path) {
            posterImageView.kf.indicatorType = .activity
//            posterImageView.kf.setImage(with: posterUrl, options: [.backgroundDecode])
            posterImageView.kf.setImage(with: posterUrl, placeholder:#imageLiteral(resourceName: "Movie.pdf") , options: [.backgroundDecode], progressBlock: nil) { (image, error, cacheType, url) in
                if error == nil {
                    if image == nil {
                        self.posterImageView.image = #imageLiteral(resourceName: "Movie.pdf")
                    }
                }
                
//                self.layoutIfNeeded()
//                self.updateConstraintsIfNeeded()
                
            }
            nameLbl.text = item.title
            releaseDateLbl.text = item.releaseDate
            overviewLbl.text = item.overview
        }
    }
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        setNeedsLayout()
//        layoutIfNeeded()
//        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//        var frame = layoutAttributes.frame
//        frame.size.height = ceil(size.height)
//        layoutAttributes.frame = frame
//        return layoutAttributes
//    }
    
//    var heightCalculated: Bool = false
//
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        //store height to avoid indefinite calling.
//        if !heightCalculated {
//            setNeedsLayout()
//            layoutIfNeeded()
//            let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//            var newFrame = layoutAttributes.frame
//            newFrame.size.width = CGFloat(ceilf(Float(size.width)))
//            layoutAttributes.frame = newFrame
//            heightCalculated = true
//        }
//        return layoutAttributes
//    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        // Specify you want _full width_
//        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 300)
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 450)


        // Calculate the size (height) using Auto Layout

        updateConstraintsIfNeeded()
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)

        // Assign the new size to the layout attributes
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        layoutIfNeeded()
//        let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
//        layoutAttributes.bounds.size.height = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//        return layoutAttributes
//    }
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        layoutIfNeeded()
//        let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
//        layoutAttributes.bounds.size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
//        return layoutAttributes
//    }
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        layoutIfNeeded()
////        updateConstraintsIfNeeded()
//        layoutAttributes.bounds.size.height = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
//        return layoutAttributes
//    }
    
    
    override func snapshotView(afterScreenUpdates afterUpdates: Bool) -> UIView? {
        return self
    }
    
}

fileprivate extension PhotoCell {
    func clearAll() {
        // Cancel downloading of image and then reset
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = UIImage(named: "Movie")
    }
}



