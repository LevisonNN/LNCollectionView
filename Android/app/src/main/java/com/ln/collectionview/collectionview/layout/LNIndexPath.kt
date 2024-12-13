package com.ln.collectionview.collectionview.layout

import android.content.ClipData.Item

class LNIndexPath (var item: UInt, var section: UInt) {
    fun key(): String {
        return "$section-$item"
    }
}