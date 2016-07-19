//
//  StickersViewController.swift
//  EmojiStickers
//
//  Created by Raul Riera on 19/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

/**
A delegate protocl for the `StickersViewController` class.
*/
protocol StickersViewControllerDelegate: class {
	/// Called when an user choses to create a new `Sticker` in the `StickersViewController`.
	func stickersViewControllerDidSelectCreate(_ controller: StickersViewController)
}

class StickersViewController: UICollectionViewController {
    /// An enumeration that represents an item in the collection view.
    enum CollectionViewItem {
        case sticker(Emoji)
        case create
    }
    
    // MARK: Properties
    
    static let storyboardIdentifier = "StickersViewController"
    weak var delegate: StickersViewControllerDelegate?

    private let items: [CollectionViewItem]
    private let stickerCache = StickerCache.cache
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        // Map the previously created stickers to an array of `CollectionViewItem`s.
        let reversedHistory = EmojiHistory.load().reversed()
        var items: [CollectionViewItem] = reversedHistory.map { .sticker($0) }
        
        // Add `CollectionViewItem` that the user can tap to start building a new sticker.
        items.insert(.create, at: 0)
        
        self.items = items
        super.init(coder: aDecoder)
    }
		
    // MARK: Convenience
	
    private func dequeueEmojiCell(for emoji: Emoji, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath) as? EmojiCell else { fatalError("Unable to dequeue am EmojiCell") }
        
        cell.representedEmoji = emoji
        
        // Use a placeholder sticker while we fetch the real one from the cache.
        let cache = StickerCache.cache
        cell.stickerView.sticker = cache.placeholderSticker
        
        // Fetch the sticker for the emoji from the cache.
        cache.sticker(for: emoji) { sticker in
            OperationQueue.main.addOperation {
                // If the cell is still showing the same emoji, update its sticker view.
                guard cell.representedEmoji == emoji else { return }
                cell.stickerView.sticker = sticker
            }
        }
        
        return cell
    }
    
    private func dequeueCreateCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: CreateCell.reuseIdentifier, for: indexPath) as? CreateCell else { fatalError("Unable to dequeue a CreateCell") }
        
        return cell
    }
}

// MARK: UICollectionViewDataSource

extension StickersViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        
        // The item's type determines which type of cell to return.
        switch item {
        case .sticker(let emoji):
            return dequeueEmojiCell(for: emoji, at: indexPath)
            
        case .create:
            return dequeueCreateCell(at: indexPath)
        }
    }
}

// MARK: UICollectionViewDelegate

extension StickersViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        switch item {
        case .create:
            delegate?.stickersViewControllerDidSelectCreate(self)
        default:
            break
        }
    }
}
