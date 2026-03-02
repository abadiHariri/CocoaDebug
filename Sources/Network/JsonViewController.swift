//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

enum EditType {
    case unknown
    case requestHeader
    case responseHeader
    case log
}


import Foundation
import UIKit

class JsonViewController: UIViewController {

    private var textView: CustomTextView!
    private var imageView: UIImageView!

    var naviItemTitleLabel: UILabel?

    var editType: EditType  = .unknown
    var detailModel: NetworkDetailModel?

    //log
    var logTitleString: String?
    var logModels: [_OCLogModel]?
    var logModel: _OCLogModel?
    var justCancelCallback:(() -> Void)?
    
    //MARK: - tool
    
    //detect format (JSON/Form)
    func detectSerializer() {
        guard let content = detailModel?.content else {
            detailModel?.requestSerializer = RequestSerializer.json//default JSON format
            return
        }
        
        if let _ = content.stringToDictionary() {
            //JSON format
            detailModel?.requestSerializer = RequestSerializer.json
        } else {
            //Form format
            detailModel?.requestSerializer = RequestSerializer.form
            
            if let jsonString = detailModel?.content?.formStringToJsonString() {
                textView.text = jsonString
                detailModel?.requestSerializer = RequestSerializer.json
                detailModel?.content = textView.text
            }
        }
    }
    
    
    //MARK: - init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        navigationController?.hidesBarsOnSwipe = false
        
        if let index = logModels?.firstIndex(where: { (model) -> Bool in
            return model.isSelected == true
        }) {
            logModels?[index].isSelected = false
        }
        
        logModel?.isSelected = true
        
        if let justCancelCallback = justCancelCallback {
            justCancelCallback()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Programmatic views
        view.backgroundColor = .black

        textView = CustomTextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = .boldSystemFont(ofSize: 12)
        textView.isEditable = false
        textView.isScrollEnabled = true
        view.addSubview(textView)

        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.textColor = Color.mainGreen
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 20)
        naviItemTitleLabel?.text = detailModel?.title
        navigationItem.titleView = naviItemTitleLabel
        
        textView.textContainer.lineFragmentPadding = 15
        //        textView.textContainerInset = .zero
        
        //detect type (default type URL)
        if detailModel?.title == "REQUEST HEADER" {
            editType = .requestHeader
        }
        if detailModel?.title == "RESPONSE HEADER" {
            editType = .responseHeader
        }
        
        //setup UI
        if editType == .requestHeader
        {
            imageView.isHidden = true
            textView.isHidden = false
            textView.text = String(detailModel?.requestHeaderFields?.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "").replacingOccurrences(of: "\",\n  \"", with: "\",\n\"")
        }
        else if editType == .responseHeader
        {
            imageView.isHidden = true
            textView.isHidden = false
            textView.text = String(detailModel?.responseHeaderFields?.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "").replacingOccurrences(of: "\",\n  \"", with: "\",\n\"")
        }
        else if editType == .log
        {
            imageView.isHidden = true
            textView.isHidden = false
            naviItemTitleLabel?.text = logTitleString
            
            if let data = logModel?.contentData {
                textView.text = data.dataToString()
            }
        }
        else
        {
            if let content = detailModel?.content {
                imageView.isHidden = true
                textView.isHidden = false
                textView.text = content
                detectSerializer()//detect format (JSON/Form)
            }
            if let image = detailModel?.image {
                textView.isHidden = true
                imageView.isHidden = false
                imageView.image = image
            }
        }
    }
}
