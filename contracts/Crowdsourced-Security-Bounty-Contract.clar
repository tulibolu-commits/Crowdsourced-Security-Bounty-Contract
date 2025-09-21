;; Crowdsourced Security Bounty Contract

;; Data variables
(define-data-var owner (optional principal) none)
(define-data-var next-bounty-id uint u1)

;; Data maps
(define-map bounties
  ((bounty-id uint))
  ((issuer principal)
   (title (buff 128))
   (description (buff 256))
   (reward uint)
   (escrowed uint)
   (open bool)
   (created-block uint)
   (deadline-block (optional uint))))

(define-map submissions
  ((bounty-id uint) (submission-id uint))
  ((submitter principal) (uri (buff 256)) (accepted bool) (votes uint)))

(define-map submission-ratings
  ((bounty-id uint) (submission-id uint) (rater principal))
  ((rating uint) (created-block uint)))

(define-map user-reputation
  ((user principal))
  ((total-ratings uint) (total-score uint) (submissions-count uint)))

;; Error codes
(define-constant ERR-NOT-OWNER u100)
(define-constant ERR-INVALID u101)
(define-constant ERR-NOT-FOUND u102)
(define-constant ERR-ALREADY_SET u103)
(define-constant ERR-ALREADY-RATED u104)
(define-constant ERR-NOT-ACCEPTED u105)

;; Utilities
(define-read-only (get-owner)
  (var-get owner))

;; Initialization
(define-public (initialize-contract (new-owner principal))
  (match (var-get owner)
    (some existing (err ERR-ALREADY_SET))
    none (begin (var-set owner (some new-owner)) (ok true))))

;; Create a new bounty
(define-public (create-bounty (title (buff 128)) (description (buff 256)) (reward uint) (deadline-block (optional uint)))
  (if (<= reward u0)
      (err ERR-INVALID)
      (begin
        (let ((id (var-get next-bounty-id)) (now block-height))
          (map-set bounties
            ((bounty-id id))
            ((issuer tx-sender)
             (title title)
             (description description)
             (reward reward)
             (escrowed u0)
             (open true)
             (created-block now)
             (deadline-block deadline-block)))
          (var-set next-bounty-id (+ id u1))
          (ok id)))))

;; Submit a solution for a bounty
(define-public (submit-solution (bounty-id uint) (uri (buff 256)))
  (match (map-get? bounties ((bounty-id bounty-id)))
    (some b
      (if (not (get open b))
          (err ERR-INVALID)
          (let ((sid (+ (sha256 (concat (buff-to-hex uri) (principal-to-hex tx-sender))) u0)))
            (map-set submissions 
              ((bounty-id bounty-id) (submission-id sid)) 
              ((submitter tx-sender) (uri uri) (accepted false) (votes u0)))
            (ok sid))))
    none (err ERR-NOT-FOUND)))

;; Accept a submission
(define-public (accept-submission (bounty-id uint) (submission-id uint))
  (match (map-get? submissions ((bounty-id bounty-id) (submission-id submission-id)))
    (some s
      (match (map-get? bounties ((bounty-id bounty-id)))
        (some b
          (if (not (is-eq tx-sender (get issuer b)))
              (err ERR-NOT-OWNER)
              (if (not (get open b))
                  (err ERR-INVALID)
                  (begin
                    (map-set submissions 
                      ((bounty-id bounty-id) (submission-id submission-id)) 
                      ((submitter (get submitter s)) 
                       (uri (get uri s)) 
                       (accepted true) 
                       (votes (get votes s))))
                    (map-delete bounties ((bounty-id bounty-id)))
                    (match (map-get? user-reputation ((user (get submitter s))))
                      (some rep true)
                      none (map-set user-reputation 
                        ((user (get submitter s))) 
                        ((total-ratings u0) (total-score u0) (submissions-count u1))))
                    (ok true)))))
        none (err ERR-NOT-FOUND)))
    none (err ERR-NOT-FOUND)))

;; Rate an accepted submission
(define-public (rate-submission (bounty-id uint) (submission-id uint) (rating uint))
  (let ((now-block block-height))
    (if (not (and (>= rating u1) (<= rating u5)))
        (err ERR-INVALID)
        (match (map-get? submissions ((bounty-id bounty-id) (submission-id submission-id)))
          (some s
            (if (not (get accepted s))
                (err ERR-NOT-ACCEPTED)
                (if (is-some (map-get? submission-ratings ((bounty-id bounty-id) (submission-id submission-id) (rater tx-sender))))
                    (err ERR-ALREADY-RATED)
                    (begin
                      (map-set submission-ratings 
                        ((bounty-id bounty-id) (submission-id submission-id) (rater tx-sender))
                        ((rating rating) (created-block now-block)))
                      (match (map-get? user-reputation ((user (get submitter s))))
                        (some rep
                          (map-set user-reputation
                            ((user (get submitter s)))
                            ((total-ratings (+ (get total-ratings rep) u1))
                             (total-score (+ (get total-score rep) rating))
                             (submissions-count (get submissions-count rep)))))
                        none
                          (map-set user-reputation
                            ((user (get submitter s)))
                            ((total-ratings u1) (total-score rating) (submissions-count u1))))
                      (ok true)))))
          none (err ERR-NOT-FOUND)))))

;; Read-only functions
(define-read-only (get-bounty (bounty-id uint))
  (match (map-get? bounties ((bounty-id bounty-id)))
    (some b (ok b))
    none (err ERR-NOT-FOUND)))

(define-read-only (get-submission (bounty-id uint) (submission-id uint))
  (match (map-get? submissions ((bounty-id bounty-id) (submission-id submission-id)))
    (some s (ok s))
    none (err ERR-NOT-FOUND)))

(define-read-only (contract-balance)
  (ok (stx-get-balance (as-contract tx-sender))))

(define-read-only (get-user-reputation-score (user principal))
  (match (map-get? user-reputation ((user user)))
    (some rep
      (if (> (get total-ratings rep) u0)
          (ok (/ (get total-score rep) (get total-ratings rep)))
          (ok u0)))
    none (err ERR-NOT-FOUND)))

(define-read-only (get-user-reputation-details (user principal))
  (match (map-get? user-reputation ((user user)))
    (some rep (ok rep))
    none (err ERR-NOT-FOUND)))

(define-read-only (get-submission-rating (bounty-id uint) (submission-id uint) (rater principal))
  (match (map-get? submission-ratings ((bounty-id bounty-id) (submission-id submission-id) (rater rater)))
    (some rating (ok rating))
    none (err ERR-NOT-FOUND)))
