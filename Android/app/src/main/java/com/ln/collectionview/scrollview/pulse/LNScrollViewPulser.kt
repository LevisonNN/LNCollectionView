package com.ln.collectionview.scrollview.pulse

import java.lang.ref.WeakReference

interface LNScrollViewPulserDelegate {
    fun pulserGetVelocity(pulser: LNScrollViewPulser): Float
    fun pulserUpdateVelocity(pulser: LNScrollViewPulser, velocity: Float)
}

class LNScrollViewPulser {

    var mass: Float = 1f
    private var isOpen: Boolean = false

    // Function to get current momentum
    fun getCurrentMomentum(): LNScrollViewMomentum {
        val currentMomentum = LNScrollViewMomentum()
        currentMomentum.mass = this.mass
        if (delegate != null) {
            val velocity = delegate?.get()?.pulserGetVelocity(this) ?: 0f
            currentMomentum.velocity = velocity
        } else {
            currentMomentum.velocity = 0f
        }
        return currentMomentum
    }

    // Function to update the momentum
    fun updateMomentum(momentum: LNScrollViewMomentum) {
        if (!isOpen) {
            return
        }
        delegate?.get()?.pulserUpdateVelocity(this, momentum.velocity)
    }

    fun openStatus(): Boolean {
        return isOpen
    }

    fun open() {
        isOpen = true
    }

    fun close() {
        isOpen = false
    }

    var delegate: WeakReference<LNScrollViewPulserDelegate>? = null
}

