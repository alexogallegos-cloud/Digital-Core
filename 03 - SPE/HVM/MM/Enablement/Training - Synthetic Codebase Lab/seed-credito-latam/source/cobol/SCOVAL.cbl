       IDENTIFICATION DIVISION.
       PROGRAM-ID. SCOVAL.
      *================================================================*
      * PROPOSITO : Obtiene el score de buro de credito del cliente     *
      * LLAMADO POR: CREDVAL                                           *
      * LLAMA A    : (dinamico) programa de buro segun WS-PROG-BURO    *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-PROG-BURO       PIC X(08) VALUE 'BUROEXT1'.
       01  WS-TIMEOUT-SEG     PIC 9(02) VALUE 30.
       01  WS-BURO-PARM.
           05  WS-BURO-CLIENTE  PIC 9(10).
           05  WS-BURO-SCORE    PIC 9(03).
           05  WS-BURO-RC       PIC 9(02).
       LINKAGE SECTION.
       01  LS-SCO-PARM.
           05  LS-SCO-CLIENTE PIC 9(10).
           05  LS-SCO-RESULT  PIC 9(03).
       PROCEDURE DIVISION USING LS-SCO-PARM.
       0000-PRINCIPAL.
           MOVE LS-SCO-CLIENTE TO WS-BURO-CLIENTE.
      *----------------------------------------------------------------*
      * Llamada dinamica al buro externo: el target se resuelve en     *
      * runtime via WS-PROG-BURO (no resoluble por analisis estatico)  *
      *----------------------------------------------------------------*
           CALL WS-PROG-BURO USING WS-BURO-PARM.
           IF WS-BURO-RC = 0
               MOVE WS-BURO-SCORE TO LS-SCO-RESULT
           ELSE
      *        Si el buro no responde, score 0 -> revision manual      *
               MOVE 0 TO LS-SCO-RESULT
           END-IF.
           GOBACK.