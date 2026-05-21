# Vision Assist Pro 👁️

Vision Assist Pro je špičková mobilní aplikace vyvinutá v rámci platformy Flutter, která slouží jako kompenzační pomůcka pro osoby s poruchami barvocitu (CVD) a zároveň jako edukační platforma pro simulaci těchto stavů v reálném čase.

##  Klíčové vlastnosti

### Vision Assist (Korekční režim)
- **Adaptivní daltonizace**: Využívá inteligentní algoritmy pro posun barevného spektra, čímž pomáhá rozlišovat problematické odstíny přímo v obraze kamery.
- **Plná kontrola citlivosti**: Nezávislé nastavení pro kanály Protan (červená), Deutan (zelená) a Tritan (modrá).
- **Rychlé presety**: Okamžitý výběr úrovně asistence (Mírná, Střední, Silná).

### Režim Simulace
- **Vědecky podložené matice**: Simulace využívá přesné matematické modely (Machado et al. 2009) pro věrné zobrazení světa očima barvoslepých (sRGB LMS transformace).
- **Interaktivní karty vady**: Každý typ vady (Protanopie, Deuteranopie, Tritanopie) má svou vizuální indikaci se zářícím efektem.
- **Plynulá intenzita**: Možnost plynulého nastavení závažnosti vady od 0 % do 100 %.

### Profesionální práce s obrazem
- **Ultra-low latency**: Optimalizovaný stream z kamery pro plynulé používání v pohybu bez trhání.
- **Kvalitní capture**: Pořizování a ukládání upravených fotografií přímo do systémové galerie zařízení.
- **Freeze & Zoom**: Možnost zmrazit náhled a detailně prozkoumat konkrétní barvy pomocí gest a digitálního přiblížení.

### Komplexní přístupnost (Accessibility)
- **Vysoký kontrast**: Speciální režim pro uživatele se zhoršeným zrakem (jasnější texty, černé plochy místo šedých, výrazné ohraničení prvků).
- **Zvětšený text**: Globální škálování UI prvků pro lepší čitelnost bez rozbití rozvržení.
- **Zjednodušené UI**: Minimalistický režim, který potlačuje vizuální šum, skrývá popisky a omezuje animace pro lepší soustředění.
- **Moderní design**: Elegantní "glassmorphism" estetika s plnou podporou tmavého i světlého režimu.

## Soukromí a bezpečnost
- **Lokální zpracování**: Veškeré výpočty a analýza obrazu probíhají výhradně v čipu telefonu v reálném čase.
- **Absence cloudu**: Žádné fotografie ani osobní údaje nejsou odesílány na externí servery ani cloudové služby.
- **Právní transparentnost**: Integrované stránky s Obchodními podmínkami a Zásadami ochrany soukromí (aktualizováno k květnu 2026).

## Prémiové detaily
- **Intro animace**: Unikátní úvodní sekvence s vektorovým vykreslováním loga oka v reálném čase pomocí `CustomPainter`.
- **Haptika**: Jemná vibrační odezva při interakci s klíčovými prvky a pořízení snímku (Haptic Feedback).
- **Perzistence**: Aplikace si pamatuje všechna vaše nastavení, zvolený motiv i konfiguraci přístupnosti i po restartu.

## Instalace a spuštění

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
3. Spusťte aplikaci:
   ```bash
   flutter run
   ```

## Technické parametry
- **State Management**: `Provider`
- **Ukládání dat**: `shared_preferences`
- **Zpracování barev**: Maticové transformace (Color Matrix) aplikované přes `ColorFiltered` widgety.

## Licence
© 2026 Vision Assist Pro. Všechna práva vyhrazena.
*Upozornění: Aplikace není certifikovaný zdravotnický prostředek a nenahrazuje odbornou lékařskou diagnózu.*
