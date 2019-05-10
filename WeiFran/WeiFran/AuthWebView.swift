//
//  AuthWebView.swift
//  WeiFran
//
//  Created by francis on 2019/5/4.
//  Copyright © 2019年 francis. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Alamofire
class AuthWebViewController: UIViewController,WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBAction func authWebViewCancel(_ sender: Any) {
        webView.stopLoading()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        if hasNetwork(){
            let urlStr = "https://api.weibo.com/oauth2/authorize?client_id=\(global.kAppkey)&redirect_uri=\(global.kRedirectURI)&display=mobile&response_type=code"
            let urlRequest = URLRequest.init(url: URL.init(string: urlStr)!)
            webView.load(urlRequest)
        }else{
            showOfflineWebView()
        }
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        if let query = webView.url?.query {
            print(query)
            if(query.hasPrefix("code=")){
                webView.stopLoading()
                global.kAuthCode = String((query.split(separator: "="))[1])
                self.dismiss(animated: true, completion: {()->Void in
                    DispatchQueue.global().async {
                        self.asyncAccsessToken()
                    }
                })
            }
        }
    }
    func asyncAccsessToken(){
        let tokenUrlStr = "https://api.weibo.com/oauth2/access_token?client_id=\(global.kAppkey)&client_secret=\(global.kAppSecret)&grant_type=authorization_code&code=\(global.kAuthCode)&redirect_uri=\(global.kRedirectURI)"
        Alamofire.request(URL.init(string: tokenUrlStr)!, method: HTTPMethod.post, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            let data = response.result.value as! NSDictionary
            global.kAccessToken = data["access_token"] as! String
            global.uid = data["uid"] as! String
            print(global.kAccessToken)
        }
    }
    func showOfflineWebView(){
        let htmlStr = """
        <div style="width:100%;height:100%;text-align: center;font-size: 50px;font-family:sans-serif;margin-top: 10%">
        You are offline
        <div style="width:100%">
        <img src="./offlineImage.png" style="width:56%"/>
        </div>
        </div>
        """
        webView.loadHTMLString(htmlStr, baseURL: Bundle.main.bundleURL)
    }
    func hasNetwork()->Bool{
        let manager = NetworkReachabilityManager.init()!
        return manager.isReachable
    }
    
}
