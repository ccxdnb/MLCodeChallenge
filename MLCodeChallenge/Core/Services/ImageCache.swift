//
//  ImageCache.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import UIKit

/// Thread-safe image cache wrapping NSCache.
/// @unchecked Sendable is justified because NSCache is documented as thread-safe,
/// though it doesn't conform to Sendable in the SDK.
final class ImageCache: @unchecked Sendable {
    private let compressedCache = NSCache<NSString, UIImage>()
    private let decodedCache = NSCache<NSString, UIImage>()

    init(
        compressedCountLimit: Int = 100,
        decodedMemoryLimit: Int = 50 * 1024 * 1024
    ) {
        compressedCache.countLimit = compressedCountLimit
        decodedCache.totalCostLimit = decodedMemoryLimit
    }

    func compressedImage(for key: String) -> UIImage? {
        compressedCache.object(forKey: key as NSString)
    }

    func decodedImage(for key: String) -> UIImage? {
        decodedCache.object(forKey: key as NSString)
    }

    func setCompressed(_ image: UIImage, for key: String) {
        compressedCache.setObject(image, forKey: key as NSString)
    }

    func setDecoded(_ image: UIImage, for key: String) {
        let cost = imageCost(image)
        decodedCache.setObject(image, forKey: key as NSString, cost: cost)
    }

    func clear() {
        compressedCache.removeAllObjects()
        decodedCache.removeAllObjects()
    }

    func clearDecoded() {
        decodedCache.removeAllObjects()
    }

    func clearCompressed() {
        compressedCache.removeAllObjects()
    }

    private func imageCost(_ image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}
