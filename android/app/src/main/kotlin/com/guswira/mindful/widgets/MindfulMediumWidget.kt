package com.guswira.mindful.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import com.guswira.mindful.MainActivity
import com.guswira.mindful.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Medium (4x2) home screen widget: today's habits and today's/overdue tasks
 * side by side, each its own scrollable list, plus a pencil button that
 * opens the app's write sheet. When there are no tasks due today, the
 * tasks column is hidden and habits fills the full width instead. Data is
 * written by `widget_service.dart`. See SPEC.md Home and Lock Screen
 * Widgets.
 */
class MindfulMediumWidget : AppWidgetProvider() {
  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
  ) {
    for (widgetId in appWidgetIds) {
      updateWidget(context, appWidgetManager, widgetId)
    }
  }

  companion object {
    fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
    ) {
      val views = RemoteViews(context.packageName, R.layout.mindful_medium_widget)

      // `home_widget`'s Flutter side saves data via `HomeWidgetPlugin`, which
      // persists it to its own "HomeWidgetPreferences" file with no key
      // prefix — not "FlutterSharedPreferences"/"flutter." (that's the
      // separate `shared_preferences` plugin's convention).
      val prefs = HomeWidgetPlugin.getData(context)

      val habitsJson = prefs.getString("habits", "[]") ?: "[]"
      val tasksJson = prefs.getString("tasks", "[]") ?: "[]"
      val habitsDone = prefs.getInt("habitsDone", 0)
      val habitsTotal = prefs.getInt("habitsTotal", 0)
      val tasksDone = prefs.getInt("tasksDone", 0)
      val tasksTotal = prefs.getInt("tasksTotal", 0)

      // Labels are pushed by widget_service.dart in the app's language;
      // the English fallbacks only show before the app's first write.
      views.setTextViewText(R.id.habits_label, prefs.getString("labelHabits", null) ?: "Routines")
      views.setTextViewText(R.id.tasks_label, prefs.getString("labelTasks", null) ?: "Todo")
      views.setTextViewText(
          R.id.habits_count,
          prefs.getString("labelHabitsCount", null) ?: "$habitsDone/$habitsTotal done",
      )
      views.setTextViewText(
          R.id.tasks_count,
          prefs.getString("labelTasksCount", null) ?: "$tasksDone/$tasksTotal done",
      )

      // No tasks due today — hide the tasks column and its divider so
      // habits_column (the other weighted child in that Row) fills the
      // full width instead of sitting next to empty space.
      val tasksColumnVisibility = if (tasksTotal > 0) View.VISIBLE else View.GONE
      views.setViewVisibility(R.id.tasks_column, tasksColumnVisibility)
      views.setViewVisibility(R.id.columns_divider, tasksColumnVisibility)

      // The habits/tasks JSON rides along as an Intent extra, but
      // RemoteViewsService intents are otherwise cached by the system — a
      // unique `data` URI on every call is what forces `onDataSetChanged`
      // to actually pick up new data instead of showing stale rows.
      val habitsIntent = Intent(context, HabitWidgetService::class.java)
      habitsIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
      habitsIntent.putExtra("habitsJson", habitsJson)
      habitsIntent.data =
          Uri.parse("widget://habits/$widgetId/${System.currentTimeMillis()}")
      views.setRemoteAdapter(R.id.habits_list, habitsIntent)

      val tasksIntent = Intent(context, TaskWidgetService::class.java)
      tasksIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
      tasksIntent.putExtra("tasksJson", tasksJson)
      tasksIntent.data =
          Uri.parse("widget://tasks/$widgetId/${System.currentTimeMillis()}")
      views.setRemoteAdapter(R.id.tasks_list, tasksIntent)

      // Rows inside a RemoteViewsService-backed list (both lists here)
      // can't use setOnClickPendingIntent — the system silently ignores it.
      // They need a mutable PendingIntentTemplate on the list itself, into
      // which each row's setOnClickFillInIntent (see HabitWidgetFactory /
      // TaskWidgetFactory) gets merged at click time. HomeWidgetLaunchIntent
      // always builds an immutable one, so these are built by hand instead.
      views.setPendingIntentTemplate(
          R.id.habits_list,
          launchTemplatePendingIntent(context, requestCode = 1),
      )
      views.setPendingIntentTemplate(
          R.id.tasks_list,
          launchTemplatePendingIntent(context, requestCode = 2),
      )

      val writeIntent =
          HomeWidgetLaunchIntent.getActivity(
              context,
              MainActivity::class.java,
              Uri.parse("mindful://open-write-sheet"),
          )
      views.setOnClickPendingIntent(R.id.pencil_btn, writeIntent)

      appWidgetManager.updateAppWidget(widgetId, views)
      appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.habits_list)
      appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.tasks_list)
    }
  }
}
