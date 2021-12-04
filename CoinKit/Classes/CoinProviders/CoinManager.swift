import Foundation

class CoinManager {
    private let coinProvider: CoinProvider
    private let mappingProvider: MappingProvider
    private var storage: ICoinStorage

    init(coinProvider: CoinProvider, mappingProvider: MappingProvider, storage: ICoinStorage) {
        self.coinProvider = coinProvider
        self.mappingProvider = mappingProvider
        
        self.storage = storage

        do {
            try updateDefaultCoins()
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try updateDefaultMappings()
        } catch {
            print(error.localizedDescription)
        }

    }

    private func updateDefaultCoins() throws {
        let defaultCoins = try coinProvider.defaultCoins()

        guard let currentVersion = storage.defaultListVersion else {
            storage.defaultListVersion = defaultCoins.version
            storage.save(coins: defaultCoins.coins)
            return
        }

        guard currentVersion != defaultCoins.version else {
            return
        }

        storage.defaultListVersion = currentVersion
        merge(coins: defaultCoins.coins)
    }
    
    private func updateDefaultMappings() throws {
        let defaultMappings = try mappingProvider.defaultMappings()
        
        guard let currentVersion = storage.defaultMappingVersion else {
            storage.defaultMappingVersion = defaultMappings.version
            storage.save(mappings: defaultMappings.mappings)
            return
        }
        
        guard currentVersion != defaultMappings.version else {
            return
        }
        
        storage.defaultMappingVersion = currentVersion
        merge(mappings: defaultMappings.mappings)
    }

    private func merge(coins: [Coin]) {
        //todo: make right merge for new coins
        storage.save(coins: coins)
    }
    
    private func merge(mappings: [CoinMapping]) {
        storage.save(mappings: mappings)
    }
}

extension CoinManager {

    var coins: [Coin] {
        storage.coins
    }
    
    var mappings: [CoinMapping] {
        storage.mappings
    }

    func coin(id: String) -> Coin? {
        storage.coin(id: id)
    }
    
    func mapping(coinId: String) -> CoinMapping? {
        storage.mapping(coinId: coinId)
    }
    
    func mapping(taylorContractAddress: String) -> CoinMapping? {
        storage.mapping(taylorContractAddress: taylorContractAddress)
    }

    func save(coins: [Coin]) {
        storage.save(coins: coins)
    }

    func save(mappings: [CoinMapping]) {
        storage.save(mappings: mappings)
    }
}
