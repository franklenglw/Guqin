import QtQuick 2.9
import Qt.labs.settings 1.0
import MuseScore 3.0

MuseScore {
    id: guqinNotation
    pluginType: "dock"

    // ==== 多语言配置 ====
    property var translations: {
        "zh": {
            "pname": "古琴减字谱",
            "desc": "基于 Noto Qin Jianzipu 字体（多标记版，带搜索）",
            "title": "古琴减字谱编辑器V5.0：",
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
        "zh_TW": {
            "pname": "古琴減字譜",
            "desc": "基於 Noto Qin Jianzipu 字體（多標記版，帶搜索）",
            "title": "古琴減字譜編輯器V5.0：",
            "read": "讀取",
            "apply": "修改",
            "delete": "刪除",
            "deleteAll": "一鍵刪除全部古琴標記",
            "hint": "點音符 -> 點讀取 -> 改代碼（多個用 ; 分隔）-> 點修改",
            "commonMarks": "常用標記",
            "search": "搜索中文 / 代碼",
            "clear": "清空",
            "count": "條",
            "noresult": "無匹配結果"
        },
        "en": {
            "pname": "Guqin Notation",
            "desc": "Based on Noto Qin Jianzipu Font (Multi-mark, with search)",
            "title": "Guqin JianZiPu Editor V5.0:",
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
            "pname": "古琴減字譜",
            "desc": "Noto Qin Jianzipu フォントに基づく（マルチマーク版、検索付き）",
            "title": "古琴減字譜エディタ V5.0：",
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
            "pname": "고금 감자보",
            "desc": "Noto Qin Jianzipu 폰트 기반 (다중 마크 버전, 검색 포함)",
            "title": "고금 감자보 편집기 V5.0:",
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
        var loc = Qt.locale().name
        if (translations[loc] !== undefined) return loc
        var prefix = loc.substring(0, 2)
        return (translations[prefix] !== undefined) ? prefix : "en"
    }

    property var tr: translations[uiLang]

    property string pname: tr.pname
    menuPath: "Plugins." + pname
    version: "5.0"
    description: tr.desc

    implicitWidth: 380
    implicitHeight: 720

    // ==== 主题自适应调色板 ====
    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    // ==== 标记统一配置 ====
    property string markFont: "Noto Qin Jianzipu"
    property int    markFontSize: 12
    property real   markLineSpacing: 1.2
    property real   markOffsetY: 3.5 

    // ==== 防止重复打开的心跳机制 ====
    Settings {
        id: pluginSettings
        category: "guqinNotation"
        property double lastHeartbeat: 0
    }

    Timer {
        id: heartbeatTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: { pluginSettings.lastHeartbeat = new Date().getTime() }
    }

    property string multiSep: ";"

    // ==== 完整标记库 ====
    property var allItems: generateAllItems()
    property var filteredItems: []

    function generateAllItems() {
        var items = []
        
        // ================= 图1 =================
        var strings = ["一", "二", "三", "四", "五", "六", "七"]
        var digits = ["1", "2", "3", "4", "5", "6", "7"]
        for (var i = 0; i < 7; i++) {
            items.push(strings[i] + " ｜ \\" + digits[i])
        }

        var baseFingers = [
            { c: "g", n: "勾" }, { c: "t", n: "挑" }, { c: "m", n: "抹" }, { c: "u", n: "托" },
            { c: "b", n: "擘" }, { c: "i", n: "剔" }, { c: "d", n: "打" }, { c: "z", n: "摘" }
        ]
        for (var i = 0; i < baseFingers.length; i++) {
            items.push(baseFingers[i].n + " ｜ \\" + baseFingers[i].c)
        }

        var comboFingers = [
            { c: "g", n: "勾" }, { c: "t", n: "挑" }, { c: "m", n: "抹" }, { c: "u", n: "托" },
            { c: "b", n: "擘" }, { c: "i", n: "剔" }, { c: "d", n: "打" }, { c: "z", n: "摘" },
            { c: "mt", n: "抹挑" }, { c: "mg", n: "抹勾" }, { c: "gi", n: "勾剔" }
        ]
        for (var s = 0; s < 7; s++) {
            for (var f = 0; f < comboFingers.length; f++) {
                items.push(strings[s] + comboFingers[f].n + " ｜ \\" + digits[s] + comboFingers[f].c)
            }
        }

        // ================= 图2 =================
        items.push("撮(大字十徽四弦散七勾) ｜ \\4/da/10||\\7/s") 
        items.push("撮(勾一反撮挑二) ｜ \\1g||\\2t") 
        items.push("反撮(单独符号) ｜ \\|f")
        items.push("反撮(勾一反撮挑二) ｜ \\1g|f\\2t") 
        items.push("掐撮三声 ｜ \\tc3s")

        // ================= 图3 =================
        items.push("勾上 ｜ \\g-s")
        items.push("勾下 ｜ \\g-x")
        items.push("勾半(横杠) ｜ \\g-b")
        items.push("勾外(横杠) ｜ \\g-w")
        
        for (var i = 1; i <= 13; i++) {
            items.push("勾中间数字" + i + " ｜ \\g-z" + i)
        }
        for (var i = 1; i <= 9; i++) {
            items.push("勾下面数字" + i + " ｜ \\g-" + i)
        }
        
        items.push("上七六(组合) ｜ \\g-s-z7-6")
        items.push("下外(组合) ｜ \\g-x-w")

        // ================= 图4 =================
        items.push("勾散 ｜ \\g/s")
        items.push("勾就 ｜ \\g/jiu")
        items.push("勾泛音 ｜ \\g/fa")
        items.push("勾绰 ｜ \\g/ch")
        items.push("勾注 ｜ \\g/zhu")
        
        items.push("勾大指 ｜ \\g/da")
        items.push("勾食指 ｜ \\g/sh")
        items.push("勾中指 ｜ \\g/zh")
        items.push("勾无名指 ｜ \\g/mi")
        
        for (var i = 1; i <= 13; i++) {
            items.push("勾上徽" + i + " ｜ \\g^" + i)
        }
        for (var i = 1; i <= 13; i++) {
            items.push("勾下徽" + i + " ｜ \\g/" + i)
        }
        
        items.push("勾半(斜杠) ｜ \\g/b")
        items.push("勾外(斜杠) ｜ \\g/wai")

        // ================= 图5 =================
        items.push("泛起 ｜ \\fan")
        items.push("泛止 ｜ \\fanz")
        items.push("进 ｜ \\jin")
        items.push("退 ｜ \\tui")
        items.push("复 ｜ \\fu")
        items.push("撞 ｜ \\zhu")
        items.push("吟 ｜ \\yin")
        items.push("猱 ｜ \\nao")
        items.push("淌 ｜ \\tan")
        items.push("拖 ｜ \\tuo")
        items.push("逗 ｜ \\dou")
        items.push("掐起 ｜ \\qia")
        items.push("带起 ｜ \\dai")
        
        items.push("散如一 ｜ \\sr1")
        items.push("历 ｜ \\li")
        items.push("散如一中间数字组合 ｜ \\sr1-z3")
        items.push("历中间数字组合 ｜ \\li-z7-6")

        // ================= 新增：完整翻译示例 =================
        items.push("大指7徽6分勾7弦 ｜ \\7g/da/7^6")
        items.push("名九勾五 ｜ \\5g/mi^9")
        items.push("大九挑七 ｜ \\7t/da^9")
        items.push("大九抹挑七 ｜ \\7mt/da^9")
        items.push("泛音中九挑六 ｜ \\6t/zh^9/fa")
        items.push("泛音名九勾六 ｜ \\6g/mi^9/fa")
        items.push("散勾三 ｜ \\3g/s")
        items.push("名七半急勾五 ｜ \\5g/mi^7/b")
        
        items.push("名九劈五 ｜ \\5b/mi^9")
        items.push("名九托五 ｜ \\5u/mi^9")
        items.push("名九抹五 ｜ \\5m/mi^9")
        items.push("名九剔五 ｜ \\5i/mi^9")
        items.push("名九打五 ｜ \\5d/mi^9")
        items.push("名九摘五 ｜ \\5z/mi^9")
        items.push("名九历五四 ｜ \\li-5-4/mi^9")
        items.push("名外勾五 ｜ \\5g/mi/wai")
        items.push("就勾五 ｜ \\5g/jiu")

        items.push("名七六 (7.6徽) ｜ \\g/mi/7^6")
        items.push("名七，六 (七徽六弦) ｜ \\6g/mi^7")
        items.push("名七六六 (7.6徽六弦) ｜ \\6g/mi/7^6")
        items.push("名十一 (10.1徽) ｜ \\g/mi/10^1")

        items.push("大九六|散三 (撮) ｜ \\6g/da^9||\\3g/s")
        items.push("大九六|散三 (反撮) ｜ \\6g/da^9|f\\3g/s")

        return items
    }

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

    // ==== 终极修复：只认游标同步状态，放弃使用 el.tick ====
    function getValidNoteLocation() {
        var cur = curScore.newCursor()
        cur.inputStateMode = Cursor.INPUT_STATE_SYNC_WITH_SCORE
        
        if (curScore.selection && curScore.selection.elements && curScore.selection.elements.length > 0) {
            var el = curScore.selection.elements[0]
            // 只校验类型，不取 el.tick，直接用已同步的 cur.tick
            if (el.type === Element.NOTE || el.type === Element.CHORD) {
                return { valid: true, tick: cur.tick, track: cur.track }
            }
            return { valid: false }
        }
        
        // 没有高亮选中，看游标当前位置是不是音符
        if (cur.segment && cur.element) {
            if (cur.element.type === Element.NOTE || cur.element.type === Element.CHORD) {
                return { valid: true, tick: cur.tick, track: cur.track }
            }
        }
        
        return { valid: false }
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

    function readCurrentText() {
        var loc = getValidNoteLocation()
        if (!loc.valid) {
            editInput.text = ""
            return
        }
        
        var texts = getAllTextsAtTick(loc.tick, loc.track)
        if (texts.length > 0) {
            var codes = []
            for (var i = 0; i < texts.length; i++) {
                var rawText = texts[i].text.replace(/\r/g, "")
                var lines = rawText.split("\n")
                for (var j = 0; j < lines.length; j++) {
                    var raw = lines[j].replace(/[+]/g, "").trim()
                    if (raw !== "") codes.push(raw)
                }
            }
            editInput.text = codes.join(multiSep + " ")
        } else {
            editInput.text = ""
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
        var loc = getValidNoteLocation()
        if (!loc.valid) return

        var input = editInput.text.trim()
        if (input === "") return

        var parts = input.split(multiSep)
        var codes = []
        for (var i = 0; i < parts.length; i++) {
            var c = parts[i].trim()
            if (c !== "") codes.push(c)
        }
        if (codes.length === 0) return

        var texts = getAllTextsAtTick(loc.tick, loc.track)
        var combinedText = codes.join("\n")

        if (texts.length === 0) {
            insertTexts([combinedText], 0, loc.tick, loc.track)
            return
        }

        curScore.startCmd()
        var mainText = texts[0]
        mainText.text = combinedText
        mainText.fontFace = markFont
        mainText.fontFamily = markFont
        mainText.textLineSpacing = markLineSpacing
        mainText.fontSize = markFontSize
        mainText.placement = Placement.BELOW
        mainText.autoplace = true
        mainText.offsetX = 0
        mainText.offsetY = markOffsetY

        for (var d = 1; d < texts.length; d++) {
            if (!_removeElementSafe(texts[d])) texts[d].text = ""
        }
        curScore.endCmd()
        relayout()

        editInput.text = codes.join(multiSep + " ")
    }

    function insertTexts(codes, startIndex, tick, track) {
        if (!codes || codes.length === 0) return
        
        var cur = curScore.newCursor()
        cur.inputStateMode = Cursor.INPUT_STATE_SYNC_WITH_SCORE

        if (track !== undefined && track >= 0) {
            cur.staffIdx = Math.floor(track / 4)
            cur.voice = track % 4
        }

        try { cur.rewindToTick(tick) } catch (e) { return }
        if (!cur.segment) return

        var combinedText = codes.join("\n")

        curScore.startCmd()
        var staffText = newElement(Element.STAFF_TEXT)
        staffText.text = combinedText
        staffText.fontFace = markFont
        staffText.fontFamily = markFont
        staffText.textLineSpacing = markLineSpacing
        staffText.fontSize = markFontSize
        staffText.placement = Placement.BELOW
        staffText.autoplace = true
        staffText.offsetX = 0
        staffText.offsetY = markOffsetY
        cur.add(staffText)
        curScore.endCmd()
        relayout()
    }

    function insertText(textData, displayText) {
        var loc = getValidNoteLocation()
        if (!loc.valid) return

        var texts = getAllTextsAtTick(loc.tick, loc.track)
        var codes = []
        for (var i = 0; i < texts.length; i++) {
            var rawText = texts[i].text.replace(/\r/g, "")
            var lines = rawText.split("\n")
            for (var j = 0; j < lines.length; j++) {
                var raw = lines[j].replace(/[+]/g, "").trim()
                if (raw !== "") codes.push(raw)
            }
        }
        codes.push(textData) 
        editInput.text = codes.join(multiSep + " ")
        applyCurrentText()
    }

    function deleteCurrentText() {
        var loc = getValidNoteLocation()
        if (!loc.valid) return

        var texts = getAllTextsAtTick(loc.tick, loc.track)
        if (texts.length === 0) {
            editInput.text = ""
            return
        }
        curScore.startCmd()
        for (var i = 0; i < texts.length; i++) {
            if (!_removeElementSafe(texts[i])) texts[i].text = ""
        }
        curScore.endCmd()
        relayout()
        editInput.text = ""
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
            console.log("[GuqinNotation] 没有找到可删除的古琴标记")
            editInput.text = ""
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

        try {
            if (curScore.selection && typeof curScore.selection.clear === "function") {
                curScore.selection.clear();
            }
        } catch (e) {}
        
        editInput.text = ""
        console.log("[GuqinNotation] 已删除 " + toRemove.length + " 个古琴标记，已清空选中状态")
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
                color: sysPalette.windowText
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // 第一排：读取、输入框、修改、删除
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
                        color: sysPalette.text
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
                opacity: 0.6
                font.pixelSize: 13
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // 第三排：一键删除全部
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

            // 第四排：常用标记、搜索、清空、数量
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
                        color: "black"
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
                width: 360; 
                height: Math.max(100, guqinNotation.height - y - 15)
                border.color: sysPalette.mid; border.width: 1; clip: true
                color: sysPalette.base
                anchors.horizontalCenter: parent.horizontalCenter

                ListView {
                    id: listView
                    anchors.fill: parent
                    anchors.rightMargin: 10
                    topMargin: 15; bottomMargin: 15
                    model: filteredItems
                    clip: true

                    delegate: Rectangle {
                        width: listView.width; height: 34
                        color: mouseArea.containsMouse ? "#55add8e6" : "transparent"
                        Text { 
                            anchors.centerIn: parent; 
                            text: modelData; 
                            font.pixelSize: 15
                            color: sysPalette.text
                        }
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent; hoverEnabled: true
                            onClicked: insertText(codeOfItem(modelData))
                        }
                    }
                }

                // 自定义滚动条
                Rectangle {
                    width: 6
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    y: listView.topMargin + listView.visibleArea.yPosition * (listView.height - listView.topMargin - listView.bottomMargin)
                    height: listView.visibleArea.heightRatio * (listView.height - listView.topMargin - listView.bottomMargin)
                    color: sysPalette.text
                    opacity: 0.4
                    radius: 3
                    visible: listView.visibleArea.heightRatio < 1.0
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