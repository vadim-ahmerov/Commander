import SwiftUI

// MARK: - SettingsTutorialView

struct SettingsTutorialView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How to use the app:")
                .font(.title2.bold())

            TutorialStepView(
                stepNumber: "1",
                title: "Select apps to launch",
                description: "Choose the apps you want to launch by either selecting them in the left sidebar or dragging and dropping them onto the circle below. You can also add files and folders."
            )

            TutorialStepView(
                stepNumber: "2",
                title: "Rearrange apps",
                description: "If you prefer a different arrangement of your apps, just drag and drop them within the circle below."
            )

            TutorialStepView(
                stepNumber: "3",
                title: "Launch apps",
                description: "Access the app launcher at any time by using the specified shortcut and slightly moving your mouse. When the app picker appears, hover over the desired app and release the shortcut to launch it."
            )
        }
    }
}

// MARK: - TutorialStepView

private struct TutorialStepView: View {
    let stepNumber: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(nsColor: NSColor.quaternaryLabelColor))
                .frame(width: 22, height: 22)
                .overlay(Text(stepNumber).font(.body).fontWeight(.bold))
                .padding(.top, 2)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3.bold())
                Text(description)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
