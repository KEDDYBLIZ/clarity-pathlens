;; PathLens Career Path Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))

;; Data Maps
(define-map profiles
  principal
  {
    name: (string-utf8 100),
    title: (string-utf8 100),
    skills: (list 20 (string-utf8 50)),
    certifications: (list 20 (string-utf8 100))
  }
)

(define-map mentorships
  { mentee: principal, mentor: principal }
  {
    status: (string-utf8 20),
    start-time: uint,
    endorsements: (list 10 (string-utf8 100))
  }
)

;; Public Functions
(define-public (create-profile (name (string-utf8 100)) (title (string-utf8 100)))
  (let ((empty-profile {
    name: name,
    title: title,
    skills: (list ),
    certifications: (list )
  }))
    (ok (map-set profiles tx-sender empty-profile))
  )
)

(define-public (add-certification (cert (string-utf8 100)))
  (let ((current-profile (unwrap! (get-profile tx-sender) err-not-found)))
    (ok (map-set profiles tx-sender
      (merge current-profile { certifications: (unwrap! (as-max-len? (append (get certifications current-profile) cert) u20) err-unauthorized) })
    ))
  )
)

(define-public (request-mentorship (mentor principal))
  (let ((mentorship-data {
    status: "pending",
    start-time: block-height,
    endorsements: (list )
  }))
    (ok (map-set mentorships { mentee: tx-sender, mentor: mentor } mentorship-data))
  )
)

;; Read Only Functions
(define-read-only (get-profile (user principal))
  (ok (map-get? profiles user))
)

(define-read-only (get-mentorship (mentee principal) (mentor principal))
  (ok (map-get? mentorships { mentee: mentee, mentor: mentor }))
)
