
import RxDataSources

struct Group<T> {
    var header: String
    var items: [Item]
}

extension Group: SectionModelType {
    typealias Item = T
    
    init(original: Group<T>, items: [Item]) {
        self = original
        self.items = items
    }
}
