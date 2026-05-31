       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTGEN.
      *================================================================*
      * PROPOSITO : Genera el reporte mensual de creditos por cliente   *
      * LLAMADO POR: PROCREDI (JCL STEP030)                            *
      * LLAMA A    : (ninguno)                                         *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-FIN-CURSOR      PIC X(01) VALUE 'N'.
           88  FIN-DATOS          VALUE 'S'.
      *    RN-007: solo se cuentan pagos del ano en curso. El ano se   *
      *    almacena con 2 digitos (HIST_ANIO) -> ventana de siglo      *
       01  WS-ANIO-CORTE      PIC 9(02) VALUE 26.
           COPY CREDCPY.
           COPY CLICPY.
       PROCEDURE DIVISION.
       0000-PRINCIPAL.
           EXEC SQL
               DECLARE C1 CURSOR FOR
                   SELECT CRED_NUM, CRED_CLIENTE, CRED_MONTO, CRED_STATUS
                     FROM CREDPROD.CREDITOS
                    WHERE CRED_STATUS = 'AP'
           END-EXEC.
           EXEC SQL OPEN C1 END-EXEC.
           PERFORM UNTIL FIN-DATOS
               EXEC SQL
                   FETCH C1 INTO :CRED-NUM, :CRED-CLIENTE,
                                 :CRED-MONTO, :CRED-STATUS
               END-EXEC
               IF SQLCODE = 100
                   MOVE 'S' TO WS-FIN-CURSOR
               ELSE
                   PERFORM 2000-IMPRIME-LINEA
               END-IF
           END-PERFORM.
           EXEC SQL CLOSE C1 END-EXEC.
           GOBACK.
       2000-IMPRIME-LINEA.
           DISPLAY 'CRED ' CRED-NUM ' CLI ' CRED-CLIENTE
                   ' MONTO ' CRED-MONTO.