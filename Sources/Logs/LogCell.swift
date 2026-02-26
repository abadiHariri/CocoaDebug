//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

// MARK: - LogPaddedLabel (pill-shaped tag)

private class LogPaddedLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
}

// MARK: - LogCell

class LogCell: UITableViewCell {

    // MARK: - Card

    private let cardView = UIView()

    // MARK: - Top row: tag pill + timestamp

    private let rowNumberLabel = UILabel()
    private let tagLabel = LogPaddedLabel()
    private let jsonTagLabel = LogPaddedLabel()
    private let timeLabel = UILabel()
    private let fileInfoLabel = UILabel()

    // MARK: - Content

    private let contentLabel = UILabel()

    // MARK: - Show Full button

    private let showFullButton = UIButton(type: .system)

    /// Callback when "Show Full" is tapped
    var onShowFull: (() -> Void)?

    // MARK: - Bottom constraints (switchable)

    private var contentBottomConstraint: NSLayoutConstraint!
    private var showFullBottomConstraint: NSLayoutConstraint!

    // MARK: - Colors

    private static let cardColor = UIColor(white: 0.11, alpha: 1)       // #1C1C1C
    private static let taggedCardColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 0.15)
    private static let tealColor = UIColor(red: 0.29, green: 0.76, blue: 0.76, alpha: 1)

    // Tag colors per log type
    private static let appTagColor = UIColor(red: 0.26, green: 0.83, blue: 0.35, alpha: 1)   // green
    private static let webTagColor = UIColor(red: 0.30, green: 0.54, blue: 0.97, alpha: 1)   // blue
    private static let rnTagColor  = UIColor(red: 0.38, green: 0.84, blue: 0.89, alpha: 1)   // cyan/react

    /// Max lines shown in the list cell for plain text
    static let maxLines = 4
    /// Max chars for JSON preview before showing "Show Full" button
    private static let jsonTruncateLength = 800

    // MARK: - Data

    var index: Int = 0

    var model: _OCLogModel? {
        didSet { configure() }
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card
        cardView.backgroundColor = Self.cardColor
        cardView.layer.cornerRadius = 10
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        // Row number
        rowNumberLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .bold)
        rowNumberLabel.textColor = UIColor(white: 0.50, alpha: 1)
        rowNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        rowNumberLabel.setContentHuggingPriority(.required, for: .horizontal)
        rowNumberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        cardView.addSubview(rowNumberLabel)

        // Tag pill
        tagLabel.font = .systemFont(ofSize: 9, weight: .bold)
        tagLabel.textColor = .white
        tagLabel.textAlignment = .center
        tagLabel.layer.cornerRadius = 4
        tagLabel.clipsToBounds = true
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.setContentHuggingPriority(.required, for: .horizontal)
        tagLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        cardView.addSubview(tagLabel)

        // JSON tag pill
        jsonTagLabel.font = .systemFont(ofSize: 9, weight: .bold)
        jsonTagLabel.textAlignment = .center
        jsonTagLabel.layer.cornerRadius = 4
        jsonTagLabel.clipsToBounds = true
        jsonTagLabel.translatesAutoresizingMaskIntoConstraints = false
        jsonTagLabel.setContentHuggingPriority(.required, for: .horizontal)
        jsonTagLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        jsonTagLabel.text = "JSON"
        jsonTagLabel.textColor = Self.tealColor
        jsonTagLabel.backgroundColor = Self.tealColor.withAlphaComponent(0.2)
        jsonTagLabel.isHidden = true
        cardView.addSubview(jsonTagLabel)

        // Timestamp
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 10, weight: .medium)
        timeLabel.textColor = Color.mainGreen
        timeLabel.textAlignment = .right
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        cardView.addSubview(timeLabel)

        // File info (source location)
        fileInfoLabel.font = .systemFont(ofSize: 10, weight: .medium)
        fileInfoLabel.textColor = UIColor(white: 0.45, alpha: 1)
        fileInfoLabel.numberOfLines = 1
        fileInfoLabel.lineBreakMode = .byTruncatingMiddle
        fileInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(fileInfoLabel)

        // Content (truncated)
        contentLabel.font = UIFont(name: "Menlo", size: 11) ?? .systemFont(ofSize: 11)
        contentLabel.textColor = UIColor(white: 0.82, alpha: 1)
        contentLabel.numberOfLines = Self.maxLines
        contentLabel.lineBreakMode = .byTruncatingTail
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(contentLabel)

        // Show Full button
        showFullButton.translatesAutoresizingMaskIntoConstraints = false
        showFullButton.backgroundColor = UIColor(white: 0.18, alpha: 1)
        showFullButton.layer.cornerRadius = 6
        showFullButton.clipsToBounds = true
        showFullButton.titleLabel?.font = .systemFont(ofSize: 11, weight: .semibold)
        showFullButton.setTitleColor(Self.tealColor, for: .normal)
        showFullButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        showFullButton.setTitle("Show Full JSON", for: .normal)
        showFullButton.addTarget(self, action: #selector(showFullTapped), for: .touchUpInside)
        showFullButton.isHidden = true
        cardView.addSubview(showFullButton)

        // Bottom constraints (switchable)
        contentBottomConstraint = contentLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8)
        showFullBottomConstraint = showFullButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10)

        // Constraints
        NSLayoutConstraint.activate([
            // Card
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),

            // Top row: row# + tag + json tag (left) ... timestamp (right)
            rowNumberLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            rowNumberLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),

            tagLabel.centerYAnchor.constraint(equalTo: rowNumberLabel.centerYAnchor),
            tagLabel.leadingAnchor.constraint(equalTo: rowNumberLabel.trailingAnchor, constant: 6),

            jsonTagLabel.centerYAnchor.constraint(equalTo: rowNumberLabel.centerYAnchor),
            jsonTagLabel.leadingAnchor.constraint(equalTo: tagLabel.trailingAnchor, constant: 4),

            timeLabel.centerYAnchor.constraint(equalTo: rowNumberLabel.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: jsonTagLabel.trailingAnchor, constant: 8),

            // File info row
            fileInfoLabel.topAnchor.constraint(equalTo: rowNumberLabel.bottomAnchor, constant: 4),
            fileInfoLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            fileInfoLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),

            // Content
            contentLabel.topAnchor.constraint(equalTo: fileInfoLabel.bottomAnchor, constant: 4),
            contentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            contentLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),

            // Show Full button
            showFullButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            showFullButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
        ])
    }

    // MARK: - Configure

    private func configure() {
        guard let model = model else { return }

        // Row number
        rowNumberLabel.text = String(index + 1)

        // Tag pill
        let tagInfo = Self.tagInfo(for: model.logType)
        tagLabel.text = tagInfo.label
        tagLabel.backgroundColor = tagInfo.color.withAlphaComponent(0.25)
        tagLabel.textColor = tagInfo.color

        // Timestamp
        if let date = model.date {
            timeLabel.text = Self.formatTime(date)
        } else {
            timeLabel.text = ""
        }

        // File info
        let rawFileInfo = (model.fileInfo ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if rawFileInfo.isEmpty || rawFileInfo == "\n" {
            fileInfoLabel.isHidden = true
        } else {
            fileInfoLabel.isHidden = false
            fileInfoLabel.text = rawFileInfo

            // Color errors red
            if rawFileInfo.lowercased().contains("error") {
                fileInfoLabel.textColor = .systemRed
            } else {
                fileInfoLabel.textColor = UIColor(white: 0.45, alpha: 1)
            }
        }

        // Detect JSON content
        let content = model.content ?? ""
        let jsonContent = Self.extractJSON(from: model)
        let isJSON = jsonContent != nil

        // JSON tag
        jsonTagLabel.isHidden = !isJSON

        // Reset
        showFullButton.isHidden = true
        contentBottomConstraint.isActive = false
        showFullBottomConstraint.isActive = false

        if isJSON, let json = jsonContent {
            // Pretty-print if possible
            let prettyJSON = Self.prettyPrint(json) ?? json

            if prettyJSON.count > Self.jsonTruncateLength {
                // Truncated JSON with syntax highlighting
                let truncated = String(prettyJSON.prefix(Self.jsonTruncateLength)) + "\n..."
                contentLabel.attributedText = NetworkDetailCell.highlightJSON(truncated)
                contentLabel.numberOfLines = 0
                showFullButton.isHidden = false
                showFullBottomConstraint.isActive = true
            } else {
                // Full JSON with syntax highlighting
                contentLabel.attributedText = NetworkDetailCell.highlightJSON(prettyJSON)
                contentLabel.numberOfLines = 0
                contentBottomConstraint.isActive = true
            }
        } else {
            // Plain text, truncated to maxLines
            contentLabel.attributedText = nil
            contentLabel.text = content
            contentLabel.textColor = model.color ?? UIColor(white: 0.82, alpha: 1)
            contentLabel.numberOfLines = Self.maxLines
            contentBottomConstraint.isActive = true
        }

        // Card background
        if model.isTag {
            cardView.backgroundColor = Self.taggedCardColor
        } else if model.isSelected {
            cardView.backgroundColor = UIColor(white: 0.15, alpha: 1)
        } else {
            cardView.backgroundColor = Self.cardColor
        }
    }

    @objc private func showFullTapped() {
        onShowFull?()
    }

    // MARK: - Helpers

    /// Try to extract a valid JSON string from the log model
    static func extractJSON(from model: _OCLogModel) -> String? {
        // First try contentData
        if let data = model.contentData,
           let str = String(data: data, encoding: .utf8),
           isValidJSON(str) {
            return str
        }
        // Then try content string
        if let content = model.content, isValidJSON(content) {
            return content
        }
        return nil
    }

    /// Pretty-print JSON string
    private static func prettyPrint(_ json: String) -> String? {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data, options: []),
              let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
              let result = String(data: pretty, encoding: .utf8) else {
            return nil
        }
        return result
    }

    private static func tagInfo(for logType: CocoaDebugLogType) -> (label: String, color: UIColor) {
        switch logType {
        case .normal: return ("app", appTagColor)
        case .RN:     return ("react", rnTagColor)
        case .web:    return ("web", webTagColor)
        @unknown default: return ("log", appTagColor)
        }
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeZone = .current
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }()

    static func formatTime(_ date: Date) -> String {
        return timeFormatter.string(from: date)
    }
}


class CustomTextView : UITextView {

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.inputView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.inputView = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(selectAll) {
            if let range = selectedTextRange, range.start == beginningOfDocument, range.end == endOfDocument {
                return false
            }
            return !text.isEmpty
        }
        else if action == #selector(paste(_:)) {
            return false
        }
        else if action == #selector(cut(_:)) {
            return false
        }

        return super.canPerformAction(action, withSender: sender)
    }
}
