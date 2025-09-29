#lang racket

(require racket/unsafe/ops)
(define set-cdr! unsafe-set-immutable-cdr!)
(define set-car! unsafe-set-immutable-car!)

