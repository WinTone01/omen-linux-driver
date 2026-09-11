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
    "omend connected": "omend bağlı",
    "omend unreachable": "omend'e ulaşılamıyor",

    /* ── vitals ─────────────────────────────────────────────── */
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
    "There is no graphics mux on this board, so there is no panel to switch: the screen is wired to the integrated GPU and the NVIDIA card drives HDMI and anything you offload to it. To run a program on it, put this in front of the command — in Steam, before":
      "Bu kartta MUX yok, yani anahtarlanacak bir panel de yok: ekran tümleşik GPU'ya bağlı, NVIDIA kartı ise HDMI'ı ve ona yönlendirdiğin her şeyi sürüyor. Bir programı onun üzerinde çalıştırmak için komutun önüne şunu koy — Steam'de şunun önüne:",

    "Application profiles": "Uygulama profilleri",
    "While one of these programs is running, the machine switches to the settings you give it and goes back to what it was doing when the program exits. The first entry that is running wins.":
      "Bu programlardan biri çalışırken makine ona verdiğin ayarlara geçer, program kapanınca eskisine döner. Çalışanlardan listede ilk sırada olan kazanır.",
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
    "Warn me when the fans are forced to full":
      "Fanlar tam güce zorlandığında beni uyar",
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

  "Hue": "Renk tonu",
  "Static": "Sabit",
  "Off": "Kapalı",
});
