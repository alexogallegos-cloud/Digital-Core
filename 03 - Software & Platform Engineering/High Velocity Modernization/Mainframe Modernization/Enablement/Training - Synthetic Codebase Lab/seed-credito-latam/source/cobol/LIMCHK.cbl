       IDENTIFICATION DIVISION.
       PROGRAM-ID. LIMCHK.
      *================================================================*
      * PROPOSITO : Verifica el limite maximo permitido por producto    *
      * LLAMADO POR: CREDVAL                                           *
      * LLAMA A    : (ninguno)                                         *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-LIM-PERSONAL    PIC S9(13)V99 COMP-3 VALUE 500000.00.
           COPY LIMCPY.
       LINKAGE SECTION.
       01  LS-LIM-PARM.
           05  LS-LIM-TIPO    PIC X(02).
           05  LS-LIM-RESULT  PIC X(01).
           05  LS-LIM-MAXIMO  PIC S9(13)V99 COMP-3.
       PROCEDURE DIVISION USING LS-LIM-PARM.
       0000-PRINCIPAL.
           MOVE 'S' TO LS-LIM-RESULT.
      *----------------------------------------------------------------*
      * RN-005: Limite maximo de credito personal = 500,000 MXN        *
      *         (valor hardcoded en WS-LIM-PERSONAL)                   *
      *----------------------------------------------------------------*
           EVALUATE LS-LIM-TIPO
               WHEN 'PE'
                   MOVE WS-LIM-PERSONAL TO LS-LIM-MAXIMO
               WHEN 'HI'
                   MOVE 9999999.99 TO LS-LIM-MAXIMO
               WHEN 'AU'
                   MOVE 1500000.00 TO LS-LIM-MAXIMO
               WHEN OTHER
                   MOVE 'N' TO LS-LIM-RESULT
                   MOVE 0 TO LS-LIM-MAXIMO
           END-EVALUATE.
           GOBACK.