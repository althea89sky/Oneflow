# Oneflow
OneFlow is a lightweight smart contract for auto-forwarding a percentage of incoming native or ERC-20 tokens to a single wallet. Fully customizable rate and wallet address. Ideal for royalty payouts, fee routing, or treasury flows. Multichain-ready. 

# OneFlow 🌀
**Author:** [althea89sky](https://github.com/althea89sky)  
**License:** Proprietary – Contact for commercial use

## Overview
**OneFlow** is a lightweight, rate-based, single-recipient ETH and ERC-20 token distribution smart contract. It is designed for auto-forwarding a configurable percentage of funds to a designated wallet.

---

## 🔐 Features
- Set a single payout address (`poolWallet`)
- Set a distribution rate (e.g., 7500 = 75%)
- Automatically distributes native tokens (ETH, BNB, MATIC, etc.)
- Manually distributes ERC-20 tokens
- Owner can update wallet, rate, and withdraw remaining funds

---

## 🔧 Example Usage

```solidity
// Deploy
OneFlow oneflow = new OneFlow(poolWallet, 7500); // 75% flow rate

// Update wallet
oneflow.setPoolWallet(newWallet);

// Update rate
oneflow.setRate(5000); // 50% distribution

