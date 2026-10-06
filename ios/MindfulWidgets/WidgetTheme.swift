//
//  WidgetTheme.swift
//  MindfulWidgets
//
//  The Android widgets' look (res/values/colors.xml, widget_*.xml
//  drawables) in SwiftUI, so both platforms' widgets read the same. See
//  SPEC.md Home and Lock Screen Widgets.
//

import SwiftUI

enum WidgetColors {
  /// GlassTheme.background. Opaque here: iOS widgets can't show the
  /// wallpaper through, unlike Android's 70% base.
  static let base = Color(red: 0x12 / 255, green: 0x13 / 255, blue: 0x12 / 255)
  static let glowTeal = Color(red: 0x14 / 255, green: 0xE6 / 255, blue: 0xAA / 255).opacity(0.18)
  static let glowBlue = Color(red: 0x37 / 255, green: 0x8A / 255, blue: 0xDD / 255).opacity(0.18)
  static let frost = Color.white.opacity(0.06)
  static let sheen = Color.white.opacity(0.08)
  static let border = Color.white.opacity(0.12)
  static let divider = Color.white.opacity(0.10)
  static let textPrimary = Color.white
  static let textSecondary = Color.white.opacity(0.60)
  static let textFooter = Color.white.opacity(0.35)
  static let pencil = Color.white.opacity(0.70)
  static let buttonBackground = Color.white.opacity(0.10)
  static let buttonBorder = Color.white.opacity(0.15)
  static let taskTodoStroke = Color.white.opacity(0.30)
  /// habitAccent.
  static let habit = Color(red: 0xA7 / 255, green: 0x8B / 255, blue: 0xFA / 255)
  /// taskAccent.
  static let task = Color(red: 0x60 / 255, green: 0xA5 / 255, blue: 0xFA / 255)
}

/// widget_glass_background.xml: dark base, teal glow top-right, blue glow
/// bottom-left (BlobBackground), 6% frost, top sheen, 12% hairline.
struct GlassWidgetBackground: View {
  var body: some View {
    ZStack {
      WidgetColors.base
      RadialGradient(
        colors: [WidgetColors.glowTeal, .clear],
        center: UnitPoint(x: 0.95, y: 0), startRadius: 0, endRadius: 160)
      RadialGradient(
        colors: [WidgetColors.glowBlue, .clear],
        center: .bottomLeading, startRadius: 0, endRadius: 140)
      WidgetColors.frost
      LinearGradient(
        colors: [WidgetColors.sheen, .clear, .clear], startPoint: .top, endPoint: .bottom)
      ContainerRelativeShape().strokeBorder(WidgetColors.border, lineWidth: 0.5)
    }
  }
}
