//
//  MirrorCoinRecord.swift
//  UnstoppableWallet
//
//  Created by ios on 2021/11/30.
//  Copyright © 2021 zhangj. All rights reserved.
//

import ObjectMapper
import GRDB

public class CoinMapping: Record, ImmutableMappable {

    public let coinId: String
    public let name: String
    public let chainType: String
    public let mirrorCoinId: String?
    public let taylorContractAddress: String
    public let crossRegion: Bool
    public let crossChain: Bool

    public init(coinId: String, name: String, chainType: String, mirrorCoinId: String?, taylorContractAddress: String, crossRegion: Bool, crossChain: Bool) {
        self.coinId = coinId
        self.name = name
        self.chainType = chainType
        self.mirrorCoinId = mirrorCoinId
        self.taylorContractAddress = taylorContractAddress
        self.crossRegion = crossRegion
        self.crossChain = crossChain

        super.init()
    }

    public override class var databaseTableName: String {
        "coin_mappings"
    }

    enum Columns: String, ColumnExpression {
        case coinId, name, chainType, mirrorCoinId, taylorContractAddress, crossRegion, crossChain
    }

    required init(row: Row) {
        coinId = row[Columns.coinId]
        name = row[Columns.name]
        chainType = row[Columns.chainType]
        mirrorCoinId = row[Columns.mirrorCoinId]
        taylorContractAddress = row[Columns.taylorContractAddress]
        crossRegion = row[Columns.crossRegion]
        crossChain = row[Columns.crossChain]

        super.init(row: row)
    }
    
    required public init(map: Map) throws {
        coinId = try map.value("coinId")
        name = try map.value("name")
        chainType = try map.value("chainType")
        mirrorCoinId = try map.value("mirrorCoinId")
        taylorContractAddress = try map.value("taylorContractAddress")
        crossRegion = try map.value("crossRegion")
        crossChain = try map.value("crossChain")

        super.init()
    }

    public override func encode(to container: inout PersistenceContainer) {
        container[Columns.coinId] = coinId
        container[Columns.name] = name
        container[Columns.chainType] = chainType
        container[Columns.mirrorCoinId] = mirrorCoinId
        container[Columns.taylorContractAddress] = taylorContractAddress
        container[Columns.crossRegion] = crossRegion
        container[Columns.crossChain] = crossChain
    }

}
