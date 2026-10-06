package com.guswira.mindful.widgets

import android.graphics.Color
import com.guswira.mindful.R

/**
 * Routines store their icon as one of the app's 20 preset emoji
 * (`habits.icon`); the widgets draw the same flat Material icon the app does
 * (habit_icon.dart) instead. Keyed without U+FE0F, which some keyboards add
 * and others don't. A non-preset emoji has no entry and is drawn as text.
 * See SPEC.md UI conventions.
 */
private val routineIcons: Map<String, Int> =
    mapOf(
        "💪" to R.drawable.ic_routine_sports_gymnastics,
        "🏃" to R.drawable.ic_routine_directions_run,
        "📚" to R.drawable.ic_routine_menu_book,
        "🧘" to R.drawable.ic_routine_self_improvement,
        "💧" to R.drawable.ic_routine_water_drop,
        "🥗" to R.drawable.ic_routine_restaurant,
        "😴" to R.drawable.ic_routine_bedtime,
        "🎯" to R.drawable.ic_routine_track_changes,
        "✍" to R.drawable.ic_routine_edit,
        "🎵" to R.drawable.ic_routine_music_note,
        "🌿" to R.drawable.ic_routine_spa,
        "🧹" to R.drawable.ic_routine_cleaning_services,
        "💊" to R.drawable.ic_routine_medication,
        "🛁" to R.drawable.ic_routine_bathtub,
        "🌅" to R.drawable.ic_routine_wb_twilight,
        "🏋" to R.drawable.ic_routine_fitness_center,
        "🚴" to R.drawable.ic_routine_directions_bike,
        "🧠" to R.drawable.ic_routine_psychology,
        "❤" to R.drawable.ic_routine_favorite_border,
        "⭐" to R.drawable.ic_routine_star_outline,
    )

/** The drawable for a stored routine [emoji], or null outside the presets. */
fun routineIconRes(emoji: String): Int? = routineIcons[emoji.replace("\uFE0F", "")]

/** A routine's `#RRGGBB` color, or [fallback] (habitAccent) if it won't parse. */
fun routineColor(hex: String?, fallback: Int): Int =
    try {
      if (hex.isNullOrEmpty()) fallback else Color.parseColor(hex)
    } catch (e: IllegalArgumentException) {
      fallback
    }
