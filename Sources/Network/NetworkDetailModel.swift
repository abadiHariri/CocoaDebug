//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation

struct NetworkDetailModel {
    var title: String?
    var content: String?
    var url: String?
    var image: UIImage?
    var blankContent: String?
    var isLast: Bool = false
    var requestSerializer: RequestSerializer = RequestSerializer.JSON//default JSON format
    var requestHeaderFields: [String: Any]?
    var responseHeaderFields: [String: Any]?
    var requestData: Data?
    var responseData: Data?
    var httpModel: _HttpModel?
    var heigth:Double = 0
    var mustInPreview:Bool = false

    
    init(title: String? = nil, content: String? = "", url: String? = "", image: UIImage? = nil, httpModel: _HttpModel? = nil) {
        self.title = title?.replacingOccurrences(of: "\\/", with: "/")
        self.content = content?.replacingOccurrences(of: "\\/", with: "/")
        self.url = url?.replacingOccurrences(of: "\\/", with: "/")
        self.image = image
        self.httpModel = httpModel
        
        mustInPreview = (content?.count ?? 0 > 10000)
        self.heigth = mustInPreview ? 100 : Double(self.content?.height(with: UIFont.systemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 30)) ?? 0.0)
        print("Estimated size of label: \(heigth)")
      

      //  let estimatedSize = estimatedSizeOfLabel(text:  self.content ?? "", font: labelFont, maxWidth: maxWidth)
     
        
//        if title == "REQUEST" {
//            self.requestData = httpModel?.requestData
//
//            guard let content = content, let url = url, let data = self.requestData, let keys = CocoaDebugSettings.shared.protobufTransferMap?.keys else {return}
//            if !content.contains("GPBMessage") {return}
//            self.title = "REQUEST (Protobuf)"
//
//            for key in keys {
//                if url.contains(key) {
//                    //1.
//                    guard let arr : Array<String> = CocoaDebugSettings.shared.protobufTransferMap?[key] else {return}
//                    if arr.count == 2 {
//                        //2.
//                        let clsNameString = arr[0]
//                        guard let cls : AnyObject.Type = NSClassFromString(clsNameString) else {return}
//                        //protobuf
//                        guard let obj = try? cls.parse(from: data) else {return}
//                        //HuiCao
//                        let jsonString = obj._JSONString(withIgnoreFields: nil)
//                        //pretty print
//                        if let prettyJsonString = jsonString?.jsonStringToPrettyJsonString() {
//                            self.content = prettyJsonString
//                        } else {
//                            self.content = jsonString
//                        }
//
//                        self.content = self.content?.replacingOccurrences(of: "\\/", with: "/")
//                        return
//                    }
//                }
//            }
//        }
            
            
            
//        else if title == "RESPONSE" {
//            self.responseData = httpModel?.responseData
//
//            guard let content = content, let url = url, let data = self.responseData, let keys = CocoaDebugSettings.shared.protobufTransferMap?.keys else {return}
//            if !content.contains("GPBMessage") {return}
//            self.title = "RESPONSE (Protobuf)"
//
//            for key in keys {
//                if url.contains(key) {
//                    //1.
//                    guard let arr : Array<String> = CocoaDebugSettings.shared.protobufTransferMap?[key] else {return}
//                    if arr.count == 2 {
//                        //2.
//                        let clsNameString = arr[1]
//                        guard let cls : AnyObject.Type = NSClassFromString(clsNameString) else {return}
//                        //protobuf
//                        guard let obj = try? cls.parse(from: data) else {return}
//                        //HuiCao
//                        let jsonString = obj._JSONString(withIgnoreFields: nil)
//                        //pretty print
//                        if let prettyJsonString = jsonString?.jsonStringToPrettyJsonString() {
//                            self.content = prettyJsonString
//                        } else {
//                            self.content = jsonString
//                        }
//
//                        self.content = self.content?.replacingOccurrences(of: "\\/", with: "/")
//                        return
//                    }
//                }
//            }
//        }
    }
}
