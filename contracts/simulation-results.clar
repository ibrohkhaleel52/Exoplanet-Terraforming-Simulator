;; Simulation Results Contract

(define-data-var simulation-count uint u0)

(define-map simulation-results
  uint
  {
    researcher: principal,
    exoplanet-id: uint,
    strategy-id: uint,
    description: (string-utf8 1000),
    results: (string-utf8 2000),
    success-probability: uint,
    timestamp: uint
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_SIMULATION (err u404))

(define-public (record-simulation-result (exoplanet-id uint) (strategy-id uint) (description (string-utf8 1000)) (results (string-utf8 2000)) (success-probability uint))
  (let
    (
      (simulation-id (+ (var-get simulation-count) u1))
    )
    (asserts! (is-some (contract-call? .exoplanet-management get-exoplanet exoplanet-id)) ERR_INVALID_SIMULATION)
    (asserts! (is-some (contract-call? .terraforming-strategy get-strategy strategy-id)) ERR_INVALID_SIMULATION)
    (map-set simulation-results
      simulation-id
      {
        researcher: tx-sender,
        exoplanet-id: exoplanet-id,
        strategy-id: strategy-id,
        description: description,
        results: results,
        success-probability: success-probability,
        timestamp: block-height
      }
    )
    (var-set simulation-count simulation-id)
    (ok simulation-id)
  )
)

(define-read-only (get-simulation-result (simulation-id uint))
  (map-get? simulation-results simulation-id)
)

(define-read-only (get-simulation-count)
  (var-get simulation-count)
)

