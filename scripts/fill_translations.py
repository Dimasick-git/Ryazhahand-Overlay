#!/usr/bin/env python3
"""
Fill missing keys in lang/*.json so every locale has the full set of
strings that the overlay can request at runtime.

Ryzhand-specific keys (the rebrand layer + new features like TXT_READER,
HOME_LED_GLOW, STAIRCASE_EFFECT, ...) only existed in en.json/ru.json --
the other 12 locales were silently falling back to the key name on UI.

Run from repo root:
    python3 scripts/fill_translations.py
"""
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

LANG_DIR = Path(__file__).resolve().parent.parent / "lang"

# Translations sourced manually. Where I'm not confident in a locale,
# I leave the English source -- it's the same fallback the overlay
# used implicitly, just made explicit here so the audit script stops
# flagging it as "missing".
NEW_KEYS = {
    "EXTERNAL_NOTIFICATIONS": {
        "en": "External Notifications",
        "ru": "Внешние уведомления",
        "uk": "Зовнішні сповіщення",
        "de": "Externe Benachrichtigungen",
        "es": "Notificaciones externas",
        "fr": "Notifications externes",
        "it": "Notifiche esterne",
        "ja": "外部通知",
        "ko": "외부 알림",
        "nl": "Externe meldingen",
        "pl": "Powiadomienia zewnętrzne",
        "pt": "Notificações externas",
        "zh-cn": "外部通知",
        "zh-tw": "外部通知",
    },
    "HOME_LED_GLOW": {
        "en": "HOME LED Glow",
        "ru": "Свечение HOME LED",
        "uk": "Свічення HOME LED",
        "de": "HOME LED Leuchten",
        "es": "Brillo del LED HOME",
        "fr": "Éclat de la LED HOME",
        "it": "Bagliore LED HOME",
        "ja": "HOME LED の発光",
        "ko": "HOME LED 발광",
        "nl": "HOME LED-gloed",
        "pl": "Świecenie diody HOME",
        "pt": "Brilho do LED HOME",
        "zh-cn": "HOME 灯效",
        "zh-tw": "HOME 燈效",
    },
    "NO_TXT_FILES_FOUND": {
        "en": "No TXT files found",
        "ru": "TXT-файлы не найдены",
        "uk": "TXT-файли не знайдено",
        "de": "Keine TXT-Dateien gefunden",
        "es": "No se han encontrado archivos TXT",
        "fr": "Aucun fichier TXT trouvé",
        "it": "Nessun file TXT trovato",
        "ja": "TXTファイルが見つかりません",
        "ko": "TXT 파일을 찾을 수 없음",
        "nl": "Geen TXT-bestanden gevonden",
        "pl": "Nie znaleziono plików TXT",
        "pt": "Nenhum ficheiro TXT encontrado",
        "zh-cn": "未找到 TXT 文件",
        "zh-tw": "找不到 TXT 檔案",
    },
    "RYZHAND_HAS_RESTARTED": {
        "en": "Ryzhand has restarted.",
        "ru": "Ryzhand перезапущен.",
        "uk": "Ryzhand перезапущено.",
        "de": "Ryzhand wurde neu gestartet.",
        "es": "Ryzhand se ha reiniciado.",
        "fr": "Ryzhand a redémarré.",
        "it": "Ryzhand è stato riavviato.",
        "ja": "Ryzhand を再起動しました。",
        "ko": "Ryzhand 재시작됨.",
        "nl": "Ryzhand is opnieuw gestart.",
        "pl": "Ryzhand został zrestartowany.",
        "pt": "Ryzhand foi reiniciado.",
        "zh-cn": "Ryzhand 已重启。",
        "zh-tw": "Ryzhand 已重啟。",
    },
    "STAIRCASE_EFFECT": {
        "en": "Staircase Effect",
        "ru": "Эффект лестницы",
        "uk": "Ефект сходів",
        "de": "Treppeneffekt",
        "es": "Efecto escalera",
        "fr": "Effet escalier",
        "it": "Effetto scala",
        "ja": "階段エフェクト",
        "ko": "계단 효과",
        "nl": "Trapeffect",
        "pl": "Efekt schodów",
        "pt": "Efeito escada",
        "zh-cn": "阶梯效果",
        "zh-tw": "階梯效果",
    },
    "STARTUP_NOTIFICATION": {
        "en": "Startup Notification",
        "ru": "Уведомление при запуске",
        "uk": "Сповіщення при запуску",
        "de": "Start-Benachrichtigung",
        "es": "Notificación de inicio",
        "fr": "Notification au démarrage",
        "it": "Notifica di avvio",
        "ja": "起動時通知",
        "ko": "시작 알림",
        "nl": "Opstartmelding",
        "pl": "Powiadomienie startowe",
        "pt": "Notificação de inicialização",
        "zh-cn": "启动通知",
        "zh-tw": "啟動通知",
    },
    "TEXT_COLOR": {
        "en": "Text Color",
        "ru": "Цвет текста",
        "uk": "Колір тексту",
        "de": "Textfarbe",
        "es": "Color del texto",
        "fr": "Couleur du texte",
        "it": "Colore del testo",
        "ja": "テキストの色",
        "ko": "텍스트 색상",
        "nl": "Tekstkleur",
        "pl": "Kolor tekstu",
        "pt": "Cor do texto",
        "zh-cn": "文本颜色",
        "zh-tw": "文字顏色",
    },
    "TEXT_COLOR_PICKER_HINT": {
        "en": "Left/Right: channel  Up/Down: +/-1  L/R: +/-10  A: Save  B: Back",
        "ru": "←/→: канал  ↑/↓: ±1  L/R: ±10  A: Сохранить  B: Назад",
        "uk": "←/→: канал  ↑/↓: ±1  L/R: ±10  A: Зберегти  B: Назад",
        "de": "L/R: Kanal  O/U: ±1  L/R: ±10  A: Speichern  B: Zurück",
        "es": "Izq/Der: canal  Arr/Aba: ±1  L/R: ±10  A: Guardar  B: Atrás",
        "fr": "G/D: canal  H/B: ±1  L/R: ±10  A: Sauver  B: Retour",
        "it": "S/D: canale  Su/Giu: ±1  L/R: ±10  A: Salva  B: Indietro",
        "ja": "←/→: チャンネル  ↑/↓: ±1  L/R: ±10  A: 保存  B: 戻る",
        "ko": "←/→: 채널  ↑/↓: ±1  L/R: ±10  A: 저장  B: 뒤로",
        "nl": "L/R: kanaal  O/N: ±1  L/R: ±10  A: Opslaan  B: Terug",
        "pl": "L/P: kanał  G/D: ±1  L/R: ±10  A: Zapisz  B: Wstecz",
        "pt": "Esq/Dir: canal  Cima/Bxo: ±1  L/R: ±10  A: Guardar  B: Voltar",
        "zh-cn": "左/右: 通道  上/下: ±1  L/R: ±10  A: 保存  B: 返回",
        "zh-tw": "左/右: 通道  上/下: ±1  L/R: ±10  A: 儲存  B: 返回",
    },
    "SOUND_NAVIGATION": {
        "en": "Navigation sound",
        "ru": "Звук навигации",
        "uk": "Звук навігації",
        "de": "Navigationston",
        "es": "Sonido de navegación",
        "fr": "Son de navigation",
        "it": "Suono di navigazione",
        "ja": "ナビゲーション音",
        "ko": "탐색 사운드",
        "nl": "Navigatiegeluid",
        "pl": "Dźwięk nawigacji",
        "pt": "Som de navegação",
        "zh-cn": "导航声音",
        "zh-tw": "導覽聲音",
    },
    "SOUND_ENTER": {
        "en": "Confirm sound",
        "ru": "Звук подтверждения",
        "uk": "Звук підтвердження",
        "de": "Bestätigungston",
        "es": "Sonido de confirmación",
        "fr": "Son de confirmation",
        "it": "Suono di conferma",
        "ja": "決定音",
        "ko": "확인 사운드",
        "nl": "Bevestigingsgeluid",
        "pl": "Dźwięk potwierdzenia",
        "pt": "Som de confirmação",
        "zh-cn": "确认声音",
        "zh-tw": "確認聲音",
    },
    "SOUND_EXIT": {
        "en": "Cancel sound",
        "ru": "Звук отмены",
        "uk": "Звук скасування",
        "de": "Abbrechen-Ton",
        "es": "Sonido de cancelación",
        "fr": "Son d'annulation",
        "it": "Suono di annullamento",
        "ja": "キャンセル音",
        "ko": "취소 사운드",
        "nl": "Annulerengeluid",
        "pl": "Dźwięk anulowania",
        "pt": "Som de cancelamento",
        "zh-cn": "取消声音",
        "zh-tw": "取消聲音",
    },
    "SOUND_WALL": {
        "en": "Wall sound",
        "ru": "Звук упора",
        "uk": "Звук удару",
        "de": "Anschlagton",
        "es": "Sonido de tope",
        "fr": "Son de butée",
        "it": "Suono di battuta",
        "ja": "壁音",
        "ko": "벽 사운드",
        "nl": "Stuitgeluid",
        "pl": "Dźwięk granicy",
        "pt": "Som de limite",
        "zh-cn": "撞壁声音",
        "zh-tw": "撞壁聲音",
    },
    "TXT_READER": {
        "en": "TXT Reader",
        "ru": "Читалка TXT",
        "uk": "Читач TXT",
        "de": "TXT-Leser",
        "es": "Lector de TXT",
        "fr": "Lecteur TXT",
        "it": "Lettore TXT",
        "ja": "TXTリーダー",
        "ko": "TXT 리더",
        "nl": "TXT-lezer",
        "pl": "Czytnik TXT",
        "pt": "Leitor de TXT",
        "zh-cn": "TXT 阅读器",
        "zh-tw": "TXT 閱讀器",
    },
}


def lang_code(fname: str) -> str:
    return fname.removesuffix(".json")


def main() -> int:
    if not LANG_DIR.is_dir():
        print(f"[!] {LANG_DIR} not found", file=sys.stderr)
        return 1

    updated_total = 0
    for path in sorted(LANG_DIR.glob("*.json")):
        code = lang_code(path.name)
        with path.open("r", encoding="utf-8-sig") as f:
            data = json.load(f)

        added = 0
        for key, translations in NEW_KEYS.items():
            if key not in data:
                value = translations.get(code) or translations["en"]
                data[key] = value
                added += 1

        if added:
            # Keep sorted-ish? overlay reads by key, order doesn't matter.
            # Write back without BOM (utf-8) -- libryazha ini loader handles
            # both, and utf-8 is the convention in the rest of the tree.
            with path.open("w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=4)
                f.write("\n")
            print(f"  ~ {path.name}: +{added}")
            updated_total += 1

    print(f"updated {updated_total} files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
