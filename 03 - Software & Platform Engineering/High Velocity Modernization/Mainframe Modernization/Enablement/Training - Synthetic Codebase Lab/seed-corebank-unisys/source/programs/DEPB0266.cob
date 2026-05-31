       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPB0266.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : deposits
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 2   FAN-OUT : 6   LOC approx: 173
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
           COPY DEP-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'DEPB0196'.
           CALL 'DEPB0227'.
           CALL 'DEPD0088'.
           CALL 'DEPD0090'.
           CALL 'UDMSIIRD'.
           CALL 'ULOGWRT'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
