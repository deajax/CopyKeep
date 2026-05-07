import SwiftUI

// MARK: - 全局中文字符串

enum Strings {
    // MARK: 菜单栏
    static let menuShowCopyKeep = "显示 CopyKeep"
    static let menuSettings = "设置..."
    static let menuClearHistory = "清除历史记录"
    static let menuQuit = "退出"

    // MARK: 搜索框
    static let searchPlaceholder = "搜索剪贴板历史..."

    // MARK: 类型筛选
    static let filterAll = "全部"
    static let filterText = "文本"
    static let filterLink = "链接"
    static let filterImage = "图片"
    static let filterFile = "文件"

    // MARK: 空状态
    static let emptyTitle = "暂无剪贴板历史"
    static let emptyHint = "复制文字 (Cmd+C) 后会出现在这里"

    // MARK: 时间
    static let yesterday = "昨天"

    // MARK: 设置 - 通用
    static let settingsGeneral = "通用"
    static let settingsStartup = "启动"
    static let settingsLaunchAtLogin = "登录时自动启动"
    static let settingsShortcut = "快捷键"
    static let settingsGlobalShortcut = "全局快捷键:"

    // MARK: 设置 - 历史记录
    static let settingsHistory = "历史记录"
    static let settingsMaxItems = "最大条数"
    static let settingsMaxItemsUnit = "条"
    static let settingsClearAll = "清除全部历史"
    static let settingsClearConfirm = "确定清除所有剪贴板历史？"
    static let settingsClearCancel = "取消"
    static let settingsClearConfirmButton = "清除"
    static let settingsClearUndone = "此操作不可撤销。"

    // (moved up)

    // MARK: 设置 - 粘贴模式
    static let settingsPasteMode = "粘贴模式"
    static let settingsMode = "模式"
    static let pasteModeSmart = "智能插入"
    static let pasteModeSmartDesc = "直接在光标处插入文字，不影响剪贴板"
    static let pasteModeClipboard = "剪贴板粘贴"
    static let pasteModeClipboardDesc = "写入剪贴板并模拟 Cmd+V（会覆盖剪贴板）"
    static let settingsAccessibility = "辅助功能权限"
    static let settingsAccessibilityGranted = "状态：已授权"
    static let settingsAccessibilityDenied = "状态：未授权"
    static let settingsOpenAccessibility = "打开系统权限页"
    static let settingsRecheckAccessibility = "重新检测"
    static let settingsAccessibilityHint = "如果已经勾选但仍显示未授权，请删除系统权限列表中的旧 CopyKeep，再重新添加当前运行的这个 App。GitHub 下载的无证书版本在更新后也可能需要重新授权。"
    static let settingsAccessibilityInstallHint = "建议将 CopyKeep 放到“应用程序”文件夹后再授权，避免路径变化导致权限失效。"
    static let settingsCurrentBundlePath = "当前 App 路径"
    static let settingsCurrentExecutablePath = "当前可执行文件"

    // MARK: 插入失败提示
    static let insertErrorActionOK = "知道了"
    static let insertErrorNoPermissionTitle = "无法插入内容"
    static let insertErrorNoPermissionMessage = "CopyKeep 缺少“辅助功能”权限。请在“系统设置 -> 隐私与安全性 -> 辅助功能”中允许当前这个 CopyKeep。如果已经勾选仍失败，请删除旧条目后重新添加。"
    static let insertErrorCurrentAppPath = "当前 App 路径"
    static let insertErrorSecureInputTitle = "当前输入框不允许注入"
    static let insertErrorSecureInputMessage = "系统开启了安全输入（常见于密码框或终端安全输入模式），macOS 会阻止自动键盘事件。请切换到普通输入框后再试。"
    static let insertErrorInjectionTitle = "插入失败"
    static let insertErrorInjectionMessage = "无法创建键盘事件，请重试。若问题持续，请重启 CopyKeep。"
    static let insertErrorPasteboardTitle = "写入剪贴板失败"
    static let insertErrorPasteboardMessage = "无法临时写入系统剪贴板，请稍后重试。"

    // MARK: 设置 - 更新
    static let settingsUpdates = "更新"
    static let settingsCheckUpdates = "检查更新..."

    // MARK: 设置 - 关于
    static let settingsAbout = "关于"
    static let settingsVersion = "版本"
    static let settingsBuild = "构建"

    // MARK: 面板底部提示
    static let footerCopyHint = "确认覆盖剪贴板"
    static let footerCloseHint = "关闭面板"

    // MARK: 设置 - 标题
    static let settingsTitle = "CopyKeep 设置"
}
