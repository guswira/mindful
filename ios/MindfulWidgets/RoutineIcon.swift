//
//  RoutineIcon.swift
//  MindfulWidgets
//
//  Routines store their icon as one of the app's 20 preset emoji
//  (`habits.icon`); the widgets draw the matching SF Symbol instead, like
//  the app draws a flat Material icon (habit_icon.dart). A non-preset
//  emoji is drawn as-is. See SPEC.md UI conventions.
//

import SwiftUI

/// Preset emoji → SF Symbol, keyed without U+FE0F (see `routineSymbol`).
private let routineSymbols: [String: String] = [
  "💪": "figure.strengthtraining.functional",
  "🏃": "figure.run",
  "📚": "book",
  "🧘": "figure.mind.and.body",
  "💧": "drop",
  "🥗": "fork.knife",
  "😴": "bed.double",
  "🎯": "target",
  "✍": "pencil",
  "🎵": "music.note",
  "🌿": "leaf",
  "🧹": "bubbles.and.sparkles",
  "💊": "pills",
  "🛁": "bathtub",
  "🌅": "sunrise",
  "🏋": "dumbbell",
  "🚴": "bicycle",
  "🧠": "brain.head.profile",
  "❤": "heart",
  "⭐": "star",
]

/// The SF Symbol for a stored routine emoji, or nil outside the presets.
/// Ignores U+FE0F, which some keyboards add and others don't.
func routineSymbol(for emoji: String) -> String? {
  routineSymbols[emoji.replacingOccurrences(of: "\u{FE0F}", with: "")]
}

/// `#RRGGBB` (a routine's `color`) as a Color, or nil if it won't parse.
func routineColor(_ hex: String?) -> Color? {
  guard let hex, hex.hasPrefix("#"), hex.count == 7,
    let value = UInt32(hex.dropFirst(), radix: 16)
  else { return nil }
  return Color(
    red: Double((value >> 16) & 0xFF) / 255,
    green: Double((value >> 8) & 0xFF) / 255,
    blue: Double(value & 0xFF) / 255)
}

/// A routine's icon: its SF Symbol, or the stored emoji when there's no
/// match. Color comes from the surrounding `foregroundStyle` — lock screen
/// widgets render monochrome, the home widget tints it per routine.
struct RoutineIcon: View {
  let icon: String
  var size: CGFloat = 16

  var body: some View {
    if let symbol = routineSymbol(for: icon) {
      Image(systemName: symbol).font(.system(size: size, weight: .medium))
    } else {
      Text(icon).font(.system(size: size))
    }
  }
}
