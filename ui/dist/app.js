/*
 * OMEN Control - front end.
 *
 * No build step and no framework on purpose: the page is a handful of
 * elements refreshed on a timer, and a bundler would be more moving parts
 * than the page itself. The backend returns the whole state in one call
 * (get_state), so a refresh is a single round trip.
 */

/*
 * Outside Tauri (a plain browser) there is no backend. Rather than throwing
 * on the first call we fall back to a stub, so the layout and the styling can
 * be worked on without the daemon, the kernel module, or even this machine.
 * Inside Tauri this branch is never taken.
 */
const MOCK = !window.__TAURI__;

const invoke = MOCK ? mockInvoke : window.__TAURI__.core.invoke;
const appWindow = MOCK
  ? { minimize() {}, toggleMaximize() {}, close() {} }
  : window.__TAURI__.window.getCurrentWindow();

const mockState = {
  daemon: {
    mode: { mode: "curve" },
    profile: "balanced",
    driver_label: "cpu/Tctl",
    driver_temp_c: 72.4,
    target_rpm: 2100,
    fan1_rpm: 2103,
    fan2_rpm: 1908,
    pwm: 112,
    safety_fallback: false,
    uptime_secs: 4230,
    temps: [["cpu/Tctl", 72.4], ["igpu/edge", 54.0], ["board/temp1", 46.0]],
    apps: [{ process: "cs2", profile: "performance", fan: { mode: "curve" }, curve: "performance" }],
    active_app: null,
    lighting_restore: false,
    lighting_fps: 30,
    lighting_off_on_battery: false,
    cleaning_secs_left: null,
    on_ac: true,
    battery_percent: 82,
    power_ac: {},
    power_battery: { profile: "low-power", fan: { mode: "curve" }, curve: "quiet" },
    curve_preset: null,
    gpu: {
      address: "0000:04:00.0", control: "auto", status: "active",
      suspended_ms: 0,
      holders: [{ pid: 1688, name: "quickshell",
                  nodes: ["/dev/dri/renderD128", "/dev/nvidia0"] }],
    },
    mux: { supported: ["uma", "hybrid", "discrete"], current: "hybrid",
           pending_reboot: false },
    gpu_boost: { ctgp: false, ppab: true, follows_profile: true },
    problems: [],
  },
  daemon_error: null,
  nvidia_powerd: true,
  leds: {
    brightness: 100,
    backlight_off: false,
    zones: Array.from({ length: 4 }, () => ({ r: 232, g: 17, b: 35 })),
  },
  leds_error: null,
  leds_writable: true,
  profile_choices: ["low-power", "balanced", "performance"],
  has_tray: true,
  interpolation: "step",
  effect: { effect: "none", speed: 5, color: { r: 232, g: 17, b: 35 } },
  curve: [
    { temp_c: 45, rpm: 0 },
    { temp_c: 50, rpm: 1800 },
    { temp_c: 55, rpm: 1800 },
    { temp_c: 60, rpm: 1800 },
    { temp_c: 65, rpm: 1800 },
    { temp_c: 70, rpm: 2400 },
    { temp_c: 75, rpm: 2400 },
    { temp_c: 80, rpm: 2400 },
    { temp_c: 85, rpm: 2400 },
    { temp_c: 90, rpm: 3300 },
  ],
};

/* The built-in table, kept so the mock backend's "reset" has something to go
 * back to. The real one lives in omen-core. */
const DEFAULT_CURVE = structuredClone(mockState.curve);

let mockSettings = { poll_ms: 2000, alerts: true, autostart: false, start_hidden: false };

/* What the sample machine reads at time t: a slow swell with some faster
 * texture, the way a laptop under a light load actually looks. */
function mockReading(t) {
  const cpu = 64 + 8 * Math.sin(t / 40) + 2.5 * Math.sin(t / 13);
  const gpu = 52 + 4 * Math.sin(t / 55 + 1) + 1.2 * Math.sin(t / 17);
  const fan = 2100 + 380 * Math.sin(t / 40 - 0.4) + 60 * Math.sin(t / 19);
  return {
    cpu: +cpu.toFixed(1),
    gpu: +gpu.toFixed(1),
    fan1: Math.round(fan),
    fan2: Math.round(fan * 0.9),
  };
}

async function mockInvoke(cmd, args) {
  switch (cmd) {
    case "get_state": {
      // A machine that is alive: the sample data drifts a little with time,
      // so the rings, sparklines and history have something to draw.
      const d = mockState.daemon;
      const at = mockReading(Date.now() / 1000);
      d.driver_temp_c = at.cpu;
      d.temps = [["cpu/Tctl", at.cpu], ["igpu/edge", at.gpu], ["board/temp1", 46.0]];
      d.fan1_rpm = at.fan1;
      d.fan2_rpm = at.fan2;
      return structuredClone(mockState);
    }
    case "samples": {
      // Ten minutes of the same drift, so the history is not blank when the
      // page opens - which is what the daemon's own record does for real.
      const now = Date.now() / 1000;
      const rows = [];
      for (let i = 300; i > 0; i--) {
        const r = mockReading(now - i * 2);
        rows.push({ uptime_secs: 4230 - i * 2, temp_c: r.cpu, fan_rpm: r.fan1, target_rpm: r.fan1 });
      }
      return rows;
    }
    case "set_mode":
      mockState.daemon.mode = args.mode;
      mockState.daemon.target_rpm =
        args.mode.mode === "manual" ? args.mode.rpm
        : args.mode.mode === "curve" ? 2100
        : null;
      return `mode: ${args.mode.mode}`;
    case "set_power_rules":
      mockState.daemon.power_ac = args.onAc;
      mockState.daemon.power_battery = args.onBattery;
      return "power rules saved";
    case "set_omen_key":
      mockState.daemon.omen_key = args.action;
      return `the OMEN key: ${args.action}`;
    case "set_startup_profile":
      mockState.daemon.startup_profile = args.profile;
      return args.profile ? `${args.profile} will be selected at startup`
                          : "the startup profile will be left to the firmware";
    case "history":
      return [
        { uptime_secs: 12, label: "cpu/Tctl", temp_c: 48.2, target_rpm: 0, reason: "cpu/Tctl 48.2C" },
        { uptime_secs: 96, label: "cpu/Tctl", temp_c: 58.1, target_rpm: 1800, reason: "cpu/Tctl 58.1C" },
        { uptime_secs: 240, label: "dgpu/ec", temp_c: 74.0, target_rpm: 2400, reason: "dgpu/ec 74.0C" },
      ];
    case "system_info":
      return {
        cpu_percent: 13, mem_used_gb: 15.6, mem_total_gb: 31.9, mem_percent: 49,
        disks: [
          { mount: "/", free_gb: 56.9, total_gb: 476.2, used_percent: 88 },
          { mount: "/home", free_gb: 170.2, total_gb: 931.5, used_percent: 82 },
        ],
        processes: [
          { pid: 1, name: "Century-Win64-Shipping", cpu_percent: 7, mem_mb: 1808 },
          { pid: 2, name: "steamwebhelper", cpu_percent: 2, mem_mb: 385 },
          { pid: 3, name: "chrome", cpu_percent: 1, mem_mb: 66 },
        ],
      };
    case "diagnose":
      return {
        sections: [
          { title: "Hardware", checks: [
            { id: "board", title: "Board", verdict: "ok", detail: "8D24, the one this is built for", fix: null },
          ]},
          { title: "Fan", checks: [
            { id: "pwm", title: "Fan control", verdict: "ok", detail: "hp-wmi exposes pwm1 (the 8D24 entry)", fix: null },
            { id: "profile", title: "Firmware thermal profile", verdict: "ok",
              detail: "hp-wmi is a platform_profile handler (amd-pmf, hp-wmi)", fix: null },
            { id: "tacho", title: "Fan tachometers", verdict: "ok",
              detail: "fan1 2104 RPM, fan2 1893 RPM (from EC RAM, through omen-kbd-rgb)", fix: null },
          ]},
          { title: "Thermal", checks: [
            { id: "sensors", title: "Temperature sensors", verdict: "ok",
              detail: "cpu/Tctl, igpu/edge, dgpu/ec, board/temp1", fix: null },
            { id: "dgpu_temp", title: "Discrete GPU temperature", verdict: "ok", detail: "being watched", fix: null },
          ]},
          { title: "Graphics", checks: [
            { id: "dgpu_pm", title: "GPU runtime power", verdict: "ok",
              detail: "may suspend; 42 minutes asleep so far", fix: null },
            { id: "dynamic_boost", title: "GPU power allowance", verdict: "ok",
              detail: "cTGP off, Dynamic Boost on", fix: null },
            { id: "mux", title: "Graphics switcher", verdict: "ok", detail: "hybrid (supports uma, hybrid, discrete)", fix: null },
          ]},
          { title: "Lighting", checks: [
            { id: "leds", title: "Keyboard lighting", verdict: "ok",
              detail: "omen-kbd-rgb 0.2.0, four zones, writable by the omen group", fix: null },
          ]},
          { title: "Service", checks: [
            { id: "daemon", title: "omend", verdict: "ok", detail: "running, the installed build", fix: null },
            { id: "skew", title: "Versions", verdict: "warn",
              detail: "the loaded omen-kbd-rgb is older than the installed one",
              fix: "sudo modprobe -r omen-kbd-rgb && sudo modprobe omen-kbd-rgb" },
          ]},
        ],
      };
    case "diagnose_text":
      return "omen-control 0.1.0 - 1 thing worth knowing about, 11 working\n";
    case "firmware":
      return {
        available: true, error: null, updates: true,
        devices: [
          { name: "System Firmware", version: "F.09", update: "F.12",
            updatable: true, needs_reboot: true },
          { name: "MZVL81T0HFLB-00BH1", version: "HPS1NKXF", update: null,
            updatable: true, needs_reboot: false },
          { name: "TPM", version: "10.6.0.4", update: null,
            updatable: false, needs_reboot: false },
        ],
      };
    case "firmware_refresh":
      return "metadata refreshed";
    case "get_settings":
      return structuredClone(mockSettings);
    case "set_settings":
      mockSettings = structuredClone(args.settings);
      return "settings saved";
    case "versions":
      return {
        app: "0.1.0", daemon: "0.1.0", daemon_reachable: true,
        modules: [
          { name: "omen_kbd_rgb", loaded: true, version: "0.1.0",
            loaded_srcversion: "A", installed_srcversion: "A" },
          { name: "hp_wmi", loaded: true, version: null,
            loaded_srcversion: "B", installed_srcversion: "C" },
        ],
      };
    case "diagnostics":
      return "omen-control 0.1.0\nboard        8D24\n(mock)\n";
    case "gpu_env":
      return {
        offload: "__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia",
        igpu: "__GLX_VENDOR_LIBRARY_NAME=mesa __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json",
      };
    case "set_gpu_mux":
      mockState.daemon.mux.current = args.mode;
      mockState.daemon.mux.pending_reboot = args.mode !== "hybrid";
      return `graphics set to ${args.mode}; it takes effect after a reboot`;
    case "set_gpu_boost":
      mockState.daemon.gpu_boost.follows_profile = args.mode === "profile";
      return args.mode === "profile"
        ? "cTGP and Dynamic Boost now follow the profile"
        : "cTGP and Dynamic Boost are left to the firmware";
    case "set_dgpu_power":
      mockState.daemon.gpu.control = args.power;
      return args.power === "auto"
        ? "the discrete GPU may suspend when idle"
        : "the discrete GPU is kept awake";
    case "set_app_profiles":
      mockState.daemon.apps = args.apps;
      return `${args.apps.length} application profile(s) saved`;
    case "set_effect":
      mockState.effect = { effect: args.effect, speed: args.speed, color: args.color };
      return args.effect === "none" ? "lighting effects off" : `lighting: ${args.effect}`;
    case "set_curve_preset":
      return `curve saved (${args.name})`;
    case "clean_fans":
      mockState.daemon.cleaning_secs_left = args.seconds;
      return `running the fans at full power for ${args.seconds}s, then back to normal`;
    case "set_lighting_fps":
      mockState.daemon.lighting_fps = args.fps;
      return `keyboard effects at ${args.fps} frames a second`;
    case "set_lighting_options":
      mockState.daemon.lighting_restore = args.restoreOnStart;
      mockState.daemon.lighting_off_on_battery = args.offOnBattery;
      return "lighting options saved";
    case "set_curve":
      mockState.curve = args.points;
      mockState.interpolation = args.interpolation;
      return `curve saved (${args.points.length} points)`;
    case "reset_curve":
      mockState.curve = structuredClone(DEFAULT_CURVE);
      return "curve saved (10 points), built-in";
    case "set_profile":
      mockState.daemon.profile = args.profile;
      return `profile ${args.profile}`;
    case "set_zone":
      mockState.leds.zones[args.index] = { r: args.r, g: args.g, b: args.b };
      return null;
    case "set_all_zones":
      mockState.leds.zones = mockState.leds.zones.map(() => ({ r: args.r, g: args.g, b: args.b }));
      return null;
    case "set_brightness":
      mockState.leds.brightness = args.value;
      mockState.leds.backlight_off = args.value === 0;
      return null;
    default:
      return "";
  }
}

const $ = (s) => document.querySelector(s);
const $$ = (s) => Array.from(document.querySelectorAll(s));

/* The poll interval is a user setting; this is the default until it loads.
 * pollTimer is rearmed whenever it changes rather than checked inside the
 * callback, so a slow poll really does mean fewer wake-ups. */
let POLL_MS = 2000;
let pollTimer = null;
/* Whether anyone can see this window. See setVisible. */
let visible = true;
const ZONES = ["Left", "WASD", "Centre", "Numpad"];

let state = null;
/* Suppresses the poll briefly after the user acts, so a stale reading does
 * not fight what they just set. */
let holdUntil = 0;
let toastTimer = null;

/* ── helpers ─────────────────────────────────────────────────── */

function toast(message, isError = false) {
  const el = $("#toast");
  el.textContent = message;
  el.classList.toggle("is-error", isError);
  el.hidden = false;
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => { el.hidden = true; }, isError ? 7000 : 2600);
}

const hex = ({ r, g, b }) =>
  "#" + [r, g, b].map((v) => v.toString(16).padStart(2, "0")).join("");

function rgb(h) {
  const n = parseInt(h.slice(1), 16);
  return { r: (n >> 16) & 255, g: (n >> 8) & 255, b: n & 255 };
}

const pct = (v, min, max) => Math.max(0, Math.min(100, ((v - min) / (max - min)) * 100));

const heat = (c) => (c >= 85 ? "is-hot" : c >= 70 ? "is-warm" : "is-cool");
const fanHeat = (rpm) => (rpm >= 3600 ? "is-hot" : rpm >= 2400 ? "is-warm" : "is-cool");

function setRing(id, percent, cls) {
  const el = $(id);
  el.style.setProperty("--p", percent.toFixed(1));
  el.classList.remove("is-cool", "is-warm", "is-hot");
  if (cls) el.classList.add(cls);
}

async function act(fn, okMessage) {
  try {
    const reply = await fn();
    holdUntil = Date.now() + 1200;
    if (okMessage !== null) toast(reply || okMessage);
    await refresh();
  } catch (e) {
    toast(String(e), true);
  }
}

/* ── chrome ──────────────────────────────────────────────────── */

$$(".win-btn").forEach((b) =>
  b.addEventListener("click", () => {
    const what = b.dataset.win;
    if (what === "minimize") appWindow.minimize();
    else if (what === "maximize") appWindow.toggleMaximize();
    else appWindow.close();
  }),
);

$("#btn-refresh").addEventListener("click", () => refresh());

/* The sidebar list and the tab strip select the same views, so a click on
 * either has to move both. */
const LAST_VIEW_KEY = "omen.view";

/* Work that belongs to a page rather than to the poll: the diagnosis checks,
 * the firmware scan, the decision log.
 *
 * Hung off the view switch rather than off the tab's click handler, because a
 * click is only one of the ways into a page - the window also reopens where
 * it was left, the address can name a page, and `omen-ui --tab X` raises one.
 * Hanging it off the click meant those three showed a page that said
 * "checking..." and never did.
 */
/* What each page is called, and what it is for.
 *
 * Here rather than in the markup because the header is one element that
 * changes, not eight that are hidden - and because these are the strings the
 * window translates, so they belong next to the rest of the copy.
 */
const PAGES = {
  vitals: ["System Vitals", "What the machine is doing right now."],
  performance: ["Performance Control", "The firmware's thermal profile, and what each mode actually does."],
  fan: ["Fan Control", "The curve, the mode, and a log of every setpoint the service chose."],
  automation: ["Game Profiles", "Rules that run the machine for you: a program, a state, a power source."],
  graphics: ["Graphics", "Which GPU drives the screen, and what the discrete one is doing."],
  lighting: ["Lighting", "Four zones, effects, and colours that survive a reboot."],
  diagnosis: ["Diagnosis", "Every part of the installation, checked, with what to do about anything wrong."],
  settings: ["Settings", "This window, the machine's defaults, versions and firmware."],
};

function renderPageHead(id) {
  const [title, sub] = PAGES[id] ?? PAGES.vitals;
  $("#page-title").textContent = t(title);
  $("#page-sub").textContent = t(sub);
}

function onViewShown(id) {
  if (id === "diagnosis") runDiagnosis(false);
  if (id === "settings") scanFirmware(false);
  if (id === "fan") refreshHistory();
}

function selectView(id) {
  $$("[data-view]").forEach((el) => {
    const match = el.dataset.view === id;
    if (el.classList.contains("view")) el.classList.toggle("is-active", match);
    else el.classList.toggle("is-active", match);
  });
  $(".main-scroll").scrollTop = 0;
  renderPageHead(id);
  onViewShown(id);
  // Remembered per machine, not in the settings file: which tab you had open
  // is a property of this window on this screen, not something to sync or
  // back up. localStorage can be unavailable, and a lost tab is not worth an
  // error.
  try {
    localStorage.setItem(LAST_VIEW_KEY, id);
  } catch {
    /* not important enough to report */
  }
}

// The sidebar entries and the tabs across the top go to the same places;
// selectView marks both.
$$(".device-link, .tab-link").forEach((el) =>
  el.addEventListener("click", () => selectView(el.dataset.view)),
);

/* Reopen where it was left, unless the address says otherwise. Both are
 * checked against the markup rather than trusted: a stored name from an older
 * version, or a hash someone typed, may not be a tab at all. */
function openInitialView() {
  const wanted = location.hash.replace(/^#/, "");
  if (wanted && $(`.device-link[data-view="${wanted}"]`)) {
    selectView(wanted);
    return;
  }
  try {
    const last = localStorage.getItem(LAST_VIEW_KEY);
    if (last && $(`.device-link[data-view="${last}"]`)) selectView(last);
  } catch {
    /* first run, or storage is off */
  }
}
openInitialView();
// openInitialView only calls selectView when it has somewhere to go; the
// default page needs its header filled in as well.
renderPageHead($(".view.is-active")?.dataset.view ?? "vitals");
window.addEventListener("hashchange", openInitialView);

/* ── keyboard graphic ────────────────────────────────────────── */

/* Generated rather than written by hand: 80-odd rects of varying width are
 * unreadable in markup, and the row shapes are what make it read as a
 * keyboard rather than a grid. */
function buildKeycaps() {
  const X0 = 14, X1 = 506, Y0 = 16, ROWH = 27, GAP = 2.5;
  const rows = [
    [...Array(13).fill(1), 1.6],
    [1.5, ...Array(12).fill(1), 1.0],
    [1.75, ...Array(11).fill(1), 1.6],
    [2.25, ...Array(10).fill(1), 2.0],
    [1.25, 1.25, 1.25, 6.25, 1.25, 1.25, 1.25],
  ];
  const ns = "http://www.w3.org/2000/svg";
  const g = $("#kb-keys");
  rows.forEach((widths, r) => {
    const y = Y0 + r * (ROWH + GAP);
    const unit = (X1 - X0 - GAP * (widths.length - 1)) / widths.reduce((a, b) => a + b, 0);
    let x = X0;
    widths.forEach((w) => {
      const kw = w * unit;
      const rect = document.createElementNS(ns, "rect");
      rect.setAttribute("x", x.toFixed(1));
      rect.setAttribute("y", y.toFixed(1));
      rect.setAttribute("width", kw.toFixed(1));
      rect.setAttribute("height", ROWH);
      rect.setAttribute("rx", 3);
      g.append(rect);
      x += kw + GAP;
    });
  });
}

function buildZonePickers() {
  const row = $("#zone-row");
  row.innerHTML = "";
  ZONES.forEach((name, i) => {
    const wrap = document.createElement("div");
    wrap.className = "zone-pick";
    const input = document.createElement("input");
    input.type = "color";
    input.id = `zone-${i}`;
    input.addEventListener("change", () =>
      act(() => invoke("set_zone", { index: i, ...rgb(input.value) }), null),
    );
    const label = document.createElement("label");
    label.textContent = name;
    label.htmlFor = input.id;
    wrap.append(input, label);
    row.append(wrap);
  });
}

/* ── fan ─────────────────────────────────────────────────────── */

const MODE_HELP = {
  curve:
    "Fans follow the curve in /etc/omen/omend.toml by temperature. This is the " +
    "normal mode, and it is the equivalent of what OMEN Gaming Hub calls Auto - " +
    "HP runs its curve in software too. Below the curve's lowest point the fans " +
    "stop, but the setpoint stays ours, so the next sample can spin them back up.",
  manual:
    "A fixed target. The critical cutout still applies - a request here does not " +
    "disable thermal protection.",
  max: "Fans at full power (WMI 0x27).",
  auto:
    "Advanced: hands the fans to the EC and stops managing them. The handover " +
    "is not immediate - there is a watchdog, and the firmware can take up to two " +
    "minutes to pick them up. Measured here, the fans sat at 0 RPM while the CPU " +
    "climbed 78 to 85 C in twelve seconds under load, so two minutes is longer " +
    "than it takes to overheat. omend forces full power if that happens and puts " +
    "you back on Automatic. For comparing against stock behaviour, not for " +
    "daily use.",
};

$$("#fan-modes button").forEach((b) =>
  b.addEventListener("click", () => {
    const mode = b.dataset.mode;
    const payload = mode === "manual"
      ? { mode: "manual", rpm: Number($("#rpm-range").value) }
      : { mode };
    act(() => invoke("set_mode", { mode: payload }));
  }),
);

$("#rpm-range").addEventListener("input", (e) => {
  $("#rpm-out").textContent = `${e.target.value} RPM`;
});

$("#rpm-range").addEventListener("change", (e) => {
  // Only send it in manual mode; otherwise dragging the slider would
  // silently take the fan away from the curve.
  if (state?.daemon?.mode?.mode !== "manual") return;
  act(() => invoke("set_mode", { mode: { mode: "manual", rpm: Number(e.target.value) } }));
});

$("#btn-reload").addEventListener("click", () => act(() => invoke("reload_config")));

/* ── lighting ────────────────────────────────────────────────── */

$("#all-color").addEventListener("change", (e) =>
  act(() => invoke("set_all_zones", rgb(e.target.value)), null),
);

$$("[data-preset]").forEach((b) =>
  b.addEventListener("click", () => {
    $("#all-color").value = b.dataset.preset;
    act(() => invoke("set_all_zones", rgb(b.dataset.preset)), null);
  }),
);

/* Effects are the daemon's job, not the UI's: they have to keep running when
 * this window is closed. So the buttons send the effect to omend and the
 * keyboard keeps doing it afterwards. */

const EFFECT_HINT = {
  none: "The zones keep the colour you set above.",
  breathing: "One colour fading in and out. Uses the colour picked above; " +
             "pick a new one and set breathing again to change it.",
  wave: "A hue travelling along the four zones.",
  pulse: "One colour beating: a quick rise and a slower fade. Uses the colour picked above.",
  chase: "A light running left to right across the zones, with a tail. Uses the colour picked above.",
  gradient: "A still blend from the leftmost zone's colour to the rightmost's. " +
            "Set those two zones first, then choose Gradient.",
  spectrum: "All four zones on the same hue, cycling through the spectrum.",
};

function currentEffect() {
  return state?.daemon?.effect ?? state?.effect ?? { effect: "none", speed: 5 };
}

function sendEffect(name) {
  const now = currentEffect();
  const zones = state?.leds?.zones ?? [];
  // The base colour is whatever the zones are showing - which is what "the
  // colour picked above" means to someone looking at the page. A gradient
  // takes its two ends from the outer zones, so it needs no second picker.
  // While an effect is running the zones show its frames, not a choice, so
  // the colours already configured are kept instead.
  const running = now.effect && now.effect !== "none";
  const pick = (i, kept) => (running ? kept : zones[i]) ?? kept;
  const oneColour = ["breathing", "pulse", "chase"].includes(name);
  const color = name === "gradient"
    ? pick(0, now.color)
    : oneColour ? pick(1, now.color) : now.color;
  const color2 = name === "gradient" ? pick(zones.length - 1, now.color2) : now.color2;
  act(() => invoke("set_effect", {
    effect: name,
    speed: Number($("#effect-speed").value),
    color: color ?? { r: 232, g: 17, b: 35 },
    color2: color2 ?? null,
  }));
}

$$("#effect-modes button").forEach((b) =>
  b.addEventListener("click", () => sendEffect(b.dataset.effect)),
);

$("#effect-speed").addEventListener("input", (e) => {
  $("#effect-speed-out").textContent = e.target.value;
});
$("#effect-speed").addEventListener("change", () => {
  const now = currentEffect();
  if (now.effect !== "none") sendEffect(now.effect);
});

function renderEffect(s) {
  const now = s.daemon?.effect ?? s.effect ?? { effect: "none", speed: 5 };
  $$("#effect-modes button").forEach((b) =>
    b.classList.toggle("is-active", b.dataset.effect === now.effect),
  );
  if (Date.now() > holdUntil) {
    $("#effect-speed").value = now.speed ?? 5;
    $("#effect-speed-out").textContent = String(now.speed ?? 5);
  }
  // A gradient holds still, so it has neither a speed nor a frame rate.
  const moves = now.effect !== "none" && now.effect !== "gradient";
  $("#effect-speed-row").hidden = !moves;
  $("#effect-fps-row").hidden = !moves;
  const fps = s.daemon?.lighting_fps ?? 30;
  $$("#effect-fps button").forEach((b) =>
    b.classList.toggle("is-active", Number(b.dataset.fps) === fps));
  $("#effect-hint").textContent = t(EFFECT_HINT[now.effect] ?? "");
  // An effect repaints the zones several times a second, so the colour
  // pickers below are not what the keyboard is showing. Say so.
  $("#effect-note").textContent =
    now.effect === "none" ? "" : t("the zone colours below are being animated");
}

$$("#effect-fps button").forEach((b) =>
  b.addEventListener("click", () =>
    act(() => invoke("set_lighting_fps", { fps: Number(b.dataset.fps) }))));

$("#bright-range").addEventListener("input", (e) => {
  $("#bright-out").textContent = `${e.target.value}%`;
});

$("#bright-range").addEventListener("change", (e) =>
  act(() => invoke("set_brightness", { value: Number(e.target.value) }), null),
);

/* ── rendering ───────────────────────────────────────────────── */

function renderDaemon(s) {
  const dot = $("#conn-dot");
  const text = $("#conn-text");
  const banner = $("#daemon-banner");

  if (!s.daemon) {
    dot.className = "status-dot is-down";
    text.textContent = t("omend unreachable");
    banner.hidden = false;
    banner.classList.add("is-error");
    banner.innerHTML =
      `<strong>The omend service cannot be reached.</strong> ` +
      `Fan readings and control are unavailable; lighting still works.` +
      (s.daemon_hint ? `<br>${s.daemon_hint}` : "") +
      (s.daemon_error ? `<br><code>${s.daemon_error}</code>` : "");
    return;
  }

  dot.className = "status-dot is-up";
  text.textContent = t("omend connected");
  banner.hidden = !s.daemon.safety_fallback;
  if (s.daemon.safety_fallback) {
    banner.classList.add("is-error");
    banner.innerHTML =
      "<strong>Safety override: the fans are at full power.</strong> Normal " +
      "control resumes once the temperature comes back down." +
      (s.daemon.safety_reason ? `<br><code>${s.daemon.safety_reason}</code>` : "");
  } else {
    banner.classList.remove("is-error");
  }

  const d = s.daemon;
  const cpu = d.driver_temp_c;

  // The Hub puts utilization in the ring and temperature in a badge below
  // it. We follow that where we have both. The GPU's load comes from NVML,
  // which is only asked while a program is already rendering on it - asking
  // otherwise would wake it - so the rest of the time its ring shows
  // temperature and says so.
  const cpuTemp = namedTemp(d, "cpu") ?? cpu;
  if (cpuTemp != null) setBadge("#cpu-badge", cpuTemp);
  $("#cpu-label").textContent = d.driver_label ?? "";

  const gpuTemp = namedTemp(d, "dgpu") ?? namedTemp(d, "igpu");
  const load = s.gpu_load ?? null;
  if (load?.util_pct != null) {
    $("#gpu-temp").textContent = `${load.util_pct}%`;
    $("#gpu-sub").textContent = t("GPU Usage");
    setRing("#ring-gpu", load.util_pct, gpuTemp != null ? heat(gpuTemp) : "");
    if (gpuTemp != null) setBadge("#gpu-badge", gpuTemp);
    const parts = [t("discrete")];
    if (load.power_w != null) {
      parts.push(load.power_limit_w != null
        ? `${load.power_w.toFixed(0)} / ${load.power_limit_w.toFixed(0)} W`
        : `${load.power_w.toFixed(0)} W`);
    }
    if (load.clock_mhz != null) parts.push(`${load.clock_mhz} MHz`);
    $("#gpu-label").textContent = parts.join(" · ");
  } else if (gpuTemp != null) {
    $("#gpu-temp").textContent = `${gpuTemp.toFixed(0)}°`;
    $("#gpu-sub").textContent = t("GPU Temperature");
    setRing("#ring-gpu", pct(gpuTemp, 30, 100), heat(gpuTemp));
    setBadge("#gpu-badge", gpuTemp);
    $("#gpu-label").textContent = t(d.temps?.find(([l]) => l.startsWith("dgpu"))
      ? "discrete" : "integrated");
  }

  for (const [key, value] of [["fan1", d.fan1_rpm], ["fan2", d.fan2_rpm]]) {
    // Rounded on the way out: an RPM is a whole number to a reader, and a
    // stray float renders as a wall of decimals.
    const v = Math.round(value ?? 0);
    const out = $(`#${key}-rpm`);
    if (out) out.textContent = v;
    // Coloured by how hard the fan itself is working, not by CPU temperature:
    // a fan ring turning amber because the CPU is warm says nothing about the
    // fan.
    if ($(`#ring-${key}`)) setRing(`#ring-${key}`, pct(v, 0, 4800), fanHeat(v));
    const live = $(`#f-${key}`);
    if (live) live.textContent = v;
  }
  // The second fan has no ring of its own on this page - the Hub has four
  // cards, not five - so it is named in the foot of the first.
  $("#fan1-foot").textContent = `${t("CPU side")} ${Math.round(d.fan1_rpm ?? 0)}`;
  $("#fan2-foot").textContent = `${t("GPU side")} ${Math.round(d.fan2_rpm ?? 0)}`;
  $("#f-pwm").textContent = d.pwm != null ? `${d.pwm}/255` : "—";

  $("#v-profile").textContent = d.profile ?? "—";
  $("#v-profile").className = "is-term";
  $("#v-mode").textContent = d.mode ? modeText(d.mode) : "—";
  $("#v-mode").className = "is-term";
  $("#v-target").textContent =
    d.target_rpm === 0 ? "fans off (idle)"
    : d.target_rpm != null ? `${d.target_rpm} RPM`
    : d.mode?.mode === "max" ? "full power"
    : "control is with the EC";
  $("#v-driver").textContent =
    d.driver_label && cpu != null ? `${d.driver_label} ${cpu.toFixed(1)} °C` : "—";
  renderGpu(d.gpu);
  $("#v-uptime").textContent = fmtUptime(d.uptime_secs);
  $("#profile-quick-label").textContent = d.profile ?? "—";

  $("#temp-list").innerHTML = (d.temps ?? [])
    .map(([label, c]) =>
      `<div class="temp-row"><span class="temp-row__name">${label}</span>` +
      `<span class="temp-row__bar"><i class="${heat(c)}" style="width:${pct(c, 30, 100)}%"></i></span>` +
      `<span class="temp-row__val">${c.toFixed(1)} °C</span></div>`)
    .join("");

  const active = d.mode?.mode ?? "curve";
  $$("#fan-modes button").forEach((b) =>
    b.classList.toggle("is-active", b.dataset.mode === active),
  );
  $("#fan-mode-help").textContent = t(MODE_HELP[active] ?? "");
  $("#fan-mode-help").classList.toggle("is-warning", active === "auto");
  $("#manual-card").style.opacity = active === "manual" ? "1" : ".55";

  if (active === "manual" && d.mode.rpm != null && Date.now() > holdUntil) {
    $("#rpm-range").value = d.mode.rpm;
    $("#rpm-out").textContent = `${d.mode.rpm} RPM`;
  }
}

/* The protocol names are not the labels people see - "curve" is presented as
 * Automatic and "auto" as EC default, so this has to translate rather than
 * print the wire value. */
const MODE_LABEL = { curve: "Automatic", auto: "EC default", max: "Max" };
const modeText = (m) =>
  m.mode === "manual" ? `Manual (${m.rpm} RPM)` : (MODE_LABEL[m.mode] ?? m.mode);

// Discrete GPU runtime power. Worth a line on this machine because the dGPU
// is the biggest single draw on battery, and it only saves anything if it is
// actually allowed to sleep - which it is not while something holds a
// /dev/nvidia* handle open.
function renderGpu(gpu) {
  const el = $("#v-gpu");
  if (!el) return;
  if (!gpu) { el.textContent = "none"; el.title = ""; return; }

  const suspended = gpu.suspended_ms > 0
    ? `${(gpu.suspended_ms / 60000).toFixed(0)} min asleep`
    : "never slept";

  if (gpu.control === "on") {
    el.textContent = `${gpu.status} — runtime PM off`;
    el.title = "power/control is \"on\": the GPU is pinned awake.";
  } else if (gpu.suspended_ms === 0 && gpu.status !== "suspended") {
    const who = (gpu.holders ?? []).map((h) => `${h.name} (${h.pid})`);
    el.textContent = who.length
      ? `awake — held by ${who[0].split(" (")[0]}${who.length > 1 ? ` +${who.length - 1}` : ""}`
      : "awake — never slept";
    el.title = who.length
      ? `Holding /dev/nvidia* open:\n${who.join("\n")}`
      : "Runtime PM is allowed but the GPU has never suspended.";
  } else {
    el.textContent = `${gpu.status} — ${suspended}`;
    el.title = "";
  }
  el.className = "is-term";
}

function fmtUptime(secs) {
  if (secs == null) return "—";
  const h = Math.floor(secs / 3600);
  const m = Math.floor((secs % 3600) / 60);
  return h > 0 ? `${h} h ${m} min` : `${m} min ${secs % 60} s`;
}

/* Measured on this machine. The clocks on battery, in both orders and with
 * enough settling time - a first attempt with two seconds produced "balanced
 * is the same as low-power", which is wrong. The watts on mains under a load
 * that reaches the power limit (omenctl profile measure,
 * docs/research/profile-power.md). */
const PROFILE_INFO = {
  "low-power": {
    blurb:
      "Caps the CPU at 2.0 GHz - about 32 W under full load. A real limit " +
      "rather than a preference, for stretching the battery.",
    icon: "M12 3v9m0 9a8 8 0 0 1-5.7-13.7M12 21a8 8 0 0 0 5.7-13.7",
  },
  balanced: {
    blurb:
      "Full 5.09 GHz boost, but reluctant about it; 55 W sustained. GPU " +
      "limited to 80 W. Firmware profile 0x30.",
    icon: "M3 12h4l3-7 4 14 3-7h4",
  },
  performance: {
    blurb:
      "Same 5.09 GHz ceiling, reached sooner and held longer; 60 W " +
      "sustained, and the GPU's limit goes to 100 W. Firmware profile 0x31.",
    icon: "M13 2 4 14h6l-1 8 9-12h-6l1-8Z",
  },
};

function renderProfiles(s) {
  const box = $("#profile-cards");
  const current = s.daemon?.profile;

  // Rebuilt when the language changes too: the blurbs are translated once,
  // when the cards are made.
  const built = `${s.profile_choices.length}:${LANG}`;
  if (box.dataset.built !== built) {
    box.innerHTML = "";
    s.profile_choices.forEach((name) => {
      const info = PROFILE_INFO[name] ?? { blurb: "", icon: "" };
      const card = document.createElement("button");
      card.className = "power-card";
      card.dataset.profile = name;
      card.innerHTML =
        `<svg class="power-card__icon" viewBox="0 0 24 24"><path d="${info.icon}"/></svg>` +
        `<h3>${name.replace("-", " ")}</h3><p>${t(info.blurb)}</p>` +
        // Said in words as well as in colour: which profile is in force is
        // the single most important thing on this page, and a border is not
        // an answer for somebody who cannot see the difference.
        `<span class="power-card__active">${t("in force")}</span>`;
      card.addEventListener("click", () => act(() => invoke("set_profile", { profile: name })));
      box.append(card);
    });
    box.dataset.built = built;
  }
  // Scoped to this grid. The graphics page draws its mux options with the
  // same class, and an unscoped selector cleared their selection on every
  // poll - saved only by the order the two happen to render in.
  $$("#profile-cards .power-card").forEach((c) =>
    c.classList.toggle("is-active", c.dataset.profile === current),
  );
}

function renderLeds(s) {
  const banner = $("#light-banner");

  if (!s.leds) {
    banner.hidden = false;
    banner.innerHTML =
      "<strong>The RGB module is not loaded.</strong> " +
      "Build it in <code>kernel/omen-kbd-rgb</code>, then " +
      "<code>sudo modprobe -a led-class-multicolor wmi</code> and " +
      `<code>sudo insmod omen-kbd-rgb.ko</code>.<br><code>${s.leds_error ?? ""}</code>`;
    return;
  }

  if (!s.leds_writable) {
    banner.hidden = false;
    banner.innerHTML =
      "<strong>The LED files are read-only for this user.</strong> " +
      "Install the udev rule (<code>packaging/99-omen-leds.rules</code>) and " +
      "join the <code>omen</code> group. A fresh group membership only takes " +
      "effect in a new login session.";
  } else if (s.leds.backlight_off) {
    banner.hidden = false;
    banner.innerHTML =
      "<strong>The keyboard backlight is off, so nothing here is visible.</strong> " +
      "Move the brightness slider above zero to switch it on.";
  } else {
    banner.hidden = true;
  }

  s.leds.zones.forEach((c, i) => {
    const colour = hex(c);
    const swatch = $(`#zone-${i}`);
    if (swatch && Date.now() > holdUntil) swatch.value = colour;
    const zone = $(`#z${i}`);
    if (!zone) return;
    // A zone set to black is off; show unlit plastic rather than a black
    // rectangle, which reads as "broken".
    const lit = c.r + c.g + c.b > 0 && !s.leds.backlight_off;
    zone.style.fill = lit ? colour : "#262626";
    // A wide glow spills onto the neighbouring zones and shifts their hue -
    // red bleeding over cyan reads as mauve. Keep it inside its own zone.
    zone.style.filter = lit ? `drop-shadow(0 0 3px ${colour}55)` : "none";
  });

  if (s.leds.brightness != null && Date.now() > holdUntil) {
    $("#bright-range").value = s.leds.brightness;
    $("#bright-out").textContent = `${s.leds.brightness}%`;
  }
}

/* ── charts ──────────────────────────────────────────────────── */

const NS = "http://www.w3.org/2000/svg";
// Half an hour at the daemon's own two-second tick. The window used to hold
// two minutes and start empty, which meant the graph could never show the
// spike that made somebody open it - by the time the window is up, the moment
// has gone. It is seeded from the daemon's own log instead; see seedHistory.
const HISTORY_MAX = 900;
const history = { temp: [], fan: [], spanSecs: 0 };

const TEMP_MIN = 30, TEMP_MAX = 100;
const FAN_MAX = 4800;

const el = (name, attrs) => {
  const n = document.createElementNS(NS, name);
  for (const [k, v] of Object.entries(attrs)) n.setAttribute(k, v);
  return n;
};

/** Maps a series onto an SVG path across the full 600x150 box. */
function seriesPath(values, min, max, w = 600, h = 150) {
  if (values.length < 2) return "";
  // Across the values there are rather than across the maximum: a half-full
  // buffer should fill the box, not leave the right half blank.
  const step = w / (values.length - 1);
  return values
    .map((v, i) => {
      const x = i * step;
      const y = h - ((Math.max(min, Math.min(max, v)) - min) / (max - min)) * h;
      return `${i ? "L" : "M"}${x.toFixed(1)} ${y.toFixed(1)}`;
    })
    .join(" ");
}

function drawGrid(id, rows, w, h) {
  const g = $(id);
  if (g.childElementCount) return;
  for (let i = 1; i < rows; i++) {
    const y = (h / rows) * i;
    g.append(el("line", { x1: 0, y1: y, x2: w, y2: y }));
  }
}

function drawHistory() {
  drawGrid("#chart-grid", 4, 600, 150);
  $("#line-temp").setAttribute("d", seriesPath(history.temp, TEMP_MIN, TEMP_MAX));
  $("#line-fan").setAttribute("d", seriesPath(history.fan, 0, FAN_MAX));
  const secs = Math.round(history.spanSecs);
  $("#chart-window").textContent =
    secs >= 60 ? `last ${Math.round(secs / 60)} min` : `last ${secs} s`;
}

/* ── the live panel and the sparklines ─────────────────────────
 *
 * Both are drawn from the same series the History chart uses, so they cannot
 * disagree with it, and both are cheap: a path string each, on the poll that
 * was already happening.
 */

/** A series as a path across its own box, with a little headroom. */
function sparkPath(values, w = 200, h = 26) {
  const seen = values.filter((v) => Number.isFinite(v) && v > 0);
  if (seen.length < 3) return "";
  // Scaled to what actually happened rather than to a fixed range: a
  // sparkline is about the shape, and 40-to-100 degrees flattens every real
  // change into a straight line.
  const lo = Math.min(...seen);
  const hi = Math.max(...seen);
  const span = Math.max(hi - lo, 1);
  const step = w / (values.length - 1);
  return values
    .map((v, i) => {
      const y = h - ((clamp(v, lo, hi) - lo) / span) * (h - 2) - 1;
      return `${i ? "L" : "M"}${(i * step).toFixed(1)} ${y.toFixed(1)}`;
    })
    .join(" ");
}

/** Rising, falling or steady, over the last minute or so of a series. */
function trendOf(values, deadband) {
  const tail = values.filter(Number.isFinite).slice(-30);
  if (tail.length < 8) return 0;
  const half = Math.floor(tail.length / 2);
  const mean = (xs) => xs.reduce((a, b) => a + b, 0) / xs.length;
  const delta = mean(tail.slice(half)) - mean(tail.slice(0, half));
  if (delta > deadband) return 1;
  if (delta < -deadband) return -1;
  return 0;
}

function setTrend(id, direction) {
  const el = $(id);
  if (!el) return;
  el.hidden = direction === 0;
  el.textContent = direction > 0 ? "▲" : "▼";
  el.className = `ring__trend ${direction > 0 ? "is-up" : "is-down"}`;
}

function drawSparks() {
  const temps = history.temp;
  const fans = history.fan;
  // The GPU has no series of its own - the chart follows the driving sensor -
  // so both temperature sparklines show the same shape. That is honest: it is
  // the curve's own view of the machine.
  for (const id of ["#spark-cpu", "#spark-gpu"]) {
    $(id)?.setAttribute("d", sparkPath(temps));
  }
  $("#spark-fan")?.setAttribute("d", sparkPath(fans));
  $("#now-spark-line")?.setAttribute("d", sparkPath(temps, 220, 34));

  // Half a degree of movement over a minute is weather, not a trend.
  setTrend("#cpu-trend", trendOf(temps, 0.6));
  setTrend("#gpu-trend", trendOf(temps, 0.6));
}

/** The sidebar panel: what is in force, wherever you are in the app. */
/** The silicon line under the model name. Written once - it cannot change
 *  while the window is open. */
function renderSpec(info) {
  const el = $("#device-spec");
  if (!el || el.dataset.done) return;
  const parts = [];
  if (info?.cpu_model) parts.push(info.cpu_model);
  if (info?.mem_total_gb) parts.push(`${Math.round(info.mem_total_gb)} GB`);
  if (!parts.length) return;
  el.textContent = parts.join(" · ");
  el.dataset.done = "1";
}

function renderNow(s) {
  const d = s.daemon;
  const panel = $("#now-panel");
  if (!panel) return;

  $("#now-profile").textContent = d?.profile ? t(d.profile) : "—";

  // The fan line says the mode and, when there is one, the setpoint - the
  // two halves of the question "what are the fans being told to do".
  let fan = "—";
  if (d?.mode) {
    fan = d.mode.mode === "manual" ? `${d.mode.rpm} RPM` : t(d.mode.mode);
  } else if (d) {
    fan = t("no fan control");
  }
  if (d?.curve_preset) fan += ` (${t(d.curve_preset)})`;
  $("#now-fan").textContent = fan;

  const cpu = namedTemp(d, "cpu") ?? d?.driver_temp_c;
  const gpu = namedTemp(d, "dgpu") ?? namedTemp(d, "igpu");
  const rpm = Math.max(d?.fan1_rpm ?? 0, d?.fan2_rpm ?? 0);

  const put = (id, value, suffix, hot, warm) => {
    const el = $(id);
    el.textContent = value == null ? "—" : `${Math.round(value)}${suffix}`;
    el.classList.toggle("is-hot", value != null && value >= hot);
    el.classList.toggle("is-warm", value != null && value >= warm && value < hot);
  };
  put("#now-cpu", cpu, "°", 85, 75);
  put("#now-gpu", gpu, "°", 85, 75);
  put("#now-rpm", rpm || null, "", Infinity, Infinity);
}

function pushHistory(temp, fan) {
  history.temp.push(temp ?? 0);
  history.fan.push(fan ?? 0);
  history.spanSecs += POLL_MS / 1000;
  while (history.temp.length > HISTORY_MAX) {
    history.temp.shift();
    history.fan.shift();
  }
  drawHistory();
  drawSparks();
}

/* The daemon has been watching since it started; this window has not.
 *
 * Without this the graph begins blank every time the window is opened, which
 * makes it useless for the thing people actually open it for - seeing what
 * just happened. Asked for once, at startup: after that the poll keeps it up
 * to date, and the two spacings (the daemon's tick and this window's poll)
 * only differ at the seam. */
async function seedHistory() {
  let rows = [];
  try {
    rows = await invoke("samples", { limit: HISTORY_MAX });
  } catch {
    return;
  }
  if (rows.length < 2 || history.temp.length > 2) return;

  history.temp = rows.map((r) => r.temp_c ?? 0);
  history.fan = rows.map((r) => r.fan_rpm ?? 0);
  // From the daemon's own clock rather than assumed: its interval is
  // configurable, and a graph labelled "last 30 min" that covers ten is worse
  // than no label.
  history.spanSecs = Math.max(0, rows[rows.length - 1].uptime_secs - rows[0].uptime_secs);
  drawHistory();
  drawSparks();
}

const CURVE_MIN_C = 40, CURVE_MAX_C = 100;

function drawCurve(points, interpolation, nowTemp, nowRpm) {
  if (!points?.length) return;
  const W = 600, H = 190;
  drawGrid("#curve-grid", 4, W, H);

  const x = (c) => ((c - CURVE_MIN_C) / (CURVE_MAX_C - CURVE_MIN_C)) * W;
  const y = (rpm) => H - (rpm / FAN_MAX) * (H - 10) - 5;

  // Drawn the way the curve is actually read. With step interpolation a
  // straight line between points would show a ramp where the daemon holds a
  // value - the chart would be lying about the behaviour.
  const step = interpolation !== "linear";
  let d = "";
  points.forEach((p, i) => {
    const px = x(p.temp_c), py = y(p.rpm);
    if (i === 0) {
      d += `M${px.toFixed(1)} ${py.toFixed(1)}`;
    } else if (step) {
      d += ` L${px.toFixed(1)} ${y(points[i - 1].rpm).toFixed(1)} L${px.toFixed(1)} ${py.toFixed(1)}`;
    } else {
      d += ` L${px.toFixed(1)} ${py.toFixed(1)}`;
    }
  });
  // Hold the last entry out to the right edge, which is what happens above
  // the top of the table.
  const last = points[points.length - 1];
  d += ` L${W} ${y(last.rpm).toFixed(1)}`;
  $("#curve-line").setAttribute("d", d);

  const marker = $("#curve-now");
  marker.replaceChildren();
  if (nowTemp == null) return;
  const mx = Math.max(0, Math.min(W, x(nowTemp)));
  const my = y(nowRpm ?? 0);
  marker.append(el("line", { x1: mx, y1: 0, x2: mx, y2: H }));
  if (nowRpm) marker.append(el("circle", { cx: mx, cy: my, r: 4 }));
  const label = el("text", { x: Math.min(mx + 6, W - 60), y: 14 });
  label.textContent = `${nowTemp.toFixed(0)}°C`;
  marker.append(label);
}

/* ── curve editor ────────────────────────────────────────────────
 *
 * The draft is a separate array, never the live state: while it exists the
 * poll keeps updating everything else, and a tick arriving mid-drag must not
 * pull the point out from under the pointer.
 *
 * Two things make a curve editor feel right, and the first version had
 * neither:
 *
 * 1. The handle you grabbed must stay the same DOM node for the whole drag.
 *    Redrawing the handle layer on every pointermove destroys the element
 *    holding the pointer capture, and the drag dies after the first few
 *    pixels. Handles are built once per shape change and only their
 *    coordinates are updated while dragging.
 *
 * 2. A point must be free to move. Clamping it between its neighbours sounds
 *    safe and is unusable: in HP's own table four points share 1800 RPM, so
 *    a clamped middle point cannot move vertically at all. Instead the drag
 *    is free and the neighbours give way - drag a point up and everything to
 *    its right comes up with it. The curve stays monotonic because the
 *    editor makes it so, not because it refused to move.
 *
 * The daemon still validates; it is the only thing that knows the critical
 * cutout. But a curve it would reject should be impossible to draw here.
 */

const CURVE_EDIT_MAX_C = 95;   // stay below the critical cutout (97 C)
const CURVE_TEMP_STEP = 1;
const CURVE_RPM_STEP = 100;    // the EC's own resolution
const CURVE_MIN_RPM = 1800;    // below this the fan does not turn
const CURVE_W = 600, CURVE_H = 190;

let draft = null;
let resetArmed = false;
let resetTimer = null;
/* Index of the point being dragged, so its label is always shown. */
let dragging = null;
/* The handle nodes, kept so a drag can move them instead of rebuilding. */
let handleNodes = [];

const clamp = (v, lo, hi) => Math.max(lo, Math.min(hi, v));

const curveX = (c) => ((c - CURVE_MIN_C) / (CURVE_MAX_C - CURVE_MIN_C)) * CURVE_W;
const curveY = (rpm) => CURVE_H - (rpm / FAN_MAX) * (CURVE_H - 10) - 5;

function curveEditing() {
  return draft !== null;
}

function startEdit() {
  const points = state?.curve ?? [];
  if (points.length < 2) {
    toast(t("no curve to edit"), true);
    return;
  }
  draft = points.map((p) => ({ ...p }));
  renderEditor();
}

function endEdit() {
  draft = null;
  dragging = null;
  renderEditor();
  refresh();
}

function renderEditor() {
  const editing = curveEditing();
  $("#btn-curve-edit").hidden = editing;
  for (const id of ["#btn-curve-cancel", "#btn-curve-save"]) {
    $(id).hidden = !editing;
  }
  $("#curve-edit-hint").hidden = !editing;
  $("#curve-chart").classList.toggle("is-editing", editing);
  $("#curve-line").classList.toggle("is-draft", editing);
  // Going back to the built-in table is worth offering without having to
  // enter the editor first - it is the way out of a curve you regret.
  $("#btn-curve-reset").textContent = t(resetArmed ? "Sure?" : "Defaults");
  $("#btn-curve-reset").classList.toggle("is-armed", resetArmed);
  if (editing) drawCurve(draft, state?.interpolation, null, null);
  buildHandles();
}

/* An RPM of 0 is not a speed, it is "fans off" - the daemon holds the
 * setpoint at zero rather than handing the fans to the EC - and it is only
 * allowed at the bottom of the curve. So the lowest point may be dragged down
 * into it, and no other point may. */
function snapRpm(raw, index) {
  const rounded = Math.round(raw / CURVE_RPM_STEP) * CURVE_RPM_STEP;
  if (index === 0) {
    // Half of the minimum is the dead zone where "off" is clearly what was
    // meant; above it the fan should actually turn.
    return rounded < CURVE_MIN_RPM / 2 ? 0 : clamp(rounded, CURVE_MIN_RPM, FAN_MAX);
  }
  return clamp(rounded, CURVE_MIN_RPM, FAN_MAX);
}

/* Move one point, and let the rest of the curve give way.
 *
 * Temperature stays between the neighbours - reordering points under the
 * pointer is disorienting, and that is what dragging past one would do. RPM
 * is free, and the neighbours are pushed to keep the curve monotonic. */
function moveDraftPoint(i, temp, rpm) {
  const p = draft[i];
  const prev = draft[i - 1], next = draft[i + 1];

  p.temp_c = Math.round(
    clamp(
      temp,
      prev ? prev.temp_c + CURVE_TEMP_STEP : CURVE_MIN_C,
      next ? next.temp_c - CURVE_TEMP_STEP : CURVE_EDIT_MAX_C,
    ) / CURVE_TEMP_STEP,
  ) * CURVE_TEMP_STEP;

  p.rpm = snapRpm(rpm, i);

  // Everything to the left must be no faster, everything to the right no
  // slower. A zero at the bottom is "off", not a speed, so it is never
  // pushed up by this.
  for (let j = i - 1; j >= 0; j--) {
    if (draft[j].rpm === 0) break;
    draft[j].rpm = Math.min(draft[j].rpm, Math.max(p.rpm, CURVE_MIN_RPM));
  }
  for (let j = i + 1; j < draft.length; j++) {
    draft[j].rpm = Math.max(draft[j].rpm, p.rpm);
  }
}

/* Builds the handle layer. Called when the shape changes - a point added or
 * removed, the editor opened or closed - never during a drag. */
function buildHandles() {
  const g = $("#curve-handles");
  g.replaceChildren();
  handleNodes = [];
  if (!curveEditing()) return;

  draft.forEach((p, i) => {
    const cx = curveX(p.temp_c), cy = curveY(p.rpm);
    // The hit target is deliberately much larger than the dot: dragging a
    // 4px circle with a trackpad is a test of patience, not a control.
    const hit = el("circle", { cx, cy, r: 14, class: "handle-hit" });
    hit.dataset.index = i;
    const dot = el("circle", { cx, cy, r: 4.5, class: "handle-dot" });
    const label = el("text", { "text-anchor": "middle" });
    g.append(hit, dot, label);
    handleNodes.push({ hit, dot, label });
  });
  positionHandles();
}

/* Moves the existing handle nodes to where the draft says they are. Cheap
 * enough to run on every pointermove, and it keeps the grabbed node alive. */
function positionHandles() {
  if (!curveEditing() || handleNodes.length !== draft.length) return;

  // The default table has ten points at 5 C spacing; labelling every one of
  // them is a line of overlapping text that reads as noise. Label a point
  // only when there is room, and always label the one being dragged.
  let lastLabelX = -Infinity;

  draft.forEach((p, i) => {
    const { hit, dot, label } = handleNodes[i];
    const cx = curveX(p.temp_c), cy = curveY(p.rpm);
    for (const node of [hit, dot]) {
      node.setAttribute("cx", cx.toFixed(1));
      node.setAttribute("cy", cy.toFixed(1));
    }
    dot.classList.toggle("is-active", i === dragging);

    const room = cx - lastLabelX >= 58;
    if (i !== dragging && !room) {
      label.textContent = "";
      return;
    }
    lastLabelX = cx;
    label.setAttribute("x", clamp(cx, 18, CURVE_W - 18).toFixed(1));
    label.setAttribute("y", clamp(cy - 13, 10, CURVE_H - 4).toFixed(1));
    label.textContent = p.rpm === 0 ? `${p.temp_c}° off` : `${p.temp_c}° ${p.rpm}`;
  });
}

function redrawDraft() {
  drawCurve(draft, state?.interpolation, null, null);
  positionHandles();
}

/* Pointer position -> chart coordinates. Read through the SVG's own matrix so
 * it stays correct whatever the window is scaled to. */
function chartPoint(ev) {
  const svg = $("#curve-chart");
  const pt = svg.createSVGPoint();
  pt.x = ev.clientX;
  pt.y = ev.clientY;
  const p = pt.matrixTransform(svg.getScreenCTM().inverse());
  return {
    temp_c: CURVE_MIN_C + (p.x / CURVE_W) * (CURVE_MAX_C - CURVE_MIN_C),
    rpm: ((CURVE_H - 5 - p.y) / (CURVE_H - 10)) * FAN_MAX,
  };
}

function bindCurveEditor() {
  const svg = $("#curve-chart");
  const handles = $("#curve-handles");

  $("#btn-curve-edit").addEventListener("click", startEdit);
  $("#btn-curve-cancel").addEventListener("click", endEdit);

  $("#btn-curve-save").addEventListener("click", () => {
    const points = draft;
    draft = null;
    dragging = null;
    act(() => invoke("set_curve", { points, interpolation: state?.interpolation ?? "step" }),
        "curve saved").then(renderEditor);
  });

  // Two clicks, because one misclick would throw away a curve someone spent
  // time on. A second button that says "Sure?" is lighter than a dialog and
  // forgets itself if you walk away.
  $("#btn-curve-code").addEventListener("click", async () => {
    try {
      await copyText(await invoke("curve_code"), t("curve code"));
    } catch (e) {
      toast(String(e), true);
    }
  });

  // A row that appears when asked for rather than a permanent field: pasting
  // a code is something somebody does once, and a box for it would otherwise
  // sit there inviting the question of what belongs in it.
  $("#btn-curve-import").addEventListener("click", () => {
    const row = $("#curve-import-row");
    row.hidden = !row.hidden;
    if (!row.hidden) $("#curve-code").focus();
  });

  const load = () => {
    const code = $("#curve-code").value.trim();
    if (!code) return;
    act(() => invoke("import_curve_code", { code }), t("curve imported"));
    $("#curve-code").value = "";
    $("#curve-import-row").hidden = true;
  };
  $("#btn-curve-code-load").addEventListener("click", load);
  $("#curve-code").addEventListener("keydown", (e) => {
    if (e.key === "Enter") load();
  });

  $("#btn-curve-reset").addEventListener("click", () => {
    if (!resetArmed) {
      resetArmed = true;
      renderEditor();
      clearTimeout(resetTimer);
      resetTimer = setTimeout(() => { resetArmed = false; renderEditor(); }, 4000);
      return;
    }
    clearTimeout(resetTimer);
    resetArmed = false;
    draft = null;
    dragging = null;
    act(() => invoke("reset_curve"), "back to the built-in curve").then(renderEditor);
  });

  handles.addEventListener("pointerdown", (ev) => {
    const hit = ev.target.closest("circle.handle-hit");
    if (!hit || ev.button !== 0 || !curveEditing()) return;
    ev.preventDefault();
    ev.stopPropagation();

    dragging = Number(hit.dataset.index);
    handles.classList.add("is-dragging");
    // Capture on the node under the pointer, which from here on is not
    // replaced - see the note at the top of this section.
    hit.setPointerCapture(ev.pointerId);
    positionHandles();

    const move = (e) => {
      if (dragging === null) return;
      const at = chartPoint(e);
      moveDraftPoint(dragging, at.temp_c, at.rpm);
      redrawDraft();
    };
    const up = () => {
      dragging = null;
      handles.classList.remove("is-dragging");
      hit.removeEventListener("pointermove", move);
      hit.removeEventListener("pointerup", up);
      hit.removeEventListener("pointercancel", up);
      positionHandles();
    };
    // On the capturing element, so the drag survives the pointer leaving the
    // chart - releasing outside the window still ends it.
    hit.addEventListener("pointermove", move);
    hit.addEventListener("pointerup", up);
    hit.addEventListener("pointercancel", up);
  });

  // Right-click removes. Two points is the minimum a curve can have.
  handles.addEventListener("contextmenu", (ev) => {
    const hit = ev.target.closest("circle.handle-hit");
    if (!curveEditing() || !hit) return;
    ev.preventDefault();
    if (draft.length <= 2) {
      toast(t("a curve needs at least two points"), true);
      return;
    }
    draft.splice(Number(hit.dataset.index), 1);
    drawCurve(draft, state?.interpolation, null, null);
    buildHandles();
  });

  // Click on empty chart adds a point where the curve already is, so adding
  // one never changes the behaviour by itself - it only gives you something
  // to drag.
  svg.addEventListener("click", (ev) => {
    if (!curveEditing() || ev.target.closest("circle.handle-hit")) return;
    const at = chartPoint(ev);
    const temp = Math.round(clamp(at.temp_c, CURVE_MIN_C, CURVE_EDIT_MAX_C));
    if (draft.some((p) => Math.abs(p.temp_c - temp) < CURVE_TEMP_STEP)) return;

    const below = draft.filter((p) => p.temp_c < temp).pop();
    draft.push({ temp_c: temp, rpm: below ? Math.max(below.rpm, CURVE_MIN_RPM) : draft[0].rpm });
    draft.sort((a, b) => a.temp_c - b.temp_c);
    drawCurve(draft, state?.interpolation, null, null);
    buildHandles();
  });
}

/* ── application profiles ────────────────────────────────────────
 *
 * The list is replaced wholesale on every edit rather than patched. Its order
 * is meaningful - the first running entry wins - so an add/remove API would
 * have to express ordering anyway, and "send the list you want" cannot get
 * out of step with what is displayed.
 */

function fanLabel(fan) {
  if (!fan) return "fan unchanged";
  if (fan.mode === "manual") return `fan ${fan.rpm} RPM`;
  return `fan ${fan.mode}`;
}

function appSummary(app) {
  const parts = [];
  if (app.profile) parts.push(app.profile);
  // The curve says more than "fan curve" does, so it replaces that half
  // rather than being listed next to it.
  if (app.curve) parts.push(`${t(app.curve)} ${t("curve")}`);
  else if (app.fan) parts.push(fanLabel(app.fan));
  return parts.join(" · ") || t("nothing to apply");
}

function saveApps(apps, message) {
  act(() => invoke("set_app_profiles", { apps }), message);
}

function renderApps(s) {
  const list = $("#apps-list");
  const apps = s.daemon?.apps ?? [];
  const active = s.daemon?.active_app ?? null;

  list.replaceChildren();
  for (const app of apps) {
    const row = document.createElement("div");
    row.className = "app-row" + (app.process === active ? " is-active" : "");

    const name = document.createElement("span");
    name.className = "app-row__name";
    name.textContent = app.process;

    const what = document.createElement("span");
    what.className = "app-row__what";
    what.textContent = appSummary(app);

    const drop = document.createElement("button");
    drop.className = "app-row__drop";
    drop.title = `Remove ${app.process}`;
    drop.textContent = "✕";
    drop.addEventListener("click", () =>
      saveApps(apps.filter((a) => a.process !== app.process), `${app.process} removed`));

    row.append(name);
    if (app.process === active) {
      const badge = document.createElement("span");
      badge.className = "app-row__badge";
      badge.textContent = t("running");
      row.append(badge);
    }
    row.append(what, drop);
    list.append(row);
  }

  $("#apps-note").textContent = active ? `${active} ${t("running")}` : "";
  // The rows were built after the page was translated, so they get their own
  // pass rather than being missed until the next language change.
  translatePage(list);

  fillChoices($("#app-fan"), FAN_CHOICES, "fan");

  // The profile choices come from the machine, so this cannot offer one the
  // firmware does not have.
  const sel = $("#app-profile");
  if (sel.dataset.built !== String(s.profile_choices?.length ?? 0)) {
    sel.dataset.built = String(s.profile_choices?.length ?? 0);
    sel.replaceChildren();
    const none = document.createElement("option");
    none.value = "";
    none.textContent = t("profile: leave alone");
    sel.append(none);
    for (const name of s.profile_choices ?? []) {
      const opt = document.createElement("option");
      opt.value = name;
      opt.textContent = `profile: ${name}`;
      sel.append(opt);
    }
  }
}

/* The programs running now, offered as completions for the process name.
 *
 * Refreshed when the page is opened rather than on every poll: it walks
 * /proc, and the list only matters while somebody is typing into the box.
 */
async function fillRunningPrograms() {
  const list = $("#running-programs");
  if (!list) return;
  let names = [];
  try {
    names = await invoke("running_programs");
  } catch {
    return;
  }
  list.replaceChildren();
  for (const name of names) {
    const opt = document.createElement("option");
    opt.value = name;
    list.append(opt);
  }
}

function bindApps() {
  // Typing into the box is the moment the list is wanted, and it is also
  // cheap enough to refresh then - a game started a minute ago should be in
  // it without reopening the page.
  $("#app-process").addEventListener("focus", fillRunningPrograms);
  fillRunningPrograms();

  const add = () => {
    const process = $("#app-process").value.trim();
    if (!process) {
      toast(t("a process name is required"), true);
      return;
    }
    const profile = $("#app-profile").value || null;
    const fanRaw = $("#app-fan").value;
    if (!profile && !fanRaw) {
      toast(t("pick a profile, a fan mode, or both - otherwise there is nothing to apply"), true);
      return;
    }
    const { fan, curve } = fanRuleFromValue(fanRaw);

    const apps = (state?.daemon?.apps ?? []).filter(
      (a) => a.process.toLowerCase() !== process.toLowerCase());
    apps.push({ process, profile, fan, curve });
    $("#app-process").value = "";
    saveApps(apps, `${process} added`);
  };

  $("#btn-app-add").addEventListener("click", add);
  $("#app-process").addEventListener("keydown", (e) => {
    if (e.key === "Enter") add();
  });
}

/* ── state triggers ──────────────────────────────────────────────
 *
 * The same list-replaced-wholesale shape as the application profiles above,
 * for the same reason: the order is meaningful (first match wins), so an
 * add/remove API would have to express ordering anyway.
 *
 * One entry per condition. Two rules watching the same thing could only
 * disagree, and the second would never fire.
 */

const TRIGGER_KINDS = [
  ["temp_above", "when it is hotter than", "C", 88],
  ["battery_below", "when the battery falls below", "%", 20],
  ["idle", "when nothing has happened for", "min", 30],
  ["lid_closed", "when the lid is shut", null, null],
  ["time_between", "between these times", "time", null],
  ["wifi_ssid", "when on this network", "ssid", null],
];

function triggerKind(when) {
  return TRIGGER_KINDS.find(([id]) => id === when) ?? TRIGGER_KINDS[0];
}

/** The condition in words - the same wording the daemon and CLI use. */
function triggerCondition(tr) {
  switch (tr.when) {
    case "temp_above": return `${t("above")} ${Math.round(tr.value)} C`;
    case "battery_below": return `${t("battery below")} ${Math.round(tr.value)}%`;
    case "idle": return `${t("idle for")} ${Math.round(tr.value)} ${t("min")}`;
    case "time_between": return `${t("between")} ${tr.from} ${t("and")} ${tr.to}`;
    case "wifi_ssid": return `${t("on the network")} ${tr.ssid}`;
    default: return t("the lid is shut");
  }
}

function saveTriggers(triggers, message) {
  act(() => invoke("set_triggers", { triggers }), message);
}

function renderTriggers(s) {
  const list = $("#triggers-list");
  if (!list) return;
  const triggers = s.daemon?.triggers ?? [];
  const active = s.daemon?.active_trigger ?? null;

  list.replaceChildren();
  for (const tr of triggers) {
    const condition = triggerCondition(tr);
    const row = document.createElement("div");
    row.className = "app-row" + (condition === active ? " is-active" : "");

    const name = document.createElement("span");
    name.className = "app-row__name";
    name.textContent = condition;

    const what = document.createElement("span");
    what.className = "app-row__what";
    what.textContent = appSummary(tr);

    const drop = document.createElement("button");
    drop.className = "app-row__drop";
    drop.title = `Remove ${condition}`;
    drop.textContent = "✕";
    drop.addEventListener("click", () =>
      saveTriggers(triggers.filter((x) => x.when !== tr.when), `${condition} removed`));

    row.append(name);
    if (condition === active) {
      const badge = document.createElement("span");
      badge.className = "app-row__badge";
      badge.textContent = t("in force");
      row.append(badge);
    }
    row.append(what, drop);
    list.append(row);
  }

  // The idle measurement is shown whether or not anything uses it: a rule
  // built on a number you cannot see is a rule you cannot trust.
  const idle = Math.floor((s.daemon?.idle_secs ?? 0) / 60);
  $("#triggers-note").textContent = active
    ? `${active} ${t("in force")}`
    : `${t("idle for")} ${idle} ${t("min")}`;
  translatePage(list);

  fillChoices($("#trigger-fan"), FAN_CHOICES, "fan");

  const kinds = $("#trigger-when");
  if (!kinds.dataset.built) {
    kinds.dataset.built = "1";
    for (const [id, label] of TRIGGER_KINDS) {
      const opt = document.createElement("option");
      opt.value = id;
      opt.textContent = t(label);
      kinds.append(opt);
    }
    syncTriggerValue();
  }

  const sel = $("#trigger-profile");
  if (sel.dataset.built !== String(s.profile_choices?.length ?? 0)) {
    sel.dataset.built = String(s.profile_choices?.length ?? 0);
    sel.replaceChildren();
    const none = document.createElement("option");
    none.value = "";
    none.textContent = t("profile: leave alone");
    sel.append(none);
    for (const name of s.profile_choices ?? []) {
      const opt = document.createElement("option");
      opt.value = name;
      opt.textContent = `profile: ${name}`;
      sel.append(opt);
    }
  }
}

/** The inputs follow the condition: a shut lid has nothing to fill in, a
 *  window has two times, a network has a name. */
function syncTriggerValue() {
  const [, , unit, preset] = triggerKind($("#trigger-when").value);
  const number = unit !== null && unit !== "time" && unit !== "ssid";

  $("#trigger-value").hidden = !number;
  $("#trigger-from").hidden = unit !== "time";
  $("#trigger-to").hidden = unit !== "time";
  $("#trigger-ssid").hidden = unit !== "ssid";

  if (number) {
    const box = $("#trigger-value");
    box.value = preset;
    box.max = unit === "C" ? 110 : unit === "%" ? 100 : 600;
  }
}

function bindTriggers() {
  if (!$("#btn-trigger-add")) return;
  $("#trigger-when").addEventListener("change", syncTriggerValue);

  $("#btn-trigger-add").addEventListener("click", () => {
    const when = $("#trigger-when").value;
    const [, , unit] = triggerKind(when);
    const profile = $("#trigger-profile").value || null;
    const fanRaw = $("#trigger-fan").value;
    if (!profile && !fanRaw) {
      toast(t("pick a profile, a fan mode, or both - otherwise there is nothing to apply"), true);
      return;
    }
    const number = unit !== null && unit !== "time" && unit !== "ssid";
    const value = number ? Number($("#trigger-value").value) : null;
    if (number && !(value > 0)) {
      toast(t("that condition needs a number"), true);
      return;
    }

    const from = unit === "time" ? $("#trigger-from").value : null;
    const to = unit === "time" ? $("#trigger-to").value : null;
    if (unit === "time" && (!from || !to || from === to)) {
      toast(t("give two different times"), true);
      return;
    }

    const ssid = unit === "ssid" ? $("#trigger-ssid").value.trim() : null;
    if (unit === "ssid" && !ssid) {
      toast(t("which network?"), true);
      return;
    }

    const { fan, curve } = fanRuleFromValue(fanRaw);

    const triggers = (state?.daemon?.triggers ?? []).filter((x) => x.when !== when);
    triggers.push({ when, value, profile, fan, curve, from, to, ssid });
    saveTriggers(triggers, t("trigger added"));
  });
}

/* ── graphics ────────────────────────────────────────────────────
 *
 * The discrete GPU's runtime power: what it is doing, who is stopping it
 * sleeping, and whether it may. The mux has its own card (renderMux).
 */

function renderGraphics(s) {
  const gpu = s.daemon?.gpu ?? null;
  const card = $("#gfx-card");
  if (!card) return;
  card.hidden = !gpu;
  if (!gpu) return;

  $("#gfx-layout").textContent =
    `NVIDIA card at ${gpu.address}, alongside the integrated GPU. ` +
    "Hybrid: programs run on the integrated GPU unless they ask for the other one.";

  $$("#gfx-power button").forEach((b) =>
    b.classList.toggle("is-active", b.dataset.power === gpu.control));

  $("#gfx-state").textContent = t(
    gpu.status === "suspended" ? "suspended (asleep)" : gpu.status);
  $("#gfx-state").className = "is-term";

  $("#gfx-suspended").textContent =
    gpu.suspended_ms > 0
      ? `${(gpu.suspended_ms / 60000).toFixed(0)} min`
      : gpu.control === "on" ? "never — you asked for that" : "never";

  const holders = gpu.holders ?? [];
  const cell = $("#gfx-holders");
  cell.textContent = holders.length
    ? holders.map((h) => `${h.name} (${h.pid})`).join(", ")
    : t(gpu.status === "suspended" ? "nothing — it is asleep" : "nothing");
  // Which device file each one has open, on hover: /dev/nvidia0 is a program
  // set up to render there, while only /dev/dri/cardN is usually one that
  // opened every card it could find - different problems, different fixes.
  cell.title = holders
    .map((h) => `${h.name} (${h.pid}): ${(h.nodes ?? []).join(" ")}`)
    .join("\n");

  $("#gfx-note").textContent =
    gpu.control === "auto" && gpu.suspended_ms === 0 && gpu.status !== "suspended"
      ? t("allowed to sleep, but it never has")
      : "";
}

/* cTGP and Dynamic Boost. Shown only where the module reports them. */
function renderBoost(s) {
  const b = s.daemon?.gpu_boost ?? null;
  const card = $("#boost-card");
  if (!card) return;
  card.hidden = !b;
  if (!b) return;

  const onOff = (v) => t(v ? "on" : "off");
  $$("#boost-mode button").forEach((btn) =>
    btn.classList.toggle("is-active",
      btn.dataset.boost === (b.follows_profile ? "profile" : "leave")));
  $("#boost-ctgp").textContent = onOff(b.ctgp);
  $("#boost-ppab").textContent = onOff(b.ppab);
  $("#boost-powerd").textContent = t(s.nvidia_powerd ? "running" : "not running");
  $("#boost-powerd").className = s.nvidia_powerd || !b.ppab ? "" : "is-warn";
  $("#boost-note").textContent = b.ppab && !s.nvidia_powerd
    ? t("Dynamic Boost is on but nvidia-powerd is not running")
    : "";
}

function bindGraphics() {
  $$("#boost-mode button").forEach((btn) =>
    btn.addEventListener("click", () =>
      act(() => invoke("set_gpu_boost", { mode: btn.dataset.boost }))));

  $$("#gfx-power button").forEach((b) =>
    b.addEventListener("click", () =>
      act(() => invoke("set_dgpu_power", { power: b.dataset.power }))));

  invoke("gpu_env")
    .then((env) => {
      $("#gfx-offload").textContent = env.offload;
      $("#gfx-igpu").textContent = env.igpu;
    })
    .catch(() => {});

  $("#btn-igpu-copy").addEventListener("click", () =>
    copyText($("#gfx-igpu").textContent.trim(), t("command")));

  $("#btn-gfx-copy").addEventListener("click", async () => {
    const text = $("#gfx-offload").textContent.trim();
    try {
      await navigator.clipboard.writeText(text);
      toast(t("copied"));
    } catch {
      // Clipboard access can be refused; selecting the text is the fallback
      // that always works.
      const range = document.createRange();
      range.selectNodeContents($("#gfx-offload"));
      const sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
      toast("could not copy - the command is selected, press Ctrl+C", true);
    }
  });
}

/* ── settings ────────────────────────────────────────────────────
 *
 * Two kinds of setting, deliberately not mixed. The ones in this section
 * belong to the person using the window and live in their own config
 * directory; anything that changes what the machine does goes to the daemon
 * and is written to /etc, where every user and the boot sequence see it.
 */

let settings = null;

async function loadSettings() {
  try {
    settings = await invoke("get_settings");
  } catch {
    settings = { poll_ms: 2000, alerts: true, autostart: false, start_hidden: false };
  }
  POLL_MS = settings.poll_ms;
  startPolling();
  applyLanguage(settings.lang ?? null);
  renderSettings();
}

function renderSettings() {
  if (!settings) return;
  $("#set-lang").value = settings.lang ?? "";
  $("#set-poll").value = String(settings.poll_ms);
  $("#set-alerts").checked = !!settings.alerts;
  $("#set-autostart").checked = !!settings.autostart;
  $("#set-hidden").checked = !!settings.start_hidden;
}

async function saveSettings(patch) {
  settings = { ...settings, ...patch };
  if (patch.poll_ms) {
    POLL_MS = patch.poll_ms;
    startPolling();
  }
  try {
    await invoke("set_settings", { settings });
  } catch (e) {
    toast(String(e), true);
  }
}

/* The startup profile is a machine setting, so it goes into the daemon's
 * config like everything else that outlives this window. */
/* Starting hidden needs somewhere to hide. Without a tray icon the option is
 * a trap - a running program with no window and no way back - so it is
 * disabled and the reason is given. */
function renderTrayDependent(s) {
  const box = $("#set-hidden");
  const has = s.has_tray !== false;
  box.disabled = !has;
  $("#set-hidden-note").hidden = has;
}

function renderStartupProfile(s) {
  const sel = $("#set-startup-profile");
  if (!sel) return;
  const choices = s.profile_choices ?? [];
  const current = s.daemon?.startup_profile ?? "";
  if (sel.dataset.built !== String(choices.length)) {
    sel.dataset.built = String(choices.length);
    sel.replaceChildren();
    const none = document.createElement("option");
    none.value = "";
    none.textContent = t("leave it as the firmware remembers");
    sel.append(none);
    for (const name of choices) {
      const opt = document.createElement("option");
      opt.value = name;
      opt.textContent = name;
      sel.append(opt);
    }
  }
  if (document.activeElement !== sel) sel.value = current;

  // The key belongs to the daemon rather than to this window - it is watched
  // whether or not the window is open - so it sits with the machine defaults.
  const key = $("#set-omen-key");
  if (key && document.activeElement !== key) {
    key.value = s.daemon?.omen_key ?? "window";
  }
}

/* ── versions ──────────────────────────────────────────────── */

const CATCH_UP = {
  omend: "sudo systemctl restart omend",
  hp_wmi: "sudo modprobe -r hp_wmi && sudo modprobe hp_wmi",
  omen_kbd_rgb: "sudo modprobe -r omen-kbd-rgb && sudo modprobe omen-kbd-rgb",
};

async function renderVersions() {
  let v;
  try {
    v = await invoke("versions");
  } catch {
    return;
  }

  const list = $("#ver-list");
  const commands = [];
  const rows = [];

  const daemonText =
    !v.daemon_reachable ? "not reachable"
    : v.daemon === null ? "running, but too old to report its version"
    : v.daemon === v.app ? `${v.daemon} (running)`
    : `${v.daemon} (running) — this window is ${v.app}`;
  const daemonStale = v.daemon_reachable && v.daemon !== v.app;
  if (daemonStale) commands.push(CATCH_UP.omend);
  rows.push(["omend", daemonText, daemonStale]);

  for (const m of v.modules) {
    const stale =
      m.loaded && m.loaded_srcversion && m.installed_srcversion &&
      m.loaded_srcversion !== m.installed_srcversion;
    if (stale && CATCH_UP[m.name]) commands.push(CATCH_UP[m.name]);
    rows.push([
      m.name,
      !m.loaded ? "not loaded"
      : stale ? `${m.version ?? "loaded"} — a different build is installed`
      : (m.version ?? "loaded"),
      stale,
    ]);
  }

  list.replaceChildren();
  for (const [name, text, stale] of rows) {
    const dt = document.createElement("dt");
    dt.textContent = name;
    const dd = document.createElement("dd");
    dd.textContent = text;
    dd.className = stale ? "ver-stale" : "is-term";
    list.append(dt, dd);
  }

  $("#footer-ver").textContent = v.app;
  $("#ver-catchup").hidden = commands.length === 0;
  $("#ver-commands").textContent = commands.join(" && ");
  $("#ver-note").textContent = commands.length
    ? t("something installed is newer than what is running")
    : "";
}

async function copyText(text, what) {
  try {
    await navigator.clipboard.writeText(text);
    toast(`${what} copied`);
  } catch {
    toast(t("could not reach the clipboard"), true);
  }
}

/* A desktop notification when the fans are forced to full, because that is
 * the one event worth interrupting someone for - and only on the edge, not
 * for every poll while it lasts. */
let lastFallback = false;

function maybeAlert(s) {
  const now = !!s.daemon?.safety_fallback;
  if (now && !lastFallback && settings?.alerts) {
    const reason = s.daemon?.safety_reason ?? "the temperature went too high";
    // The desktop's own notification, not the WebView's: this is the one
    // event worth interrupting somebody for, and the window is very often
    // not the thing they are looking at when it happens.
    invoke("notify", {
      title: t("fans forced to full power"),
      body: reason,
    }).catch(() => {});
    toast(`${t("fans forced to full power")} - ${reason}`, true);
  }
  lastFallback = now;
}

/* The other things worth a notification, each on its edge only:
 *   - a hardware command the service tried and the firmware refused (a
 *     profile that would not set, a GPU setting, the fans' mode);
 *   - the service going away, which leaves the fans to the EC;
 *   - the fans not doing what they were told.
 * Problems that were already there when the window opened are not
 * announced: the window did not see them happen. */
let lastProblemId = null;
let hadDaemon = null;
let lastDrift = null;

function maybeNotify(s) {
  if (!settings?.alerts) {
    lastProblemId = null;
    hadDaemon = null;
    lastDrift = null;
    return;
  }
  const d = s.daemon;
  const say = (title, body, urgency) => {
    invoke("notify", { title, body, urgency }).catch(() => {});
    toast(`${title} - ${body}`, true);
  };

  if (d) {
    const newest = Math.max(0, ...(d.problems ?? []).map((p) => p.id));
    if (lastProblemId !== null) {
      (d.problems ?? [])
        .filter((p) => p.id > lastProblemId)
        .slice(-3)
        .forEach((p) => say(t("the service could not do something"), p.what, "normal"));
    }
    lastProblemId = newest;

    if (d.drift && lastDrift === null && hadDaemon !== null) {
      say(t("the fans are not doing what they were told"), d.drift, "normal");
    }
    lastDrift = d.drift ?? null;
  }

  const has = !!d;
  if (hadDaemon === true && !has) {
    say(t("the service stopped responding"),
      s.daemon_error ?? t("the fans are with the firmware until it is back"), "critical");
  }
  hadDaemon = has;
}

function bindSettings() {
  $("#set-lang").addEventListener("change", (e) => {
    const lang = e.target.value || null;
    saveSettings({ lang });
    // Applied immediately rather than on the next start: a language setting
    // that needs a restart to take effect is a language setting nobody
    // trusts they set correctly.
    applyLanguage(lang);
    refresh();
  });

  $("#set-poll").addEventListener("change", (e) =>
    saveSettings({ poll_ms: Number(e.target.value) }));
  $("#set-alerts").addEventListener("change", (e) => {
    saveSettings({ alerts: e.target.checked });
    // Turning it on while the window is hidden should start the heartbeat
    // that makes it work, not wait for the next time the window is opened.
    startPolling();
  });
  $("#set-autostart").addEventListener("change", (e) =>
    saveSettings({ autostart: e.target.checked }));
  $("#set-hidden").addEventListener("change", (e) =>
    saveSettings({ start_hidden: e.target.checked }));

  $("#set-startup-profile").addEventListener("change", (e) =>
    act(() => invoke("set_startup_profile", { profile: e.target.value || null })));

  $("#set-omen-key").addEventListener("change", (e) =>
    act(() => invoke("set_omen_key", { action: e.target.value })));

  $("#btn-ver-copy").addEventListener("click", () =>
    copyText($("#ver-commands").textContent, t("commands")));

}

/* ── firmware ────────────────────────────────────────────────────
 *
 * Reports, never flashes. See the note at the top of fwupd.rs for why that
 * line is where it is.
 *
 * The scan is not part of the poll: it spawns fwupdmgr twice and the first
 * call after boot starts the fwupd daemon. It runs when this tab is first
 * opened, and whenever it is asked for.
 */

let firmwareScanned = false;

async function scanFirmware(force) {
  if (firmwareScanned && !force) return;
  firmwareScanned = true;

  const list = $("#fw-list");
  $("#fw-note").textContent = t("scanning…");
  list.replaceChildren();

  let fw;
  try {
    fw = await invoke("firmware");
  } catch (e) {
    $("#fw-note").textContent = String(e);
    return;
  }

  if (!fw.available) {
    $("#fw-note").textContent = "";
    const row = document.createElement("p");
    row.className = "hint";
    row.textContent =
      fw.error ?? "fwupd is not available on this machine.";
    list.append(row);
    $("#fw-apply").hidden = true;
    return;
  }

  for (const dev of fw.devices) {
    const row = document.createElement("div");
    row.className = "fw-row" + (dev.update ? " has-update" : "");

    const name = document.createElement("span");
    name.className = "fw-row__name";
    name.textContent = dev.name;
    row.append(name);

    if (dev.needs_reboot && dev.update) {
      const flag = document.createElement("span");
      flag.className = "fw-row__flag";
      flag.textContent = t("needs reboot");
      row.append(flag);
    }

    const ver = document.createElement("span");
    ver.className = "fw-row__ver";
    ver.textContent = dev.version ?? "—";
    row.append(ver);

    if (dev.update) {
      const arrow = document.createElement("span");
      arrow.className = "fw-row__new";
      arrow.textContent = `→ ${dev.update}`;
      row.append(arrow);
    }
    list.append(row);
  }

  const waiting = fw.devices.filter((d) => d.update).length;
  $("#fw-note").textContent = waiting
    ? `${waiting} update${waiting > 1 ? "s" : ""} waiting`
    : `${fw.devices.length} devices, nothing waiting`;
  $("#fw-apply").hidden = !waiting;
}

function bindFirmware() {
  $("#btn-fw-scan").addEventListener("click", () => scanFirmware(true));

  $("#btn-fw-refresh").addEventListener("click", async () => {
    $("#fw-note").textContent = t("asking LVFS…");
    try {
      await invoke("firmware_refresh");
      toast(t("update metadata refreshed"));
    } catch (e) {
      toast(String(e), true);
    }
    await scanFirmware(true);
  });

  $("#btn-fw-copy").addEventListener("click", () =>
    copyText($("#fw-command").textContent, "command"));

  // Scanned when the Settings tab is opened rather than at startup: there is
  // no reason to start the fwupd daemon for someone who only wanted to look
  // at a fan curve. The window can also REOPEN on this tab, which is not a
  // click, so that case is covered too.
  if ($('.view[data-view="settings"]')?.classList.contains("is-active")) {
    scanFirmware(false);
  }
}

/* ── diagnosis ───────────────────────────────────────────────────
 *
 * The checks live in omen-core, so this page and "omenctl doctor" ask the
 * same questions and get the same answers. All this does is render them -
 * and render the remedy, which is the half a diagnostic usually leaves out.
 *
 * Not on the poll: the checks talk to the daemon, walk /proc and shell out to
 * modinfo. Run when the page is opened, and when asked.
 */

let diagnosed = false;

const VERDICT_LABEL = { ok: "OK", warn: "WARN", fail: "FAIL", skip: "—" };

function countChecks(report, verdict) {
  return report.sections.reduce(
    (n, s) => n + s.checks.filter((c) => c.verdict === verdict).length, 0);
}

async function runDiagnosis(force) {
  if (diagnosed && !force) return;
  diagnosed = true;

  $("#diag-summary").textContent = t("checking…");
  $("#btn-diag-run").disabled = true;

  let report;
  try {
    report = await invoke("diagnose");
  } catch (e) {
    $("#diag-summary").textContent = String(e);
    $("#btn-diag-run").disabled = false;
    return;
  }
  $("#btn-diag-run").disabled = false;

  const fail = countChecks(report, "fail");
  const warn = countChecks(report, "warn");
  const ok = countChecks(report, "ok");

  $("#diag-summary").textContent =
    fail && warn ? `${fail} ${t("broken")}, ${warn} ${t("to know about")}`
    : fail ? `${fail} ${t("broken")}`
    : warn ? `${warn} ${t("to know about")}`
    : t("everything checked is working");

  const counts = $("#diag-counts");
  counts.replaceChildren();
  for (const [cls, n, label] of [
    ["is-fail", fail, t("broken")],
    ["is-warn", warn, t("to know about")],
    ["is-ok", ok, t("working")],
  ]) {
    if (!n) continue;
    const pill = document.createElement("span");
    pill.className = `diag-count ${cls}`;
    const b = document.createElement("b");
    b.textContent = String(n);
    pill.append(b, document.createTextNode(label));
    counts.append(pill);
  }

  const host = $("#diag-sections");
  host.replaceChildren();
  for (const section of report.sections) {
    const wrap = document.createElement("section");
    wrap.className = "diag-section";

    const h = document.createElement("h3");
    h.className = "diag-section__title";
    h.textContent = section.title;
    wrap.append(h);

    for (const check of section.checks) {
      const row = document.createElement("div");
      row.className = `diag-row is-${check.verdict}`;

      const badge = document.createElement("span");
      badge.className = `diag-badge is-${check.verdict}`;
      badge.textContent = VERDICT_LABEL[check.verdict] ?? check.verdict;

      const body = document.createElement("div");
      const title = document.createElement("div");
      title.className = "diag-row__title";
      title.textContent = check.title;
      const detail = document.createElement("div");
      detail.className = "diag-row__detail";
      detail.textContent = check.detail;
      body.append(title, detail);

      if (check.fix) {
        const fix = document.createElement("div");
        fix.className = "diag-row__fix";
        fix.textContent = check.fix;
        body.append(fix);
      }

      row.append(badge, body);
      wrap.append(row);
    }
    host.append(wrap);
  }
}

/* ── the things that need root ───────────────────────────────────
 *
 * The window sends a NAME, never a command; what each name runs lives in the
 * Rust side and nowhere else. The password is typed into the desktop's own
 * polkit dialog, which is the only prompt anyone should type one into.
 *
 * Shown only when there is something to do. A permanent list of root commands
 * on a page people visit when something is wrong is an invitation to run one
 * and see.
 */

async function renderRootActions() {
  const card = $("#root-card");
  if (!card) return;

  let actions = [];
  try {
    actions = await invoke("privileged_actions");
  } catch {
    card.hidden = true;
    return;
  }

  card.hidden = actions.length === 0;
  if (!actions.length) return;

  try {
    $("#root-asker").textContent = await invoke("privileged_asker");
  } catch {
    $("#root-asker").textContent = "";
  }

  const list = $("#root-list");
  list.replaceChildren();
  for (const action of actions) {
    const row = document.createElement("div");
    row.className = "app-row";

    const name = document.createElement("span");
    name.className = "app-row__name";
    name.textContent = t(action.title);

    const what = document.createElement("span");
    what.className = "app-row__what";
    // The command itself, not a description of it: a password prompt should
    // never be the first time you find out what is about to run.
    what.textContent = action.command;

    const run = document.createElement("button");
    run.className = "btn btn--sm btn--accent";
    run.textContent = t("Run");
    run.title = t(action.why);
    run.addEventListener("click", async () => {
      run.disabled = true;
      run.textContent = t("asking…");
      try {
        toast(await invoke("run_privileged", { action: action.id }));
        await refresh();
        await renderRootActions();
      } catch (e) {
        // A cancelled dialog lands here too, which is right: nothing
        // happened, and the row stays where it was.
        toast(String(e), true);
        run.disabled = false;
        run.textContent = t("Run");
      }
    });

    row.append(name, what, run);
    list.append(row);
  }
  translatePage(list);
}

function bindDiagnosis() {
  $("#btn-diag-run").addEventListener("click", renderRootActions);
  $("#btn-diag-run").addEventListener("click", () => runDiagnosis(true));
  $("#btn-diag-copy").addEventListener("click", async () => {
    const text = await invoke("diagnose_text");
    await copyText(text, t("report"));
  });

  renderRootActions();

  $("#btn-diag-save").addEventListener("click", async () => {
    const note = $("#diag-saved");
    note.hidden = false;
    note.textContent = t("writing the report…");
    try {
      const path = await invoke("save_report");
      note.textContent = `${t("Written to")} ${path}`;
    } catch (e) {
      note.textContent = String(e);
    }
  });

  // Entering the page is what starts a scan - see onViewShown. This covers
  // the one case that is not a view switch: the page the window opened on.
  if ($('.view[data-view="diagnosis"]')?.classList.contains("is-active")) {
    runDiagnosis(false);
  }
}

/* ── power source ────────────────────────────────────────────────
 *
 * Four selects describing two rules. Filled from the machine's own profile
 * list, and sent as a pair because the daemon stores them as a pair - sending
 * one at a time would leave the two halves out of step if an edit were
 * interrupted.
 */

/* One control answers "how should the fan behave", because the two halves of
 * that answer - whether the curve drives, and which curve - are never chosen
 * independently. "curve:performance" carries both. */
const FAN_CHOICES = [
  ["", "fan: leave alone"],
  ["curve", "fan: curve"],
  ["curve:quiet", "fan: quiet curve"],
  ["curve:default", "fan: default curve"],
  ["curve:performance", "fan: performance curve"],
  ["max", "fan: max"],
  ["2400", "fan: 2400 RPM"],
  ["3000", "fan: 3000 RPM"],
  ["3600", "fan: 3600 RPM"],
];

/* A rule's fan + curve as one select value, and back. */
function fanRuleValue(rule) {
  if (rule?.curve) return `curve:${rule.curve}`;
  return fanValue(rule?.fan);
}

function fanRuleFromValue(v) {
  if (v.startsWith("curve:")) {
    return { fan: { mode: "curve" }, curve: v.slice("curve:".length) };
  }
  return { fan: fanFromValue(v), curve: null };
}

function fillChoices(sel, options, built) {
  if (sel.dataset.built === built) return;
  sel.dataset.built = built;
  sel.replaceChildren();
  for (const [value, label] of options) {
    const opt = document.createElement("option");
    opt.value = value;
    opt.textContent = t(label);
    sel.append(opt);
  }
}

function fanValue(fan) {
  if (!fan) return "";
  return fan.mode === "manual" ? String(fan.rpm) : fan.mode;
}

function fanFromValue(v) {
  if (!v) return null;
  return /^\d+$/.test(v) ? { mode: "manual", rpm: Number(v) } : { mode: v };
}

function renderPowerRules(s) {
  const choices = s.profile_choices ?? [];
  const built = String(choices.length);
  const profileOptions = [["", t("profile: leave alone")]]
    .concat(choices.map((c) => [c, `${t("profile")}: ${c}`]));

  for (const id of ["#power-ac-profile", "#power-bat-profile"]) {
    fillChoices($(id), profileOptions, built);
  }
  for (const id of ["#power-ac-fan", "#power-bat-fan"]) {
    fillChoices($(id), FAN_CHOICES, "fan");
  }

  const ac = s.daemon?.power_ac ?? {};
  const bat = s.daemon?.power_battery ?? {};
  // Not while someone is choosing: overwriting an open select mid-decision is
  // what makes a settings page feel haunted.
  const set = (sel, value) => {
    if (document.activeElement !== sel) sel.value = value;
  };
  set($("#power-ac-profile"), ac.profile ?? "");
  set($("#power-ac-fan"), fanRuleValue(ac));
  set($("#power-bat-profile"), bat.profile ?? "");
  set($("#power-bat-fan"), fanRuleValue(bat));

  const onAc = s.daemon?.on_ac;
  const pct = s.daemon?.battery_percent;
  $("#power-note").textContent =
    onAc === true ? `on mains${pct != null ? `, battery ${pct}%` : ""}`
    : onAc === false ? `on battery${pct != null ? ` ${pct}%` : ""}`
    : "";
}

function bindPowerRules() {
  const send = () => {
    const rule = (p, f) => ({
      profile: $(p).value || null,
      ...fanRuleFromValue($(f).value),
    });
    act(() => invoke("set_power_rules", {
      onAc: rule("#power-ac-profile", "#power-ac-fan"),
      onBattery: rule("#power-bat-profile", "#power-bat-fan"),
    }));
  };

  for (const id of ["#power-ac-profile", "#power-ac-fan",
                    "#power-bat-profile", "#power-bat-fan"]) {
    $(id).addEventListener("change", send);
  }
}

/* ── decision log ────────────────────────────────────────────────
 *
 * Asked for separately from the status, and only while the Fan tab is open:
 * the status is polled every couple of seconds and nobody needs two hundred
 * rows of history at that rate.
 */

function fmtSince(secs) {
  if (secs < 60) return `${secs}s`;
  if (secs < 3600) return `${Math.floor(secs / 60)}m ${secs % 60}s`;
  return `${Math.floor(secs / 3600)}h ${Math.floor((secs % 3600) / 60)}m`;
}

async function refreshHistory() {
  const list = $("#hist-list");
  if (!list) return;

  let rows;
  try {
    rows = await invoke("history", { limit: 200 });
  } catch {
    return;
  }

  list.replaceChildren();
  for (const row of rows) {
    const el = document.createElement("div");
    const off = row.target_rpm === 0;
    const max = row.target_rpm != null && row.target_rpm >= FAN_MAX;
    el.className = "hist-row" + (off ? " is-off" : max ? " is-max" : "");

    const when = document.createElement("span");
    when.className = "hist-row__when";
    when.textContent = `+${fmtSince(row.uptime_secs)}`;

    const what = document.createElement("span");
    what.textContent = `${row.label} ${row.temp_c.toFixed(1)} °C`;

    const target = document.createElement("span");
    target.className = "hist-row__target";
    target.textContent =
      row.target_rpm == null ? "EC"
      : row.target_rpm === 0 ? t("fans off")
      : `${row.target_rpm} RPM`;
    target.title = row.reason;

    el.append(when, what, target);
    list.append(el);
  }
  $("#hist-note").textContent = rows.length
    ? `${rows.length} ${t("changes since the service started")}`
    : "";
}

function bindHistory() {
  // Refreshed when the tab is opened and on the normal poll while it is the
  // visible one - a log nobody is looking at does not need updating.
  if ($('.view[data-view="fan"]')?.classList.contains("is-active")) refreshHistory();
}

/* ── presets, dust, lighting behaviour ───────────────────────────
 *
 * The presets send points rather than a name so the daemon has one way in for
 * a curve: starting from a preset and then dragging it is the same path as
 * drawing one from scratch.
 */

function bindExtras() {
  $$("[data-preset-curve]").forEach((b) =>
    b.addEventListener("click", () => {
      // Leaving the editor open on a curve that has just been replaced would
      // show a draft of the old one.
      draft = null;
      act(() => invoke("set_curve_preset", { name: b.dataset.presetCurve }))
        .then(renderEditor);
    }));

  $("#btn-clean").addEventListener("click", () =>
    act(() => invoke("clean_fans", { seconds: 20 })));

  const sendLighting = () =>
    act(() => invoke("set_lighting_options", {
      restoreOnStart: $("#light-restore").checked,
      offOnBattery: $("#light-battery").checked,
    }), null);

  $("#light-restore").addEventListener("change", sendLighting);
  $("#light-battery").addEventListener("change", sendLighting);
}

function renderExtras(s) {
  const left = s.daemon?.cleaning_secs_left ?? null;
  $("#btn-clean").disabled = left != null;
  $("#clean-note").textContent = left != null ? `${left}s` : "";

  if (Date.now() > holdUntil) {
    $("#light-restore").checked = !!s.daemon?.lighting_restore;
    $("#light-battery").checked = !!s.daemon?.lighting_off_on_battery;
  }
}

/* ── the Hub's non-thermal vitals ────────────────────────────────
 *
 * CPU load, memory, disks and the busiest processes. Read straight from /proc
 * in the Rust side; none of it goes near the daemon, because none of it is
 * hardware-specific and none of it needs privileges.
 */

function namedTemp(daemon, prefix) {
  const hit = (daemon?.temps ?? []).find(([label]) => label.startsWith(prefix));
  return hit ? hit[1] : null;
}

/* The green circle the Hub hangs off the bottom-left of each ring. */
function setBadge(id, celsius) {
  setBadgeText(id, `${celsius.toFixed(0)}°C`, heat(celsius));
}

function setBadgeText(id, text, cls) {
  const el = $(id);
  if (!el) return;
  el.textContent = text;
  el.className = `ring-card__badge ${cls ?? ""}`;
  el.hidden = false;
}

async function renderSystem() {
  let info;
  try {
    info = await invoke("system_info");
  } catch {
    return;
  }

  renderSpec(info);

  if (info.cpu_percent != null) {
    $("#cpu-util").textContent = `${Math.round(info.cpu_percent)}%`;
    setRing("#ring-cpu", info.cpu_percent, loadHeat(info.cpu_percent));
    const strip = $("#perf-cpu-util");
    if (strip) strip.textContent = `${Math.round(info.cpu_percent)}%`;
  }

  $("#ram-pct").textContent = `${Math.round(info.mem_percent)}%`;
  setRing("#ring-ram", info.mem_percent, loadHeat(info.mem_percent));
  $("#ram-foot").textContent =
    `${info.mem_used_gb.toFixed(1)}GB / ${info.mem_total_gb.toFixed(1)}GB`;

  const disks = $("#disk-list");
  disks.replaceChildren();
  for (const disk of info.disks) {
    const row = document.createElement("div");
    row.className = "disk-row";

    const name = document.createElement("span");
    name.className = "disk-row__name";
    name.textContent = disk.mount;

    const bar = document.createElement("span");
    bar.className = "disk-row__bar";
    const fill = document.createElement("i");
    fill.className = disk.used_percent > 90 ? "is-hot" : "is-cool";
    fill.style.width = `${disk.used_percent.toFixed(0)}%`;
    bar.append(fill);

    const free = document.createElement("span");
    free.className = "disk-row__free";
    free.textContent =
      `${disk.free_gb.toFixed(1)} GB ${t("free of")} ${disk.total_gb.toFixed(1)} GB`;

    row.append(name, bar, free);
    disks.append(row);
  }

  const procs = $("#proc-list");
  procs.replaceChildren();
  for (const proc of info.processes) {
    const row = document.createElement("div");
    row.className = "proc-row";

    const name = document.createElement("span");
    name.className = "proc-row__name";
    name.textContent = proc.name;
    name.title = `pid ${proc.pid}`;

    const cpuCell = document.createElement("span");
    cpuCell.className = "proc-row__cpu";
    cpuCell.textContent = `${proc.cpu_percent.toFixed(0)}%`;

    const memCell = document.createElement("span");
    memCell.className = "proc-row__mem";
    memCell.textContent = proc.mem_mb >= 1024
      ? `${(proc.mem_mb / 1024).toFixed(1)} GB`
      : `${Math.round(proc.mem_mb)} MB`;

    row.append(name, cpuCell, memCell);
    procs.append(row);
  }
}

const loadHeat = (p) => (p >= 85 ? "is-hot" : p >= 50 ? "is-warm" : "is-cool");

/* ── graphics switcher ───────────────────────────────────────────
 *
 * This board does have a mux, which took some finding: in hybrid mode the
 * panel is wired to the integrated GPU and the NVIDIA card enumerates only
 * HDMI, which looks exactly like a machine with no mux. The firmware knows -
 * its system design data declares UMA, hybrid and discrete - and the kernel
 * module asks it.
 *
 * Switching is a firmware setting that takes effect during the next POST, so
 * the card says so rather than pretending something changed.
 */

const MUX_INFO = {
  hybrid: {
    title: "Hybrid",
    blurb: "The screen runs off the integrated GPU and the discrete one sleeps until something asks for it. Longer battery, quieter.",
    icon: "M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2Zm0 4a6 6 0 0 1 0 12Z",
  },
  discrete: {
    title: "Discrete",
    blurb: "The screen is driven by the NVIDIA GPU directly. Faster in games, and it never sleeps.",
    icon: "M4 6h16v12H4Zm3 3h10v6H7Z",
  },
  uma: {
    title: "Integrated only",
    blurb: "The discrete GPU is switched off entirely. The longest battery life, and no NVIDIA acceleration at all.",
    icon: "M6 6h12v12H6Zm3 3h6v6H9Z",
  },
};

function renderMux(s) {
  const card = $("#mux-card");
  if (!card) return;
  const mux = s.daemon?.mux ?? null;
  card.hidden = !mux;
  if (!mux) return;

  const box = $("#mux-cards");
  const key = mux.supported.join(",");
  if (box.dataset.built !== key) {
    box.dataset.built = key;
    box.replaceChildren();
    for (const mode of mux.supported) {
      const info = MUX_INFO[mode] ?? { title: mode, blurb: "", icon: "" };
      const el = document.createElement("button");
      el.className = "power-card";
      el.dataset.mux = mode;
      el.innerHTML =
        `<svg class="power-card__icon" viewBox="0 0 24 24"><path d="${info.icon}"/></svg>` +
        `<h3>${t(info.title)}</h3><p>${t(info.blurb)}</p>`;
      el.addEventListener("click", () => act(() => invoke("set_gpu_mux", { mode })));
      box.append(el);
    }
  }

  $$("#mux-cards .power-card").forEach((c) =>
    c.classList.toggle("is-active", c.dataset.mux === mux.current));
  // "now" would be wrong once a switch is waiting for the reboot: the
  // firmware reports the mode it will boot into, not the one in force.
  $("#mux-note").textContent = !mux.current
    ? ""
    : mux.pending_reboot
      ? `${t("after the next restart")}: ${mux.current}`
      : `${t("now")}: ${mux.current}`;
}

/* The three numbers the Hub puts under the mode cards, and the fan switch
 * next to them. */
function renderPerfStrip(s) {
  const d = s.daemon;
  const cpu = namedTemp(d, "cpu") ?? d?.driver_temp_c ?? null;
  const gpu = namedTemp(d, "dgpu") ?? namedTemp(d, "igpu");

  const put = (id, value, suffix, cls) => {
    const el = $(id);
    if (!el) return;
    el.textContent = value == null ? "—" : `${Math.round(value)}${suffix}`;
    el.className = value == null ? "" : cls ?? "";
  };
  put("#perf-cpu-temp", cpu, "°C", cpu != null ? heat(cpu) : "");
  put("#perf-gpu-temp", gpu, "°C", gpu != null ? heat(gpu) : "");

  const mode = d?.mode?.mode ?? "curve";
  $$("#perf-fan button").forEach((b) =>
    b.classList.toggle("is-active", b.dataset.mode === mode));
}

function bindPerfStrip() {
  $$("#perf-fan button").forEach((b) =>
    b.addEventListener("click", () =>
      act(() => invoke("set_mode", { mode: { mode: b.dataset.mode } }))));
}

/* ── the Hub's lighting basics ───────────────────────────────────
 *
 * A hue strip and a Static/Off switch, which is what the Hub's basic view
 * offers. Hue rather than a colour picker because that is the control people
 * reach for; the swatches and the per-zone pickers are still below.
 */

function hueToRgb(hue) {
  const h = ((hue % 360) + 360) % 360 / 60;
  const sector = Math.floor(h);
  const f = h - sector;
  const up = Math.round(f * 255);
  const down = 255 - up;
  switch (sector) {
    case 0: return { r: 255, g: up, b: 0 };
    case 1: return { r: down, g: 255, b: 0 };
    case 2: return { r: 0, g: 255, b: up };
    case 3: return { r: 0, g: down, b: 255 };
    case 4: return { r: up, g: 0, b: 255 };
    default: return { r: 255, g: 0, b: down };
  }
}

function bindLightBasics() {
  // While dragging, only the preview moves; the keyboard is written when the
  // slider is released. Every intermediate value would be four WMI calls.
  $("#hue-range").addEventListener("input", (e) => {
    const c = hueToRgb(Number(e.target.value));
    for (let i = 0; i < ZONES.length; i++) {
      const zone = $(`#z${i}`);
      if (zone) zone.style.fill = hex(c);
    }
    holdUntil = Date.now() + 1200;
  });
  $("#hue-range").addEventListener("change", (e) =>
    act(() => invoke("set_all_zones", hueToRgb(Number(e.target.value))), null));

  $$("#light-mode button").forEach((b) =>
    b.addEventListener("click", () => {
      const on = b.dataset.light === "static";
      act(async () => {
        // "Off" is the backlight switch, not black zones: writing black
        // would lose the colours and still leave the keyboard technically on.
        if (!on) return invoke("set_brightness", { value: 0 });
        await invoke("set_effect", {
          effect: "none",
          speed: 5,
          color: state?.leds?.zones?.[1] ?? { r: 232, g: 17, b: 35 },
        });
        return invoke("set_brightness", { value: 100 });
      }, null);
    }));
}

/* ── battery ─────────────────────────────────────────────────────
 *
 * Offered only where the kernel actually exposes the threshold. On a machine
 * without it the card says where the setting really lives rather than showing
 * a control that writes nowhere - which is the failure this project keeps
 * finding in other tools.
 */

function renderBattery(s) {
  const card = $("#battery-card");
  if (!card) return;
  const d = s.daemon;
  const supported = !!d?.charge_limit_supported;

  $("#battery-control").hidden = !supported;
  $("#battery-unsupported").hidden = supported;
  if (!supported) {
    let text = t(
      "This kernel exposes no charge threshold for this battery. On HP laptops the setting usually lives in BIOS setup instead — Battery Health Manager, F10 at boot.");
    // The question anyone who knows their BIOS has the setting will ask
    // next: HP's own BIOS-settings driver is right there, so why not through
    // that? Because this firmware does not publish it there either.
    if (s.bioscfg_present) {
      text += " " + t(
        "hp-bioscfg is loaded, but this firmware does not publish the setting through it either, so there is nothing for the system to write.");
    }
    $("#battery-unsupported").textContent = text;
  }

  const pct = d?.battery_percent;
  $("#battery-note").textContent =
    pct == null ? "" : `${pct}%${d?.on_ac ? ` · ${t("on mains")}` : ""}`;

  const sel = $("#set-charge-limit");
  // Not while it has focus: overwriting a choice mid-selection is the kind of
  // thing a two-second poll does and a person cannot fight.
  if (supported && document.activeElement !== sel) {
    const limit = d?.charge_limit ?? 100;
    sel.value = limit >= 100 ? "" : String(limit);
  }
}

function bindBattery() {
  const sel = $("#set-charge-limit");
  if (!sel) return;
  sel.addEventListener("change", () =>
    act(() => invoke("set_charge_limit", {
      percent: sel.value ? Number(sel.value) : null,
    })));
}

/* ── what this machine can do ────────────────────────────────────
 *
 * Only shown when it is not everything. On the verified board this banner
 * never appears; on an OMEN whose board is missing from hp-wmi's DMI table it
 * is the difference between "this app is broken" and "this machine cannot do
 * that part, and here is why".
 */

function renderCaps(s) {
  const banner = $("#caps-banner");
  if (!banner) return;
  const caps = s.daemon?.caps;
  const level = capsLevel(caps);
  if (!caps || level === "full") {
    banner.hidden = true;
    return;
  }
  banner.hidden = false;
  const missing = [
    !caps.fan_setpoint && t("fan control"),
    !caps.profile && t("performance profiles"),
    !caps.leds && t("keyboard lighting"),
  ].filter(Boolean);
  banner.textContent =
    `${t("Running with what this machine has:")} ${missing.join(", ")} ${t("not available here.")} ` +
    t("omenctl caps says why.");
}

/** The level, worked out here rather than sent, so an older daemon still gets
 * a sensible answer from the fields it does send. */
function capsLevel(caps) {
  if (!caps) return "full";
  if (caps.fan_setpoint) return "full";
  if (caps.profile) return "profile-only";
  return caps.temps ? "telemetry-only" : "unsupported";
}

function renderLightMode(s) {
  const off = !!s.leds?.backlight_off || (s.leds?.brightness ?? 0) === 0;
  $$("#light-mode button").forEach((b) =>
    b.classList.toggle("is-active", (b.dataset.light === "off") === off));
}

async function refresh() {
  try {
    state = await invoke("get_state");
  } catch (e) {
    toast(`could not read the state: ${e}`, true);
    return;
  }
  renderDaemon(state);
  renderNow(state);
  renderProfiles(state);
  renderApps(state);
  renderTriggers(state);
  renderBattery(state);
  renderCaps(state);
  renderGraphics(state);
  renderBoost(state);
  renderPowerRules(state);
  renderExtras(state);
  renderSystem();
  renderMux(state);
  renderPerfStrip(state);
  if ($('.view[data-view="fan"]')?.classList.contains("is-active")) refreshHistory();
  renderStartupProfile(state);
  renderTrayDependent(state);
  maybeAlert(state);
  maybeNotify(state);
  renderLeds(state);
  renderEffect(state);
  renderLightMode(state);

  const d = state.daemon;
  pushHistory(d?.driver_temp_c, d?.fan1_rpm);
  // While the editor is open the chart belongs to the draft. Redrawing the
  // saved curve here would undo a drag every two seconds.
  if (!curveEditing()) {
    drawCurve(state.curve, state.interpolation, d?.driver_temp_c, d?.target_rpm);
  }
  const forced = state.daemon?.curve_preset;
  $("#curve-forced").hidden = !forced;
  if (forced) {
    $("#curve-forced").textContent =
      `${t("A rule is running the")} ${t(forced)} ${t("curve; this is the configured one.")}`;
  }
  $("#curve-note").textContent = t(
    state.interpolation === "linear"
      ? "linear between points"
      : "held between points, as OMEN Gaming Hub does");
}

buildKeycaps();
buildZonePickers();
bindCurveEditor();
bindApps();
bindTriggers();
bindBattery();
bindGraphics();
bindSettings();
bindFirmware();
bindDiagnosis();
bindPowerRules();
bindHistory();
bindExtras();
bindPerfStrip();
bindLightBasics();
loadSettings();
renderVersions();
refresh();
seedHistory();
/* How often a hidden window still looks, when alerts are on.
 *
 * Closed to the tray used to mean polling stopped altogether, which also
 * meant the "warn me when the fans are forced to full" setting did nothing in
 * exactly the case it was for: the window in the tray, the machine
 * overheating, nobody looking. A slow heartbeat costs one socket round trip
 * every fifteen seconds and keeps that promise. */
const WATCH_MS = 15000;

function startPolling() {
  clearInterval(pollTimer);
  const interval = visible ? POLL_MS : settings?.alerts ? WATCH_MS : 0;
  if (!interval) return;
  pollTimer = setInterval(() => { if (Date.now() > holdUntil) refresh(); }, interval);
}
startPolling();

/* Closing to the tray leaves this page running. Polling the daemon every two
 * seconds for a window nobody can see is work that only costs battery, so the
 * Rust side says when the window is hidden and shown - WebKit does not fire
 * visibilitychange reliably for an unmapped window, though it is listened for
 * as well for the cases where it does. */
function setVisible(next) {
  if (next === visible) return;
  visible = next;
  if (visible) {
    refresh();
  }
  // Hidden is not "stopped" any more - see WATCH_MS. startPolling decides
  // whether there is anything to watch for.
  startPolling();
}

/* `omen-ui --tab graphics`, from a launcher or a shortcut. */
window.__TAURI__?.event?.listen?.("omen://open-tab", (e) => {
  const wanted = String(e.payload ?? "");
  if ($(`.device-link[data-view="${wanted}"]`)) selectView(wanted);
});

document.addEventListener("visibilitychange", () => setVisible(!document.hidden));
window.__TAURI__?.event?.listen?.("omen://visible", (e) => setVisible(!!e.payload));
