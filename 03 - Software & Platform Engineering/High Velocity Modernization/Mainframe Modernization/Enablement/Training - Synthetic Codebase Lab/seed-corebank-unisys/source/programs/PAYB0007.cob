       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAYB0007.
      *================================================================*
      * SYSTEM  : SISTEMA-CORE-UNISYS  (synthetic · graph-as-data)       *
      * LAYER   : BL       DOMAIN  : payments
      * ACCESS  : update (writes)
      * FAN-IN  : 2   FAN-OUT : 8   LOC approx: 403
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
       01  WS-AREA   PIC X(512).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Call dependencies (match the graph edges):
           CALL 'CHNB0061'.
           CALL 'CRDB0269'.
           CALL 'LONB0401'.
           CALL 'PAYB0283'.
           CALL 'PAYD0056'.
           CALL 'UCURRCNV'.
           CALL 'UDMSIIWR'.
           CALL 'UERRHND'.
           ENTER 'UDMSIIWR' USING WS-AREA RC-AREA.   *> writes to the system of record
           GOBACK.
