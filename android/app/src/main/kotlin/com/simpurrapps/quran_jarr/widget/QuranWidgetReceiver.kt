package com.simpurrapps.quran_jarr.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.simpurrapps.quran_jarr.R

/**
 * Simple Quran Widget Provider
 */
class QuranWidgetReceiver : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val prefs = context.getSharedPreferences("QuranJarrWidget", Context.MODE_PRIVATE)

            val arabicText = prefs.getString("arabic_text", "بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ") ?: ""
            val translation = prefs.getString("translation", "In the name of Allah, the Most Gracious, the Most Merciful") ?: ""
            val surahName = prefs.getString("surah_name", "Al-Fatiha") ?: ""
            val surahNum = prefs.getInt("surah_number", 1)
            val ayahNum = prefs.getInt("ayah_number", 1)

            val views = RemoteViews(context.packageName, R.layout.quran_widget_layout)

            views.setTextViewText(R.id.widget_surah_name, "$surahName ($surahNum:$ayahNum)")
            views.setTextViewText(R.id.widget_arabic_text, arabicText)
            views.setTextViewText(R.id.widget_translation, translation)

            // Set colors
            views.setInt(R.id.widget_container, "setBackgroundColor", 0xFFF5F0E8.toInt())
            views.setTextColor(R.id.widget_surah_name, 0xFF7CB342.toInt())
            views.setTextColor(R.id.widget_arabic_text, 0xFF5D4E37.toInt())
            views.setTextColor(R.id.widget_translation, 0xFF5D4E37.toInt())

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
