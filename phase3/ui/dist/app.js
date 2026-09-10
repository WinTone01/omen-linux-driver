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
    "are left alone, which keeps the machine silent at idle.",
  manual:
    "A fixed target. The critical cutout still applies - a request here does not " +
    "disable thermal protection.",
  max: "Fans at full power (WMI 0x27).",
  auto:
    "Advanced: hands the fans to the EC and stops managing them. On this machine " +
    "the EC does not take them - measured, the fans sat at 0 RPM while the CPU " +
    "climbed 78 to 85 C in twelve seconds under load. omend forces full power if " +
    "that happens and puts you back on Automatic. Useful for comparing against " +
    "stock behaviour, not for daily use.",
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
    d.target_rpm != null ? `${d.target_rpm} RPM`
    : d.mode?.mode === "max" ? "full power"
    : "automatic (EC)";
  $("#v-driver").textContent =
    d.driver_label && cpu != null ? `${d.driver_label} ${cpu.toFixed(1)} °C` : "—";
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

function fmtUptime(secs) {
  if (secs == null) return "—";
  const h = Math.floor(secs / 3600);
  const m = Math.floor((secs % 3600) / 60);
  return h > 0 ? `${h} h ${m} min` : `${m} min ${secs % 60} s`;
}

const PROFILE_INFO = {
  "low-power": {
    blurb: "Lowest power draw and the quietest fans. Best on battery.",
    icon: "M12 3v9m0 9a8 8 0 0 1-5.7-13.7M12 21a8 8 0 0 0 5.7-13.7",
  },
  balanced: {
    blurb: "The default. HPCM = 48 on the firmware side.",
    icon: "M3 12h4l3-7 4 14 3-7h4",
  },
  performance: {
    blurb: "Raises the power limit and the fan ceiling. HPCM = 49.",
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
      "<strong>The keyboard backlight is off.</strong> Colours will be written " +
      "but nothing will light up. The master switch is internal EC state — " +
      "press <kbd>Fn</kbd>+<kbd>F4</kbd>.";
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

  const d = state.daemon;
  pushHistory(d?.driver_temp_c, d?.fan1_rpm);
  drawCurve(state.curve, state.interpolation, d?.driver_temp_c, d?.target_rpm);
  $("#curve-note").textContent =
    state.interpolation === "linear"
      ? "linear between points"
      : "held between points, as OMEN Gaming Hub does";
}

buildKeycaps();
buildZonePickers();
refresh();
setInterval(() => { if (Date.now() > holdUntil) refresh(); }, POLL_MS);
