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
    apps: [{ process: "cs2", profile: "performance", fan: { mode: "manual", rpm: 3000 } }],
    active_app: null,
    on_ac: true,
    battery_percent: 82,
    power_ac: {},
    power_battery: { profile: "low-power" },
    gpu: {
      address: "0000:04:00.0", control: "auto", status: "active",
      suspended_ms: 0, holders: [{ pid: 1688, name: "quickshell" }],
    },
  },
  daemon_error: null,
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

async function mockInvoke(cmd, args) {
  switch (cmd) {
    case "get_state":
      return structuredClone(mockState);
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
    case "set_startup_profile":
      mockState.daemon.startup_profile = args.profile;
      return args.profile ? `${args.profile} will be selected at startup`
                          : "the startup profile will be left to the firmware";
    case "diagnose":
      return {
        sections: [
          { title: "Hardware", checks: [
            { id: "board", title: "Board", verdict: "ok", detail: "8D24, the one this is built for", fix: null },
          ]},
          { title: "Thermal", checks: [
            { id: "dgpu_temp", title: "Discrete GPU temperature", verdict: "warn",
              detail: "the service is not watching it - the curve only follows the CPU",
              fix: "sudo modprobe ec_sys (read-only), then: sudo systemctl restart omend" },
          ]},
        ],
      };
    case "diagnose_text":
      return "omen-control 0.1.0 - 1 thing worth knowing about\n";
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

function selectView(id) {
  $$("[data-view]").forEach((el) => {
    const match = el.dataset.view === id;
    if (el.classList.contains("view")) el.classList.toggle("is-active", match);
    else el.classList.toggle("is-active", match);
  });
  $(".main-scroll").scrollTop = 0;
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

$$(".device-link, .main-tab").forEach((el) =>
  el.addEventListener("click", () => selectView(el.dataset.view)),
);

/* Reopen where it was left. Verified against the markup rather than trusted:
 * a stored name from an older version may no longer be a tab. */
try {
  const last = localStorage.getItem(LAST_VIEW_KEY);
  if (last && $(`.main-tab[data-view="${last}"]`)) selectView(last);
} catch {
  /* first run, or storage is off */
}

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
  spectrum: "All four zones on the same hue, cycling through the spectrum.",
};

function currentEffect() {
  return state?.daemon?.effect ?? state?.effect ?? { effect: "none", speed: 5 };
}

function sendEffect(name) {
  const now = currentEffect();
  // The base colour for breathing is whatever the zones are showing - which
  // is what "the colour picked above" means to someone looking at the page.
  const base = state?.leds?.zones?.[1] ?? now.color ?? { r: 232, g: 17, b: 35 };
  act(() => invoke("set_effect", {
    effect: name,
    speed: Number($("#effect-speed").value),
    color: name === "breathing" ? base : (now.color ?? base),
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
  $("#effect-speed-row").hidden = now.effect === "none";
  $("#effect-hint").textContent = EFFECT_HINT[now.effect] ?? "";
  // An effect repaints the zones several times a second, so the colour
  // pickers below are not what the keyboard is showing. Say so.
  $("#effect-note").textContent =
    now.effect === "none" ? "" : "the zone colours below are being animated";
}

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
    text.textContent = "omend unreachable";
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
  text.textContent = "omend connected";
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

  if (cpu != null) {
    $("#cpu-temp").textContent = `${cpu.toFixed(0)}°`;
    setRing("#ring-cpu", pct(cpu, 30, 100), heat(cpu));
    $("#cpu-label").textContent = d.driver_label ?? "";
  }

  for (const [key, value] of [["fan1", d.fan1_rpm], ["fan2", d.fan2_rpm]]) {
    // Rounded on the way out: an RPM is a whole number to a reader, and a
    // stray float renders as a wall of decimals.
    const v = Math.round(value ?? 0);
    $(`#${key}-rpm`).textContent = v;
    // Coloured by how hard the fan itself is working, not by CPU temperature:
    // a fan ring turning amber because the CPU is warm says nothing about the
    // fan.
    setRing(`#ring-${key}`, pct(v, 0, 4800), fanHeat(v));
    $(`#f-${key}`).textContent = v;
  }
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
  $("#fan-mode-help").textContent = MODE_HELP[active] ?? "";
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

/* Measured on this machine, on battery, in both orders and with enough
 * settling time - a first attempt with two seconds produced "balanced is the
 * same as low-power", which is wrong. */
const PROFILE_INFO = {
  "low-power": {
    blurb:
      "Caps the CPU at 2.0 GHz. A real limit rather than a preference, for " +
      "stretching the battery.",
    icon: "M12 3v9m0 9a8 8 0 0 1-5.7-13.7M12 21a8 8 0 0 0 5.7-13.7",
  },
  balanced: {
    blurb:
      "Full 5.09 GHz boost, but reluctant about it. Firmware profile 0x30.",
    icon: "M3 12h4l3-7 4 14 3-7h4",
  },
  performance: {
    blurb:
      "Same 5.09 GHz ceiling, reached sooner and held longer. Firmware " +
      "profile 0x31.",
    icon: "M13 2 4 14h6l-1 8 9-12h-6l1-8Z",
  },
};

function renderProfiles(s) {
  const box = $("#profile-cards");
  const current = s.daemon?.profile;

  if (box.dataset.built !== String(s.profile_choices.length)) {
    box.innerHTML = "";
    s.profile_choices.forEach((name) => {
      const info = PROFILE_INFO[name] ?? { blurb: "", icon: "" };
      const card = document.createElement("button");
      card.className = "power-card";
      card.dataset.profile = name;
      card.innerHTML =
        `<svg class="power-card__icon" viewBox="0 0 24 24"><path d="${info.icon}"/></svg>` +
        `<h3>${name.replace("-", " ")}</h3><p>${info.blurb}</p>`;
      card.addEventListener("click", () => act(() => invoke("set_profile", { profile: name })));
      box.append(card);
    });
    box.dataset.built = String(s.profile_choices.length);
  }
  $$(".power-card").forEach((c) =>
    c.classList.toggle("is-active", c.dataset.profile === current),
  );
}

function renderLeds(s) {
  const banner = $("#light-banner");

  if (!s.leds) {
    banner.hidden = false;
    banner.innerHTML =
      "<strong>The RGB module is not loaded.</strong> " +
      "Build it in <code>phase3/kernel/omen-kbd-rgb</code>, then " +
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
const HISTORY_MAX = 60; // 60 samples x 2 s = two minutes
const history = { temp: [], fan: [] };

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
  const step = w / (HISTORY_MAX - 1);
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

function pushHistory(temp, fan) {
  history.temp.push(temp ?? 0);
  history.fan.push(fan ?? 0);
  if (history.temp.length > HISTORY_MAX) {
    history.temp.shift();
    history.fan.shift();
  }
  drawGrid("#chart-grid", 4, 600, 150);
  $("#line-temp").setAttribute("d", seriesPath(history.temp, TEMP_MIN, TEMP_MAX));
  $("#line-fan").setAttribute("d", seriesPath(history.fan, 0, FAN_MAX));
  const secs = (history.temp.length - 1) * (POLL_MS / 1000);
  $("#chart-window").textContent =
    secs >= 60 ? `last ${Math.round(secs / 60)} min` : `last ${secs} s`;
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
    toast("no curve to edit", true);
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
  $("#btn-curve-reset").textContent = resetArmed ? "Sure?" : "Defaults";
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
      toast("a curve needs at least two points", true);
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
  if (app.fan) parts.push(fanLabel(app.fan));
  return parts.join(" · ") || "nothing to apply";
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
      badge.textContent = "running";
      row.append(badge);
    }
    row.append(what, drop);
    list.append(row);
  }

  $("#apps-note").textContent = active ? `${active} is running` : "";

  // The profile choices come from the machine, so this cannot offer one the
  // firmware does not have.
  const sel = $("#app-profile");
  if (sel.dataset.built !== String(s.profile_choices?.length ?? 0)) {
    sel.dataset.built = String(s.profile_choices?.length ?? 0);
    sel.replaceChildren();
    const none = document.createElement("option");
    none.value = "";
    none.textContent = "profile: leave alone";
    sel.append(none);
    for (const name of s.profile_choices ?? []) {
      const opt = document.createElement("option");
      opt.value = name;
      opt.textContent = `profile: ${name}`;
      sel.append(opt);
    }
  }
}

function bindApps() {
  const add = () => {
    const process = $("#app-process").value.trim();
    if (!process) {
      toast("a process name is required", true);
      return;
    }
    const profile = $("#app-profile").value || null;
    const fanRaw = $("#app-fan").value;
    if (!profile && !fanRaw) {
      toast("pick a profile, a fan mode, or both - otherwise there is nothing to apply", true);
      return;
    }
    const fan =
      !fanRaw ? null
      : /^\d+$/.test(fanRaw) ? { mode: "manual", rpm: Number(fanRaw) }
      : { mode: fanRaw };

    const apps = (state?.daemon?.apps ?? []).filter(
      (a) => a.process.toLowerCase() !== process.toLowerCase());
    apps.push({ process, profile, fan });
    $("#app-process").value = "";
    saveApps(apps, `${process} added`);
  };

  $("#btn-app-add").addEventListener("click", add);
  $("#app-process").addEventListener("keydown", (e) => {
    if (e.key === "Enter") add();
  });
}

/* ── graphics ────────────────────────────────────────────────────
 *
 * There is nothing to switch on this board - no mux, the panel is wired to
 * the integrated GPU - so this panel does the two things that are real:
 * report what the discrete GPU is doing and who is stopping it sleeping, and
 * let its runtime power policy be set.
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

  $("#gfx-state").textContent =
    gpu.status === "suspended" ? "suspended (asleep)" : gpu.status;
  $("#gfx-state").className = "is-term";

  $("#gfx-suspended").textContent =
    gpu.suspended_ms > 0
      ? `${(gpu.suspended_ms / 60000).toFixed(0)} min`
      : gpu.control === "on" ? "never — you asked for that" : "never";

  const holders = gpu.holders ?? [];
  $("#gfx-holders").textContent = holders.length
    ? holders.map((h) => `${h.name} (${h.pid})`).join(", ")
    : gpu.status === "suspended" ? "nothing — it is asleep" : "nothing";

  $("#gfx-note").textContent =
    gpu.control === "auto" && gpu.suspended_ms === 0 && gpu.status !== "suspended"
      ? "allowed to sleep, but it never has"
      : "";
}

function bindGraphics() {
  $$("#gfx-power button").forEach((b) =>
    b.addEventListener("click", () =>
      act(() => invoke("set_dgpu_power", { power: b.dataset.power }))));

  $("#btn-gfx-copy").addEventListener("click", async () => {
    const text = $("#gfx-offload").textContent.trim();
    try {
      await navigator.clipboard.writeText(text);
      toast("copied");
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
  renderSettings();
}

function renderSettings() {
  if (!settings) return;
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
    none.textContent = "leave it as the firmware remembers";
    sel.append(none);
    for (const name of choices) {
      const opt = document.createElement("option");
      opt.value = name;
      opt.textContent = name;
      sel.append(opt);
    }
  }
  if (document.activeElement !== sel) sel.value = current;
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
    ? "something installed is newer than what is running"
    : "";
}

async function copyText(text, what) {
  try {
    await navigator.clipboard.writeText(text);
    toast(`${what} copied`);
  } catch {
    toast("could not reach the clipboard", true);
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
    if (window.Notification?.permission === "granted") {
      new Notification("OMEN Control: fans forced to full power", { body: reason });
    }
    toast(`fans forced to full power - ${reason}`, true);
  }
  lastFallback = now;
}

function bindSettings() {
  $("#set-poll").addEventListener("change", (e) =>
    saveSettings({ poll_ms: Number(e.target.value) }));
  $("#set-alerts").addEventListener("change", (e) => {
    saveSettings({ alerts: e.target.checked });
    if (e.target.checked) window.Notification?.requestPermission?.();
  });
  $("#set-autostart").addEventListener("change", (e) =>
    saveSettings({ autostart: e.target.checked }));
  $("#set-hidden").addEventListener("change", (e) =>
    saveSettings({ start_hidden: e.target.checked }));

  $("#set-startup-profile").addEventListener("change", (e) =>
    act(() => invoke("set_startup_profile", { profile: e.target.value || null })));

  $("#btn-ver-copy").addEventListener("click", () =>
    copyText($("#ver-commands").textContent, "commands"));

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
  $("#fw-note").textContent = "scanning…";
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
      flag.textContent = "needs reboot";
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
    $("#fw-note").textContent = "asking LVFS…";
    try {
      await invoke("firmware_refresh");
      toast("update metadata refreshed");
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
  $$('[data-view="settings"]').forEach((tab) =>
    tab.addEventListener("click", () => scanFirmware(false)));
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

  $("#diag-summary").textContent = "checking…";
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
    fail && warn ? `${fail} broken, ${warn} worth knowing about`
    : fail ? `${fail} thing${fail > 1 ? "s" : ""} broken`
    : warn ? `${warn} thing${warn > 1 ? "s" : ""} worth knowing about`
    : "everything checked is working";

  const counts = $("#diag-counts");
  counts.replaceChildren();
  for (const [cls, n, label] of [
    ["is-fail", fail, "broken"],
    ["is-warn", warn, "to know about"],
    ["is-ok", ok, "working"],
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

function bindDiagnosis() {
  $("#btn-diag-run").addEventListener("click", () => runDiagnosis(true));
  $("#btn-diag-copy").addEventListener("click", async () => {
    const text = await invoke("diagnose_text");
    await copyText(text, "report");
  });

  $$('[data-view="diagnosis"]').forEach((tab) =>
    tab.addEventListener("click", () => runDiagnosis(false)));
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

const FAN_CHOICES = [
  ["", "fan: leave alone"],
  ["curve", "fan: curve"],
  ["max", "fan: max"],
  ["2400", "fan: 2400 RPM"],
  ["3000", "fan: 3000 RPM"],
  ["3600", "fan: 3600 RPM"],
];

function fillChoices(sel, options, built) {
  if (sel.dataset.built === built) return;
  sel.dataset.built = built;
  sel.replaceChildren();
  for (const [value, label] of options) {
    const opt = document.createElement("option");
    opt.value = value;
    opt.textContent = label;
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
  const profileOptions = [["", "profile: leave alone"]]
    .concat(choices.map((c) => [c, `profile: ${c}`]));

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
  set($("#power-ac-fan"), fanValue(ac.fan));
  set($("#power-bat-profile"), bat.profile ?? "");
  set($("#power-bat-fan"), fanValue(bat.fan));

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
      fan: fanFromValue($(f).value),
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

async function refresh() {
  try {
    state = await invoke("get_state");
  } catch (e) {
    toast(`could not read the state: ${e}`, true);
    return;
  }
  renderDaemon(state);
  renderProfiles(state);
  renderApps(state);
  renderGraphics(state);
  renderPowerRules(state);
  renderStartupProfile(state);
  renderTrayDependent(state);
  maybeAlert(state);
  renderLeds(state);
  renderEffect(state);

  const d = state.daemon;
  pushHistory(d?.driver_temp_c, d?.fan1_rpm);
  // While the editor is open the chart belongs to the draft. Redrawing the
  // saved curve here would undo a drag every two seconds.
  if (!curveEditing()) {
    drawCurve(state.curve, state.interpolation, d?.driver_temp_c, d?.target_rpm);
  }
  $("#curve-note").textContent =
    state.interpolation === "linear"
      ? "linear between points"
      : "held between points, as OMEN Gaming Hub does";
}

buildKeycaps();
buildZonePickers();
bindCurveEditor();
bindApps();
bindGraphics();
bindSettings();
bindFirmware();
bindDiagnosis();
bindPowerRules();
loadSettings();
renderVersions();
refresh();
function startPolling() {
  clearInterval(pollTimer);
  pollTimer = setInterval(() => { if (Date.now() > holdUntil) refresh(); }, POLL_MS);
}
startPolling();
