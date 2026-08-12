//
//  BAPlaybackFrame.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/8/26.
//


import BAModel
import Foundation

public struct BAPlaybackFrame: Equatable, Sendable {
    public let duration: TimeInterval
    public let layerData: LayerData

    public enum LayerData: Equatable, Sendable {
        case single(Data)
        case double(foreground: Data, background: Data)
    }
}
