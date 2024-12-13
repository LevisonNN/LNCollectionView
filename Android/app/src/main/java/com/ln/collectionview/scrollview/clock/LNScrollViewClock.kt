package com.ln.collectionview.scrollview.clock

import android.view.Choreographer
import java.util.concurrent.CopyOnWriteArrayList

public interface LNScrollViewClockProtocol {
    fun scrollViewClockUpdateTimeInterval(timeInterval: Long)
}

public class LNScrollViewClock private constructor() {

    private val choreographer: Choreographer = Choreographer.getInstance()
    private var lastTimeStamp: Long = 0
    private var isPaused: Boolean = true
    private val objects: MutableList<LNScrollViewClockProtocol> = CopyOnWriteArrayList()

    companion object {
        @Volatile
        private var instance: LNScrollViewClock? = null

        public fun shareInstance(): LNScrollViewClock {
            return instance ?: synchronized(this) {
                instance ?: LNScrollViewClock().also { instance = it }
            }
        }
    }

    fun addObject(obj: LNScrollViewClockProtocol) {
        if (!objects.contains(obj)) {
            objects.add(obj)
            checkNeedStartOrStop()
        }
    }

    fun removeObject(obj: LNScrollViewClockProtocol) {
        if (objects.contains(obj)) {
            objects.remove(obj)
            checkNeedStartOrStop()
        }
    }

    private fun checkNeedStartOrStop() {
        if (objects.isNotEmpty()) {
            startOrResume()
        } else {
            stop()
        }
    }

    private fun startOrResume() {
        if (isPaused) {
            isPaused = false
            resetClock()
        }
    }

    fun pause() {
        isPaused = true
    }

    private fun stop() {
        isPaused = true
        choreographer.removeFrameCallback(frameCallback)
    }

    private fun resetClock() {
        lastTimeStamp = System.nanoTime() / 1000000
        choreographer.postFrameCallback(frameCallback)
    }

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (isPaused) return

            val currentTime = System.nanoTime() / 1000000
            val timeInterval = currentTime - lastTimeStamp

            objects.forEach {
                it.scrollViewClockUpdateTimeInterval(timeInterval)
            }

            lastTimeStamp = currentTime

            choreographer.postFrameCallback(this)
        }
    }
}
