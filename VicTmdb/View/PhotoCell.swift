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
            
            posterImageView.kf.setImage(with: posterUrl, placeholder: UIImage(named: "Movie"), completionHandler: {
                (image, error, cacheType, imageUrl) in
                if image == nil {
                    self.posterImageView.image = UIImage(named: "Movie")
                }
            })
        }
    }
    
}

fileprivate extension PhotoCell {
    func clearAll() {
        // Cancel downloading of image and then reset
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = UIImage(named: "Movie")
    }
}

