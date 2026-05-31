       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYO0005.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : ONLINE   DOMAIN  : payments
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 0   FAN-OUT : 2   LOC approx: 344
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-CLIENTE.
           COPY CB-ENCABEZADO.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
           COPY PAY-AUXILIAR.
           COPY PAY-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'PAYB0121'.
           CALL 'PAYB0303'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
