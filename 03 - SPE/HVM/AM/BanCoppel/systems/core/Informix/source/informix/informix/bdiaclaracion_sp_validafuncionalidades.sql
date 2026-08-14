CREATE PROCEDURE "informix".sp_validafuncionalidades(pUsuario CHAR(50))
	RETURNING CHAR(5) AS codret,
		INTEGER AS sql_error,
		INTEGER AS id_permiso,
		CHAR(255) AS descripcion,
		CHAR(100) AS nombre;
			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdPermiso INTEGER;
	DEFINE cDescripcion CHAR(255);
	DEFINE cNombre CHAR(100);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET iIdPermiso = 0;
	LET cDescripcion = '';
	LET cNombre = '';
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = '002';
				RETURN cCodRet,iSqlErr,iIdPermiso,cDescripcion,cNombre;
			END IF;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validafuncionalidades.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT pe.pky_id_permiso,pe.descripcion,pe.nombre
			INTO iIdPermiso,cDescripcion,cNombre
			FROM "informix".acl_usuario AS us 
			INNER JOIN "informix".acl_perfil_usuario AS pu ON us.pky_usuario = pu.fky_usuario
			INNER JOIN "informix".acl_perfil_permiso AS pp ON pu.fky_id_perfil = pp.fky_id_perfil
			INNER JOIN "informix".acl_permiso AS pe ON pp.fky_id_permiso = pe.pky_id_permiso
			WHERE us.usuario = pUsuario
			AND pe.activo = 1
			--AND pe.fky_origen_permiso = 3
			ORDER BY pe.pky_id_permiso ASC
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,iSqlErr,iIdPermiso,cDescripcion,cNombre WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			RETURN cCodRet,iSqlErr,iIdPermiso,cDescripcion,cNombre;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 27/07/2018',
'SISTEMA: ACLARACIONES',
'FUNCIONALIDAD: CENTRO DE ATENCIÓN TELEFÓNICA (CAT)',
'DESCRIPCION: SPL encargado de la validación de las funcionalidades a las cuales tiene permiso de acceso el usuario en sesión.',
'BD: bdiaclaracion',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 27/07/2018',
'DESCRIPCION: Se quita la validación del campo fky_origen_permiso = 3.';

CREATE PROCEDURE "informix".sp_intento_solicitud_aclaracion(opcion INTEGER, pNumero_cliente	CHAR(10), pFecha_registro DATE)
		RETURNING CHAR(5) AS codret, 
		INTEGER AS intentos;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iIntentos INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iIntentos = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIntentos;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_intento_solicitud_aclaracion.out';
		--TRACE ON;
		
		IF pNumero_cliente = '' OR pFecha_registro = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIntentos;
		END IF;		
		
		IF(opcion = 1) THEN
			SELECT COUNT(*) 
			INTO iIntentos
			FROM bdiaclaracion:"informix".acl_intento_solicitud
			WHERE numero_cliente = pNumero_cliente
			AND fecha_registro = pFecha_registro;
			RETURN cCodRet, iIntentos;
		ELIF(opcion = 2) THEN
			INSERT INTO bdiaclaracion:"informix".acl_intento_solicitud(numero_cliente, fecha_registro)
			VALUES(pNumero_cliente, CURRENT);
			RETURN cCodRet, iIntentos;
		ELIF(opcion = 3) THEN
			SELECT COUNT(*)
			INTO iIntentos
			FROM bdiaclaracion:"informix".acl_aclaracion 
			WHERE  num_cliente = pNumero_cliente
			AND fky_estatus_aclaracion = 1 ;
			RETURN cCodRet, iIntentos;
		END IF;

	END;

END PROCEDURE
DOCUMENT 'AUTOR: URIEL CAAMAÃO MEJIA',
'FECHA: 12/09/2018',
'SISTEMA: ACLARACIONES',
'FUNCIONALIDAD: CENTRO DE ATENCIÃN TELEFÃNICA (CAT)',
'DESCRIPCION: NÃºmero de intentos de la aclaracion por cliente.',
'BD: bdiaclaracion';

CREATE PROCEDURE "informix".sp_obten_dias_permitidos(pIdAclaracion INTEGER)

RETURNING CHAR(6) AS cod_ret, INTEGER AS dias_permitidos, INTEGER AS regla_negocio;

    DEFINE cCodRet              CHAR(6);
    DEFINE sql_err              INTEGER;
    DEFINE isam_err             INTEGER;
	DEFINE cMensaje             CHAR(80);
	
	DEFINE vDiasPermitidos		INTEGER;
	DEFINE vReglaNegocio		INTEGER;
	
BEGIN

	ON EXCEPTION SET sql_err,isam_err,cMensaje
		--En caso de error los dÃ­as a considerar serÃ¡n 90
		LET cCodRet = sql_err;
		LET vDiasPermitidos = 90;
		
		RETURN cCodRet, vDiasPermitidos, vReglaNegocio;
	END EXCEPTION;

	LET cCodRet      			= '000';
	LET vDiasPermitidos 		= NULL;
	LET vReglaNegocio 			= NULL;
	
	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar debug
	--SET DEBUG FILE TO "/informix/traces/sp_obten_dias_permitidos"||"_"||""||pIdAclaracion||""||".out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--ObtenciÃ³n del total de dÃ­as permitidos
	
	SELECT rn.dias_permitidos, rn.pky_id_regla
		INTO vDiasPermitidos, vReglaNegocio
	FROM acl_aclaracion acl
	   INNER JOIN acl_producto pro on acl.fky_producto = pro.pky_producto
	   INNER JOIN acl_regla_negocio rn on acl.fky_tipo_evento = rn.fky_tipo_evento and rn.activo = 1 and 
		   pro.fky_tipo_producto = rn.fky_tipo_producto
	WHERE pky_aclaracion = pIdAclaracion;
	
	
	--Sino Obtiene la cantidad de dÃ­as permitidos se regresarÃ¡n 90 dÃ­as
	IF (vDiasPermitidos IS NULL) THEN
		LET vDiasPermitidos = 90;
		LET cCodRet	= '001';
	END IF;
	
	RETURN cCodRet, vDiasPermitidos, vReglaNegocio;
	
END;

END PROCEDURE
DOCUMENT
'Sp 			:	sp_obten_dias_permitidos',
'Sistema		:	Aclaraciones',
'AUTOR 			:	Bancoppel',
'Area			: 	Sistemas Administrativos y Perifericos',
'Coordinador	:	Norberto Corona Berruecos',
					'Gerencia de Mtto y Soporte IV',
'FECHA 			:	Julio/2018',
'VERSION		:	1.0.0',
'RQM			:	RQM 10 1029',
'BD    			:	bdiaclaracion';

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