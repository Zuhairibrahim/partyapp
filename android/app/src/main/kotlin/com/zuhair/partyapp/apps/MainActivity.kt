package com.zuhair.partyapp.apps

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "partyapp/placestore")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "read" -> result.success(readFile(file("partyapp_store.json"), "[]"))
                    "write" -> {
                        writeFile(file("partyapp_store.json"), call.arguments as? String ?: "[]")
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        // Bookings: each customer request is tagged with its own customer id
        // (partyapp_customer_id.txt) and stored in partyapp_bookings.json, which
        // the admin dashboard reads/writes through PlaceStoreProvider.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "partyapp/bookingstore")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "read" -> result.success(readFile(file("partyapp_bookings.json"), "[]"))
                    "write" -> {
                        writeFile(file("partyapp_bookings.json"), call.arguments as? String ?: "[]")
                        result.success(true)
                    }
                    "readId" -> {
                        val id = readFile(file("partyapp_customer_id.txt"), "").trim()
                        result.success(if (id.isEmpty()) null else id)
                    }
                    "writeId" -> {
                        writeFile(file("partyapp_customer_id.txt"), call.arguments as? String ?: "")
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        // Cart: kept private to the customer app (the dashboard never reads it).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "partyapp/cartstore")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "read" -> result.success(readFile(file("partyapp_cart.json"), "[]"))
                    "write" -> {
                        writeFile(file("partyapp_cart.json"), call.arguments as? String ?: "[]")
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        // Customer profile: mandatory registration (name + phone).
        // partyapp_profile.json is exposed to the dashboard through the provider
        // (path /profiles) so orders show the customer's name. The customerId is
        // mirrored into partyapp_customer_id.txt so bookings get the same id.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "partyapp/customerstore")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "read" -> {
                        val raw = readFile(file("partyapp_profile.json"), "")
                        result.success(if (raw.isEmpty()) null else raw)
                    }
                    "write" -> {
                        writeFile(file("partyapp_profile.json"), call.arguments as? String ?: "")
                        result.success(true)
                    }
                    "writeId" -> {
                        writeFile(file("partyapp_customer_id.txt"), call.arguments as? String ?: "")
                        result.success(true)
                    }
                    "clear" -> {
                        file("partyapp_profile.json").delete()
                        file("partyapp_customer_id.txt").delete()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun file(name: String): File = File(filesDir, name)

    private fun readFile(file: File, def: String): String =
        if (file.exists()) file.readText() else def

    private fun writeFile(file: File, payload: String) {
        file.parentFile?.mkdirs()
        file.writeText(payload)
    }
}