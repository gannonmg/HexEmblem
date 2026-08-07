//
//  PixelImageError.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/3/26.
//

import Foundation

public enum PixelImageError: Error {
    case cannotCreateImageSource(URL)
    case cannotReadImage(URL)
    case cannotCreateContext
    case cannotCreateCGImage
    case cannotCreateDestination(URL)
    case cannotWritePNG(URL)
}
