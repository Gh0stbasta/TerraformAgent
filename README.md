# 🚀 GitHub Agent + Terraform Mini-Projekte

Dieses Repository dient als Testumgebung für einfache Infrastruktur-Projekte, die automatisch aus GitHub-Issues generiert und ausgeführt werden. Jedes Issue beschreibt ein kleines Setup, das als Terraform-Code umgesetzt wird.

## 🧪 Testzweck

- Automatisiertes Provisionieren von Infrastruktur über GitHub-Issues
- Testen von GitHub Agent
- Dynamische Generierung von Terraform-Code mittels TypeScript

## 🧱 Ordnerstruktur

```bash
/
├── .github/
│   └── workflows/              # GitHub Actions Workflows
├── scripts/                    # Codegenerierung & Verarbeitung
├── templates/                  # Terraform-Bausteine
├── projects/                   # Generierte Infrastruktur-Projekte pro Issue
└── README.md
```

## ⚙️ Funktion

1. Ein neues GitHub-Issue wird erstellt.
2. Der Github Agent wird getriggert und analysiert den Inhalt.
3. Ein Skript generiert daraus ein passendes Terraform-Projekt.
4. Das Projekt wird gespeichert und optional ausgeführt.

## 🎯 Ziel

- Infrastruktur-Komponenten aus Textbeschreibungen erzeugen
- Automatisierte DevOps-Pipeline mit minimalem Setup
- Lernen, wie GitHub als Steuerzentrale für IAC (Infrastructure as Code) genutzt werden kann

## 🔧 Technisches Setup

- **Terraform** – Infrastruktur-Provisionierung
- **TypeScript / JavaScript** – Codegenerierung & Automatisierung
- **GitHub Actions** – Event-gesteuerte Ausführung
- **(Optional)** GitHub Self-Hosted Agent – Lokale oder cloudbasierte Verarbeitung

## 📄 Lizenz

MIT License
