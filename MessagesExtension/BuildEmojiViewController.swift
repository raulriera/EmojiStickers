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
			canvas.superview?.layer.borderColor = UIColor.lightGray.cgColor
			canvas.superview?.layer.cornerRadius = 4.0

			let singleTap = createTapGestureRecognizer(targetView: canvas)
			let doubleTap = createDoubleTapGestureRecognizer(targetView: canvas)

			singleTap.require(toFail: doubleTap)
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
		
		controller.selectEmojiHandler = handleEmojiSelection
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
	
	// MARK: Private
	
	private func instantiateEmojiCategoriesController() -> UIViewController {
		// Instantiate a `EmojiCategoriesViewController` and present it.
		guard let controller = storyboard?.instantiateViewController(withIdentifier: EmojiCategoriesViewController.storyboardIdentifier) as? EmojiCategoriesViewController else { fatalError("Unable to instantiate a EmojiCategoriesViewController from the storyboard") }
		
		return controller
	}

	private func handleEmojiSelection(emoji: String, categoryIndex: Int, selectionRect: CGRect) -> () {
		lastUsedCategory = categoryIndex
		let emojiView = EmojiView(character: emoji)

		// Convert the point to the canvas coordinates, while
		// also inseting the point because it appears it won't take into
		// consideration the navigation bar
		emojiView.frame = emojiView.convert(selectionRect, to: canvas)
		emojiView.frame.origin = emojiView.frame.origin.insetBy(dx: 0, dy: view.frame.origin.y)
		canvas.addSubview(emojiView)

		UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
			emojiView.center = self.canvas.convert(self.canvas.center, to: self.canvas.superview)
			}, completion: { _ in

				UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .beginFromCurrentState, animations: {
						emojiView.bounds.size = emojiView.defaultSize
				}, completion: nil)
			})

		createRotateGestureRecognizer(targetView: emojiView)
		createPinchGestureRecognizer(targetView: emojiView)
		createPanGestureRecognizer(targetView: emojiView)
		createLongTapGestureRecognizer(targetView: emojiView)

		// Remove any existing child controllers.
		removeChildViewControllers()
	}
}

// MARK: UIGestureRecognizerDelegate

extension BuildEmojiViewController: UIGestureRecognizerDelegate {
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	// MARK: Gesture Helpers
	
	func createTapGestureRecognizer(targetView: UIView) -> UITapGestureRecognizer {
		let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		targetView.addGestureRecognizer(gesture)
		return gesture
	}
	
	func createDoubleTapGestureRecognizer(targetView: UIView) -> UITapGestureRecognizer {
		let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
		gesture.numberOfTapsRequired = 2
		gesture.delegate = self
		
		targetView.addGestureRecognizer(gesture)
		return gesture
	}

	func createLongTapGestureRecognizer(targetView: UIView) {
		// Don't include this gesture in the delegate, we don't want it
		// to run simultaneously with any other gesture
		let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap))
		targetView.addGestureRecognizer(gesture)
	}
	
	func createPanGestureRecognizer(targetView: UIView) {
		// Don't include this gesture in the delegate, we don't want it
		// to run simultaneously with any other gesture
		let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
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
		guard let _ = recognizer.view else { return }

		// Bring the emoji at the bottom to the top,
		// this way we can cycle through all of them by just tapping
		if let bottomView = canvas.subviews.first {
			bottomView.superview?.bringSubview(toFront: bottomView)
		}
	}
	
	func handleDoubleTap(recognizer: UITapGestureRecognizer) {
		let point = recognizer.location(in: canvas)
		guard let view = canvas.hitTest(point, with: nil) as? EmojiView else { return }

		UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .beginFromCurrentState, animations: {
			view.transform = .identity
			view.bounds.size = view.defaultSize
			}, completion: { _ in
				view.setNeedsImageUpdate()
		})
	}

	func handleLongTap(recognizer: UILongPressGestureRecognizer) {
		guard let view = recognizer.view else { return }

		if case .began = recognizer.state {
			let flip = CGAffineTransform(scaleX: -1, y: 1)
			view.isUserInteractionEnabled = false

			UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .beginFromCurrentState, animations: {
				view.transform = view.transform.concatenating(flip)
				}, completion: { _ in
					view.isUserInteractionEnabled = true
			})
		}
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
					view.transform = view.transform.scaledBy(x: 0.1, y: 0.1)
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
		
		view.bounds = view.bounds.applying(CGAffineTransform(scaleX: recognizer.scale, y: recognizer.scale))
		
		recognizer.scale = 1
		
		// When the use stops pinching the view, render it again
		// so it always looks crispy
		if case .ended = recognizer.state {
			view.setNeedsImageUpdate()
		}
	}
	
	func handleRotate(recognizer: UIRotationGestureRecognizer) {
		guard let view = recognizer.view else { return }
		view.transform = view.transform.rotated(by: recognizer.rotation)
		recognizer.rotation = 0
	}
}
