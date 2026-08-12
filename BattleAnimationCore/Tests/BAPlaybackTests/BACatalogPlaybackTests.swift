//
//  BACatalogPlaybackTests.swift
//  BattleAnimationCore
//

import BAModel
import Foundation
import Testing

@testable import BAPlayback

@Suite("Catalog-driven playback")
struct BACatalogPlaybackTests {

    @Test("Catalog loads from the bundle and is non-empty")
    func catalogLoads() throws {
        let catalog = try BAProcessedAnimationStore.catalog()

        #expect(catalog.version == 1)
        #expect(!catalog.animations.isEmpty)
    }

    @Test("Every catalog entry can resolve frames for the modes it claims")
    func everyEntryPlaysItsClaimedModes() throws {
        let catalog = try BAProcessedAnimationStore.catalog()

        for entry in catalog.animations {
            for mode in entry.modes {
                let frames = try BAProcessedAnimationStore.playableEvents(entry: entry, mode: mode)

                #expect(
                    !frames.isEmpty,
                    "\(entry.id) mode \(mode.rawValue) resolved to zero frames"
                )
            }
        }
    }

//    @Test("Every referenced frame asset exists on disk")
//    func frameAssetsExist() throws {
//        let catalog = try BAProcessedAnimationStore.catalog()
//
//        for entry in catalog.animations {
//            let frames: [BAPlaybackFrame] = try BAProcessedAnimationStore.playableEvents(
//                entry: entry,
//                mode: .standing
//            ).compactMap { event in
//                guard case .frame(let baPlaybackFrame) = event else { return nil }
//                return baPlaybackFrame
//            }
//
//            for frame in frames {
//                switch frame.layerURLs {
//                case .single(let url):
//                    #expect(FileManager.default.fileExists(atPath: url.path))
//
//                case .double(let foreground, let background):
//                    #expect(FileManager.default.fileExists(atPath: foreground.path))
//                    #expect(FileManager.default.fileExists(atPath: background.path))
//                }
//            }
//        }
//    }

    @Test("Lookup by animation ID matches lookup by entry")
    func lookupByIDMatchesEntry() throws {
        let catalog = try BAProcessedAnimationStore.catalog()
        let entry = try #require(catalog.animations.first)

        let byID = try BAProcessedAnimationStore.playableEvents(
            animationID: entry.id,
            mode: .meleeAttack
        )
        let byEntry = try BAProcessedAnimationStore.playableEvents(
            entry: entry,
            mode: .meleeAttack
        )

        #expect(byID.count == byEntry.count)
    }

    @Test("Unknown animation IDs throw rather than returning empty")
    func unknownAnimationThrows() {
        #expect(throws: BAProcessedAnimationStoreError.self) {
            try BAProcessedAnimationStore.playableEvents(
                animationID: "LanceHalberdier",
                mode: .meleeAttack
            )
        }
    }

    @Test("Mode fallback substitutes a mode the entry actually has")
    func modeFallbackResolves() throws {
        let catalog = try BAProcessedAnimationStore.catalog()

        // Find an entry missing at least one mode so the fallback chain is exercised.
        let incomplete = catalog.animations.first { !$0.contains(.rangedCritical) }

        guard let incomplete else { return }

        let resolved = try BAProcessedAnimationStore.resolveMode(.rangedCritical, in: incomplete)

        #expect(resolved != .rangedCritical)
        #expect(incomplete.contains(resolved))
    }

//    @Test("Catalog resolves a sprite set and weapon slot to an entry")
//    func spriteSetAndSlotResolution() throws {
//        let catalog = try BAProcessedAnimationStore.catalog()
//        let seed = try #require(catalog.animations.first { $0.variant.slot != nil })
//        let slot = try #require(seed.variant.slot)
//
//        let resolved = try #require(
//            catalog.entry(spriteSetID: seed.spriteSet.id, slot: slot)
//        )
//
//        #expect(resolved.spriteSet.id == seed.spriteSet.id)
//        #expect(resolved.variant.slot == seed.variant.slot)
//    }

    @Test("Melee lance attack classifies the impact bracket and holds for HP drain")
    func meleeAttackMarkerSpine() throws {
        let events = try BAProcessedAnimationStore.playableEvents(
            animationID: "Custom-Halb-Halberdier-Gwendolyn-F-by-UltraFenix_2-Lance",
            mode: .meleeAttack
        )

        let markerKinds: [BAPlaybackEvent.Marker] = events.compactMap {
            guard case .marker(let marker) = $0 else { return nil }
            return marker
        }

        #expect(markerKinds == [
            .startAttack,
            .startAttack,
            .playSound,
            .armHPDepletion,
            .impact,
            .playSound,
            .impact,
            .waitForHPDepletion,
            .playSound,
            .playSound,
            .playSound,
            .beginOpponentTurn,
            .endDodge
        ])

        #expect(events.count == 32)

        // Two impact markers, one damage beat — the first of the pair.
        let impactCount = markerKinds.filter { $0 == .impact }.count
        #expect(impactCount == 2)
//        #expect(events.firstDamageBeatIndex == events.firstIndex { event in
//            guard case .marker(let marker) = event else { return false }
//            return marker == .impact
//        })
    }

    @Test("Ranged bow attack yields an interleaved, fully classified marker spine",)
    func attackMarkerSpine() throws {
        let events = try BAProcessedAnimationStore.playableEvents(
            animationID: "Crossbow-Cowboy-M-by-MeatofJustice_5-Bow",
            mode: .rangedAttack
        )

        let markerKinds: [BAPlaybackEvent.Marker] = events.compactMap {
            guard case .marker(let marker) = $0 else { return nil }
            return marker
        }

        #expect(markerKinds == [
            .startAttack,
            .startAttack,
            .castSpell,
            .waitForHPDepletion,
            .beginOpponentTurn,
            .endDodge
        ])

        #expect(events.count == 24)
//        #expect(events.firstDamageBeatIndex != nil)
    }
}
