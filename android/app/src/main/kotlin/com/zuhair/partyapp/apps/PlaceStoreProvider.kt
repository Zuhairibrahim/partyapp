package com.zuhair.partyapp.apps

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.File
import java.io.FileNotFoundException

/**
 * Exposes the shared local JSON files (all admin-added items + customer
 * bookings + customer registration profiles) to other apps signed with the
 * same key (the admin dashboard app). Read/write access is protected by
 * signature-level permissions, so only our own apps can use it.
 */
class PlaceStoreProvider : ContentProvider() {

    override fun onCreate(): Boolean = true

    private fun storeFile(uri: Uri): File =
        when (uri.lastPathSegment) {
            "bookings" -> File(context!!.filesDir, "partyapp_bookings.json")
            "profiles" -> File(context!!.filesDir, "partyapp_profile.json")
            else -> File(context!!.filesDir, "partyapp_store.json")
        }

    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor {
        val file = storeFile(uri)

        val parse = ParcelFileDescriptor.parseMode(mode)
        // "w" / "wt" must truncate + create so repeated writes never corrupt
        // the JSON by leaving trailing bytes from a previous, longer payload.
        val flags = when {
            mode.contains("w") && !mode.contains("a") ->
                parse or ParcelFileDescriptor.MODE_CREATE or
                    ParcelFileDescriptor.MODE_TRUNCATE
            else -> parse
        }

        if (!file.exists() && (flags and ParcelFileDescriptor.MODE_CREATE) != 0) {
            file.parentFile?.mkdirs()
        }

        Log.i("PlaceStoreProvider", "openFile mode=$mode flags=$flags file=${file.absolutePath}")
        try {
            return ParcelFileDescriptor.open(file, flags)
        } catch (e: FileNotFoundException) {
            file.parentFile?.mkdirs()
            // Create the file first so a subsequent write can open it.
            file.createNewFile()
            return ParcelFileDescriptor.open(file, flags)
        }
    }

    override fun query(
        uri: Uri, projection: Array<out String>?,
        selection: String?, selectionArgs: Array<out String>?, sortOrder: String?
    ): Cursor? = null

    override fun getType(uri: Uri): String? = "application/json"

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0

    override fun update(
        uri: Uri, values: ContentValues?,
        selection: String?, selectionArgs: Array<out String>?
    ): Int = 0
}