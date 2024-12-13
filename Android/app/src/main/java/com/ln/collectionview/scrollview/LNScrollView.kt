package com.ln.collectionview.scrollview

import android.app.ActionBar.LayoutParams
import android.content.Context
import android.graphics.Color
import android.graphics.PointF
import android.util.AttributeSet
import android.util.Log
import android.util.Size
import android.util.SizeF
import android.view.MotionEvent
import android.view.VelocityTracker
import android.view.View
import android.view.ViewGroup
import com.ln.collectionview.scrollview.simulator.LNScrollViewDecelerateSimulator
import com.ln.collectionview.scrollview.status.LNScrollViewAutoEffect
import com.ln.collectionview.scrollview.status.LNScrollViewAutoEffectDataSource
import com.ln.collectionview.scrollview.status.LNScrollViewAutoEffectDelegate
import com.ln.collectionview.scrollview.status.LNScrollViewAutoEffectRestStatus
import com.ln.collectionview.scrollview.status.LNScrollViewGestureEffect
import com.ln.collectionview.scrollview.status.LNScrollViewGestureEffectBoundsType
import com.ln.collectionview.scrollview.status.LNScrollViewGestureEffectProtocol
import com.ln.collectionview.scrollview.status.LNScrollViewGestureStatus
import java.lang.ref.WeakReference

interface LNScrollViewDelegate {
    fun scrollViewDidScroll(scrollView: LNScrollView) {}
    fun scrollViewWillBeginDragging(scrollView: LNScrollView) {}
    fun scrollViewWillEndDragging(
        scrollView: LNScrollView,
        velocity: PointF,
        targetContentOffset: PointF
    ) {}
    fun scrollViewDidEndDragging(
        scrollView: LNScrollView,
        willDecelerate: Boolean
    ) {}
    fun scrollViewWillBeginDecelerating(scrollView: LNScrollView) {}
    fun scrollViewDidEndDecelerating(scrollView: LNScrollView) {}
    fun scrollViewHorizontalDecelerateSimulatorForPosition(
        position: Float,
        velocity: Float
    ): LNScrollViewDecelerateSimulator? = null
    fun scrollViewVerticalDecelerateSimulatorForPosition(
        position: Float,
        velocity: Float
    ): LNScrollViewDecelerateSimulator? = null
}

class LNScrollViewRestStatus() {
    //这个用来算位移
    var startPosition: PointF = PointF(0f,0f)
}

open class LNScrollView(context: Context) : ViewGroup(context), LNScrollViewGestureEffectProtocol, LNScrollViewAutoEffectDelegate, LNScrollViewAutoEffectDataSource{
    private val gestureEffect: LNScrollViewGestureEffect = LNScrollViewGestureEffect().apply {
        delegate = WeakReference(this@LNScrollView)
    }
    private val autoEffect: LNScrollViewAutoEffect = LNScrollViewAutoEffect().apply {
        delegate = WeakReference(this@LNScrollView)
        dataSource = WeakReference(this@LNScrollView)
    }
    var pageEnable: Boolean = true
        set(value) {
            field = value
            autoEffect.pageEnable = value
        }
    val velocityTracker = VelocityTracker.obtain()
    private var restStatus: LNScrollViewRestStatus? = null
    var contentSize: Size = Size(0,0)
    init {

    }

    fun contentSizeF():SizeF {
        return SizeF(contentSize.width.toFloat(), contentSize.height.toFloat())
    }

    fun convertedRealLocation(event: MotionEvent): PointF {
        // 这里contentOffset好像不会影响到gesture的位置
        return PointF(event.x, event.y)
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        velocityTracker.addMovement(event)
        if (event != null) {
            when(event.action) {
                MotionEvent.ACTION_DOWN -> {
                    velocityTracker.clear()
                    autoEffect.finishForcely()
                    gestureEffect.finish()
                    val newRestStatus:LNScrollViewRestStatus = LNScrollViewRestStatus()
                    newRestStatus.startPosition = PointF(event.x, event.y)
                    restStatus = newRestStatus
                    val frameSize = SizeF(width.toFloat(), height.toFloat())
                    val currentContentSize = contentSize
                    val currentContentOffset = PointF(scrollX.toFloat(), scrollY.toFloat())
                    gestureEffect.startWithFrameSize(frameSize, contentSizeF(), currentContentOffset, newRestStatus.startPosition)
                }
                MotionEvent.ACTION_MOVE -> {
                    if (restStatus == null) {
                        return true
                    }
                    val validRestStatus = restStatus as LNScrollViewRestStatus
                    velocityTracker.computeCurrentVelocity(1000)
                    gestureEffect.updateGestureLocation(PointF(event.x, event.y))
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    gestureEffect.finish()
                    if (restStatus == null) {
                        return true
                    }
                    val validRestStatus = restStatus as LNScrollViewRestStatus
                    velocityTracker.computeCurrentVelocity(1000)
                    val velocityX = -velocityTracker.xVelocity
                    val velocityY = -velocityTracker.yVelocity
                    autoEffect.startWithVelocity(PointF(velocityX, velocityY))
                }
            }
        }
        return true
    }

    override fun gestureEffectStatusDidChange(status: LNScrollViewGestureStatus) {
        scrollX = status.convertedOffset.x.toInt()
        scrollY = status.convertedOffset.y.toInt()
    }

    override fun gestureEffect(
        gestureEffect: LNScrollViewGestureEffect,
        shouldOverBounds: LNScrollViewGestureEffectBoundsType
    ): Boolean {
        return true
    }

    //dataSource
    override fun autoEffectGetContentOffset(effect: LNScrollViewAutoEffect): PointF {
        return PointF(scrollX.toFloat(), scrollY.toFloat())
    }

    override fun autoEffectGetFrameSize(effect: LNScrollViewAutoEffect): SizeF {
        return SizeF(width.toFloat(), height.toFloat())
    }

    override fun autoEffectGetContentSize(effect: LNScrollViewAutoEffect): SizeF {
        return contentSizeF()
    }

    override fun autoEffectVerticalDecelerateWith(
        effect: LNScrollViewAutoEffect,
        position: Float,
        velocity: Float
    ): LNScrollViewDecelerateSimulator? {
        return null
    }

    override fun autoHorizontalDecelerateWith(
        effect: LNScrollViewAutoEffect,
        position: Float,
        velocity: Float
    ): LNScrollViewDecelerateSimulator? {
        return null
    }

    override fun autoEffectStatusHasFinished(effect: LNScrollViewAutoEffect) {

    }

    override fun autoEffectStatusDidChange(status: LNScrollViewAutoEffectRestStatus) {
        scrollX = status.offset.x.toInt()
        scrollY = status.offset.y.toInt()
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
    }
}