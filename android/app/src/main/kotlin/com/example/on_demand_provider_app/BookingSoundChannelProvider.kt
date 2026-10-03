package com.pt.swwishoprovider

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri as AndroidUri

/**
 * Runs when the process starts, including a killed app receiving FCM,
 * so the booking channel exists before Android shows the system notification.
 */
class BookingSoundChannelProvider : ContentProvider() {
    override fun onCreate(): Boolean {
        val appContext = context ?: return true
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return true
        val sound = Uri.parse("android.resource://${appContext.packageName}/raw/notification")
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        val channel = NotificationChannel(
            "demandium_sound_v5",
            "Swwisho Provider with sound",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            setSound(sound, audioAttributes)
            enableVibration(true)
            description = "Booking alerts"
        }
        val manager = appContext.getSystemService(NotificationManager::class.java)
        manager?.createNotificationChannel(channel)
        return true
    }

    override fun query(
        uri: AndroidUri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?,
    ): Cursor? = null

    override fun getType(uri: AndroidUri): String? = null

    override fun insert(uri: AndroidUri, values: ContentValues?): AndroidUri? = null

    override fun delete(uri: AndroidUri, selection: String?, selectionArgs: Array<out String>?): Int = 0

    override fun update(
        uri: AndroidUri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<out String>?,
    ): Int = 0
}
