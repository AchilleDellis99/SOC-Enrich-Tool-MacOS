//
//  Localization.swift
//  SOC
//
//  Complete multilingual support for 13 languages
//

import Foundation
import SwiftUI

// MARK: - Language Model

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case italian = "it"
    case spanish = "es"
    case german = "de"
    case french = "fr"
    case portuguese = "pt"
    case russian = "ru"
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
    case arabic = "ar"
    case hindi = "hi"
    case greek = "el"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .italian: return "Italiano"
        case .spanish: return "Español"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .portuguese: return "Português"
        case .russian: return "Русский"
        case .chinese: return "中文"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .arabic: return "العربية"
        case .hindi: return "हिन्दी"
        case .greek: return "Ελληνικά"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .italian: return "🇮🇹"
        case .spanish: return "🇪🇸"
        case .german: return "🇩🇪"
        case .french: return "🇫🇷"
        case .portuguese: return "🇵🇹"
        case .russian: return "🇷🇺"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .arabic: return "🇸🇦"
        case .hindi: return "🇮🇳"
        case .greek: return "🇬🇷"
        }
    }
}

// MARK: - Localization Manager

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
        }
    }
    
    private init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage")
        self.currentLanguage = AppLanguage(rawValue: savedLanguage ?? "en") ?? .english
    }
    
    func getString(_ key: LocalizedKey) -> String {
        return key.localized(for: currentLanguage)
    }
}

// MARK: - Localization Keys

enum LocalizedKey {
    case appTitle
    case appSubtitle
    case inputPlaceholder
    case inputLabel
    case searchTitle
    case ipButton
    case domainButton
    case shaButton
    case mxButton
    case asnButton
    case openBackground
    case prefillClipboard
    case footerVersion
    case footerTitle
    case lastSearch
    case clearButton
    case refreshButton
    case aboutTitle
    case aboutMessage
    case quitButton
    case openButton
    case exportButton
    case exportCSV
    case exportJSON
    case csvCopied
    case jsonCopied
    case csvCopiedMessage
    case jsonCopiedMessage
    case historyTitle
    case searchHistoryPlaceholder
    case clearAllButton
    case closeButton
    case deleteButton
    case noSearches
    case noResults
    case servicesManagement
    case servicesManagementDesc
    case enabledServices
    case resetDefaults
    case categoryIP
    case categoryDomain
    case categorySHA
    case categoryASN
    case categoryEmail
    case openFullApp
    case openFullAppDesc
    
    func localized(for language: AppLanguage) -> String {
        switch language {
        case .english:
            return englishStrings[self] ?? ""
        case .italian:
            return italianStrings[self] ?? ""
        case .spanish:
            return spanishStrings[self] ?? ""
        case .german:
            return germanStrings[self] ?? ""
        case .french:
            return frenchStrings[self] ?? ""
        case .portuguese:
            return portugueseStrings[self] ?? ""
        case .russian:
            return russianStrings[self] ?? ""
        case .chinese:
            return chineseStrings[self] ?? ""
        case .japanese:
            return japaneseStrings[self] ?? ""
        case .korean:
            return koreanStrings[self] ?? ""
        case .arabic:
            return arabicStrings[self] ?? ""
        case .hindi:
            return hindiStrings[self] ?? ""
        case .greek:
            return greekStrings[self] ?? ""
        }
    }
}

// MARK: - English Strings
private let englishStrings: [LocalizedKey: String] = [
    .appTitle: "SOC Lookup Tool",
    .appSubtitle: "Security Operations Center",
    .inputPlaceholder: "Paste or type here...",
    .inputLabel: "Enter: IP / FQDN / SHA-256 / ASN / Email",
    .searchTitle: "Perform search",
    .ipButton: "IP Address",
    .domainButton: "Domain",
    .shaButton: "SHA-256",
    .mxButton: "MX Records",
    .asnButton: "ASN Lookup",
    .openBackground: "Open in background",
    .prefillClipboard: "Load from clipboard",
    .footerVersion: "v3.2",
    .footerTitle: "SOC Enrichment Tool",
    .lastSearch: "Last search",
    .clearButton: "Clear",
    .refreshButton: "Refresh",
    .aboutTitle: "About SOC Lookup Tool",
    .aboutMessage: "Security Operations Center Lookup Tool\nVersion 3.0\n\nQuick lookup for IPs, domains, hashes, and more across 51 threat intelligence services.",
    .quitButton: "Quit",
    .openButton: "Open SOC",
    .exportButton: "Export",
    .exportCSV: "Export CSV",
    .exportJSON: "Export JSON",
    .csvCopied: "CSV Copied!",
    .jsonCopied: "JSON Copied!",
    .csvCopiedMessage: "CSV data has been copied to clipboard.\n\nPaste it into Excel, Numbers, or any text editor and save wherever you want.",
    .jsonCopiedMessage: "JSON data has been copied to clipboard.\n\nPaste it into a text editor and save wherever you want.",
    .historyTitle: "Search History",
    .searchHistoryPlaceholder: "Search in history...",
    .clearAllButton: "Clear All",
    .closeButton: "Close",
    .deleteButton: "Delete",
    .noSearches: "No searches saved",
    .noResults: "No results found",
    .servicesManagement: "Services Management",
    .servicesManagementDesc: "Enable or disable lookup services for each category",
    .enabledServices: "services enabled",
    .resetDefaults: "Reset Defaults",
    .categoryIP: "IP",
    .categoryDomain: "Domain",
    .categorySHA: "SHA-256",
    .categoryASN: "ASN",
    .categoryEmail: "Email",
    .openFullApp: "Open IOC Analyzer",
    .openFullAppDesc: "Full threat analysis with free APIs"
]

// MARK: - Italian Strings
private let italianStrings: [LocalizedKey: String] = [
    .appTitle: "SOC Lookup Tool",
    .appSubtitle: "Security Operations Center",
    .inputPlaceholder: "Incolla o digita qui...",
    .inputLabel: "Inserisci: IP / FQDN / SHA-256 / ASN / Email",
    .searchTitle: "Effettua ricerca",
    .ipButton: "Indirizzo IP",
    .domainButton: "Dominio",
    .shaButton: "SHA-256",
    .mxButton: "Record MX",
    .asnButton: "Ricerca ASN",
    .openBackground: "Apri in background",
    .prefillClipboard: "Carica da clipboard",
    .footerVersion: "v3.2",
    .footerTitle: "SOC Enrichment Tool",
    .lastSearch: "Ultima ricerca",
    .clearButton: "Cancella",
    .refreshButton: "Aggiorna",
    .aboutTitle: "Info su SOC Lookup Tool",
    .aboutMessage: "Security Operations Center Lookup Tool\nVersione 3.0\n\nRicerca rapida per IP, domini, hash e altro su 51 servizi di threat intelligence.",
    .quitButton: "Esci",
    .openButton: "Apri SOC",
    .exportButton: "Esporta",
    .exportCSV: "Esporta CSV",
    .exportJSON: "Esporta JSON",
    .csvCopied: "CSV Copiato!",
    .jsonCopied: "JSON Copiato!",
    .csvCopiedMessage: "I dati CSV sono stati copiati negli appunti.\n\nIncollali in Excel, Numbers o qualsiasi editor di testo e salva dove vuoi.",
    .jsonCopiedMessage: "I dati JSON sono stati copiati negli appunti.\n\nIncollali in un editor di testo e salva dove vuoi.",
    .historyTitle: "Cronologia Ricerche",
    .searchHistoryPlaceholder: "Cerca nella cronologia...",
    .clearAllButton: "Cancella Tutto",
    .closeButton: "Chiudi",
    .deleteButton: "Elimina",
    .noSearches: "Nessuna ricerca salvata",
    .noResults: "Nessun risultato trovato",
    .servicesManagement: "Gestione Servizi",
    .servicesManagementDesc: "Abilita o disabilita i servizi di lookup per ogni categoria",
    .enabledServices: "servizi abilitati",
    .resetDefaults: "Reset Predefiniti",
    .categoryIP: "IP",
    .categoryDomain: "Dominio",
    .categorySHA: "SHA-256",
    .categoryASN: "ASN",
    .categoryEmail: "Email",
    .openFullApp: "Apri IOC Analyzer",
    .openFullAppDesc: "Analisi completa con API gratuite"
]

// MARK: - Spanish Strings
private let spanishStrings: [LocalizedKey: String] = [
    .appTitle: "SOC Lookup Tool",
    .appSubtitle: "Security Operations Center",
    .inputPlaceholder: "Pega o escribe aquí...",
    .inputLabel: "Ingresa: IP / FQDN / SHA-256 / ASN / Email",
    .searchTitle: "Realizar búsqueda",
    .ipButton: "Dirección IP",
    .domainButton: "Dominio",
    .shaButton: "SHA-256",
    .mxButton: "Registros MX",
    .asnButton: "Búsqueda ASN",
    .openBackground: "Abrir en segundo plano",
    .prefillClipboard: "Cargar del portapapeles",
    .footerVersion: "v3.2",
    .footerTitle: "SOC Enrichment Tool",
    .lastSearch: "Última búsqueda",
    .clearButton: "Limpiar",
    .refreshButton: "Actualizar",
    .aboutTitle: "Acerca de SOC Lookup Tool",
    .aboutMessage: "Security Operations Center Lookup Tool\nVersión 3.0\n\nBúsqueda rápida de IPs, dominios, hashes y más en 51 servicios de inteligencia de amenazas.",
    .quitButton: "Salir",
    .openButton: "Abrir SOC",
    .exportButton: "Exportar",
    .exportCSV: "Exportar CSV",
    .exportJSON: "Exportar JSON",
    .csvCopied: "¡CSV Copiado!",
    .jsonCopied: "¡JSON Copiado!",
    .csvCopiedMessage: "Los datos CSV se han copiado al portapapeles.\n\nPégalos en Excel, Numbers o cualquier editor de texto y guarda donde quieras.",
    .jsonCopiedMessage: "Los datos JSON se han copiado al portapapeles.\n\nPégalos en un editor de texto y guarda donde quieras.",
    .historyTitle: "Historial de Búsquedas",
    .searchHistoryPlaceholder: "Buscar en historial...",
    .clearAllButton: "Borrar Todo",
    .closeButton: "Cerrar",
    .deleteButton: "Eliminar",
    .noSearches: "No hay búsquedas guardadas",
    .noResults: "No se encontraron resultados",
    .servicesManagement: "Gestión de Servicios",
    .servicesManagementDesc: "Activa o desactiva los servicios de búsqueda para cada categoría",
    .enabledServices: "servicios activados",
    .resetDefaults: "Restablecer Predeterminados",
    .categoryIP: "IP",
    .categoryDomain: "Dominio",
    .categorySHA: "SHA-256",
    .categoryASN: "ASN",
    .categoryEmail: "Email",
    .openFullApp: "Abrir IOC Analyzer",
    .openFullAppDesc: "Análisis completo con APIs gratuitas"
]

// MARK: - German Strings
private let germanStrings: [LocalizedKey: String] = [
    .appTitle: "SOC Lookup Tool",
    .appSubtitle: "Security Operations Center",
    .inputPlaceholder: "Einfügen oder eingeben...",
    .inputLabel: "Eingeben: IP / FQDN / SHA-256 / ASN / E-Mail",
    .searchTitle: "Suche durchführen",
    .ipButton: "IP-Adresse",
    .domainButton: "Domain",
    .shaButton: "SHA-256",
    .mxButton: "MX-Einträge",
    .asnButton: "ASN-Suche",
    .openBackground: "Im Hintergrund öffnen",
    .prefillClipboard: "Aus Zwischenablage laden",
    .footerVersion: "v3.2",
    .footerTitle: "SOC Enrichment Tool",
    .lastSearch: "Letzte Suche",
    .clearButton: "Löschen",
    .refreshButton: "Aktualisieren",
    .aboutTitle: "Über SOC Lookup Tool",
    .aboutMessage: "Security Operations Center Lookup Tool\nVersion 3.0\n\nSchnelle Suche nach IPs, Domains, Hashes und mehr über 51 Threat-Intelligence-Dienste.",
    .quitButton: "Beenden",
    .openButton: "SOC öffnen",
    .exportButton: "Exportieren",
    .exportCSV: "CSV exportieren",
    .exportJSON: "JSON exportieren",
    .csvCopied: "CSV kopiert!",
    .jsonCopied: "JSON kopiert!",
    .csvCopiedMessage: "Die CSV-Daten wurden in die Zwischenablage kopiert.\n\nFügen Sie sie in Excel, Numbers oder einen beliebigen Texteditor ein und speichern Sie sie wo Sie möchten.",
    .jsonCopiedMessage: "Die JSON-Daten wurden in die Zwischenablage kopiert.\n\nFügen Sie sie in einen Texteditor ein und speichern Sie sie wo Sie möchten.",
    .historyTitle: "Suchverlauf",
    .searchHistoryPlaceholder: "Im Verlauf suchen...",
    .clearAllButton: "Alles löschen",
    .closeButton: "Schließen",
    .deleteButton: "Löschen",
    .noSearches: "Keine Suchen gespeichert",
    .noResults: "Keine Ergebnisse gefunden",
    .servicesManagement: "Dienstverwaltung",
    .servicesManagementDesc: "Aktivieren oder deaktivieren Sie Lookup-Dienste für jede Kategorie",
    .enabledServices: "Dienste aktiviert",
    .resetDefaults: "Standardwerte zurücksetzen",
    .categoryIP: "IP",
    .categoryDomain: "Domain",
    .categorySHA: "SHA-256",
    .categoryASN: "ASN",
    .categoryEmail: "E-Mail",
    .openFullApp: "IOC Analyzer öffnen",
    .openFullAppDesc: "Vollständige Analyse mit kostenlosen APIs"
]

// MARK: - French Strings
private let frenchStrings: [LocalizedKey: String] = [
    .appTitle: "SOC Lookup Tool",
    .appSubtitle: "Security Operations Center",
    .inputPlaceholder: "Coller ou taper ici...",
    .inputLabel: "Entrer: IP / FQDN / SHA-256 / ASN / Email",
    .searchTitle: "Effectuer une recherche",
    .ipButton: "Adresse IP",
    .domainButton: "Domaine",
    .shaButton: "SHA-256",
    .mxButton: "Enregistrements MX",
    .asnButton: "Recherche ASN",
    .openBackground: "Ouvrir en arrière-plan",
    .prefillClipboard: "Charger du presse-papiers",
    .footerVersion: "v3.2",
    .footerTitle: "SOC Enrichment Tool",
    .lastSearch: "Dernière recherche",
    .clearButton: "Effacer",
    .refreshButton: "Actualiser",
    .aboutTitle: "À propos de SOC Lookup Tool",
    .aboutMessage: "Security Operations Center Lookup Tool\nVersion 3.0\n\nRecherche rapide d'IPs, domaines, hashes et plus sur 51 services de renseignement sur les menaces.",
    .quitButton: "Quitter",
    .openButton: "Ouvrir SOC",
    .exportButton: "Exporter",
    .exportCSV: "Exporter CSV",
    .exportJSON: "Exporter JSON",
    .csvCopied: "CSV copié !",
    .jsonCopied: "JSON copié !",
    .csvCopiedMessage: "Les données CSV ont été copiées dans le presse-papiers.\n\nCollez-les dans Excel, Numbers ou tout éditeur de texte et enregistrez où vous voulez.",
    .jsonCopiedMessage: "Les données JSON ont été copiées dans le presse-papiers.\n\nCollez-les dans un éditeur de texte et enregistrez où vous voulez.",
    .historyTitle: "Historique des recherches",
    .searchHistoryPlaceholder: "Rechercher dans l'historique...",
    .clearAllButton: "Tout effacer",
    .closeButton: "Fermer",
    .deleteButton: "Supprimer",
    .noSearches: "Aucune recherche enregistrée",
    .noResults: "Aucun résultat trouvé",
    .servicesManagement: "Gestion des services",
    .servicesManagementDesc: "Activer ou désactiver les services de recherche pour chaque catégorie",
    .enabledServices: "services activés",
    .resetDefaults: "Réinitialiser par défaut",
    .categoryIP: "IP",
    .categoryDomain: "Domaine",
    .categorySHA: "SHA-256",
    .categoryASN: "ASN",
    .categoryEmail: "Email",
    .openFullApp: "Ouvrir IOC Analyzer",
    .openFullAppDesc: "Analyse complète avec APIs gratuites"
]

// MARK: - Portuguese Strings
private let portugueseStrings: [LocalizedKey: String] = [
    .appTitle: "SOC Lookup Tool",
    .appSubtitle: "Security Operations Center",
    .inputPlaceholder: "Cole ou digite aqui...",
    .inputLabel: "Digite: IP / FQDN / SHA-256 / ASN / Email",
    .searchTitle: "Realizar pesquisa",
    .ipButton: "Endereço IP",
    .domainButton: "Domínio",
    .shaButton: "SHA-256",
    .mxButton: "Registros MX",
    .asnButton: "Pesquisa ASN",
    .openBackground: "Abrir em segundo plano",
    .prefillClipboard: "Carregar da área de transferência",
    .footerVersion: "v3.2",
    .footerTitle: "SOC Enrichment Tool",
    .lastSearch: "Última pesquisa",
    .clearButton: "Limpar",
    .refreshButton: "Atualizar",
    .aboutTitle: "Sobre SOC Lookup Tool",
    .aboutMessage: "Security Operations Center Lookup Tool\nVersão 3.0\n\nPesquisa rápida de IPs, domínios, hashes e mais em 51 serviços de inteligência de ameaças.",
    .quitButton: "Sair",
    .openButton: "Abrir SOC",
    .exportButton: "Exportar",
    .exportCSV: "Exportar CSV",
    .exportJSON: "Exportar JSON",
    .csvCopied: "CSV Copiado!",
    .jsonCopied: "JSON Copiado!",
    .csvCopiedMessage: "Os dados CSV foram copiados para a área de transferência.\n\nCole-os no Excel, Numbers ou qualquer editor de texto e salve onde quiser.",
    .jsonCopiedMessage: "Os dados JSON foram copiados para a área de transferência.\n\nCole-os em um editor de texto e salve onde quiser.",
    .historyTitle: "Histórico de Pesquisas",
    .searchHistoryPlaceholder: "Pesquisar no histórico...",
    .clearAllButton: "Limpar Tudo",
    .closeButton: "Fechar",
    .deleteButton: "Excluir",
    .noSearches: "Nenhuma pesquisa salva",
    .noResults: "Nenhum resultado encontrado",
    .servicesManagement: "Gerenciamento de Serviços",
    .servicesManagementDesc: "Ativar ou desativar serviços de pesquisa para cada categoria",
    .enabledServices: "serviços ativados",
    .resetDefaults: "Restaurar Padrões",
    .categoryIP: "IP",
    .categoryDomain: "Domínio",
    .categorySHA: "SHA-256",
    .categoryASN: "ASN",
    .categoryEmail: "Email",
    .openFullApp: "Abrir IOC Analyzer",
    .openFullAppDesc: "Análise completa com APIs gratuitas"
]

// MARK: - Russian Strings
private let russianStrings: [LocalizedKey: String] = [
    .appTitle: "SOC Lookup Tool",
    .appSubtitle: "Security Operations Center",
    .inputPlaceholder: "Вставьте или введите здесь...",
    .inputLabel: "Введите: IP / FQDN / SHA-256 / ASN / Email",
    .searchTitle: "Выполнить поиск",
    .ipButton: "IP-адрес",
    .domainButton: "Домен",
    .shaButton: "SHA-256",
    .mxButton: "MX-записи",
    .asnButton: "Поиск ASN",
    .openBackground: "Открыть в фоне",
    .prefillClipboard: "Загрузить из буфера",
    .footerVersion: "v3.2",
    .footerTitle: "SOC Enrichment Tool",
    .lastSearch: "Последний поиск",
    .clearButton: "Очистить",
    .refreshButton: "Обновить",
    .aboutTitle: "О программе SOC Lookup Tool",
    .aboutMessage: "Security Operations Center Lookup Tool\nВерсия 3.0\n\nБыстрый поиск IP, доменов, хешей и многого другого в 51 службе анализа угроз.",
    .quitButton: "Выход",
    .openButton: "Открыть SOC",
    .exportButton: "Экспорт",
    .exportCSV: "Экспорт CSV",
    .exportJSON: "Экспорт JSON",
    .csvCopied: "CSV скопирован!",
    .jsonCopied: "JSON скопирован!",
    .csvCopiedMessage: "Данные CSV скопированы в буфер обмена.\n\nВставьте их в Excel, Numbers или любой текстовый редактор и сохраните где угодно.",
    .jsonCopiedMessage: "Данные JSON скопированы в буфер обмена.\n\nВставьте их в текстовый редактор и сохраните где угодно.",
    .historyTitle: "История поиска",
    .searchHistoryPlaceholder: "Поиск в истории...",
    .clearAllButton: "Очистить все",
    .closeButton: "Закрыть",
    .deleteButton: "Удалить",
    .noSearches: "Нет сохраненных поисков",
    .noResults: "Результаты не найдены",
    .servicesManagement: "Управление службами",
    .servicesManagementDesc: "Включить или отключить службы поиска для каждой категории",
    .enabledServices: "служб включено",
    .resetDefaults: "Сбросить настройки",
    .categoryIP: "IP",
    .categoryDomain: "Домен",
    .categorySHA: "SHA-256",
    .categoryASN: "ASN",
    .categoryEmail: "Email",
    .openFullApp: "Открыть IOC Analyzer",
    .openFullAppDesc: "Полный анализ с бесплатными API"
]

// MARK: - Chinese Strings
private let chineseStrings: [LocalizedKey: String] = [
    .appTitle: "SOC Lookup Tool",
    .appSubtitle: "Security Operations Center",
    .inputPlaceholder: "粘贴或输入...",
    .inputLabel: "输入: IP / FQDN / SHA-256 / ASN / Email",
    .searchTitle: "执行搜索",
    .ipButton: "IP地址",
    .domainButton: "域名",
    .shaButton: "SHA-256",
    .mxButton: "MX记录",
    .asnButton: "ASN查询",
    .openBackground: "在后台打开",
    .prefillClipboard: "从剪贴板加载",
    .footerVersion: "v3.2",
    .footerTitle: "SOC Enrichment Tool",
    .lastSearch: "上次搜索",
    .clearButton: "清除",
    .refreshButton: "刷新",
    .aboutTitle: "关于SOC Lookup Tool",
    .aboutMessage: "Security Operations Center Lookup Tool\n版本 3.0\n\n在51个威胁情报服务中快速查找IP、域名、哈希等。",
    .quitButton: "退出",
    .openButton: "打开SOC",
    .exportButton: "导出",
    .exportCSV: "导出CSV",
    .exportJSON: "导出JSON",
    .csvCopied: "CSV已复制！",
    .jsonCopied: "JSON已复制！",
    .csvCopiedMessage: "CSV数据已复制到剪贴板。\n\n将其粘贴到Excel、Numbers或任何文本编辑器中，然后保存到您想要的位置。",
    .jsonCopiedMessage: "JSON数据已复制到剪贴板。\n\n将其粘贴到文本编辑器中，然后保存到您想要的位置。",
    .historyTitle: "搜索历史",
    .searchHistoryPlaceholder: "在历史中搜索...",
    .clearAllButton: "全部清除",
    .closeButton: "关闭",
    .deleteButton: "删除",
    .noSearches: "没有保存的搜索",
    .noResults: "未找到结果",
    .servicesManagement: "服务管理",
    .servicesManagementDesc: "为每个类别启用或禁用查找服务",
    .enabledServices: "服务已启用",
    .resetDefaults: "重置默认值",
    .categoryIP: "IP",
    .categoryDomain: "域名",
    .categorySHA: "SHA-256",
    .categoryASN: "ASN",
    .categoryEmail: "Email",
    .openFullApp: "打开 IOC Analyzer",
    .openFullAppDesc: "使用免费API进行完整分析"
]

// MARK: - Japanese Strings
private let japaneseStrings: [LocalizedKey: String] = [
    .appTitle: "SOC Lookup Tool",
    .appSubtitle: "Security Operations Center",
    .inputPlaceholder: "貼り付けまたは入力...",
    .inputLabel: "入力: IP / FQDN / SHA-256 / ASN / Email",
    .searchTitle: "検索を実行",
    .ipButton: "IPアドレス",
    .domainButton: "ドメイン",
    .shaButton: "SHA-256",
    .mxButton: "MXレコード",
    .asnButton: "ASN検索",
    .openBackground: "バックグラウンドで開く",
    .prefillClipboard: "クリップボードから読み込む",
    .footerVersion: "v3.2",
    .footerTitle: "SOC Enrichment Tool",
    .lastSearch: "最後の検索",
    .clearButton: "クリア",
    .refreshButton: "更新",
    .aboutTitle: "SOC Lookup Toolについて",
    .aboutMessage: "Security Operations Center Lookup Tool\nバージョン 3.0\n\n51の脅威インテリジェンスサービスでIP、ドメイン、ハッシュなどを迅速に検索。",
    .quitButton: "終了",
    .openButton: "SOCを開く",
    .exportButton: "エクスポート",
    .exportCSV: "CSVをエクスポート",
    .exportJSON: "JSONをエクスポート",
    .csvCopied: "CSVをコピーしました！",
    .jsonCopied: "JSONをコピーしました！",
    .csvCopiedMessage: "CSVデータがクリップボードにコピーされました。\n\nExcel、Numbers、またはテキストエディタに貼り付けて、好きな場所に保存してください。",
    .jsonCopiedMessage: "JSONデータがクリップボードにコピーされました。\n\nテキストエディタに貼り付けて、好きな場所に保存してください。",
    .historyTitle: "検索履歴",
    .searchHistoryPlaceholder: "履歴を検索...",
    .clearAllButton: "すべてクリア",
    .closeButton: "閉じる",
    .deleteButton: "削除",
    .noSearches: "保存された検索はありません",
    .noResults: "結果が見つかりません",
    .servicesManagement: "サービス管理",
    .servicesManagementDesc: "各カテゴリの検索サービスを有効または無効にする",
    .enabledServices: "サービスが有効",
    .resetDefaults: "デフォルトにリセット",
    .categoryIP: "IP",
    .categoryDomain: "ドメイン",
    .categorySHA: "SHA-256",
    .categoryASN: "ASN",
    .categoryEmail: "Email",
    .openFullApp: "IOC Analyzerを開く",
    .openFullAppDesc: "無料APIで完全分析"
]

// MARK: - Korean Strings
private let koreanStrings: [LocalizedKey: String] = [
    .appTitle: "SOC Lookup Tool",
    .appSubtitle: "Security Operations Center",
    .inputPlaceholder: "붙여넣기 또는 입력...",
    .inputLabel: "입력: IP / FQDN / SHA-256 / ASN / Email",
    .searchTitle: "검색 수행",
    .ipButton: "IP 주소",
    .domainButton: "도메인",
    .shaButton: "SHA-256",
    .mxButton: "MX 레코드",
    .asnButton: "ASN 검색",
    .openBackground: "백그라운드에서 열기",
    .prefillClipboard: "클립보드에서 로드",
    .footerVersion: "v3.2",
    .footerTitle: "SOC Enrichment Tool",
    .lastSearch: "마지막 검색",
    .clearButton: "지우기",
    .refreshButton: "새로고침",
    .aboutTitle: "SOC Lookup Tool 정보",
    .aboutMessage: "Security Operations Center Lookup Tool\n버전 3.0\n\n51개의 위협 인텔리전스 서비스에서 IP, 도메인, 해시 등을 빠르게 검색합니다.",
    .quitButton: "종료",
    .openButton: "SOC 열기",
    .exportButton: "내보내기",
    .exportCSV: "CSV 내보내기",
    .exportJSON: "JSON 내보내기",
    .csvCopied: "CSV 복사됨!",
    .jsonCopied: "JSON 복사됨!",
    .csvCopiedMessage: "CSV 데이터가 클립보드에 복사되었습니다.\n\nExcel, Numbers 또는 텍스트 편집기에 붙여넣고 원하는 곳에 저장하세요.",
    .jsonCopiedMessage: "JSON 데이터가 클립보드에 복사되었습니다.\n\n텍스트 편집기에 붙여넣고 원하는 곳에 저장하세요.",
    .historyTitle: "검색 기록",
    .searchHistoryPlaceholder: "기록에서 검색...",
    .clearAllButton: "모두 지우기",
    .closeButton: "닫기",
    .deleteButton: "삭제",
    .noSearches: "저장된 검색이 없습니다",
    .noResults: "결과를 찾을 수 없습니다",
    .servicesManagement: "서비스 관리",
    .servicesManagementDesc: "각 카테고리의 조회 서비스를 활성화 또는 비활성화",
    .enabledServices: "서비스 활성화됨",
    .resetDefaults: "기본값으로 재설정",
    .categoryIP: "IP",
    .categoryDomain: "도메인",
    .categorySHA: "SHA-256",
    .categoryASN: "ASN",
    .categoryEmail: "Email",
    .openFullApp: "IOC Analyzer 열기",
    .openFullAppDesc: "무료 API로 완전한 분석"
]

// MARK: - Arabic Strings
private let arabicStrings: [LocalizedKey: String] = [
    .appTitle: "SOC Lookup Tool",
    .appSubtitle: "Security Operations Center",
    .inputPlaceholder: "الصق أو اكتب هنا...",
    .inputLabel: "أدخل: IP / FQDN / SHA-256 / ASN / البريد الإلكتروني",
    .searchTitle: "تنفيذ البحث",
    .ipButton: "عنوان IP",
    .domainButton: "النطاق",
    .shaButton: "SHA-256",
    .mxButton: "سجلات MX",
    .asnButton: "بحث ASN",
    .openBackground: "فتح في الخلفية",
    .prefillClipboard: "التحميل من الحافظة",
    .footerVersion: "v3.2",
    .footerTitle: "SOC Enrichment Tool",
    .lastSearch: "آخر بحث",
    .clearButton: "مسح",
    .refreshButton: "تحديث",
    .aboutTitle: "حول SOC Lookup Tool",
    .aboutMessage: "Security Operations Center Lookup Tool\nالإصدار 3.0\n\nبحث سريع عن عناوين IP والنطاقات والهاشات والمزيد عبر 51 خدمة استخبارات التهديدات.",
    .quitButton: "خروج",
    .openButton: "فتح SOC",
    .exportButton: "تصدير",
    .exportCSV: "تصدير CSV",
    .exportJSON: "تصدير JSON",
    .csvCopied: "تم نسخ CSV!",
    .jsonCopied: "تم نسخ JSON!",
    .csvCopiedMessage: "تم نسخ بيانات CSV إلى الحافظة.\n\nالصقها في Excel أو Numbers أو أي محرر نصوص واحفظها أينما تريد.",
    .jsonCopiedMessage: "تم نسخ بيانات JSON إلى الحافظة.\n\nالصقها في محرر نصوص واحفظها أينما تريد.",
    .historyTitle: "سجل البحث",
    .searchHistoryPlaceholder: "البحث في السجل...",
    .clearAllButton: "مسح الكل",
    .closeButton: "إغلاق",
    .deleteButton: "حذف",
    .noSearches: "لا توجد عمليات بحث محفوظة",
    .noResults: "لم يتم العثور على نتائج",
    .servicesManagement: "إدارة الخدمات",
    .servicesManagementDesc: "تمكين أو تعطيل خدمات البحث لكل فئة",
    .enabledServices: "الخدمات مفعلة",
    .resetDefaults: "إعادة تعيين الافتراضيات",
    .categoryIP: "IP",
    .categoryDomain: "النطاق",
    .categorySHA: "SHA-256",
    .categoryASN: "ASN",
    .categoryEmail: "البريد الإلكتروني",
    .openFullApp: "افتح IOC Analyzer",
    .openFullAppDesc: "تحليل كامل مع واجهات برمجة التطبيقات المجانية"
]

// MARK: - Hindi Strings
private let hindiStrings: [LocalizedKey: String] = [
    .appTitle: "SOC Lookup Tool",
    .appSubtitle: "Security Operations Center",
    .inputPlaceholder: "यहाँ पेस्ट करें या टाइप करें...",
    .inputLabel: "दर्ज करें: IP / FQDN / SHA-256 / ASN / Email",
    .searchTitle: "खोज करें",
    .ipButton: "IP पता",
    .domainButton: "डोमेन",
    .shaButton: "SHA-256",
    .mxButton: "MX रिकॉर्ड",
    .asnButton: "ASN खोज",
    .openBackground: "पृष्ठभूमि में खोलें",
    .prefillClipboard: "क्लिपबोर्ड से लोड करें",
    .footerVersion: "v3.2",
    .footerTitle: "SOC Enrichment Tool",
    .lastSearch: "अंतिम खोज",
    .clearButton: "साफ़ करें",
    .refreshButton: "रीफ्रेश करें",
    .aboutTitle: "SOC Lookup Tool के बारे में",
    .aboutMessage: "Security Operations Center Lookup Tool\nसंस्करण 3.0\n\n51 थ्रेट इंटेलिजेंस सेवाओं में IP, डोमेन, हैश और अधिक की त्वरित खोज।",
    .quitButton: "बाहर निकलें",
    .openButton: "SOC खोलें",
    .exportButton: "निर्यात",
    .exportCSV: "CSV निर्यात करें",
    .exportJSON: "JSON निर्यात करें",
    .csvCopied: "CSV कॉपी किया गया!",
    .jsonCopied: "JSON कॉपी किया गया!",
    .csvCopiedMessage: "CSV डेटा क्लिपबोर्ड में कॉपी किया गया है।\n\nइसे Excel, Numbers या किसी भी टेक्स्ट एडिटर में पेस्ट करें और जहाँ चाहें सेव करें।",
    .jsonCopiedMessage: "JSON डेटा क्लिपबोर्ड में कॉपी किया गया है।\n\nइसे टेक्स्ट एडिटर में पेस्ट करें और जहाँ चाहें सेव करें।",
    .historyTitle: "खोज इतिहास",
    .searchHistoryPlaceholder: "इतिहास में खोजें...",
    .clearAllButton: "सभी साफ़ करें",
    .closeButton: "बंद करें",
    .deleteButton: "हटाएं",
    .noSearches: "कोई खोज सहेजी नहीं गई",
    .noResults: "कोई परिणाम नहीं मिला",
    .servicesManagement: "सेवा प्रबंधन",
    .servicesManagementDesc: "प्रत्येक श्रेणी के लिए लुकअप सेवाओं को सक्षम या अक्षम करें",
    .enabledServices: "सेवाएं सक्षम",
    .resetDefaults: "डिफ़ॉल्ट रीसेट करें",
    .categoryIP: "IP",
    .categoryDomain: "डोमेन",
    .categorySHA: "SHA-256",
    .categoryASN: "ASN",
    .categoryEmail: "Email",
    .openFullApp: "IOC Analyzer खोलें",
    .openFullAppDesc: "मुफ्त API के साथ पूर्ण विश्लेषण"
]

// MARK: - Greek Strings
private let greekStrings: [LocalizedKey: String] = [
    .appTitle: "SOC Lookup Tool",
    .appSubtitle: "Security Operations Center",
    .inputPlaceholder: "Επικολλήστε ή πληκτρολογήστε εδώ...",
    .inputLabel: "Εισάγετε: IP / FQDN / SHA-256 / ASN / Email",
    .searchTitle: "Εκτέλεση αναζήτησης",
    .ipButton: "Διεύθυνση IP",
    .domainButton: "Τομέας",
    .shaButton: "SHA-256",
    .mxButton: "Εγγραφές MX",
    .asnButton: "Αναζήτηση ASN",
    .openBackground: "Άνοιγμα στο παρασκήνιο",
    .prefillClipboard: "Φόρτωση από πρόχειρο",
    .footerVersion: "v3.2",
    .footerTitle: "SOC Enrichment Tool",
    .lastSearch: "Τελευταία αναζήτηση",
    .clearButton: "Εκκαθάριση",
    .refreshButton: "Ανανέωση",
    .aboutTitle: "Σχετικά με το SOC Lookup Tool",
    .aboutMessage: "Security Operations Center Lookup Tool\nΈκδοση 3.0\n\nΓρήγορη αναζήτηση IPs, τομέων, hashes και άλλων σε 51 υπηρεσίες πληροφοριών απειλών.",
    .quitButton: "Έξοδος",
    .openButton: "Άνοιγμα SOC",
    .exportButton: "Εξαγωγή",
    .exportCSV: "Εξαγωγή CSV",
    .exportJSON: "Εξαγωγή JSON",
    .csvCopied: "Το CSV αντιγράφηκε!",
    .jsonCopied: "Το JSON αντιγράφηκε!",
    .csvCopiedMessage: "Τα δεδομένα CSV αντιγράφηκαν στο πρόχειρο.\n\nΕπικολλήστε τα στο Excel, Numbers ή οποιοδήποτε πρόγραμμα επεξεργασίας κειμένου και αποθηκεύστε όπου θέλετε.",
    .jsonCopiedMessage: "Τα δεδομένα JSON αντιγράφηκαν στο πρόχειρο.\n\nΕπικολλήστε τα σε πρόγραμμα επεξεργασίας κειμένου και αποθηκεύστε όπου θέλετε.",
    .historyTitle: "Ιστορικό αναζήτησης",
    .searchHistoryPlaceholder: "Αναζήτηση στο ιστορικό...",
    .clearAllButton: "Εκκαθάριση όλων",
    .closeButton: "Κλείσιμο",
    .deleteButton: "Διαγραφή",
    .noSearches: "Δεν υπάρχουν αποθηκευμένες αναζητήσεις",
    .noResults: "Δεν βρέθηκαν αποτελέσματα",
    .servicesManagement: "Διαχείριση υπηρεσιών",
    .servicesManagementDesc: "Ενεργοποιήστε ή απενεργοποιήστε τις υπηρεσίες αναζήτησης για κάθε κατηγορία",
    .enabledServices: "υπηρεσίες ενεργοποιημένες",
    .resetDefaults: "Επαναφορά προεπιλογών",
    .categoryIP: "IP",
    .categoryDomain: "Τομέας",
    .categorySHA: "SHA-256",
    .categoryASN: "ASN",
    .categoryEmail: "Email",
    .openFullApp: "Άνοιγμα IOC Analyzer",
    .openFullAppDesc: "Πλήρης ανάλυση με δωρεάν APIs"
]
