import SwiftUI
import WebKit
import UIKit

public struct AIWebChatServiceItem: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let urlString: String
    public let iconSystemName: String
    public let note: String

    public static let defaults: [AIWebChatServiceItem] = [
        AIWebChatServiceItem(
            id: "gemini",
            name: "Google Gemini",
            urlString: "https://gemini.google.com",
            iconSystemName: "sparkles",
            note: "Đăng nhập Google, chat miễn phí không lo hết quota"
        ),
        AIWebChatServiceItem(
            id: "deepseek",
            name: "DeepSeek R1 / V3",
            urlString: "https://chat.deepseek.com",
            iconSystemName: "brain",
            note: "Suy luận sâu mã nguồn mở, miễn phí"
        ),
        AIWebChatServiceItem(
            id: "chatgpt",
            name: "ChatGPT",
            urlString: "https://chat.openai.com",
            iconSystemName: "bolt.fill",
            note: "OpenAI GPT-4o chat miễn phí"
        ),
        AIWebChatServiceItem(
            id: "claude",
            name: "Claude AI",
            urlString: "https://claude.ai",
            iconSystemName: "text.bubble.fill",
            note: "Anthropic Claude Sonnet"
        ),
        AIWebChatServiceItem(
            id: "aistudio",
            name: "Google AI Studio",
            urlString: "https://aistudio.google.com",
            iconSystemName: "hammer.fill",
            note: "Giao diện prompt & test model chuyên sâu của Google"
        )
    ]
}

public struct AIWebChatView: View {
    @ObservedObject var workspace: WorkspaceManager
    @ObservedObject var preferences: EditorPreferences

    @AppStorage("VisualIDE.aiwebchat.selectedService") private var selectedServiceID: String = "gemini"
    @State private var webActionTrigger: AIWebNavAction? = nil
    @State private var canGoBack: Bool = false
    @State private var canGoForward: Bool = false
    @State private var isLoading: Bool = false
    @State private var estimatedProgress: Double = 0.0
    @State private var currentURL: URL? = nil
    @State private var toastMessage: String? = nil
    @State private var showPasteConfirmationSheet: Bool = false
    @State private var clipboardCodeCandidate: String = ""

    public init(workspace: WorkspaceManager, preferences: EditorPreferences) {
        self.workspace = workspace
        self.preferences = preferences
    }

    private var activeService: AIWebChatServiceItem {
        AIWebChatServiceItem.defaults.first(where: { $0.id == selectedServiceID }) ?? AIWebChatServiceItem.defaults[0]
    }

    public var body: some View {
        let palette = preferences.activePalette

        VStack(spacing: 0) {
            // Web Navigation Bar
            HStack(spacing: 8) {
                // Service Selector Menu
                Menu {
                    ForEach(AIWebChatServiceItem.defaults) { item in
                        Button {
                            selectedServiceID = item.id
                            if let targetURL = URL(string: item.urlString) {
                                webActionTrigger = .load(targetURL)
                            }
                        } label: {
                            HStack {
                                Label(item.name, systemImage: item.iconSystemName)
                                if item.id == activeService.id {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: activeService.iconSystemName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: palette.accent))
                        Text(activeService.name)
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundColor(Color(hex: palette.foreground))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(Color(hex: palette.gutterForeground))
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Color(hex: palette.currentLineBackground))
                    .cornerRadius(6)
                }

                // Browser Navigation: Back / Forward / Reload
                Button {
                    webActionTrigger = .goBack
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(canGoBack ? Color(hex: palette.foreground) : Color(hex: palette.gutterForeground).opacity(0.4))
                }
                .disabled(!canGoBack)

                Button {
                    webActionTrigger = .goForward
                } label: {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(canGoForward ? Color(hex: palette.foreground) : Color(hex: palette.gutterForeground).opacity(0.4))
                }
                .disabled(!canGoForward)

                Button {
                    webActionTrigger = .reload
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11.5))
                        .foregroundColor(Color(hex: palette.foreground))
                }

                Spacer(minLength: 4)

                // Quick Action: Copy Active File Code to Clipboard
                Button {
                    copyActiveFileCodeToClipboard()
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 11))
                        Text(preferences.tr("Chép code file", "Copy code"))
                            .font(.system(size: 10.5, weight: .medium))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.18))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                }

                // Quick Action: Paste Code From Clipboard to File
                Button {
                    handlePasteFromClipboard()
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.down.doc")
                            .font(.system(size: 11))
                        Text(preferences.tr("Dán vào file", "Paste code"))
                            .font(.system(size: 10.5, weight: .medium))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.18))
                    .foregroundColor(.green)
                    .cornerRadius(6)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: palette.headerBackground))

            // Loading Progress Bar
            if isLoading && estimatedProgress < 1.0 {
                ProgressView(value: estimatedProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: palette.accent)))
                    .frame(height: 2)
            } else {
                Divider().overlay(Color.white.opacity(0.08))
            }

            // Toast Alert Banner
            if let toastMessage {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 11))
                    Text(toastMessage)
                        .font(.system(size: 11))
                        .lineLimit(2)
                    Spacer()
                    Button {
                        withAnimation { self.toastMessage = nil }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Embedded Persistent Web View
            AIWebChatContainer(
                initialURL: URL(string: activeService.urlString) ?? URL(string: "https://gemini.google.com")!,
                actionTrigger: $webActionTrigger,
                canGoBack: $canGoBack,
                canGoForward: $canGoForward,
                isLoading: $isLoading,
                estimatedProgress: $estimatedProgress,
                currentURL: $currentURL
            )
            .background(Color(hex: palette.editorBackground))
        }
        .confirmationDialog(
            preferences.tr("Dán code vào dự án", "Paste Code to Project"),
            isPresented: $showPasteConfirmationSheet,
            titleVisibility: .visible
        ) {
            if let activeTab = workspace.activeTab {
                Button(preferences.tr("Ghi đè file hiện tại (\(activeTab.title))", "Overwrite current file (\(activeTab.title))")) {
                    let rel = workspace.relativePath(for: activeTab.fileURL)
                    workspace.applyAgentFileEdit(relativePath: rel, newContent: clipboardCodeCandidate)
                    showToast(preferences.tr("Đã cập nhật file \(activeTab.title)!", "Updated file \(activeTab.title)!"))
                }
                Button(preferences.tr("Nối thêm vào cuối file hiện tại", "Append to current file")) {
                    let rel = workspace.relativePath(for: activeTab.fileURL)
                    let updated = activeTab.content + "\n\n" + clipboardCodeCandidate
                    workspace.applyAgentFileEdit(relativePath: rel, newContent: updated)
                    showToast(preferences.tr("Đã nối code vào file \(activeTab.title)!", "Appended to \(activeTab.title)!"))
                }
            }
            Button(preferences.tr("Tạo file mới từ code vừa copy...", "Create new file from clipboard...")) {
                let defaultName = "NewCode_\(Int(Date().timeIntervalSince1970 % 10000)).swift"
                workspace.applyAgentFileEdit(relativePath: defaultName, newContent: clipboardCodeCandidate)
                showToast(preferences.tr("Đã tạo file \(defaultName)!", "Created file \(defaultName)!"))
            }
            Button(preferences.tr("Hủy", "Cancel"), role: .cancel) {}
        } message: {
            Text(preferences.tr(
                "Đã phát hiện code trong Clipboard (\(clipboardCodeCandidate.count) ký tự). Bạn muốn áp dụng vào đâu?",
                "Found code in Clipboard (\(clipboardCodeCandidate.count) characters). Where would you like to paste it?"
            ))
        }
    }

    private func copyActiveFileCodeToClipboard() {
        guard let tab = workspace.activeTab else {
            showToast(preferences.tr("Chưa mở file nào để sao chép.", "No active file open to copy."))
            return
        }
        let rel = workspace.relativePath(for: tab.fileURL)
        let snippet = """
        File: \(rel)
        ```
        \(tab.content)
        ```
        Hãy xem xét file này và giúp tôi:
        """
        UIPasteboard.general.string = snippet
        showToast(preferences.tr("Đã sao chép nội dung file '\(tab.title)'! Bạn chỉ cần dán (Paste) vào ô chat.", "Copied '\(tab.title)' content! Paste directly into the chat."))
    }

    private func handlePasteFromClipboard() {
        guard let text = UIPasteboard.general.string, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showToast(preferences.tr("Clipboard chưa có nội dung văn bản nào.", "Clipboard is empty."))
            return
        }
        // Extract raw code if inside markdown code fences
        let extracted = Self.extractCodeBlock(from: text)
        clipboardCodeCandidate = extracted
        showPasteConfirmationSheet = true
    }

    private static func extractCodeBlock(from text: String) -> String {
        let pattern = "```(?:[a-zA-Z0-9_-]+)?\\s*\\n([\\s\\S]*?)\\n```"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: (text as NSString).length)) {
            let ns = text as NSString
            return ns.substring(with: match.range(at: 1))
        }
        return text
    }

    private func showToast(_ msg: String) {
        withAnimation {
            toastMessage = msg
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            if toastMessage == msg {
                withAnimation { toastMessage = nil }
            }
        }
    }
}

public enum AIWebNavAction: Equatable {
    case load(URL)
    case goBack
    case goForward
    case reload
}

struct AIWebChatContainer: UIViewRepresentable {
    let initialURL: URL
    @Binding var actionTrigger: AIWebNavAction?
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var isLoading: Bool
    @Binding var estimatedProgress: Double
    @Binding var currentURL: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = WKWebsiteDataStore.default() // Persistent session cookies for Google / OpenAI login!

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic

        // Standard mobile Safari user agent to ensure Google & OAuth logins are never blocked
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"

        context.coordinator.attachObservers(to: webView)
        webView.load(URLRequest(url: initialURL))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let action = actionTrigger else { return }
        DispatchQueue.main.async {
            self.actionTrigger = nil
        }
        switch action {
        case .load(let url):
            webView.load(URLRequest(url: url))
        case .goBack:
            if webView.canGoBack { webView.goBack() }
        case .goForward:
            if webView.canGoForward { webView.goForward() }
        case .reload:
            webView.reload()
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: AIWebChatContainer
        private var observations: [NSKeyValueObservation] = []

        init(_ parent: AIWebChatContainer) {
            self.parent = parent
        }

        func attachObservers(to webView: WKWebView) {
            observations.append(webView.observe(\.canGoBack, options: [.new]) { [weak self] wv, _ in
                DispatchQueue.main.async { self?.parent.canGoBack = wv.canGoBack }
            })
            observations.append(webView.observe(\.canGoForward, options: [.new]) { [weak self] wv, _ in
                DispatchQueue.main.async { self?.parent.canGoForward = wv.canGoForward }
            })
            observations.append(webView.observe(\.isLoading, options: [.new]) { [weak self] wv, _ in
                DispatchQueue.main.async { self?.parent.isLoading = wv.isLoading }
            })
            observations.append(webView.observe(\.estimatedProgress, options: [.new]) { [weak self] wv, _ in
                DispatchQueue.main.async { self?.parent.estimatedProgress = wv.estimatedProgress }
            })
            observations.append(webView.observe(\.url, options: [.new]) { [weak self] wv, _ in
                DispatchQueue.main.async { self?.parent.currentURL = wv.url }
            })
        }

        // Handle target="_blank" and window.open for OAuth / Google sign in popups
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.canGoBack = webView.canGoBack
                self.parent.canGoForward = webView.canGoForward
                self.parent.currentURL = webView.url
                self.parent.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
    }
}
