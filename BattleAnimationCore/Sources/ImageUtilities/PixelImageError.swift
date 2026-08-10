//
//  PixelImageError.swift
//  BattleAnimationCore
//
//  Created by Matt Gannon on 8/3/26.
//

import Foundation

public enum PixelImageError: LocalizedError {
    case cannotCreateImageSource(URL)
    case cannotReadImage(URL)
    case cannotCreateContext
    case cannotCreateCGImage
    case cannotCreateDestination(URL)
    case cannotWritePNG(URL)

    public var errorDescription: String {
        switch self {
        case .cannotCreateImageSource(let url):
            "Cannot creat image source for image at \(url)"
        case .cannotReadImage(let url):
            "Cannot read image at \(url)"
        case .cannotCreateContext:
            "Cannot create context"
        case .cannotCreateCGImage:
            "Cannot creat CGImage"
        case .cannotCreateDestination(let url):
            "Cannot create destination at \(url)"
        case .cannotWritePNG(let url):
            "Cannot write PNG at \(url)"
        }
    }
}
