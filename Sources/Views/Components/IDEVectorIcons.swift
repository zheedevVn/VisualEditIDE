import Foundation
import SwiftUI

// MARK: - Inline Label Style & Aligned Form / List Action Buttons

public struct IDEInlineLabelStyle: LabelStyle {
    public var spacing: CGFloat

    public init(spacing: CGFloat = 5) {
        self.spacing = spacing
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}

public enum IDEButtonProminence {
    case prominent
    case secondary
    case destructive
}

public struct IDEActionButton<LabelContent: View>: View {
    private let prominence: IDEButtonProminence
    private let tint: Color
    private let fullWidth: Bool
    private let compact: Bool
    private let action: () -> Void
    private let label: () -> LabelContent

    @Environment(\.isEnabled) private var isEnabled

    public init(
        prominence: IDEButtonProminence = .prominent,
        tint: Color = .accentColor,
        fullWidth: Bool = true,
        compact: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> LabelContent
    ) {
        self.prominence = prominence
        self.tint = tint
        self.fullWidth = fullWidth
        self.compact = compact
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                label()
            }
            .labelStyle(IDEInlineLabelStyle(spacing: compact ? 5 : 6))
            .font(.system(size: compact ? 12.5 : 13.5, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.84)
            .foregroundColor(foreground)
            .frame(maxWidth: fullWidth ? .infinity : nil, alignment: .center)
            .padding(.horizontal, compact ? 12 : 14)
            .padding(.vertical, compact ? 8 : 10)
            .background(
                RoundedRectangle(cornerRadius: compact ? 8 : 10, style: .continuous)
                    .fill(backgroundFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: compact ? 8 : 10, style: .continuous)
                    .stroke(borderStroke, lineWidth: 0.75)
            )
            .contentShape(RoundedRectangle(cornerRadius: compact ? 8 : 10, style: .continuous))
            .opacity(isEnabled ? 1.0 : 0.45)
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        switch prominence {
        case .prominent: return .white
        case .secondary: return tint
        case .destructive: return .red
        }
    }

    private var backgroundFill: Color {
        switch prominence {
        case .prominent: return tint
        case .secondary: return tint.opacity(0.13)
        case .destructive: return Color.red.opacity(0.13)
        }
    }

    private var borderStroke: Color {
        switch prominence {
        case .prominent: return tint.opacity(0.2)
        case .secondary: return tint.opacity(0.24)
        case .destructive: return Color.red.opacity(0.28)
        }
    }
}

public struct IDEPillButton<LabelContent: View>: View {
    private let prominence: IDEButtonProminence
    private let tint: Color
    private let action: () -> Void
    private let label: () -> LabelContent

    @Environment(\.isEnabled) private var isEnabled

    public init(
        prominence: IDEButtonProminence = .prominent,
        tint: Color = .accentColor,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> LabelContent
    ) {
        self.prominence = prominence
        self.tint = tint
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                label()
            }
            .labelStyle(IDEInlineLabelStyle(spacing: 5))
            .font(.system(size: 12, weight: .semibold))
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .foregroundColor(foreground)
            .padding(.horizontal, 12)
            .padding(.vertical, 6.5)
            .background(Capsule(style: .continuous).fill(backgroundFill))
            .overlay(Capsule(style: .continuous).stroke(borderStroke, lineWidth: 0.75))
            .contentShape(Capsule(style: .continuous))
            .opacity(isEnabled ? 1.0 : 0.45)
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        switch prominence {
        case .prominent: return .white
        case .secondary: return tint
        case .destructive: return .red
        }
    }

    private var backgroundFill: Color {
        switch prominence {
        case .prominent: return tint
        case .secondary: return tint.opacity(0.13)
        case .destructive: return Color.red.opacity(0.13)
        }
    }

    private var borderStroke: Color {
        switch prominence {
        case .prominent: return Color.clear
        case .secondary: return tint.opacity(0.24)
        case .destructive: return Color.red.opacity(0.28)
        }
    }
}

/// Bespoke 120Hz vector brand mark (`30` / `12` with Programmer's Slashed Zero & Active Gutter Rail)
/// matching the iOS Home Screen AppIcon on an exact 1024-unit architectural grid.
public struct IDECodeMarkVector: View {
    public var size: CGFloat = 22
    public var primaryColor: Color = Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255) // #10B981 Terminal Emerald
    public var slashColor: Color = Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255)
    public var secondaryColor: Color = Color(red: 241 / 255, green: 245 / 255, blue: 249 / 255) // #F1F5F9 Titanium Chalk
    public var showTileBackground: Bool = true

    public init(
        size: CGFloat = 22,
        primaryColor: Color = Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255),
        slashColor: Color = Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255),
        secondaryColor: Color = Color(red: 241 / 255, green: 245 / 255, blue: 249 / 255),
        showTileBackground: Bool = true
    ) {
        self.size = size
        self.primaryColor = primaryColor
        self.slashColor = slashColor
        self.secondaryColor = secondaryColor
        self.showTileBackground = showTileBackground
    }

    public var body: some View {
        Canvas { context, canvasSize in
            let side = min(canvasSize.width, canvasSize.height)
            let u = side / 1024.0
            let tileRect = CGRect(x: 0, y: 0, width: side, height: side)
            let pt = { (x: CGFloat, y: CGFloat) in CGPoint(x: x * u, y: y * u) }

            var drawCtx = context
            if showTileBackground {
                let squircle = RoundedRectangle(cornerRadius: 228 * u, style: .continuous).path(in: tileRect)
                drawCtx.clip(to: squircle)

                let bgTop = Color(red: 20 / 255, green: 26 / 255, blue: 34 / 255) // #141A22 Anodized Carbon
                let bgBot = Color(red: 10 / 255, green: 13 / 255, blue: 18 / 255) // #0A0D12 Deep Obsidian
                drawCtx.fill(
                    squircle,
                    with: .linearGradient(
                        Gradient(colors: [bgTop, bgBot]),
                        startPoint: CGPoint(x: side * 0.5, y: 0),
                        endPoint: CGPoint(x: side * 0.5, y: side)
                    )
                )

                // Ambient Center Radial Core Glow
                let glowCircle = Circle().path(in: CGRect(x: 160 * u, y: 160 * u, width: 704 * u, height: 704 * u))
                drawCtx.fill(glowCircle, with: .color(Color(red: 0 / 255, green: 210 / 255, blue: 255 / 255).opacity(0.12)))
            }

            // 2. V-Monogram Ribbon of Visual IDE
            let vStrokeWidth = (size < 28 ? 96 : 84) * u
            var leftWing = Path()
            leftWing.move(to: pt(230, 240))
            leftWing.addLine(to: pt(512, 800))
            drawCtx.stroke(
                leftWing,
                with: .color(Color(red: 2 / 255, green: 132 / 255, blue: 199 / 255)),
                style: StrokeStyle(lineWidth: vStrokeWidth, lineCap: .round, lineJoin: .round)
            )

            var rightWing = Path()
            rightWing.move(to: pt(794, 240))
            rightWing.addLine(to: pt(512, 800))
            drawCtx.stroke(
                rightWing,
                with: .color(slashColor),
                style: StrokeStyle(lineWidth: vStrokeWidth, lineCap: .round, lineJoin: .round)
            )

            // Overlap Vertex Joint
            let vertexRect = CGRect(x: (512 - 42) * u, y: (800 - 42) * u, width: 84 * u, height: 84 * u)
            drawCtx.fill(Circle().path(in: vertexRect), with: .color(slashColor))

            // 3. Inner Code Core: < / > Bracket Glyph
            let codeStroke = StrokeStyle(
                lineWidth: (size < 28 ? 50 : 42) * u,
                lineCap: .round,
                lineJoin: .round
            )

            var leftChevron = Path()
            leftChevron.move(to: pt(420, 380))
            leftChevron.addLine(to: pt(330, 460))
            leftChevron.addLine(to: pt(420, 540))
            drawCtx.stroke(leftChevron, with: .color(Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255)), style: codeStroke)

            var slashLine = Path()
            slashLine.move(to: pt(540, 360))
            slashLine.addLine(to: pt(484, 560))
            drawCtx.stroke(slashLine, with: .color(Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255)), style: codeStroke)

            var rightChevron = Path()
            rightChevron.move(to: pt(604, 380))
            rightChevron.addLine(to: pt(694, 460))
            rightChevron.addLine(to: pt(604, 540))
            drawCtx.stroke(rightChevron, with: .color(Color(red: 52 / 255, green: 211 / 255, blue: 153 / 255)), style: codeStroke)

            // 4. Machined Inner Rim Border
            if showTileBackground {
                let borderInset = max(0.5, 5 * u)
                let borderRect = tileRect.insetBy(dx: borderInset, dy: borderInset)
                let borderPath = RoundedRectangle(cornerRadius: 223 * u, style: .continuous).path(in: borderRect)
                drawCtx.stroke(
                    borderPath,
                    with: .color(Color(red: 48 / 255, green: 62 / 255, blue: 82 / 255)),
                    lineWidth: max(0.8, 10 * u)
                )
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// Single-line horizontal `VisualIDE_` developer wordmark (heavy monospaced set with emerald terminal block cursor).
public struct BrandVisualIDEWordmarkView: View {
    public var height: CGFloat = 28
    public var inkColor: Color = .primary
    public var accentColor: Color = Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255)

    public init(
        height: CGFloat = 28,
        inkColor: Color = .primary,
        accentColor: Color = Color(red: 16 / 255, green: 185 / 255, blue: 129 / 255)
    ) {
        self.height = height
        self.inkColor = inkColor
        self.accentColor = accentColor
    }

    public var body: some View {
        let cursorWidth = height * 0.36
        let cursorHeight = height * 0.13

        HStack(alignment: .firstTextBaseline, spacing: height * 0.09) {
            Text("Visual IDE")
                .font(.system(size: height * 0.80, weight: .heavy, design: .monospaced))
                .tracking(-height * 0.014)
                .foregroundColor(inkColor)
                .lineLimit(1)
                .minimumScaleFactor(0.55)

            // Terminal Emerald Underscore Cursor, sitting on the text baseline
            RoundedRectangle(cornerRadius: cursorHeight * 0.3, style: .continuous)
                .fill(accentColor)
                .frame(width: cursorWidth, height: cursorHeight)
                .alignmentGuide(.firstTextBaseline) { $0[.bottom] }
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Visual IDE")
    }
}

/// VS Code Seti-style language & filename icon renderer across all supported languages and special dev files (`.x`, `.xm`, `.h`, `Makefile`, `control`, `.deb`, `.ipa`, etc.).
public struct FileLanguageIconView: View {
    public let language: CodeLanguage
    public let fileName: String?
    public var size: CGFloat = 12

    public init(language: CodeLanguage, fileName: String? = nil, size: CGFloat = 12) {
        self.language = language
        self.fileName = fileName
        self.size = size
    }

    private enum IconGlyph {
        case monogram(String, Color)
        case symbol(String, Color)
    }

    public var body: some View {
        let frameSide = size + 5
        Group {
            switch resolvedGlyph() {
            case .monogram(let text, let color):
                Text(text)
                    .font(.system(size: max(8, size * (text.count >= 3 ? 0.68 : (text.count == 2 ? 0.78 : 0.94))), weight: .heavy, design: .rounded))
                    .foregroundColor(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.45)
            case .symbol(let symbolName, let color):
                Image(systemName: symbolName)
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: size, weight: .semibold))
                    .foregroundColor(color)
            }
        }
        .frame(width: frameSide, height: frameSide, alignment: .center)
    }

    private func resolvedGlyph() -> IconGlyph {
        if let rawName = fileName?.trimmingCharacters(in: .whitespacesAndNewlines), !rawName.isEmpty {
            let lowerName = (rawName as NSString).lastPathComponent.lowercased()
            let ext = (lowerName as NSString).pathExtension

            // Special exact filenames (VS Code Seti style)
            if lowerName == "makefile" || lowerName == "gnumakefile" {
                return .symbol("hammer.fill", Color(red: 0.89, green: 0.48, blue: 0.22))
            }
            if lowerName == "control" {
                return .symbol("shippingbox.fill", Color(red: 0.92, green: 0.54, blue: 0.22))
            }
            if lowerName == "dockerfile" || lowerName.hasPrefix("dockerfile.") {
                return .symbol("shippingbox.fill", Color(red: 0.22, green: 0.72, blue: 0.95))
            }
            if lowerName == "package.swift" {
                return .symbol("swift", Color(red: 0.97, green: 0.45, blue: 0.15))
            }
            if lowerName == "package.json" || lowerName == "package-lock.json" || lowerName == "tsconfig.json" {
                return .monogram("{}", Color(red: 0.94, green: 0.76, blue: 0.24))
            }
            if lowerName == "cmakelists.txt" {
                return .monogram("CM", Color(red: 0.22, green: 0.82, blue: 0.62))
            }
            if lowerName == ".gitignore" || lowerName == ".gitattributes" || lowerName == ".gitmodules" {
                return .symbol("arrow.triangle.branch", Color(red: 0.95, green: 0.34, blue: 0.22))
            }
            if lowerName == ".env" || lowerName.hasPrefix(".env.") {
                return .symbol("key.fill", Color(red: 0.96, green: 0.74, blue: 0.20))
            }
            if lowerName == "xtool.yml" || lowerName == "project.yml" {
                return .symbol("wrench.and.screwdriver.fill", Color(red: 0.76, green: 0.48, blue: 0.98))
            }

            // Extension-specific VS Code overrides (especially Tweaks, Headers, Archives & Binaries)
            switch ext {
            case "x", "xi":
                return .monogram(".x", Color(red: 0.76, green: 0.42, blue: 0.98))
            case "xm", "xmi":
                return .monogram("xm", Color(red: 0.88, green: 0.40, blue: 0.96))
            case "h":
                return .monogram("H", Color(red: 0.64, green: 0.46, blue: 0.88))
            case "hpp", "hh", "hxx":
                return .monogram("H+", Color(red: 0.64, green: 0.46, blue: 0.88))
            case "m":
                return .monogram("M", Color(red: 0.34, green: 0.66, blue: 0.98))
            case "mm":
                return .monogram("M+", Color(red: 0.46, green: 0.56, blue: 0.98))
            case "c":
                return .monogram("C", Color(red: 0.32, green: 0.64, blue: 0.96))
            case "cpp", "cc", "cxx":
                return .monogram("C++", Color(red: 0.32, green: 0.64, blue: 0.96))
            case "jsx":
                return .symbol("atom", Color(red: 0.96, green: 0.78, blue: 0.22))
            case "tsx":
                return .symbol("atom", Color(red: 0.24, green: 0.72, blue: 0.98))
            case "plist", "entitlements":
                return .symbol("checklist", Color(red: 0.95, green: 0.55, blue: 0.24))
            case "svg":
                return .symbol("circle.square.fill", Color(red: 0.98, green: 0.72, blue: 0.20))
            case "deb", "ipa", "apk":
                return .symbol("shippingbox.fill", Color(red: 0.26, green: 0.82, blue: 0.52))
            case "dylib", "so", "a", "framework":
                return .symbol("cpu.fill", Color(red: 0.56, green: 0.64, blue: 0.98))
            case "zip", "tar", "gz", "7z", "rar":
                return .symbol("doc.zipper", Color(red: 0.82, green: 0.62, blue: 0.36))
            case "png", "jpg", "jpeg", "gif", "webp", "ico":
                return .symbol("photo.fill", Color(red: 0.64, green: 0.48, blue: 0.94))
            case "log":
                return .symbol("doc.text.magnifyingglass", Color(red: 0.58, green: 0.64, blue: 0.72))
            default:
                break
            }
        }

        // Language-level VS Code Seti icons
        switch language {
        case .html:
            return .monogram("<>", Color(red: 0.94, green: 0.40, blue: 0.18))
        case .css:
            return .monogram("#", Color(red: 0.26, green: 0.66, blue: 0.96))
        case .scss:
            return .monogram("S", Color(red: 0.92, green: 0.35, blue: 0.62))
        case .javascript:
            return .monogram("JS", Color(red: 0.96, green: 0.80, blue: 0.20))
        case .typescript:
            return .monogram("TS", Color(red: 0.24, green: 0.56, blue: 0.96))
        case .tsx:
            return .symbol("atom", Color(red: 0.24, green: 0.74, blue: 0.98))
        case .vue:
            return .monogram("V", Color(red: 0.26, green: 0.74, blue: 0.52))
        case .svelte:
            return .monogram("S", Color(red: 0.98, green: 0.34, blue: 0.14))
        case .astro:
            return .monogram("As", Color(red: 0.98, green: 0.42, blue: 0.24))
        case .graphql:
            return .monogram("GQ", Color(red: 0.90, green: 0.30, blue: 0.64))
        case .c:
            return .monogram("C", Color(red: 0.32, green: 0.64, blue: 0.96))
        case .cpp:
            return .monogram("C++", Color(red: 0.32, green: 0.64, blue: 0.96))
        case .objectiveC:
            return .monogram("M", Color(red: 0.34, green: 0.66, blue: 0.98))
        case .rust:
            return .symbol("gearshape.2.fill", Color(red: 0.90, green: 0.48, blue: 0.28))
        case .go:
            return .monogram("Go", Color(red: 0.00, green: 0.74, blue: 0.88))
        case .zig:
            return .monogram("Z", Color(red: 0.96, green: 0.68, blue: 0.16))
        case .dlang:
            return .monogram("D", Color(red: 0.84, green: 0.32, blue: 0.30))
        case .nim:
            return .monogram("Nm", Color(red: 0.96, green: 0.76, blue: 0.22))
        case .crystal:
            return .symbol("diamond", Color(red: 0.74, green: 0.82, blue: 0.94))
        case .assembly:
            return .symbol("cpu", Color(red: 0.52, green: 0.58, blue: 0.96))
        case .swift:
            return .symbol("swift", Color(red: 0.97, green: 0.45, blue: 0.15))
        case .dart:
            return .monogram("D", Color(red: 0.08, green: 0.74, blue: 0.82))
        case .java:
            return .symbol("cup.and.saucer.fill", Color(red: 0.92, green: 0.34, blue: 0.28))
        case .kotlin:
            return .monogram("K", Color(red: 0.64, green: 0.38, blue: 0.98))
        case .scala:
            return .monogram("Sc", Color(red: 0.90, green: 0.30, blue: 0.28))
        case .groovy:
            return .monogram("Gv", Color(red: 0.38, green: 0.64, blue: 0.86))
        case .csharp:
            return .monogram("C#", Color(red: 0.48, green: 0.76, blue: 0.38))
        case .python:
            return .monogram("PY", Color(red: 0.32, green: 0.66, blue: 0.96))
        case .php:
            return .monogram("php", Color(red: 0.56, green: 0.48, blue: 0.94))
        case .ruby:
            return .symbol("diamond.fill", Color(red: 0.88, green: 0.25, blue: 0.33))
        case .perl:
            return .monogram("Pl", Color(red: 0.34, green: 0.62, blue: 0.86))
        case .lua:
            return .symbol("moon.circle.fill", Color(red: 0.30, green: 0.54, blue: 0.96))
        case .r:
            return .monogram("R", Color(red: 0.26, green: 0.56, blue: 0.92))
        case .julia:
            return .symbol("circle.grid.2x2.fill", Color(red: 0.62, green: 0.42, blue: 0.92))
        case .elixir:
            return .symbol("drop.fill", Color(red: 0.64, green: 0.40, blue: 0.92))
        case .erlang:
            return .monogram("e", Color(red: 0.84, green: 0.24, blue: 0.36))
        case .haskell:
            return .monogram("λ", Color(red: 0.62, green: 0.44, blue: 0.92))
        case .ocaml:
            return .monogram("Ml", Color(red: 0.94, green: 0.56, blue: 0.20))
        case .elm:
            return .monogram("El", Color(red: 0.36, green: 0.72, blue: 0.88))
        case .lisp:
            return .monogram("()", Color(red: 0.78, green: 0.54, blue: 0.92))
        case .pascal:
            return .monogram("Ps", Color(red: 0.34, green: 0.64, blue: 0.92))
        case .solidity:
            return .symbol("hexagon.fill", Color(red: 0.56, green: 0.64, blue: 0.82))
        case .sql:
            return .symbol("cylinder.split.1x2.fill", Color(red: 0.26, green: 0.72, blue: 0.92))
        case .json, .json5:
            return .monogram("{}", Color(red: 0.95, green: 0.76, blue: 0.20))
        case .yaml:
            return .monogram("Y!", Color(red: 0.92, green: 0.34, blue: 0.58))
        case .toml:
            return .monogram("T", Color(red: 0.86, green: 0.48, blue: 0.26))
        case .xml:
            return .monogram("</>", Color(red: 0.94, green: 0.52, blue: 0.20))
        case .protobuf:
            return .monogram("Pb", Color(red: 0.44, green: 0.72, blue: 0.94))
        case .ini:
            return .symbol("slider.horizontal.3", Color(red: 0.64, green: 0.70, blue: 0.78))
        case .shell, .fish:
            return .monogram("$_", Color(red: 0.30, green: 0.84, blue: 0.52))
        case .powershell:
            return .monogram(">_", Color(red: 0.32, green: 0.66, blue: 0.96))
        case .dockerfile:
            return .symbol("shippingbox.fill", Color(red: 0.22, green: 0.72, blue: 0.95))
        case .makefile:
            return .symbol("hammer.fill", Color(red: 0.89, green: 0.48, blue: 0.22))
        case .cmake:
            return .monogram("CM", Color(red: 0.22, green: 0.82, blue: 0.62))
        case .hcl, .bicep:
            return .monogram("TF", Color(red: 0.64, green: 0.42, blue: 0.96))
        case .nix:
            return .symbol("snowflake", Color(red: 0.42, green: 0.70, blue: 0.98))
        case .markdown:
            return .monogram("M↓", Color(red: 0.32, green: 0.68, blue: 0.96))
        case .latex:
            return .monogram("Te", Color(red: 0.22, green: 0.76, blue: 0.64))
        case .regex:
            return .monogram(".*", Color(red: 0.88, green: 0.54, blue: 0.28))
        case .diff:
            return .symbol("slash.circle", Color(red: 0.48, green: 0.82, blue: 0.56))
        case .plainText:
            return .symbol("doc.text", Color(red: 0.60, green: 0.66, blue: 0.74))
        }
    }
}

public typealias BrandNexusKingWordmarkView = BrandVisualIDEWordmarkView
