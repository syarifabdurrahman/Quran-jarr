package com.simpurrapps.quran_jarr.widget

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.material3.ColorProviders
import androidx.glance.material3.MaterialTheme
import androidx.glance.unit.ColorProvider
import androidx.glance.GlanceModifier
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.dp
import androidx.glance.unit.sp

/**
 * Quran Widget - Displays daily verse on home screen
 */
class QuranWidget : GlanceAppWidget() {
    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = context.getSharedPreferences("QuranJarrWidget", Context.MODE_PRIVATE)

        val arabicText = prefs.getString("arabic_text", "بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ") ?: ""
        val translation = prefs.getString("translation", "In the name of Allah, the Most Gracious, the Most Merciful") ?: ""
        val surahName = prefs.getString("surah_name", "Al-Fatiha") ?: ""
        val surahNum = prefs.getInt("surah_number", 1)
        val ayahNum = prefs.getInt("ayah_number", 1)

        provideContent {
            MaterialTheme(colorScheme = ColorProviders(
                light = androidx.glance.material3.ColorScheme(
                    primary = ColorProvider(0xFF7CB342),
                    surface = ColorProvider(0xFFFFF8F0),
                    onSurface = ColorProvider(0xFF5D4E37),
                )
            )) {
                Column(
                    modifier = GlanceModifier
                        .fillMaxSize()
                        .background(ColorProvider(0xFFF5F0E8))
                        .padding(16.dp),
                    verticalAlignment = Alignment.Vertical.CenterVertically,
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally
                ) {
                    // Surah reference
                    Text(
                        text = "$surahName ($surahNum:$ayahNum)",
                        modifier = GlanceModifier.padding(bottom = 8.dp),
                        style = TextStyle(
                            color = ColorProvider(0xFF7CB342),
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp
                        )
                    )

                    // Arabic verse
                    Text(
                        text = arabicText,
                        modifier = GlanceModifier.padding(bottom = 12.dp),
                        style = TextStyle(
                            fontSize = 18.sp,
                            textAlign = TextAlign.Right
                        ),
                        maxLines = 3
                    )

                    // Divider
                    Box(
                        modifier = GlanceModifier
                            .fillMaxWidth()
                            .height(1.dp)
                            .background(ColorProvider(0xFF7CB342))
                            .padding(vertical = 8.dp)
                    )

                    // Translation
                    Text(
                        text = translation,
                        style = TextStyle(
                            fontSize = 14.sp,
                            textAlign = TextAlign.Center
                        ),
                        maxLines = 3
                    )
                }
            }
        }
    }
}

/**
 * Widget Receiver
 */
class QuranWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = QuranWidget()
}
