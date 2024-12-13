package com.ln.collectionview.collectionview.attributes

import android.graphics.Rect
import com.ln.collectionview.collectionview.layout.LNIndexPath

class LNCollectionViewLayoutAttributes {
    var indexPath: LNIndexPath = LNIndexPath(0u, 0u)
    var frame:Rect = Rect()
    companion object {
        fun createForCellAt(indexPath: LNIndexPath): LNCollectionViewLayoutAttributes {
            val att = LNCollectionViewLayoutAttributes()
            att.indexPath = indexPath
            return att
        }
    }
}