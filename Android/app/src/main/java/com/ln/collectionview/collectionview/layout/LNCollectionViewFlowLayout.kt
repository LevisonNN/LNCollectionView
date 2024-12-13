package com.ln.collectionview.collectionview.layout

import android.graphics.Rect
import android.graphics.RectF
import android.util.Size
import android.util.SizeF
import com.ln.collectionview.collectionview.LNCollectionView
import com.ln.collectionview.collectionview.attributes.LNCollectionViewLayoutAttributes
import kotlin.math.max

interface LNCollectionViewDelegateFlowLayout {

    fun collectionViewSizeForItemAtIndexPath(
        collectionView: LNCollectionView,
        layout: LNCollectionViewLayout,
        indexPath: LNIndexPath
    ): Size {
        return Size(100, 100)
    }

    fun collectionViewMinimumLineSpacingForSectionAtIndex(
        collectionView: LNCollectionView,
        layout: LNCollectionViewLayout,
        section: UInt
    ): Float {
        return 16f
    }

    fun collectionViewMinimumInterItemSpacingForSectionAtIndex(
        collectionView: LNCollectionView,
        layout: LNCollectionViewLayout,
        section: UInt
    ): Float {
        return 8f
    }

    fun collectionViewInsetForSectionAtIndex(
        collectionView: LNCollectionView,
        collectionViewLayout: LNCollectionViewLayout,
        section: UInt
    ): RectF {
        return RectF(0f, 0f, 0f, 0f)
    }

}

class LNCollectionViewFlowLayout(): LNCollectionViewLayout() {

    var indexPathArr: List<LNIndexPath> = listOf()
    var frameDic: Map<String, Rect> = mapOf()
    var attributesMDic: MutableMap<String, LNCollectionViewLayoutAttributes> = mutableMapOf()
    var scrollDirection: LNCollectionViewScrollDirection = LNCollectionViewScrollDirection.VERTICAL
    var defaultLineSpacing: Float = 16f
    var defaultItemSpacing: Float = 8f
    var defaultSectionInset: RectF = RectF(0f,0f,0f,0f)
    private fun getSizingInfos(): Map<String, Rect> {
        val mDic = mutableMapOf<String, Rect>()
        val indexPathMArr = mutableListOf<LNIndexPath>()
        var cursorX = 0f
        var cursorY = 0f
        var lineWidth = 0f
        if (collectionViewWeakRef?.get() == null || collectionViewWeakRef?.get()?.dataSource?.get() == null) {
            return mapOf()
        }
        val validCollectionView = collectionViewWeakRef?.get()!!
        val validDataSource = collectionViewWeakRef?.get()?.dataSource?.get()!!
        val sectionCount = validDataSource.numberOfSectionsInCollectionView(validCollectionView)
        val isHorizontal = scrollDirection == LNCollectionViewScrollDirection.HORIZONTAL
        val frameWidth = validCollectionView.width
        val frameHeight = validCollectionView.height
        if (isHorizontal) {
            for (sectionIndex in 0u until sectionCount) {
                val itemCount = validDataSource.collectionViewNumberOfItemsInSection(validCollectionView, sectionIndex)
                val minLineSpacing = (validCollectionView.delegate?.get() as? LNCollectionViewDelegateFlowLayout)
                    ?.collectionViewMinimumLineSpacingForSectionAtIndex(validCollectionView, this, sectionIndex)
                    ?: defaultLineSpacing
                val minItemSpacing = (validCollectionView.delegate?.get() as? LNCollectionViewDelegateFlowLayout)
                    ?.collectionViewMinimumInterItemSpacingForSectionAtIndex(validCollectionView, this, sectionIndex)
                    ?: defaultItemSpacing
                val sectionInset = (validCollectionView.delegate?.get() as? LNCollectionViewDelegateFlowLayout)
                    ?.collectionViewInsetForSectionAtIndex(validCollectionView, this, sectionIndex)
                    ?: defaultSectionInset
                cursorX += sectionInset.left
                lineWidth = 0f
                cursorY = sectionInset.top
                for (itemIndex in 0u until itemCount) {
                    val itemSize: Size = (validCollectionView.delegate?.get() as? LNCollectionViewDelegateFlowLayout)
                        ?.collectionViewSizeForItemAtIndexPath(validCollectionView, this, LNIndexPath(itemIndex, sectionIndex))
                        ?: defaultItemSize

                    if (cursorY > 0 && cursorY + itemSize.height + sectionInset.bottom >= frameHeight) {
                        cursorX += lineWidth + minLineSpacing
                        lineWidth = 0f
                        cursorY = sectionInset.top
                    }
                    lineWidth = max(lineWidth, itemSize.width.toFloat())
                    val itemRect = Rect(cursorX.toInt(), cursorY.toInt(), (cursorX + itemSize.width).toInt(), (cursorY + itemSize.height).toInt())
                    cursorY = itemRect.bottom + minItemSpacing
                    mDic[LNIndexPath(itemIndex, sectionIndex).key()] = itemRect
                    indexPathMArr.add(LNIndexPath(itemIndex, sectionIndex))
                }
                cursorX += lineWidth + sectionInset.right
            }
        } else {
            cursorX = 0f
            cursorY = 0f
            lineWidth = 0f

            for (sectionIndex in 0u until sectionCount) {
                val itemCount = validDataSource.collectionViewNumberOfItemsInSection(validCollectionView, sectionIndex)
                val minLineSpacing = (validCollectionView.delegate?.get() as? LNCollectionViewDelegateFlowLayout)
                    ?.collectionViewMinimumLineSpacingForSectionAtIndex(validCollectionView, this, sectionIndex)
                    ?: defaultLineSpacing
                val minItemSpacing = (validCollectionView.delegate?.get() as? LNCollectionViewDelegateFlowLayout)
                    ?.collectionViewMinimumInterItemSpacingForSectionAtIndex(validCollectionView, this, sectionIndex)
                    ?: defaultItemSpacing
                val sectionInset = (validCollectionView.delegate?.get() as? LNCollectionViewDelegateFlowLayout)
                    ?.collectionViewInsetForSectionAtIndex(validCollectionView, this, sectionIndex)
                    ?: defaultSectionInset
                cursorY += sectionInset.top
                lineWidth = 0f
                cursorX = sectionInset.left
                for (itemIndex in 0u until itemCount) {
                    val itemSize = (validCollectionView.delegate?.get() as? LNCollectionViewDelegateFlowLayout)
                        ?.collectionViewSizeForItemAtIndexPath(validCollectionView, this, LNIndexPath(itemIndex, sectionIndex))
                        ?: defaultItemSize

                    if (cursorX > 0 && cursorX + itemSize.width + sectionInset.right >= frameWidth) {
                        cursorY += lineWidth + minLineSpacing
                        lineWidth = 0f
                        cursorX = sectionInset.left
                    }
                    lineWidth = max(lineWidth, itemSize.height.toFloat())
                    val itemRect = Rect(cursorX.toInt(), cursorY.toInt(), (cursorX + itemSize.width).toInt(), (cursorY + itemSize.height).toInt())
                    cursorX = itemRect.right + minItemSpacing
                    mDic[LNIndexPath(itemIndex, sectionIndex).key()] = itemRect
                    indexPathMArr.add(LNIndexPath(itemIndex, sectionIndex))
                }
                cursorY += lineWidth + sectionInset.bottom
            }
        }

        collectionViewContentSize = Size(cursorX.toInt(), cursorY.toInt())
        indexPathArr = indexPathMArr
        return mDic
    }

    override fun prepareLayout() {
        frameDic = getSizingInfos()
    }

    override fun invalidateLayout() {
        indexPathArr = listOf()
        frameDic = mapOf()
        attributesMDic.clear()
        collectionViewContentSize = Size(0, 0)
    }

    override fun layoutAttributesForElementsInRect(rect: Rect): List<LNCollectionViewLayoutAttributes> {
        val targetIndex = binarySearchIndexPathInRect(rect)
        if (targetIndex < 0 || targetIndex >= indexPathArr.size) {
            return emptyList()
        }

        val result = mutableListOf<LNCollectionViewLayoutAttributes>()
        val targetIndexPath = indexPathArr[targetIndex]
        result.add(layoutAttributesForItemAtIndexPath(targetIndexPath))

        for (i in targetIndex - 1 downTo 0) {
            val indexPath = indexPathArr[i]
            val frame = frameDic[indexPath.key()] ?: continue
            if (scrollDirection == LNCollectionViewScrollDirection.HORIZONTAL) {
                if (frame.right < rect.left) break
            } else {
                if (frame.bottom < rect.top) break
            }
            if (frame.intersects(rect.left, rect.top, rect.right, rect.bottom)) {
                val attributes = layoutAttributesForItemAtIndexPath(indexPath)
                result.add(attributes)
            }
        }

        for (i in targetIndex + 1 until frameDic.keys.size) {
            val indexPath = indexPathArr[i]
            val frame = frameDic[indexPath.key()] ?: continue
            if (scrollDirection == LNCollectionViewScrollDirection.HORIZONTAL) {
                if (frame.left > rect.right) break
            } else {
                if (frame.top > rect.bottom) break
            }
            if (frame.intersects(rect.left, rect.top, rect.right, rect.bottom)) {
                val attributes = layoutAttributesForItemAtIndexPath(indexPath)
                result.add(attributes)
            }
        }

        return result
    }

    private fun binarySearchIndexPathInRect(rect: Rect): Int {
        if (indexPathArr.isEmpty()) return -1
        if (indexPathArr.size == 1) {
            val singleKey = indexPathArr.first()
            val singleFrame = frameDic[singleKey.key()] ?: return -1
            return if (singleFrame.intersects(rect.left, rect.top, rect.right, rect.bottom)) 0 else -1
        }

        var left = 0
        var right = indexPathArr.size - 1
        while (left <= right) {
            val mid = left + (right - left) / 2
            val midIndexPath = indexPathArr[mid]
            val midFrame = frameDic[midIndexPath.key()] ?: return -1
            if (midFrame.intersects(rect.left, rect.top, rect.right, rect.bottom)) return mid

            if (scrollDirection == LNCollectionViewScrollDirection.HORIZONTAL) {
                if (midFrame.bottom <= rect.top) {
                    left = mid + 1
                } else if (midFrame.top >= rect.bottom) {
                    right = mid - 1
                } else if (midFrame.right <= rect.left){
                    left = mid + 1
                } else if (midFrame.left >= rect.right) {
                    right = mid - 1
                } else {
                    left = mid + 1
                }
            } else {
                if (midFrame.right <= rect.left) {
                    left = mid + 1
                } else if (midFrame.left >= rect.right) {
                    right = mid - 1
                } else if (midFrame.bottom <= rect.top){
                    left = mid + 1
                } else if (midFrame.top >= rect.bottom) {
                    right = mid - 1
                } else {
                    left = mid + 1;
                }
            }
        }
        return -1
    }

    override fun layoutAttributesForItemAtIndexPath(indexPath: LNIndexPath): LNCollectionViewLayoutAttributes {
        return attributesMDic.getOrPut(indexPath.key()) {
            val attributes = LNCollectionViewLayoutAttributes.createForCellAt(indexPath)
            attributes.frame = frameDic[indexPath.key()] ?: Rect()
            attributes
        }
    }
}




