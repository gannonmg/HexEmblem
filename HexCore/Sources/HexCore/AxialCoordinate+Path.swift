//
//  AxialCoordinate+Path.swift
//  HexCore
//
//  Created by Matt Gannon on 8/20/26.
//

import Foundation
import HeapModule

extension AxialCoordinate {
    /// Finds all reachable coordinates in a weight graph/map of hex nodes
    public func reachable(
        movement: Int,
        weightMap: WeightMap
    ) -> Set<AxialCoordinate> {
        let start = self

        // Movement must be positive
        guard 0 <= movement else { return [start] }

        // We track the minimum expense of reaching each coordinate in range
        var costSoFar: [AxialCoordinate: Int] = [start: 0]

        var buckets: [[AxialCoordinate]] = Array(repeating: [], count: movement + 1)
        buckets[0].append(start)

        for cost in 0...movement {
            while let current = buckets[cost].popLast() {
                // Stale entry from before a cheaper path to `current` was found — skip it.
                guard costSoFar[current] == cost else { continue }

                for neighbor in current.neighbors() {
                    let weight = weightMap[neighbor] ?? .standard

                    // If a hex is impassable, we just move on
                    guard case .passable(let weightCost) = weight else { continue }

                    // We know costSoFar[current] is not nil, because that was the criteria to enter the loop.
                    // This is a reasonable fast fail.
                    let newCost = costSoFar[current]! + weightCost

                    // If newCost exceeds allowed movement, ignore and continue
                    guard newCost <= movement else { continue }

                    if newCost < costSoFar[neighbor] ?? .max {
                        costSoFar[neighbor] = newCost
                        buckets[newCost].append(neighbor)
                    }
                }
            }
        }

        return Set(costSoFar.keys)
    }

    // Path
    private struct FrontierNode: Comparable {
        let coordinate: AxialCoordinate
        let priority: Int

        static func < (lhs: FrontierNode, rhs: FrontierNode) -> Bool {
            lhs.priority < rhs.priority
        }
    }

    public func path(
        to goal: AxialCoordinate,
        in weightMap: WeightMap
    ) -> Set<AxialCoordinate> {
        let start = self

        // We track the minimum expense of reaching each coordinate in range
        var costSoFar: [AxialCoordinate: Int] = [start: 0]

        // For pathfinding, we're also tracking the least expensive previous node for each node
        var cameFrom: [AxialCoordinate: AxialCoordinate] = [:]

        // The "frontier" is the group of nodes we have on deck to explore
        // We explore by cheapest first - preferring to explore any node with the shortest
        // absolute, unweighted distance to the goal
        var frontier = Heap<FrontierNode>()
        frontier.insert(FrontierNode(coordinate: start, priority: start.distance(from: goal)))

        while let current = frontier.popMin() {
            // If we reached our goal, break out
            if current.coordinate == goal { break }

            // Check the cost of each neighbor
            for neighbor in current.coordinate.neighbors() {
                // We assume the weight of a hex is neutral (1) if we don't have it stored
                let weight = weightMap[neighbor] ?? .standard

                // If a hex is impassable, we just move on
                guard case .passable(let weightCost) = weight else { continue }

                let newCost = costSoFar[current.coordinate]! + weightCost

                if newCost < costSoFar[neighbor] ?? .max {
                    costSoFar[neighbor] = newCost
                    cameFrom[neighbor] = current.coordinate
                    let priority = newCost + neighbor.distance(from: goal)
                    frontier.insert(FrontierNode(coordinate: neighbor, priority: priority))
                }
            }

        }

        return Set<AxialCoordinate>()
    }
}
