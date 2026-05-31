      *================================================================*
      * COPYBOOK : CB-IMPORTE   (libreria compartida CB- = Core Banking)*
      * SIGNIFICA: Importe monetario estandar (monto, moneda, signo)    *
      * ACOPLAMIENTO: compartido por muchos programas en deposits,      *
      *   payments, loans, cards, gl (ver answer-key/                   *
      *   ground-truth-copybook-coupling.md)                            *
      *================================================================*
       01  IMPORTE-AREA.
           05  IMP-MONTO       PIC S9(13)V99 COMP.
           05  IMP-MONEDA      PIC X(03).
           05  IMP-SIGNO       PIC X(01).