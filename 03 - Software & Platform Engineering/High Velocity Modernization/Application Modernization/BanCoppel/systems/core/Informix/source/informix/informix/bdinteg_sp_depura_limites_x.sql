CREATE PROCEDURE "informix".sp_depura_limites_x(p_fecha_hoy  date)

    RETURNING CHAR(5)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje,
              CHAR(1)  AS Reverso,
              CHAR(25) AS StorePro;


   DEFINE p_mensaje   varchar(80);  
   DEFINE isam_err    smallint;
   DEFINE error_info  char(40);  
 

   DEFINE v_f_respeta    DATE;
   DEFINE v_f_depura     DATE;   
   DEFINE vi_valor    INTEGER;

   DEFINE v_codigo_retorno  CHAR(5);
   DEFINE v_mensaje	    CHAR(80);
   DEFINE v_reverso         CHAR(1);
   DEFINE v_store_pro       CHAR(25);
  
   DEFINE vsqlerr      INTEGER;

   DEFINE vrowid       INTEGER;     
	
	--*********************************************************--
	-- Creado por: Francisco Martinez Viveros	
	--Fecha: 07/JULIO/2010
    --Modificacion: 21/JULIO/2010
	--Objetivo: Diariamente depure la tabla si_limite_diario, 
    --de modo que conserve únicamente los últimos 15 días de información 
    --(con base en el campo f_operacion). 
	--*********************************************************--
      
   --    SET debug file TO "/tmp/depura_limite_x.out";
   --    TRACE ON;
              
            LET v_codigo_retorno = "00000";
            LET v_mensaje = "Proceso Inicio Correctamente!";
            LET v_reverso = '0';
            LET v_store_pro = 'sp_depura_limites_x';

        SET ISOLATION TO dirty READ;
        SET LOCK MODE TO wait 3;

    BEGIN
       ON EXCEPTION SET vsqlerr        
          IF vsqlerr <> 0 THEN      
               LET v_codigo_retorno = "00030";
               LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";
               LET v_reverso = '1';
               LET v_store_pro = 'sp_depura_limites_x';              
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
                    LET v_store_pro = 'sp_depura_limites_x';                 
            END IF;   


           LET vrowid      = 0;
           LET v_f_respeta = (p_fecha_hoy - vi_valor units day);
           LET v_f_depura  = (v_f_respeta);


          IF (p_fecha_hoy is null) then
                    LET v_codigo_retorno = "00030";
                    LET v_mensaje = "Se genero error de Ejecucion, Fecha Nula!";
                    LET v_reverso = '1';
                    LET v_store_pro = 'sp_depura_limites_x';
                RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
          END IF;

          IF (p_fecha_hoy <> today) then
                    LET v_codigo_retorno = "00031";
                    LET v_mensaje = "Se genero error de Ejecucion, Diferente de Hoy!";
                    LET v_reverso = '1';
                    LET v_store_pro = 'sp_depura_limites_x';
                RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
          END IF;

 
               FOREACH cursor_borra WITH HOLD FOR
                SELECT {+index (si_limite_diario idx_limite_ope)} rowid 
                  INTO vrowid  
                  FROM bdinteg:si_limite_diario
                 WHERE f_operacion <= v_f_depura  
                

                BEGIN WORK;
                   DELETE FROM {+index (si_limite_diario idx_limite_dia)}
                     bdinteg:si_limite_diario WHERE 
                    CURRENT OF cursor_borra;                                                                             
               COMMIT WORK;
             END FOREACH;  

                IF (v_reverso <> '0') THEN
                   RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
                 END IF;                 
               
                  LET v_codigo_retorno = "00000";
                  LET v_mensaje = "Proceso de Depuracion, Termino Correctamente!";
                  LET v_reverso = '0';
                  LET v_store_pro = 'sp_depura_limites_x';                                

    END;   --begin        
  RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;

END PROCEDURE;