//
//  StoryCVCell.swift
//  WhatsAppStoryView
//
//  Created by Raju Kumar on 01/10/23.
//

import UIKit

protocol StoryPreviewProtocol: AnyObject {
    func didStoryViewEnd()
}

class StoryCVCell: UICollectionViewCell {
    
    //MARK: -IBOutlets
    @IBOutlet weak private var progressVw: UIView!
    @IBOutlet weak private var imgVw: UIImageView!
    @IBOutlet weak private var videoVw: UIView!
    @IBOutlet weak private var indicatorVw: UIActivityIndicatorView!
    
    //MARK: -Variables
    weak var delegate: StoryPreviewProtocol?
    var progressBar: StoryProgressView?
    var story: [StoryModel]?
    var parentStoryIndex: Int = 0
    private var requestCount = 0
    private let defaultSession = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?
    private var videoPlayerView: VideoPlayerView?
    private var longGesture: UILongPressGestureRecognizer!

    //MARK: -Lifecycles
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.removeGestureRecognizer(longGesture)
        self.dataTask?.cancel()
        progressBar?.resetBar()
    }
    
    // MARK: - Function
    private func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touch(_:)))
        self.addGestureRecognizer(tapGesture)

        self.longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.longGesture.minimumPressDuration = 0.2
    }
    
    func initProgressbar() {
        self.progressBar = StoryProgressView(arrayStories: story?.count ?? 0)
        self.progressBar?.delegate = self
        self.progressBar?.frame = CGRect(x: 0, y: 0, width: frame.width, height: 4)
        self.progressVw.subviews.forEach { $0.removeFromSuperview() }
        self.progressVw.addSubview(progressBar!)
    }

    private func loadImageFromUrl(urlString: String, completion: ((Bool) -> Void)?) {
        if let url = URL(string: urlString) {
            self.dataTask = self.defaultSession.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.imgVw.image = UIImage(data: data)
                        completion?(true)
                    }
                } else {
                    completion?(false)
                }
            }
            dataTask?.resume()

        } else {
            completion?(false)
        }
    }

    private func requestImage(url: String) {
        self.removeGestureRecognizer(longGesture)
        requestCount += 1
        loadImageFromUrl(urlString: url) { (_) in
            DispatchQueue.main.async {
                self.requestCount -= 1
                self.progressBar?.resume()
                self.indicatorVw.stopAnimating()
                self.indicatorVw.isHidden = true
                self.addGestureRecognizer(self.longGesture)
            }
        }
    }

    func loadImage(urlString: String) {
        self.videoVw.isHidden = true
        self.imgVw.isHidden = false
        self.imgVw.image = nil
        self.indicatorVw.isHidden = false
        self.indicatorVw.startAnimating()
        self.progressBar?.pause()
        self.requestCount = self.requestCount == 0 ? 1 : 0
        if self.requestCount != 0 {
            dataTask?.cancel()
        }
        requestImage(url: urlString)
    }

    func resetVideoView() {
        self.videoVw.subviews.forEach({ $0.removeFromSuperview() })
        self.videoPlayerView = nil
    }

    func loadVideo(urlString: String) {
        self.removeGestureRecognizer(longGesture)
        self.indicatorVw.startAnimating()
        self.indicatorVw.isHidden = false
        self.progressBar?.pause()
        self.videoVw.isHidden = false
        self.imgVw.isHidden = true
        resetVideoView()
        videoPlayerView = VideoPlayerView(frame: contentView.bounds, urlString: urlString, delegate: self)
        self.videoVw.addSubViewWithAutolayout(subView: videoPlayerView!)
    }
    
    // MARK: - Objc Functions
    @objc private func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            videoPlayerView?.pauseVideo()
            progressBar?.pause()
        } else if sender.state == .ended {
            videoPlayerView?.playVideo()
            progressBar?.resume()
        }
    }

    @objc private func touch(_ sender: UITapGestureRecognizer) {
        let touch = sender.location(in: self)
        let screenWidthOneThird = self.frame.width / 3
        let absoluteTouch = touch.x

        if absoluteTouch < screenWidthOneThird {
            videoPlayerView?.pauseVideo()
            self.progressBar?.rewind()
        } else {
            videoPlayerView?.pauseVideo()
            self.progressBar?.skip()
        }
    }


}

// MARK: - SegmentedProgressBarDelegate
extension StoryCVCell: SegmentedProgressBarDelegate {
    func segmentedProgressBarChangedIndex(index: Int) {
        videoPlayerView?.pauseVideo()
        guard let urlStory = story?.get(at: index)?.url else { return }
        if story?.get(at: index)?.type == "image" {
            loadImage(urlString: urlStory)
        } else {
            loadVideo(urlString: urlStory)
        }
    }

    func segmentedProgressBarsFinished() {
        prepareForReuse()
        self.delegate?.didStoryViewEnd()
    }
}

// MARK: - VideoPlayerViewDelegate & Video Functions
extension StoryCVCell: VideoPlayerViewDelegate {

    func videoLoaded() {
        self.indicatorVw.stopAnimating()
        self.indicatorVw.isHidden = true
        self.progressBar?.resume()
        self.addGestureRecognizer(longGesture)
    }
}
