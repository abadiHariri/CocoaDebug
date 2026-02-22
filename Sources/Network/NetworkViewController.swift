//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
//

import UIKit

/// Persists filter state in memory across view reloads (lives as long as the app).
private final class NetworkFilterState {
    static let shared = NetworkFilterState()
    var selectedHosts = Set<String>()       // raw host strings (from url.host)
    var selectedEndpoints = Set<String>()   // normalized endpoint patterns
}

class NetworkViewController: UIViewController {

    var reachEnd: Bool = true
    var firstIn: Bool = true
    var reloadDataFinish: Bool = true

    var models: Array<_HttpModel>?
    var cacheModels: Array<_HttpModel>?

    var naviItemTitleLabel: UILabel?

    var filterButton: UIBarButtonItem!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var deleteItem: UIBarButtonItem!
    @IBOutlet weak var naviItem: UINavigationItem!

    // Convenience accessors
    private var filterState: NetworkFilterState { NetworkFilterState.shared }

    //MARK: - Host resolution

    /// Build the list of display hosts.
    /// - For each entry in `onlyURLs`, extract the host portion (strip scheme) and show as-is.
    /// - Any captured host NOT covered by `onlyURLs` is shown raw from the URL.
    private func buildHostList() -> [(display: String, rawHost: String)] {
        guard let allModels = cacheModels else { return [] }

        // Collect all unique raw hosts from captured models
        var capturedHosts = [String]()
        var capturedSet = Set<String>()
        for model in allModels {
            if let host = model.url?.host, !host.isEmpty, capturedSet.insert(host).inserted {
                capturedHosts.append(host)
            }
        }

        // Build onlyURLs host mapping: display string -> set of raw hosts it matches
        let onlyURLs = (_NetworkHelper.shared().onlyURLs as? [String]) ?? []
        var result = [(display: String, rawHost: String)]()
        var coveredHosts = Set<String>()

        for urlString in onlyURLs {
            // Strip scheme if present
            var display = urlString
            for prefix in ["https://", "http://", "HTTPS://", "HTTP://"] {
                if display.hasPrefix(prefix) {
                    display = String(display.dropFirst(prefix.count))
                    break
                }
            }
            // Remove trailing slash
            if display.hasSuffix("/") { display = String(display.dropLast()) }

            // Match against captured hosts: a captured host matches if the onlyURL
            // display string starts with that host or contains it
            for rawHost in capturedHosts {
                if display.lowercased().hasPrefix(rawHost.lowercased()) ||
                   rawHost.lowercased().hasPrefix(display.lowercased()) {
                    if !coveredHosts.contains(rawHost) {
                        result.append((display: display, rawHost: rawHost))
                        coveredHosts.insert(rawHost)
                    }
                }
            }
        }

        // Add any captured hosts not covered by onlyURLs
        for rawHost in capturedHosts where !coveredHosts.contains(rawHost) {
            result.append((display: rawHost, rawHost: rawHost))
        }

        return result.sorted { $0.display.lowercased() < $1.display.lowercased() }
    }

    /// Extract unique normalized endpoints for the given raw hosts
    private func uniqueEndpoints(forRawHosts rawHosts: Set<String>) -> [String] {
        guard let models = cacheModels else { return [] }
        var seen = Set<String>()
        var result = [String]()
        for model in models {
            guard let host = model.url?.host, rawHosts.contains(host) else { continue }
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

    //MARK: - Filter logic

    /// Apply current filter state to cacheModels and update models
    private func applyFilter() {
        guard let cacheModels = cacheModels else {
            models = nil
            return
        }

        let hosts = filterState.selectedHosts
        let endpoints = filterState.selectedEndpoints

        if hosts.isEmpty && endpoints.isEmpty {
            models = cacheModels
            return
        }

        models = cacheModels.filter { model in
            guard let host = model.url?.host else { return false }

            // Host filter
            if !hosts.isEmpty && !hosts.contains(host) {
                return false
            }

            // Endpoint filter
            if !endpoints.isEmpty {
                let normalized = normalizeEndpoint(model.url?.path ?? "")
                if !endpoints.contains(normalized) {
                    return false
                }
            }

            return true
        }
    }

    /// Update the filter button appearance
    private func updateFilterButtonTitle() {
        let hasFilter = !filterState.selectedHosts.isEmpty || !filterState.selectedEndpoints.isEmpty
        if hasFilter {
            filterButton.image = UIImage(systemName: "line.3.horizontal.decrease.circle.fill")
        } else {
            filterButton.image = UIImage(systemName: "line.3.horizontal.decrease.circle")
        }
    }

    //MARK: - Filter actions

    @objc func didTapFilter() {
        let hostList = buildHostList()
        if hostList.isEmpty { return }

        let alert = UIAlertController(title: "Filter by Host", message: "Select hosts to show (multi-select)", preferredStyle: .actionSheet)

        // Clear all filters
        let clearAction = UIAlertAction(title: "Clear All Filters", style: .destructive) { [weak self] _ in
            self?.filterState.selectedHosts.removeAll()
            self?.filterState.selectedEndpoints.removeAll()
            self?.applyFilter()
            self?.updateFilterButtonTitle()
            self?.tableView.reloadData()
        }
        alert.addAction(clearAction)

        // One toggle per host
        for entry in hostList {
            let isSelected = filterState.selectedHosts.contains(entry.rawHost)
            let title = isSelected ? "\u{2713}  \(entry.display)" : "     \(entry.display)"
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self = self else { return }
                // Toggle this host
                if self.filterState.selectedHosts.contains(entry.rawHost) {
                    self.filterState.selectedHosts.remove(entry.rawHost)
                } else {
                    self.filterState.selectedHosts.insert(entry.rawHost)
                }
                // Clear endpoint filter when host selection changes
                self.filterState.selectedEndpoints.removeAll()
                self.applyFilter()
                self.updateFilterButtonTitle()
                self.tableView.reloadData()
                // Re-show the host picker so user can select more
                self.didTapFilter()
            }
            alert.addAction(action)
        }

        // Endpoint filter option (only if hosts are selected)
        if !filterState.selectedHosts.isEmpty {
            let endpointAction = UIAlertAction(title: "Filter Endpoints...", style: .default) { [weak self] _ in
                self?.showEndpointFilter()
            }
            alert.addAction(endpointAction)
        }

        alert.addAction(UIAlertAction(title: "Done", style: .cancel))

        alert.popoverPresentationController?.barButtonItem = filterButton
        present(alert, animated: true)
    }

    private func showEndpointFilter() {
        let endpoints = uniqueEndpoints(forRawHosts: filterState.selectedHosts)
        if endpoints.isEmpty { return }

        let hostNames = filterState.selectedHosts.sorted().joined(separator: ", ")
        let alert = UIAlertController(title: "Filter by Endpoint", message: hostNames, preferredStyle: .actionSheet)

        // Clear endpoint filter
        let clearAction = UIAlertAction(title: "Clear Endpoint Filter", style: .destructive) { [weak self] _ in
            self?.filterState.selectedEndpoints.removeAll()
            self?.applyFilter()
            self?.tableView.reloadData()
        }
        alert.addAction(clearAction)

        for endpoint in endpoints {
            let isSelected = filterState.selectedEndpoints.contains(endpoint)
            let title = isSelected ? "\u{2713}  \(endpoint)" : "     \(endpoint)"
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self = self else { return }
                // Toggle this endpoint
                if self.filterState.selectedEndpoints.contains(endpoint) {
                    self.filterState.selectedEndpoints.remove(endpoint)
                } else {
                    self.filterState.selectedEndpoints.insert(endpoint)
                }
                self.applyFilter()
                self.tableView.reloadData()
                // Re-show the endpoint picker so user can select more
                self.showEndpointFilter()
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Done", style: .cancel))

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

        // Restore filter button state from persisted selection
        updateFilterButtonTitle()

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
        filterState.selectedHosts.removeAll()
        filterState.selectedEndpoints.removeAll()
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
