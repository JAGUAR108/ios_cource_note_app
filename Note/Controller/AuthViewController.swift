//
//  AuthViewController.swift
//  GetGists
//
//  Created by Максим Бачурин on 07/08/2019.
//  Copyright © 2019 Максим Бачурин. All rights reserved.
//

import UIKit
import WebKit

protocol AuthViewControllerDelegate: class {
    func handleTokenChanged(token: String)
}

class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    private let webView = WKWebView()
    private let clientId = "" //Your Client Id
    private let clientSecret = "" //Your Client Secret

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        guard let request = tokenGetRequest else {return}
        webView.load(request)
        webView.navigationDelegate = self
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private var tokenGetRequest: URLRequest? {
        guard var urlComponents = URLComponents(string: "https://github.com/login/oauth/authorize") else {return nil}
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "scope", value: "gist")
        ]
        guard let url = urlComponents.url else {return nil}
        return URLRequest(url: url)
    }

}

extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == scheme {
            guard let components = URLComponents(string: url.absoluteString) else {return}
            if let code = components.queryItems?.first(where: {$0.name == "code"})?.value {
                guard var urlComponents = URLComponents(string: "https://github.com/login/oauth/access_token") else {return}
                urlComponents.queryItems = [
                    URLQueryItem(name: "client_id", value: clientId),
                    URLQueryItem(name: "client_secret", value: clientSecret),
                    URLQueryItem(name: "code", value: code)
                ]
                guard let url = urlComponents.url else {return}
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                let task = URLSession.shared.dataTask(with: request) { [weak self](data, response, error) in
                    if let error = error {
                        print(error)
                    }
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
                            if let token = json?["access_token"] {
                                self?.delegate?.handleTokenChanged(token: token)
                            }
                            DispatchQueue.main.async {
                                self?.dismiss(animated: true, completion: nil)
                            }
                        }catch {
                            print(error)
                        }
                    }
                    else {
                        self?.delegate?.handleTokenChanged(token: "ERROR GET TOKEN")
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
                task.resume()
            }
        }
        do {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if error.localizedDescription == "The Internet connection appears to be offline." {
            delegate?.handleTokenChanged(token: "ERROR GET TOKEN")
            dismiss(animated: true, completion: nil)
        }
    }
}

private let scheme = "" //Your URL callback scheme
