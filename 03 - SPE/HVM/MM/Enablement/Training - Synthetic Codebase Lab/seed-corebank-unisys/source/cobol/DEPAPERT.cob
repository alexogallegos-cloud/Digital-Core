       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPAPERT.
      *================================================================*
      * DOMINIO  : deposits  ·  Capa: BL                               *
      * PROPOSITO: Apertura de cuenta de deposito                       *
      * CORRIDO POR: WFL DEPNOCT                                       *
      * LLAMA A   : UDMSIIWR (hub), UERRHND (hub), USECCHK (hub)        *
      * DB       : COREBANK (DMSII)                                    *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY CB-CUENTA.
           COPY CB-IMPORTE.
           COPY CB-RETCODE.
       01  WS-USUARIO          PIC X(08).
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
      *    Validacion de seguridad via hub compartido
           ENTER "USECCHK" USING WS-USUARIO RETCODE-AREA.
           IF NOT RC-OK
               ENTER "UERRHND" USING RETCODE-AREA
               STOP RUN
           END-IF.

           OPEN UPDATE COREBANK.
           BEGIN-TRANSACTION.

      *    Alta del registro de cuenta en DMSII
           MOVE 'VI' TO CTA-STATUS.
           MOVE 0    TO CTA-SALDO.
           STORE CUENTA.
           IF DMSTATUS NOT = 0
               MOVE 9001 TO RC-CODE
               ENTER "UERRHND" USING RETCODE-AREA
           END-IF.

      *    Persistencia auditada via hub
           ENTER "UDMSIIWR" USING CUENTA-AREA RETCODE-AREA.

           END-TRANSACTION.
           CLOSE COREBANK.
           STOP RUN.