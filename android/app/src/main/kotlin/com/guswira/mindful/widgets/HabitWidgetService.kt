package com.guswira.mindful.widgets

import android.content.Intent
import android.widget.RemoteViewsService

/**
 * Backs the habits [android.widget.ListView] in [MindfulMediumWidget] with
 * [HabitWidgetFactory]. See SPEC.md Home and Lock Screen Widgets.
 */
class HabitWidgetService : RemoteViewsService() {
  override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
      HabitWidgetFactory(applicationContext, intent)
}
