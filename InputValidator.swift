//
//  InputValidator.swift
//  SOC
//
//  Enhanced input validation for security artifacts
//

import Foundation

enum ValidationResult {
    case valid(ArtifactType)
    case invalid(String)
    case empty
    
    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .invalid(let message) = self { return message }
        return nil
    }
    
    var detectedType: ArtifactType? {
        if case .valid(let type) = self { return type }
        return nil
    }
}

struct InputValidator {
    
    // MARK: - Main Validation
    
    static func validate(_ input: String) -> ValidationResult {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            return .empty
        }
        
        // Auto-detect tipo
        if let type = detectType(trimmed) {
            return .valid(type)
        }
        
        return .invalid("Formato non riconosciuto")
    }
    
    static func detectType(_ input: String) -> ArtifactType? {
        if isValidIPv4(input) || isValidIPv6(input) {
            return .ip
        } else if isValidSHA256(input) {
            return .sha
        } else if isValidASN(input) {
            return .asn
        } else if isValidEmail(input) {
            return .mail
        } else if isValidDomain(input) {
            return .domain
        }
        return nil
    }
    
    // MARK: - IPv4 Validation
    
    static func isValidIPv4(_ input: String) -> Bool {
        let parts = input.split(separator: ".")
        guard parts.count == 4 else { return false }
        
        for part in parts {
            guard let num = Int(part), num >= 0, num <= 255 else {
                return false
            }
        }
        return true
    }
    
    // MARK: - IPv6 Validation
    
    static func isValidIPv6(_ input: String) -> Bool {
        // Semplificata: controlla che contenga : e caratteri esadecimali
        let hexDigits = CharacterSet(charactersIn: "0123456789abcdefABCDEF:")
        return input.rangeOfCharacter(from: hexDigits.inverted) == nil && 
               input.contains(":") &&
               input.split(separator: ":").count >= 3
    }
    
    // MARK: - Domain Validation
    
    static func isValidDomain(_ input: String) -> Bool {
        // Pattern base per domini
        let pattern = "^([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex?.firstMatch(in: input, range: range) != nil
    }
    
    // MARK: - SHA-256 Validation
    
    static func isValidSHA256(_ input: String) -> Bool {
        // SHA-256 è esattamente 64 caratteri esadecimali
        guard input.count == 64 else { return false }
        let hexDigits = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        return input.rangeOfCharacter(from: hexDigits.inverted) == nil
    }
    
    // MARK: - ASN Validation
    
    static func isValidASN(_ input: String) -> Bool {
        let upper = input.uppercased()
        
        // Formato: AS12345 o 12345
        if upper.hasPrefix("AS") {
            let numberPart = String(upper.dropFirst(2))
            return Int(numberPart) != nil
        }
        
        // Solo numero
        return Int(input) != nil && input.count <= 10
    }
    
    // MARK: - Email/Domain Validation for MX
    
    static func isValidEmail(_ input: String) -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let regex = try? NSRegularExpression(pattern: emailPattern)
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex?.firstMatch(in: input, range: range) != nil
    }
    
    // MARK: - Batch Validation
    
    static func validateBatch(_ input: String) -> [(String, ValidationResult)] {
        let lines = input.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        return lines.map { line in
            (line, validate(line))
        }
    }
    
    // MARK: - Helper Methods
    
    static func getSuggestionFor(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return nil
        }
        
        // Suggerimenti basati su pattern parziali
        if trimmed.contains(".") && !trimmed.contains("@") && trimmed.count < 64 {
            return "Potrebbe essere un dominio o IP"
        }
        
        if trimmed.count == 63 || trimmed.count == 65 {
            return "SHA-256 deve essere esattamente 64 caratteri"
        }
        
        if trimmed.lowercased().hasPrefix("as") && trimmed.count < 4 {
            return "ASN deve essere nel formato AS12345 o 12345"
        }
        
        return "Formato non valido"
    }
}
