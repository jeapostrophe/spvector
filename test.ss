#lang scheme
(require scheme/package
         tests/eli-tester
         "main.ss")

(package-begin
 (define v1 (make-spvector #f #f #f))
 (spvector-set v1 1 #t))

(package-begin
 (define v1 (make-spvector #f #f #f))
 (define v2 (spvector-set v1 1 #t))
 (test
  (spvector-ref v1 1) => #f
  (spvector-ref v2 1) => #t))

(package-begin
 (test
  (for/list ([i (make-spvector 1 2 3)])
    i) => (list 1 2 3)))

(package-begin
 (define v1 (make-spvector #f #f #f))
 (define v2 (spvector-set v1 1 'v2))
 (define v3 (spvector-set v1 1 'v3))
 (define v4 (spvector-set v2 2 'v4))
 (define v5 (spvector-set v3 2 'v5))
 (test
  (spvector-ref v1 1) => #f
  (spvector-ref v2 1) => 'v2
  (spvector-ref v3 1) => 'v3
  (spvector-ref v4 1) => 'v2
  (spvector-ref v4 2) => 'v4
  (spvector-ref v5 1) => 'v3
  (spvector-ref v5 2) => 'v5
  ))