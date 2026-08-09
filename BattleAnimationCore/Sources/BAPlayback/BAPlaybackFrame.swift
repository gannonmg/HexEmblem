//
//  BAPlaybackFrame.swift
//  HexEmblem
//
//  Created by Matt Gannon on 8/8/26.
//


import BAModel
import Foundation

public struct BAPlaybackFrame {
    public let duration: TimeInterval
    public let layerURLs: LayerURLs

    public enum LayerURLs {
        case single(URL)
        case double(foreground: URL, background: URL)
    }
}