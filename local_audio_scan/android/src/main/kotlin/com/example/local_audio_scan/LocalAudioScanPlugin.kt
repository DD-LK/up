package com.example.local_audio_scan

import android.Manifest
import android.content.ContentUris
import android.content.Context
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import kotlinx.coroutines.*

class LocalAudioScanPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, RequestPermissionsResultListener {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingResult: Result? = null
    private val coroutineScope = CoroutineScope(Dispatchers.IO)

    private val requiredPermission: String
        get() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_AUDIO
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "local_audio_scan")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        pendingResult = result
        when (call.method) {
            "scanTracks" -> {
                val includeArtwork = call.argument<Boolean>("includeArtwork") ?: true
                val filterJunkAudio = call.argument<Boolean>("filterJunkAudio") ?: true
                coroutineScope.launch {
                    val tracks = scanAudioFiles(includeArtwork, filterJunkAudio)
                    withContext(Dispatchers.Main) {
                        result.success(tracks)
                    }
                }
            }
            "checkPermission" -> {
                result.success(hasPermission())
            }
            "requestPermission" -> {
                if (hasPermission()) {
                    result.success(true)
                } else {
                    activityBinding?.activity?.let {
                        ActivityCompat.requestPermissions(it, arrayOf(requiredPermission), 101)
                    } ?: result.error("NO_ACTIVITY", "Plugin is not attached to an activity.", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun hasPermission(): Boolean {
        return ContextCompat.checkSelfPermission(context, requiredPermission) == PackageManager.PERMISSION_GRANTED
    }

    private fun scanAudioFiles(includeArtwork: Boolean, filterJunkAudio: Boolean): List<Map<String, Any?>> {
        val tracks = mutableListOf<Map<String, Any?>>()
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.MIME_TYPE,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.DATE_ADDED,
            MediaStore.Audio.Media.ALBUM_ID
        )

        val selection = StringBuilder("${MediaStore.Audio.Media.IS_MUSIC} != 0")
        if (filterJunkAudio) {
            selection.append(" AND ${MediaStore.Audio.Media.DATA} NOT LIKE '%/WhatsApp/%'")
            selection.append(" AND ${MediaStore.Audio.Media.DATA} NOT LIKE '%/Call/%'")
        }
        val sortOrder = "${MediaStore.Audio.Media.TITLE} ASC"

        context.contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection.toString(),
            null,
            sortOrder
        )?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val titleColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val artistColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val albumColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val durationColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val filePathColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
            val mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.MIME_TYPE)
            val sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)
            val dateAddedColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_ADDED)
            val albumIdColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idColumn)
                val albumId = cursor.getLong(albumIdColumn)
                val artwork = if (includeArtwork) getAlbumArt(albumId) else null

                val track = mapOf(
                    "id" to id.toString(),
                    "title" to cursor.getString(titleColumn),
                    "artist" to cursor.getString(artistColumn),
                    "album" to cursor.getString(albumColumn),
                    "duration" to cursor.getInt(durationColumn),
                    "filePath" to cursor.getString(filePathColumn),
                    "mimeType" to cursor.getString(mimeTypeColumn),
                    "size" to cursor.getInt(sizeColumn),
                    "dateAdded" to cursor.getLong(dateAddedColumn) * 1000, // Convert to milliseconds
                    "artwork" to artwork
                )
                tracks.add(track)
            }
        }
        return tracks
    }

    private fun getAlbumArt(albumId: Long): ByteArray? {
        var artwork: ByteArray? = null
        try {
            val albumArtUri = ContentUris.withAppendedId(Uri.parse("content://media/external/audio/albumart"), albumId)
            context.contentResolver.openInputStream(albumArtUri)?.use { inputStream ->
                artwork = inputStream.readBytes()
            }
        } catch (e: Exception) {
            // Album art not found or other error
        }
        return artwork
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        coroutineScope.cancel()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeRequestPermissionsResultListener(this)
        activityBinding = null
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        if (requestCode == 101) {
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingResult?.success(granted)
            pendingResult = null
            return true
        }
        return false
    }
}