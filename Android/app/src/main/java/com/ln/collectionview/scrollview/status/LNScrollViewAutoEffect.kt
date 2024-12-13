package com.ln.collectionview.scrollview.status

import android.graphics.Point
import android.graphics.PointF
import android.os.Looper
import android.util.Log
import android.util.Size
import android.util.SizeF
import com.ln.collectionview.scrollview.LNScrollViewRestStatus
import com.ln.collectionview.scrollview.simulator.LNScrollViewBounceSimulator
import com.ln.collectionview.scrollview.simulator.LNScrollViewDecelerateSimulator
import com.ln.collectionview.scrollview.simulator.LNScrollViewDragSimulator
import com.ln.collectionview.scrollview.simulator.LNScrollViewPageSimulator
import java.lang.ref.WeakReference
import com.ln.collectionview.scrollview.clock.LNScrollViewClock
import com.ln.collectionview.scrollview.clock.LNScrollViewClockProtocol
import com.ln.collectionview.scrollview.pulse.LNScrollViewPulseGenerator
import com.ln.collectionview.scrollview.pulse.LNScrollViewPulser
import com.ln.collectionview.scrollview.pulse.LNScrollViewPulserDelegate
import java.util.logging.Handler

const val LNScrollViewAutoEffectCommonTolerance = 0.001f

class LNScrollViewAutoEffectRestStatus {
    var leadingPoint: PointF = PointF(0f,0f)
    var trailingPoint: PointF = PointF(0f, 0f)
    var velocity: PointF = PointF(0f,0f)
    var offset: PointF = PointF(0f,0f)

    var contentSize: SizeF = SizeF(0f,0f)
    var frameSize: SizeF = SizeF(0f, 0f)
    var startPosition: PointF = PointF(0f, 0f)
}

interface LNScrollViewAutoEffectDataSource {

    fun autoEffectGetContentSize(effect: LNScrollViewAutoEffect): SizeF {
        return SizeF(0f,0f)
    }
    fun autoEffectGetFrameSize(effect: LNScrollViewAutoEffect): SizeF {
        return SizeF(0f, 0f)
    }
    fun autoEffectGetContentOffset(effect: LNScrollViewAutoEffect): PointF {
        return PointF(0f, 0f)
    }
    fun autoHorizontalDecelerateWith(
        effect: LNScrollViewAutoEffect,
        position: Float,
        velocity: Float
    ): LNScrollViewDecelerateSimulator? {
        return null
    }

    fun autoEffectVerticalDecelerateWith(
        effect: LNScrollViewAutoEffect,
        position: Float,
        velocity: Float
    ): LNScrollViewDecelerateSimulator? {
        return null
    }
}

interface LNScrollViewAutoEffectDelegate {
    fun autoEffectStatusDidChange(status: LNScrollViewAutoEffectRestStatus)
    fun autoEffectStatusHasFinished(effect: LNScrollViewAutoEffect)
}

class LNScrollViewAutoEffect: LNScrollViewClockProtocol, LNScrollViewPulserDelegate {
    var horizontalBounceSimulator: LNScrollViewBounceSimulator? = null
    var verticalBounceSimulator: LNScrollViewBounceSimulator? = null
    var horizontalDecelerateSimulator: LNScrollViewDecelerateSimulator? = null
    var verticalDecelerateSimulator: LNScrollViewDecelerateSimulator? = null
    var horizontalPageSimulator: LNScrollViewPageSimulator? = null
    var verticalPageSimulator: LNScrollViewPageSimulator? = null

    val topPulseGenerator: LNScrollViewPulseGenerator = LNScrollViewPulseGenerator()
    val leftPulseGenerator: LNScrollViewPulseGenerator = LNScrollViewPulseGenerator()
    val bottomPulseGenerator: LNScrollViewPulseGenerator = LNScrollViewPulseGenerator()
    val rightPulseGenerator: LNScrollViewPulseGenerator = LNScrollViewPulseGenerator()

    val topPulser: LNScrollViewPulser = LNScrollViewPulser().apply {
        delegate = WeakReference(this@LNScrollViewAutoEffect)
    }
    val leftPulser: LNScrollViewPulser = LNScrollViewPulser().apply {
        delegate = WeakReference(this@LNScrollViewAutoEffect)
    }
    val bottomPulser: LNScrollViewPulser = LNScrollViewPulser().apply {
        delegate = WeakReference(this@LNScrollViewAutoEffect)
    }
    val rightPulser: LNScrollViewPulser = LNScrollViewPulser().apply {
        delegate = WeakReference(this@LNScrollViewAutoEffect)
    }

    var restStatus: LNScrollViewAutoEffectRestStatus? = null
    var dataSource: WeakReference<LNScrollViewAutoEffectDataSource>? = null
    var delegate: WeakReference<LNScrollViewAutoEffectDelegate>? = null
    var pageEnable: Boolean = false
    var pageSwitchPercent = 0.2f
    var pageDamping: Float = 20f

    override fun pulserGetVelocity(pulser: LNScrollViewPulser): Float {
        if (restStatus == null) {
            return 0f
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        return when (pulser) {
            topPulser -> validRestStatus.velocity.y
            leftPulser -> validRestStatus.velocity.x
            bottomPulser -> -validRestStatus.velocity.y
            rightPulser -> -validRestStatus.velocity.x
            else -> 0f
        }
    }

    override fun pulserUpdateVelocity(pulser: LNScrollViewPulser, velocity: Float) {
        if (restStatus == null) {
            when (pulser) {
                topPulser -> startWithVelocity(PointF(0f, velocity))
                leftPulser -> startWithVelocity(PointF(velocity, 0f))
                bottomPulser -> startWithVelocity(PointF(0f, -velocity))
                rightPulser -> startWithVelocity(PointF(-velocity, 0f))
            }
            return
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        when (pulser) {
            topPulser -> validRestStatus.velocity = PointF(validRestStatus.velocity.x, velocity)
            leftPulser -> validRestStatus.velocity = PointF(velocity, validRestStatus.velocity.y)
            bottomPulser -> validRestStatus.velocity = PointF(validRestStatus.velocity.x, -velocity)
            rightPulser -> validRestStatus.velocity = PointF(-velocity, validRestStatus.velocity.y)
        }
        startWithVelocity(validRestStatus.velocity)
    }

    fun checkSizeValid(size: SizeF): Boolean {
        return size.width > 0 && size.height > 0
    }

    fun startWithVelocity(velocity: PointF): Boolean {
        finish()
        LNScrollViewClock.shareInstance().addObject(this)
        val dataSource = this.dataSource
        if (dataSource?.get() == null){
            return false
        }
        val validDataSource: LNScrollViewAutoEffectDataSource = dataSource.get() as LNScrollViewAutoEffectDataSource

        val contentSize = validDataSource.autoEffectGetContentSize(this)
        val frameSize = validDataSource.autoEffectGetFrameSize(this)
        val contentOffset = validDataSource.autoEffectGetContentOffset(this)

        restStatus = LNScrollViewAutoEffectRestStatus().apply {
            this.velocity= velocity
            this.contentSize = contentSize
            this.frameSize = frameSize
            this.startPosition = contentOffset
            this.leadingPoint = PointF(0f, 0f)  // Leading point (x, y)
            this.trailingPoint = PointF(contentSize.width - frameSize.width, contentSize.height - frameSize.height)  // Trailing point (x, y)
            this.offset = contentOffset
        }

        createHorizontalSimulatorIfNeeded()
        createVerticalSimulatorIfNeeded()

        return false
    }

    override fun scrollViewClockUpdateTimeInterval(time: Long) {
        var didStatusChange = false
        didStatusChange = updateVerticalDecelerateSimulator(time) || didStatusChange
        didStatusChange = updateVerticalBounceSimulator(time) || didStatusChange
        didStatusChange = updateVerticalPageSimulator(time) || didStatusChange
        didStatusChange = updateHorizontalDecelerateSimulator(time) || didStatusChange
        didStatusChange = updateHorizontalBounceSimulator(time) || didStatusChange
        didStatusChange = updateHorizontalPageSimulator(time) || didStatusChange

        if (didStatusChange &&
            delegate?.get() != null &&
            restStatus != null) {
            delegate?.get()!!.autoEffectStatusDidChange(restStatus!!)
        }
        checkFinished()
    }


    fun updateHorizontalDecelerateSimulator(time: Long): Boolean {
        if (restStatus == null) {
            return false
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        if (horizontalDecelerateSimulator != null) {
            horizontalDecelerateSimulator?.accumulate(time)
            validRestStatus.velocity = PointF(horizontalDecelerateSimulator!!.velocity, validRestStatus.velocity.y)
            validRestStatus.offset = PointF(horizontalDecelerateSimulator!!.position, validRestStatus.offset.y)

            if (validRestStatus.offset.x < validRestStatus.leadingPoint.x - LNScrollViewAutoEffectCommonTolerance) {
                if (validRestStatus.velocity.x < LNScrollViewAutoEffectCommonTolerance && leftPulseGenerator.openStatus()) {
                    validRestStatus.offset = PointF(validRestStatus.leadingPoint.x, validRestStatus.offset.y)
                    val feedbackVelocity = leftPulseGenerator.generate(Math.abs(validRestStatus.velocity.x))
                    if (feedbackVelocity >= -LNScrollViewAutoEffectCommonTolerance) {
                        validRestStatus.velocity = PointF(0f, validRestStatus.velocity.y)
                        horizontalDecelerateSimulator = null
                    } else {
                        startWithVelocity(PointF(-feedbackVelocity, validRestStatus.velocity.y))
                    }
                } else {
                    horizontalBounceSimulator = LNScrollViewBounceSimulator(
                        horizontalDecelerateSimulator!!.position,
                        horizontalDecelerateSimulator!!.velocity,
                        validRestStatus.leadingPoint.x
                    )
                    horizontalDecelerateSimulator = null
                }
            } else if (validRestStatus.offset.x > validRestStatus.trailingPoint.x + LNScrollViewAutoEffectCommonTolerance) {
                if (validRestStatus.velocity.x > LNScrollViewAutoEffectCommonTolerance && rightPulseGenerator.openStatus()) {
                    validRestStatus.offset = PointF(validRestStatus.trailingPoint.x, validRestStatus.offset.y)
                    val feedbackVelocity = rightPulseGenerator.generate(Math.abs(validRestStatus.velocity.x))
                    if (feedbackVelocity >= -LNScrollViewAutoEffectCommonTolerance) {
                        validRestStatus.velocity = PointF(0f, validRestStatus.velocity.y)
                        horizontalDecelerateSimulator = null
                    } else {
                        startWithVelocity(PointF(feedbackVelocity, validRestStatus.velocity.y))
                    }
                } else {
                    horizontalBounceSimulator = LNScrollViewBounceSimulator(
                        horizontalDecelerateSimulator!!.position,
                        horizontalDecelerateSimulator!!.velocity,
                        validRestStatus.trailingPoint.x
                    )
                    horizontalDecelerateSimulator = null
                }
            } else if (horizontalDecelerateSimulator!!.isFinished()) {
                horizontalDecelerateSimulator = null
            }
            return true
        }
        return false
    }


    fun updateHorizontalBounceSimulator(time: Long): Boolean {
        if (restStatus == null) {
            return false
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        horizontalBounceSimulator?.let {
            it.accumulate((time/1000f))
            validRestStatus.velocity = PointF(it.velocity, validRestStatus.velocity.y)
            validRestStatus.offset = PointF(it.position(), validRestStatus.offset.y)
            if (it.isFinished()) {
                horizontalBounceSimulator = null
            }
            return true
        }
        return false
    }

    fun updateHorizontalPageSimulator(time: Long): Boolean {
        if (restStatus == null) {
            return false
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        horizontalPageSimulator?.let {
            it.accumulate(time/1000f)
            validRestStatus.velocity = PointF(it.velocity, validRestStatus.velocity.y)
            validRestStatus.offset = PointF(it.position(), validRestStatus.offset.y)
            if (it.isFinished()) {
                horizontalPageSimulator = null
            }
            return true
        }
        return false
    }

    fun updateVerticalDecelerateSimulator(time: Long): Boolean {
        if (restStatus == null) {
            return false
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        if (verticalDecelerateSimulator != null) {
            verticalDecelerateSimulator?.accumulate(time)
            validRestStatus.offset = PointF(validRestStatus.offset.x, verticalDecelerateSimulator!!.position)
            validRestStatus.velocity = PointF(validRestStatus.velocity.x, verticalDecelerateSimulator!!.velocity)

            if (validRestStatus.offset.y < validRestStatus.leadingPoint.y - LNScrollViewAutoEffectCommonTolerance) {
                if (validRestStatus.velocity.y < LNScrollViewAutoEffectCommonTolerance && topPulseGenerator.openStatus()) {
                    validRestStatus.offset = PointF(validRestStatus.offset.x, validRestStatus.leadingPoint.y)
                    val feedbackVelocity = topPulseGenerator.generate(Math.abs(validRestStatus.velocity.y))
                    if (feedbackVelocity >= -LNScrollViewAutoEffectCommonTolerance) {
                        validRestStatus.velocity = PointF(validRestStatus.velocity.x, 0f)
                        verticalDecelerateSimulator = null
                    } else {
                        startWithVelocity(PointF(validRestStatus.velocity.x, -feedbackVelocity))
                    }
                } else {
                    verticalBounceSimulator = LNScrollViewBounceSimulator(
                        verticalDecelerateSimulator!!.position,
                        verticalDecelerateSimulator!!.velocity,
                        validRestStatus.leadingPoint.y
                    )
                    verticalDecelerateSimulator = null
                }
            } else if (validRestStatus.offset.y > validRestStatus.trailingPoint.y + LNScrollViewAutoEffectCommonTolerance) {
                if (validRestStatus.velocity.y > LNScrollViewAutoEffectCommonTolerance && bottomPulseGenerator.openStatus()) {
                    validRestStatus.offset = PointF(validRestStatus.offset.x, validRestStatus.trailingPoint.y)
                    val feedbackVelocity = bottomPulseGenerator.generate(Math.abs(validRestStatus.velocity.y))
                    if (feedbackVelocity >= -LNScrollViewAutoEffectCommonTolerance) {
                        validRestStatus.velocity = PointF(validRestStatus.velocity.x, 0f)
                        verticalDecelerateSimulator = null
                    } else {
                        startWithVelocity(PointF(validRestStatus.velocity.x, feedbackVelocity))
                    }
                } else {
                    verticalBounceSimulator = LNScrollViewBounceSimulator(
                        verticalDecelerateSimulator!!.position,
                        verticalDecelerateSimulator!!.velocity,
                        validRestStatus.trailingPoint.y
                    )
                    verticalDecelerateSimulator = null
                }
            } else if (verticalDecelerateSimulator!!.isFinished()) {
                verticalDecelerateSimulator = null
            }
            return true
        }
        return false
    }

    fun updateVerticalBounceSimulator(time: Long): Boolean {
        if (restStatus == null) {
            return false
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        verticalBounceSimulator?.let {
            it.accumulate((time/1000f))
            validRestStatus.velocity = PointF(validRestStatus.velocity.x, it.velocity)
            validRestStatus.offset = PointF(validRestStatus.offset.x, it.position())
            if (it.isFinished()) {
                verticalBounceSimulator = null
            }
            return true
        }
        return false
    }

    fun updateVerticalPageSimulator(time: Long): Boolean {
        if (restStatus == null) {
            return false
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        verticalPageSimulator?.let {
            it.accumulate(time/1000f)
            validRestStatus.velocity = PointF(validRestStatus.velocity.x, it.velocity)
            validRestStatus.offset = PointF(validRestStatus.offset.x, it.position())
            if (it.isFinished()) {
                verticalPageSimulator = null
            }
            return true
        }
        return false
    }

    //create
    fun createHorizontalSimulatorIfNeeded() {
        if (restStatus == null) {
            return
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        if (validRestStatus.contentSize.width > validRestStatus.frameSize.width + LNScrollViewAutoEffectCommonTolerance) {
            if (validRestStatus.startPosition.x < validRestStatus.leadingPoint.x - LNScrollViewAutoEffectCommonTolerance) {
                createHorizontalBounceSimulator(false)
            } else if (validRestStatus.startPosition.x > validRestStatus.trailingPoint.x + LNScrollViewAutoEffectCommonTolerance) {
                createHorizontalBounceSimulator(true)
            } else {
                if (pageEnable) {
                    createHorizontalPageSimulator()
                } else {
                    createHorizontalDecelerateSimulator()
                }
            }
        }
    }

    fun createHorizontalBounceSimulator(isTrailing: Boolean) {
        if (restStatus == null) {
            return
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        val targetPosition = if (isTrailing) {
            validRestStatus.trailingPoint.x
        } else {
            validRestStatus.leadingPoint.x
        }

        horizontalBounceSimulator = LNScrollViewBounceSimulator(
            validRestStatus.startPosition.x,
            validRestStatus.velocity.x,
            targetPosition
        )
    }

    fun createHorizontalDecelerateSimulator() {
        if (restStatus == null) {
            return
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        var simulator: LNScrollViewDecelerateSimulator? = null
        if (dataSource?.get() != null) {
            val validDataSource: LNScrollViewAutoEffectDataSource = dataSource?.get() as LNScrollViewAutoEffectDataSource
            simulator = validDataSource.autoHorizontalDecelerateWith(
                this,
                validRestStatus.startPosition.x,
                validRestStatus.velocity.x)
        }
        if (simulator != null) {
            horizontalDecelerateSimulator = simulator
        } else {
            horizontalDecelerateSimulator = LNScrollViewDecelerateSimulator(
                validRestStatus.startPosition.x,
                validRestStatus.velocity.x
            )
        }
    }

    fun createHorizontalPageSimulatorTo(targetPosition: Float) {
        if (restStatus == null) {
            return
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        horizontalPageSimulator = LNScrollViewPageSimulator(
            validRestStatus.startPosition.x,
            validRestStatus.velocity.x,
            targetPosition,
            pageDamping
        )
    }

    fun validPositionForHorizontalPage(pageIndex: Int): Float {
        if (restStatus == null) {
            return 0f
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        val pageSize = validRestStatus.frameSize.width
        return Math.max(validRestStatus.leadingPoint.x, Math.min(pageIndex * pageSize.toFloat(), validRestStatus.trailingPoint.x))
    }

    fun createHorizontalPageSimulator() {
        if (restStatus == null) {
            return
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        val pageSize = validRestStatus.frameSize.width
        val pageIndex = Math.floor(validRestStatus.startPosition.x / pageSize.toDouble()).toInt()
        val restOffset = validRestStatus.startPosition.x - pageIndex * pageSize
        if (validRestStatus.velocity.x <= 0) {
            if (restOffset < pageSize * (1 - pageSwitchPercent)) {
                val targetPosition = validPositionForHorizontalPage(pageIndex)
                createHorizontalPageSimulatorTo(targetPosition)
            } else {
                val targetOffset = LNScrollViewPageSimulator.targetOffsetWithVelocity(
                    validRestStatus.velocity.x,
                    restOffset,
                    pageDamping
                )
                if (targetOffset < pageSize * (1 - pageSwitchPercent)) {
                    val targetPosition = validPositionForHorizontalPage(pageIndex)
                    createHorizontalPageSimulatorTo(targetPosition)
                } else {
                    val targetPosition = validPositionForHorizontalPage(pageIndex + 1)
                    createHorizontalPageSimulatorTo(targetPosition)
                }
            }
        } else {
            if (restOffset > pageSize * pageSwitchPercent) {
                val targetPosition = validPositionForHorizontalPage(pageIndex + 1)
                createHorizontalPageSimulatorTo(targetPosition)
            } else {
                val targetOffset = LNScrollViewPageSimulator.targetOffsetWithVelocity(
                    validRestStatus.velocity.x,
                    restOffset,
                    pageDamping
                )
                if (targetOffset > pageSize * pageSwitchPercent) {
                    val targetPosition = validPositionForHorizontalPage(pageIndex + 1)
                    createHorizontalPageSimulatorTo(targetPosition)
                } else {
                    val targetPosition = validPositionForHorizontalPage(pageIndex)
                    createHorizontalPageSimulatorTo(targetPosition)
                }
            }
        }
    }


    fun createVerticalSimulatorIfNeeded() {
        if (restStatus == null) {
            return
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        if (validRestStatus.contentSize.height > validRestStatus.frameSize.height + LNScrollViewAutoEffectCommonTolerance) {
            if (validRestStatus.startPosition.y < validRestStatus.leadingPoint.y - LNScrollViewAutoEffectCommonTolerance) {
                createVerticalBounceSimulator(false)
            } else if (validRestStatus.startPosition.y > validRestStatus.trailingPoint.y + LNScrollViewAutoEffectCommonTolerance) {
                createVerticalBounceSimulator(true)
            } else {
                if (pageEnable) {
                    createVerticalPageSimulator()
                } else {
                    createVerticalDecelerateSimulator()
                }
            }
        }
    }

    // 创建垂直方向的弹性模拟器
    fun createVerticalBounceSimulator(isTrailing: Boolean) {
        if (restStatus == null) {
            return
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        val targetPosition = if (isTrailing) validRestStatus.trailingPoint.y else validRestStatus.leadingPoint.y
        verticalBounceSimulator = LNScrollViewBounceSimulator(
            validRestStatus.startPosition.y,
            validRestStatus.velocity.y,
            targetPosition
        )
    }

    fun createVerticalDecelerateSimulator() {
        if (restStatus == null) {
            return
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        var simulator: LNScrollViewDecelerateSimulator? = null
        if (dataSource?.get() != null) {
            val validDataSource: LNScrollViewAutoEffectDataSource = dataSource?.get() as LNScrollViewAutoEffectDataSource
            simulator = validDataSource.autoHorizontalDecelerateWith(
                this,
                validRestStatus.startPosition.y,
                validRestStatus.velocity.y)
        }
        if (simulator != null) {
            verticalDecelerateSimulator = simulator
        } else {
            verticalDecelerateSimulator = LNScrollViewDecelerateSimulator(
                validRestStatus.startPosition.y,
                validRestStatus.velocity.y
            )
        }
    }

    fun createVerticalPageSimulatorTo(targetPosition: Float) {
        if (restStatus == null) {
            return
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        verticalPageSimulator = LNScrollViewPageSimulator(
            validRestStatus.startPosition.y,
            validRestStatus.velocity.y,
            targetPosition,
            pageDamping
        )
    }

    fun validPositionForVerticalPage(pageIndex: Int): Float {
        if (restStatus == null) {
            return 0f
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        val pageSize = validRestStatus.frameSize.height
        return Math.max(validRestStatus.leadingPoint.y, Math.min(pageIndex * pageSize.toFloat(), validRestStatus.trailingPoint.y))
    }

    // 创建垂直分页模拟器
    fun createVerticalPageSimulator() {
        if (restStatus == null) {
            return
        }
        val validRestStatus = restStatus as LNScrollViewAutoEffectRestStatus
        val pageSize = validRestStatus.frameSize.height
        var pageIndex = Math.floor(validRestStatus.startPosition.y / pageSize.toDouble()).toInt()
        val restOffset = validRestStatus.startPosition.y - pageIndex * pageSize
        if (validRestStatus.velocity.y <= 0) {
            if (restOffset < pageSize * (1 - pageSwitchPercent)) {
                val targetPosition = validPositionForVerticalPage(pageIndex)
                createVerticalPageSimulatorTo(targetPosition)
            } else {
                val targetOffset = LNScrollViewPageSimulator.targetOffsetWithVelocity(
                    validRestStatus.velocity.y,
                    restOffset,
                    pageDamping
                )
                if (targetOffset < pageSize * (1 - pageSwitchPercent)) {
                    val targetPosition = validPositionForVerticalPage(pageIndex)
                    createVerticalPageSimulatorTo(targetPosition)
                } else {
                    val targetPosition = validPositionForVerticalPage(pageIndex + 1)
                    createVerticalPageSimulatorTo(targetPosition)
                }
            }
        } else {
            if (restOffset > pageSize * pageSwitchPercent) {
                val targetPosition = validPositionForVerticalPage(pageIndex + 1)
                createVerticalPageSimulatorTo(targetPosition)
            } else {
                val targetOffset = LNScrollViewPageSimulator.targetOffsetWithVelocity(
                    validRestStatus.velocity.y,
                    restOffset,
                    pageDamping
                )
                if (targetOffset > pageSize * pageSwitchPercent) {
                    val targetPosition = validPositionForVerticalPage(pageIndex + 1)
                    createVerticalPageSimulatorTo(targetPosition)
                } else {
                    val targetPosition = validPositionForVerticalPage(pageIndex)
                    createVerticalPageSimulatorTo(targetPosition)
                }
            }
        }
    }

    fun checkFinished() {
        if (hasFinished()) {
            finish()
            if (delegate?.get() != null) {
                val validDelegate = delegate?.get() as LNScrollViewAutoEffectDelegate
                validDelegate.autoEffectStatusHasFinished(this)
            }
        }
    }

    fun hasFinished(): Boolean {
        if (horizontalDecelerateSimulator != null) {
            val simulator = horizontalDecelerateSimulator as LNScrollViewDecelerateSimulator
            if (!simulator.isFinished()) {
                return false
            }
        }

        if (horizontalBounceSimulator != null) {
            val simulator = horizontalBounceSimulator as LNScrollViewBounceSimulator
            if (!simulator.isFinished()) {
                return false
            }
        }

        if (horizontalPageSimulator != null) {
            val simulator = horizontalPageSimulator as LNScrollViewPageSimulator
            if (!simulator.isFinished()) {
                return false
            }
        }

        if (verticalDecelerateSimulator != null) {
            val simulator = verticalDecelerateSimulator as LNScrollViewDecelerateSimulator
            if (!simulator.isFinished()) {
                return false
            }
        }

        if (verticalBounceSimulator != null) {
            val simulator = verticalBounceSimulator as LNScrollViewBounceSimulator
            if (!simulator.isFinished()) {
                return false
            }
        }

        if (verticalPageSimulator != null) {
            val simulator = verticalPageSimulator as LNScrollViewPageSimulator
            if (!simulator.isFinished()) {
                return false
            }
        }
        return true
    }

    fun finishForcely() {
        finish()
    }

    fun finish() {
        horizontalBounceSimulator = null
        horizontalDecelerateSimulator = null
        horizontalPageSimulator = null
        verticalBounceSimulator = null
        verticalDecelerateSimulator = null
        verticalPageSimulator = null

        restStatus = null

        LNScrollViewClock.shareInstance().removeObject(this)
    }
}