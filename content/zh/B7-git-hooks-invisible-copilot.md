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

FIRE51项目并没有选择比较复杂的框架。毕竟是单人 Vibe Coding 项目，git hook就是足够保障工程化的严谨性。整个预提交系统就是一个 Bash 脚本，提交到 `scripts/hooks/`，由 `setup.sh` 软链到 `.git/hooks/`。三十行，零依赖，Claude 一轮就写完，

下文将介绍机制和实际脚本，并说明什么时候该升级到框架。

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

上一篇[《代码与文档同步：三层强制机制》](/blog/zh/code-and-docs-in-sync)收尾讲"软性胜过硬性"——这篇讲的是那套哲学落到代码里长什么样。FIRE51 的钩子刻意是混合的：文档同步是个推一下（`exit 0`），税务验证是堵墙（`exit 1`）。规则：**只有当违规是客观上被破坏时才硬阻止**——测试失败、Lint 报错、diff 里检测出密钥。其他都是提醒。税务引擎配得上那堵墙，是因为它一旦算错会把几十年后的退休预测复利成毫无意义的数字；文档漂移可以补救，税务算错不能。

## 让钩子保持效率

慢的钩子等于被绕过的钩子。我的预算：**pre-commit 不超过 ~2 秒，pre-push 不超过 ~10 秒。** 超过这个线，一周内 `--no-verify` 的习惯就会成形，护栏安静地消失。

不该放进 pre-commit 的：

- 完整测试套件 —— 跑一个有针对性的子集，剩下交给 CI。
- 网络调用 —— 依赖扫描、远端 Linter、任何会因为网络抖动而卡住的东西。
- 任何需要从零开始干净构建的步骤。

注意 FIRE51 的税务引擎门控实际跑的是什么：`npm test -- --testPathPattern="tests/validation"`。是验证子集，不是完整套件。完整测试放在 CI 里跑。钩子只守住那一类既常见又有灾难性后果的错误 —— 税务逻辑算错 —— 而且跑得够快，快到从不诱惑你去绕过。

## 钩子的子集：以 PolicyEngine 为例

上一节提到钩子跑的是"验证子集"而不是完整套件。这个子集到底是什么，为什么一定是这个形状？

**为什么需要一个外部基准。** AI 写出来的金融代码，"看起来合理"和"确实正确"之间差得很远。退休预测里一个 5% 的税务误差复利到 45 年后，就是一个毫无意义的数字。而且 AI 很容易把税务引擎和它的测试一起"修对"——输入参数微调一下，测试就过了，错的逻辑留在生产里。唯一的解法是拉一个 AI 没法糊弄的独立基准进来。

[PolicyEngine](https://policyengine.org/) 是开源的税务微观模拟模型，政策研究人员用它做仿真。FIRE51 把它当独立 ground truth 来校对自己的税务引擎：同一组输入，两边分别算，差值落在容差内（联邦 ±$100、州 ±$300、NIIT ±$50、SS 应税 ±$50）才算通过。

**为什么不能把 PolicyEngine 的开源代码直接嵌进产品。** PolicyEngine 是 AGPL 许可证。只在开发机本地跑来比对结果没问题，但一旦作为库打包进 app 二进制、或者通过 API 暴露给终端用户，就会触发 AGPL 的开源传染——FIRE51 所有闭源代码都必须一起公开。所以它只活在离线校对那一侧，永远不和生产代码共享进程。

**为什么钩子里不跑完整 PolicyEngine 校对。** 完整 pipeline（`npm run validate:pe`）要批量调一个外部 Python 服务、覆盖多个年份和多种场景，一遍要跑十几分钟，而且会随项目成长而延长。塞进 pre-commit 会立刻触发上一节讲过的 `--no-verify` 习惯，等于什么都没守住。

**实际的触发方式。** 开发机上先用 PolicyEngine 跑一轮完整校对，把结果快照到 `tests/validation/` 下的参考值文件里。钩子里跑的那行 `npm test` 做的就是拿当前税务引擎的输出去和这批快照比对——秒级完成，且只在 `TaxEngine.ts` 发生变更时触发。完整 PolicyEngine 校对什么时候重跑？重大税务逻辑改动之后（新增税种、年份参数升级、IRS 规则更新），手动跑一次，刷新快照，再进入常规提交流程。

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

四种标准解法：

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
