CREATE PROCEDURE "informix".sp_graba_respuesta_conscoppel(	pEstado SMALLINT,
															pNumcte_ref CHAR(20),
															pPuntualidad CHAR(3),
															pEficiencia DECIMAL(5,2),
															pLimitecredito INTEGER,
															pMeseshist INTEGER,
															pSdoropa INTEGER,
															pSdomuebles INTEGER,
															pSdoprestamos INTEGER,
															pVdoropa INTEGER,
															pVdomuebles INTEGER,
															pVdoprestamos INTEGER,
															pAbonomesropa INTEGER,
															pAbonomesmuebles INTEGER,
															pAbonomesprestamos INTEGER,
															pSitespecial CHAR(2),
															pCausa SMALLINT,
															pCreditoaut INTEGER,	
															pFecha_ult_compra CHAR(13))
	RETURNING
		CHAR(6) AS COD_RET,
		CHAR(80) AS DESCRIPCION; 

		---DECLARACIONES
		DEFINE iSqlErr			INTEGER;
		DEFINE iIsamErr			INTEGER;
		DEFINE cErrorInfo		CHAR(80);
		DEFINE cCodRet			CHAR(6);
		DEFINE cMensajeRet		CHAR(80);
		DEFINE cNumSolicitud    CHAR(20);
		DEFINE cNumCte			CHAR(20);
		DEFINE sMaxIntentos     SMALLINT;
		DEFINE sNumIntentos     SMALLINT;
		DEFINE dtFechaHoy		DATE;
		DEFINE dtFechaAnt       DATE;
		
		---INICIALIZACIONES
		LET iSqlErr				= 0;
		LET iIsamErr			= 0;
		LET cErrorInfo			= '';
		LET cCodRet				= '000000';
		LET cMensajeRet			= 'Proceso Exitoso';
		LET cNumSolicitud		= '';
		LET cNumCte				= '';
		LET sMaxIntentos     	= 0;
		LET sNumIntentos     	= 0;
		LET dtFechaHoy          = DATE(1);
		LET dtFechaAnt          = DATE(1);

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		   IF iSqlErr != 0 THEN
			  LET cCodRet = iSqlErr;
			  LET cMensajeRet = cErrorInfo;
			  
			 IF (SELECT count(folio_movil) 
				FROM bdisolic:"informix".ss_solicitudes_movil							
				WHERE 	empresa  = pEmpresa 
				AND  numcte_cop =  pNumcte_ref AND  status <> '3') > 0 THEN

				UPDATE "informix".ss_resum_scor_fin
				SET status = '3'
				WHERE empresa =  '001'
				AND numcte_cop =  pNumcte_ref
				AND  status <> '3';
			 
			 END IF;
			  
			  RETURN cCodRet, cMensajeRet;
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		
		
		---SET DEBUG FILE TO "/respaldosbd/Malena/sp_graba_respuesta_conscoppel.out";
		---TRACE ON;
		
		--OBTENER FECHA ACTUAL
		SELECT fecha_hoy, monthadd(fecha_hoy,-1)
		INTO dtFechaHoy,dtFechaAnt
		FROM "informix".sd_fechas;	
		
		--OBTENER RANGO DE FECHA ANTERIOR, EL CUAL SERÁ DE UN MES.
		--LET dtFechaAnt= dtFechaHoy- 1 UNITS MONTH;
			
		--OBTENER NUMERO DE CLIENTE DE BANCO Y NUMERO DE SOLICITUD
		SELECT numcte,num_solicitud 
		INTO cNumCte,cNumSolicitud
		FROM "informix".sd_consultar_infoctecoppel
		WHERE empresa = '001'
			AND numcte_ref=NVL(pNumcte_ref,'')		
			AND fecha_insert = (SELECT MAX(fecha_insert) 
								FROM "informix".sd_consultar_infoctecoppel
								WHERE empresa = '001'
									AND numcte_ref=NVL(pNumcte_ref,'')								
									--AND fecha_insert BETWEEN dtFechaAnt AND dtFechaHoy
									AND status_envio=0	
								)
			AND status_envio=0;
				
		--VALIDACION DE PARAMETRO DE ENTRADA
		IF pEstado = 0 THEN
			LET cCodRet                  = '000001';
			LET cMensajeRet              = 'Parametro pEstado valor no valido';
			RETURN cCodRet, cMensajeRet;
		ELIF pEstado <> 1 THEN
			--OBTENER NUMERO DE INTENTOS MAXIMOS DEL ERROR DEVUELTO
			SELECT intentos_max
			INTO sMaxIntentos
			FROM "informix".sd_catalogo_error_ctecoppel
			WHERE estado=pEstado;
			
			--OBTENER NUMERO DE INTENTOS DE CONSULTA DEL CLIENTE FALLIDOS
			SELECT COUNT(num_solicitud)
			INTO sNumIntentos
			FROM "informix".sd_bitacora_error_ctecoppel
			WHERE numcte_ref=NVL(pNumcte_ref,'')
			AND fecha_insert BETWEEN dtFechaAnt AND dtFechaHoy;
		
			--VERIFICAR SI YA SE EXCEDIÓ EL NUMERO DE INTENTOS MAXIMOS 
			IF NVL(sNumIntentos,0) >= NVL(sMaxIntentos,0) THEN 				
				UPDATE "informix".sd_consultar_infoctecoppel 
				SET fecha_respuesta=dtFechaHoy,hora_respuesta=CURRENT HOUR TO FRACTION(3), status_envio=3 
				WHERE numcte_ref=NVL(pNumcte_ref,'');				
				--SI  SE EXCEDIO EL NUMERO DE INTENTOS MAXIMOS SE INSERTA EN LA TABLA QUE GRABA RESPUESTA PARA CONTINUAR CON EL FLUJO DE LA SOLICITUD.
				INSERT INTO "informix".sd_graba_respuesta_conscoppel(empresa,numcte,numcte_ref,num_solicitud,puntualidad,eficiencia,limitecredito,meseshist,sdoropa,sdomuebles,sdoprestamos,vdoropa,vdomuebles,vdoprestamos,abonomesropa,abonomesmuebles,abonomesprestamos,sitespecial,causa,creditoaut,fecha_ult_compra,fecha_insert,sin_respuesta) 
				VALUES('001',cNumCte,pNumcte_ref,cNumSolicitud,'',0,0,0,0,0,0,0,0,0,0,0,0,'',0,0,		 '',dtFechaHoy,0);							
			ELSE
				--SI AUN NO SE EXCEDE EL INTENTO MAXIMO SE VUELVE A REGISTRAR EN LA TABLA DE BITACORA DE ERROR.
				INSERT INTO "informix".sd_bitacora_error_ctecoppel(empresa,numcte,numcte_ref,num_solicitud,estado,fecha_insert,hora_insert)
				VALUES('001',cNumCte,pNumcte_ref,cNumSolicitud,pEstado,dtFechaHoy,CURRENT HOUR TO FRACTION(3));					
			END IF;
		ELIF pEstado = 1 THEN
				--SI EL ESTADO DEVUELTO FUE ESTADO CORRECTO SE GRABA LA INFORMACION RECIBIDA POR EL SERVICIO EN LA TABLA QUE GRABA LA RESPUESTA.
				UPDATE "informix".sd_consultar_infoctecoppel 
				SET fecha_respuesta=dtFechaHoy,hora_respuesta=CURRENT HOUR TO FRACTION(3),status_envio=1
				WHERE numcte_ref=NVL(pNumcte_ref,'');
				
				INSERT INTO "informix".sd_graba_respuesta_conscoppel(empresa,numcte,numcte_ref,num_solicitud,puntualidad,eficiencia,limitecredito,meseshist,sdoropa,sdomuebles,sdoprestamos,vdoropa,vdomuebles,vdoprestamos,abonomesropa,abonomesmuebles,abonomesprestamos,sitespecial,causa,creditoaut,fecha_ult_compra,fecha_insert,sin_respuesta) 
				VALUES('001',cNumCte,pNumcte_ref,cNumSolicitud,pPuntualidad,pEficiencia,pLimitecredito,pMeseshist,pSdoropa,pSdomuebles,pSdoprestamos,pVdoropa,pVdomuebles,pVdoprestamos,pAbonomesropa,pAbonomesmuebles,pAbonomesprestamos,pSitespecial,pCausa,pCreditoaut,pFecha_ult_compra,dtFechaHoy,1);
				
		END IF;
		
		RETURN cCodRet, cMensajeRet;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para almacenar información de la respuesta de la consulta a coppel mediante el servicio', 
'AUTOR: Maria Elena Angulo',
'FECHA: Noviembre 2011',
'DESCRIPCION: Se incluye filtro de status_envio =0 y la MAX(fecha_insert) de la tabla sd_consultar_infoctecoppel para con esto asegurar que se retornara un solo registro y que no marque error el procedimiento.',
'			  cambiar el orden de acciones, ahora primero se actualizara la tabla ?sd_consultar_infoctecoppel? y despues se hara el insert a la tabla ?sd_graba_respuesta_conscoppel? ya que el trigger que detona',
' 			  esta ultima tabla en algunas ocaciones a presentado error el procedimiento(?sp_continuacionincrementolincred)?que detona el trigger, ocacionando que no se alcance actualizar el estatus de envio (?status_envio?)',
'			  ya sea a ?3?que es un ?estatus de error por numero maximo de intentos de envio? o se actualiza a ?1? si la ?informacion recibida por el servicio llego correctamente?, ocasionando con esto que el estus quede igual a ?0?',
'			  y por la tanto si se realiza otra solicitud de incremento y se inserta un registro mas con estatus activo ?0? a enviar a coppel y va ha existir duplicidad de informacion y por consecuencia el procedimiento del',
' 			  demonio marque error de duplicidad de informacion. Tambien se comenta el BETWEEN de la fecha_insert para que consulte todos los clientes con status_envio = 0.', 
'MODIFICO: Guadalupe Payan',
'FECHA: Abril 2013',
'VERSION: 20130429.1420',
'BASE DE DATOS: Bdicred';

CREATE PROCEDURE "informix".sp_evalua_sol_movil(pEmpresa CHAR(3),pFolio CHAR(20))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;
		  
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cCodRet2         CHAR(6); 
DEFINE cCodRet3         CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cMensajeRet3     CHAR(80);
DEFINE cComentario      CHAR(80);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cDescripcion		CHAR(40);
DEFINE cStatus			CHAR(2);
DEFINE cBanderaAlta		CHAR(1);
DEFINE cProd			CHAR(4);
DEFINE cTipoSol			CHAR(1);
DEFINE cPrioridad		CHAR(2);
DEFINE sMensaje	SMALLINT;
DEFINE sSecuencia	SMALLINT;
DEFINE cNumCte 		CHAR(20);
DEFINE cProducto	CHAR(4);
DEFINE cSucursal	CHAR(4);
DEFINE cEjecutivo	CHAR(10);
DEFINE cBanderatdc	CHAR(1);
 
---INICIALIZACIONES
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "000000";
LET cCodRet2        = "000000";
LET cCodRet3        = "000000";
LET cMensajeRet     = "Se realizó la consulta correctamente";
LET cMensajeRet3    = "Se realizó la consulta correctamente";
LET cStatus			='';
LET cDescripcion	='';
LET cBanderaAlta	='';
LET cProd			= "";
LET cTipoSol		= "";
LET cPrioridad		= "";
LET sMensaje	= 0;
LET sSecuencia	= 0;
LET cNumCte 	= "";
LET cProducto	= "";
LET cSucursal	= "";
LET cEjecutivo	= "";
LET cBanderatdc	= "0";
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo   
     LET cCodRet= iSqlErr;
     RETURN cCodRet, cMensajeRet;   
END EXCEPTION;

--SET DEBUG FILE TO '/informix/jesus/sp_evalua_sol_movil.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	
	IF NVL(pEmpresa,'') ='' OR  NVL(pFolio,'') =''  THEN
		LET cCodRet             = "000001";
		LET cMensajeRet         = "PARAMETROS DE ENTRADA INVALIDOS";
		RETURN  cCodRet, cMensajeRet;
	ELSE
		FOREACH WITH HOLD
			SELECT numcte,producto,sucursal,user_insert
				INTO   cNumCte ,cProducto, cSucursal,cEjecutivo
			FROM "informix".ss_solicitudes_movil							
			WHERE 	empresa  = pEmpresa 
			AND  folio_movil = pFolio
			AND status <> '3'
											
				--se ejecuta para validar los datos del cte
				FOREACH EXECUTE PROCEDURE bdinteg:"informix".consultacatmensajesmaestro(2,1,'','',cNumCte)
					INTO cCodRet3,sMensaje,sSecuencia,cMensajeRet3
				END FOREACH;
					
				IF cCodRet3::INTEGER <> 0 THEN
					LET cBanderatdc ='1';
			    END IF;
					
				--se ejecuta para validar los datos del cte
				FOREACH EXECUTE PROCEDURE bdinteg:"informix".consultacatmensajesmaestro(1,1,'','',cNumCte)
					INTO cCodRet3,sMensaje,sSecuencia,cMensajeRet3
				END FOREACH;
				IF cCodRet3::INTEGER <> 0 THEN
					LET cBanderatdc ='1';
			    END IF;
				
				--SE VALIDA QUE PRODUCTOS SE VAN A OFRECER
				FOREACH EXECUTE PROCEDURE "informix".sp_obtiene_productos_cjunk_club
					( pEmpresa ,cSucursal ,cEjecutivo,'A', cNumCte, '1',cBanderatdc,'0', '0', '0', '0') 
					INTO cCodRet2,cProd,cTipoSol,cDescripcion,cPrioridad
			
					IF cProd= cProducto THEN
						LET cBanderaAlta = '1';
						EXIT FOREACH;
					END IF;			

				END FOREACH;
				
				IF NVL(cBanderaAlta,'') = '1' THEN
					EXECUTE PROCEDURE "informix".sp_registra_sol_movil(pEmpresa,pFolio,cProducto) INTO  cCodRet3,cMensajeRet3;						
				
				ELSE				
		
					UPDATE "informix".ss_solicitudes_movil		
					SET status = '3'--finalizado
					WHERE 	empresa  = pEmpresa 
					AND  folio_movil = pFolio
					AND producto = cProducto;
				END IF;
				
			
		END FOREACH;
	END IF;
	RETURN  cCodRet, cMensajeRet;
	
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para la obtencion de los status de incrementos de linea de crédito',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 18/02/2013',
'BD    : bdisolic',
'Version: 20130218.1210';

CREATE PROCEDURE "informix".executaedoctageneralcrd_pp_pba(pempresa CHAR(3),pNumProd CHAR(4), pfechahoy DATE)
RETURNING CHAR(6), CHAR(80);

--Fecha: 13/11/2009
--Autor: Roque Enrique Solis
--Modificacion:  Se agrego como parametro de entrada el tipo de producto para poder generar también el estado de cuenta de Prestamos Personales

DEFINE sql_err               INTEGER;
DEFINE v_cod_ret	         CHAR(6);
DEFINE ccodret	             CHAR(6);
DEFINE v_corta_retorno       INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE cMensajeRet           CHAR(80);
DEFINE v_empresa             CHAR(3);
DEFINE v_num_credito         CHAR(20);
DEFINE v_num_creditoAux      CHAR(20);
DEFINE v_id_registro         CHAR(7);
DEFINE v_descripcion 	     CHAR(50);
DEFINE v_texto		         CHAR(1000);
DEFINE v_clave               INTEGER;
DEFINE v_secuencia           INTEGER;
DEFINE v_mensajes		     VARCHAR(255);
DEFINE cNumProd              CHAR(4);
DEFINE v_linea_auxiliar	     DECIMAL(14,2);
DEFINE v_corta_linea_mensaje INTEGER;
---DECLARACION DE VARIABLES PARA IDENTIFICAR PRESTAMOS MAS VENCIDO Y/O MAS ANTIGUO
DEFINE cNumcte				 CHAR(20);
DEFINE cStatuscred			 CHAR(2);
DEFINE cNumCredVenc          CHAR(20);
DEFINE cNumCredAux			 CHAR(20);
DEFINE cStatuscredAux        CHAR(2);
DEFINE dCapital_vencido      DECIMAL(14,2);  --Capital_Ven_tc
DEFINE dInteres_vencido      DECIMAL(14,2);  --Interes_Ven_tc
DEFINE dIva_vencido          DECIMAL(14,2);  --Iva_Interes_Ven_tc
DEFINE dMoratorio            DECIMAL(14,2);  --Moratorios
DEFINE dIva_moratorio        DECIMAL(14,2);  --iva_Moratorios
DEFINE dMontoVencidoMin      DECIMAL(14,2);  --Monto Vencido Min
DEFINE dMontoVencidoMax		 DECIMAL(14,2);  --Monto Vencido Max
DEFINE idias_esp             INTEGER;

SET DEBUG FILE TO "executaedoctageneralcrd_pp.out";
TRACE ON;

BEGIN

  ON EXCEPTION SET sql_err, iIsamErr, cErrorInfo
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;
			LET cMensajeRet= cErrorInfo;
            RETURN v_cod_ret, cMensajeRet;
        END IF
   END EXCEPTION;

	LET cMensajeRet              = 'Exito';
	LET v_cod_ret	             = "000000";
	LET ccodret	                 = "000000";
	LET v_empresa                = "";
	LET v_num_credito            = "";
	LET v_num_creditoAux         = "";
	LET v_id_registro            = "";
	LET v_descripcion 	         = "";
	LET v_texto                  = "";
	LET v_linea_auxiliar         = 999999.00;
	LET v_mensajes				 = "";
	LET v_corta_retorno 		 = 0;
	LET v_corta_linea_mensaje 	 = 100;
	LET cNumProd                 = '';
--- INICIO DE VARIABLES PARA IDENTIFICAR PRESTAMOS MAS VENCIDO Y/O MAS ANTIGUO
	LET cNumcte				 = '';
	LET cStatuscred			 = '';
	LET cNumCredVenc         = '';
	LET cNumCredAux          = '';
	LET cStatuscredAux		 = '';
	LET dCapital_vencido     = 0;  --Capital_Ven_tc
	LET dInteres_vencido     = 0;  --Interes_Ven_tc
	LET dIva_vencido         = 0;  --Iva_Interes_Ven_tc
	LET dMoratorio           = 0;  --Moratorios
	LET dIva_moratorio       = 0;  --iva_Moratorios
	LET dMontoVencidoMin     = 0;  --Monto Vencido Min
	LET dMontoVencidoMax	 = 0;  --Monto Vencido Max
        LET idias_esp            = 0; -- Dia Calculo Dia inhabil 1-ENERO


	--SE INICIALIZA TABLA PARA EDOCTAS
	TRUNCATE "informix".sd_movhisedoctacrd;

	--	CARGA LA TABLA  PARA EDOCTAS
    EXECUTE PROCEDURE "informix".carga_movhis_edoctacrd_pp (pfechahoy, pNumProd) INTO v_cod_ret, cMensajeRet;

    IF v_cod_ret <> "000000" THEN
       RETURN v_cod_ret, cMensajeRet;
    END IF;

	SET ISOLATION TO DIRTY READ;
	/* --Se inactivan insertos derivado de que aun no hay solicitud para enviarlos --fmj Dic,2012
    --  SE GENERAN LOS INSERTOS FIJOS PARA CUENTAS CON 1 PAGO VENCIDOS
	EXECUTE PROCEDURE sp_activa_insertos_fijoscrd
					(
					pempresa,
					pfechahoy
					) INTO v_cod_ret;

    IF v_cod_ret<> "00000" THEN
         RETURN v_cod_ret, cMensajeRet;
    END IF;
    */
    -----MENSAJES DEL ESTADO DE CUENTA
    CREATE TEMP TABLE mensajes
                (
                clave      SERIAL,
                secuencia  INTEGER,
                mensaje    CHAR(101),
			    num_producto CHAR(4)
                );

    LET v_clave = 1;
	FOREACH

    	SELECT REPLACE(mensajes,'{0}',TRIM(v_linea_auxiliar::VARCHAR(21))) , num_producto
		  INTO v_texto, cNumProd
		  FROM "informix".sd_config_mensaje_edocta
		 WHERE clave >= case when pNumProd = '6300' then '200'
                             when pNumProd = '6400' then '300' END
		   AND clave < case when pNumProd = '6300' then '300'
                            when pNumProd = '6400' then '400' END
	  ORDER BY clave


		   LET v_secuencia = 1;

		FOREACH

			EXECUTE PROCEDURE "informix".corta_linea(TRIM(v_texto),v_corta_linea_mensaje)
			  	         INTO v_mensajes, v_corta_retorno
			      INSERT INTO mensajes (clave, secuencia, mensaje, num_producto)
				       VALUES (v_clave,v_secuencia,v_mensajes,cNumProd);
			LET v_secuencia = v_secuencia+1;

		END FOREACH;
		LET v_clave = v_clave + 1;

	END FOREACH;


	DELETE "informix".sd_mensajes_mensual_edoctacrd WHERE fecha_emision = pfechahoy AND num_producto = pNumProd;
	INSERT INTO "informix".sd_mensajes_mensual_edoctacrd
	SELECT pfechahoy,cNumProd,clave, secuencia, mensaje FROM mensajes where (clave||secuencia not in (11,22,62));
	DELETE FROM mensajes WHERE (clave||secuencia not in (11,22,62));

	--------------------------------------------------------
	--	GENERACION ENCABEZADO EDO CUENTA
	--------------------------------------------------------
			LET v_id_registro = pNumProd || '100';

			IF NOT EXISTS(SELECT num_credito FROM "informix".sd_encabezado_edoctacrd WHERE fecha_emision = pfechahoy AND num_credito = v_id_registro) THEN
			   INSERT INTO "informix".sd_encabezado_edoctacrd
						(fecha_emision,        num_credito,         numcte,
						 num_producto,         nombre_cte,          direccion_cn,
						 direccion_col,        direccion_del,       edo_cd,
						 cl_cobra,             sucursal_numero,     sucursal_nombre,
						 sucursal_gerente,     rfc,                 sucursal_tel,
						 cp,                   ruta,                entre_calles,
						 observaciones,        insertos
						)
					VALUES
						(
						 pfechahoy,			v_id_registro,          "0",
						 pNumProd,          "0",                    "0",
						 "0",               "0",                    "0",
						 "0",               "0",   			        "0",
						 "0",               "0",			        "0",
						 "0",               "0",				    "0",
						 "0",               "0"
						);
			 END IF;

			 --	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA

			 LET v_id_registro = pNumProd || '200';

			IF NOT EXISTS(SELECT num_credito FROM "informix".sd_encabezado2_edoctacrd WHERE fecha_emision = pfechahoy AND num_credito = v_id_registro) THEN

				INSERT INTO "informix".sd_encabezado2_edoctacrd
						(
						fecha_emision,            num_credito,            capital_tc,
						interes_tc,               iva_interes_tc,         numero_pago_tc,
						monto_pago,               capital_ven_tc,         interes_ven_tc,
						iva_interes_ven_tc,       moratorios_tc,          iva_moratorios_tc,
						pago_total_tc,            fecha_limite_tc,        periodo_tc_ini,
						periodo_tc_fin,           fecha_corte_tc,         dias_periodo_tc,
						monto_credito_tc,         fecha_otorgamiento_tc,  intereses_efec_pag,
                        comisiones_efec_cargadas
						)
				VALUES (
						pfechahoy,			v_id_registro,			0,
						0,                  0,                      "0",
						0,                  0,                      0,
						0,                  0,                      0,
						0,                  pfechahoy,			    pfechahoy,
						pfechahoy,          pfechahoy,			    "0",
						0,                  pfechahoy,              0,
                        0
						);
			END IF;

			--	VARIABLES GENERACION DETALLE EDO CUENTA

			LET v_id_registro = pNumProd || '300';

			IF NOT EXISTS(SELECT num_credito FROM "informix".sd_detalle_edoctacrd WHERE fecha_emision = pfechahoy AND num_credito = v_id_registro) THEN

				INSERT INTO "informix".sd_detalle_edoctacrd
					(
					fecha_emision, 		num_credito, 			secuencia,
					nlinea, 			fecha_mov, 			     concepto,
					cargos, 			abonos
					)
				VALUES
					(
					pfechahoy,			v_id_registro,			"0",
					"0", 				"0", 					"0",
					 0,  				 0
					);
			END IF;

			--	VARIABLES GENERACION ACLARACIONES EDO CUENTA

			LET v_id_registro = pNumProd || '400';
			IF NOT EXISTS(SELECT num_credito FROM "informix".sd_aclaraciones_edoctacrd WHERE fecha_emision = pfechahoy AND num_credito = v_id_registro) THEN

				INSERT INTO "informix".sd_aclaraciones_edoctacrd
					(
					fecha_emision,     num_credito,      secuencia,
					nlinea,            fecha_aclara,     folio_suc,
					fecha_mov,         descripcion,      importe
					)
				VALUES
					(
					pfechahoy,		   v_id_registro,		0,
					0,			       pfechahoy, 			"0",
					pfechahoy,         "0",                 0
					);
			END IF;

			--	VARIABLES GENERACION MENSAJES EDO CUENTA

			LET v_id_registro = pNumProd || '500';

			IF NOT EXISTS(SELECT num_credito FROM "informix".sd_mensajes_edoctacrd WHERE fecha_emision = pfechahoy AND num_credito = v_id_registro) THEN

				INSERT INTO "informix".sd_mensajes_edoctacrd
					(
					    fecha_emision, 			num_credito, 		num_producto,
					    secuencia,				 nlinea,	         si_paga,
 						mensajes
					)
				VALUES
					(
					    pfechahoy,				v_id_registro,		pNumProd,
					    0,              					0,		       0,
					   "0"
					);
			END IF

			--	VARIABLES GENERACION PIE EDO CUENTA

			LET v_id_registro = pNumProd || '600';

			IF NOT EXISTS(SELECT num_credito FROM "informix".sd_pie_edoctacrd WHERE fecha_emision = pfechahoy AND num_credito = v_id_registro) THEN

				INSERT INTO "informix".sd_pie_edoctacrd
					(
					  fecha_emision,      num_credito,        tasa_anual,
					  tasa_mensual,     	tasa_mora_anual,  	tasa_mora_mensual,
					  cat,              	saldo_insoluto
					)
				VALUES
					(
					  pfechahoy, 			v_id_registro, 		0,
					  0, 				    0,                  0,
					  0,                  0
					);
			  END IF;
			--SET DEBUG FILE TO "/informix/Malena/executaedoctageneralcrd_pp.out";
			--TRACE ON;
			--	GENERA UNO A UNO LOS ESTADOS DE CUENTA

    --DAY(pfechahoy) --fmv
    --IF DAY(pfechahoy) = 30 AND MONTH(pfechahoy) = abri, jun,sep, nov  --meses que tiene 30 dias

	IF pNumProd = '6300' THEN
		 FOREACH

		        SELECT a.empresa,a.num_credito
				  INTO v_empresa,v_num_credito
				  FROM "informix".sd_maecredcrd a
				 INNER JOIN  "informix".sd_maesdoshistcrd b ON(a.num_credito=b.num_credito AND a.empresa=b.empresa)
				 INNER JOIN  "informix".sd_maecredanexocrd c ON(a.num_credito=c.num_credito and a.empresa=c.empresa)
				 WHERE  b.fecha = pfechahoy
				   AND a.empresa = pempresa
				   AND a.num_producto = pNumProd
                   AND c.dia_corte = DAY(pfechahoy)
				   AND a.campo_trab3 =''

				  SELECT num_credito
                    INTO v_num_creditoAux
					FROM "informix".sd_encabezado_edoctacrd
				   WHERE fecha_emision = pfechahoy
				     AND num_credito = v_num_credito;

					 IF v_num_creditoAux IS NOT NULL THEN
					    CONTINUE FOREACH;
					 END IF;

                    EXECUTE PROCEDURE "informix".generaedosctacrd_pp(v_empresa,v_num_credito,pfechahoy)
                                 INTO v_cod_ret;

				IF v_cod_ret <> "000000" THEN

					SELECT descripcion
					  INTO v_descripcion
					  FROM bdinteg:si_codret
					 WHERE codigo_retorno = v_cod_ret
					   AND sistema  = "06";

					INSERT INTO "informix".sd_valedoctacrd
						(
						 empresa,		num_credito,		cod_ret,
						 descripcion,	fecha_proc,			tipo
						)
					VALUES
						(
						 v_empresa,		v_num_credito,		v_cod_ret,
						 v_descripcion,	pfechahoy,			"E"
						);

				END IF

			END FOREACH;
	END IF;

	IF pNumProd = '6400' THEN
		 FOREACH

		        SELECT a.empresa,a.numcte,a.num_credito,a.status_cred
				  INTO v_empresa,cNumcte,v_num_credito, cStatuscred
				  FROM "informix".sd_maecredcrd a
				 INNER JOIN  "informix".sd_maesdoshistcrd b ON(a.num_credito=b.num_credito AND a.empresa=b.empresa)
				 INNER JOIN  "informix".sd_maecredanexocrd c ON(a.num_credito=c.num_credito and a.empresa=c.empresa)
				 WHERE  b.fecha = pfechahoy
				   AND a.empresa = pempresa
				   AND a.num_producto = pNumProd
                   AND c.dia_corte = CASE WHEN DAY(pfechahoy) < 18 AND tp_dias_fecha_pago = 2 OR tp_dias_fecha_pago = 1 THEN  DATE(c.dia_corte)
									 ELSE DATE(pfechahoy) END
				   ORDER BY a.numcte

				  SELECT num_credito
                    INTO v_num_creditoAux
					FROM "informix".sd_encabezado_edoctacrd
				   WHERE fecha_emision = pfechahoy
				     AND num_credito = v_num_credito;

					 IF v_num_creditoAux IS NOT NULL THEN
					    CONTINUE FOREACH;
					 END IF;

                    EXECUTE PROCEDURE "informix".generaedosctacrd_pp(v_empresa,v_num_credito,pfechahoy)
                                 INTO v_cod_ret;

				IF v_cod_ret <> "000000" THEN

					SELECT descripcion
					  INTO v_descripcion
					  FROM bdinteg:"informix".si_codret
					 WHERE codigo_retorno = v_cod_ret
					   AND sistema  = "06";

					INSERT INTO "informix".sd_valedoctacrd
						(
						 empresa,		num_credito,		cod_ret,
						 descripcion,	fecha_proc,			tipo
						)
					VALUES
						(
						 v_empresa,		v_num_credito,		v_cod_ret,
						 v_descripcion,	pfechahoy,			"E"
						);

				END IF

			END FOREACH;
	END IF;


--FMV 7ago13: Seccion para generar estados de cuenta de PP y CRNOM, con corte dias 31 de mes
--FMV 25sep13: Se adiciona validacion para el mes de Febrero 29 y Enero 1

  IF (DAY(pfechahoy) = 30 AND MONTH(pfechahoy) IN (4, 6, 9 ,11)) OR  --Meses que tienen 30 dias
     (DAY(pfechahoy) = 28 AND MONTH(pfechahoy) = 2 ) OR      --Febrero
     (DAY(pfechahoy) = 31  AND MONTH(pfechahoy) = 12) THEN      --DICIEMBRE DIA INHABIL

	  IF (DAY(pfechahoy) = 31  AND MONTH(pfechahoy) = 12) THEN
          LET idias_esp = 1 ;
		ELSE
		  LET idias_esp = DAY(pfechahoy) + 1 ;
      END IF;

    
	IF pNumProd = '6300' THEN
		 FOREACH

		        SELECT a.empresa,a.numcte,a.num_credito
				  INTO v_empresa,cNumcte,v_num_credito
				  FROM "informix".sd_maecredcrd a
				 INNER JOIN  "informix".sd_maesdoshistcrd b ON(a.num_credito=b.num_credito AND a.empresa=b.empresa)
				 INNER JOIN  "informix".sd_maecredanexocrd c ON(a.num_credito=c.num_credito and a.empresa=c.empresa)
				 WHERE  b.fecha = pfechahoy
				   AND a.empresa = pempresa
				   AND a.num_producto = pNumProd
                   AND (   (c.dia_corte = idias_esp AND  MONTH(pfechahoy) <> 2) 
                        OR (c.dia_corte >= idias_esp AND  MONTH(pfechahoy) = 2) 
                       )
				   ORDER BY a.numcte

				  SELECT num_credito
                    INTO v_num_creditoAux
					FROM "informix".sd_encabezado_edoctacrd
				   WHERE fecha_emision = pfechahoy
				     AND num_credito = v_num_credito;

					 IF v_num_creditoAux IS NOT NULL THEN
					    CONTINUE FOREACH;
					 END IF;

                    EXECUTE PROCEDURE "informix".generaedosctacrd_pp(v_empresa,v_num_credito,pfechahoy)
                                 INTO v_cod_ret;

				IF v_cod_ret <> "000000" THEN

					SELECT descripcion
					  INTO v_descripcion
					  FROM bdinteg:si_codret
					 WHERE codigo_retorno = v_cod_ret
					   AND sistema  = "06";

					INSERT INTO "informix".sd_valedoctacrd
						(
						 empresa,		num_credito,		cod_ret,
						 descripcion,	fecha_proc,			tipo
						)
					VALUES
						(
						 v_empresa,		v_num_credito,		v_cod_ret,
						 v_descripcion,	pfechahoy,			"E"
						);

				END IF

			END FOREACH;
	END IF;

	IF pNumProd = '6400' THEN
		 FOREACH

		        SELECT a.empresa,a.numcte,a.num_credito,a.status_cred
				  INTO v_empresa,cNumcte,v_num_credito, cStatuscred
				  FROM "informix".sd_maecredcrd a
				 INNER JOIN  "informix".sd_maesdoshistcrd b ON(a.num_credito=b.num_credito AND a.empresa=b.empresa)
				 INNER JOIN  "informix".sd_maecredanexocrd c ON(a.num_credito=c.num_credito and a.empresa=c.empresa)
				 WHERE  b.fecha = pfechahoy
				   AND a.empresa = pempresa
				   AND a.num_producto = pNumProd
                   AND c.dia_corte = CASE WHEN DAY(pfechahoy) < 18 AND tp_dias_fecha_pago = 2 OR tp_dias_fecha_pago = 1 THEN  DATE(c.dia_corte)
									 ELSE DATE(pfechahoy) +1 END
				   ORDER BY a.numcte

				  SELECT num_credito
                    INTO v_num_creditoAux
					FROM "informix".sd_encabezado_edoctacrd
				   WHERE fecha_emision = pfechahoy
				     AND num_credito = v_num_credito;

					 IF v_num_creditoAux IS NOT NULL THEN
					    CONTINUE FOREACH;
					 END IF;

                    EXECUTE PROCEDURE "informix".generaedosctacrd_pp(v_empresa,v_num_credito,pfechahoy)
                                 INTO v_cod_ret;

				IF v_cod_ret <> "000000" THEN

					SELECT descripcion
					  INTO v_descripcion
					  FROM bdinteg:"informix".si_codret
					 WHERE codigo_retorno = v_cod_ret
					   AND sistema  = "06";

					INSERT INTO "informix".sd_valedoctacrd
						(
						 empresa,		num_credito,		cod_ret,
						 descripcion,	fecha_proc,			tipo
						)
					VALUES
						(
						 v_empresa,		v_num_credito,		v_cod_ret,
						 v_descripcion,	pfechahoy,			"E"
						);

				END IF

			END FOREACH;
	END IF;
  END IF; --IF DAY(pfechahoy) = 30 AND MONTH(pfechahoy) IN (4, 6, 9 ,11) THEN --Meses que tienen 30 dias


    DROP TABLE mensajes;
	--SE ELIMINA TABLA DATOS DE TABLA DE TRABAJO  --AAME.
	--TRUNCATE "informix".sd_masvdoantiguo;
	-- AAME. SE ANEXA LLAMADO A PROCEDIMIENTO QUE ACTUALIZARÁ LA CLAVE DE COBRANZA
	IF DAY(pfechahoy) = 17 AND pNumProd='6300' THEN
	  EXECUTE PROCEDURE "informix".sp_actualizacvlcobranzacte(pempresa, pfechahoy)
	  INTO ccodret;
	  IF ccodret <> "000000" THEN
		LET v_cod_ret = ccodret;
	  END IF;
	END IF;

END;

	RETURN v_cod_ret, cMensajeRet;

END PROCEDURE
DOCUMENT
"Se crea procedimiento para realizar la inicializacion",
"y la carga de movimientos historico para comenzar",
"con la generación de los estados de cuenta reestructura",
"(ejecutando el procedimiento: generaestadosdecuentacrd ",
"base de datos : bdicred",
"AUTOR : Jose de Jesus Almeida",
"FECHA : 23/Julio/2009",
"MODIFICACION: Se actualiza procedimiento para anexar la ejecución de un nuevo procedimiento que actualizará la clave de cobranza por cliente",
"con el prestamo mas vencido y/o mas antiguo segun sea el caso por cliente.",
"MODIFICÓ:Maria Elena Angulo",
"FECHA: 15-08-2013";

CREATE PROCEDURE "informix".provisionlineacred_parte_pba(pEmpresa CHAR(3), pEjecucion smallint)
    RETURNING CHAR(5);
   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE CodRet   CHAR(5);  DEFINE sql_err SMALLINT; DEFINE isam_err SMALLINT;
   DEFINE error_info CHAR(40); DEFINE nRows SMALLINT; DEFINE vMensaje VARCHAR(200,1); 
   DEFINE Mensaje  VARCHAR(200,1);  DEFINE vNumCred CHAR(20); DEFINE vProgBand SMALLINT;

   DEFINE GLOBAL FechaHoy  DATE  DEFAULT NULL;
   DEFINE GLOBAL FechaAnt  DATE  DEFAULT NULL;
   DEFINE GLOBAL ProxFecha DATE  DEFAULT NULL;
   DEFINE GLOBAL PriDiaMes DATE  DEFAULT NULL;
   DEFINE GLOBAL PriHabMes DATE  DEFAULT NULL;
   DEFINE GLOBAL UltDiaMes DATE  DEFAULT NULL;
   DEFINE GLOBAL UltHabMes DATE  DEFAULT NULL;
   DEFINE GLOBAL vPrecioReal     DECIMAL(14,6) DEFAULT 0;
   DEFINE GLOBAL vPrecioRealAnt  DECIMAL(14,6) DEFAULT 0;
   DEFINE GLOBAL vIvaSuc         DECIMAL(5,3)  DEFAULT 0;
   DEFINE GLOBAL vIvaBase        DECIMAL(5,3)  DEFAULT 0;
   DEFINE GLOBAL DiasCalc        SMALLINT      DEFAULT 0;
   DEFINE GLOBAL DiasTraspIC     SMALLINT      DEFAULT 0;

   DEFINE SdoIntAnticip, SdoIntereses, SdoDiaAntInt, SdoMesAntInt, SdoAcumMesInt, SdoExigInt, SdoNoExig MONEY(14,2); --SdoIntAntDev   , , ProvisionNormal
   DEFINE SdoMoratorio,  SdoCapital, SdoCapInsoluto, SdoDiaAntCap,  SdoAcumMesCap, MontoVencido MONEY(14,2); --SdoDiaAntMor   , SdoMesAntMor  , SdoMesAntCap,
   DEFINE MtoVencTrasp,  DiasAcumIntPer, SdoGlobalInt, SdoAcumIntPer, IntTraNoExig, SdoTrab4, MontoFinanciado, MtoVencTraInt, IntTraNoExigMes MONEY(14,2); 
   DEFINE MtoCapitalizado, MtoMinistraCap, vIvaMora, vSdoAcumMora, SdoPromedio, InteresMam, InteresPmm, InteresMad     MONEY(14,2); --MontoReservado,
   DEFINE InteresPmd,   MontoProvision, MtoCapitaliza, TotalAdeudo, MontoPago, MtoMoraOrdi, MtoMoraCope, MtoMoraOrdiMa, MtoMoraCopeMa     MONEY(14,2);
   DEFINE MtoMoraOrdiPm, MtoMoraCopePm,CapTrasNo,vIntOrden,vIvaOrd,vSdoNoExigPas,vIvaOrden,vIvaOrdenAnt,vCapInsEsTot   MONEY(14,2);

   DEFINE TasaAm, TasaHm, TasaAd, TasaHd, TasaIn, vTasaMora, TasaCope, TasaIntd, vTasaCte,TasaIntm DECIMAL(9,6) ;
   DEFINE vPrecioIni, vPrecioFin, TasaDiaria  DECIMAL(14,6);
   DEFINE vMtoVencido, vMtoVencido_ant, vIvaInt,vIntGrav, vIvaIntv, vIvaIntMes,  vReservaInt, vMtoProvision,SdoRetenido,vVencidoHist,MinimoMesAnt,VigenteMesAnt DECIMAL(14,2); 
   DEFINE vProvIva,vProvInt, TopeMinimo, vIntDiario,  vCuotaMes,vIntOrd,vCalcIvaMesAnt             DECIMAL(14,2);
   DEFINE vPorcReserva                        DECIMAL(5,2);

   DEFINE DiasPeriodo, DiasAcCap, DiasMa, DiasPm, DifDias, DiaCuota, DiasAcumCap, DiasAcumInt, DiasAcumMora, Aniversario, vReferencia, vDiaDeCorte  SMALLINT;
   DEFINE vDiasGraciaMora, vDiasMaxPago, vDiasBloqueo, DiasProvMa, DiasProvPm, vDiasTrasp, vRMora, rLog, vCodRefInt,vPasoProm, vFactorPagoMin, vDiaProxPag  SMALLINT;

   DEFINE CambioMes   CHAR(1); DEFINE vCodigoFun CHAR(3); DEFINE Folio      CHAR(16); DEFINE vSucursal   CHAR(4); DEFINE vDivisa CHAR(2);
   DEFINE NumProducto CHAR(4); DEFINE Transacc   CHAR(4); DEFINE vTpDiasMora CHAR(1); DEFINE vTpDiasPago CHAR(1); DEFINE Begin   CHAR(1);
   DEFINE TrasHoy     CHAR(1); DEFINE vCodFunInt CHAR(3); DEFINE BanderaInt CHAR(1);  DEFINE vStProc   CHAR(1);
   DEFINE StatusMora  CHAR(1); DEFINE vForeach   CHAR(1); DEFINE vBandFinan CHAR(1);  DEFINE vPlaza    CHAR(3);  DEFINE Es_Totalero  CHAR(1);
   DEFINE vSiCap      CHAR(1); DEFINE vDia       CHAR(2); DEFINE vCapVig    CHAR(10); DEFINE vCapTras  CHAR(10); DEFINE vCapVenExig  CHAR(15);
   DEFINE vIntVig     CHAR(10);DEFINE vIntVenc   CHAR(10);DEFINE vFolio     CHAR(16); DEFINE StatusCred, StatusCred_ant   CHAR(2);
   DEFINE vmnto_otorgado DECIMAL (18,2); DEFINE vFactorPagoMinLinC DECIMAL (4,4);

   DEFINE FechaPagoCap, FechaPagoInt, vFechaVenc, vFecProxPag, vFProceso, vFechaReserva ,vFechaCuota,vFechaUDIant,vFecMes, vFechaUltPago,vFechaVencim, vFechahist    DATE;
   DEFINE vErrores,vMarcaAyuda, vdiasatraso INTEGER;

   DEFINE vMtofinventrasp integer; DEFINE wstatus_cred char(02); DEFINE pprocesos smallint; DEFINE cred_ini CHAR(20);
   DEFINE cred_fin CHAR(20);  DEFINE vComportamiento smallint;   DEFINE Campotrabajo3 CHAR(10);

-- APOYO 2014 INI
   DEFINE wbandera_apoyo CHAR(01);
-- APOYO 2014 FIN
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- ********************  ******************************************************
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
      CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,TRIM(error_info)) RETURNING rLog;

      IF Begin = "S" THEN ROLLBACK WORK; END IF
      IF rLog > 0 THEN
          RETURN CodRet;
      ELSE
        IF vForeach <> "S" THEN RETURN CodRet; END IF
      END IF
   END EXCEPTION WITH RESUME;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
   SET ISOLATION TO DIRTY READ;
   SET DEBUG FILE TO "/resplogifx/archivoscartera/cierre/sp_provision1.out";
   TRACE ON;

   LET CodRet         = '000';
   LET SdoIntereses   = 0;    LET SdoDiaAntInt  = 0;  LET SdoMesAntInt   = 0;  LET SdoAcumMesInt   = 0;   LET SdoExigInt     = 0;   LET SdoNoExig      = 0;
   LET DiasAcumInt    = 0;    LET SdoMoratorio  = 0;  LET DiasAcumMora   = 0;  LET SdoCapital      = 0;   LET SdoCapInsoluto = 0;   LET SdoDiaAntCap   = 0;  
   LET SdoAcumMesCap  = 0;    LET DiasAcumCap   = 0;  LET MontoVencido   = 0;  LET MtoVencTrasp    = 0;   LET DiasAcumIntPer = 0;   LET SdoGlobalInt   = 0; 
   LET SdoAcumIntPer  = 0;    LET InteresMam    = 0;  LET InteresPmm     = 0;  LET DiasProvMa      = 0;   LET DiasProvPm     = 0;   LET MtoMoraOrdi    = 0; 
   LET MtoVencTraInt  = 0;    LET MtoMoraCope   = 0;  LET MtoMoraOrdiMa  = 0;  LET MtoMoraCopeMa   = 0;   LET MtoMoraOrdiPm  = 0;   LET MtoMoraCopePm  = 0;    
   LET IntTraNoExig   = 0;    LET SdoTrab4      = 0;  LET DiasMa         = 0;  LET DiasPm          = 0;   LET CambioMes      = 'N'; LET MontoProvision = 0;
   LET vCodigoFun     = '034'; LET vReferencia  = ''; LET Transacc       = ''; LET MtoCapitalizado = 0;   LET TasaAd         = 0;   LET TasaHd         = 0;
   LET DiasPeriodo    = 0;    LET MtoCapitaliza = 0;  LET MtoMinistraCap = 0;  LET TotalAdeudo     = 0;   LET MtoMoraOrdi    = 0;   LET MtoMoraCope    = 0;
   LET vNumCred       = " ";  LET rLog          = 0;  LET vMensaje       = ""; LET Begin           = "N"; LET TrasHoy        = "N";
   LET vPrecioIni     = 0;    LET vPrecioFin    = 0;  LET vIvaInt        = 0;  LET vIvaIntMes      = 0;   LET vIvaIntv       = 0;   LET TasaDIaria     = 0;
   LET vIvaMora       = 0;    LET vSdoAcumMora  = 0;  LET vReservaInt    = 0;  LET vPorcReserva    = 100; LET vForeach       = "N"; --LET vBaseReserva = 0;
   LET vMtoVencido    = 0;    LET vPasoProm     = 0;  LET BanderaInt     ="?"; LET vProvInt        = 0;   LET vProvIva       = 0;   LET Es_Totalero    = "?";
   LET vDia           ='';    LET vCapVig       ='';  LET vCapTras       ='';  LET vCapVenExig     ='';   LET vIntVig        ='';   LET vIntVenc       ='';
   LET vIntDiario     = 0;    LET vCuotaMes     = 0;  LET vFechaUDIant   ='';  LET vFecMes         = '';  LET vIntOrd        =0;
   LET vFolio         ='';    LET vIntOrden     = 0;  LET vIvaOrd        = 0;  LET vSdoNoExigPas   = 0;   LET vIvaOrden      = 0;   LET StatusCred     = '';   
   LET vIvaOrdenAnt   = 0;    LET vProgBand     = 0;  LET vMtofinventrasp = 0; LET vIntGrav        = 0;   LET wstatus_cred = '';    LET pprocesos = 0; 
   LET cred_ini = '';         LET cred_fin = '';      LET vComportamiento = 0; LET vFechaUltPago = date(1); LET vMtoVencido_ant = 0; LET vdiasatraso = 0;   LET Campotrabajo3 = '';        
   LET vFactorPagoMin = 0;    LET vDiaProxPag=0;      LET vFactorPagoMinLinC=0;   LET vmnto_otorgado=0; LET vFechahist = date(1);
-- APOYO 2014 INI
   LET wbandera_apoyo = '';
-- APOYO 2014 FIN

   SELECT fecha_hoy, fecha_ant, prox_fecha, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes
     INTO FechaHoy, FechaAnt, ProxFecha, PriDiaMes, PriHabMes, UltDiaMes, UltHabMes
     FROM sd_fechas WHERE empresa = pEmpresa;

    IF FechaHoy IS NULL THEN
       LET CodRet = "110";
       RETURN CodRet;
    END IF;

    SELECT * FROM bdinteg:si_sucursales
     WHERE tpo_sucursal = "S"
      INTO TEMP cr_sucursales;
    CREATE INDEX crsucursal on cr_sucursales (empresa, sucursal);
    update statistics medium for table cr_sucursales;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
      LET vFechaReserva = FechaHoy;

     SELECT valor::SMALLINT INTO vProgBand
       FROM sd_param
      WHERE empresa = pEmpresa AND cod_param = "020";

      SELECT valor INTO DiasCalc
        FROM sd_param
       WHERE empresa = pEmpresa AND cod_param = "24";       -- Dias Para Calculo de Intereses

      IF DiasCalc IS NULL THEN
         LET CodRet = "110";
         CALL log_cierre (pEmpresa, "0000000", CodRet, FechaHoy,"Dias Base para calculo de intereses") RETURNING rLog;
         RETURN CodRet;
      END IF

      SELECT valor INTO vDiasBloqueo
        FROM sd_param
       WHERE empresa = pEmpresa AND cod_param = "335";  --Dias para bloqueo de pagos creditos venc.

      IF vDiasBloqueo IS NULL THEN
         LET CodRet = "110";
         CALL log_cierre (pEmpresa, "0000000", CodRet, FechaHoy,"Dias para BLoqueo de pagos") RETURNING rLog;
         RETURN CodRet;
      END IF

      -- ******************************
      -- Extrae Parametro de IVA Base *
      -- ******************************
      SELECT valor INTO vIvaBase
        FROM bdinteg:si_param
       WHERE empresa = pEmpresa AND cod_param = 47;

      IF vIvaBase IS NULL THEN
         LET CodRet = "800";
         CALL log_cierre (pEmpresa, "0000000", CodRet, FechaHoy,"Valor de Iva Base         ") RETURNING rLog; RETURN CodRet;
      END IF

      -- Determina Valor de Udi para Calculo de Iva de Int. Gravado
      CALL determina_udi(pEmpresa, FechaHoy) RETURNING CodRet, vPrecioReal;

      IF CodRet <> "000" THEN
          CALL log_cierre (pEmpresa, "0000000", CodRet, FechaHoy,"Valor de Real de Udi      ") RETURNING rLog; RETURN CodRet;
      END IF
      -- Determina Valor de Udi para Calculo de Iva de Int. Gravado  Mes Anterior
      CALL monthadd(FechaHoy,-1) returning vFechaUDIant;
      CALL determina_udi(pEmpresa, vFechaUDIant) RETURNING CodRet, vPrecioRealAnt;

       IF CodRet <> "000" THEN
         CALL log_cierre (pEmpresa, "0000000", CodRet, FechaHoy,"Valor de Real de Udi      ") RETURNING rLog; RETURN CodRet;
      END IF
        -- Determina Dias de Provision
        LET DiasProvMa = (ProxFecha - FechaHoy);
        IF DiasProvMa <= 0 THEN
           LET DiasProvMa = 1;
        END IF

      SELECT USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||SUBSTR(CURRENT,12,2)||substr(current,15,2)||SUBSTR(current,18,2) INTO Folio FROM dual;

--     Se determina el rango de creditos a facturar
        SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) INTO cred_ini,cred_fin
         FROM bdicred:sd_param  WHERE cod_param = (950 + pEjecucion)::CHAR(3);               
		 
        SELECT {+INDEX(sd_maecredanexo idx_sd_maecredanexo1), (sd_maecred maecred3) } a.num_credito, a.status_cred
          FROM sd_maecred a, sd_maecredanexo b
         WHERE a.empresa = pEmpresa     AND b.num_credito = a.num_credito
           AND b.empresa = a.empresa    AND b.fecha_proceso = FechaHoy
           and status_cred NOT IN ("CC", "FC")
           and a.num_credito >= cred_ini    and a.num_credito  < cred_fin    
           into temp paso_cred_fac with no log;

        begin;
            create unique index inx_paso_cred on paso_cred_fac(num_credito) ONLINE;
        commit;
        update statistics medium for table paso_cred_fac;
 
FOREACH WITH HOLD
        SELECT num_credito INTO vNumCred
          FROM paso_cred_fac
      ORDER BY status_cred DESC  --FMV 8jul13: Order by por estatus de credito

   BEGIN WORK;

   LET Begin        = "S";
   LET vForeach     = "S";
   LET vSiCap       ='';
   LET vCapInsEsTot = 0;
   LET vCalcIvaMesAnt = 0;
   LET IntTraNoExigMes = 0;
   LET vIvaInt=0;
   LET vIvaIntv=0;
   LET vIntGrav = 0;
   LET vIvaIntMes = 0;
   LET vFechaVencim = NULL;
  
   SELECT a.empresa,              a.num_credito,              a.sdo_int_anticip,  a.sdo_intereses,        a.sdo_dia_ant_int,        a.sdo_mes_ant_int,  
          a.sdo_acum_mes_int,     a.sdo_exig_int,             a.sdo_no_exig,      a.dias_acum_int,        a.sdo_moratorio,          a.dias_acum_mora,     
          a.sdo_capital,          a.sdo_cap_insoluto,         a.sdo_dia_ant_cap,  a.sdo_acum_mes_cap,     a.dias_acum_cap,          a.monto_vencido,
          a.mto_venc_trasp,       a.dias_acum_intper,         a.sdo_global_int,   a.sdo_acum_intper,      a.mto_venc_tra_int,       b.num_producto, 
          DAY(b.fecha_apertura),  b.tasa_interes,             b.sucursal,         b.divisa,               b.fecha_pago_cap,         b.fecha_pago_int,      
          a.mto_capitalizado,     a.int_tra_no_exig,          a.sdo_trab4,        a.monto_financiado,     b.status_cred,            a.sdo_acum_mes_cap,    
          a.dias_acum_cap,        a.mto_ministra_cap,         f.dia_corte,        f.dias_gracia_mora,     f.tp_dias_calc_mora,      f.dias_fecha_max_pago, 
          f.tp_dias_fecha_pago,   NVL(f.tasa_interes_cte,0),  b.dias_trasp_cap,   f.fecha_vencto,         f.prox_fecha_pago,        b.tasa_moratorios,     
          f.fecha_proceso,        a.sdo_contab_mora,          a.sdo_retenido,     a.cap_tras_no_venci,    NVL(b.id_unidad_prod,0),  f.fecha_ult_pago,      
          b.campo_trab3,mto_fin_ven_trasp, a.monto_otorgado
     INTO pEmpresa ,       vNumCred        ,   SdoIntAnticip ,     SdoIntereses   ,    SdoDiaAntInt,  SdoMesAntInt,
          SdoAcumMesInt,   SdoExigInt      ,   SdoNoExig     ,     DiasAcumInt    ,    SdoMoratorio,  DiasAcumMora,
          SdoCapital,      SdoCapInsoluto  ,   SdoDiaAntCap  ,     SdoAcumMesCap  ,    DiasAcumCap,   MontoVencido,
          MtovencTrasp,    DiasAcumIntPer  ,   SdoGlobalInt  ,     SdoAcumIntPer  ,    MtoVencTraInt, NumProducto,
          Aniversario,     TasaIntm        ,   vSucursal     ,     vDivisa        ,    FechaPagoCap,  FechaPagoInt,
          MtoCapitalizado, IntTraNoExig    ,   SdoTrab4      ,     MontoFinanciado,    StatusCred,    SdoPromedio,
          DiasAcCap,       MtoMinistraCap  ,   vDiaDeCorte   ,     vDiasGraciaMora,    vTpDiasMora,   vDiasMaxPago,
          vTpDiasPago,     vTasaCte        ,   vDiasTrasp    ,     vFechaVenc     ,    vFecProxPag,   vTasaMora,
          vFProceso,       vSdoAcumMora    ,   SdoRetenido   ,     CapTrasNo      ,    vMarcaAyuda,   vFechaUltPago,
          Campotrabajo3,   vMtofinventrasp, vmnto_otorgado
     FROM sd_maesdos a, sd_maecred b, sd_maecredanexo f
    WHERE a.num_credito = vNumCred          AND a.empresa     = pEmpresa
      AND b.num_credito = a.num_credito     AND b.empresa     = a.empresa
      AND f.num_credito = a.num_credito     AND f.empresa     = a.empresa;
     
      LET vMtoVencido = 0;
      LET vMtoVencido_ant = 0;
      LET vBandFinan = "0";
      LET Es_Totalero = "N";

--APOYO 2014 INI
      LET wbandera_apoyo = '';
--APOYO 2014 FIN

	  IF (Campotrabajo3 <> 'BAJA' ) then
          LET vMtofinventrasp = 0;
	  ElSE
		IF (vMtofinventrasp <> 0) THEN
			 SELECT count(*) INTO vMtofinventrasp
			 FROM sd_amortiza_credito
			WHERE empresa = pempresa  AND num_credito = vNumCred  AND capital_status IN ("2","7");
		END IF;
	  END IF;

      LET StatusCred_ant = StatusCred;
      LET vComportamiento = 0;

      IF (StatusCred = "AA") THEN
         LET MtoVencTraInt = 0;
      END IF;

    IF ( Campotrabajo3 is null ) then
        LET Campotrabajo3 = '';
    END IF;

    IF (StatusCred = "FF") THEN
-- JOM INI Graba historico para generar estados de cuenta de creditos cancelados
        LET vFechahist = mdy(month(FechaHoy),vDiaDeCorte,year(FechaHoy));

        IF ( day(FechaHoy)::smallint > vDiaDeCorte) THEN
            LET vFechahist = monthadd(vFechahist,1);
        END IF;
 
        INSERT INTO sd_maesdoshist SELECT {+INDEX(sd_maesdos idx_sd_maesdos)} vFechahist, * FROM sd_maesdos  WHERE empresa = pEmpresa AND num_credito = vNumCred;
        COMMIT WORK;
        CONTINUE FOREACH;
    END IF;
-- JOM INI Graba historico para generar estados de cuenta de creditos cancelados

 -- jom Ini Venta de Cartera
    IF ( vMarcaAyuda = 1 OR StatusCred = "CV" OR ( Campotrabajo3 = 'BAJA' AND StatusCred <> "CV") ) THEN -- Marca para bloqueo de créditos
        UPDATE sd_maesdos
           SET mto_fin_ven_trasp  = vMtofinventrasp
	     WHERE empresa = pEmpresa AND num_credito = vNumCred;
	
        CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                               SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,FechaHoy) RETURNING CodRet;

        IF ( CodRet <> "000" ) THEN
            LET vMensaje = " Saldos Diarios";
            CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,vMensaje) RETURNING rLog;
        END IF;

        IF ( ( Campotrabajo3 = 'BAJA' AND StatusCred <> "CV") OR (vMarcaAyuda = 1 AND StatusCred <> "CV") ) THEN
            UPDATE sd_maecredanexo  SET fecha_proceso = ProxFecha
             WHERE num_credito = vNumCred AND empresa = pEmpresa;

            IF ( FechaHoy = UltHabMes ) THEN
                INSERT INTO bdicred:"informix".sd_maesdoscont
                 SELECT FechaHoy, *
                   FROM bdicred:"informix".sd_maesdos
                  WHERE num_credito = vNumCred AND empresa = pEmpresa ;

                INSERT INTO bdicred:"informix".sd_maecredcont
                  SELECT FechaHoy, *
                    FROM bdicred:"informix".sd_maecred
                   WHERE num_credito = vNumCred
                     AND empresa = pEmpresa ;

                IF (vFechaVenc IS NOT NULL) THEN
                    LET vdiasatraso = abs(FechaHoy) - abs(date(vFechaVenc + 1 units month));
                ELSE
                    LET vdiasatraso = 0;
                END IF;

               UPDATE bdicred:"informix".sd_indicador_cred
                SET fecha_ultimo_pago_h   = fecha_ultimo_pago,   monto_ultimo_pago_h   = monto_ultimo_pago,   trans_ultimo_pago_h   = trans_ultimo_pago, 
                    saldo_maximo_h        = saldo_maximo,        fecha_sdo_maximo_h    = fecha_sdo_maximo ,   fecha_ultima_compra_h = fecha_ultima_compra,
                    monto_ultima_compra_h = monto_ultima_compra, atm_disp_monto_h      = atm_disp_monto,      atm_disp_fecha_h      = atm_disp_fecha, 
                    atm_disp_transacc_h   = atm_disp_transacc,   pos_disp_monto_h      = pos_disp_monto,      pos_disp_fecha_h      = pos_disp_fecha,
                    pos_disp_transacc_h   = pos_disp_transacc,   vnt_disp_monto_h      = vnt_disp_monto,      vnt_disp_fecha_h      = vnt_disp_fecha, 
                    monto_ult_convenio_h  = monto_ult_convenio,  fecha_ult_convenio_h  = fecha_ult_convenio,  num_vencidos_his      = num_vencidos,        
                    num_vencidos		  = vMtofinventrasp,     saldo_max_facturado_h = saldo_max_facturado, pago_mayor_h          = pago_mayor,  
                    num_atm_h             = num_atm,             monto_atm_h           = monto_atm,           num_pos_h             = num_pos,
                    monto_pos_h           = monto_pos,           num_vtn_h             = num_vtn,             monto_vtn_h           = monto_vtn, 
                    num_pagos_h           = num_pagos,           monto_pagos_h         = monto_pagos,         dias_atraso           = vdiasatraso,
                    num_atm               = 0,                   monto_atm             = 0,			          num_pos               = 0, 
                    monto_pos             = 0,        		     num_vtn               = 0,                   monto_vtn             = 0,
                    num_pagos             = 0,                   monto_pagos           = 0,                   fecha_vencido_h       = fecha_vencido, 
                    fecha_cancelacion_h   = fecha_cancelacion,   fecha_ult_respaldo    = FechaHoy
                   WHERE num_credito = vNumCred     AND empresa     = pEmpresa ;

            ELIF DAY(FechaHoy) = vDiaDeCorte THEN
                    -- Genera Historico de Saldos
                INSERT INTO sd_maesdoshist
                 SELECT {+INDEX(sd_maesdos idx_sd_maesdos)} FechaHoy, *
                   FROM sd_maesdos  WHERE empresa = pEmpresa    AND num_credito = vNumCred;

                UPDATE sd_maesdos
                    SET sdo_int_anticip  = 0, sdo_mes_ant_int  = sdo_intereses, sdo_intereses    = 0, sdo_acum_mes_int = 0,
                        sdo_acum_intper  = 0, sdo_acum_mes_cap = 0,             dias_acum_cap    = 0, dias_acum_int    = 0
                  WHERE empresa = pEmpresa  AND num_credito = vNumCred;

                UPDATE "informix".sd_indicador_cred SET 
                    fecha_ultimo_pago_ch = fecha_ultimo_pago, monto_ultimo_pago_ch   = monto_ultimo_pago,   saldo_maximo_ch        = saldo_maximo, 
                    fecha_sdo_maximo_ch  = fecha_sdo_maximo,  fecha_ultima_compra_ch = fecha_ultima_compra, monto_ultima_compra_ch = monto_ultima_compra,
                    atm_disp_monto_ch    = atm_disp_monto,    atm_disp_fecha_ch      = atm_disp_fecha,      pos_disp_monto_ch      = pos_disp_monto, 
                    pos_disp_fecha_ch    = pos_disp_fecha,    vnt_disp_monto_ch      = vnt_disp_monto,      vnt_disp_fecha_ch      = vnt_disp_fecha,
                    num_vencidos		 = vMtofinventrasp,   num_vencidos_ch        = num_vencidos,        saldo_max_facturado_ch = saldo_max_facturado, 
                    pago_mayor_ch        = pago_mayor,        monto_capitalizado_ch  = monto_capitalizado,  num_atm_ch   		   = num_atmc,
                    monto_atm_ch 		 = monto_atmc,        num_pos_ch   			 = num_posc,			monto_pos_ch 		   = monto_posc, 
                    num_vtn_ch   		 = num_vtnc,   		  monto_vtn_ch 			 = monto_vtnc,          num_pagos_ch 		   = num_pagosc,
                    monto_pagos_ch   	 = monto_pagosc,      num_atmc   			 = 0,                   monto_atmc 			   = 0, 
                    num_posc   			 = 0,			      monto_posc 			 = 0,                   num_vtnc   			   = 0,
                    monto_vtnc 			 = 0,                 num_pagosc 			 = 0,			        monto_pagosc  		   = 0, 
                    fecha_ult_respaldo   = FechaHoy,          comportamiento = vComportamiento, 
                    fecha_vencido = CASE WHEN fecha_vencido IS NULL AND vFechaVencim IS NOT NULL THEN vFechaVencim ELSE fecha_vencido END                  
                WHERE empresa     = pEmpresa AND num_credito = vNumCred ;
            END IF;
        END IF;

        COMMIT WORK;
        CONTINUE FOREACH;
    END IF
 -- jom Ini Venta de Cartera

--APOYO 2014 INI
    SELECT bandera INTO wbandera_apoyo FROM sd_programa_apoyo2014 WHERE num_credito = vNumCred;
	
    IF ( wbandera_apoyo is null ) THEN LET wbandera_apoyo = ''; END IF;
--APOYO 2014 FIN

  -- ***********************************
  -- CALCULO DE PROVISION DE INTERESES *
  -- ***********************************
     LET vMensaje = "Provision Normal";
     LET vMtoProvision = (SdoCapital+CapTrasNo);

--APOYO 2014 INI
    IF ( vMtoProvision > 0 AND wbandera_apoyo <> 'A' ) THEN
--APOYO 2014 FIN
        -- Provision Mes Actual
        LET TasaDiaria = TasaIntm / (DiasCalc * 100);
        LET InteresMam = (vMtoProvision) * TasaDiaria;
        LET InteresMam = InteresMam * DiasProvMa ;
        --Provision Proximo Mes
        IF DiasProvPm > 0 THEN
           LET InteresPmm = (vMtoProvision) * TasaDiaria;
           LET InteresPmm = InteresPmm * DiasProvPm ;
        END IF
        LET SdoDiaAntInt = SdoIntereses;
        LET SdoDiaAntCap = SdoCapInsoluto;
        LET SdoIntAnticip = SdoIntAnticip + InteresMam + InteresPmm;
        LET SdoIntereses = SdoIntereses + InteresMam + InteresPmm;
--        LET vIntDiario   = InteresMam + InteresPmm;
     END IF;

     LET SdoAcumMesInt = SdoAcumMesInt + InteresMam + InteresPmm; -- no se utiliza
     LET DiasAcumInt   = DiasAcumInt + DiasProvMa + DiasProvPm; -- no se utiliza
     IF (SdoCapital > 0) THEN
        LET SdoAcumMesCap = SdoAcumMesCap + (SdoCapital * (DiasProvMa + DiasProvPm));
        LET DiasAcumCap   = DiasAcumCap + DiasProvMa + DiasProvPm; -- no se utiliza
     END IF;
--     LET SdoGlobalInt  = SdoGlobalInt + InteresMam + InteresPmm; -- no se utiliza
     LET SdoAcumIntPer = SdoAcumIntPer + InteresMam + InteresPmm; -- no se utiliza

   -- **********************************************
   --       C a l c u l a   M o r a t o r i o s    *
   -- **********************************************
    LET vMensaje = "Provision de Moratorios";
    IF (StatusCred = "BA" OR StatusCred = "BT") and DAY(FechaHoy) <> vDiaDeCorte THEN

        SELECT MAX(fecha_cuota), count(*) INTO vFechaCuota, vMtofinventrasp
         FROM sd_amortiza_credito
        WHERE empresa = pempresa AND num_credito = vNumCred AND capital_status IN ("2","7");

--APOYO 2014 INI
        IF ( wbandera_apoyo <> 'A' ) THEN
--APOYO 2014 FIN
            LET TasaCope    = vTasaMora - TasaIntm;
            LET MtoMoraOrdiMa = MontoVencido + MtovencTrasp;
            LET MtoMoraCopeMa = MontoVencido + MtovencTrasp;
            LET MtoMoraOrdiMa = (MtoMoraOrdiMa) * TasaIntm/(DiasCalc * 100);
            LET MtoMoraOrdiMa = MtoMoraOrdiMa * DiasProvMa ;
            LET MtoMoraCopeMa = (MtoMoraCopeMa) * TasaCope/(DiasCalc * 100);
            LET MtoMoraCopeMa = MtoMoraCopeMa * DiasProvMa ;
            LET vSdoAcumMora = vSdoAcumMora + MtoMoraOrdiMa + MtoMoraCopeMa;
            LET DiasAcumMora = DiasAcumMora + DiasProvMa;

           UPDATE sd_amortiza_credito
              SET mora_provi_ordi = mora_provi_ordi + MtoMoraOrdiMa,
                  mora_provi_cope = mora_provi_cope + MtoMoraCopeMa,
                  mora_status = 1
            WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota;
--APOYO 2014 INI
       END IF;       
--APOYO 2014 FIN
   END IF

   -- ****************************************************************
   -- *     P r o c e s o s   p a r a   D i a   d e   C o r t e      *
   -- ****************************************************************
--APOYO 2014 INI
    IF ( DAY(FechaHoy) = vDiaDeCorte AND wbandera_apoyo = 'A' ) THEN
-- RESPLADA TABLAS
       INSERT INTO bdicred:"informix".sd_maesdos_apoyo2014
       SELECT FechaHoy, *
         FROM bdicred:"informix".sd_maesdos 
        WHERE num_credito = vNumCred AND empresa = pEmpresa;              

       INSERT INTO bdicred:"informix".sd_amortiza_credito_apoyo2014
       SELECT FechaHoy, *
         FROM bdicred:"informix".sd_amortiza_credito
        WHERE num_credito = vNumCred AND empresa = pEmpresa;              
-- MUEVE CUOTAS ACTIVAS UN MES
       UPDATE sd_amortiza_credito
          SET fecha_cuota = monthadd(fecha_cuota,1)
        WHERE empresa = pempresa AND num_credito = vNumCred AND ( capital_status in ('1','7') OR fecha_cuota >= FechaHoy - 1 UNITS MONTH );

       LET vDiaProxPag = vDiaDeCorte-vDiasGraciaMora;
       LET vFecProxPag = DATE(MONTH(FechaHoy + 1 UNITS MONTH) || "/" || vDiaProxPag || "/" || YEAR(FechaHoy + 1 UNITS MONTH));

       UPDATE sd_maecredanexo
          SET prox_fecha_pago = vFecProxPag
        WHERE empresa = pEmpresa AND num_credito = vNumCred;
   END IF;
--APOYO 2014 FIN

    IF ( DAY(FechaHoy) = vDiaDeCorte  AND wbandera_apoyo <> 'A' ) THEN
-----Verifica que en el credito tenga la fecha cuota, si no la crea INI
        LET vFechaCuota = NULL;
-- SE ELIMINA SALDOS INMATERIALES JOM RQM 07 054 11/14/2011
        SELECT fecha_cuota INTO vFechaCuota
          FROM sd_amortiza_credito
         WHERE empresa = pEmpresa AND num_credito = vNumCred AND fecha_cuota = FechaHoy;

        IF vFechaCuota Is Null  THEN
            CALL sp_creacuota(pEmpresa,vNumCred,0) RETURNING CodRet;
            SELECT fecha_cuota INTO vFechaCuota
               FROM sd_amortiza_credito
              WHERE empresa = pEmpresa AND num_credito = vNumCred AND fecha_cuota = FechaHoy;
        END IF;
-----Verifica que en el credito tenga la fecha cuota, si no la crea FIN

        IF vFechaCuota = FechaHoy THEN
           Let DiasAcumInt = FechaHoy - vFechaUDIant;
           LET vIvaInt = 0;
		   
           SELECT iva, plaza INTO vIvaSuc, vPlaza FROM cr_sucursales WHERE empresa = pEmpresa AND sucursal = vSucursal;

        -- ************************************************************
        -- Genera Movimiento de Financiamiento de Intereses           *
        -- ************************************************************
        SELECT NVL(sdo_cap_insoluto,0), NVL((mto_venc_trasp),0), NVL(sdo_trab4,0), monto_financiado - (mto_venc_trasp + monto_vencido)
          INTO vMtoVencido , vVencidoHist, MinimoMesAnt, VigenteMesAnt
          FROM sd_maesdoshist WHERE fecha = FechaHoy - 1 UNITS MONTH AND empresa = pEmpresa AND num_credito = vNumCred;

        LET vMtoVencido_ant = vMtoVencido;
 --***
        IF VigenteMesAnt Is Null OR VigenteMesAnt < 0  THEN
           LET VigenteMesAnt = 0;
        END IF;
        IF SdoCapInsoluto <= 0 THEN
            LET vMtoVencido = 0;
            LET SdoIntereses = 0;
        END IF

        LET vCapInsEsTot = MontoFinanciado;
        IF MontoFinanciado < 0  Or (MontoFinanciado = 0 and vMtoVencido <= 0) THEN  --**Considerar Totalero Cuando El Mto.Financiado Es Cero
            LET MontoFinanciado = MontoFinanciado * -1;
            LET vBandFinan = "1";
        END IF

        IF vBandFinan = "1" THEN
           LET vMtoVencido = vMtoVencido - (MontoFinanciado + MinimoMesAnt);
        ELSE
           LET vMtoVencido = ABS(vMtoVencido - MinimoMesAnt);
        END IF

        IF SdoNoExig > 0 THEN
           LET vSiCap = 'S';
           IF vMtoVencido <= 0  AND  vCapInsEsTot <= 0 THEN
              LET Es_Totalero ="S";
              LET SdoNoExig = 0;
              UPDATE sd_amortiza_credito SET interes_debe = 0, iva_debe = 0, iva_pagado = 0
                WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota -1 UNITS MONTH;
           END IF

           IF (vMtoVencido > 0 AND StatusCred <> "BT" ) or (vCapInsEsTot >0 AND StatusCred <> "BT") THEN
           -- Capitalizacion de iva
              SELECT SUM(iva_debe - iva_pagado) INTO vIvaInt
                FROM sd_amortiza_credito
               WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota -1 UNITS MONTH;

              IF vIvaInt IS NOT NULL AND vIvaInt <> 0 THEN

                  CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,3, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
                  IF (CodRet <> "00000") THEN
                      ROLLBACK WORK;
                      LET vMensaje = "Financiamiento de Iva      ";
                      CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, TRIM(vMensaje) || "(GENMOV)") RETURNING rLog;
                      IF rLog > 0 THEN
                         RETURN CodRet;
                      ELSE
                         CONTINUE FOREACH;
                      END IF
                  ELSE
                      LET CodRet = "000";
                  END IF;
              ELSE
                  LET vIvaInt = 0;
              END IF;

-- Capitalizacion de interes
              IF SdoNoExig IS NOT NULL AND SdoNoExig <> 0 THEN

                  LET MtoVencTraInt = MtoVencTraInt + SdoNoExig;

                  CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,2, "605", FechaHoy,  SdoNoExig, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
                  IF (CodRet <> "00000") THEN
                      ROLLBACK WORK;
                      LET vMensaje = "Financiamiento de Intereses";
                      CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, TRIM(vMensaje) || "(GENMOV)") RETURNING rLog;
                      IF rLog > 0 THEN
                         RETURN CodRet;
                      ELSE
                        CONTINUE FOREACH;
                      END IF
                  ELSE
                      LET CodRet = "000";
                      
                  END IF;
              ELSE
                  LET SdoNoExig = 0;
              END IF;

              LET sdoCapital = SdoCapital + SdoNoExig + vIvaInt;
              LET sdoCapInsoluto = SdoCapInsoluto + SdoNoExig + vIvaInt;
              LET MtoCapitalizado = MtoCapitalizado + SdoNoExig + vIvaInt;
              LET vIntDiario = SdoNoExig;
              LET vIvaInt      = 0;
           END IF
        END IF
        LET vMtoVencido = 0;

         -- *      REALIZA    P R O V I S I O N    AL    CORTE   *
        IF (StatusCred = "BT") THEN
                LET vCodFunInt = "604";
                LET vCodRefInt = 2;
                LET BanderaInt = "1";
        ELSE
                LET vCodFunInt = "606";
                LET vCodRefInt = 1;
                LET BanderaInt = "0";
        END IF;

        SELECT nvl(SUM(interes_debe - interes_pagado),0), nvl(SUM(iva_debe - iva_pagado),0) INTO vProvInt, vProvIva
          FROM sd_amortiza_credito
         WHERE empresa = pEmpresa
           AND num_credito = vNumCred
          AND fecha_cuota = vFechaCuota -1 UNITS MONTH;

      IF ( IntTraNoExig > 0 and StatusCred <>'AA' ) THEN  --Mov. Int Orden.  --CAS
          let IntTraNoExigMes = vProvInt;
          let vIvaOrdenAnt = vProvIva;

          IF IntTraNoExigMes IS NOT NULL AND IntTraNoExigMes <> 0 THEN
              CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,2, 604, FechaHoy, IntTraNoExigMes, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
          ELSE
              LET IntTraNoExigMes = 0;
          END IF;

          IF vIvaOrdenAnt > 0 THEN

              CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,22, 340, FechaHoy, vIvaOrdenAnt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
              IF (CodRet <> "00000") THEN
                   RETURN CodRet;
              ELSE
                 LET CodRet = "000";
              END IF;
           END IF;
      END IF;

  IF SdoNoExig > 0 THEN
      LET SdoNoExig    = 0;   --**JL
      IF vProvInt > 0  THEN
          IF (vSiCap = '' Or vSiCap IS Null) and StatusCred <> "BT"  THEN
---- ESTE CODIGO ESTA DE MAS              
              let vIvaInt = '';
              let vIvaInt=vProvIva;

             IF vIvaInt IS NOT NULL AND vIvaInt <> 0 THEN
                  CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,3, "605", FechaHoy, vIvaInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
             ELSE
                  LET vIvaInt = 0;
             END IF;

             CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,2, 605, FechaHoy, vProvInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
             CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,vCodRefInt, vCodFunInt, FechaHoy, vProvInt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
---- ESTE CODIGO ESTA DE MAS
          ELSE
               CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,vCodRefInt, vCodFunInt, FechaHoy, vProvInt , Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING CodRet, Mensaje;
         END IF;

          IF (CodRet <> "00000") THEN
              ROLLBACK WORK;
              LET vMensaje = "Provision de Int. Ordinarios";
              CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, TRIM(vMensaje) || "(GENMOV)") RETURNING rLog;
              IF rLog > 0 THEN
                RETURN CodRet;
              ELSE
                CONTINUE FOREACH;
              END IF;
          ELSE
              LET CodRet = "000";
          END IF;
          -- Genera Calculo de Iva por Intereses

--- PARA QUE SE REALIZA ESTE CALCULO ????
          CALL calc_iva_grav(pEmpresa, vSucursal, vNumCred, ((SdoAcumMesCap+CapTrasNo)/DiasAcumInt), Folio, TasaIntm, vDivisa, DiasCalc, DiasAcumInt,
                             vProvInt, NumProducto, BanderaInt, vPlaza, "S", vPrecioRealAnt)  RETURNING CodRet, vIvaInt, vIntGrav;
          IF (CodRet <> "000") THEN
             ROLLBACK WORK;
             CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, TRIM(vMensaje) || "(GENMOV)") RETURNING rLog;
             IF rLog > 0 THEN
                RETURN CodRet;
             ELSE
                CONTINUE FOREACH;
             END IF;
          END IF;
--- PARA QUE SE REALIZA ESTE CALCULO ????

          IF vCodFunInt = "606" THEN
            UPDATE sd_amortiza_credito
               SET interes_debe = 0,
                   iva_debe = 0
             WHERE empresa = pempresa
               AND num_credito = vNumCred
               AND fecha_cuota = vFechaCuota - 1 UNITS MONTH;
          END IF;

      END IF
END IF;  -- IF PROVISION

          -- Actualiza Tabla de Amortizacion por Provision de Int Ordinario y por Interes moratorio si existiera
          CALL calc_iva_grav(pEmpresa, vSucursal, vNumCred, SdoIntereses, Folio, TasaIntm, vDivisa, DiasCalc, DiasAcumInt,
                             SdoIntereses, NumProducto, BanderaInt, vPlaza, "N", vPrecioReal) RETURNING CodRet, vIvaInt, vIntGrav;
          IF (CodRet <> "000") THEN
             ROLLBACK WORK;
             CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, TRIM(vMensaje) || "(GENMOV)") RETURNING rLog;
             IF rLog > 0 THEN
                RETURN CodRet;
             ELSE
                CONTINUE FOREACH;
             END IF
          END IF

        If SdoIntereses > 0 then
             UPDATE sd_amortiza_credito
                SET interes_debe = SdoIntereses, iva_debe = vIvaInt, interes_status = DECODE(vCodFunInt,"604","3","1"), campo_trabajo2 = vIntGrav
             WHERE empresa = pEmpresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota;
        end if;

        -- *******************************************************
        -- T r a s p a s o   a    C a r t e r a   V e n c i d a  *
        -- *******************************************************
        IF vBandFinan = "1" THEN
           LET MontoFinanciado = MontoFinanciado * -1;
        END IF

        LET vFechaCuota = NULL;
        IF MontoFinanciado > 0 THEN
           LET vMtoVencido = MontoFinanciado;
        END IF
        IF SdoCapInsoluto = 0 THEN
             LET vMtoVencido = 0;
        END IF

        IF ( vMtoVencido > 0 AND StatusCred <> "BT" ) THEN -- Traspaso de Vigente a transitorio *
            LET vMensaje = "Traspaso a Transitorio ";
            IF StatusCred = "BA" THEN
               LET vMtoVencido = VigenteMesAnt;
            END IF

            IF (vMtoVencido <= SdoCapital) THEN
                LET MontoVencido = MontoVencido + vMtoVencido;
                LET SdoCapital = SdoCapital - vMtoVencido;
            ELSE
                LET MontoVencido = MontoVencido + SdoCapital;
            END IF;

            CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,1, "602", FechaHoy, vMtoVencido, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
            IF (CodRet <> "00000") THEN
                ROLLBACK WORK;
                LET vMensaje = TRIM(vMensaje) || " (GENMOV)";
                CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, vMensaje) RETURNING rLog;
                IF rLog > 0 THEN
                    RETURN CodRet;
                ELSE
                    CONTINUE FOREACH;
                END IF
            ELSE
                LET CodRet = "000";
            END IF;

            IF vFechaVenc IS NULL OR vFechaVenc = " " THEN -- Vencido Trans.
                LET vFechaVenc = DATE(MONTH((FechaHoy -1 UNITS MONTH)) || "/" || vDiaDeCorte || "/" || YEAR((FechaHoy -1 UNITS MONTH)));
            END IF

            IF (StatusCred = "AA") THEN
                UPDATE sd_amortiza_credito
                   SET capital_status = "7"
                 WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = FechaHoy  -1 UNITS MONTH;
            END IF;

            LET StatusCred ="BA";
            LET TrasHoy    = "S";
          
            LET vFechaVencim = FechaHoy;
        END IF -- Traspaso de Vigente a transitorio *

        LET vMensaje = "Traspaso de Transitorio a Vencido";

-- bloque para transitorios o vencidos
        IF ( StatusCred_ant <> "AA" ) THEN
            IF ( StatusCred <> "BT" ) THEN
                    LET StatusCred ="BT";
                    LET MtovencTrasp = (MontoVencido);
                    LET CapTrasNo = SdoCapital;
                    LET SdoCapital= 0;
                    LET MontoVencido = 0;

                    IF CapTrasNo IS NOT NULL AND CapTrasNo <> 0 THEN
                     -- Capital de Vigente a Traspasado
                        CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,1, "601", FechaHoy, (CapTrasNo),
                                    Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
                        IF (CodRet <> "00000") THEN
                            ROLLBACK WORK;
                            LET vMensaje = TRIM(vMensaje)||" Vigente a Vencido(GENMOV)";
                            CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, vMensaje) RETURNING rLog;
                            IF rLog > 0 THEN
                                 RETURN CodRet;
                            ELSE
                                 CONTINUE FOREACH;
                            END IF
                        ELSE
                            LET CodRet = "000";
                        END IF;
                    ELSE 
                        LET CapTrasNo = 0;
                    END IF;

                    IF MtovencTrasp IS NOT NULL AND MtovencTrasp <> 0 THEN
                     -- Capital de transitorio a vencido
                        CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,1, "600", FechaHoy, MtovencTrasp,
                                 Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
                        IF (CodRet <> "00000") THEN
                            ROLLBACK WORK;
                            LET vMensaje = TRIM(vMensaje) || " Trans a Vencido (GENMOV)";
                            CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, vMensaje) RETURNING rLog;
                            IF rLog > 0 THEN
                                RETURN CodRet;
                            ELSE
                                CONTINUE FOREACH;
                            END IF
                        ELSE
                            LET CodRet = "000";
                        END IF;
                    ELSE
                        LET MtovencTrasp = 0;
                    END IF;

                    LET MontoVencido = 0;

                    UPDATE sd_amortiza_credito
                       SET capital_status = "2"
                     WHERE empresa = pempresa
                       AND num_credito = vNumCred
                       AND capital_status IN ("1","7")
                       AND fecha_cuota < FechaHoy
                       AND capital_debe > 0
                       AND (capital_debe - capital_pagado) > 0;
            ELSE   -- Realiza reubicacion de saldos cuando ya esta vencido
                LET MtovencTrasp = MtovencTrasp ;
                LET VigenteMesAnt = VigenteMesAnt ;
                LET MtovencTrasp = MtovencTrasp + VigenteMesAnt;
                LET CapTrasNo = CapTrasNo - VigenteMesAnt; --AXL

                IF VigenteMesAnt IS NOT NULL AND VigenteMesAnt <> 0 THEN
                    CALL genmovcierre_movdia(pEmpresa, vNumCred, NumProducto,2, "601", FechaHoy, VigenteMesAnt, Folio, vSucursal, vDivisa, Transacc,vPlaza) RETURNING  CodRet, Mensaje;
                    IF (CodRet <> "00000") THEN
                        ROLLBACK WORK;
                        LET vMensaje = TRIM(vMensaje) || "Trasp Cap No Exig a Trasp";
                        CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, vMensaje) RETURNING rLog;
                        IF rLog > 0 THEN
                            RETURN CodRet;
                        ELSE
                            CONTINUE FOREACH;
                        END IF
                    ELSE
                        LET CodRet = "000";
                    END IF;
                ELSE
                    LET VigenteMesAnt = 0;
                END IF;

                LET SdoNoExig = 0;

                UPDATE sd_amortiza_credito
                   SET capital_status = "2", interes_status = case when (interes_debe - interes_pagado) > 0 then "3" else interes_status end
                 WHERE empresa = pempresa
                   AND num_credito = vNumCred
                   AND fecha_cuota < FechaHoy
                   AND capital_status IN ("1","7","2");

                SELECT SUM(interes_debe - interes_pagado) INTO IntTraNoExig
                  FROM sd_amortiza_credito
                 WHERE empresa = pempresa
                   AND num_credito = vNumCred
                   AND fecha_cuota < FechaHoy
                   AND capital_status='2';

            END IF -- Status Diferente a BT
        END IF -- Credito Vencido Traspasado

    -- **********************************************
    --       C a l c u l a   M o r a t o r i o s    *
    -- **********************************************
        LET vMensaje = "Acumulacion de Moratorios";

        IF ( StatusCred = "BA" OR StatusCred = "BT" ) THEN

           SELECT MAX(fecha_cuota), count(*) INTO vFechaCuota, vMtofinventrasp
             FROM sd_amortiza_credito
            WHERE empresa = pempresa AND num_credito = vNumCred AND capital_status IN ("2","7");

                LET TasaCope    = vTasaMora - TasaIntm;
                LET MtoMoraOrdiMa = MontoVencido + MtovencTrasp;
                LET MtoMoraCopeMa = MontoVencido + MtovencTrasp;
                LET MtoMoraOrdiMa = (MtoMoraOrdiMa) * TasaIntm/(DiasCalc * 100);
                LET MtoMoraOrdiMa = MtoMoraOrdiMa * DiasProvMa ;
                LET MtoMoraCopeMa = (MtoMoraCopeMa) * TasaCope/(DiasCalc * 100);
                LET MtoMoraCopeMa = MtoMoraCopeMa * DiasProvMa ;
                LET vSdoAcumMora = vSdoAcumMora + MtoMoraOrdiMa + MtoMoraCopeMa;
                LET DiasAcumMora = DiasAcumMora + DiasProvMa;

               UPDATE sd_amortiza_credito
                  SET mora_provi_ordi = mora_provi_ordi + MtoMoraOrdiMa, mora_provi_cope = mora_provi_cope + MtoMoraCopeMa, mora_status = 1
                WHERE empresa = pempresa AND num_credito = vNumCred AND fecha_cuota = vFechaCuota;
        END IF

       -- *********************************************
       -- *        Calculo de pago minimo             *
       -- *********************************************

	   -- Obtiene el monto de pago minimo y factor de monto minimo
        SELECT factor_pago_min::SMALLINT, mto_pago_min::DECIMAL, fact_pag_min_lc INTO vFactorPagoMin, TopeMinimo, vFactorPagoMinLinC FROM bdicred:sd_definicion WHERE empresa = pempresa and num_producto = NumProducto;
	   
        LET vMensaje = "Calculo de pago Minimo";
       -- Pregunta si hay capital pendiente para cobrar los moratorios
        IF TrasHoy = "N" THEN
            IF SdoCapInsoluto = 0 THEN
                LET vSdoAcumMora = 0;
            END IF
        END IF

        -- ************************************************************
        -- Valida si estaba en vencido y ya salio para que regenere el
        -- pago minimo RQM 10 011
        -- ************************************************************
        Let StatusCred = StatusCred;
        let SdoCapInsoluto = SdoCapInsoluto;
        let SdoNoExig = SdoNoExig;
        let SdoExigInt = SdoExigInt;


        IF ( Es_Totalero = "S" ) THEN
            LET SdoTrab4 = 0;
		    LET vComportamiento = 1;
			
            IF SdoCapInsoluto <= 0 THEN
                LET MontoFinanciado = 0;
            ELSE
                LET TotalAdeudo = ROUND(((SdoCapital+CapTrasNo) / vFactorPagoMin), -0) ;
				
				IF TotalAdeudo < ROUND((vmnto_otorgado * vFactorPagoMinLinC),-0) THEN 
					LET TotalAdeudo = ROUND((vmnto_otorgado * vFactorPagoMinLinC),-0); 
				END IF;
				
				IF ( TotalAdeudo > SdoCapInsoluto ) THEN
					LET TotalAdeudo = SdoCapInsoluto;
				END IF;
				
                IF TotalAdeudo < 0 THEN
                    LET TotalAdeudo = 0;
                ELIF SdoCapInsoluto < TopeMinimo THEN
                    IF SdoCapInsoluto < 0 THEN
                        LET TotalAdeudo = 0;
                    ELSE
                        LET TotalAdeudo = SdoCapInsoluto;
                    END IF;
                ELIF TotalAdeudo < TopeMinimo THEN
                    LET TotalAdeudo = TopeMinimo;
                END IF
                LET MontoFinanciado = TotalAdeudo;
            END IF;
        ELSE
            LET TotalAdeudo = ROUND(((SdoCapital+CapTrasNo) / vFactorPagoMin), -0) ;

            IF TotalAdeudo < ROUND((vmnto_otorgado * vFactorPagoMinLinC),-0) THEN 
                LET TotalAdeudo = ROUND((vmnto_otorgado * vFactorPagoMinLinC),-0); 
            END IF;
			
            IF TotalAdeudo < 0 THEN
               LET TotalAdeudo = 0;
            ELIF (SdoCapital+CapTrasNo) < TopeMinimo THEN     --SdoCapInsoluto < TopeMinimo THEN  --210508 Solicitado Por Juan Olivares.
               IF (SdoCapital+CapTrasNo) < 0 THEN    --SdoCapInsoluto < 0 THEN
                   LET TotalAdeudo = 0;
               ELSE
                   LET TotalAdeudo = (SdoCapital+CapTrasNo);     --SdoCapInsoluto;
               END IF;
            ELIF TotalAdeudo < TopeMinimo THEN  --210508 Solicitado Por Juan Olivares.
               LET TotalAdeudo = TopeMinimo;
            END IF

            LET MontoFinanciado = TotalAdeudo;

            IF (SdoCapital+CapTrasNo) <= MontoFinanciado THEN   --SdoCapInsoluto <= MontoFinanciado THEN
               LET MontoFinanciado = (SdoCapital+CapTrasNo);   --SdoCapInsoluto;
               IF MontoFinanciado < 0 THEN
                  LET MontoFinanciado = 0;
               END IF;
            END IF;
        END IF;

      -- Marcar como crédito inactivo si no tuvo movimientos durante el período (by MACF)
      IF (vMtoVencido_ant <= 0 AND SdoCapInsoluto <= 0) THEN
         IF ( vFechaUltPago < FechaHoy -1 UNITS MONTH ) THEN
            LET vComportamiento = 3;
         ELSE
            LET vComportamiento = 2;
         END IF;
      END IF;
      
      IF Round(MontoFinanciado,-1) - MontoFinanciado < 0 THEN
         Let MontoFinanciado = Round(MontoFinanciado,-1) + 10;
      ELSE
         Let MontoFinanciado = Round(MontoFinanciado,-1);
      END IF;

	IF MontoFinanciado>(SdoCapital+CapTrasNo) THEN
	    IF (SdoCapital+CapTrasNo) > 0 THEN
      	  LET vCuotaMes = (SdoCapital+CapTrasNo);
	    ELSE
		  LET vCuotaMes = 0;
	    END IF;
	ELSE
 		LET vCuotaMes = MontoFinanciado;
	END IF;

    LET SdoTrab4 = MontoFinanciado + MontoVencido + MtoVencTrasp;

    IF SdoTrab4 > SdoCapInsoluto THEN
        IF SdoCapInsoluto < 0 THEN
            LET SdoTrab4 = 0;
        ELSE
            LET SdoTrab4 = SdoCapInsoluto;
        END IF;
    END IF;

    LET MontoFinanciado = SdoTrab4;

      -- ********************************************************************
      -- Genera Prorrateo de la Deuda
      -- ********************************************************************
            CALL prorratea_cargos(pEmpresa, vNumCred, vCuotaMes) RETURNING CodRet;

            IF (CodRet <> "000") THEN
                  ROLLBACK WORK;
                  LET vMensaje = TRIM(vMensaje) || " Prorratea Cargos";
                  CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, vMensaje) RETURNING rLog;
                  IF rLog > 0 THEN
                     RETURN CodRet;
                  ELSE
                     CONTINUE FOREACH;
                  END IF
            END IF;
               --** Actualiza Amortiza En CampoTrabajo1  --**
            SELECT NVL(Sum(iva_debe - iva_pagado),0) Into vIvaIntMes FROM sd_amortiza_credito
            WHERE empresa = pEmpresa and num_credito = vNumCred and capital_status in ('2','7');

            UPDATE sd_amortiza_credito SET campo_trabajo1 = vIvaIntMes
            WHERE empresa = pEmpresa and num_credito = vNumCred and fecha_cuota = FechaHoy;

      -- ********************************************************************
      -- Actualiza Intereses del periodo en las columnas correspondientes   *
      -- ********************************************************************
          IF StatusCred IN ("AA", "BA") THEN
             LET SdoNoExig = SdoIntereses;
          ELSE
             LET IntTraNoExig = IntTraNoExig + SdoIntereses;
          END IF;

          LET SdoIntereses = 0;

          -- Actualiza Anexo Maecred
          LET vDiaProxPag = vDiaDeCorte-vDiasGraciaMora;
          LET vFecProxPag = DATE(MONTH(FechaHoy + 1 UNITS MONTH) || "/" || vDiaProxPag || "/" || YEAR(FechaHoy + 1 UNITS MONTH));

          UPDATE sd_maecredanexo
             SET prox_fecha_pago = vFecProxPag, fecha_vencto = vFechaVenc
           WHERE empresa = pEmpresa AND num_credito = vNumCred;

          IF ( StatusCred = "AA" ) THEN
              UPDATE sd_amortiza_credito
                 SET capital_status = "5", capital_pagado = capital_debe
               WHERE empresa = pEmpresa AND num_credito = vNumCred
                 AND fecha_cuota = FechaHoy - 1 UNITS MONTH
                 AND capital_status NOT IN ("2","7");
          END IF;
        END IF; -- Termina IF de DIa de Corte
   END IF;

   -- **********************************************
   -- Actualiza Tabla de Amortizaciones y Maestros
   -- **********************************************

   IF (SdoRetenido > 0) then
       CALL libera_retenido(pEmpresa, vNumCred, SdoRetenido) RETURNING CodRet, SdoRetenido;
       IF (CodRet <> "000") THEN
           LET vMensaje = " Libera Retenido";
           CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy, vMensaje) RETURNING rLog;
       END IF;
   END IF;

   Let SdoNoExig = SdoNoExig;

  -- ******************************************************

   UPDATE sd_maesdos
   SET
      fecha_ult_mov    = FechaHoy,       sdo_int_anticip   = SdoIntAnticip,   sdo_intereses     = SdoIntereses,    sdo_dia_ant_int  = SdoDiaAntInt,    
      sdo_retenido     = SdoRetenido,    sdo_acum_mes_int  = SdoAcumMesInt ,  sdo_exig_int      = SdoExigInt,      sdo_no_exig      = SdoNoExig,       
      dias_acum_int    = DiasAcumInt,    sdo_moratorio     = SdoMoratorio,    sdo_contab_mora   = vSdoAcumMora,    dias_acum_mora   = DiasAcumMora,    
      sdo_capital      = SdoCapital ,    sdo_cap_insoluto  = SdoCapInsoluto,  sdo_dia_ant_cap   = SdoDiaAntCap,    sdo_acum_mes_cap = SdoAcumMesCap,   
      dias_acum_cap    = DiasAcumCap,    mto_capitalizado  = MtoCapitalizado, monto_vencido     = MontoVencido,    mto_venc_trasp   = MtoVencTrasp,    
      dias_acum_intper = DiasAcumIntPer, sdo_global_int    = SdoGlobalInt,    sdo_acum_intper   = SdoAcumIntPer,   mto_venc_int     = vIvaIntMes,      
      mto_venc_tra_int = MtoVencTraInt,  monto_financiado  = MontoFinanciado, mto_fin_ven_trasp = vMtofinventrasp, int_tra_no_exig  = IntTraNoExig,  
      sdo_trab4        = SdoTrab4,       cap_tras_no_venci = CapTrasNo
  WHERE num_credito = vNumCred AND empresa = pEmpresa;

  IF (StatusCred_ant <> StatusCred) then
      UPDATE sd_maecred
         SET status_cred = StatusCred
       WHERE num_credito = vNumCred AND empresa = pEmpresa;
  END IF;

  UPDATE sd_maecredanexo
     SET fecha_proceso = ProxFecha
   WHERE num_credito = vNumCred AND empresa = pEmpresa;

  -- ******************************************************
  -- Actualiza tabla de saldos diaria y mensual
  -- ******************************************************
    Let vIvaInt = 0;
    Let vIvaIntv = 0;

    Select {+INDEX(sd_amortiza_credito amorst)} sum(case when capital_status='1' then (interes_debe - interes_pagado) else 0 end),
           sum(case when capital_status in ('2','7') then (interes_debe - interes_pagado) else 0 end),
           sum(case when capital_status='1' then (iva_debe - iva_pagado) else 0 end),
           sum(case when capital_status in ('2','7') then (iva_debe - iva_pagado) else 0 end)
    into  SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv
    from sd_amortiza_credito
    where empresa = pEmpresa
    and num_credito = vNumCred
    and capital_status in ('1','2','7'); -- validar

   IF FechaHoy = PriHabMes THEN
   	Let vFecMes = PriDiaMes - 1 UNITS DAY;
        Let vFecMes = MDY(MONTH(vFecMes),20,YEAR(vFecMes));
          CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                               SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,FechaHoy) RETURNING CodRet;
        IF (CodRet <> "000") THEN
          LET vMensaje = " Saldos Diarios";
          CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,vMensaje) RETURNING rLog;
       END IF;
   ELSE
          CALL sp_actsdodiario(vNumCred,vSucursal,SdoCapital,MontoVencido,CapTrasNo,MtoVencTrasp,
                               SdoNoExig,IntTraNoExig,vIvaInt,vIvaIntv,vMtofinventrasp,vSdoAcumMora + SdoMoratorio,FechaHoy) RETURNING CodRet;
       IF (CodRet <> "000") THEN
          LET vMensaje = " Saldos Diarios";
          CALL log_cierre (pEmpresa, vNumCred, CodRet, FechaHoy,vMensaje) RETURNING rLog;
      END IF;
  END IF;

   -- *********************************************
   -- Genera Estado de Cuenta                     *
   -- *********************************************
   IF DAY(FechaHoy) = vDiaDeCorte THEN
        -- Genera Historico de Saldos
        LET vMensaje = "Paso a MaesdosHist    ";
        INSERT INTO sd_maesdoshist
        SELECT {+INDEX(sd_maesdos idx_sd_maesdos)} FechaHoy, *
          FROM sd_maesdos
         WHERE empresa = pEmpresa AND num_credito = vNumCred;

       UPDATE sd_maesdos
          SET sdo_int_anticip  = 0, sdo_mes_ant_int  = sdo_intereses, sdo_intereses    = 0, sdo_acum_mes_int = 0,
              sdo_acum_intper  = 0, sdo_acum_mes_cap = 0,             dias_acum_cap    = 0, dias_acum_int    = 0
        WHERE empresa = pEmpresa AND num_credito = vNumCred;

        UPDATE "informix".sd_indicador_cred SET 
			fecha_ultimo_pago_ch = fecha_ultimo_pago, monto_ultimo_pago_ch   = monto_ultimo_pago,   saldo_maximo_ch        = saldo_maximo, 
            fecha_sdo_maximo_ch  = fecha_sdo_maximo , fecha_ultima_compra_ch = fecha_ultima_compra, monto_ultima_compra_ch = monto_ultima_compra,
			atm_disp_monto_ch    = atm_disp_monto,    atm_disp_fecha_ch      = atm_disp_fecha,      pos_disp_monto_ch      = pos_disp_monto, 
            pos_disp_fecha_ch    = pos_disp_fecha,    vnt_disp_monto_ch      = vnt_disp_monto,      vnt_disp_fecha_ch      = vnt_disp_fecha,
			num_vencidos		 = vMtofinventrasp,   num_vencidos_ch        = num_vencidos,        saldo_max_facturado_ch = saldo_max_facturado, 
            pago_mayor_ch        = pago_mayor,        monto_capitalizado_ch  = monto_capitalizado,  num_atm_ch   		   = num_atmc,
			monto_atm_ch 		 = monto_atmc,        num_pos_ch   			 = num_posc,			monto_pos_ch 		   = monto_posc, 
            num_vtn_ch   		 = num_vtnc,   		  monto_vtn_ch 			 = monto_vtnc,          num_pagos_ch 		   = num_pagosc,
			monto_pagos_ch   	 = monto_pagosc,      num_atmc   			 = 0,                   monto_atmc 			   = 0, 
            num_posc   			 = 0,			      monto_posc 			 = 0,                   num_vtnc   			   = 0,
			monto_vtnc 			 = 0,                 num_pagosc 			 = 0,			        monto_pagosc  		   = 0, 
            fecha_ult_respaldo   = FechaHoy,          comportamiento = vComportamiento, 
            fecha_vencido = CASE WHEN fecha_vencido IS NULL AND vFechaVencim IS NOT NULL THEN vFechaVencim ELSE fecha_vencido END                  
        WHERE empresa     = pEmpresa AND num_credito = vNumCred ;
   END IF;
   -- **************************************************
   -- Respaldo de datos para contabilidad a fin de mes *
   -- **************************************************
  IF FechaHoy = UltHabMes THEN
       INSERT INTO bdicred:"informix".sd_maesdoscont
       SELECT FechaHoy, *
         FROM bdicred:"informix".sd_maesdos
        WHERE num_credito = vNumCred AND empresa = pEmpresa ;

      INSERT INTO bdicred:"informix".sd_maecredcont
      SELECT FechaHoy, *
        FROM bdicred:"informix".sd_maecred
       WHERE num_credito = vNumCred AND empresa = pEmpresa ;

    IF (vFechaVenc IS NOT NULL) THEN
--APOYO 2014 INI
        IF ( wbandera_apoyo <> 'A' ) THEN
            LET vdiasatraso = abs(FechaHoy) - abs(date(vFechaVenc + 1 units month));
        END IF;
--APOYO 2014 FIN
    ELSE
        LET vdiasatraso = 0;
    END IF;

    UPDATE bdicred:"informix".sd_indicador_cred
       SET  fecha_ultimo_pago_h   = fecha_ultimo_pago,   monto_ultimo_pago_h   = monto_ultimo_pago,   trans_ultimo_pago_h   = trans_ultimo_pago, 
            saldo_maximo_h        = saldo_maximo,        fecha_sdo_maximo_h    = fecha_sdo_maximo ,   fecha_ultima_compra_h = fecha_ultima_compra,
            monto_ultima_compra_h = monto_ultima_compra, atm_disp_monto_h      = atm_disp_monto,      atm_disp_fecha_h      = atm_disp_fecha, 
            atm_disp_transacc_h   = atm_disp_transacc,   pos_disp_monto_h      = pos_disp_monto,      pos_disp_fecha_h      = pos_disp_fecha,
            pos_disp_transacc_h   = pos_disp_transacc,   vnt_disp_monto_h      = vnt_disp_monto,      vnt_disp_fecha_h      = vnt_disp_fecha, 
            monto_ult_convenio_h  = monto_ult_convenio,  fecha_ult_convenio_h  = fecha_ult_convenio,  num_vencidos_his      = num_vencidos,        
	        num_vencidos		  = vMtofinventrasp,     saldo_max_facturado_h = saldo_max_facturado, pago_mayor_h          = pago_mayor,  
            num_atm_h             = num_atm,             monto_atm_h           = monto_atm,           num_pos_h             = num_pos,
            monto_pos_h           = monto_pos,           num_vtn_h             = num_vtn,             monto_vtn_h           = monto_vtn, 
            num_pagos_h           = num_pagos,           monto_pagos_h         = monto_pagos,         dias_atraso           = vdiasatraso,
			num_atm               = 0,                   monto_atm             = 0,			          num_pos               = 0, 
            monto_pos             = 0,          		 num_vtn               = 0,                   monto_vtn             = 0,
			num_pagos             = 0,                   monto_pagos           = 0,                   fecha_vencido_h       = fecha_vencido, 
            fecha_cancelacion_h   = fecha_cancelacion,   fecha_ult_respaldo    = FechaHoy
       WHERE num_credito = vNumCred AND empresa = pEmpresa;
   END IF

 COMMIT WORK;

END FOREACH

   RETURN CodRet;
END PROCEDURE
DOCUMENT
'Procedimiento para la provision y traspaso a cartera ',
'vencida para creditos tipo tarjeta',
'AUTOR : Antonio Ruiz',
'FECHA : 30/Diciembre/2006',
'VERSION: 1.00.006',
'BD    : BDICRED'
;

CREATE PROCEDURE "informix".sp_repto_inc_mc(pEmpresa CHAR(3), pPeriodoIni DATE, pPeriodoFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(6)        AS codigo_retorno,
			  VARCHAR(80,1)  AS mensaje_retorno,
			  DATE           AS fecha_origen,
			  VARCHAR(20,1)  AS num_solicitud,
			  CHAR(1)        AS origen,
			  VARCHAR(20,1)  AS num_cliente,
			  VARCHAR(110,1) AS nombre,
			  DECIMAL(18,2)  AS lin_cred_actual,
			  DECIMAL(18,2)  AS lin_cred_sugerida,
			  DECIMAL(18,2)  AS porcentaje,
			  CHAR(2)        AS status,
			  CHAR(8)        AS ejecutivo_uno,
			  CHAR(8)        AS ejecutivo_dos,
			  CHAR(8)        AS ejecutivo_tres,
			  VARCHAR(120,1) AS motivo,
			  INTEGER        AS num_registros;
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRet      CHAR(80);
DEFINE cEmpresaAux         CHAR(3);
DEFINE dFechaOrigen        DATE;
DEFINE vNumSolicitud       VARCHAR(20,1);
DEFINE cOrigen             CHAR(1);
DEFINE vNumCte             VARCHAR(20,1);
DEFINE vNomCte             VARCHAR(110,1);
DEFINE dcLinCredActual     DECIMAL(18,2);
DEFINE dcLinCredSugerida   DECIMAL(18,2);
DEFINE dcPorcentaje        DECIMAL(18,2);
DEFINE cStatus             CHAR(2);
DEFINE cEjecutivo1         CHAR(8);
DEFINE cEjecutivo2         CHAR(8);
DEFINE cEjecutivo3         CHAR(8);
DEFINE cMotivo             VARCHAR(120,1);
DEFINE iAux                INTEGER;
DEFINE iDias               INTEGER;
LET iSqlErr      	    = 0;
LET  iIsamErr           = 0;
LET  cErrorInfo         = '';
LET  cCodRet            = '000000';
LET  cMensajeRet        = 'Se realizo la consulta correctamente';
LET cEmpresaAux         = '';
LET dFechaOrigen        = DATE(1);
LET vNumSolicitud       = '';
LET cOrigen             = '';
LET vNumCte             = '';
LET vNomCte             = '';
LET dcLinCredActual     = 0;
LET dcLinCredSugerida   = 0;
LET dcPorcentaje        = 0;
LET cStatus             = '';
LET cEjecutivo1         = '';
LET cEjecutivo2         = '';
LET cEjecutivo3         = '';
LET cMotivo             = '';
LET iAux                = 0;
LET iDias               = 0;
BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0);
   END IF;
END EXCEPTION;
 --SET DEBUG FILE TO '/informix/sp_repto_inc_mc.out';
 --TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 5;
SELECT empresa
  INTO cEmpresaAux
  FROM bdinteg:"informix".si_empresas
 WHERE empresa = pEmpresa;
IF TRIM(NVL(cEmpresaAux,'')) = '' THEN
	LET cCodRet     = '000001';
    LET cMensajeRet = 'La empresa indicada no es valida';
    RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0);
END IF;
IF NVL(pPeriodoIni,DATE(1)) = DATE(1) OR NVL(pPeriodoFin,DATE(1)) = DATE(1) THEN
	LET cCodRet     = '000002';
    LET cMensajeRet = 'El periodo indicado no es valido';
    RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0);
END IF;
IF NVL(pPeriodoIni,DATE(1)) >  NVL(pPeriodoFin,DATE(1)) THEN
	LET cCodRet     = '000003';
    LET cMensajeRet = 'El periodo indicado no es correcto';
    RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0);
END IF;
LET iDias = NVL(pPeriodoFin,DATE(1)) - NVL(pPeriodoIni,DATE(1));
IF  iDias > 31 THEN
	LET cCodRet     = '000004';
    LET cMensajeRet = 'El periodo de consulta indicado no es valido';
    RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0);
END IF;
    SELECT COUNT(a.num_solicitud)
	  INTO iAux
	  FROM "informix".sd_bitacora_aumlincred a
INNER JOIN bdinteg:"informix".si_cliente cte ON cte.empresa ='001' AND cte.numcte =a.numcte
INNER JOIN "informix".sd_historica_cac_aumlincred h1 ON h1.solicitud = a.num_solicitud AND h1.fecha_insert = a.fecha_insert AND h1.puesto = '01'
 LEFT JOIN "informix".sd_historica_cac_aumlincred h2 ON h2.solicitud = a.num_solicitud AND h2.fecha_insert = a.fecha_insert AND h2.puesto = '02'
 LEFT JOIN "informix".sd_historica_cac_aumlincred h3 ON h3.solicitud = a.num_solicitud AND h3.fecha_insert = a.fecha_insert AND h3.puesto = '03'
     WHERE a.empresa = pEmpresa
       AND num_solicitud > ''
       AND a.fecha_insert BETWEEN pPeriodoIni AND pPeriodoFin
       AND a.status IN ('RT','CM','AP')
       AND a.origen = 'S';
IF iAux < 1 THEN
      LET cCodRet     = '000005';
      LET cMensajeRet = 'No hay datos de consulta para el filtro indicado';
      RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0);
END IF;
FOREACH WITH HOLD
	SELECT SKIP pRegistros FIRST pRecuperacion
	       a.fecha_insert, TRIM(a.num_solicitud), TRIM(a.origen), TRIM(a.numcte),
		   TRIM(NVL(cte.nombre1, ''))||' '||TRIM(NVL(cte.nombre2,''))||' '||TRIM(NVL(cte.apell_paterno, ''))||' '||TRIM(NVL(cte.apell_materno, '')),
		   NVL(a.lincred_actual,0), NVL(a.lincred_sugerida,0),
		   CASE WHEN (a.lincred_sugerida - a.lincred_actual) > 0 THEN ROUND(((a.lincred_sugerida - a.lincred_actual) / a.lincred_sugerida) * 100) ELSE 0 END CASE,
		   TRIM(a.status), TRIM(h1.ejecutivo), TRIM(h2.ejecutivo), TRIM(h3.ejecutivo),
		   CASE WHEN status <> "AP" THEN  (SELECT descripcion FROM bdicred:"informix".sd_causas_aumlincred WHERE status = a.status AND causa_status = a.causa_status) ELSE '' END CASE
	  INTO dFechaOrigen, vNumSolicitud, cOrigen, vNumCte, vNomCte, dcLinCredActual, dcLinCredSugerida,
		   dcPorcentaje, cStatus, cEjecutivo1, cEjecutivo2, cEjecutivo3, cMotivo
	  FROM "informix".sd_bitacora_aumlincred a
INNER JOIN bdinteg:"informix".si_cliente cte ON cte.empresa ='001' AND cte.numcte =a.numcte
INNER JOIN "informix".sd_historica_cac_aumlincred h1 ON h1.solicitud = a.num_solicitud AND h1.fecha_insert = a.fecha_insert AND h1.puesto = '01'
 LEFT JOIN "informix".sd_historica_cac_aumlincred h2 ON h2.solicitud = a.num_solicitud AND h2.fecha_insert = a.fecha_insert AND h2.puesto = '02'
 LEFT JOIN "informix".sd_historica_cac_aumlincred h3 ON h3.solicitud = a.num_solicitud AND h3.fecha_insert = a.fecha_insert AND h3.puesto = '03'
     WHERE a.empresa = pEmpresa
       AND num_solicitud > ''
       AND a.fecha_insert BETWEEN pPeriodoIni AND pPeriodoFin
       AND a.status IN ('RT','CM','AP')
       AND a.origen = 'S'
	   ORDER BY a.fecha_insert

	   RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0)  WITH RESUME;
END FOREACH;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para reporte mensual',
'de incrementos via web',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 03/Febrero/2015',
'BD    : BDICRED';

CREATE PROCEDURE "informix".movimientos_edoctacrd_pp(cEmpresa CHAR(3), cNumCredito CHAR(20), dFechaEmision DATE,sNumRegistros SMALLINT)

    RETURNING CHAR(5), DATE, CHAR(20), SMALLINT, SMALLINT, DATE, CHAR(50),DECIMAL(14,2), DECIMAL(14,2);


    -- DECLARACION DE VARIABLES --
    DEFINE sSqlErr SMALLINT;
    DEFINE cCodRet CHAR(5);
    DEFINE cNumeroCredito CHAR(20);
    DEFINE v_maximo SMALLINT;
    DEFINE v_contador SMALLINT;
    DEFINE v_fecha_mov_aux DATE;
------------------------------------------------
    DEFINE v_concepto        CHAR(50);
    DEFINE v_cargos          DECIMAL(14,2);
    DEFINE v_abonos          DECIMAL(14,2);
    DEFINE v_monto_det       DECIMAL(14,2);
    DEFINE v_naturaleza      CHAR (1);
    DEFINE v_cod_ref         INTEGER;
    DEFINE v_cod_fun         CHAR(3);
    DEFINE v_descripcion_det CHAR(255);
    DEFINE v_num_pago_am     INTEGER;
    DEFINE v_plazo           INTEGER;  
    DEFINE v_num_producto    CHAR(4);
    DEFINE vfechacentral     DATE;
    DEFINE v_periodo_tc_ini  DATE;		
    DEFINE v_periodo_tc_fin  DATE;		
    DEFINE v_cod_ret_otro	 CHAR(5);
    DEFINE v_periodo_anterior DATE;
    DEFINE v_dias_periodo_tc INTEGER;
    DEFINE v_fecha_mora DATE;
    define vfechaapertura date;
    define vfechamovimiento date;



    -- INICIALIZACION DE VARIABLES --
    LET sSqlErr          = 0;
    LET cCodRet          = '000';
--    LET dFechaDeEmision = '';
    LET cNumeroCredito   = '';
    LET v_maximo         = 0;
    LET v_contador       = 0;
    -----------------------------------------
    LET v_cargos         = 0;
    LET v_abonos         = 0;
    LET v_monto_det      = 0;
    LET v_naturaleza     = "";
    LET v_cod_ref        = 0;
    LET v_cod_fun        = "";
    LET  v_concepto      = ""; 
    LET v_descripcion_det = "";
    LET v_num_pago_am    = 0;
    LET v_fecha_mov_aux  = DATE(1); 
    LET v_plazo          = 0;
    LET v_num_producto   = "";
    LET vfechacentral    = DATE(1);
    LET v_periodo_tc_ini    = " ";		
    LET v_periodo_tc_fin    = " ";		
    LET v_cod_ret_otro      = "000";	
    LET v_periodo_anterior  = " ";
    LET v_dias_periodo_tc 	= 0;
    LET v_fecha_mora = DATE(1);
    let vfechaapertura = DATE(1); 
    let vfechamovimiento = DATE(1);   


--    SET DEBUG FILE TO "/pisa/leo/detalle_movs_edoctacrd.out";
--    TRACE ON;


    BEGIN
        ON EXCEPTION SET sSqlErr
            LET cCodRet = sSqlErr;
            RETURN cCodRet, dFechaEmision, cNumeroCredito, v_maximo, v_contador, v_fecha_mov_aux,
                   v_concepto,v_cargos,v_abonos;
        END EXCEPTION;


        SELECT num_producto,plazo,fecha_apertura
          INTO v_num_producto,v_plazo, vfechaapertura
          FROM "informix".sd_maecredcrd
         WHERE empresa = cEmpresa
           AND num_credito = cNumCredito;
         

        SELECT fecha_hoy INTO vfechacentral
        FROM bdicred:sd_fechas;
--          LET vfechacentral = mdy('04','02','2011');


            IF (vfechacentral <= dFechaEmision) then
                EXECUTE PROCEDURE sp_mes_siguiente(dFechaEmision,-1,DAY(dFechaEmision)) 
                INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;
                LET v_periodo_tc_ini = v_periodo_anterior + 1 units day;
                LET v_periodo_tc_fin = vfechacentral;
            ELIF (vfechacentral >= dFechaEmision) then  
                let v_periodo_tc_ini = dFechaEmision + 1 units day;
                let v_periodo_tc_fin = vfechacentral;
            ELSE
                LET cCodRet = "001";
                RETURN cCodRet, dFechaEmision, NVL(cNumCredito, ""), NVL(v_maximo, 0), NVL(v_contador, 0),
                       NVL(v_fecha_mov_aux, ""), NVL(v_descripcion_det, 0), NVL(v_cargos, 0), NVL(v_abonos, 0)
                  WITH RESUME;
               
            END IF;

            -- Generación de los Detalles de Movimientos del Estado de Cuenta
			-- AAME 20150430 RQM 10 550 Se contemplan los dos nuevos productos de prestamo para que se muestre los movimientos
            IF v_num_producto IN ('6300','7600','7700') THEN

                if (date(v_periodo_tc_ini - 1 UNITS MONTH) = vfechaapertura) then 
                    let v_periodo_tc_ini = date(v_periodo_tc_ini - 1 UNITS MONTH);
                else
                    let v_periodo_tc_ini = date(v_periodo_tc_ini - 1 UNITS MONTH + 1 units day);
                END IF;

                FOREACH
                    SELECT lpad(month(a.fecha_mov),2,0)||'/'||
                           lpad(day(a.fecha_mov),2,0)||'/'|| lpad(year(a.fecha_mov),4,0),
                           a.referencia,b.descripcion,a.monto,c.naturaleza,a.codigo_fun,a.codigo_ref, fecha_mov
                    INTO v_fecha_mov_aux,
                         v_concepto,
                         v_descripcion_det,
                         v_monto_det,
                         v_naturaleza,
                         v_cod_fun,
                         v_cod_ref,
                         vfechamovimiento
                         FROM "informix".sd_movhiscrd a,
                          "informix".sd_transfun b,
                          bdinteg:si_transacc  c,
                          "informix".sd_definicion d
                    WHERE a.codigo_fun = b.codigo_fun 
                      AND a.codigo_ref  = b.codigo_ref
                      AND c.numero = b.transacc 
                      AND c.se_emite_edocta = "S"
                      AND a.fecha_mov  between v_periodo_tc_ini and v_periodo_tc_fin
    --                  WHEN date(v_periodo_tc_ini - 1 UNITS MONTH) = (select fecha_apertura from bdicred:sd_maecredcrd where a.empresa = empresa  and a.num_credito = num_credito)
    --                  THEN date(v_periodo_tc_ini - 1 UNITS MONTH)
    --                  ELSE date(v_periodo_tc_ini - 1 UNITS MONTH + 1 units day) end
    --                  AND a.fecha_mov <= v_periodo_tc_fin
                      AND a.num_credito = cNumCredito
                      AND a.reversado = "N"
                      AND a.num_producto = v_num_producto
                      AND a.num_producto = d.num_producto
--                      order by secuencia


--                if  (vfechamovimiento > v_periodo_tc_fin or vfechamovimiento < v_periodo_tc_ini) then
--                    continue foreach;
--                end if;

                LET v_contador = v_contador + 3;    

                IF v_naturaleza = "A" THEN
                    LET v_abonos = v_monto_det;
                    LET v_cargos = 0;
                ELSE
                    LET v_cargos = v_monto_det;
                    LET v_abonos = 0;
                END IF

                IF v_cod_fun in ("020","021","022","023","024","025") AND v_cod_ref = 1 THEN
                   LET v_descripcion_det = "";
                   LET v_descripcion_det = TRIM(v_concepto) || " " || v_abonos;
                   LET  v_cargos = 0;
                   LET  v_abonos = 0;

                ELIF v_cod_fun = "002" AND v_cod_ref = 66 THEN
                   LET v_descripcion_det = Trim(v_descripcion_det);

                ELIF v_cod_ref in (43,44) THEN

                ELIF v_cod_fun in ("023") AND v_cod_ref in (2,3) THEN

                     LET v_fecha_mora = v_fecha_mov_aux;
                     LET v_fecha_mov_aux = DATE(1);
                ELSE
                   LET v_fecha_mov_aux = DATE(1);
                   LET v_descripcion_det = Trim(v_descripcion_det) || " " || Trim(v_concepto) || "/" || v_plazo;
                END IF


                IF v_cod_fun = "023" and v_cod_ref = 2 THEN
                   LET v_descripcion_det = substr(Trim(v_descripcion_det),3,17);
                ELIF  v_cod_fun = "023" and v_cod_ref = 3 THEN
                    LET v_descripcion_det = substr(Trim(v_descripcion_det),3,19);
                END IF;

                IF substr(trim(v_descripcion_det),1,1) = "-" THEN
                    LET v_contador = v_contador + 1;   
                ELSE
                    LET v_maximo = v_maximo + 3;
                    LET v_contador = 0;			    
                    LET v_contador = v_contador + 1;			
                END IF;                


                RETURN cCodRet, dFechaEmision, NVL(cNumCredito, ""), NVL(v_maximo, 0), NVL(v_contador, 0),
                       NVL(v_fecha_mov_aux, ""), NVL(v_descripcion_det, 0), NVL(v_cargos, 0), NVL(v_abonos, 0)
                  WITH RESUME;


                LET v_fecha_mov_aux  = date(1);
                LET v_concepto       = "";
                LET v_cargos         = 0;
                LET v_abonos         = 0;

            END FOREACH
        END IF
        END;


END PROCEDURE
DOCUMENT
"Genera el Detalle de los Movimientos del Estado de Cuenta de Crédito Reestructurado",
"AUTOR: Iris Arias Zazueta",
"FECHA: 06/08/2009",
"BD: bdicred";

CREATE PROCEDURE "informix".sp_conciliarsaldoscredito_pba(cEmpresa CHAR(3),cFecha date, cTipoProd integer)
												
--------------------------------------------------------------------
--DOCUMENTACIÓN
--Regresa la conciliacion de los saldos y movimientos de credito vs la balanza contable
--Realizó: Richar 
--Fecha: 06/01/2015
--------------------------------------------------------------------													
--cTipoConcil = tipo de conciliacion 1=Saldos 2 = movimientos
--cTipoProd = 1 TDC, 2 credinomina, 3 prestamos personal y 4 Reestructura

							
    --DATOS A REGRESAR---	
	RETURNING CHAR(5);	--codret
              

			  /*
			   CHAR(40),	--nomproducto
              Char(40), --Concepto
              Char(20), --Nivel contable
              Money(18,2), --Saldo Operativo
              Money(18,2), --Saldo contable
			  */
			  
	--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    ---------------------------
	DEFINE vNomProducto	CHAR(40);
	DEFINE vConcepto 	CHAR(40);
	DEFINE vNivelCon	CHAR(14);
	DEFINE vSaldoOpe	MONEY(18,2);
	DEFINE vSaldoCon	MONEY(18,2);
	DEFINE vDiferencia	MONEY(18,2);
	DEFINE vDiferenciaAbono	MONEY(18,2);
	DEFINE vDiferenciaCargo	MONEY(18,2);
	
	DEFINE vMesactual 	Integer;
	DEFINE vMesmodulo 	Integer;
		
	--	Variables para las cuentas ***********
	DEFINE vCtaCapVig 		Char(14);
	DEFINE vCtaCapTrans 	Char(14);
	DEFINE vCtaCapVenNoNeg 	Char(14);
	DEFINE vCtaCapVenExig	Char(14);
	DEFINE vCtaSdoFavor		Char(14);
	DEFINE vCtaIntVig		Char(14);
	DEFINE vCtaIntVenXTrans	Char(14);
	DEFINE vCtaInteresVen	Char(14);
	DEFINE vCtaIVAIntVig	Char(14);
	DEFINE vCtaIVAInteres	Char(14);
	DEFINE vCtaInteresVenOrd Char(14);
	DEFINE vCtaIVAInteresOrd Char(14);
	
	--  ***********
	DEFINE vDescripcion		Char(50);
	DEFINE vCC			  	Char(50);
	DEFINE vsdoCargos		Money(18,2);
	DEFINE vsdoAbonos		Money(18,2);
	DEFINE vSdoInicioDia	Money(18,2);
	DEFINE vSdoFinDia		Money(18,2);	
	DEFINE vSdoConta 		Money(18,2);	
	DEFINE vsdoCargosConta	Money(18,2);
	DEFINE vsdoAbonosConta	Money(18,2);
		
	--Variables para los saldos del sif
	DEFINE vSdoCapVig 		Money(18,2);
	DEFINE vSdoCapTrans  	Money(18,2);
	DEFINE vSdoCapVenNoNeg	Money(18,2);
	DEFINE vSdoCapVenExig	Money(18,2);
	DEFINE vSdoSdoFavor		Money(18,2);
	DEFINE vSdoInteresVen	Money(18,2);
	DEFINE vSdoIVAInteres	Money(18,2);
	
	
	--Variables para los saldos del sif Abono
	DEFINE vSdoCapVig_a 		Money(18,2);
	DEFINE vSdoCapTrans_a  	Money(18,2);
	DEFINE vSdoCapVenNoNeg_a	Money(18,2);
	DEFINE vSdoCapVenExig_a	Money(18,2);
	DEFINE vSdoSdoFavor_a		Money(18,2);
	DEFINE vSdoInteresVen_a	Money(18,2);
	DEFINE vSdoIVAInteres_a	Money(18,2);
	
	
	--Variables para los saldos de contabilidad	
	DEFINE vSdoCapVigCont 		Money(18,2);
	DEFINE vSdoCapTransCont  	Money(18,2);
	DEFINE vSdoCapVenNoNegCont	Money(18,2);
	DEFINE vSdoCapVenExigCont	Money(18,2);
	DEFINE vSdoSdoFavorCont		Money(18,2);
	DEFINE vSdoInteresVenCont	Money(18,2);
	DEFINE vSdoIVAInteresCont	Money(18,2);
	
	DEFINE vSdoCapVigCont_a 		Money(18,2);
	DEFINE vSdoCapTransCont_a  		Money(18,2);
	DEFINE vSdoCapVenNoNegCont_a	Money(18,2);
	DEFINE vSdoCapVenExigCont_a		Money(18,2);
	DEFINE vSdoSdoFavorCont_a		Money(18,2);
	DEFINE vSdoInteresVenCont_a		Money(18,2);
	DEFINE vSdoIVAInteresCont_a		Money(18,2);	
	
	--Variables para la naturaleza
	DEFINE vSdoCapVigNat 		CHAR(1);
	DEFINE vSdoCapTransNat  	CHAR(1);
	DEFINE vSdoCapVenNoNegNat	CHAR(1);
	DEFINE vSdoCapVenExigNat	CHAR(1);
	DEFINE vSdoSdoFavorNat		CHAR(1);
	DEFINE vSdoInteresVenNat	CHAR(1);
	DEFINE vSdoIVAInteresNat	CHAR(1);
	

	--Banderas
	DEFINE v_paso				varchar(50);
	
	--INICIALIZACION DE VARIABLES--
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET vDiferencia=0;
	LET vDiferenciaAbono=0;
	LET vDiferenciaCargo=0;
	LET vsdoAbonos=0;
	LET vsdoCargos=0;
	LET vsdoAbonosConta=0;
	LET vsdoCargosConta=0;
	
	LET vDescripcion='';	
		
	--LET vMesactual = month(today); --Producción
	LET vMesactual = '01'; --Desarrollo
	LET vMesmodulo = month(cFecha);
	
	--Definimos todas las cuentas contables de TDC
	
	LET vCtaCapVig = '13110101010032';
	LET vCtaCapTrans = '13110101030032';
	LET vCtaCapVenNoNeg = '13610101010232';
	LET vCtaCapVenExig = '13610101010132';
	LET vCtaSdoFavor = '24029014000032';
    LET vCtaIntVig = '13110101020032';
	LET vCtaIntVenXTrans = '13110101040032';
	LET vCtaInteresVen = '13610101020132';
	LET vCtaIVAIntVig ='14020305110132'; --Iva de Interes Vigente
	LET vCtaInteresVenOrd = '77106101010132';
	LET vCtaIVAInteresOrd = '78376101010132';
		
				
	LET vSdoCapVig =0;
	LET vSdoCapTrans =0;
	LET vSdoCapVenNoNeg =0;
	LET vSdoCapVenExig =0;
	LET vSdoSdoFavor =0;
	LET vSdoInteresVen =0;
	LET vSdoIVAInteres =0;
	
	LET vSdoCapVig_a =0;
	LET vSdoCapTrans_a =0;
	LET vSdoCapVenNoNeg_a =0;
	LET vSdoCapVenExig_a =0;
	LET vSdoSdoFavor_a =0;
	LET vSdoInteresVen_a =0;
	LET vSdoIVAInteres_a =0;
	
	LET vSdoCapVigCont =0;
	LET vSdoCapTransCont =0;
	LET vSdoCapVenNoNegCont =0;
	LET vSdoCapVenExigCont =0;
	LET vSdoSdoFavorCont =0;
	LET vSdoInteresVenCont =0;
	LET vSdoIVAInteresCont =0;
	
	LET vSdoCapVigCont_a =0;
	LET vSdoCapTransCont_a =0;
	LET vSdoCapVenNoNegCont_a =0;
	LET vSdoCapVenExigCont_a =0;
	LET vSdoSdoFavorCont_a =0;
	LET vSdoInteresVenCont_a =0;
	LET vSdoIVAInteresCont_a =0;
	
	
	LET v_paso ='';
		
	--SET DEBUG FILE TO "/home/sysifx/sp_conciliarsaldoscredito.out";
	SET DEBUG FILE TO "/resplogifx/P-BD-20150601-01/bdicred/spl/sp_conciliarsaldoscredito.trc";
	TRACE ON;	

	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	 
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--Borramos la tabla donde se va guardando la informacion para el reporte
		delete from sd_conciliacredito;
		
		
				--Valida parámetros de entrada
	IF (cTipoProd=1) THEN		--Tarjeta de credito		
		
				FOREACH
				select descripcion,cc,cargos_dia,abonos_dia,saldo_inicio_dia,saldo_fin_de_dia
				into vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia
				from bdicred:sd_histsdodias SDH
				left join bdicred:sd_catalogocc SDC on SDH.cc=SDC.cuentacontable
				where SDH.producto='TDC' and mes_dia=cFecha 
				and cc in (vCtaCapVig,vCtaCapTrans,vCtaCapVenNoNeg,vCtaCapVenExig,vCtaSdoFavor,vCtaIntVig,vCtaIntVenXTrans,vCtaInteresVen,vCtaIVAIntVig,vCtaInteresVenOrd,vCtaIVAInteresOrd)
				order by ordenar
					
					
					  if vMesactual=vMesmodulo then	--Si es el mismo mes buscar en la tabla co_sdodias
					  
						--Sacamos los saldos para la cuenta diario
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_sdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  else --Si es diferente buscar en la tabla historica
					  
						  --Sacamos los saldos para cada uno de la historica si el mes no es el actual
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_histsdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  End if;
					  
					  -- Capital vigente
					  
					  if vSdoFinDia<0 then
						LET vDiferencia = (vSdoFinDia * -1) - vSdoConta;
					  elif vSdoConta<0 then
						LET vDiferencia = vSdoFinDia - (vSdoConta * -1);
					  else
						LET vDiferencia = vSdoFinDia - vSdoConta;
					  End if;
					  
					  
					  LET vDiferenciaAbono = vsdoAbonos -  vsdoAbonosConta;
					  LET vDiferenciaCargo = vsdoCargos -  vsdoCargosConta;
					  Insert into bdicred:sd_conciliacredito (producto,concepto,nivelcontable,abono_operativo,cargo_operativo,sdoperativo,abono_conta,cargo_conta,sdocontable,sdodif,abonos_dif,cargos_dif,fechasys)
							values('Tarjeta de credito',vDescripcion,vCC,vsdoAbonos,vsdoCargos,vSdoFinDia,vsdoAbonosConta,vsdoCargosConta,vSdoConta,vDiferencia,vDiferenciaAbono,vDiferenciaCargo,today);
						
														
				End FOREACH;
				
				
				LET cCodRet = '00000';
			
				RETURN cCodRet	WITH RESUME;		
				
				
		ElIF (cTipoProd=2) THEN		--Credinomina
		
				LET vCtaCapVig = '13110203010032';
				LET vCtaCapTrans = '13110203030032';
				LET vCtaCapVenNoNeg = '13610203010232';
				LET vCtaCapVenExig = '13610203010132';
				LET vCtaIntVig = '13110203020032';
				LET vCtaInteresVen = '13610203020132';
				LET vCtaInteresVenOrd = '77106102030132';	
				LET vCtaIVAIntVig ='14020305110332'; --Iva de Interes	
				LET vCtaIVAInteresOrd = '78376102030132';
									
		
				FOREACH
				select descripcion,cc,cargos_dia,abonos_dia,saldo_inicio_dia,saldo_fin_de_dia
				into vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia
				from bdicred:sd_histsdodias SDH
				left join bdicred:sd_catalogocc SDC on SDH.cc=SDC.cuentacontable
				where SDH.producto='CDN' and mes_dia=cFecha 
				and cc in (vCtaCapVig,vCtaCapTrans,vCtaCapVenNoNeg,vCtaCapVenExig,vCtaIntVig,vCtaInteresVen,vCtaIVAIntVig,vCtaInteresVenOrd,vCtaIVAInteresOrd)
				order by ordenar
					
					  if vMesactual=vMesmodulo then	--Si es el mismo mes buscar en la tabla co_sdodias
					  
						--Sacamos los saldos para la cuenta diario
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_sdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  else --Si es diferente buscar en la tabla historica
					  
						  --Sacamos los saldos para cada uno de la historica si el mes no es el actual
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_histsdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  End if;
					  
					  -- Capital vigente
					  
					  if vSdoFinDia<0 then
						LET vDiferencia = (vSdoFinDia * -1) - vSdoConta;
					  elif vSdoConta<0 then
						LET vDiferencia = vSdoFinDia - (vSdoConta * -1);
					  else
						LET vDiferencia = vSdoFinDia - vSdoConta;
					  End if;
					  
					  
					  LET vDiferenciaAbono = vsdoAbonos -  vsdoAbonosConta;
					  LET vDiferenciaCargo = vsdoCargos -  vsdoCargosConta;
					  Insert into bdicred:sd_conciliacredito (producto,concepto,nivelcontable,abono_operativo,cargo_operativo,sdoperativo,abono_conta,cargo_conta,sdocontable,sdodif,abonos_dif,cargos_dif,fechasys)
							values('Credinomina',vDescripcion,vCC,vsdoAbonos,vsdoCargos,vSdoFinDia,vsdoAbonosConta,vsdoCargosConta,vSdoConta,vDiferencia,vDiferenciaAbono,vDiferenciaCargo,today);
						
														
				End FOREACH;
				
				
				LET cCodRet = '00000';
			
				RETURN cCodRet	WITH RESUME;		
				
		ElIF (cTipoProd=3) THEN		--Prestamo personal
		
				LET vCtaCapVig = '13110202010032';
				LET vCtaCapTrans = '13110202030032';
				LET vCtaCapVenNoNeg = '13610202010232';
				LET vCtaCapVenExig = '13610202010132';
				LET vCtaIntVig = '13110202020032';
				LET vCtaInteresVen = '13610202020132';
				LET vCtaInteresVenOrd = '77106102020132';	
				LET vCtaIVAIntVig ='14020305110232'; --Iva de Interes	
				LET vCtaIVAInteresOrd = '78376102020132';
											
				FOREACH
				select descripcion,cc,cargos_dia,abonos_dia,saldo_inicio_dia,saldo_fin_de_dia
				into vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia
				from bdicred:sd_histsdodias SDH
				left join bdicred:sd_catalogocc SDC on SDH.cc=SDC.cuentacontable
				where SDH.producto='PP' and mes_dia=cFecha 
				and cc in (vCtaCapVig,vCtaCapTrans,vCtaCapVenNoNeg,vCtaCapVenExig,vCtaIntVig,vCtaInteresVen,vCtaIVAIntVig,vCtaInteresVenOrd,vCtaIVAInteresOrd)
				order by ordenar
					
					  if vMesactual=vMesmodulo then	--Si es el mismo mes buscar en la tabla co_sdodias
					  
						--Sacamos los saldos para la cuenta diario
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_sdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  else --Si es diferente buscar en la tabla historica
					  
						  --Sacamos los saldos para cada uno de la historica si el mes no es el actual
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_histsdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  End if;
					  
					  -- Capital vigente
					  
					  if vSdoFinDia<0 then
						LET vDiferencia = (vSdoFinDia * -1) - vSdoConta;
					  elif vSdoConta<0 then
						LET vDiferencia = vSdoFinDia - (vSdoConta * -1);
					  else
						LET vDiferencia = vSdoFinDia - vSdoConta;
					  End if;					  
					  
					  LET vDiferenciaAbono = vsdoAbonos -  vsdoAbonosConta;
					  LET vDiferenciaCargo = vsdoCargos -  vsdoCargosConta;
					  Insert into bdicred:sd_conciliacredito (producto,concepto,nivelcontable,abono_operativo,cargo_operativo,sdoperativo,abono_conta,cargo_conta,sdocontable,sdodif,abonos_dif,cargos_dif,fechasys)
							values('Prestamo Personal',vDescripcion,vCC,vsdoAbonos,vsdoCargos,vSdoFinDia,vsdoAbonosConta,vsdoCargosConta,vSdoConta,vDiferencia,vDiferenciaAbono,vDiferenciaCargo,today);
						
														
				End FOREACH;				
				
				LET cCodRet = '00000';			
				RETURN cCodRet	WITH RESUME;		
		
	ElIF (cTipoProd=4) THEN		--Restrucutra
		
				LET vCtaCapVig = '13110102010032';				
				LET vCtaCapVenExig = '13610102010132';
				LET vCtaCapVenNoNeg = '13610102010232';				
				LET vCtaCapTrans = '13110102030032';				
				LET vCtaIntVig = '13110102020032';				
				LET vCtaInteresVen = '13610102020032';				
				LET vCtaInteresVenOrd = '77106101020132';				
				LET vCtaIVAIntVig ='14020305110432'; --Iva de Interes					
				LET vCtaIVAInteresOrd = '78376101020132';
											
				FOREACH
				select descripcion,cc,cargos_dia,abonos_dia,saldo_inicio_dia,saldo_fin_de_dia
				into vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia
				from bdicred:sd_histsdodias SDH
				left join bdicred:sd_catalogocc SDC on SDH.cc=SDC.cuentacontable
				where SDH.producto='RTC' and mes_dia=cFecha 
				and cc in (vCtaCapVig,vCtaCapTrans,vCtaCapVenNoNeg,vCtaCapVenExig,vCtaIntVig,vCtaInteresVen,vCtaIVAIntVig,vCtaInteresVenOrd,vCtaIVAInteresOrd)
				order by ordenar
					
					  if vMesactual=vMesmodulo then	--Si es el mismo mes buscar en la tabla co_sdodias
					  
						--Sacamos los saldos para la cuenta diario
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_sdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  else --Si es diferente buscar en la tabla historica
					  
						  --Sacamos los saldos para cada uno de la historica si el mes no es el actual
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_histsdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  End if;
					  
					  -- Capital vigente
					  
					  if vSdoFinDia<0 then
						LET vDiferencia = (vSdoFinDia * -1) - vSdoConta;
					  elif vSdoConta<0 then
						LET vDiferencia = vSdoFinDia - (vSdoConta * -1);
					  else
						LET vDiferencia = vSdoFinDia - vSdoConta;
					  End if;
					  
					  
					  LET vDiferenciaAbono = vsdoAbonos -  vsdoAbonosConta;
					  LET vDiferenciaCargo = vsdoCargos -  vsdoCargosConta;
					  Insert into bdicred:sd_conciliacredito (producto,concepto,nivelcontable,abono_operativo,cargo_operativo,sdoperativo,abono_conta,cargo_conta,sdocontable,sdodif,abonos_dif,cargos_dif,fechasys)
							values('Reestructura',vDescripcion,vCC,vsdoAbonos,vsdoCargos,vSdoFinDia,vsdoAbonosConta,vsdoCargosConta,vSdoConta,vDiferencia,vDiferenciaAbono,vDiferenciaCargo,today);
						
														
				End FOREACH;
				
				
				LET cCodRet = '00000';
			
				RETURN cCodRet	WITH RESUME;
		
		ELSE
		
			--Parámetro de entrada vacío
			LET cCodRet = '00001';
			
				RETURN cCodRet					   					   
				  WITH RESUME;
			
		END IF;
		



	END;
	
END PROCEDURE;