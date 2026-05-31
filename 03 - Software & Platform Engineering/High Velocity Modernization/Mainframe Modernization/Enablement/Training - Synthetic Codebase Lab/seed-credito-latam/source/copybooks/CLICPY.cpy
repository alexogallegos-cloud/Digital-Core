      *================================================================*
      * COPYBOOK : CLICPY                                             *
      * SISTEMA  : SISTEMA-CREDITO-LATAM                              *
      * USO      : CREDVAL, CREDALT, RPTGEN                          *
      * DESC     : Estructura del registro de cliente                 *
      *================================================================*
       01  CLIENTE-RECORD.
           05  CLI-ID             PIC 9(10).
           05  CLI-NOMBRE         PIC X(40).
           05  CLI-RFC            PIC X(13).
           05  CLI-SALDO-PROM     PIC S9(13)V99 COMP-3.
           05  CLI-CREDITOS-ACT   PIC 9(03).
           05  CLI-STATUS         PIC X(02).
               88  CLI-ACTIVO         VALUE 'AC'.
               88  CLI-BAJA           VALUE 'BA'.
           05  CLI-SCORE-BURO     PIC 9(03).