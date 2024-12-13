package com.ln.collectionview.collectionview.cell

import android.content.Context
import android.view.ViewGroup
import android.widget.FrameLayout

open class LNCollectionViewCell(context: Context): ViewGroup(context) {

    var identifier: String? = null
    val contentView: ViewGroup by lazy { LNCollectionViewCellContentView(context) }

    init {
        addView(contentView)
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        contentView.layout(0, 0, r - l, b - t)
    }
}
