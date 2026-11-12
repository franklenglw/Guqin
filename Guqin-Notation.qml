import QtQuick 2.9
import Qt.labs.settings 1.0
import MuseScore 3.0

// ================================================================
//  古琴减字谱编辑器 (Guqin Jianzipu Editor)
//  ----------------------------------------------------------------
//  版本: 5.26.1119 (主版本号.次版本号.修订号)
//  修改记录:
//    - 新增 normalizeCode 代码自动纠错函数
//    - 解决手敲 \li-5-4 或 -s-7-6 导致数字重叠的 BUG
// ================================================================

MuseScore {
    id: guqinNotation
    pluginType: "dock"
    version: "5.26.1119"

    // ==== 多语言配置 ====
    property var translations: {
        "zh": {
            "pname": "古琴减字谱",
            "desc": "基于 ShanZiJianZiPu 字体（多标记版，带搜索）",
            "title": "古琴减字谱编辑器",
            "read": "读取",
            "apply": "修改",
            "delete": "删除",
            "deleteAll": "一键删除全部标记",
            "switchFont": "一键切换字体",
            "hint": "点音符 -> 点读取 -> 改代码/汉字（用分号隔开）-> 点修改",
            "commonMarks": "常用标记",
            "search": "搜索中文 / 代码",
            "clear": "清空",
            "count": "条",
            "noresult": "无匹配结果",
            "unrecognized": "未识别"
        },
        "zh_TW": {
            "pname": "古琴減字譜",
            "desc": "基於 ShanZiJianZiPu 字體（多標記版，帶搜索）",
            "title": "古琴減字譜編輯器",
            "read": "讀取",
            "apply": "修改",
            "delete": "刪除",
            "deleteAll": "一鍵刪除全部標記",
            "switchFont": "一鍵切換字體",
            "hint": "點音符 -> 點讀取 -> 改代碼/漢字（用分號隔開）-> 點修改",
            "commonMarks": "常用標記",
            "search": "搜索中文 / 代碼",
            "clear": "清空",
            "count": "條",
            "noresult": "無匹配結果",
            "unrecognized": "未識別"
        },
        "en": {
            "pname": "Guqin Notation",
            "desc": "Based on ShanZiJianZiPu Font (Multi-mark, with search)",
            "title": "Guqin JianZiPu Editor",
            "read": "Read",
            "apply": "Apply",
            "delete": "Delete",
            "deleteAll": "Delete All Marks",
            "switchFont": "Switch Font",
            "hint": "Click note -> Read -> Edit code/Chinese (separate with ;) -> Apply",
            "commonMarks": "Common",
            "search": "Search",
            "clear": "Clear",
            "count": "items",
            "noresult": "No matches found",
            "unrecognized": "Unrecognized"
        },
        "ja": {
            "pname": "古琴減字譜",
            "desc": "ShanZiJianZiPu フォントに基づく（マルチマーク版、検索付き）",
            "title": "古琴減字譜エディタ",
            "read": "読み取り",
            "apply": "適用",
            "delete": "削除",
            "deleteAll": "すべて削除",
            "switchFont": "フォント切替",
            "hint": "音符をクリック -> 読み取り -> コード/漢字を編集（; で区切る） -> 適用",
            "commonMarks": "よく使う",
            "search": "検索",
            "clear": "クリア",
            "count": "件",
            "noresult": "一致する結果がありません",
            "unrecognized": "認識できない"
        },
        "ko": {
            "pname": "고금 감자보",
            "desc": "ShanZiJianZiPu 폰트 기반 (다중 마크 버전, 검색 포함)",
            "title": "고금 감자보 편집기",
            "read": "읽기",
            "apply": "적용",
            "delete": "삭제",
            "deleteAll": "모두 삭제",
            "switchFont": "폰트 전환",
            "hint": "음표 클릭 -> 읽기 -> 코드/한자 편집 (; 로 구분) -> 적용",
            "commonMarks": "자주 쓰는",
            "search": "검색",
            "clear": "지우기",
            "count": "개",
            "noresult": "일치하는 결과가 없습니다",
            "unrecognized": "인식 불가"
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
    description: tr.desc

    implicitWidth: 380
    implicitHeight: 750

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    // ==== 字体核心设置 ====
    property string markFont: "ShanZiJianZiPu"          
    property string legacyMarkFont: "Noto Qin Jianzipu" 
    property int    markFontSize: 12
    property real   markLineSpacing: 1.2
    property real   markOffsetY: 3.5 
    
    property string nextSwitchTarget: "Noto Qin Jianzipu"

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

    property var allItems: generateAllItems()
    property var filteredItems: []
    property string statusMessage: ""

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
        
        // ================= 历与散如一的新增示例 =================
        items.push("名九历五四 ｜ \\li-z5-4/mi^9")
        items.push("名七历三、四弦 ｜ \\li-z3-4/mi^7")
        items.push("大九历五、六弦 ｜ \\li-z5-6/da^9")
        items.push("食七历一、二弦 ｜ \\li-z1-2/sh^7")
        items.push("中九历四、五弦 ｜ \\li-z4-5/zh^9")
        items.push("名十历六、七弦 ｜ \\li-z6-7/mi^10")
        items.push("大七历二、三弦 ｜ \\li-z2-3/da^7")
        items.push("散如一中间数字三 ｜ \\sr1-z3")
        // ========================================================

        // ================= 综合示例 =================
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
        items.push("名外勾五 ｜ \\5g/mi/wai")
        items.push("就勾五 ｜ \\5g/jiu")

        items.push("名七六 (7.6徽) ｜ \\g/mi/7^6")
        items.push("名七，六 (七徽六弦) ｜ \\6g/mi^7")
        items.push("名七六六 (7.6徽六弦) ｜ \\6g/mi/7^6")
        items.push("名十一 (10.1徽) ｜ \\g/mi/10^1")

        items.push("大九六|散三 (撮) ｜ \\6g/da^9||\\3g/s")
        items.push("大九六|散三 (反撮) ｜ \\6g/da^9|f\\3g/s")

        // ================= 扩展常用组合 =================
        items.push("大七勾一 ｜ \\1g/da^7")
        items.push("大七挑二 ｜ \\2t/da^7")
        items.push("大七抹三 ｜ \\3m/da^7")
        items.push("大七托四 ｜ \\4u/da^7")
        items.push("大七剔五 ｜ \\5i/da^7")
        items.push("大七打六 ｜ \\6d/da^7")
        items.push("大七摘七 ｜ \\7z/da^7")
        items.push("大九勾五 ｜ \\5g/da^9")
        items.push("大九抹四 ｜ \\4m/da^9")
        items.push("大九托六 ｜ \\6u/da^9")
        items.push("大十徽八分挑七 ｜ \\7t/da/10^8")
        items.push("大七徽九分抹二 ｜ \\2m/da/7^9")
        items.push("大十徽三分托六 ｜ \\6u/da/10^3")
        items.push("大九勾四(下徽) ｜ \\4g/da/9")
        items.push("大十挑六(下徽) ｜ \\6t/da/10")

        items.push("名七勾一 ｜ \\1g/mi^7")
        items.push("名七挑二 ｜ \\2t/mi^7")
        items.push("名七抹三 ｜ \\3m/mi^7")
        items.push("名七托四 ｜ \\4u/mi^7")
        items.push("名七剔五 ｜ \\5i/mi^7")
        items.push("名七打六 ｜ \\6d/mi^7")
        items.push("名七摘七 ｜ \\7z/mi^7")
        items.push("名九勾三 ｜ \\3g/mi^9")
        items.push("名九挑五 ｜ \\5t/mi^9")
        items.push("名九抹六 ｜ \\6m/mi^9")
        items.push("名十徽八分勾七 ｜ \\7g/mi/10^8")
        items.push("名七徽六分挑一 ｜ \\1t/mi/7^6")
        items.push("名九勾四(下徽) ｜ \\4g/mi/9")
        items.push("名十挑五(下徽) ｜ \\5t/mi/10")

        items.push("食七勾一 ｜ \\1g/sh^7")
        items.push("食七挑二 ｜ \\2t/sh^7")
        items.push("食七抹三 ｜ \\3m/sh^7")
        items.push("食七托四 ｜ \\4u/sh^7")
        items.push("食七剔五 ｜ \\5i/sh^7")
        items.push("食七打六 ｜ \\6d/sh^7")
        items.push("食七摘七 ｜ \\7z/sh^7")
        items.push("中七勾一 ｜ \\1g/zh^7")
        items.push("中七挑二 ｜ \\2t/zh^7")
        items.push("中七抹三 ｜ \\3m/zh^7")
        items.push("中七托四 ｜ \\4u/zh^7")
        items.push("中七剔五 ｜ \\5i/zh^7")
        items.push("中七打六 ｜ \\6d/zh^7")
        items.push("中七摘七 ｜ \\7z/zh^7")

        items.push("泛音大七勾一 ｜ \\1g/da^7/fa")
        items.push("泛音大九挑二 ｜ \\2t/da^9/fa")
        items.push("泛音名七抹三 ｜ \\3m/mi^7/fa")
        items.push("泛音名十勾四 ｜ \\4g/mi^10/fa")
        items.push("泛音食七挑五 ｜ \\5t/sh^7/fa")
        items.push("泛音食九勾六 ｜ \\6g/sh^9/fa")
        items.push("泛音中七抹七 ｜ \\7m/zh^7/fa")
        items.push("泛音大十勾一 ｜ \\1g/da^10/fa")
        items.push("泛音名九挑二 ｜ \\2t/mi^9/fa")
        items.push("泛音食十抹三 ｜ \\3m/sh^10/fa")

        items.push("大九勾五上 ｜ \\5g/da^9-s")
        items.push("大七挑六下 ｜ \\6t/da^7-x")
        items.push("名十抹四下 ｜ \\4m/mi^10-x")
        items.push("名九挑五上 ｜ \\5t/mi^9-s")
        items.push("大九绰挑七 ｜ \\7t/da^9/ch")
        items.push("名十注勾五 ｜ \\5g/mi^10/zhu")
        items.push("大七上挑三 ｜ \\3t/da^7-s")
        items.push("大七下勾四 ｜ \\4g/da^7-x")
        items.push("名九上抹五 ｜ \\5m/mi^9-s")
        items.push("名九下挑六 ｜ \\6t/mi^9-x")
        items.push("中七上勾二 ｜ \\2g/zh^7-s")
        items.push("中七下挑三 ｜ \\3t/zh^7-x")
        items.push("食七上抹四 ｜ \\4m/sh^7-s")
        items.push("食七下挑五 ｜ \\5t/sh^7-x")
        items.push("名十绰勾六 ｜ \\6g/mi^10/ch")

        items.push("撮(大七勾一|名九挑三) ｜ \\1g/da^7||\\3t/mi^9")
        items.push("撮(大九挑二|散勾六) ｜ \\2t/da^9||\\6g/s")
        items.push("撮(名七勾三|中九挑五) ｜ \\3g/mi^7||\\5t/zh^9")
        items.push("撮(食七挑四|大九勾六) ｜ \\4t/sh^7||\\6g/da^9")
        items.push("反撮(大七勾一|名九挑三) ｜ \\1g/da^7|f\\3t/mi^9")
        items.push("反撮(大九挑二|散勾六) ｜ \\2t/da^9|f\\6g/s")

        return items
    }

    // 全角标点/字母/数字 → 半角
    function toHalfWidth(s) {
        if (!s) return "";
        return s
            .replace(/[\uFF01-\uFF5E]/g, function(c) {
                return String.fromCharCode(c.charCodeAt(0) - 0xFEE0);
            })
            .replace(/\u3000/g, " ")
            .replace(/、/g, ",")
            .replace(/。/g, ".")
            .replace(/[“”]/g, '"')
            .replace(/[‘’]/g, "'");
    }

    // 只保留字体语法需要的字符
    function sanitizeCode(s) {
        if (!s) return "";
        return s.replace(/[^0-9A-Za-z\\\/\-\^\|]/g, "");
    }

    // ============================================================
    // 代码自动纠错函数：防呆设计
    // ============================================================
    function normalizeCode(code) {
        if (!code) return code;
        
        // 1. 修复 \li-5 为 \li-z5
        code = code.replace(/\\li-(\d)/g, "\\li-z$1");
        // 2. 修复 \sr1-3 为 \sr1-z3
        code = code.replace(/\\sr1-(\d)/g, "\\sr1-z$1");
        // 3. 修复走音 \g-s-7 为 \g-s-z7，\g-x-3 为 \g-x-z3
        code = code.replace(/-([sx])-(\d)/g, "-$1-z$2");
        
        // 4. 修复多余的 z (如 -z3-z4 -> -z3-4，-z3-z4-z5 -> -z3-4-5)
        code = code.replace(/-z(\d+)-z(\d+)/g, "-z$1-$2");
        code = code.replace(/-z(\d+)-z(\d+)-z(\d+)/g, "-z$1-$2-$3");
        
        return code;
    }

    function codeOfItem(s) {
        var parts = s.split("｜")
        return parts.length > 1 ? parts[1].trim() : parts[0].trim()
    }

    // ============================================================
    // 代码 → 中文 智能反推（三级优先：字典 → 智能反推 → 原代码）
    // ============================================================
    function codeToChinese(code) {
        if (!code) return "";
        if (code.indexOf("\\") === -1 && code.indexOf("/") === -1) return code;

        // 1. 字典优先（保留 282 条简洁表达）
        for (var i = 0; i < allItems.length; i++) {
            var parts = allItems[i].split("｜");
            if (parts.length > 1 && toHalfWidth(parts[1].trim()) === toHalfWidth(code)) {
                return parts[0].trim();
            }
        }

        // 2. 智能反推
        var smart = codeToChineseSmart(code);
        if (smart && smart.indexOf("\\") < 0) return smart;

        // 3. 兜底：原代码
        return code;
    }

    // 数字 → 中文（1~99 安全转换）
    function _cnNum(n) {
        var m = ["零","一","二","三","四","五","六","七","八","九"];
        if (n <= 0) return "";
        if (n <= 9) return m[n];
        if (n === 10) return "十";
        if (n < 20) return "十" + m[n - 10];
        return String(n);
    }

    // 代码 → 中文（智能反推，失败返回 ""）
    function codeToChineseSmart(code) {
        if (!code) return "";
        var s = toHalfWidth(code.trim());

        // 撮 / 反撮：递归拆分
        if (s.indexOf("||") >= 0) {
            var ps = s.split("||");
            if (ps.length === 2) {
                var a = codeToChineseSmart(ps[0]);
                var b = codeToChineseSmart(ps[1]);
                if (a && b && a.indexOf("\\") < 0 && b.indexOf("\\") < 0)
                    return "撮(" + a + "|" + b + ")";
            }
            return "";
        }
        if (s.indexOf("|f") >= 0) {
            var ps2 = s.split("|f");
            if (ps2.length === 2) {
                var a2 = codeToChineseSmart(ps2[0]);
                var b2 = codeToChineseSmart(ps2[1]);
                if (a2 && b2 && a2.indexOf("\\") < 0 && b2.indexOf("\\") < 0)
                    return "反撮(" + a2 + "|" + b2 + ")";
            }
            return "";
        }

        if (s.charAt(0) !== "\\") return "";

        // 完全支持的独立符号（不跟后续参数）
        var hardSpecials = ["fan","fanz","jin","tui","fu","zhu","yin","nao",
                            "tan","tuo","dou","qia","dai","tc3s"];
        for (var k = 0; k < hardSpecials.length; k++) {
            if (s.substring(1, 1 + hardSpecials[k].length) === hardSpecials[k]) return "";
        }

        var isLi = false;
        var isSr1 = false;
        var startIdx = 1;
        if (s.substring(1, 3) === "li") { isLi = true; startIdx = 3; }
        else if (s.substring(1, 4) === "sr1") { isSr1 = true; startIdx = 4; }

        var strNum = 0, rhand = "", lhand = "";
        var huiNum = 0, fenNum = 0;
        var isShangHui = false, isXiaHui = false;
        var fan = false, san = false, jiu = false, ch = false, zhu = false;
        var half = false, wai = false;
        var walks = [];
        var midNum = 0, lowNum = 0;
        var liNums = []; // 存放历的弦序列或散如一中间数字

        var i = startIdx, len = s.length;

        // 如果是普通情况，解析弦号和右手
        if (!isLi && !isSr1) {
            if (i < len && s.charAt(i) >= "1" && s.charAt(i) <= "7") {
                strNum = parseInt(s.charAt(i), 10);
                i++;
            }
            var rhandMap = {
                "g":"勾","t":"挑","m":"抹","u":"托",
                "b":"擘","i":"剔","d":"打","z":"摘",
                "mt":"抹挑","mg":"抹勾","gi":"勾剔"
            };
            if (i + 1 < len && rhandMap[s.substring(i, i + 2)]) {
                rhand = rhandMap[s.substring(i, i + 2)];
                i += 2;
            } else if (i < len && rhandMap[s.charAt(i)]) {
                rhand = rhandMap[s.charAt(i)];
                i++;
            }
        }

        while (i < len) {
            var ch1 = s.charAt(i);
            if (ch1 === "/") {
                i++;
                var st = i;
                while (i < len && /[a-z0-9]/i.test(s.charAt(i))) i++;
                var token = s.substring(st, i);
                if (!token) return "";
                if (token === "da") lhand = "大";
                else if (token === "sh") lhand = "食";
                else if (token === "zh") lhand = "中";
                else if (token === "mi") lhand = "名";
                else if (token === "s") san = true;
                else if (token === "fa") fan = true;
                else if (token === "jiu") jiu = true;
                else if (token === "ch") ch = true;
                else if (token === "zhu") zhu = true;
                else if (token === "b") half = true;
                else if (token === "wai") wai = true;
                else if (/^\d+$/.test(token)) {
                    var n = parseInt(token, 10);
                    if (n < 1 || n > 13) return "";
                    huiNum = n;
                    isXiaHui = !(i < len && s.charAt(i) === "^");
                } else return "";
            } else if (ch1 === "^") {
                i++;
                var st2 = i;
                while (i < len && /\d/.test(s.charAt(i))) i++;
                var token2 = s.substring(st2, i);
                if (!/^\d+$/.test(token2)) return "";
                var n2 = parseInt(token2, 10);
                if (n2 < 1 || n2 > 13) return "";
                if (huiNum > 0 && fenNum === 0) fenNum = n2;
                else { huiNum = n2; isShangHui = true; }
            } else if (ch1 === "-") {
                i++;
                var st3 = i;
                while (i < len && /[a-z0-9]/i.test(s.charAt(i))) i++;
                var token3 = s.substring(st3, i);
                if (!token3) return "";
                
                if (isLi || isSr1) {
                    if (token3.charAt(0) === "z" && /^\d+$/.test(token3.substring(1))) {
                        liNums.push(parseInt(token3.substring(1), 10));
                    } else if (/^\d+$/.test(token3)) {
                        liNums.push(parseInt(token3, 10));
                    } else {
                        return "";
                    }
                } else {
                    if (token3 === "s") walks.push("上");
                    else if (token3 === "x") walks.push("下");
                    else if (token3 === "b") half = true;
                    else if (token3 === "w") wai = true;
                    else if (token3.charAt(0) === "z" && /^\d+$/.test(token3.substring(1))) {
                        midNum = parseInt(token3.substring(1), 10);
                        if (midNum < 1 || midNum > 13) return "";
                    } else if (/^\d+$/.test(token3)) {
                        lowNum = parseInt(token3, 10);
                        if (lowNum < 1 || lowNum > 9) return "";
                    } else return "";
                }
            } else return "";
        }

        // 专门针对「历」与「散如一」的反推组装
        if (isLi || isSr1) {
            var result = "";
            var leftPart = "";
            
            if (lhand) leftPart += lhand;
            if (huiNum > 0) {
                if (isShangHui) leftPart += "上徽" + _cnNum(huiNum);
                else if (isXiaHui) leftPart += "下徽" + _cnNum(huiNum);
                else leftPart += _cnNum(huiNum) + "徽";
            }
            if (fenNum > 0) leftPart += _cnNum(fenNum) + "分";
            
            var seqPart = "";
            if (liNums.length > 0) {
                for (var ln = 0; ln < liNums.length; ln++) {
                    if (ln > 0) seqPart += "、";
                    seqPart += _cnNum(liNums[ln]);
                }
            }
            
            if (isLi) {
                if (leftPart) result = leftPart + "历" + seqPart;
                else result = "历" + seqPart;
            } else {
                result = "散如一";
                if (seqPart) result += seqPart;
            }
            return result;
        }

        if (midNum > 0) return (rhand || "勾") + "中间数字" + _cnNum(midNum);
        if (lowNum > 0) return (rhand || "勾") + "下面数字" + _cnNum(lowNum);

        var result = "";
        if (fan)  result += "泛音";
        if (san)  result += "散";
        if (jiu)  result += "就";
        if (lhand) result += lhand;
        if (huiNum > 0) {
            if (isShangHui)      result += "上徽" + _cnNum(huiNum);
            else if (isXiaHui)   result += "下徽" + _cnNum(huiNum);
            else                 result += _cnNum(huiNum) + "徽";
        }
        if (fenNum > 0) result += _cnNum(fenNum) + "分";
        if (rhand) result += rhand;
        if (strNum > 0) result += _cnNum(strNum);
        for (var w = 0; w < walks.length; w++) result += walks[w];
        if (ch)   result += "绰";
        if (zhu)  result += "注";
        if (half) result += "半";
        if (wai)  result += "外";

        if (!result) return "";
        return result;
    }

    // ====================== 中文 → 代码 解析器（合并版） ======================
    property var _cnDigits: ({
        "零":0,"〇":0,"一":1,"二":2,"两":2,"三":3,"四":4,
        "五":5,"六":6,"七":7,"八":8,"九":9,"十":10
    })

    function _readNumberAt(s, i) {
        var len = s.length
        if (i < 0 || i >= len) return { num: -1, end: i }
        var c = s.charAt(i)
        if (c >= "0" && c <= "9") {
            var j = i
            while (j < len && s.charAt(j) >= "0" && s.charAt(j) <= "9") j++
            return { num: parseInt(s.substring(i, j), 10), end: j }
        }
        if (c === "十" && i + 1 < len) {
            var d = _cnDigits[s.charAt(i + 1)]
            if (d !== undefined && d >= 1 && d <= 9) return { num: 10 + d, end: i + 2 }
            return { num: 10, end: i + 1 }
        }
        if (_cnDigits[c] !== undefined) return { num: _cnDigits[c], end: i + 1 }
        return { num: -1, end: i }
    }

    function parseCuoMark(s) {
        var isFan = /反撮/.test(s)
        var m = s.match(/[（(]([^）)]*)[）)]/)
        var inner = m ? m[1] : s.replace(/[（(]?反?撮[）)]?/g, "")
        inner = inner.replace(/\s+/g, "")

        var sep = -1
        for (var k = 0; k < inner.length; k++) {
            var ch = inner.charAt(k)
            if (ch === "|" || ch === "｜") { sep = k; break }
        }
        if (sep < 0) return ""

        var left = inner.substring(0, sep).trim()
        var right = inner.substring(sep + 1).trim()
        var p1 = parseChineseMark(left)
        var p2 = parseChineseMark(right)
        if (!p1 || !p2) return ""
        return isFan ? (p1 + "|f" + p2) : (p1 + "||" + p2)
    }

    function parseChineseMark(raw) {
        var s = String(raw || "").trim()
        if (!s) return ""
        if (s.indexOf("撮") >= 0) return parseCuoMark(s)

        var _noParen = s.replace(/[（(][^）)]*[）)]/g, "")
        var preferHyphenHalf = /半.*?横杠/.test(_noParen) || /半.*?横杠/.test(s)
        var preferHyphenWai  = /外.*?横杠/.test(_noParen) || /外.*?横杠/.test(s)

        var clean = s
            .replace(/[（(][^）)]*[）)]/g, "")
            .replace(/\s+/g, "")
            .replace(/\u3000/g, "")
        if (!clean) return ""

        var rhand = "", lhand = ""
        var strNum = 0, huiNum = 0, fenNum = 0, xiaMark = false
        var walks = []
        var fan = false, san = false, jiu = false, ch = false, zhu = false
        var half = false, wai = false
        var special = ""
        var liStrings = []
        var inLi = false
        var midNum = 0, lowNum = 0
        var bare = []

        var i = 0
        while (i < clean.length) {
            if (clean.substr(i, 4) === "中间数字") {
                var n1 = _readNumberAt(clean, i + 4)
                if (n1.num > 0) { 
                    if (inLi) liStrings.push(n1.num)
                    else midNum = n1.num
                    i = n1.end; continue 
                }
                i += 4; continue
            }
            if (clean.substr(i, 4) === "下面数字") {
                var n2 = _readNumberAt(clean, i + 4)
                if (n2.num > 0) { lowNum = n2.num; i = n2.end; continue }
                i += 4; continue
            }
            if (clean.substr(i, 4) === "掐撮三声") { special = "tc3s"; i += 4; continue }
            if (clean.substr(i, 3) === "散如一")   { special = "sr1";  i += 3; continue }
            if (clean.substr(i, 3) === "无名指")   { lhand = "mi";    i += 3; continue }
            
            var c2 = clean.substr(i, 2)
            if (c2 === "泛起") { special = "fan";  i += 2; continue }
            if (c2 === "泛止") { special = "fanz"; i += 2; continue }
            if (c2 === "带起") { special = "dai";  i += 2; continue }
            if (c2 === "掐起") { special = "qia";  i += 2; continue }
            if (c2 === "泛音") { fan = true;       i += 2; continue }
            if (c2 === "抹挑") { rhand = "mt";     i += 2; continue }
            if (c2 === "抹勾") { rhand = "mg";     i += 2; continue }
            if (c2 === "勾剔") { rhand = "gi";     i += 2; continue }
            if (c2 === "大指") { lhand = "da";     i += 2; continue }
            if (c2 === "食指") { lhand = "sh";     i += 2; continue }
            if (c2 === "中指") { lhand = "zh";     i += 2; continue }
            if (c2 === "上徽") {
                var mh1 = _readNumberAt(clean, i + 2)
                if (mh1.num > 0) { huiNum = mh1.num; i = mh1.end; continue }
                i += 2; continue
            }
            if (c2 === "下徽") {
                var mh2 = _readNumberAt(clean, i + 2)
                if (mh2.num > 0) { huiNum = mh2.num; xiaMark = true; i = mh2.end; continue }
                xiaMark = true; i += 2; continue
            }

            var nr = _readNumberAt(clean, i)
            if (nr.num > 0) {
                var after = clean.substring(nr.end)
                if (after.indexOf("徽") === 0) { huiNum = nr.num; i = nr.end + 1; continue }
                if (after.indexOf("弦") === 0) { strNum = nr.num; i = nr.end + 1; continue }
                if (after.indexOf("分") === 0) { fenNum = nr.num; i = nr.end + 1; continue }
                if (inLi) {
                    liStrings.push(nr.num)
                } else {
                    bare.push({ num: nr.num, seenRhand: !!rhand, seenLhand: !!lhand })
                }
                i = nr.end
                continue
            }

            switch (clean.charAt(i)) {
                case "勾": rhand = "g"; i++; continue
                case "挑": rhand = "t"; i++; continue
                case "抹": rhand = "m"; i++; continue
                case "托": rhand = "u"; i++; continue
                case "擘": case "劈": rhand = "b"; i++; continue
                case "剔": rhand = "i"; i++; continue
                case "打": rhand = "d"; i++; continue
                case "摘": rhand = "z"; i++; continue
                case "大": lhand = "da"; i++; continue
                case "食": lhand = "sh"; i++; continue
                case "中": lhand = "zh"; i++; continue
                case "名": lhand = "mi"; i++; continue
                case "散": san = true; i++; continue
                case "就": jiu = true; i++; continue
                case "绰": ch = true; i++; continue
                case "注": zhu = true; i++; continue
                case "半": half = true; i++; continue
                case "外": wai = true; i++; continue
                case "上": walks.push("s"); i++; continue
                case "下": walks.push("x"); i++; continue
                case "进": special = "jin"; i++; continue
                case "退": special = "tui"; i++; continue
                case "复": special = "fu"; i++; continue
                case "撞": special = "zhu"; i++; continue
                case "吟": special = "yin"; i++; continue
                case "猱": special = "nao"; i++; continue
                case "淌": special = "tan"; i++; continue
                case "拖": special = "tuo"; i++; continue
                case "逗": special = "dou"; i++; continue
                case "历": special = "li"; inLi = true; i++; continue
                case "，": case "、": case ",": case "。": case ".":
                case "·": case " ": case "急": case "慢": case "字":
                    i++; continue
                default: i++; continue
            }
        }

        for (var k = 0; k < bare.length; k++) {
            var b = bare[k]
            if (b.seenRhand) {
                if (strNum === 0) strNum = b.num
            } else if (b.seenLhand) {
                if (huiNum === 0) huiNum = b.num
                else if (fenNum === 0) fenNum = b.num
                else if (strNum === 0 && !inLi) strNum = b.num
            } else {
                if (strNum === 0 && !inLi) strNum = b.num
            }
        }

        if (special) {
            var codeS = "\\" + special
            if (special === "li" && liStrings.length > 0) {
                for (var L = 0; L < liStrings.length; L++) {
                    if (L === 0) {
                        codeS += "-z" + liStrings[L]
                    } else {
                        codeS += "-" + liStrings[L]
                    }
                }
            } else if (midNum > 0) {
                codeS += "-z" + midNum
            } else if (lowNum > 0) {
                codeS += "-" + lowNum
            }
            if (lhand) codeS += "/" + lhand
            if (huiNum > 0) {
                if (fenNum > 0) codeS += "/" + huiNum + "^" + fenNum
                else if (xiaMark) codeS += "/" + huiNum
                else codeS += "^" + huiNum
            }
            for (var W1 = 0; W1 < walks.length; W1++) codeS += "-" + walks[W1]
            if (fan) codeS += "/fa"
            if (san) codeS += "/s"
            return codeS
        }

        if (!rhand) {
            if (lhand && (huiNum > 0 || fenNum > 0)) rhand = "g"
            else if (huiNum > 0 && strNum > 0) rhand = "g"
        }

        if (midNum > 0) {
            var codeM = "\\"
            if (strNum > 0) codeM += strNum
            if (rhand) codeM += rhand
            if (!rhand && !strNum) codeM = "\\g"
            codeM += "-z" + midNum
            for (var W2 = 0; W2 < walks.length; W2++) codeM += "-" + walks[W2]
            return codeM
        }
        if (lowNum > 0) {
            var codeL = "\\"
            if (strNum > 0) codeL += strNum
            if (rhand) codeL += rhand
            if (!rhand && !strNum) codeL = "\\g"
            codeL += "-" + lowNum
            for (var W3 = 0; W3 < walks.length; W3++) codeL += "-" + walks[W3]
            return codeL
        }

        var code = "\\"
        if (strNum > 0) code += strNum
        if (rhand) code += rhand
        if (lhand) code += "/" + lhand
        if (huiNum > 0) {
            if (fenNum > 0) code += "/" + huiNum + "^" + fenNum
            else if (xiaMark) code += "/" + huiNum
            else code += "^" + huiNum
        }
        for (var W4 = 0; W4 < walks.length; W4++) code += "-" + walks[W4]
        if (fan)  code += "/fa"
        if (san)  code += "/s"
        if (jiu)  code += "/jiu"
        if (ch)   code += "/ch"
        if (zhu)  code += "/zhu"
        if (half) code += (preferHyphenHalf ? "-b" : "/b")
        if (wai)  code += (preferHyphenWai  ? "-w" : "/wai")

        return (code === "\\") ? "" : code
    }

    function resolveChineseName(cn) {
        var key = toHalfWidth(String(cn || "").trim())
        if (!key) return ""

        for (var i = 0; i < allItems.length; i++) {
            var item = allItems[i]
            var sep = item.indexOf("｜")
            if (sep < 0) continue
            var left = toHalfWidth(item.substring(0, sep).trim())
            var leftBase = left.replace(/[（(][^）)]*[）)]/g, "").trim()
            if (left === key || leftBase === key) return item.substring(sep + 1).trim()
        }
        for (var j = 0; j < allItems.length; j++) {
            var item2 = allItems[j]
            var sep2 = item2.indexOf("｜")
            if (sep2 < 0) continue
            var left2 = toHalfWidth(item2.substring(0, sep2).trim())
            if (left2.indexOf(key) === 0) {
                var rest = left2.substring(key.length)
                if (/^[\s(（]/.test(rest)) return item2.substring(sep2 + 1).trim()
            }
        }
        return parseChineseMark(key)
    }

    // ============================================================================

    function relayout() {
        try { if (curScore && curScore.layout) curScore.layout() } catch (e) {}
        try {
            if (typeof score !== "undefined" && score && score.layout)
                score.layout()
        } catch (e) {}
    }

    function getValidNoteLocation() {
        var cur = curScore.newCursor()
        cur.inputStateMode = Cursor.INPUT_STATE_SYNC_WITH_SCORE
        
        if (curScore.selection && curScore.selection.elements && curScore.selection.elements.length > 0) {
            var el = curScore.selection.elements[0]
            if (el.type === Element.NOTE || el.type === Element.CHORD) {
                return { valid: true, tick: cur.tick, track: cur.track }
            }
            return { valid: false }
        }
        
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
                    var raw = toHalfWidth(lines[j].replace(/[+]/g, "").trim())
                    if (raw !== "") {
                        codes.push(codeToChinese(raw))
                    }
                }
            }
            editInput.text = codes.join(multiSep + " ")
        } else {
            editInput.text = ""
        }
        statusMessage = ""
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

        var input = toHalfWidth(editInput.text.trim())
        if (input === "") return

        var parts = input.split(multiSep)
        var codesToSend = []
        var displayParts = []
        var unresolved = []

        for (var i = 0; i < parts.length; i++) {
            var c = parts[i].trim()
            if (c === "") continue

            var finalCode = ""
            if (c.indexOf("\\") !== -1 || c.indexOf("/") !== -1) {
                // 显式代码：清洗后，进行自动纠错
                finalCode = normalizeCode(sanitizeCode(c))
            } else {
                finalCode = sanitizeCode(resolveChineseName(c))
            }

            if (finalCode === "") {
                unresolved.push(c)
                continue
            }

            codesToSend.push(finalCode)
            displayParts.push(codeToChinese(finalCode))
        }

        if (unresolved.length > 0) {
            statusMessage = tr.unrecognized + ": " + unresolved.join(", ")
        } else {
            statusMessage = ""
        }

        if (codesToSend.length === 0) return

        var texts = getAllTextsAtTick(loc.tick, loc.track)
        var combinedText = codesToSend.join("\n")

        if (texts.length === 0) {
            insertTexts([combinedText], 0, loc.tick, loc.track)
            editInput.text = displayParts.join(multiSep + " ")
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

        editInput.text = displayParts.join(multiSep + " ")
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
        // 从列表点击插入时，也自动纠错一次
        textData = normalizeCode(sanitizeCode(toHalfWidth(textData)))
        if (textData === "") return

        var loc = getValidNoteLocation()
        if (!loc.valid) return

        var texts = getAllTextsAtTick(loc.tick, loc.track)
        var codes = []
        var displays = []
        for (var i = 0; i < texts.length; i++) {
            var rawText = texts[i].text.replace(/\r/g, "")
            var lines = rawText.split("\n")
            for (var j = 0; j < lines.length; j++) {
                var raw = toHalfWidth(lines[j].replace(/[+]/g, "").trim())
                if (raw !== "") {
                    codes.push(raw)
                    displays.push(codeToChinese(raw))
                }
            }
        }
        codes.push(textData)
        displays.push(codeToChinese(textData))
        
        editInput.text = displays.join(multiSep + " ")
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
        statusMessage = ""
    }

    // 同时兼容新老字体的识别
    function isGuqinMark(el) {
        if (!el) return false
        try { if (el.type !== Element.STAFF_TEXT) return false } catch (e) { return false }
        var f1 = el.fontFace ? String(el.fontFace).toLowerCase() : ""
        var f2 = el.fontFamily ? String(el.fontFamily).toLowerCase() : ""
        
        var t1 = markFont.toLowerCase()          // ShanZiJianZiPu
        var t2 = legacyMarkFont.toLowerCase()    // Noto Qin Jianzipu
        
        return (f1.indexOf(t1) >= 0 || f2.indexOf(t1) >= 0 ||
                f1.indexOf(t2) >= 0 || f2.indexOf(t2) >= 0)
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
        statusMessage = ""
        console.log("[GuqinNotation] 已删除 " + toRemove.length + " 个古琴标记，已清空选中状态")
    }

    // ==== 一键修改全谱字体（静默忽略版） ====
    function switchAllGuqinFonts() {
        if (!curScore) return

        var fontList = Qt.fontFamilies()
        var hasTargetFont = false
        for (var f = 0; f < fontList.length; f++) {
            if (fontList[f].toLowerCase() === nextSwitchTarget.toLowerCase()) {
                hasTargetFont = true
                break
            }
        }

        if (!hasTargetFont) return

        var toSwitch = []
        function addIfMatch(el) {
            if (!el) return
            if (!isGuqinMark(el)) return
            for (var z = 0; z < toSwitch.length; z++) {
                if (toSwitch[z] === el) return
            }
            toSwitch.push(el)
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

        if (toSwitch.length === 0) return

        curScore.startCmd()
        for (var k = 0; k < toSwitch.length; k++) {
            toSwitch[k].fontFace = nextSwitchTarget
            toSwitch[k].fontFamily = nextSwitchTarget
        }
        curScore.endCmd()
        relayout()
        
        if (nextSwitchTarget === "Noto Qin Jianzipu") {
            nextSwitchTarget = "ShanZiJianZiPu"
        } else {
            nextSwitchTarget = "Noto Qin Jianzipu"
        }
    }

    function filterItems() {
        var kw = toHalfWidth(searchInput.text.trim()).toLowerCase()
        if (kw === "") { filteredItems = allItems; return }
        var kws = kw.split(/\s+/)
        var res = []
        for (var i = 0; i < allItems.length; i++) {
            var s = toHalfWidth(allItems[i]).toLowerCase()
            var ok = true
            for (var j = 0; j < kws.length; j++) {
                if (s.indexOf(kws[j]) < 0) { ok = false; break }
            }
            if (ok) res.push(allItems[i])
        }
        filteredItems = res
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

            Text {
                id: statusText
                text: guqinNotation.statusMessage
                color: "#b04040"
                font.pixelSize: 12
                visible: text !== ""
                wrapMode: Text.WordWrap
                width: 360
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                width: 360
                spacing: 6
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 177; height: 34
                    color: switchMouse.containsMouse ? "#c0e0c0" : "#e0e0e0" 
                    border.color: "gray"; border.width: 1
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        text: tr.switchFont
                        font.pixelSize: 15
                        color: "#306030"
                    }

                    MouseArea {
                        id: switchMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: switchAllGuqinFonts()
                    }
                }

                Rectangle {
                    width: 177; height: 34
                    color: delAllMouse.containsMouse ? "#ffaaaa" : "#e0e0e0" 
                    border.color: "gray"; border.width: 1
                    radius: 4

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
            }

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