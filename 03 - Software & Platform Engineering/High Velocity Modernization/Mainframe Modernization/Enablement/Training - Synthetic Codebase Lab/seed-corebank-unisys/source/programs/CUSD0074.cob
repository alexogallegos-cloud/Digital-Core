       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSD0074.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : DA       DOMAIN  : customer
      * ACCESS  : inquiry (read-only)
      * FAN-IN  : 3   FAN-OUT : 2   LOC approx: 163
      * NOTE    : generated skeleton; COPY = copybook-usage, CALL = graph
      *           edges. The real business logic is synthetic.            *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-CLIENTE.
           COPY CB-ENCABEZADO.
           COPY CB-RETCODE.
           COPY CUS-AUXILIAR.
           COPY CUS-CATALOGO.
           COPY CUS-PARAMETRO.
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'UDMSIIRD'.
           CALL 'ULOGWRT'.
           ENTER 'UDMSIIRD' USING WS-AREA RC-AREA.   *> inquiry only
           GOBACK.
