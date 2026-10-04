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
    "SETTINGS_OVERVIEW_DESC": {
        "en": "Controls, language, system tools and appearance in one place.",
        "ru": "Управление, язык, системные инструменты и оформление в одном месте.",
        "uk": "Керування, мова, системні інструменти й оформлення в одному місці.",
        "de": "Steuerung, Sprache, Systemwerkzeuge und Darstellung an einem Ort.",
        "es": "Controles, idioma, herramientas del sistema y aspecto en un solo lugar.",
        "fr": "Commandes, langue, outils système et apparence au même endroit.",
        "it": "Controlli, lingua, strumenti di sistema e aspetto in un unico posto.",
        "ja": "操作、言語、システムツール、外観をまとめて設定します。",
        "ko": "조작, 언어, 시스템 도구와 화면 스타일을 한곳에서 설정합니다.",
        "nl": "Bediening, taal, systeemtools en uiterlijk op één plek.",
        "pl": "Sterowanie, język, narzędzia systemowe i wygląd w jednym miejscu.",
        "pt": "Controlos, idioma, ferramentas do sistema e aparência num só lugar.",
        "zh-cn": "在一处设置控制、语言、系统工具和外观。",
        "zh-tw": "在一處設定控制、語言、系統工具和外觀。",
    },
    "UI_OVERVIEW_DESC": {
        "en": "Choose colors, themes, sounds, wallpaper and widget layout.",
        "ru": "Выберите цвета, темы, звуки, обои и компоновку виджета.",
        "uk": "Виберіть кольори, теми, звуки, шпалери та компонування віджета.",
        "de": "Farben, Designs, Klänge, Hintergrund und Widget-Layout wählen.",
        "es": "Elige colores, temas, sonidos, fondo y diseño del widget.",
        "fr": "Choisissez les couleurs, thèmes, sons, fond et disposition du widget.",
        "it": "Scegli colori, temi, suoni, sfondo e disposizione del widget.",
        "ja": "色、テーマ、サウンド、壁紙、ウィジェット配置を選びます。",
        "ko": "색상, 테마, 소리, 배경화면과 위젯 배치를 선택합니다.",
        "nl": "Kies kleuren, thema's, geluiden, achtergrond en widgetindeling.",
        "pl": "Wybierz kolory, motywy, dźwięki, tapetę i układ widżetu.",
        "pt": "Escolha cores, temas, sons, fundo e disposição do widget.",
        "zh-cn": "选择颜色、主题、声音、壁纸和小组件布局。",
        "zh-tw": "選擇顏色、主題、聲音、桌布和小工具配置。",
    },
    "THEME_OVERVIEW_DESC": {
        "en": "Choose a visual theme. Changes are applied immediately.",
        "ru": "Выберите тему оформления. Изменения применяются сразу.",
        "uk": "Виберіть тему оформлення. Зміни застосовуються одразу.",
        "de": "Ein Design auswählen. Änderungen werden sofort angewendet.",
        "es": "Elige un tema visual. Los cambios se aplican al instante.",
        "fr": "Choisissez un thème visuel. Les changements sont immédiats.",
        "it": "Scegli un tema grafico. Le modifiche vengono applicate subito.",
        "ja": "外観テーマを選択します。変更はすぐに適用されます。",
        "ko": "화면 테마를 선택합니다. 변경 사항은 즉시 적용됩니다.",
        "nl": "Kies een visueel thema. Wijzigingen worden direct toegepast.",
        "pl": "Wybierz motyw. Zmiany są stosowane natychmiast.",
        "pt": "Escolha um tema visual. As alterações são aplicadas de imediato.",
        "zh-cn": "选择视觉主题，更改会立即生效。",
        "zh-tw": "選擇視覺主題，變更會立即生效。",
    },
    "SOUNDS_OVERVIEW_DESC": {
        "en": "Choose the feedback pack used for navigation and actions.",
        "ru": "Выберите набор откликов для навигации и действий.",
        "uk": "Виберіть набір відгуків для навігації та дій.",
        "de": "Feedback-Paket für Navigation und Aktionen auswählen.",
        "es": "Elige el paquete de respuesta para navegación y acciones.",
        "fr": "Choisissez le pack de retour pour la navigation et les actions.",
        "it": "Scegli il pacchetto di feedback per navigazione e azioni.",
        "ja": "ナビゲーションと操作に使うフィードバック音を選びます。",
        "ko": "탐색과 동작에 사용할 피드백 사운드 팩을 선택합니다.",
        "nl": "Kies het feedbackpakket voor navigatie en acties.",
        "pl": "Wybierz pakiet dźwięków nawigacji i działań.",
        "pt": "Escolha o pacote de resposta para navegação e ações.",
        "zh-cn": "选择用于导航和操作反馈的声音包。",
        "zh-tw": "選擇用於導覽和操作回饋的聲音包。",
    },
    "WALLPAPER_OVERVIEW_DESC": {
        "en": "Choose the background image and tune its color filter.",
        "ru": "Выберите фоновое изображение и настройте его цветовой фильтр.",
        "uk": "Виберіть фонове зображення та налаштуйте його кольоровий фільтр.",
        "de": "Hintergrundbild auswählen und seinen Farbfilter einstellen.",
        "es": "Elige la imagen de fondo y ajusta su filtro de color.",
        "fr": "Choisissez l'image de fond et réglez son filtre de couleur.",
        "it": "Scegli l'immagine di sfondo e regola il filtro colore.",
        "ja": "背景画像を選択し、カラーフィルターを調整します。",
        "ko": "배경 이미지를 선택하고 색상 필터를 조정합니다.",
        "nl": "Kies de achtergrondafbeelding en stel het kleurfilter af.",
        "pl": "Wybierz obraz tła i dostosuj jego filtr kolorów.",
        "pt": "Escolha a imagem de fundo e ajuste o filtro de cor.",
        "zh-cn": "选择背景图像并调整其颜色滤镜。",
        "zh-tw": "選擇背景影像並調整其色彩濾鏡。",
    },
    "WIDGET_OVERVIEW_DESC": {
        "en": "Choose which indicators are shown and how the widget is aligned.",
        "ru": "Выберите видимые показатели и способ выравнивания виджета.",
        "uk": "Виберіть видимі показники та спосіб вирівнювання віджета.",
        "de": "Sichtbare Anzeigen und Ausrichtung des Widgets festlegen.",
        "es": "Elige los indicadores visibles y la alineación del widget.",
        "fr": "Choisissez les indicateurs visibles et l'alignement du widget.",
        "it": "Scegli gli indicatori visibili e l'allineamento del widget.",
        "ja": "表示する情報とウィジェットの配置を選びます。",
        "ko": "표시할 정보와 위젯 정렬 방식을 선택합니다.",
        "nl": "Kies welke indicatoren zichtbaar zijn en hoe de widget wordt uitgelijnd.",
        "pl": "Wybierz widoczne wskaźniki i wyrównanie widżetu.",
        "pt": "Escolha os indicadores visíveis e o alinhamento do widget.",
        "zh-cn": "选择要显示的指标和小组件的对齐方式。",
        "zh-tw": "選擇要顯示的指標和小工具的對齊方式。",
    },
    "FEATURES_OVERVIEW_DESC": {
        "en": "System behavior, controller feedback, notifications and extra tools.",
        "ru": "Поведение системы, отклик контроллера, уведомления и дополнительные инструменты.",
        "uk": "Поведінка системи, відгук контролера, сповіщення та додаткові інструменти.",
        "de": "Systemverhalten, Controller-Feedback, Meldungen und Zusatzwerkzeuge.",
        "es": "Comportamiento del sistema, respuesta del mando, avisos y herramientas extra.",
        "fr": "Comportement système, retour de la manette, notifications et outils supplémentaires.",
        "it": "Comportamento del sistema, feedback del controller, notifiche e strumenti extra.",
        "ja": "システム動作、コントローラー反応、通知、追加ツールを設定します。",
        "ko": "시스템 동작, 컨트롤러 피드백, 알림과 추가 도구를 설정합니다.",
        "nl": "Systeemgedrag, controllerfeedback, meldingen en extra hulpmiddelen.",
        "pl": "Działanie systemu, reakcje kontrolera, powiadomienia i dodatkowe narzędzia.",
        "pt": "Comportamento do sistema, resposta do comando, notificações e ferramentas extra.",
        "zh-cn": "设置系统行为、控制器反馈、通知和附加工具。",
        "zh-tw": "設定系統行為、控制器回饋、通知和附加工具。",
    },
    "INTERFACE_OVERVIEW_DESC": {
        "en": "Tune selection, tables, transitions, gestures and panel side.",
        "ru": "Настройте выделение, таблицы, переходы, жесты и сторону панели.",
        "uk": "Налаштуйте виділення, таблиці, переходи, жести та бік панелі.",
        "de": "Auswahl, Tabellen, Übergänge, Gesten und Panel-Seite einstellen.",
        "es": "Ajusta selección, tablas, transiciones, gestos y lado del panel.",
        "fr": "Réglez la sélection, les tableaux, transitions, gestes et le côté du panneau.",
        "it": "Regola selezione, tabelle, transizioni, gesti e lato del pannello.",
        "ja": "選択表示、表、切り替え、ジェスチャー、パネル位置を調整します。",
        "ko": "선택 표시, 표, 전환, 제스처와 패널 위치를 조정합니다.",
        "nl": "Stel selectie, tabellen, overgangen, gebaren en paneelzijde af.",
        "pl": "Dostosuj zaznaczenie, tabele, przejścia, gesty i stronę panelu.",
        "pt": "Ajuste a seleção, tabelas, transições, gestos e lado do painel.",
        "zh-cn": "调整选中效果、表格、过渡、手势和面板位置。",
        "zh-tw": "調整選取效果、表格、轉場、手勢和面板位置。",
    },
    "UPDATES_OVERVIEW_DESC": {
        "en": "Automatic checks are optional. Manual scanning never freezes the menu.",
        "ru": "Автопроверка необязательна. Ручное сканирование не блокирует меню.",
        "uk": "Автоперевірка необов'язкова. Ручне сканування не блокує меню.",
        "de": "Automatische Prüfungen sind optional. Manuelles Suchen blockiert das Menü nicht.",
        "es": "La comprobación automática es opcional. El escaneo manual no bloquea el menú.",
        "fr": "La vérification automatique est facultative. L'analyse manuelle ne bloque pas le menu.",
        "it": "Il controllo automatico è facoltativo. La scansione manuale non blocca il menu.",
        "ja": "自動確認は任意です。手動スキャン中もメニューは停止しません。",
        "ko": "자동 확인은 선택 사항입니다. 수동 검색 중에도 메뉴가 멈추지 않습니다.",
        "nl": "Automatisch controleren is optioneel. Handmatig scannen blokkeert het menu niet.",
        "pl": "Automatyczne sprawdzanie jest opcjonalne. Ręczne skanowanie nie blokuje menu.",
        "pt": "A verificação automática é opcional. A pesquisa manual não bloqueia o menu.",
        "zh-cn": "自动检查为可选项，手动扫描不会卡住菜单。",
        "zh-tw": "自動檢查為選用項目，手動掃描不會卡住選單。",
    },
    "DEVICE_OVERVIEW_DESC": {
        "en": "Hardware, firmware, storage and the memory available to overlays.",
        "ru": "Оборудование, прошивка, накопители и доступная оверлеям память.",
        "uk": "Обладнання, прошивка, накопичувачі та доступна оверлеям пам'ять.",
        "de": "Hardware, Firmware, Speicher und der für Overlays verfügbare Arbeitsspeicher.",
        "es": "Hardware, firmware, almacenamiento y memoria disponible para overlays.",
        "fr": "Matériel, firmware, stockage et mémoire disponible pour les overlays.",
        "it": "Hardware, firmware, archiviazione e memoria disponibile per gli overlay.",
        "ja": "ハードウェア、ファームウェア、ストレージ、オーバーレイ用メモリを表示します。",
        "ko": "하드웨어, 펌웨어, 저장소와 오버레이에서 사용할 수 있는 메모리입니다.",
        "nl": "Hardware, firmware, opslag en geheugen dat voor overlays beschikbaar is.",
        "pl": "Sprzęt, firmware, pamięć masowa i RAM dostępny dla nakładek.",
        "pt": "Hardware, firmware, armazenamento e memória disponível para overlays.",
        "zh-cn": "显示硬件、固件、存储空间及叠加层可用内存。",
        "zh-tw": "顯示硬體、韌體、儲存空間及疊加層可用記憶體。",
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
