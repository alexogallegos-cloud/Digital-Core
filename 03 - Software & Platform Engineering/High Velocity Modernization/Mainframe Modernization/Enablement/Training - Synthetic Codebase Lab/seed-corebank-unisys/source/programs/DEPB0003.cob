       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPB0003.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : deposits
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 0   FAN-OUT : 8   LOC approx: 488
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ASIENTO.
           COPY CB-CLIENTE.
           COPY CB-CUENTA.
           COPY CB-ENCABEZADO.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'DEPB0033'.
           CALL 'DEPB0082'.
           CALL 'DEPD0088'.
           CALL 'RPTB0055'.
           CALL 'UCURRCNV'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIRD'.
           CALL 'UTRACE'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
