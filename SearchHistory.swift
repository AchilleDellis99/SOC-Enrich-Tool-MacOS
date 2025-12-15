//
//  SearchHistory.swift
//  SOC
//
//  Search history management
//

import Foundation
import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - Search Record

struct SearchRecord: Identifiable, Codable {
    let id: UUID
    let value: String
    let type: ArtifactType
    let timestamp: Date
    
    init(value: String, type: ArtifactType) {
        self.id = UUID()
        self.value = value
        self.type = type
        self.timestamp = Date()
    }
    
    var displayType: String {
        switch type {
        case .ip: return "IP"
        case .domain: return "Domain"
        case .sha: return "SHA-256"
        case .asn: return "ASN"
        case .mail: return "Email"
        }
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

// MARK: - Search History Manager

class SearchHistoryManager: ObservableObject {
    static let shared = SearchHistoryManager()
    
    @Published var searches: [SearchRecord] = []
    
    private let maxHistorySize = 50
    private let userDefaultsKey = "searchHistory"
    
    private init() {
        loadHistory()
    }
    
    func addSearch(value: String, type: ArtifactType) {
        // Evita duplicati recenti (stesso valore e tipo nelle ultime 5 ricerche)
        if let lastFive = searches.prefix(5).first(where: { $0.value == value && $0.type == type }) {
            // Se esiste già nelle ultime 5, rimuovilo e aggiungilo in cima
            searches.removeAll(where: { $0.id == lastFive.id })
        }
        
        let record = SearchRecord(value: value, type: type)
        searches.insert(record, at: 0)
        
        // Mantieni solo le ultime N ricerche
        if searches.count > maxHistorySize {
            searches = Array(searches.prefix(maxHistorySize))
        }
        
        saveHistory()
    }
    
    func deleteSearch(_ record: SearchRecord) {
        searches.removeAll(where: { $0.id == record.id })
        saveHistory()
    }
    
    func clearHistory() {
        searches.removeAll()
        saveHistory()
    }
    
    func getRecent(limit: Int = 10) -> [SearchRecord] {
        return Array(searches.prefix(limit))
    }
    
    func searchHistory(query: String) -> [SearchRecord] {
        guard !query.isEmpty else { return searches }
        
        let lowercasedQuery = query.lowercased()
        return searches.filter { 
            $0.value.lowercased().contains(lowercasedQuery) ||
            $0.displayType.lowercased().contains(lowercasedQuery)
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(searches) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([SearchRecord].self, from: data) else {
            return
        }
        searches = decoded
    }
    
    // MARK: - Export Functions
    
    func exportToCSV() -> String {
        var csv = "Timestamp,Type,Value\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for record in searches {
            let timestamp = dateFormatter.string(from: record.timestamp)
            let escapedValue = record.value.replacingOccurrences(of: "\"", with: "\"\"")
            csv += "\"\(timestamp)\",\"\(record.displayType)\",\"\(escapedValue)\"\n"
        }
        
        return csv
    }
    
    func exportToJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let exportData = searches.map { record in
            [
                "timestamp": ISO8601DateFormatter().string(from: record.timestamp),
                "type": record.displayType,
                "value": record.value
            ]
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        
        return jsonString
    }
    
    func copyToClipboard(content: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
    }
}
