import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin

struct SettingsView: View {
    private var viewModel: ClipboardViewModel? { AppDelegate.shared.clipboardVM }
    @AppStorage("maxHistory") private var maxHistory: Int = Constants.defaultMaxHistory
    @State private var showingClearConfirmation = false
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("通用").tag(0)
                Text("关于").tag(1)
            }
            .pickerStyle(.segmented)
            .frame(width: 180)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()

            ZStack {
                generalTab
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 0)

                aboutTab
                    .opacity(selectedTab == 1 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 1)
            }
        }
        .frame(width: 420, height: 300)
    }

    // MARK: - General Tab

    private var generalTab: some View {
        ScrollView {
            VStack(spacing: 0) {
                sectionSpacer

                SettingsGroup {
                    SettingsRow(
                        icon: "power",
                        color: .gray,
                        label: Strings.settingsLaunchAtLogin
                    ) {
                        Toggle("", isOn: Binding(
                            get: { LaunchAtLogin.isEnabled },
                            set: { LaunchAtLogin.isEnabled = $0 }
                        ))
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .scaleEffect(0.85)
                        .frame(width: 40, alignment: .trailing)
                    }

                    SettingsSeparator()

                    SettingsRow(
                        icon: "command",
                        color: Color(red: 0.25, green: 0.47, blue: 0.96),
                        label: Strings.settingsGlobalShortcut
                    ) {
                        KeyboardShortcuts.Recorder(for: .toggleClipboardPanel)
                            .fixedSize()
                    }
                }

                sectionSpacer

                SettingsGroup {
                    SettingsRow(
                        icon: "list.number",
                        color: Color(red: 0.20, green: 0.78, blue: 0.35),
                        label: Strings.settingsMaxItems
                    ) {
                        HStack(spacing: 8) {
                            CustomSlider(
                                value: Binding(
                                    get: { Double(maxHistory) },
                                    set: { maxHistory = Int($0) }
                                ),
                                range: Double(Constants.minHistory)...Double(Constants.maxHistory),
                                step: 1
                            )
                            .frame(width: 100)

                            Text("\(maxHistory)")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .frame(width: 30, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }

                    SettingsSeparator()

                    SettingsRow(
                        icon: "trash",
                        color: .red,
                        label: Strings.settingsClearAll
                    ) {
                        Button {
                            showingClearConfirmation = true
                        } label: {
                            Text("清除...")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.red.opacity(0.85))
                                )
                        }
                        .buttonStyle(.plain)
                        .alert(Strings.settingsClearConfirm, isPresented: $showingClearConfirmation) {
                            Button(Strings.settingsClearCancel, role: .cancel) {}
                            Button(Strings.settingsClearConfirmButton, role: .destructive) {
                                viewModel?.clearHistory()
                            }
                        } message: {
                            Text(Strings.settingsClearUndone)
                        }
                    }
                }

                sectionSpacer
            }
            .padding(.horizontal, 16)
        }
        .background(bgColor)
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                if let icon = NSImage(named: "AppIcon") {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                VStack(spacing: 2) {
                    Text(Constants.appName)
                        .font(.system(size: 15, weight: .medium))
                    Text("版本 \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0")")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Button(Strings.settingsCheckUpdates) {
                    UpdaterController().checkForUpdates()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(bgColor)
    }

    // MARK: - Helpers

    private var bgColor: Color {
        Color(red: 0.973, green: 0.973, blue: 0.973)
    }

    private var sectionSpacer: some View {
        Color.clear
            .frame(height: 1)
            .padding(.vertical, 10)
    }
}

// MARK: - Reusable Components

private struct SettingsGroup<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct SettingsRow<Content: View>: View {
    let icon: String
    let color: Color
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 10) {
            SettingsIcon(systemName: icon, color: color)

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            content
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

private struct SettingsIcon: View {
    let systemName: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(color)
                .frame(width: 22, height: 22)

            Image(systemName: systemName)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

private struct SettingsSeparator: View {
    var body: some View {
        Divider()
            .padding(.leading, 50)
    }
}

private struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double

    @State private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track background — always light gray
                Capsule()
                    .fill(Color(red: 0.82, green: 0.82, blue: 0.84))
                    .frame(height: 4)

                // Filled portion
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: filledWidth(in: geometry), height: 4)

                // Thumb
                Circle()
                    .fill(.white)
                    .frame(width: 13, height: 13)
                    .shadow(color: .black.opacity(isDragging ? 0.2 : 0.12), radius: 2, x: 0, y: 1)
                    .offset(x: thumbOffset(in: geometry))
            }
            .frame(height: 20, alignment: .center)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        isDragging = true
                        updateValue(from: gesture.location.x, in: geometry)
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
        }
    }

    private func filledWidth(in geometry: GeometryProxy) -> CGFloat {
        let ratio = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return geometry.size.width * CGFloat(ratio)
    }

    private func thumbOffset(in geometry: GeometryProxy) -> CGFloat {
        let ratio = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return geometry.size.width * CGFloat(ratio) - 6.5
    }

    private func updateValue(from x: CGFloat, in geometry: GeometryProxy) {
        let ratio = max(0, min(1, x / geometry.size.width))
        let raw = range.lowerBound + (range.upperBound - range.lowerBound) * Double(ratio)
        let stepped = round((raw - range.lowerBound) / step) * step + range.lowerBound
        value = min(range.upperBound, max(range.lowerBound, stepped))
    }
}
