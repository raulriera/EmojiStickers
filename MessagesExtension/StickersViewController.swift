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

	/// An enumeration that represents the current status of the collection view
	enum CollectionViewStatus {
		case browsing
		case editing
	}
    
    // MARK: Properties
    
    static let storyboardIdentifier = "StickersViewController"
    weak var delegate: StickersViewControllerDelegate?

	private var status: CollectionViewStatus = .browsing {
		didSet {
			collectionView?.reloadData()
		}
	}
    private var items: [CollectionViewItem]
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

	// MARK: Life cycle

	override func didMove(toParentViewController parent: UIViewController?) {
		super.didMove(toParentViewController: parent)

		// Offset the collection view content to hide the "EditCollectionReusableView"
		collectionView?.contentOffset = CGPoint(x: 0, y: 44)
	}
		
    // MARK: Convenience
	
    private func dequeueEmojiCell(for emoji: Emoji, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath) as? EmojiCell else { fatalError("Unable to dequeue am EmojiCell") }
        
        cell.representedEmoji = emoji
        
        // Use a placeholder sticker while we fetch the real one from the cache.
        let cache = StickerCache.cache
        cell.stickerView.sticker = cache.placeholderSticker
		cell.collectionViewStatus = status
        
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

	private func dequeueEditStickersReusableView(at indexPath: IndexPath) -> UICollectionReusableView {
		guard let view = collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: EditCollectionReusableView.reuseIdentifier, for: indexPath) as? EditCollectionReusableView else { fatalError("Unable to dequeue a EditCollectionReusableView") }

		view.collectionViewStatus = status
		view.toggleEditModeHandler = { [weak self] newStatus in
			self?.status = newStatus
		}

		return view
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

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		return dequeueEditStickersReusableView(at: indexPath)
	}
}

// MARK: UICollectionViewDelegate

extension StickersViewController {

	override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		guard status == .editing else { return false }
		// We can move all cells except the first one
		return indexPath.row != 0
	}

	override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		// TODO: Update the contents of EmojiHistory so this new order 
		// gets stored for future references
		swap(&items[sourceIndexPath.row], &items[destinationIndexPath.row])
	}

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
