package com.ln.collectionview.scrollview.simulator

import android.util.Log

class LNScrollViewBounceSimulator(
    initialPosition: Float,
    initialVelocity: Float,
    targetPosition: Float
) {

    private var damping: Float = 10.9f
    private var currentTime: Float = 0f
    private var velocity0: Float = 0f
    var offset: Float = initialPosition - targetPosition
    private var targetPosition: Float = targetPosition

    var velocity: Float = initialVelocity
        private set

    fun position():Float {
        return targetPosition + offset
    }

    init {
        offset = initialPosition - targetPosition
        if (Math.abs(offset) < 1f) {
            currentTime = 0f
            velocity0 = initialVelocity
        } else {
            currentTime = 1f / (damping + initialVelocity / offset)
            velocity0 = offset * Math.exp((damping * currentTime).toDouble()).toFloat() / currentTime
        }
    }

    fun accumulate(during: Float) {
        currentTime += during
        offset = velocity0 * currentTime * Math.exp(-damping * currentTime.toDouble()).toFloat()
        velocity = velocity0 * Math.exp(-damping * currentTime.toDouble()).toFloat()
    }

    fun isFinished(): Boolean {
        return Math.abs(offset) < 0.1f && Math.abs(velocity) < 0.01f
    }
}
