package com.ladikov.personal_pim

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class AddContactWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.add_contact_widget)

            // Use HomeWidgetLaunchIntent with Uri so the Flutter home_widget plugin catches it
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("personalpim://add_contact")
            )

            views.setOnClickPendingIntent(R.id.btn_add_contact, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}