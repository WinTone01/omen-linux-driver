/*
 * OMEN Control - front end.
 *
 * No build step and no framework on purpose: the whole thing is a handful of
 * elements refreshed on a timer, and a bundler would be more moving parts
 * than the page itself. The backend hands us the entire state in one call
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
    driver_temp_c: 61.4,
    target_rpm: 1900,
    fan1_rpm: 1902,
    fan2_rpm: 1804,
    pwm: 101,
    safety_fallback: false,
    uptime_secs: 4230,
    temps: [["cpu/Tctl", 61.4], ["igpu/edge", 48.0], ["board/temp1", 45.0]],
  },
  daemon_error: null,
  leds: {
    brightness: 100,
    backlight_off: false,
    zones: [
      { r: 228, g: 0, b: 43 },
      { r: 228, g: 0, b: 43 },
      { r: 228, g: 0, b: 43 },
      { r: 228, g: 0, b: 43 },
    ],
  },
  leds_error: null,
  leds_writable: true,
  profile_choices: ["low-power", "balanced", "performance"],
};

async function mockInvoke(cmd, args) {
  switch (cmd) {
    case "get_state":
      return structuredClone(mockState);
    case "set_mode":
      mockState.daemon.mode = args.mode;
      mockState.daemon.target_rpm =
        args.mode.mode === "manual" ? args.mode.rpm : args.mode.mode === "curve" ? 1900 : null;
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

const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => Array.from(document.querySelectorAll(sel));

const POLL_MS = 2000;
const ZONES = ["left", "wasd", "centre", "numpad"];

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
  toastTimer = setTimeout(() => { el.hidden = true; }, isError ? 6000 : 2600);
}

const hex = ({ r, g, b }) =>
  "#" + [r, g, b].map((v) => v.toString(16).padStart(2, "0")).join("");

function rgb(hexStr) {
  const n = parseInt(hexStr.slice(1), 16);
  return { r: (n >> 16) & 255, g: (n >> 8) & 255, b: n & 255 };
}

/** Maps a value onto 0-100% for the little bars. */
const pct = (v, min, max) =>
  Math.max(0, Math.min(100, ((v - min) / (max - min)) * 100));

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

/* ── window controls ─────────────────────────────────────────── */

$$(".win-btn").forEach((btn) =>
  btn.addEventListener("click", () => {
    const what = btn.dataset.win;
    if (what === "minimize") appWindow.minimize();
    else if (what === "maximize") appWindow.toggleMaximize();
    else appWindow.close();
  }),
);

/* ── navigation ──────────────────────────────────────────────── */

$$(".nav-item").forEach((item) =>
  item.addEventListener("click", () => {
    $$(".nav-item").forEach((n) => n.classList.remove("is-active"));
    item.classList.add("is-active");
    $$(".view").forEach((v) =>
      v.classList.toggle("is-active", v.dataset.view === item.dataset.view),
    );
  }),
);

/* ── fan ─────────────────────────────────────────────────────── */

const MODE_HELP = {
  curve: "The curve in /etc/omen/omend.toml drives the fan. Below its lowest point control is handed back to the EC, which keeps the fans stopped at idle.",
  auto: "Control belongs to the EC entirely. This is what the machine does out of the box.",
  manual: "A fixed target. The critical cutout still applies — a request here does not disable thermal protection.",
  max: "Fans at full power (WMI 0x27). The EC takes over the curve while this is on.",
};

$$("#fan-modes button").forEach((btn) =>
  btn.addEventListener("click", () => {
    const mode = btn.dataset.mode;
    const payload =
      mode === "manual"
        ? { mode: "manual", rpm: Number($("#rpm-range").value) }
        : { mode };
    act(() => invoke("set_mode", { mode: payload }));
  }),
);

$("#rpm-range").addEventListener("input", (e) => {
  $("#rpm-out").textContent = `${e.target.value} RPM`;
});

$("#rpm-range").addEventListener("change", (e) => {
  // Only send it if manual is the active mode; otherwise moving the slider
  // would silently take the fan away from the curve.
  if (state?.daemon?.mode?.mode !== "manual") return;
  act(() =>
    invoke("set_mode", { mode: { mode: "manual", rpm: Number(e.target.value) } }),
  );
});

$("#btn-reload").addEventListener("click", () =>
  act(() => invoke("reload_config")),
);

/* ── lighting ────────────────────────────────────────────────── */

function buildZonePickers() {
  const row = $("#zone-row");
  row.innerHTML = "";
  ZONES.forEach((name, i) => {
    const wrap = document.createElement("div");
    wrap.className = "zone-pick";
    const input = document.createElement("input");
    input.type = "color";
    input.id = `zone-${i}`;
    input.addEventListener("change", () => {
      const c = rgb(input.value);
      act(() => invoke("set_zone", { index: i, ...c }), null);
    });
    const label = document.createElement("label");
    label.textContent = name;
    label.htmlFor = input.id;
    wrap.append(input, label);
    row.append(wrap);
  });
}

$("#all-color").addEventListener("change", (e) =>
  act(() => invoke("set_all_zones", rgb(e.target.value)), null),
);

$$("[data-preset]").forEach((btn) =>
  btn.addEventListener("click", () => {
    $("#all-color").value = btn.dataset.preset;
    act(() => invoke("set_all_zones", rgb(btn.dataset.preset)), null);
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

  if (!s.daemon) {
    dot.className = "status-dot is-down";
    text.textContent = "omend unreachable";
    $("#d-notice").hidden = false;
    $("#d-notice").innerHTML =
      `<strong>The omend service is not reachable.</strong> ` +
      `Fan readings and control are unavailable; lighting still works. ` +
      `<br>${s.daemon_error ?? ""}`;
    return;
  }

  dot.className = "status-dot is-up";
  text.textContent = "omend connected";
  $("#d-notice").hidden = true;

  const d = s.daemon;
  const cpu = d.driver_temp_c;

  $("#d-cpu").textContent = cpu != null ? cpu.toFixed(1) : "—";
  $("#d-cpu-bar").style.width = cpu != null ? `${pct(cpu, 30, 100)}%` : "0";
  $("#d-cpu-bar").classList.toggle("is-hot", (cpu ?? 0) >= 80);

  for (const [id, value] of [["fan1", d.fan1_rpm], ["fan2", d.fan2_rpm]]) {
    const v = value ?? 0;
    $(`#d-${id}`).textContent = v === 0 ? "0" : v;
    $(`#d-${id}-bar`).style.width = `${pct(v, 0, 4800)}%`;
    $(`#f-${id}`).textContent = v === 0 ? "0" : v;
  }

  $("#d-profile").textContent = d.profile ?? "—";
  $("#d-mode").textContent = d.mode ? modeText(d.mode) : "—";
  $("#d-target").textContent =
    d.target_rpm != null
      ? `${d.target_rpm} RPM`
      : d.mode?.mode === "max"
        ? "full power"
        : "automatic (EC)";
  $("#d-driver").textContent =
    d.driver_label && d.driver_temp_c != null
      ? `${d.driver_label} ${d.driver_temp_c.toFixed(1)} °C`
      : "—";
  $("#d-uptime").textContent = fmtUptime(d.uptime_secs);

  if (d.safety_fallback) {
    $("#d-notice").hidden = false;
    $("#d-notice").innerHTML =
      "<strong>The critical cutout has tripped.</strong> The curve is " +
      "suspended and the EC has control until the temperature falls back.";
  }

  $("#d-temps").innerHTML = (d.temps ?? [])
    .map(
      ([label, c]) =>
        `<div class="temp-row"><span>${label}</span>` +
        `<span class="bar"><i style="width:${pct(c, 30, 100)}%"></i></span>` +
        `<span>${c.toFixed(1)} °C</span></div>`,
    )
    .join("");

  const active = d.mode?.mode ?? "curve";
  $$("#fan-modes button").forEach((b) =>
    b.classList.toggle("is-active", b.dataset.mode === active),
  );
  $("#fan-mode-help").textContent = MODE_HELP[active] ?? "";
  $("#manual-card").style.opacity = active === "manual" ? "1" : ".5";

  if (active === "manual" && d.mode.rpm != null && Date.now() > holdUntil) {
    $("#rpm-range").value = d.mode.rpm;
    $("#rpm-out").textContent = `${d.mode.rpm} RPM`;
  }
}

const modeText = (m) => (m.mode === "manual" ? `manual (${m.rpm} RPM)` : m.mode);

function fmtUptime(secs) {
  if (secs == null) return "—";
  const h = Math.floor(secs / 3600);
  const m = Math.floor((secs % 3600) / 60);
  return h > 0 ? `${h} h ${m} min` : `${m} min ${secs % 60} s`;
}

function renderProfiles(s) {
  const box = $("#profile-cards");
  const current = s.daemon?.profile;
  const blurb = {
    "low-power": "Lowest power draw, quietest. Best on battery.",
    balanced: "The default. HPCM = 48 on the firmware side.",
    performance: "Raises the power limit. HPCM = 49.",
  };

  if (box.dataset.built !== String(s.profile_choices.length)) {
    box.innerHTML = "";
    s.profile_choices.forEach((name) => {
      const card = document.createElement("button");
      card.className = "profile-card";
      card.dataset.profile = name;
      card.innerHTML = `<h3>${name.replace("-", " ")}</h3><p>${blurb[name] ?? ""}</p>`;
      card.addEventListener("click", () =>
        act(() => invoke("set_profile", { profile: name })),
      );
      box.append(card);
    });
    box.dataset.built = String(s.profile_choices.length);
  }
  $$(".profile-card").forEach((c) =>
    c.classList.toggle("is-active", c.dataset.profile === current),
  );
}

function renderLeds(s) {
  const warn = $("#light-warn");

  if (!s.leds) {
    warn.hidden = false;
    warn.innerHTML =
      "<strong>The RGB module is not loaded.</strong> " +
      `Load it with <code>sudo modprobe -a led-class-multicolor wmi</code> ` +
      `then <code>sudo insmod omen-kbd-rgb.ko</code>.<br>${s.leds_error ?? ""}`;
    return;
  }

  if (!s.leds_writable) {
    warn.hidden = false;
    warn.innerHTML =
      "<strong>The LED files are read-only for this user.</strong> " +
      "Install the udev rule (packaging/99-omen-leds.rules) and join the " +
      "<code>omen</code> group, then log out and back in.";
  } else if (s.leds.backlight_off) {
    warn.hidden = false;
    warn.innerHTML =
      "<strong>The keyboard backlight is off.</strong> Colours will still be " +
      "written but nothing will light up. The master switch is internal EC " +
      "state — press <kbd>Fn</kbd>+<kbd>F4</kbd>.";
  } else {
    warn.hidden = true;
  }

  s.leds.zones.forEach((c, i) => {
    const colour = hex(c);
    const swatch = $(`#zone-${i}`);
    if (swatch && Date.now() > holdUntil) swatch.value = colour;
    const zone = $(`#z${i}`);
    if (zone) {
      // A zone set to black is off; show the unlit plastic rather than a
      // black rectangle that reads as "broken".
      const lit = c.r + c.g + c.b > 0 && !s.leds.backlight_off;
      zone.style.fill = lit ? colour : "#2a2a31";
      // A wide glow spills onto the neighbouring zones and shifts their hue -
      // red bleeding over cyan reads as mauve, over green as olive. Keep it
      // tight enough to stay inside its own zone.
      zone.style.filter = lit ? `drop-shadow(0 0 3px ${colour}55)` : "none";
    }
  });

  if (s.leds.brightness != null && Date.now() > holdUntil) {
    $("#bright-range").value = s.leds.brightness;
    $("#bright-out").textContent = `${s.leds.brightness}%`;
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
  renderLeds(state);
}

buildZonePickers();
refresh();
setInterval(() => {
  if (Date.now() > holdUntil) refresh();
}, POLL_MS);
