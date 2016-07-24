//
//  BuildEmojiViewController.swift
//  EmojiStickers
//
//  Created by Raúl Riera on 19/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

/**
A delegate protocol for the `BuildEmojiViewController` class.
*/
protocol BuildEmojiViewControllerDelegate: class {
	/// Called when the user taps to finished the `Emoji` in the `BuildEmojiViewController`.
	func buildEmojiViewController(_ controller: BuildEmojiViewController, didFinish emoji: Emoji)
}

class BuildEmojiViewController: UIViewController {
    
    // MARK: IBOutlets
	
	@IBOutlet private weak var canvas: UIView! {
		didSet {
			canvas.superview?.layer.borderWidth = 0.5
			canvas.superview?.layer.borderColor = UIColor.lightGray().cgColor
			canvas.superview?.layer.cornerRadius = 4.0
		}
	}
	
	override func willMove(toParentViewController parent: UIViewController?) {
		super.willMove(toParentViewController: parent)
		
		guard parent == nil else { return }
		removeChildViewControllers()
	}
	
    // MARK: Properties
    
    static let storyboardIdentifier = "BuildEmojiViewController"
    weak var delegate: BuildEmojiViewControllerDelegate?
	private var lastUsedCategory: Int = 0
		
	// MARK: IBActions
	
	@IBAction func didTapPickEmoji(_ sender: UIButton) {
		guard let controller = instantiateEmojiCategoriesController() as? EmojiCategoriesViewController else { return }
		
		// Remove any existing child controllers.
		removeChildViewControllers()
		
		// Embed the new controller.
		addChildViewController(controller)
		
		controller.view.frame = view.bounds
		controller.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(controller.view)
		
		controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		controller.view.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor).isActive = true
		controller.view.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor).isActive = true
		
		controller.didMove(toParentViewController: self)
		
		controller.selectEmojiHandler = { emoji, categoryIndex, selectionRect in
			self.lastUsedCategory = categoryIndex
			let emojiView = EmojiView(character: emoji)

			// Convert the point to the canvas coordinates
			emojiView.frame = emojiView.convert(selectionRect, to: self.canvas)

			self.canvas.addSubview(emojiView)

			UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
				//emojiView.frame = originalRect
				emojiView.center = self.canvas.convert(self.canvas.center, to: self.canvas.superview)
				}, completion: { _ in

					UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .beginFromCurrentState, animations: {
						emojiView.bounds.size = emojiView.defaultSize
						}, completion: nil)
			})

			self.createRotateGestureRecognizer(targetView: emojiView)
			self.createPinchGestureRecognizer(targetView: emojiView)
			self.createPanGestureRecognizer(targetView: emojiView)
			self.createDoubleTapGestureRecognizer(targetView: emojiView)
			self.createTapGestureRecognizer(targetView: emojiView)
						
			// Remove any existing child controllers.
			self.removeChildViewControllers()
		}
		
		controller.changePage(to: lastUsedCategory, animated: false)
	}
	
	@IBAction func didTapSave(_ sender: UIButton) {
		guard canvas.subviews.isEmpty == false else { return }

		let image = UIImage(view: canvas)
		let emoji = Emoji(uuid: UUID(), image: image)
		
		// Append this sticker to the history
		var history = EmojiHistory.load()
		history.append(emoji)
		history.save()
		
		// Use a placeholder sticker while we fetch the real one from the cache.
		let cache = StickerCache.cache
		
		// Fetch the sticker for the emoji from the cache.
		cache.sticker(for: emoji) { sticker in
			OperationQueue.main.addOperation {
				// If the cell is still showing the same emoji, update its sticker view.
				self.delegate?.buildEmojiViewController(self, didFinish: emoji)
			}
		}
	}
	
	// MARK:
	
	private func instantiateEmojiCategoriesController() -> UIViewController {
		// Instantiate a `EmojiCategoriesViewController` and present it.
		guard let controller = storyboard?.instantiateViewController(withIdentifier: EmojiCategoriesViewController.storyboardIdentifier) as? EmojiCategoriesViewController else { fatalError("Unable to instantiate a EmojiCategoriesViewController from the storyboard") }
		
		return controller
	}
}

// MARK: UIGestureRecognizerDelegate

extension BuildEmojiViewController: UIGestureRecognizerDelegate {
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	// MARK: Gesture Helpers
	
	func createTapGestureRecognizer(targetView: UIView) {
		let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		
		targetView.addGestureRecognizer(gesture)
	}
	
	func createDoubleTapGestureRecognizer(targetView: UIView) {
		let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
		gesture.numberOfTapsRequired = 2
		gesture.delegate = self
		
		targetView.addGestureRecognizer(gesture)
	}
	
	func createPanGestureRecognizer(targetView: UIView) {
		let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
		gesture.delegate = self
		
		targetView.addGestureRecognizer(gesture)
	}
	
	func createPinchGestureRecognizer(targetView: UIView) {
		let gesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
		gesture.delegate = self
		
		targetView.addGestureRecognizer(gesture)
	}
	
	func createRotateGestureRecognizer(targetView: UIView) {
		let gesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
		gesture.delegate = self
		
		targetView.addGestureRecognizer(gesture)
	}
	
	// MARK: Gesture Handlers
	
	func handleTap(recognizer: UITapGestureRecognizer) {
		guard let view = recognizer.view else { return }
		view.superview?.bringSubview(toFront: view)
	}
	
	func handleDoubleTap(recognizer: UITapGestureRecognizer) {
		guard let view = recognizer.view as? EmojiView else { return }
		
		UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .beginFromCurrentState, animations: {
			view.transform = .identity
			view.bounds.size = view.defaultSize
			}, completion: { _ in
				view.setNeedsImageUpdate()
		})
	}
	
	func handlePan(recognizer: UIPanGestureRecognizer) {
		guard let view = recognizer.view else { return }

		let translation = recognizer.translation(in: self.view)
		
		view.center = CGPoint(x:view.center.x + translation.x,
							  y:view.center.y + translation.y)
		
		recognizer.setTranslation(.zero, in: self.view)
				
		let isViewInsideCanvas = canvas.bounds.contains(view.center)
		
		switch recognizer.state {
		case .changed:
			view.alpha = isViewInsideCanvas ? 1.0 : 0.5
		default:
			if !isViewInsideCanvas {
				view.isUserInteractionEnabled = false
				
				UIView.animate(withDuration: 0.2, delay: 0.05, options: .curveEaseIn, animations: {
					view.transform = view.transform.scaleBy(x: 0.1, y: 0.1)
					view.alpha = 0
				}) { _ in
					view.removeFromSuperview()
				}
			}
		}
	}
	
	func handlePinch(recognizer: UIPinchGestureRecognizer) {
		guard let view = recognizer.view as? EmojiView else { return }

		// Prevent the emoji from growing too large
		let maximumSize: CGSize = CGSize(width: 900, height: 900)
		
		// If the view grows too large, the app will crash
		guard view.bounds.size.height <= maximumSize.height else {
			view.bounds.size = maximumSize
			return
		}
		
		view.bounds = view.bounds.apply(transform: CGAffineTransform(scaleX: recognizer.scale, y: recognizer.scale))
		
		recognizer.scale = 1
		
		// When the use stops pinching the view, render it again
		// so it always looks crispy
		if case .ended = recognizer.state {
			view.setNeedsImageUpdate()
		}
	}
	
	func handleRotate(recognizer: UIRotationGestureRecognizer) {
		guard let view = recognizer.view else { return }
		view.transform = view.transform.rotate(recognizer.rotation)
		recognizer.rotation = 0
	}
}
