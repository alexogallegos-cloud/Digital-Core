       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREDALT.
      *================================================================*
      * PROPOSITO : Da de alta un credito aprobado en la base           *
      * LLAMADO POR: PROCREDI (JCL STEP020)                            *
      * LLAMA A    : (ninguno)                                         *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-MONTO-MINIMO    PIC S9(09)V99 COMP-3 VALUE 1000.00.
           COPY CREDCPY.
       LINKAGE SECTION.
       01  LS-ALT-PARM.
           05  LS-ALT-CLIENTE PIC 9(10).
           05  LS-ALT-MONTO   PIC S9(11)V99 COMP-3.
           05  LS-ALT-TIPO    PIC X(02).
           05  LS-ALT-RESULT  PIC X(02).
       PROCEDURE DIVISION USING LS-ALT-PARM.
       0000-PRINCIPAL.
           MOVE 'OK' TO LS-ALT-RESULT.
      *----------------------------------------------------------------*
      * RN-008: El monto del credito no puede ser menor a 1,000 MXN    *
      *         (valor hardcoded en WS-MONTO-MINIMO)                   *
      *----------------------------------------------------------------*
           IF LS-ALT-MONTO < WS-MONTO-MINIMO
               MOVE 'ER' TO LS-ALT-RESULT
               GOBACK
           END-IF.
           MOVE LS-ALT-CLIENTE TO CRED-CLIENTE.
           MOVE LS-ALT-MONTO   TO CRED-MONTO.
           MOVE LS-ALT-TIPO    TO CRED-TIPO.
           MOVE 'AP'           TO CRED-STATUS.
           EXEC SQL
               INSERT INTO CREDPROD.CREDITOS
                   (CRED_CLIENTE, CRED_MONTO, CRED_TIPO, CRED_STATUS)
               VALUES
                   (:CRED-CLIENTE, :CRED-MONTO, :CRED-TIPO, :CRED-STATUS)
           END-EXEC.
           IF SQLCODE NOT = 0
               MOVE 'ER' TO LS-ALT-RESULT
           END-IF.
           GOBACK.