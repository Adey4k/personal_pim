package com.ladikov.personal_pim

import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONObject

class CustomEventRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return CustomEventRemoteViewsFactory(this.applicationContext)
    }
}

class CustomEventRemoteViewsFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var events: List<BirthdayEntry> = listOf()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val currentIndex = prefs.getInt("custom_event_index", 0)
        val dataJson = prefs.getString("custom_events_data", "{}") ?: "{}"
        
        val list = mutableListOf<BirthdayEntry>()
        try {
            val jsonObject = JSONObject(dataJson)
            val eventTypes = jsonObject.optJSONArray("eventTypes")
            val eventsMap = jsonObject.optJSONObject("events")
            
            if (eventTypes != null && eventTypes.length() > 0 && eventsMap != null) {
                val index = (currentIndex % eventTypes.length() + eventTypes.length()) % eventTypes.length()
                val currentType = eventTypes.getString(index)
                val typeEvents = eventsMap.optJSONArray(currentType)
                
                if (typeEvents != null) {
                    for (i in 0 until typeEvents.length()) {
                        val obj = typeEvents.getJSONObject(i)
                        list.add(BirthdayEntry(
                            id = obj.optString("id", ""),
                            name = obj.optString("name", ""),
                            date = obj.optString("date", ""),
                            age = obj.optString("age", "")
                        ))
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        events = list
    }

    override fun onDestroy() {}

    override fun getCount(): Int = events.size

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.birthday_item)
        if (position >= events.size) return views
        
        val entry = events[position]

        views.setTextViewText(R.id.contact_name, entry.name)
        views.setTextViewText(R.id.contact_birthday, entry.date)

        if (entry.age.isNotEmpty() && entry.age != "0") {
            views.setTextViewText(R.id.contact_age_info, "Виповниться ${entry.age} р.")
            views.setViewVisibility(R.id.contact_age_info, android.view.View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.contact_age_info, android.view.View.GONE)
        }

        // Theming
        val isDarkMode = (context.resources.configuration.uiMode and
                Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES

        val nameColor = if (isDarkMode) Color.WHITE else Color.BLACK
        val dateColor = if (isDarkMode) Color.parseColor("#BBBBBB") else Color.parseColor("#555555")
        val ageColor = if (isDarkMode) Color.parseColor("#BB86FC") else Color.parseColor("#6750A4")

        views.setTextColor(R.id.contact_name, nameColor)
        views.setTextColor(R.id.contact_birthday, dateColor)
        views.setTextColor(R.id.contact_age_info, ageColor)
        
        // Deep link click handling
        if (entry.id.isNotEmpty()) {
            val fillInIntent = Intent()
            fillInIntent.data = Uri.parse("personalpim://contact?id=${entry.id}")
            views.setOnClickFillInIntent(R.id.birthday_item_root, fillInIntent)
        }

        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true
}
