package com.ln.collectionview.collectionview

import android.content.Context
import android.graphics.Rect
import android.util.Log
import android.view.ViewGroup
import com.ln.collectionview.collectionview.attributes.LNCollectionViewLayoutAttributes
import com.ln.collectionview.collectionview.cell.LNCollectionViewCell
import com.ln.collectionview.collectionview.layout.LNCollectionViewLayout
import com.ln.collectionview.collectionview.layout.LNIndexPath
import com.ln.collectionview.collectionview.reuse.LNCollectionViewReusePool
import com.ln.collectionview.scrollview.LNScrollView
import com.ln.collectionview.scrollview.LNScrollViewDelegate
import java.lang.ref.WeakReference

interface LNCollectionViewDataSource {
    fun collectionViewNumberOfItemsInSection(collectionView: LNCollectionView, section: UInt): UInt
    fun collectionViewCellForItemAtIndexPath(collectionView: LNCollectionView, indexPath: LNIndexPath): LNCollectionViewCell
    fun numberOfSectionsInCollectionView(collectionView: LNCollectionView): UInt { return 1u }
}

interface LNCollectionViewDelegate : LNScrollViewDelegate {
    fun collectionViewDidSelectItemAtIndexPath(collectionView: LNCollectionView, indexPath : LNIndexPath) {}
    fun collectionViewDidDeselectItemAtIndexPath(collectionView: LNCollectionView, indexPath: LNIndexPath) {}
    fun collectionViewWillDisplayCellForItemAtIndexPath(collectionView: LNCollectionView, cell: LNCollectionViewCell, indexPath: LNIndexPath) {}
    fun collectionViewDidEndDisplayingCellForItemAtIndexPath(collectionView: LNCollectionView, cell: LNCollectionViewCell, indexPath: LNIndexPath) {}
}

class LNCollectionView(
    context: Context,
    var collectionViewLayout: LNCollectionViewLayout
) : LNScrollView(context) {

    var delegate: WeakReference<LNCollectionViewDelegate>? = null
    var dataSource: WeakReference<LNCollectionViewDataSource>? = null

    var currentAttributesArr: List<LNCollectionViewLayoutAttributes> = emptyList()
    var currentCells: MutableMap<String, LNCollectionViewCell> = mutableMapOf()
    var hasInitialized = false
    var pool: LNCollectionViewReusePool = LNCollectionViewReusePool(this)

    init {
        collectionViewLayout.collectionViewWeakRef = WeakReference<LNCollectionView>(this)
    }

    override fun setScrollX(value: Int) {
        super.setScrollX(value)
        checkVisible()
    }

    override fun setScrollY(value: Int) {
        super.setScrollY(value)
        checkVisible()
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        super.onLayout(changed, l, t, r, b)
        if (!hasInitialized) {
            collectionViewLayout.prepareLayout()
            checkVisible()
            hasInitialized = true
        }
    }

    fun reloadData() {
        for (attributes in currentAttributesArr) {
            val cell = currentCells[attributes.indexPath.key()]
            cell?.let {
                removeView(it)
                currentCells.remove(attributes.indexPath.key())
                pool.addReusableCell(it)
            }
        }
        currentCells.clear()
        currentAttributesArr = emptyList()
        collectionViewLayout.invalidateLayout()
        collectionViewLayout.prepareLayout()
        checkVisible()
    }

    private fun checkVisible() {
        val currentBounds = Rect(scrollX, scrollY, scrollX + width, scrollY + height)
        var newAttributesArr = collectionViewLayout.layoutAttributesForElementsInRect(currentBounds)
        val visibleAttributesSet = currentAttributesArr.toSet()
        val newAttributesSet = newAttributesArr.toSet()
        val newlyVisibleAttributesMSet = newAttributesSet.toMutableSet().apply { minusAssign(visibleAttributesSet) }
        val disappearingAttributesMSet = visibleAttributesSet.toMutableSet().apply { minusAssign(newAttributesSet) }


        if (dataSource?.get() == null) {
            return
        }
        val validDataSource = dataSource?.get()!!
        for (attributes in newlyVisibleAttributesMSet) {
            val cell = validDataSource.collectionViewCellForItemAtIndexPath(this, attributes.indexPath).let {
                currentCells[attributes.indexPath.key()] = it
                this@LNCollectionView.addView(it)
                it.layout(attributes.frame.left, attributes.frame.top, attributes.frame.right, attributes.frame.bottom)
                it
            }
        }

        for (attributes in disappearingAttributesMSet) {
            val cell = currentCells[attributes.indexPath.key()]
            cell?.let {
                this@LNCollectionView.removeView(it)
                currentCells.remove(attributes.indexPath.key())
                pool.addReusableCell(it)
            }
        }

        currentAttributesArr = newAttributesSet.toList()
        contentSize = collectionViewLayout.collectionViewContentSize
    }

    fun registerClassForCellWithReuseIdentifier(cellClass: Class<out LNCollectionViewCell>, identifier: String) {
        pool.registerClassForCellWithReuseIdentifier(cellClass, identifier)
    }

    fun dequeueReusableCellWithReuseIdentifier(identifier: String, indexPath: LNIndexPath): LNCollectionViewCell? {
        return pool.dequeueReusableCellWithIdentifier(identifier)
    }
}

