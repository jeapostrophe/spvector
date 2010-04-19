#lang scheme
#|
A semi-persistent vector is like an imperative vector, except old versions can be read.

It works by remembering changes in a weak hash table.
|#

(define-struct sp-vector (version vmap vec)
  #:property prop:sequence
  (lambda (spv)
    (make-do-sequence
     (lambda ()
       (values (lambda (i) (spvector-ref spv i))
               (lambda (i) (add1 i))
               0
               (lambda (i) (i . < . (spvector-length spv)))
               (lambda (v) #t)
               (lambda (i v) #t))))))

(define (spvector-length spv)
  (vector-length (sp-vector-vec spv)))

(define (build-sp-vector v)
  (make-sp-vector (gensym 'sp) (make-weak-hasheq) v))

(define spvector? sp-vector?)

(define (make-spvector . es)
  (build-sp-vector (apply vector es)))

(define (build-spvector n f)
  (build-sp-vector (build-vector n f)))

(define-struct remap (i iv next-ver))

(define (lookup vmap version i vec)
  (match (hash-ref vmap version #f)
    [#f (vector-ref vec i)]
    [(struct remap (ri riv next-ver))
     (if (= ri i)
         riv
         (lookup vmap next-ver i vec))]))

; If version is current, O(1), otherwise O(n) where n = version to current
(define (spvector-ref spv i)
  (lookup (sp-vector-vmap spv)
          (sp-vector-version spv)
          i
          (sp-vector-vec spv)))

; If version is current, O(1), otherwise O(n) where n = version to current
(define (make-current-version! spv)
  (match spv
    [(struct sp-vector (V1 M Vec))
     (match (hash-ref M V1 #f)
       [#f
        (void)]
       [(struct remap (idx val V2))
        ; Forget the remapping
        (hash-set! M V1 #f)
        ; Make the next version the current
        (make-current-version! (make-sp-vector V2 M Vec))
        ; Point the next version to this one
        (hash-set! M V2 (make-remap idx (vector-ref Vec idx) V1))
        ; Edit the vector
        (vector-set! Vec idx val)])]))

; If version is current, O(1), otherwise O(n) where n = version to current
(define (spvector-set spv i iv)
  (make-current-version! spv)
  (match spv
    [(struct sp-vector (V1 M Vec))
     (define V2 (gensym 'sp))
     ; Update the mapping
     (hash-set! M V1 (make-remap i (vector-ref Vec i) V2))
     ; Modify the vector
     (vector-set! Vec i iv)
     (make-sp-vector V2 M Vec)]))

(define (spvector-set! spv i iv)
  (vector-set! (sp-vector-vec spv) i iv))

(provide/contract
 [spvector? (any/c . -> . boolean?)]
 [build-spvector (exact-positive-integer? (exact-nonnegative-integer? . -> . any/c) . -> . spvector?)]
 [make-spvector (() () #:rest (listof any/c) . ->* . spvector?)]
 [spvector-length (spvector? . -> . exact-positive-integer?)]
 [spvector-ref (spvector? exact-nonnegative-integer? . -> . any/c)]
 [spvector-set (spvector? exact-nonnegative-integer? any/c . -> . spvector?)]
 [spvector-set! (spvector? exact-nonnegative-integer? any/c . -> . void)])
