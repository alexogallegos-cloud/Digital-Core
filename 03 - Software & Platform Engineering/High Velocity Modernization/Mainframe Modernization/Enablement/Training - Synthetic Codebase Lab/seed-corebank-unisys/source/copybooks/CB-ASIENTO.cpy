      *================================================================*
      * COPYBOOK : CB-ASIENTO   (libreria compartida CB- = Core Banking)*
      * SIGNIFICA: Asiento contable (posting al General Ledger)         *
      * ACOPLAMIENTO OCULTO: compartido por deposits, gl, loans,        *
      *   payments. Acopla esos 4 dominios al GL aunque NO haya un CALL  *
      *   entre ellos -> el revelador nº1 del seed.                     *
      *================================================================*
       01  ASIENTO-AREA.
           05  GL-ASIENTO      PIC 9(15).
           05  GL-CUENTA-CONT  PIC X(10).
           05  GL-CARGO        PIC S9(13)V99 COMP.
           05  GL-ABONO        PIC S9(13)V99 COMP.
           05  GL-FECHA        PIC 9(08).