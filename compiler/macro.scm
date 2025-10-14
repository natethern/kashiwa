(define (quote-expand args)
  (define (expand-list lst acc)
    (cond ((pair? lst)
           (expand-list (cdr lst) (cons (quote-expand (list (car lst))) acc)))
          ((null? lst) (cons 'list (reverse acc)))
          (else
           (cons 'list* (reverse (cons (quote-expand (list lst)) acc))))))
  (if (pair? (car args))
      (expand-list (car args) '())
      (cons 'quote args)))

(define (macroexpand exp)
  (cond ((not (pair? exp)) exp)
        ;; syntax
        ((eq? (source-unvec (car exp)) 'quote)
         (quote-expand (cdr exp)))
        ((eq? (source-unvec (car exp)) 'if)
         (list* 'if (macroexpand (cadr exp)) (macroexpand (caddr exp))
                (if (null? (cadddr exp))
                    '()
                    (list (macroexpand (cadddr exp))))))
        ((eq? (source-unvec (car exp)) 'lambda)
         (list* 'lambda (cadr exp) (map macroexpand (cddr exp))))
        ((eq? (source-unvec (car exp)) 'set!)
         (list 'set! (cadr exp) (macroexpand (caddr exp))))
        ;; procedure
        (else (map macroexpand exp))))

