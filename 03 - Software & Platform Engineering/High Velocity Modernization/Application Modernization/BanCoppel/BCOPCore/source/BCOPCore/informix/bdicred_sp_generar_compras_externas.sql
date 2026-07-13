CREATE PROCEDURE "informix".sp_generar_compras_externas() 
	RETURNING	 CHAR(5); --Codigo Retorno
	
DEFINE cCodret				    CHAR(5);
DEFINE iSqlerr				    INTEGER;

DEFINE pNumCredito				CHAR(20);
DEFINE pProducto			    CHAR(4);
DEFINE pMontoPago               DECIMAL(16,2);
DEFINE pPeriodo  			    CHAR(20);
DEFINE pNumCte			    CHAR(20);
DEFINE pFechaCorteCompraInicio	DATE;
DEFINE pFechaCorteCompraFinal	DATE;
DEFINE pFechaCentral		    DATE;
DEFINE pFechaMov		    	DATE;
DEFINE pReferencia23			CHAR(40);
DEFINE cFechaMov		    	DATE;
DEFINE pEstatusCalculo			BOOLEAN;
DEFINE cNumCreditoCompras		CHAR(20);
DEFINE cPeriodoCompras			CHAR(20);
DEFINE cMontoCompras			DECIMAL(16,2);
DEFINE cOrigen					CHAR(40);
DEFINE cMoneda					CHAR(40);
DEFINE cReferencia23			CHAR(40);
DEFINE pNombreComercio			CHAR(80);
DEFINE eReferencia23			CHAR(40);
DEFINE eMontoRecibido           DECIMAL(16,2);

--INICIALIZANDO VARIABLES -------------
---------------------------------------
LET iSqlerr    			= 0;
LET cCodret    			= "00000";

LET pNumCredito    		= "";
LET pProducto			= "";
LET pNumCte 			= "";
LET pMontoPago          = "";
LET pPeriodo 			= "";
LET pFechaCentral       = "";
LET pFechaMov			= "";
LET cFechaMov			= "";
LET pReferencia23		= null;
LET pEstatusCalculo		= "f";
LET cNumCreditoCompras  = "";
LET cPeriodoCompras		= "";
LET cMontoCompras		= "";
LET cReferencia23		= "";
LET pNombreComercio		= "";
LET eReferencia23		= "";
LET eMontoRecibido		= "";


LET cOrigen				= "Reworth";LET cMoneda				= "mxn";
---------------------------------------
BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/Fausto/sp_compras_externas.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

---------------------------------------------------------------------------------------------
--Obtener fecha DE CENTRAL -----------------------
	--------------------------------------------------
	SELECT fecha_hoy
	INTO pFechaCentral
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';
		
	foreach
		----------------------------
		SELECT referencia23,transaction_amount
		INTO eReferencia23,eMontoRecibido
		FROM bdicred:"informix".sd_recibir_reworth
		WHERE status = 'confirmed'
		----------------------------
		
		SELECT first 1 a.num_credito,b.num_producto,b.numcte,a.fecha_mov, a.monto :: DECIMAL(16,2) as monto1,a.referencia23,c.nomcomercio325
		INTO   pNumCredito,pProducto,pNumCte,pFechaMov,pMontoPago,pReferencia23,pNombreComercio
		FROM bdicred:"informix".sd_movhis a
		INNER JOIN bdicred:"informix".sd_maecred b ON a.num_credito = b.num_credito
		INNER JOIN bditarjeta:"informix".td_movimientos_conciliacion c on a.nro_tarjeta = c.numtarjeta and a.referencia23 = c.referencia23_325
		where a.referencia23 = eReferencia23
		AND a.monto = eMontoRecibido;
		
		IF pNumCte IS NOT NULL AND pReferencia23 IS NOT NULL THEN 
			
			IF NVL(pNombreComercio,"")=""  OR pNombreComercio = "" THEN
				LET pNombreComercio= 'Desconocido';
			END IF;	
					
			SELECT num_credito, monto_diario, periodo, fecha, referencia23
			INTO cNumCreditoCompras, cMontoCompras, cPeriodoCompras, cFechaMov, cReferencia23
			FROM bdicred:"informix".sd_compras_externas
			WHERE num_credito = pNumCredito
			AND referencia23 = pReferencia23
			AND monto_diario = pMontoPago;
			
			IF cNumCreditoCompras = pNumCredito AND cMontoCompras = pMontoPago AND cReferencia23 = pReferencia23 AND cFechaMov = pFechaMov THEN
			
				CONTINUE FOREACH;
				
			ELSE
				If pMontoPago IS NOT NULL THEN
				
					LET pPeriodo = TO_CHAR(pFechaMov, "%m-%Y");
					
					INSERT INTO bdicred:"informix".sd_compras_externas(numcte, producto, num_credito, monto_diario, periodo, fecha, estatus_calculo, origen, moneda, referencia23,nombre_comercio)
					VALUES (pNumCte,pProducto,pNumCredito,pMontoPago,pPeriodo,pFechaMov, pEstatusCalculo, cOrigen, cMoneda, pReferencia23,pNombreComercio);
				END IF;
			END IF;
		END IF;
		
	END FOREACH;	
		
	RETURN cCodret;
END;
---------------------------------------------------------------------------------------------
END procedure
DOCUMENT
'Se crea SP para Recibir Compras',
'AUTOR : FAUSTO VALENZUELA 99805228',
'FECHA : 17/08/2022',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_generar_aclaraciones_pl() 
	RETURNING	 CHAR(5); --Codigo Retorno
	
DEFINE cCodret					CHAR(5);			 
DEFINE iSqlerr					INTEGER;
DEFINE iExiste					INTEGER;

DEFINE vMoneda					CHAR(40);
DEFINE dEstatus					BOOLEAN;
DEFINE vProducto				CHAR(4);
DEFINE dNumCte					CHAR(40); 
DEFINE vPeriodo					CHAR(40);
DEFINE dFechaTransaccion		DATE;
DEFINE dFolioMov				CHAR(40);
DEFINE cObservaciones			CHAR(40);
DEFINE cReferencia23			CHAR(40);
DEFINE cNumCreditoDevolucion	CHAR(40);
DEFINE cImporteReclamado		DECIMAL(18,2);
DEFINE cFechaAclaracion			DATE;
DEFINE pFechaCentral			DATE;
DEFINE mBeneficioCalculado		DECIMAL(18,2);
DEFINE mSaldoTotal				DECIMAL(18,2);
DEFINE vNumCredito				CHAR(40);
DEFINE vNumCte					CHAR(40);
DEFINE vOrigen					CHAR(40);
DEFINE vMonto					DECIMAL(18,2);
DEFINE vReferencia23			CHAR(40);
DEFINE pNumCredito				CHAR(40);
DEFINE pNumCte					CHAR(40);
DEFINE pProducto				CHAR(4);
DEFINE pMonto					DECIMAL(18,2);
DEFINE pReferencia23			CHAR(40);
DEFINE pFecha					DATE;
DEFINE cId						int;
DEFINE vNombreComercio			CHAR(80);
DEFINE aNumCredito				CHAR(40);
DEFINE aNumCte					CHAR(40);
DEFINE aProducto				CHAR(40);
DEFINE aMonto					DECIMAL(18,2);
DEFINE aReferencia23			CHAR(40);
DEFINE aOrigen					CHAR(40);
DEFINE pOrigen					CHAR(40);
DEFINE aObservaciones			CHAR(40);

---------------------------------------
LET cCodret    				= "00001";
LET iSqlerr    				= 0;
LET iExiste	   				= 0;

LET vOrigen					= "";
LET vMoneda					= "mxn";
LET dEstatus				= "f";
LET vProducto				= "";
LET dNumCte					= "";
LET vPeriodo				= "";
LET dFechaTransaccion		= "";
LET dFolioMov				= "";
LET cReferencia23			= "";

LET cObservaciones			= "";
LET cNumCreditoDevolucion	= "";
LET cImporteReclamado		= "";
LET cFechaAclaracion		= "";
LET pFechaCentral			= "";
LET mBeneficioCalculado		= "";
LET mSaldoTotal				= "";

LET vReferencia23			= "";
LET vNumCredito 			= "";
LET vNumCte					= "";
LET vMonto					= "";
LET vNombreComercio			= "";

LET pNumCredito				= "";
LET pNumCte					= "";
LET pProducto				= "";
LET pMonto					= "";
LET pReferencia23			= "";
LET pFecha					= "";
LET cId						= "";
LET aNumCredito				= ""; 
LET aNumCte					= "";
LET aProducto				= "";
LET aMonto					= "";
LET aReferencia23			= "";
LET aOrigen					= "";
LET pOrigen					= "";
LET aObservaciones			= "";


BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/Fausto/sp_aclaraciones.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

----------------------------------------------------------------------LLenado de tabla devoluciones---------------------------------------------------------------------------------------------
	--Obtener fecha DE CENTRAL -----------------------
	--------------------------------------------------
	SELECT fecha_hoy,  TO_CHAR( fecha_hoy, '%m-%Y' )
	INTO pFechaCentral,vPeriodo
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = '001';
	
		
	FOREACH

			SELECT fecha_cargo, referencia23, importe_reclamado, observaciones, id
				INTO cFechaAclaracion, cReferencia23, cImporteReclamado, cObservaciones, cId
				FROM bdicred:"informix".sd_aclaraciones_pl
				where estatus = "f"
			union all 
			select fecha, referencia23, monto,
				case 
					when naturaleza = "A" or naturaleza = "a" then "ABONAR"
					when naturaleza = "C" or naturaleza = "c" then "QUITAR"
				end as observaciones,
				id
				from bdicred:"informix".sd_aclaraciones_soc
				where estatus ="f"
			
			
			
			IF cReferencia23 IS NOT NULL AND cObservaciones IS NOT NULL AND cFechaAclaracion IS NOT NULL THEN 
			
				SELECT num_credito,numcte,producto, monto_diario,referencia23,nombre_comercio
				INTO vNumCredito,vNumCte,vProducto,vMonto,vReferencia23,vNombreComercio
				FROM bdicred: "informix".sd_compras_plan_lealtad
				where referencia23 = cReferencia23
				AND origen NOT IN ('Devolucion_Pl', 'Devolucion_Ex', 'Devolucion','Aclaraciones_Pl','Aclaraciones_Ex');
			---------------------------------------------------------------------------
				select first 1 referencia23,origen
				INTO aReferencia23,aOrigen
				FROM bdicred:"informix".sd_aclaraciones_soc 
				where estatus = "t"
				AND referencia23 = cReferencia23
				and monto = cImporteReclamado;
			---------------------------------------------------------------------------
				IF vReferencia23 is not null and vReferencia23 != '' THEN
					IF vNumCredito IS NOT NULL AND vNumCte IS NOT NULL AND vMonto IS NOT NULL AND vReferencia23 IS NOT NULL THEN
						
						IF cObservaciones = "QUITAR" THEN
							LET cImporteReclamado = cImporteReclamado * -1;
						END IF;	
					
						LET vOrigen	= 'Aclaraciones_Pl';
						
						SELECT first 1 a.num_credito,a.numcte,a.producto, a.monto_diario,a.referencia23,a.fecha,a.origen
						INTO pNumCredito,pNumCte,pProducto,pMonto,pReferencia23,pFecha,pOrigen
						FROM bdicred: "informix".sd_compras_plan_lealtad a
						where a.referencia23 = vReferencia23
						and a.origen = vOrigen;
					
						IF pNumCredito = vNumCredito AND pNumCte = vNumCte AND pReferencia23 = vReferencia23 AND pMonto = vMonto AND aOrigen = pOrigen THEN
							CONTINUE FOREACH;
						ELSE
							INSERT INTO bdicred:"informix".sd_compras_plan_lealtad(numcte, producto, num_credito, monto_diario, periodo, fecha, estatus_calculo, origen, moneda, referencia23, nombre_comercio)
							VALUES (vNumCte,vProducto,vNumCredito,cImporteReclamado,vPeriodo,pFechaCentral, "f", vOrigen, vMoneda, vReferencia23, vNombreComercio);
							
							update bdicred:"informix".sd_aclaraciones_pl set estatus = 't'
							where referencia23 = vReferencia23
							and id = cId;
							
							update bdicred:"informix".sd_aclaraciones_soc set estatus = 't'
							where referencia23 = vReferencia23
							and id = cId;
							
						END IF;
						
					ELSE
						CONTINUE FOREACH;
					END IF;
				
				ELSE
					
					LET vOrigen	= 'Reworth';
				
					SELECT first 1 a.num_credito,a.numcte,a.producto,a.monto_diario, a.referencia23, a.nombre_comercio
					INTO vNumCredito,vNumCte,vProducto,vMonto,vReferencia23,vNombreComercio
					FROM bdicred: "informix".sd_compras_externas a
					where a.referencia23 = cReferencia23
					and a.origen = vOrigen;
					
					IF vNumCredito IS NOT NULL AND vNumCte IS NOT NULL AND vMonto IS NOT NULL AND vReferencia23 IS NOT NULL THEN
					
						IF cObservaciones = "QUITAR" THEN
							LET cImporteReclamado = cImporteReclamado * -1;
						END IF;	
					
						LET vOrigen	= 'Aclaraciones_Ex';
						
						SELECT first 1 a.num_credito,a.numcte,a.producto, a.monto_diario,a.referencia23,a.fecha,a.origen
						INTO pNumCredito,pNumCte,pProducto,pMonto,pReferencia23,pFecha,pOrigen-------------------------------------------------------------
						FROM bdicred: "informix".sd_compras_plan_lealtad a
						where a.referencia23 = vReferencia23
						and a.origen = vOrigen;
					
						IF pNumCredito = vNumCredito AND pNumCte = vNumCte AND pReferencia23 = vReferencia23 AND pFecha = cFechaAclaracion AND pMonto = vMonto and pOrigen = aOrigen THEN
							CONTINUE FOREACH;
						ELSE
							INSERT INTO bdicred:"informix".sd_compras_plan_lealtad(numcte, producto, num_credito, monto_diario, periodo, fecha, estatus_calculo, origen, moneda, referencia23, nombre_comercio)
							VALUES (vNumCte,vProducto,vNumCredito,cImporteReclamado,vPeriodo,pFechaCentral, "f", vOrigen, vMoneda, vReferencia23, vNombreComercio);
							
							update bdicred:"informix".sd_aclaraciones_pl set estatus = 't'
							where referencia23 = vReferencia23
							and id = cId;
							
							update bdicred:"informix".sd_aclaraciones_soc set estatus = 't'
							where referencia23 = vReferencia23
							and id = cId;
							
						END IF;
						
					ELSE
						CONTINUE FOREACH;
					END IF;
				END IF;
			END IF;
		-----------------------------------------------------------------------------------------------------------------------------------------------------------
	END FOREACH;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

RETURN  cCodret;
END
END procedure
DOCUMENT
'Se crea SP para Aclaraciones de Plan de Lealtad',
'AUTOR : FAUSTO VALENZUELA 99805228',
'FECHA : 09/12/2022',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_liberasaldo_automatico()
RETURNING CHAR(5) AS CodRet,
CHAR(64) AS MensRet;

	DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr				INTEGER;
	DEFINE cErrorInfo			CHAR(200);
	DEFINE vCodRet				CHAR(5);
	DEFINE vMensajeRet			CHAR(64);
	DEFINE cRuta				CHAR(80);
	DEFINE vSql					CHAR(1024);
	DEFINE vSql2				CHAR(1024);
	DEFINE vArchivo				CHAR(200);
	DEFINE vCodRet2				CHAR(5);
	DEFINE vNomQuery			CHAR(50);
	DEFINE v_num_credito		CHAR(20);
	DEFINE v_existe				INTEGER;
	DEFINE i					INTEGER;
	DEFINE vTotalRegistros		INTEGER;
	DEFINE vfecha				CHAR(8);

	LET iSqlErr 				= 0;
	LET iIsamErr				= 0;
	LET cErrorInfo				= '';
	LET vCodRet 				= '00000';
	LET vMensajeRet				= 'Liberacion de saldos exitoso';
	LET cRuta 					='/resplogifx/archivoscredito/';
	LET vSql					='';
	LET vSql					='';
	LET vArchivo				="ventanaCreditoRetenido"; 
	LET vCodRet2				= '';
	LET vNomQuery				='cargaRetenido.sql';
	LET vTotalRegistros			= 0;
	LET vfecha					= '';
	
BEGIN

	/* EXCEPTION */
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr <> 0 THEN 
			LET vMensajeRet = 'Ocurrio un error en el proceso de liberar saldos automatico';
			RETURN iSqlErr,vMensajeRet; 
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/informix/ciaguilar/Saldo_Retenido/automatizacion_liberasaldo.out";
	--TRACE ON;
	
	SELECT lpad(day(fecha_hoy),2,0)||lpad(month(fecha_hoy),2,0)||year(fecha_hoy)
	INTO vfecha
	FROM bdicred:sd_fechas;
	  
	/*Paso de validaciones para el archivo */
	DROP TABLE IF EXISTS "informix".tmp_sdo_retenido;
	
	CREATE TABLE "informix".tmp_sdo_retenido 
	(
	 num_tarjeta	CHAR(20) NOT NULL,
	 num_credito	CHAR(20) NOT NULL,
	 monto      	DECIMAL(18,2) NOT NULL,
	 folio_suc  	CHAR(16) NOT NULL,
	 fecha_hora 	DATETIME YEAR to SECOND DEFAULT CURRENT YEAR to SECOND,
	 existe 		INTEGER DEFAULT 1,
	 observaciones	CHAR(40)
	);

	CREATE INDEX "informix".idx_tmp_sdoretenido01 on "informix".tmp_sdo_retenido(num_credito);
	CREATE INDEX "informix".idx_tmp_sdoretenido02 on "informix".tmp_sdo_retenido(existe);
	
	LET vSql = 'echo "load from '||TRIM(cRuta)||TRIM(vArchivo)||vfecha||'.unl'||' insert into "informix".tmp_sdo_retenido(num_tarjeta,num_credito,monto,folio_suc,fecha_hora);" > ' || TRIM(cRuta)|| TRIM(vNomQuery);
	SYSTEM vSql;
	LET vSql = 'dbaccess bdicred ' || TRIM(cRuta)|| TRIM(vNomQuery);
	SYSTEM vSql;
	
	
	/* Comienzan validaciones */
	SELECT COUNT(*) INTO vTotalRegistros FROM "informix".tmp_sdo_retenido;
	
	IF vTotalRegistros = 0 THEN
		LET vMensajeRet = 'Archivo Vacio';
		RETURN vCodRet, vMensajeRet;	
	END IF;
	
	--Valida la existencia del credito
	FOREACH WITH HOLD
		SELECT num_credito into v_num_credito from bdicred:tmp_sdo_retenido 
			
			SELECT count(*) INTO i FROM sd_maecred WHERE num_credito = v_num_credito;
	
			IF i IS NULL OR i = 0 THEN
				BEGIN WORK;
					UPDATE "informix".tmp_sdo_retenido SET existe = 0 where num_credito = v_num_credito;
				COMMIT WORK;
			END IF;
			
	END FOREACH;
	
	/*PASO 1*/
	/* TRUNCATE */
	TRUNCATE TABLE "informix".sd_retenidolibera;
	
	/*PASO 2*/
	/* LOAD */
	INSERT INTO bdicred:"informix".sd_retenidolibera (num_tarjeta, num_credito, monto, folio_suc, fecha_hora)
	SELECT tmpsdo.num_tarjeta, tmpsdo.num_credito, tmpsdo.monto,tmpsdo.folio_suc,tmpsdo.fecha_hora
	FROM "informix".tmp_sdo_retenido tmpsdo 
	WHERE existe = 1 ;

	/*PASO 3*/
	/* STORED PRODECURED */
	EXECUTE PROCEDURE "informix".libera_retenido_forzado() into vCodRet2;
	
	SELECT COUNT(*) into i FROM tmp_sdo_retenido where existe = 0;
	
	IF  i > 0  THEN
		LET vSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'ObservacionesSaldoRetenido'||vfecha||'.unl'||
		' SELECT num_credito,folio_suc,DECODE(existe,0,''Credito no existe'') FROM "informix".tmp_sdo_retenido where existe = 0 " > '||TRIM(cRuta)|| TRIM(vNomQuery) ;
		SYSTEM vSql;
		LET vSql = 'dbaccess bdicred ' || TRIM(cRuta)|| TRIM(vNomQuery);
		SYSTEM vSql;
	END IF;
	
	LET vSql = 'rm -f ' || TRIM(cRuta) || TRIM(vNomQuery);
	SYSTEM vSql;
	
	IF vCodRet2 <> "000" THEN
		LET vMensajeRet = 'Error en ejecucion del stored libera_retenido_forzado';
		RETURN vCodRet2,vMensajeRet ;
	END IF;
	
	RETURN vCodRet,vMensajeRet;
END;
END PROCEDURE;