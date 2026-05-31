      *================================================================*
      * COPYBOOK : CREDCPY                                             *
      * SISTEMA  : SISTEMA-CREDITO-LATAM                              *
      * USO      : CREDVAL, SCOVAL, CREDALT, RPTGEN                   *
      * DESC     : Estructura del registro de credito                 *
      *================================================================*
       01  CREDITO-RECORD.
           05  CRED-NUM           PIC 9(10).
           05  CRED-CLIENTE       PIC 9(10).
           05  CRED-MONTO         PIC S9(13)V99 COMP-3.
           05  CRED-TASA          PIC S9(03)V9(06) COMP-3.
           05  CRED-TIPO          PIC X(02).
               88  CRED-PERSONAL      VALUE 'PE'.
               88  CRED-HIPOTECARIO   VALUE 'HI'.
               88  CRED-AUTOMOTRIZ    VALUE 'AU'.
           05  CRED-STATUS        PIC X(02).
               88  CRED-APROBADO      VALUE 'AP'.
               88  CRED-RECHAZADO     VALUE 'RE'.
               88  CRED-PENDIENTE     VALUE 'PE'.
               88  CRED-CANCELADO     VALUE 'CA'.
           05  CRED-FECHA-APR     PIC 9(08).
           05  CRED-FECHA-VEN     PIC 9(08).
           05  CRED-PLAZO-MESES   PIC 9(03).