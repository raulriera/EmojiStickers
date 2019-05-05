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

final class StickersViewController: UICollectionViewController {
    /// An enumeration that represents an item in the collection view.
    enum CollectionViewItem {
        case sticker(EmojiSticker)
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
	private var items: [CollectionViewItem] {
		didSet {
			let emojis: [EmojiSticker] = items.dropFirst().compactMap { item in
				switch item {
				case .sticker(let emoji):
					return emoji
				case .create:
					return nil
				}
			}

			var history = EmojiHistory.load()
			history.update(with: emojis.reversed())
		}
	}
    
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

	override func didMove(toParent parent: UIViewController?) {
		super.didMove(toParent: parent)

		// Offset the collection view content to hide the "EditCollectionReusableView"
		collectionView?.contentOffset = CGPoint(x: 0, y: 44)
	}
		
    // MARK: Convenience
	
    private func dequeueEmojiCell(for emoji: EmojiSticker, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: EmojiStickerCell.reuseIdentifier, for: indexPath) as? EmojiStickerCell else { fatalError("Unable to dequeue am EmojiStickerCell") }
		
        cell.representedEmoji = emoji
        
        // Use a placeholder sticker while we fetch the real one from the cache.
        let cache = StickerCache.cache
        cell.stickerView.sticker = cache.placeholderSticker
		cell.collectionViewStatus = status
		cell.deleteHandler = { [weak self] in
			self?.handleDeleteEmojiSticker(sticker: $0)
		}

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
		guard let view = collectionView?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EditCollectionReusableView.reuseIdentifier, for: indexPath) as? EditCollectionReusableView else { fatalError("Unable to dequeue a EditCollectionReusableView") }

		view.collectionViewStatus = status
		view.toggleEditModeHandler = { [weak self] newStatus in
			self?.status = newStatus
		}

		return view
	}

	// MARK:

	private func handleDeleteEmojiSticker(sticker: EmojiSticker) {
		// Remove the first index, that is always the create button
		// transform everything to an emoji so it can be queried 
		// easier. We don't need nils
		let stickers: [EmojiSticker] = items.dropFirst().compactMap { item in
			switch item {
			case .sticker(let emoji):
				return emoji
			case .create:
				return nil
			}
		}
		
		collectionView?.performBatchUpdates({ [weak self] in
			// Find the index path we want to delete
			guard let stickerIndex = stickers.firstIndex(where: { $0 == sticker }) else { return }
			// Shift the index by 1 because the first index is always the "create sticker" button
			let indexPath = IndexPath(row: stickerIndex + 1, section: 0)
			// Delete the item from the dataSource
			self?.items.remove(at: indexPath.row)
			// Remove from the collectionView
			self?.collectionView?.deleteItems(at: [indexPath])
		}, completion: nil)

		// Delete the sticker from the cache
		StickerCache.cache.delete(sticker)
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
		// Copy the array so we are not calling the observer more times than we actually need to
		var items = self.items

		// Move the item to the new position
		let item = items[sourceIndexPath.row]
		items.remove(at: sourceIndexPath.row)
		items.insert(item, at: destinationIndexPath.row)

		// Update the array
		self.items = items
	}

	override func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
		// Don't allow the first row to be replaced
		return proposedIndexPath.row == 0 ? originalIndexPath : proposedIndexPath
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
