
import RxDataSources

//struct Group<T> {
//    var header: String
//    var items: [Item]
//}

struct Group<T> where T:IdentifiableType, T:Equatable {
    var header: String
    var items: [Item]
}

extension Group: AnimatableSectionModelType {
    typealias Identity = String
    
    var identity: Identity {
        return header
    }
    
    typealias Item = T
    init(original: Group<T>, items: [Item]) {
        self = original
        self.items = items
    }
}

