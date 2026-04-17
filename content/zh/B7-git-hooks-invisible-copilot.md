---
title: Git 钩子：你的隐形副驾驶
date: 2026-04-21
lang: zh
slug: git-hooks-invisible-copilot
series: vibecoding
episode: 7
translated: true
author: 迈哥
---

<!-- Image placeholder: git hook / guardrail illustration -->

2026 年，大多数需要 Git 钩子的项目会选一个框架：Node 生态里的 [Husky](https://typicode.github.io/husky/)，多语言项目要并行执行的选 [Lefthook](https://lefthook.dev/)，Python 技术栈多的选 [pre-commit 框架](https://pre-commit.com/)。都不错，都会多出一个依赖。

FIRE51 一个都没用。整个预提交系统就是一个 Bash 脚本，提交到 `scripts/hooks/`，由 `setup.sh` 软链到 `.git/hooks/`。三十行，零依赖，Claude 一轮就写完，已经安静运行了数月。对单人 Vibe Coding 项目来说，这才是刚好的工具量级。

这篇文章讲清楚机制，放上实际脚本，并说明什么时候该升级到框架。

## 机制

Git 钩子是 Git 在工作流特定节点自动运行的 Shell 脚本。它们放在 `.git/hooks/`，Git 按名字调用——不需要任何配置。

```
.git/hooks/
  pre-commit     ← 提交创建前触发
  commit-msg     ← 你写完提交信息后触发
  pre-push       ← Git 推送到远端前触发
  post-commit    ← 提交完成后触发（无法中止）
```

当你执行 `git commit` 时，Git 会找 `.git/hooks/pre-commit`。如果它存在且可执行（`chmod +x`），Git 就运行它：

- 退出码 `0` → 提交继续
- 退出码非零 → 提交中止

整个机制就这些，剩下的都是 Shell 脚本。

## FIRE51 实际用的钩子

这是完整的 `pre-commit` 脚本，原封不动：

```bash
#!/bin/bash
# FIRE51 pre-commit hook
# Reminds about doc sync and VIBECODING.md diary when code changes without docs.
# Soft warning only — does not block the commit.

STAGED=$(git diff --cached --name-only)

CODE_CHANGED=$(echo "$STAGED" | grep -E "^src/|^public/" | grep -v "\.map$" | head -1)
DOC_CHANGED=$(echo "$STAGED" | grep -E "\.md$" | head -1)

if [ -n "$CODE_CHANGED" ] && [ -z "$DOC_CHANGED" ]; then
  echo ""
  echo "  ┌─────────────────────────────────────────────────────────┐"
  echo "  │  Doc sync reminder                                      │"
  echo "  │                                                         │"
  echo "  │  Code changed but no .md files staged.                  │"
  echo "  │                                                         │"
  echo "  │  → Did the relevant design doc get updated?             │"
  echo "  │  → Anything worth adding to VIBECODING.md Raw Notes?    │"
  echo "  │                                                         │"
  echo "  │  Committing anyway — update docs in a follow-up if so.  │"
  echo "  └─────────────────────────────────────────────────────────┘"
  echo ""
fi

# Hard gate: tax engine must pass validation before commit
if echo "$STAGED" | grep -q "TaxEngine.ts"; then
  echo "pre-commit: TaxEngine.ts changed — running PolicyEngine validation..."
  npm test -- --testPathPattern="tests/validation" --silent 2>&1
  if [ $? -ne 0 ]; then
    echo "pre-commit: PolicyEngine validation FAILED. Fix before committing."
    exit 1
  fi
  echo "pre-commit: validation passed."
fi

exit 0
```

两种行为、两种哲学，写在一个文件里。

## 软性 vs. 硬性

文档同步提醒是软性的——退出码 `0`，提交总能继续。税务验证是硬性的——退出码 `1`，直接阻止提交。这个分裂是刻意的。

**硬性合适的时候**：违规是客观上的破坏——测试失败、Lint 报错、diff 里检测出密钥。一个坏提交的代价足够高，摩擦是值得的。

**软性合适的时候**：这条检查是实践提醒，不是正确性门控。把文档更新做成硬性阻止，一周内就会形成 `git commit --no-verify` 习惯。在正确时机的可见提醒，不制造抵触却能改变行为。

在 FIRE51 的钩子里两者都能看到：文档同步是个推一下，税务引擎正确性是堵墙。税务引擎是唯一一个一旦算错就会悄悄地把几十年后的退休预测复利成毫无意义数字的模块。它配得上那堵墙。

## 快速参考

| 钩子 | 时机 | 退出码非零则 |
|------|------|-------------|
| `pre-commit` | 提交创建前 | 中止提交 |
| `commit-msg` | 信息写完后 | 中止提交 |
| `pre-push` | 推送到远端前 | 中止推送 |
| `post-commit` | 提交完成后 | （无法中止）|
| `pre-rebase` | rebase 开始前 | 中止 rebase |

FIRE51 用了 `pre-commit` 和 `pre-push`。pre-commit 在问题被记录进 Git 历史前捕获。pre-push 是它们到达远端之前的最后一道防线——它会重跑税务引擎验证，防止有人用 `--no-verify` 绕过了 pre-commit。

## 你必须知道的限制

`.git/hooks/` 在设计上被排除在 Git 跟踪之外。一次新的 `git clone` 拿到的是空的 hooks 目录。其他协作者不会自动得到你的钩子。

三种标准解法：

1. **把钩子提交到 `scripts/hooks/`，让 `setup.sh` 软链到 `.git/hooks/`** —— FIRE51 这么做。零依赖，一行 setup，任何装了 Bash 的机器都能跑。
2. **[Husky](https://typicode.github.io/husky/)** —— Node 生态的默认选项。把钩子作为 `package.json` 的一部分管理。如果你已经在做 `npm install`，最理想。
3. **[Lefthook](https://lefthook.dev/)** —— 一个 Go 二进制，YAML 配置，并行跑钩子。多语言项目或者提交前耗时明显时值得上。
4. **[pre-commit 框架](https://pre-commit.com/)** —— 基于 Python，海量的预置钩子库，语言无关。重量级选项。

单人项目，方案 1 基本够了。团队场景，方案 2 或 3 是正确的下一步——Husky 和 Lefthook 的选择主要在于你愿不愿意为钩子工具付出 Node.js 这个成本，以及钩子速度是否重要。

## 为什么特别适合 Vibe Coding

AI 动作很快。没有门控，坏习惯会跨会话累积到你没注意的程度。有了钩子，质量检查会在注意力自然落在提交那一刻——在提交完成之前——就发生。

钩子本身也可以由 AI 写。FIRE51 的 pre-commit 钩子是 Claude 在一个会话里写出来的——我要一个代码改动时没文档就弹个软提醒，税务引擎验证失败就硬性阻止，拿到了上面那段 30 行的脚本。提交到 `scripts/hooks/`，由 `setup.sh` 软链过去，之后一直安静地跑着。零维护成本。持久的护栏。

最好的副驾驶，是你忘记它在那里的那种。

---

*FIRE51 是一款完全通过 Vibe Coding 构建的退休规划工具。这是 Vibe Coding 系列的第七篇文章。*
