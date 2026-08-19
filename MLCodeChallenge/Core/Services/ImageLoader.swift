//
//  ImageLoader.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import UIKit

protocol URLSessionProtocol: Sendable {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

actor ImageLoader {
    private let cache: ImageCache
    private let session: URLSessionProtocol
    private var inFlightTasks: [String: Task<UIImage, Error>] = [:]

    init(cache: ImageCache, session: URLSessionProtocol = URLSession.shared) {
        self.cache = cache
        self.session = session
    }

    func loadImage(from url: URL, targetSize: CGSize, scale: CGFloat) async throws -> UIImage {
        let cacheKey = cacheKey(url: url, size: targetSize, scale: scale)

        if let decoded = cache.decodedImage(for: cacheKey) {
            return decoded
        }

        if let compressed = cache.compressedImage(for: url.absoluteString) {
            let decoded = await decode(compressed, targetSize: targetSize, scale: scale)
            cache.setDecoded(decoded, for: cacheKey)
            return decoded
        }

        if let existingTask = inFlightTasks[url.absoluteString] {
            let compressed = try await existingTask.value
            let decoded = await decode(compressed, targetSize: targetSize, scale: scale)
            cache.setDecoded(decoded, for: cacheKey)
            return decoded
        }

        let task = Task<UIImage, Error> {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else {
                throw ImageLoaderError.invalidImageData
            }
            return image
        }

        inFlightTasks[url.absoluteString] = task

        do {
            let compressed = try await task.value
            inFlightTasks.removeValue(forKey: url.absoluteString)

            cache.setCompressed(compressed, for: url.absoluteString)

            let decoded = await decode(compressed, targetSize: targetSize, scale: scale)
            cache.setDecoded(decoded, for: cacheKey)

            return decoded
        } catch {
            inFlightTasks.removeValue(forKey: url.absoluteString)
            throw error
        }
    }

    private func cacheKey(url: URL, size: CGSize, scale: CGFloat) -> String {
        return "\(url.absoluteString)_\(Int(size.width * scale))x\(Int(size.height * scale))"
    }

    private func decode(_ image: UIImage, targetSize: CGSize, scale: CGFloat) async -> UIImage {
        return await Self.downsampleAndDecode(image, targetSize: targetSize, scale: scale)
    }

    @concurrent
    private nonisolated static func downsampleAndDecode(_ image: UIImage, targetSize: CGSize, scale: CGFloat) async -> UIImage {
        let pixelSize = CGSize(
            width: targetSize.width * scale,
            height: targetSize.height * scale
        )

        guard let cgImage = image.cgImage else { return image }

        let originalWidth = CGFloat(cgImage.width)
        let originalHeight = CGFloat(cgImage.height)
        let aspectRatio = originalWidth / originalHeight

        var drawSize = pixelSize
        if originalWidth > pixelSize.width || originalHeight > pixelSize.height {
            if aspectRatio > 1 {
                drawSize.height = pixelSize.width / aspectRatio
            } else {
                drawSize.width = pixelSize.height * aspectRatio
            }
        } else {
            drawSize = CGSize(width: originalWidth, height: originalHeight)
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: drawSize, format: format)
        let decodedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: drawSize))
        }

        return decodedImage
    }

    func removeAll() async {
        cache.clear()
        inFlightTasks.values.forEach { $0.cancel() }
        inFlightTasks.removeAll()
    }

    func removeAllDecoded() async {
        cache.clearDecoded()
    }
}

enum ImageLoaderError: Error {
    case invalidImageData
}
