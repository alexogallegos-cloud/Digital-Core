CREATE PROCEDURE "informix".sp_domi_procesararchivo11 (p_CodRuta CHAR(2), p_NombreArchivo VARCHAR(20), p_Usuario CHAR(8))
RETURNING
	CHAR(5), ---cod_ret
	CHAR(80); ---descripcion

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	
	DEFINE sDescMensajeError		VARCHAR(95);
	DEFINE sRuta					CHAR(100);
	DEFINE iNumOperCod11			INTEGER;
	DEFINE iNumRegCod11				INTEGER;
	DEFINE iNumRegCod10				INTEGER;
	DEFINE bBandChecaCtas			CHAR(1);
	DEFINE sFechaPres				CHAR(8);
	DEFINE sMotivoDev				CHAR(2);
	DEFINE bBandPagina				CHAR(1);
	DEFINE iContPagina				INTEGER;
	DEFINE iNumBloques				SMALLINT;
	
	DEFINE sTipoReg					CHAR(2);
	DEFINE sCodDivisa				CHAR(2);
	DEFINE sBancoPres				CHAR(3);
	DEFINE sBancoRec				CHAR(3);
	DEFINE sImporte					CHAR(15);
	DEFINE sTipoOper				CHAR(2);
	DEFINE sTipoCtaOrd				CHAR(2);
	DEFINE sNumCtaOrd				CHAR(20);
	DEFINE sNomOrd					CHAR(40);
	DEFINE sRfcOrd					CHAR(18);
	DEFINE sTipoCtaRec				CHAR(2);
	DEFINE sNumCtaRec				CHAR(20);
	DEFINE sNomRec					CHAR(40);
	DEFINE sRfcRec					CHAR(18);
	DEFINE sRefServicio				CHAR(40);
	DEFINE sNomTitularServ			CHAR(40);
	DEFINE sImporteIva				CHAR(15);
	DEFINE sRefNumerica				CHAR(7);
	DEFINE sRefLeyenda				CHAR(40);
	DEFINE sCveRastreo				CHAR(30);
	DEFINE sCveStatus				CHAR(2);
	DEFINE sFolioSuc				CHAR(16);
	DEFINE sCveStatusVer			CHAR(2);
	DEFINE dFechaHoy				DATE;
	
	---INICIALIZACIONES
	LET v_cod_ret = '00000';
	LET sDescMensajeError	= "";
	LET sRuta						= "";
	LET iNumOperCod11				= "";
	LET iNumRegCod11				= "";
	LET iNumRegCod10				= "";
	LET bBandChecaCtas				= "0";
	LET bBandPagina					= "1";
	LET iContPagina					= 0;
	LET iNumBloques					= 0;
	
	LET sTipoReg					= "";
	LET sCodDivisa					= "";
	LET sBancoPres					= "";
	LET sBancoRec					= "";
	LET sImporte					= "";
	LET sTipoOper					= "";
	LET sTipoCtaOrd					= "";
	LET sNumCtaOrd					= "";
	LET sNomOrd						= "";
	LET sRfcOrd						= "";
	LET sTipoCtaRec					= "";
	LET sNumCtaRec					= "";
	LET sNomRec						= "";
	LET sRfcRec						= "";
	LET sRefServicio				= "";
	LET sNomTitularServ				= "";
	LET sImporteIva					= "";
	LET sRefNumerica				= "";
	LET sRefLeyenda					= "";
	LET sCveRastreo					= "";
	LET sCveStatus					= "";
	LET sFolioSuc					= "";
	LET sCveStatusVer				= "";
	LET dFechaHoy 		 = MDY(1,1,1900);

BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
		
		ROLLBACK WORK;
		--- SI NO SUPERA UN BLOQUE DE 5000 NO HAY NECESIDAD DE HACER ROLLBACK MANUAL
		IF iNumBloques > 0 THEN
			FOREACH
				SELECT banco_presentador,num_cta_rec,fecha_presentacion,DECODE(motivo_dev,"99","01","02") AS CVESTATUS,motivo_dev,rfc_ord
				INTO sBancoPres,sNumCtaRec,sFechaPres,sCveStatus,sMotivoDev,sRfcOrd
				FROM bdidomi: dom_cce_detalle_paso
				WHERE nombre_arch = p_NombreArchivo
				
				DELETE BDIDOMI: dom_ctas_verificadas 
				WHERE nombre_arch = p_NombreArchivo AND fecha_insert = TODAY AND cve_banco = sBancoPres AND cuenta = sNumCtaRec;
						
				UPDATE bdidomi: dom_cce_detalle 
				SET cve_estatus = "00"
				WHERE cod_operacion = "10" AND cve_estatus = "01" AND fecha_presentacion >= REPLACE(TODAY - 5,"-")::CHAR(8)
				AND rfc_ord = sRfcOrd AND num_cta_rec = sNumCtaRec;
				
				UPDATE bdidomi: dom_cce_detalle_paso
				SET cve_estatus = "00"
				WHERE nombre_arch = p_NombreArchivo AND cod_operacion = "11" AND cve_estatus = "01";
			END FOREACH
		END IF
		
        RETURN v_cod_ret, NULL;
    END EXCEPTION;

	---SET DEBUG FILE TO "/tmp/has/Sp_Domi_ProcesarArchivo11.out";
	---TRACE ON;
	
	--- OBTENER LA FECHA DEL SISTEMA
	SELECT fecha_hoy   
	INTO dFechaHoy
	FROM  bdicheq: sc_fechas;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;	
	--- OBTIENE LA RUTA DONDE SE ENCUENTRA EL ARCHIVO 
	SELECT TRIM(valor)
	INTO sRuta
	FROM bdidomi: dom_parametros
	WHERE cod_param = p_CodRuta;

	--- VALIDA CODIGO DE RUTA PERMITIDO
	IF p_CodRuta::SMALLINT NOT IN (1,2,3,4) THEN 
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("01500") INTO v_cod_ret, sDescMensajeError; 
		RETURN v_cod_ret, sDescMensajeError;
	END IF

	--- VALIDA QUE SE HALLA ENCONTRADO LA RUTA
	IF (sRuta IS NULL) OR (sRuta = "") THEN 
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("01501") INTO v_cod_ret, sDescMensajeError; 
		RETURN v_cod_ret, sDescMensajeError;
	END IF

	--- OBTENER EL NUMERO DE REGISTROS DEL ARCHIVO CODIGO 11 QUE EXISTE EN LA TABLA DE DETALLE
	SELECT COUNT(*)
	INTO iNumRegCod11
	FROM bdidomi: dom_cce_detalle_paso  
	WHERE nombre_arch = p_NombreArchivo;

	--- OBTENER EL NUMERO DE OPERACIONES QUE DE LA TABLA DE SUMARIO DEL ARCHIVO CODIGO 11
	SELECT (num_operaciones)::INTEGER
	INTO iNumOperCod11
	FROM bdidomi: dom_cce_sumario_paso  
	WHERE  nombre_arch = p_NombreArchivo;

	--- VALIDAR QUE EL NUMERO DE REGISTROS  SEA IGUAL AL NUMERO DE OPERACIONES DEL ARCHIVO
	IF iNumRegCod11 <> iNumOperCod11 THEN 
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("01502") INTO v_cod_ret, sDescMensajeError; 
		RETURN v_cod_ret, sDescMensajeError;
	END IF

	/*NOTA.- se quito esta validacion por peticion de jaime gonzales, dado que se cambio el flujo, se pueden revcibir la cantidad de registros independite al numero de registros del 10 orignal.
	---  OBTIENE EL NUMERO DE REGISTROS PENDIENTES POR COMPARAR DEL ARCHIVO 10
	SELECT COUNT(*)
	INTO iNumRegCod10
	FROM bdidomi: dom_cce_detalle  
	WHERE cod_operacion = "10"
	AND cve_estatus = "00"
	AND fecha_presentacion >= REPLACE(TODAY - 5,"-")::CHAR(8);
	
	--- VALIDAR QUE EL NUMERO DE REGISTROS  QUE NOS MANDAN NO SEA MAYOR AL NUMERO DE REGISTROS QUE TENEMOS
	IF iNumRegCod11 > iNumRegCod10 THEN 
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("01503") INTO v_cod_ret, sDescMensajeError; 
		RETURN v_cod_ret, sDescMensajeError;
	END IF */
	
	--- CICLO PARA VERIFICAR QUE LAS CUENTAS QUE NOS MANDAN EXISTEN EN LOS REGISTROS DEL ARCHIVO CODIGO 10
	FOREACH 
		SELECT tipo_registro,cod_divisa,banco_presentador,banco_receptor,importe,tipo_operacion
				,tipo_cta_ord,num_cta_ord,nombre_ord,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec
				,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica,ref_leyenda,clave_rastreo,cve_estatus,folio_suc
		INTO sTipoReg,sCodDivisa,sBancoPres,sBancoRec,sImporte,sTipoOper
				,sTipoCtaOrd,sNumCtaOrd,sNomOrd,sRfcOrd,sTipoCtaRec,sNumCtaRec,sNomRec,sRfcRec
				,sRefServicio,sNomTitularServ,sImporteIva,sRefNumerica,sRefLeyenda,sCveRastreo,sCveStatus,sFolioSuc
		FROM bdidomi: dom_cce_detalle_paso 
		WHERE nombre_arch = p_NombreArchivo
		
		IF NOT EXISTS(SELECT tipo_registro FROM bdidomi: dom_cce_detalle WHERE cod_operacion = "10" AND cve_estatus = "00" 
					AND fecha_presentacion >= REPLACE(dFechaHoy - 5,"-")::CHAR(8) AND tipo_registro = "02"
					AND TRIM(cod_divisa) = TRIM(sCodDivisa) AND TRIM(banco_presentador) = TRIM(sBancoRec) AND TRIM(banco_receptor) = TRIM(sBancoPres) --SE COMPARAN EL BANCO RECEPTOR Y PRESENTADOR DE MANERA CRUZADA PORQUE SE CAMBIAN CUANDO SE GENERA EL ARCHIVO 10
					AND TRIM(importe) = TRIM(sImporte) AND TRIM(tipo_operacion) = TRIM(sTipoOper) AND TRIM(tipo_cta_ord) = TRIM(sTipoCtaOrd) AND TRIM(num_cta_ord) = TRIM(sNumCtaOrd)
					AND TRIM(nombre_ord) = TRIM(sNomOrd) AND TRIM(rfc_ord) = TRIM(sRfcOrd) AND TRIM(tipo_cta_rec) = TRIM(sTipoCtaRec) AND TRIM(num_cta_rec) = TRIM(sNumCtaRec)
					AND TRIM(nombre_rec) = TRIM(sNomRec) AND TRIM(rfc_rec) = TRIM(sRfcRec) AND TRIM(ref_servicio) = TRIM(sRefServicio) AND TRIM(nombre_titular_serv) = TRIM(sNomTitularServ)
					AND TRIM(importe_iva) = TRIM(sImporteIva) AND TRIM(ref_numerica) = TRIM(sRefNumerica) AND TRIM(ref_leyenda) = TRIM(sRefLeyenda) AND TRIM(clave_rastreo) = TRIM(sCveRastreo)
					AND TRIM(folio_suc) = TRIM(sFolioSuc)) THEN
			LET bBandChecaCtas = "1";
			EXIT FOREACH;
		END IF
	END FOREACH
	
	--- VALIDA QUE  TODAS LAS CUENTAS SE HAYAN ENCONTRADO EN EL CODIGO 10 SI NO MANDA MENSAJE
	IF bBandChecaCtas = "1" THEN
		EXECUTE PROCEDURE BDIDOMI: sp_ObtenerMensajeError("01504") INTO v_cod_ret, sDescMensajeError; 
		RETURN v_cod_ret, sDescMensajeError;
	END IF
	
	
	--- CICLO PARA PROCESAR EL REGISTRO DE DETALLE
	FOREACH WITH HOLD
		SELECT tipo_registro,cod_divisa,banco_presentador,banco_receptor,importe,tipo_operacion,tipo_cta_ord,num_cta_ord,nombre_ord
				,rfc_ord,tipo_cta_rec,num_cta_rec,nombre_rec,rfc_rec,ref_servicio,nombre_titular_serv,importe_iva,ref_numerica
				,ref_leyenda,clave_rastreo,cve_estatus,folio_suc,fecha_presentacion,DECODE(motivo_dev,"99","01","02") AS CveStatusVer,motivo_dev
		INTO sTipoReg,sCodDivisa,sBancoPres,sBancoRec,sImporte,sTipoOper,sTipoCtaOrd,sNumCtaOrd,sNomOrd
				,sRfcOrd,sTipoCtaRec,sNumCtaRec,sNomRec,sRfcRec,sRefServicio,sNomTitularServ,sImporteIva,sRefNumerica
				,sRefLeyenda,sCveRastreo,sCveStatus,sFolioSuc,sFechaPres,sCveStatusVer,sMotivoDev
		FROM bdidomi: dom_cce_detalle_paso
		WHERE nombre_arch = p_NombreArchivo AND cod_operacion = "11"
		
		LET iContPagina = iContPagina + 1;
		--- bBandPagina = 1 ES EL VALOR CON EL EL QUE INICIA LA PRIMERA VEZ		bBandPagina = 2 ES EL VALOR QUE TOMA CUANDO SE HACE UN BEGIN WORK		bBandPagina = 3 VALOR QUE TOMA CUANDO SE HACE UN COMMIT WORK
		IF bBandPagina IN ("1","3") THEN
			BEGIN WORK;
			LET bBandPagina = "2";
		END IF
		--- SI NO EXISTE INSERTA EN LA TABLA dom_ctas_verificadas SI NO ACTUALIZA
		IF NOT EXISTS(SELECT cve_banco FROM BDIDOMI: dom_ctas_verificadas WHERE cve_banco = sBancoPres AND cuenta = sNumCtaRec) THEN
			INSERT INTO BDIDOMI: dom_ctas_verificadas(cve_banco,cuenta,nombre_arch,fecha_presentacion,cve_estatus,motivo_dev,user_insert,fecha_insert)
			VALUES (sBancoPres,sNumCtaRec,p_NombreArchivo,sFechaPres,sCveStatusVer,sMotivoDev,p_Usuario,CURRENT);
		ELSE
			UPDATE BDIDOMI: dom_ctas_verificadas
			SET nombre_arch = p_NombreArchivo, fecha_presentacion = sFechaPres, cve_estatus = sCveStatusVer, motivo_dev = sMotivoDev
			WHERE cve_banco = sBancoPres AND cuenta = sNumCtaRec;
		END IF
		
		--- ACTUALIZA LA TABLA dom_cce_detalle_paso PARA CAMBIAR EL ESTATUS DE 00 A 01
		UPDATE bdidomi: dom_cce_detalle_paso
		SET cve_estatus = sCveStatusVer
		WHERE nombre_arch = p_NombreArchivo AND cod_operacion = "11" AND num_cta_rec = sNumCtaRec;
		
		--- ACTUALIZA LA TABLA dom_cce_detalle PARA CAMBIAR EL ESTATUS DE 00 A 01
		UPDATE bdidomi: dom_cce_detalle 
		SET cve_estatus = sCveStatusVer
		WHERE cod_operacion = "10" AND cve_estatus = "00" 
		AND fecha_presentacion >= REPLACE(dFechaHoy - 5,"-")::CHAR(8) AND tipo_registro = sTipoReg 
		AND cod_divisa = sCodDivisa AND banco_presentador = sBancoRec AND banco_receptor = sBancoPres --SE COMPARAN EL BANCO RECEPTOR Y PRESENTADOR DE MANERA CRUZADA PORQUE SE CAMBIAN CUANDO SE GENERA EL ARCHIVO 10
		AND importe = sImporte AND tipo_operacion = sTipoOper AND tipo_cta_ord = sTipoCtaOrd AND num_cta_ord = sNumCtaOrd
		AND nombre_ord = sNomOrd AND TRIM(rfc_ord) = TRIM(sRfcOrd) AND tipo_cta_rec = sTipoCtaRec AND num_cta_rec = sNumCtaRec
		AND nombre_rec = sNomRec AND rfc_rec = sRfcRec AND ref_servicio = sRefServicio AND nombre_titular_serv = sNomTitularServ
		AND importe_iva = sImporteIva AND ref_numerica = sRefNumerica AND ref_leyenda = sRefLeyenda AND clave_rastreo = sCveRastreo
		AND folio_suc = sFolioSuc;
		
		--- SI LLEGA A 5000 REALIZA UN COMMIT WORK Y ACTUALIZA LA BANDERA EL CONTADOR Y EL NUMERO DE BLOQUES
		IF iContPagina = 5000 THEN
			COMMIT WORK;
			LET bBandPagina = "3";
			LET iContPagina = 0;
			LET iNumBloques = iNumBloques + 1;
		END IF
	END FOREACH
	
	IF bBandPagina IN ("2","3") THEN
		COMMIT WORK;
	END IF
	
	
	RETURN v_cod_ret, sDescMensajeError;
END;
--##############################################################################
--## Procedimiento   : Sp_Domi_ProcesarArchivo11
--## Version         : 1.0
--## Creado por      : Mohamed CarreÃ³n 
--## Fecha creacion  : Julio de 2009
--##Descripcion :  Procedimiento para procesar la recepcion del archivo codigo 11 el cual es la respuesta al archivo codigo 10
--##############################################################################
END PROCEDURE;