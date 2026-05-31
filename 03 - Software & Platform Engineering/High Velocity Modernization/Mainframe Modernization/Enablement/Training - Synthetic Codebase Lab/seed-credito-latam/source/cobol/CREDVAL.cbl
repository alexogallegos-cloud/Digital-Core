       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREDVAL.
      *================================================================*
      * PROPOSITO : Valida si un cliente puede recibir un nuevo credito *
      * LLAMADO POR: PROCREDI (JCL STEP010)                            *
      * LLAMA A    : LIMCHK, SCOVAL                                    *
      *================================================================*
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-VARS.
           05  WS-RETURN-CODE     PIC 9(04) VALUE 0.
           05  WS-CRED-ACTIVOS    PIC 9(03) VALUE 0.
           05  WS-SALDO-PROM      PIC S9(13)V99 COMP-3.
           05  WS-LIMITE-CALC     PIC S9(13)V99 COMP-3.
           05  WS-FACTOR-LIMITE   PIC 9(02) VALUE 5.
           05  WS-SCORE           PIC 9(03) VALUE 0.
           05  WS-UMBRAL-SCORE    PIC 9(03) VALUE 600.
           05  WS-MAX-CREDITOS    PIC 9(03) VALUE 3.
       01  WS-LIM-PARM.
           05  WS-LIM-TIPO        PIC X(02).
           05  WS-LIM-RESULT      PIC X(01).
           05  WS-LIM-MAXIMO      PIC S9(13)V99 COMP-3.
       01  WS-SCO-PARM.
           05  WS-SCO-CLIENTE     PIC 9(10).
           05  WS-SCO-RESULT      PIC 9(03).
           COPY CLICPY.
           COPY CREDCPY.
       LINKAGE SECTION.
       01  LS-INPUT.
           05  LS-CLI-ID          PIC 9(10).
           05  LS-MONTO-SOL       PIC S9(11)V99 COMP-3.
           05  LS-TIPO-CRED       PIC X(02).
       01  LS-OUTPUT.
           05  LS-RESULTADO       PIC X(02).
           05  LS-MSG             PIC X(80).
           05  LS-LIMITE-DISP     PIC S9(11)V99 COMP-3.
       PROCEDURE DIVISION USING LS-INPUT LS-OUTPUT.
       0000-PRINCIPAL.
           PERFORM 1000-INICIA.
           PERFORM 2000-VALIDA-CLIENTE.
           IF WS-RETURN-CODE NOT = 0
               PERFORM 9000-FINALIZA
               GOBACK
           END-IF.
           PERFORM 3000-CUENTA-ACTIVOS.
           PERFORM 4000-CALCULA-LIMITE.
           PERFORM 5000-EVALUA-RIESGO.
           PERFORM 6000-DECIDE.
           PERFORM 9000-FINALIZA.
           GOBACK.

       1000-INICIA.
           MOVE 'PE' TO LS-RESULTADO.
           MOVE SPACES TO LS-MSG.
           MOVE 0 TO WS-RETURN-CODE.

      *----------------------------------------------------------------*
      * RN-006: El cliente debe existir y estar activo                 *
      *----------------------------------------------------------------*
       2000-VALIDA-CLIENTE.
           EXEC SQL
               SELECT CLI_SALDO_PROM, CLI_CREDITOS_ACT, CLI_STATUS,
                      CLI_SCORE_BURO
                 INTO :CLI-SALDO-PROM, :CLI-CREDITOS-ACT, :CLI-STATUS,
                      :CLI-SCORE-BURO
                 FROM CREDPROD.CLIENTES
                WHERE CLI_ID = :LS-CLI-ID
           END-EXEC.
           IF SQLCODE NOT = 0
               MOVE 'RE' TO LS-RESULTADO
               MOVE 'CLIENTE NO EXISTE' TO LS-MSG
               MOVE 8 TO WS-RETURN-CODE
           END-IF.
           IF CLI-STATUS NOT = 'AC'
               MOVE 'RE' TO LS-RESULTADO
               MOVE 'CLIENTE INACTIVO' TO LS-MSG
               MOVE 8 TO WS-RETURN-CODE
           END-IF.

      *----------------------------------------------------------------*
      * RN-001: Maximo 3 creditos activos por cliente                  *
      *----------------------------------------------------------------*
       3000-CUENTA-ACTIVOS.
           MOVE CLI-CREDITOS-ACT TO WS-CRED-ACTIVOS.
           IF WS-CRED-ACTIVOS > WS-MAX-CREDITOS
               MOVE 'RE' TO LS-RESULTADO
               MOVE 'EXCEDE MAXIMO DE CREDITOS ACTIVOS' TO LS-MSG
               MOVE 4 TO WS-RETURN-CODE
           END-IF.

      *----------------------------------------------------------------*
      * RN-002: Limite disponible = 5 x saldo promedio 6 meses         *
      *         (factor 5 hardcoded en WS-FACTOR-LIMITE)               *
      *----------------------------------------------------------------*
       4000-CALCULA-LIMITE.
           MOVE CLI-SALDO-PROM TO WS-SALDO-PROM.
           COMPUTE WS-LIMITE-CALC = WS-SALDO-PROM * WS-FACTOR-LIMITE.
           MOVE WS-LIMITE-CALC TO LS-LIMITE-DISP.

      *----------------------------------------------------------------*
      * RN-003: Creditos hipotecarios requieren validacion de buro     *
      * RN-004: Score < 600 pasa a revision manual (PE), no rechazo    *
      *----------------------------------------------------------------*
       5000-EVALUA-RIESGO.
           EVALUATE LS-TIPO-CRED
               WHEN 'HI'
                   MOVE LS-CLI-ID TO WS-SCO-CLIENTE
                   CALL 'SCOVAL' USING WS-SCO-PARM
                   MOVE WS-SCO-RESULT TO WS-SCORE
                   IF WS-SCORE < WS-UMBRAL-SCORE
                       MOVE 'PE' TO LS-RESULTADO
                       MOVE 'REVISION MANUAL POR SCORE BAJO' TO LS-MSG
                   END-IF
               WHEN 'PE'
                   MOVE CLI-SCORE-BURO TO WS-SCORE
               WHEN 'AU'
                   MOVE CLI-SCORE-BURO TO WS-SCORE
               WHEN OTHER
                   MOVE 'RE' TO LS-RESULTADO
                   MOVE 'TIPO DE CREDITO INVALIDO' TO LS-MSG
                   MOVE 4 TO WS-RETURN-CODE
           END-EVALUATE.

       6000-DECIDE.
           IF WS-RETURN-CODE NOT = 0
               GO TO 6000-EXIT
           END-IF.
           IF LS-RESULTADO = 'PE'
               GO TO 6000-EXIT
           END-IF.
           MOVE LS-TIPO-CRED TO WS-LIM-TIPO.
           CALL 'LIMCHK' USING WS-LIM-PARM.
           IF LS-MONTO-SOL > LS-LIMITE-DISP
               MOVE 'RE' TO LS-RESULTADO
               MOVE 'MONTO EXCEDE LIMITE DISPONIBLE' TO LS-MSG
           ELSE
               IF WS-LIM-RESULT = 'N'
                   MOVE 'RE' TO LS-RESULTADO
                   MOVE 'MONTO EXCEDE LIMITE DE PRODUCTO' TO LS-MSG
               ELSE
                   MOVE 'AP' TO LS-RESULTADO
                   MOVE 'CREDITO APROBADO' TO LS-MSG
               END-IF
           END-IF.
       6000-EXIT.
           EXIT.

       9000-FINALIZA.
           DISPLAY 'CREDVAL RESULTADO=' LS-RESULTADO ' MSG=' LS-MSG.