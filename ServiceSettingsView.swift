//
//  ServiceSettingsView.swift
//  SOC
//
//  Service management view
//

import SwiftUI

struct ServiceSettingsView: View {
    @ObservedObject var serviceManager = ServiceManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var selectedCategory: ArtifactType = .ip
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Category Selector
            categorySelector
            
            Divider()
            
            // Services List
            servicesList
            
            Divider()
            
            // Footer
            footerView
        }
        .frame(width: 600, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(localization.getString(.servicesManagement))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(localization.getString(.servicesManagementDesc))
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
    }
    
    // MARK: - Category Selector
    
    private var categorySelector: some View {
        HStack(spacing: 12) {
            CategoryButton(title: localization.getString(.categoryIP), icon: "network", isSelected: selectedCategory == .ip) {
                selectedCategory = .ip
            }
            CategoryButton(title: localization.getString(.categoryDomain), icon: "globe", isSelected: selectedCategory == .domain) {
                selectedCategory = .domain
            }
            CategoryButton(title: localization.getString(.categorySHA), icon: "number.square", isSelected: selectedCategory == .sha) {
                selectedCategory = .sha
            }
            CategoryButton(title: localization.getString(.categoryASN), icon: "building.2", isSelected: selectedCategory == .asn) {
                selectedCategory = .asn
            }
            CategoryButton(title: localization.getString(.categoryEmail), icon: "envelope", isSelected: selectedCategory == .mail) {
                selectedCategory = .mail
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Services List
    
    private var servicesList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                let services = serviceManager.getAllServices(for: selectedCategory)
                
                if services.isEmpty {
                    emptyStateView
                } else {
                    ForEach(services) { service in
                        ServiceRow(service: service) {
                            serviceManager.toggleService(service.id)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(localization.getString(.noResults))
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        HStack {
            Text(serviceCountText)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(localization.getString(.resetDefaults)) {
                serviceManager.resetToDefaults()
            }
            .buttonStyle(.borderless)
            
            Button(localization.getString(.closeButton)) {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var serviceCountText: String {
        let enabled = serviceManager.getEnabledServices(for: selectedCategory).count
        let total = serviceManager.getAllServices(for: selectedCategory).count
        return "\(enabled)/\(total) \(localization.getString(.enabledServices))"
    }
}

// MARK: - Category Button

struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Service Row

struct ServiceRow: View {
    let service: LookupService
    let onToggle: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Toggle
            Toggle("", isOn: Binding(
                get: { service.isEnabled },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
            
            // Service Info
            VStack(alignment: .leading, spacing: 4) {
                Text(service.name)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(service.urlTemplate.replacingOccurrences(of: "{value}", with: "•••"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            // Status Badge
            if service.isEnabled {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.body)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovering ? Color.secondary.opacity(0.05) : Color.clear)
        )
        .contentShape(Rectangle()) // Rende tutta l'area cliccabile
        .onTapGesture {
            onToggle() // Click su qualsiasi parte toglie il servizio
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Window Controller

class ServiceSettingsWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Gestione Servizi"
        window.center()
        window.contentView = NSHostingView(rootView: ServiceSettingsView())
        
        self.init(window: window)
    }
}

// MARK: - Preview

#Preview {
    ServiceSettingsView()
}
