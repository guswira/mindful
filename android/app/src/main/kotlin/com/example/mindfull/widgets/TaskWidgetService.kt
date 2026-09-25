package com.example.mindfull.widgets

import android.content.Intent
import android.widget.RemoteViewsService

/**
 * Backs the tasks [android.widget.ListView] in [MindfullMediumWidget] with
 * [TaskWidgetFactory]. See SPEC.md Home and Lock Screen Widgets.
 */
class TaskWidgetService : RemoteViewsService() {
  override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
      TaskWidgetFactory(applicationContext, intent)
}
