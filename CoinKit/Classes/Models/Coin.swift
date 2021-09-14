import ObjectMapper
import GRDB

public class Coin: Record, ImmutableMappable {
    public let title: String
    public let code: String
    public let decimal: Int
    public let type: CoinType
    /// tlc20 对应的公链币
    public let mainId: String?

    public var id: String {
        type.id
    }

    public override class var databaseTableName: String {
        "coins"
    }

    public init(title: String, code: String, decimal: Int, type: CoinType, mainId: String) {
        self.title = title
        self.code = code
        self.decimal = decimal
        self.type = type
        self.mainId = mainId

        super.init()
    }

    required public init(map: Map) throws {
        title = try map.value("title")
        code = try map.value("code")
        decimal = try map.value("decimal")
        mainId = try map.value("mainId")

        let type: String = try map.value("type")
        let typeExtension: String? = (try? map.value("address")) ?? (try? map.value("symbol"))

        let id = [type, typeExtension].compactMap { $0 }.joined(separator: "|")

        self.type = CoinType(id: id)

        super.init()
    }

    enum Columns: String, ColumnExpression {
        case id
        case title
        case code
        case decimal
        case mainId
    }

    required init(row: Row) {
        title = row[Columns.title]
        code = row[Columns.code]
        decimal = row[Columns.decimal]
        type = CoinType(id: row[Columns.id])
        mainId = row[Columns.mainId]

        super.init(row: row)
    }

    public override func encode(to container: inout PersistenceContainer) {
        container[Columns.title] = title
        container[Columns.code] = code
        container[Columns.decimal] = decimal
        container[Columns.id] = id
        container[Columns.mainId] = mainId
    }

}

extension Coin: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }

}

extension Coin: Equatable {

    public static func ==(lhs: Coin, rhs: Coin) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.code == rhs.code && lhs.decimal == rhs.decimal && lhs.type == rhs.type
    }

}

extension Coin: Comparable {

    public static func <(lhs: Coin, rhs: Coin) -> Bool {
        lhs.title < rhs.title
    }
}
