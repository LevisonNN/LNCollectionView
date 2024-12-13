package com.ln.collectionview.scrollview.pulse

import java.lang.ref.WeakReference

class LNScrollViewPulseConvertor: LNScrollViewPulseGeneratorDelegate {

    private var generator: LNScrollViewPulseGenerator? = null
    private var pulser: LNScrollViewPulser? = null
    var isConversationOfEnergy: Boolean = false

    init {
        isConversationOfEnergy = false
    }

    fun bindGenerator(generator: LNScrollViewPulseGenerator) {
        this.generator?.delegate = null
        this.generator = generator
        generator.delegate = WeakReference(this)
    }

    fun bindPulser(pulser: LNScrollViewPulser) {
        this.pulser = pulser
    }

    override fun generatorHasDetectedMomentum(momentum: LNScrollViewMomentum): LNScrollViewMomentum {
        return if (isConversationOfEnergy) {
            val pulserMomentum = pulser?.getCurrentMomentum() ?: return LNScrollViewMomentum().apply {
                mass = momentum.mass
                velocity = 0f
            }
            val targetMomentum = LNScrollViewMomentum().apply {
                mass = pulserMomentum.mass
                velocity = (2 * momentum.mass * momentum.velocity + pulserMomentum.mass * pulserMomentum.velocity - momentum.mass * pulserMomentum.velocity) /
                        (momentum.mass + pulserMomentum.mass)
            }
            pulser?.updateMomentum(targetMomentum)

            val feedbackMomentum = LNScrollViewMomentum().apply {
                mass = momentum.mass
                velocity = (2 * pulserMomentum.mass * pulserMomentum.velocity + momentum.mass * momentum.velocity - pulserMomentum.mass * momentum.velocity) /
                        (momentum.mass + pulserMomentum.mass)
            }
            feedbackMomentum
        } else {
            val pulserMomentum = pulser?.getCurrentMomentum() ?: return LNScrollViewMomentum().apply {
                mass = momentum.mass
                velocity = 0f
            }
            val targetMomentum = LNScrollViewMomentum().apply {
                mass = pulserMomentum.mass
                velocity = (momentum.mass * momentum.velocity + pulserMomentum.mass * pulserMomentum.velocity) / pulserMomentum.mass
            }
            pulser?.updateMomentum(targetMomentum)

            val feedbackMomentum = LNScrollViewMomentum().apply {
                mass = momentum.mass
                velocity = 0f
            }
            feedbackMomentum
        }
    }
}
