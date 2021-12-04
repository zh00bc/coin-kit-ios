import RxSwift

protocol ICoinStorage {
    var coins: [Coin] { get }
    var mappings: [CoinMapping] { get }
    var defaultListVersion: Int? { get set }
    var defaultMappingVersion: Int? { get set }
    func coin(id: String) -> Coin?
    func mapping(coinId: String) -> CoinMapping?
    func mapping(taylorContractAddress: String) -> CoinMapping?
    func save(coins: [Coin])
    func save(mappings: [CoinMapping])
}
