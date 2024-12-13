package com.ln.collectionview.collectionview.layout

import android.graphics.PointF
import android.graphics.Rect
import android.util.Size
import android.util.SizeF
import com.ln.collectionview.collectionview.LNCollectionView
import com.ln.collectionview.collectionview.attributes.LNCollectionViewLayoutAttributes
import java.lang.ref.WeakReference

enum class LNCollectionViewScrollDirection {
    HORIZONTAL, VERTICAL
}

open class LNCollectionViewLayout {

    var collectionViewWeakRef: WeakReference<LNCollectionView>? = null

    init {}

    var collectionViewContentSize: Size = Size(0, 0)
    var defaultItemSize: Size = Size(88*3, 88*3)

    open fun invalidateLayout() {
    }

    open fun prepareLayout() {
    }

    open fun layoutAttributesForItemAtIndexPath(indexPath: LNIndexPath): LNCollectionViewLayoutAttributes {
        return LNCollectionViewLayoutAttributes()
    }

    open fun layoutAttributesForElementsInRect(rect: Rect): List<LNCollectionViewLayoutAttributes> {
        return emptyList()
    }

    fun targetContentOffsetForProposedContentOffset(proposedContentOffset: PointF): PointF {
        return PointF(0f, 0f)
    }
}
