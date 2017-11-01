//
//  CenteredFlowLayout.swift
//  EmojiStickers
//
//  Created by Raul Riera on 19/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

final class CenteredFlowLayout: UICollectionViewFlowLayout {
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		let currentBounds = collectionView?.bounds ?? .zero
		return newBounds.width != currentBounds.width
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		let attributes = super.layoutAttributesForElements(in: rect) ?? []
		guard let collectionView = collectionView, collectionViewContentSize.width < collectionView.bounds.width else { return attributes }
		let availableWidth = (collectionView.bounds.width - collectionViewContentSize.width) / 2
		
		for item in attributes {
			item.frame.origin.x = item.frame.origin.x + availableWidth
		}
		
		return attributes
	}
}
