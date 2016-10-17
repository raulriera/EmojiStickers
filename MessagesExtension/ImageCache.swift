//
//  EmojiCache.swift
//  EmojiStickers
//
//  Created by Raul Riera on 01/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

protocol Cachable {
	var identifier: String { get }
	var image: () -> UIImage { get }
}

final class ImageCache {
	static let cache = ImageCache()
	private let cacheURL: URL
	private let queue = OperationQueue()
	
	enum CacheDestination {
		case temporary
		case atFolder(String)
	}
	
	/**
	An `UIImage` that can be used as a placeholder while a real image
	is being fetched from the cache.
	*/
	let placeholderImage: UIImage = {
		guard let image = UIImage(named: "placeholder_image") else {
			fatalError("Failed to create placeholder image")
		}
		
		return image
	}()
	
	// MARK: Initialization
	
	private init(destination: CacheDestination = .temporary) {		
		// Create the URL for the location of the cache resources
		switch destination {
		case .temporary:
			cacheURL = URL(fileURLWithPath: NSTemporaryDirectory())
		case .atFolder(let folder):
			let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
			cacheURL = URL(fileURLWithPath: documentFolder + folder)
		}
		
		let fileManager = FileManager.default
		
		do {
			try fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
		}
		catch {
			fatalError("Unable to create cache URL: \(error)")
		}
	}
	
	deinit {
		let fileManager = FileManager.default
		do {
			try fileManager.removeItem(at: cacheURL)
		}
		catch {
			print("Unable to remove cache directory: \(error)")
		}
	}
	
	// MARK
	
	func image(for cachable: Cachable, completion: @escaping (_ image: UIImage) -> Void) {
		let fileName = cachable.identifier + ".png"
		let url = cacheURL.appendingPathComponent(fileName, isDirectory: false)
		
		// Create an operation to process the request.
		let operation = BlockOperation {
			// Check if the image already exists at the URL.
			let fileManager = FileManager.default
			guard fileManager.fileExists(atPath: url.path) == false else {
				return
			}
			
			// Create the image and write it to disk.
			guard let imageData = UIImagePNGRepresentation(cachable.image()) else {
				fatalError("Unable to build image for cache")
			}
			
			do {
				try imageData.write(to: url, options: [.atomicWrite])
			} catch {
				fatalError("Failed to write image to cache: \(error)")
			}
		}
		
		// Set the operation's completion block to call the request's completion handler.
		operation.completionBlock = {
			guard let image = UIImage(contentsOfFile: url.path) else {
				print("Failed to read image from \(url)")
				return
			}
			completion(image)
		}
		
		// Add the operation to the queue to start the work.
		queue.addOperation(operation)
	}
}
