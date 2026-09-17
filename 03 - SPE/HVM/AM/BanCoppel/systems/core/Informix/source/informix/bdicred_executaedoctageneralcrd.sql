CREATE PROCEDURE "informix".executaedoctageneralcrd(pempresa CHAR(3),pfechahoy DATE)
--EXECUTE PROCEDURE executaedoctageneralcrd('001',MDY('09','17','2021'));
RETURNING CHAR(5);

--     VARIABLES CONTROL DE ERRORES     --
DEFINE sql_err          INTEGER;
DEFINE v_cod_ret	    CHAR(5);
DEFINE v_corta_retorno  INTEGER;
--	VARIABLES GENERALES
DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);
DEFINE v_id_registro    CHAR(5);
DEFINE v_descripcion 	CHAR(50);
DEFINE v_periodo_anterior  DATE;		 --Fecha Periodo Anterior
DEFINE v_dias_periodo_tc   INTEGER;		 --dias_periodo_tc
DEFINE v_texto		       CHAR(1000);
DEFINE v_clave             INTEGER;
DEFINE v_secuencia         INTEGER;
DEFINE v_mensajes		   VARCHAR(255);
DEFINE v_producto          CHAR(4);
DEFINE GLOBAL v_linea_auxiliar	      DECIMAL(14,2) DEFAULT 0;
DEFINE GLOBAL v_corta_linea_mensaje   INTEGER  DEFAULT 0;
--     INICIALIZACION VARIABLES     --
LET sql_err         = "";
LET v_cod_ret	    = "000";
LET v_corta_retorno 		= 0;
LET v_empresa       = "";
LET v_num_credito   = "";
LET v_id_registro   = "";
LET v_descripcion 	= "";
LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc
LET v_texto                 = "";
LET v_linea_auxiliar        =999999.00;
LET v_mensajes				= "";
LET v_producto              = "";
LET v_corta_linea_mensaje 	= 100;
LET v_clave                 = '';
LET v_secuencia             = 1;
--SET DEBUG FILE TO "/pisa/leo/executaedoctageneralcrd.out";
--TRACE ON;

BEGIN

  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;
            RETURN v_cod_ret;
        END IF
   END EXCEPTION;

	  
	SELECT num_producto INTO v_producto 
	  FROM bdicred:sd_definicion 
	 WHERE empresa = pempresa AND cod_tipcred = '03' 
	 AND nombre_prod = 'REESTRUCTURA DE TARJETA DE CREDITO';  
	  
	--	PREPARA LA TABLA  PARA EDOCTAS

	TRUNCATE "informix".sd_movhisedoctacrd;

	EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy))
	              INTO v_cod_ret,v_periodo_anterior,v_dias_periodo_tc;

	LET v_periodo_anterior = v_periodo_anterior + 1 UNITS DAY;

	EXECUTE PROCEDURE carga_movhis_edoctacrd (pfechahoy,TRIM(v_producto)) INTO v_cod_ret;

   IF v_cod_ret <> "000" THEN
         RETURN v_cod_ret;
   END IF;

	SET ISOLATION TO DIRTY READ;

    --  SE GENERAN LOS INSERTOS FIJOS PARA CUENTAS CON 1 PAGO VENCIDOS
	/* --Se inactivan insertos derivado de que aun no hay solicitud para enviarlos --fmj Dic,2012
	EXECUTE PROCEDURE sp_activa_insertos_fijoscrd
					(
					pempresa,
					pfechahoy
					) INTO v_cod_ret;

   IF v_cod_ret<> "00000" THEN
         RETURN v_cod_ret;
   END IF;
	*/
	--	GENERACION ENCABEZADO EDO CUENTA

  	LET v_id_registro = "61100";
 	IF NOT EXISTS(SELECT num_credito
                    FROM "informix".sd_encabezado_edoctacrd
  		           WHERE fecha_emision = pfechahoy
  		             AND num_credito = v_id_registro) THEN

	   INSERT INTO "informix".sd_encabezado_edoctacrd
				(
	            fecha_emision,        num_credito,          num_cta_efec,
                num_producto,         numcte,            	nombre_cte,
                direccion_cn,      	  direccion_col,        direccion_del,
                edo_cd,           	  cl_cobra,        		sucursal_numero,
				sucursal_nombre,      sucursal_gerente,     rfc,
                sucursal_tel,         cp,                   ruta,
                entre_calles,         observaciones,        insertos,
				confirmacion,		  num_region,			num_ciudad_banco,
				num_ciudad_coppel,	  ec_edocta
				)
	  		VALUES
	            (
				 pfechahoy,			v_id_registro,          "0",
            TRIM(v_producto),       "0",                    "0",
	             "0",               "0",				    "0",
	 			 "0",   			"0",				    "0",
		 		 "0",			    "0",                    "0",
	 			 "0",				"0",                    "0",
	 			 "0",               "0",                    "0",
				 "0",				"0",					"0",
				 "0",				"0"
				);
 	 END IF;
	--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA

	LET v_id_registro = "61200";
  	IF NOT EXISTS(SELECT num_credito
                    FROM "informix".sd_encabezado2_edoctacrd
  		           WHERE fecha_emision = pfechahoy
  		             AND num_credito = v_id_registro) THEN

		INSERT INTO "informix".sd_encabezado2_edoctacrd
                (
                fecha_emision,            num_credito,            capital_tc,
                interes_tc,               iva_interes_tc,         numero_pago_tc,
                monto_pago,               capital_ven_tc,         interes_ven_tc,
                iva_interes_ven_tc,       moratorios_tc,          iva_moratorios_tc,
                pago_total_tc,            fecha_limite_tc,        periodo_tc_ini,
                periodo_tc_fin,           fecha_corte_tc,         dias_periodo_tc,
                monto_credito_tc,         fecha_otorgamiento_tc,  intereses_efec_pag,
                comisiones_efec_cargadas, descuento,			  subtotal,				total 
                )
		VALUES (
                pfechahoy,			v_id_registro,			0,
                0,                  0,                      "0",
                0,                  0,                      0,
                0,                  0,                      0,
                0,                  pfechahoy,			    pfechahoy + 1,
   				pfechahoy,          pfechahoy,			    "0",
 			    0,                  pfechahoy,               0,
                0,					0,						 0,					0 
                );
	END IF;

	--	VARIABLES GENERACION DETALLE EDO CUENTA

	LET v_id_registro = "61300";
	IF NOT EXISTS(SELECT num_credito FROM "informix".sd_detalle_edoctacrd
		           WHERE fecha_emision = pfechahoy
		             AND num_credito = v_id_registro) THEN


		INSERT INTO sd_detalle_edoctacrd
			(
			fecha_emision, 		num_credito, 			secuencia,
            nlinea, 			fecha_mov, 			     concepto,
            cargos, 			abonos
			)
		VALUES
         	(
         	pfechahoy,			v_id_registro,			"0",
         	"0", 				"0", 					"0",
			"0", 				"0"
         	);
	    END IF;

	--	VARIABLES GENERACION ACLARACIONES EDO CUENTA

	LET v_id_registro = "61400";
	IF NOT EXISTS(SELECT num_credito FROM "informix".sd_aclaraciones_edoctacrd
		           WHERE fecha_emision = pfechahoy
		             AND num_credito = v_id_registro) THEN

		INSERT INTO "informix".sd_aclaraciones_edoctacrd
			(
            fecha_emision,     num_credito,      secuencia,
            nlinea,            fecha_aclara,     folio_suc,
            fecha_mov,         descripcion,      importe
            )
		VALUES
         	(
         	pfechahoy,		   v_id_registro,		0,
         	0,			       pfechahoy, 		  "0",
         	pfechahoy,         "0",                 0
         	);
	END IF;

	--	VARIABLES GENERACION MENSAJES EDO CUENTA

	LET v_id_registro = "61500";

	IF NOT EXISTS(SELECT num_credito FROM "informix".sd_mensajes_edoctacrd
		           WHERE fecha_emision = pfechahoy
		             AND num_credito = v_id_registro) THEN

		INSERT INTO "informix".sd_mensajes_edoctacrd
			(
			fecha_emision, 			num_credito,		secuencia,
  			nlinea,					si_paga, 			mensajes
			)
		VALUES
         	(
         	pfechahoy,				v_id_registro,		0,
         	0,					    0,				    "0"
         	);
	END IF

	--	VARIABLES GENERACION PIE EDO CUENTA

  	LET v_id_registro = "61600";
	IF NOT EXISTS(SELECT num_credito FROM "informix".sd_pie_edoctacrd
	  	           WHERE fecha_emision = pfechahoy
	  	             AND num_credito = v_id_registro) THEN

		INSERT INTO "informix".sd_pie_edoctacrd
			(
            fecha_emision,      num_credito,        tasa_anual,
            tasa_mensual,     	tasa_mora_anual,  	tasa_mora_mensual,
            cat,              	saldo_insoluto
			)
		VALUES  (
			pfechahoy, 			v_id_registro, 		0,
			0, 				    0,                  0,
			0,                  0
			);
	  END IF;

    -----MENSAJES DEL ESTADO DE CUENTA

	CREATE TEMP TABLE mensajes(
				clave      serial,
                secuencia  integer,
                mensaje    char(101));

        LET v_clave = 1;


		FOREACH
            SELECT REPLACE(mensajes,'{0}',TRIM(v_linea_auxiliar::VARCHAR(21)))INTO v_texto
		              FROM "informix".sd_config_mensaje_edocta
		             WHERE clave BETWEEN 100 AND 199 AND num_producto = v_producto
		          ORDER BY clave

				  LET v_secuencia = 1;

				  FOREACH
                     EXECUTE PROCEDURE corta_linea(TRIM(v_texto),v_corta_linea_mensaje)
                                  INTO v_mensajes, v_corta_retorno
                     INSERT INTO mensajes VALUES (v_clave,v_secuencia,v_mensajes);
					 LET v_secuencia = v_secuencia+1;
                END FOREACH;
                LET v_clave = v_clave + 1;
		END FOREACH;

        DELETE bdicred:sd_mensajes_mensual_edoctacrd WHERE fecha_emision = pfechahoy and num_producto = v_producto;
        INSERT INTO bdicred:sd_mensajes_mensual_edoctacrd
        SELECT pfechahoy,v_producto,clave, secuencia, mensaje FROM mensajes where (clave||secuencia not in (11,23,62));
        DELETE FROM mensajes WHERE (clave||secuencia not in (11,23,62));

	--	GENERA UNO A UNO LOS ESTADOS DE CUENTA

 FOREACH
           SELECT a.empresa,a.num_credito
 			 INTO v_empresa,v_num_credito
 			 FROM "informix".sd_maesdoshistcrd a,
                  "informix".sd_maecredanexocrd b,
                  "informix".sd_maecredcrd c
        	WHERE fecha = pfechahoy
        	  AND a.empresa = pempresa
              AND a.empresa = b.empresa
              AND a.empresa = c.empresa
              AND a.num_credito = b.num_credito
              AND a.num_credito = c.num_credito
        	  AND a.num_credito NOT IN (SELECT num_credito
									  	  FROM "informix".sd_encabezado_edoctacrd
										 WHERE fecha_emision = pfechahoy)			  
              AND c.num_producto = v_producto
              AND dia_corte = day(pfechahoy)
			  AND c.campo_trab3 =''


		EXECUTE PROCEDURE generaedosctacrd
						(
						v_empresa,
                        v_num_credito,
                        pfechahoy
                        ) INTO v_cod_ret;

		 IF v_cod_ret <> "000" THEN

      		SELECT descripcion INTO v_descripcion
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

    DELETE FROM bdicred:sd_mensajes_edoctacrd WHERE fecha_emision = pfechahoy and num_credito <> "61500" and (secuencia||nlinea not in (11,23,62));
    DROP TABLE mensajes;
END;

	RETURN "000";

END PROCEDURE
DOCUMENT
"Se crea procedimiento para obtener",
"la informacion para la generacion de los",
"estados de cuenta para creditos reestructurados",
"base de datos : bdicred",
"AUTOR : Bernardo Baez",
"FECHA : 23/Julio/2009";

CREATE PROCEDURE "informix".libera_retenido(eEmpresa    CHAR(3),
				 eNumCredito CHAR(20),
				 eRetenido   DECIMAL(14,2))
RETURNING CHAR(5),       -- Codigo de Retorno
	  DECIMAL(14,2); -- Monto Retenido 
   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE GLOBAL FechaHoy     DATE DEFAULT NULL;

   DEFINE CodRet        CHAR(5);
   DEFINE sql_err       SMALLINT;
   DEFINE vFOlio	CHAR(16);
   DEFINE vFecha	DATE;
   DEFINE vDiasRet	SMALLINT;
   DEFINE vMonto	DECIMAL(14,2);
   DEFINE vMontoLib     DECIMAL(14,2);
   DEFINE vDIas		SMALLINT;
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   ON EXCEPTION SET sql_err
      LET CodRet = sql_err;
      RETURN CodRet, vMontoLib;
   END EXCEPTION

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
   LET CodRet    = '000';
   LET vFolio    = "??????";
   LET vFecha    = " ";
   LET vDiasRet  = 0;
   LET vMonto    = 0;
   LET vMontoLib = 0;
   LET vDias     = 0;

 -- **************************************************************************
 -- *                      PROGRAMA PRINCIPAL                                *
 -- **************************************************************************

    set isolation to dirty read;

	FOREACH SELECT folio_suc, fecha, dias_ret, monto
		  INTO vFolio, vFecha, vDiasRet, vMonto
		  FROM sd_maeretenido
		 WHERE empresa = eEmpresa
		   AND num_credito = eNumCredito
		   AND estatus = "P"
           AND dias_ret <= (FechaHoy - fecha) 
		
--		LET vDias = FechaHoy - vFecha;
		
--		IF vDiasRet <= vDias THEN	
            LET vMontoLib = vMontoLib + vMonto;
            UPDATE sd_maeretenido
               SET estatus = "S"
             WHERE empresa = eEmpresa
               AND num_credito = eNumCredito
               AND folio_suc = vFolio
               AND fecha = vFecha;
--		END IF


	END FOREACH

--- JOM RQI 27 210 20190520 {
--- Ajusta monto de retenidos JOM INI

-- Retenidos por compras

    SELECT sum(monto)
      INTO vMonto
      FROM sd_maeretenido
     WHERE empresa = eEmpresa
       AND num_credito = eNumCredito 
       AND estatus in ('P','R') and monto >0;

    IF (vMonto is null) then
        LET vMonto = 0;
    END IF;
    
    LET vMontoLib = vMonto;

-- Retenidos por credisoluciones


--- Ajusta monto de retenidos JOM FIN

--	LET vMontoLib = eRetenido - vMontoLib;
-- } 20190520 JOM RQI 27 210

	IF vMontoLib < 0 THEN
		LET vMontoLib = 0;
	END IF

	RETURN CodRet, vMontoLib;

END PROCEDURE
DOCUMENT
'****************************************************************************************************************',
'Procedimiento para la liberaciÃÂ³n de saldo retenido',
'BD: BDICRED',
'****************************************************************************************************************',
'MODIFICACIÃÂN',
'Fecha: 20/05/2019',
'ModificÃÂ³: Juan Olivares MartÃÂ­nez',
'InstalÃÂ³: Jorge Humberto Quintana Santiesteban',
'RQ: RQI 27 210 Actualizar el Saldo Retenido de forma diaria cuando no cuadran las cifras en tablas de Saldos.',
'DescripciÃÂ³n: Ajuste de monto de retenidos',
'CC: 32746 28/05/2019',
'****************************************************************************************************************';

CREATE PROCEDURE "informix".sp_conscredamortiza(pEmpresa CHAR(3), pNumCte CHAR(20), pNumCred CHAR(20))
RETURNING CHAR(5) AS CodRet,
	CHAR(20) AS NumCredito,
	CHAR(20) AS NumCliente,
	CHAR(150) AS NombreCte,
	CHAR(4) AS NumProducto,
	CHAR(40) AS NombreProd,
	DECIMAL(18,2) AS SaldoActual,
	INTEGER AS Plazo;

DEFINE cCodRet CHAR(5);
DEFINE cCodRetorno CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE cMensajeRet CHAR(80);
DEFINE cNumCredito CHAR(20);
DEFINE cNumCliente CHAR(20);
DEFINE cNombreProd CHAR(40);
DEFINE cNumTarjeta CHAR(20);
DEFINE cNombreCte CHAR(150);
DEFINE cNumProducto CHAR(4);
DEFINE dSaldoActual DECIMAL(18,2);
DEFINE cCodigoTipCred CHAR(2);
DEFINE dtFechaOrigen DATE;
DEFINE dtFechaProxPago DATE;
DEFINE dPagoMinimo DECIMAL(18,2);
DEFINE dtFechaUltPago DATE;
DEFINE iPlazo INTEGER;
DEFINE iPagosRealizados INTEGER;
DEFINE dLineaOtorgada DECIMAL(18,2);
DEFINE dTasaInteres DECIMAL(9,6);
DEFINE dTasaMoratorios DECIMAL(9,6);
DEFINE dMontoSbc DECIMAL(14,2);
DEFINE dCapVig DECIMAL(18,2);
DEFINE dCapTrans DECIMAL(18,2);
DEFINE dCapVdoExig DECIMAL(18,2);
DEFINE dCapVdoNoExig DECIMAL(18,2);
DEFINE dSdoActTotalCap DECIMAL(18,2);
DEFINE dIntVig DECIMAL(18,2);
DEFINE dIntVdo DECIMAL(18,2);
DEFINE dIntMoratorios DECIMAL(18,2);
DEFINE dIntMes DECIMAL(18,2);
DEFINE dSdoActTotalInt DECIMAL(18,2);
DEFINE dIvaIntVig DECIMAL(18,2);
DEFINE dIvaIntVdo DECIMAL(18,2);
DEFINE dIvaIntMoratorios DECIMAL(18,2);
DEFINE dIvaIntMes DECIMAL(18,2);
DEFINE dSdoActTotalIva DECIMAL(18,2);
DEFINE dComPend DECIMAL(18,2);
DEFINE dIvaCom DECIMAL(18,2);
DEFINE dSdoRetenido DECIMAL(18,2);
DEFINE dTotalLiquidacion DECIMAL(18,2);
DEFINE dIntDevengado DECIMAL(18,2);
DEFINE dIvaIntDevengado DECIMAL(18,2);
DEFINE dLineaDisponible DECIMAL(18,2);
DEFINE dPagosVdos DECIMAL(18,2);
DEFINE dDescStatusCred CHAR(60);
DEFINE iIdBloqueoCred INTEGER;
DEFINE cBloqueoCta CHAR(60);
DEFINE cIdCausaBloqueoCred CHAR(3);
DEFINE cCausaBloqueoCta CHAR(50);
DEFINE cIdSitEspCte CHAR(1);
DEFINE iIdCausaEspCte INTEGER;
DEFINE cSitEspCte CHAR(75);
DEFINE cIdSitEspCred CHAR(1);
DEFINE iIdCausaEspCred INTEGER;
DEFINE cSitEspCred CHAR(75);
DEFINE vNumProducto INTEGER;

LET cCodRet = '000';
LET cCodRetorno = '';
LET iSqlErr = 0;
LET cMensajeRet = '';
LET cNumCredito = '';
LET cNumCliente = '';
LET cNombreProd = '';
LET cNumTarjeta = '';
LET cNombreCte = '';
LET cNumProducto = '';
LET dSaldoActual = '';
LET cCodigoTipCred = '';
LET dtFechaOrigen = '';
LET dtFechaProxPago = '';
LET dPagoMinimo = 0;
LET dtFechaUltPago = '';
LET iPlazo = 0;
LET iPagosRealizados = 0;
LET dLineaOtorgada = 0;
LET dTasaInteres = 0;
LET dTasaMoratorios = 0;
LET dMontoSbc = 0;
LET dCapVig = 0;
LET dCapTrans = 0;
LET dCapVdoExig = 0;
LET dCapVdoNoExig = 0;
LET dSdoActTotalCap = 0;
LET dIntVig = 0;
LET dIntVdo = 0;
LET dIntMoratorios = 0;
LET dIntMes = 0;
LET dSdoActTotalInt = 0;
LET dIvaIntVig = 0;
LET dIvaIntVdo = 0;
LET dIvaIntMoratorios = 0;
LET dIvaIntMes = 0;
LET dSdoActTotalIva = 0;
LET dComPend = 0;
LET dIvaCom = 0;
LET dSdoRetenido = 0;
LET dTotalLiquidacion = 0;
LET dIntDevengado = 0;
LET dIvaIntDevengado = 0;
LET dLineaDisponible = 0;
LET dPagosVdos = 0;
LET dDescStatusCred = '';
LET iIdBloqueoCred = 0;
LET cBloqueoCta = '';
LET cIdCausaBloqueoCred = '';
LET cCausaBloqueoCta = '';
LET cIdSitEspCte = '';
LET iIdCausaEspCte = 0;
LET cSitEspCte = '';
LET cIdSitEspCred = '';
LET iIdCausaEspCred = 0;
LET cSitEspCred = '';
LET vNumProducto = 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN TRIM(cCodRet), TRIM(NVL(cNumCredito,'')), TRIM(NVL(cNumCliente,'')), TRIM(NVL(cNombreCte,'')), TRIM(NVL(cNumProducto,'')), TRIM(NVL(cNombreProd,'')), NVL(dSaldoActual,0), NVL(iPlazo,0);
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/sp_conscredamortiza.out';
	--TRACE ON;

	FOREACH
		EXECUTE PROCEDURE "informix".sp_consulta_datos_general(pEmpresa, pNumCte, pNumCred, '', '', '', '')
			INTO cCodRetorno, cMensajeRet, cNumCredito, cNumCliente, cNombreProd, cNumTarjeta, cNombreCte

		LET cNumCredito = TRIM(cNumCredito);

		IF NVL(cCodRetorno,'') = '000000' THEN

			SELECT num_producto INTO cNumProducto
			FROM "informix".sd_maecredcrd WHERE num_credito = cNumCredito;

			--IF NVL(cNumProducto,'')  <> '' THEN

			LET vNumProducto = (SELECT count(1) FROM "informix".sd_tipprod a, "informix".sd_definicion b WHERE a.empresa = b.empresa AND b.num_producto = cNumProducto
				AND a.abrevia_prod = b.num_producto AND a.cod_prod IN('P','R') AND b.tasa_fija_o_var = '1');

			--IF EXISTS(SELECT 1 FROM "informix".sd_tipprod a, "informix".sd_definicion b WHERE a.empresa = b.empresa AND b.num_producto = cNumProducto
				--AND a.abrevia_prod = b.num_producto AND a.cod_prod IN('P','R') AND b.tasa_fija_o_var = '1') THEN

			IF(vNumProducto > 0)THEN

				EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa, cNumCredito)
					INTO cCodRetorno, cMensajeRet, cNumCredito, cCodigoTipCred, dtFechaOrigen, dtFechaProxPago, dPagoMinimo, dtFechaUltPago, iPlazo, iPagosRealizados,
					dLineaOtorgada, dTasaInteres, dTasaMoratorios, dMontoSbc, dCapVig, dCapTrans, dCapVdoExig, dCapVdoNoExig, dSdoActTotalCap, dIntVig, dIntVdo,
					dIntMoratorios, dIntMes, dSdoActTotalInt, dIvaIntVig, dIvaIntVdo, dIvaIntMoratorios, dIvaIntMes, dSdoActTotalIva, dComPend, dIvaCom, dSdoRetenido,
					dTotalLiquidacion, dIntDevengado, dIvaIntDevengado, dLineaDisponible, dPagosVdos, dDescStatusCred, iIdBloqueoCred, cBloqueoCta, cIdCausaBloqueoCred,
					cCausaBloqueoCta, cIdSitEspCte, iIdCausaEspCte, cSitEspCte, cIdSitEspCred, iIdCausaEspCred, cSitEspCred;

				LET dSaldoActual = NVL(dCapVdoNoExig,0) + NVL(dSdoActTotalCap,0);
				LET cCodRet = '000000';

				RETURN TRIM(cCodRet), TRIM(NVL(cNumCredito,'')), TRIM(NVL(cNumCliente,'')), TRIM(NVL(cNombreCte,'')), TRIM(NVL(cNumProducto,'')), TRIM(NVL(cNombreProd,'')), NVL(dSaldoActual,0), NVL(iPlazo,0) WITH RESUME;
			/* ELSE
				LET cCodRet = '1031';
				RETURN TRIM(cCodRet), TRIM(NVL(cNumCredito,'')), TRIM(NVL(cNumCliente,'')), TRIM(NVL(cNombreCte,'')), TRIM(NVL(cNumProducto,'')), TRIM(NVL(cNombreProd,'')), NVL(dSaldoActual,0), NVL(iPlazo,0);*/
			END IF;
		   /* ELSE
				LET cCodRet = '000000';
				RETURN TRIM(cCodRet), TRIM(NVL(cNumCredito,'')), TRIM(NVL(cNumCliente,'')), TRIM(NVL(cNombreCte,'')), TRIM(NVL(cNumProducto,'')), TRIM(NVL(cNombreProd,'')), NVL(dSaldoActual,0), NVL(iPlazo,0);
			END IF;*/

		ELSE
			LET cCodRet = '1031';
			RETURN TRIM(cCodRet), TRIM(NVL(cNumCredito,'')), TRIM(NVL(cNumCliente,'')), TRIM(NVL(cNombreCte,'')), TRIM(NVL(cNumProducto,'')), TRIM(NVL(cNombreProd,'')), NVL(dSaldoActual,0), NVL(iPlazo,0);
		END IF;
	END FOREACH;

END
END PROCEDURE
DOCUMENT
'Base de datos: bdicred';

CREATE PROCEDURE "informix".sp_extrae_info_cuotas() 
	Returning char(7);

	/*DEFINICIÃ?N DE VARIABLES*/
	--Variables de retorno
	DEFINE vcodret				char(5);	
	DEFINE vsqlerr				integer;
	
	--Variable para ejecuciÃ³n de comandos
	DEFINE vsql	        		char(3000);
	
	--Variables de elementos requeridos
	
---INICializacion de variables
	
	let vcodret = "00000";
	let vsqlerr = 0;
	
	Let vsql='';


--SET DEBUG FILE TO "/RESPALDOSNEW/aclaraciones/sp_repaltaunicaidbox.out";
 --TRACE ON;
	--LET v_tiempo = CURRENT;
	begin	
		
		On exception set vsqlerr		
			if vsqlerr<>0 then
				let vcodret = vsqlerr;
				COMMIT WORK;
				return vcodret;
			end if;
		end exception;
		
		

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
      


	BEGIN WORK;
		--generacion de reporte 
	
		let vsql=  'echo "UNLOAD TO /bitacoras/cobranza/Temp_Delinquency.txt '||
		'SELECT customer_id,identity_code,acc_customer_id,product_id,account_number,age,delinquency,paid_delinquency,principal_delinquency, '||' '||
		'paid_principal_delinquency,interest_delinquent,paid_interest_delinquent,comission,paid_comission,insurance_deg,'||' '||
		'paid_insurance_deg,insurance_fire,paid_insurance_fire,other_reasons,paid_other_reasons,update_date,due_date,'||' '||
		'last_entrance_date,state_cause_id,quote_status,last_payment_date,reviewed,return_id,entrance_date,wite_off_date FROM ics_cuotas;">/bitacoras/cobranza/Temp_Delinquency.sql';
		system vsql;
		let vsql= 'dbaccess bdicred /bitacoras/cobranza/Temp_Delinquency.sql';
		system vsql;
		let vsql ='rm  /bitacoras/cobranza/Temp_Delinquency.sql';

		system vsql;
		
		
		let vcodret = '00000';					
	COMMIT WORK;		
	
		return vcodret;
		
	end;
end procedure
DOCUMENT
'Sp para generaciÃ³n de Reporte Mensual IDBox',
'AUTOR : Rey David Zavala Garcia.',
'Area: Bnaca Comercial',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Norberto Corona',
'FECHA : 21/Abril/2020',
'VERSION: 1.0.0',
'BD    :  bdinteg';

CREATE PROCEDURE "informix".sp_extrae_info_pagos() 
	Returning char(7);

	/*DEFINICIÃ?N DE VARIABLES*/
	--Variables de retorno
	DEFINE vcodret				char(5);	
	DEFINE vsqlerr				integer;
	
	--Variable para ejecuciÃ³n de comandos
	DEFINE vsql	        		char(3000);
	
	--Variables de elementos requeridos
---INICializacion de variables
	
	let vcodret = "00000";
	let vsqlerr = 0;

	Let vsql='';
	--LET v_sucursal_cliente = '';

--SET DEBUG FILE TO "/RESPALDOSNEW/aclaraciones/sp_repaltaunicaidbox.out";
 --TRACE ON;
	--LET v_tiempo = CURRENT;
	begin	
		
		On exception set vsqlerr		
			if vsqlerr<>0 then
				let vcodret = vsqlerr;
				COMMIT WORK;
				return vcodret;
			end if;
		end exception;
		
		

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
      


	BEGIN WORK;
		--generacion de reporte 
		
		let vsql=  'echo "UNLOAD TO /bitacoras/cobranza/Temp_Payment.txt '||
			'SELECT customer_id,identity_code,acc_customer_id,product_id,account_number,payment_date,payment_type,transaction_type,cust_branch_id,'||' '||
			'payment_amount,reviewed,support_entity,check_number,return_id,payment_location,age,rate,payment_money,session_id FROM ics_pagos;">/bitacoras/cobranza/Temp_Payment.sql';	
		system vsql;
		let vsql= 'dbaccess bdicred /bitacoras/cobranza/Temp_Payment.sql';
		system vsql;
		let vsql ='rm  /bitacoras/cobranza/Temp_Payment.sql';
		system vsql;
	
		
		let vcodret = '00000';					
	COMMIT WORK;		
	
		return vcodret;
		
	end;
end procedure
DOCUMENT
'Sp para generaciÃ³n de Reporte Mensual IDBox',
'AUTOR : Rey David Zavala Garcia.',
'Area: Bnaca Comercial',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Norberto Corona',
'FECHA : 21/Abril/2020',
'VERSION: 1.0.0',
'BD    :  bdinteg';

CREATE PROCEDURE "informix".sp_extrae_info_personas() 
	Returning char(7);

	/*DEFINICIÃ?N DE VARIABLES*/
	--Variables de retorno
	DEFINE vcodret				char(5);	
	DEFINE vsqlerr				integer;
	
	--Variable para ejecuciÃ³n de comandos
	DEFINE vsql	        		char(3000);
	

---INICializacion de variables
	
	let vcodret = "00000";
	let vsqlerr = 0;
	
	Let vsql='';


--SET DEBUG FILE TO "/RESPALDOSNEW/aclaraciones/sp_repaltaunicaidbox.out";
 --TRACE ON;
	--LET v_tiempo = CURRENT;
	begin	
		
		On exception set vsqlerr		
			if vsqlerr<>0 then
				let vcodret = vsqlerr;
				COMMIT WORK;
				return vcodret;
			end if;
		end exception;
		
		

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
      


	BEGIN WORK;
		--generacion de reporte 
		
		let vsql=  'echo "UNLOAD TO /bitacoras/cobranza/Temp_People.txt '||
			'SELECT customer_id,identity_code,seq,first_surname,first_name,sex,civil_status,address_type1,zone1,city1,use_this_1,address_type2,'||' '||
			'zone2,city2,use_this_2,telephone_type1,addr_tel_type1,telephone_type2,addr_tel_type2,income_payment_type,income_payment_day,'||' '||
			'reviewed,company,second_surname,midlle_name,birth_date,addres_number1,province1,country1,po_box1,strata1,addres_number2,'||' '||
			'province2,country2,po_box2,strata2,area_code1,telephone_number1,extention1,county_code1,area_code2,telephone_number2,'||' '||
			'extention2,county_code2,ocupation,profession,income,persons_in_charge,work_timetable_start,work_timetable_end,user_defined1,'||' '||
			'return_id,qualification,common_id,latitude1,longitude1,latitude2,longitude2 FROM ics_personas;">/bitacoras/cobranza/Temp_People.sql';
		system vsql;
		let vsql= 'dbaccess bdicred /bitacoras/cobranza/Temp_People.sql';
		system vsql;
		let vsql ='rm  /bitacoras/cobranza/Temp_People.sql';
		system vsql;
	
		let vcodret = '00000';					
	COMMIT WORK;		
	
		return vcodret;
		
	end;
end procedure
DOCUMENT
'Sp para generaciÃ³n de Reporte Mensual IDBox',
'AUTOR : Rey David Zavala Garcia.',
'Area: Bnaca Comercial',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Norberto Corona',
'FECHA : 21/Abril/2020',
'VERSION: 1.0.0',
'BD    :  bdinteg';

CREATE PROCEDURE "informix".sp_genera_ec_tdc_muestras()
--EXECUTE PROCEDURE sp_genera_ec_tdc_muestras();

RETURNING CHAR(5);

--DECLARACION
DEFINE vCodRet			CHAR(05);
DEFINE cMensaje    	 	CHAR(100); 
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr     	INTEGER;
DEFINE vMes				CHAR(02);
DEFINE vAnio			CHAR(04);
DEFINE vFecha			DATE;
DEFINE contador_ec  	INTEGER;
DEFINE numero_cre  		VARCHAR(20,1);
DEFINE fecha_emi  		DATE;
DEFINE centro_imp_var  	CHAR(06);
DEFINE centro_imptemp  	CHAR(06);
DEFINE centro_impanterior CHAR(06);
DEFINE numero_reg  		INTEGER;
DEFINE contador_aux 	CHAR(06);
DEFINE vCentroDis		INTEGER;

--INICIALIZACION
LET vCodRet        	= '00000';
LET cMensaje    	= 'Ejecucion Exitosa';
LET iSqlErr     	= 0;
LET iIsamErr    	= 0;
LET vMes			= '';
LET vAnio			= '';
LET vFecha			= date(1);
LET contador_ec  	= 0;
LET numero_cre 		= "";
LET fecha_emi 		= DATE(1);
LET centro_imp_var 	= "";	
LET centro_imptemp 	= "";
LET centro_impanterior 	= "";
LET numero_reg 		= 0;
LET contador_aux 	= '0';
LET vCentroDis		= 0;

--SET DEBUG FILE TO "/informix/ALEOUT/generacion_ec_tdc.out";
--TRACE ON; 

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
			LET vCodRet = iSqlErr;		
            LET cMensaje = 'Error en la ejecucion';
            RETURN vCodRet;
		END IF;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- Recupera la fecha
	SELECT LPAD(MONTH(fecha_hoy),2,0), YEAR(fecha_hoy)
	INTO vMes, vAnio
	FROM bdicred:sd_fechas
	WHERE empresa = '001';
	
	LET vFecha = MDY(vMes,20,vAnio);
	--LET vFecha = mdy('07','20','2021'); -- para pruebas
	
	SELECT centro FROM bdinteg:"informix".si_catzonas where centro is null
	into temp centros_distrib;
	
	FOREACH WITH HOLD
		SELECT centro INTO vCentroDis FROM centros_distrib
		
		IF vCentroDis is null THEN
		BEGIN;
			UPDATE bdinteg:"informix".si_catzonas SET centro = 999999 WHERE centro is null;
		COMMIT;
		END IF;
	END FOREACH;

	SELECT a.num_credito, a.fecha_emision, c.numerociudadcoppel, c.centro, c.jefegrupozona, c.supervisorzona, c.numerocoloniacoppel,
		   b.numerocalle, b.numeroextcalle, b.tipo_dir
	FROM bdicred:sd_encabezado_edocta a 
	INNER JOIN bdinteg:si_direcciones_actual b ON a.numcte = b.numcte AND b.tipo_dir = '1' 
	INNER JOIN bdinteg:si_catzonas c ON nvl(c.numerociudad,0) = nvl(b.numerociudad,0) AND nvl(c.numerocolonia,0) = nvl(b.numerocolonia,0)
	WHERE a.fecha_emision = vFecha AND a.num_credito NOT IN('000','100')
	and c.centro is not null
	INTO TEMP creditostdc_ec WITH NO LOG;

	INSERT INTO creditostdc_ec
	SELECT a.num_credito, a.fecha_emision, c.numerociudadcoppel, c.centro, c.jefegrupozona, c.supervisorzona, c.numerocoloniacoppel,
		   b.numerocalle, b.numeroextcalle, b.tipo_dir
	FROM bdicred:sd_encabezado_edocta a 
	LEFT OUTER JOIN bdinteg:si_direcciones_actual b ON a.numcte = b.numcte --AND b.tipo_dir = 1 
	LEFT OUTER JOIN bdinteg:si_catzonas c ON nvl(c.numerociudad,0) = nvl(b.numerociudad,0) AND nvl(c.numerocolonia,0) = nvl(b.numerocolonia,0)
	WHERE a.fecha_emision = vFecha AND a.num_credito NOT IN('000','100')
	and c.centro is not null
	AND a.num_credito NOT IN(select num_credito from creditostdc_ec);
	
	
	SELECT num_credito, fecha_emision, numerociudadcoppel, centro, jefegrupozona, supervisorzona, numerocoloniacoppel,
		   numerocalle, numeroextcalle, tipo_dir 
	FROM creditostdc_ec 
	group by centro, numerociudadcoppel,jefegrupozona, supervisorzona, numerocoloniacoppel,numerocalle, numeroextcalle, tipo_dir,fecha_emision,num_credito
	INTO TEMP tmpNumeroRegistros WITH NO LOG;
 

	FOREACH WITH HOLD 

		SELECT num_credito, fecha_emision, centro INTO numero_cre, fecha_emi, centro_imp_var FROM tmpNumeroRegistros
		ORDER BY centro::INTEGER, numerociudadcoppel, jefegrupozona, supervisorzona, numerocoloniacoppel, numerocalle, numeroextcalle
		
		IF centro_imp_var IS NULL THEN
			LET centro_imp_var = 999999;
		END IF;

		/*IF (contador_aux = 0) THEN

			LET centro_imptemp = centro_imp_var;

		END IF;*/
		
	BEGIN;

		IF (centro_impanterior = centro_imp_var) THEN

			/*IF( centro_impanterior <> centro_imp_var)THEN

				LET contador_ec = 0;

			END IF;*/

			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edocta
			SET ec_edocta = contador_ec
			WHERE num_credito = numero_cre
			AND fecha_emision = fecha_emi;

			LET contador_aux = contador_aux + 1;

		ELSE
		
			LET centro_impanterior = centro_imp_var;

			--LET contador_aux = 0;
			LET contador_ec = 0;
			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edocta
			SET ec_edocta = contador_ec
			WHERE num_credito = numero_cre
			AND fecha_emision = fecha_emi;

		END IF;
	COMMIT;
		
		--LET centro_impanterior = centro_imp_var;

	END FOREACH; 

	DROP TABLE IF EXISTS creditostdc_ec;
	DROP TABLE IF EXISTS tmpNumeroRegistros;
	
	BEGIN;
		UPDATE bdinteg:"informix".si_catzonas SET centro = NULL WHERE centro = 999999;
	COMMIT;
	
	END;

	RETURN vCodRet;

END PROCEDURE;