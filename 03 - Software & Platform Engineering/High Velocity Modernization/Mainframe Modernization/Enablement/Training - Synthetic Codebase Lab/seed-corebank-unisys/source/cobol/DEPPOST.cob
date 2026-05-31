       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPPOST.
      *================================================================*
      * DOMINIO  : deposits  ·  Capa: BL                               *
      * PROPOSITO: Posteo de movimiento + asiento contable al GL        *
      * CORRIDO POR: WFL DEPNOCT                                       *
      * ACOPLAMIENTO OCULTO: usa CB-ASIENTO -> acopla deposits con el GL *
      *   SIN un CALL a ningun programa de gl (ver answer-key).          *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-CUENTA.
           COPY CB-IMPORTE.
           COPY CB-ASIENTO.
           COPY CB-RETCODE.
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
           OPEN UPDATE COREBANK.
           BEGIN-TRANSACTION.

      *    Afecta saldo de la cuenta
           FIND CUENTA-POR-NUM AT CTA-NUM = CTA-NUM.
           ADD IMP-MONTO TO CTA-SALDO.
           MODIFY CUENTA.

      *    Genera el asiento contable correspondiente.
      *    La estructura ASIENTO-AREA (CB-ASIENTO) es el contrato compartido
      *    con el dominio gl: aqui se escribe, alla se concilia. No hay CALL
      *    entre dominios, pero estan acoplados por este copybook.
           MOVE CTA-NUM   TO GL-CUENTA-CONT.
           MOVE IMP-MONTO TO GL-CARGO.
           STORE ASIENTO-GL.

      *    Persistencia auditada via hub compartido
           ENTER "UDMSIIWR" USING ASIENTO-AREA RETCODE-AREA.

           END-TRANSACTION.
           CLOSE COREBANK.
           STOP RUN.