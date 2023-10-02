//
//  StatusCVCell.swift
//  WhatsAppStoryView
//
//  Created by Raju Kumar on 01/10/23.
//

import UIKit

class StatusCVCell: UICollectionViewCell {
    
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initCircularProgressBar() {
        let circularProgressBarView = CircularProgressBarView(frame: self.imgVw.bounds)
        self.imgVw.addSubview(circularProgressBarView)

        // To update the progress, call setProgress:
        circularProgressBarView.setProgress(0.5) // 50% progress
    }

}
