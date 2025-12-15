//
//  LookupView.swift
//  SOC
//
//  Enhanced version with validation, auto-detection, and history
//

import SwiftUI
import AppKit

struct LookupView: View {
    @ObservedObject var popoverState: PopoverState
    @ObservedObject private var localization = LocalizationManager.shared
    @ObservedObject private var historyManager = SearchHistoryManager.shared
    @ObservedObject private var serviceManager = ServiceManager.shared
    
    @State private var input: String = ""
    @State private var openInBackground = true
    @State private var prefillFromClipboard = true
    @State private var lastSearchType: String = ""
    @State private var validationResult: ValidationResult = .empty
    @State private var showingHistory = false
    @State private var isSearching = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            headerView
            
            Divider()
            
            // Input Section with Validation
            inputSection
            
            // Validation Feedback
            validationFeedback
            
            // Search Buttons
            searchButtonsSection
            
            Spacer()
            
            Divider()
            
            // Settings
            settingsSection
            
            // Footer
            footerView
        }
        .padding(20)
        .frame(width: 400, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .onChange(of: popoverState.shouldRefresh) { _ in
            loadClipboardIfNeeded()
        }
        .onChange(of: input) { newValue in
            validationResult = InputValidator.validate(newValue)
            lastSearchType = ""
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(onSelect: { record in
                input = record.value
                showingHistory = false
            })
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.title2)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(localization.getString(.appTitle))
                    .font(.headline)
                Text(localization.getString(.appSubtitle))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // History Button
            Button(action: { showingHistory = true }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Cronologia ricerche")
            
            // Settings Button
            Button(action: openServiceSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Gestione servizi")
            
            // Language Button
            Button(action: openLanguageSettings) {
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.body)
                    Text(localization.currentLanguage.flag)
                        .font(.body)
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .help("Change language / Cambia lingua")
            
            // Quit Button
            Button(action: quitApp) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help(localization.getString(.quitButton))
        }
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(localization.getString(.inputLabel))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Auto-detect badge
                if case .valid(let type) = validationResult {
                    HStack(spacing: 4) {
                        Image(systemName: "wand.and.stars")
                            .font(.caption2)
                        Text("Auto: \(type.displayName)")
                            .font(.caption2)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                }
                
                // Refresh Button
                Button(action: loadClipboardIfNeeded) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.caption)
                        Text(localization.getString(.refreshButton))
                            .font(.caption2)
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help(localization.getString(.refreshButton))
            }
            
            HStack(spacing: 8) {
                TextField(localization.getString(.inputPlaceholder), text: $input)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .onAppear {
                        loadClipboardIfNeeded()
                    }
                    .onSubmit {
                        performAutoSearch()
                    }
                
                if !input.isEmpty {
                    Button(action: { input = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help(localization.getString(.clearButton))
                }
            }
            
            if !lastSearchType.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text("\(localization.getString(.lastSearch)): \(lastSearchType)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(serviceManager.getEnabledServices(for: validationResult.detectedType ?? .ip).count) servizi")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Validation Feedback
    
    @ViewBuilder
    private var validationFeedback: some View {
        if case .invalid(let message) = validationResult, !input.isEmpty {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(6)
        }
    }
    
    // MARK: - Search Buttons
    private var searchButtonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(localization.getString(.searchTitle))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // Auto-search button
                if validationResult.isValid {
                    Button(action: performAutoSearch) {
                        HStack(spacing: 4) {
                            Image(systemName: "wand.and.stars.inverse")
                                .font(.caption)
                            Text("Auto Search")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .help("Cerca automaticamente (⏎)")
                }
            }
            
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    SearchButton(
                        title: localization.getString(.ipButton),
                        icon: "network",
                        color: .blue,
                        isEnabled: validationResult.isValid || input.isEmpty,
                        serviceCount: serviceManager.getEnabledServices(for: .ip).count
                    ) {
                        performSearch(type: .ip, name: "IP")
                    }
                    
                    SearchButton(
                        title: localization.getString(.domainButton),
                        icon: "globe",
                        color: .green,
                        isEnabled: validationResult.isValid || input.isEmpty,
                        serviceCount: serviceManager.getEnabledServices(for: .domain).count
                    ) {
                        performSearch(type: .domain, name: "FQDN")
                    }
                }
                
                HStack(spacing: 8) {
                    SearchButton(
                        title: localization.getString(.shaButton),
                        icon: "number.square",
                        color: .orange,
                        isEnabled: validationResult.isValid || input.isEmpty,
                        serviceCount: serviceManager.getEnabledServices(for: .sha).count
                    ) {
                        performSearch(type: .sha, name: "SHA-256")
                    }
                    
                    SearchButton(
                        title: localization.getString(.mxButton),
                        icon: "envelope",
                        color: .purple,
                        isEnabled: validationResult.isValid || input.isEmpty,
                        serviceCount: serviceManager.getEnabledServices(for: .mail).count
                    ) {
                        performSearch(type: .mail, name: "MX Records")
                    }
                }
                
                SearchButton(
                    title: localization.getString(.asnButton),
                    icon: "building.2",
                    color: .indigo,
                    isEnabled: validationResult.isValid || input.isEmpty,
                    serviceCount: serviceManager.getEnabledServices(for: .asn).count
                ) {
                    performSearch(type: .asn, name: "ASN")
                }
            }
        }
    }
    
    // MARK: - Settings
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $openInBackground) {
                HStack(spacing: 6) {
                    Image(systemName: "safari")
                        .foregroundColor(.blue)
                    Text(localization.getString(.openBackground))
                }
            }
            .toggleStyle(.checkbox)
            
            Toggle(isOn: $prefillFromClipboard) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.on.clipboard")
                        .foregroundColor(.orange)
                    Text(localization.getString(.prefillClipboard))
                }
            }
            .toggleStyle(.checkbox)
        }
        .font(.subheadline)
    }
    
    // MARK: - Footer
    private var footerView: some View {
        HStack {
            Text(localization.getString(.footerVersion))
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(localization.getString(.footerTitle))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Functions
    
    private func loadClipboardIfNeeded() {
        guard prefillFromClipboard else { return }
        
        if let clipboardString = NSPasteboard.general.string(forType: .string) {
            let cleaned = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)
            if !cleaned.isEmpty && cleaned.count < 500 {
                if input != cleaned {
                    input = cleaned
                    lastSearchType = ""
                }
            }
        }
    }
    
    private func performAutoSearch() {
        guard let detectedType = validationResult.detectedType else { return }
        
        let typeName: String
        switch detectedType {
        case .ip: typeName = "IP"
        case .domain: typeName = "Domain"
        case .sha: typeName = "SHA-256"
        case .asn: typeName = "ASN"
        case .mail: typeName = "Email"
        }
        
        performSearch(type: detectedType, name: typeName)
    }
    
    private func performSearch(type: ArtifactType, name: String) {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        // Validate before searching
        let validation = InputValidator.validate(trimmedInput)
        guard validation.isValid else {
            // Show validation error
            NSSound.beep()
            return
        }
        
        isSearching = true
        
        let urls = Resolver.urls(for: type, value: trimmedInput, all: true)
        
        guard !urls.isEmpty else {
            // No services enabled
            NSSound.beep()
            isSearching = false
            return
        }
        
        for url in urls {
            if openInBackground {
                openURLInBackground(url)
            } else {
                NSWorkspace.shared.open(url)
            }
        }
        
        lastSearchType = name
        
        // Add to history
        historyManager.addSearch(value: trimmedInput, type: type)
        
        // Haptic feedback
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
        
        isSearching = false
    }
    
    private func openURLInBackground(_ url: URL) {
        let config = NSWorkspace.OpenConfiguration()
        config.activates = false
        
        NSWorkspace.shared.open(
            [url],
            withApplicationAt: URL(fileURLWithPath: "/Applications/Safari.app"),
            configuration: config
        ) { _, _ in }
    }
    
    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    private func openLanguageSettings() {
        let windowController = LanguageSettingsWindowController()
        windowController.showWindow(nil)
        windowController.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func openServiceSettings() {
        let windowController = ServiceSettingsWindowController()
        windowController.showWindow(nil)
        windowController.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Search Button Component

struct SearchButton: View {
    let title: String
    let icon: String
    let color: Color
    let isEnabled: Bool
    let serviceCount: Int
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.body)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(serviceCount) servizi")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isEnabled ? color.opacity(isHovering ? 0.15 : 0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isEnabled ? color.opacity(isHovering ? 0.5 : 0.3) : Color.gray.opacity(0.2),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - History View

struct HistoryView: View {
    @ObservedObject private var historyManager = SearchHistoryManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery = ""
    @State private var showExportSuccess = false
    @State private var exportMessage = ""
    
    let onSelect: (SearchRecord) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localization.getString(.historyTitle))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("\(historyManager.searches.count) \(localization.getString(.noSearches).lowercased())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField(localization.getString(.searchHistoryPlaceholder), text: $searchQuery)
                    .textFieldStyle(.plain)
                
                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // History list
            ScrollView {
                LazyVStack(spacing: 8) {
                    let filtered = historyManager.searchHistory(query: searchQuery)
                    
                    if filtered.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(filtered) { record in
                            HistoryRow(record: record) {
                                onSelect(record)
                            } onDelete: {
                                historyManager.deleteSearch(record)
                            }
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer
            HStack {
                // Export Menu
                Menu {
                    Button(localization.getString(.exportCSV)) {
                        exportCSV()
                    }
                    Button(localization.getString(.exportJSON)) {
                        exportJSON()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text(localization.getString(.exportButton))
                    }
                }
                .buttonStyle(.borderless)
                .disabled(historyManager.searches.isEmpty)
                
                Button(localization.getString(.clearAllButton)) {
                    historyManager.clearHistory()
                }
                .buttonStyle(.borderless)
                .disabled(historyManager.searches.isEmpty)
                
                Spacer()
                
                Button(localization.getString(.closeButton)) {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 500, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            // Success badge
            Group {
                if showExportSuccess {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(exportMessage)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.bottom, 20)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(searchQuery.isEmpty ? localization.getString(.noSearches) : localization.getString(.noResults))
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Export Functions
    
    private func exportCSV() {
        let csv = historyManager.exportToCSV()
        historyManager.copyToClipboard(content: csv)
        
        // Mostra badge di successo
        withAnimation {
            exportMessage = localization.getString(.csvCopied)
            showExportSuccess = true
        }
        
        // Nascondi dopo 2 secondi
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showExportSuccess = false
            }
        }
    }
    
    private func exportJSON() {
        guard let json = historyManager.exportToJSON() else {
            NSSound.beep()
            return
        }
        
        historyManager.copyToClipboard(content: json)
        
        // Mostra badge di successo
        withAnimation {
            exportMessage = localization.getString(.jsonCopied)
            showExportSuccess = true
        }
        
        // Nascondi dopo 2 secondi
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showExportSuccess = false
            }
        }
    }
}

// MARK: - History Row

struct HistoryRow: View {
    let record: SearchRecord
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Type Badge
            Text(record.displayType)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(typeColor)
                .cornerRadius(6)
            
            // Value
            VStack(alignment: .leading, spacing: 2) {
                Text(record.value)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(record.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Actions
            if isHovering {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Elimina")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovering ? Color.secondary.opacity(0.05) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        .onTapGesture {
            onSelect()
        }
    }
    
    private var typeColor: Color {
        switch record.type {
        case .ip: return .blue
        case .domain: return .green
        case .sha: return .orange
        case .asn: return .indigo
        case .mail: return .purple
        }
    }
}

// MARK: - Extensions

extension ArtifactType {
    var displayName: String {
        switch self {
        case .ip: return "IP"
        case .domain: return "Domain"
        case .sha: return "SHA-256"
        case .asn: return "ASN"
        case .mail: return "Email"
        }
    }
}

// MARK: - Preview

#Preview {
    LookupView(popoverState: PopoverState())
        .frame(width: 400, height: 500)
}
