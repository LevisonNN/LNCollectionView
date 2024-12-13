package com.ln.collectionview.scrollview.status

import android.graphics.PointF
import android.util.SizeF
import com.ln.collectionview.scrollview.simulator.LNScrollViewDragSimulator
import java.lang.ref.WeakReference

enum class LNScrollViewGestureEffectBoundsType {
    VerticalLeading,
    HorizontalLeading,
    VerticalTrailing,
    HorizontalTrailing,
}

interface LNScrollViewGestureEffectProtocol {
    fun gestureEffectStatusDidChange(status: LNScrollViewGestureStatus)
    fun gestureEffect(
        gestureEffect: LNScrollViewGestureEffect,
        shouldOverBounds: LNScrollViewGestureEffectBoundsType
    ): Boolean
}

class LNScrollViewGestureStatus {
    var gestureStartPosition: PointF = PointF(0f,0f)
    var startContentOffset: PointF = PointF(0f, 0f)
    var convertedOffset: PointF = PointF(0f, 0f)
}

class LNScrollViewGestureEffect {
    var horizontalDragSimulator: LNScrollViewDragSimulator? = null
    var verticalDragSimulator: LNScrollViewDragSimulator? = null
    var status: LNScrollViewGestureStatus? = null
    var delegate: WeakReference<LNScrollViewGestureEffectProtocol>? = null

    fun startWithFrameSize(
        frameSize: SizeF,
        contentSize: SizeF,
        currentOffset: PointF,
        gesturePosition: PointF
    ) {
        status = LNScrollViewGestureStatus().apply {
            gestureStartPosition = gesturePosition
            startContentOffset = currentOffset
            convertedOffset = PointF(0f,0f)
        }

        if (contentSize.height > frameSize.height) {
            verticalDragSimulator = LNScrollViewDragSimulator(
                leadingPoint = 0f,
                trailingPoint = contentSize.height - frameSize.height,
                startPoint = currentOffset.y
            )
        }

        if (contentSize.width > frameSize.width) {
            horizontalDragSimulator = LNScrollViewDragSimulator(
                leadingPoint = 0f,
                trailingPoint = contentSize.width - frameSize.width,
                startPoint = currentOffset.x
            )
        }
    }

    fun checkCouldOverBounds(boundsType: LNScrollViewGestureEffectBoundsType): Boolean {
        return delegate?.get()?.gestureEffect(this, boundsType) ?: false
    }

    fun updateGestureLocation(location: PointF) {
        var didStatusChange = false
        if (status == null) {
            return
        }
        val currentStatus = status as LNScrollViewGestureStatus

        horizontalDragSimulator?.let {
            val horizontalOffset = location.x - currentStatus.gestureStartPosition.x
            it.updateOffset(horizontalOffset)
            val resultOffset = it.getResultOffset()

            currentStatus.convertedOffset = when {
                resultOffset < it.leadingPoint -> {
                    if (checkCouldOverBounds(LNScrollViewGestureEffectBoundsType.HorizontalLeading)) {
                        PointF(resultOffset, currentStatus.convertedOffset.y)
                    } else {
                        PointF(it.leadingPoint, currentStatus.convertedOffset.y)
                    }
                }
                resultOffset > it.trailingPoint -> {
                    if (checkCouldOverBounds(LNScrollViewGestureEffectBoundsType.HorizontalTrailing)) {
                        PointF(resultOffset, currentStatus.convertedOffset.y)
                    } else {
                        PointF(it.trailingPoint, currentStatus.convertedOffset.y)
                    }
                }
                else -> {
                    PointF(resultOffset, currentStatus.convertedOffset.y)
                }
            }
            didStatusChange = true
        }

        verticalDragSimulator?.let {
            val verticalOffset = location.y - currentStatus.gestureStartPosition.y
            it.updateOffset(verticalOffset)
            val resultOffset = it.getResultOffset()

            currentStatus.convertedOffset = when {
                resultOffset < it.leadingPoint -> {
                    if (checkCouldOverBounds(LNScrollViewGestureEffectBoundsType.VerticalLeading)) {
                        PointF(currentStatus.convertedOffset.x, resultOffset)
                    } else {
                        PointF(currentStatus.convertedOffset.x, it.leadingPoint)
                    }
                }
                resultOffset > it.trailingPoint -> {
                    if (checkCouldOverBounds(LNScrollViewGestureEffectBoundsType.VerticalTrailing)) {
                        PointF(currentStatus.convertedOffset.x, resultOffset)
                    } else {
                        PointF(currentStatus.convertedOffset.x, it.trailingPoint)
                    }
                }
                else -> {
                    PointF(currentStatus.convertedOffset.x, resultOffset)
                }
            }
            didStatusChange = true
        }

        if (didStatusChange) {
            delegate?.get()?.gestureEffectStatusDidChange(currentStatus)
        }
    }

    fun finish() {
        status = null
        horizontalDragSimulator = null
        verticalDragSimulator = null
    }

}