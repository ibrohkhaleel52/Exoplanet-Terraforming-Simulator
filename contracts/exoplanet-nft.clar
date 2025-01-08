;; Exoplanet NFT Contract

(define-non-fungible-token exoplanet-nft uint)

(define-data-var last-token-id uint u0)

(define-map token-metadata
  uint
  {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    creator: principal,
    exoplanet-id: uint,
    image-url: (string-ascii 256),
    terraforming-milestone: (string-utf8 500),
    timestamp: uint
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))

(define-public (mint (name (string-ascii 100)) (description (string-utf8 1000)) (exoplanet-id uint) (image-url (string-ascii 256)) (terraforming-milestone (string-utf8 500)))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
      (exoplanet (unwrap! (contract-call? .exoplanet-management get-exoplanet exoplanet-id) ERR_NOT_AUTHORIZED))
    )
    (asserts! (is-eq tx-sender (get discoverer exoplanet)) ERR_NOT_AUTHORIZED)
    (try! (nft-mint? exoplanet-nft token-id tx-sender))
    (map-set token-metadata
      token-id
      {
        name: name,
        description: description,
        creator: tx-sender,
        exoplanet-id: exoplanet-id,
        image-url: image-url,
        terraforming-milestone: terraforming-milestone,
        timestamp: block-height
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer (token-id uint) (recipient principal))
  (nft-transfer? exoplanet-nft token-id tx-sender recipient)
)

(define-read-only (get-token-metadata (token-id uint))
  (map-get? token-metadata token-id)
)

(define-read-only (get-last-token-id)
  (var-get last-token-id)
)

