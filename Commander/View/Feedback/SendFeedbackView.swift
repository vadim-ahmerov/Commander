import Combine
import SwiftUI
import Foundation

struct SendFeedbackView: View {
    // MARK: Internal

    enum ViewState {
        case entering
        case submitting
        case submitted
    }

    var fontLineHeight: CGFloat {
        NSLayoutManager().defaultLineHeight(for: NSFont.preferredFont(forTextStyle: .body))
    }

    var body: some View {
        Form {
            Section(header: Text("Message").font(.title3)) {
                TextArea(text: $feedbackText, maximumNumberOfLines: 0)
                    .frame(height: 120)
                    .cornerRadius(4)
            }
            Spacer().frame(height: 16)
            Section(header: Text("Your email or Contact Details (optional)").font(.title3)) {
                TextArea(text: $contactDetails, maximumNumberOfLines: 1)
                    .frame(minHeight: fontLineHeight + 16)
                    .cornerRadius(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer().frame(height: 16)

            switch state {
            case .entering:
                Button {
                    submitFeedback()
                } label: {
                    Text("Submit")
                }.disabled(feedbackText.isEmpty)
            case .submitting:
                HStack {
                    Spacer()
                    ProgressView().progressViewStyle(.circular)
                    Spacer()
                }
            case .submitted:
                Text("\(Image(systemName: "checkmark")) Your feedback has been received, thank you")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundColor(Color.accentColor)
            }
        }
        .animation(.default, value: state)
        .frame(minWidth: 400)
        .padding()
    }

    @MainActor
    func submitFeedback() {
        guard !feedbackText.isEmpty else {
            return
        }

        state = .submitting
        sendFeedback(message: feedbackText, contactDetails: contactDetails)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        state = .submitted
                    case .failure:
                        state = .entering
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    // MARK: Private

    @State private var feedbackText = ""
    @State private var contactDetails = ""
    @State private var state = ViewState.entering
    @State private var cancellables = Set<AnyCancellable>()

    private func sendFeedback(message: String, contactDetails: String) -> AnyPublisher<Void, URLError> {
        guard let url = URL(string: "https://ethereal-expanse.com/api/chromex/feedback") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let params: [String: Any] = [
            "message": message,
            "email": contactDetails,
            "app": "Commander",
            "platform": "macOS",
            "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "systemVersion": ProcessInfo.processInfo.operatingSystemVersionString
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: params) else {
            return Fail(error: URLError(.cannotParseResponse)).eraseToAnyPublisher()
        }
        
        request.httpBody = jsonData

        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
