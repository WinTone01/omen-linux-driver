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

const POLL_MS = 2000;
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
function selectView(id) {
  $$("[data-view]").forEach((el) => {
    const match = el.dataset.view === id;
    if (el.classList.contains("view")) el.classList.toggle("is-active", match);
    else el.classList.toggle("is-active", match);
  });
  $(".main-scroll").scrollTop = 0;
}

$$(".device-link, .main-tab").forEach((el) =>
  el.addEventListener("click", () => selectView(el.dataset.view)),
);

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
 * Validation here mirrors the daemon's rules rather than replacing them. The
 * daemon still checks - it is the only thing that can, since it knows the
 * critical cutout - but a dragged point that would be rejected should be
 * impossible to express, not rejected after the fact.
 */

const CURVE_EDIT_MAX_C = 95;   // stay below the critical cutout (97 C)
const CURVE_TEMP_STEP = 1;
const CURVE_RPM_STEP = 100;    // the EC's own resolution
const CURVE_MIN_RPM = 1800;    // below this the fan does not turn

let draft = null;
let resetArmed = false;
let resetTimer = null;
/* Index of the point under the pointer, so its label is always shown. */
let dragging = null;

const clamp = (v, lo, hi) => Math.max(lo, Math.min(hi, v));

function curveEditing() {
  return draft !== null;
}

function startEdit() {
  draft = structuredClone(state?.curve ?? []).map((p) => ({ ...p }));
  if (draft.length < 2) {
    toast("no curve to edit", true);
    draft = null;
    return;
  }
  renderEditor();
}

function endEdit() {
  draft = null;
  renderEditor();
  refresh();
}

function renderEditor() {
  const editing = curveEditing();
  $("#btn-curve-edit").hidden = editing;
  for (const id of ["#btn-curve-cancel", "#btn-curve-save"]) {
    $(id).hidden = !editing;
  }
  // Going back to the built-in table is worth offering without having to
  // enter the editor first - it is the way out of a curve you regret.
  $("#btn-curve-reset").textContent = resetArmed ? "Sure?" : "Defaults";
  $("#btn-curve-reset").classList.toggle("is-armed", resetArmed);
  $("#curve-edit-hint").hidden = !editing;
  $("#curve-chart").classList.toggle("is-editing", editing);
  $("#curve-line").classList.toggle("is-draft", editing);
  if (editing) drawCurve(draft, state?.interpolation, null, null);
  drawHandles();
}

/* An RPM of 0 is not a speed, it is "fans off" - the daemon holds the
 * setpoint at zero rather than handing the fans to the EC - and it is only
 * allowed at the bottom of the curve. So the lowest point may be dragged down
 * into it, and no other point may. */
function snapRpm(raw, index) {
  const rounded = Math.round(raw / CURVE_RPM_STEP) * CURVE_RPM_STEP;
  if (index === 0 && rounded < CURVE_MIN_RPM / 2) return 0;
  return clamp(rounded, index === 0 && rounded < CURVE_MIN_RPM ? 0 : CURVE_MIN_RPM, FAN_MAX);
}

/* The fan may not slow down as the machine gets hotter, so a point is bounded
 * by its neighbours rather than free. Same for temperature: points keep their
 * order, which is what makes the drag feel like editing a table. */
function moveDraftPoint(i, temp, rpm) {
  const prev = draft[i - 1], next = draft[i + 1];
  const p = draft[i];

  p.temp_c = Math.round(
    clamp(temp,
      prev ? prev.temp_c + CURVE_TEMP_STEP : CURVE_MIN_C,
      next ? next.temp_c - CURVE_TEMP_STEP : CURVE_EDIT_MAX_C)
    / CURVE_TEMP_STEP) * CURVE_TEMP_STEP;

  let r = snapRpm(rpm, i);
  // A neighbour sitting in the idle region (0) is not a floor - it is off,
  // and anything above it is a real speed.
  if (prev && prev.rpm > 0) r = Math.max(r, prev.rpm);
  if (next && next.rpm > 0) r = Math.min(r, next.rpm);
  p.rpm = r;
}

function drawHandles() {
  const g = $("#curve-handles");
  g.replaceChildren();
  if (!curveEditing()) return;

  const W = 600, H = 190;
  const x = (c) => ((c - CURVE_MIN_C) / (CURVE_MAX_C - CURVE_MIN_C)) * W;
  const y = (rpm) => H - (rpm / FAN_MAX) * (H - 10) - 5;

  // The default table has ten points at 5 C spacing; labelling every one of
  // them produces a line of overlapping text that reads as noise. Label a
  // point only when there is room, and always label the one being dragged.
  let lastLabelX = -Infinity;

  draft.forEach((p, i) => {
    const cx = x(p.temp_c), cy = y(p.rpm);
    const hit = el("circle", { cx, cy, r: 12, class: "handle-hit" });
    hit.dataset.index = i;
    g.append(hit, el("circle", { cx, cy, r: 4, class: "handle-dot" }));

    if (i !== dragging && cx - lastLabelX < 58) return;
    lastLabelX = cx;
    const label = el("text", {
      x: clamp(cx, 16, W - 16), y: clamp(cy - 12, 10, H - 4), "text-anchor": "middle",
    });
    label.textContent = p.rpm === 0 ? `${p.temp_c}° off` : `${p.temp_c}° ${p.rpm}`;
    g.append(label);
  });
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
    temp_c: CURVE_MIN_C + (p.x / 600) * (CURVE_MAX_C - CURVE_MIN_C),
    rpm: ((190 - 5 - p.y) / (190 - 10)) * FAN_MAX,
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
    act(() => invoke("reset_curve"), "back to the built-in curve").then(renderEditor);
  });

  handles.addEventListener("pointerdown", (ev) => {
    const hit = ev.target.closest("circle.handle-hit");
    if (!hit || ev.button !== 0) return;
    ev.preventDefault();
    ev.stopPropagation();
    const i = Number(hit.dataset.index);
    hit.setPointerCapture(ev.pointerId);
    handles.classList.add("is-dragging");
    dragging = i;
    drawHandles();

    const move = (e) => {
      const at = chartPoint(e);
      moveDraftPoint(i, at.temp_c, at.rpm);
      drawCurve(draft, state?.interpolation, null, null);
      drawHandles();
    };
    const up = () => {
      dragging = null;
      drawHandles();
      handles.classList.remove("is-dragging");
      handles.removeEventListener("pointermove", move);
      handles.removeEventListener("pointerup", up);
      handles.removeEventListener("pointercancel", up);
    };
    handles.addEventListener("pointermove", move);
    handles.addEventListener("pointerup", up);
    handles.addEventListener("pointercancel", up);
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
    drawHandles();
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
    draft.push({ temp_c: temp, rpm: below ? below.rpm : draft[0].rpm });
    draft.sort((a, b) => a.temp_c - b.temp_c);
    drawCurve(draft, state?.interpolation, null, null);
    drawHandles();
  });
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
refresh();
setInterval(() => { if (Date.now() > holdUntil) refresh(); }, POLL_MS);
