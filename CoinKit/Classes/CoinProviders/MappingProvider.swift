import ObjectMapper

struct MappingResponse: ImmutableMappable {
    let version: Int
    let mappings: [CoinMapping]

    init(map: Map) throws {
        version = try map.value("version")
        mappings = try map.value("mappings")
    }

}

class MappingProvider {
    private let parser: JsonParser
    private let filename: String

    init(parser: JsonParser, testNet: Bool) {
        self.parser = parser
        filename = testNet ? "default.mappings" : "default.mappings"
    }

    func defaultMappings() throws -> MappingResponse {
        try parser.parse(filename: filename)
    }
}
