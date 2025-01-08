;; Exoplanet Management Contract

(define-data-var exoplanet-count uint u0)

(define-map exoplanets
  uint
  {
    discoverer: principal,
    name: (string-ascii 100),
    description: (string-utf8 1000),
    parameters: (list 10 int),
    habitability-score: uint,
    terraforming-status: (string-ascii 20)
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_EXOPLANET (err u404))

(define-public (register-exoplanet (name (string-ascii 100)) (description (string-utf8 1000)) (parameters (list 10 int)))
  (let
    (
      (exoplanet-id (+ (var-get exoplanet-count) u1))
    )
    (map-set exoplanets
      exoplanet-id
      {
        discoverer: tx-sender,
        name: name,
        description: description,
        parameters: parameters,
        habitability-score: u0,
        terraforming-status: "untouched"
      }
    )
    (var-set exoplanet-count exoplanet-id)
    (ok exoplanet-id)
  )
)

(define-public (update-habitability-score (exoplanet-id uint) (new-score uint))
  (let
    (
      (exoplanet (unwrap! (map-get? exoplanets exoplanet-id) ERR_INVALID_EXOPLANET))
    )
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) (is-eq tx-sender (get discoverer exoplanet))) ERR_NOT_AUTHORIZED)
    (ok (map-set exoplanets
      exoplanet-id
      (merge exoplanet { habitability-score: new-score })
    ))
  )
)

(define-public (update-terraforming-status (exoplanet-id uint) (new-status (string-ascii 20)))
  (let
    (
      (exoplanet (unwrap! (map-get? exoplanets exoplanet-id) ERR_INVALID_EXOPLANET))
    )
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) (is-eq tx-sender (get discoverer exoplanet))) ERR_NOT_AUTHORIZED)
    (ok (map-set exoplanets
      exoplanet-id
      (merge exoplanet { terraforming-status: new-status })
    ))
  )
)

(define-read-only (get-exoplanet (exoplanet-id uint))
  (map-get? exoplanets exoplanet-id)
)

(define-read-only (get-exoplanet-count)
  (var-get exoplanet-count)
)

