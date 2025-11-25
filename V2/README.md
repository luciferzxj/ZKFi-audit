# Vault (ERC-20 Multi-Asset Yield Vault)

> 可暂停的多 Token 收益型金库。用户质押任意被允许的 ERC-20 资产，按年化比例累计奖励；提取采用**等待队列**模式，由外部 WithdrawVault 发放；同时配套 **zkToken**（份额代币）记录并可转移用户份额，支持**闪提（带罚金）**与**撤销领取**（均可开关）。

---

## 目录

- [特性](#特性)
- [架构概览](#架构概览)
- [角色与权限](#角色与权限)
- [核心概念](#核心概念)
- [安装与部署](#安装与部署)
- [配置指南](#配置指南)
- [典型用户流程](#典型用户流程)
- [接口速查](#接口速查)
- [事件](#事件)
- [安全与实现细节](#安全与实现细节)
- [运维建议](#运维建议)
- [常见问题](#常见问题)
- [合约源码](#合约源码)
- [许可](#许可)

---

## 特性

- ✅ 支持**多种 ERC-20 Token** 统一收益管理  
- ✅ **可暂停**（Pausable），便于运维风控  
- ✅ **队列式提现**：申请→等待期→WithdrawVault 发放  
- ✅ **份额代币（zkToken）** 代表权益，可转账，可按比例迁移本金与奖励  
- ✅ **奖励分段计提**：奖励率可多次调整，按时间线精确结算  
- ✅ **闪提与撤销**：即时退出（收取罚金）与撤销领取（按汇率回铸份额）  
- ✅ 完整的**最小/最大质押限额**、**等待期**、**罚金比例**等参数化控制

---

## 架构概览

- **Vault**：核心逻辑与状态管理（质押、奖励、领取队列、闪提、撤销、参数配置）  
- **zkToken**：每种受支持 Token 对应一个 zkToken（1:1 绑定）  
- **WithdrawVault**：提现执行器，到期由它给用户转账

---

## 角色与权限

| 角色 | 权限 |
| --- | --- |
| `DEFAULT_ADMIN_ROLE` | 增删支持 Token、配置限额/等待期/罚金/奖励率、ceffu 托管地址、空投地址等 |
| `PAUSER_ROLE` | `pause()` / `unpause()` |
| `BOT_ROLE` | `transferToCeffu()` 拨款到托管地址 |

**可控开关**

- `setFlashEnable(bool)`：闪提开关（内部布尔为 `flashNotEnable`，取反逻辑）  
- `setCancelEnable(bool)`：撤销领取开关（内部布尔为 `cancelNotEnable`，取反逻辑）

---

## 核心概念

- **TVL（tvl[token]）**：仅本金维度的金库锁仓（奖励不计入此字段）  
- **奖励率（APY）**：以 `BASE=10_000` 为分母，例如 `700` = **7%** 年化  
- **时间基准**：**365.25 天**（31,557,600 秒，闰年友好）  
- **兑换率（exchangeRate）**  
  ```text
  exchangeRate = (totalStakeAmountByToken[token] + totalRewardsAmountByToken[token]) / totalSupply(zkToken)
  若 totalSupply == 0 => exchangeRate = 1e18
