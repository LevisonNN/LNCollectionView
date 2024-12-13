package com.example.myapplication

import android.graphics.RectF
import android.os.Bundle
import android.util.Size
import androidx.activity.ComponentActivity
import androidx.activity.enableEdgeToEdge
import android.widget.LinearLayout
import androidx.core.view.setPadding
import com.ln.collectionview.collectionview.LNCollectionView
import com.ln.collectionview.collectionview.LNCollectionViewDataSource
import com.ln.collectionview.collectionview.LNCollectionViewDelegate
import com.ln.collectionview.collectionview.cell.LNCollectionViewCell
import com.ln.collectionview.collectionview.layout.LNCollectionViewDelegateFlowLayout
import com.ln.collectionview.collectionview.layout.LNCollectionViewFlowLayout
import com.ln.collectionview.collectionview.layout.LNCollectionViewLayout
import com.ln.collectionview.collectionview.layout.LNCollectionViewScrollDirection
import com.ln.collectionview.collectionview.layout.LNIndexPath
import java.lang.ref.WeakReference

class MainActivity : ComponentActivity(), LNCollectionViewDataSource, LNCollectionViewDelegate, LNCollectionViewDelegateFlowLayout{
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        enableEdgeToEdge()

        val linearLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(0)
        }

        val flowLayout = LNCollectionViewFlowLayout().apply {
            this.scrollDirection = LNCollectionViewScrollDirection.VERTICAL
        }

        val collectionView = LNCollectionView(this, flowLayout).apply {
            registerClassForCellWithReuseIdentifier(LNCollectionViewCell::class.java, "kLNCollectionViewCell")
            pageEnable = false
            dataSource = WeakReference<LNCollectionViewDataSource>(this@MainActivity)
            delegate = WeakReference<LNCollectionViewDelegate>(this@MainActivity)
        }
        linearLayout.addView(collectionView)
        setContentView(linearLayout)
    }

    override fun numberOfSectionsInCollectionView(collectionView: LNCollectionView): UInt {
        return 10u
    }

    override fun collectionViewNumberOfItemsInSection(
        collectionView: LNCollectionView,
        section: UInt
    ): UInt {
        return 20u
    }

    override fun collectionViewSizeForItemAtIndexPath(
        collectionView: LNCollectionView,
        layout: LNCollectionViewLayout,
        indexPath: LNIndexPath
    ): Size {
        return Size(300, 300)
    }

    override fun collectionViewCellForItemAtIndexPath(
        collectionView: LNCollectionView,
        indexPath: LNIndexPath
    ): LNCollectionViewCell {
        val cell = collectionView.dequeueReusableCellWithReuseIdentifier("kLNCollectionViewCell", indexPath)!!
        return cell
    }

    override fun collectionViewMinimumInterItemSpacingForSectionAtIndex(
        collectionView: LNCollectionView,
        layout: LNCollectionViewLayout,
        section: UInt
    ): Float {
        return 8f * 3f
    }

    override fun collectionViewMinimumLineSpacingForSectionAtIndex(
        collectionView: LNCollectionView,
        layout: LNCollectionViewLayout,
        section: UInt
    ): Float {
        return 16f * 3f
    }

    override fun collectionViewInsetForSectionAtIndex(
        collectionView: LNCollectionView,
        collectionViewLayout: LNCollectionViewLayout,
        section: UInt
    ): RectF {
        return RectF(12f * 3, 16f * 3, 12f * 3, 16f * 3)
    }

}