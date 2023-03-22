import SwiftUI

// MARK: - SettingsSearchField

struct SettingsSearchField: View {
    @FocusState private var isFocused: Bool
    @Binding var searchText: String

    var body: some View {
        GroupBox {
            HStack(spacing: 2) {
                contentView
            }.animation(.default, value: isFocused)
        }.onTapGesture {
            isFocused = true
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if !isFocused {
            searchIconView
        }
        TextField(text: $searchText)
            .focused($isFocused)
        if !isFocused {
            Spacer()
        }
        if !searchText.isEmpty {
            clearButton
        }
    }

    private var searchIconView: some View {
        Image(systemName: "magnifyingglass")
            .foregroundColor(.gray)
            .opacity(isFocused ? 0 : 1)
            .padding(.leading, 6)
    }

    private var clearButton: some View {
        Button {
            searchText = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .padding(.horizontal, 4)
                .opacity(0.7)
        }.buttonStyle(.plain)
    }
}

extension SettingsSearchField {
    struct TextField: NSViewRepresentable {
        final class Coordinator: NSObject, NSTextFieldDelegate {
            // MARK: Lifecycle

            override init() {
                textField = NSTextField()
                super.init()
                configureTextField()
            }

            // MARK: Internal

            let textField: NSTextField
            var onTextChange: ((String) -> Void)?

            func controlTextDidChange(_: Notification) {
                onTextChange?(textField.stringValue)
            }

            private func configureTextField() {
                let font = NSFont.preferredFont(forTextStyle: .body)
                textField.font = font
                textField.placeholderAttributedString = NSAttributedString(
                    string: "Search",
                    attributes: [.foregroundColor: NSColor.gray, .font: font]
                )
                textField.focusRingType = .none
                textField.isBezeled = false
                textField.backgroundColor = .clear
                textField.delegate = self
            }
        }

        @Binding var text: String

        func makeNSView(context: Context) -> some NSView {
            context.coordinator.textField
        }

        func makeCoordinator() -> Coordinator {
            let coordinator = Coordinator()
            coordinator.onTextChange = {
                text = $0
            }
            return coordinator
        }

        func updateNSView(_ nsView: NSViewType, context _: Context) {
            guard let textField = nsView as? NSTextField else {
                return
            }
            textField.stringValue = text
        }
    }
}
