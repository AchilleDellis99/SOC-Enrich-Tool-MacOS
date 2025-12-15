//
//  HistoryView.swift
//  SOC
//
//  Search history viewer with export functionality
//

import SwiftUI
import AppKit

struct HistoryView: View {
    @ObservedObject private var historyManager = SearchHistoryManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var searchQuery = ""
    @State private var selectedType: String? = nil
    @State private var showingExportMenu = false
    
    private let types = ["Tutti", "ip", "domain", "sha", "asn", "mail"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Filters
            filterBar
            
            Divider()
            
            // History List
            if filteredSearches.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredSearches) { record in
                            HistoryRowView(record: record)
                        }
                    }
                    .padding()
                }
            }
            
            Divider()
            
            // Footer Actions
            footerView
        }
        .frame(width: 600, height: 500)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Cronologia Ricerche")
                    .font(.headline)
                Text("\(historyManager.searches.count) ricerche totali")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Chiudi") {
                dismiss()
            }
            .keyboardShortcut(.escape, modifiers: [])
        }
        .padding()
    }
    
    // MARK: - Filter Bar
    
    private var filterBar: some View {
        HStack {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Cerca nella cronologia...", text: $searchQuery)
                    .textFieldStyle(.plain)
                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Type filter
            Picker("Tipo", selection: $selectedType) {
                ForEach(types, id: \.self) { type in
                    Text(type == "Tutti" ? type : type.uppercased())
                        .tag(type == "Tutti" ? nil : Optional(type))
                }
            }
            .pickerStyle(.menu)
            .frame(width: 120)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("Nessuna ricerca")
                .font(.headline)
            Text("Le tue ricerche appariranno qui")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        HStack {
            Button(action: clearAll) {
                Label("Cancella tutto", systemImage: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .disabled(historyManager.searches.isEmpty)
            
            Spacer()
            
            Menu {
                Button("Esporta in CSV") {
                    exportCSV()
                }
                Button("Esporta in JSON") {
                    exportJSON()
                }
            } label: {
                Label("Esporta", systemImage: "square.and.arrow.up")
            }
            .disabled(historyManager.searches.isEmpty)
            
            Button("Statistiche") {
                showStatistics()
            }
        }
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var filteredSearches: [SearchRecord] {
        var filtered = historyManager.searches
        
        if let type = selectedType {
            filtered = filtered.filter { $0.type == type }
        }
        
        if !searchQuery.isEmpty {
            filtered = filtered.filter { 
                $0.value.localizedCaseInsensitiveContains(searchQuery) 
            }
        }
        
        return filtered
    }
    
    // MARK: - Actions
    
    private func clearAll() {
        let alert = NSAlert()
        alert.messageText = "Cancellare tutta la cronologia?"
        alert.informativeText = "Questa operazione non può essere annullata."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Cancella")
        alert.addButton(withTitle: "Annulla")
        
        if alert.runModal() == .alertFirstButtonReturn {
            historyManager.removeAll()
        }
    }
    
    private func exportCSV() {
        let csv = historyManager.exportToCSV()
        saveToFile(content: csv, filename: "SOC_History.csv")
    }
    
    private func exportJSON() {
        if let json = historyManager.exportToJSON() {
            saveToFile(content: json, filename: "SOC_History.json")
        }
    }
    
    private func saveToFile(content: String, filename: String) {
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = filename
        savePanel.allowedContentTypes = [.commaSeparatedText, .json]
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            try? content.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    private func showStatistics() {
        let stats = historyManager.getStatistics()
        var message = "Statistiche ricerche:\n\n"
        for (type, count) in stats.sorted(by: { $0.key < $1.key }) {
            message += "\(type.uppercased()): \(count)\n"
        }
        
        let alert = NSAlert()
        alert.messageText = "Statistiche"
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// MARK: - History Row View

struct HistoryRowView: View {
    let record: SearchRecord
    @ObservedObject private var historyManager = SearchHistoryManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Type icon
            Image(systemName: typeIcon)
                .font(.title3)
                .foregroundColor(typeColor)
                .frame(width: 30)
            
            // Value
            VStack(alignment: .leading, spacing: 4) {
                Text(record.value)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(record.type.uppercased())
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(typeColor.opacity(0.2))
                        .cornerRadius(4)
                    
                    Text(record.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 8) {
                Button(action: { copyToClipboard(record.value) }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help("Copia")
                
                Button(action: { repeatSearch(record) }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
                .help("Ripeti ricerca")
                
                Button(action: { deleteRecord(record) }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Elimina")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var typeIcon: String {
        switch record.type {
        case "ip": return "network"
        case "domain": return "globe"
        case "sha": return "number.square"
        case "asn": return "building.2"
        case "mail": return "envelope"
        default: return "questionmark"
        }
    }
    
    private var typeColor: Color {
        switch record.type {
        case "ip": return .blue
        case "domain": return .green
        case "sha": return .orange
        case "asn": return .indigo
        case "mail": return .purple
        default: return .gray
        }
    }
    
    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
    
    private func repeatSearch(_ record: SearchRecord) {
        if let type = record.artifactType {
            let enabledServices = PreferencesManager.shared.getEnabledServices(for: type)
            let urls = enabledServices.map { service -> URL? in
                let urlString = service.url.replacingOccurrences(of: "{value}", with: record.value)
                return URL(string: urlString)
            }.compactMap { $0 }
            
            BrowserManager.shared.openURLs(urls, inBackground: true)
        }
    }
    
    private func deleteRecord(_ record: SearchRecord) {
        historyManager.removeSearch(record)
    }
}

// MARK: - Preview

#Preview {
    HistoryView()
}
