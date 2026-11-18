import SwiftUI
import UniformTypeIdentifiers
import UIKit

public struct SettingsAndThemesSheet: View {
    @ObservedObject var preferences: EditorPreferences
    @ObservedObject var liveServer: LiveServerService
    @ObservedObject var runner: CodeRunnerService
    @ObservedObject var daemonService: LocalDaemonService
    var onOpenDaemonManager: () -> Void = {}
    @Environment(\.dismiss) private var dismiss

    @State private var showThemeStudio: Bool = false
    @State private var copiedBanner: Bool = false
    @State private var copiedTelegram: Bool = false
    @State private var copiedCloudURL: Bool = false
    @State private var themeImportMessage: String? = nil
    @State private var pendingDismissAction: (() -> Void)? = nil

    public init(
        preferences: EditorPreferences,
        liveServer: LiveServerService,
        runner: CodeRunnerService,
        daemonService: LocalDaemonService,
        onOpenDaemonManager: @escaping () -> Void = {}
    ) {
        self.preferences = preferences
        self.liveServer = liveServer
        self.runner = runner
        self.daemonService = daemonService
        self.onOpenDaemonManager = onOpenDaemonManager
    }

    public var body: some View {
        CompatibleNavigationContainer {
            Form {
                // MARK: - 0. Visual IDE Hero Identity Card
                Section {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 16) {
                            IDECodeMarkVector(size: 58)
                                .shadow(color: Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255).opacity(0.35), radius: 8, x: 0, y: 3)

                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .center, spacing: 8) {
                                    BrandVisualIDEWordmarkView(height: 20, inkColor: .primary)
                                    Text("v5.8.0")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255).opacity(0.18))
                                        .foregroundColor(Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255))
                                        .clipShape(Capsule())
                                }
                                Text("Native Code Editor & 24/7 Cloud Workstation")
                                    .font(.system(size: 12.5, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Status badges
                        HStack(spacing: 8) {
                            badgePill(text: "● Cloud 24/7", color: Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255))
                            badgePill(text: "Apple Metal 60 FPS", color: Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255))
                            badgePill(text: "Zero-Config Sandbox", color: Color(red: 168 / 255, green: 85 / 255, blue: 247 / 255))
                        }
                    }
                    .padding(.vertical, 8)
                }

                // MARK: - 1. Visual IDE Cloud 24/7 (Vercel Edge Server)
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            iconBadge(name: "cloud.fill", color: Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Visual IDE Cloud Web (24/7)")
                                    .font(.system(size: 14.5, weight: .bold))
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255))
                                        .frame(width: 6, height: 6)
                                    Text("Online 24/7 trên Vercel Edge Server")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255))
                                }
                            }
                            Spacer()
                        }

                        Text(preferences.tr(
                            "Bạn có thể tắt máy đi ngủ, dự án vẫn luôn được duy trì chạy 24/7 trên Vercel Edge Server. Monaco Editor, Terminal, Live Preview & Antigravity AI đều có sẵn trên web.",
                            "You can turn off your device and sleep—your workspace stays alive 24/7 on Vercel Edge Server with Monaco Editor, Terminal, Live Preview & Antigravity AI."
                        ))
                        .font(.system(size: 12.5))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)

                        HStack {
                            Text(IDEAuthorInfo.cloudDomain)
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundColor(Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255).opacity(0.12))
                                .cornerRadius(6)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 4)

                    Button {
                        UIApplication.shared.open(IDEAuthorInfo.cloudURL)
                    } label: {
                        HStack(spacing: 10) {
                            iconBadge(name: "safari.fill", color: Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255))
                            Text(preferences.tr(
                                "Mở Web IDE (idevisual.vercel.app)",
                                "Open Web IDE (idevisual.vercel.app)"
                            ))
                            .font(.system(size: 13.5, weight: .semibold))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }

                    Button {
                        UIPasteboard.general.string = "https://\(IDEAuthorInfo.cloudDomain)"
                        copiedCloudURL = true
                    } label: {
                        HStack(spacing: 10) {
                            iconBadge(name: copiedCloudURL ? "checkmark.circle.fill" : "doc.on.doc.fill", color: copiedCloudURL ? Color.green : Color.blue)
                            Text(copiedCloudURL
                                ? preferences.tr("Đã sao chép link idevisual.vercel.app!", "Copied idevisual.vercel.app link!")
                                : preferences.tr("Sao chép liên kết Cloud (idevisual.vercel.app)", "Copy Cloud Link (idevisual.vercel.app)")
                            )
                            .font(.system(size: 13.5, weight: .medium))
                        }
                    }
                } header: {
                    Text(preferences.tr(
                        "Đồng Bộ & Chạy Ngầm 24/7 (Vercel Server)",
                        "Cloud Workstation & 24/7 Sync (Vercel)",
                        zh: "云端工作区与 24/7 同步 (Vercel)",
                        ja: "クラウドワークスペース＆ 24/7 同期 (Vercel)",
                        ko: "클라우드 워크스페이스 & 24/7 동기화 (Vercel)",
                        ru: "Облачный воркспейс 24/7 (Vercel)",
                        es: "Estación Cloud 24/7 (Vercel)"
                    ))
                }

                // MARK: - 2. Interface Language
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(AppLanguage.allCases) { lang in
                                let isSelected = (preferences.appLanguage == lang)
                                Button {
                                    preferences.appLanguage = lang
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(lang.shortBadge)
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.18))
                                            .foregroundColor(isSelected ? .white : .primary)
                                            .cornerRadius(4)
                                        Text(lang.nativeName)
                                            .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(isSelected ? Color.accentColor.opacity(0.14) : Color(uiColor: .secondarySystemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
                                    )
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    Picker(
                        selection: $preferences.appLanguage
                    ) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text("\(lang.shortBadge) — \(lang.displayName(in: preferences.appLanguage))").tag(lang)
                        }
                    } label: {
                        HStack(spacing: 10) {
                            iconBadge(name: "globe", color: .blue)
                            Text(preferences.tr(
                                "Ngôn ngữ giao diện",
                                "Interface Language",
                                zh: "界面语言",
                                ja: "表示言語",
                                ko: "인터페이스 언어",
                                ru: "Язык интерфейса",
                                es: "Idioma de la interfaz"
                            ))
                            .font(.system(size: 13.5))
                        }
                    }

                    if preferences.appLanguage != .vietnamese {
                        Button {
                            preferences.appLanguage = .vietnamese
                        } label: {
                            HStack(spacing: 10) {
                                iconBadge(name: "arrow.uturn.backward", color: .orange)
                                Text(preferences.tr(
                                    "Đặt lại Tiếng Việt (Mặc định)",
                                    "Reset to Tiếng Việt (Default)",
                                    zh: "恢复默认语言 (Tiếng Việt)",
                                    ja: "Tiếng Việt（デフォルト）に戻す",
                                    ko: "Tiếng Việt(기본값)으로 복원",
                                    ru: "Сбросить на Tiếng Việt (По умолчанию)",
                                    es: "Restablecer a Tiếng Việt (Predeterminado)"
                                ))
                                .font(.system(size: 13.5, weight: .semibold))
                            }
                        }
                    }
                } header: {
                    Text(preferences.tr(
                        "Ngôn Ngữ Giao Diện (Mặc định: Tiếng Việt)",
                        "Interface Language (Default: Vietnamese)",
                        zh: "界面语言（默认：越南语）",
                        ja: "表示言語（デフォルト：ベトナム語）",
                        ko: "인터페이스 언어 (기본값: 베트남어)",
                        ru: "Язык интерфейса (По умолчанию: Вьетнамский)",
                        es: "Idioma de la Interfaz (Predeterminado: Vietnamita)"
                    ))
                }

                // MARK: - 3. Author & Developer Info
                Section {
                    authorInfoCardRow(
                        icon: "person.crop.circle.fill",
                        iconColor: .indigo,
                        label: preferences.tr("Tác giả", "Author", zh: "作者", ja: "作者", ko: "작성자", ru: "Автор", es: "Autor"),
                        value: IDEAuthorInfo.fullName
                    )
                    authorInfoCardRow(
                        icon: "envelope.fill",
                        iconColor: .blue,
                        label: preferences.tr("Email", "Email", zh: "邮箱", ja: "メール", ko: "이메일", ru: "Эл. почта", es: "Correo"),
                        value: IDEAuthorInfo.email,
                        monospaced: true
                    )
                    authorInfoCardRow(
                        icon: "chevron.left.forwardslash.chevron.right",
                        iconColor: .purple,
                        label: "GitHub",
                        value: IDEAuthorInfo.githubHandle,
                        monospaced: true
                    )
                    authorInfoCardRow(
                        icon: "paperplane.fill",
                        iconColor: Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255),
                        label: "Telegram",
                        value: IDEAuthorInfo.telegramHandle,
                        monospaced: true
                    )
                    authorInfoCardRow(
                        icon: "doc.text.fill",
                        iconColor: .orange,
                        label: preferences.tr("Giấy phép", "License", zh: "许可证", ja: "ライセンス", ko: "라이선스", ru: "Лицензия", es: "Licencia"),
                        value: "\(IDEAuthorInfo.licenseName) (Open Source)"
                    )

                    Button {
                        UIApplication.shared.open(IDEAuthorInfo.emailURL)
                    } label: {
                        HStack(spacing: 10) {
                            iconBadge(name: "envelope.badge.fill", color: .blue)
                            Text(preferences.tr(
                                "Gửi Email (\(IDEAuthorInfo.email))",
                                "Send Email (\(IDEAuthorInfo.email))"
                            ))
                            .font(.system(size: 13.5, weight: .semibold))
                        }
                    }

                    Button {
                        UIApplication.shared.open(IDEAuthorInfo.telegramURL)
                    } label: {
                        HStack(spacing: 10) {
                            iconBadge(name: "paperplane.fill", color: Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255))
                            Text(preferences.tr(
                                "Liên hệ qua Telegram (\(IDEAuthorInfo.telegramHandle))",
                                "Contact via Telegram (\(IDEAuthorInfo.telegramHandle))"
                            ))
                            .font(.system(size: 13.5, weight: .semibold))
                        }
                    }

                    Button {
                        UIPasteboard.general.string = IDEAuthorInfo.telegramHandle
                        copiedTelegram = true
                    } label: {
                        HStack(spacing: 10) {
                            iconBadge(name: copiedTelegram ? "checkmark.circle.fill" : "doc.on.doc.fill", color: copiedTelegram ? .green : .cyan)
                            Text(copiedTelegram
                                ? preferences.tr("Đã sao chép \(IDEAuthorInfo.telegramHandle)!", "Copied \(IDEAuthorInfo.telegramHandle)!")
                                : preferences.tr("Sao chép Telegram (\(IDEAuthorInfo.telegramHandle))", "Copy Telegram Handle (\(IDEAuthorInfo.telegramHandle))")
                            )
                            .font(.system(size: 13.5, weight: .medium))
                        }
                    }

                    Button {
                        UIApplication.shared.open(IDEAuthorInfo.githubRepoURL)
                    } label: {
                        HStack(spacing: 10) {
                            iconBadge(name: "chevron.left.forwardslash.chevron.right", color: .purple)
                            Text(preferences.tr(
                                "Mã nguồn GitHub (zheedevVN/VisualEditIDE)",
                                "GitHub Repository (zheedevVN/VisualEditIDE)"
                            ))
                            .font(.system(size: 13.5, weight: .semibold))
                        }
                    }
                } header: {
                    Text(preferences.tr(
                        "Thông Tin Tác Giả & Nhà Phát Triển",
                        "Author & Developer",
                        zh: "作者与开发者信息",
                        ja: "作者・開発者情報",
                        ko: "작성자 및 개발자 정보",
                        ru: "Автор и разработчик",
                        es: "Autor y Desarrollador"
                    ))
                }

                // MARK: - 4. Code Intelligence & Inline Diagnostics
                Section {
                    Toggle(isOn: $preferences.enableCodeCompletion) {
                        HStack(spacing: 10) {
                            iconBadge(name: "sparkles", color: .blue)
                            Text(preferences.tr("Bật gợi ý code thông minh (IntelliSense)", "Enable VS Code Smart IntelliSense"))
                                .font(.system(size: 13.5))
                        }
                    }

                    Toggle(isOn: $preferences.enableLiveDiagnostics) {
                        HStack(spacing: 10) {
                            iconBadge(name: "exclamationmark.triangle.fill", color: .orange)
                            Text(preferences.tr("Báo lỗi trực tiếp (Inline Diagnostics)", "Enable Inline Error Diagnostics"))
                                .font(.system(size: 13.5))
                        }
                    }

                    Toggle(isOn: $preferences.formatOnSave) {
                        HStack(spacing: 10) {
                            iconBadge(name: "wand.and.stars", color: .green)
                            Text(preferences.tr("Tự động Format Code khi Lưu / Chạy", "Auto-Format Code on Save / Run"))
                                .font(.system(size: 13.5))
                        }
                    }

                    Toggle(isOn: $preferences.autoIndentOnReturn) {
                        HStack(spacing: 10) {
                            iconBadge(name: "arrow.right.to.line", color: .teal)
                            Text(preferences.tr("Tự động thụt lề khi nhấn Enter", "Smart Auto-Indent on Return"))
                                .font(.system(size: 13.5))
                        }
                    }

                    Toggle(isOn: $preferences.enableAutoSave) {
                        HStack(spacing: 10) {
                            iconBadge(name: "clock.arrow.circlepath", color: .indigo)
                            Text(preferences.tr("Tự động lưu & ghi lịch sử phiên bản", "Auto-Save & Record Version Snapshots"))
                                .font(.system(size: 13.5))
                        }
                    }

                    Toggle(isOn: $preferences.showBreadcrumbs) {
                        HStack(spacing: 10) {
                            iconBadge(name: "point.filled.topleft.down.curvedto.point.bottomright.up", color: .purple)
                            Text(preferences.tr("Hiện thanh đường dẫn hàm (Breadcrumbs)", "Show Breadcrumbs & Symbol Outline"))
                                .font(.system(size: 13.5))
                        }
                    }

                    Toggle(isOn: $preferences.enableCodeFolding) {
                        HStack(spacing: 10) {
                            iconBadge(name: "chevron.up.chevron.down", color: .pink)
                            Text(preferences.tr("Cho phép gập/mở khối code (Folding)", "Enable Code Folding"))
                                .font(.system(size: 13.5))
                        }
                    }
                } header: {
                    Text(preferences.tr(
                        "Gợi Ý Code Thông Minh & Báo Lỗi",
                        "Smart IntelliSense & Diagnostics",
                        zh: "智能代码提示与错误诊断",
                        ja: "スマート補完・エラー診断",
                        ko: "스마트 자동완성 및 진단",
                        ru: "IntelliSense и диагностика",
                        es: "IntelliSense y Diagnóstico"
                    ))
                } footer: {
                    Text(preferences.tr(
                        "Hỗ trợ nhận diện 64 ngôn ngữ, gợi ý Fuzzy/CamelCase, gợi ý thành phần (./::/->), Emmet HTML và tự động căn chỉnh code chuẩn.",
                        "Supports 64 programming languages, Fuzzy/CamelCase ranking, member triggers (./::/->), Emmet HTML expansion, and language-aware formatting."
                    ))
                }

                // MARK: - 5. Syntax Color & Themes
                Section(preferences.tr(
                    "Bộ Sưu Tập Theme Màu Code & Giao Diện App",
                    "Syntax Themes & App Appearance",
                    zh: "代码配色主题与外观",
                    ja: "シンタックステーマ＆外観",
                    ko: "코드 테마 및 앱 외관",
                    ru: "Темы подсветки и интерфейс",
                    es: "Temas de Sintaxis y Apariencia"
                )) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(preferences.allThemes) { theme in
                                themePreviewCard(theme)
                            }
                        }
                        .padding(.vertical, 6)
                    }

                    Picker(selection: $preferences.selectedThemeID) {
                        ForEach(preferences.allThemes) { theme in
                            Text(theme.name).tag(theme.id)
                        }
                    } label: {
                        HStack(spacing: 10) {
                            iconBadge(name: "paintbrush.fill", color: .purple)
                            Text(preferences.tr("Chọn nhanh Theme", "Quick Theme Picker"))
                                .font(.system(size: 13.5))
                        }
                    }

                    // App Accent Swatch Bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            HStack(spacing: 10) {
                                iconBadge(name: "circle.lefthalf.filled", color: .cyan)
                                Text(preferences.tr("Màu nhấn ứng dụng (App Accent)", "App Accent Color"))
                                    .font(.system(size: 13.5))
                            }
                            Spacer()
                            Text(preferences.customAccentHex.isEmpty ? preferences.tr("Theo Theme", "From Theme") : preferences.customAccentHex)
                                .font(.system(size: 11.5, design: .monospaced))
                                .foregroundColor(.secondary)
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(EditorPreferences.appAccentPresets, id: \.name) { preset in
                                    let isSelected = (preferences.customAccentHex == preset.hex)
                                    Button {
                                        preferences.customAccentHex = preset.hex
                                    } label: {
                                        HStack(spacing: 5) {
                                            Circle()
                                                .fill(preset.hex.isEmpty ? Color(hex: preferences.activePalette.accent) : Color(hex: preset.hex))
                                                .frame(width: 14, height: 14)
                                            Text(preset.hex.isEmpty ? preferences.tr("Theo Theme", "From Theme") : preset.name)
                                                .font(.system(size: 11.5, weight: isSelected ? .bold : .regular))
                                        }
                                        .padding(.horizontal, 9)
                                        .padding(.vertical, 5)
                                        .background(isSelected ? Color.accentColor.opacity(0.18) : Color(uiColor: .secondarySystemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
                                        )
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 2)

                    Button {
                        showThemeStudio = true
                    } label: {
                        HStack(spacing: 10) {
                            iconBadge(name: "paintpalette.fill", color: .pink)
                            Text(preferences.tr("Mở Theme Studio (Tự chỉnh màu Code & Nền)", "Open Theme Studio (Customize Colors)"))
                                .font(.system(size: 13.5, weight: .semibold))
                        }
                    }

                    Button {
                        NativeDocumentPickerPresenter.shared.presentPicker(mode: .themeJSON) { pickedURL in
                            let fallbackName = pickedURL.deletingPathExtension().lastPathComponent
                            guard let raw = try? Data(contentsOf: pickedURL) else {
                                themeImportMessage = preferences.tr(
                                    "Không đọc được file theme .json đã chọn.",
                                    "Could not read the selected theme .json file."
                                )
                                return
                            }
                            let cleaned = ExtensionStoreService.stripJSONComments(from: raw) ?? raw
                            if let imported = VSCodeThemeImporter.parse(jsonData: cleaned, fallbackName: fallbackName) {
                                preferences.upsertCustomTheme(imported)
                                themeImportMessage = preferences.tr(
                                    "[OK] Đã nhập & áp dụng theme \"\(imported.name)\".",
                                    "[OK] Imported & applied theme \"\(imported.name)\"."
                                )
                            } else {
                                themeImportMessage = preferences.tr(
                                    "File .json không đúng cấu trúc VS Code Color Theme.",
                                    "Selected .json is not a valid VS Code Color Theme."
                                )
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            iconBadge(name: "square.and.arrow.down.fill", color: .blue)
                            Text(preferences.tr("Import File Theme .json từ VS Code", "Import VS Code Theme .json"))
                                .font(.system(size: 13.5))
                        }
                    }

                    if let msg = themeImportMessage {
                        Text(msg)
                            .font(.footnote)
                            .foregroundColor(msg.hasPrefix("[OK]") ? .green : .red)
                    }
                }

                // MARK: - 6. Font & Editor Layout
                Section(preferences.tr(
                    "Font Chữ & Hiển Thị Vùng Code",
                    "Typography & Editor Layout",
                    zh: "字体与编辑器布局",
                    ja: "フォントとエディタ表示",
                    ko: "글꼴 및 에디터 레이아웃",
                    ru: "Шрифты и отображение редактора",
                    es: "Fuente y Diseño del Editor"
                )) {
                    Picker(selection: $preferences.fontName) {
                        ForEach(EditorPreferences.availableFonts, id: \.self) { f in
                            Text(f).tag(f)
                        }
                    } label: {
                        HStack(spacing: 10) {
                            iconBadge(name: "textformat", color: .blue)
                            Text(preferences.tr("Font chữ", "Font Family"))
                                .font(.system(size: 13.5))
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            HStack(spacing: 10) {
                                iconBadge(name: "textformat.size", color: .purple)
                                Text(preferences.tr("Cỡ chữ (Hỗ trợ Pinch-to-Zoom)", "Font Size (Pinch-to-Zoom)"))
                                    .font(.system(size: 13.5))
                            }
                            Spacer()
                            Text("\(Int(preferences.fontSize)) pt")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $preferences.fontSize, in: 10...28, step: 0.5)
                    }
                    .padding(.vertical, 2)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            HStack(spacing: 10) {
                                iconBadge(name: "arrow.up.and.down.text.horizontal", color: .teal)
                                Text(preferences.tr("Giãn dòng (Line Height)", "Line Height"))
                                    .font(.system(size: 13.5))
                            }
                            Spacer()
                            Text(String(format: "%.2fx", preferences.lineHeightMultiplier))
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $preferences.lineHeightMultiplier, in: 1.0...1.65, step: 0.05)
                    }
                    .padding(.vertical, 2)

                    Picker(selection: $preferences.tabWidth) {
                        Text("2 Spaces").tag(2)
                        Text("4 Spaces").tag(4)
                    } label: {
                        HStack(spacing: 10) {
                            iconBadge(name: "arrow.right.to.line.compact", color: .orange)
                            Text(preferences.tr("Độ rộng phím Tab", "Tab Width"))
                                .font(.system(size: 13.5))
                        }
                    }

                    Toggle(isOn: $preferences.wordWrap) {
                        HStack(spacing: 10) {
                            iconBadge(name: "wrap", color: .indigo)
                            Text(preferences.tr("Tự xuống dòng (Word Wrap)", "Word Wrap"))
                                .font(.system(size: 13.5))
                        }
                    }

                    Toggle(isOn: $preferences.showLineNumbers) {
                        HStack(spacing: 10) {
                            iconBadge(name: "list.number", color: .blue)
                            Text(preferences.tr("Hiện số dòng (Line Numbers)", "Show Line Numbers"))
                                .font(.system(size: 13.5))
                        }
                    }

                    Toggle(isOn: $preferences.showInvisibleCharacters) {
                        HStack(spacing: 10) {
                            iconBadge(name: "eye.fill", color: .gray)
                            Text(preferences.tr("Hiện ký tự khoảng trắng ẩn", "Show Invisible Characters"))
                                .font(.system(size: 13.5))
                        }
                    }
                }

                // MARK: - 7. Live Server & Safari
                Section(preferences.tr("Live Server (:5500) & Xem Trên Safari", "Live Server (:5500) & Safari Preview")) {
                    Toggle(isOn: $preferences.keepServerInBackground) {
                        HStack(spacing: 10) {
                            iconBadge(name: "network", color: .green)
                            Text(preferences.tr("Giữ localhost:5500 chạy ngầm cho Safari", "Keep localhost:5500 Alive in Background"))
                                .font(.system(size: 13.5))
                        }
                    }
                    .onChange(of: preferences.keepServerInBackground) { enabled in
                        liveServer.updateBackgroundKeepAlive(enabled: enabled)
                    }

                    Text(preferences.tr(
                        "Khi bật, bạn có thể viết HTML/CSS/JS trong Visual IDE rồi chuyển sang Safari mở http://localhost:\(liveServer.port) mà máy chủ không bị đóng băng.",
                        "When enabled, you can edit HTML/CSS/JS in Visual IDE and switch to Safari at http://localhost:\(liveServer.port) without iOS suspending the server."
                    ))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }

                // MARK: - 8. On-Device Background Terminal & Bot Runner
                Section(preferences.tr(
                    "Terminal & Treo Bot Chạy Ngầm 24/7 (Trên Máy)",
                    "On-Device 24/7 Background Terminal & Bot Runner"
                )) {
                    Toggle(isOn: $daemonService.keepTerminalAliveInBackground) {
                        HStack(spacing: 10) {
                            iconBadge(name: "bolt.shield.fill", color: .mint)
                            Text(preferences.tr(
                                "Giữ Terminal & Bot chạy ngầm khi tắt màn hình",
                                "Keep Terminal & Bots Alive When Screen Off"
                            ))
                            .font(.system(size: 13.5))
                        }
                    }

                    Toggle(isOn: $daemonService.autoRestartOnError) {
                        HStack(spacing: 10) {
                            iconBadge(name: "arrow.counterclockwise.circle.fill", color: .orange)
                            Text(preferences.tr(
                                "Tự khởi động lại Bot nếu gặp lỗi / rớt mạng",
                                "Auto-Restart Bot on Error / Network Drop"
                            ))
                            .font(.system(size: 13.5))
                        }
                    }

                    Toggle(isOn: $daemonService.preventScreenSleep) {
                        HStack(spacing: 10) {
                            iconBadge(name: "sun.max.fill", color: .yellow)
                            Text(preferences.tr(
                                "Chống tự tắt màn hình khi đang mở Visual IDE",
                                "Prevent Screen Auto-Lock While Open"
                            ))
                            .font(.system(size: 13.5))
                        }
                    }

                    Button {
                        pendingDismissAction = onOpenDaemonManager
                        dismiss()
                    } label: {
                        HStack {
                            HStack(spacing: 10) {
                                iconBadge(name: "cpu.fill", color: .purple)
                                Text(preferences.tr("Quản lý Bot Telegram & Tiến trình Ngầm", "Manage Telegram Bots & Background Jobs"))
                                    .font(.system(size: 13.5, weight: .semibold))
                            }
                            Spacer()
                            Text("\(daemonService.runningJobsCount)")
                                .font(.caption.monospacedDigit().weight(.bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(daemonService.runningJobsCount > 0 ? Color.green.opacity(0.2) : Color.secondary.opacity(0.15))
                                .foregroundColor(daemonService.runningJobsCount > 0 ? .green : .secondary)
                                .clipShape(Capsule())
                        }
                    }
                }

                // MARK: - 9. Zero-Config Compiler & VPS
                Section(preferences.tr("Zero-Config Compiler & Kết nối VPS Riêng", "Zero-Config Compiler & Private VPS Runner")) {
                    HStack(spacing: 10) {
                        iconBadge(name: "server.rack", color: .gray)
                        TextField(preferences.tr("URL Runner trên VPS (Tùy chọn)", "VPS Runner URL (Optional)"), text: $runner.vpsEndpointURL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .font(.system(size: 13.5))
                    }

                    HStack(spacing: 10) {
                        iconBadge(name: "key.fill", color: .orange)
                        SecureField(preferences.tr("VPS Bearer Token (Tùy chọn)", "VPS Bearer Token (Optional)"), text: $runner.vpsAuthToken)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .font(.system(size: 13.5))
                    }

                    Button {
                        UIPasteboard.general.string = CodeRunnerService.vpsBootstrapCommand
                        copiedBanner = true
                    } label: {
                        HStack(spacing: 10) {
                            iconBadge(name: copiedBanner ? "checkmark.circle.fill" : "doc.on.doc.fill", color: copiedBanner ? .green : .blue)
                            Text(copiedBanner
                                ? preferences.tr("Đã copy lệnh cài Toolchain VPS!", "Copied VPS Toolchain Setup Command!")
                                : preferences.tr("Copy lệnh 1-Click cài C++/Python/Node cho VPS", "Copy 1-Click C++/Python/Node VPS Setup Command")
                            )
                            .font(.system(size: 13.5, weight: .medium))
                        }
                    }

                    Text(preferences.tr(
                        "Mặc định nếu để trống VPS, Visual IDE tự biên dịch & chạy ngay C, C++20, Python, Swift, JS bằng Zero-Config Sandbox.",
                        "Without a VPS configured, Visual IDE compiles and runs C, C++20, Python, Swift, and JS immediately via Zero-Config Sandbox."
                    ))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }

                // MARK: - 10. Hardware Keyboard Shortcuts Reference
                Section(preferences.tr("Phím Tắt Bàn Phím Bluetooth / Magic Keyboard", "Hardware Keyboard Shortcuts")) {
                    shortcutRow("Cmd + S", preferences.tr("Lưu file & tự động Format", "Save & Auto-Format"))
                    shortcutRow("Cmd + Shift + F", preferences.tr("Format Code theo ngôn ngữ hiện tại", "Format Document"))
                    shortcutRow("Cmd + R", preferences.tr("Chạy file hiện tại (Smart Run 30+ ngôn ngữ)", "Smart Run Active File"))
                    shortcutRow("Cmd + P", preferences.tr("Mở Command Palette & tìm nhanh file", "Quick Open & Command Palette"))
                    shortcutRow("Cmd + /", preferences.tr("Bật/tắt chú thích dòng (Toggle Comment)", "Toggle Line Comment"))
                    shortcutRow("Cmd + B", preferences.tr("Đóng/mở thanh Explorer bên trái", "Toggle Explorer Sidebar"))
                    shortcutRow("Cmd + I", preferences.tr("Đóng/mở khung Coding Agent", "Toggle Coding Agent Panel"))
                    shortcutRow("Cmd + J", preferences.tr("Đóng/mở bảng Terminal / Problems / Web F12", "Toggle Terminal / Problems"))
                }
            }
            .navigationTitle(preferences.tr(
                "Cài đặt Visual IDE",
                "Visual IDE Settings",
                zh: "Visual IDE 设置",
                ja: "Visual IDE 設定",
                ko: "Visual IDE 설정",
                ru: "Настройки Visual IDE",
                es: "Ajustes de Visual IDE"
            ))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(preferences.tr("Đóng", "Done", zh: "关闭", ja: "閉じる", ko: "닫기", ru: "Готово", es: "Cerrar")) { dismiss() }
                        .font(.body.weight(.semibold))
                }
            }
            .sheet(isPresented: $showThemeStudio) {
                ThemeStudioEditorSheet(preferences: preferences)
            }
            .onDisappear {
                guard let action = pendingDismissAction else { return }
                pendingDismissAction = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    action()
                }
            }
        }
    }

    // MARK: - Helper UI Builders
    @ViewBuilder
    private func iconBadge(name: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 28, height: 28)
            Image(systemName: name)
                .font(.system(size: 13.5, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    @ViewBuilder
    private func badgePill(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    @ViewBuilder
    private func authorInfoCardRow(icon: String, iconColor: Color, label: String, value: String, monospaced: Bool = false) -> some View {
        HStack(spacing: 10) {
            iconBadge(name: icon, color: iconColor)
            Text(label)
                .font(.system(size: 13.5))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(monospaced ? .system(size: 13, weight: .semibold, design: .monospaced) : .system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
                .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private func themePreviewCard(_ theme: IDEColorPalette) -> some View {
        let isSelected = (preferences.selectedThemeID == theme.id)
        Button {
            preferences.selectedThemeID = theme.id
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Circle().fill(Color(hex: theme.keyword)).frame(width: 8, height: 8)
                    Circle().fill(Color(hex: theme.function)).frame(width: 8, height: 8)
                    Circle().fill(Color(hex: theme.string)).frame(width: 8, height: 8)
                    Circle().fill(Color(hex: theme.number)).frame(width: 8, height: 8)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: theme.accent))
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 0) {
                        Text("fn ")
                            .foregroundColor(Color(hex: theme.keyword))
                        Text("main")
                            .foregroundColor(Color(hex: theme.function))
                        Text("()")
                            .foregroundColor(Color(hex: theme.foreground))
                    }
                    Text("\"Visual IDE\"")
                        .foregroundColor(Color(hex: theme.string))
                }
                .font(.system(size: 10.5, design: .monospaced))

                Text(theme.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: theme.foreground))
                    .lineLimit(1)
            }
            .padding(9)
            .frame(width: 132, alignment: .leading)
            .background(Color(hex: theme.editorBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color(hex: theme.accent) : Color.secondary.opacity(0.28), lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func shortcutRow(_ keys: String, _ desc: String) -> some View {
        HStack {
            Text(desc)
                .font(.system(size: 13))
            Spacer()
            Text(keys)
                .font(.system(size: 11.5, weight: .semibold, design: .monospaced))
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(5)
        }
    }
}
