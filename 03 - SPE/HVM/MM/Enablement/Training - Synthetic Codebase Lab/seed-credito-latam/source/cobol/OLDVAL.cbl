       IDENTIFICATION DIVISION.
       PROGRAM-ID. OLDVAL.
      *================================================================*
      * PROPOSITO : Validacion de credito (version anterior, 2009)      *
      * LLAMADO POR: --- NINGUN PROGRAMA NI JCL LO REFERENCIA ---       *
      * NOTA      : Reemplazado por CREDVAL. Quedo en la libreria.      *
      *             [DEAD CODE PLANTADO]                               *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-LIMITE-VIEJO    PIC S9(11)V99 COMP-3 VALUE 300000.00.
           COPY CREDCPY.
       LINKAGE SECTION.
       01  LS-OLD-PARM.
           05  LS-OLD-CLIENTE PIC 9(10).
           05  LS-OLD-MONTO   PIC S9(11)V99 COMP-3.
           05  LS-OLD-RESULT  PIC X(02).
       PROCEDURE DIVISION USING LS-OLD-PARM.
       0000-PRINCIPAL.
           IF LS-OLD-MONTO > WS-LIMITE-VIEJO
               MOVE 'RE' TO LS-OLD-RESULT
           ELSE
               MOVE 'AP' TO LS-OLD-RESULT
           END-IF.
           GOBACK.