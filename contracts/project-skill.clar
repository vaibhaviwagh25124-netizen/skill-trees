;; Skill Trees with Token Unlocks
;; Users complete skill paths to mint NFTs as proof of achievement

(define-non-fungible-token skill-nft uint)

;; Track completed users per skill path
(define-map skill-completions (tuple (user principal) (path-id uint)) bool)

;; Track minted NFTs
(define-data-var nft-id-counter uint u0)

;; Errors
(define-constant err-already-completed (err u100))
(define-constant err-not-completed (err u101))

;; Complete a skill path (admin only for simplicity)
(define-public (complete-skill-path (user principal) (path-id uint))
  (begin
    (asserts! (is-none (map-get? skill-completions {user: user, path-id: path-id})) err-already-completed)
    (map-set skill-completions {user: user, path-id: path-id} true)
    (ok true)))

;; Mint NFT for a completed skill path
(define-public (mint-skill-nft (path-id uint))
  (let ((completed? (map-get? skill-completions {user: tx-sender, path-id: path-id})))
    (begin
      (asserts! (is-some completed?) err-not-completed)
      (let ((new-id (+ (var-get nft-id-counter) u1)))
        (try! (nft-mint? skill-nft new-id tx-sender))
        (var-set nft-id-counter new-id)
        (ok new-id)))))
