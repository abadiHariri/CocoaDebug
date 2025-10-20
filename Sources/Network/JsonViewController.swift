//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import JSONPreview

class NetworkDetailViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var closeItem: UIBarButtonItem!
    @IBOutlet weak var naviItem: UINavigationItem!
    
    var naviItemTitleLabel: UILabel?
    
    var httpModel: _HttpModel?
    var httpModels: [_HttpModel]?
    
    var detailModels: [NetworkDetailModel] = [NetworkDetailModel]()
    
    var requestDictionary: [String: Any]? = Dictionary()
    
    var headerCell: NetworkCell?
    
    var messageBody: String = ""
    
    var justCancelCallback:(() -> Void)?
    
    static func instanceFromStoryBoard() -> NetworkDetailViewController {
        let storyboard = UIStoryboard(name: "Network", bundle: Bundle(for: CocoaDebug.self))
        return storyboard.instantiateViewController(withIdentifier: "NetworkDetailViewController") as! NetworkDetailViewController
    }
    
    
    //MARK: - tool
    func setupModels() {
        guard let requestSerializer = httpModel?.requestSerializer else { return }
        var requestContent: String? = nil

        if httpModel?.requestData == nil {
            httpModel?.requestData = Data()
        }
        if httpModel?.responseData == nil {
            httpModel?.responseData = Data()
        }

        // detect the request parameter format (JSON/Form)
        if requestSerializer == RequestSerializer.JSON {
            requestContent = httpModel?.requestData.dataToPrettyPrintString()
        }else if requestSerializer == RequestSerializer.form {
            if let data = httpModel?.requestData {
                // 1. Try UTF-8 string
                var rawString = String(data: data, encoding: .utf8) ?? ""
                if rawString.isEmpty {
                    rawString = data.dataToString() ?? ""
                }

                // 2. Handle application/x-www-form-urlencoded
                if rawString.contains("=") && !rawString.contains("Content-Disposition: form-data;") {
                    var dict: [String: String] = [:]
                    let pairs = rawString.components(separatedBy: "&")
                    for pair in pairs {
                        let parts = pair.components(separatedBy: "=")
                        if parts.count >= 2 {
                            let key = parts[0].removingPercentEncoding ?? parts[0]
                            let value = parts[1...].joined(separator: "=").removingPercentEncoding ?? ""
                            dict[key] = value
                        }
                    }
                    if !dict.isEmpty,
                       let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        requestContent = jsonString
                    } else {
                        requestContent = rawString
                    }
                }
                // 3. Handle multipart/form-data
                else if rawString.contains("Content-Disposition: form-data;") {
                    var formDict: [String: String] = [:]
                    let boundaryParts = rawString.components(separatedBy: "--").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    for part in boundaryParts {
                        if let nameRange = part.range(of: "name=\""),
                           let endRange = part[nameRange.upperBound...].range(of: "\"") {
                            let name = String(part[nameRange.upperBound..<endRange.lowerBound])
                            let sections = part.components(separatedBy: "\r\n\r\n")
                            if sections.count > 1 {
                                let value = sections[1].replacingOccurrences(of: "\r\n", with: "")
                                if !value.isEmpty {
                                    formDict[name] = value
                                }
                            }
                        }
                    }
                    if !formDict.isEmpty,
                       let jsonData = try? JSONSerialization.data(withJSONObject: formDict, options: .prettyPrinted),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        requestContent = jsonString
                    } else {
                        requestContent = rawString
                    }
                }
                // 4. Fallback
                else {
                    requestContent = rawString.isEmpty ? nil : rawString
                }

                if requestContent == "" || requestContent == "\u{8}\u{1e}" {
                    requestContent = nil
                }
            }
        }

        if httpModel?.isImage == true {
            let model_1 = NetworkDetailModel(title: "URL", content: "https://github.com/CocoaDebug/CocoaDebug", url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_3 = NetworkDetailModel(title: "REQUEST", content: requestContent, url: httpModel?.url.absoluteString, httpModel: httpModel)
            var model_5 = NetworkDetailModel(title: "RESPONSE", content: nil, url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_6 = NetworkDetailModel(title: "ERROR", content: httpModel?.errorLocalizedDescription, url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_7 = NetworkDetailModel(title: "ERROR DESCRIPTION", content: httpModel?.errorDescription, url: httpModel?.url.absoluteString, httpModel: httpModel)
            if let responseData = httpModel?.responseData {
                model_5 = NetworkDetailModel(title: "RESPONSE", content: nil, url: httpModel?.url.absoluteString, image: UIImage(gifData: responseData), httpModel: httpModel)
            }
            let model_8 = NetworkDetailModel(title: "TOTAL TIME", content: httpModel?.totalDuration, url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_9 = NetworkDetailModel(title: "MIME TYPE", content: httpModel?.mineType, url: httpModel?.url.absoluteString, httpModel: httpModel)

            var model_2 = NetworkDetailModel(title: "REQUEST HEADER", content: nil, url: httpModel?.url.absoluteString, httpModel: httpModel)
            if let requestHeaderFields = httpModel?.requestHeaderFields, !requestHeaderFields.isEmpty {
                model_2 = NetworkDetailModel(title: "REQUEST HEADER", content: requestHeaderFields.description, url: httpModel?.url.absoluteString, httpModel: httpModel)
                model_2.requestHeaderFields = requestHeaderFields
                model_2.content = String(requestHeaderFields.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "")
                    .replacingOccurrences(of: "\",\n  \"", with: "\",\n\"")
                    .replacingOccurrences(of: "\\/", with: "/")
            }

            var model_4 = NetworkDetailModel(title: "RESPONSE HEADER", content: nil, url: httpModel?.url.absoluteString, httpModel: httpModel)
            if let responseHeaderFields = httpModel?.responseHeaderFields, !responseHeaderFields.isEmpty {
                model_4 = NetworkDetailModel(title: "RESPONSE HEADER", content: responseHeaderFields.description, url: httpModel?.url.absoluteString, httpModel: httpModel)
                model_4.responseHeaderFields = responseHeaderFields
                model_4.content = String(responseHeaderFields.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "")
                    .replacingOccurrences(of: "\",\n  \"", with: "\",\n\"")
                    .replacingOccurrences(of: "\\/", with: "/")
            }

            let model_0 = NetworkDetailModel(title: "RESPONSE SIZE", content: httpModel?.size, url: httpModel?.url.absoluteString, httpModel: httpModel)
            detailModels.append(contentsOf: [model_1, model_2, model_3, model_4, model_5, model_6, model_7, model_0, model_8, model_9])
        } else {
            let model_1 = NetworkDetailModel(title: "URL", content: "https://github.com/CocoaDebug/CocoaDebug", url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_3 = NetworkDetailModel(title: "REQUEST", content: requestContent, url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_5 = NetworkDetailModel(title: "RESPONSE", content: httpModel?.responseData.dataToPrettyPrintString(), url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_6 = NetworkDetailModel(title: "ERROR", content: httpModel?.errorLocalizedDescription, url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_7 = NetworkDetailModel(title: "ERROR DESCRIPTION", content: httpModel?.errorDescription, url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_8 = NetworkDetailModel(title: "TOTAL TIME", content: httpModel?.totalDuration, url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_9 = NetworkDetailModel(title: "MIME TYPE", content: httpModel?.mineType, url: httpModel?.url.absoluteString, httpModel: httpModel)

            var model_2 = NetworkDetailModel(title: "REQUEST HEADER", content: nil, url: httpModel?.url.absoluteString, httpModel: httpModel)
            if let requestHeaderFields = httpModel?.requestHeaderFields, !requestHeaderFields.isEmpty {
                model_2 = NetworkDetailModel(title: "REQUEST HEADER", content: requestHeaderFields.description, url: httpModel?.url.absoluteString, httpModel: httpModel)
                model_2.requestHeaderFields = requestHeaderFields
                if let data = try? JSONSerialization.data(withJSONObject: requestHeaderFields, options: [.prettyPrinted]),
                   let jsonString = String(data: data, encoding: .utf8) {
                    model_2.content = jsonString
                } else {
                    model_2.content = String(requestHeaderFields.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "")
                        .replacingOccurrences(of: "\",\n  \"", with: "\",\n\"")
                        .replacingOccurrences(of: "\\/", with: "/")
                }
            }

            var model_4 = NetworkDetailModel(title: "RESPONSE HEADER", content: nil, url: httpModel?.url.absoluteString, httpModel: httpModel)
            if let responseHeaderFields = httpModel?.responseHeaderFields, !responseHeaderFields.isEmpty {
                model_4 = NetworkDetailModel(title: "RESPONSE HEADER", content: responseHeaderFields.description, url: httpModel?.url.absoluteString, httpModel: httpModel)
                model_4.responseHeaderFields = responseHeaderFields
                if let data = try? JSONSerialization.data(withJSONObject: responseHeaderFields, options: [.prettyPrinted]),
                   let jsonString = String(data: data, encoding: .utf8) {
                    model_4.content = jsonString
                } else {
                    model_4.content = String(responseHeaderFields.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "")
                        .replacingOccurrences(of: "\",\n  \"", with: "\",\n\"")
                        .replacingOccurrences(of: "\\/", with: "/")
                }
            }

            let model_0 = NetworkDetailModel(title: "RESPONSE SIZE", content: httpModel?.size, url: httpModel?.url.absoluteString, httpModel: httpModel)
            detailModels.append(contentsOf: [model_1, model_2, model_3, model_4, model_5, model_6, model_7, model_0, model_8, model_9])
        }
    }
    
    //detetc request format (JSON/Form)
    func detectRequestSerializer() {
        guard let requestData = httpModel?.requestData else {
            httpModel?.requestSerializer = RequestSerializer.JSON//default JSON format
            return
        }
        
        if let _ = requestData.dataToDictionary() {
            //JSON format
            httpModel?.requestSerializer = RequestSerializer.JSON
        } else {
            //Form format
            httpModel?.requestSerializer = RequestSerializer.form
        }
    }
    
    
    //email configure
    func configureMailComposer(_ copy: Bool = false) -> MFMailComposeViewController? {
        
        //1.image
        var img: UIImage? = nil
        var isImage: Bool = false
        if let httpModel = httpModel {
            isImage = httpModel.isImage
        }
        
        //2.body message ------------------ start ------------------
        var string: String = ""
        messageBody = ""
        
        for model in detailModels {
            if let title = model.title, let content = model.content {
                if content != "" {
                    string = "\n\n" + "------- " + title + " -------" + "\n" + content
                }
            }
            if !messageBody.contains(string) {
                messageBody.append(string)
            }
            //image
            if isImage == true {
                if let image = model.image {
                    img = image
                }
            }
        }
        
        //2.1.url
        var url: String = ""
        if let httpModel = httpModel {
            url = httpModel.url.absoluteString
        }
        
        //2.2.method
        var method: String = ""
        if let httpModel = httpModel {
            method = "[" + httpModel.method + "]"
        }
        
        //2.3.time
        var time: String = ""
        if let httpModel = httpModel {
            if let startTime = httpModel.startTime {
                if (startTime as NSString).doubleValue == 0 {
                    time = _OCLoggerFormat.formatDate(Date())
                } else {
                    time = _OCLoggerFormat.formatDate(NSDate(timeIntervalSince1970: (startTime as NSString).doubleValue) as Date)
                }
            }
        }
        
        //2.4.statusCode
        var statusCode: String = ""
        if let httpModel = httpModel {
            statusCode = httpModel.statusCode
            if statusCode == "0" { //"0" means network unavailable
                statusCode = "❌"
            }
        }
        
        //body message ------------------ end ------------------
        var subString = method + " " + time + " " + "(" + statusCode + ")"
        if subString.contains("❌") {
            subString = subString.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        }
        
        messageBody = messageBody.replacingOccurrences(of: "https://github.com/CocoaDebug/CocoaDebug", with: url)
        messageBody = subString + messageBody
        
        //////////////////////////////////////////////////////////////////////////////////
        
        if !MFMailComposeViewController.canSendMail() {
            if copy == false {
                //share via email
                let alert = UIAlertController.init(title: "No Mail Accounts", message: "Please set up a Mail account in order to send email.", preferredStyle: .alert)
                let action = UIAlertAction.init(title: "OK", style: .cancel) { _ in
                }
                alert.addAction(action)
                
                alert.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
                alert.popoverPresentationController?.sourceView = self.view
                alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                
                self.present(alert, animated: true, completion: nil)
            } else {
                //copy to clipboard
            }
            
            return nil
        }
        
        if copy == true {
            //copy to clipboard
            return nil
        }
        
        //3.email recipients
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(CocoaDebugSettings.shared.emailToRecipients)
        mailComposeVC.setCcRecipients(CocoaDebugSettings.shared.emailCcRecipients)
        
        //4.image
        if let img = img {
            if let imageData = img.pngData() {
                mailComposeVC.addAttachmentData(imageData, mimeType: "image/png", fileName: "image")
            }
        }
        
        //5.body
        mailComposeVC.setMessageBody(messageBody, isHTML: false)
        
        //6.subject
        mailComposeVC.setSubject(url)
        
        return mailComposeVC
    }
    
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.textColor = Color.mainGreen
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 20)
        naviItemTitleLabel?.text = "Details"
        naviItem.titleView = naviItemTitleLabel
        
        closeItem.tintColor = Color.mainGreen
        
        //detect the request format (JSON/Form)
        detectRequestSerializer()
        
        setupModels()
        
        if var lastModel = detailModels.last {
            lastModel.isLast = true
            detailModels.removeLast()
            detailModels.append(lastModel)
        }
        
        //Use a separate xib-cell file, must be registered, otherwise it will crash
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "NetworkCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: "NetworkCell")
        
        //header
        headerCell = bundle.loadNibNamed(String(describing: NetworkCell.self), owner: nil, options: nil)?.first as? NetworkCell
        headerCell?.httpModel = httpModel
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let index = httpModels?.firstIndex(where: { (model) -> Bool in
            return model.isSelected == true
        }) {
            httpModels?[index].isSelected = false
        }
        
        httpModel?.isSelected = true
        
        if let justCancelCallback = justCancelCallback {
            justCancelCallback()
        }
    }
    
    //MARK: - target action
    @IBAction func close(_ sender: UIBarButtonItem) {
        (self.navigationController as! CocoaDebugNavigationController).exit()
    }
    
    @IBAction func didTapMail(_ sender: UIBarButtonItem) {
        
        // create an actionSheet
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "share via email", style: .default) { [weak self] action -> Void in
            if let mailComposeViewController = self?.configureMailComposer() {
                self?.present(mailComposeViewController, animated: true, completion: nil)
            }
        }
        
        let secondAction: UIAlertAction = UIAlertAction(title: "copy to clipboard", style: .default) { [weak self] action -> Void in
            _ = self?.configureMailComposer(true)
            UIPasteboard.general.string = self?.messageBody
        }
        
        let curlAction = UIAlertAction(title: "copy cURL to clipboard", style: .default) { _ in
            if let httpModel = self.httpModel {
                UIPasteboard.general.string = httpModel.cURLDescription()
            }
        }
        
        let moreAction: UIAlertAction = UIAlertAction(title: "more", style: .default) { [weak self] action -> Void in
            _ = self?.configureMailComposer(true)
            let items: [Any] = [self?.messageBody ?? ""]
            let action = UIActivityViewController(activityItems: items, applicationActivities: nil)
            if UI_USER_INTERFACE_IDIOM() == .phone {
                self?.present(action, animated: true, completion: nil)
            } else {
                action.popoverPresentationController?.sourceRect = .init(x: self?.view.bounds.midX ?? 0, y: self?.view.bounds.midY ?? 0, width: 0, height: 0)
                action.popoverPresentationController?.sourceView = self?.view
                self?.present(action, animated: true, completion: nil)
            }

        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        
        // add actions
        alert.addAction(secondAction)
        alert.addAction(curlAction)
        alert.addAction(firstAction)
        alert.addAction(moreAction)
        alert.addAction(cancelAction)
        
        alert.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        // present an actionSheet...
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource
extension NetworkDetailViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkDetailCell", for: indexPath)
            as! NetworkDetailCell
        cell.detailModel = detailModels[indexPath.row]
        
        //2.click edit view
        cell.tapEditViewCallback = { [weak self] detailModel in
            
//            let fallback = BasicExampleViewController()
//            fallback.json = detailModel?.content ?? ""
//            self?.navigationController?.pushViewController(fallback, animated: true)
//
//            let vc = DemoJSONViewerHostController()
//            vc.jsonString = detailModel?.content ?? ""
//            self?.navigationController?.pushViewController(vc, animated: true)
            
            self?.pushJSONViewerOrFallback(with: detailModel?.content ?? "")
            
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension NetworkDetailViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let detailModel = detailModels[indexPath.row]
        
        if detailModel.blankContent == "..." {
            if detailModel.isLast == true {
                return 50.5
            }
            return 50
        }
        
        if indexPath.row == 0 {
            return 0
        }
        
        if detailModel.image == nil {
            if let content = detailModel.content {
                if content == "" {
                    return 0
                }
                //Calculate NSString height
                let height = detailModel.heigth
                return height + 70
            }
            return 0
        }
        
        return UIScreen.main.bounds.size.width + 50
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerCell?.contentView
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let serverURL = CocoaDebugSettings.shared.serverURL else {return 0}
        
        var height: CGFloat = 0.0
        
        if let cString = httpModel?.url.absoluteString.cString(using: String.Encoding.utf8) {
            if let content_ = NSString(cString: cString, encoding: String.Encoding.utf8.rawValue) {
                
                if httpModel?.url.absoluteString.contains(serverURL) == true {
                    //Calculate NSString height
                    if #available(iOS 8.2, *) {
                        height = content_.height(with: UIFont.systemFont(ofSize: 13, weight: .heavy), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    } else {
                        // Fallback on earlier versions
                        height = content_.height(with: UIFont.boldSystemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    }
                } else {
                    //Calculate NSString height
                    if #available(iOS 8.2, *) {
                        height = content_.height(with: UIFont.systemFont(ofSize: 13, weight: .regular), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    } else {
                        // Fallback on earlier versions
                        height = content_.height(with: UIFont.systemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    }
                }
                return height + 57
            }
        }
        
        return 0
    }
}

//MARK: - MFMailComposeViewControllerDelegate
extension NetworkDetailViewController {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true) {
            if error != nil {
                let alert = UIAlertController.init(title: error?.localizedDescription, message: nil, preferredStyle: .alert)
                let action = UIAlertAction.init(title: "OK", style: .cancel, handler: { _ in
                })
                alert.addAction(action)
                
                alert.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
                alert.popoverPresentationController?.sourceView = self.view
                alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}


// MARK: - JSON validity check
@inline(__always)
private func isValidJSON(_ text: String) -> Bool {
    guard let data = text.data(using: .utf8), !data.isEmpty else { return false }
    do {
        _ = try JSONSerialization.jsonObject(with: data, options: [])
        return true
    } catch {
        return false
    }
}

// MARK: - Push logic
extension UIViewController {
    func pushJSONViewerOrFallback(with jsonString: String) {
        let controller: UIViewController
        if isValidJSON(jsonString) {
            let vc = DemoJSONViewerHostController()
            vc.jsonString = jsonString
            controller = vc
        } else {
            let fallback = BasicExampleViewController()
            fallback.json = jsonString
            controller = fallback
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}

import UIKit

import SafariServices

import JSONPreview

class BaseJSONPreviewController: UIViewController {
    lazy var previewView = JSONPreview()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        previewView.delegate = self
        
        view.addSubview(previewView)
    }
}

// MARK: - UITextViewDelegate

extension BaseJSONPreviewController: JSONPreviewDelegate {
    func jsonPreview(_ view: JSONPreview, didClickURL url: URL, on textView: UITextView) -> Bool {
        print(url)
        
        let safari = SFSafariViewController(url: url)
        safari.modalPresentationStyle = .overFullScreen
        present(safari, animated: true, completion: nil)
        
        return false
    }
}
class BasicExampleViewController: BaseJSONPreviewController {
    var json:String? //= ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Json Preview"
        
        addPreviewViewLayout()
        
        preview()
    }
}

// MARK: -

private extension BasicExampleViewController {
    func addPreviewViewLayout() {
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func preview() {
        let json = json ?? ""
        
        previewView.preview(json, initialState: .folded)
        
    }
}


import UIKit
import WebKit

// JSON Viewer using https://github.com/andypf/json-viewer (web component)
final class JSONViewerViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    private var isLoaded = false
    private var pendingJSON: String?

    private let initialHTML: String = """
    <!doctype html>
    <html lang="ar" dir="auto">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
      <style>
        html, body { height:100%; margin:0; background:#0f1115; color:#e6e6e6;
          font-family:-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial,
          "Apple Color Emoji", "Segoe UI Emoji", "Noto Sans Arabic", "Geeza Pro", "PingFang SC",
          "Noto Sans", sans-serif; }
        #root { height:100%; display:grid; }
        andypf-json-viewer { height:100%; width:100%; }
        :root { unicode-bidi: plaintext; }
      </style>
      <script defer src="https://pfau-software.de/json-viewer/dist/iife/index.js"></script>
    </head>
    <body>
      <div id="root">
        <andypf-json-viewer
          id="viewer"
          indent="2"
          expanded="2"
          theme="onedark"
          show-data-types="true"
          show-toolbar="true"
          expand-icon-type="arrow"
          show-copy="true"
          show-size="true"
        >{}</andypf-json-viewer>
      </div>

      <script>
        function getViewer(){ return document.getElementById("viewer"); }

        function b64ToUtf8(b64) {
          const bin = atob(b64);
          const bytes = Uint8Array.from(bin, c => c.charCodeAt(0));
          if (window.TextDecoder) {
            return new TextDecoder("utf-8").decode(bytes);
          }
          let out = "", i = 0;
          while (i < bytes.length) out += String.fromCharCode(bytes[i++]);
          return decodeURIComponent(escape(out));
        }

        window.renderBase64 = (b64) => {
          try {
            const jsonText = b64ToUtf8(b64);
            const obj = JSON.parse(jsonText);
            getViewer().data = obj;
          } catch (e) { console.error("renderBase64 error", e); }
        };

        window.configureViewer = (opts = {}) => {
          const el = getViewer();
          if (typeof opts.indent === "number") el.indent = opts.indent;
          if (typeof opts.expanded !== "undefined") el.expanded = opts.expanded;
          if (typeof opts.theme === "string") el.theme = opts.theme;
          if (typeof opts.showDataTypes === "boolean") el.showDataTypes = opts.showDataTypes;
          if (typeof opts.showToolbar === "boolean") el.showToolbar = opts.showToolbar;
          if (typeof opts.expandIconType === "string") el.expandIconType = opts.expandIconType;
          if (typeof opts.showCopy === "boolean") el.showCopy = opts.showCopy;
          if (typeof opts.showSize === "boolean") el.showSize = opts.showSize;
          if (typeof opts.direction === "string") document.documentElement.setAttribute("dir", opts.direction);
        };
      </script>
    </body>
    </html>
    """


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        webView.loadHTMLString(initialHTML, baseURL: nil)
    }

    // MARK: - Public API

    /// Pass a JSON string (UTF-8). Arabic is fully supported.
    func render(jsonString: String) {
        guard isLoaded else {
            pendingJSON = jsonString
            return
        }
        evaluateRender(jsonString: jsonString)
    }

    /// Optionally force RTL/LTR or tweak viewer.
    func configure(indent: Int? = nil,
                   expanded: Any? = nil,          // Int or Bool
                   theme: String? = nil,
                   showDataTypes: Bool? = nil,
                   showToolbar: Bool? = nil,
                   expandIconType: String? = nil, // "square" | "circle" | "arrow"
                   showCopy: Bool? = nil,
                   showSize: Bool? = nil,
                   direction: String? = nil       // "rtl" | "ltr" | "auto"
    ) {
        var dict: [String: Any] = [:]
        if let indent { dict["indent"] = indent }
        if let expanded {
            if let b = expanded as? Bool { dict["expanded"] = b }
            else if let i = expanded as? Int { dict["expanded"] = i }
        }
        if let theme { dict["theme"] = theme }
        if let showDataTypes { dict["showDataTypes"] = showDataTypes }
        if let showToolbar { dict["showToolbar"] = showToolbar }
        if let expandIconType { dict["expandIconType"] = expandIconType }
        if let showCopy { dict["showCopy"] = showCopy }
        if let showSize { dict["showSize"] = showSize }
        if let direction { dict["direction"] = direction }

        guard
            let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
            let json = String(data: data, encoding: .utf8)
        else { return }

        webView.evaluateJavaScript("window.configureViewer(\(json));", completionHandler: nil)
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoaded = true
        if let text = pendingJSON {
            evaluateRender(jsonString: text)
            pendingJSON = nil
        }
    }

    // MARK: - Internal

    private func evaluateRender(jsonString: String) {
        let b64 = Data(jsonString.utf8).base64EncodedString()
        let js = "window.renderBase64('\(b64)');"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
}

// MARK: - Example Usage

final class DemoJSONViewerHostController: UIViewController {
    private let viewer = JSONViewerViewController()
    var jsonString: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(viewer)
        viewer.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewer.view)
        viewer.didMove(toParent: self)
        NSLayoutConstraint.activate([
            viewer.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewer.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewer.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewer.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Optional configuration
        viewer.configure(indent: 2,
                         expanded: 2,
                         theme: "onedark",
                         showDataTypes: true,
                         showToolbar: true,
                         expandIconType: "arrow",
                         showCopy: true,
                         showSize: true)

        // Render JSON passed as STRING
 
        viewer.render(jsonString: jsonString)
    }
}
 
 
