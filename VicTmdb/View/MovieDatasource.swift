//
//  MovieDatasource.swift
//  VicTmdb
//
//  Created by victory1908 on 8/10/18.
//  Copyright © 2018 victory1908. All rights reserved.
//

import RxDataSources

class MovieDatasource: RxCollectionViewSectionedReloadDataSource<Group<Movie>> {
    convenience init() {
        self.init(
            configureCell: { (ds, cv, ip, item) -> UICollectionViewCell  in
                let cell = cv.dequeueReusableCell(withReuseIdentifier: Constant.photoCellidentifier, for: ip) as! PhotoCell
                cell.configure(forItem: item)
                return cell
        })
    }
}

//extension MovieDatasource {
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let screenSize              = UIScreen.main.bounds
//        let screenWidth             = screenSize.width
//        let cellSquareSize: CGFloat = (screenWidth / 2.0) - 10
//        
//        return CGSize.init(width: cellSquareSize, height: 240.0)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 5
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 5
//    }
//}
