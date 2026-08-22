import Testing
@testable import HexCore

@Suite("Hex Grid Algorithms")
struct HexCoreTests {

    let origin = AxialCoordinate(q: 0, r: 0)

    @Test("Hex neighbors returns 6 values")
    func testFindNeighbors() throws {
        let neighbors = origin.neighbors()
        print("neighbors: \(neighbors)")
        #expect(neighbors.count == 6)
        
    }

    @Test("Test disk at ranges 1-10.")
    func testDisk() async throws {
        let ranges = 1...10
        for range in ranges {
            let area = AxialCoordinate.disk(center: origin, radius: range)
            let expectedCount = 1 + 3 * range * (range+1)
            #expect(area.count == expectedCount)
            for coordinate in area {
                #expect(origin.distance(from: coordinate) <= range)
            }
        }
    }

    @Test("Test rings at ranges 1-10")
    func testRing() async throws {
        let ranges = 1...10
        for range in ranges {
            let borderHexes = try AxialCoordinate.ring(center: origin, radius: range)
            #expect(borderHexes.count == range * 6)
            for borderHex in borderHexes {
                #expect(origin.distance(from: borderHex) == range)
            }
        }
    }

    private func makeMap() -> WeightMap {
        var map = WeightMap()
        map.storeWeight(.passable(weight: 2), at: .init(q: -1, r: -1))
        map.storeWeight(.passable(weight: 2), at: .init(q:  0, r: -1))
        map.storeWeight(.passable(weight: 2), at: .init(q:  1, r: -1))
        map.storeWeight(.passable(weight: 2), at: .init(q:  2, r: -1))
        return map
    }

    @Test("Test find moveable hexes")
    func testReachableHexes() {
        let hexes = origin.reachable(movement: 2, weightMap: makeMap())
        print("Hexes:")
        for hex in hexes {
            print("    (\(hex.q),\(hex.r))")
        }
    }

    // Test that reachable coordinates in a map with no weighted hexes is the same as disk()
    @Test("Test standard map")
    func testReachableInStandardMap() async throws {
        for radius in 1...10 {
            let reachable = origin.reachable(movement: radius, weightMap: WeightMap())
            let disk = AxialCoordinate.disk(center: origin, radius: radius)
            #expect(reachable == disk)
        }
    }

    @Test("Neighbor exceeds movement")
    func testExpensiveNeighbor() async throws {
        var map = WeightMap()
        let expensiveCoord = origin.offsetBy(q: 1, r: 0)
        let movement = 3
        map[expensiveCoord] = .passable(weight: movement + 1)

        let reachable = origin.reachable(movement: movement, weightMap: map)
        let sorted = reachable.sorted(by: {
            if $0.q != $1.q { return $0.q < $1.q }
            return $0.r != $1.r
        })

        for r in sorted {
            print("\(r.q),\(r.r)")
        }

        #expect(!reachable.contains(expensiveCoord))
    }

    @Test("Test island")
    func testIsland() async throws {
        var map = WeightMap()
        for neighbor in origin.neighbors() {
            map[neighbor] = .impassable
        }

        let reachable = origin.reachable(movement: 100, weightMap: map)
        #expect(reachable.count == 1)
        #expect(reachable.contains(origin))
    }
}
