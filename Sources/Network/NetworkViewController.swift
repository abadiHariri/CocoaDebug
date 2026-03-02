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
    var selectedEndpoints = Set<String>()     // full normalized path patterns used as filter keys
}

/// One row in the endpoint sub-filter list.
private struct FilterEndpointEntry {
    /// Relative sub-path shown in the UI (e.g. "/stores/{id}")
    let displayPath: String
    /// Full normalized path used as the filter key in applyFilter() (e.g. "/mahally/v2/stores/{id}")
    let filterPath: String
    /// Parent group label — the tag name or host (e.g. "mahally")
    let tag: String
}

/// UITableViewCell subclass that uses the .subtitle style for 2-line display.
private final class FilterSubtitleCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError() }
}

//MARK: - Filter Sheet Controller

private class NetworkFilterSheetController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    enum Page { case hosts, endpoints }

    // Data
    var page: Page = .hosts
    var entries: [(display: String, filterKeys: [(key: String, isPathFilter: Bool)], isWeb: Bool)] = []
    var tempPathFilters = Set<String>()
    var tempHostFilters = Set<String>()
    var tempEndpoints = Set<String>()
    var endpointProvider: (() -> [FilterEndpointEntry])?

    // Callbacks
    var onApply: ((Set<String>, Set<String>, Set<String>) -> Void)?

    // UI
    private let topBar = UIView()
    private let titleLabel = UILabel()
    private let applyButton = UIButton(type: .system)
    private let leftButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var endpoints: [FilterEndpointEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.12, alpha: 1)

        setupTopBar()
        setupTableView()
        refreshEndpoints()
    }

    private func setupTopBar() {
        topBar.backgroundColor = UIColor(white: 0.15, alpha: 1)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)

        // Left button (Clear on hosts page, Back on endpoints page)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        leftButton.addTarget(self, action: #selector(didTapLeft), for: .touchUpInside)
        topBar.addSubview(leftButton)

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        topBar.addSubview(titleLabel)

        // Apply button
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.setTitle("Apply", for: .normal)
        applyButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        applyButton.setTitleColor(.black, for: .normal)
        applyButton.backgroundColor = Color.mainGreen
        applyButton.layer.cornerRadius = 14
        applyButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        applyButton.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)
        topBar.addSubview(applyButton)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 52),

            leftButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 12),
            leftButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            applyButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -12),
            applyButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
        ])

        updateTopBar()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(white: 0.12, alpha: 1)
        tableView.separatorColor = UIColor(white: 0.25, alpha: 1)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FilterSubtitleCell.self, forCellReuseIdentifier: "FilterCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func updateTopBar() {
        switch page {
        case .hosts:
            titleLabel.text = "Filter by Host"
            leftButton.setTitle("Clear", for: .normal)
            leftButton.setTitleColor(.systemRed, for: .normal)
        case .endpoints:
            titleLabel.text = "Filter by Endpoint"
            leftButton.setTitle("\u{25C0} Back", for: .normal)
            leftButton.setTitleColor(Color.mainGreen, for: .normal)
        }
    }

    private func refreshEndpoints() {
        endpoints = endpointProvider?() ?? []
    }

    // MARK: Actions

    @objc private func didTapLeft() {
        switch page {
        case .hosts:
            // Clear all
            tempPathFilters.removeAll()
            tempHostFilters.removeAll()
            tempEndpoints.removeAll()
            onApply?(tempPathFilters, tempHostFilters, tempEndpoints)
            dismiss(animated: true)
        case .endpoints:
            // Back to hosts
            page = .hosts
            updateTopBar()
            tableView.reloadData()
        }
    }

    @objc private func didTapApply() {
        onApply?(tempPathFilters, tempHostFilters, tempEndpoints)
        dismiss(animated: true)
    }

    // MARK: Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch page {
        case .hosts:
            let hasSelectedHosts = !tempPathFilters.isEmpty || !tempHostFilters.isEmpty
            return entries.count + (hasSelectedHosts ? 1 : 0) // +1 for "Filter Endpoints..."
        case .endpoints:
            return endpoints.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        cell.backgroundColor = UIColor(white: 0.12, alpha: 1)
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 15)
        cell.selectionStyle = .none
        cell.tintColor = Color.mainGreen

        switch page {
        case .hosts:
            cell.detailTextLabel?.text = nil   // clear any tag left from an endpoint cell reuse
            if indexPath.row < entries.count {
                let entry = entries[indexPath.row]
                let isSelected = entry.filterKeys.contains { pair in
                    pair.isPathFilter ? tempPathFilters.contains(pair.key) : tempHostFilters.contains(pair.key)
                }
                cell.textLabel?.text = entry.display
                if entry.isWeb {
                    cell.detailTextLabel?.text = "web"
                    cell.detailTextLabel?.textColor = UIColor(white: 0.55, alpha: 1)
                    cell.detailTextLabel?.font = .systemFont(ofSize: 12)
                }
                cell.accessoryType = isSelected ? .checkmark : .none
            } else {
                // "Filter Endpoints..." row
                cell.textLabel?.text = "Filter Endpoints..."
                cell.textLabel?.textColor = Color.mainGreen
                cell.accessoryType = .disclosureIndicator
            }

        case .endpoints:
            let entry = endpoints[indexPath.row]
            let isSelected = tempEndpoints.contains(entry.filterPath)
            cell.textLabel?.text = entry.displayPath
            if !entry.tag.isEmpty {
                cell.detailTextLabel?.text = entry.tag
                cell.detailTextLabel?.textColor = UIColor(white: 0.55, alpha: 1)
                cell.detailTextLabel?.font = .systemFont(ofSize: 12)
            }
            cell.accessoryType = isSelected ? .checkmark : .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch page {
        case .hosts:
            if indexPath.row < entries.count {
                let entry = entries[indexPath.row]
                let isSelected = entry.filterKeys.contains { pair in
                    pair.isPathFilter ? tempPathFilters.contains(pair.key) : tempHostFilters.contains(pair.key)
                }
                for pair in entry.filterKeys {
                    if pair.isPathFilter {
                        if isSelected { tempPathFilters.remove(pair.key) } else { tempPathFilters.insert(pair.key) }
                    } else {
                        if isSelected { tempHostFilters.remove(pair.key) } else { tempHostFilters.insert(pair.key) }
                    }
                }
                tempEndpoints.removeAll()
                refreshEndpoints()
                tableView.reloadData()
            } else {
                // Switch to endpoints page
                refreshEndpoints()
                if endpoints.isEmpty { return }
                page = .endpoints
                updateTopBar()
                tableView.reloadData()
            }

        case .endpoints:
            let entry = endpoints[indexPath.row]
            if tempEndpoints.contains(entry.filterPath) {
                tempEndpoints.remove(entry.filterPath)
            } else {
                tempEndpoints.insert(entry.filterPath)
            }
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}

//MARK: - NetworkViewController

class NetworkViewController: UIViewController {

    var reachEnd: Bool = true
    var firstIn: Bool = true
    var reloadDataFinish: Bool = true

    var models: Array<_HttpModel>?
    var cacheModels: Array<_HttpModel>?

    var naviItemTitleLabel: UILabel?

    var filterButton: UIBarButtonItem!

    private var searchText: String = ""

    private var tableView: UITableView!
    private var searchBar: UISearchBar!
    private var deleteItem: UIBarButtonItem!

    // Convenience accessors
    private var filterState: NetworkFilterState { NetworkFilterState.shared }

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

    private func buildFilterEntries() -> [(display: String, filterKeys: [(key: String, isPathFilter: Bool)], isWeb: Bool)] {
        guard let allModels = cacheModels, !allModels.isEmpty else { return [] }

        let onlyURLs = (_NetworkHelper.shared.onlyURLs as? [String]) ?? []
        var rawEntries: [(display: String, filterKey: String, isPathFilter: Bool, isWeb: Bool)] = []
        var coveredHosts = Set<String>()

        for urlString in onlyURLs {
            var stripped = stripScheme(urlString)
            if stripped.hasSuffix("/") { stripped = String(stripped.dropLast()) }

            let host = stripped.components(separatedBy: "/").first ?? stripped

            var hasMatch = false
            var pathIsWeb = false
            for model in allModels {
                let modelURL = stripScheme(model.url?.absoluteString ?? "").lowercased()
                let key = stripped.lowercased()
                if modelURL.hasPrefix(key + "/") || modelURL == key {
                    hasMatch = true
                    if model.isWebViewRequest { pathIsWeb = true }
                }
            }

            if hasMatch {
                let display = tagLabel(forURLString: urlString) ?? stripped
                rawEntries.append((display: display, filterKey: stripped, isPathFilter: true, isWeb: pathIsWeb))
                coveredHosts.insert(host.lowercased())
            }
        }

        var seenHosts = Set<String>()
        for model in allModels {
            guard let host = model.url?.host, !host.isEmpty else { continue }
            let lowerHost = host.lowercased()
            if seenHosts.contains(lowerHost) { continue }
            seenHosts.insert(lowerHost)

            if !coveredHosts.contains(lowerHost) {
                let display = tagLabel(forHost: lowerHost) ?? host
                let isWeb = allModels.contains { m in
                    m.isWebViewRequest && m.url?.host?.lowercased() == lowerHost
                }
                rawEntries.append((display: display, filterKey: host, isPathFilter: false, isWeb: isWeb))
            }
        }

        // Sort by priority then alphabetically
        let sorted = rawEntries.sorted {
            let priorityA = $0.isPathFilter ? 0 : ($0.isWeb ? 1 : 2)
            let priorityB = $1.isPathFilter ? 0 : ($1.isWeb ? 1 : 2)
            if priorityA != priorityB { return priorityA < priorityB }
            return $0.display.lowercased() < $1.display.lowercased()
        }

        // Deduplicate by display label — merge all filterKeys under the same tag into one row
        var displayOrder: [String] = []
        var mergedMap: [String: (filterKeys: [(key: String, isPathFilter: Bool)], isWeb: Bool)] = [:]
        for entry in sorted {
            let key = entry.display.lowercased()
            if mergedMap[key] == nil {
                displayOrder.append(entry.display)
                mergedMap[key] = (filterKeys: [], isWeb: false)
            }
            mergedMap[key]!.filterKeys.append((key: entry.filterKey, isPathFilter: entry.isPathFilter))
            if entry.isWeb { mergedMap[key]!.isWeb = true }
        }
        return displayOrder.map { display in
            let info = mergedMap[display.lowercased()]!
            return (display: display, filterKeys: info.filterKeys, isWeb: info.isWeb)
        }
    }

    /// Returns the tag label from networkTagMap whose key is a substring of the full URL,
    /// or nil if no custom tag matches.
    private func tagLabel(forURLString urlString: String) -> String? {
        guard let map = CocoaDebug.networkTagMap else { return nil }
        let lower = urlString.lowercased()
        // Direct key lookup first (most common case: onlyURLs key == networkTagMap key)
        if let label = map[urlString] { return label }
        // Substring match fallback
        for (keyword, label) in map where lower.contains(keyword.lowercased()) {
            return label
        }
        return nil
    }

    /// Returns the tag label from networkTagMap whose key matches the given host, or nil.
    private func tagLabel(forHost host: String) -> String? {
        guard let map = CocoaDebug.networkTagMap else { return nil }
        for (keyword, label) in map where host.contains(keyword.lowercased()) {
            return label
        }
        return nil
    }

    private func uniqueEndpointsForFilters(pathFilters: Set<String>, hostFilters: Set<String>) -> [FilterEndpointEntry] {
        guard let models = cacheModels else { return [] }
        if pathFilters.isEmpty && hostFilters.isEmpty { return [] }

        let onlyURLs = (_NetworkHelper.shared.onlyURLs as? [String]) ?? []

        // Build set of onlyURLs paths (for exclusion — already top-level filter entries).
        // Also map: lowercased stripped key → original full URL (for tag lookup).
        var onlyURLPaths = Set<String>()
        var strippedToOriginalURL: [String: String] = [:]
        for urlString in onlyURLs {
            var stripped = stripScheme(urlString)
            if stripped.hasSuffix("/") { stripped = String(stripped.dropLast()) }
            strippedToOriginalURL[stripped.lowercased()] = urlString
            if let url = URL(string: urlString) {
                var path = url.path
                if path.hasSuffix("/") && path.count > 1 { path = String(path.dropLast()) }
                if !path.isEmpty && path != "/" {
                    onlyURLPaths.insert(normalizeEndpoint(path).lowercased())
                }
            }
        }

        // Tag label for each selected path filter.
        var pathFilterTagMap: [String: String] = [:]
        for pf in pathFilters {
            let key = pf.lowercased()
            if let original = strippedToOriginalURL[key] {
                pathFilterTagMap[key] = tagLabel(forURLString: original) ?? pf
            } else {
                pathFilterTagMap[key] = tagLabel(forURLString: pf) ?? pf
            }
        }

        // Tag label for each selected host filter.
        var hostFilterTagMap: [String: String] = [:]
        for hf in hostFilters {
            hostFilterTagMap[hf.lowercased()] = tagLabel(forHost: hf.lowercased()) ?? hf
        }

        // Path prefix to strip per path filter so we show relative sub-paths.
        // e.g. "api.salla.dev/mahally/v2" → "/mahally/v2"
        var pathPrefixMap: [String: String] = [:]
        for pf in pathFilters {
            let subParts = Array(pf.components(separatedBy: "/").dropFirst())
            if !subParts.isEmpty {
                pathPrefixMap[pf.lowercased()] = "/" + subParts.joined(separator: "/")
            }
        }

        // Pre-build set of filterPaths that have at least one web request, so
        // we can show "· web" in the tag regardless of which model is processed first.
        var webFilterPaths = Set<String>()
        for model in models where model.isWebViewRequest {
            let fp = normalizeEndpoint(model.url?.path ?? "")
            if !fp.isEmpty { webFilterPaths.insert(fp) }
        }

        var seen = Set<String>()   // dedup by filterPath (full normalized path)
        var result = [FilterEndpointEntry]()
        for model in models {
            let modelURL = stripScheme(model.url?.absoluteString ?? "").lowercased()
            let host = (model.url?.host ?? "").lowercased()
            let fullPath = model.url?.path ?? ""

            var matchedPrefix: String? = nil
            var matchedTag = ""
            var matches = false
            for pf in pathFilters {
                let key = pf.lowercased()
                if modelURL.hasPrefix(key + "/") || modelURL == key {
                    matches = true
                    matchedPrefix = pathPrefixMap[key]
                    matchedTag = pathFilterTagMap[key] ?? pf
                    break
                }
            }
            if !matches {
                for hf in hostFilters {
                    if host == hf.lowercased() {
                        matches = true
                        matchedTag = hostFilterTagMap[hf.lowercased()] ?? hf
                        break
                    }
                }
            }
            if !matches { continue }

            // Skip models whose full path is itself an onlyURLs entry (already a top-level filter)
            let fullNormalized = normalizeEndpoint(fullPath).lowercased()
            if fullNormalized.isEmpty || onlyURLPaths.contains(fullNormalized) { continue }

            // filterPath = full normalized path (used as key in applyFilter)
            let filterPath = normalizeEndpoint(fullPath)
            if filterPath.isEmpty { continue }
            guard seen.insert(filterPath).inserted else { continue }

            // displayPath = relative sub-path (strip the onlyURLs base prefix for readability)
            var displayPath = fullPath
            if let prefix = matchedPrefix, fullPath.lowercased().hasPrefix(prefix.lowercased()) {
                let relative = String(fullPath.dropFirst(prefix.count))
                displayPath = relative.isEmpty ? "/" : relative
            }
            let normalizedDisplay = normalizeEndpoint(displayPath)
            if normalizedDisplay.isEmpty || normalizedDisplay == "/" { continue }

            let isWebEndpoint = webFilterPaths.contains(filterPath)
            let endpointTag: String
            if isWebEndpoint {
                endpointTag = matchedTag.isEmpty ? "web" : "\(matchedTag) · web"
            } else {
                endpointTag = matchedTag
            }
            result.append(FilterEndpointEntry(
                displayPath: normalizedDisplay,
                filterPath: filterPath,
                tag: endpointTag
            ))
        }
        return result.sorted { $0.displayPath < $1.displayPath }
    }

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

    private func applyFilter() {
        guard let cacheModels = cacheModels else {
            models = nil
            return
        }

        let pathFilters = filterState.selectedPathFilters
        let hostFilters = filterState.selectedHostFilters
        let endpoints = filterState.selectedEndpoints

        var filtered = cacheModels

        // Host / path filters
        let hasFilterSelection = !pathFilters.isEmpty || !hostFilters.isEmpty
        if hasFilterSelection {
            filtered = filtered.filter { model in
                let modelURL = stripScheme(model.url?.absoluteString ?? "").lowercased()
                let host = (model.url?.host ?? "").lowercased()

                for pf in pathFilters {
                    let key = pf.lowercased()
                    if modelURL.hasPrefix(key + "/") || modelURL == key { return true }
                }
                for hf in hostFilters {
                    if host == hf.lowercased() { return true }
                }
                return false
            }
        }

        // Endpoint filter
        if !endpoints.isEmpty {
            filtered = filtered.filter { model in
                let normalized = normalizeEndpoint(model.url?.path ?? "")
                return endpoints.contains(normalized)
            }
        }

        // Search text filter
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            filtered = filtered.filter { model in
                (model.url?.absoluteString ?? "").lowercased().contains(query)
            }
        }

        models = filtered
    }

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

        let sheet = NetworkFilterSheetController()
        sheet.entries = entries
        sheet.tempPathFilters = filterState.selectedPathFilters
        sheet.tempHostFilters = filterState.selectedHostFilters
        sheet.tempEndpoints = filterState.selectedEndpoints

        sheet.endpointProvider = { [weak self, weak sheet] in
            guard let self = self, let sheet = sheet else { return [] }
            return self.uniqueEndpointsForFilters(
                pathFilters: sheet.tempPathFilters,
                hostFilters: sheet.tempHostFilters
            )
        }

        sheet.onApply = { [weak self] pathFilters, hostFilters, endpoints in
            guard let self = self else { return }
            self.filterState.selectedPathFilters = pathFilters
            self.filterState.selectedHostFilters = hostFilters
            self.filterState.selectedEndpoints = endpoints
            self.applyFilter()
            self.updateFilterButtonTitle()
            self.tableView.reloadData()
        }

        sheet.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheetPC = sheet.sheetPresentationController {
                sheetPC.detents = [.medium(), .large()]
                // sheetPC.prefersGrabberHandle = true
            }
        }
        present(sheet, animated: true)
    }

    //MARK: - private
    func reloadHttp(needScrollToEnd: Bool = false) {

        if reloadDataFinish == false { return }

        self.models = (_HttpDatasource.shared.httpModels as NSArray as? [_HttpModel])
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

        setupUI()

        let tap = UITapGestureRecognizer.init(target: self, action: #selector(didTapView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.textColor = Color.mainGreen
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 20)
        navigationItem.titleView = naviItemTitleLabel
        naviItemTitleLabel?.text = "\u{1f680}[0]"

        // Nav bar buttons: trash, up, down
        let bundle = Bundle(for: NetworkViewController.self)
        let upImage   = UIImage(named: "_icon_file_type_up.png",   in: bundle, compatibleWith: nil)
        let downImage = UIImage(named: "_icon_file_type_down.png", in: bundle, compatibleWith: nil)
        let upButton   = UIBarButtonItem(image: upImage,   style: .plain, target: self, action: #selector(didTapUp(_:)))
        let downButton = UIBarButtonItem(image: downImage, style: .plain, target: self, action: #selector(didTapDown(_:)))
        upButton.tintColor   = Color.mainGreen
        downButton.tintColor = Color.mainGreen
        deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(tapTrashButton(_:)))
        deleteItem.tintColor = Color.mainGreen
        navigationItem.rightBarButtonItems = [deleteItem, downButton, upButton]

        // Search bar styling
        searchBar.barTintColor = .black
        searchBar.isTranslucent = false
        searchBar.tintColor = Color.mainGreen
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.backgroundColor = UIColor(white: 0.15, alpha: 1)
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search URL...",
            attributes: [.foregroundColor: UIColor.lightGray]
        )
        searchBar.searchTextField.leftView?.tintColor = .lightGray
        searchBar.delegate = self

        // Filter button — appended to existing right items
        filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(didTapFilter)
        )
        filterButton.tintColor = Color.mainGreen
        var rightItems = navigationItem.rightBarButtonItems ?? []
        rightItems.append(filterButton)
        navigationItem.rightBarButtonItems = rightItems

        updateFilterButtonTitle()

        //notification
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "reloadHttp_CocoaDebug"), object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.reloadHttp(needScrollToEnd: self?.reachEnd ?? true)
        }

        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.register(NetworkCell.self, forCellReuseIdentifier: "NetworkCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 80, right: 0)
        tableView.showsVerticalScrollIndicator = false

        reloadHttp(needScrollToEnd: true)

        if models?.count ?? 0 > CocoaDebugSettings.shared.networkLastIndex && CocoaDebugSettings.shared.networkLastIndex > 0 {
            tableView.tableViewScrollToIndex(index: CocoaDebugSettings.shared.networkLastIndex, animated: false)
        }
    }

    private func setupUI() {
        view.backgroundColor = .black

        searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: - target action
    @objc func didTapDown(_ sender: Any) {
        tableView.tableViewScrollToBottom(animated: true)
        reachEnd = true
        CocoaDebugSettings.shared.networkLastIndex = 0
    }

    @objc func didTapUp(_ sender: Any) {
        tableView.tableViewScrollToHeader(animated: true)
        reachEnd = false
        CocoaDebugSettings.shared.networkLastIndex = 0
    }

    @objc func tapTrashButton(_ sender: UIBarButtonItem) {
        _HttpDatasource.shared.reset()
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

//MARK: - UISearchBarDelegate
extension NetworkViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        applyFilter()
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchText = ""
        searchBar.resignFirstResponder()
        applyFilter()
        tableView.reloadData()
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

        guard let models = models, indexPath.row < models.count else { return cell }
        cell.index = indexPath.row
        cell.httpModel = models[indexPath.row]
        return cell
    }
}

//MARK: - UITableViewDelegate
extension NetworkViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        reachEnd = false

        guard let models = models, indexPath.row < models.count else { return }

        // Mark as viewed so the list cell shows a "viewed" indicator
        models[indexPath.row].isViewed = true
        tableView.reloadRows(at: [indexPath], with: .none)

        let vc = NetworkDetailViewController()
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
