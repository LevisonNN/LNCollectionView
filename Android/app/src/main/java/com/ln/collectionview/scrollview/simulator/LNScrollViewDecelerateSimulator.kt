package com.ln.collectionview.scrollview.simulator

class LNScrollViewDecelerateSimulator(
    initialPosition: Float,
    initialVelocity: Float
) {

    var position: Float = initialPosition
        private set
    var velocity: Float = initialVelocity
        private set

    private var damping: Float = 2f
    private var currentTime: Long = 0 // 当前时间，以毫秒为单位

    fun accumulate(during: Long) {
        currentTime += during
        val v = velocity * Math.exp((-damping * during / 1000.0).toDouble()).toFloat()
        val l = (-1f / damping) * velocity * Math.exp((-damping * during / 1000.0).toDouble()).toFloat() - (-1f / damping) * velocity
        if (Math.abs(velocity) < 0.01f) {
            velocity = 0f
        }
        velocity = v
        position += l
    }

    fun isFinished(): Boolean {
        return Math.abs(velocity) < 0.01f
    }
}
