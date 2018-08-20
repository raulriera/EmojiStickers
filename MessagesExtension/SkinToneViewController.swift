//
//  SkinToneViewController.swift
//  EmojiStickers
//
//  Created by Raul Riera on 19/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

class SkinToneViewController: UIViewController {
	typealias onSelectedHandler = (Int) -> ()
	
	@IBOutlet private var skinToneButtons: [UIButton]! {
		didSet {
			// Prevent the buttons from being horribly streched
			// I wish Storyboards would allow me to do this
			_ = skinToneButtons.map {
				$0.imageView?.contentMode = .scaleAspectFit
			}
		}
	}
	
	private let skinTones = ["", "1f3fb", "1f3fc", "1f3fd", "1f3fe", "1f3ff"] // FIXME: Make this better
	private let skinToneHistory = SkinToneCache.load()
	var selectedSkinTone: Int = 0 {
		didSet {
			skinToneHistory.save(tone: selectedSkinTone)
			onSelected?(selectedSkinTone)
		}
	}
	var onSelected: onSelectedHandler? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		preferredContentSize = CGSize(width: 300, height: 64)
		
		for (index, _) in skinTones.enumerated() {
			if index == skinToneHistory.tone {
				skinToneButtons[index].transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
				return
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		UIImpactFeedbackGenerator(style: .medium).impactOccurred()
	}
	
	@IBAction func didTapSkinButton(sender: UIButton) {
		for (index, button) in skinToneButtons.enumerated() {
			if button == sender {
				selectedSkinTone = index
				return
			}
		}
	}
}
