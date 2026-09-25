package com.guswira.mindful.widgets

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import com.guswira.mindful.MainActivity
import es.antonborri.home_widget.HomeWidgetLaunchIntent

/**
 * A `PendingIntent` opening [MainActivity] with no `data` of its own —
 * used as the `PendingIntentTemplate` for a RemoteViewsService-backed
 * `ListView` (the habits/tasks lists on both [MindfulMediumWidget] and
 * [MindfulSmallWidget]). Each row supplies its own `data` via
 * `setOnClickFillInIntent` ([HabitWidgetFactory]/[TaskWidgetFactory]),
 * which the system merges in at click time — that merge requires
 * [PendingIntent.FLAG_MUTABLE], unlike [HomeWidgetLaunchIntent], which
 * always builds an immutable one. See SPEC.md Home and Lock Screen
 * Widgets.
 */
fun launchTemplatePendingIntent(context: Context, requestCode: Int): PendingIntent {
  val intent =
      Intent(context, MainActivity::class.java).apply {
        action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
      }
  val flags =
      if (Build.VERSION.SDK_INT >= 23) {
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
      } else {
        PendingIntent.FLAG_UPDATE_CURRENT
      }
  return PendingIntent.getActivity(context, requestCode, intent, flags)
}
