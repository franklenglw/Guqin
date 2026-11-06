import QtQuick 2.9
import Qt.labs.settings 1.0
import MuseScore 3.0

MuseScore {
    id: guqinTool
    pluginType: "dock"

    // ==== 多语言配置 ====
    property var translations: {
        "zh": {
            "pname": "古琴工具",
            "desc": "基于 JianZiPu V3 标准（多标记版，带搜索）",
            "title": "古琴减字 V3（面板编辑器）：",
            "read": "读取",
            "apply": "修改",
            "delete": "删除",
            "deleteAll": "一键删除全部古琴标记",
            "hint": "点音符 -> 点读取 -> 改代码（多个用 ; 分隔）-> 点修改",
            "commonMarks": "常用标记",
            "search": "搜索中文 / 代码",
            "clear": "清空",
            "count": "条",
            "noresult": "无匹配结果"
        },
        "en": {
            "pname": "Guqin Tool",
            "desc": "Based on JianZiPu V3 Standard (Multi-mark, with search)",
            "title": "Guqin JianZiPu V3 (Panel Editor):",
            "read": "Read",
            "apply": "Apply",
            "delete": "Delete",
            "deleteAll": "Delete All Guqin Marks",
            "hint": "Click note -> Read -> Edit code (separate with ;) -> Apply",
            "commonMarks": "Common",
            "search": "Search",
            "clear": "Clear",
            "count": "items",
            "noresult": "No matches found"
        },
        "ja": {
            "pname": "古琴ツール",
            "desc": "JianZiPu V3 標準に基づく（マルチマーク版、検索付き）",
            "title": "古琴減字 V3（パネルエディタ）：",
            "read": "読み取り",
            "apply": "適用",
            "delete": "削除",
            "deleteAll": "古琴マークをすべて削除",
            "hint": "音符をクリック -> 読み取り -> コードを編集（複数は ; 区切り） -> 適用",
            "commonMarks": "よく使う",
            "search": "検索",
            "clear": "クリア",
            "count": "件",
            "noresult": "一致する結果がありません"
        },
        "ko": {
            "pname": "고금 도구",
            "desc": "JianZiPu V3 표준 기반 (다중 마크 버전, 검색 포함)",
            "title": "고금 감자 V3 (패널 편집기):",
            "read": "읽기",
            "apply": "적용",
            "delete": "삭제",
            "deleteAll": "모든 고금 마크 삭제",
            "hint": "음표 클릭 -> 읽기 -> 코드 편집 (여러 개는 ; 로 구분) -> 적용",
            "commonMarks": "자주 쓰는",
            "search": "검색",
            "clear": "지우기",
            "count": "개",
            "noresult": "일치하는 결과가 없습니다"
        }
    }

    property string uiLang: {
        var loc = Qt.locale().name.substring(0, 2)
        return (translations[loc] !== undefined) ? loc : "en"
    }

    property var tr: translations[uiLang]

    property string pname: tr.pname
    menuPath: "Plugins." + pname
    version: "3.7"
    description: tr.desc

    implicitWidth: 380
    implicitHeight: 720

    // ==== 主题自适应调色板 ====
    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    // ==== 标记统一配置 ====
    property string markFont: "JianZiPu"
    property int    markFontSize: 12
    property real   markLineSpacing: 1.2
    property real   markOffsetY: 3.5
    property real   markStackSpacing: 2.0

    Settings {
        id: pluginSettings
        category: "guqinTool"
        property double lastHeartbeat: 0
    }

    Timer {
        id: heartbeatTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: { pluginSettings.lastHeartbeat = new Date().getTime() }
    }

    property var activeNote: null
    property int activeTick: 0
    property int activeTrack: -1
    property int lastReadTick: -1

    property string multiSep: ";"

    // ==== 完整标记库（基于 JianZiPu V3 官方字体说明） ====
    property var allItems: [
        // --- 左手基础指法 ---
        "名九勾三 ｜ s9k3",
        "中九勾三 ｜ d9k3",
        "食九勾三 ｜ f9k3",
        "大九勾三 ｜ v9k3",
        "跪九勾三 ｜ x9k3",
        "大七挑五 ｜ v7,5u5",
        "中八抹四 ｜ d8,4j4",
        "食十劈一 ｜ f10,1n1",
        "跪三托二 ｜ x3,2h2",

        // --- 散音右手基本指法 ---
        "散劈五 ｜ 0n5",
        "散托五 ｜ 0h5",
        "散抹五 ｜ 0j5",
        "散挑五 ｜ 0u5",
        "散勾五 ｜ 0k5",
        "散剔五 ｜ 0i5",
        "散打五 ｜ 0l5",
        "散摘五 ｜ 0o5",
        "散抹挑五 ｜ 0ju5",
        "散勾剔五 ｜ 0ki5",
        "散打摘五 ｜ 0lo5",
        "散历六五 ｜ 0U65",

        // --- 名指右手指法（各种手型） ---
        "名九劈五 ｜ s9n5",
        "名九托五 ｜ s9h5",
        "名九抹五 ｜ s9j5",
        "名九挑五 ｜ s9u5",
        "名九勾五 ｜ s9k5",
        "名九剔五 ｜ s9i5",
        "名九打五 ｜ s9l5",
        "名九摘五 ｜ s9o5",
        "名九历五四 ｜ s9U54",

        // --- 各指法组合 ---
        "名八勾三 ｜ s8k3",
        "中外挑五 ｜ d13+u5",
        "大九抹挑七 ｜ v9ju7",
        "名七徽五 ｜ s7.5",
        "名七五 ｜ s75",

        // --- 徽位与弦位 ---
        "名七六 (7.6徽无弦) ｜ s76",
        "名七,六 (7徽6弦) ｜ s7,6",
        "名七六六 (7.6徽6弦) ｜ s766",
        "名十一 (10.1徽) ｜ s10.1",
        "历七六 (历7、6弦) ｜ U76",
        "名七点九 ｜ s7.9",
        "名十 ｜ s10",
        "名十二 ｜ s12",
        "名十二徽 ｜ s12",
        "名十，二 ｜ s10,2",
        "名十二二 ｜ s122",
        "中八半勾五 ｜ d8.5k5",
        "中八五勾五 ｜ d85k5",
        "名外挑六 (13+徽) ｜ s13+u6",
        "名十三二挑六 ｜ s132u6",

        // --- 特殊装饰音 ---
        "名九绰勾三 ｜ s9/k3",
        "名九急勾三 ｜ s9>k3",
        "名九注勾三 ｜ s9\\k3",
        "名九掩六 ｜ s9V6",
        "名九绰勾六 ｜ s9/k6",
        "名九急勾六 ｜ s9>k6",
        "名九注勾六 ｜ s9\\k6",
        "泛音名九勾六 ｜ fys9k6",
        "泛音大八五 ｜ fyv8,5",
        "就勾五 ｜ jiuk5",

        // --- 撮/和弦 ---
        "撮大九,六|散三 ｜ Cv9, 6|03",
        "撮大九六|散三 ｜ Cv96|03",
        "撮名九,三|散五 ｜ Cs9,3|05",
        "撮中八,七|散五 ｜ Cd8,7|05",
        "大撮中八,七|散二 ｜ DCd8, 7|02",
        "反撮中八,七|散二 ｜ FCd8,7|02",
        "拨中七,七|散六 ｜ Bd7,7|06",
        "剌中七,七|散六 ｜ Ld7,7|06",
        "拨剌中七,七|散六 ｜ BLd7, 7|06",
        "双弹中七,七|散六 ｜ TTd7, 7|06",
        "三弹中七,七|散六 ｜ TTTd7,7|06",
        "拨剌大九注六|散五 ｜ BLv9\\6|05",

        // --- 竖排 - 位置/走向 ---
        "上七九 ｜ :shang79",
        "下六二 ｜ :xia62",
        "上六四 ｜ :shang64",
        "下七九 ｜ :xia79",
        "进 ｜ :jin",
        "退 ｜ :tui",
        "复 ｜ :fu4",
        "撞 ｜ :zhuang",
        "至 ｜ :zhi4",
        "上 ｜ :shang",
        "下 ｜ :xia",

        // --- 竖排 - 吟猱 ---
        "吟 ｜ :yin",
        "猱 ｜ :nao",
        "长吟 ｜ :changyin",
        "细吟 ｜ :xiyin",
        "定吟 ｜ :dingyin",
        "小吟 ｜ :xiaoyin",

        // --- 竖排 - 其它技法/符号 ---
        "泛起 ｜ :fanqi",
        "泛止 ｜ :fanzhi",
        "泛 ｜ :fan",
        "止 ｜ :zhi",
        "起 ｜ :qi",
        "分开 ｜ :fenkai",
        "滚沸 ｜ :gunfu",
        "应合 ｜ :yinghe",
        "淌 ｜ :tang",
        "如 ｜ :ru",
        "带起 ｜ :daiqi",
        "对起 ｜ :duiqi",
        "抓起 ｜ :zhuaqi",
        "撇起 ｜ :pieqi",
        "大息 ｜ :daxi",
        "少息 ｜ :shaoxi",

        // --- 竖排 - 复合指法 ---
        "大八五轮七 ｜ :v8.51un7",
        "大八五七 ｜ :v8.57",
        "大八五 ｜ :v8.5",
        "大八，五 ｜ :v8,5",

        // --- 散音与基础标记 ---
        "散 ｜ 0",
        "散(竖排) ｜ :san",
        "外 ｜ :wai",
        "半 ｜ :ban",
        "就 ｜ :jiu"
    ]
    property var filteredItems: []

    function codeOfItem(s) {
        var parts = s.split("｜")
        return parts.length > 1 ? parts[1].trim() : parts[0].trim()
    }

    function filterItems() {
        var kw = searchInput.text.trim().toLowerCase()
        if (kw === "") { filteredItems = allItems; return }
        var kws = kw.split(/\s+/)
        var res = []
        for (var i = 0; i < allItems.length; i++) {
            var s = allItems[i].toLowerCase()
            var ok = true
            for (var j = 0; j < kws.length; j++) {
                if (s.indexOf(kws[j]) < 0) { ok = false; break }
            }
            if (ok) res.push(allItems[i])
        }
        filteredItems = res
    }

    function relayout() {
        try { if (curScore && curScore.layout) curScore.layout() } catch (e) {}
        try {
            if (typeof score !== "undefined" && score && score.layout)
                score.layout()
        } catch (e) {}
    }

    function captureCursor() {
        var cur = curScore.newCursor()
        cur.inputStateMode = Cursor.INPUT_STATE_SYNC_WITH_SCORE
        if (cur.segment) {
            activeTick = cur.tick
            activeNote = cur.element
            activeTrack = cur.track !== undefined ? cur.track : (cur.staffIdx * 4 + cur.voice)
            return true
        } else {
            activeNote = null
            activeTick = -1
            activeTrack = -1
            return false
        }
    }

    function getAllTextsAtTick(tick, track) {
        var result = []
        if (tick === undefined || tick < 0) return result
        var cur = curScore.newCursor()
        cur.inputStateMode = Cursor.INPUT_STATE_SYNC_WITH_SCORE
        try { cur.rewindToTick(tick) } catch (e) { return result }
        if (!cur.segment) return result

        var seg = cur.segment
        var seen = []

        var checkAndPush = function(el) {
            if (!el || el.type !== Element.STAFF_TEXT) return
            if (track !== undefined && el.track !== undefined && el.track !== track) return
            for (var k = 0; k < seen.length; k++) if (seen[k] === el) return
            seen.push(el)
            result.push(el)
        }

        if (seg.annotations) {
            for (var i = 0; i < seg.annotations.length; i++) checkAndPush(seg.annotations[i])
        }
        if (seg.elements) {
            for (var j = 0; j < seg.elements.length; j++) checkAndPush(seg.elements[j])
        }

        result.sort(function(a, b) {
            var aY = (a.offsetY !== undefined && a.offsetY !== null) ? a.offsetY : 0;
            var bY = (b.offsetY !== undefined && b.offsetY !== null) ? b.offsetY : 0;
            return aY - bY;
        })
        return result
    }

    function getAllTextsAtCursor() {
        var cur = curScore.newCursor()
        cur.inputStateMode = Cursor.INPUT_STATE_SYNC_WITH_SCORE
        var currentTrack = cur.track !== undefined ? cur.track : (cur.staffIdx * 4 + cur.voice)

        if (curScore.selection && curScore.selection.elements && curScore.selection.elements.length > 0) {
            var el = curScore.selection.elements[0]
            var t = (el.tick !== undefined) ? el.tick : (cur.segment ? cur.segment.tick : -1)
            var tr2 = (el.track !== undefined) ? el.track : currentTrack
            if (t >= 0) return getAllTextsAtTick(t, tr2)
        }
        if (!cur.segment) return []
        return getAllTextsAtTick(cur.segment.tick, currentTrack)
    }

    function locateTexts() {
        var cur = curScore.newCursor()
        cur.inputStateMode = Cursor.INPUT_STATE_SYNC_WITH_SCORE
        var currentTick = cur.tick
        var currentTrack = cur.track !== undefined ? cur.track : (cur.staffIdx * 4 + cur.voice)

        if (currentTick !== lastReadTick) {
            return getAllTextsAtCursor()
        }
        var arr = getAllTextsAtTick(lastReadTick, currentTrack)
        if (arr.length > 0) return arr
        return getAllTextsAtCursor()
    }

    function readCurrentText() {
        if (!captureCursor()) return
        var texts = getAllTextsAtCursor()
        if (texts.length > 0) {
            lastReadTick = activeTick
            var codes = []
            for (var i = 0; i < texts.length; i++) {
                var raw = texts[i].text.replace(/[+\n]/g, "").trim()
                if (raw !== "") codes.push(raw)
            }
            editInput.text = codes.join(multiSep + " ")
        } else {
            editInput.text = ""
            lastReadTick = activeTick
        }
    }

    function _removeElementSafe(el) {
        try {
            if (typeof curScore.removeElement === "function") {
                curScore.removeElement(el); return true
            } else if (typeof curScore.remove === "function") {
                curScore.remove(el); return true
            }
        } catch (e) {}
        return false
    }

    function applyCurrentText() {
        var input = editInput.text.trim()
        if (input === "") return

        var parts = input.split(multiSep)
        var codes = []
        for (var i = 0; i < parts.length; i++) {
            var c = parts[i].trim()
            if (c !== "") codes.push(c)
        }
        if (codes.length === 0) return

        var cur = curScore.newCursor()
        cur.inputStateMode = Cursor.INPUT_STATE_SYNC_WITH_SCORE
        var currentTick = cur.tick
        var currentTrack = cur.track !== undefined ? cur.track : (cur.staffIdx * 4 + cur.voice)

        var texts = locateTexts()
        var tick = (texts.length > 0 && texts[0].tick !== undefined) ? texts[0].tick : currentTick
        var track = (texts.length > 0 && texts[0].track !== undefined) ? texts[0].track : currentTrack

        if (texts.length === 0) {
            insertTexts(codes, 0, tick, track)
            return
        }

        curScore.startCmd()
        var n = Math.min(texts.length, codes.length)
        for (var k = 0; k < n; k++) {
            texts[k].text = codes[k] + "+\n"
            texts[k].fontFace = markFont
            texts[k].fontFamily = markFont
            texts[k].textLineSpacing = markLineSpacing
            texts[k].fontSize = markFontSize
            texts[k].placement = Placement.BELOW
            texts[k].autoplace = false
            texts[k].offsetX = 0
            texts[k].offsetY = markOffsetY + k * markStackSpacing
        }
        for (var d = codes.length; d < texts.length; d++) {
            if (!_removeElementSafe(texts[d])) texts[d].text = ""
        }
        curScore.endCmd()
        relayout()

        if (codes.length > texts.length) {
            insertTexts(codes.slice(texts.length), texts.length, tick, track)
        }

        editInput.text = codes.join(multiSep + " ")
        lastReadTick = tick
    }

    function insertTexts(codes, startIndex, tick, track) {
        if (!codes || codes.length === 0) return
        if (tick === undefined || tick < 0) {
            if (!captureCursor()) return
            tick = activeTick
            track = activeTrack
        } else if (track === undefined) {
            var cur = curScore.newCursor()
            cur.inputStateMode = Cursor.INPUT_STATE_SYNC_WITH_SCORE
            track = cur.track !== undefined ? cur.track : (cur.staffIdx * 4 + cur.voice)
        }

        var cur = curScore.newCursor()
        cur.inputStateMode = Cursor.INPUT_STATE_SYNC_WITH_SCORE

        if (track !== undefined && track >= 0) {
            cur.staffIdx = Math.floor(track / 4)
            cur.voice = track % 4
        }

        try { cur.rewindToTick(tick) } catch (e) { return }
        if (!cur.segment) return

        var base = startIndex || 0
        curScore.startCmd()
        for (var i = 0; i < codes.length; i++) {
            var staffText = newElement(Element.STAFF_TEXT)
            staffText.text = codes[i] + "+\n"
            staffText.fontFace = markFont
            staffText.fontFamily = markFont
            staffText.textLineSpacing = markLineSpacing
            staffText.fontSize = markFontSize
            staffText.placement = Placement.BELOW
            staffText.autoplace = false
            staffText.offsetX = 0
            staffText.offsetY = markOffsetY + (base + i) * markStackSpacing
            cur.add(staffText)
        }
        curScore.endCmd()
        relayout()
        lastReadTick = tick
    }

    function insertText(textData, displayText) {
        var cur = curScore.newCursor()
        cur.inputStateMode = Cursor.INPUT_STATE_SYNC_WITH_SCORE
        var currentTick = cur.tick
        var currentTrack = cur.track !== undefined ? cur.track : (cur.staffIdx * 4 + cur.voice)

        var existingTexts = getAllTextsAtTick(currentTick, currentTrack)
        var startIndex = existingTexts.length

        insertTexts([textData], startIndex, currentTick, currentTrack)
        readCurrentText()
    }

    function deleteCurrentText() {
        var texts = locateTexts()
        if (texts.length === 0) {
            editInput.text = ""
            lastReadTick = -1
            return
        }
        curScore.startCmd()
        for (var i = 0; i < texts.length; i++) {
            if (!_removeElementSafe(texts[i])) texts[i].text = ""
        }
        curScore.endCmd()
        relayout()
        editInput.text = ""
        lastReadTick = -1
    }

    // ==== 全谱删除古琴标记 ====
    function isGuqinMark(el) {
        if (!el) return false
        try { if (el.type !== Element.STAFF_TEXT) return false } catch (e) { return false }
        var f1 = el.fontFace ? String(el.fontFace).toLowerCase() : ""
        var f2 = el.fontFamily ? String(el.fontFamily).toLowerCase() : ""
        var t = markFont.toLowerCase()
        return f1.indexOf(t) >= 0 || f2.indexOf(t) >= 0
    }

    function deleteAllGuqinMarks() {
        if (!curScore) return

        var toRemove = []
        function addIfMatch(el) {
            if (!el) return
            if (!isGuqinMark(el)) return
            for (var z = 0; z < toRemove.length; z++) {
                if (toRemove[z] === el) return
            }
            toRemove.push(el)
        }

        var numStaves = curScore.nstaves || 1
        for (var s = 0; s < numStaves; s++) {
            for (var v = 0; v < 4; v++) {
                var cur = curScore.newCursor()
                cur.inputStateMode = Cursor.INPUT_STATE_SYNC_WITH_SCORE
                cur.staffIdx = s
                cur.voice = v
                try { cur.rewind(0) } catch (e) { continue }

                var guard = 0
                while (cur.segment && guard < 20000) {
                    guard++
                    var seg = cur.segment
                    if (seg.annotations) {
                        for (var i = 0; i < seg.annotations.length; i++) addIfMatch(seg.annotations[i])
                    }
                    if (seg.elements) {
                        for (var j = 0; j < seg.elements.length; j++) addIfMatch(seg.elements[j])
                    }
                    cur.next()
                }
            }
        }

        if (toRemove.length === 0) {
            console.log("[GuqinTool] 没有找到可删除的古琴标记")
            editInput.text = ""
            lastReadTick = -1
            return
        }

        curScore.startCmd()
        for (var k = 0; k < toRemove.length; k++) {
            if (!_removeElementSafe(toRemove[k])) {
                try { toRemove[k].text = "" } catch (e) {}
            }
        }
        curScore.endCmd()
        relayout()

        editInput.text = ""
        lastReadTick = -1
        console.log("[GuqinTool] 已删除 " + toRemove.length + " 个古琴标记")
    }

    // 根级自适应背景色
    Rectangle {
        anchors.fill: parent
        color: sysPalette.window

        Column {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
            spacing: 10

            Text {
                text: tr.title
                font.pixelSize: 16
                color: sysPalette.windowText // 自动反白/黑
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // 第一排：读取、输入框、修改、删除（总宽360，左右对齐）
            Row {
                width: 360
                spacing: 6
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 60; height: 34
                    color: readMouse.containsMouse ? "#add8e6" : "#e0e0e0"
                    border.color: "gray"; radius: 4
                    Text { anchors.centerIn: parent; text: tr.read; font.pixelSize: 15; color: "black" }
                    MouseArea { id: readMouse; anchors.fill: parent; hoverEnabled: true; onClicked: readCurrentText() }
                }

                Rectangle {
                    width: 182; height: 34
                    border.color: sysPalette.mid; color: sysPalette.base
                    TextInput {
                        id: editInput
                        anchors.fill: parent; anchors.margins: 5
                        font.pixelSize: 16; selectByMouse: true; clip: true
                        color: sysPalette.text // 自适应文字色
                        verticalAlignment: TextInput.AlignVCenter
                    }
                }

                Rectangle {
                    width: 50; height: 34
                    color: applyMouse.containsMouse ? "#90ee90" : "#e0e0e0"
                    border.color: "gray"; radius: 4
                    Text { anchors.centerIn: parent; text: tr.apply; font.pixelSize: 15; color: "black" }
                    MouseArea { id: applyMouse; anchors.fill: parent; hoverEnabled: true; onClicked: applyCurrentText() }
                }

                Rectangle {
                    width: 50; height: 34
                    color: delMouse.containsMouse ? "#f4a460" : "#e0e0e0"
                    border.color: "gray"; radius: 4
                    Text { anchors.centerIn: parent; text: tr.delete; font.pixelSize: 15; color: "black" }
                    MouseArea { id: delMouse; anchors.fill: parent; hoverEnabled: true; onClicked: deleteCurrentText() }
                }
            }

            Text {
                text: tr.hint
                color: sysPalette.windowText
                opacity: 0.6 // 自适应半透明
                font.pixelSize: 13
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // 第三排：一键删除全部按钮（宽360，左右对齐）
            Rectangle {
                width: 360; height: 34
                color: delAllMouse.containsMouse ? "#ffaaaa" : "#e0e0e0" 
                border.color: "gray"; border.width: 1
                radius: 4
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text: tr.deleteAll
                    font.pixelSize: 15
                    color: "#803030"
                }

                MouseArea {
                    id: delAllMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: deleteAllGuqinMarks()
                }
            }

            // 第四排：常用标记、搜索、清空、数量（总宽360，左右对齐）
            Row {
                width: 360
                spacing: 6
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 65; height: 34
                    color: "#d0d0d0"
                    border.color: "#999"
                    radius: 4
                    Text {
                        anchors.centerIn: parent
                        text: tr.commonMarks
                        font.pixelSize: 14
                        color: "black" // 黑色字体
                    }
                }

                Rectangle {
                    width: 177; height: 34
                    border.color: sysPalette.mid; color: sysPalette.base; radius: 4
                    TextInput {
                        id: searchInput
                        anchors.fill: parent; anchors.margins: 5
                        font.pixelSize: 14; selectByMouse: true; clip: true
                        color: sysPalette.text
                        verticalAlignment: TextInput.AlignVCenter
                        onTextChanged: filterItems()
                        onAccepted: {
                            if (filteredItems.length > 0)
                                insertText(codeOfItem(filteredItems[0]))
                        }
                    }
                    Text {
                        anchors.fill: parent; anchors.leftMargin: 5
                        verticalAlignment: Text.AlignVCenter
                        text: tr.search; color: sysPalette.windowText; opacity: 0.5; font.pixelSize: 14
                        visible: searchInput.text.length === 0
                    }
                }

                Rectangle {
                    width: 45; height: 34
                    color: clrMouse.containsMouse ? "#f0c0c0" : "#e0e0e0"
                    border.color: "gray"; radius: 4
                    Text { anchors.centerIn: parent; text: tr.clear; font.pixelSize: 14; color: "black" }
                    MouseArea { id: clrMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { searchInput.text = ""; filterItems() } }
                }

                Text {
                    width: 55; height: 34
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: filteredItems.length + " " + tr.count
                    color: sysPalette.windowText; opacity: 0.6; font.pixelSize: 13
                }
            }

            // 第五排：列表
            Rectangle {
                width: 360; height: 440
                border.color: sysPalette.mid; border.width: 1; clip: true
                color: sysPalette.base // 自适应深/浅底色
                anchors.horizontalCenter: parent.horizontalCenter

                ListView {
                    anchors.fill: parent
                    topMargin: 15; bottomMargin: 15
                    model: filteredItems

                    delegate: Rectangle {
                        width: 360; height: 34
                        color: mouseArea.containsMouse ? "#55add8e6" : "transparent" // 半透明，深浅皆可见
                        Text { 
                            anchors.centerIn: parent; 
                            text: modelData; 
                            font.pixelSize: 15
                            color: sysPalette.text // 自适应文字颜色
                        }
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent; hoverEnabled: true
                            onClicked: insertText(codeOfItem(modelData))
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: tr.noresult; color: sysPalette.windowText; opacity: 0.5; font.pixelSize: 15
                    visible: filteredItems.length === 0
                }
            }
        }
    }

    Component.onCompleted: filterItems()

    onRun: {
        var now = new Date().getTime()
        var lastActive = pluginSettings.lastHeartbeat
        if (now - lastActive < 1500) {
            Qt.quit(); return
        }
        pluginSettings.lastHeartbeat = now
    }
}