CREATE PROCEDURE "informix".sp_reversa_acum_x( pfecha_oper  DATE,
					                 pnum_cliente CHAR(10), 
                                               pnum_cta     CHAR(16), 
                                               pid_opera    CHAR(2),
                                               pid_canal    CHAR(2),   -- 01:ATM, 03:PORTAL                                    
                                               pmonto_tran  money(16,2))

	RETURNING CHAR(5)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje,
              CHAR(1)  AS Reverso;
	
    DEFINE v_numcte 	        CHAR(10);	
    DEFINE v_cuenta             CHAR(16);
    DEFINE v_idopera            CHAR(2);
    DEFINE v_idcanal            CHAR(2);
    DEFINE v_fopera             DATE;
    DEFINE v_monto_tran         DECIMAL(18,2);
    DEFINE v_importe_dia        money(16,2);
   
	DEFINE vsqlerr				INTEGER;
  
    DEFINE v_codigo_retorno		CHAR(5);
    DEFINE v_mensaje			CHAR(80);
    DEFINE v_reverso            CHAR(1);
	
	--*********************************************************--
	-- Creado por: Francisco Martinez Viveros	
	-- Fecha: 29/JUNIO/2010
      -- Modif: 23/JULIO/2010 Version sin Sequential-Scan
	-- Objetivo: Decrementa el campo importe_dia de la tabla si_limite_diario 
      -- restándole el monto a reversar, para el cliente  cuenta  canal especificado.
	--*********************************************************--
	
	--SET DEBUG FILE TO '/tmp/sp_sp_reversa_acum_x.out';
	--	TRACE ON;

            LET vsqlerr = 0;
            LET v_numcte  = pnum_cliente;
            LET v_codigo_retorno = "00000";
            LET v_mensaje = "";
            LET v_reverso = '0';

            
              IF 
                (pnum_cliente IS NULL OR pnum_cliente = '') OR 
                (pnum_cta     IS NULL OR pnum_cta     = '') OR  
                (pid_opera    IS NULL OR pid_opera    = ''  OR LENGTH(pid_opera) <> 2) OR
                (pid_canal    IS NULL OR pid_canal    = ''  OR pid_canal <='00' OR LENGTH(pid_canal) <> 2) OR
                (pfecha_oper  IS NULL OR pfecha_oper  = '') AND
                (pmonto_tran  IS NULL OR pmonto_tran <= 0.00) THEN   
                    LET v_codigo_retorno = "00036";
                    LET v_mensaje = "Se genero error de Ejecucion, Verifique Datos!";
                    LET v_reverso = '1';
                RETURN v_codigo_retorno, v_mensaje, v_reverso;
              END IF;

              BEGIN
                  ON EXCEPTION SET vsqlerr
                      IF vsqlerr <> 0 THEN                                        
                          LET v_codigo_retorno = "00030";
                          LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";
                          LET v_reverso = '1';
                         RETURN v_codigo_retorno, v_mensaje, v_reverso;
                      END IF;
                    END EXCEPTION;

               SET ISOLATION TO DIRTY READ;
               SET LOCK MODE TO WAIT 3;

            IF pid_canal = '03' THEN
               LET v_idopera =  pid_opera;
            ELSE
               LET v_idopera = '00';
            END IF;

	
	       SELECT {+index (si_limite_diario idx_limite_dia)} 
                  numcte, cuenta, importe_dia 
                  INTO v_numcte, v_cuenta, v_importe_dia  
                  FROM bdinteg:si_limite_diario 
                 WHERE numcte = pnum_cliente
                   AND cuenta = pnum_cta
                   AND id_operacion = v_idopera
                   AND id_canal = pid_canal 
                   AND f_operacion = pfecha_oper;
                      

                 IF NOT EXISTS(SELECT {+index (si_limite_diario idx_limite_dia)} 
                                 numcte, cuenta, importe_dia 
                                 FROM bdinteg:si_limite_diario 
                                WHERE numcte = pnum_cliente
                                  AND cuenta = pnum_cta
                                  AND id_operacion = v_idopera
                                  AND id_canal = pid_canal 
                                  AND f_operacion = pfecha_oper) THEN                                   
                    LET v_codigo_retorno = "00037";
                    LET v_mensaje = "Registro a Reversar no existe!";
                    LET v_reverso = '1';
                	RETURN v_codigo_retorno, v_mensaje, v_reverso;              
                 END IF;    

                   LET v_fopera  = pfecha_oper; 
                   LET v_idcanal = pid_canal;
                   LET v_monto_tran = pmonto_tran;

				IF (pmonto_tran > 0 AND  pmonto_tran <= v_importe_dia) THEN
					UPDATE {+index (si_limite_diario idx_limite_dia)}
                           bdinteg:si_limite_diario                     
                       SET importe_dia = importe_dia - pmonto_tran 
                     WHERE numcte = pnum_cliente                           
                       AND cuenta = pnum_cta
                       AND id_operacion = v_idopera
                       AND id_canal = pid_canal 
                       AND f_operacion = pfecha_oper;
										
                        LET v_codigo_retorno = "00000";
                        LET v_mensaje = "Reverso Realizado con Exito";
                        LET v_reverso = '0';
                END IF;  -- IF pmonto_tran > 0 THEN    --pmonto_tran <= v_importe_dia

                IF (pmonto_tran > v_importe_dia) THEN
                    LET v_codigo_retorno = "00035";
                    LET v_mensaje = "El monto a reversar supera el limite diario registrado!";
                    LET v_reverso = '1';
                  RETURN v_codigo_retorno, v_mensaje, v_reverso;
                END IF;                
				
			RETURN v_codigo_retorno, v_mensaje, v_reverso;		
	END;
END PROCEDURE;