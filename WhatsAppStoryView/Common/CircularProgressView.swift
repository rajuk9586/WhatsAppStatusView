//
//  CircularProgressView.swift
//  WhatsAppStoryView
//
//  Created by Raju Kumar on 02/10/23.
//

import UIKit


class CircularProgressBarView: UIView {
    private var progressLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCircularProgressBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCircularProgressBar()
    }
    
    private func setupCircularProgressBar() {
        // Create a circular path for the progress indicator
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2),
            radius: min(bounds.size.width, bounds.size.height) / 2,
            startAngle: -.pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        
        progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.green.cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0.0 // Initial progress is 0
        
        layer.addSublayer(progressLayer)
    }
    
    // Function to update the progress (0.0 to 1.0)
    func setProgress(_ progress: Float) {
        progressLayer.strokeEnd = CGFloat(progress)
    }
}
