//
//  InformationWebViewController.swift
//  SurfApp
//
//  Created by 김상현 on 2023/05/17.
//

import UIKit
import SnapKit
import WebKit

class InformationWebViewController: UIViewController {
    let url = URL(string: "https://miniature-wildcat-c1c.notion.site/fe0289c244054ec7ada51835d301028c")

    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        loadPage()
    }
    
    private func setLayout() {
        view.addSubview(webView)
        
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadPage() {
        let urlRequest = URLRequest(url: url!)
        webView.load(urlRequest)
    }
}

extension InformationWebViewController: WKUIDelegate {
    
}
