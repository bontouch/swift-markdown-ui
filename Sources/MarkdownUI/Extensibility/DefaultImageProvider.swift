import SwiftUI

/// The default image provider, which loads images from the network.
public struct DefaultImageProvider: ImageProvider {
  public func makeImage(url: URL?) -> some View {
    AsyncImage(url: url) { state in
      switch state {
      case .success(let image):
        ResizeToFit {
          image.resizable()
        }
      case .empty, .failure:
        Color.clear
          .frame(width: 0, height: 0)
      @unknown default:
        Color.clear
          .frame(width: 0, height: 0)
      }
    }
  }
}

extension ImageProvider where Self == DefaultImageProvider {
  /// The default image provider, which loads images from the network.
  ///
  /// Use the `markdownImageProvider(_:)` modifier to configure this image provider for a view hierarchy.
  public static var `default`: Self {
    .init()
  }
}
