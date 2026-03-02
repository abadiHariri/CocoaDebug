//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

class LogViewController: UIViewController {

    var reachEnd: Bool = true
    var firstIn: Bool = true
    var reloadDataFinish: Bool = true

    private var deleteItem: UIBarButtonItem!
    private var defaultTableView: UITableView!
    private var defaultSearchBar: UISearchBar!

    /// Combined log models from all sources (app + RN + web), sorted by date
    var allModels: [_OCLogModel] = []
    var cacheModels: [_OCLogModel]?
    var searchModels: [_OCLogModel]?


    // MARK: - Search

    func searchLogic(_ searchText: String = "") {
        guard let cache = cacheModels else { return }
        if searchText.isEmpty {
            allModels = cache
        } else {
            allModels = cache.filter {
                ($0.content ?? "").lowercased().contains(searchText.lowercased())
            }
        }
    }

    // MARK: - Reload

    func reloadLogs(needScrollToEnd: Bool = false, needReloadData: Bool = true) {
        if !reloadDataFinish { return }

        // Merge all 3 log stores into one list sorted by date
        var combined: [_OCLogModel] = []
        if let normal = _OCLogStoreManager.shared.normalLogArray as? [_OCLogModel] {
            combined.append(contentsOf: normal)
        }
        if let rn = _OCLogStoreManager.shared.rnLogArray as? [_OCLogModel] {
            combined.append(contentsOf: rn)
        }
        if let web = _OCLogStoreManager.shared.webLogArray as? [_OCLogModel] {
            combined.append(contentsOf: web)
        }
        combined.sort { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
        allModels = combined
        cacheModels = combined

        // Apply search filter
        searchLogic(CocoaDebugSettings.shared.logSearchWordNormal ?? "")

        if needReloadData || allModels.count > 0 {
            reloadDataFinish = false
            defaultTableView.reloadData {
                self.reloadDataFinish = true
            }
        }

        if needScrollToEnd && allModels.count > 0 {
            defaultTableView.tableViewScrollToBottom(animated: !firstIn)
            firstIn = false
        }
    }

    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Nav bar title
        let titleLabel = UILabel()
        titleLabel.text = "Logs"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = Color.mainGreen
        navigationItem.titleView = titleLabel

        // Nav bar buttons: trash, up, down
        let bundle = Bundle(for: LogViewController.self)
        let upImage   = UIImage(named: "_icon_file_type_up.png",   in: bundle, compatibleWith: nil)
        let downImage = UIImage(named: "_icon_file_type_down.png", in: bundle, compatibleWith: nil)
        let upButton   = UIBarButtonItem(image: upImage,   style: .plain, target: self, action: #selector(didTapUp(_:)))
        let downButton = UIBarButtonItem(image: downImage, style: .plain, target: self, action: #selector(didTapDown(_:)))
        upButton.tintColor   = Color.mainGreen
        downButton.tintColor = Color.mainGreen
        deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(resetLogs(_:)))
        deleteItem.tintColor = Color.mainGreen
        navigationItem.rightBarButtonItems = [deleteItem, downButton, upButton]

        // Configure main table
        defaultTableView.register(LogCell.self, forCellReuseIdentifier: "LogCell")
        defaultTableView.tableFooterView = UIView()
        defaultTableView.delegate = self
        defaultTableView.dataSource = self
        defaultTableView.backgroundColor = .black
        defaultTableView.separatorStyle = .none
        defaultTableView.rowHeight = UITableView.automaticDimension
        defaultTableView.estimatedRowHeight = 80
        defaultTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)
        defaultTableView.showsVerticalScrollIndicator = false

        // Search bar
        defaultSearchBar.delegate = self
        defaultSearchBar.text = CocoaDebugSettings.shared.logSearchWordNormal
        defaultSearchBar.barTintColor = .black
        defaultSearchBar.isTranslucent = false
        defaultSearchBar.tintColor = Color.mainGreen
        defaultSearchBar.backgroundImage = UIImage()
        defaultSearchBar.searchTextField.textColor = .white
        defaultSearchBar.searchTextField.backgroundColor = UIColor(white: 0.15, alpha: 1)
        defaultSearchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search logs...",
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        defaultSearchBar.searchTextField.leftView?.tintColor = .lightGray
        defaultSearchBar.searchTextField.returnKeyType = .default

        // Notification
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "refreshLogs_CocoaDebug"),
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.refreshLogs_notification()
        }

        reloadLogs(needScrollToEnd: true, needReloadData: true)
    }

    private func setupUI() {
        view.backgroundColor = .black

        defaultSearchBar = UISearchBar()
        defaultSearchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(defaultSearchBar)

        defaultTableView = UITableView(frame: .zero, style: .plain)
        defaultTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(defaultTableView)

        NSLayoutConstraint.activate([
            defaultSearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            defaultSearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            defaultSearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            defaultSearchBar.heightAnchor.constraint(equalToConstant: 44),

            defaultTableView.topAnchor.constraint(equalTo: defaultSearchBar.bottomAnchor),
            defaultTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            defaultTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            defaultTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        defaultSearchBar.resignFirstResponder()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Actions

    @objc func didTapDown(_ sender: Any) {
        defaultTableView.tableViewScrollToBottom(animated: true)
        defaultSearchBar.resignFirstResponder()
        reachEnd = true
    }

    @objc func didTapUp(_ sender: Any) {
        defaultTableView.tableViewScrollToHeader(animated: true)
        defaultSearchBar.resignFirstResponder()
        reachEnd = false
    }

    @objc func resetLogs(_ sender: Any) {
        allModels = []
        cacheModels = []
        defaultSearchBar.resignFirstResponder()

        _OCLogStoreManager.shared.resetNormalLogs()
        _OCLogStoreManager.shared.resetRNLogs()
        _OCLogStoreManager.shared.resetWebLogs()

        defaultTableView.reloadData()
    }

    @objc func didTapView() {
        defaultSearchBar.resignFirstResponder()
    }

    // MARK: - Notification

    @objc func refreshLogs_notification() {
        reloadLogs(needScrollToEnd: reachEnd, needReloadData: true)
    }
}

// MARK: - UITableViewDataSource

extension LogViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! LogCell
        guard indexPath.row < allModels.count else { return cell }
        let logModel = allModels[indexPath.row]
        cell.index = indexPath.row
        cell.model = logModel

        // Wire "Show Full JSON" button
        cell.onShowFull = { [weak self] in
            guard let self = self else { return }
            if let json = LogCell.extractJSON(from: logModel) {
                self.pushJSONViewerOrFallback(with: json)
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension LogViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        defaultSearchBar.resignFirstResponder()
        reachEnd = false

        guard indexPath.row < allModels.count else { return }
        let logModel = allModels[indexPath.row]

        // Determine title from log type
        let logTitleString: String
        switch logModel.logType {
        case .normal: logTitleString = "App Log"
        case .rn:     logTitleString = "React Log"
        case .web:    logTitleString = "Web Log"
        @unknown default: logTitleString = "Log"
        }

        // If JSON, open JSON viewer
        if let json = LogCell.extractJSON(from: logModel) {
            if let prevIndex = allModels.firstIndex(where: { $0.isSelected }) {
                allModels[prevIndex].isSelected = false
            }
            logModel.isSelected = true
            defaultTableView.reloadData()
            pushJSONViewerOrFallback(with: json)
            return
        }

        let vc = JsonViewController()
        vc.editType = .log
        vc.logTitleString = logTitleString
        vc.logModels = allModels
        vc.logModel = logModel

        navigationController?.pushViewController(vc, animated: true)

        vc.justCancelCallback = {
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UIScrollViewDelegate

extension LogViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        defaultSearchBar.resignFirstResponder()
        reachEnd = false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            reachEnd = true
        }
    }
}

// MARK: - UISearchBarDelegate

extension LogViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        CocoaDebugSettings.shared.logSearchWordNormal = searchText
        searchLogic(searchText)
        defaultTableView.reloadData()
    }
}
