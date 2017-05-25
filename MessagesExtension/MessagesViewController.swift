//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Raúl Riera on 18/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {

	var state: State = .browsing {
		didSet {
			if case .browsing = state {
				requestPresentationStyle(.compact)
				presentViewController(for: .compact)
			} else {
				requestPresentationStyle(.expanded)
				presentViewController(for: .expanded)
			}
		}
	}

	enum State {
		case browsing
		case creating
	}

    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
		// Present the view controller for the appropriate presentation style.
		presentViewController(for: presentationStyle)

		// Run this code only once per "Emoji assets update"
		if !UserDefaults.standard.bool(forKey: "SwitchToTwitterEmoji2.3") {
			ImageCache.cache.clear()
			SkinToneCache.load().clear()
			EmojiCategoryOffsetCache.load().clear()
			RecentEmojiCache.load().clear()

			UserDefaults.standard.set(true, forKey: "SwitchToTwitterEmoji2.3")
		}
    }
    
    // MARK: MSMessagesAppViewController

	override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
		super.didTransition(to: presentationStyle)

		// If the state is "creating an emoji" but the presentation is "compact"
		// then switch to "browsing emojis" because the creating state doesn't fit
		if case .creating = state, presentationStyle == .compact {
			state = .browsing
		}
	}
    
    // MARK: Private
    
    private func presentViewController(for presentationStyle: MSMessagesAppPresentationStyle) {
        // Determine the controller to present.
        let controller: UIViewController
        if case .browsing = state {
            // Show a list of previously created emojis.
            controller = instantiateStickersController()
        } else {
            controller = instantiateBuildEmojiController()
        }
        
        // Remove any existing child controllers.
        for child in childViewControllers {
			UIView.animate(withDuration: 0.25, animations: { 
				child.view.alpha = 0

			}, completion: { _ in
				child.willMove(toParentViewController: nil)
				child.view.removeFromSuperview()
				child.removeFromParentViewController()
			})
        }
        
        // Embed the new controller.
        addChildViewController(controller)

		controller.view.alpha = 0
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
		
		// Attach the controller to the very bottom only if it's the compact style
		// this one seems to already take into account the input field.
		if presentationStyle == .compact {
			controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		} else {
			controller.view.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor).isActive = true
		}

        controller.didMove(toParentViewController: self)

		UIView.animate(withDuration: 0.25) {
			controller.view.alpha = 1
		}
    }
    
    private func instantiateBuildEmojiController() -> UIViewController {
        // Instantiate a `BuildEmojiViewController` and present it.
        guard let controller = storyboard?.instantiateViewController(withIdentifier: BuildEmojiViewController.storyboardIdentifier) as? BuildEmojiViewController else { fatalError("Unable to instantiate a BuildEmojiViewController from the storyboard") }
        
        controller.delegate = self
        
        return controller
    }
    
    private func instantiateStickersController() -> UIViewController {
        // Instantiate a `IceCreamsViewController` and present it.
        guard let controller = storyboard?.instantiateViewController(withIdentifier: StickersViewController.storyboardIdentifier) as? StickersViewController else { fatalError("Unable to instantiate an StickersViewController from the storyboard") }
        
        controller.delegate = self
        
        return controller
    }
}

// MARK: BuildEmojiViewControllerDelegate

extension MessagesViewController: BuildEmojiViewControllerDelegate {
    func buildEmojiViewController(_ controller: BuildEmojiViewController, didFinish emoji: Emoji) {
		state = .browsing
    }
}

// MARK: EmojisViewControllerDelegate

extension MessagesViewController: StickersViewControllerDelegate {
    func stickersViewControllerDidSelectCreate(_ controller: StickersViewController) {
		state = .creating
    }
}
