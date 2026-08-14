CREATE PROCEDURE "informix".sp_buscarclientespornombreyfecha(
                        pNombre1 CHAR(30),
                        pNombre2 CHAR(30),
                        pPaterno CHAR(30),
                        pMaterno CHAR(30),
                        pFechaNac DATE)

RETURNING CHAR(3) as cCodRet, CHAR(20) as num_cliente, CHAR(30) as nombre1, CHAR(30) as nombre2, CHAR(30) as apaterno, CHAR(30) as amaterno, DATE as fechaNac;

-- Definición de variables
DEFINE sql_err INTEGER;
DEFINE v_nombre1 CHAR(30);
DEFINE v_nombre2 CHAR(30);
DEFINE v_paterno CHAR(30);
DEFINE v_materno CHAR(30);
DEFINE v_numcte CHAR(20);
DEFINE v_fecha_nac DATE;
DEFINE v_cod_ret CHAR(4);

-- inicialización de variables

LET v_cod_ret = "000";

LET v_nombre1 = "";
LET v_nombre2 = "";
LET v_paterno = "";
LET v_materno = "";
LET v_fecha_nac = "";

LET v_numcte = "";

BEGIN
  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
   	     LET v_cod_ret = sql_err;
	     RETURN v_cod_ret,v_numcte, v_nombre1, v_nombre2, v_paterno, v_materno,v_fecha_nac;
     END IF;
   END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

   ---VALIDA PARAMETROS
        if ( pPaterno is null or pPaterno = "" ) then
           let pPaterno = "";
        else
--           let pPaterno = trim(pPaterno)||"*";
           let pPaterno = trim(pPaterno);
        end if;

        if ( pMaterno is null or pMaterno = "" ) then
           let pMaterno = "*";
        else
--           let pMaterno = trim(pMaterno)||"*";
           let pMaterno = trim(pMaterno);
        end if;

        if ( pNombre1 is null or pNombre1 = "" ) then
           let pNombre1 = "";
        else
           let pNombre1 = trim(pNombre1)||"*";
        end if;

        if ( pNombre2 is null or pNombre2 = "" ) then
           let pNombre2 = "*";
        else
           let pNombre2 = trim(pNombre2)||"*";
        end if;

		IF NVL(pFechaNac,'') <> '' THEN
			FOREACH
				SELECT nombre1,nombre2,apell_paterno,apell_materno,cl.numcte,pf.fecha_nac
				INTO v_nombre1,v_nombre2,v_paterno,v_materno,v_numcte,v_fecha_nac
				FROM bdinteg:si_ctepf pf, bdinteg:si_cliente cl
				WHERE cl.apell_paterno = ppaterno
				AND cl.apell_materno matches pmaterno
				AND cl.nombre1 matches pNombre1
				AND cl.nombre2 matches pNombre2
				AND pf.fecha_nac = pFechaNac
				AND cl.numcte = pf.numcte
				ORDER BY apell_paterno, apell_materno, nombre1, nombre2

				RETURN v_cod_ret, v_numcte, TRIM(v_nombre1), TRIM(v_nombre2), TRIM(v_paterno), TRIM(v_materno), v_fecha_nac WITH RESUME;
			END FOREACH;
		END IF;
END;
END PROCEDURE
DOCUMENT
'Sp sp_buscarclientespornombreyfecha',
'Sistema: Aclaraciones',
'AUTOR : Root',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 05/Junio/2018',
'VERSION: 1.0.0',
'BD    :  bdiaclaracion';

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