package com.ln.collectionview.collectionview.reuse

import android.content.Context
import android.graphics.Color
import com.ln.collectionview.collectionview.LNCollectionView
import com.ln.collectionview.collectionview.cell.LNCollectionViewCell
import java.lang.ref.WeakReference
import java.util.*

class LNCollectionViewReusePool(collectionView: LNCollectionView) {

    private val collectionViewRef: WeakReference<LNCollectionView> = WeakReference(collectionView)
    private val reusePool: MutableMap<String, MutableSet<LNCollectionViewCell>> = mutableMapOf()
    private val registeredClasses: MutableMap<String, Class<out LNCollectionViewCell>> = mutableMapOf()

    fun registerClassForCellWithReuseIdentifier(cellClass: Class<out LNCollectionViewCell>, identifier: String) {
        if (identifier.isEmpty()) {
            return
        }
        registeredClasses[identifier] = cellClass
    }

    fun dequeueReusableCellWithIdentifier(identifier: String?): LNCollectionViewCell? {
        if (identifier.isNullOrEmpty()) {
            return null
        }

        if (collectionViewRef.get()?.context == null) {
            return null
        }
        val validContext = collectionViewRef.get()?.context!!
        val cells = reusePool[identifier]
        var cell: LNCollectionViewCell? = cells?.firstOrNull()
        if (cells != null && cell != null) {
            cells.remove(cell)
        } else {
            val cellClass = registeredClasses[identifier]
            if (cellClass != null) {
                try {
                    cell = cellClass.getDeclaredConstructor(Context::class.java).newInstance(validContext)
                    cell?.identifier = identifier
                    cell?.contentView?.setBackgroundColor(Color.BLUE)
                } catch (e: Exception) {
                    cell = LNCollectionViewCell(validContext)
                    cell.identifier = identifier
                }
            } else {
                cell = LNCollectionViewCell(validContext)
                cell.identifier = identifier
            }
        }
        return cell
    }

    fun addReusableCell(cell: LNCollectionViewCell?) {
        if (cell == null || cell.identifier.isNullOrEmpty()) {
            return
        }
        val cells = reusePool.getOrPut(cell.identifier!!) { mutableSetOf() }
        cells.add(cell)
    }

    fun clearReusableViews() {
        reusePool.clear()
    }
}
