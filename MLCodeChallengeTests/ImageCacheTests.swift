import Testing
import UIKit
@testable import MLCodeChallenge

@MainActor
@Suite("ImageCache Tests")
struct ImageCacheTests {
    @Test("stores and retrieves compressed images")
    func storesCompressedImages() async throws {
        let cache = ImageCache()
        let image = createTestImage()
        let key = "test-key"

        cache.setCompressed(image, for: key)
        let retrieved = cache.compressedImage(for: key)

        #expect(retrieved != nil)
    }

    @Test("stores and retrieves decoded images")
    func storesDecodedImages() async throws {
        let cache = ImageCache()
        let image = createTestImage()
        let key = "test-key"

        cache.setDecoded(image, for: key)
        let retrieved = cache.decodedImage(for: key)

        #expect(retrieved != nil)
    }

    @Test("decoded and compressed caches are separate tiers")
    func separateTiers() async throws {
        let cache = ImageCache()
        let compressedKey = "compressed"
        let decodedKey = "decoded"
        let image = createTestImage()

        cache.setCompressed(image, for: compressedKey)
        cache.setDecoded(image, for: decodedKey)

        #expect(cache.compressedImage(for: compressedKey) != nil)
        #expect(cache.decodedImage(for: decodedKey) != nil)
        #expect(cache.compressedImage(for: decodedKey) == nil)
        #expect(cache.decodedImage(for: compressedKey) == nil)
    }

    @Test("clear removes all cached items")
    func clearCache() async throws {
        let cache = ImageCache()
        let image = createTestImage()

        cache.setCompressed(image, for: "key1")
        cache.setDecoded(image, for: "key2")

        cache.clear()

        #expect(cache.compressedImage(for: "key1") == nil)
        #expect(cache.decodedImage(for: "key2") == nil)
    }

    @Test("clearDecoded removes only decoded cache")
    func clearDecodedOnly() async throws {
        let cache = ImageCache()
        let image = createTestImage()

        cache.setCompressed(image, for: "key1")
        cache.setDecoded(image, for: "key2")

        cache.clearDecoded()

        #expect(cache.compressedImage(for: "key1") != nil)
        #expect(cache.decodedImage(for: "key2") == nil)
    }

    @Test("clearCompressed removes only compressed cache")
    func clearCompressedOnly() async throws {
        let cache = ImageCache()
        let image = createTestImage()

        cache.setCompressed(image, for: "key1")
        cache.setDecoded(image, for: "key2")

        cache.clearCompressed()

        #expect(cache.compressedImage(for: "key1") == nil)
        #expect(cache.decodedImage(for: "key2") != nil)
    }

    private func createTestImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
