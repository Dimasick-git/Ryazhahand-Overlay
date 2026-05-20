#!/usr/bin/env python3
"""
Удаляет эмодзи и прочие символы вне базового латинско-кириллического
диапазона из текстовых файлов проекта. На Switch (libtesla) шрифт
не содержит этих глифов -- они отображаются как пустые квадраты или
ломают вёрстку меню.

Запуск:
    python scripts/strip_emoji.py [--root PATH] [--dry-run]
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

# Регулярка для широкого набора эмодзи и пиктограмм.
# Покрывает: эмодзи (U+1F300..U+1FAFF), Misc Symbols (U+2600..U+27BF),
# Dingbats, Geometric Shapes Extended, variation selectors, ZWJ,
# Misc Technical, Supplemental Symbols (U+1F000..U+1F9FF).
EMOJI_RE = re.compile(
    "["
    "\U0001F300-\U0001FAFF"
    "\U0001F000-\U0001F9FF"
    "\U00002600-\U000027BF"
    "\U00002300-\U000023FF"
    "\U000025A0-\U000026FF"
    "\U0001F1E6-\U0001F1FF"  # флаги
    "\U00002B00-\U00002BFF"
    "︀-️"           # variation selectors
    "‍"                  # zero-width joiner
    "]+",
    flags=re.UNICODE,
)

TEXT_EXT = {
    ".md", ".txt", ".cpp", ".hpp", ".h", ".c", ".cc",
    ".mk", ".ini", ".json", ".yml", ".yaml",
    ".ps1", ".py", ".sh", ".bat", ".cmd",
    ".kts", ".gradle", ".cmake",
}
TEXT_NAMES = {"Makefile", "LICENSE", "README", "CHANGELOG", "AUTHORS"}

SKIP = (
    os.sep + ".git" + os.sep,
    os.sep + "build" + os.sep,
    os.sep + "out" + os.sep,
    os.sep + "node_modules" + os.sep,
    os.sep + "lib" + os.sep + "libryazhahand" + os.sep,  # отдельный submodule
    "strip_emoji.py",
    "strip_emoji-report",
)


def is_target(p: Path) -> bool:
    sp = str(p)
    for s in SKIP:
        if s in sp:
            return False
    return p.suffix.lower() in TEXT_EXT or p.name in TEXT_NAMES


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=os.getcwd())
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    root = Path(args.root).resolve()
    if not root.exists():
        print(f"[!] {root} не существует")
        return 1

    scanned = 0
    changed = 0
    lines: list[str] = []

    for p in root.rglob("*"):
        if not p.is_file():
            continue
        if not is_target(p):
            continue
        scanned += 1
        try:
            raw = p.read_bytes()
            text = raw.decode("utf-8")
        except (OSError, UnicodeDecodeError):
            continue

        cleaned = EMOJI_RE.sub("", text)
        # Подчистить случаи "слово  слово" и хвостовые пробелы.
        cleaned = re.sub(r"  +", " ", cleaned)
        cleaned = re.sub(r" +\n", "\n", cleaned)
        # Подчистить пустые "[ ]" и "()" если что-то рядом удалилось.
        cleaned = re.sub(r"\[\s*\]\(", "[](", cleaned)

        if cleaned != text:
            removed = len(text) - len(cleaned)
            rel = p.relative_to(root)
            lines.append(f"{rel}: -{removed} chars")
            changed += 1
            if not args.dry_run:
                p.write_text(cleaned, encoding="utf-8")

    report_dir = root / "scripts"
    report_dir.mkdir(exist_ok=True)
    report = report_dir / "strip_emoji-report.txt"
    report.write_text(
        f"scanned: {scanned}\nchanged: {changed}\ndry_run: {args.dry_run}\n\n"
        + "\n".join(lines) + "\n",
        encoding="utf-8",
    )
    print(f"scanned={scanned} changed={changed} report={report}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
