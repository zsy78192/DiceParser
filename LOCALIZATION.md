# DiceParser 多语言本地化指南

DiceParser 现在支持多语言本地化，使用 `.xcstrings` 格式来管理各种语言的错误信息。

## 支持的语言

- 🇨🇳 **中文** (zh-Hans)
- 🇺🇸 **英文** (en) 
- 🇫🇷 **法文** (fr)
- 🇩🇪 **德文** (de)
- 🇯🇵 **日文** (ja)
- 🇰🇷 **韩文** (ko)
- 🇷🇺 **俄文** (ru)

## 文件结构

```
Sources/DiceParser/
├── Localizable.xcstrings          # 多语言字符串资源文件
├── String+Localization.swift      # 本地化扩展方法
└── DiceParserError.swift          # 使用本地化的错误处理
```

## 主要特性

### 1. 自动语言检测
系统会根据用户的设备语言设置自动选择对应的错误消息语言。

### 2. 错误消息本地化
所有 `DiceParserError` 错误类型的消息都已本地化：

- `emptyExpression` - 空表达式错误
- `invalidOperatorCombination` - 无效运算符组合
- `invalidDiceFaces` - 无效骰子面数
- `invalidCharacter` - 无效字符
- `missingOperator` - 缺少运算符
- `diceCountExceeded` - 骰子数量超限
- `invalidExpression` - 无效表达式
- `unmatchedParentheses` - 括号不匹配
- `mathExpressionError` - 数学表达式错误

### 3. 参数化消息支持
支持带有参数的错误消息，如：
```swift
DiceParserError.invalidCharacter("@")
// 输出: "Invalid character: @" (英文)
// 输出: "无效字符：@" (中文)
```

## 使用方法

### 基本用法
```swift
import DiceParser

let parser = DiceParser()
do {
    let result = try parser.evaluateExpression("invalid@expression")
} catch let error as DiceParserError {
    print(error.errorDescription ?? "Unknown error")
    // 根据系统语言显示对应的错误消息
}
```

### 演示本地化功能
```bash
# 运行本地化演示
swift run DiceParserCLI --demo-localization
```

### 错误示例
```bash
# 测试各种错误场景
swift run DiceParserCLI ""          # 空表达式
swift run DiceParserCLI "2d@"       # 无效字符
swift run DiceParserCLI "2d0"       # 无效面数
swift run DiceParserCLI "2d6)"      # 括号不匹配
swift run DiceParserCLI "101d6"     # 超过骰子数量限制
```

## 技术实现

### 1. Localizable.xcstrings
使用 Xcode 15 引入的新格式 `.xcstrings`，包含所有语言的翻译：

```json
{
  "sourceLanguage" : "en",
  "strings" : {
    "error.emptyExpression" : {
      "localizations" : {
        "en" : { "stringUnit" : { "value" : "Please enter an expression" }},
        "zh-Hans" : { "stringUnit" : { "value" : "请输入表达式" }},
        "fr" : { "stringUnit" : { "value" : "Veuillez saisir une expression" }},
        // ... 其他语言
      }
    }
  }
}
```

### 2. 本地化扩展
`String+Localization.swift` 提供了便利方法：

```swift
extension String {
    func localized(comment: String = "") -> String
    func localized(with arguments: CVarArg..., comment: String = "") -> String
}
```

### 3. Swift Package Manager 支持
在 `Package.swift` 中配置资源文件：

```swift
.target(
    name: "DiceParser",
    dependencies: [],
    resources: [
        .process("Localizable.xcstrings")
    ]
)
```

## 添加新语言

要添加新的语言支持：

1. 在 `Localizable.xcstrings` 文件中添加新的语言条目
2. 为每个错误消息添加对应的翻译
3. 更新本文档中的支持语言列表

## 测试

运行测试以验证本地化功能：

```bash
swift test --filter LocalizationTests
```

## 注意事项

1. **设备语言设置**: 错误消息的语言取决于设备的系统语言设置
2. **英文后备**: 如果当前语言不可用，系统会自动降级到英文
3. **Swift Package Manager**: 确保 `.xcstrings` 文件被正确打包到资源中

## 示例输出

### 英文环境
```
❌ 错误: Please enter an expression
❌ 错误: Invalid character: @
❌ 错误: Number of dice cannot exceed 100
```

### 中文环境
```
❌ 错误: 请输入表达式
❌ 错误: 无效字符：@
❌ 错误: 骰子数量不能超过100
```

### 法文环境
```
❌ 错误: Veuillez saisir une expression
❌ 错误: Caractère invalide : @
❌ 错误: Le nombre de dés ne peut pas dépasser 100
```
