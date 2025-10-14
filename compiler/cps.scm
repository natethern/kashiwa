(load "utilities.scm")

(define (cps-trans-if args cont)
  (let ((test (car args))
        (then (cadr args))
        (alt (if (null? (cddr args)) 'undefined (caddr args)))
        (v (gensym)))
    (cps-trans
     test
     (list 'lambda (list v)
           (list 'if v (cps-trans then cont)
                 (cps-trans alt (copy-tree cont)))))))

(define (cps-trans-begin args cont)
  (if (null? args)
      (list cont 'undefined)
      (cps-trans (car args)
                 (if (null? (cdr args))
                     cont
                     (let ((ig (gensym)))
                       (list 'lambda (list ig)
                             (cps-trans-begin (cdr args) cont)))))))

(define (cps-trans-lambda args cont)
  (let ((c (gensym)))
    (list cont
          (list 'lambda (cons c (car args))
                (cps-trans-begin (cdr args) c)))))

(define (cps-trans-set! args cont)
  (if (pair? (cadr args))
      (let ((v (gensym)))
        (cps-trans (cadr args)
                   (list 'lambda (list v)
                         (list cont (list 'set! (car args) v)))))
      (list cont (list* 'set! args))))

(define (cps-trans-evlis rargs rparam acc)
  (if (null? rargs)
      acc
      (cps-trans-evlis
       (cdr rargs) (cdr rparam)
       (if (pair? (car rargs))
           (cps-trans (car rargs) (list 'lambda (list (car rparam)) acc))
           acc))))

(define (cps-trans-proc fn args cont)
  (let* ((param (map (lambda (arg) (if (pair? arg) (gensym) arg))
                     (cons fn args)))
         (call (list* (car param) cont (cdr param))))
    (cps-trans-evlis (reverse (cons fn args)) (reverse param) call)))

(define (cps-trans-pair op args cont)
  (cond ((eq? (source-unvec op) 'quote) (list cont (cons op args)))
        ((eq? (source-unvec op) 'if) (cps-trans-if args cont))
        ((eq? (source-unvec op) 'begin) (cps-trans-begin args cont))
        ((eq? (source-unvec op) 'lambda) (cps-trans-lambda args cont))
        ((eq? (source-unvec op) 'set!) (cps-trans-set! args cont))
        (else (cps-trans-proc op args cont))))

(define (cps-trans exp cont)
  (if (pair? exp)
      (cps-trans-pair (car exp) (cdr exp) cont)
      (list cont exp)))

(define (cps exp)
  (let ((cont (gensym)))
    (cps-trans exp (list 'lambda (list cont) cont))))

