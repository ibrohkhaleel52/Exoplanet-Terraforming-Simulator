;; Terraforming Strategy Contract

(define-data-var strategy-count uint u0)

(define-map terraforming-strategies
  uint
  {
    creator: principal,
    exoplanet-id: uint,
    name: (string-ascii 100),
    description: (string-utf8 1000),
    steps: (list 10 (string-utf8 500)),
    estimated-duration: uint,
    status: (string-ascii 20)
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_STRATEGY (err u404))

(define-public (create-strategy (exoplanet-id uint) (name (string-ascii 100)) (description (string-utf8 1000)) (steps (list 10 (string-utf8 500))) (estimated-duration uint))
  (let
    (
      (strategy-id (+ (var-get strategy-count) u1))
    )
    (asserts! (is-some (contract-call? .exoplanet-management get-exoplanet exoplanet-id)) ERR_INVALID_STRATEGY)
    (map-set terraforming-strategies
      strategy-id
      {
        creator: tx-sender,
        exoplanet-id: exoplanet-id,
        name: name,
        description: description,
        steps: steps,
        estimated-duration: estimated-duration,
        status: "proposed"
      }
    )
    (var-set strategy-count strategy-id)
    (ok strategy-id)
  )
)

(define-public (update-strategy-status (strategy-id uint) (new-status (string-ascii 20)))
  (let
    (
      (strategy (unwrap! (map-get? terraforming-strategies strategy-id) ERR_INVALID_STRATEGY))
    )
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) (is-eq tx-sender (get creator strategy))) ERR_NOT_AUTHORIZED)
    (ok (map-set terraforming-strategies
      strategy-id
      (merge strategy { status: new-status })
    ))
  )
)

(define-read-only (get-strategy (strategy-id uint))
  (map-get? terraforming-strategies strategy-id)
)

(define-read-only (get-strategy-count)
  (var-get strategy-count)
)

