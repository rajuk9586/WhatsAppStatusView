//
//  UpdatesVC.swift
//  WhatsAppStoryView
//
//  Created by Raju Kumar on 01/10/23.
//

import AVKit

//protocol for video loaded
protocol VideoPlayerViewDelegate: AnyObject {
    func videoLoaded()
}

final class VideoPlayerView: UIView {
    // MARK: - Constants
    private let timeObserverKeyPath: String = "timeControlStatus"

    // MARK: - Variables
    private var avPlayer: AVPlayer?
    private var avPlayerLayer: AVPlayerLayer?
    private weak var delegate: VideoPlayerViewDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        self.avPlayerLayer?.frame = self.bounds
    }

    // MARK: - Init & Deinit
    init(frame: CGRect, urlString: String, delegate: VideoPlayerViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate

        if let url = URL(string: urlString) {
            self.avPlayer = AVPlayer()

            guard let vplayer = avPlayer else { return }
            self.avPlayerLayer = AVPlayerLayer(player: vplayer)
            self.avPlayerLayer?.videoGravity = .resizeAspectFill

            guard let vl = self.avPlayerLayer else { return }
            layer.addSublayer(vl)

            avPlayer?.addObserver(self, forKeyPath: timeObserverKeyPath, options: [.old, .new], context: nil)

            let avItem = AVPlayerItem(url: url)
            vplayer.replaceCurrentItem(with: avItem)
            vplayer.play()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        if self.avPlayer?.observationInfo != nil {
            NotificationCenter.default.removeObserver(self)
        }
        self.avPlayer?.pause()
        self.avPlayerLayer?.player = nil
        self.avPlayerLayer?.removeFromSuperlayer()
        self.avPlayer = nil
        self.avPlayerLayer = nil
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let avPlayer = self.avPlayer, avPlayer.observationInfo != nil else { return }

        if keyPath == "timeControlStatus",
           let change = change,
           let newValue = change[NSKeyValueChangeKey.newKey] as? Int,
           let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {

            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                if newStatus == .playing {
                    avPlayer.seek(to: .zero)
                    avPlayer.removeObserver(self, forKeyPath: timeObserverKeyPath)
                    delegate?.videoLoaded()
                }
            }

        }
    }

    // MARK: - Functions
    //video Play
    func playVideo() {
        avPlayer?.play()
    }
   //audio Play
    func pauseVideo() {
        avPlayer?.pause()
    }
}
