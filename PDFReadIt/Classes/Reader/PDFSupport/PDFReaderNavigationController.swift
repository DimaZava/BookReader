//
//  PDFReaderNavigationController.swift
//  BookReader
//
//  Created by Dmitryj on 04.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

open class PDFReaderNavigationController: UINavigationController {

    @objc
    var postPresentAction: ((PDFReaderNavigationController) -> Void)?
    @objc
    var postDismissAction: ((PDFReaderNavigationController) -> Void)?

    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        postPresentAction?(self)
    }

    override open func popViewController(animated: Bool) -> UIViewController? {
        defer { postDismissAction?(self) }
        return super.popViewController(animated: animated)
    }

    override open func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        postPresentAction?(self)
    }

    override open func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        defer { postDismissAction?(self) }
        super.dismiss(animated: flag, completion: completion)
    }
}
