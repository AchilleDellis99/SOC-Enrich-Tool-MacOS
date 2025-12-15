//
//  PreferencesView.swift
//  SOC
//
//  Preferences and service customization
//

import SwiftUI
import AppKit

struct PreferencesView: View {
    @ObservedObject private var preferencesManager = PreferencesManager.shared
    @ObservedObject private var browserManager = BrowserManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Tab View
            TabView(selection: $selectedTab) {
                GeneralPreferencesView()
                    .tabItem {
                        Label("Generale", systemImage: "gear")
                    }
                    .tag(0)
                
                ServicesPreferencesView()
                    .tabItem {
                        Label("Servizi", systemImage: "list.bullet")
                    }
                    .tag(1)
                
                BrowserPreferencesView()
                    .tabItem {
                        Label("Browser", systemImage: "safari")
                    }
                    .tag(2)
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }
    
    private var headerView: some View {
        HStack {
            Text("Preferenze")
                .font(.headline)
            
            Spacer()
            
            Button("Chiudi") {
                dismiss()
            }
            .keyboardShortcut(.escape, modifiers: [])
        }
        .padding()
    }
}

// MARK: - General Preferences

struct GeneralPreferencesView: View {
    @ObservedObject private var preferencesManager = PreferencesManager.shared
    
    var body: some View {
        Form {
            Section("Comportamento") {
                Toggle("Apri link in background", isOn: binding(\.openInBackground))
                Toggle("Carica automaticamente da clipboard", isOn: binding(\.prefillFromClipboard))
                Toggle("Rileva automaticamente il tipo", isOn: binding(\.autoDetectType))
                Toggle("Mostra errori di validazione", isOn: binding(\.showValidationErrors))
            }
            
            Section("Interfaccia") {
                Toggle("Feedback aptico", isOn: binding(\.enableHapticFeedback))
                Toggle("Mostra notifiche", isOn: binding(\.showNotifications))
                Toggle("Abilita keyboard shortcuts", isOn: binding(\.enableKeyboardShortcuts))
            }
            
            Section("Cronologia") {
                Stepper("Massimo elementi: \(preferencesManager.preferences.maxHistoryCount)", 
                       value: binding(\.maxHistoryCount), 
                       in: 10...200, 
                       step: 10)
            }
            
            Section("Batch Mode") {
                Toggle("Abilita modalità batch", isOn: binding(\.enableBatchMode))
                Stepper("Massimo items batch: \(preferencesManager.preferences.maxBatchItems)", 
                       value: binding(\.maxBatchItems), 
                       in: 5...50, 
                       step: 5)
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("Reset Preferenze") {
                    resetPreferences()
                }
                .foregroundColor(.red)
            }
        }
        .formStyle(.grouped)
    }
    
    private func binding(_ keyPath: WritableKeyPath<UserPreferences, Bool>) -> Binding<Bool> {
        Binding(
            get: { preferencesManager.preferences[keyPath: keyPath] },
            set: { 
                var prefs = preferencesManager.preferences
                prefs[keyPath: keyPath] = $0
                preferencesManager.updatePreferences(prefs)
            }
        )
    }
    
    private func binding(_ keyPath: WritableKeyPath<UserPreferences, Int>) -> Binding<Int> {
        Binding(
            get: { preferencesManager.preferences[keyPath: keyPath] },
            set: { 
                var prefs = preferencesManager.preferences
                prefs[keyPath: keyPath] = $0
                preferencesManager.updatePreferences(prefs)
            }
        )
    }
    
    private func resetPreferences() {
        let alert = NSAlert()
        alert.messageText = "Reset Preferenze"
        alert.informativeText = "Vuoi ripristinare tutte le preferenze ai valori predefiniti?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Annulla")
        
        if alert.runModal() == .alertFirstButtonReturn {
            preferencesManager.resetPreferences()
        }
    }
}

// MARK: - Services Preferences

struct ServicesPreferencesView: View {
    @ObservedObject private var preferencesManager = PreferencesManager.shared
    @State private var selectedCategory = "ip"
    
    private let categories = [
        ("ip", "IP Address", "network", Color.blue),
        ("domain", "Domain", "globe", Color.green),
        ("sha", "SHA-256", "number.square", Color.orange),
        ("asn", "ASN", "building.2", Color.indigo),
        ("mail", "Mail/MX", "envelope", Color.purple)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Category selector
            HStack(spacing: 12) {
                ForEach(categories, id: \.0) { category in
                    CategoryButton(
                        title: category.1,
                        icon: category.2,
                        color: category.3,
                        isSelected: selectedCategory == category.0
                    ) {
                        selectedCategory = category.0
                    }
                }
            }
            .padding()
            
            Divider()
            
            // Services list
            List {
                ForEach(servicesForCategory) { service in
                    ServiceRowView(service: service)
                }
            }
            
            Divider()
            
            // Footer
            HStack {
                Button("Reset Servizi") {
                    resetServices()
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Text("\(enabledCount)/\(totalCount) servizi abilitati")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
    
    private var servicesForCategory: [ServiceConfig] {
        preferencesManager.getAllServices(for: ArtifactType(rawValue: selectedCategory) ?? .ip)
    }
    
    private var enabledCount: Int {
        servicesForCategory.filter { $0.enabled }.count
    }
    
    private var totalCount: Int {
        servicesForCategory.count
    }
    
    private func resetServices() {
        let alert = NSAlert()
        alert.messageText = "Reset Servizi"
        alert.informativeText = "Vuoi ripristinare tutti i servizi ai valori predefiniti?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Annulla")
        
        if alert.runModal() == .alertFirstButtonReturn {
            preferencesManager.resetToDefaultServices()
        }
    }
}

struct CategoryButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.2) : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ServiceRowView: View {
    let service: ServiceConfig
    @ObservedObject private var preferencesManager = PreferencesManager.shared
    
    var body: some View {
        HStack {
            Toggle(isOn: Binding(
                get: { service.enabled },
                set: { _ in preferencesManager.toggleService(service.id) }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.name)
                        .font(.body)
                    Text(service.url.replacingOccurrences(of: "{value}", with: "..."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Browser Preferences

struct BrowserPreferencesView: View {
    @ObservedObject private var browserManager = BrowserManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Seleziona il browser predefinito per aprire i link")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if browserManager.availableBrowsers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Nessun browser rilevato")
                        .font(.headline)
                    Button("Ricarica") {
                        browserManager.detectBrowsers()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(browserManager.availableBrowsers) { browser in
                            BrowserRowView(
                                browser: browser,
                                isSelected: browserManager.selectedBrowser?.id == browser.id
                            ) {
                                browserManager.selectBrowser(browser)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            Divider()
            
            HStack {
                Button("Usa Browser di Sistema") {
                    browserManager.useSystemDefault()
                }
                
                Spacer()
                
                Button("Ricarica Browser") {
                    browserManager.detectBrowsers()
                }
            }
        }
        .padding()
    }
}

struct BrowserRowView: View {
    let browser: Browser
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = browser.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(browser.name)
                        .font(.body)
                    Text(browser.path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    PreferencesView()
}
