//
//  Extensions.swift
//  iOS Assignment
//
//  Created by Raju Kumar on 07/09/23.
//


import Foundation
import UIKit


var imageCache = NSCache<AnyObject, AnyObject>()
private var activityIndicatorKey: UInt8 = 0

extension UICollectionView {
    func animateCollectionViewCells() {
        let visibleCells = self.visibleCells
        
        for (index, cell) in visibleCells.enumerated() {
            cell.transform = CGAffineTransform(translationX: self.bounds.width, y: 0)
            UIView.animate(withDuration: 2.0, delay: 0.1 * Double(index), usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
    func verticallyAnimateCollectionViewCells() {
        let visibleCells = self.visibleCells
        
        for (index, cell) in visibleCells.enumerated() {
            cell.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
            UIView.animate(withDuration: 1.0, delay: 0.1 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
}

extension Collection {
    func get(at index: Index) -> Iterator.Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}


extension UIColor {
    static var iconColor: UIColor { get { UIColor(named: "Icon_color") ?? UIColor(red: 84/255, green: 22/255, blue: 109/255, alpha: 1)}}
    
    static var iconSelectedColor: UIColor { get { UIColor(named: "Icon_selected_color") ?? UIColor(red: 244/255, green: 211/255, blue: 71/255, alpha: 1)}}
}

//MARK: - UIView
extension UIView {
    //add view in subview with auto layout
    func addSubViewWithAutolayout(subView: UIView) {
        addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        subView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        subView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        subView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        subView.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
    //MARK: - Corners
    @objc public var cornerRadius: CGFloat {
        get { self.layer.cornerRadius }
        set { self.layer.cornerRadius = newValue }
    }
    
    
    //MARK: - Shadows
    @objc public var shadowColor: UIColor {
        get {
            self.layer.shadowColor != nil
            ? UIColor(cgColor: self.layer.shadowColor!)
            : UIColor.gray
        }
        set { self.layer.shadowColor = newValue.cgColor }
    }
    
    @objc public var shadowOffset: CGSize {
        get { self.layer.shadowOffset }
        set { self.layer.shadowOffset = newValue }
    }
    
    @objc public var maskToBounds: Bool {
        get { self.layer.masksToBounds }
        set { self.layer.masksToBounds = newValue }
    }
    
    @objc public var shadowRadius: CGFloat {
        get { self.layer.shadowRadius }
        set { self.layer.shadowRadius = newValue }
    }
    
    @objc public var shadowOpacity: Float {
        get { self.layer.shadowOpacity }
        set { self.layer.shadowOpacity = newValue }
    }
}

//MARK: - UiimageView
extension UIImageView {
    private var activityIndicator: UIActivityIndicatorView? {
            get {
                return objc_getAssociatedObject(self, &activityIndicatorKey) as? UIActivityIndicatorView
            }
            set {
                objc_setAssociatedObject(self, &activityIndicatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    
    func downloadImage(url: String?, image: UIImage = UIImage(named: "image_NA") ?? UIImage(), completion: ()->Void) {
        self.image = nil
        
        // Remove any existing activity indicator view
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
        
        guard let urlString = url else {
            return
        }
        
        //retrieve image from imageCache variable
        if let image = imageCache.object(forKey: urlString as NSString) {
            self.image = image as? UIImage
            return // Image found in cache, no need to show the activity indicator.
        }
        
        if let url = URL(string: url ?? "") {
            // Create and add the activity indicator view
            let indicatorSize: CGFloat = 40.0
            let indicatorFrame = CGRect(x: (frame.width - indicatorSize) / 2, y: (frame.height - indicatorSize) / 2, width: indicatorSize, height: indicatorSize)
            let indicator = UIActivityIndicatorView(frame: indicatorFrame)
            indicator.color = UIColor.black
            indicator.style = .large
            indicator.startAnimating()
            addSubview(indicator)
            self.activityIndicator = indicator
            
            DispatchQueue.global().async { [weak self] in
                //download image
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        //update ui: set image in main queue
                        DispatchQueue.main.async {
                            //store image in cache memory imageCache
                            imageCache.setObject(image, forKey: urlString as NSString)
                            //set image
                            self?.image = image
                            
                            // Hide the activity indicator view after image download is completed.
                            self?.activityIndicator?.stopAnimating()
                            self?.activityIndicator?.removeFromSuperview()
                            self?.activityIndicator = nil
                        }
                    }else {
                        DispatchQueue.main.async {
                            //store image in cache memory imageCache
                            imageCache.setObject(image, forKey: urlString as NSString)
                            //set image
                            self?.image = image
                            
                            // Hide the activity indicator view after image download is completed.
                            self?.activityIndicator?.stopAnimating()
                            self?.activityIndicator?.removeFromSuperview()
                            self?.activityIndicator = nil
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        //store image in cache memory imageCache
                        imageCache.setObject(image, forKey: urlString as NSString)
                        //set image
                        self?.image = image
                        
                        // Hide the activity indicator view after image download is completed.
                        self?.activityIndicator?.stopAnimating()
                        self?.activityIndicator?.removeFromSuperview()
                        self?.activityIndicator = nil
                    }
                }
            }
        } else {
            // In case of an invalid URL or any other error while fetching the image, display a placeholder image.
            self.image = image
        }
        completion()
    }
    
    func downloadImage(url: String?, image: UIImage = UIImage(named: "image_NA") ?? UIImage()) {
        self.image = nil
        
        // Remove any existing activity indicator view
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
        
        guard let urlString = url else {
            return
        }
        
        //retrieve image from imageCache variable
        if let image = imageCache.object(forKey: urlString as NSString) {
            self.image = image as? UIImage
            return // Image found in cache, no need to show the activity indicator.
        }
        
        if let url = URL(string: url ?? "") {
            // Create and add the activity indicator view
            let indicatorSize: CGFloat = 40.0
            let indicatorFrame = CGRect(x: (frame.width - indicatorSize) / 2, y: (frame.height - indicatorSize) / 2, width: indicatorSize, height: indicatorSize)
            let indicator = UIActivityIndicatorView(frame: indicatorFrame)
            indicator.color = UIColor(red: 115/255, green: 0/255, blue: 241/255, alpha: 1.0)
            indicator.style = .large
            indicator.startAnimating()
            addSubview(indicator)
            self.activityIndicator = indicator
            
            DispatchQueue.global().async { [weak self] in
                //download image
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        //update ui: set image in main queue
                        DispatchQueue.main.async {
                            //store image in cache memory imageCache
                            imageCache.setObject(image, forKey: urlString as NSString)
                            //set image
                            self?.image = image
                            
                            // Hide the activity indicator view after image download is completed.
                            self?.activityIndicator?.stopAnimating()
                            self?.activityIndicator?.removeFromSuperview()
                            self?.activityIndicator = nil
                        }
                    }else {
                        DispatchQueue.main.async {
                            //store image in cache memory imageCache
                            imageCache.setObject(image, forKey: urlString as NSString)
                            //set image
                            self?.image = image
                            
                            // Hide the activity indicator view after image download is completed.
                            self?.activityIndicator?.stopAnimating()
                            self?.activityIndicator?.removeFromSuperview()
                            self?.activityIndicator = nil
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        //store image in cache memory imageCache
                        imageCache.setObject(image, forKey: urlString as NSString)
                        //set image
                        self?.image = image
                        
                        // Hide the activity indicator view after image download is completed.
                        self?.activityIndicator?.stopAnimating()
                        self?.activityIndicator?.removeFromSuperview()
                        self?.activityIndicator = nil
                    }
                }
            }
        } else {
            // In case of an invalid URL or any other error while fetching the image, display a placeholder image.
            self.image = image
        }
    }
}
