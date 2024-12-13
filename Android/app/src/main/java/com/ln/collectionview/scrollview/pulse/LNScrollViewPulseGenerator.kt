package com.ln.collectionview.scrollview.pulse

import com.ln.collectionview.scrollview.status.LNScrollViewAutoEffectDelegate
import java.lang.ref.WeakReference

interface LNScrollViewPulseGeneratorDelegate {
    fun generatorHasDetectedMomentum(momentum: LNScrollViewMomentum): LNScrollViewMomentum
}

class LNScrollViewPulseGenerator {

    private var isOpen: Boolean = false
    var mass: Float = 1f
        set(value) {
            field = if (value < 1.0f) 1.0f else value
        }

    var delegate: WeakReference<LNScrollViewPulseGeneratorDelegate>? = null

    init {
        mass = 1f
        isOpen = false
    }

    fun generate(velocity: Float): Float {
        if (!isOpen) {
            return velocity
        }

        if (velocity <= 0) {
            return velocity
        }

        delegate?.get()?.let {
            val momentum = LNScrollViewMomentum().apply {
                this.mass = this@LNScrollViewPulseGenerator.mass
                this.velocity = velocity
            }
            val resultMomentum = it.generatorHasDetectedMomentum(momentum)
            return resultMomentum.velocity
        }

        return velocity
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
}
