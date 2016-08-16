//
//  CenteredFlowLayout.swift
//  EmojiStickers
//
//  Created by Raul Riera on 19/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

class CenteredFlowLayout: UICollectionViewFlowLayout {
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		
		var attributes = [UICollectionViewLayoutAttributes]()
		
		let superAttributes = super.layoutAttributesForElements(in: rect)
		
		for attrib in superAttributes! {
			let attributesCopy = attrib.copy() as! UICollectionViewLayoutAttributes
			attributes.append(attributesCopy)
		}
		
		var rowCollections = [Float: [UICollectionViewLayoutAttributes]]()
		
		for itemAttributes in attributes {
			
			let midYRound = roundf(Float(itemAttributes.frame.midY))
			let midYPlus = midYRound + 1
			let midYMinus = midYRound - 1
			
			var key: Float?
			
			if let _ = rowCollections[midYPlus] {
				key = midYPlus
			}
			
			if let _ = rowCollections[midYMinus] {
				key = midYMinus
			}
			
			if let _ = key { //fix this
			} else {
				key = midYRound
			}
			
			if let theKey = key  {
				if let _ = rowCollections[theKey] {
					rowCollections[theKey]?.append(itemAttributes)
				} else {
					var attributesArray = [UICollectionViewLayoutAttributes]()
					attributesArray.append(itemAttributes)
					rowCollections[theKey] = attributesArray
				}
			}
		}
		
		var collectionViewWidth: CGFloat = 0
		
		if let collectionView = self.collectionView {
			collectionViewWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
		}
		
		for (_, itemAttributesArray) in rowCollections {
			
			let itemsInRow = itemAttributesArray.count
			var interitemSpacing = minimumInteritemSpacing
			
			if let theCollectionView = collectionView, let flowDelegate = theCollectionView.delegate as? UICollectionViewDelegateFlowLayout {
				
				let section = itemAttributesArray[0].indexPath.section
				
				if let spacing = flowDelegate.collectionView?(theCollectionView, layout: self, minimumInteritemSpacingForSectionAt: section)  {
					interitemSpacing = spacing
				}
			}
			
			let aggregateInteritemSpacing = interitemSpacing * CGFloat(itemsInRow-1)
			
			var aggregateItemWidths: CGFloat = 0.0
			
			for itemAttributes in itemAttributesArray {
				aggregateItemWidths += itemAttributes.frame.width
			}
			
			let alignmentWidth = aggregateItemWidths + aggregateInteritemSpacing
			let alignmentXOffset = abs((collectionViewWidth - alignmentWidth) / 2.0)
			
			var previousFrame = CGRect.zero
			for itemAttributes in itemAttributesArray {
				
				var itemFrame = itemAttributes.frame
				
				if previousFrame.equalTo(CGRect.zero) {
					itemFrame.origin.x = alignmentXOffset
				} else {
					itemFrame.origin.x = previousFrame.maxX + interitemSpacing
				}
				
				itemAttributes.frame = itemFrame
				previousFrame = itemFrame
			}
		}
		
		return attributes
	}
}
