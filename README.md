# Vision Assist Pro 👁️

Vision Assist Pro je špičková mobilní aplikace vyvinutá v rámci platformy Flutter, která slouží jako komplexní kompenzační pomůcka pro osoby s poruchami barvocitu (CVD) a zároveň jako edukační platforma pro simulaci těchto stavů v reálném čase.

## 💎 Klíčové vlastnosti

### 🛠️ Vision Assist (Korekční režim)
- **Deficiency Focus**: Unikátní systém cílení, který umožňuje zvolit konkrétní typ vady (Protan, Deutan, Tritan), na který se má asistence primárně zaměřit.
- **Cílená daltonizace**: Využívá pokročilou metodu *Targeted Error Redistribution* založenou na LMS modelech. Algoritmus v reálném čase identifikuje "ztracenou" barvocitnou informaci a redistribuuje ji do viditelného spektra pro dosažení přirozeného obrazu bez zbytečného zkreslení.
- **Inteligentní presety**: Tlačítka **Mild**, **Medium** a **Strong** jsou kontextově závislá – upravují citlivost **pouze pro aktivní typ vady**, čímž zachovávají věrnost barev, které uživatel vidí správně.
- **Plná kontrola**: Možnost jemného manuálního doladění všech tří kanálů nezávisle a uložení vlastní konfigurace přímo do paměti zařízení.

### 🎭 Režim Simulace
- **Vědecky podložené matice**: Simulace využívá přesné matematické modely (Machado et al. 2009) pro věrné zobrazení světa očima barvoslepých (sRGB LMS transformace).
- **Vylepšené karty vady**: Každý typ vady (Protanopie, Deuteranopie, Tritanopie) disponuje interaktivní kartou s barevně kódovanou ikonou a ambientní září odpovídající danému spektru (červená, zelená, modrá).
- **Plynulá intenzita**: Možnost plynulého nastavení závažnosti vady od 0 % (normální vidění) do 100 % (úplná dichromacie).

### 📸 Profesionální práce s obrazem
- **Ultra-low latency**: Nativně optimalizovaný stream z kamery zajišťuje plynulý náhled i při rychlém pohybu bez vizuálních artefaktů.
- **Prémiový Capture**: Možnost pořídit fotografii s aplikovaným filtrem a uložit ji v plné kvalitě přímo do systémové galerie.
- **Freeze & Zoom**: Funkce zmrazení obrazu umožňující detailní prozkoumání barev scény pomocí gest a digitálního přiblížení.

### ♿ Komplexní přístupnost (Accessibility)
- **Vysoký kontrast**: Režim optimalizovaný pro uživatele se zhoršeným zrakem (jasnější texty, absolutní černá na pozadí, výrazné ohraničení interaktivních prvků).
- **Zvětšený text**: Podpora pro dynamické škálování celého UI (~ o 20 %) při zachování responzivity rozvržení.
- **Zjednodušené UI**: Minimalistický režim, který eliminuje vizuální šum, skrývá vedlejší popisky a omezuje animace pro lepší soustředění na obsah.
- **Moderní design**: Elegantní "glassmorphism" estetika s plnou podporou a automatickým přepínáním mezi tmavým, světlým a systémovým motivem.

## 🛡️ Soukromí a bezpečnost
- **100% On-Device Processing**: Veškeré výpočty, filtrace a analýza obrazu probíhají výhradně lokálně v čipu telefonu.
- **Absolutní anonymita**: Aplikace nevyžaduje registraci, nemá žádný systém účtů a neodesílá žádná data do cloudu.
- **Transparentní podmínky**: Integrované právní sekce (Obchodní podmínky a Zásady ochrany soukromí) aktualizované k datu **květen 2026**.

## ✨ Prémiové detaily
- **Assembly Intro**: Unikátní úvodní sekvence, kde se logo aplikace oka v reálném čase "sestavuje" pomocí vektorového vykreslování cest (`CustomPainter`).
- **Haptická odezva**: Jemná a inteligentní vibrační zpětná vazba při interakci s klíčovými prvky a při pořízení snímku.
- **Plná perzistence**: Aplikace si pamatuje veškerá vaše nastavení, zvolený motiv, konfiguraci asistence i parametry přístupnosti i po restartu.

## 🚀 Instalace a spuštění

### Požadavky
- **Flutter SDK**: `^3.11.5`
- **Android**: API 21+ (5.0 Lollipop a novější)
- **iOS**: iOS 12.0+

### Postup
1. Nainstalujte závislosti:
   ```bash
   flutter pub get
   ```
2. Vyčistěte build cache (doporučeno):
   ```bash
   flutter clean
   ```
3. Spusťte aplikaci na připojeném zařízení:
   ```bash
   flutter run
   ```

## 🛠️ Technické parametry
- **State Management**: `Provider`
- **Ukládání dat**: `shared_preferences`
- **Zpracování barev**: GPU-akcelerované maticové transformace přes `ColorFiltered`.
- **Verze**: 1.34.0+44

## 📜 Licence
© 2026 Vision Assist Pro. Všechna práva vyhrazena.
*Upozornění: Tato aplikace není certifikovaný zdravotnický prostředek a neslouží k klinické diagnostice barvosleposti.*
