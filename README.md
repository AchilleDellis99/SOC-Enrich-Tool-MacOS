# 🛡️ SOC Enrich Tool for macOS

![Swift](https://img.shields.io/badge/Swift-5.10-orange?logo=swift)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey?logo=apple)
![License](https://img.shields.io/badge/license-MIT-blue)
![Status](https://img.shields.io/badge/status-active-success)
![Languages](https://img.shields.io/badge/languages-13-green)

**SOC Enrich Tool** is a lightweight, open-source macOS menu bar application built for **Security Operations Center (SOC)** analysts and cybersecurity professionals.  
It enables instant lookups of IPs, domains, file hashes, ASNs, and mail records across multiple open intelligence sources — all directly from your Mac’s menu bar.

---

## 🚀 Features

- ⚡ **Instant Lookups** — Query IPs, domains, SHA-256 hashes, ASNs, and email MX records in one click.  
- 🌍 **Multi-language Interface** — Supports **13 languages** including English, Italian, Spanish, German, French, Russian, Chinese, Japanese, and more.  
- 📋 **Clipboard Integration** — Automatically pre-fills the last copied value for quick lookups.  
- 🪟 **Minimal macOS UI** — Built entirely in **SwiftUI + AppKit**, runs directly from the menu bar without cluttering your Dock.  
- 🔗 **Multi-source Enrichment** — Fetches data from VirusTotal, AbuseIPDB, Shodan, ipinfo.io, AlienVault OTX, and others.  
- ⚙️ **Customizable Behavior** — Choose whether to open results in the background or in Safari, and toggle clipboard prefill.

---

## 🧩 Supported Lookup Types

| Artifact Type | Example | Sources Queried |
|----------------|----------|------------------|
| **IP Address** | `8.8.8.8` | VirusTotal, OTX, GreyNoise, AbuseIPDB, Shodan, IPInfo |
| **Domain / FQDN** | `example.com` | VirusTotal, OTX, URLScan, GreyNoise |
| **SHA-256 Hash** | `44d88612fea8a8f36de82e1278abb02f` | VirusTotal, Hybrid Analysis, Abuse.ch |
| **ASN** | `AS15169` | IPInfo, BGP.HE.NET |
| **Email / MX** | `user@domain.com` | MXToolbox (MX, SPF, DMARC) |

---

## 💻 Installation

### Option 1 — Download Prebuilt DMG
Download the latest `.dmg` release from the [**Releases**](../../releases) page and drag the app to your **Applications** folder.

### Option 2 — Build from Source
```bash
git clone https://github.com/AchilleDellis99/SOC-Enrich-Tool-MacOS.git
cd SOC-Enrich-Tool-MacOS
open SOC-Enrich-Tool.xcodeproj
