package com.guswira.mindful.widgets

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.guswira.mindful.R
import org.json.JSONArray

/** One task row's worth of the `tasks` JSON `widget_service.dart` saves. */
private data class TaskEntry(val id: String, val name: String, val isCompleted: Boolean)

/**
 * Renders one row per today-or-overdue task for the medium widget's tasks
 * list — a checkbox glyph and name, strikethrough-free (RemoteViews text
 * styling is limited); tapping a row opens that task's detail sheet. See
 * SPEC.md Home and Lock Screen Widgets.
 */
class TaskWidgetFactory(
    private val context: Context,
    intent: Intent,
) : RemoteViewsService.RemoteViewsFactory {
  private val tasksJson = intent.getStringExtra("tasksJson") ?: "[]"
  private var tasks: List<TaskEntry> = emptyList()

  override fun onCreate() {}

  override fun onDataSetChanged() {
    tasks = parseTasks(tasksJson)
  }

  override fun onDestroy() {}

  override fun getCount(): Int = tasks.size

  override fun getViewAt(position: Int): RemoteViews {
    val task = tasks[position]
    val views = RemoteViews(context.packageName, R.layout.widget_task_row)
    views.setTextViewText(R.id.task_name, task.name)
    views.setImageViewResource(
        R.id.task_check,
        if (task.isCompleted) {
          R.drawable.ic_widget_check_task
        } else {
          R.drawable.ic_widget_circle_task_todo
        },
    )

    // A row inside a RemoteViewsService-backed list can't use
    // setOnClickPendingIntent (silently ignored) — only a fill-in intent
    // merged into the ListView's PendingIntentTemplate, set once in
    // MindfulMediumWidget.
    val fillInIntent =
        Intent().apply { data = Uri.parse("mindful://open-task?taskId=${task.id}") }
    views.setOnClickFillInIntent(R.id.task_row_root, fillInIntent)
    return views
  }

  override fun getLoadingView(): RemoteViews? = null

  override fun getViewTypeCount(): Int = 1

  override fun getItemId(position: Int): Long = position.toLong()

  override fun hasStableIds(): Boolean = true

  private fun parseTasks(json: String): List<TaskEntry> {
    val array = JSONArray(json)
    return (0 until array.length()).map { i ->
      val obj = array.getJSONObject(i)
      TaskEntry(
          id = obj.getString("id"),
          name = obj.getString("name"),
          isCompleted = obj.optBoolean("isCompleted", false),
      )
    }
  }
}
