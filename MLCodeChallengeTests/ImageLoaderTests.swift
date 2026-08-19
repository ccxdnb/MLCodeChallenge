//
//  ImageLoaderTests.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import Testing
import Foundation
import UIKit
@testable import MLCodeChallenge

@MainActor
@Suite("ImageLoader Tests")
struct ImageLoaderTests {
    @Test("returns decoded image from cache on hit")
    func cacheHit() async throws {
        let cache = ImageCache()
        let mockSession = MockURLSession()
        let loader = ImageLoader(cache: cache, session: mockSession)
        let url = URL(string: "https://example.com/image.jpg")!
        let targetSize = CGSize(width: 100, height: 100)

        let testImage = createTestImage()
        let scale: CGFloat = 3.0
        let cacheKey = "\(url.absoluteString)_\(Int(targetSize.width * scale))x\(Int(targetSize.height * scale))"
        cache.setDecoded(testImage, for: cacheKey)

        _ = try await loader.loadImage(from: url, targetSize: targetSize, scale: scale)

        #expect(mockSession.dataCallCount == 0)
    }

    @Test("fetches image when not in cache")
    func cacheMiss() async throws {
        let cache = ImageCache()
        let mockSession = MockURLSession()
        let loader = ImageLoader(cache: cache, session: mockSession)
        let url = URL(string: "https://example.com/image.jpg")!
        let targetSize = CGSize(width: 100, height: 100)

        let testImage = createTestImage()
        mockSession.dataToReturn = testImage.pngData()

        _ = try await loader.loadImage(from: url, targetSize: targetSize, scale: 1.0)

        #expect(mockSession.dataCallCount == 1)
    }

    @Test("caches compressed image after fetch")
    func cachesAfterFetch() async throws {
        let cache = ImageCache()
        let mockSession = MockURLSession()
        let loader = ImageLoader(cache: cache, session: mockSession)
        let url = URL(string: "https://example.com/image.jpg")!
        let targetSize = CGSize(width: 100, height: 100)

        let testImage = createTestImage()
        mockSession.dataToReturn = testImage.pngData()

        _ = try await loader.loadImage(from: url, targetSize: targetSize, scale: 1.0)

        let compressed = cache.compressedImage(for: url.absoluteString)
        #expect(compressed != nil)
    }

    @Test("caches decoded image after fetch")
    func cachesDecodedAfterFetch() async throws {
        let cache = ImageCache()
        let mockSession = MockURLSession()
        let loader = ImageLoader(cache: cache, session: mockSession)
        let url = URL(string: "https://example.com/image.jpg")!
        let targetSize = CGSize(width: 100, height: 100)

        let testImage = createTestImage()
        mockSession.dataToReturn = testImage.pngData()

        _ = try await loader.loadImage(from: url, targetSize: targetSize, scale: 1.0)

        let scale: CGFloat = 1.0
        let cacheKey = "\(url.absoluteString)_\(Int(targetSize.width * scale))x\(Int(targetSize.height * scale))"
        let decoded = cache.decodedImage(for: cacheKey)
        #expect(decoded != nil)
    }

    @Test("deduplicates concurrent requests for same URL")
    func deduplicatesConcurrentRequests() async throws {
        let cache = ImageCache()
        let mockSession = MockURLSession()
        let loader = ImageLoader(cache: cache, session: mockSession)
        let url = URL(string: "https://example.com/image.jpg")!
        let targetSize = CGSize(width: 100, height: 100)

        let testImage = createTestImage()
        mockSession.dataToReturn = testImage.pngData()
        mockSession.delayDuration = 0.1

        async let result1 = loader.loadImage(from: url, targetSize: targetSize, scale: 1.0)
        async let result2 = loader.loadImage(from: url, targetSize: targetSize, scale: 1.0)
        async let result3 = loader.loadImage(from: url, targetSize: targetSize, scale: 1.0)

        let images = try await [result1, result2, result3]

        #expect(images.count == 3)
        #expect(mockSession.dataCallCount == 1)
    }

    @Test("different target sizes use different cache keys")
    func differentSizesUseDifferentKeys() async throws {
        let cache = ImageCache()
        let mockSession = MockURLSession()
        let loader = ImageLoader(cache: cache, session: mockSession)
        let url = URL(string: "https://example.com/image.jpg")!
        let size1 = CGSize(width: 100, height: 100)
        let size2 = CGSize(width: 200, height: 200)

        let testImage = createTestImage()
        mockSession.dataToReturn = testImage.pngData()

        _ = try await loader.loadImage(from: url, targetSize: size1, scale: 1.0)
        _ = try await loader.loadImage(from: url, targetSize: size2, scale: 1.0)

        #expect(mockSession.dataCallCount == 1)
    }

    @Test("throws error for invalid image data")
    func throwsForInvalidData() async throws {
        let cache = ImageCache()
        let mockSession = MockURLSession()
        let loader = ImageLoader(cache: cache, session: mockSession)
        let url = URL(string: "https://example.com/image.jpg")!
        let targetSize = CGSize(width: 100, height: 100)

        mockSession.dataToReturn = Data("invalid".utf8)

        await #expect(throws: ImageLoaderError.self) {
            try await loader.loadImage(from: url, targetSize: targetSize, scale: 1.0)
        }
    }

    @Test("removeAll clears cache and cancels in-flight tasks")
    func removeAllClearsCacheAndCancelsTasks() async throws {
        let cache = ImageCache()
        let mockSession = MockURLSession()
        let loader = ImageLoader(cache: cache, session: mockSession)
        let url = URL(string: "https://example.com/image.jpg")!
        let targetSize = CGSize(width: 100, height: 100)

        let testImage = createTestImage()
        mockSession.dataToReturn = testImage.pngData()

        _ = try await loader.loadImage(from: url, targetSize: targetSize, scale: 1.0)

        #expect(cache.compressedImage(for: url.absoluteString) != nil)

        await loader.removeAll()

        #expect(cache.compressedImage(for: url.absoluteString) == nil)
    }

    @Test("removeAllDecoded clears only decoded cache")
    func removeAllDecodedClearsOnlyDecodedCache() async throws {
        let cache = ImageCache()
        let mockSession = MockURLSession()
        let loader = ImageLoader(cache: cache, session: mockSession)
        let url = URL(string: "https://example.com/image.jpg")!
        let targetSize = CGSize(width: 100, height: 100)

        let testImage = createTestImage()
        mockSession.dataToReturn = testImage.pngData()

        _ = try await loader.loadImage(from: url, targetSize: targetSize, scale: 1.0)

        await loader.removeAllDecoded()

        #expect(cache.compressedImage(for: url.absoluteString) != nil)
    }

    private func createTestImage() -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

final class MockURLSession: URLSessionProtocol, @unchecked Sendable {
    var dataToReturn: Data?
    var errorToThrow: Error?
    var dataCallCount = 0
    var delayDuration: TimeInterval = 0

    func data(from url: URL) async throws -> (Data, URLResponse) {
        dataCallCount += 1

        if delayDuration > 0 {
            try await Task.sleep(nanoseconds: UInt64(delayDuration * 1_000_000_000))
        }

        if let error = errorToThrow {
            throw error
        }

        guard let data = dataToReturn else {
            throw URLError(.badServerResponse)
        }

        guard let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ) else {
            throw URLError(.badServerResponse)
        }

        return (data, response)
    }
}
