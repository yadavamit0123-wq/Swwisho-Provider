package com.pt.swwishoprovider

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build

class ProviderApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        createBookingAlertChannel()
    }

    private fun createBookingAlertChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val soundUri = Uri.parse("android.resource://$packageName/${R.raw.booking_ring}")
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        val channel = NotificationChannel(
            BOOKING_ALERT_CHANNEL_ID,
            "Booking Alert",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "New booking requests with ring sound"
            setSound(soundUri, audioAttributes)
            enableVibration(true)
            setShowBadge(true)
        }

        val manager = getSystemService(NotificationManager::class.java)
        manager?.createNotificationChannel(channel)
    }

    companion object {
        const val BOOKING_ALERT_CHANNEL_ID = "swwisho_booking_alert_v2"
    }
}
