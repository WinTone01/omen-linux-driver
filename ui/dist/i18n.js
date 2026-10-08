/*
 * Translations.
 *
 * Keyed by the English text rather than by invented identifiers. Two reasons:
 * the English is already written in index.html and duplicating it as keys
 * would mean two places to keep in step, and a missing translation then falls
 * back to something correct rather than to "settings.window.title".
 *
 * What is NOT translated, deliberately:
 *
 *   - Anything the daemon says. Its replies, the diagnosis findings and the
 *     journal are English, because they are also what goes into a bug report
 *     and what a kernel maintainer would be shown.
 *   - Commands, paths, module and file names.
 *
 * So the window speaks Turkish and the machine speaks English, which is the
 * same split the rest of this project uses.
 */

const I18N = {
  tr: {
    /* ── chrome ─────────────────────────────────────────────── */
    "Profile": "Profil",
    "System Vitals": "Sistem Durumu",
    "Performance Control": "Performans",
    "Fan Control": "Fan",
    "Lighting": "Aydınlatma",
    "Diagnosis": "Tanılama",
    "Settings": "Ayarlar",
    "connecting…": "bağlanılıyor…",

    /* ── page headers ───────────────────────────────────────── */
    "What the machine is doing right now.": "Makinenin şu an ne yaptığı.",
    "The firmware's thermal profile, and what each mode actually does.":
      "Firmware'in termal profili ve her modun gerçekte ne yaptığı.",
    "The curve, the mode, and a log of every setpoint the service chose.":
      "Eğri, mod ve servisin seçtiği her hedefin kaydı.",
    "Rules that run the machine for you: a program, a state, a power source.":
      "Makineyi senin yerine çalıştıran kurallar: bir program, bir durum, bir güç kaynağı.",
    "Which GPU drives the screen, and what the discrete one is doing.":
      "Ekranı hangi GPU sürüyor ve ayrık olan ne yapıyor.",
    "Four zones, effects, and colours that survive a reboot.":
      "Dört bölge, efektler ve yeniden başlatmadan sağ çıkan renkler.",
    "Every part of the installation, checked, with what to do about anything wrong.":
      "Kurulumun her parçası denetlenir, yanlış olan için ne yapılacağıyla birlikte.",
    "This window, the machine's defaults, versions and firmware.":
      "Bu pencere, makinenin varsayılanları, sürümler ve firmware.",
    "omend connected": "omend bağlı",
    "omend unreachable": "omend'e ulaşılamıyor",

    /* ── vitals ─────────────────────────────────────────────── */
    "no fan control": "fan denetimi yok",
    "Package": "Paket",
    "CPU side": "CPU tarafı",
    "GPU side": "GPU tarafı",
    "History": "Geçmiş",
    "Temperature": "Sıcaklık",
    "Fan": "Fan",
    "System Temperature": "Sistem Sıcaklığı",
    "Your settings": "Ayarların",
    "Performance profile": "Performans profili",
    "Fan mode": "Fan modu",
    "Fan target": "Fan hedefi",
    "Driving sensor": "Süren sensör",
    "Discrete GPU": "Ayrık GPU",
    "Service uptime": "Servis süresi",
    "last 2 min": "son 2 dk",

    /* ── performance ────────────────────────────────────────── */
    "Performance mode": "Performans modu",
    "Two handlers act on this machine.":
      "Bu makinede iki sürücü birlikte çalışıyor.",
    "sets the CPU's energy preference and its frequency ceiling;":
      "CPU'nun enerji tercihini ve frekans tavanını belirliyor;",
    "writes the firmware's own thermal profile, which is what the EC uses to decide how hard to work the fans. Changing it here drives both, and the desktop's power widget picks the change up within a few seconds.":
      "ise firmware'in kendi termal profilini yazıyor — EC fanları ne kadar zorlayacağına buna bakarak karar veriyor. Buradan değiştirmek ikisini birden sürüyor ve masaüstünün güç göstergesi değişikliği birkaç saniye içinde fark ediyor.",

    "Power source": "Güç kaynağı",
    "What the machine should do on mains and on battery. Applied when the source changes, not continuously — so you can still override it while plugged in. An application profile wins over these.":
      "Fişteyken ve pildeyken makinenin ne yapacağı. Kaynak değiştiğinde uygulanır, sürekli değil — böylece fişteyken yine de elle değiştirebilirsin. Uygulama profilleri bunlara üstün gelir.",
    "On mains": "Fişte",
    "On battery": "Pilde",

    "Graphics": "Ekran kartı",
    "Let it sleep": "Uyumasına izin ver",
    "Keep it awake": "Uyanık tut",
    "Runtime state": "Çalışma durumu",
    "Time suspended": "Uyuduğu süre",
    "Holding it awake": "Uyanık tutan",
    "In Hybrid, programs run on the integrated GPU unless they ask for the other one. To make one ask, put this in front of the command — in Steam, before":
      "Hibritte programlar, diğerini istemedikçe tümleşik GPU'da çalışır. İstemesini sağlamak için komutun önüne şunu koy — Steam'de şunun önüne:",
    "Discrete GPU power": "Ayrık GPU gücü",

    /* ── state triggers ─────────────────────────────────────── */
    "Three rules, applied in that order: a running program beats a state of the machine, which beats the power source. The more specific statement wins — \"this game is open\" says more about what the machine should be doing than \"the charger is in\".":
      "Üç kural, bu sırayla uygulanır: çalışan program makinenin durumunu, o da güç kaynağını yener. Daha belirli olan kazanır — \"bu oyun açık\", \"şarj takılı\"dan daha çok şey söyler.",
    "State triggers": "Durum tetikleyicileri",
    "The machine's own state rather than a program: it got hot, the lid is shut, the battery is low, nothing has happened for a while. The settings go back when the state ends, and the first matching entry wins. A running application profile beats all of these.":
      "Program değil, makinenin kendi durumu: ısındı, kapak kapandı, pil azaldı, bir süredir bir şey olmuyor. Durum bitince ayarlar geri alınır; eşleşenlerden ilki kazanır. Çalışan bir uygulama profili hepsini yener.",
    "\"Idle\" is measured from CPU time, not from your keyboard — the service runs outside your session and cannot see it. A machine compiling something unattended is not idle; one sitting at a login screen is.":
      "\"Boşta\" ölçüsü klavyen değil, CPU zamanıdır — servis oturumunun dışında çalışır ve klavyeni göremez. Arka planda derleme yapan makine boşta değildir; giriş ekranında bekleyen makine boştadır.",
    "when it is hotter than": "şundan sıcaksa",
    "when the battery falls below": "pil şunun altına düşerse",
    "when nothing has happened for": "şu süredir bir şey olmadıysa",
    "when the lid is shut": "kapak kapalıysa",
    "between these times": "şu saatler arasında",
    "when on this network": "şu ağdayken",
    "between": "saat",
    "and": "ile",
    "on the network": "şu ağda:",
    "network name": "ağ adı",
    "give two different times": "iki farklı saat ver",
    "which network?": "hangi ağ?",
    "above": "üzeri",
    "battery below": "pil altında",
    "idle for": "boşta",
    "min": "dk",
    "the lid is shut": "kapak kapalı",
    "in force": "yürürlükte",
    "trigger added": "tetikleyici eklendi",
    "that condition needs a number": "bu koşul bir sayı ister",

    /* ── battery ────────────────────────────────────────────── */
    "The warning is a desktop notification, and it arrives with the window in the tray too — a closed window keeps a slow watch for that one event rather than stopping altogether.":
      "Uyarı bir masaüstü bildirimi olarak gelir ve pencere tepsideyken de gelir — kapalı pencere tamamen durmak yerine yalnızca bu olay için yavaş bir gözlem sürdürür.",
    "Battery": "Pil",
    "A laptop that lives on its charger sits at 100%, which is the one state a lithium cell ages fastest in. Stopping short of full trades a little runtime for a longer life.":
      "Sürekli şarjda duran dizüstü %100'de kalır; lityum hücrenin en hızlı yaşlandığı durum budur. Tam dolmadan kesmek, biraz kullanım süresini daha uzun ömre takas eder.",
    "Stop charging at": "Şarjı şurada kes",
    "Off — charge to full": "Kapalı — tam doldur",
    "This kernel exposes no charge threshold for this battery. On HP laptops the setting usually lives in BIOS setup instead — Battery Health Manager, F10 at boot.":
      "Bu çekirdek bu pil için bir şarj eşiği sunmuyor. HP dizüstülerde bu ayar genellikle BIOS'ta durur — açılışta F10, Battery Health Manager.",
    "hp-bioscfg is loaded, but this firmware does not publish the setting through it either, so there is nothing for the system to write.":
      "hp-bioscfg yüklü, ama bu firmware ayarı onun üzerinden de yayınlamıyor; yani sistemin yazabileceği bir şey yok.",
    "fans forced to full power": "fanlar tam güce zorlandı",
    "on mains": "prizde",

    /* ── what this machine can do ───────────────────────────── */
    "Running with what this machine has:": "Bu makinede olanla çalışıyor:",
    "not available here.": "burada yok.",
    "omenctl caps says why.": "nedenini 'omenctl caps' söyler.",
    "fan control": "fan denetimi",
    "performance profiles": "performans profilleri",
    "keyboard lighting": "klavye aydınlatması",

    /* ── what needs root ────────────────────────────────────── */
    "Needs your password": "Şifreni ister",
    "Almost nothing here needs root — the service holds the privileges and this window talks to it over a socket. What is left is the plumbing: restarting the service after an upgrade, reloading a module, joining the group. Each button runs one fixed command, shown next to it.":
      "Burada neredeyse hiçbir şey root istemez — yetkileri servis tutar, bu pencere onunla soket üzerinden konuşur. Geriye tesisat kalır: yükseltmeden sonra servisi yeniden başlatmak, modül yeniden yüklemek, gruba katılmak. Her düğme yanında yazan tek sabit komutu çalıştırır.",
    "Run": "Çalıştır",
    "asking…": "soruluyor…",
    "Restart the service": "Servisi yeniden başlat",
    "Start the service, and at every boot": "Servisi başlat, her açılışta da",
    "Reload hp-wmi": "hp-wmi'yi yeniden yükle",
    "Reload omen-kbd-rgb": "omen-kbd-rgb'yi yeniden yükle",
    "Load ec_sys (read-only)": "ec_sys'i yükle (salt okunur)",
    "Join the 'omen' group": "'omen' grubuna katıl",

    /* ── sharing and reports ────────────────────────────────── */
    "Copy code": "Kodu kopyala",
    "Paste code": "Kod yapıştır",
    "Load": "Yükle",
    "curve code": "eğri kodu",
    "curve imported": "eğri alındı",
    "Save full report": "Tam raporu kaydet",
    "writing the report…": "rapor yazılıyor…",
    "Written to": "Şuraya yazıldı:",

    "Application profiles": "Uygulama profilleri",
    "While one of these programs is running, the machine switches to the settings you give it and goes back to what it was doing when the program exits. The first entry that is running wins.":
      "Bu programlardan biri çalışırken makine ona verdiğin ayarlara geçer, program kapanınca eskisine döner. Çalışanlardan listede ilk sırada olan kazanır.",
    "The name has to be what the kernel calls the program, which is often not what the launcher is called. Start the game, then pick it from the box below — it lists what you have running now.":
      "İsim, çekirdeğin programa verdiği ad olmalı; bu çoğu zaman başlatıcının adı değildir. Oyunu başlat, sonra aşağıdaki kutudan seç — şu an çalışanları listeliyor.",
    "Add": "Ekle",
    "profile: leave alone": "profil: dokunma",
    "fan: leave alone": "fan: dokunma",
    "fan: curve": "fan: eğri",
    "fan: max": "fan: tam güç",
    "running": "çalışıyor",

    "Configuration": "Yapılandırma",
    "The fan curve lives in": "Fan eğrisi şurada:",
    ". After editing it, have the service re-read it without a restart.":
      "— düzenledikten sonra servisi yeniden başlatmadan okutabilirsin.",
    "Reload configuration": "Yapılandırmayı yeniden oku",

    /* ── fan ────────────────────────────────────────────────── */
    "Automatic": "Otomatik",
    "Manual": "Elle",
    "Max": "Tam güç",
    "EC default": "EC varsayılanı",
    "Curve": "Eğri",
    "Edit": "Düzenle",
    "Defaults": "Varsayılan",
    "Cancel": "Vazgeç",
    "Save": "Kaydet",
    "Sure?": "Emin misin?",
    "Drag a point to move it. Click an empty part of the chart to add one, right-click a point to remove it. Nothing changes until you save.":
      "Bir noktayı sürükleyerek taşı. Boş bir yere tıklayarak yeni nokta ekle, bir noktaya sağ tıklayarak sil. Kaydedene kadar hiçbir şey değişmez.",
    "held between points, as OMEN Gaming Hub does":
      "noktalar arasında sabit tutulur, OMEN Gaming Hub'ın yaptığı gibi",
    "linear between points": "noktalar arasında doğrusal",

    "Recent decisions": "Son kararlar",
    "Every time the setpoint actually changed, and what the temperature was when it did. The keep-alive rewrites are not here — only the moments something was decided.":
      "Ayar noktasının gerçekten değiştiği her an, ve o anda sıcaklığın ne olduğu. Düzenli tazeleme yazmaları burada değil — yalnızca bir karar verilen anlar.",
    "fans off": "fanlar kapalı",
    "changes since the service started": "değişiklik (servis başladığından beri)",

    "Manual target": "Elle hedef",
    "Clamped to 1800–4800 RPM and rounded to 100 RPM, the EC's real resolution. The critical cutout still applies in manual mode.":
      "1800–4800 RPM arasına sıkıştırılır ve EC'nin gerçek çözünürlüğü olan 100 RPM'e yuvarlanır. Kritik kesme elle modda da geçerlidir.",
    "Live": "Anlık",

    /* ── lighting ───────────────────────────────────────────── */
    "Zones": "Bölgeler",
    "All zones": "Tüm bölgeler",
    "Effect": "Efekt",
    "Static": "Sabit",
    "Breathing": "Nefes",
    "Wave": "Dalga",
    "Spectrum": "Tayf",
    "Speed": "Hız",
    "Brightness": "Parlaklık",
    "The hardware switch is on/off only, so every level in between is produced by scaling the colours. Sliding to 0 switches the backlight off; anything above turns it on.":
      "Donanımdaki anahtar yalnızca açık/kapalı, dolayısıyla aradaki her seviye renkleri ölçekleyerek üretiliyor. 0'a çekmek arka ışığı kapatır; üstündeki her değer açar.",
    "the zone colours below are being animated":
      "aşağıdaki bölge renkleri canlandırılıyor",

    /* ── diagnosis ──────────────────────────────────────────── */
    "checking…": "kontrol ediliyor…",
    "Check again": "Yeniden kontrol et",
    "Copy report": "Raporu kopyala",
    "everything checked is working": "kontrol edilen her şey çalışıyor",
    "broken": "bozuk",
    "to know about": "bilinmesi gereken",
    "working": "çalışıyor",

    /* ── settings ───────────────────────────────────────────── */
    "This window": "Bu pencere",
    "These are yours, not the machine's: they live in your own config directory and change nothing for other users. The fan curve, the safety thresholds and the application profiles are machine-wide and live in":
      "Bunlar makinenin değil senin: kendi yapılandırma dizininde durur ve başka kullanıcılar için hiçbir şeyi değiştirmez. Fan eğrisi, güvenlik eşikleri ve uygulama profilleri makine geneline aittir ve şurada yaşar:",
    "Language": "Dil",
    "Follow the system": "Sistemi izle",
    "Refresh every": "Yenileme sıklığı",
    "1 second": "1 saniye",
    "2 seconds": "2 saniye",
    "5 seconds": "5 saniye",
    "10 seconds": "10 saniye",
    "Warn me when the fans are forced to full, or something fails":
      "Fanlar tam güce zorlandığında ya da bir şey başarısız olduğunda beni uyar",
    "Start with the session": "Oturumla birlikte başlat",
    "Start hidden in the tray": "Tepside gizli başlat",
    "There is no tray icon in this session, so starting hidden would leave you with a running program and no way back to it. Install":
      "Bu oturumda tepsi ikonu yok, dolayısıyla gizli başlamak elinde çalışan ama geri dönülemeyen bir program bırakırdı. Şunu kur:",
    "and reopen the app.": "ve uygulamayı yeniden aç.",

    "Machine defaults": "Makine varsayılanları",
    "The firmware remembers the last performance profile across a reboot. Naming one here makes the starting point explicit instead — useful if an evening on Performance should not become the new normal.":
      "Firmware son performans profilini yeniden başlatmalar boyunca hatırlar. Buradan bir tane seçmek başlangıç noktasını açıkça belirler — bir akşamlık Performance'ın kalıcı hale gelmesini istemiyorsan işe yarar.",
    "Profile at startup": "Açılıştaki profil",
    "leave it as the firmware remembers": "firmware ne hatırlıyorsa o kalsın",

    "Versions": "Sürümler",
    "Everything here is built and upgraded together, and then keeps running whatever was loaded before the upgrade. This is where you find out that the fix you installed is not the code you are running.":
      "Buradaki her şey birlikte derlenir ve birlikte güncellenir, sonra da güncellemeden önce yüklenmiş olanı çalıştırmaya devam eder. Kurduğun düzeltmenin, çalıştırdığın kod olmadığını burada öğrenirsin.",
    "Installed but not running. To catch up:":
      "Kurulu ama çalışmıyor. Yetişmek için:",
    "A reboot does all of it, and is the safer answer while the keyboard is lit or the fans are under load.":
      "Yeniden başlatma hepsini halleder ve klavye yanıyorken ya da fanlar yük altındayken daha güvenli olanıdır.",

    "Firmware": "Ürün yazılımı",
    "What": "Bu makinede",
    "can see on this machine, and what it has a newer version for. Nothing here flashes anything: firmware is the one thing that cannot be undone from a shell, and the checks that make flashing safe — mains power, battery level, the right reboot method — belong to":
      "ne görüyorsa ve hangisi için yeni sürümü varsa. Burada hiçbir şey yazılmıyor: ürün yazılımı kabuktan geri alınamayan tek şey, ve yazmayı güvenli kılan kontroller — priz, pil seviyesi, doğru yeniden başlatma yöntemi — şunun işi:",
    ", which already does them.": "— onlar zaten yapıyor.",
    "Scan": "Tara",
    "Check online": "Çevrimiçi bak",
    "To install what is waiting, in a terminal:":
      "Bekleyeni kurmak için, terminalde:",
    "scanning…": "taranıyor…",
    "asking LVFS…": "LVFS'e soruluyor…",
    "needs reboot": "yeniden başlatma gerekir",
    "something installed is newer than what is running":
      "kurulu olan, çalışandan yeni",
    "allowed to sleep, but it never has": "uyumasına izin var ama hiç uyumadı",
    "nothing — it is asleep": "hiçbir şey — uyuyor",
    "nothing": "hiçbir şey",
    "suspended (asleep)": "askıda (uyuyor)",
    "never": "hiç",
    "none": "yok",
    "copied": "kopyalandı",
    "commands copied": "komutlar kopyalandı",
    "report copied": "rapor kopyalandı",
    "curve saved": "eğri kaydedildi",
    "back to the built-in curve": "yerleşik eğriye dönüldü",
    "update metadata refreshed": "güncelleme verisi tazelendi",
    "a curve needs at least two points": "bir eğride en az iki nokta olmalı",
    "no curve to edit": "düzenlenecek eğri yok",
    "a process name is required": "bir süreç adı gerekli",
    "pick a profile, a fan mode, or both - otherwise there is nothing to apply":
      "bir profil, bir fan modu ya da ikisini seç — yoksa uygulanacak bir şey yok",
    "could not reach the clipboard": "panoya erişilemedi",

    /* ── the longer explanations the page builds itself ─────── */
    "Fans follow the curve in /etc/omen/omend.toml by temperature. This is the normal mode, and it is the equivalent of what OMEN Gaming Hub calls Auto - HP runs its curve in software too. Below the curve's lowest point the fans stop, but the setpoint stays ours, so the next sample can spin them back up.":
      "Fanlar /etc/omen/omend.toml içindeki eğriyi sıcaklığa göre izler. Normal mod budur ve OMEN Gaming Hub'ın Auto dediği şeyin karşılığıdır — HP de eğrisini yazılımda çalıştırır. Eğrinin en alt noktasının altında fanlar durur, ama ayar noktası bizde kalır; böylece bir sonraki ölçümde geri çalıştırılabilirler.",
    "A fixed target. The critical cutout still applies - a request here does not disable thermal protection.":
      "Sabit bir hedef. Kritik kesme yine geçerlidir — buradaki bir istek termal korumayı devre dışı bırakmaz.",
    "Fans at full power (WMI 0x27).": "Fanlar tam güçte (WMI 0x27).",
    "Advanced: hands the fans to the EC and stops managing them. The handover is not immediate - there is a watchdog, and the firmware can take up to two minutes to pick them up. Measured here, the fans sat at 0 RPM while the CPU climbed 78 to 85 C in twelve seconds under load, so two minutes is longer than it takes to overheat. omend forces full power if that happens and puts you back on Automatic. For comparing against stock behaviour, not for daily use.":
      "İleri düzey: fanları EC'ye devreder ve yönetmeyi bırakır. Devir anında olmaz — bir watchdog var ve firmware'in fanları devralması iki dakikayı bulabilir. Burada ölçüldü: yük altında CPU on iki saniyede 78'den 85 dereceye çıkarken fanlar 0 RPM'de kaldı, yani iki dakika ısınmanın gerektirdiğinden uzun. Böyle olursa omend tam güce geçer ve seni Otomatik moda geri alır. Fabrika davranışıyla karşılaştırmak için, günlük kullanım için değil.",

    "The zones keep the colour you set above.":
      "Bölgeler yukarıda verdiğin rengi korur.",
    "One colour fading in and out. Uses the colour picked above; pick a new one and set breathing again to change it.":
      "Tek renk, yavaşça açılıp sönüyor. Yukarıda seçilen rengi kullanır; değiştirmek için yeni bir renk seçip nefesi yeniden uygula.",
    "A hue travelling along the four zones.":
      "Dört bölge boyunca ilerleyen bir renk tonu.",
    "All four zones on the same hue, cycling through the spectrum.":
      "Dört bölge de aynı tonda, tayf boyunca dönüyor.",

    /* ── power limits, Unleashed, fan algorithm ─────────────── */
    "OMEN Gaming Hub's fourth mode: PL1 up to 71 W and the shared CPU+GPU limit raised, with the palm rest held under its limit. Firmware profile 0x04.":
      "OMEN Gaming Hub'ın dördüncü modu: PL1 71 W'a kadar, CPU+GPU ortak sınırı yükseltilmiş, avuç içi yüzeyi sınırının altında tutuluyor. Firmware profili 0x04.",
    "Surface": "Yüzey",
    "Power limits": "Güç sınırları",
    "What OMEN Gaming Hub sets around its modes, with HP's own ranges for this board. Unleashed raises the CPU's sustained limit and holds the palm rest under a temperature by taking it back down; the shared limit is what the CPU and GPU may draw together.":
      "OMEN Gaming Hub'ın modlarıyla birlikte ayarladıkları, HP'nin bu kart için verdiği aralıklarla. Unleashed CPU'nun sürekli güç sınırını yükseltir ve avuç içi yüzeyi bir sıcaklığın altında tutmak için gerektiğinde geri düşürür; ortak sınır CPU ile GPU'nun birlikte çekebileceği güçtür.",
    "Unleashed PL1": "Unleashed PL1",
    "Surface limit": "Yüzey sınırı",
    "Shared limit, Unleashed": "Ortak sınır, Unleashed",
    "Shared limit, performance": "Ortak sınır, performans",
    "Battery floor, performance": "Pil tabanı, performans",
    "Battery floor, Unleashed": "Pil tabanı, Unleashed",
    "CPU energy preference": "CPU enerji tercihi",
    "Follows the profile": "Profili izler",
    "shared": "ortak",
    "surface": "yüzey",
    "held down for the surface": "yüzey için düşürüldü",
    "kept in step by": "eşitleyen:",
    "not available": "yok",
    "What decides the speed": "Hızı ne belirliyor",
    "The curve": "Eğri",
    "OMEN Gaming Hub's tables": "OMEN Gaming Hub tabloları",
    "CPU, GPU and surface each have a table for the profile; the fans follow whichever asks for most.":
      "CPU, GPU ve yüzeyin her birinin profile göre bir tablosu var; fanlar en çok isteyeni izler.",
    "Running": "Çalışan",
    "CPU average": "CPU ortalaması",
    "The curve below drives the fans from the hottest CPU or GPU reading.":
      "Aşağıdaki eğri fanları en sıcak CPU ya da GPU okumasına göre sürer.",

    /* ── rules: refresh rate, GameMode ──────────────────────── */
    "refresh: leave alone": "yenileme: dokunma",
    "pick a profile, a fan mode or a refresh rate - otherwise there is nothing to apply":
      "bir profil, bir fan modu ya da bir yenileme hızı seç - yoksa uygulanacak bir şey yok",
    "A refresh rate is applied by a helper in your desktop session, because the screen belongs to it and not to the service. Turn the helper on once with":
      "Yenileme hızını masaüstü oturumundaki bir yardımcı uygular, çünkü ekran servise değil oturuma aittir. Yardımcıyı bir kez şununla aç:",
    ". It works on KDE, Hyprland, sway and X11; GNOME offers no way to do it.":
      ". KDE, Hyprland, sway ve X11'de çalışır; GNOME bunu yapmanın bir yolunu sunmuyor.",
    "Feral GameMode knows when any game is running, not just the ones listed above. While it says one is, these settings apply, and they go back afterwards. An application profile that names the game wins.":
      "Feral GameMode yalnızca yukarıdakileri değil, çalışan her oyunu bilir. Bir oyun çalışıyor dediği sürece bu ayarlar uygulanır, sonra geri alınır. Oyunun adını veren bir uygulama profili önceliklidir.",
    "GameMode has to be told about this once, with two lines in its configuration file:":
      "GameMode'a bunu bir kez, yapılandırma dosyasına iki satır ekleyerek söylemek gerekir:",
    "While a game runs": "Oyun çalışırken",
    "Hands the fans to the EC's own curve, the one the machine ships with. The hp-wmi this project builds writes the firmware's own automatic setpoint, so the EC takes over within two seconds and keeps the thermal profile. omend stops driving them until you choose another mode.":
      "Fanları EC'nin makineyle gelen kendi eğrisine bırakır. Bu projenin derlediği hp-wmi firmware'in kendi otomatik hedef değerini yazar; EC iki saniye içinde devralır ve termal profil korunur. Başka bir mod seçene kadar omend fanları sürmez.",
    "a game is running": "bir oyun çalışıyor",
  },
};

/* The language in effect. Resolved once, when the setting is applied. */
let LANG = "en";

/* Translate, or return the original. A missing entry is not an error: it
 * shows the English, which is always correct if not always ideal. */
function t(text) {
  if (LANG === "en" || text == null) return text;
  const table = I18N[LANG];
  if (!table) return text;

  const raw = String(text);
  // Prose in the markup is wrapped across lines and indented, so the text
  // node contains newlines and runs of spaces that the dictionary key does
  // not. Look it up normalised.
  const key = raw.replace(/\s+/g, " ").trim();
  const hit = table[key];
  if (hit === undefined) return raw;

  // Keep whatever spacing surrounded the text, so a translated fragment
  // sitting next to a <code> element keeps its gap.
  const before = raw.match(/^\s*/)[0];
  const after = raw.match(/\s*$/)[0];
  return before + hit + after;
}

/* Walks the page and translates what it recognises.
 *
 * Text nodes rather than elements: the markup mixes prose with <code> spans,
 * so the translatable units are the fragments between them - which is also
 * why the dictionary contains sentence fragments that look odd on their own.
 */
/* The English a node started with. Translating from the current text works
 * once and then traps the page in whatever language it reached first;
 * switching back to English, or between languages, has to go through the
 * original. A WeakMap because the nodes come and go with every render. */
const ORIGINALS = new WeakMap();

function original(node, current) {
  if (!ORIGINALS.has(node)) ORIGINALS.set(node, current);
  return ORIGINALS.get(node);
}

function translatePage(root = document.body) {
  const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
  const nodes = [];
  while (walker.nextNode()) nodes.push(walker.currentNode);

  for (const node of nodes) {
    const from = original(node, node.nodeValue);
    const to = t(from);
    if (to !== node.nodeValue) node.nodeValue = to;
  }

  for (const el of root.querySelectorAll("[placeholder]")) {
    el.placeholder = t(original(el, el.placeholder));
  }
  for (const el of root.querySelectorAll("[title]")) {
    el.title = t(original(el, el.title));
  }
}

/* Chooses the language and applies it.
 *
 * `null` follows the desktop, which is what someone running a Turkish system
 * expects without having to find a setting. Anything else is an explicit
 * choice and is obeyed.
 */
function applyLanguage(choice) {
  const wanted =
    choice ??
    (String(navigator.language || "").toLowerCase().startsWith("tr") ? "tr" : "en");
  LANG = I18N[wanted] ? wanted : "en";
  document.documentElement.lang = LANG;
  translatePage();
}

/* Strings added with the presets, the dust run and the lighting switches. */
Object.assign(I18N.tr, {
  "Quiet": "Sessiz",
  "Performance": "Performans",
  "Clear the dust": "Tozu temizle",
  "Runs both fans at full power for a while and then puts everything back. Worth doing with the laptop tilted; it is loud, and it is meant to be.":
    "İki fanı da bir süre tam güçte çalıştırır, sonra her şeyi eski haline döndürür. Dizüstünü eğik tutarak yapmaya değer; gürültülü, ve öyle olması gerekiyor.",
  "Run for 20 seconds": "20 saniye çalıştır",
  "Behaviour": "Davranış",
  "Put these colours back after a reboot":
    "Yeniden başlatmadan sonra bu renkleri geri getir",
  "Turn the backlight off on battery": "Pildeyken arka ışığı kapat",
  "The LED class does not survive a reboot — the keyboard comes up in whatever the firmware left — so the colours have to be written again by something. The service remembers them while no effect is running.":
    "LED sınıfı yeniden başlatmayı atlatmıyor — klavye, firmware ne bıraktıysa onunla açılıyor — dolayısıyla renkleri birinin yeniden yazması gerekiyor. Servis, hiçbir efekt çalışmazken onları hatırlıyor.",
});

/* Strings added with the Hub-style vitals page, the graphics switcher and the
 * lighting basics. */
Object.assign(I18N.tr, {
  "GPU Temperature": "GPU Sıcaklığı",
  "CPU Utilization": "CPU Kullanımı",
  "RAM Utilization": "RAM Kullanımı",
  "Storage": "Depolama",
  "Processes": "Süreçler",
  "free of": "boş /",
  "CPU side": "CPU tarafı",
  "GPU side": "GPU tarafı",
  "integrated": "tümleşik",
  "discrete": "ayrık",
  "Fan Speed": "Fan hızı",
  "Auto": "Otomatik",
  "CPU Temperature": "CPU Sıcaklığı",

  "Graphics Switcher": "Ekran kartı anahtarı",
  "now": "şimdi",
  "after the next restart": "bir sonraki yeniden başlatmadan sonra",
  "Hybrid": "Hibrit",
  "Discrete": "Ayrık",
  "Integrated Only": "Yalnızca tümleşik",
  "The screen runs off the integrated GPU and the discrete one sleeps until something asks for it. Longer battery, quieter.":
    "Ekran tümleşik GPU'dan çalışır, ayrık olan biri isteyene kadar uyur. Daha uzun pil, daha sessiz.",
  "The screen is driven by the NVIDIA GPU directly. Faster in games, and it never sleeps.":
    "Ekranı doğrudan NVIDIA GPU sürer. Oyunlarda daha hızlı, ve hiç uyumaz.",
  "The discrete GPU is switched off entirely. The longest battery life, and no NVIDIA acceleration at all.":
    "Ayrık GPU tamamen kapatılır. En uzun pil ömrü, ve hiç NVIDIA hızlandırma yok.",
  "Changing this re-wires the screen during the next boot — nothing happens until you restart. Hybrid keeps the discrete GPU asleep until something asks for it; Discrete drives the panel from it directly, which is faster in games and costs battery everywhere else.":
    "Bunu değiştirmek ekranı bir sonraki açılışta yeniden bağlar — yeniden başlatana kadar hiçbir şey olmaz. Hibrit, ayrık GPU'yu biri isteyene kadar uykuda tutar; Ayrık ise paneli doğrudan ondan sürer, ki bu oyunlarda daha hızlı ve diğer her yerde pilden yer.",

  "Know the way back before choosing Discrete: the panel is then driven by the NVIDIA GPU, and if that does not come up you need a working machine to undo it. A text console (Ctrl+Alt+F3) or ssh is enough —":
    "Ayrık'ı seçmeden önce dönüş yolunu bil: panel o zaman NVIDIA GPU tarafından sürülür, ve o açılmazsa geri almak için çalışan bir makineye ihtiyacın olur. Bir metin konsolu (Ctrl+Alt+F3) ya da ssh yeter —",
  "does not need a desktop.": "masaüstü gerektirmiyor.",
  "Hue": "Renk tonu",
  "Static": "Sabit",
  "Off": "Kapalı",
});

/* The two pages that were split out of Performance Control. */
Object.assign(I18N.tr, {
  "Game Profiles": "Oyun Profilleri",
  "Automatic profiles": "Otomatik profiller",
  "Two rules, applied in that order: a running program wins over the power source, because \"this game is open\" says more about what the machine should be doing than \"the charger is in\".":
    "İki kural, bu sırayla uygulanır: çalışan bir program güç kaynağına üstün gelir, çünkü \"bu oyun açık\" makinenin ne yapması gerektiği hakkında \"şarj takılı\"dan daha fazlasını söyler.",
  "Which GPU drives the screen, and what the discrete one is doing when nothing is asking it to.":
    "Ekranı hangi GPU sürüyor, ve kimse istemezken ayrık olan ne yapıyor.",
});

/* Named curves in a rule. */
Object.assign(I18N.tr, {
  "fan: quiet curve": "fan: sessiz eğri",
  "fan: default curve": "fan: varsayılan eğri",
  "fan: performance curve": "fan: performans eğrisi",
  "quiet": "sessiz",
  "default": "varsayılan",
  "performance": "performans",
  "curve": "eğrisi",
  "nothing to apply": "uygulanacak bir şey yok",
  "A rule is running the": "Bir kural şu anda",
  "curve; this is the configured one.": "eğrisini çalıştırıyor; buradaki yapılandırılmış olan.",
});

/* The OMEN key. */
Object.assign(I18N.tr, {
  "The OMEN key": "OMEN tuşu",
  "opens this window": "bu pencereyi açar",
  "steps through the profiles": "profiller arasında geçer",
  "does both": "ikisini birden yapar",
  "does nothing": "hiçbir şey yapmaz",
});

/* Strings added with the GPU power allowance and the GPU load ring. */
Object.assign(I18N.tr, {
  "GPU Usage": "GPU Kullanımı",
  "GPU power allowance": "GPU güç sınırı",
  "Follow the profile": "Profili takip et",
  "Leave to the firmware": "Firmware'e bırak",
  "running": "çalışıyor",
  "not running": "çalışmıyor",
  "on": "açık",
  "off": "kapalı",
  "Dynamic Boost is on but nvidia-powerd is not running":
    "Dynamic Boost açık ama nvidia-powerd çalışmıyor",
  "Following the profile does what the vendor software does on Windows: cTGP and Dynamic Boost in Performance, Dynamic Boost in Balanced, neither in Low power. Dynamic Boost lets the GPU borrow power the CPU is not using, and it only works while nvidia-powerd runs.":
    "Profili takip etmek, üretici yazılımının Windows'ta yaptığını yapar: Performans'ta cTGP ve Dynamic Boost, Dengeli'de Dynamic Boost, Düşük güçte hiçbiri. Dynamic Boost, GPU'nun CPU'nun kullanmadığı gücü ödünç almasını sağlar ve yalnızca nvidia-powerd çalışırken işe yarar.",
});

/* The profile cards, with what each was measured to allow. */
Object.assign(I18N.tr, {
  "Caps the CPU at 2.0 GHz - about 32 W under full load. A real limit rather than a preference, for stretching the battery.":
    "CPU'yu 2,0 GHz'de sınırlar - tam yükte yaklaşık 32 W. Bir tercih değil gerçek bir sınır; pili uzatmak için.",
  "Full 5.09 GHz boost, but reluctant about it; 55 W sustained. GPU limited to 80 W. Firmware profile 0x30.":
    "Tam 5,09 GHz'e çıkar ama isteksizce; sürekli 55 W. GPU 80 W ile sınırlı. Firmware profili 0x30.",
  "Same 5.09 GHz ceiling, reached sooner and held longer; 60 W sustained, and the GPU's limit goes to 100 W. Firmware profile 0x31.":
    "Aynı 5,09 GHz tavan, daha çabuk ulaşılır ve daha uzun tutulur; sürekli 60 W, ve GPU'nun sınırı 100 W'a çıkar. Firmware profili 0x31.",
});

/* Notifications beyond the fans being forced to full. */
Object.assign(I18N.tr, {
  "the service could not do something": "servis bir şeyi yapamadı",
  "the fans are not doing what they were told": "fanlar söyleneni yapmıyor",
  "the service stopped responding": "servis yanıt vermiyor",
  "the fans are with the firmware until it is back": "servis dönene kadar fanlar firmware'de",
});

/* The effect frame rate. */
Object.assign(I18N.tr, {
  "Smoothness": "Akıcılık",
});

/* Pulse, chase and gradient. */
Object.assign(I18N.tr, {
  "Pulse": "Nabız",
  "Chase": "Kovalamaca",
  "Gradient": "Geçiş",
  "One colour beating: a quick rise and a slower fade. Uses the colour picked above.":
    "Tek renk atıyor: hızlı yükseliş, daha yavaş sönüş. Yukarıda seçilen rengi kullanır.",
  "A light running left to right across the zones, with a tail. Uses the colour picked above.":
    "Bölgeler boyunca soldan sağa koşan, arkasında iz bırakan bir ışık. Yukarıda seçilen rengi kullanır.",
  "A still blend from the leftmost zone's colour to the rightmost's. Set those two zones first, then choose Gradient.":
    "En soldaki bölgenin renginden en sağdakine sabit bir geçiş. Önce bu iki bölgeyi ayarla, sonra Geçiş'i seç.",
});

/* The redrawn window. */
Object.assign(I18N.tr, {
  "Active Profile": "Etkin profil",
});

