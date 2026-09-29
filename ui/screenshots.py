#!/usr/bin/env python3
"""Renders the window's pages to docs/screenshots/*.png.

Uses WebKitGTK - the engine the window itself runs on under Tauri on Linux -
off screen, so the pictures are what the program draws and nothing on the
desktop gets in the way. Outside Tauri the page runs on its built-in sample
data (mockState in app.js), which is also what keeps process names and
paths from this machine out of a public README.

    python3 ui/screenshots.py            # every page
    python3 ui/screenshots.py vitals fan # some of them

Needs the WebKit2GTK 4.1 GObject bindings (python-gobject and webkit2gtk-4.1,
which Tauri needs anyway) and a graphical session to borrow a display from.
"""

import os
import sys
from pathlib import Path

# Off screen there is no GL context to composite into, and WebKit aborts
# trying to make one. Software rendering draws the same pixels.
os.environ.setdefault("WEBKIT_DISABLE_COMPOSITING_MODE", "1")
os.environ.setdefault("WEBKIT_DISABLE_DMABUF_RENDERER", "1")

import gi  # noqa: E402

gi.require_version("Gtk", "3.0")
gi.require_version("WebKit2", "4.1")
from gi.repository import GLib, Gtk, WebKit2  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
PAGE = ROOT / "ui" / "dist" / "index.html"
OUT = ROOT / "docs" / "screenshots"

# The window's default size (ui/src-tauri/tauri.conf.json).
WIDTH, HEIGHT = 1180, 780

# Page id -> output file. The order is the order they are taken in.
PAGES = {
    "vitals": "vitals.png",
    "performance": "performance.png",
    "fan": "fan.png",
    "automation": "automation.png",
    "graphics": "graphics.png",
    "lighting": "lighting.png",
    "diagnosis": "diagnosis.png",
    "settings": "settings.png",
}

# How long a page gets before the picture. The sample data ticks every two
# seconds; the vitals and fan pages draw history, so they get a few ticks.
SETTLE_MS = {"vitals": 9000, "fan": 5000}
DEFAULT_SETTLE_MS = 2500

# English whatever the desktop's language, and no leftover page from the
# last run: the page is chosen by the address.
PREPARE_JS = """
try { localStorage.clear(); } catch (e) {}
applyLanguage('en');
"""


class Shooter:
    def __init__(self, pages):
        self.queue = list(pages)
        self.window = Gtk.OffscreenWindow()
        self.window.set_default_size(WIDTH, HEIGHT)
        self.view = WebKit2.WebView()
        self.view.set_size_request(WIDTH, HEIGHT)
        settings = self.view.get_settings()
        settings.set_allow_file_access_from_file_urls(True)
        self.window.add(self.view)
        self.window.show_all()
        self.view.connect("load-changed", self.on_load)
        self.current = None

    def next(self):
        if not self.queue:
            Gtk.main_quit()
            return
        self.current = self.queue.pop(0)
        # A query string forces a full load: only the fragment changing would
        # be a same-document navigation, and the page would not re-read it.
        uri = PAGE.as_uri() + f"?shot={self.current}#{self.current}"
        self.view.load_uri(uri)

    def on_load(self, view, event):
        if event != WebKit2.LoadEvent.FINISHED:
            return
        view.run_javascript(PREPARE_JS, None, None, None)
        wait = SETTLE_MS.get(self.current, DEFAULT_SETTLE_MS)
        GLib.timeout_add(wait, self.snap)

    def snap(self):
        self.view.get_snapshot(
            WebKit2.SnapshotRegion.VISIBLE,
            WebKit2.SnapshotOptions.NONE,
            None,
            self.saved,
        )
        return False

    def saved(self, view, result):
        surface = view.get_snapshot_finish(result)
        target = OUT / PAGES[self.current]
        surface.write_to_png(str(target))
        print(f"  {target.relative_to(ROOT)}")
        self.next()


def main():
    wanted = sys.argv[1:] or list(PAGES)
    unknown = [p for p in wanted if p not in PAGES]
    if unknown:
        sys.exit(f"unknown page(s): {' '.join(unknown)} (one of: {' '.join(PAGES)})")
    OUT.mkdir(parents=True, exist_ok=True)
    shooter = Shooter(wanted)
    GLib.idle_add(lambda: shooter.next() and False)
    Gtk.main()


if __name__ == "__main__":
    main()
