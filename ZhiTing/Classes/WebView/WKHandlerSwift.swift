
import Foundation
import WebKit

public let WKEventHandlerNameSwift = "WKEventHandler"

public protocol WKEventHandlerProtocol:class,NSObjectProtocol {
    func nativeHandle(funcName:inout String!, params:Dictionary<String, Any>?, callback:((_ response:Any?) -> Void)?) -> Void
    
}

open class WKEventHandlerSwift: NSObject,WKScriptMessageHandler {
    
    public weak var webView:WKWebView!
    weak var delegate:WKEventHandlerProtocol?
    
    public init(_ webView:WKWebView!,_ delegate:WKEventHandlerProtocol!) {
        super.init()
        self.webView = webView
        self.delegate = delegate
    }
    public class func handleJS() -> String {
        
        let jsString = jsCode.replacingOccurrences(of: "\n", with: "")
        return jsString
    }
    
    /// 清空handler的数据信息， 注入的脚本。绑定事件信息等等
    /// - Parameter handler: handler
    /// - Returns: void
    public func cleanHandler( handler:inout WKEventHandlerSwift!) -> Void {
        if (handler.webView != nil) {
            handler.webView.evaluateJavaScript("zhiting.removeAllCallBacks();", completionHandler: nil)
            handler.webView.configuration.userContentController.removeScriptMessageHandler(forName: WKEventHandlerNameSwift)
        }
        handler = nil
    }
    
    /// 执行js脚本
    /// - Parameters:
    ///   - js: js
    ///   - completed: completed
    /// - Returns: void
    public func evaluateJavaScript(js:String!, withCompleted completed:((_ data:Any?, _ error:Error?) ->Void)?) -> Void {
        self.webView.evaluateJavaScript(js, completionHandler: { (data:Any?, error:Error?) in
            completed?(data,error)
        })
    }
    
    /// 执行js脚本，同步返回
    /// - Parameters:
    ///   - js: js
    ///   - error: error
    /// - Returns: void
    public func synEvaluateJavaScript(js:String!, withError error:inout UnsafeMutablePointer<Error>?) -> Any? {
        var result:Any?
        var success:Bool? = false
        var result_Error:Error?
        self.evaluateJavaScript(js: js, withCompleted: { (data:Any?, tmp_error:Error?) in
            if tmp_error != nil {
                result = data
                success = true
            } else {
                result_Error = tmp_error
            }
        })
        
        while success != nil {
            RunLoop.current.run(mode: .default, before: .distantFuture)
        }
        
        if error != nil {
            do {
                try error = withUnsafeMutablePointer(to: &result_Error, result_Error as! (UnsafeMutablePointer<Error?>) throws -> UnsafeMutablePointer<Error>?)
            } catch  {
                #if DEBUG
                print("WKEventHandlerNameSwift error:%@",error)
                #endif
            }
        }
        return result
        
    }
    
    
    //MARK: WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == WKEventHandlerNameSwift {
            let body: Dictionary? = message.body as? Dictionary<String, Any>;
            var funcName: String? = (body!["func"] as! String)
            let params: Dictionary = (body!["params"] as? Dictionary<String, Any>) ?? [:]
            let callbackID: String = (body!["callbackID"] as? String) ?? ""

            self.interactWithPlguin(withFuncName: &funcName, withParams: params, withCallback: { (response:Any?) in
                self.callJSWithCallbackName(callbackName: callbackID, response: response)
            })
            
        }
    }
    
    private func interactWithPlguin(withFuncName funcName:inout String!, withParams params:Dictionary<String, Any>?, withCallback callback:((_ response:Any?) -> Void)?) -> Void {
        self.delegate?.nativeHandle(funcName: &funcName, params: params, callback: callback)

        
    }
    
    private func callJSWithCallbackName(callbackName:String, response:Any?) {
        if callbackName == "" { return }

        var responseString:String = response as? String ?? ""
        if response is Dictionary<String,Any>
            || response is Array<Any> {
            var jsonData:Data
            do {
                try jsonData = JSONSerialization.data(withJSONObject: response!, options: .prettyPrinted)
                var jsonString:String = String.init(data: jsonData , encoding: .utf8) ?? ""
                jsonString = jsonString.replacingOccurrences(of: "\n", with: "")
                responseString = jsonString
            } catch  {
                #if DEBUG
                print("WKEventHandlerNameSwift error:%@",error)
                #endif
            }
        }
        let jsString:String = String.init(format: "zhiting.callBack('%@','%@');", callbackName,responseString)
        self.webView.evaluateJavaScript(jsString, completionHandler: { (data:Any?, error:Error?) in
            #if DEBUG
            print("zhiting.callBack:\ndata: error%@\n error: %@\n",data as Any,error as Any)
            #endif
        })
        
    }
    
    
}
