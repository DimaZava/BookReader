//
//  PDFReaderViewController+Delegates.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 18.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import MessageUI
import PDFKit
import UIKit

// MARK: - UIPopoverPresentationControllerDelegate
extension PDFReaderViewController: UIPopoverPresentationControllerDelegate {
    open func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension PDFReaderViewController: MFMailComposeViewControllerDelegate {

    open func mailComposeController(_ controller: MFMailComposeViewController,
                                    didFinishWith result: MFMailComposeResult,
                                    error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: - ActionMenuViewControllerDelegate
extension PDFReaderViewController: ActionMenuViewControllerDelegate {

    func didPrepareForShare(document: PDFDocument) {

        guard MFMailComposeViewController.canSendMail() else {
            print("This device doesn't support MFMailComposeViewController")
            return
        }

        let documentToProceed: PDFDocument
        if document.documentURL == nil {
            let basicName = pdfDocument?.documentURL?.lastPathComponent ?? "Document.pdf"
            let urlToWrite = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(basicName)
            document.write(to: urlToWrite)
            documentToProceed = PDFDocument(url: urlToWrite)!
        } else {
            documentToProceed = document
        }

        guard let fileName = documentToProceed.documentURL?.lastPathComponent,
            let attachmentData = documentToProceed.dataRepresentation() else { return }

        let mailComposeViewController = MFMailComposeViewController()

        if let title = pdfDocument?.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String {
            mailComposeViewController.setSubject(title)
        }

        mailComposeViewController.addAttachmentData(attachmentData, mimeType: "application/pdf", fileName: fileName)
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.modalPresentationStyle = .formSheet
        mailComposeViewController.isModalInPopover = true

        if navigationController?.presentedViewController != nil {
            navigationController?.dismiss(animated: true, completion: {
                self.navigationController?.present(mailComposeViewController, animated: true)
            })
        } else {
            navigationController?.present(mailComposeViewController, animated: true)
        }
    }

    func actionMenuViewControllerPrintDocument(_ actionMenuViewController: ActionMenuViewController) {
        UIPrintInteractionController.shared.printingItem = pdfDocument?.dataRepresentation()
        UIPrintInteractionController.shared.present(animated: true)
    }
}

extension PDFReaderViewController: UIGestureRecognizerDelegate {

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == barHideOnTapGestureRecognizer {
            return true
        }
        return false
    }
}

// MARK: - SearchViewControllerDelegate
extension PDFReaderViewController: SearchViewControllerDelegate {

    func searchViewController(_ searchViewController: PDFSearchViewController,
                              didSelectSearchResult selection: PDFSelection) {
        selectAndOpen(selection)
        showBars()
    }
}

// MARK: - OutlineViewControllerDelegate
extension PDFReaderViewController: OutlineViewControllerDelegate {

    func outlineViewController(_ outlineViewController: PDFOutlineViewController,
                               didSelectOutlineAt destination: PDFDestination) {
        setDefaultUIState()
        open(destination: destination)
    }
}

// MARK: - ThumbnailGridViewControllerDelegate
extension PDFReaderViewController: ThumbnailGridViewControllerDelegate {

    func thumbnailGridViewController(_ thumbnailGridViewController: PDFThumbnailGridViewController,
                                     didSelectPage page: PDFPage) {
        setDefaultUIState()
        open(page: page)
    }
}

extension PDFReaderViewController: BookmarkViewControllerDelegate {

    func bookmarkViewController(_ bookmarkViewController: PDFBookmarkViewController,
                                didSelectPage page: PDFPage) {
        setDefaultUIState()
        open(page: page)
    }
}
