       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPB0016.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : deposits
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 2   FAN-OUT : 8   LOC approx: 185
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-ASIENTO.
           COPY CB-CUENTA.
           COPY CB-ENCABEZADO.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
           COPY DEP-AUXILIAR.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'DEPB0180'.
           CALL 'DEPB0211'.
           CALL 'DEPB0246'.
           CALL 'DEPD0073'.
           CALL 'UDATECONV'.
           CALL 'UDMSIIRD'.
           CALL 'UERRHND'.
           CALL 'ULOGWRT'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
