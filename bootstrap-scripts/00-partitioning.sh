#!/usr/bin/env bash
# arch-partition.sh — Non-interactive partitioning for /dev/nvme0n1
#
# Usage:
#   sudo ./arch-partition.sh               # partition only
#   sudo ./arch-partition.sh --nvme-format # nvme format -s 1, then partition

set -euo pipefail

DISK="/dev/nvme0n1"
PART_ESP="${DISK}p1"
PART_DATA="${DISK}p2"

die() { echo "ERROR: $*" >&2; exit 1; }

[[ "${EUID}" -eq 0 ]] || die "Must be run as root."
command -v sgdisk   &>/dev/null || die "sgdisk not found."
command -v mkfs.fat &>/dev/null || die "mkfs.fat not found."
[[ -b "${DISK}" ]]  || die "${DISK} is not a block device."

# ── NVMe secure erase (optional) ─────────────────────────────────────────────

if [[ "${1:-}" == "--nvme-format" ]]; then
  command -v nvme &>/dev/null || die "nvme-cli not found."
  echo ">> nvme format -s 1 ${DISK}"
  nvme format -s 1 "${DISK}"
  sleep 2
fi

# ── Partition ─────────────────────────────────────────────────────────────────

echo ">> Wiping ${DISK}..."
# sgdisk --zap-all "${DISK}"
sgdisk --clear   "${DISK}"

echo ">> Creating ESP (1 GiB)..."
sgdisk --new=1:0:+1GiB --typecode=1:ef00 --change-name=1:"EFI System Partition" "${DISK}"

echo ">> Creating data partition (remaining)..."
sgdisk --new=2:0:0 --typecode=2:8300 --change-name=2:"Linux filesystem" "${DISK}"

partprobe "${DISK}" 2>/dev/null || udevadm settle
sleep 1

# ── Format ESP ────────────────────────────────────────────────────────────────

echo ">> Formatting ${PART_ESP} as FAT32..."
mkfs.fat -F 32 -n "EFI" "${PART_ESP}"

# ${PART_DATA} intentionally left unformatted.

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
sgdisk --print "${DISK}"
echo ""
echo "${PART_ESP}  → FAT32 (ESP)"
echo "${PART_DATA} → unformatted"
