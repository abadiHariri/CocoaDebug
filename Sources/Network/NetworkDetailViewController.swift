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

class NetworkDetailViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    private var closeItem: UIBarButtonItem!

    var naviItemTitleLabel: UILabel?
    
    var httpModel: _HttpModel?
    var httpModels: [_HttpModel]?
    
    var detailModels: [NetworkDetailModel] = [NetworkDetailModel]()

    /// Raw cURL string — stored separately because NetworkDetailModel.init
    /// applies replacingOccurrences(of: "\\/", with: "/") which corrupts
    /// JSON body data inside the cURL command.
    private var rawCurlString: String = ""

    var headerCell: NetworkCell?
    
    var messageBody: String = ""
    
    var justCancelCallback:(() -> Void)?
    
    //MARK: - tool
    func setupModels() {
        guard let requestSerializer = httpModel?.requestSerializer else { return }
        var requestContent: String? = nil

        // Load data from disk ONCE into local variables.
        // Each access to .requestData / .responseData reads from disk,
        // so we must not call the getter multiple times.
        let cachedRequestData: Data? = httpModel?.requestData  // single disk read
        // responseData loaded later, only when needed

        // detect the request parameter format (JSON/Form)
        if requestSerializer == RequestSerializer.JSON {
            requestContent = cachedRequestData?.dataToPrettyPrintString()
        }else if requestSerializer == RequestSerializer.form {
            if let data = cachedRequestData {
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

        // Load response data from disk ONCE - single disk read
        let cachedResponseData: Data? = httpModel?.responseData

        let urlStr = httpModel?.url.absoluteString

        // URL (hidden row placeholder)
        let model_1 = NetworkDetailModel(title: "URL", content: "https://github.com/CocoaDebug/CocoaDebug", url: urlStr, httpModel: httpModel)

        // Request parameters (extracted from URL query string)
        var modelParams = NetworkDetailModel(title: "REQUEST PARAMETERS", content: nil, url: urlStr, httpModel: httpModel)
        if let url = httpModel?.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems, !queryItems.isEmpty {
            var dict: [String: Any] = [:]
            for item in queryItems {
                dict[item.name] = item.value ?? ""
            }
            if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                modelParams.content = jsonString
            }
        }
        modelParams.showPreview = true

        // Request header
        var model_2 = NetworkDetailModel(title: "REQUEST HEADER", content: nil, url: urlStr, httpModel: httpModel)
        if let requestHeaderFields = httpModel?.requestHeaderFields, !requestHeaderFields.isEmpty {
            model_2 = NetworkDetailModel(title: "REQUEST HEADER", content: requestHeaderFields.description, url: urlStr, httpModel: httpModel)
            model_2.requestHeaderFields = requestHeaderFields
            if let data = try? JSONSerialization.data(withJSONObject: requestHeaderFields, options: [.prettyPrinted]),
               let jsonString = String(data: data, encoding: .utf8) {
                model_2.content = jsonString
            }
        }
        model_2.showPreview = true

        // Request body
        var model_3 = NetworkDetailModel(title: "REQUEST", content: requestContent, url: urlStr, httpModel: httpModel)
        model_3.showPreview = true

        // Response header
        var model_4 = NetworkDetailModel(title: "RESPONSE HEADER", content: nil, url: urlStr, httpModel: httpModel)
        if let responseHeaderFields = httpModel?.responseHeaderFields, !responseHeaderFields.isEmpty {
            model_4 = NetworkDetailModel(title: "RESPONSE HEADER", content: responseHeaderFields.description, url: urlStr, httpModel: httpModel)
            model_4.responseHeaderFields = responseHeaderFields
            if let data = try? JSONSerialization.data(withJSONObject: responseHeaderFields, options: [.prettyPrinted]),
               let jsonString = String(data: data, encoding: .utf8) {
                model_4.content = jsonString
            }
        }
        model_4.showPreview = true

        // Response body
        var model_5: NetworkDetailModel
        if httpModel?.isImage == true {
            if let responseData = cachedResponseData {
                model_5 = NetworkDetailModel(title: "RESPONSE", content: nil, url: urlStr, image: UIImage(gifData: responseData), httpModel: httpModel)
            } else {
                model_5 = NetworkDetailModel(title: "RESPONSE", content: nil, url: urlStr, httpModel: httpModel)
            }
        } else {
            model_5 = NetworkDetailModel(title: "RESPONSE", content: cachedResponseData?.dataToPrettyPrintString(), url: urlStr, httpModel: httpModel)
        }
        model_5.showPreview = true

        // Errors (info-only sections — different styling, no preview)
        var model_6 = NetworkDetailModel(title: "ERROR", content: httpModel?.errorLocalizedDescription, url: urlStr, httpModel: httpModel)
        model_6.isInfoOnly = true
        var model_7 = NetworkDetailModel(title: "ERROR DESCRIPTION", content: httpModel?.errorDescription, url: urlStr, httpModel: httpModel)
        model_7.isInfoOnly = true

        // cURL command (pass cached data to avoid redundant disk read)
        rawCurlString = httpModel?.cURLDescription(cachedRequestData: cachedRequestData) ?? ""
        var modelCurl = NetworkDetailModel(title: "REQUEST CURL", content: rawCurlString, url: urlStr, httpModel: httpModel)
        modelCurl.showPreview = true

        // Build final list — only include sections that have content.
        // URL is always included (hidden placeholder row).
        // REQUEST CURL is always included (useful even with just URL + method).
        // Everything else is filtered out when empty.
        let alwaysInclude: Set<String> = ["URL", "REQUEST CURL"]

        let allSections = [model_1, modelParams, model_2, model_3, model_4, model_5, model_6, model_7, modelCurl]
        for section in allSections {
            let title = section.title ?? ""
            if alwaysInclude.contains(title) {
                detailModels.append(section)
            } else if section.image != nil {
                detailModels.append(section)
            } else if let content = section.content, !content.isEmpty {
                detailModels.append(section)
            }
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
        navigationItem.titleView = naviItemTitleLabel

        let closeImage = UIImage(named: "_icon_file_type_close.png", in: Bundle(for: NetworkDetailViewController.self), compatibleWith: nil)
        closeItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(close(_:)))
        closeItem.tintColor = Color.mainGreen
        
        //detect the request format (JSON/Form)
        detectRequestSerializer()
        
        setupModels()
        
        if var lastModel = detailModels.last {
            lastModel.isLast = true
            detailModels.removeLast()
            detailModels.append(lastModel)
        }
        
        //Register programmatic cells (overrides storyboard prototypes)
        tableView.register(NetworkCell.self, forCellReuseIdentifier: "NetworkCell")
        tableView.register(NetworkDetailCell.self, forCellReuseIdentifier: "NetworkDetailCell")

        // Table styling
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.contentInset.bottom = 80  // padding so sticky header doesn't cover last row
        tableView.showsVerticalScrollIndicator = false

        // Nav bar: close only
        navigationItem.rightBarButtonItems = [closeItem]

        //header
        headerCell = NetworkCell(style: .default, reuseIdentifier: "NetworkCell")
        headerCell?.httpModel = httpModel
        headerCell?.showCurlButton = true
        headerCell?.onCurlTapped = { [weak self] in
            guard let self = self else { return }
            // Use rawCurlString — NOT detailModel.content which has \/ replaced
            let curl = self.rawCurlString
            UIPasteboard.general.string = curl

            let activity = UIActivityViewController(activityItems: [curl], applicationActivities: nil)
            if UI_USER_INTERFACE_IDIOM() == .pad {
                activity.popoverPresentationController?.sourceView = self.view
                activity.popoverPresentationController?.sourceRect = CGRect(
                    x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0
                )
            }
            self.present(activity, animated: true)
        }
    }
    
    private var hasPerformedInitialReload = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // After the table gets its correct width, reload once so
        // self-sizing cells and the sticky header compute correct heights.
        if !hasPerformedInitialReload {
            hasPerformedInitialReload = true
            tableView.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Only run cleanup when actually going back (popped), not when pushing a child VC
        guard isMovingFromParent || isBeingDismissed else { return }

        if let index = httpModels?.firstIndex(where: { (model) -> Bool in
            return model.isSelected == true
        }) {
            httpModels?[index].isSelected = false
        }

        httpModel?.isSelected = true

        if let justCancelCallback = justCancelCallback {
            justCancelCallback()
        }

        // Release large strings (response body, request body) immediately
        // when navigating away instead of waiting for dealloc.
        detailModels.removeAll()
    }
    
    //MARK: - target action

    @objc func close(_ sender: UIBarButtonItem) {
        (self.navigationController as! CocoaDebugNavigationController).exit()
    }
    
    @objc func didTapMail(_ sender: UIBarButtonItem) {
        
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
        guard indexPath.row < detailModels.count else { return cell }
        cell.detailModel = detailModels[indexPath.row]
        
        //2.click edit view
        cell.tapEditViewCallback = { [weak self] detailModel in
            guard let self = self else { return }
            let content = detailModel?.content ?? ""

            // cURL section → open cURL preview with RAW string (not processed by NetworkDetailModel)
            if detailModel?.title == "REQUEST CURL" {
                let vc = CurlPreviewViewController()
                vc.curlString = self.rawCurlString
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }

            self.pushJSONViewerOrFallback(with: content)
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension NetworkDetailViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < detailModels.count else { return 0 }

        // Row 0 (URL placeholder) — hidden
        if detailModels[indexPath.row].title == "URL" { return 0 }

        return UITableView.automaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerCell?.contentView
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let cell = headerCell else { return 0 }
        let targetSize = CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let size = cell.contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return size.height
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
func isValidJSON(_ text: String) -> Bool {
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
            let vc = JsonViewController()
            var model = NetworkDetailModel(title: "Preview", content: jsonString, url: nil, httpModel: nil)
            model.showPreview = false
            vc.detailModel = model
            controller = vc
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}

import UIKit
import WebKit

// Bridges navigator.clipboard.writeText() from WKWebView to UIPasteboard.
// WKWebView blocks the Clipboard API when the page origin is null (loadHTMLString).
private final class ClipboardMessageHandler: NSObject, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard let text = message.body as? String else { return }
        UIPasteboard.general.string = text
    }
}

// JSON Viewer using https://github.com/andypf/json-viewer (web component)
final class JSONViewerViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    private var isLoaded = false
    private var pendingJSON: String?
    private let clipboardHandler = ClipboardMessageHandler()

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
        // Limit WKWebView memory: disable back-forward cache
        config.suppressesIncrementalRendering = true

        // Override navigator.clipboard.writeText so the json-viewer copy button
        // works when the page has a null origin (WKWebView blocks Clipboard API otherwise).
        let clipboardOverride = WKUserScript(
            source: """
            navigator.clipboard = {
              writeText: function(text) {
                window.webkit.messageHandlers.nativeClipboard.postMessage(text);
                return Promise.resolve();
              },
              readText: function() { return Promise.resolve(""); }
            };
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(clipboardOverride)
        config.userContentController.add(clipboardHandler, name: "nativeClipboard")

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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Only tear down when actually leaving (popped/dismissed), not when pushing a child.
        guard isMovingFromParent || isBeingDismissed else { return }
        tearDownWebView()
    }

    deinit {
        tearDownWebView()
    }

    /// Release WKWebView and all associated memory.
    /// WKWebView is known for retaining large JS heaps even after the VC is gone.
    private func tearDownWebView() {
        pendingJSON = nil
        guard let wv = webView else { return }
        wv.stopLoading()
        wv.navigationDelegate = nil
        wv.configuration.userContentController.removeScriptMessageHandler(forName: "nativeClipboard")
        // Load blank page to force JS engine to release parsed JSON objects
        wv.loadHTMLString("", baseURL: nil)
        wv.removeFromSuperview()
        webView = nil
        isLoaded = false
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

        webView?.evaluateJavaScript("window.configureViewer(\(json));", completionHandler: nil)
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
        webView?.evaluateJavaScript(js, completionHandler: nil)
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

// MARK: - CurlPreviewViewController

final class CurlPreviewViewController: UIViewController {

    var curlString: String = ""

    private let scrollView = UIScrollView()
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let textView = UITextView()
    private let copyButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // Nav title
        let navTitle = UILabel()
        navTitle.text = "cURL"
        navTitle.font = .boldSystemFont(ofSize: 20)
        navTitle.textColor = Color.mainGreen
        navigationItem.titleView = navTitle

        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        view.addSubview(scrollView)

        // Card (same as NetworkDetailCell)
        cardView.backgroundColor = UIColor(white: 0.11, alpha: 1)
        cardView.layer.cornerRadius = 10
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(cardView)

        // Section title (same style as detail sections)
        titleLabel.text = "cURL COMMAND"
        titleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.29, green: 0.76, blue: 0.76, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)

        // cURL text
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.attributedText = highlightCurl(curlString)
        textView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(textView)

        // Buttons row
        let buttonsStack = UIStackView()
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 8
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(buttonsStack)

        // Copy button (same style as "Copy cURL" in NetworkCell)
        copyButton.backgroundColor = UIColor(white: 0.18, alpha: 1)
        copyButton.layer.cornerRadius = 6
        copyButton.clipsToBounds = true
        copyButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        copyButton.setTitleColor(Color.mainGreen, for: .normal)
        copyButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        if let icon = UIImage(systemName: "doc.on.doc")?.withRenderingMode(.alwaysTemplate) {
            copyButton.setImage(icon, for: .normal)
            copyButton.tintColor = Color.mainGreen
            copyButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        }
        copyButton.setTitle("Copy", for: .normal)
        buttonsStack.addArrangedSubview(copyButton)

        // Share button
        shareButton.backgroundColor = UIColor(white: 0.18, alpha: 1)
        shareButton.layer.cornerRadius = 6
        shareButton.clipsToBounds = true
        shareButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        shareButton.setTitleColor(Color.mainGreen, for: .normal)
        shareButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        if let icon = UIImage(systemName: "square.and.arrow.up")?.withRenderingMode(.alwaysTemplate) {
            shareButton.setImage(icon, for: .normal)
            shareButton.tintColor = Color.mainGreen
            shareButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        }
        shareButton.setTitle("Share", for: .normal)
        buttonsStack.addArrangedSubview(shareButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            cardView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            cardView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            buttonsStack.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 14),
            buttonsStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            buttonsStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            buttonsStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            buttonsStack.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    @objc private func copyTapped() {
        UIPasteboard.general.string = curlString

        let originalTitle = copyButton.title(for: .normal)
        copyButton.setTitle("Copied!", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.copyButton.setTitle(originalTitle, for: .normal)
        }
    }

    @objc private func shareTapped() {
        let activity = UIActivityViewController(activityItems: [curlString], applicationActivities: nil)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            activity.popoverPresentationController?.sourceView = view
            activity.popoverPresentationController?.sourceRect = CGRect(
                x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0
            )
        }
        present(activity, animated: true)
    }

    // MARK: - cURL Syntax Highlighting

    private func highlightCurl(_ text: String) -> NSAttributedString {
        let font = UIFont(name: "Menlo", size: 12) ?? .monospacedSystemFont(ofSize: 12, weight: .regular)
        let attr = NSMutableAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: UIColor(white: 0.82, alpha: 1)
        ])

        let nsText = text as NSString
        let fullRange = NSRange(location: 0, length: nsText.length)

        let flagColor = UIColor(red: 0.40, green: 0.70, blue: 1.0, alpha: 1)       // blue
        let urlColor = UIColor(red: 0.26, green: 0.83, blue: 0.35, alpha: 1)        // green
        let stringColor = UIColor(red: 0.82, green: 0.60, blue: 0.34, alpha: 1)     // orange
        let cmdColor = UIColor(red: 0.70, green: 0.50, blue: 0.88, alpha: 1)        // purple

        // "curl" command keyword
        if let regex = try? NSRegularExpression(pattern: "^curl\\b", options: []) {
            for match in regex.matches(in: text, range: fullRange) {
                attr.addAttribute(.foregroundColor, value: cmdColor, range: match.range)
                attr.addAttribute(.font, value: UIFont(name: "Menlo-Bold", size: 12) ?? .monospacedSystemFont(ofSize: 12, weight: .bold), range: match.range)
            }
        }

        // Flags: -X, -H, -d, --data-binary
        if let regex = try? NSRegularExpression(pattern: "(?:^|\\s)(-X|-H|-d|--data-binary)\\b", options: .anchorsMatchLines) {
            for match in regex.matches(in: text, range: fullRange) {
                attr.addAttribute(.foregroundColor, value: flagColor, range: match.range(at: 1))
            }
        }

        // Single-quoted strings: '...'
        if let regex = try? NSRegularExpression(pattern: "'[^']*'", options: []) {
            for match in regex.matches(in: text, range: fullRange) {
                let matchStr = nsText.substring(with: match.range)
                if matchStr.contains("://") {
                    attr.addAttribute(.foregroundColor, value: urlColor, range: match.range)
                } else {
                    attr.addAttribute(.foregroundColor, value: stringColor, range: match.range)
                }
            }
        }

        // Line continuation backslash
        if let regex = try? NSRegularExpression(pattern: "\\\\$", options: .anchorsMatchLines) {
            for match in regex.matches(in: text, range: fullRange) {
                attr.addAttribute(.foregroundColor, value: UIColor(white: 0.40, alpha: 1), range: match.range)
            }
        }

        return attr
    }
}

