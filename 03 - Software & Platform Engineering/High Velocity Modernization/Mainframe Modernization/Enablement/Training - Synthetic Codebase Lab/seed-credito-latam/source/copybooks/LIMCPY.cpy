      *================================================================*
      * COPYBOOK : LIMCPY                                             *
      * SISTEMA  : SISTEMA-CREDITO-LATAM                              *
      * USO      : LIMCHK                                            *
      * DESC     : Limites de credito por tipo de producto           *
      *================================================================*
       01  LIMITE-RECORD.
           05  LIM-TIPO           PIC X(02).
           05  LIM-MAXIMO         PIC S9(13)V99 COMP-3.
           05  LIM-MINIMO         PIC S9(13)V99 COMP-3.
           05  LIM-VIGENTE        PIC X(01).