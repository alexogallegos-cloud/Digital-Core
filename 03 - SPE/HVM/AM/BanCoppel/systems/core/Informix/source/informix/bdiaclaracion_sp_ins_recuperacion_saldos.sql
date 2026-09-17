CREATE PROCEDURE "informix".sp_ins_recuperacion_saldos(e_fky_aclaracion INTEGER, 
                                                        e_folio_csuac VARCHAR(11), 
                                                        e_total_abono MONEY,
                                                        e_abono_recuperado MONEY,
                                                        e_abono_afectado MONEY,    
                                                        e_total_comision MONEY,
                                                        e_comision_recuperada MONEY,
                                                        e_comision_afectada MONEY,
                                                        e_total_iva MONEY, 
                                                        e_iva_recuperada MONEY,
                                                        e_iva_afectada MONEY,
                                                        --RQM 287-3
                                                        e_total_interes MONEY,
                                                        e_interes_recuperado MONEY,
                                                        e_interes_afectado MONEY,
                                                        --Fin
                                                        e_f_recuperacion DATE,    
                                                        e_fc_recuperacion DATETIME YEAR to FRACTION(5),     
                                                        e_fi_recuperacion DATETIME YEAR to FRACTION(5),    
                                                        e_fa_recuperacion DATETIME YEAR to FRACTION(5),

                                                        e_fin_recuperacion DATETIME YEAR to FRACTION(5),
                                                        
                                                        e_abono_irrecuperable SMALLINT,    
                                                        e_cron_activo SMALLINT,       
                                                        e_exito_ca SMALLINT, 
                                                        e_exito_cc SMALLINT, 
                                                        e_exito_ci SMALLINT,

                                                        e_exito_cin SMALLINT,

                                                        e_rec_trans INTEGER)    

RETURNING CHAR(3) as s_CodRet, CHAR(30) as s_Mensaje;

    /* Variables Salida*/
    DEFINE s_CodRet                 CHAR(3);  
    DEFINE s_Mensaje                CHAR(30);
  
  
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

   BEGIN

       --> Variables Salida
       LET s_CodRet   = '000';
       LET s_Mensaje  = 'Inserción Correcta';

       IF e_fky_aclaracion IS NULL OR e_fky_aclaracion = '' OR e_fky_aclaracion == 0 THEN   
          LET s_CodRet='001';
          LET s_Mensaje='La columna e_fky_aclaracion es null vacia o igual a cero';
          RETURN s_CodRet,s_Mensaje;
       END IF;

       IF e_folio_csuac IS NULL OR e_folio_csuac = '' OR e_folio_csuac == 0 THEN  
          LET s_CodRet='002';
          LET s_Mensaje='La columna e_folio_csuac es null o igual a cero';
          RETURN s_CodRet,s_Mensaje;
       END IF;

       IF e_total_abono IS NULL THEN  
          LET s_CodRet='003';
          LET s_Mensaje='La columna e_total_abono es null';
          RETURN s_CodRet,s_Mensaje;
       END IF;

       IF e_abono_recuperado IS NULL THEN   
          LET s_CodRet='004';
          LET s_Mensaje='La columna i_abono_recuperado es null';
          RETURN s_CodRet,s_Mensaje;
       END IF;

       IF e_total_comision IS NULL THEN   
          LET s_CodRet='005';
          LET s_Mensaje='La columna e_total_comision es null';
          RETURN s_CodRet,s_Mensaje;
       END IF;

       IF e_comision_recuperada IS NULL THEN  
          LET s_CodRet='006';
          LET s_Mensaje='La columna i_comision_recuperada es null';
          RETURN s_CodRet,s_Mensaje;
       END IF;

       IF e_total_iva IS NULL THEN  
          LET s_CodRet='007';
          LET s_Mensaje='La columna e_total_iva es null';
          RETURN s_CodRet,s_Mensaje;
       END IF;

       IF e_iva_recuperada IS NULL THEN   
          LET s_CodRet='008';
          LET s_Mensaje='La columna i_iva_recuperada es null';
          RETURN s_CodRet,s_Mensaje;
       END IF;

       IF e_cron_activo IS NULL THEN  
          LET s_CodRet='009';
          LET s_Mensaje='La columna i_cron_activo es null';
          RETURN s_CodRet,s_Mensaje;
       END IF;

       IF e_abono_irrecuperable IS NULL THEN  
          LET s_CodRet='010';
          LET s_Mensaje='La columna i_abono_irrecuperable es null';
          RETURN s_CodRet,s_Mensaje;
       END IF;

       IF e_exito_ca IS NULL THEN   
          LET s_CodRet='011';
          LET s_Mensaje='La columna e_exito_ca es null';
          RETURN s_CodRet,s_Mensaje;
       END IF;

       IF e_exito_cc IS NULL THEN   
          LET s_CodRet='012';
          LET s_Mensaje='La columna e_exito_cc es null';
          RETURN s_CodRet,s_Mensaje;
       END IF;

       IF e_exito_ci IS NULL THEN   
          LET s_CodRet='013';
          LET s_Mensaje='La columna e_exito_ci es null';
          RETURN s_CodRet,s_Mensaje;
       END IF;

       IF e_rec_trans IS NULL OR e_rec_trans = 0 THEN
          LET s_CodRet='014';
          LET s_Mensaje='La columna e_rec_trans es null o 0';
          RETURN s_CodRet,s_Mensaje;
       END IF;
       -- RQM 287/3
       IF e_total_interes IS NULL THEN
          LET s_CodRet='015';
          LET s_Mensaje='La columna e_total_intereses es null o 0';
          RETURN s_CodRet, s_Mensaje;
       END IF;
       IF e_interes_recuperado IS NULL THEN
          LET s_CodRet='016';
          LET s_Mensaje='La columna e_interes_recuperado es null o 0';
       END IF;

    -- ***********************************************************************************************************************************************
        IF e_total_iva == 0 THEN

            LET e_total_iva = e_total_comision * 0.16;
            UPDATE bdiaclaracion:acl_aclaracion SET fky_estatus_flujo_causa = 22 WHERE folio_csuac=e_folio_csuac;
        END IF;           
                  
                INSERT INTO bdiaclaracion:acl_recuperacion_saldos VALUES (bdiaclaracion:RECUPERACION_SALDOS_SEQ.NEXTVAL,
                                                                          e_fky_aclaracion,     
                                                                          e_folio_csuac,     
                                                                          e_total_abono,    
                                                                          e_abono_recuperado,
                                                                          e_abono_afectado,
                                                                          e_total_comision,     
                                                                          e_comision_recuperada,
                                                                          e_comision_afectada,  
                                                                          e_total_iva,     
                                                                          e_iva_recuperada,
                                                                          e_iva_afectada,

                                                                          e_total_interes,
                                                                          e_interes_recuperado,
                                                                          e_interes_afectado,

                                                                          e_f_recuperacion,    
                                                                          e_fc_recuperacion,     
                                                                          e_fi_recuperacion,     
                                                                          e_fa_recuperacion,

                                                                          e_fin_recuperacion,     
                                                                          
                                                                          e_abono_irrecuperable,    
                                                                          e_cron_activo,     
                                                                          e_exito_ca,    
                                                                          e_exito_cc,     
                                                                          e_exito_ci,

                                                                          e_exito_cin,

                                                                          e_rec_trans);
                                  LET s_CodRet   = '000';
                                  LET s_Mensaje  = 'Insercion Correcta';                                                                    
            UPDATE bdiaclaracion:acl_movimiento 
            SET recuperacion= 1 
            WHERE folio_csuac = e_folio_csuac AND exitoso=0;                                                    

-- ***********************************************************************************************************************************************

   RETURN s_CodRet,s_Mensaje;
   END;
        
END PROCEDURE;