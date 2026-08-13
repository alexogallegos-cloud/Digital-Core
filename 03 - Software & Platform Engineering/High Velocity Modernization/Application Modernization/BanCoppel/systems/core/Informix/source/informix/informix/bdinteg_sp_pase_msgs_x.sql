CREATE PROCEDURE "informix".sp_pase_msgs_x(p_fecha_pase   DATE)
    RETURNING CHAR(5)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje,
              CHAR(1)  AS Reverso,
              CHAR(25) AS StorePro;              
               

    DEFINE vsqlerr               INTEGER; 

    DEFINE v_codigo_retorno	 CHAR(5);
    DEFINE v_mensaje	  	 CHAR(80);
    DEFINE v_reverso         CHAR(1);
    DEFINE v_store_pro       CHAR(25);

    DEFINE vrowid       INTEGER;
    DEFINE vd_valida       DATE;
    DEFINE vd_valida3      DATE;

    DEFINE v_f_depura     DATE;   --Variable para la depuracion del historico
    DEFINE v_f_respeta    DATE;
    DEFINE vi_valor    INTEGER;



          -- SET debug file TO "/tmp/pase_msgs.out";
          -- TRACE ON;

             LET v_codigo_retorno = "00000";
             LET v_mensaje = "Proceso Inicia Correctamente";
             LET v_reverso = '0';
             LET v_store_pro = 'sp_pase_msgs_x';


            SET ISOLATION TO dirty READ;
            SET LOCK MODE TO wait 3;

 BEGIN
   ON EXCEPTION SET vsqlerr          
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = "00030";
            LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";
            LET v_reverso = '1';         
            LET v_store_pro = 'sp_pase_msgs_x';
         RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
        END IF;
   END EXCEPTION;


         SELECT valor
           INTO vi_valor
           FROM si_param
           WHERE empresa = '001'
             AND cod_param = '111';
            IF NOT EXISTS (SELECT valor FROM si_param WHERE empresa = '001' AND cod_param = '111')
              THEN 
                    LET vi_valor = 15;
                    LET v_codigo_retorno = "00032";
                    LET v_mensaje = "Se Genero Error en si_param, No Existe Parametro 111!";
                    LET v_reverso = '1';
                    LET v_store_pro = 'sp_pase_msgs_x';                 
            END IF;   



    LET vrowid      = 0;
    LET vd_valida   = (p_fecha_pase + 1 units day);
    LET vd_valida3  = p_fecha_pase;
 
    LET v_f_respeta = (p_fecha_pase - vi_valor units day);
    LET v_f_depura  = (v_f_respeta);


	--*********************************************************--
	-- Creado por: Francisco Martinez Viveros	
	--Fecha Creacion: 05/JULIO/2010
    --Fecha Modifica: 21/JULIO/2010
	--Objetivo: Traspasa los mensajes diarios enviados a la tabla historica.    
	--*********************************************************--

           IF (p_fecha_pase is null) THEN
                    LET v_codigo_retorno = "00030";
                    LET v_mensaje = "Se genero error de Ejecucion, Verifique Fecha Nula!";
                    LET v_reverso = '1';
                    LET v_store_pro = 'sp_pase_msgs_x';
                RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
           END IF;

           IF (p_fecha_pase > vd_valida) THEN
                    LET v_codigo_retorno = "00031";
                    LET v_mensaje = "Se genero error de Ejecucion, Verifique Fecha Mayor!";
                    LET v_reverso = '1';
                    LET v_store_pro = 'sp_pase_msgs_x';
                RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
           END IF;



           FOREACH cursor_inserta WITH HOLD FOR
                 SELECT  {+index (si_mensajes_enviar idx_msgs_envdos)}
                          rowid
                    INTO vrowid            
                   FROM bdinteg:"informix".si_mensajes_enviar
                  WHERE date(f_mensaje) < p_fecha_pase
                  --TO_CHAR(f_mensaje,'%Y-%m-%d') = TO_CHAR(p_fecha_pase,'%Y-%m-%d')
                    AND enviado = 'V'
                    AND numcte <> ''
             BEGIN WORK;
                   INSERT INTO {+index (si_mensajes_enviar_his idx_msgs_envhis)} 
                     bdinteg:"informix".si_mensajes_enviar_his 
                      SELECT {+index (si_mensajes_enviar idx_msgs_envdos)} 
                      * FROM bdinteg:"informix".si_mensajes_enviar
                       WHERE rowid = vrowid;
                                                                   
                    DELETE FROM {+index (si_mensajes_enviar idx_msgs_envdos)}
                       bdinteg:"informix".si_mensajes_enviar
                        WHERE CURRENT OF cursor_inserta;
             COMMIT WORK;                           
               
           END FOREACH;


      -- FOREACH 2 ELIMINA DATOS DE 15 DIAS ANTERIORES A LA FECHA HOY EN EL HISTORICO
               FOREACH cursor_borra WITH HOLD FOR
                SELECT {+index (si_mensajes_enviar_his idx_msgs_envhis)} rowid                     
                  INTO vrowid  
                  FROM bdinteg:"informix".si_mensajes_enviar_his 
                 WHERE date(f_mensaje) <= v_f_depura  
                
                BEGIN WORK;
                   DELETE FROM {+index (si_mensajes_enviar_his idx_msgs_envhis)}
                     bdinteg:"informix".si_mensajes_enviar_his WHERE 
                    CURRENT OF cursor_borra;                                                                             
               COMMIT WORK;
             END FOREACH;  




               IF (v_reverso <> '0') THEN        
                   RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
               END IF;
                     LET v_codigo_retorno = "00000";
                     LET v_mensaje = "Proceso Pase de Mensajes, Termino Correctamente!";
                     LET v_reverso = '0';         
                     LET v_store_pro = 'sp_pase_msgs_x';   

       
           
 END;   --begin        
      RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
END PROCEDURE;