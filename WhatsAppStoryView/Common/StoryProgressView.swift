//
//  UpdatesVC.swift
//  WhatsAppStoryView
//
//  Created by Raju Kumar on 01/10/23.
//

import UIKit

protocol SegmentedProgressBarDelegate: AnyObject {
    func segmentedProgressBarChangedIndex(index: Int)
    func segmentedProgressBarsFinished()
}

final class StoryProgressView: UIView {

    weak var delegate: SegmentedProgressBarDelegate?

    private var barsArr: [UIProgressView] = []

    private var padding: CGFloat = 8.0

    private var leftRightSpace: CGFloat = 10.0

    private var hasDoneLayout = false

    private var currentAnimationIndex = 0

    private var timer: Timer?

    private var paused = false

    private var timerRunning = false

    init(arrayStories: Int) {
        super.init(frame: .zero)

        for _ in 0...arrayStories - 1 {
            let bar = UIProgressView()
            self.barsArr.append(bar)
            addSubview(bar)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if self.hasDoneLayout { return }

        let barPadding = self.padding * CGFloat(self.barsArr.count - 1)
        let leftSpace = self.leftRightSpace * 2
        let frameWidth = frame.width - barPadding - leftSpace
        let width = frameWidth / CGFloat(self.barsArr.count)

        for (index, progressBar) in self.barsArr.enumerated() {

            let segFrame = CGRect(x: (CGFloat(index) * (width + self.padding)) + self.leftRightSpace, y: 0, width: width, height: 20)
            progressBar.frame = segFrame
            progressBar.progress = 0.0
            progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 1)
            progressBar.tintColor = .orange
            progressBar.backgroundColor = UIColor.lightGray
            progressBar.layer.cornerRadius = progressBar.frame.height / 2
        }

        self.hasDoneLayout = true
    }

    func animate(index: Int) {
        self.timer = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(updateProgressBar(_:)), userInfo: index, repeats: true)
        self.currentAnimationIndex = index
        self.timerRunning = true
    }

    @objc private func updateProgressBar(_ timer: Timer) {
        guard let selectdStoryIndex = timer.userInfo as? Int, let progressBar = self.barsArr.get(at: selectdStoryIndex) else { return }
        progressBar.progress += 0.005
        progressBar.setProgress(progressBar.progress, animated: false)

        if progressBar.progress == 1.0 {
            self.next()
        }
    }

    private func next() {
        let newIndex = self.currentAnimationIndex + 1
        self.timer?.invalidate()
        if newIndex < self.barsArr.count {
            self.animate(index: newIndex)
            self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
        } else {
            self.delegate?.segmentedProgressBarsFinished()
        }
    }

    func pause() {
        if !paused {
            self.paused = true
            self.timer?.invalidate()
        }
    }

    func resume() {
        if paused {
            self.paused = false
            self.animate(index: currentAnimationIndex)
        }
    }

    func resetBar() {
        for i in self.barsArr {
            i.progress = 0.0
        }
        self.timer?.invalidate()
        self.timerRunning = false
        self.currentAnimationIndex = 0
        self.paused = false
    }

    func skip() {
        self.paused = false
        guard let currentBar = self.barsArr.get(at: currentAnimationIndex) else { return }
        currentBar.progress = 1.0
        self.next()
    }

    func rewind() {
        self.paused = false
        guard let currentBar = self.barsArr.get(at: currentAnimationIndex) else { return }
        let newIndex = self.currentAnimationIndex - 1
        currentBar.progress = 0.0

        if newIndex < 0 {
            self.timer?.invalidate()
            self.delegate?.segmentedProgressBarsFinished()
            return
        }
        guard let prevBar = self.barsArr.get(at: newIndex) else { return }
        prevBar.setProgress(0.0, animated: false)
        self.timer?.invalidate()
        self.animate(index: newIndex)
        self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
    }
}
