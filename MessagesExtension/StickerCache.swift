//
//  StickerCache.swift
//  EmojiStickers
//
//  Created by Raul Riera on 19/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit
import Messages

final class StickerCache {
    static let cache = StickerCache()
    private let cacheURL: URL
    private let queue = OperationQueue()
    
    /**
     An `MSSticker` that can be used as a placeholder while a real emoji
     sticker is being fetched from the cache.
     */
    let placeholderSticker: MSSticker = {
		guard let placeholderURL = Bundle.main.url(forResource: "sticker_placeholder", withExtension: "png") else { fatalError("Unable to find placeholder sticker image") }
        
        do {
            let description = NSLocalizedString("An emoji sticker", comment: "")
            return try MSSticker(contentsOfFileURL: placeholderURL, localizedDescription: description)
        }
        catch {
            fatalError("Failed to create placeholder sticker: \(error)")
        }
    }()
    
    // MARK: Initialization
    
    private init() {
        let fileManager = FileManager.default
        let directoryName = "stickers"
		let tempPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

        do {
			cacheURL = URL(fileURLWithPath: tempPath).appendingPathComponent(directoryName, isDirectory: true)
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
    
    func sticker(for emoji: EmojiSticker, completion: @escaping (_ sticker: MSSticker) -> Void) {
        // Determine the URL for the sticker.
		let fileName = "\(emoji.uuid.uuidString).png"
		let url = cacheURL.appendingPathComponent(fileName, isDirectory: false)

        // Create an operation to process the request.
        let operation = BlockOperation {
            // Check if the sticker already exists at the URL.
            let fileManager = FileManager.default
            guard !fileManager.fileExists(atPath: url.absoluteString) else { return }
            
            // Create the sticker image and write it to disk.
			guard let image = emoji.image else { return }
			guard let imageData = image.pngData() else { fatalError("Unable to build image for the emoji") }
            
            do {
                try imageData.write(to: url, options: [.atomicWrite])
            } catch {
                fatalError("Failed to write sticker image to cache: \(error)")
            }
        }
        
        // Set the operation's completion block to call the request's completion handler.
        operation.completionBlock = {
            do {
                let sticker = try MSSticker(contentsOfFileURL: url, localizedDescription: "Emoji Sticker")
                completion(sticker)
            } catch {
                print("Failed to write image to cache, error: \(error)")
            }
        }
        
        // Add the operation to the queue to start the work.
        queue.addOperation(operation)
    }

	func delete(_ emoji: EmojiSticker) {
		// Determine the URL for the sticker.
		let fileName = "\(emoji.uuid.uuidString).png"
		let url = cacheURL.appendingPathComponent(fileName, isDirectory: false)

		// Create an operation to process the request.
		let operation = BlockOperation {
			// Check if the sticker already exists at the URL.
			let fileManager = FileManager.default
			guard !fileManager.fileExists(atPath: url.absoluteString) else { return }

			do {
				try fileManager.removeItem(at: url)
			}
			catch {
				print("Unable to remove sticker: \(error)")
			}
		}

		// Add the operation to the queue to start the work.
		queue.addOperation(operation)
	}
}
