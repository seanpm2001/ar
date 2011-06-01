(= tcp-test-port* 50013)

(def tcp-connect (host port)
  (ail-code "(racket-let-values (((i o) (racket-tcp-connect host port)))
               (list i o))"))

(with (ready (make-semaphore)
       their-ip nil)

  (thread
   (w/socket s tcp-test-port*
     (racket-semaphore-post ready)
     (let (i o ip) (socket-accept s)
       (= their-ip ip)
       (disp "foo" o)
       (racket-flush-output o)
       (close i o))))

  (racket-semaphore-wait ready)
  (testis (let (i o) (tcp-connect "127.0.0.1" tcp-test-port*)
            (string (n-of 3 (readc i))))
          "foo")
  (testis their-ip "127.0.0.1"))
