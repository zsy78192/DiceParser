# Swift骰子表达式解析器

这是一个用Swift实现的骰子表达式解析器，完整复现了JavaScript版本的所有功能。

## 功能特性

- ✅ 标准骰子投掷（如 2d6, d20）
- ✅ 百分骰投掷（d100）
- ✅ 优势/劣势投掷（Adv(d20), Dis(d6)）
- ✅ 数学运算支持（+ - * / ()）
- ✅ 错误处理和验证
- ✅ 详细的投掷记录
- ✅ 完整的单元测试

## 文件结构

```
swift/
├── Package.swift          # Swift包配置文件
├── DiceParser.swift       # 核心解析器类
├── DiceParserTests.swift  # 单元测试
├── main.swift            # 演示程序
└── README.md             # 说明文档
```

## 安装和构建

### GitHub仓库地址
GitHub: https://github.com/zsy78192/DiceParser.git

### 方法1：使用Swift Package Manager

```bash
cd swift
swift build
```

### 方法2：直接运行

```bash
cd swift
swift run
```

### 方法3：运行测试

```bash
cd swift
swift test
```

### 方法4：通过Swift Package Manager安装

在您的`Package.swift`中添加：

```swift
.package(url: "https://github.com/zsy78192/DiceParser.git", from: "1.0.0")
```

## 使用方法

### 命令行使用（推荐）

#### 基本命令
```bash
cd swift
swift run DiceParser "2d6 + 3"
```

#### 示例
```bash
# 简单骰子投掷
swift run DiceParser "d20"

# 多个骰子加修饰符
swift run DiceParser "3d6 + 5"

# 优势投掷
swift run DiceParser "Adv(d20)"

# 劣势投掷
swift run DiceParser "Dis(d6)"

# 复杂表达式
swift run DiceParser "(2d6 + d4) * 2"

# 百分骰
swift run DiceParser "d100 + 20"
```

#### 查看帮助
```bash
swift run DiceParser --help
```

### 程序化使用

#### 基本使用

```swift
import Foundation

let parser = DiceParser()

do {
    let result = try parser.evaluateExpression("2d6 + Adv(d20)")
    
    if let rolls = result["rolls"] as? [[String: Any]] {
        print("投掷记录: \(rolls)")
    }
    
    if let steps = result["steps"] as? String {
        print("计算步骤: \(steps)")
    }
    
    if let finalResult = result["finalResult"] as? Double {
        print("最终结果: \(Int(finalResult))")
    }
    
} catch {
    print("错误: \(error.localizedDescription)")
}
```

### 支持的表达式格式

| 表达式 | 说明 |
|--------|------|
| `d6` | 投掷一个6面骰子 |
| `2d6` | 投掷两个6面骰子 |
| `d100` | 投掷百分骰 |
| `Adv(d20)` | d20优势投掷（取最大值） |
| `Dis(d6)` | d6劣势投掷（取最小值） |
| `2d6 + 3` | 两个6面骰子加3 |
| `(d6 + d8) * 2` | 括号内的计算 |

### 错误处理

解析器会抛出以下错误：

- `DiceParserError.emptyExpression`: 空表达式
- `DiceParserError.invalidOperatorCombination`: 无效运算符组合
- `DiceParserError.invalidDiceFaces`: 骰子面数无效（1-1000）
- `DiceParserError.invalidCharacter`: 无效字符
- `DiceParserError.missingOperator`: 缺少运算符
- `DiceParserError.diceCountExceeded`: 骰子数量超过限制（100）
- `DiceParserError.invalidExpression`: 无效表达式

## 运行演示

### 演示模式
```bash
swift run
# 选择选项 1 查看演示
```

### 交互式计算器
```bash
swift run
# 选择选项 2 进入交互模式
```

### 运行测试
```bash
swift run
# 选择选项 3 运行单元测试
```

## 与JavaScript版本的差异

| 特性 | Swift版本 | JavaScript版本 |
|------|-----------|----------------|
| 随机数生成 | Swift原生 | Math.random() |
| 数学计算 | NSExpression | math.js |
| 错误处理 | Swift Error | JavaScript Error |
| 测试框架 | XCTest | Jest |
| 包管理 | Swift Package Manager | npm |

## 示例输出

```
🎲 骰子表达式解析器演示
========================================

表达式: 2d6 + 3
--------------------
投掷结果:
  d6: 4
  d6: 5
计算步骤: [4+5] + 3
最终结果: 12

表达式: Adv(d20)
--------------------
投掷结果:
  Adv(d20): [15,12] → 15
计算步骤: [15,12→15]
最终结果: 15
```

## 技术细节

- **Swift版本**: 5.7+
- **依赖**: 无外部依赖，使用Foundation框架
- **平台**: macOS, Linux, iOS (需适配)
- **架构**: 面向对象设计，封装为DiceParser类

## 扩展建议

1. **添加自定义骰子类型**：可以扩展支持更多骰子类型
2. **历史记录**：添加投掷历史记录功能
3. **统计分析**：计算平均值、标准差等统计信息
4. **UI集成**：为iOS/macOS应用创建图形界面
5. **网络功能**：添加在线骰子投掷服务

## 许可证

MIT License - 可自由使用和修改