//
//  UILabel.swift
//  Budget Tracker
//
//  Created by Misha Dovhiy on 21.10.2023.
//  Copyright © 2023 Misha Dovhiy. All rights reserved.
//

import UIKit

extension UILabel {
    func linkPressed(at touches: Set<UITouch>) -> URL? {
        guard let attributedText = attributedText, attributedText.length > 0 else { return nil }
        guard let touchLocation = touches.sorted(by: { $0.timestamp < $1.timestamp } ).last?.location(in: self) else { return nil }
        guard let textStorage = preparedTextStorage() else { return nil }
        let layoutManager = textStorage.layoutManagers[0]
        let textContainer = layoutManager.textContainers[0]
        let characterIndex = layoutManager.characterIndex(for: touchLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        guard characterIndex >= 0, characterIndex != NSNotFound else { return nil }
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: characterIndex, length: 1), actualCharacterRange: nil)
        let characterRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        guard characterRect.contains(touchLocation) else { return nil }
        if let url = textStorage.attribute(.link, at: characterIndex, effectiveRange: nil) as? URL {
            return url
        }
        return textStorage.attribute(.link, at: characterIndex, effectiveRange: nil) as? URL
    }
    
    private func preparedTextStorage() -> NSTextStorage? {
        guard let attributedText = attributedText, attributedText.length > 0 else { return nil }
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0
        let textStorage = NSTextStorage(string: "")
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.size = self.textRect(forBounds: bounds, limitedToNumberOfLines: self.numberOfLines).size
        textStorage.setAttributedString(attributedText)
        return textStorage
    }
}
