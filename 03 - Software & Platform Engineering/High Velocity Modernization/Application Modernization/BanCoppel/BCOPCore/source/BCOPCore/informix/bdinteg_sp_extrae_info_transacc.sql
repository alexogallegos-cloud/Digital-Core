CREATE PROCEDURE "informix".sp_extrae_info_transacc()

		RETURNING CHAR(40), CHAR(80);
	--DeclaraciÃ³n de Variables
        DEFINE v_codret         	CHAR(40);
        DEFINE v_ruta_unl       	CHAR(50);
        DEFINE v_id_tabla       	CHAR(60);
        DEFINE v_msj_ret        	CHAR(80);
        DEFINE v_sql            	CHAR(1100);
        DEFINE v_fec_hoy        	DATE;
        DEFINE sql_err          	INTEGER;
		DEFINE isam_err          	INTEGER;
        DEFINE error_info       	CHAR(80);
		DEFINE v_fec_ant        	DATE;
		DEFINE v_fecha_upd_com  	DATE;
		DEFINE v_dia               	CHAR(2);
		DEFINE v_mes                CHAR(2);
		DEFINE v_anio 				CHAR(4);
		DEFINE v_fecha 				CHAR(10);
		DEFINE v_dia2               CHAR(2);
		DEFINE v_mes2               CHAR(2);
		DEFINE v_anio2 				CHAR(4);
		DEFINE vCliente    			CHAR(20);
		DEFINE vFolio				CHAR(16);
		DEFINE vFecha               DATE;
		DEFINE vCuenta              CHAR(20);
		DEFINE vMonto               CHAR(17);
		DEFINE vHora                CHAR(12);
		DEFINE vUsuario				CHAR(8);
		DEFINE vTransacc			CHAR(4);
		DEFINE vSaldo               CHAR(17);
		DEFINE vSucursal			CHAR(4);
		DEFINE vBanco				CHAR(20);
		DEFINE vCuentachq		    CHAR(20);
		DEFINE vNumchq              CHAR(11);
		DEFINE vTransacc_suc		CHAR(4);
		DEFINE vNumtarjeta			CHAR(20);
		--DEFINE iLinea				INTEGER;
		DEFINE vFolio_s				CHAR(10);
		DEFINE vReferencia 			CHAR(40);
		DEFINE vPri_nom_ben			CHAR(30);
		DEFINE vSeg_nom_ben			CHAR(30);
		DEFINE vApell_pat_ben		CHAR(30);
		DEFINE vApell_mat_ben		CHAR(30);
		DEFINE vFirstName			CHAR(30);
		DEFINE vMiddleName			CHAR(30);
		DEFINE vLastName 			CHAR(30);
		DEFINE vMotherName			CHAR(30);  
		DEFINE vFechaMax            DATE;
		DEFINE vPri_nom_ben_alt		CHAR(30);
		DEFINE vSeg_nom_ben_alt		CHAR(30);
		DEFINE vApell_pat_ben_alt	CHAR(30);
		DEFINE vApell_mat_ben_alt	CHAR(30);
		DEFINE vBeneficiario		CHAR(104);
		DEFINE vBeneficiario2		CHAR(104);
		DEFINE vIdentificacion 		CHAR(2);
		DEFINE vIdentificacion2		CHAR(2);
		DEFINE vNumId				CHAR(25);
		DEFINE vNumId2				CHAR(25);
		DEFINE vFormapago			CHAR(15);
		DEFINE vNumOrden			CHAR(20);
		DEFINE vClaveConf			CHAR(20);
		DEFINE vFechamin            DATE;
		DEFINE pFechaIni			DATE;
		DEFINE pFechaFin			DATE;
		DEFINE v_fecha_upd_eje		DATE;
		DEFINE iMesActual           INTEGER;
		DEFINE iMes					INTEGER;
		DEFINE iAnio				INTEGER;
		DEFINE vReversado			CHAR(1);
		DEFINE dFecha_borrado       DATE;
		DEFINE iMes_borrado         INTEGER;
		DEFINE vSaltaTransaccion	INTEGER;
		DEFINE vProcesosEjecutados	INTEGER;
		DEFINE vBorraInfo			INTEGER;
		DEFINE vProceso				CHAR(8);
		DEFINE iContador			INTEGER;

	--Inicializacion de Variables
	LET iContador 				= 0;
	LET v_codret   				= '';
	LET v_ruta_unl 	    		= '';
	LET v_id_tabla 				= '';
	LET v_msj_ret 				= '';
	LET v_sql 					= '';
	LET v_dia 					= '';
	LET v_mes 					= '';
	LET v_anio 					= '';
	LET v_fecha 				= '';
	LET v_dia2  				= '';
	LET v_mes2      			= '';
	LET v_anio2 				= '';
	LET vCliente    	        = '';
	LET vFolio					= '';
	LET vFecha       			= DATE(1);
	LET vCuenta      			= '';
	LET vMonto       			= '';
	LET vHora                   = '';
	LET vUsuario				= '';
	LET vTransacc				= '';
	LET vSaldo       			= '';
	LET vSucursal				= '';
	LET vBanco					= '';
	LET vCuentachq				= '';
	LET vNumchq      			= '';
	LET vTransacc_suc           = '';
	LET vNumtarjeta				= '';
	--LET iLinea                  = 0;
	LET vFolio_s                = '';
	LET vReferencia 			= '';
	LET vPri_nom_ben		    = '';
	LET vSeg_nom_ben		    = '';
	LET vApell_pat_ben		    = '';
	LET vApell_mat_ben		    = '';
	LET vPri_nom_ben_alt	    = '';
	LET vSeg_nom_ben_alt	    = '';
	LET vApell_pat_ben_alt	    = '';
	LET vApell_mat_ben_alt	    = '';
	LET vFirstName			 	= '';
	LET vMiddleName				= '';
	LET vLastName 				 = '';
	LET vMotherName				 = '';
	LET vFechaMax              	=DATE(1);
	LET vBeneficiario		   	= '';
	LET vBeneficiario2			= '';
	LET vIdentificacion			= '';
	LET vIdentificacion2		= '';
	LET vNumId					= '';
	LET vNumId2					= '';
	LET vFormapago				= '';
	LET vNumOrden 				= '';
	LET vClaveConf              = '';
	LET vFechamin            	= DATE(1);
	LET pFechaIni			    = DATE(1);
	LET pFechaFin			    = DATE(1);
	LET v_fecha_upd_eje			= DATE(1);
	LET iMesActual				= 0;
	LET	iMes					= 0;
	LET iAnio 					= 0;
	LET vReversado				= '';
	LET dFecha_borrado          = DATE(1);
    LET iMes_borrado            = 0;
	LET vSaltaTransaccion		= Null;
	LET vProcesosEjecutados		= 0;
	LET vBorraInfo				= Null;
	LET vProceso				= '';
/*----------------*----------------*----------------*----------------*----------------*------------*
/ Se crea procedimiento almacenado para extraer la informaciÃ³n requerida para la generaciÃ³n        /
/ de los reportes de auditoria desde la aplicaciÃ³n "Consulta de Transacciones"                     /
/ Elaborado por: Adilene Lara                                                                      /
/ Fecha: 20/11/2014                                                                                /
/ Modificado: Victor Mendoza 23/12/14                                                              /
/ Modificado: Victor Mendoza 09/10/15 Se agrega indice en borrado de la tabla si_rptcaja_aud       /
/ Modificado: Victor Mendoza 17/01/15 Se agregan condiciones para identificar si ya se ejecutÃ³     /
/		previamente un proceso y saltarlo, de igual manera se valida si existe informaciÃ³n en 	   /
/		las tablas y se elimina en caso de ser necesario; se optimiza la bÃºsqueda de Cheques SBC   /
/ Solicitado por: Norberto Corona                                                                  /
*----------------*----------------*----------------*----------------*----------------*------------*/

BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info

		IF sql_err <> 0 THEN
			LET v_codret = 'sql_err: ' || sql_err;
		    LET v_msj_ret = 'Error No Controlado, ' || nvl(vProcesosEjecutados,'') || ' Procesos Ejecutados; Proceso: ' || vProceso;
			RETURN v_codret, v_msj_ret;
		END IF;
	END EXCEPTION;

	 ON EXCEPTION IN (-535)
			  --ROLLBACK WORK;
			  LET v_codret = 'sql_err: ' || sql_err;
			  LET v_msj_ret = 'Error No Controlado, ' || nvl(vProcesosEjecutados,'') || ' Procesos Ejecutados; Proceso: ' || vProceso;
			  COMMIT WORK;
			  RETURN v_codret, v_msj_ret;
     END EXCEPTION;
	
   --SET DEBUG FILE TO '/ifxsif01/PLL/RQI_315/sp_extrae_info_transacc_0023.out';
   --TRACE ON;
	--SET DEBUG FILE TO "/informix/VJMP/extraeinfo/extrae_info_new.out"; --> TRACE DESDE APP217
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;						 

	SELECT fecha_hoy INTO v_fec_hoy FROM bdinteg:"informix".si_fechas;
	SELECT MONTH (fecha_hoy), YEAR (fecha_hoy) INTO iMesActual, iAnio FROM bdinteg:"informix".si_fechas; --Obtener mes y aÃ±o actual

	LET pFechaFin = DATE(iMesActual || '/01/' || iAnio) - DAY (1); --Asignamos Fecha final para periodo de consulta

	IF (iMesActual = 1) THEN --Si mes Actual es enero el mes a consultar debera ser Diciembre del aÃ±o anterior
		LET iMes = 12;
		LET iAnio = iAnio - 1;
	ELSE
		LET iMes = iMesActual - 1;
	END IF;

	IF iMes < 10 THEN
		LET pFechaIni = DATE('0' || iMes || '/01/' || iAnio);
	ELSE
		LET pFechaIni = DATE(iMes || '/01/' || iAnio);
	END IF;

	SELECT MAX (fecha_upd)
    INTO v_fecha_upd_eje
    FROM bdinteg:"informix".si_param_extr
    WHERE ruta_unl = 'info_transacciones';

	
   --INSERT INTO bdinteg:"informix".tiempo  
   --SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Inicio' AS NOMBRE from sysmaster:sysshmvals;
	

-- // ----> Descarga de informaciÃ³n para consulta de transacciones - INICIO <----
 -- AsignaciÃ³n de Inicio de proceso, sin Finalizar
    LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

    --INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 1' AS NOMBRE from sysmaster:sysshmvals;
	
	-------> Descarga de informaciÃ³n de Cheques Devueltos <-------

	LET vProceso = 'CHQ_DEV';
	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'cheques_devueltos';

	IF vSaltaTransaccion is NULL THEN

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		--SELECT FIRST 1 1
		--	INTO vBorraInfo
		--FROM bdinteg:"informix".si_rptcaja_aud
		--WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0001') --Cheques Devueltos
		--	AND fecha BETWEEN pFechaIni AND pFechaFin;
			
		SELECT FIRST 1 1	
        INTO vBorraInfo		
		FROM bdinteg:"informix".si_rptcaja_aud a
        INNER JOIN bdinteg:"informix".si_transacciones_auditar_det d on (a.cod_transacc = d.transaccion AND d.codigo ='0001') --Cheques Devueltos
     	WHERE A.fecha BETWEEN pFechaIni AND pFechaFin;
       

		IF vBorraInfo IS NOT NULL THEN
		
			DELETE {+INDEX (bdinteg:"informix".informix.idx3_si_rptcaja_aud)} FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0001') --Cheques Devueltos
			AND fecha BETWEEN pFechaIni AND pFechaFin;
		         	
		
		END IF;
		
		--Se elimina la Tabla Temporal en caso de que Exista
		DROP TABLE IF EXISTS temp_cheques_devueltos;
		--DROP TABLE IF EXISTS temp_reversos_deb_final;

		-- Se crea Tabla Temporal
		CREATE TEMP TABLE temp_cheques_devueltos
			(folio_suc		CHAR(16),
			fech_alt		DATE,
			cuenta			CHAR(20),
			monto_tot		MONEY,
			fech_hor		DATETIME HOUR TO FRACTION(3),
			usuario			CHAR(8),
			transacc		CHAR(4),
			sdo_cuenta		MONEY,
			sucursal		CHAR(4),
			num_cheq		INTEGER,
			transacc_suc	CHAR(4),
			cancelad		CHAR(1)) with no log;
		
		
			INSERT INTO temp_cheques_devueltos
			SELECT a.folio_suc, a.fech_alt, a.cuenta,a.monto_tot,a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal, a.num_cheq, a.transacc_suc,a.cancelad
			FROM bdicheq:"informix".sc_movhis a
			WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
			AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0001') --Cheques Devueltos
			AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
			AND a.empresa = '001'
			AND a.cancelad <> 'S';
			
			INSERT INTO temp_cheques_devueltos
			SELECT a.folio_suc, a.fech_alt, a.cuenta,a.monto_tot,a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal, a.num_cheq, a.transacc_suc,a.cancelad
			FROM bdicheq:"informix".sc_movhis_old a
			WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
			AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0001') --Cheques Devueltos
			AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
			AND a.empresa = '001'
			AND a.cancelad <> 'S';
		
		LET iContador = 0;
		BEGIN WORK;
		FOREACH WITH HOLD
			SELECT Distinct b.num_cte,a.folio_suc, a.fech_alt, a.cuenta,  a.monto_tot,a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal, d.cvebanco, d.numcuenta, a.num_cheq, a.transacc_suc, c.num_tarjeta, a.cancelad
			INTO vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vUsuario, vTransacc, vSaldo, vSucursal, vBanco, vCuentachq, vNumchq,  vTransacc_suc, vNumtarjeta, vReversado
			FROM temp_cheques_devueltos a,bdicheq:"informix".sc_maechq b, OUTER bdicheq:"informix".sc_tarjeta c,
			bditef:"informix".cce_cheques_dev d
				WHERE  d.numcte = b.num_cte
				AND d.numcte = c.numcte
				AND b.cuenta = a.cuenta
				AND c.cuenta = a.cuenta
				AND c.status_tar = 'A'
				AND c.expiracion > today
				AND d.numcheque = a.num_cheq
				AND d.fecha_alta = a.fech_alt
			
				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, cliente, folio, fecha, cuenta, monto, hora, usuario, transaccion, saldo, sucursal, banco, cuenta_banco, cheque, transacc_suc, tarjeta, reversado)
				VALUES ('001',vTransacc, today, vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vUsuario, vTransacc, vSaldo, vSucursal, vBanco, vCuentachq, vNumchq, vTransacc_suc, vNumtarjeta, vReversado);
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
		
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS temp_cheques_devueltos;

		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'cheques_devueltos', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;

	--INSERT INTO bdinteg:"informix".tiempo  
   --SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 2' AS NOMBRE from sysmaster:sysshmvals;
   
	
	-------> Descarga de informaciÃ³n de Cheques propios <-------
	LET vProceso = 'CHQ_PRO';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'cheques_propios';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;
		
		
		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0002') --Cheques propios
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0002') --Cheques propios
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;
		
		
		--Se elimina la Tabla Temporal en caso de que Exista
		DROP TABLE IF EXISTS temp_cheques_propios;
		--DROP TABLE IF EXISTS temp_reversos_deb_final;

		-- Se crea Tabla Temporal
		CREATE TEMP TABLE temp_cheques_propios
			(folio_suc		CHAR(16),
			fech_alt		DATE,
			cuenta			CHAR(20),
			monto_tot		MONEY,
			fech_hor		DATETIME HOUR TO FRACTION(3),
			usuario			CHAR(8),
			transacc		CHAR(4),
			sdo_cuenta		MONEY,
			sucursal		CHAR(4),
			num_cheq		INTEGER,
			transacc_suc	CHAR(4),
			cancelad		CHAR(1)) with no log;
	    
		INSERT INTO temp_cheques_propios
		SELECT a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal, a.num_cheq, a.transacc_suc, a.cancelad 
		FROM bdicheq:"informix".sc_movhis a
		WHERE a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0002') --Cheques Propios
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.cancelad <> 'S';
				
				
		INSERT INTO temp_cheques_propios
		SELECT a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal, a.num_cheq, a.transacc_suc, a.cancelad 
		FROM bdicheq:"informix".sc_movhis_old a
				WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0002') --Cheques Propios
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.cancelad <> 'S';
		
		
		BEGIN WORK;
		FOREACH WITH HOLD
			SELECT Distinct b.num_cte, a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal, a.num_cheq, a.transacc_suc, c.num_tarjeta, a.cancelad
			INTO vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vUsuario, vTransacc, vSaldo, vSucursal, vNumchq,  vTransacc_suc, vNumtarjeta, vReversado
			FROM temp_cheques_propios a
			Inner Join bdicheq:"informix".sc_maechq b on a.cuenta = b.cuenta
			Left Outer Join bdicheq:"informix".sc_tarjeta c on a.cuenta = c.cuenta AND b.num_cte = c.numcte AND c.cuenta = b.cuenta AND c.status_tar = 'A' and c.expiracion > today
				WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin

				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, cliente, folio, fecha, cuenta, monto, hora, usuario, transaccion, saldo, sucursal,  cheque, transacc_suc, tarjeta, reversado)
				VALUES ('001',vTransacc, today, vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vUsuario, vTransacc, vSaldo, vSucursal,  vNumchq, vTransacc_suc, vNumtarjeta, vReversado);
			
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
			
			
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS temp_cheques_propios;
		
		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'cheques_propios', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
    
	
	--INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 3' AS NOMBRE FROM  sysmaster:sysshmvals;
		
	-------> Descarga de informaciÃ³n de ConcentraciÃ³n de Efectivo <-------
	LET vProceso = 'CON_EFE';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'concentracion_efe';

	IF vSaltaTransaccion is NULL THEN
		
		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0004') --ConcentraciÃÂ³n de Efectivo
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0004') --ConcentraciÃÂ³n de Efectivo
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;

		BEGIN WORK;
		FOREACH WITH HOLD
			SELECT Distinct a.fecha_operacion,  b.hora_solicitud, a.folio_sucursal, a.usuario, a.sucursal, a.monto, a.cod_trans, b.folio_servicio, a.reversado
			INTO vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vFolio_s, vReversado
			FROM bdisuc:"informix".ss_operaciones a
			Inner Join bdisuc:"informix".ss_mae_entradasalida b On a.folio_oper = b.folio_oper
			WHERE a.fecha_operacion BETWEEN pFechaIni AND pFechaFin
			AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
			AND a.cod_trans  IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0004') --ConcentraciÃÂ³n de Efectivo
			AND a.reversado = '0'

			INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, fecha, hora, folio, usuario, sucursal, monto, transaccion, folio_oper, reversado)
			VALUES ('001',vTransacc, today, vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vFolio_s, vReversado);
				
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
			COMMIT WORK;
			LET iContador = 0;
			BEGIN WORK;
			END IF; 	
			
		END FOREACH;
		COMMIT WORK;

			INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
			VALUES('001', pFechaFin, 'info_transacciones', 'concentracion_efe', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
	
--INSERT INTO bdinteg:"informix".tiempo  
	    --SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 4' AS NOMBRE from sysmaster:sysshmvals;
		
	-------> Descarga de informaciÃ³n de DotaciÃ³n de Efectivo <-------
	LET vProceso = 'DOT_EFE';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'dotacion_efe';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0005') --DotaciÃ³n de Efectivo
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0005') --DotaciÃ³n de Efectivo
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;

		BEGIN WORK;
		FOREACH WITH HOLD
			SELECT Distinct a.fecha_operacion,  b.hora_solicitud, a.folio_sucursal, a.usuario, a.sucursal, a.monto, a.cod_trans, b.folio_servicio, a.reversado
			INTO vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vFolio_s, vReversado
			FROM bdisuc:"informix".ss_operaciones a
			Inner Join  bdisuc:"informix".ss_mae_entradasalida b on a.folio_oper = b.folio_oper
			WHERE a.fecha_operacion BETWEEN pFechaIni AND pFechaFin
			AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
			AND a.cod_trans IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0005') --DotaciÃ³n de Efectivo
			AND a.reversado = '0'

		
			INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, fecha, hora, folio, usuario, sucursal, monto, transaccion, folio_oper, reversado)
			VALUES ('001',vTransacc, today, vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vFolio_s, vReversado);
				
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
			COMMIT WORK;
			LET iContador = 0;
			BEGIN WORK;
			END IF; 
			
		END FOREACH;
		COMMIT WORK;

		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'dotacion_efe', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;

	
	
	--INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 5' AS NOMBRE from sysmaster:sysshmvals;
	-------> Descarga de informaciÃ³n de Orden de pago <-------
	LET vProceso = 'O_PAGO';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'orden_pago';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0007') 
		AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE {+INDEX (bdinteg:"informix".informix.idx2_si_rptcaja_aud)}  FROM bdinteg:"informix".si_rptcaja_aud WHERE fecha BETWEEN pFechaIni AND pFechaFin 		AND cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0007');
		END IF;

		
		-- Se Elimna Tabla Temporal
		DROP TABLE IF EXISTS tabtemp_orden_pago;
		
			-- Se crea Tabla Temporal
		CREATE TEMP TABLE tabtemp_orden_pago
		(fech_alt		DATE,
		 fech_hor		DATETIME HOUR TO FRACTION(3),
		 folio_suc		CHAR(16),
		 usuario		CHAR(8),
		 sucursal		CHAR(4),
		 monto_tot		MONEY,
		 transacc		CHAR(4),
		 transacc_suc	CHAR(4),
		 cancelad		CHAR(1)) with no log;
		
		--Se almacena en la Tabla Temporal todos los movimientos de las transacciones correspondientes
		INSERT INTO tabtemp_orden_pago
			Select {+ INDEX(bdicheq:"informix".sc_movhis idx_movhisnew3)} a.fech_alt, a.fech_hor, a.folio_suc, a.usuario, a.sucursal, a.monto_tot, a.transacc,a.transacc_suc, a.cancelad  FROM bdicheq:"informix".sc_movhis a
			WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0007') --Orden de Pago
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.cancelad <> 'S';
				
			INSERT INTO tabtemp_orden_pago
			Select a.fech_alt, a.fech_hor, a.folio_suc, a.usuario, a.sucursal, a.monto_tot, a.transacc,a.transacc_suc, a.cancelad  
			FROM bdicheq:"informix".sc_movhis_old a		
			WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0007') --Orden de Pago
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.cancelad <> 'S';
				
		
		BEGIN WORK;
		FOREACH  WITH HOLD
			SELECT Distinct a.fech_alt, a.fech_hor, a.folio_suc, a.usuario, a.sucursal, a.monto_tot, a.transacc, b.referencia1,d.pri_nom_ben,d.seg_nom_ben,d.apell_pat_ben,d.apell_mat_ben,c.pri_nom_ben,c.seg_nom_ben,c.apell_pat_ben,c.apell_mat_ben,d.identificacion,c.identificacion,d.num_ident,c.num_ident,b.forma_pago,b.cuenta_cargo,a.transacc_suc, a.cancelad
			   INTO vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vNumOrden, vPri_nom_ben,vSeg_nom_ben,vApell_pat_ben,vApell_mat_ben,vPri_nom_ben_alt,vSeg_nom_ben_alt,vApell_pat_ben_alt,vApell_mat_ben_alt, vIdentificacion, vIdentificacion2, vNumId, vNumId2,vFormapago, vCuenta, vTransacc_suc, vReversado
				FROM bdinteg:"informix".tabtemp_orden_pago a
				Inner Join bdisac: "informix". sac_movimientoshistorial b on b.folio_suc = a.folio_suc AND a.fech_alt = b.fecha_pago AND b.id_sucursal = a.sucursal
				Left outer Join bdisac: "informix".sac_enviosdineroya c on b.referencia1 = c.no_control
				Left outer Join bdisac: "informix".sac_enviosdineroyahis d on b.referencia1 = d.no_control
				
			
				-- Formateo de datos --
				 LET vBeneficiario = '';
				 
				
				 IF (vPri_nom_ben) IS NOT NULL THEN 
				 LET vBeneficiario = Trim(vPri_nom_ben) ||' '||NVL(Trim(vSeg_nom_ben),'')||' '||Trim(vApell_pat_ben)||' '||NVL(Trim(vApell_mat_ben),'');
				 LET vIdentificacion = TRIM(vIdentificacion);
				 LET vNumId = TRIM(vNumId);
				 ELSE 
				 LET vBeneficiario =  Trim(vPri_nom_ben_alt) ||' '||NVL(Trim(vSeg_nom_ben_alt),'')||' '||Trim(vApell_pat_ben_alt)||' '||NVL(Trim(vApell_mat_ben_alt),'');
				 LET vIdentificacion = TRIM(NVL(vIdentificacion2,''));
				 LET vNumId = TRIM(NVL(vNumId2,''));
		         END IF;
											
				 CASE vFormapago
				   WHEN '1' THEN LET vFormapago  = 'EFECTIVO';
				   WHEN '2' THEN LET vFormapago  = 'CARGO EN CUENTA';
				   WHEN '3' THEN LET vFormapago  = 'PAGO MIXTO';  
				   WHEN '4' THEN LET vFormapago  = 'ABONO EN CUENTA';  
				   WHEN '5' THEN LET vFormapago  = 'CARGO EN TDC';  
				   WHEN NULL THEN LET vFormapago = '';
				   ELSE LET vFormapago = vFormapago;
				 END CASE;
				 
				 LET vNumOrden = TRIM(NVL(vNumOrden,''));
				
				
				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, fecha, hora, folio, usuario, sucursal, monto, transaccion, num_orden, beneficiario, identificacion, folio_identif, referencia, cuenta, transacc_suc, reversado)
				VALUES ('001',vTransacc, today, vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc,vNumOrden, vBeneficiario, vIdentificacion, vNumId,vFormapago, vCuenta, vTransacc_suc, vReversado );
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
			
		END FOREACH;
		COMMIT WORK;
	    DROP TABLE IF EXISTS tabtemp_orden_pago;
		
		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'orden_pago', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
	
	

    --INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 6' AS NOMBRE from sysmaster:sysshmvals;
		


	-------> Descarga de informaciÃ³n de Remesas BTS <-------
	LET vProceso = 'REM_BTS';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'remesas_bts';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0008') --Remesas BTS
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE {+INDEX (bdinteg:"informix".informix.idx2_si_rptcaja_aud)} FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0008') --Remesas BTS
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;
		
		-- Se Elimna Tabla Temporal
		DROP TABLE IF EXISTS tabtem_remesas_bts;
		--DROP TABLE IF EXISTS tabtem_remesas_final;
		
			-- Se crea Tabla Temporal
		CREATE TEMP TABLE tabtem_remesas_bts
		(fech_alt		DATE,
		 fech_hor		DATETIME HOUR TO FRACTION(3),
		 folio_suc		CHAR(16),
		 usuario		CHAR(8),
		 sucursal		CHAR(4),
		 monto_tot		MONEY,
		 transacc		CHAR(4),
		 transacc_suc	CHAR(4),
		 cancelad		CHAR(1)) with no log;
		 
		
		 -- Se crea Tabla Temporal
		CREATE TEMP TABLE tabtem_remesas_bts_final
		(fech_alt		DATE,
		 fech_hor		DATETIME HOUR TO FRACTION(3),
		 folio_suc		CHAR(16),
		 usuario		CHAR(8),
		 sucursal		CHAR(4),
		 monto_tot		MONEY,
		 transacc		CHAR(4),
		 transacc_suc	CHAR(4),
		 cancelad		CHAR(1)) with no log;
		
		--Se almacena en la Tabla Temporal todos los movimientos de las transacciones correspondientes
		INSERT INTO tabtem_remesas_bts
			Select {+ INDEX(bdicheq:"informix".sc_movhis idx_movhisnew3)} a.fech_alt, a.fech_hor, a.folio_suc, a.usuario, a.sucursal, a.monto_tot, a.transacc,a.transacc_suc, a.cancelad 
			FROM bdicheq:"informix".sc_movhis a
			WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND  a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0008') --Remesas BTS
				AND a.cancelad <> 'S'
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S');
				
			INSERT INTO tabtem_remesas_bts
			Select a.fech_alt, a.fech_hor, a.folio_suc, a.usuario, a.sucursal, a.monto_tot, a.transacc,a.transacc_suc, a.cancelad  
			FROM bdicheq:"informix".sc_movhis_old a
				WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0008') --Remesas BTS
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.cancelad <> 'S';
		   
			--INSERT INTO tabtem_remesas_bts_final
			--Select a.fech_alt, a.fech_hor, a.folio_suc, a.usuario, a.sucursal, a.monto_tot, --a.transacc,a.transacc_suc, a.cancelad  --Remesas BTS
			--FROM tabtem_remesas_bts a
			--WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin;
			
		
	BEGIN WORK;	
	FOREACH WITH HOLD
	
	SELECT Distinct a.fech_alt, a.fech_hor, a.folio_suc, a.usuario,a.sucursal,a.monto_tot,a.transacc,b.referencia1 as Referencia1,
			'' as Beneficiario,b.forma_pago,b.cuenta_cargo, a.transacc_suc, a.cancelad
			    INTO vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vClaveConf, vBeneficiario,vFormapago, vCuenta, vTransacc_suc, vReversado
				FROM tabtem_remesas_bts a
				Inner Join bdisac: "informix". sac_movimientoshistorial b on (b.folio_suc = a.folio_suc AND b.id_sucursal = a.sucursal 
				and b.fecha_pago = a.fech_alt)
				WHERE b.status_cancelado ='N'
			
				
				
				CASE vFormapago
				   WHEN '1' THEN LET vFormapago  = 'EFECTIVO';
				   WHEN '2' THEN LET vFormapago  = 'CARGO EN CUENTA';
				   WHEN '3' THEN LET vFormapago  = 'PAGO MIXTO';  
				   WHEN '4' THEN LET vFormapago  = 'ABONO EN CUENTA';  
				   WHEN '5' THEN LET vFormapago  = 'CARGO EN TDC';  
				   WHEN NULL THEN LET vFormapago = '';
				   ELSE LET vFormapago = vFormapago;
				 END CASE;
				
                LET vClaveConf = TRIM(vClaveConf);							
				
				-- Obtener Beneficiaio  query optimizado. 
				SELECT MAX(fecha_insert)
				INTO vFechaMax
				FROM   bdisac: "informix".sac_bts_qryi 
				WHERE  confirmation_nm = vClaveConf
				AND txn_status = 'A';
			
				SELECT  r_first_name ,  r_middle_name , r_last_name ,r_mother_m_name
				INTO    vFirstName,vMiddleName,vLastName,vMotherName
				FROM   	bdisac: "informix".sac_bts_qryi 
				WHERE  	confirmation_nm = vClaveConf
				AND  	fecha_insert = vFechaMax
				AND 	txn_status = 'A';
				
				
				SELECT LIMIT 1 MAX(fecha_insert) ,p.r_identif_type , p.r_identif_nm
				INTO vFechaMax,vIdentificacion, vNumId
				FROM bdisac: "informix".sac_bts_payi p 
				WHERE confirmation_nm = vClaveConf
				AND txn_status = 'A'
				GROUP BY p.r_identif_type , p.r_identif_nm;
				-- Formato del beneficiario -- 
				 LET vBeneficiario = TRIM(NVL(NVL(trim(vFirstName),'') ||' '||NVL(trim(vMiddleName),'')||' '||NVL(trim(vLastName),'')||' '||NVL(trim(vMotherName),''),''));
			
						
				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, fecha, hora, folio, usuario, sucursal, monto, transaccion, clave_confir,  beneficiario, identificacion, folio_identif, referencia, cuenta, transacc_suc , reversado)
				VALUES ('001',vTransacc, today, vFecha, vHora, vFolio, vUsuario, vSucursal, vMonto, vTransacc, vClaveConf, vBeneficiario, vIdentificacion, vNumId,vFormapago, vCuenta, vTransacc_suc, vReversado );
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
		
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS tabtem_remesas_bts;

		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'remesas_bts', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
    
		
	--INSERT INTO bdinteg:"informix".tiempo  
    --SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 7' AS NOMBRE from sysmaster:sysshmvals;
	

	-------> Descarga de informaciÃ³n de Reversos CrÃ©dito <-------
	LET vProceso = 'REV_CRE';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'reversos_cre';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0012') --Reversos CrÃ©dito
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0012') --Reversos CrÃ©dito
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;

		BEGIN WORK;	
		FOREACH WITH HOLD
			SELECT Distinct b.numcte, a.folio_suc, a.usuario, a.fecha_mov, a.hora_mov, a.num_credito, a.monto, a.transacc_suc, c.sdo_capital, a.sucursal, a.transacc_suc, a.referencia, a.nro_tarjeta, a.reversado
			INTO vCliente, vFolio, vUsuario, vFecha, vHora, vCuenta, vMonto, vTransacc, vSaldo, vSucursal, vTransacc_suc, vReferencia, vNumTarjeta, vReversado
			FROM bdicred:"informix".sd_movhis a
			Inner Join bdicred:"informix".sd_maecred b On b.num_credito = a.num_credito
			Inner Join bdicred:"informix".sd_maesdos c On c.num_credito = a.num_credito
				WHERE a.fecha_mov BETWEEN pFechaIni AND pFechaFin
				AND a.empresa = '001'
				AND a.transacc_suc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0012')	--Reversos CrÃ©dito
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.reversado = 'S'

		
				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, cliente, folio, usuario, fecha, hora, cuenta, monto, transaccion, saldo, sucursal, transacc_suc, referencia, tarjeta, reversado)
				VALUES ('001', vTransacc, today, vcliente, vFolio, vUsuario, vFecha, vHora, vCuenta, vMonto, vTransacc, vSaldo, vSucursal, vTransacc_suc, vReferencia, vNumTarjeta, vReversado);
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
				
								
		END FOREACH;
		COMMIT WORK;

			INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
			VALUES('001', pFechaFin, 'info_transacciones', 'reversos_cre', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;

	
	--INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 8' AS NOMBRE from sysmaster:sysshmvals;
	
	-------> Descarga de informaciÃ³n de Reversos DÃ©bito <-------
	LET vProceso = 'REV_DEB';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'reversos_deb';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0009') --Reversos DÃ©bito
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0009') --Reversos DÃ©bito
			AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;
		
		--Se elimina la Tabla Temporal en caso de que Exista
		DROP TABLE IF EXISTS temp_reversos_deb;
		--DROP TABLE IF EXISTS temp_reversos_deb_final;

		-- Se crea Tabla Temporal
		CREATE TEMP TABLE temp_reversos_deb
			(folio_suc		CHAR(16),
			usuario		CHAR(8),
			fech_alt		DATE,
			fech_hor		DATETIME HOUR TO FRACTION(3),
			cuenta			CHAR(20),
			monto_tot		MONEY,
			transacc		CHAR(4),
			sdo_cuenta		MONEY,
			sucursal		CHAR(4),
			transacc_suc	CHAR(4),
			referencia 		CHAR(40),
			cancelad		CHAR(1)) with no log;
		
	      INSERT INTO temp_reversos_deb
		    SELECT b.folio_suc, b.usuario, b.fech_alt, b.fech_hor,b.cuenta, b.monto_tot, b.transacc, b.sdo_cuenta, b.sucursal, b.transacc_suc, b.referencia, b.cancelad
	        FROM bdicheq:"informix".sc_movhis b
			WHERE b.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND b.empresa ='001'
				AND b.transacc_suc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0009') --Reversos DÃ©bito
				AND b.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND b.cancelad = 'S';
	      
			INSERT INTO temp_reversos_deb
			SELECT b.folio_suc, b.usuario, b.fech_alt, b.fech_hor,b.cuenta, b.monto_tot, b.transacc, b.sdo_cuenta, b.sucursal, b.transacc_suc, b.referencia, b.cancelad
			FROM bdicheq:"informix".sc_movhis_old b
			WHERE b.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND b.empresa ='001'
				AND b.transacc_suc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0009') --Reversos DÃ©bito
				AND b.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND b.cancelad = 'S';
	
	
		BEGIN WORK;
		FOREACH  WITH HOLD
			SELECT DISTINCT c.num_cte, b.folio_suc, b.usuario, b.fech_alt, b.fech_hor,b.cuenta, b.monto_tot, b.transacc, b.sdo_cuenta, b.sucursal, b.transacc_suc, b.referencia, d.num_tarjeta, b.cancelad
			INTO vCliente, vFolio, vUsuario, vFecha, vHora, vCuenta, vMonto, vTransacc, vSaldo, vSucursal, vTransacc_suc, vReferencia, vNumTarjeta, vReversado
			FROM temp_reversos_deb b
			Inner Join  bdicheq:"informix".sc_maechq c on c.cuenta = b.cuenta
			Left Outer Join bdicheq:"informix".sc_tarjeta d on b.cuenta = d.cuenta and c.num_cte = d.numcte AND d.status_tar = 'A' and d.expiracion > today
				
			INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, folio_oper, fecha_insert, cliente, folio, usuario, fecha, hora, cuenta, monto, transaccion, saldo, sucursal, transacc_suc, referencia, tarjeta, reversado)
			VALUES ('001', vTransacc_suc, today, vcliente, vFolio, vUsuario, vFecha, vHora, vCuenta, vMonto, vTransacc, vSaldo, vSucursal, vTransacc_suc, vReferencia, vNumTarjeta, vReversado);
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
		
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS temp_reversos_deb;
		
		LET vCliente = TRIM(vCliente);

		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'reversos_deb', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
    
	--INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta 9' AS NOMBRE from sysmaster:sysshmvals;
	
	-------> Descarga de informaciÃ³n de Pagos Reversados <-------
	LET vProceso = 'PAG_REV';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'pagos_reversados';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0013') --Pagos Reversados
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE  FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0013') --Pagos Reversados
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;

		
		--Se elimina la Tabla Temporal en caso de que Exista
		DROP TABLE IF EXISTS temp_pagos_reversados;
		--DROP TABLE IF EXISTS temp_reversos_deb_final;

		-- Se crea Tabla Temporal
		CREATE TEMP TABLE temp_pagos_reversados
			(folio_suc		CHAR(16),
			usuario		CHAR(8),
			fech_alt		DATE,
			fech_hor		DATETIME HOUR TO FRACTION(3),
			cuenta			CHAR(20),
			monto_tot		MONEY,
			transacc		CHAR(4),
			sdo_cuenta		MONEY,
			sucursal		CHAR(4),
			transacc_suc	CHAR(4),
			referencia 		CHAR(40),
			num_tarjeta		CHAR(20),
			cancelad		CHAR(1)) with no log;
		
		
			INSERT INTO temp_pagos_reversados
		    SELECT  b.folio_suc, b.usuario, b.fech_alt, b.fech_hor,b.cuenta, b.monto_tot, b.transacc, b.sdo_cuenta, b.sucursal, b.transacc_suc, b.referencia, b.num_tarjeta, b.cancelad
			FROM bdicheq:"informix".sc_movhis b
			WHERE b.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND b.empresa = '001'
				AND b.transacc_suc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0013') --Pagos Reversados
				AND b.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND b.cancelad = 'S';
				
			INSERT INTO temp_pagos_reversados
		    SELECT  b.folio_suc, b.usuario, b.fech_alt, b.fech_hor,b.cuenta, b.monto_tot, b.transacc, b.sdo_cuenta, b.sucursal, b.transacc_suc, b.referencia, b.num_tarjeta, b.cancelad
			FROM bdicheq:"informix".sc_movhis_old b
			WHERE b.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND b.empresa = '001'
				AND b.transacc_suc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0013') --Pagos Reversados
				AND b.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND b.cancelad = 'S';
			
		BEGIN WORK;
		FOREACH  WITH HOLD
			SELECT Distinct c.num_cte, b.folio_suc, b.usuario, b.fech_alt, b.fech_hor,b.cuenta, b.monto_tot, b.transacc, b.sdo_cuenta, b.sucursal, b.transacc_suc, b.referencia, b.num_tarjeta, b.cancelad
			INTO vCliente, vFolio, vUsuario, vFecha, vHora, vCuenta, vMonto, vTransacc, vSaldo, vSucursal, vTransacc_suc, vReferencia, vNumTarjeta, vReversado
			FROM temp_pagos_reversados b
			Inner Join bdicheq:"informix".sc_maechq c on c.cuenta = b.cuenta
				
			LET vCliente = TRIM(vCliente);
			
				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, cliente, folio, usuario, fecha, hora, cuenta, monto, transaccion, saldo, sucursal, transacc_suc, referencia, tarjeta, reversado)
				VALUES ('001', vTransacc_suc, today, vcliente, vFolio, vUsuario, vFecha, vHora, vCuenta, vMonto, vTransacc, vSaldo, vSucursal, vTransacc_suc, vReferencia, vNumTarjeta, vReversado);
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
			
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS temp_pagos_reversados;

		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'pagos_reversados', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
    
	--INSERT INTO bdinteg:"informix".tiempo  
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta10' AS NOMBRE from sysmaster:sysshmvals;
	-------> Descarga de informaciÃ³n de movimientos SPEI <-------
	LET vProceso = 'SPEI';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'spei';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;

		--Identifica si es necesario Eliminar la informaciÃ³n de la tabla previo a su ejecuciÃ³n
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0011')
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0011') --SPEI
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;

		
		--Se elimina la Tabla Temporal en caso de que Exista
		DROP TABLE IF EXISTS temp_spei;
		--DROP TABLE IF EXISTS temp_reversos_deb_final;

		-- Se crea Tabla Temporal
		
			CREATE TEMP TABLE temp_spei
			(folio_suc		CHAR(16),
			fech_alt		DATE,
			cuenta			CHAR(20),
			monto_tot		MONEY,
			fech_hor		DATETIME HOUR TO FRACTION(3),
			sucursal		CHAR(4),
			sdo_cuenta		MONEY,
			transacc		CHAR(4),
			referencia 		CHAR(40),
			transacc_suc	CHAR(4),
			usuario			CHAR(8),
			cancelad		CHAR(1)) with no log;
	    
		
		INSERT INTO temp_spei
		SELECT  a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.sucursal, a.sdo_cuenta, a.transacc, a.referencia, a.transacc_suc, a.cancelad, a.usuario
		 	FROM bdicheq:"informix".sc_movhis a
				WHERE a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0011') --SPEI
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.empresa = '001'
				AND a.cancelad <> 'S';
				
				
		INSERT INTO temp_spei 		
		SELECT  a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.sucursal, a.sdo_cuenta, a.transacc, a.referencia, a.transacc_suc, a.cancelad, a.usuario
		FROM bdicheq:"informix".sc_movhis_old a
				WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
				AND a.empresa = '001'
				AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0011') --SPEI
				AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
				AND a.cancelad <> 'S';
		
		BEGIN WORK;
		FOREACH  WITH HOLD
			SELECT Distinct b.num_cte, a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.sucursal, a.sdo_cuenta, a.transacc, a.referencia, a.transacc_suc, a.cancelad, a.usuario
			INTO vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vSucursal, vSaldo, vTransacc, vReferencia,  vTransacc_suc, vReversado, vUsuario
			FROM temp_spei a
			Inner join bdicheq:"informix".sc_maechq b on b.cuenta = a.cuenta
								
				LET vCliente = TRIM(vCliente);

				INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, cliente, folio, fecha, cuenta, monto, hora,  sucursal, saldo, transaccion, transacc_suc, referencia, reversado, usuario)
				VALUES ('001', vTransacc, today, vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vSucursal, vSaldo, vTransacc, vTransacc_suc, vReferencia, vReversado, vUsuario);
				
				LET iContador = iContador + 1;
				IF iContador = 1000 THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
				END IF; 
		
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS temp_spei;

		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'spei', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;

    
	--INSERT INTO bdinteg:"informix".tiempo   
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Consulta11' AS NOMBRE from sysmaster:sysshmvals;
	
	-------> Descarga de informaciÃ³n de Cheques SBC <-------
	LET vProceso = 'CHQ_SBC';
	LET v_codret = '00001';
    LET v_msj_ret = 'Inicio de proceso, sin Finalizar';

	SELECT 1
		INTO vSaltaTransaccion
	FROM bdinteg:"informix".si_param_extr
	WHERE fecha_ant = pFechaFin
		and ruta_unl = 'info_transacciones'
		and id_tabla = 'cheques_sbc';

	IF vSaltaTransaccion is NULL THEN
		--LET iLinea = 0;
		LET vBorraInfo = NULL;

		SELECT FIRST 1 1
			INTO vBorraInfo
		FROM bdinteg:"informix".si_rptcaja_aud
		WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0003')--Cheques SBC
			AND fecha BETWEEN pFechaIni AND pFechaFin;

		IF vBorraInfo IS NOT NULL THEN
			DELETE FROM bdinteg:"informix".si_rptcaja_aud
			WHERE cod_transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0003')--Cheques SBC
				AND fecha BETWEEN pFechaIni AND pFechaFin;
		END IF;

		--Se elimina la Tabla Temporal en caso de que Exista
		DROP TABLE IF EXISTS tabtemp_cheques_sbc;

		-- Se crea Tabla Temporal
		CREATE TEMP TABLE tabtemp_cheques_sbc
			(num_cte 		CHAR(20),
			folio_suc		CHAR(16),
			fech_alt		DATE,
			cuenta			CHAR(20),
			monto_tot		MONEY,
			fech_hor		DATETIME HOUR TO FRACTION(3),
			usuario			CHAR(8),
			transacc		CHAR(4),
			sdo_cuenta		MONEY,
			sucursal		CHAR(4),
			num_cheq		INTEGER,
			transacc_suc	CHAR(4),
			num_tarjeta		CHAR(20),
			cancelad		CHAR(1)) with no log;

		--Se almacena en la Tabla Temporal todos los movimientos de las transacciones correspondientes

		INSERT INTO tabtemp_cheques_sbc  			
				SELECT b.num_cte, a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal,
						a.num_cheq, a.transacc_suc, c.num_tarjeta, a.cancelad
				FROM bdicheq:"informix".sc_movhis a
					Inner Join bdicheq:"informix".sc_maechq b on a.cuenta = b.cuenta
					Left Join bdicheq:"informix".sc_tarjeta c on a.cuenta = c.cuenta and b.num_cte = c.numcte AND c.status_tar = 'A' and c.expiracion > today
				WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
					AND a.empresa = '001'
					AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0003') --Cheques SBC
					AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
					AND a.cancelad <> 'S';

		INSERT INTO tabtemp_cheques_sbc  		
				SELECT b.num_cte, a.folio_suc, a.fech_alt, a.cuenta, a.monto_tot, a.fech_hor, a.usuario, a.transacc, a.sdo_cuenta, a.sucursal,
						a.num_cheq, a.transacc_suc, c.num_tarjeta, a.cancelad
				FROM bdicheq:"informix".sc_movhis_old a
					Inner Join bdicheq:"informix".sc_maechq b on a.cuenta = b.cuenta
					Left Join bdicheq:"informix".sc_tarjeta c on a.cuenta = c.cuenta and b.num_cte = c.numcte AND c.status_tar = 'A' and c.expiracion > today
				WHERE a.fech_alt BETWEEN pFechaIni AND pFechaFin
					AND a.empresa = '001'
					AND a.transacc IN (SELECT transaccion FROM bdinteg:"informix".si_transacciones_auditar_det WHERE codigo = '0003') --Cheques SBC
					AND a.sucursal IN (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S')
					AND a.cancelad <> 'S';

		BEGIN WORK;
		FOREACH WITH HOLD

			SELECT Distinct
				num_cte, folio_suc, fech_alt, cuenta, monto_tot, fech_hor, usuario, transacc, sdo_cuenta, sucursal,
				cc.bco_receptor, cc.num_cuenta, num_cheq, transacc_suc, num_tarjeta, cancelad
			INTO vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vUsuario, vTransacc, vSaldo, vSucursal,
				vBanco, vCuentachq, vNumchq,  vTransacc_suc, vNumtarjeta, vReversado
			FROM tabtemp_cheques_sbc tt
				INNER JOIN bditef:"informix".cce_detalle cc on cc.cuenta_dep = tt.cuenta AND cc.num_cheque = tt.num_cheq
					AND cc.importe = tt.monto_tot

			LET vNumtarjeta = TRIM(vNumtarjeta);		
					
			
			INSERT INTO bdinteg:"informix".si_rptcaja_aud (empresa, cod_transacc, fecha_insert, cliente, folio, fecha, cuenta, monto, hora, usuario, transaccion, saldo, sucursal, banco, cuenta_banco, cheque, transacc_suc, tarjeta, reversado)
				VALUES ('001',vTransacc, today, vCliente, vFolio, vFecha, vCuenta, vMonto, vHora, vUsuario, vTransacc, vSaldo, vSucursal, vBanco, vCuentachq, vNumchq, vTransacc_suc,vNumtarjeta, vReversado);
			
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
			COMMIT WORK;
			LET iContador = 0;
			BEGIN WORK;
			END IF; 
			
		END FOREACH;
		COMMIT WORK;
		DROP TABLE IF EXISTS tabtemp_cheques_sbc; 
		 
		INSERT INTO bdinteg:"informix".si_param_extr (empresa, fecha_ant, ruta_unl, id_tabla, usuario_upd, fecha_upd)
		VALUES('001', pFechaFin, 'info_transacciones', 'cheques_sbc', user, today);

		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
		LET vProcesosEjecutados = vProcesosEjecutados + 1;
	ELSE
		LET vSaltaTransaccion = NULL;
	END IF;
  
	--INSERT INTO bdinteg:"informix".tiempo   
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Elimiar historico' AS NOMBRE from sysmaster:sysshmvals;
	
	--ValidaciÃ³n de Procesos Ejecutados:
	IF vProcesosEjecutados = 11 THEN
		LET v_codret    = '00000';
		LET v_msj_ret   = 'Proceso Finalizado Correctamente';
	ELIF vProcesosEjecutados = 0 THEN
		LET v_codret    = '00002';
		LET v_msj_ret   = 'Descarga de informaciÃ³n previamente ejecutada';
	ELSE
		LET v_codret    = '00003';
		LET v_msj_ret   = 'Proceso Ejecutado Parcialmente: ' || nvl(vProcesosEjecutados,'') || ' procesos ejecutados';
	END IF;
	-------> DepuraciÃ³n de InformaciÃ³n con antigÃ¼edad mayor a 6 meses <-------
		IF iMesActual > 1 and iMesActual < 7 then
			Let iAnio = iAnio - 1;
		End IF;
	IF (iMes > 5 ) THEN
			LET iMes_borrado = iMes - 5;
			LET dFecha_borrado = DATE('0' || iMes_borrado  || '/01/' || iAnio) - DAY (1);
				DELETE {+INDEX (bdinteg:"informix".informix.idx2_si_rptcaja_aud)} FROM bdinteg:"informix".si_rptcaja_aud WHERE fecha <= dFecha_borrado;  --Victor Mendoza 09/10/15
		ELSE
			LET iMes_borrado =  iMes + 12 - 5;
			IF (iMes_borrado < 10 ) THEN
				LET dFecha_borrado = DATE('0' || iMes_borrado || '/01/' || iAnio) - DAY(1);
			ELSE
				LET dFecha_borrado = DATE(iMes_borrado || '/01/' || iAnio) - DAY (1);
			END IF;

			DELETE {+INDEX (bdinteg:"informix".informix.idx2_si_rptcaja_aud)} FROM bdinteg:"informix".si_rptcaja_aud WHERE fecha <= dFecha_borrado;  --Victor Mendoza 09/10/15
		END IF;
      	 
	--INSERT INTO bdinteg:"informix".tiempo   
	--SELECT DBINFO("utc_to_datetime", sh_curtime) AS TIEMPO, 'Elimiar historico' AS NOMBRE from sysmaster:sysshmvals;

		RETURN v_codret, v_msj_ret;
END
END PROCEDURE;