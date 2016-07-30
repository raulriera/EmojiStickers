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

    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
		// Present the view controller for the appropriate presentation style.
		presentViewController(for: presentationStyle)
    }
    
    // MARK: MSMessagesAppViewController

	override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
		super.didTransition(to: presentationStyle)
		presentViewController(for: presentationStyle)
	}
    
    // MARK: Private
    
    private func presentViewController(for presentationStyle: MSMessagesAppPresentationStyle) {
        // Determine the controller to present.
        let controller: UIViewController
        if presentationStyle == .compact {
            // Show a list of previously created emojis.
            controller = instantiateStickersController()
        } else {
            controller = instantiateBuildEmojiController()
        }
        
        // Remove any existing child controllers.
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        // Embed the new controller.
        addChildViewController(controller)
        
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
		/*
		The user tapped the save button and has finished creating the sticker.
		Change the presentation style to `.compact`.
		*/
		requestPresentationStyle(.compact)
    }
}

// MARK: EmojisViewControllerDelegate

extension MessagesViewController: StickersViewControllerDelegate {
    func stickersViewControllerDidSelectCreate(_ controller: StickersViewController) {
        /*
         The user tapped the create icon to start creating a new sticker.
         Change the presentation style to `.expanded`.
         */
        requestPresentationStyle(.expanded)
    }
}
