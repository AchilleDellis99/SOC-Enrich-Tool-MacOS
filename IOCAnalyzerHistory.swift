//
//  IOCAnalyzerHistory.swift
//  SOC
//
//  History and Dashboard for IOC Analyzer
//

import SwiftUI
import AppKit

// MARK: - IOC Analysis Record

struct IOCAnalysisRecord: Identifiable, Codable {
    let id: UUID
    let value: String
    let type: String // IP, Domain, SHA-256, Email, ASN, URL
    let timestamp: Date
    let verdict: String // clean, suspicious, malicious, unknown
    let sourcesCount: Int
    let source: String // "analyzer" or "popover"
    
    init(value: String, type: String, verdict: String, sourcesCount: Int, source: String = "analyzer") {
        self.id = UUID()
        self.value = value
        self.type = type
        self.timestamp = Date()
        self.verdict = verdict
        self.sourcesCount = sourcesCount
        self.source = source
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var verdictColor: Color {
        switch verdict {
        case "clean": return .green
        case "suspicious": return .orange
        case "malicious": return .red
        default: return .gray
        }
    }
    
    var verdictIcon: String {
        switch verdict {
        case "clean": return "checkmark.shield.fill"
        case "suspicious": return "exclamationmark.triangle.fill"
        case "malicious": return "xmark.shield.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    var typeIcon: String {
        switch type {
        case "IP": return "network"
        case "Domain": return "globe"
        case "SHA-256": return "number"
        case "Email": return "envelope"
        case "ASN": return "building.2"
        case "URL": return "link"
        default: return "doc.text"
        }
    }
}

// MARK: - IOC Analyzer History Manager

class IOCAnalyzerHistoryManager: ObservableObject {
    static let shared = IOCAnalyzerHistoryManager()
    
    @Published var records: [IOCAnalysisRecord] = []
    
    private let maxHistorySize = 200
    private let userDefaultsKey = "iocAnalyzerHistory"
    
    private init() {
        loadHistory()
    }
    
    func addRecord(value: String, type: String, verdict: String, sourcesCount: Int, source: String = "analyzer") {
        // Avoid duplicates in last 5
        if let existing = records.prefix(5).first(where: { $0.value == value }) {
            records.removeAll(where: { $0.id == existing.id })
        }
        
        let record = IOCAnalysisRecord(value: value, type: type, verdict: verdict, sourcesCount: sourcesCount, source: source)
        records.insert(record, at: 0)
        
        if records.count > maxHistorySize {
            records = Array(records.prefix(maxHistorySize))
        }
        
        saveHistory()
    }
    
    func deleteRecord(_ record: IOCAnalysisRecord) {
        records.removeAll(where: { $0.id == record.id })
        saveHistory()
    }
    
    func clearHistory() {
        records.removeAll()
        saveHistory()
    }
    
    func searchHistory(query: String) -> [IOCAnalysisRecord] {
        guard !query.isEmpty else { return records }
        let q = query.lowercased()
        return records.filter { $0.value.lowercased().contains(q) || $0.type.lowercased().contains(q) }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([IOCAnalysisRecord].self, from: data) else { return }
        records = decoded
    }
    
    // MARK: - Statistics
    
    func getStats() -> DashboardStats {
        let now = Date()
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: now)!
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let todayStart = Calendar.current.startOfDay(for: now)
        
        let last30Days = records.filter { $0.timestamp >= thirtyDaysAgo }
        let last7Days = records.filter { $0.timestamp >= sevenDaysAgo }
        let today = records.filter { $0.timestamp >= todayStart }
        
        // Verdicts
        let malicious = last30Days.filter { $0.verdict == "malicious" }.count
        let suspicious = last30Days.filter { $0.verdict == "suspicious" }.count
        let clean = last30Days.filter { $0.verdict == "clean" }.count
        
        // Types breakdown
        var typeBreakdown: [String: Int] = [:]
        for record in last30Days {
            typeBreakdown[record.type, default: 0] += 1
        }
        
        // Daily activity (last 7 days)
        var dailyActivity: [Date: Int] = [:]
        for i in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: now)!
            let dayStart = Calendar.current.startOfDay(for: date)
            dailyActivity[dayStart] = 0
        }
        for record in last7Days {
            let dayStart = Calendar.current.startOfDay(for: record.timestamp)
            dailyActivity[dayStart, default: 0] += 1
        }
        
        // Source breakdown
        let fromAnalyzer = last30Days.filter { $0.source == "analyzer" }.count
        let fromPopover = last30Days.filter { $0.source == "popover" }.count
        
        return DashboardStats(
            totalLast30Days: last30Days.count,
            totalLast7Days: last7Days.count,
            totalToday: today.count,
            maliciousCount: malicious,
            suspiciousCount: suspicious,
            cleanCount: clean,
            typeBreakdown: typeBreakdown,
            dailyActivity: dailyActivity.sorted { $0.key < $1.key }.map { ($0.key, $0.value) },
            fromAnalyzer: fromAnalyzer,
            fromPopover: fromPopover
        )
    }
}

// MARK: - Dashboard Stats

struct DashboardStats {
    let totalLast30Days: Int
    let totalLast7Days: Int
    let totalToday: Int
    let maliciousCount: Int
    let suspiciousCount: Int
    let cleanCount: Int
    let typeBreakdown: [String: Int]
    let dailyActivity: [(Date, Int)]
    let fromAnalyzer: Int
    let fromPopover: Int
    
    var threatRate: Double {
        guard totalLast30Days > 0 else { return 0 }
        return Double(maliciousCount + suspiciousCount) / Double(totalLast30Days) * 100
    }
}

// MARK: - Dashboard Strings

struct DashboardL10n {
    static func get(_ key: Key, for lang: AppLanguage) -> String {
        return strings[lang]?[key] ?? strings[.english]![key]!
    }
    
    enum Key {
        case dashboard, last30Days, last7Days, today, totalAnalyses
        case threats, malicious, suspicious, clean, unknown
        case byType, activity, recentAnalyses, noData
        case threatRate, fromAnalyzer, fromPopover, viewAll
        case history, searchHistory, clearAll, export
    }
    
    static let strings: [AppLanguage: [Key: String]] = [
        .english: [
            .dashboard: "Dashboard", .last30Days: "Last 30 Days", .last7Days: "Last 7 Days",
            .today: "Today", .totalAnalyses: "Total Analyses", .threats: "Threats Detected",
            .malicious: "Malicious", .suspicious: "Suspicious", .clean: "Clean", .unknown: "Unknown",
            .byType: "By Type", .activity: "Activity", .recentAnalyses: "Recent Analyses",
            .noData: "No data yet", .threatRate: "Threat Rate", .fromAnalyzer: "From Analyzer",
            .fromPopover: "From Menu Bar", .viewAll: "View All", .history: "History",
            .searchHistory: "Search history...", .clearAll: "Clear All", .export: "Export"
        ],
        .italian: [
            .dashboard: "Dashboard", .last30Days: "Ultimi 30 Giorni", .last7Days: "Ultimi 7 Giorni",
            .today: "Oggi", .totalAnalyses: "Analisi Totali", .threats: "Minacce Rilevate",
            .malicious: "Malevoli", .suspicious: "Sospetti", .clean: "Puliti", .unknown: "Sconosciuti",
            .byType: "Per Tipo", .activity: "Attività", .recentAnalyses: "Analisi Recenti",
            .noData: "Nessun dato", .threatRate: "Tasso Minacce", .fromAnalyzer: "Da Analyzer",
            .fromPopover: "Da Menu Bar", .viewAll: "Vedi Tutto", .history: "Cronologia",
            .searchHistory: "Cerca nella cronologia...", .clearAll: "Cancella Tutto", .export: "Esporta"
        ],
        .spanish: [
            .dashboard: "Panel", .last30Days: "Últimos 30 Días", .last7Days: "Últimos 7 Días",
            .today: "Hoy", .totalAnalyses: "Análisis Totales", .threats: "Amenazas Detectadas",
            .malicious: "Maliciosos", .suspicious: "Sospechosos", .clean: "Limpios", .unknown: "Desconocidos",
            .byType: "Por Tipo", .activity: "Actividad", .recentAnalyses: "Análisis Recientes",
            .noData: "Sin datos", .threatRate: "Tasa de Amenazas", .fromAnalyzer: "Desde Analyzer",
            .fromPopover: "Desde Menú", .viewAll: "Ver Todo", .history: "Historial",
            .searchHistory: "Buscar historial...", .clearAll: "Borrar Todo", .export: "Exportar"
        ],
        .german: [
            .dashboard: "Dashboard", .last30Days: "Letzte 30 Tage", .last7Days: "Letzte 7 Tage",
            .today: "Heute", .totalAnalyses: "Gesamtanalysen", .threats: "Erkannte Bedrohungen",
            .malicious: "Bösartig", .suspicious: "Verdächtig", .clean: "Sauber", .unknown: "Unbekannt",
            .byType: "Nach Typ", .activity: "Aktivität", .recentAnalyses: "Letzte Analysen",
            .noData: "Keine Daten", .threatRate: "Bedrohungsrate", .fromAnalyzer: "Von Analyzer",
            .fromPopover: "Von Menüleiste", .viewAll: "Alle Anzeigen", .history: "Verlauf",
            .searchHistory: "Verlauf durchsuchen...", .clearAll: "Alle Löschen", .export: "Exportieren"
        ],
        .french: [
            .dashboard: "Tableau de Bord", .last30Days: "30 Derniers Jours", .last7Days: "7 Derniers Jours",
            .today: "Aujourd'hui", .totalAnalyses: "Analyses Totales", .threats: "Menaces Détectées",
            .malicious: "Malveillants", .suspicious: "Suspects", .clean: "Propres", .unknown: "Inconnus",
            .byType: "Par Type", .activity: "Activité", .recentAnalyses: "Analyses Récentes",
            .noData: "Aucune donnée", .threatRate: "Taux de Menaces", .fromAnalyzer: "Depuis Analyzer",
            .fromPopover: "Depuis Menu", .viewAll: "Voir Tout", .history: "Historique",
            .searchHistory: "Rechercher...", .clearAll: "Tout Effacer", .export: "Exporter"
        ],
        .portuguese: [
            .dashboard: "Painel", .last30Days: "Últimos 30 Dias", .last7Days: "Últimos 7 Dias",
            .today: "Hoje", .totalAnalyses: "Análises Totais", .threats: "Ameaças Detectadas",
            .malicious: "Maliciosos", .suspicious: "Suspeitos", .clean: "Limpos", .unknown: "Desconhecidos",
            .byType: "Por Tipo", .activity: "Atividade", .recentAnalyses: "Análises Recentes",
            .noData: "Sem dados", .threatRate: "Taxa de Ameaças", .fromAnalyzer: "Do Analyzer",
            .fromPopover: "Do Menu", .viewAll: "Ver Tudo", .history: "Histórico",
            .searchHistory: "Pesquisar...", .clearAll: "Limpar Tudo", .export: "Exportar"
        ],
        .russian: [
            .dashboard: "Панель", .last30Days: "Последние 30 Дней", .last7Days: "Последние 7 Дней",
            .today: "Сегодня", .totalAnalyses: "Всего Анализов", .threats: "Обнаружено Угроз",
            .malicious: "Вредоносные", .suspicious: "Подозрительные", .clean: "Чистые", .unknown: "Неизвестные",
            .byType: "По Типу", .activity: "Активность", .recentAnalyses: "Последние Анализы",
            .noData: "Нет данных", .threatRate: "Уровень Угроз", .fromAnalyzer: "Из Analyzer",
            .fromPopover: "Из Меню", .viewAll: "Показать Все", .history: "История",
            .searchHistory: "Поиск...", .clearAll: "Очистить", .export: "Экспорт"
        ],
        .chinese: [
            .dashboard: "仪表板", .last30Days: "过去30天", .last7Days: "过去7天",
            .today: "今天", .totalAnalyses: "分析总数", .threats: "检测到的威胁",
            .malicious: "恶意", .suspicious: "可疑", .clean: "安全", .unknown: "未知",
            .byType: "按类型", .activity: "活动", .recentAnalyses: "最近分析",
            .noData: "暂无数据", .threatRate: "威胁率", .fromAnalyzer: "来自分析器",
            .fromPopover: "来自菜单栏", .viewAll: "查看全部", .history: "历史记录",
            .searchHistory: "搜索...", .clearAll: "清除全部", .export: "导出"
        ],
        .japanese: [
            .dashboard: "ダッシュボード", .last30Days: "過去30日間", .last7Days: "過去7日間",
            .today: "今日", .totalAnalyses: "分析合計", .threats: "検出された脅威",
            .malicious: "悪意あり", .suspicious: "疑わしい", .clean: "安全", .unknown: "不明",
            .byType: "タイプ別", .activity: "アクティビティ", .recentAnalyses: "最近の分析",
            .noData: "データなし", .threatRate: "脅威率", .fromAnalyzer: "Analyzerから",
            .fromPopover: "メニューから", .viewAll: "すべて表示", .history: "履歴",
            .searchHistory: "検索...", .clearAll: "すべてクリア", .export: "エクスポート"
        ],
        .korean: [
            .dashboard: "대시보드", .last30Days: "최근 30일", .last7Days: "최근 7일",
            .today: "오늘", .totalAnalyses: "총 분석", .threats: "탐지된 위협",
            .malicious: "악성", .suspicious: "의심", .clean: "안전", .unknown: "알 수 없음",
            .byType: "유형별", .activity: "활동", .recentAnalyses: "최근 분석",
            .noData: "데이터 없음", .threatRate: "위협률", .fromAnalyzer: "분석기에서",
            .fromPopover: "메뉴에서", .viewAll: "모두 보기", .history: "기록",
            .searchHistory: "검색...", .clearAll: "모두 지우기", .export: "내보내기"
        ],
        .arabic: [
            .dashboard: "لوحة التحكم", .last30Days: "آخر 30 يوم", .last7Days: "آخر 7 أيام",
            .today: "اليوم", .totalAnalyses: "إجمالي التحليلات", .threats: "التهديدات المكتشفة",
            .malicious: "ضار", .suspicious: "مشبوه", .clean: "نظيف", .unknown: "غير معروف",
            .byType: "حسب النوع", .activity: "النشاط", .recentAnalyses: "التحليلات الأخيرة",
            .noData: "لا توجد بيانات", .threatRate: "معدل التهديد", .fromAnalyzer: "من المحلل",
            .fromPopover: "من القائمة", .viewAll: "عرض الكل", .history: "السجل",
            .searchHistory: "بحث...", .clearAll: "مسح الكل", .export: "تصدير"
        ],
        .hindi: [
            .dashboard: "डैशबोर्ड", .last30Days: "पिछले 30 दिन", .last7Days: "पिछले 7 दिन",
            .today: "आज", .totalAnalyses: "कुल विश्लेषण", .threats: "खतरे पाए गए",
            .malicious: "हानिकारक", .suspicious: "संदिग्ध", .clean: "सुरक्षित", .unknown: "अज्ञात",
            .byType: "प्रकार के अनुसार", .activity: "गतिविधि", .recentAnalyses: "हाल के विश्लेषण",
            .noData: "कोई डेटा नहीं", .threatRate: "खतरा दर", .fromAnalyzer: "विश्लेषक से",
            .fromPopover: "मेनू से", .viewAll: "सभी देखें", .history: "इतिहास",
            .searchHistory: "खोजें...", .clearAll: "सब साफ करें", .export: "निर्यात"
        ],
        .greek: [
            .dashboard: "Πίνακας", .last30Days: "Τελευταίες 30 Μέρες", .last7Days: "Τελευταίες 7 Μέρες",
            .today: "Σήμερα", .totalAnalyses: "Συνολικές Αναλύσεις", .threats: "Απειλές",
            .malicious: "Κακόβουλα", .suspicious: "Ύποπτα", .clean: "Καθαρά", .unknown: "Άγνωστα",
            .byType: "Ανά Τύπο", .activity: "Δραστηριότητα", .recentAnalyses: "Πρόσφατες Αναλύσεις",
            .noData: "Χωρίς δεδομένα", .threatRate: "Ποσοστό Απειλών", .fromAnalyzer: "Από Analyzer",
            .fromPopover: "Από Μενού", .viewAll: "Προβολή Όλων", .history: "Ιστορικό",
            .searchHistory: "Αναζήτηση...", .clearAll: "Διαγραφή Όλων", .export: "Εξαγωγή"
        ]
    ]
}

// MARK: - Dashboard View

struct DashboardView: View {
    @ObservedObject private var historyManager = IOCAnalyzerHistoryManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    
    private var lang: AppLanguage { localization.currentLanguage }
    private var stats: DashboardStats { historyManager.getStats() }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Main Stats Cards
                HStack(spacing: 12) {
                    StatCard(
                        title: DashboardL10n.get(.last30Days, for: lang),
                        value: "\(stats.totalLast30Days)",
                        icon: "calendar",
                        color: .blue
                    )
                    StatCard(
                        title: DashboardL10n.get(.last7Days, for: lang),
                        value: "\(stats.totalLast7Days)",
                        icon: "clock",
                        color: .purple
                    )
                    StatCard(
                        title: DashboardL10n.get(.today, for: lang),
                        value: "\(stats.totalToday)",
                        icon: "sun.max",
                        color: .orange
                    )
                }
                
                // Threat Stats
                HStack(spacing: 12) {
                    ThreatStatCard(
                        title: DashboardL10n.get(.malicious, for: lang),
                        count: stats.maliciousCount,
                        color: .red,
                        icon: "xmark.shield.fill"
                    )
                    ThreatStatCard(
                        title: DashboardL10n.get(.suspicious, for: lang),
                        count: stats.suspiciousCount,
                        color: .orange,
                        icon: "exclamationmark.triangle.fill"
                    )
                    ThreatStatCard(
                        title: DashboardL10n.get(.clean, for: lang),
                        count: stats.cleanCount,
                        color: .green,
                        icon: "checkmark.shield.fill"
                    )
                }
                
                // Threat Rate
                if stats.totalLast30Days > 0 {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(DashboardL10n.get(.threatRate, for: lang))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f%%", stats.threatRate))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(stats.threatRate > 30 ? .red : (stats.threatRate > 10 ? .orange : .green))
                        }
                        
                        Spacer()
                        
                        // Mini bar chart
                        HStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.red)
                                .frame(width: CGFloat(stats.maliciousCount) / CGFloat(max(stats.totalLast30Days, 1)) * 100, height: 20)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.orange)
                                .frame(width: CGFloat(stats.suspiciousCount) / CGFloat(max(stats.totalLast30Days, 1)) * 100, height: 20)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.green)
                                .frame(width: CGFloat(stats.cleanCount) / CGFloat(max(stats.totalLast30Days, 1)) * 100, height: 20)
                        }
                        .frame(width: 150)
                    }
                    .padding(12)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(10)
                }
                
                // Type Breakdown
                if !stats.typeBreakdown.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(DashboardL10n.get(.byType, for: lang))
                            .font(.headline)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                            ForEach(stats.typeBreakdown.sorted(by: { $0.value > $1.value }), id: \.key) { type, count in
                                HStack {
                                    Image(systemName: iconForType(type))
                                        .foregroundColor(.blue)
                                    Text(type)
                                        .font(.caption)
                                    Spacer()
                                    Text("\(count)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .padding(8)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Activity Chart (last 7 days)
                if !stats.dailyActivity.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(DashboardL10n.get(.activity, for: lang))
                            .font(.headline)
                        
                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(stats.dailyActivity, id: \.0) { date, count in
                                VStack(spacing: 4) {
                                    Text("\(count)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .bottom, endPoint: .top))
                                        .frame(width: 30, height: max(CGFloat(count) * 8, 4))
                                    
                                    Text(dayName(date))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(10)
                    }
                }
                
                // Source breakdown
                if stats.totalLast30Days > 0 {
                    HStack(spacing: 12) {
                        SourceCard(
                            title: DashboardL10n.get(.fromAnalyzer, for: lang),
                            count: stats.fromAnalyzer,
                            icon: "shield.lefthalf.filled",
                            color: .blue
                        )
                        SourceCard(
                            title: DashboardL10n.get(.fromPopover, for: lang),
                            count: stats.fromPopover,
                            icon: "menubar.rectangle",
                            color: .purple
                        )
                    }
                }
                
                // Empty State
                if stats.totalLast30Days == 0 {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text(DashboardL10n.get(.noData, for: lang))
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                }
            }
            .padding(16)
        }
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "IP": return "network"
        case "Domain": return "globe"
        case "SHA-256": return "number"
        case "Email": return "envelope"
        case "ASN": return "building.2"
        case "URL": return "link"
        default: return "doc.text"
        }
    }
    
    private func dayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct ThreatStatCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(.headline)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct SourceCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(.headline)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

// MARK: - History List View

struct HistoryListView: View {
    @ObservedObject private var historyManager = IOCAnalyzerHistoryManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var searchText = ""
    @State private var showingClearConfirm = false
    
    private var lang: AppLanguage { localization.currentLanguage }
    
    var filteredRecords: [IOCAnalysisRecord] {
        historyManager.searchHistory(query: searchText)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField(DashboardL10n.get(.searchHistory, for: lang), text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                Button(DashboardL10n.get(.clearAll, for: lang)) {
                    showingClearConfirm = true
                }
                .buttonStyle(.borderless)
                .foregroundColor(.red)
                .disabled(historyManager.records.isEmpty)
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // History List
            if filteredRecords.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(DashboardL10n.get(.noData, for: lang))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredRecords) { record in
                            HistoryRecordRow(record: record, lang: lang) {
                                historyManager.deleteRecord(record)
                            }
                        }
                    }
                    .padding(12)
                }
            }
        }
        .alert(DashboardL10n.get(.clearAll, for: lang), isPresented: $showingClearConfirm) {
            Button("Cancel", role: .cancel) { }
            Button(DashboardL10n.get(.clearAll, for: lang), role: .destructive) {
                historyManager.clearHistory()
            }
        }
    }
}

struct HistoryRecordRow: View {
    let record: IOCAnalysisRecord
    let lang: AppLanguage
    let onDelete: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Type Icon
            Image(systemName: record.typeIcon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(record.value)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(record.type)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                    
                    Text(record.timeAgo)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(record.source == "analyzer" ? "Analyzer" : "Menu")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Verdict
            HStack(spacing: 4) {
                Image(systemName: record.verdictIcon)
                Text(record.verdict.capitalized)
            }
            .font(.caption)
            .foregroundColor(record.verdictColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(record.verdictColor.opacity(0.1))
            .cornerRadius(6)
            
            // Delete button
            if isHovering {
                Button { onDelete() } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
        .onHover { isHovering = $0 }
    }
}
