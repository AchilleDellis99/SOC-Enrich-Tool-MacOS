//
//  PreferencesManager.swift
//  SOC
//
//  User preferences and service customization
//

import Foundation

// MARK: - Service Configuration

struct ServiceConfig: Codable, Identifiable {
    let id: String
    let name: String
    let url: String
    var enabled: Bool
    let category: String // "ip", "domain", "sha", "asn", "mail"
    
    init(id: String = UUID().uuidString, name: String, url: String, enabled: Bool = true, category: String) {
        self.id = id
        self.name = name
        self.url = url
        self.enabled = enabled
        self.category = category
    }
}

// MARK: - User Preferences

struct UserPreferences: Codable {
    var openInBackground: Bool = true
    var prefillFromClipboard: Bool = true
    var autoDetectType: Bool = true
    var showValidationErrors: Bool = true
    var maxHistoryCount: Int = 50
    var enableHapticFeedback: Bool = true
    var showNotifications: Bool = false
    
    // Keyboard shortcuts
    var enableKeyboardShortcuts: Bool = true
    
    // Batch operations
    var enableBatchMode: Bool = false
    var maxBatchItems: Int = 20
}

// MARK: - Preferences Manager

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    @Published var preferences: UserPreferences
    @Published var services: [ServiceConfig]
    
    private let preferencesKey = "userPreferences"
    private let servicesKey = "customServices"
    
    private init() {
        self.preferences = PreferencesManager.loadPreferences()
        self.services = PreferencesManager.loadServices()
    }
    
    // MARK: - Preferences
    
    func updatePreferences(_ newPreferences: UserPreferences) {
        preferences = newPreferences
        savePreferences()
    }
    
    func resetPreferences() {
        preferences = UserPreferences()
        savePreferences()
    }
    
    private func savePreferences() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }
    
    private static func loadPreferences() -> UserPreferences {
        if let data = UserDefaults.standard.data(forKey: "userPreferences"),
           let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            return decoded
        }
        return UserPreferences()
    }
    
    // MARK: - Services Management
    
    func getEnabledServices(for type: ArtifactType) -> [ServiceConfig] {
        services.filter { $0.category == type.rawValue && $0.enabled }
    }
    
    func getAllServices(for type: ArtifactType) -> [ServiceConfig] {
        services.filter { $0.category == type.rawValue }
    }
    
    func toggleService(_ serviceId: String) {
        if let index = services.firstIndex(where: { $0.id == serviceId }) {
            services[index].enabled.toggle()
            saveServices()
        }
    }
    
    func addCustomService(_ service: ServiceConfig) {
        services.append(service)
        saveServices()
    }
    
    func removeService(_ serviceId: String) {
        services.removeAll { $0.id == serviceId }
        saveServices()
    }
    
    func resetToDefaultServices() {
        services = PreferencesManager.getDefaultServices()
        saveServices()
    }
    
    private func saveServices() {
        if let encoded = try? JSONEncoder().encode(services) {
            UserDefaults.standard.set(encoded, forKey: servicesKey)
        }
    }
    
    private static func loadServices() -> [ServiceConfig] {
        if let data = UserDefaults.standard.data(forKey: "customServices"),
           let decoded = try? JSONDecoder().decode([ServiceConfig].self, from: data) {
            return decoded
        }
        return getDefaultServices()
    }
    
    // MARK: - Default Services
    
    static func getDefaultServices() -> [ServiceConfig] {
        var services: [ServiceConfig] = []
        
        // IP Services
        services.append(ServiceConfig(name: "VirusTotal", url: "https://www.virustotal.com/gui/ip-address/{value}/details", category: "ip"))
        services.append(ServiceConfig(name: "AlienVault OTX", url: "https://otx.alienvault.com/indicator/ip/{value}", category: "ip"))
        services.append(ServiceConfig(name: "GreyNoise", url: "https://viz.greynoise.io/ip/{value}", category: "ip"))
        services.append(ServiceConfig(name: "AbuseIPDB", url: "https://www.abuseipdb.com/check/{value}", category: "ip"))
        services.append(ServiceConfig(name: "IPInfo", url: "https://ipinfo.io/{value}", category: "ip"))
        services.append(ServiceConfig(name: "Shodan", url: "https://www.shodan.io/host/{value}", category: "ip"))
        
        // Domain Services
        services.append(ServiceConfig(name: "VirusTotal", url: "https://www.virustotal.com/gui/domain/{value}/details", category: "domain"))
        services.append(ServiceConfig(name: "AlienVault OTX", url: "https://otx.alienvault.com/indicator/domain/{value}", category: "domain"))
        services.append(ServiceConfig(name: "URLScan", url: "https://urlscan.io/search/#{value}", category: "domain"))
        services.append(ServiceConfig(name: "GreyNoise", url: "https://viz.greynoise.io/query/{value}", category: "domain"))
        
        // SHA Services
        services.append(ServiceConfig(name: "VirusTotal", url: "https://www.virustotal.com/gui/file/{value}/details", category: "sha"))
        services.append(ServiceConfig(name: "MalwareBazaar", url: "https://bazaar.abuse.ch/sample/{value}", category: "sha"))
        services.append(ServiceConfig(name: "Hybrid Analysis", url: "https://www.hybrid-analysis.com/search?query={value}", category: "sha"))
        
        // ASN Services
        services.append(ServiceConfig(name: "IPInfo", url: "https://ipinfo.io/AS{value}", category: "asn"))
        services.append(ServiceConfig(name: "Hurricane Electric", url: "https://bgp.he.net/AS{value}", category: "asn"))
        
        // Mail Services
        services.append(ServiceConfig(name: "MX Lookup", url: "https://mxtoolbox.com/SuperTool.aspx?action=mx%3a{value}#&run=toolpage", category: "mail"))
        services.append(ServiceConfig(name: "SPF Lookup", url: "https://mxtoolbox.com/SuperTool.aspx?action=spf%3a{value}#&run=toolpage", category: "mail"))
        services.append(ServiceConfig(name: "DMARC Lookup", url: "https://mxtoolbox.com/SuperTool.aspx?action=dmarc%3a{value}#&run=toolpage", category: "mail"))
        
        return services
    }
    
    // MARK: - Statistics
    
    func getServiceStatistics() -> [String: Int] {
        var stats: [String: Int] = [:]
        for category in ["ip", "domain", "sha", "asn", "mail"] {
            let enabled = services.filter { $0.category == category && $0.enabled }.count
            let total = services.filter { $0.category == category }.count
            stats[category] = enabled
            stats["\(category)_total"] = total
        }
        return stats
    }
}
