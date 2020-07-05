//
// EmojiArt.swift
// EmojiArt
// 
// Created by Sebastian Penafiel on 7/5/20.
// Copyright © 2020 Sebastian Penafiel. All rights reserved.
//

import Foundation

struct EmojiArt {
  var backgroundURL: URL?
  var emojis = [Emoji]()

  struct Emoji: Identifiable {
    let text: String
    var x: Int // offset from the center
    var y: Int // offset from the center
    var size: Int
    let id: Int

    // fileprivate makes it private for anything outside the file
    // this will allow adding emojis to only be allowed within EmojiArt
    fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
      self.text = text
      self.x = x
      self.y = y
      self.size = size
      self.id = id
    }

  }

  private var uniqueEmojiId = 0

  mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
    uniqueEmojiId += 1
    emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
  }
}
