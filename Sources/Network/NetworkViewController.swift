//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
//

import UIKit

class NetworkViewController: UIViewController {

    var reachEnd: Bool = true
    var firstIn: Bool = true
    var reloadDataFinish: Bool = true

    var models: Array<_HttpModel>?
    var cacheModels: Array<_HttpModel>?

    var naviItemTitleLabel: UILabel?

    // Filter state
    var selectedHost: String?
    var selectedEndpoint: String?
    var filterButton: UIBarButtonItem!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var deleteItem: UIBarButtonItem!
    @IBOutlet weak var naviItem: UINavigationItem!

    //MARK: - Filter logic

    /// Extract unique hostnames from all cached models
    private func uniqueHosts() -> [String] {
        guard let models = cacheModels else { return [] }
        var seen = Set<String>()
        var result = [String]()
        for model in models {
            if let host = model.url?.host, !host.isEmpty, seen.insert(host).inserted {
                result.append(host)
            }
        }
        return result.sorted()
    }

    /// Extract unique normalized endpoints for a given hostname
    private func uniqueEndpoints(forHost host: String) -> [String] {
        guard let models = cacheModels else { return [] }
        var seen = Set<String>()
        var result = [String]()
        for model in models {
            guard model.url?.host == host else { continue }
            let normalized = normalizeEndpoint(model.url?.path ?? "")
            if !normalized.isEmpty, seen.insert(normalized).inserted {
                result.append(normalized)
            }
        }
        return result.sorted()
    }

    /// Normalize a URL path by replacing numeric and UUID segments with {id}
    private func normalizeEndpoint(_ path: String) -> String {
        let components = path.components(separatedBy: "/")
        let normalized = components.map { component -> String in
            if component.isEmpty { return component }
            if component.allSatisfy({ $0.isNumber || $0 == "-" }) && component.contains(where: { $0.isNumber }) {
                return "{id}"
            }
            if UUID(uuidString: component) != nil { return "{id}" }
            return component
        }
        return normalized.joined(separator: "/")
    }

    /// Check if a model's URL path matches a normalized endpoint pattern
    private func modelMatchesEndpoint(_ model: _HttpModel, endpoint: String) -> Bool {
        let modelEndpoint = normalizeEndpoint(model.url?.path ?? "")
        return modelEndpoint == endpoint
    }

    /// Apply current filter state to cacheModels and update models
    private func applyFilter() {
        guard let cacheModels = cacheModels else {
            models = nil
            return
        }

        if selectedHost == nil {
            models = cacheModels
        } else {
            models = cacheModels.filter { model in
                guard model.url?.host == selectedHost else { return false }
                if let endpoint = selectedEndpoint {
                    return modelMatchesEndpoint(model, endpoint: endpoint)
                }
                return true
            }
        }
    }

    /// Update the filter button appearance based on current state
    private func updateFilterButtonTitle() {
        if selectedHost == nil {
            filterButton.image = UIImage(systemName: "line.3.horizontal.decrease.circle")
        } else {
            filterButton.image = UIImage(systemName: "line.3.horizontal.decrease.circle.fill")
        }
    }

    //MARK: - Filter actions

    @objc func didTapFilter() {
        let hosts = uniqueHosts()
        if hosts.isEmpty { return }

        let alert = UIAlertController(title: "Filter by Host", message: nil, preferredStyle: .actionSheet)

        // "All" option to clear filter
        let allAction = UIAlertAction(title: "All Hosts", style: selectedHost == nil ? .destructive : .default) { [weak self] _ in
            self?.selectedHost = nil
            self?.selectedEndpoint = nil
            self?.applyFilter()
            self?.updateFilterButtonTitle()
            self?.tableView.reloadData()
        }
        alert.addAction(allAction)

        // One action per unique hostname
        for host in hosts {
            let isSelected = (host == selectedHost)
            let title = isSelected ? "\u{2713} \(host)" : host
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.selectedHost = host
                self?.selectedEndpoint = nil
                self?.applyFilter()
                self?.updateFilterButtonTitle()
                self?.tableView.reloadData()

                // After selecting host, immediately offer endpoint filter
                self?.showEndpointFilter(forHost: host)
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.popoverPresentationController?.barButtonItem = filterButton
        present(alert, animated: true)
    }

    private func showEndpointFilter(forHost host: String) {
        let endpoints = uniqueEndpoints(forHost: host)
        if endpoints.count <= 1 { return }

        let alert = UIAlertController(title: "Filter by Endpoint", message: host, preferredStyle: .actionSheet)

        let allAction = UIAlertAction(title: "All Endpoints", style: selectedEndpoint == nil ? .destructive : .default) { [weak self] _ in
            self?.selectedEndpoint = nil
            self?.applyFilter()
            self?.tableView.reloadData()
        }
        alert.addAction(allAction)

        for endpoint in endpoints {
            let isSelected = (endpoint == selectedEndpoint)
            let title = isSelected ? "\u{2713} \(endpoint)" : endpoint
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.selectedEndpoint = endpoint
                self?.applyFilter()
                self?.tableView.reloadData()
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.popoverPresentationController?.barButtonItem = filterButton
        present(alert, animated: true)
    }

    //MARK: - private
    func reloadHttp(needScrollToEnd: Bool = false) {

        if reloadDataFinish == false { return }

        self.models = (_HttpDatasource.shared().httpModels as NSArray as? [_HttpModel])
        self.cacheModels = self.models

        applyFilter()

        self.reloadDataFinish = false
        self.tableView.reloadData {
            self.reloadDataFinish = true
        }

        if needScrollToEnd == false { return }

        if let count = self.models?.count {
            if count > 0 {
                self.tableView.tableViewScrollToBottom(animated: !firstIn)
                self.firstIn = false
            }
        }
    }

    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer.init(target: self, action: #selector(didTapView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.textColor = Color.mainGreen
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 20)
        naviItem.titleView = naviItemTitleLabel

        naviItemTitleLabel?.text = "\u{1f680}[0]"
        deleteItem.tintColor = Color.mainGreen

        // Hide the storyboard search bar
        searchBar.isHidden = true
        searchBar.removeFromSuperview()

        // Filter button in nav bar
        filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(didTapFilter)
        )
        filterButton.tintColor = Color.mainGreen

        var rightItems = naviItem.rightBarButtonItems ?? []
        rightItems.append(filterButton)
        naviItem.rightBarButtonItems = rightItems

        //notification
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "reloadHttp_CocoaDebug"), object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.reloadHttp(needScrollToEnd: self?.reachEnd ?? true)
        }

        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self

        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0

        reloadHttp(needScrollToEnd: true)

        if models?.count ?? 0 > CocoaDebugSettings.shared.networkLastIndex && CocoaDebugSettings.shared.networkLastIndex > 0 {
            tableView.tableViewScrollToIndex(index: CocoaDebugSettings.shared.networkLastIndex, animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: - target action
    @IBAction func didTapDown(_ sender: Any) {
        tableView.tableViewScrollToBottom(animated: true)
        reachEnd = true
        CocoaDebugSettings.shared.networkLastIndex = 0
    }

    @IBAction func didTapUp(_ sender: Any) {
        tableView.tableViewScrollToHeader(animated: true)
        reachEnd = false
        CocoaDebugSettings.shared.networkLastIndex = 0
    }

    @IBAction func tapTrashButton(_ sender: UIBarButtonItem) {
        _HttpDatasource.shared().reset()
        models = []
        cacheModels = []
        selectedHost = nil
        selectedEndpoint = nil
        updateFilterButtonTitle()
        CocoaDebugSettings.shared.networkLastIndex = 0

        self.tableView.reloadData()
        self.naviItemTitleLabel?.text = "\u{1f680}[0]"

        NotificationCenter.default.post(name: NSNotification.Name("deleteAllLogs_CocoaDebug"), object: nil, userInfo: nil)
    }

    @objc func didTapView() {
        view.endEditing(true)
    }
}

//MARK: - UITableViewDataSource
extension NetworkViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = models?.count {
            naviItemTitleLabel?.text = "\u{1f680}[" + String(count) + "]"
            return count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkCell", for: indexPath)
            as! NetworkCell

        cell.httpModel = models?[indexPath.row]
        cell.index = indexPath.row
        return cell
    }
}

//MARK: - UITableViewDelegate
extension NetworkViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let serverURL = CocoaDebugSettings.shared.serverURL else { return 0 }
        let model = models?[indexPath.row]
        var height: CGFloat = 0.0

        if let cString = model?.url.absoluteString.cString(using: String.Encoding.utf8) {
            if let content_ = NSString(cString: cString, encoding: String.Encoding.utf8.rawValue) {

                if model?.url.absoluteString.contains(serverURL) == true {
                    if #available(iOS 8.2, *) {
                        height = content_.height(with: UIFont.systemFont(ofSize: 13, weight: .heavy), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    } else {
                        height = content_.height(with: UIFont.boldSystemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    }
                } else {
                    if #available(iOS 8.2, *) {
                        height = content_.height(with: UIFont.systemFont(ofSize: 13, weight: .regular), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    } else {
                        height = content_.height(with: UIFont.systemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    }
                }

                return height + 57
            }
        }

        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        reachEnd = false

        guard let models = models else { return }

        let vc: NetworkDetailViewController = NetworkDetailViewController.instanceFromStoryBoard()
        vc.httpModels = models
        vc.httpModel = models[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)

        vc.justCancelCallback = { [weak self] in
            self?.tableView.reloadData()
        }

        CocoaDebugSettings.shared.networkLastIndex = indexPath.row
    }
}

//MARK: - UIScrollViewDelegate
extension NetworkViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        reachEnd = false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            reachEnd = true
        }
    }
}
