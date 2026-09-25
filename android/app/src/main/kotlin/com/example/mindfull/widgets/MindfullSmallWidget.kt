package com.example.mindfull.widgets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import com.example.mindfull.R
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Small (2x2) home screen widget: a chooser on first add, then either
 * today's tasks or today's habits — whichever the user picked — reusing
 * [TaskWidgetService]/[HabitWidgetService] from the medium widget. Data is
 * written by `widget_service.dart`. See SPEC.md Home and Lock Screen
 * Widgets.
 */
class MindfullSmallWidget : AppWidgetProvider() {
  companion object {
    const val ACTION_CHOOSE_MODE = "com.example.mindfull.widgets.ACTION_CHOOSE_MODE"
    const val EXTRA_MODE = "mode"
    private const val REQUEST_CODE_CHOOSE_TASKS = 101
    private const val REQUEST_CODE_CHOOSE_HABITS = 102

    fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
    ) {
      // `home_widget`'s Flutter side saves data via `HomeWidgetPlugin`, which
      // persists it to its own "HomeWidgetPreferences" file with no key
      // prefix — not "FlutterSharedPreferences"/"flutter." (that's the
      // separate `shared_preferences` plugin's convention).
      val prefs = HomeWidgetPlugin.getData(context)
      val mode = prefs.getString("smallWidgetMode", null)

      if (mode.isNullOrEmpty()) {
        showChooser(context, appWidgetManager, widgetId)
      } else {
        showList(context, appWidgetManager, widgetId, mode, prefs)
      }
    }

    private fun showChooser(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
    ) {
      val views = RemoteViews(context.packageName, R.layout.mindfull_small_widget_choose)
      // Labels are pushed by widget_service.dart in the app's language;
      // the layout's English text is only a first-launch fallback.
      val prefs = HomeWidgetPlugin.getData(context)
      views.setTextViewText(R.id.choose_title, prefs.getString("labelShowMe", null) ?: "Show me:")
      views.setTextViewText(
          R.id.choose_tasks, prefs.getString("labelChooseTasks", null) ?: "✅ Todo")
      views.setTextViewText(
          R.id.choose_habits, prefs.getString("labelChooseHabits", null) ?: "💪 Routines")
      views.setOnClickPendingIntent(
          R.id.choose_tasks,
          chooseModePendingIntent(context, "tasks", REQUEST_CODE_CHOOSE_TASKS),
      )
      views.setOnClickPendingIntent(
          R.id.choose_habits,
          chooseModePendingIntent(context, "habits", REQUEST_CODE_CHOOSE_HABITS),
      )
      appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun chooseModePendingIntent(
        context: Context,
        mode: String,
        requestCode: Int,
    ): PendingIntent {
      val intent =
          Intent(context, MindfullSmallWidget::class.java).apply {
            action = ACTION_CHOOSE_MODE
            putExtra(EXTRA_MODE, mode)
          }
      return PendingIntent.getBroadcast(
          context,
          requestCode,
          intent,
          PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
      )
    }

    private fun showList(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        mode: String,
        prefs: SharedPreferences,
    ) {
      val isTasks = mode == "tasks"
      val views = RemoteViews(context.packageName, R.layout.mindfull_small_widget)

      views.setTextViewText(
          R.id.small_title,
          if (isTasks) prefs.getString("labelTasks", null) ?: "Todo"
          else prefs.getString("labelHabits", null) ?: "Routines",
      )
      val accentColorRes = if (isTasks) R.color.widget_task_accent else R.color.widget_habit_accent
      views.setTextColor(R.id.small_count, ContextCompat.getColor(context, accentColorRes))

      val done = prefs.getInt(if (isTasks) "tasksDone" else "habitsDone", 0)
      val total = prefs.getInt(if (isTasks) "tasksTotal" else "habitsTotal", 0)
      views.setTextViewText(R.id.small_count, "$done/$total")
      views.setTextViewText(
          R.id.small_footer,
          prefs.getString(if (isTasks) "labelTasksRemaining" else "labelHabitsRemaining", null)
              ?: "${total - done} remaining",
      )

      val listIntent =
          if (isTasks) {
            Intent(context, TaskWidgetService::class.java).apply {
              putExtra("tasksJson", prefs.getString("tasks", "[]") ?: "[]")
            }
          } else {
            Intent(context, HabitWidgetService::class.java).apply {
              putExtra("habitsJson", prefs.getString("habits", "[]") ?: "[]")
            }
          }
      listIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
      listIntent.data =
          Uri.parse("widget://small/$mode/$widgetId/${System.currentTimeMillis()}")
      views.setRemoteAdapter(R.id.small_list, listIntent)

      // Rows inside a RemoteViewsService-backed list can't use
      // setOnClickPendingIntent — see launchTemplatePendingIntent's doc.
      views.setPendingIntentTemplate(
          R.id.small_list,
          launchTemplatePendingIntent(context, requestCode = 3),
      )

      appWidgetManager.updateAppWidget(widgetId, views)
      appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.small_list)
    }
  }

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
  ) {
    for (widgetId in appWidgetIds) {
      updateWidget(context, appWidgetManager, widgetId)
    }
  }

  override fun onReceive(context: Context, intent: Intent) {
    super.onReceive(context, intent)
    if (intent.action != ACTION_CHOOSE_MODE) {
      return
    }
    val mode = intent.getStringExtra(EXTRA_MODE) ?: return

    HomeWidgetPlugin.getData(context).edit().putString("smallWidgetMode", mode).apply()

    val appWidgetManager = AppWidgetManager.getInstance(context)
    val widgetIds =
        appWidgetManager.getAppWidgetIds(ComponentName(context, MindfullSmallWidget::class.java))
    for (widgetId in widgetIds) {
      updateWidget(context, appWidgetManager, widgetId)
    }
  }
}
