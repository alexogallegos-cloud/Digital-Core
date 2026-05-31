       IDENTIFICATION DIVISION.
       PROGRAM-ID. LONB0049.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : loans
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 0   FAN-OUT : 5   LOC approx: 864
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
           COPY CB-RETCODE.
           COPY LON-AUXILIAR.
           COPY LON-CATALOGO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'LOND0064'.
           CALL 'LOND0102'.
           CALL 'UDMSIIRD'.
           CALL 'UERRHND'.
           CALL 'ULOGWRT'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
