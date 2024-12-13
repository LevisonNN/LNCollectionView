package com.ln.collectionview.scrollview.simulator

import kotlin.math.abs
import kotlin.math.exp
import kotlin.math.E

class LNScrollViewPageSimulator(
    initialPosition: Float,
    initialVelocity: Float,
    targetPosition: Float,
    damping: Float
) {

    var damping: Float = damping
    var currentTime: Float = 0f
    var velocity0: Float = 0f
    var offset: Float = initialPosition - targetPosition
    var targetPosition: Float = targetPosition
    var velocity: Float = initialVelocity
        private set

    init {
        if (abs(offset) < 1f) {
            currentTime = 0f
            velocity0 = initialVelocity
        } else {
            currentTime = 1f / (damping + initialVelocity / offset)
            velocity0 = offset * exp(damping * currentTime) / currentTime
        }
    }

    fun position(): Float {
        return targetPosition + offset
    }

    companion object {
        // 静态方法，计算目标偏移量
        fun targetOffsetWithVelocity(velocity: Float, offset: Float, damping: Float): Float {
            val currentTime = 1f / (damping + velocity / offset)
            val v0 = offset * exp(damping * currentTime) / currentTime
            return v0/(E.toFloat() * damping)
        }
    }

    fun accumulate(during: Float) {
        currentTime += during
        offset = velocity0 * currentTime * exp(-damping * currentTime)
        velocity = velocity0 * exp(-damping * currentTime)
    }

    fun isFinished(): Boolean {
        return abs(offset) < 0.1f && abs(velocity) < 0.01f
    }
}
