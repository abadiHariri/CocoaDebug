//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation
import UIKit

class NetworkDetailCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: CustomTextView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var middleLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var editView: UIView!
    
    @IBOutlet weak var titleViewBottomSpaceToMiddleLine: NSLayoutConstraint!
    //-12.5
    
    
    var tapEditViewCallback:((NetworkDetailModel?) -> Void)?
    func configureCellWithText(_ text: String) {
         // Offload heavy text layout to a background thread
         DispatchQueue.global(qos: .userInitiated).async {
             // Perform heavy text layout processing here

             let processedText = self.processLargeText(text)

             // Switch back to the main thread to update the UI
             DispatchQueue.main.async {
                 self.contentTextView.text = detailModel?.mustInPreview ? "large Json .. tab 'Preview Json' to view full json format":processedText
             }
         }
     }

     private func processLargeText(_ text: String) -> String {
         // Process the text as needed, e.g., truncating, adding styles
         // For simplicity, let's just return the original text
         return text
     }
    var detailModel: NetworkDetailModel? {
        didSet {
            
            titleLabel.text = detailModel?.title
          //  contentTextView.text = detailModel?.content
            configureCellWithText(detailModel?.content ?? "")
            //image
            if detailModel?.image == nil {
                imgView.isHidden = true
            } else {
                imgView.isHidden = false
                imgView.image = detailModel?.image
            }
            
            //Hide content automatically
            if detailModel?.blankContent == "..." {
                middleLine.isHidden = true
                imgView.isHidden = true
                titleViewBottomSpaceToMiddleLine.constant = -12.5 + 2
            } else {
                middleLine.isHidden = false
                if detailModel?.image != nil {
                    imgView.isHidden = false
                }
                titleViewBottomSpaceToMiddleLine.constant = 0
            }
            
            //Bottom dividing line
            if detailModel?.isLast == true {
                bottomLine.isHidden = false
            } else {
                bottomLine.isHidden = true
            }
        }
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        editView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapEditView)))
      editView.backgroundColor = .blue
        editView.isHidden = false
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.textContainerInset = .zero
    }
    
    
    //MARK: - target action
    //edit
    @objc func tapEditView() {
        if let tapEditViewCallback = tapEditViewCallback {
            tapEditViewCallback(detailModel)
        }
    }
}
