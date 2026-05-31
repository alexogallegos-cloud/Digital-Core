       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYB0036.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : payments
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 0   FAN-OUT : 6   LOC approx: 459
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ASIENTO.
           COPY CB-CLIENTE.
           COPY CB-ENCABEZADO.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
           COPY PAY-AUXILIAR.
           COPY PAY-CATALOGO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'PAYB0141'.
           CALL 'PAYB0433'.
           CALL 'PAYD0086'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIRD'.
           CALL 'UTRACE'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
