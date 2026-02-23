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
    var selectedPathFilters = Set<String>()   // onlyURL-based filters (match by URL prefix)
    var selectedHostFilters = Set<String>()   // plain host filters (match by host)
    var selectedEndpoints = Set<String>()     // normalized endpoint patterns
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

    // Temporary selection state used during filter picker interaction
    private var tempPathFilters = Set<String>()
    private var tempHostFilters = Set<String>()
    private var tempEndpoints = Set<String>()

    //MARK: - Helpers

    private func stripScheme(_ url: String) -> String {
        var result = url
        for prefix in ["https://", "http://", "HTTPS://", "HTTP://"] {
            if result.hasPrefix(prefix) {
                result = String(result.dropFirst(prefix.count))
                break
            }
        }
        return result
    }

    //MARK: - Filter entry building

    /// Build the list of filter entries.
    /// - Each `onlyURLs` entry becomes a path-based filter (e.g. "salla.sa/mahally/v1").
    /// - Captured hosts NOT covered by any `onlyURLs` entry become host-based filters.
    private func buildFilterEntries() -> [(display: String, filterKey: String, isPathFilter: Bool)] {
        guard let allModels = cacheModels, !allModels.isEmpty else { return [] }

        let onlyURLs = (_NetworkHelper.shared().onlyURLs as? [String]) ?? []
        var entries: [(display: String, filterKey: String, isPathFilter: Bool)] = []
        var coveredHosts = Set<String>() // hosts that belong to an onlyURL entry

        // 1. Build entries from onlyURLs
        for urlString in onlyURLs {
            var stripped = stripScheme(urlString)
            // Remove trailing slash for display
            if stripped.hasSuffix("/") { stripped = String(stripped.dropLast()) }

            let host = stripped.components(separatedBy: "/").first ?? stripped

            // Only include if at least one captured model matches this prefix
            let hasMatch = allModels.contains { model in
                let modelURL = stripScheme(model.url?.absoluteString ?? "").lowercased()
                let key = stripped.lowercased()
                return modelURL.hasPrefix(key + "/") || modelURL == key
            }

            if hasMatch {
                entries.append((display: stripped, filterKey: stripped, isPathFilter: true))
                coveredHosts.insert(host.lowercased())
            }
        }

        // 2. Find hosts NOT covered by any onlyURL
        var seenHosts = Set<String>()
        for model in allModels {
            guard let host = model.url?.host, !host.isEmpty else { continue }
            let lowerHost = host.lowercased()
            if seenHosts.contains(lowerHost) { continue }
            seenHosts.insert(lowerHost)

            if !coveredHosts.contains(lowerHost) {
                entries.append((display: host, filterKey: host, isPathFilter: false))
            }
        }

        return entries.sorted { $0.display.lowercased() < $1.display.lowercased() }
    }

    /// Extract unique normalized endpoints for models matching the current temp filters
    private func uniqueEndpointsForTempFilters() -> [String] {
        guard let models = cacheModels else { return [] }
        var seen = Set<String>()
        var result = [String]()
        for model in models {
            if !modelMatchesTempFilters(model) { continue }
            let normalized = normalizeEndpoint(model.url?.path ?? "")
            if !normalized.isEmpty, seen.insert(normalized).inserted {
                result.append(normalized)
            }
        }
        return result.sorted()
    }

    /// Check if a model matches the current temp path/host filters
    private func modelMatchesTempFilters(_ model: _HttpModel) -> Bool {
        if tempPathFilters.isEmpty && tempHostFilters.isEmpty { return true }

        let modelURL = stripScheme(model.url?.absoluteString ?? "").lowercased()
        let host = (model.url?.host ?? "").lowercased()

        for pf in tempPathFilters {
            let key = pf.lowercased()
            if modelURL.hasPrefix(key + "/") || modelURL == key {
                return true
            }
        }
        for hf in tempHostFilters {
            if host == hf.lowercased() {
                return true
            }
        }
        return false
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

    /// Apply persisted filter state to cacheModels and update models
    private func applyFilter() {
        guard let cacheModels = cacheModels else {
            models = nil
            return
        }

        let pathFilters = filterState.selectedPathFilters
        let hostFilters = filterState.selectedHostFilters
        let endpoints = filterState.selectedEndpoints

        if pathFilters.isEmpty && hostFilters.isEmpty && endpoints.isEmpty {
            models = cacheModels
            return
        }

        models = cacheModels.filter { model in
            let hasFilterSelection = !pathFilters.isEmpty || !hostFilters.isEmpty
            if hasFilterSelection {
                let modelURL = stripScheme(model.url?.absoluteString ?? "").lowercased()
                let host = (model.url?.host ?? "").lowercased()

                var matchesFilter = false
                for pf in pathFilters {
                    let key = pf.lowercased()
                    if modelURL.hasPrefix(key + "/") || modelURL == key {
                        matchesFilter = true
                        break
                    }
                }
                if !matchesFilter {
                    for hf in hostFilters {
                        if host == hf.lowercased() {
                            matchesFilter = true
                            break
                        }
                    }
                }
                if !matchesFilter { return false }
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
        let hasFilter = !filterState.selectedPathFilters.isEmpty ||
                        !filterState.selectedHostFilters.isEmpty ||
                        !filterState.selectedEndpoints.isEmpty
        if hasFilter {
            filterButton.image = UIImage(systemName: "line.3.horizontal.decrease.circle.fill")
        } else {
            filterButton.image = UIImage(systemName: "line.3.horizontal.decrease.circle")
        }
    }

    //MARK: - Filter UI

    @objc func didTapFilter() {
        let entries = buildFilterEntries()
        if entries.isEmpty { return }

        // Initialize temp state from persisted state
        tempPathFilters = filterState.selectedPathFilters
        tempHostFilters = filterState.selectedHostFilters
        tempEndpoints = filterState.selectedEndpoints

        showHostFilterAlert(entries: entries)
    }

    private func showHostFilterAlert(entries: [(display: String, filterKey: String, isPathFilter: Bool)]) {
        let alert = UIAlertController(title: "Filter by Host", message: nil, preferredStyle: .actionSheet)

        // Clear all filters
        let hasAnyTemp = !tempPathFilters.isEmpty || !tempHostFilters.isEmpty || !tempEndpoints.isEmpty
        if hasAnyTemp {
            alert.addAction(UIAlertAction(title: "Clear All Filters", style: .destructive) { [weak self] _ in
                self?.tempPathFilters.removeAll()
                self?.tempHostFilters.removeAll()
                self?.tempEndpoints.removeAll()
                self?.showHostFilterAlert(entries: entries)
            })
        }

        // One toggle per entry
        for entry in entries {
            let isSelected = entry.isPathFilter
                ? tempPathFilters.contains(entry.filterKey)
                : tempHostFilters.contains(entry.filterKey)
            let title = isSelected ? "\u{2713}  \(entry.display)" : "     \(entry.display)"

            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self = self else { return }
                if entry.isPathFilter {
                    if self.tempPathFilters.contains(entry.filterKey) {
                        self.tempPathFilters.remove(entry.filterKey)
                    } else {
                        self.tempPathFilters.insert(entry.filterKey)
                    }
                } else {
                    if self.tempHostFilters.contains(entry.filterKey) {
                        self.tempHostFilters.remove(entry.filterKey)
                    } else {
                        self.tempHostFilters.insert(entry.filterKey)
                    }
                }
                // Clear endpoint selection when host changes
                self.tempEndpoints.removeAll()
                self.showHostFilterAlert(entries: entries)
            })
        }

        // Endpoint filter option (only if some hosts are selected)
        if !tempPathFilters.isEmpty || !tempHostFilters.isEmpty {
            alert.addAction(UIAlertAction(title: "Filter Endpoints...", style: .default) { [weak self] _ in
                self?.showEndpointFilterAlert(entries: entries)
            })
        }

        // Apply
        alert.addAction(UIAlertAction(title: "Apply", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.filterState.selectedPathFilters = self.tempPathFilters
            self.filterState.selectedHostFilters = self.tempHostFilters
            self.filterState.selectedEndpoints = self.tempEndpoints
            self.applyFilter()
            self.updateFilterButtonTitle()
            self.tableView.reloadData()
        })

        // Dismiss
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))

        alert.popoverPresentationController?.barButtonItem = filterButton
        present(alert, animated: true)
    }

    private func showEndpointFilterAlert(entries: [(display: String, filterKey: String, isPathFilter: Bool)]) {
        let endpoints = uniqueEndpointsForTempFilters()
        if endpoints.isEmpty {
            showHostFilterAlert(entries: entries)
            return
        }

        let alert = UIAlertController(title: "Filter by Endpoint", message: nil, preferredStyle: .actionSheet)

        // Clear endpoint filter
        if !tempEndpoints.isEmpty {
            alert.addAction(UIAlertAction(title: "Clear Endpoint Filter", style: .destructive) { [weak self] _ in
                self?.tempEndpoints.removeAll()
                self?.showEndpointFilterAlert(entries: entries)
            })
        }

        // Endpoint toggles
        for endpoint in endpoints {
            let isSelected = tempEndpoints.contains(endpoint)
            let title = isSelected ? "\u{2713}  \(endpoint)" : "     \(endpoint)"
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self = self else { return }
                if self.tempEndpoints.contains(endpoint) {
                    self.tempEndpoints.remove(endpoint)
                } else {
                    self.tempEndpoints.insert(endpoint)
                }
                self.showEndpointFilterAlert(entries: entries)
            })
        }

        // Back
        alert.addAction(UIAlertAction(title: "\u{25C0} Back", style: .default) { [weak self] _ in
            self?.showHostFilterAlert(entries: entries)
        })

        // Apply
        alert.addAction(UIAlertAction(title: "Apply", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.filterState.selectedPathFilters = self.tempPathFilters
            self.filterState.selectedHostFilters = self.tempHostFilters
            self.filterState.selectedEndpoints = self.tempEndpoints
            self.applyFilter()
            self.updateFilterButtonTitle()
            self.tableView.reloadData()
        })

        // Dismiss
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))

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
        filterState.selectedPathFilters.removeAll()
        filterState.selectedHostFilters.removeAll()
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
