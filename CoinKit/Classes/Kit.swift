import RxSwift

public class Kit {
    private var disposeBag = DisposeBag()
    private let coinManager: CoinManager
    private let storage: GrdbStorage

    public var coinMigrationObservable: Observable<[Coin]>? {
        didSet {
            subscribeMigration()
        }
    }

    private init(coinManager: CoinManager, storage: GrdbStorage) {
        self.coinManager = coinManager

        self.storage = storage
    }

    private static func databaseDirectoryUrl() throws -> URL {
        let fileManager = FileManager.default

        let url = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("coin-kit", isDirectory: true)

        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)

        return url
    }

    private func subscribeMigration() {
        disposeBag = DisposeBag()

        coinMigrationObservable?.subscribe(onNext:{ [weak self] coins in
            if !coins.isEmpty {
                self?.coinManager.save(coins: coins)
            }
        }).disposed(by: disposeBag)
    }

}

extension Kit {

    static var bundle: Bundle? {
        Bundle(for: Kit.self).url(forResource: "CoinKit", withExtension: "bundle").flatMap { Bundle(url: $0) }
    }

    public static func defaultCoins(testNet: Bool) -> [Coin] {
        (try? CoinProvider(parser: JsonParser(), testNet: testNet).defaultCoins().coins) ?? []
    }

    public static func defaultMappings(testNet: Bool) -> [CoinMapping] {
        (try? MappingProvider(parser: JsonParser(), testNet: testNet).defaultMappings().mappings) ?? []
    }
}

extension Kit {

    public static func instance(testNet: Bool = false) throws -> Kit {
        let storage = try GrdbStorage(databaseDirectoryUrl: databaseDirectoryUrl(), databaseFileName: "coin-kit-db")

        let coinProvider = CoinProvider(parser: JsonParser(), testNet: testNet)
        let mappingProvider = MappingProvider(parser: JsonParser(), testNet: testNet)
        let coinManager = CoinManager(coinProvider: coinProvider, mappingProvider: mappingProvider, storage: storage)

        return Kit(coinManager: coinManager, storage: storage)
    }

}

extension Kit {

    public var coins: [Coin] {
        coinManager.coins
    }
    
    public var mappings: [CoinMapping] {
        coinManager.mappings
    }

    public func save(coins: [Coin]) {
        coinManager.save(coins: coins)
    }

    public func coin(id: String) -> Coin? {
        coinManager.coin(id: id)
    }

    public func coin(type: CoinType) -> Coin? {
        coinManager.coin(id: type.id)
    }

    public func save(mappings: [CoinMapping]) {
        coinManager.save(mappings: mappings)
    }
    
    public func mapping(coinId: String) -> CoinMapping? {
        coinManager.mapping(coinId: coinId)
    }
}
