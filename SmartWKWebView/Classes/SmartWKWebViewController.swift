//
//  PannableViewController.swift
//  SmartWKWebView
//
//  Created by Baris Atamer on 12/24/17.
//

import Foundation
import UIKit
import WebKit

public class SmartWKWebViewController: PannableViewController, UIScrollViewDelegate {

    
    // MARK: - Public Variables
    
    public var barHeight: CGFloat = 44
    public var topMargin: CGFloat = UIApplication.shared.statusBarFrame.size.height
    public var stringLoading = "Loading"
    @objc public var url: URL!
    @objc public var webView: WKWebView!
	@objc public weak var delegate: SmartWKWebViewControllerDelegate?
    @objc public weak var webViewNavigationDelegate: WKNavigationDelegate?
    var toolbar: SmartWKWebViewToolbar!
    
    
    // MARK: - Private Variables
    
    private var backgroundBlackOverlay: UIView = {
        let v = UIView(frame: CGRect.zero);
        v.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        return v;
    } ()
    
    private var isDraggingEnabled = true
    
    
    // MARK: - Initialization
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        modalPresentationStyle = .overCurrentContext
    }

    
    // MARK: - View Lifecycle
    
    public override func loadView() {
        self.view = UIView(frame: CGRect.zero)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(self.backgroundBlackOverlay)
        initToolbar()
        initWebView()
        view.addObserver(self, forKeyPath: #keyPath(UIView.frame), options: .new, context: nil)
    }
    
    func initToolbar() {
        toolbar = SmartWKWebViewToolbar.init(frame: CGRect(x: 0, y: topMargin, width: UIScreen.main.bounds.width, height: barHeight))
        view.addSubview(toolbar)
        toolbar.closeButton.addTarget(self, action: #selector(closeTapped), for: UIControl.Event.touchUpInside)
    }
    
    func initWebView() {
        webView = WKWebView(frame: CGRect.zero)
        webView.backgroundColor = .white
        
        webView.navigationDelegate = webViewNavigationDelegate
        webView.scrollView.delegate = self
        
        webView.scrollView.panGestureRecognizer.addTarget(self, action: #selector(panGestureActionWebView(_:)))
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        view.addSubview(webView)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        toolbar.titleLabel.text = stringLoading
        
        if let URL = url {
            let urlRequest = URLRequest.init(url: URL)
            webView.load(urlRequest)
            
            if let host = URL.host {
                toolbar.addressLabel.text = host
            }
            else {
                toolbar.addressLabel.text = url?.absoluteString ?? ""
            }
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView.frame = CGRect(x: 0, y: barHeight + topMargin,
                               width: UIScreen.main.bounds.width,
                               height: UIScreen.main.bounds.height - barHeight - topMargin)
        
        backgroundBlackOverlay.frame = CGRect(x: 0,
                                              y: -UIScreen.main.bounds.height,
                                              width: UIScreen.main.bounds.width,
                                              height: UIScreen.main.bounds.height * 2)
        
        toolbar.frame = CGRect(x: 0, y: topMargin, width: UIScreen.main.bounds.width, height: barHeight)
    }
    
    deinit {
        if (webView != nil) {
            webView.scrollView.delegate = nil
            
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        }
        
        if (view != nil) {
            view.removeObserver(self, forKeyPath: #keyPath(UIView.frame))
        }
    }
    
    public func updateTitle(title: String) {
        toolbar.titleLabel.text = title
    }
    
    
    // MARK: - Button events
    
    @objc func closeTapped() {
        if #available(iOS 10.0, *) {
        }
        else {
            // Looks better on iOS 9 to do this transition.
            modalTransitionStyle = .crossDissolve
        }
        
        dismiss()
    }
    
    override func dismiss() {
        dismiss(animated: true, completion: {
            self.delegate?.didDismiss?(viewController: self)
        })
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        
        if (keyPath == "estimatedProgress") {
            toolbar.progressView.progress = Float(webView.estimatedProgress)
            toolbar.progressView.isHidden = toolbar.progressView.progress == 1
        }
        else if (keyPath == "frame") {
            let alpha = 1 - (view.frame.origin.y / UIScreen.main.bounds.height)
            backgroundBlackOverlay.alpha = alpha
        }
    }
    
    
    // MARK: - ScrollView Delegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y == 0 && scrollView.panGestureRecognizer.velocity(in: view).y == 0) {
            isDraggingEnabled = true
        }
    }
    
    @objc func panGestureActionWebView(_ panGesture: UIPanGestureRecognizer) {
        if panGesture.translation(in: self.view).y < 0 {
            isDraggingEnabled = false
        }
    
        if isDraggingEnabled {
            panGestureAction(panGesture)
            webView.scrollView.contentOffset.y = 0
        }
    }
}

@objc public protocol SmartWKWebViewControllerDelegate {
	@objc optional func didDismiss(viewController: SmartWKWebViewController)
}
