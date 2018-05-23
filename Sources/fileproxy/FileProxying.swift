//
//  FileProxying.swift
//  fileproxy
//
//  Created by Michael Nisi on 21.02.18.
//

import Foundation

public typealias HTTPStatusCode = Int

/// Enumerates specific errors for this package.
public enum FileProxyError: Error {
  case fileSizeRequired
  case http(HTTPStatusCode)
  case invalidURL(URL)
  case maxBytesExceeded(Int)
  case targetRequired
}

/// The system appreciates it if you configure your download tasks.
public struct DownloadTaskConfiguration {
  let countOfBytesClientExpectsToSend: Int64?
  let countOfBytesClientExpectsToReceive: Int64?
  let earliestBeginDate: Date?
}

/// Blurs the line between local and remote files with long-running nonurgent
/// transfers.
public protocol FileProxying {

  /// Identifies this proxy.
  var identifier: String { get }

  /// The background download completion handler, submitted to the main queue,
  /// when all events have been handled or the session did become invalid.
  var backgroundCompletionHandler: (() -> Void)? { get set }

  /// The maximum size of the target directory in bytes. If the target
  /// directory's size exceeds this maximum, downloaded files are removed,
  /// oldest first.
  var maxBytes: Int { get }

  /// A callback delegate.
  var delegate: FileProxyDelegate? { get set }

  /// Returns proxied URL for `url` and, if the file doesn’t exist locally,
  /// asks the system to download the file in the background. The proxied URL
  /// is either the local file URL or the original remote URL.
  @discardableResult func url(for url: URL, with: DownloadTaskConfiguration?) throws -> URL

  /// Removes the local item for `url`.
  func removeItem(for url: URL) throws

  /// Invalidates this file proxy.
  ///
  /// - Parameters:
  ///   - finishing: Pass `true` to finish current download tasks.
  func invalidate(finishing: Bool)

}

extension FileProxying {

  public func removeItem(for url: URL) throws {
    guard let localURL = FileLocator(identifier: identifier, url: url)?.localURL else {
      fatalError("unhandled error")
    }
    try FileManager.default.removeItem(at: localURL)
  }

}



