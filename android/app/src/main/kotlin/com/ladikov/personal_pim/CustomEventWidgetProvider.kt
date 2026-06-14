package com.ladikov.personal_pim

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import org.json.JSONObject

class CustomEventWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_NEXT_EVENT = "com.ladikov.personal_pim.NEXT_EVENT"
        const val ACTION_PREV_EVENT = "com.ladikov.personal_pim.PREV_EVENT"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val currentIndex = prefs.getInt("custom_event_index", 0)
        val dataJson = prefs.getString("custom_events_data", "{}") ?: "{}"
        
        var eventTypeTitle = "Events"
        try {
            val jsonObject = JSONObject(dataJson)
            val eventTypes = jsonObject.optJSONArray("eventTypes")
            if (eventTypes != null && eventTypes.length() > 0) {
                val index = (currentIndex % eventTypes.length() + eventTypes.length()) % eventTypes.length()
                eventTypeTitle = eventTypes.getString(index)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        val views = RemoteViews(context.packageName, R.layout.custom_event_widget)
        views.setTextViewText(R.id.event_type_title, eventTypeTitle)

        // Setup ListView
        val intent = Intent(context, CustomEventRemoteViewsService::class.java).apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            // Add a random data scheme to force the RemoteViewsFactory to re-initialize if data changes
            data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
        }
        views.setRemoteAdapter(R.id.event_list, intent)
        views.setEmptyView(R.id.event_list, R.id.empty_view)

        // Setup Prev Button
        val prevIntent = Intent(context, CustomEventWidgetProvider::class.java).apply {
            action = ACTION_PREV_EVENT
        }
        val prevPendingIntent = PendingIntent.getBroadcast(
            context, 0, prevIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.btn_prev, prevPendingIntent)

        // Setup Next Button
        val nextIntent = Intent(context, CustomEventWidgetProvider::class.java).apply {
            action = ACTION_NEXT_EVENT
        }
        val nextPendingIntent = PendingIntent.getBroadcast(
            context, 1, nextIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.btn_next, nextPendingIntent)

        // PendingIntent template for the collection items
        val clickIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java
        )
        views.setPendingIntentTemplate(R.id.event_list, clickIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.event_list)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val action = intent.action
        
        if (action == ACTION_NEXT_EVENT || action == ACTION_PREV_EVENT) {
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            val dataJson = prefs.getString("custom_events_data", "{}") ?: "{}"
            var length = 1
            try {
                val jsonObject = JSONObject(dataJson)
                val eventTypes = jsonObject.optJSONArray("eventTypes")
                if (eventTypes != null && eventTypes.length() > 0) {
                    length = eventTypes.length()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            var currentIndex = prefs.getInt("custom_event_index", 0)
            if (action == ACTION_NEXT_EVENT) {
                currentIndex = (currentIndex + 1) % length
            } else {
                currentIndex = (currentIndex - 1 + length) % length
            }
            
            prefs.edit().putInt("custom_event_index", currentIndex).apply()

            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = android.content.ComponentName(context, CustomEventWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }
        } else if (action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = android.content.ComponentName(context, CustomEventWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }
        }
    }
}
