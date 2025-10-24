;; ===============================================================
;; Contract: TimeLockedVault.clar
;; Description: A decentralized vault that locks STX deposits until
;;              a user-specified block height is reached.
;; ===============================================================

;; ---------------------------
;; Constants and Error Codes
;; ---------------------------

(define-constant ERR_NO_DEPOSIT (err u100))
(define-constant ERR_TOO_SOON (err u101))
(define-constant ERR_TRANSFER_FAILED (err u102))

;; ---------------------------
;; Data Structures
;; ---------------------------

;; Each user can have one active lock at a time
(define-map user-locks
  principal
  {
    amount: uint,
    unlock-height: uint
  }
)

(define-data-var total-locked uint u0)

;; ---------------------------
;; Public Functions
;; ---------------------------

;; Deposit STX and set a block height for withdrawal
(define-public (lock-funds (unlock-height uint))
  (let (
        (deposit (stx-get-balance tx-sender))
        ;; Use block-height built-in instead of non-existent get-block-info?
        (current-height stacks-block-height)
       )
    (if (<= unlock-height current-height)
        (err u101) ;; unlock height must be in the future
        (begin
          (unwrap! (stx-transfer? deposit tx-sender (as-contract tx-sender)) ERR_TRANSFER_FAILED)
          (map-set user-locks tx-sender {amount: deposit, unlock-height: unlock-height})
          (var-set total-locked (+ (var-get total-locked) deposit))
          (ok "Funds locked successfully")
        )
    )
  )
)

;; Withdraw funds after unlock height is reached
(define-public (withdraw-funds)
  (let (
        (lock (map-get? user-locks tx-sender))
       )
    (if (is-none lock)
        ERR_NO_DEPOSIT
        (let (
              (amount (get amount (unwrap-panic lock)))
              (unlock-height (get unlock-height (unwrap-panic lock)))
              ;; Use block-height built-in instead of non-existent get-block-info?
              (current-height stacks-block-height)
             )
          (if (< current-height unlock-height)
              ERR_TOO_SOON
              (begin
                (unwrap! (stx-transfer? amount (as-contract tx-sender) tx-sender) ERR_TRANSFER_FAILED)
                (map-delete user-locks tx-sender)
                (var-set total-locked (- (var-get total-locked) amount))
                (ok "Withdrawal successful.")
              )
          )
        )
    )
  )
)
