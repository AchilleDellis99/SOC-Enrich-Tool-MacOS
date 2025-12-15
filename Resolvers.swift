//
//  Resolvers.swift
//  SOC
//
//  Enhanced version with more services and service management
//

import Foundation

enum ArtifactType: String, Codable {
    case ip
    case domain
    case sha
    case asn
    case mail
}

// MARK: - Service Definition

struct LookupService: Identifiable, Codable {
    let id: String
    let name: String
    let urlTemplate: String
    let category: ArtifactType
    var isEnabled: Bool
    
    init(id: String, name: String, urlTemplate: String, category: ArtifactType, isEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.urlTemplate = urlTemplate
        self.category = category
        self.isEnabled = isEnabled
    }
}

// MARK: - Service Manager

class ServiceManager: ObservableObject {
    static let shared = ServiceManager()
    
    @Published var services: [LookupService]
    
    private let userDefaultsKey = "enabledServices"
    
    private init() {
        self.services = ServiceManager.defaultServices()
        loadEnabledStates()
    }
    
    private static func defaultServices() -> [LookupService] {
        // IP LOOKUP SERVICES (15 servizi)
        let ipServices = [
            LookupService(id: "vt-ip", name: "VirusTotal", urlTemplate: "https://www.virustotal.com/gui/ip-address/{value}/details", category: .ip),
            LookupService(id: "otx-ip", name: "AlienVault OTX", urlTemplate: "https://otx.alienvault.com/indicator/ip/{value}", category: .ip),
            LookupService(id: "gn-ip", name: "GreyNoise", urlTemplate: "https://viz.greynoise.io/ip/{value}", category: .ip),
            LookupService(id: "abuse-ip", name: "AbuseIPDB", urlTemplate: "https://www.abuseipdb.com/check/{value}", category: .ip),
            LookupService(id: "ipinfo", name: "IPInfo", urlTemplate: "https://ipinfo.io/{value}", category: .ip),
            LookupService(id: "shodan", name: "Shodan", urlTemplate: "https://www.shodan.io/host/{value}", category: .ip),
            LookupService(id: "censys-ip", name: "Censys", urlTemplate: "https://search.censys.io/hosts/{value}", category: .ip),
            LookupService(id: "threat-crowd-ip", name: "ThreatCrowd", urlTemplate: "https://threatcrowd.org/ip.php?ip={value}", category: .ip),
            LookupService(id: "cisco-talos-ip", name: "Cisco Talos", urlTemplate: "https://talosintelligence.com/reputation_center/lookup?search={value}", category: .ip),
            LookupService(id: "ibm-xforce-ip", name: "IBM X-Force", urlTemplate: "https://exchange.xforce.ibmcloud.com/ip/{value}", category: .ip),
            LookupService(id: "pulsedive-ip", name: "Pulsedive", urlTemplate: "https://pulsedive.com/indicator/?ioc={value}", category: .ip),
            LookupService(id: "threathunter-ip", name: "ThreatHunter", urlTemplate: "https://threathunter.io/ip/{value}", category: .ip, isEnabled: false),
            LookupService(id: "ipvoid", name: "IPVoid", urlTemplate: "https://www.ipvoid.com/ip-blacklist-check/?ip={value}", category: .ip),
            LookupService(id: "spamhaus-ip", name: "Spamhaus", urlTemplate: "https://www.spamhaus.org/query/ip/{value}", category: .ip, isEnabled: false),
            LookupService(id: "threatminer-ip", name: "ThreatMiner", urlTemplate: "https://www.threatminer.org/host.php?q={value}", category: .ip)
        ]
        
        // DOMAIN LOOKUP SERVICES (12 servizi)
        let domainServices = [
            LookupService(id: "vt-domain", name: "VirusTotal", urlTemplate: "https://www.virustotal.com/gui/domain/{value}/details", category: .domain),
            LookupService(id: "otx-domain", name: "AlienVault OTX", urlTemplate: "https://otx.alienvault.com/indicator/domain/{value}", category: .domain),
            LookupService(id: "urlscan", name: "URLScan.io", urlTemplate: "https://urlscan.io/search/#{value}", category: .domain),
            LookupService(id: "gn-domain", name: "GreyNoise", urlTemplate: "https://viz.greynoise.io/query/{value}", category: .domain),
            LookupService(id: "threat-crowd-domain", name: "ThreatCrowd", urlTemplate: "https://threatcrowd.org/domain.php?domain={value}", category: .domain),
            LookupService(id: "cisco-talos-domain", name: "Cisco Talos", urlTemplate: "https://talosintelligence.com/reputation_center/lookup?search={value}", category: .domain),
            LookupService(id: "ibm-xforce-domain", name: "IBM X-Force", urlTemplate: "https://exchange.xforce.ibmcloud.com/url/{value}", category: .domain),
            LookupService(id: "pulsedive-domain", name: "Pulsedive", urlTemplate: "https://pulsedive.com/indicator/?ioc={value}", category: .domain),
            LookupService(id: "whois", name: "WHOIS Lookup", urlTemplate: "https://who.is/whois/{value}", category: .domain),
            LookupService(id: "dns-dumpster", name: "DNSDumpster", urlTemplate: "https://dnsdumpster.com/", category: .domain, isEnabled: false),
            LookupService(id: "threatminer-domain", name: "ThreatMiner", urlTemplate: "https://www.threatminer.org/domain.php?q={value}", category: .domain),
            LookupService(id: "securitytrails", name: "SecurityTrails", urlTemplate: "https://securitytrails.com/domain/{value}/dns", category: .domain)
        ]
        
        // SHA-256 HASH LOOKUP SERVICES (10 servizi)
        let shaServices = [
            LookupService(id: "vt-file", name: "VirusTotal", urlTemplate: "https://www.virustotal.com/gui/file/{value}/details", category: .sha),
            LookupService(id: "malware-bazaar", name: "MalwareBazaar", urlTemplate: "https://bazaar.abuse.ch/sample/{value}", category: .sha),
            LookupService(id: "hybrid-analysis", name: "Hybrid Analysis", urlTemplate: "https://www.hybrid-analysis.com/search?query={value}", category: .sha),
            LookupService(id: "any-run", name: "ANY.RUN", urlTemplate: "https://app.any.run/submissions/#filehash:{value}", category: .sha),
            LookupService(id: "joe-sandbox", name: "Joe Sandbox", urlTemplate: "https://www.joesandbox.com/search?q={value}", category: .sha, isEnabled: false),
            LookupService(id: "reversing-labs", name: "ReversingLabs", urlTemplate: "https://a1000.reversinglabs.com/accounts/login/?next=/search/v2/%3Fquery%3D{value}", category: .sha, isEnabled: false),
            LookupService(id: "metadefender", name: "MetaDefender", urlTemplate: "https://metadefender.opswat.com/results/file/{value}/regular/overview", category: .sha),
            LookupService(id: "threatminer-hash", name: "ThreatMiner", urlTemplate: "https://www.threatminer.org/sample.php?q={value}", category: .sha),
            LookupService(id: "kaspersky-opentip", name: "Kaspersky Opentip", urlTemplate: "https://opentip.kaspersky.com/{value}", category: .sha),
            LookupService(id: "intezer", name: "Intezer Analyze", urlTemplate: "https://analyze.intezer.com/files/{value}", category: .sha, isEnabled: false)
        ]
        
        // ASN LOOKUP SERVICES (8 servizi) - NOTA: {value} sarà solo il numero, senza "AS"
        let asnServices = [
            LookupService(id: "ipinfo-asn", name: "IPInfo ASN", urlTemplate: "https://ipinfo.io/AS{value}", category: .asn),
            LookupService(id: "he-bgp", name: "Hurricane Electric BGP", urlTemplate: "https://bgp.he.net/AS{value}", category: .asn),
            LookupService(id: "bgpview", name: "BGPView", urlTemplate: "https://bgpview.io/asn/{value}", category: .asn),
            LookupService(id: "peeringdb", name: "PeeringDB", urlTemplate: "https://www.peeringdb.com/asn/{value}", category: .asn),
            LookupService(id: "ripe-asn", name: "RIPE Stat", urlTemplate: "https://stat.ripe.net/AS{value}", category: .asn),
            LookupService(id: "bgp-tools", name: "BGP.Tools", urlTemplate: "https://bgp.tools/as/{value}", category: .asn),
            LookupService(id: "robtex-asn", name: "Robtex ASN", urlTemplate: "https://www.robtex.com/as/as{value}.html", category: .asn),
            LookupService(id: "ultratools-asn", name: "UltraTools ASN", urlTemplate: "https://www.ultratools.com/tools/asnInfoResult?asn={value}", category: .asn, isEnabled: false)
        ]
        
        // EMAIL/MX LOOKUP SERVICES (6 servizi)
        let mailServices = [
            LookupService(id: "mx-toolbox-mx", name: "MXToolbox MX", urlTemplate: "https://mxtoolbox.com/SuperTool.aspx?action=mx%3a{value}#&run=toolpage", category: .mail),
            LookupService(id: "mx-toolbox-spf", name: "MXToolbox SPF", urlTemplate: "https://mxtoolbox.com/SuperTool.aspx?action=spf%3a{value}#&run=toolpage", category: .mail),
            LookupService(id: "mx-toolbox-dmarc", name: "MXToolbox DMARC", urlTemplate: "https://mxtoolbox.com/SuperTool.aspx?action=dmarc%3a{value}#&run=toolpage", category: .mail),
            LookupService(id: "dmarcian", name: "Dmarcian", urlTemplate: "https://dmarcian.com/domain-checker/?domain={value}", category: .mail, isEnabled: false),
            LookupService(id: "email-checker", name: "Email Checker", urlTemplate: "https://email-checker.net/validate", category: .mail, isEnabled: false),
            LookupService(id: "hunter-email", name: "Hunter.io", urlTemplate: "https://hunter.io/email-verifier/{value}", category: .mail, isEnabled: false)
        ]
        
        return ipServices + domainServices + shaServices + asnServices + mailServices
    }
    
    func toggleService(_ serviceId: String) {
        if let index = services.firstIndex(where: { $0.id == serviceId }) {
            services[index].isEnabled.toggle()
            saveEnabledStates()
        }
    }
    
    func getEnabledServices(for type: ArtifactType) -> [LookupService] {
        return services.filter { $0.category == type && $0.isEnabled }
    }
    
    func getAllServices(for type: ArtifactType) -> [LookupService] {
        return services.filter { $0.category == type }
    }
    
    private func saveEnabledStates() {
        let enabledStates = services.reduce(into: [String: Bool]()) { result, service in
            result[service.id] = service.isEnabled
        }
        if let encoded = try? JSONEncoder().encode(enabledStates) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadEnabledStates() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let enabledStates = try? JSONDecoder().decode([String: Bool].self, from: data) else {
            return
        }
        
        for i in 0..<services.count {
            if let isEnabled = enabledStates[services[i].id] {
                services[i].isEnabled = isEnabled
            }
        }
    }
    
    func resetToDefaults() {
        services = ServiceManager.defaultServices()
        saveEnabledStates()
    }
}

// MARK: - Resolver

enum Resolver {
    /// Genera gli URL per il tipo di artefatto specificato
    /// - Parameters:
    ///   - type: Il tipo di artefatto (IP, domain, SHA, ecc.)
    ///   - value: Il valore da cercare
    ///   - all: Se true, restituisce tutti gli URL abilitati
    /// - Returns: Array di URL per la ricerca
    static func urls(for type: ArtifactType, value: String, all: Bool = true) -> [URL] {
        let input = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return [] }
        
        // Per ASN, rimuovi "AS" se presente
        let cleanValue: String
        if type == .asn {
            cleanValue = input.uppercased().hasPrefix("AS") ? String(input.dropFirst(2)) : input
        } else {
            cleanValue = input
        }
        
        let services = all ? ServiceManager.shared.getEnabledServices(for: type) : []
        
        return services.compactMap { service in
            let urlString = service.urlTemplate.replacingOccurrences(of: "{value}", with: cleanValue)
            return URL(string: urlString)
        }
    }
}

// MARK: - Input Validation

enum ValidationResult {
    case valid(ArtifactType)
    case invalid(String)
    case empty
    
    var isValid: Bool {
        if case .valid = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case .invalid(let message) = self {
            return message
        }
        return nil
    }
    
    var detectedType: ArtifactType? {
        if case .valid(let type) = self {
            return type
        }
        return nil
    }
}

class InputValidator {
    static func validate(_ input: String) -> ValidationResult {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return .empty
        }
        
        // Check IPv4
        if isValidIPv4(trimmed) {
            return .valid(.ip)
        }
        
        // Check IPv6
        if isValidIPv6(trimmed) {
            return .valid(.ip)
        }
        
        // Check SHA-256
        if isValidSHA256(trimmed) {
            return .valid(.sha)
        }
        
        // Check ASN
        if isValidASN(trimmed) {
            return .valid(.asn)
        }
        
        // Check Email
        if isValidEmail(trimmed) {
            return .valid(.mail)
        }
        
        // Check Domain (deve essere l'ultimo perché è il meno restrittivo)
        if isValidDomain(trimmed) {
            return .valid(.domain)
        }
        
        return .invalid("Formato non riconosciuto")
    }
    
    private static func isValidIPv4(_ string: String) -> Bool {
        let parts = string.split(separator: ".")
        guard parts.count == 4 else { return false }
        
        return parts.allSatisfy { part in
            guard let num = Int(part), num >= 0, num <= 255 else { return false }
            return String(num) == part // Evita "01" o "001"
        }
    }
    
    private static func isValidIPv6(_ string: String) -> Bool {
        // Regex semplificata per IPv6
        let ipv6Pattern = "^([0-9a-fA-F]{0,4}:){7}[0-9a-fA-F]{0,4}$|^([0-9a-fA-F]{0,4}:){1,7}:$|^::([0-9a-fA-F]{0,4}:){0,6}[0-9a-fA-F]{0,4}$"
        return string.range(of: ipv6Pattern, options: .regularExpression) != nil
    }
    
    private static func isValidSHA256(_ string: String) -> Bool {
        // SHA-256 è esattamente 64 caratteri esadecimali
        let sha256Pattern = "^[a-fA-F0-9]{64}$"
        return string.range(of: sha256Pattern, options: .regularExpression) != nil
    }
    
    private static func isValidASN(_ string: String) -> Bool {
        // ASN può essere "AS12345" o solo "12345"
        let asnPattern = "^(AS)?[0-9]{1,10}$"
        return string.uppercased().range(of: asnPattern, options: .regularExpression) != nil
    }
    
    private static func isValidEmail(_ string: String) -> Bool {
        // Regex semplificata per email
        let emailPattern = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        return string.range(of: emailPattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
    
    private static func isValidDomain(_ string: String) -> Bool {
        // Domain pattern base (molto permissivo)
        let domainPattern = "^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]?\\.[a-zA-Z]{2,}$"
        
        // Verifica anche domini con più livelli (es. example.co.uk)
        let parts = string.split(separator: ".")
        guard parts.count >= 2 else { return false }
        
        return string.range(of: domainPattern, options: .regularExpression) != nil ||
               parts.allSatisfy { $0.range(of: "^[a-zA-Z0-9-]+$", options: .regularExpression) != nil }
    }
}
