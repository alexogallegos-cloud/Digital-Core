       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYB0210.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : payments
      * ACCESS  : update (writes)
      * FAN-IN  : 1   FAN-OUT : 7   LOC approx: 312
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ENCABEZADO.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
           COPY PAY-AUXILIAR.
           COPY PAY-CATALOGO.
           COPY PAY-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CHNB0288'.
           CALL 'PAYB0176'.
           CALL 'PAYD0001'.
           CALL 'PAYD0100'.
           CALL 'UDMSIIWR'.
           CALL 'ULOGWRT'.
           CALL 'UPARSEDT'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
