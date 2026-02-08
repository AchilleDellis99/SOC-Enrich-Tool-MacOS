//
//  IOCAnalyzerView.swift
//  SOC
//
//  Full IOC Analysis with free APIs - v3.2
//

import SwiftUI
import AppKit

// MARK: - Window Controller

class IOCAnalyzerWindowController: NSWindowController, NSWindowDelegate {
    static var sharedInput: String = ""
    static var sharedInstance: IOCAnalyzerWindowController?
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 750, height: 650),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false
        )
        window.title = "IOC Analyzer"
        window.center()
        window.contentView = NSHostingView(rootView: IOCAnalyzerView())
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 650, height: 550)
        self.init(window: window)
        window.delegate = self
    }
    
    static func show(withInput input: String = "") {
        // Enter traditional mode
        AppModeManager.shared.enterTraditionalMode()
        
        sharedInput = input
        
        if sharedInstance == nil {
            sharedInstance = IOCAnalyzerWindowController()
        }
        
        sharedInstance?.showWindow(nil)
        sharedInstance?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // Called when window is closed
    func windowWillClose(_ notification: Notification) {
        // Exit traditional mode and return to menu bar only
        AppModeManager.shared.exitTraditionalMode()
    }
}

// MARK: - Localized Strings

struct L10n {
    static func get(_ key: Key, for lang: AppLanguage) -> String {
        return strings[lang]?[key] ?? strings[.english]![key]!
    }
    
    enum Key {
        case title, subtitle, enterIOC, detected, analyze, analyzing, clearResults
        case apiKeys, apiKeysConfig, apiKeysInfo, getKey, freeAPIs, done
        case overallVerdict, sourcesAnalyzed, analysisResults, urlRedirectChain
        case limitedRequests, clean, suspicious, malicious, unknown
        case pasteClipboard, requestsDay, viewOn
    }
    
    static let strings: [AppLanguage: [Key: String]] = [
        .english: [
            .title: "IOC Analyzer", .subtitle: "Threat Intelligence Analysis",
            .enterIOC: "Enter IOC to analyze", .detected: "Detected",
            .analyze: "Analyze IOC", .analyzing: "Analyzing...",
            .clearResults: "Clear Results", .apiKeys: "API Keys",
            .apiKeysConfig: "API Keys Configuration",
            .apiKeysInfo: "Add API keys for additional threat intelligence. All APIs offer free tiers.",
            .getKey: "Get Key", .freeAPIs: "Free APIs (No Key Required)",
            .done: "Done", .overallVerdict: "Overall Verdict",
            .sourcesAnalyzed: "sources analyzed", .analysisResults: "Analysis Results",
            .urlRedirectChain: "URL Redirect Chain",
            .limitedRequests: "Free tier APIs • Limited requests per day",
            .clean: "Clean", .suspicious: "Suspicious", .malicious: "Malicious",
            .unknown: "Unknown", .pasteClipboard: "Paste from clipboard",
            .requestsDay: "requests/day free", .viewOn: "View on"
        ],
        .italian: [
            .title: "IOC Analyzer", .subtitle: "Analisi Threat Intelligence",
            .enterIOC: "Inserisci IOC da analizzare", .detected: "Rilevato",
            .analyze: "Analizza IOC", .analyzing: "Analisi in corso...",
            .clearResults: "Cancella Risultati", .apiKeys: "Chiavi API",
            .apiKeysConfig: "Configurazione Chiavi API",
            .apiKeysInfo: "Aggiungi le chiavi API per ulteriori fonti di intelligence. Tutte le API offrono tier gratuiti.",
            .getKey: "Ottieni Chiave", .freeAPIs: "API Gratuite (Senza Chiave)",
            .done: "Fatto", .overallVerdict: "Verdetto Complessivo",
            .sourcesAnalyzed: "fonti analizzate", .analysisResults: "Risultati Analisi",
            .urlRedirectChain: "Catena Redirect URL",
            .limitedRequests: "API gratuite • Richieste limitate al giorno",
            .clean: "Pulito", .suspicious: "Sospetto", .malicious: "Malevolo",
            .unknown: "Sconosciuto", .pasteClipboard: "Incolla da appunti",
            .requestsDay: "richieste/giorno gratis", .viewOn: "Vedi su"
        ],
        .spanish: [
            .title: "IOC Analyzer", .subtitle: "Análisis de Inteligencia de Amenazas",
            .enterIOC: "Ingrese IOC para analizar", .detected: "Detectado",
            .analyze: "Analizar IOC", .analyzing: "Analizando...",
            .clearResults: "Limpiar Resultados", .apiKeys: "Claves API",
            .apiKeysConfig: "Configuración de Claves API",
            .apiKeysInfo: "Agregue claves API para fuentes adicionales. Todas ofrecen niveles gratuitos.",
            .getKey: "Obtener Clave", .freeAPIs: "APIs Gratuitas (Sin Clave)",
            .done: "Hecho", .overallVerdict: "Veredicto General",
            .sourcesAnalyzed: "fuentes analizadas", .analysisResults: "Resultados del Análisis",
            .urlRedirectChain: "Cadena de Redirección URL",
            .limitedRequests: "APIs gratuitas • Solicitudes limitadas por día",
            .clean: "Limpio", .suspicious: "Sospechoso", .malicious: "Malicioso",
            .unknown: "Desconocido", .pasteClipboard: "Pegar del portapapeles",
            .requestsDay: "solicitudes/día gratis", .viewOn: "Ver en"
        ],
        .german: [
            .title: "IOC Analyzer", .subtitle: "Bedrohungsanalyse",
            .enterIOC: "IOC zur Analyse eingeben", .detected: "Erkannt",
            .analyze: "IOC Analysieren", .analyzing: "Analyse läuft...",
            .clearResults: "Ergebnisse löschen", .apiKeys: "API-Schlüssel",
            .apiKeysConfig: "API-Schlüssel Konfiguration",
            .apiKeysInfo: "Fügen Sie API-Schlüssel hinzu. Alle APIs bieten kostenlose Stufen.",
            .getKey: "Schlüssel holen", .freeAPIs: "Kostenlose APIs (Kein Schlüssel)",
            .done: "Fertig", .overallVerdict: "Gesamturteil",
            .sourcesAnalyzed: "Quellen analysiert", .analysisResults: "Analyseergebnisse",
            .urlRedirectChain: "URL-Weiterleitungskette",
            .limitedRequests: "Kostenlose APIs • Begrenzte Anfragen pro Tag",
            .clean: "Sauber", .suspicious: "Verdächtig", .malicious: "Bösartig",
            .unknown: "Unbekannt", .pasteClipboard: "Aus Zwischenablage einfügen",
            .requestsDay: "Anfragen/Tag kostenlos", .viewOn: "Ansehen auf"
        ],
        .french: [
            .title: "IOC Analyzer", .subtitle: "Analyse de Renseignement sur les Menaces",
            .enterIOC: "Entrez l'IOC à analyser", .detected: "Détecté",
            .analyze: "Analyser IOC", .analyzing: "Analyse en cours...",
            .clearResults: "Effacer les Résultats", .apiKeys: "Clés API",
            .apiKeysConfig: "Configuration des Clés API",
            .apiKeysInfo: "Ajoutez des clés API pour des sources supplémentaires. Toutes offrent des niveaux gratuits.",
            .getKey: "Obtenir Clé", .freeAPIs: "APIs Gratuites (Sans Clé)",
            .done: "Terminé", .overallVerdict: "Verdict Global",
            .sourcesAnalyzed: "sources analysées", .analysisResults: "Résultats de l'Analyse",
            .urlRedirectChain: "Chaîne de Redirection URL",
            .limitedRequests: "APIs gratuites • Requêtes limitées par jour",
            .clean: "Propre", .suspicious: "Suspect", .malicious: "Malveillant",
            .unknown: "Inconnu", .pasteClipboard: "Coller du presse-papiers",
            .requestsDay: "requêtes/jour gratuites", .viewOn: "Voir sur"
        ],
        .portuguese: [
            .title: "IOC Analyzer", .subtitle: "Análise de Inteligência de Ameaças",
            .enterIOC: "Insira IOC para analisar", .detected: "Detectado",
            .analyze: "Analisar IOC", .analyzing: "Analisando...",
            .clearResults: "Limpar Resultados", .apiKeys: "Chaves API",
            .apiKeysConfig: "Configuração de Chaves API",
            .apiKeysInfo: "Adicione chaves API para fontes adicionais. Todas oferecem níveis gratuitos.",
            .getKey: "Obter Chave", .freeAPIs: "APIs Gratuitas (Sem Chave)",
            .done: "Concluído", .overallVerdict: "Veredicto Geral",
            .sourcesAnalyzed: "fontes analisadas", .analysisResults: "Resultados da Análise",
            .urlRedirectChain: "Cadeia de Redirecionamento URL",
            .limitedRequests: "APIs gratuitas • Solicitações limitadas por dia",
            .clean: "Limpo", .suspicious: "Suspeito", .malicious: "Malicioso",
            .unknown: "Desconhecido", .pasteClipboard: "Colar da área de transferência",
            .requestsDay: "solicitações/dia grátis", .viewOn: "Ver em"
        ],
        .russian: [
            .title: "IOC Analyzer", .subtitle: "Анализ угроз",
            .enterIOC: "Введите IOC для анализа", .detected: "Обнаружено",
            .analyze: "Анализировать", .analyzing: "Анализ...",
            .clearResults: "Очистить", .apiKeys: "API ключи",
            .apiKeysConfig: "Настройка API ключей",
            .apiKeysInfo: "Добавьте API ключи для дополнительных источников. Все API имеют бесплатные уровни.",
            .getKey: "Получить ключ", .freeAPIs: "Бесплатные API (Без ключа)",
            .done: "Готово", .overallVerdict: "Общий вердикт",
            .sourcesAnalyzed: "источников", .analysisResults: "Результаты анализа",
            .urlRedirectChain: "Цепочка перенаправлений",
            .limitedRequests: "Бесплатные API • Ограниченные запросы в день",
            .clean: "Чисто", .suspicious: "Подозрительно", .malicious: "Вредоносно",
            .unknown: "Неизвестно", .pasteClipboard: "Вставить из буфера",
            .requestsDay: "запросов/день", .viewOn: "Смотреть на"
        ],
        .chinese: [
            .title: "IOC 分析器", .subtitle: "威胁情报分析",
            .enterIOC: "输入要分析的IOC", .detected: "已检测",
            .analyze: "分析IOC", .analyzing: "分析中...",
            .clearResults: "清除结果", .apiKeys: "API密钥",
            .apiKeysConfig: "API密钥配置",
            .apiKeysInfo: "添加API密钥以获取更多威胁情报。所有API都提供免费套餐。",
            .getKey: "获取密钥", .freeAPIs: "免费API（无需密钥）",
            .done: "完成", .overallVerdict: "综合判定",
            .sourcesAnalyzed: "个来源已分析", .analysisResults: "分析结果",
            .urlRedirectChain: "URL重定向链",
            .limitedRequests: "免费API • 每日请求有限",
            .clean: "安全", .suspicious: "可疑", .malicious: "恶意",
            .unknown: "未知", .pasteClipboard: "从剪贴板粘贴",
            .requestsDay: "请求/天", .viewOn: "查看"
        ],
        .japanese: [
            .title: "IOC アナライザー", .subtitle: "脅威インテリジェンス分析",
            .enterIOC: "分析するIOCを入力", .detected: "検出済み",
            .analyze: "IOCを分析", .analyzing: "分析中...",
            .clearResults: "結果をクリア", .apiKeys: "APIキー",
            .apiKeysConfig: "APIキー設定",
            .apiKeysInfo: "追加の脅威情報源のためにAPIキーを追加。すべて無料枠があります。",
            .getKey: "キーを取得", .freeAPIs: "無料API（キー不要）",
            .done: "完了", .overallVerdict: "総合判定",
            .sourcesAnalyzed: "ソースを分析", .analysisResults: "分析結果",
            .urlRedirectChain: "URLリダイレクトチェーン",
            .limitedRequests: "無料API • 1日のリクエスト数に制限",
            .clean: "安全", .suspicious: "疑わしい", .malicious: "悪意あり",
            .unknown: "不明", .pasteClipboard: "クリップボードから貼り付け",
            .requestsDay: "リクエスト/日", .viewOn: "表示"
        ],
        .korean: [
            .title: "IOC 분석기", .subtitle: "위협 인텔리전스 분석",
            .enterIOC: "분석할 IOC 입력", .detected: "감지됨",
            .analyze: "IOC 분석", .analyzing: "분석 중...",
            .clearResults: "결과 지우기", .apiKeys: "API 키",
            .apiKeysConfig: "API 키 설정",
            .apiKeysInfo: "추가 위협 정보 소스를 위해 API 키를 추가하세요. 모두 무료 티어가 있습니다.",
            .getKey: "키 받기", .freeAPIs: "무료 API (키 불필요)",
            .done: "완료", .overallVerdict: "종합 판정",
            .sourcesAnalyzed: "개 소스 분석됨", .analysisResults: "분석 결과",
            .urlRedirectChain: "URL 리다이렉트 체인",
            .limitedRequests: "무료 API • 일일 요청 제한",
            .clean: "안전", .suspicious: "의심스러움", .malicious: "악성",
            .unknown: "알 수 없음", .pasteClipboard: "클립보드에서 붙여넣기",
            .requestsDay: "요청/일", .viewOn: "보기"
        ],
        .arabic: [
            .title: "محلل IOC", .subtitle: "تحليل استخبارات التهديدات",
            .enterIOC: "أدخل IOC للتحليل", .detected: "تم الكشف",
            .analyze: "تحليل IOC", .analyzing: "جاري التحليل...",
            .clearResults: "مسح النتائج", .apiKeys: "مفاتيح API",
            .apiKeysConfig: "تكوين مفاتيح API",
            .apiKeysInfo: "أضف مفاتيح API لمصادر إضافية. جميعها توفر مستويات مجانية.",
            .getKey: "احصل على مفتاح", .freeAPIs: "APIs مجانية (بدون مفتاح)",
            .done: "تم", .overallVerdict: "الحكم العام",
            .sourcesAnalyzed: "مصادر تم تحليلها", .analysisResults: "نتائج التحليل",
            .urlRedirectChain: "سلسلة إعادة توجيه URL",
            .limitedRequests: "APIs مجانية • طلبات محدودة يومياً",
            .clean: "نظيف", .suspicious: "مشبوه", .malicious: "ضار",
            .unknown: "غير معروف", .pasteClipboard: "لصق من الحافظة",
            .requestsDay: "طلبات/يوم", .viewOn: "عرض على"
        ],
        .hindi: [
            .title: "IOC विश्लेषक", .subtitle: "खतरा इंटेलिजेंस विश्लेषण",
            .enterIOC: "विश्लेषण के लिए IOC दर्ज करें", .detected: "पता चला",
            .analyze: "IOC विश्लेषण", .analyzing: "विश्लेषण हो रहा है...",
            .clearResults: "परिणाम साफ़ करें", .apiKeys: "API कुंजियाँ",
            .apiKeysConfig: "API कुंजी विन्यास",
            .apiKeysInfo: "अतिरिक्त स्रोतों के लिए API कुंजियाँ जोड़ें। सभी मुफ्त टियर प्रदान करती हैं।",
            .getKey: "कुंजी प्राप्त करें", .freeAPIs: "मुफ्त APIs (कुंजी की आवश्यकता नहीं)",
            .done: "हो गया", .overallVerdict: "समग्र निर्णय",
            .sourcesAnalyzed: "स्रोत विश्लेषित", .analysisResults: "विश्लेषण परिणाम",
            .urlRedirectChain: "URL रीडायरेक्ट श्रृंखला",
            .limitedRequests: "मुफ्त APIs • प्रतिदिन सीमित अनुरोध",
            .clean: "सुरक्षित", .suspicious: "संदिग्ध", .malicious: "दुर्भावनापूर्ण",
            .unknown: "अज्ञात", .pasteClipboard: "क्लिपबोर्ड से चिपकाएँ",
            .requestsDay: "अनुरोध/दिन", .viewOn: "देखें"
        ],
        .greek: [
            .title: "IOC Αναλυτής", .subtitle: "Ανάλυση Πληροφοριών Απειλών",
            .enterIOC: "Εισάγετε IOC για ανάλυση", .detected: "Ανιχνεύθηκε",
            .analyze: "Ανάλυση IOC", .analyzing: "Ανάλυση...",
            .clearResults: "Καθαρισμός", .apiKeys: "Κλειδιά API",
            .apiKeysConfig: "Ρύθμιση Κλειδιών API",
            .apiKeysInfo: "Προσθέστε κλειδιά API για επιπλέον πηγές. Όλα προσφέρουν δωρεάν επίπεδα.",
            .getKey: "Λήψη Κλειδιού", .freeAPIs: "Δωρεάν APIs (Χωρίς Κλειδί)",
            .done: "Τέλος", .overallVerdict: "Συνολική Ετυμηγορία",
            .sourcesAnalyzed: "πηγές αναλύθηκαν", .analysisResults: "Αποτελέσματα",
            .urlRedirectChain: "Αλυσίδα Ανακατεύθυνσης",
            .limitedRequests: "Δωρεάν APIs • Περιορισμένα αιτήματα",
            .clean: "Καθαρό", .suspicious: "Ύποπτο", .malicious: "Κακόβουλο",
            .unknown: "Άγνωστο", .pasteClipboard: "Επικόλληση από πρόχειρο",
            .requestsDay: "αιτήματα/ημέρα", .viewOn: "Προβολή σε"
        ]
    ]
}

// MARK: - Threat Level

enum ThreatLevel: Int, Comparable {
    case unknown = 0, clean = 1, suspicious = 2, malicious = 3
    
    static func < (lhs: ThreatLevel, rhs: ThreatLevel) -> Bool { lhs.rawValue < rhs.rawValue }
    
    var color: Color {
        switch self {
        case .unknown: return .gray
        case .clean: return .green
        case .suspicious: return .orange
        case .malicious: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .unknown: return "questionmark.circle.fill"
        case .clean: return "checkmark.shield.fill"
        case .suspicious: return "exclamationmark.triangle.fill"
        case .malicious: return "xmark.shield.fill"
        }
    }
    
    func name(for lang: AppLanguage) -> String {
        switch self {
        case .unknown: return L10n.get(.unknown, for: lang)
        case .clean: return L10n.get(.clean, for: lang)
        case .suspicious: return L10n.get(.suspicious, for: lang)
        case .malicious: return L10n.get(.malicious, for: lang)
        }
    }
    
    var rawString: String {
        switch self {
        case .unknown: return "unknown"
        case .clean: return "clean"
        case .suspicious: return "suspicious"
        case .malicious: return "malicious"
        }
    }
}

// MARK: - Models

struct AnalysisResult: Identifiable {
    let id = UUID()
    let source: String
    let sourceIcon: String
    let threatLevel: ThreatLevel
    let details: String
    let link: String?
    let timestamp = Date()
    
    init(source: String, sourceIcon: String, threatLevel: ThreatLevel, details: String, link: String? = nil) {
        self.source = source
        self.sourceIcon = sourceIcon
        self.threatLevel = threatLevel
        self.details = details
        self.link = link
    }
}

struct UnshortenerResult {
    let originalURL: String
    let finalURL: String
    let redirectChain: [String]
    let threatLevel: ThreatLevel
}

// MARK: - API Keys Manager

class APIKeysManager: ObservableObject {
    static let shared = APIKeysManager()
    
    @Published var virusTotalAPIKey: String {
        didSet { UserDefaults.standard.set(virusTotalAPIKey, forKey: "vtAPIKey") }
    }
    @Published var abuseIPDBAPIKey: String {
        didSet { UserDefaults.standard.set(abuseIPDBAPIKey, forKey: "abuseIPDBAPIKey") }
    }
    @Published var alienVaultOTXAPIKey: String {
        didSet { UserDefaults.standard.set(alienVaultOTXAPIKey, forKey: "otxAPIKey") }
    }
    
    private init() {
        virusTotalAPIKey = UserDefaults.standard.string(forKey: "vtAPIKey") ?? ""
        abuseIPDBAPIKey = UserDefaults.standard.string(forKey: "abuseIPDBAPIKey") ?? ""
        alienVaultOTXAPIKey = UserDefaults.standard.string(forKey: "otxAPIKey") ?? ""
    }
}

// MARK: - IOC Analyzer Service

class IOCAnalyzerService: ObservableObject {
    static let shared = IOCAnalyzerService()
    
    @Published var isAnalyzing = false
    @Published var results: [AnalysisResult] = []
    @Published var overallThreatLevel: ThreatLevel = .unknown
    @Published var unshortenerResult: UnshortenerResult?
    @Published var analysisProgress: Double = 0
    @Published var currentTask: String = ""
    
    private let apiKeys = APIKeysManager.shared
    private let urlShorteners = ["bit.ly", "tinyurl.com", "t.co", "goo.gl", "ow.ly", "is.gd", "buff.ly", "adf.ly", "bit.do", "tiny.cc", "j.mp", "ad.fly", "shorturl.at", "rb.gy", "cutt.ly", "t.ly"]
    
    func analyzeIOC(_ input: String) async {
        await MainActor.run {
            isAnalyzing = true
            results = []
            overallThreatLevel = .unknown
            unshortenerResult = nil
            analysisProgress = 0
            currentTask = "Detecting IOC type..."
        }
        
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let validation = InputValidator.validate(trimmed)
        
        guard validation.isValid, let iocType = validation.detectedType else {
            await MainActor.run {
                results.append(AnalysisResult(source: "Validation", sourceIcon: "exclamationmark.triangle", threatLevel: .unknown, details: "Could not determine IOC type."))
                isAnalyzing = false
            }
            return
        }
        
        // Check for shortened URL
        if iocType == .domain || trimmed.contains("/") {
            let domain = extractDomain(from: trimmed)
            if urlShorteners.contains(where: { domain.lowercased().contains($0) }) {
                await unshortenURL(trimmed)
            }
        }
        
        switch iocType {
        case .ip: await analyzeIP(trimmed)
        case .domain: await analyzeDomain(trimmed)
        case .sha: await analyzeHash(trimmed)
        case .mail: await analyzeEmail(trimmed)
        case .asn: await analyzeASN(trimmed)
        }
        
        await MainActor.run {
            overallThreatLevel = results.map { $0.threatLevel }.max() ?? .unknown
            isAnalyzing = false
            analysisProgress = 1.0
            
            // Save to history
            let typeString: String
            switch iocType {
            case .ip: typeString = "IP"
            case .domain: typeString = "Domain"
            case .sha: typeString = "SHA-256"
            case .mail: typeString = "Email"
            case .asn: typeString = "ASN"
            }
            
            IOCAnalyzerHistoryManager.shared.addRecord(
                value: trimmed,
                type: typeString,
                verdict: overallThreatLevel.rawString,
                sourcesCount: results.count,
                source: "analyzer"
            )
        }
    }
    
    // MARK: - URL Unshortener
    
    private func unshortenURL(_ urlString: String) async {
        var url = urlString
        if !url.hasPrefix("http") { url = "https://\(url)" }
        guard let startURL = URL(string: url) else { return }
        
        var chain: [String] = [url]
        var currentURL = startURL
        var maxRedirects = 10
        
        while maxRedirects > 0 {
            maxRedirects -= 1
            var request = URLRequest(url: currentURL)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 10
            
            let config = URLSessionConfiguration.default
            config.httpShouldSetCookies = false
            let session = URLSession(configuration: config, delegate: RedirectBlocker(), delegateQueue: nil)
            
            do {
                let (_, response) = try await session.data(for: request)
                if let http = response as? HTTPURLResponse, (300...399).contains(http.statusCode),
                   let location = http.value(forHTTPHeaderField: "Location"),
                   let nextURL = location.hasPrefix("http") ? URL(string: location) : URL(string: location, relativeTo: currentURL) {
                    chain.append(nextURL.absoluteString)
                    currentURL = nextURL
                } else { break }
            } catch { break }
        }
        
        let finalURL = chain.last ?? url
        await MainActor.run {
            unshortenerResult = UnshortenerResult(originalURL: url, finalURL: finalURL, redirectChain: chain, threatLevel: .unknown)
            if chain.count > 1 {
                results.append(AnalysisResult(source: "URL Unshortener", sourceIcon: "link", threatLevel: .unknown, details: "Resolved \(chain.count - 1) redirect(s).\nFinal: \(finalURL)"))
            }
        }
    }
    
    // MARK: - IP Analysis
    
    private func analyzeIP(_ ip: String) async {
        let isIPv6 = ip.contains(":")
        
        // IPInfo
        await MainActor.run { currentTask = "Querying IPInfo..."; analysisProgress = 0.1 }
        if let url = URL(string: "https://ipinfo.io/\(ip)/json") {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let details = "IP: \(ip)\nCity: \(json["city"] ?? "N/A")\nRegion: \(json["region"] ?? "N/A")\nCountry: \(json["country"] ?? "N/A")\nOrg: \(json["org"] ?? "N/A")"
                    await MainActor.run {
                        results.append(AnalysisResult(source: "IPInfo", sourceIcon: "globe", threatLevel: .clean, details: details, link: "https://ipinfo.io/\(ip)"))
                    }
                }
            } catch {}
        }
        
        // HackerTarget ASN
        if !isIPv6 {
            await MainActor.run { currentTask = "Querying ASN..."; analysisProgress = 0.2 }
            if let url = URL(string: "https://api.hackertarget.com/aslookup/?q=\(ip)") {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let text = String(data: data, encoding: .utf8), !text.contains("error") {
                        let parts = text.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ",")
                        let asn = parts.first?.replacingOccurrences(of: "\"", with: "") ?? "N/A"
                        let org = parts.dropFirst().joined(separator: ",").replacingOccurrences(of: "\"", with: "")
                        await MainActor.run {
                            results.append(AnalysisResult(source: "ASN Lookup", sourceIcon: "building.2", threatLevel: .clean, details: "ASN: \(asn)\nOrg: \(org)", link: "https://mxtoolbox.com/SuperTool.aspx?action=asn%3a\(ip)"))
                        }
                    }
                } catch {}
            }
        }
        
        // AbuseIPDB
        if !apiKeys.abuseIPDBAPIKey.isEmpty {
            await MainActor.run { currentTask = "Querying AbuseIPDB..."; analysisProgress = 0.4 }
            if let url = URL(string: "https://api.abuseipdb.com/api/v2/check?ipAddress=\(ip)&maxAgeInDays=90") {
                var request = URLRequest(url: url)
                request.setValue(apiKeys.abuseIPDBAPIKey, forHTTPHeaderField: "Key")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                do {
                    let (data, _) = try await URLSession.shared.data(for: request)
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let d = json["data"] as? [String: Any] {
                        let score = d["abuseConfidenceScore"] as? Int ?? 0
                        let reports = d["totalReports"] as? Int ?? 0
                        let threat: ThreatLevel = score >= 75 ? .malicious : (score >= 25 ? .suspicious : .clean)
                        await MainActor.run {
                            results.append(AnalysisResult(source: "AbuseIPDB", sourceIcon: "exclamationmark.shield", threatLevel: threat, details: "Abuse Score: \(score)%\nReports: \(reports)\nCountry: \(d["countryCode"] ?? "N/A")\nISP: \(d["isp"] ?? "N/A")", link: "https://www.abuseipdb.com/check/\(ip)"))
                        }
                    }
                } catch {}
            }
        }
        
        // VirusTotal
        if !apiKeys.virusTotalAPIKey.isEmpty {
            await MainActor.run { currentTask = "Querying VirusTotal..."; analysisProgress = 0.6 }
            await queryVirusTotal(ip, type: "ip_addresses", linkType: "ip-address")
        }
        
        // AlienVault OTX
        if !apiKeys.alienVaultOTXAPIKey.isEmpty {
            await MainActor.run { currentTask = "Querying AlienVault OTX..."; analysisProgress = 0.75 }
            await queryOTX(ip, type: isIPv6 ? "IPv6" : "IPv4", linkType: "ip")
        }
        
        // URLhaus
        await MainActor.run { currentTask = "Querying URLhaus..."; analysisProgress = 0.9 }
        await queryURLhaus(ip)
    }
    
    // MARK: - Domain Analysis
    
    private func analyzeDomain(_ domain: String) async {
        let cleanDomain = extractDomain(from: domain)
        
        // DNS Records
        await MainActor.run { currentTask = "Querying DNS..."; analysisProgress = 0.15 }
        await queryDNS(cleanDomain)
        
        // VirusTotal
        if !apiKeys.virusTotalAPIKey.isEmpty {
            await MainActor.run { currentTask = "Querying VirusTotal..."; analysisProgress = 0.4 }
            await queryVirusTotal(cleanDomain, type: "domains", linkType: "domain")
        }
        
        // AlienVault OTX
        if !apiKeys.alienVaultOTXAPIKey.isEmpty {
            await MainActor.run { currentTask = "Querying AlienVault OTX..."; analysisProgress = 0.6 }
            await queryOTX(cleanDomain, type: "domain", linkType: "domain")
        }
        
        // URLhaus
        await MainActor.run { currentTask = "Querying URLhaus..."; analysisProgress = 0.8 }
        await queryURLhaus(cleanDomain)
        
        // Heuristics
        await MainActor.run { analysisProgress = 0.9 }
        await analyzeDomainHeuristics(cleanDomain)
    }
    
    private func queryDNS(_ domain: String) async {
        var mx = "None", spf = "Not found", dmarc = "Not found"
        
        if let url = URL(string: "https://dns.google/resolve?name=\(domain)&type=MX") {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let answers = json["Answer"] as? [[String: Any]],
                   let first = answers.first(where: { ($0["type"] as? Int) == 15 }) {
                    mx = first["data"] as? String ?? "None"
                }
            } catch {}
        }
        
        if let url = URL(string: "https://dns.google/resolve?name=\(domain)&type=TXT") {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let answers = json["Answer"] as? [[String: Any]] {
                    for a in answers {
                        if let txt = a["data"] as? String, txt.lowercased().contains("v=spf1") {
                            spf = String(txt.prefix(60)) + "..."
                            break
                        }
                    }
                }
            } catch {}
        }
        
        if let url = URL(string: "https://dns.google/resolve?name=_dmarc.\(domain)&type=TXT") {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let answers = json["Answer"] as? [[String: Any]],
                   let txt = answers.first?["data"] as? String {
                    dmarc = String(txt.prefix(60)) + "..."
                }
            } catch {}
        }
        
        await MainActor.run {
            results.append(AnalysisResult(source: "DNS Records", sourceIcon: "envelope", threatLevel: .clean, details: "Domain: \(domain)\nMX: \(mx)\nSPF: \(spf)\nDMARC: \(dmarc)", link: "https://mxtoolbox.com/SuperTool.aspx?action=mx%3a\(domain)"))
        }
    }
    
    private func analyzeDomainHeuristics(_ domain: String) async {
        var threat: ThreatLevel = .clean
        var findings: [String] = []
        
        let badTLDs = ["tk", "ml", "ga", "cf", "gq", "xyz", "top", "click", "buzz"]
        let tld = domain.components(separatedBy: ".").last?.lowercased() ?? ""
        if badTLDs.contains(tld) {
            threat = .suspicious
            findings.append("⚠️ Suspicious TLD: .\(tld)")
        }
        
        if domain.count > 50 {
            threat = max(threat, .suspicious)
            findings.append("⚠️ Unusually long domain")
        }
        
        let keywords = ["login", "secure", "verify", "bank", "paypal", "account"]
        for kw in keywords {
            if domain.lowercased().contains(kw) {
                threat = max(threat, .suspicious)
                findings.append("⚠️ Suspicious keyword: \(kw)")
                break
            }
        }
        
        if findings.isEmpty { findings.append("✅ No issues detected") }
        
        await MainActor.run {
            results.append(AnalysisResult(source: "Domain Heuristics", sourceIcon: "magnifyingglass", threatLevel: threat, details: findings.joined(separator: "\n")))
        }
    }
    
    // MARK: - Hash Analysis
    
    private func analyzeHash(_ hash: String) async {
        if !apiKeys.virusTotalAPIKey.isEmpty {
            await MainActor.run { currentTask = "Querying VirusTotal..."; analysisProgress = 0.3 }
            await queryVirusTotal(hash, type: "files", linkType: "file")
        }
        
        if !apiKeys.alienVaultOTXAPIKey.isEmpty {
            await MainActor.run { currentTask = "Querying AlienVault OTX..."; analysisProgress = 0.5 }
            await queryOTX(hash, type: "file", linkType: "file")
        }
        
        await MainActor.run { currentTask = "Querying MalwareBazaar..."; analysisProgress = 0.8 }
        await queryMalwareBazaar(hash)
    }
    
    private func queryMalwareBazaar(_ hash: String) async {
        guard let url = URL(string: "https://mb-api.abuse.ch/api/v1/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "query=get_info&hash=\(hash)".data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if json["query_status"] as? String == "ok",
                   let dataArr = json["data"] as? [[String: Any]],
                   let m = dataArr.first {
                    let sig = m["signature"] as? String ?? "Unknown"
                    let name = m["file_name"] as? String ?? "Unknown"
                    let tags = (m["tags"] as? [String])?.joined(separator: ", ") ?? ""
                    await MainActor.run {
                        results.append(AnalysisResult(source: "MalwareBazaar", sourceIcon: "ladybug", threatLevel: .malicious, details: "🚨 MALWARE FOUND\nSignature: \(sig)\nFile: \(name)\nTags: \(tags)", link: "https://bazaar.abuse.ch/sample/\(hash)"))
                    }
                } else {
                    await MainActor.run {
                        results.append(AnalysisResult(source: "MalwareBazaar", sourceIcon: "ladybug", threatLevel: .clean, details: "Not found in malware database"))
                    }
                }
            }
        } catch {}
    }
    
    // MARK: - Email Analysis
    
    private func analyzeEmail(_ email: String) async {
        let parts = email.components(separatedBy: "@")
        guard parts.count == 2 else { return }
        let domain = parts[1]
        
        await analyzeDomain(domain)
        
        var threat: ThreatLevel = .clean
        var findings: [String] = []
        
        let disposable = ["tempmail", "throwaway", "guerrillamail", "10minutemail", "mailinator", "yopmail"]
        for d in disposable {
            if domain.lowercased().contains(d) {
                threat = .suspicious
                findings.append("⚠️ Disposable email service")
                break
            }
        }
        
        if findings.isEmpty { findings.append("✅ No issues with email address") }
        
        await MainActor.run {
            results.append(AnalysisResult(source: "Email Heuristics", sourceIcon: "envelope.badge", threatLevel: threat, details: findings.joined(separator: "\n")))
        }
    }
    
    // MARK: - ASN Analysis
    
    private func analyzeASN(_ asn: String) async {
        let cleanASN = asn.uppercased().hasPrefix("AS") ? String(asn.dropFirst(2)) : asn
        
        await MainActor.run { currentTask = "Querying BGPView..."; analysisProgress = 0.5 }
        
        if let url = URL(string: "https://api.bgpview.io/asn/\(cleanASN)") {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let d = json["data"] as? [String: Any] {
                    let name = d["name"] as? String ?? "Unknown"
                    let desc = d["description_short"] as? String ?? "N/A"
                    let country = d["country_code"] as? String ?? "N/A"
                    await MainActor.run {
                        results.append(AnalysisResult(source: "BGPView", sourceIcon: "building.2", threatLevel: .clean, details: "Name: \(name)\nDescription: \(desc)\nCountry: \(country)", link: "https://bgpview.io/asn/\(cleanASN)"))
                    }
                }
            } catch {}
        }
    }
    
    // MARK: - Shared Queries
    
    private func queryVirusTotal(_ value: String, type: String, linkType: String) async {
        guard let url = URL(string: "https://www.virustotal.com/api/v3/\(type)/\(value)") else { return }
        var request = URLRequest(url: url)
        request.setValue(apiKeys.virusTotalAPIKey, forHTTPHeaderField: "x-apikey")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let d = json["data"] as? [String: Any],
               let attr = d["attributes"] as? [String: Any],
               let stats = attr["last_analysis_stats"] as? [String: Int] {
                let mal = stats["malicious"] ?? 0
                let sus = stats["suspicious"] ?? 0
                let clean = stats["harmless"] ?? 0
                let undet = stats["undetected"] ?? 0
                let threat: ThreatLevel = mal >= 5 ? .malicious : (mal >= 1 || sus >= 3 ? .suspicious : .clean)
                await MainActor.run {
                    results.append(AnalysisResult(source: "VirusTotal", sourceIcon: "shield.checkerboard", threatLevel: threat, details: "🔴 Malicious: \(mal)\n🟠 Suspicious: \(sus)\n🟢 Clean: \(clean)\n⚪ Undetected: \(undet)", link: "https://www.virustotal.com/gui/\(linkType)/\(value)"))
                }
            }
        } catch {}
    }
    
    private func queryOTX(_ value: String, type: String, linkType: String) async {
        let endpoint = "https://otx.alienvault.com/api/v1/indicators/\(type)/\(value)/general"
        guard let url = URL(string: endpoint) else { return }
        var request = URLRequest(url: url)
        request.setValue(apiKeys.alienVaultOTXAPIKey, forHTTPHeaderField: "X-OTX-API-KEY")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let pulseInfo = json["pulse_info"] as? [String: Any]
                let pulses = pulseInfo?["count"] as? Int ?? 0
                let threat: ThreatLevel = pulses > 10 ? .malicious : (pulses > 5 ? .suspicious : .clean)
                await MainActor.run {
                    results.append(AnalysisResult(source: "AlienVault OTX", sourceIcon: "ant", threatLevel: threat, details: "Threat Pulses: \(pulses)\nCountry: \(json["country_name"] ?? "N/A")", link: "https://otx.alienvault.com/indicator/\(linkType)/\(value)"))
                }
            }
        } catch {}
    }
    
    private func queryURLhaus(_ value: String) async {
        guard let url = URL(string: "https://urlhaus-api.abuse.ch/v1/host/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "host=\(value)".data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let status = json["query_status"] as? String ?? ""
                if status == "ok" {
                    let count = json["url_count"] as? Int ?? 0
                    await MainActor.run {
                        results.append(AnalysisResult(source: "URLhaus", sourceIcon: "link.badge.plus", threatLevel: count > 0 ? .malicious : .clean, details: "Malicious URLs: \(count)", link: "https://urlhaus.abuse.ch/browse/"))
                    }
                } else if status == "no_results" {
                    await MainActor.run {
                        results.append(AnalysisResult(source: "URLhaus", sourceIcon: "link.badge.plus", threatLevel: .clean, details: "Not found in URLhaus"))
                    }
                }
            }
        } catch {}
    }
    
    private func extractDomain(from input: String) -> String {
        var d = input
        if d.hasPrefix("https://") { d = String(d.dropFirst(8)) }
        else if d.hasPrefix("http://") { d = String(d.dropFirst(7)) }
        if let i = d.firstIndex(of: "/") { d = String(d[..<i]) }
        if let i = d.firstIndex(of: ":") { d = String(d[..<i]) }
        return d
    }
}

class RedirectBlocker: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}

// MARK: - Main View

struct IOCAnalyzerView: View {
    @StateObject private var analyzer = IOCAnalyzerService.shared
    @StateObject private var apiKeys = APIKeysManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    
    @State private var input: String = IOCAnalyzerWindowController.sharedInput
    @State private var showingAPISettings = false
    @State private var validationResult: ValidationResult = .empty
    @State private var selectedTab: Int = 0
    
    private var lang: AppLanguage { localization.currentLanguage }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            
            // Tab Bar
            HStack(spacing: 0) {
                TabButton(title: L10n.get(.analyze, for: lang), icon: "magnifyingglass", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: DashboardL10n.get(.dashboard, for: lang), icon: "chart.bar.fill", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabButton(title: DashboardL10n.get(.history, for: lang), icon: "clock.arrow.circlepath", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            
            Divider()
            
            // Tab Content
            switch selectedTab {
            case 0:
                analyzerTabContent
            case 1:
                DashboardView()
            case 2:
                HistoryListView()
            default:
                analyzerTabContent
            }
            
            Divider()
            footerView
        }
        .background(Color(NSColor.windowBackgroundColor))
        .sheet(isPresented: $showingAPISettings) { APISettingsSheet(lang: lang) }
        .onChange(of: input) { newValue in
            // Remove newlines and validate
            let cleaned = newValue.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "")
            if cleaned != newValue {
                input = cleaned
            }
            validationResult = InputValidator.validate(cleaned)
        }
        .onAppear {
            // First check if there's input from the popover
            if !IOCAnalyzerWindowController.sharedInput.isEmpty {
                let cleaned = IOCAnalyzerWindowController.sharedInput
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\n", with: "")
                    .replacingOccurrences(of: "\r", with: "")
                input = cleaned
                IOCAnalyzerWindowController.sharedInput = "" // Clear it
                validationResult = InputValidator.validate(cleaned)
            } else if input.isEmpty {
                // Fallback to clipboard
                if let clip = NSPasteboard.general.string(forType: .string) {
                    let cleaned = clip
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "\n", with: "")
                        .replacingOccurrences(of: "\r", with: "")
                    if cleaned.count < 500 && !cleaned.isEmpty {
                        input = cleaned
                        validationResult = InputValidator.validate(cleaned)
                    }
                }
            }
        }
    }
    
    // MARK: - Analyzer Tab Content
    
    private var analyzerTabContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                inputSection
                
                if let unshort = analyzer.unshortenerResult, unshort.redirectChain.count > 1 {
                    unshortenerView(unshort)
                }
                
                if analyzer.isAnalyzing {
                    ProgressView(value: analyzer.analysisProgress) {
                        Text(analyzer.currentTask).font(.caption).foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(12)
                }
                
                if !analyzer.isAnalyzing && !analyzer.results.isEmpty {
                    verdictView
                }
                
                if !analyzer.results.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.get(.analysisResults, for: lang)).font(.headline)
                        ForEach(analyzer.results) { result in
                            ResultCard(result: result, lang: lang)
                        }
                    }
                }
            }
            .padding(20)
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                .font(.title)
                .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.get(.title, for: lang)).font(.title2).fontWeight(.bold)
                Text(L10n.get(.subtitle, for: lang)).font(.caption).foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button { showingAPISettings = true } label: {
                HStack(spacing: 4) {
                    Image(systemName: "key.fill")
                    Text(L10n.get(.apiKeys, for: lang))
                }
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.get(.enterIOC, for: lang)).font(.headline)
                Spacer()
                if case .valid(let type) = validationResult {
                    Text("\(L10n.get(.detected, for: lang)): \(type.displayName)")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            HStack(spacing: 12) {
                TextField("IP, Domain, URL, SHA-256, Email, ASN", text: $input)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .onSubmit { startAnalysis() }
                
                if !input.isEmpty {
                    Button { input = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Button {
                    if let clip = NSPasteboard.general.string(forType: .string) {
                        let cleaned = clip
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: "\n", with: "")
                            .replacingOccurrences(of: "\r", with: "")
                        input = cleaned
                        validationResult = InputValidator.validate(cleaned)
                    }
                } label: {
                    Image(systemName: "doc.on.clipboard").foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help(L10n.get(.pasteClipboard, for: lang))
            }
            
            Button { startAnalysis() } label: {
                HStack {
                    if analyzer.isAnalyzing {
                        ProgressView().scaleEffect(0.7).frame(width: 16, height: 16)
                    } else {
                        Image(systemName: "magnifyingglass.circle.fill")
                    }
                    Text(analyzer.isAnalyzing ? L10n.get(.analyzing, for: lang) : L10n.get(.analyze, for: lang))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(LinearGradient(colors: validationResult.isValid ? [.blue, .purple] : [.gray], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .disabled(!validationResult.isValid || analyzer.isAnalyzing)
            
            // API Status
            HStack(spacing: 16) {
                ForEach([("VirusTotal", apiKeys.virusTotalAPIKey), ("AbuseIPDB", apiKeys.abuseIPDBAPIKey), ("OTX", apiKeys.alienVaultOTXAPIKey)], id: \.0) { name, key in
                    HStack(spacing: 4) {
                        Circle().fill(key.isEmpty ? Color.red : Color.green).frame(width: 8, height: 8)
                        Text(name).font(.caption).foregroundColor(.secondary)
                    }
                }
                HStack(spacing: 4) {
                    Circle().fill(Color.green).frame(width: 8, height: 8)
                    Text("Free APIs").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private func unshortenerView(_ result: UnshortenerResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "link.badge.plus").foregroundColor(.blue)
                Text(L10n.get(.urlRedirectChain, for: lang)).font(.headline)
            }
            
            ForEach(Array(result.redirectChain.enumerated()), id: \.offset) { index, url in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: index < result.redirectChain.count - 1 ? "\(index + 1).circle.fill" : "flag.checkered")
                        .foregroundColor(index < result.redirectChain.count - 1 ? .blue : .green)
                    Text(url)
                        .font(.system(.caption, design: .monospaced))
                        .lineLimit(2)
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.blue.opacity(0.2), lineWidth: 1))
    }
    
    private var verdictView: some View {
        HStack(spacing: 16) {
            Image(systemName: analyzer.overallThreatLevel.icon)
                .font(.system(size: 48))
                .foregroundColor(analyzer.overallThreatLevel.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.get(.overallVerdict, for: lang)).font(.caption).foregroundColor(.secondary)
                Text(analyzer.overallThreatLevel.name(for: lang))
                    .font(.title).fontWeight(.bold).foregroundColor(analyzer.overallThreatLevel.color)
                Text("\(analyzer.results.count) \(L10n.get(.sourcesAnalyzed, for: lang))")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(20)
        .background(analyzer.overallThreatLevel.color.opacity(0.1))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(analyzer.overallThreatLevel.color.opacity(0.3), lineWidth: 2))
    }
    
    private var footerView: some View {
        HStack {
            Text(L10n.get(.limitedRequests, for: lang)).font(.caption2).foregroundColor(.secondary)
            Spacer()
            Button(L10n.get(.clearResults, for: lang)) {
                analyzer.results.removeAll()
                analyzer.overallThreatLevel = .unknown
                analyzer.unshortenerResult = nil
            }
            .buttonStyle(.borderless)
            .disabled(analyzer.results.isEmpty)
        }
        .padding(16)
    }
    
    private func startAnalysis() {
        guard validationResult.isValid else { return }
        Task { await analyzer.analyzeIOC(input) }
    }
}

// MARK: - Result Card

struct ResultCard: View {
    let result: AnalysisResult
    let lang: AppLanguage
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { withAnimation { isExpanded.toggle() } } label: {
                HStack(spacing: 12) {
                    Image(systemName: result.sourceIcon)
                        .font(.title3)
                        .foregroundColor(result.threatLevel.color)
                        .frame(width: 24)
                    Text(result.source).font(.headline)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: result.threatLevel.icon)
                        Text(result.threatLevel.name(for: lang))
                    }
                    .font(.caption).fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(result.threatLevel.color)
                    .cornerRadius(6)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down").foregroundColor(.secondary)
                }
                .padding(12)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text(result.details)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                    
                    if let link = result.link {
                        Button {
                            if let url = URL(string: link) { NSWorkspace.shared.open(url) }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.right.square")
                                Text("\(L10n.get(.viewOn, for: lang)) \(result.source)")
                            }
                            .font(.caption).foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(result.threatLevel.color.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - API Settings Sheet

struct APISettingsSheet: View {
    let lang: AppLanguage
    @Environment(\.dismiss) private var dismiss
    @StateObject private var apiKeys = APIKeysManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(L10n.get(.apiKeysConfig, for: lang)).font(.title2).fontWeight(.bold)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill").font(.title3).foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill").foregroundColor(.blue)
                        Text(L10n.get(.apiKeysInfo, for: lang)).font(.caption).foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    APIKeyRow(title: "VirusTotal", desc: "500 \(L10n.get(.requestsDay, for: lang))", url: "https://www.virustotal.com/gui/join-us", icon: "shield.checkerboard", key: $apiKeys.virusTotalAPIKey, lang: lang)
                    APIKeyRow(title: "AbuseIPDB", desc: "1,000 \(L10n.get(.requestsDay, for: lang))", url: "https://www.abuseipdb.com/register", icon: "exclamationmark.shield", key: $apiKeys.abuseIPDBAPIKey, lang: lang)
                    APIKeyRow(title: "AlienVault OTX", desc: "10,000 \(L10n.get(.requestsDay, for: lang))", url: "https://otx.alienvault.com/api", icon: "ant", key: $apiKeys.alienVaultOTXAPIKey, lang: lang)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.get(.freeAPIs, for: lang)).font(.headline)
                        HStack(spacing: 8) {
                            ForEach(["IPInfo", "URLhaus", "MalwareBazaar", "BGPView", "HackerTarget", "DNS Google"], id: \.self) { api in
                                Text(api).font(.caption2).padding(.horizontal, 8).padding(.vertical, 4).background(Color.green.opacity(0.1)).cornerRadius(4)
                            }
                        }
                    }
                }
                .padding(20)
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button(L10n.get(.done, for: lang)) { dismiss() }.buttonStyle(.borderedProminent)
            }
            .padding(16)
        }
        .frame(width: 550, height: 520)
    }
}

struct APIKeyRow: View {
    let title: String
    let desc: String
    let url: String
    let icon: String
    @Binding var key: String
    let lang: AppLanguage
    @State private var showKey = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).foregroundColor(.blue)
                Text(title).font(.headline)
                Spacer()
                Circle().fill(key.isEmpty ? Color.red : Color.green).frame(width: 10, height: 10)
            }
            Text(desc).font(.caption).foregroundColor(.secondary)
            HStack(spacing: 8) {
                Group {
                    if showKey {
                        TextField("API Key", text: $key)
                    } else {
                        SecureField("API Key", text: $key)
                    }
                }
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
                
                Button { showKey.toggle() } label: {
                    Image(systemName: showKey ? "eye.slash" : "eye").foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                
                Button(L10n.get(.getKey, for: lang)) {
                    NSWorkspace.shared.open(URL(string: url)!)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                LinearGradient(colors: [Color(NSColor.controlBackgroundColor)], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    IOCAnalyzerView().frame(width: 750, height: 700)
}
