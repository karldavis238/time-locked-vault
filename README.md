Time-Locked Vault Smart Contract

Overview
The **Time-Locked Vault Smart Contract** is a secure token management system built on the Stacks blockchain using the **Clarity** language.  
It allows users to deposit and lock their tokens until a specified block height (unlock time). Once the lock duration expires, the user can safely withdraw their tokens.

This contract promotes **trustless savings**, **vesting mechanisms**, and **deferred payments** without relying on intermediaries.

---

Features
- **Time-Based Locking:** Lock tokens until a future block height.
- **Secure Withdrawals:** Funds can only be accessed after the unlock height.
- **Owner-Based Access:** Only the original depositor can withdraw locked funds.
- **Data Transparency:** Retrieve vault information on-chain using public read-only functions.

---

Contract Functions

| Function | Type | Description |
|-----------|------|-------------|
| `deposit(amount, unlock-height)` | Public | Allows a user to deposit tokens and lock them until a specified block height. |
| `withdraw()` | Public | Enables the depositor to withdraw their locked tokens once the unlock height has passed. |
| `get-vault-info(owner)` | Read-Only | Returns details of the locked vault for the specified owner (amount and unlock height). |

---

Data Structures

```clarity
(define-map vaults
  { owner: principal }
  { amount: uint, unlock-height: uint })
