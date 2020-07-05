//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Sebastian Penafiel on 7/5/20.
//  Copyright © 2020 Sebastian Penafiel. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
  @ObservedObject var document: EmojiArtDocument

  var body: some View {
    VStack {
      ScrollView(.horizontal) {
        HStack {
          // \.self -> the \. means a keypath which specifies,
          // a var in another object
          ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self ) { emoji in
            Text(emoji)
                .font(Font.system(size: self.DEFAULT_EMOJI_SIZE))
                // makes the emoji draggable
                .onDrag { NSItemProvider(object: emoji as NSString) }
          }
        }
      }
          .padding(.horizontal)
      // Using the Rectangle overlay, makes it behave as a Shape, which resizes the image
      // to fill the Rectangle Container
      // replaced `Rectangle` with `Color.white` because Color can also be a View
      GeometryReader { geometry in
        ZStack {
          Color.white.overlay(
                  // overlay takes a View, not a closure, thats why its wrapped in Group
                  Group {
                    if self.document.backgroundImage != nil {
                      Image(uiImage: self.document.backgroundImage!)
                    }
                  }
              )
              .edgesIgnoringSafeArea([.horizontal, .bottom])
              // onDrop -> DragAndDrop
              // public.image tells the UI that what Im dropping is an image, it will do magic to take it
              // providers, provide the info that is being dropped, happens async
              // location is where its being dropped
              // location -> is in the global coordinate system, not in its container
              .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                var location = geometry.convert(location, from: .global)
                location = CGPoint(x: location.x - geometry.size.width / 2, y: location.y - geometry.size.height / 2)
                return self.drop(providers: providers, at: location)
              }
          ForEach(self.document.emojis) { emoji in
            Text(emoji.text)
              .font(self.font(for: emoji))
              .position(self.position(for: emoji, in: geometry.size))
          }
        }
      }
    }
  }

  private func font(for emoji: EmojiArt.Emoji) -> Font {
    Font.system(size: emoji.fontSize)
  }

  private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
    CGPoint(x: emoji.location.x + size.width / 2, y: emoji.location.y + size.height / 2)
  }

  private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
    // URL.self is the actual type URL
    var found = providers.loadFirstObject(ofType: URL.self) { url in
      print("dropped \(url)")
      self.document.setBackgroundURL(url)
    }
    if !found {
      // for emoji text
      found = providers.loadObjects(ofType: String.self) { string in
        self.document.addEmoji(string, at: location, size: self.DEFAULT_EMOJI_SIZE)
      }
    }
    return found
  }

  private let DEFAULT_EMOJI_SIZE: CGFloat = 40

}
