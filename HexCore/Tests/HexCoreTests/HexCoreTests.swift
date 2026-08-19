import Testing
@testable import HexCore

@Suite("Hex Grid Algorithms")
struct HexCoreTests {
    @Test("Hex neighbors returns 6 values")
    func testFindNeighbors() throws {
        let hex = HexCoordinate(q: 0, r: 0)
        let neighbors = HexCoordinate.neighborCoordinates(hex: hex)
        print("neighbors: \(neighbors)")
        #expect(neighbors.count == 6)
    }
}
