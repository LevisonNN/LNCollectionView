package com.ln.collectionview.scrollview.simulator

class LNScrollViewDragSimulator(
    val leadingPoint: Float,
    val trailingPoint: Float,
    val startPoint: Float
) {
    private var offset: Float = 0f
    private var resultOffset: Float = 0f
    private val k: Float = 0.0001f
    private val b: Float = 0.55f

    fun updateOffset(offset: Float) {
        this.offset = offset
        val targetPoint = startPoint - offset

        if (startPoint < leadingPoint) {
            val revertOutside = revertScaleOutsidePart(leadingPoint - startPoint)
            resultOffset = if (-offset > revertOutside) {
                leadingPoint - offset - revertOutside
            } else {
                val targetRevert = revertOutside + offset
                val scaleTargetRevert = scaleOutsidePart(targetRevert)
                leadingPoint - scaleTargetRevert
            }
        } else if (startPoint > trailingPoint) {
            val revertOutside = revertScaleOutsidePart(startPoint - trailingPoint)
            resultOffset = if (offset > revertOutside) {
                trailingPoint - offset + revertOutside
            } else {
                val targetRevert = revertOutside - offset
                val scaleTargetRevert = scaleOutsidePart(targetRevert)
                trailingPoint + scaleTargetRevert
            }
        } else {
            if (targetPoint < leadingPoint) {
                val outsidePart = leadingPoint - targetPoint
                val scaleOutsidePart = scaleOutsidePart(outsidePart)
                resultOffset = leadingPoint - scaleOutsidePart
            } else if (targetPoint > trailingPoint) {
                val outsidePart = targetPoint - trailingPoint
                val scaleOutsidePart = scaleOutsidePart(outsidePart)
                resultOffset = trailingPoint + scaleOutsidePart
            } else {
                resultOffset = targetPoint
            }
        }
    }

    private fun revertScaleOutsidePart(outsidePart: Float): Float {
        return outsidePart / (b - k * outsidePart)
    }

    private fun scaleOutsidePart(outsidePart: Float): Float {
        return (b * outsidePart) / (1 + k * outsidePart)
    }

    fun getResultOffset(): Float {
        return resultOffset
    }
}
