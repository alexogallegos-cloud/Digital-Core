      *================================================================*
      * COPYBOOK : CB-RETCODE   (libreria compartida CB- = Core Banking)*
      * SIGNIFICA: Codigo de retorno estandar entre programas           *
      * ACOPLAMIENTO: el mas usado del sistema (~todos los programas).   *
      *   Cambiar esta estructura impacta a casi todo el core.          *
      *================================================================*
       01  RETCODE-AREA.
           05  RC-CODE         PIC 9(04).
               88  RC-OK           VALUE 0000.
               88  RC-NOT-FOUND    VALUE 0100.
               88  RC-DB-ERROR     VALUE 9001.
               88  RC-SEC-DENIED   VALUE 9002.
           05  RC-MSG          PIC X(80).