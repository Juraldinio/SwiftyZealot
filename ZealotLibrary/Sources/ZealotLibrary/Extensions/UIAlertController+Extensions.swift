//
//  UIAlertController+Extensions.swift
//
//
//  Created by Juraldinio on 09.04.2024.
//

import UIKit

extension UIAlertController {
    
    public func addTextView(text: String) {
        let textViewer = TextViewController(text: text.isEmpty ? "No updates" : text)
        set(vc: textViewer)
    }
    
    func setMaxHeight(_ height: CGFloat) {
        guard let view else { return }
        let height = NSLayoutConstraint(item: view,
                                        attribute: .height,
                                        relatedBy: .lessThanOrEqual,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1,
                                        constant: height)
        view.addConstraint(height)
    }
    
    func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
        guard let vc else { return }
        setValue(vc, forKey: "contentViewController")
        if let height {
            vc.preferredContentSize.height = height
            preferredContentSize.height = height
        }
    }
}

final class TextViewController: UIViewController {
    
    private lazy var textView: UITextView = {
        $0.isEditable = false
        $0.isSelectable = true
        $0.backgroundColor = nil
        $0.font = UIFont.systemFont(ofSize: 15)
        return $0
    }(UITextView())
    
    init(text: String) {
        super.init(nibName: nil, bundle: nil)
        
        textView.text = text
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        textView.flashScrollIndicators()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = textView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            preferredContentSize.width = UIScreen.main.bounds.width * 0.618
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.scrollRangeToVisible(NSMakeRange(0, 1))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize.height = textView.contentSize.height
    }
}

final class WindowHandler {
    
    static let shared = WindowHandler()
    
    var window: UIWindow?
    var viewController: UIViewController?

    func present(viewController: UIViewController) {
        if self.viewController != nil { return }

        guard let window = UIApplication.shared.windows.first,
              let currentController = window.rootViewController else { return }
        
        self.window = window
        self.viewController = currentController

        let emptyController = UIViewController()
        window.rootViewController = emptyController
        
        emptyController.addChild(currentController)
        emptyController.view.addSubview(currentController.view)
        
        currentController.view.frame = emptyController.view.bounds
        currentController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        emptyController.present(viewController, animated: true, completion: nil)
        
        currentController.didMove(toParent: emptyController)
    }

    func dismiss() {
        
        guard let window, let viewController else { return }
        
        viewController.removeFromParent()
        window.rootViewController = viewController
        
        self.window = nil
        self.viewController = nil
    }
}
