//
//  StoryVC.swift
//  WhatsAppStoryView
//
//  Created by Raju Kumar on 01/10/23.
//

import UIKit

class StoryVC: UIViewController {
    
    //MARK: -IBoutlets
    @IBOutlet weak private var storyCollectionVw: UICollectionView!
    
    //MARK: -Variables
    private var needsDelayedScrolling = false
    private var firstLaunch = true
    var selectedStoryIndex = 0
    var arrayStories: [StatusModel] = []
    private var currentStoryIndex: Int?
    private var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    private var displayBlurAtHeight: CGFloat = 200
    
    //MARK: -Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        needsDelayedScrolling = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = IndexPath(item: self.selectedStoryIndex, section: 0)
        self.storyCollectionVw.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.needsDelayedScrolling {
            self.needsDelayedScrolling = !self.needsDelayedScrolling
            let indexPath = IndexPath(item: self.selectedStoryIndex, section: 0)
            self.storyCollectionVw.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
   
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let cell = self.storyCollectionVw.visibleCells.get(at: 0) as? StoryCVCell else { return }
        cell.progressBar?.resetBar()
    }
    
    // MARK: - Function
    private func setupUI() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(self.swipeDown(_:)))
        self.view.addGestureRecognizer(recognizer)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        self.registerNib()
    }
    
    private func registerNib() {
        self.storyCollectionVw.delegate = self
        self.storyCollectionVw.dataSource = self
        self.storyCollectionVw.register(UINib(nibName: "StoryCVCell", bundle: nil), forCellWithReuseIdentifier: "StoryCVCell")
//        self.configureCompositionalLayout()
        self.storyCollectionVw.isPagingEnabled = true
    }
    
    private func configureCompositionalLayout() {
        let collection_layout = UICollectionViewCompositionalLayout {sectionIndex, environment in
                return Layouts.shared.storyListLayout()
        }
        self.storyCollectionVw.setCollectionViewLayout(collection_layout, animated: true)
    }
    
    private func panGestureStateChange(touchPoint: CGPoint) {
        if touchPoint.y - initialTouchPoint.y > 0 {
            self.storyCollectionVw.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y + 0, width:  self.storyCollectionVw.frame.size.width, height:  self.storyCollectionVw.frame.size.height)
            view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 1 - (touchPoint.y - initialTouchPoint.y) / displayBlurAtHeight)
        }
    }

    private func panGestureStateCancelledAndEnded(touchPoint: CGPoint) {
        if touchPoint.y - initialTouchPoint.y > displayBlurAtHeight {
            dismiss(animated: true, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = .black
                self.storyCollectionVw.frame = CGRect(x: 0, y: 0, width:  self.storyCollectionVw.frame.size.width, height:  self.storyCollectionVw.frame.size.height)
            })
        }
    }

    private func scrollDidEndDeceleratingAndDidEndScrollAnimation() {
        self.storyCollectionVw.isUserInteractionEnabled = true
        var cell: StoryCVCell
        let visibleCells =  self.storyCollectionVw.visibleCells

        if visibleCells.count > 1 {
            guard let mostVisableCell = scrollToMostVisibleCell(), let storyCell =   self.storyCollectionVw.cellForItem(at: mostVisableCell) as? StoryCVCell else { return }
            cell = storyCell
        } else {
            guard let storyCell = visibleCells.first as? StoryCVCell else { return }
            cell = storyCell
        }

        if cell.parentStoryIndex != currentStoryIndex {
            cell.progressBar?.resetBar()
            cell.progressBar?.animate(index: 0)
            cell.progressBar?.delegate?.segmentedProgressBarChangedIndex(index: 0)
            currentStoryIndex = cell.parentStoryIndex
        }
    }

    
    // MARK: - @objc Functions/Actions
    @objc private func swipeDown(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: view?.window)
        if sender.state == .began {
            self.initialTouchPoint = touchPoint
        } else if sender.state == .changed {
            self.panGestureStateChange(touchPoint: touchPoint)
        } else if sender.state == .ended || sender.state == .cancelled {
            self.panGestureStateCancelledAndEnded(touchPoint: touchPoint)
        }
    }

    @objc private func appMovedToBackground() {
        guard let cell = self.storyCollectionVw.visibleCells.get(at: 0) as? StoryCVCell else { return }
        cell.progressBar?.pause()
    }

   
}

extension StoryVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.arrayStories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCVCell", for: indexPath) as? StoryCVCell else { return .init()}
        cell.parentStoryIndex = indexPath.row
        cell.story = arrayStories.get(at: indexPath.row)?.story
        cell.initProgressbar()
        cell.delegate = self

        if firstLaunch && selectedStoryIndex == indexPath.row {
            cell.progressBar?.resetBar()
            cell.progressBar?.animate(index: 0)
            firstLaunch = false
            currentStoryIndex = selectedStoryIndex
        }

        if arrayStories[indexPath.row].story?.get(at: 0)?.type == "image" {
            if let videoURL = arrayStories.get(at: indexPath.row)?.story?.get(at: 0)?.url {
                cell.loadImage(urlString: videoURL)
            }
        } else {
            if let videoURL = arrayStories.get(at: indexPath.row)?.story?.get(at: 0)?.url {
                cell.loadVideo(urlString: videoURL)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      return CGSize(width: self.storyCollectionVw.frame.width, height: self.storyCollectionVw.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    

    //Scrolling Functions
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDidEndDeceleratingAndDidEndScrollAnimation()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.selectedStoryIndex == 0 && !self.firstLaunch {
            self.storyCollectionVw.isUserInteractionEnabled = false
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollDidEndDeceleratingAndDidEndScrollAnimation()
    }

    func scrollToMostVisibleCell() -> IndexPath? {
        let visibleRect = CGRect(origin: self.storyCollectionVw.contentOffset, size: self.storyCollectionVw.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath: IndexPath = self.storyCollectionVw.indexPathForItem(at: visiblePoint) {
            return visibleIndexPath
        } else {
            return nil
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let oldCell = cell as? StoryCVCell else { return }
        oldCell.progressBar?.resetBar()
    }
}

// MARK: - StoryCVCell delegates
extension StoryVC: StoryPreviewProtocol {
    func didStoryViewEnd() {
        dismiss(animated: true, completion: nil)
    }
}
