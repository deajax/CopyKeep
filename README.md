# CopyKeep

macOS 剪贴板历史管理工具 — 常驻菜单栏，全局快捷键唤醒，纯本地运行。

## 功能

- **自动记录** — 监听剪贴板变化，自动保存复制历史
- **全局快捷键** — 默认 `⌘⇧V` 弹出历史面板（可在设置中自定义）
- **模糊搜索** — 面板内直接键入关键词实时过滤
- **类型筛选** — 按「全部 / 文本 / 链接」快速定位
- **纯文本模式** — 点击条目复制到剪贴板，手动 `⌘V` 粘贴
- **自动清理** — 支持设置历史记录上限（3-999 条）
- **开机启动** — 可在设置中开启
- **内置更新** — 通过 Sparkle 框架自动检查 GitHub 新版本

## 安装

从 [Releases](https://github.com/deajax/CopyKeep/releases) 下载最新版 DMG。

> 由于没有 Apple 开发者签名，首次启动需要：
> 1. 右键 → 打开（不要双击）
> 2. 在系统提示中点击「仍然打开」

## 系统要求

| 项目 | 要求 |
|------|------|
| macOS 版本 | 14.0 (Sonoma) 或更高 |
| 芯片 | Intel (x86_64) 和 Apple Silicon (arm64) 均可 |
| 架构支持 | Universal Binary，单个 DMG 通吃两种芯片 |

## 使用

| 操作 | 效果 |
|------|------|
| `⌘⇧V` | 在光标处弹出历史面板 |
| `↑↓` | 在列表中移动选择 |
| `⏎` | 复制选中内容到剪贴板并关闭面板 |
| `⎋` | 关闭面板 |
| 键入文字 | 自动聚焦搜索框，实时过滤 |
| 点击菜单栏图标 | 弹出面板 / 打开菜单 |

## 截图

<!-- TODO: 添加截图 -->

## 从源码构建

需要 Xcode 16+ / macOS 14+：

```bash
git clone https://github.com/deajax/CopyKeep.git
cd CopyKeep
./dev.sh      # 构建并启动开发版
./package.sh  # 构建并打包 DMG
```

## 技术栈

- **语言** — Swift (AppKit + SwiftUI)
- **存储** — SQLite (GRDB.swift) + FTS5 全文索引
- **快捷键** — KeyboardShortcuts
- **开机启动** — LaunchAtLogin
- **更新** — Sparkle
- **最低版本** — macOS 14.0 (Sonoma)
- **架构** — Universal Binary（x86_64 + arm64），Intel 和 Apple Silicon 均支持

## 隐私

- 所有数据存储在本地 `~/Library/Application Support/com.copykeep/`
- 无网络请求（更新检查仅在用户触发时连接 GitHub）
- 纯文本记录，不追踪图片和文件

## License

MIT
