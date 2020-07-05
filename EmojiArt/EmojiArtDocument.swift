//
// EmojiArtDocument.swift
// EmojiArt
// 
// Created by Sebastian Penafiel on 7/5/20.
// Copyright © 2020 Sebastian Penafiel. All rights reserved.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
  static let palette: String = "😖😋😳😞🥶😇"

  @Published private var emojiArt: EmojiArt = EmojiArt()

  @Published private(set) var backgroundImage: UIImage?

  var emojis: [EmojiArt.Emoji] { emojiArt.emojis }

  // MARK: - Intent(s)

  func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
    emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
  }

  func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
    if let index = emojiArt.emojis.firstIndex(matching: emoji) {
      emojiArt.emojis[index].x += Int(offset.width)
      emojiArt.emojis[index].y += Int(offset.height)
    }
  }

  func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
    if let index = emojiArt.emojis.firstIndex(matching: emoji) {
      emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
    }
  }

  func setBackgroundURL(_ url: URL?) {
    emojiArt.backgroundURL = url?.imageURL
    fetchBackgroundImageData()
  }

  private func fetchBackgroundImageData() {
    // clear it first to show Im doing something
    backgroundImage = nil
    if let url = self.emojiArt.backgroundURL {
      // this should be done with URLSessions which abstracts all of this
      // calling Data without dispatch, will freeze the UI
      // because it'll use the main thread
      // this uses the global thread, and .userInitiated is the priority
      DispatchQueue.global(qos: .userInitiated).async {
        if let imageData = try? Data(contentsOf: url) {
          // UI updates must ALWAYS happen in the main thread
          // if I just leave this without it, the change will call the @Published event
          // for re-drawing the UI, but because its in .global, weird stuff can happen
          // ALWAYS updates to UI must happen on .main
          DispatchQueue.main.async {
            // why this condition?
            // because multiple images could have been queued and they might arrive at different times
            // so it makes sure only the latest one gets set
            if url == self.emojiArt.backgroundURL {
              self.backgroundImage = UIImage(data: imageData)
            }
          }
        }
      }
    }
  }
}

extension EmojiArt.Emoji {
  var fontSize: CGFloat { CGFloat(self.size) }
  var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
