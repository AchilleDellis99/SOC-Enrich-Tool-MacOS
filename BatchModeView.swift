//
//  BatchModeView.swift
//  SOC
//
//  Batch processing for multiple lookups
//

import SwiftUI
import AppKit

struct BatchModeView: View {
    @Binding var isPresented: Bool
    @ObservedObject private var preferencesManager = PreferencesManager.shared
    @ObservedObject private var browserManager = BrowserManager.shared
    @ObservedObject private var historyManager = SearchHistoryManager.shared
    
    @State private var batchInput = ""
    @State private var selectedType: ArtifactType = .ip
    @State private var isProcessing = false
    @State private var results: [(String, ValidationResult)] = []
    @State private var processedCount = 0
    @State private var showingResults = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            if !showingResults {
                // Input view
                inputView
            } else {
                // Results view
                resultsView
            }
            
            Divider()
            
            // Footer
            footerView
        }
        .frame(width: 600, height: 500)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Modalità Batch")
                    .font(.headline)
                Text("Inserisci più valori da cercare, uno per riga")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Chiudi") {
                isPresented = false
            }
            .keyboardShortcut(.escape, modifiers: [])
        }
        .padding()
    }
    
    // MARK: - Input View
    
    private var inputView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Type selector
            HStack {
                Text("Tipo di ricerca:")
                    .font(.subheadline)
                
                Picker("", selection: $selectedType) {
                    Text("IP Address").tag(ArtifactType.ip)
                    Text("Domain").tag(ArtifactType.domain)
                    Text("SHA-256").tag(ArtifactType.sha)
                    Text("ASN").tag(ArtifactType.asn)
                    Text("Mail/MX").tag(ArtifactType.mail)
                }
                .pickerStyle(.segmented)
            }
            
            // Text editor
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Valori da cercare:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(lineCount) righe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if lineCount > preferencesManager.preferences.maxBatchItems {
                        Text("(massimo \(preferencesManager.preferences.maxBatchItems))")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                TextEditor(text: $batchInput)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxHeight: .infinity)
                    .border(Color.gray.opacity(0.3), width: 1)
            }
            
            // Quick actions
            HStack {
                Button("Incolla da Clipboard") {
                    pasteFromClipboard()
                }
                
                Button("Carica esempio") {
                    loadExample()
                }
                
                Spacer()
                
                Button("Cancella") {
                    batchInput = ""
                }
                .foregroundColor(.red)
                .disabled(batchInput.isEmpty)
            }
        }
        .padding()
    }
    
    // MARK: - Results View
    
    private var resultsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Risultati Validazione")
                    .font(.headline)
                
                Spacer()
                
                Button("← Indietro") {
                    showingResults = false
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Statistics
            HStack(spacing: 20) {
                StatCard(title: "Totali", value: results.count, color: .blue)
                StatCard(title: "Validi", value: validCount, color: .green)
                StatCard(title: "Non validi", value: invalidCount, color: .orange)
            }
            .padding(.horizontal)
            
            Divider()
            
            // Results list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(results.enumerated()), id: \.offset) { index, result in
                        BatchResultRow(index: index + 1, value: result.0, result: result.1)
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        HStack {
            if isProcessing {
                ProgressView()
                    .scaleEffect(0.7)
                Text("Elaborazione in corso... (\(processedCount)/\(lineCount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !showingResults {
                Button("Valida") {
                    validateBatch()
                }
                .disabled(batchInput.isEmpty || lineCount > preferencesManager.preferences.maxBatchItems)
                
                Button("Esegui Ricerca") {
                    processBatch()
                }
                .buttonStyle(.borderedProminent)
                .disabled(batchInput.isEmpty || lineCount > preferencesManager.preferences.maxBatchItems)
            } else {
                Button("Esporta Risultati") {
                    exportResults()
                }
                
                Button("Esegui Ricerca Validi") {
                    processBatchFromResults()
                }
                .buttonStyle(.borderedProminent)
                .disabled(validCount == 0)
            }
        }
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var lineCount: Int {
        batchInput.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .count
    }
    
    private var validCount: Int {
        results.filter { $0.1.isValid }.count
    }
    
    private var invalidCount: Int {
        results.filter { !$0.1.isValid && $0.1.errorMessage != nil }.count
    }
    
    // MARK: - Actions
    
    private func pasteFromClipboard() {
        if let clipboard = NSPasteboard.general.string(forType: .string) {
            batchInput = clipboard
        }
    }
    
    private func loadExample() {
        switch selectedType {
        case .ip:
            batchInput = "8.8.8.8\n1.1.1.1\n192.168.1.1"
        case .domain:
            batchInput = "google.com\nexample.com\napple.com"
        case .sha:
            batchInput = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\na" + String(repeating: "0", count: 63)
        case .asn:
            batchInput = "AS15169\nAS13335\n7018"
        case .mail:
            batchInput = "google.com\nexample.com"
        }
    }
    
    private func validateBatch() {
        results = InputValidator.validateBatch(batchInput)
        showingResults = true
    }
    
    private func processBatch() {
        isProcessing = true
        processedCount = 0
        
        let items = batchInput.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .prefix(preferencesManager.preferences.maxBatchItems)
        
        let enabledServices = preferencesManager.getEnabledServices(for: selectedType)
        
        DispatchQueue.global(qos: .userInitiated).async {
            for item in items {
                // Valida
                let validation = InputValidator.validate(item)
                guard validation.isValid else { continue }
                
                // Genera URLs
                var urls: [URL] = []
                for service in enabledServices {
                    let urlString = service.url.replacingOccurrences(of: "{value}", with: item)
                    if let url = URL(string: urlString) {
                        urls.append(url)
                    }
                }
                
                // Apri URLs
                DispatchQueue.main.async {
                    self.browserManager.openURLs(urls, inBackground: true)
                    self.historyManager.addSearch(value: item, type: self.selectedType)
                    self.processedCount += 1
                }
                
                // Delay per non sovraccaricare
                Thread.sleep(forTimeInterval: 0.5)
            }
            
            DispatchQueue.main.async {
                self.isProcessing = false
                self.showCompletionAlert()
            }
        }
    }
    
    private func processBatchFromResults() {
        let validItems = results.filter { $0.1.isValid }.map { $0.0 }
        
        // Ricostruisci il batch input solo con i valori validi
        batchInput = validItems.joined(separator: "\n")
        showingResults = false
        
        // Esegui la ricerca
        processBatch()
    }
    
    private func exportResults() {
        var csv = "Index,Value,Status,Error\n"
        for (index, result) in results.enumerated() {
            let status = result.1.isValid ? "Valid" : "Invalid"
            let error = result.1.errorMessage ?? ""
            csv += "\(index + 1),\"\(result.0)\",\(status),\"\(error)\"\n"
        }
        
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = "Batch_Validation_Results.csv"
        savePanel.allowedContentTypes = [.commaSeparatedText]
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            try? csv.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    private func showCompletionAlert() {
        let alert = NSAlert()
        alert.messageText = "Batch completato"
        alert.informativeText = "Elaborate \(processedCount) ricerche su \(lineCount) totali"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct BatchResultRow: View {
    let index: Int
    let value: String
    let result: ValidationResult
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(index)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            Image(systemName: result.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(result.isValid ? .green : .orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.body, design: .monospaced))
                
                if let error = result.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(result.isValid ? Color.green.opacity(0.05) : Color.orange.opacity(0.05))
        .cornerRadius(6)
    }
}

// MARK: - Preview

#Preview {
    BatchModeView(isPresented: .constant(true))
}
