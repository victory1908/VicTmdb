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
                let cell = cv.dequeueReusableCell(withReuseIdentifier: Constant.movieCellidentifier, for: ip) as! MovieCell
                cell.configure(forItem: item)
                return cell
        })
    }
}

class SearchDatasource: RxTableViewSectionedReloadDataSource<Group<String>> {
    convenience init() {
        self.init(
            configureCell: { (ds, tv, ip, item) -> UITableViewCell  in
                let cell = tv.dequeueReusableCell(withIdentifier: Constant.searchCell, for: ip)
                cell.textLabel?.text = item
                return cell
        })
    }
}
