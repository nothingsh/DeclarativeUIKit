import DeclarativeUIKit
import UIKit

private struct Message {
    let id: Int
    let title: String
    var isRead = false
}

private enum Row {
    case message(Message)
    case notifications
    case storage
    case version

    var id: String {
        switch self {
        case .message(let message): return "message-\(message.id)"
        case .notifications: return "notifications"
        case .storage: return "storage"
        case .version: return "version"
        }
    }
}

/// A grouped list with reusable and standard rows, updated by passing new data.
final class ListExampleViewController: UIViewController {

    private var messages = (1...4).map { Message(id: $0, title: "Message \($0)") }
    private var notifications = true
    private var list: VList<Row>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List"
        view.background(.systemGroupedBackground)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add", style: .plain, target: self, action: #selector(addMessage)
        )

        list = view.addContent(
            VList(sections: sections(), id: \.id, appearance: .insetGrouped) { [weak self] row in
                switch row {
                case .message(let message):
                    return ListRow(MessageRow.self) { $0.update(message) }
                        .onSelect { self?.toggleRead(message.id) }
                        .trailingSwipeActions([
                            UIContextualAction(style: .destructive, title: "Delete") { _, _, done in
                                self?.deleteMessage(message.id)
                                done(true)
                            }
                        ])
                case .notifications:
                    return ListRow(SwitchRow.self) {
                        $0.update(title: "Notifications", isOn: self?.notifications ?? false)
                        $0.onChange = { self?.notifications = $0 }
                    }
                case .storage:
                    var content = UIListContentConfiguration.valueCell()
                    content.text = "Storage"
                    content.secondaryText = "1.2 GB"
                    content.image = UIImage(systemName: "internaldrive")
                    return ListRow(content: content)
                case .version:
                    return ListRow {
                        HStack(spacing: 8) {
                            UILabel().text("Version").font(textStyle: .body)
                            Spacer()
                            UILabel().text("1.0").font(textStyle: .body).textColor(.secondaryLabel)
                        }
                        .padding(horizontal: 16, vertical: 12)
                    }
                }
            },
            safeArea: .horizontal
        )
        .contentInsetAdjustmentBehavior(.automatic)
        .onRefresh { [weak self] in await self?.startOver() }
    }

    private func sections() -> [ListSection<Row>] {
        [
            ListSection(
                id: "inbox",
                header: "Inbox · \(messages.filter { !$0.isRead }.count) unread",
                footer: "Add inserts a message at the top. Tap a message to mark it read or unread, swipe it to delete it, and pull down to start over.",
                items: messages.map(Row.message)
            ),
            ListSection(id: "settings", header: "Settings", items: [.notifications, .storage, .version])
        ]
    }

    @objc private func addMessage() {
        let id = (messages.map(\.id).max() ?? 0) + 1
        messages.insert(Message(id: id, title: "Message \(id)"), at: 0)
        list.update(sections())
    }

    private func deleteMessage(_ id: Int) {
        messages.removeAll { $0.id == id }
        list.update(sections())
    }

    private func startOver() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        messages = (1...4).map { Message(id: $0, title: "Message \($0)") }
        list.update(sections())
    }

    private func toggleRead(_ id: Int) {
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[index].isRead.toggle()
        list.update(sections())
    }
}

/// A reusable row: the structure is built once per cell and `update` fills it in.
private final class MessageRow: UIView, ListRowView {
    private let dot = UIView()
        .background(.systemBlue)
        .cornerRadius(5)
        .frame(width: 10, height: 10)
    private let title = UILabel().font(textStyle: .body)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addHStack(spacing: 12) {
            dot
            title
            Spacer()
        }
        .padding(horizontal: 16, vertical: 12)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported.")
    }

    func update(_ message: Message) {
        title.text(message.title)
        dot.alpha = message.isRead ? 0 : 1
    }
}

/// A reusable row with a switch, which reports changes through `onChange`.
private final class SwitchRow: UIView, ListRowView {
    private let title = UILabel().font(textStyle: .body)
    private let toggle = UISwitch()
    var onChange: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        toggle.onEvent(.valueChanged) { [weak self] in self?.onChange?($0.isOn) }
        addHStack(spacing: 8) {
            title
            Spacer()
            toggle
        }
        .padding(horizontal: 16, vertical: 8)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported.")
    }

    func update(title: String, isOn: Bool) {
        self.title.text(title)
        toggle.isOn = isOn
    }
}
