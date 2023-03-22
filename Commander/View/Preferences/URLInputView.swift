import SwiftUI

extension SettingsSidebarView {
    struct URLInputView: View {
        // MARK: Internal

        @Binding var isVisible: Bool
        @Binding var enteredURL: URL?

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "link")
                        .foregroundColor(.blue)
                        .font(.title3)
                    Text("Add URL for quick access")
                        .font(.title3.weight(.medium))
                }
                Text("Once you've added the URL, you can launch it like any other app using the Commander launcher.")
                    .padding(.bottom, 8)
                TextField("Paste your URL here", text: $enteredText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 8)
                HStack {
                    Spacer()
                    Button("Cancel") {
                        isVisible = false
                    }.keyboardShortcut(.cancelAction)
                    Button("Create") {
                        isVisible = false
                        enteredURL = URL(string: enteredText)
                    }.disabled(urlIsInvalid).keyboardShortcut(.defaultAction)
                }
            }.onChange(of: enteredText) { newValue in
                urlIsInvalid = URL(string: newValue) == nil
            }.padding().frame(width: 400)
        }

        // MARK: Private

        @State private var urlIsInvalid = true
        @State private var enteredText = ""
    }
}
