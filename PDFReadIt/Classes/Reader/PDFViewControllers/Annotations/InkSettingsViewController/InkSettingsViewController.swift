//
//  InkSettingsViewController.swift
//  PDFReadIt
//
//  Created by Dmitry Zawadsky on 13.02.2020.
//  Copyright © 2020 Kishikawa Katsumi. All rights reserved.
//

import UIKit

class InkSettingsViewController: UIViewController {

    enum InkSettingsCells: Int, CaseIterable {
        case example
        case strokeColor
        case fillColor
        case opacity
        case thickness
    }

    // MARK: - Outlets
    @IBOutlet weak var tableView: SelfSizedTableView!

    // MARK: - Constants
    let inkSettings = InkSettings.sharedInstance

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ink"

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonAction(_:)))
        ]

        InkSettingsCells.allCases.forEach { cellType in
            switch cellType {
            case .example:
                let name = String(describing: InkSettingsExampleCell.self)
                tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
            case .strokeColor:
                let name = String(describing: InkSettingsStrokeColorCell.self)
                tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
            case .fillColor:
                let name = String(describing: InkSettingsFillColorCell.self)
                tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
            case .opacity:
                let name = String(describing: InkSettingsOpacityCell.self)
                tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
            case .thickness:
                let name = String(describing: InkSettingsThicknessCell.self)
                tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
            }
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let desiredContentSize = tableView.intrinsicContentSize
        navigationController?.preferredContentSize = CGSize(width: desiredContentSize.width,
                                                            height: desiredContentSize.height)
        tableView.reloadData()
    }

    // MARK: - Actions
    @objc
    func doneBarButtonAction(_ barButton: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate
extension InkSettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellType = InkSettingsCells(rawValue: indexPath.row) else { fatalError("Unknown InkSettingsCells case") }

        switch cellType {
        case .example:
            tableView.deselectRow(at: indexPath, animated: false)
        case .strokeColor:
            tableView.deselectRow(at: indexPath, animated: true)
            let viewController = InkSettingsColorPickerViewController(with: .strokeColor)
            viewController.delegate = self
            navigationController?.pushViewController(viewController, animated: true)
        case .fillColor:
            tableView.deselectRow(at: indexPath, animated: true)
            let viewController = InkSettingsColorPickerViewController(with: .fillColor)
            viewController.delegate = self
            navigationController?.pushViewController(viewController, animated: true)
        case .opacity:
            tableView.deselectRow(at: indexPath, animated: true)
        case .thickness:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension InkSettingsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return InkSettingsCells.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellType = InkSettingsCells(rawValue: indexPath.row) else { fatalError("Unknown InkSettingsCells case") }

        switch cellType {
        case .example:
            let name = String(describing: InkSettingsExampleCell.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: name, for: indexPath) as! InkSettingsExampleCell
            cell.configure(with: inkSettings)
            return cell
        case .strokeColor:
            let name = String(describing: InkSettingsStrokeColorCell.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: name, for: indexPath) as! InkSettingsStrokeColorCell
            cell.configure(with: inkSettings)
            return cell
        case .fillColor:
            let name = String(describing: InkSettingsFillColorCell.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: name, for: indexPath) as! InkSettingsFillColorCell
            cell.configure(with: inkSettings)
            return cell
        case .opacity:
            let name = String(describing: InkSettingsOpacityCell.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: name, for: indexPath) as! InkSettingsOpacityCell
            cell.delegate = self
            cell.configure(with: inkSettings)
            return cell
        case .thickness:
            let name = String(describing: InkSettingsThicknessCell.self)
            let cell = tableView.dequeueReusableCell(withIdentifier: name, for: indexPath) as! InkSettingsThicknessCell
            cell.delegate = self
            cell.configure(with: inkSettings)
            return cell
        }
    }
}

// MARK: - InkSettingsStrokeColorViewControllerDelegate
extension InkSettingsViewController: InkSettingsStrokeColorViewControllerDelegate {

    func didSelect(color: UIColor, for mode: InkSettingsColorPickerViewController.Mode) {
        var indexPathsToReload = [IndexPath]()
        switch mode {
        case .strokeColor:
            inkSettings.strokeColor = color
            if let cell = tableView.visibleCells.first(where: { $0 is InkSettingsStrokeColorCell }),
                let indexPath = tableView.indexPath(for: cell) {
                indexPathsToReload.append(indexPath)
            }
        case .fillColor:
            inkSettings.fillColor = color
            if let cell = tableView.visibleCells.first(where: { $0 is InkSettingsFillColorCell }),
                let indexPath = tableView.indexPath(for: cell) {
                indexPathsToReload.append(indexPath)
            }
        }
        if let cell = tableView.visibleCells.first(where: { $0 is InkSettingsExampleCell }),
            let indexPath = tableView.indexPath(for: cell) {
            indexPathsToReload.append(indexPath)
        }
        tableView.reloadRows(at: indexPathsToReload, with: .none)
    }
}

// MARK: - InkSettingsOpacityCellDelegate
extension InkSettingsViewController: InkSettingsOpacityCellDelegate {

    func didUpdate(opacity value: Float) {
        var indexPathsToReload = [IndexPath]()
        if let cell = tableView.visibleCells.first(where: { $0 is InkSettingsOpacityCell }),
            let indexPath = tableView.indexPath(for: cell) {
            indexPathsToReload.append(indexPath)
        }
        if let cell = tableView.visibleCells.first(where: { $0 is InkSettingsExampleCell }),
            let indexPath = tableView.indexPath(for: cell) {
            indexPathsToReload.append(indexPath)
        }
        tableView.reloadRows(at: indexPathsToReload, with: .none)
    }
}

// MARK: - InkSettingsThicknessCellDelegate
extension InkSettingsViewController: InkSettingsThicknessCellDelegate {

    func didUpdate(thickness value: Float) {
        var indexPathsToReload = [IndexPath]()
        if let cell = tableView.visibleCells.first(where: { $0 is InkSettingsThicknessCell }),
            let indexPath = tableView.indexPath(for: cell) {
            indexPathsToReload.append(indexPath)
        }
        if let cell = tableView.visibleCells.first(where: { $0 is InkSettingsExampleCell }),
            let indexPath = tableView.indexPath(for: cell) {
            indexPathsToReload.append(indexPath)
        }
        tableView.reloadRows(at: indexPathsToReload, with: .none)
    }
}
