//
//  PhotoCell.swift
//  VicTmdb
//
//  Created by victory1908 on 8/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import UIKit
import Kingfisher

class MovieCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var releaseDateLbl: UILabel!
    @IBOutlet weak var overviewLbl: UILabel!
    
    //    private task
    
    // MARK: Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearAll()
    }
    
    func configure(forItem item: Movie) {
        if let path = item.posterPath, let posterUrl = URL(string: Constant.imageUrlString + path) {
            posterImageView.kf.indicatorType = .activity
            posterImageView.kf.setImage(with: posterUrl, placeholder:#imageLiteral(resourceName: "Movie.pdf") , options: [.backgroundDecode], progressBlock: nil) { (image, error, cacheType, url) in
                if error == nil {
                    if image == nil {
                        self.posterImageView.image = #imageLiteral(resourceName: "Movie.pdf")
                    }
                }
            }
            nameLbl.text = item.title
            releaseDateLbl.text = item.releaseDate
            overviewLbl.text = item.overview
        }
    }
    

    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        // Specify you want _full width_
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 450)

        // Calculate the size (height) using Auto Layout

        updateConstraintsIfNeeded()
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)

        // Assign the new size to the layout attributes
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    override func snapshotView(afterScreenUpdates afterUpdates: Bool) -> UIView? {
        return self
    }
    
}

extension MovieCell {
    func clearAll() {
        // Cancel downloading of image and then reset
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = UIImage(named: "Movie")
    }
}



