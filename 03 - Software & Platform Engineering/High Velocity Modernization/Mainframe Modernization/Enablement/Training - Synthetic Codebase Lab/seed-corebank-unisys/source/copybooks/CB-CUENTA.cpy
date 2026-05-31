      *================================================================*
      * COPYBOOK : CB-CUENTA    (libreria compartida CB- = Core Banking)*
      * SIGNIFICA: Maestro de cuenta bancaria                           *
      * ACOPLAMIENTO: compartido por programas de deposits, gl, loans   *
      *================================================================*
       01  CUENTA-AREA.
           05  CTA-NUM         PIC 9(12).
           05  CTA-CLIENTE     PIC 9(10).
           05  CTA-PRODUCTO    PIC X(04).
           05  CTA-SALDO       PIC S9(13)V99 COMP.
           05  CTA-MONEDA      PIC X(03).
           05  CTA-STATUS      PIC X(02).
               88  CTA-VIGENTE     VALUE 'VI'.
               88  CTA-CANCELADA   VALUE 'CA'.