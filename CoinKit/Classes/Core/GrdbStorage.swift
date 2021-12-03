import RxSwift
import GRDB

class GrdbStorage {
    private let dbPool: DatabasePool

    init(databaseDirectoryUrl: URL, databaseFileName: String) {
        let databaseURL = databaseDirectoryUrl.appendingPathComponent("\(databaseFileName).sqlite")

        let configuration: Configuration = Configuration()
//        configuration.trace = { print($0) }

        dbPool = try! DatabasePool(path: databaseURL.path, configuration: configuration)

        try! migrator.migrate(dbPool)
    }

    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("createResponseVersions") { db in
            try db.create(table: ResponseVersion.databaseTableName) { t in
                t.column(ResponseVersion.Columns.id.name, .text).notNull()
                t.column(ResponseVersion.Columns.version.name, .integer).notNull()

                t.primaryKey([Coin.Columns.id.name], onConflict: .replace)
            }
        }

        migrator.registerMigration("createCoins") { db in
            try db.create(table: Coin.databaseTableName) { t in
                t.column(Coin.Columns.id.name, .text).notNull()
                t.column(Coin.Columns.title.name, .text).notNull()
                t.column(Coin.Columns.code.name, .text).notNull()
                t.column(Coin.Columns.decimal.name, .integer).notNull()
                t.column(Coin.Columns.mainId.name, .text)

                t.primaryKey([Coin.Columns.id.name], onConflict: .replace)
            }
        }
        
        migrator.registerMigration("createMappings") { db in
            try db.create(table: CoinMapping.databaseTableName, body: { t in
                t.column(CoinMapping.Columns.coinId.name, .text).notNull()
                t.column(CoinMapping.Columns.coinType.name, .text).notNull()
                t.column(CoinMapping.Columns.chainType.name, .text).notNull()
                t.column(CoinMapping.Columns.mirrorCoinId.name, .text)
                t.column(CoinMapping.Columns.taylorContractAddress.name, .text)
                t.column(CoinMapping.Columns.crossRegion.name, .boolean).notNull()
                t.column(CoinMapping.Columns.crossChain.name, .boolean).notNull()
                
                t.primaryKey([CoinMapping.Columns.coinId.name], onConflict: .replace)
            })
        }

        return migrator
    }
}

extension GrdbStorage: ICoinStorage {
    
    var mappings: [CoinMapping] {
        try! dbPool.read { db in
            try CoinMapping.fetchAll(db)
        }
    }

    var coins: [Coin] {
        try! dbPool.read { db in
            try Coin.fetchAll(db)
        }
    }

    var defaultListVersion: Int? {
        get {
            try! dbPool.read { db in
                try ResponseVersion
                        .filter(ResponseVersion.Columns.id == String(describing: Coin.self))
                        .fetchOne(db)?
                        .version
            }
        }
        set {
            _ = try! dbPool.write { db in
                guard let version = newValue else {
                    try ResponseVersion
                            .filter(ResponseVersion.Columns.id == String(describing: Coin.self))
                            .deleteAll(db)
                    return
                }
                try ResponseVersion(id: String(describing: Coin.self), version: version).insert(db)
            }
        }
    }
    
    var defaultMappingVersion: Int? {
        get {
            try! dbPool.read { db in
                try ResponseVersion
                        .filter(ResponseVersion.Columns.id == String(describing: CoinMapping.self))
                        .fetchOne(db)?
                        .version
            }
        }
        set {
            _ = try! dbPool.write { db in
                guard let version = newValue else {
                    try ResponseVersion
                            .filter(ResponseVersion.Columns.id == String(describing: CoinMapping.self))
                            .deleteAll(db)
                    return
                }
                try ResponseVersion(id: String(describing: CoinMapping.self), version: version).insert(db)
            }
        }
    }

    func save(coins: [Coin]) {
        _ = try! dbPool.write { db in
            try coins.forEach { record in
                try record.insert(db)
            }
        }
    }
    
    func save(mappings: [CoinMapping]) {
        _ = try! dbPool.write { db in
            try mappings.forEach { record in
                try record.insert(db)
            }
        }
    }

    func coin(id: String) -> Coin? {
        try! dbPool.read { db in
            let coin = try Coin
                    .filter(Coin.Columns.id == id)
                    .fetchOne(db)
            return coin
        }
    }

    func mapping(coinId: String) -> CoinMapping? {
        try! dbPool.read { db in
            let mapping = try CoinMapping
                .filter(CoinMapping.Columns.coinId == coinId)
                .fetchOne(db)
            return mapping
        }
    }
}
