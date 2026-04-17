---
title: 代码与文档同步：三层强制机制
date: 2026-04-18
lang: zh
slug: code-and-docs-in-sync
series: vibecoding
episode: 6
translated: true
author: 迈哥
---

<!-- Image placeholder: three-layer enforcement illustration -->

行业正在出现一个新名词来描述 AI Agent 没有约束就写代码的后果：[**AI 架构漂移（AI Architecture Drift）**](https://techdebt.best/ai-architecture-drift/)。Agent 无视此前记录过的决策，重新引入已被废弃的模式，违反分层边界，在项目中途自创新的约定。2026 年行业给出的对策很重：自动化的架构决策记录（ADR）生成器、LLM 驱动的文档 Linter、在 PR 层面强制架构一致性的机器人。

FIRE51 用的是一个轻得多的系统。三层，没有新工具，没有新依赖。它管用，是因为它刚好落在注意力自然到达的节点上——会话开始的那一刻、提交发生的那一刻——并且把规则白纸黑字地留在了仓库里。

## 漂移问题

Vibe Coding 几个会话下来，架构文档描述的是一个已经不存在的系统。新会话从一张过时的地图开始。设计决策被反复争论，因为没人记录过为什么那么决定。已经修过的 Bug 又悄悄地回来了。

根本原因不是懒。是没有自然的强制机制。团队里，Code Review 会抓住偏离；单人 Vibe Coding 里，除非你刻意构建，什么都不会抓。

这事我在 FIRE51 上亲眼见过。下面这个系统建立之前，同一个设计决策——引擎应该在 RMD 之前还是之后处理 Roth 转换——在连续三个会话里被重新争论了一遍。每次答案都一样。没人写下来。AI 对前一次讨论没有任何记忆。我自己也会忘记已经决定过。三次，每次都在浪费时间。

## 第一层 —— AI 常规指令（`CLAUDE.md`）

`CLAUDE.md` 在每次会话开始时被读取。它是杠杆最大的一层，因为它在提交时零成本，却塑造每一次会话。

FIRE51 的 `CLAUDE.md` 里有一张文档同步表——把变更的代码类型直接映射到同一个提交里需要更新的设计文档：

| 代码改动范围 | 需更新的文档 |
|---|---|
| 引擎逻辑、年循环、税务、RMD | `MODULE2_DESIGN.md` 或 `TAX_ENGINE_DESIGN.md` |
| Chat 步骤、解析器、Builder | `MODULE1_DESIGN.md` |
| 报告、图表、PDF、数据转换 | `MODULE3_DESIGN.md` |
| 认证、OTP、邮件、服务器路由 | `GOLIVE_DESIGN.md` |
| 移动端 / Capacitor | `CAPACITOR_DESIGN.md` |
| 部署、基础设施、nginx、VM | `GOLIVE_DESIGN.md` |
| 架构 / 模块边界 | `ARCHITECTURE.md` |
| 以上任何一种 | 如果过程艰难、出人意料或有启发，考虑在 `VIBECODING.md` Raw Notes 里加一行 |

当 AI 做出对应行的代码改动时，它会作为同一个任务的一部分更新对应文档。到提交时不需要提醒，因为工作已经在写代码时就做完了。

`CLAUDE.md` 里还有一份四问的提交前清单：

1. 相关的设计文档更新了吗？
2. `npm test` 通过了吗？
3. `dist/` 和源码同步了吗（`npm run build`）？
4. 有没有值得加到 `VIBECODING.md` 的经验？

AI 在宣布一次提交准备就绪之前过一遍这四个问题。四个问题，大约 10 秒，在大部分漂移出仓库之前就能抓住。

## 第二层 —— Git 预提交钩子（人类提醒）

钩子在每次 `git commit` 时触发，无法被遗忘。FIRE51 的钩子做两件事：

- 暂存了 `src/` 或 `public/` 文件但没有 `.md` 文件被暂存 → 打印一个可见的提醒框——*软警告，不阻止提交*
- `TaxEngine.ts` 被暂存且 PolicyEngine 验证失败 → 硬性阻止

```
  ┌─────────────────────────────────────────────────────────┐
  │  Doc sync reminder                                      │
  │                                                         │
  │  Code changed but no .md files staged.                  │
  │                                                         │
  │  → Did the relevant design doc get updated?             │
  │  → Anything worth adding to VIBECODING.md Raw Notes?    │
  │                                                         │
  │  Committing anyway — update docs in a follow-up if so.  │
  └─────────────────────────────────────────────────────────┘
```

软性执行。对每一次提交都硬性阻止会产生摩擦，最终被 `git commit --no-verify` 绕过。在正确时机的可见提醒，不产生抵触却能改变行为。这系列下一篇会深入讲钩子本身。

## 第三层 —— 写下来，不要口耳相传

只活在某人脑子里的规则，注意力一转就消失了。写下来提交到仓库里的规则，能跨会话、跨协作者、跨项目沉寂的数月持续存在。

两个位置，两类读者：

- `CLAUDE.md` —— AI 读它
- `VIBECODING.md` —— 人类读它

`VIBECODING.md` 的日记规则：每当一个问题需要多次尝试、有出人意料的根本原因，或产生了一个教训——就在 Raw Notes 里加一行。门槛故意设得很低。来自 FIRE51 的真实条目：

> setup.sh 需要 `set -a && source .env` 来加载 DB_PASS——手动 export 在 CI/部署中容易出错

> PM2 会把环境变量缓存进它的 dump；`--update-env` 能添加/覆盖，但从不删除——删除一个变量得 `pm2 delete <app> && bash setup.sh`

> Helmet 8 CSP 会静默添加 `script-src-attr: 'none'`，即使 `script-src` 已有 `'unsafe-inline'`——所有 `onclick=` 处理器都被破坏

每一条写下来只要 10 秒。每一条都价值一个博客段落。Raw Notes 累积起来，博客文章就自己写成了。（这个系列，很大程度上就是从那个文件里提炼出来的。）

## 为什么软性胜过硬性

硬性执行听起来很诱人。实际中，对每次提交都硬性阻止，一周之内就会产生 `git commit --no-verify` 的习惯。目标不是让违规变得不可能——而是让正确行为成为阻力最小的路径。

提交时的可见提醒，加上一个被指示在每次任务里更新文档的 AI，比一个门控系统更耐久。ADR 生成机器人和 PR 强制工具在团队场景下有它的位置。对单人 Vibe Coding 来说，三层写下来的纪律更轻、更便宜，而且——以我的经验——更持久。

## 实践中是什么样子

**之前**：会话结束，代码提交，文档过时，教训被遗忘。下次会话：AI 从一张一周前的地图开始。

**之后**：
1. AI 在同一个任务里更新相关设计文档
2. 预提交钩子触发——人类确认或补一条后续说明
3. 如果问题有趣，Raw Notes 里加一行
4. 下次会话从准确的地图和不断增长的日记开始

每次会话的额外开销：不到 2 分钟。复利价值：每次未来的会话、每一篇博客文章、每一位新贡献者都从真相出发，而不是从考古学出发。

---

*FIRE51 是一款完全通过 Vibe Coding 构建的退休规划工具。这是 Vibe Coding 系列的第六篇文章。*
