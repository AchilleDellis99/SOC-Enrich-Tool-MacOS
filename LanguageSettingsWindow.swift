//
//  LanguageSettingsWindow.swift
//  SOC
//
//  Created on 30/10/2025.
//

import SwiftUI
import AppKit

class LanguageSettingsWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Language Settings"
        window.contentView = NSHostingView(rootView: LanguageSettingsView())
        
        self.init(window: window)
    }
}

struct LanguageSettingsView: View {
    @ObservedObject private var localization = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "globe")
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Language / Lingua / Sprache")
                        .font(.headline)
                    Text("Select your preferred language")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.bottom, 10)
            
            Divider()
            
            // Current Language Display
            HStack {
                Text("Current:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text(localization.currentLanguage.flag)
                        .font(.title2)
                    Text(localization.currentLanguage.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
            // Language Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(AppLanguage.allCases) { language in
                        LanguageButton(
                            language: language,
                            isSelected: localization.currentLanguage == language
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                localization.currentLanguage = language
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            
            Divider()
            
            // Footer Info
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                    Text("Language preference is saved automatically")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                    Text("13 languages • 5+ billion speakers covered")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding(24)
        .frame(width: 400, height: 500)
    }
}

struct LanguageButton: View {
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(language.flag)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.displayName)
                        .font(.body)
                        .fontWeight(isSelected ? .semibold : .regular)
                    
                    Text(language.rawValue.uppercased())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            .padding(12)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isSelected
                        ? Color.blue.opacity(0.15)
                        : (isHovering ? Color.gray.opacity(0.1) : Color.clear)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isSelected ? Color.blue : Color.gray.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

#Preview {
    LanguageSettingsView()
}
