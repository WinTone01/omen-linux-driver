# What each profile actually allows (8D24)

Measured 2026-09-28 on the OMEN 16-ap0xxx (Ryzen AI 9 365, RTX 5060 Laptop),
BIOS F.11, kernel 7.2.6, on mains. Reproduce with:

```bash
omenctl profile measure
```

## Why this needed measuring

A platform profile is a request to the firmware, and whether the firmware
acts on it is a question of fact. On 8E35 - a sibling in the same 16-ap0xxx
family - OmenCore found **0.0 W** between Quiet and Performance until it
switched to a different firmware path (their issue #195). Until today this
project had never put a number on its own profiles either. The Performance page
said what each mode does. It did not show any measurement behind that claim.

## Method

Every thread is loaded, the profile is switched, the firmware is given 15 s
to settle, and then the CPU package energy counter (RAPL, `package-0` under
`/sys/class/powercap`) is read across 10 s. The clock is the mean of
`scaling_cur_freq` over all CPUs. The GPU figure is the limit the NVIDIA
driver is *enforcing* (`nvidia-smi --query-gpu=enforced.power.limit`). It is
not the GPU's power draw: the GPU is idle during the test.

The load matters. A scalar integer loop was tried first and gave balanced
and performance the same 51.1 W at 4.0 GHz. That loop hits the clock ceiling
before it reaches the power limit, so it measures nothing about the limit. A
vectorised floating-point loop over a wide array does reach it, and gives the
figures below. A plain `while :; do :; done` in bash gave the same figures
within 0.5 W.

## Results

| Profile | CPU package | Clock | GPU limit |
|---|---|---|---|
| low-power | 31.7 W | 1992 MHz | 80 W |
| balanced | 55.0 W | 3479 MHz | 80 W |
| performance | 60.0 W | 3552 MHz | 100 W |

The GPU's maximum limit, per `nvidia-smi`, is 115 W in every profile.

## What it says

* **The profiles are real on this board.** The path is hp-wmi's thermal-profile
  write (EC `0x95`) together with amd-pmf. Balanced and performance hold the
  package at a flat 55 W and 60 W. Those are sustained limits, not averages
  of something noisier.
* **Low-power is a clock cap, not a power cap.** Every core sits at about
  2 GHz and the package draws what that costs.
* **Performance is worth +5 W to the CPU and +20 W to the GPU.** The GPU half
  is the bigger one, and it only appears in performance.
* **The last 15 W of GPU headroom (100 → 115 W) is not granted by the profile
  alone.** Dynamic Boost is the documented mechanism for it: the GPU borrows
  what the CPU is not using, through nvidia-powerd. The firmware's switch for
  it is GM22 byte 1, which omen-kbd-rgb 0.2.0 exposes as `gpu_ppab` and omend
  sets with the profile. Whether it raises the GPU's draw under a combined
  CPU+GPU load still has to be measured. That needs a GPU load, which this
  test deliberately does not run.

## Still open

* The same table on battery.
* A GPU load (a game, or `glmark2`) in performance, with Dynamic Boost on and
  then off: does the GPU draw go past 100 W?
* cTGP (GM22 byte 0). The DSDT stores it in `WMID.CTGP`, and nothing else in
  the DSDT reads that name. If the NVIDIA platform controller consumes it, it
  does so in an SSDT that has not been dumped. It is set because the vendor
  software sets it, not because an effect has been seen.
