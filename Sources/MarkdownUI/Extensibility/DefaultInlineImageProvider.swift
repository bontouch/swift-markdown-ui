import SwiftUI

/// The default inline image provider, which loads images from the network.
public struct DefaultInlineImageProvider: InlineImageProvider {
  public func image(with url: URL, label: String) async throws -> Image {
    try await downloadImage(url: url, label: Text(label))
  }
}

extension InlineImageProvider where Self == DefaultInlineImageProvider {
  /// The default inline image provider, which loads images from the network.
  ///
  /// Use the `markdownInlineImageProvider(_:)` modifier to configure
  /// this image provider for a view hierarchy.
  public static var `default`: Self {
    .init()
  }
}

let urlSession: URLSession = {
  let configuration = URLSessionConfiguration.default
  configuration.requestCachePolicy = .returnCacheDataElseLoad
  configuration.urlCache = URLCache(
    memoryCapacity: 10 * 1024 * 1024,
    diskCapacity: 100 * 1024 * 1024
  )
  configuration.timeoutIntervalForRequest = 15
  configuration.httpAdditionalHeaders = ["Accept": "image/*"]
  return .init(configuration: configuration)
}()

func downloadImage(url: URL, label: Text) async throws -> Image {
  let (data, response) = try await urlSession.data(from: url)
  
  guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
        200..<300 ~= statusCode
  else {
    throw URLError(.badServerResponse)
  }
  
  guard
    let source = CGImageSourceCreateWithData(data as CFData, nil),
    let image = CGImageSourceCreateImageAtIndex(
      source, 0,
      [kCGImageSourceShouldCache: true] as CFDictionary
    )
  else {
    throw URLError(.cannotDecodeContentData)
  }
  
  return Image(image, scale: 1, label: label)
}
