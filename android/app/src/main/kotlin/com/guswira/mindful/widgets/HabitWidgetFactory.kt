package com.guswira.mindful.widgets

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.guswira.mindful.R
import org.json.JSONArray

/** One habit row's worth of the `habits` JSON `widget_service.dart` saves. */
private data class HabitEntry(
    val id: String,
    val name: String,
    val icon: String,
    val actions: List<String>,
    val isCompleted: Boolean,
)

/**
 * Renders one row per habit for the medium widget's habits list — a name
 * and icon, plus either a checkmark (done) or up to 2 action pills. Tapping
 * a pill opens the app and logs that action (`navigateFromWidgetUri` on the
 * Dart side does the logging); a habit with no actions has no pill to tap,
 * so tapping its row opens the app to that habit's detail screen instead.
 * See SPEC.md Home and Lock Screen Widgets.
 */
class HabitWidgetFactory(
    private val context: Context,
    intent: Intent,
) : RemoteViewsService.RemoteViewsFactory {
  private val habitsJson = intent.getStringExtra("habitsJson") ?: "[]"
  private var habits: List<HabitEntry> = emptyList()

  override fun onCreate() {}

  override fun onDataSetChanged() {
    habits = parseHabits(habitsJson)
  }

  override fun onDestroy() {}

  override fun getCount(): Int = habits.size

  override fun getViewAt(position: Int): RemoteViews {
    val habit = habits[position]
    val views = RemoteViews(context.packageName, R.layout.widget_habit_row)
    views.setTextViewText(R.id.habit_icon, habit.icon)
    views.setTextViewText(R.id.habit_name, habit.name)
    views.removeAllViews(R.id.action_buttons)

    if (habit.actions.isEmpty()) {
      // No custom actions to log from a pill — tapping the row instead
      // opens the habit's own detail screen, same as a task row does.
      val fillInIntent =
          Intent().apply {
            data = Uri.parse("mindful://open-habit?habitId=${habit.id}")
          }
      views.setOnClickFillInIntent(R.id.habit_row_root, fillInIntent)
    }

    if (habit.isCompleted) {
      views.setViewVisibility(R.id.habit_check, View.VISIBLE)
    } else {
      views.setViewVisibility(R.id.habit_check, View.GONE)
      for (action in habit.actions.take(2)) {
        val pill = RemoteViews(context.packageName, R.layout.widget_action_pill)
        pill.setTextViewText(R.id.pill_label, action)
        // A view inside a RemoteViewsService-backed list can't use
        // setOnClickPendingIntent (silently ignored) — only a fill-in
        // intent merged into the ListView's PendingIntentTemplate, set
        // once in MindfulMediumWidget.
        val fillInIntent =
            Intent().apply {
              data =
                  Uri.parse(
                      "mindful://log-habit?habitId=${habit.id}&action_label=$action",
                  )
            }
        pill.setOnClickFillInIntent(R.id.pill_label, fillInIntent)
        views.addView(R.id.action_buttons, pill)
      }
    }
    return views
  }

  override fun getLoadingView(): RemoteViews? = null

  override fun getViewTypeCount(): Int = 1

  override fun getItemId(position: Int): Long = position.toLong()

  override fun hasStableIds(): Boolean = true

  private fun parseHabits(json: String): List<HabitEntry> {
    val array = JSONArray(json)
    return (0 until array.length()).map { i ->
      val obj = array.getJSONObject(i)
      val actionsArray = obj.optJSONArray("actions")
      val actions =
          if (actionsArray == null) {
            emptyList()
          } else {
            (0 until actionsArray.length()).map { actionsArray.getString(it) }
          }
      HabitEntry(
          id = obj.getString("id"),
          name = obj.getString("name"),
          icon = obj.getString("icon"),
          actions = actions,
          isCompleted = obj.optBoolean("isCompleted", false),
      )
    }
  }
}
