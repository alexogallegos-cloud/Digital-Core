CREATE PROCEDURE "informix".sp_sacreportemensualtae(pConvenio CHAR(5), pPeriodo CHAR(6))
RETURNING
		CHAR (6) 	  AS retorno,
		CHAR(6) 	  AS aniomes,
		DATE 	 	  AS fecha,
		INTEGER       AS num_operaciones,
		MONEY (16,2)  AS comision,
		MONEY (16,2)  AS iva;

--Definicion de Variables
DEFINE cCodRet			 CHAR(6);
DEFINE cAnioMes			 CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE dFecha			 DATE;
DEFINE iNumOperaciones	 INTEGER;
DEFINE iSqlErr			 INTEGER;
DEFINE iIsamErr			 INTEGER;
DEFINE mComision		 MONEY(16,2);
DEFINE mIva				 MONEY(16,2);

--Inicializacion de Variables
LET cCodRet				 = '000000';
LET cAnioMes			 = '';
LET dFecha				 = DATE (1);
LET iNumOperaciones		 = 0;
LET mComision			 = 0;
LET mIva				 = 0;
LET iSqlErr				 = 0;
LET iIsamErr			 = 0;
LET cInfoErr			 = '';

-- SET DEBUG FILE TO  '/home/sysifx/JesusBueno/sp_sacreportemensualtae.out';
-- TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualtae");
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;

	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;

	IF  pPeriodo = "" OR LENGTH(pPeriodo) <> 6 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
	ELSE
		SET ISOLATION TO DIRTY READ;
		FOREACH

			SELECT aniomes, fecha, num_operaciones, comision, iva
			INTO cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			FROM bdisac:"informix".sac_liquidacionmensual
			WHERE aniomes = pPeriodo
			AND id_convenio = pConvenio
			ORDER BY fecha

			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : JesÃºs Isaias Bueno',
'DESCRIPCIÃN: Obtiene la informacion para la generacion del reporte mensual de pago de Tiempo Aire',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 22 Enero 2015',
'VERSIÃN: 20150122.1740',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportesemanaltae(pConvenio CHAR (5),pConsecutivo INTEGER)
	RETURNING
			CHAR (6) 	AS retorno,
			INTEGER 	AS rec_lunes ,
			INTEGER 	AS rec_martes,
			INTEGER 	AS rec_miercoles,
			INTEGER 	AS rec_jueves,
			INTEGER 	AS rec_viernes,
			INTEGER 	AS rec_sabado,
			INTEGER 	AS rec_domingo,
			MONEY(16,2) AS cob_lunes,
			MONEY(16,2) AS cob_martes,
			MONEY(16,2) AS cob_miercoles,
			MONEY(16,2) AS cob_jueves,
			MONEY(16,2) AS cob_viernes,
			MONEY(16,2) AS cob_sabado,
			MONEY(16,2) AS cob_domingo,
			INTEGER 	AS rec_efectivo,
			INTEGER 	AS rec_chequemb,
			INTEGER 	AS rec_chequeob,
			INTEGER 	AS rec_tarcred,
			MONEY(16,2) AS cob_efectivo,
			MONEY(16,2) AS cob_cheqmb,
			MONEY(16,2) AS cob_cheqob,
			MONEY(16,2) AS cob_tarcred,
			MONEY(16,2) AS liq_miercoles,
			MONEY(16,2) AS liq_jueves,
			MONEY(16,2) AS liq_viernes,
			MONEY(16,2) AS liq_sabado,
			MONEY(16,2) AS liq_domingo,
			MONEY(16,2) AS liq_lunes,
			MONEY(16,2) AS liq_martes,
			MONEY(16,2) AS aclaraciones,
			MONEY(16,2) AS comision,
			MONEY(16,2) AS iva_comision,
			DATE        AS fec_iniperiodo,
			DATE 	    AS fec_finperiodo,
			INTEGER 	AS keyx;
 --Definicion de Variables
	DEFINE cCodRet			CHAR (6);
	DEFINE cInfoErr         CHAR(100);
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE iRecLunes		INTEGER;
	DEFINE iRecMartes		INTEGER;
	DEFINE iRecMiercoles	INTEGER;
	DEFINE iRecJueves		INTEGER;
	DEFINE iRecViernes		INTEGER;
	DEFINE iRecSabado		INTEGER;
	DEFINE iRecDomingo		INTEGER;
	DEFINE iRecEfectivo		INTEGER;
	DEFINE iRecChequemb		INTEGER;
	DEFINE iRecChequeob		INTEGER;
	DEFINE iRecTarcred		INTEGER;
	DEFINE iCobEfectivo		INTEGER;
	DEFINE dFecIniPeriodo	DATE;
	DEFINE dFecFinPeriodo	DATE;
	DEFINE mCobLunes		MONEY(16,2);
	DEFINE mCobMartes		MONEY(16,2);
	DEFINE mCobMiercoles	MONEY(16,2);
	DEFINE mCobJueves		MONEY(16,2);
	DEFINE mCobViernes		MONEY(16,2);
	DEFINE mCobSabado		MONEY(16,2);
	DEFINE mCobDomingo		MONEY(16,2);
	DEFINE mCobCheqmb		MONEY(16,2);
	DEFINE mCobCheqob		MONEY(16,2);
	DEFINE mCobTarcred		MONEY(16,2);
	DEFINE mLiqMiercoles	MONEY(16,2);
	DEFINE mLiqJueves		MONEY(16,2);
	DEFINE mLiqViernes		MONEY(16,2);
	DEFINE mLiqSabado       MONEY(16,2);
	DEFINE mLiqDomingo      MONEY(16,2);
	DEFINE mLiqLunes		MONEY(16,2);
	DEFINE mLiqMartes		MONEY(16,2);
	DEFINE mAclaraciones	MONEY(16,2);
	DEFINE mComision		MONEY(16,2);
	DEFINE mIvaComision		MONEY(16,2);
--Inicializacion de Variables
	LET cCodRet			= '000000';
	LET iRecLunes		= 0;
	LET iRecMartes		= 0;
	LET iRecMiercoles	= 0;
	LET iRecJueves		= 0;
	LET iRecViernes		= 0;
	LET iRecSabado		= 0;
	LET iRecDomingo		= 0;
	LET mCobLunes		= 0;
	LET mCobMartes		= 0;
	LET mCobMiercoles	= 0;
	LET mCobJueves		= 0;
	LET mCobViernes		= 0;
	LET mCobSabado		= 0;
	LET mCobDomingo		= 0;
	LET iRecEfectivo	= 0;
	LET iRecChequemb	= 0;
	LET iRecChequeob	= 0;
	LET iRecTarcred		= 0;
	LET iCobEfectivo	= 0;
	LET mCobCheqmb		= 0;
	LET mCobCheqob		= 0;
	LET mCobTarcred		= 0;
	LET mLiqMiercoles	= 0;
	LET mLiqJueves		= 0;
	LET mLiqViernes		= 0;
	LET mLiqSabado      = 0;
	LET mLiqDomingo     = 0;
	LET mLiqLunes		= 0;
	LET mLiqMartes		= 0;
	LET mAclaraciones	= 0;
	LET mComision		= 0;
	LET mIvaComision	= 0;
	LET dFecIniPeriodo	= DATE (1);
	LET dFecFinPeriodo	= DATE (1);
	LET iSqlErr			= 0;
	LET iIsamErr		= 0;
	LET cInfoErr		= '';
BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportesemanaltae");
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo,
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo;
		END IF;
	END EXCEPTION;
	SET LOCK MODE TO WAIT 3;
	IF  pConsecutivo IS NULL THEN
		LET cCodRet = "00001";
		RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
			mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo,
			mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
			mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo;
	ELSE
		SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT {+INDEX (bdisac:"informix".sac_liquidacionsemanal idx_sacliqsem)} rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, cob_martes,
					cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred,
					cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred, liq_miercoles, liq_jueves, liq_viernes, liq_sabado, liq_domingo, liq_lunes, liq_martes,
					aclaraciones, comision, iva_comision, fec_iniperiodo, fec_finperiodo
				INTO iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo,
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo
				FROM bdisac:"informix".sac_liquidacionsemanal
				WHERE id_convenio = pConvenio
				AND  consecutivo_convenio  = pConsecutivo
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes,
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, iCobEfectivo,
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqSabado, mLiqDomingo, mLiqLunes, mLiqMartes, mAclaraciones, mComision,
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, pConsecutivo WITH RESUME;
			END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : JesÃºs Isaias Bueno',
'DESCRIPCIÃN: Consulta la informacion para la generacion del reporte de liquidacion semanal de pagos TAE',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : 22 Enero 2015',
'VERSIÃN: 20150122.1746',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_tramacomunicacionemex
(
	pNumCategoria   CHAR (2),
	pNumConvenio    CHAR (3),
	pFolioSucursal	CHAR (16),
	pRef1			CHAR (40),
	pId_Sucursal	CHAR (4),
	pFecha_Pago		DATE
)
RETURNING CHAR (5) AS cCodRet, CHAR (269) AS cTrama;

--Declaracion de variables
		DEFINE cCodRet 		    CHAR(6);
        DEFINE cDescription     CHAR(40);
		DEFINE cTrans_Interact  CHAR(5);
		DEFINE cTrans_Servicio  CHAR(5);
		DEFINE cClave_Medio	    CHAR(2);
		DEFINE cClave_Centro    CHAR(2);
		DEFINE cSucursal	    CHAR(30);
		DEFINE cCuenta_Deposito CHAR(20);
		DEFINE cForma_pago	    CHAR(2);
		DEFINE cRefer1		    CHAR(27);
		DEFINE cImporte		    CHAR(16);
		DEFINE cFecha_Pago	    CHAR(10);
		DEFINE cFecha_Aplica    CHAR(10);
		DEFINE cAutoriza	    CHAR(60); --folio_Suc from sac_movimientos
		DEFINE cPlazo		    CHAR(2);  --valor from sac_param
		DEFINE cTrama			CHAR(269);
		DEFINE iSqlErr			INTEGER;
		DEFINE cTran_suc		CHAR (4);
		DEFINE cTran_cent		CHAR(4);
		DEFINE cUser			CHAR(8);
		DEFINE iValida			INTEGER;

		LET cCodRet 			= '00000'; --Codigo 00000 = OK; 00001 = No hubo datos; 00002 = Cualquier otro error
        LET cDescription        = '';
        LET cTrans_Interact		= '';
        LET cTrans_Servicio		= '';
        LET cClave_Medio		= '';      --Identificacion del medio de pago. Siempre serÃ¡ parametrizado 2 para ventanilla, 1 en Linea.
        LET cClave_Centro		= '';    --Identificacion del centro de pago. Siempre serÃ¡ 36, el cliente definia para BanCoppel.
        LET cSucursal			= '';
        LET cCuenta_Deposito  	= '';
        LET cForma_pago			= '';
        LET cRefer1				= '';
        LET cImporte			= '';
        LET cFecha_Pago			= '';
        LET cFecha_Aplica		= '';
        LET cAutoriza			= '';     --Folio_Suc
        LET cPlazo				= '';
		LET cTrama				= '';
		LET cTran_suc			='';
		LET cTran_cent			='';
		LET cUser				='';
		Let iValida				= 0;
		LET iSqlErr				= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTrama;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/sp_tramacomunicacionemex.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		IF NVL (pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' OR NVL (pFolioSucursal, '') = ''
		   OR NVL (pRef1, '') = '' OR NVL (pId_Sucursal, '') = '' OR NVL (pFecha_Pago, '') = ''  THEN
			 LET cCodRet = '00002';
			 --DATOS VACIOS, ERROR.
			 RETURN cCodRet, NVL(cTrama, '');
		END IF;

		--Obtenemos los campos requeridos  de bdisac: sac_intrfz_serv
		SELECT trans_interact, trans_servicio
		INTO   cTrans_Interact, cTrans_Servicio
		FROM    bdisac: "informix".sac_intrfz_serv
		WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00001';
				RETURN cCodRet, NVL(cTrama, '');
			END IF;


		--FORMA DE PAGO: EFECTIVO (1 = '04')
		--FORMA DE PAGO: CARGO CUENTA (2 = '08')
		--FORMA DE PAGO: CARGO TARJETA DE CREDITO (5 = '02')
		--FORMA NO ENCONTRADA (NINGUNA DE LAS ANTERIORES = default: '-1')
		SELECT DECODE (forma_pago, '1', '04', '2', '08', '5', '02', '-1')
		INTO cForma_pago --Para decidir que forma de pago enviar en base a validacion con sac_movimientos.forma_pago
		FROM  bdisac: "informix".sac_movimientos
		WHERE id_sucursal = pId_Sucursal AND folio_suc = pFolioSucursal AND numcategoria = pNumCategoria
			   AND numconvenio = pNumConvenio AND referencia1 = pRef1 AND fecha_pago=pFecha_Pago; --Activa idxsac_mov114 (Indice)

			--cForma_pago = '-1' es una forma de pago no vÃ?Â¡lida, no encontrada.
			IF DBINFO("sqlca.sqlerrd2") = 0 OR cForma_pago = '-1' THEN
				LET cCodRet = '00001';
				RETURN cCodRet, NVL(cTrama, '');
			END IF;

		IF cForma_pago = '04' THEN
			SELECT  trans_cen_efectivo_cliente INTO  cTran_cent FROM bdisac: "informix".sac_convenios WHERE numcategoria=pNumCategoria and numconvenio=pNumConvenio;
		ELSE
			IF cForma_pago = '08' THEN
				SELECT  trans_cen_cargo_cliente INTO  cTran_cent FROM bdisac: "informix".sac_convenios WHERE numcategoria=pNumCategoria and numconvenio=pNumConvenio;
			ELSE
				IF cForma_pago = '02' THEN
					SELECT valor INTO  cTran_cent FROM bdisac: "informix".sac_param where cod_param = 25;
				ELSE
					LET cTran_cent = ' ';
				END IF;
			END IF;
		END IF;
		SELECT fn_instr(valor, pId_Sucursal) INTO iValida FROM  bdisac: "informix".sac_param where cod_param = '28';

			IF iValida > 0 THEN
				SELECT valor INTO cClave_Medio FROM bdisac: "informix".sac_param where cod_param = '27';
			ELSE
				SELECT valor INTO cClave_Medio FROM bdisac: "informix".sac_param where cod_param = '26';
			END IF;

		SELECT valor INTO cClave_Centro FROM  bdisac: "informix".sac_param where cod_param = '29';

		--Replace quita los '.' y ',' del importe_pago. To_Char convierte la fecha al estÃ?Â¡ndar solicitado por el cliente. 1468-EdoMex.
		SELECT id_sucursal, referencia1,
			   RPAD (REPLACE(REPLACE(REPLACE (importe_pago, '.', ''), ',', ''), '$', ''), 16, ' '),
			   TO_CHAR(fecha_pago, "%d%m%Y"), RPAD(folio_suc, 88, ' ')
		INTO   cSucursal, cRefer1, cImporte, cFecha_Pago, cAutoriza --cAutoriza = (folio_suc)
		FROM    bdisac: "informix".sac_movimientos
		WHERE  id_sucursal = pId_Sucursal AND folio_suc = pFolioSucursal AND numcategoria = pNumCategoria
			   AND numconvenio = pNumConvenio AND referencia1 = pRef1 AND fecha_pago=pFecha_Pago;
		--WHERE  id_sucursal = pId_Sucursal AND numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND referencia1 = pRef1;

			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00001';
				RETURN cCodRet, NVL(cTrama, '');
			ELSE
				LET cFecha_Aplica =  cFecha_Pago; --fecha_pago se aplica a cFecha_Pago y a cFecha_Aplica.
			END IF;

		-- El cÃ³digo comentado en las dos secciones de continuaciÃ³n son parte importante a futuro ya que se definirÃ¡ el plazo parametrizado lo cual no ha sido definido hasta el momento
		/*SELECT valor
		INTO   cPlazo
		FROM   sac_param
		WHERE  cod_param = '01'; --Inicialmente '00' hasta que el cliente responda que valor fijo va en cod_param.
		*/
		LET cPlazo = '00';

		/*IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00001';
				RETURN cCodRet, NVL(cTrama, '');
		END IF;	*/

	/*	SELECT cuenta
		INTO cCuenta_Deposito
		FROM bdisac: "informix".sac_edomex_cuentas
		WHERE SUBSTRING(prefijo FROM 1 FOR 6) LIKE SUBSTRING(pRef1 FROM 1 FOR 6);
		--LOS PRIMEROS 6 CARACTERES DE LA REFERENCIA 1, SON EL PREFIJO A BUSCAR.*/

        EXECUTE PROCEDURE "informix".sp_asignacuenta_edomex(SUBSTRING(pRef1 FROM 1 FOR 6))
		INTO cCodRet,cDescription,cCuenta_Deposito;

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00002';
					RETURN cCodRet, NVL(cCuenta_Deposito, '');
		ELSE
			LET cTrama = cTrans_Servicio||cClave_Medio||cClave_Centro||TRIM(cSucursal)||TRIM(cCuenta_Deposito)||cForma_pago||cRefer1||cImporte||TRIM(cFecha_Pago)||TRIM(cFecha_Aplica)||cAutoriza||cPlazo;


			-- Solicita y guarda el valor de trans_suc_efectivo de bdisac: sac_convenios
			SELECT trans_suc_efectivo INTO cTran_suc FROM bdisac: "informix".sac_convenios WHERE numcategoria=pNumCategoria and numconvenio=pNumConvenio;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
					RETURN cCodRet, NVL(cCuenta_Deposito, '');
			END IF;
			--Solicita y guarda el valor de usuario de bdisac: sac_movimientos
			SELECT usuario INTO cUser FROM bdisac: "informix".sac_movimientos where id_sucursal = pId_Sucursal AND folio_suc = pFolioSucursal AND numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND referencia1 = pRef1 AND fecha_pago=pFecha_Pago;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
					RETURN cCodRet, NVL(cCuenta_Deposito, '');
			END IF;

			--Almacenar datos en bdisac: sac_msw_solicitud
			INSERT INTO bdisac: "informix".sac_msw_solicitud(numcategoria, numconvenio, id_sucursal, trans_suc, trans_central, trans_interact, folio_suc, fecha_pago, campo1, campo2, campo3, campo4, campo5, campo6 , campo7, campo8, campo9, campo10, campo11, campo12, campo13, campo14, campo15, campo16, campo17, campo18, campo19, campo20, campo21, campo22, campo23, campo24, campo25, campo26, campo27, campo28, campo29, campo30, campo31, campo32, campo33, campo34, campo35, campo36, campo37, campo38, campo39, campo40, user_insert, fecha_insert) VALUES (pNumCategoria, pNumConvenio, pId_Sucursal, cTran_suc, cTran_cent, cTrans_Interact, pFolioSucursal, pFecha_Pago,  cTrans_Servicio, cClave_Medio, cClave_Centro, cSucursal, cCuenta_Deposito, cForma_pago, cRefer1 , cImporte, cFecha_Pago, cFecha_Aplica, cAutoriza, cPlazo, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',  cUser, current );

		RETURN cCodRet, NVL(cTrama, '');
		END IF;


END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: SPL que recupera datos (EdoMex) para generar la trama a enviar a Interact.',
'FOLIO: 1468-PagosRef_PagoImpEdoMex',
'FECHA : 10 de Febrero de 2015',
'VERSION: 20150202.1000',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consultaconceptogdf(pClave CHAR(2))

--DATOS A REGRESAR---
RETURNING
CHAR(5)   AS CodigoRetorno,
CHAR(20)  AS Leyenda;

--DECLARACION DE VARIABLES			
DEFINE iSqlerr     	INTEGER;
DEFINE cCodRet     	CHAR(5);
DEFINE cLeyenda     CHAR(20);

--ASIGNACION DE VALORES
LET iSqlerr = 0;
LET cCodRet = '00000';
LET cLeyenda = '';
 
   --SET DEBUG FILE TO "/respaldosbd/Martha/sp_consultaconceptogdf.out";
   --TRACE ON;   
  
BEGIN

	ON EXCEPTION SET iSqlerr
		LET cCodRet= iSqlerr;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
	IF NVL(pClave,'') = '' THEN		
		LET cCodRet = '00001';
	END IF;
	
	SELECT leyenda 
	INTO cLeyenda
	FROM bdisac:"informix".sac_catconceptosgdf
	WHERE clave = pClave;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
		LET cCodRet = '00002';
	END IF;  

	RETURN cCodRet, cLeyenda;
	
END
END PROCEDURE

DOCUMENT
"Autor : Martha Aguirre",
"FECHA : 08/01/2013",
"Descripcion: Valida si la clave recibida es vÃ¡lida",
"	          consultando en el catalago de conceptos",
"             de pagos del gobierno del distrito federal",
"Ver.  : 1.0",
"BD    : bdisac",
'MODIFICACION : 11/02/2013',
'MODIFICO :Felipe Urias  ',
'DESCRIPCION: se agrega como retorno la leyenda de conceptos de sac_catconceptosgdf';

CREATE PROCEDURE "informix".sp_consultaempleadowu
(
	pSucursal CHAR(4), 	pEmpleado CHAR(8), pCategoria CHAR(2), 	pConvenio CHAR(3), pModo SMALLINT
)
--		pSucursal		CHAR(4);   Parámetro obligatorio.
--		pEmpleado		CHAR(8);   Parámetro obligatorio.
--		pCategoria		CHAR(2);   Parámetro Obligatorio para modalidad 2.
--		pConvenio 		CHAR(3);   Parámetro obligatorio para modalidad 2.
--		pModo			SMALLINT;  Parámetro obligatorio.
		
RETURNING
	CHAR(5)  AS cCodRet,	    	
	SMALLINT AS sValor,	
	CHAR(30) AS cDescripcion,
	CHAR(1)  AS cMsg;

DEFINE cCodRet		  CHAR(5);
DEFINE iSqlErr  	  INTEGER;
DEFINE sValor		  SMALLINT;
DEFINE cDescripcion   CHAR(30);
DEFINE cMsg			  CHAR(1);
DEFINE cEdoFronterizo CHAR(2); --Estado fronterizo.
DEFINE dFecha_hoy	  DATETIME YEAR TO FRACTION;

LET cCodRet		   = '00002'; --Inicializado como código de error en caso de no entrar al cuerpo del sp.
LET iSqlErr  	   = 0;
LET sValor		   = 0;
LET cDescripcion   = '';
LET cMsg		   = '';	
LET cEdoFronterizo = '';
LET dFecha_hoy	   = CURRENT;

	BEGIN
		-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, sValor, cDescripcion, cMsg;	
		END IF;
		END EXCEPTION;
			
		--SET DEBUG FILE TO '/respaldosbd/antoniocebreros/1508/sp_consultaempleadowu.out';
		--TRACE ON;
			 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;  

		--Validamos parámetros obligatorios
		IF NVL(pSucursal, '') = '' OR NVL(pEmpleado, '') = '' OR NVL(pModo, '') = '' THEN
			LET cCodRet = '00001';
			RETURN cCodRet, sValor, cDescripcion, cMsg;			
		ELSE
			--Obtenemos la fecha de bdinteg:"informix".si_fechas (campo fecha_hoy) y la guardamos en la variable dFecha_hoy para uso posterior.
			SELECT fecha_hoy
			INTO dFecha_hoy
			FROM bdinteg:"informix".si_fechas;
			
			IF pModo = '1' THEN				
				--Validamos que la sucursal recibida como parámetro exista en bdinteg:"informix".si_sucursales.
				IF NOT EXISTS(SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal) THEN
					LET cCodRet = '00002';
					RETURN cCodRet, sValor, cDescripcion, cMsg;
				ELSE
					SELECT estado 
					INTO cEdoFronterizo
					FROM bdinteg:"informix".si_sucursales 
					WHERE sucursal = pSucursal;
								
					--Validamos si la sucursal está o no en un estado fronterizo
					------------------------------------------------------------------------------------------------------------------
					IF EXISTS 
					(SELECT descripcion FROM "informix".sac_param WHERE  TRIM(valor) LIKE '%' || TRIM(cEdoFronterizo) || '%' AND cod_param = '87084' ) THEN
						--Sí es estado fronterizo
						--Validamos si el empleado ha aceptado los términos de WU (Western Union) antes de la transacción actual.
						IF EXISTS( SELECT usuario FROM "informix".sac_registraempleadowu WHERE usuario = pEmpleado AND sucursal = pSucursal 
								   AND fecha = dFecha_hoy
								 ) THEN
							--Si ha aceptado los términos.
							LET cCodRet		 = '00000';
							LET sValor 		 = 1;
							LET cDescripcion = 'Sucursal fronteriza';
							LET cMsg 		 = 1;				
							RETURN cCodRet, sValor, cDescripcion, cMsg;					
						ELSE
							--No ha aceptado los términos (primer pago de remesa extranjera del empleado actual)
							LET cCodRet		 = '00000';
							LET sValor 		 = 1;
							LET cDescripcion = 'Sucursal fronteriza';
							LET cMsg 		 = 0;				
							RETURN cCodRet, sValor, cDescripcion, cMsg;
						END IF;						
					ELSE
						--No es estado fronterizo
						LET cCodRet = '00000';
						LET sValor = 0;
						LET cDescripcion = 'Sucursal no fronteriza';
						LET cMsg = 0;				
						RETURN cCodRet, sValor, cDescripcion, cMsg;	
					END IF;
				END IF;
					------------------------------------------------------------------------------------------------------------------
			ELIF pModo = '2' THEN
				--En esta modalidad se registrará al empleado en la nueva tabla bdisac:"informix".sac_registraempleadowu.
				IF NVL(pCategoria,'') = '' OR NVL(pConvenio,'') = '' THEN
					LET cCodRet = '00001';
					RETURN cCodRet, sValor, cDescripcion, cMsg;
				ELSE					
					INSERT INTO "informix".sac_registraempleadowu (numcategoria, numconvenio, usuario, sucursal, fecha, fecha_hora, status)
					VALUES (pCategoria, pConvenio, pEmpleado, pSucursal, dFecha_hoy, CURRENT, 0);
						IF DBINFO("sqlca.sqlerrd2") = 0 THEN
							LET cCodret = '00003'; --NO INSERTÓ EL REGISTRO.
							RETURN cCodRet, sValor, cDescripcion, cMsg;
						ELSE
							LET cCodRet = '00000';
							LET sValor = 0;
							LET cDescripcion = 'Empleado Registrado correctamente.';
							LET cMsg = 0;
							RETURN cCodRet, sValor, cDescripcion, cMsg;
						END IF;					
				END IF;
			ELSE
				LET cCodRet = '00001';
				RETURN cCodRet, sValor, cDescripcion, cMsg;
			END IF;
		END IF;		
	END
END PROCEDURE
DOCUMENT
'AUTOR: 96273763, Antonio Cebreros Perez',
'FOLIO: 230202 - 1508 - MttoRemWUyOVoVFrontNte',
'DESCRIPCION: Verifica si el estado es fronterizo, de ser así verificará si el empleado ya ha aceptado los términos impuestos por WU, en caso de no haber aceptado aún, registrará al empleado en la nueva tabla bdisac:sac_registraempleadowu.',
'FECHA: 31/10/2015',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_pay 
(
	pEmpresa			CHAR(3), 
	pMarca              CHAR(2),
	pUsuario			CHAR(8),  
	pBenefNameType 		CHAR(1), 
	pBenefNombreUno		CHAR(40), 
	pBenefNombreDos		CHAR(40), 
	pBenefApaterno		CHAR(40), 
	pBenefAmaterno		CHAR(40), 
	pBenefCiudad 		CHAR(24),-- se adapta a la longitud del campo benef_ciudad  
	pBenefEdo  			CHAR(40), 
	pBeneCP				CHAR(9),-- se adapta a la longitud del campo benef_cp
	pBenefIdType  		CHAR(1), 
	pBenefIdPaisExpedi	CHAR(45), 
	pBenefIdNumber  	CHAR(20), 
	pBenefTieneFechVenc	CHAR(1), 
	pBenefFechaVenc  	CHAR(8),
	pBenefFechNac  		CHAR(8), 
	pBenefOcupacion  	CHAR(30), 
	pBenefCalleNum  	CHAR(40), 
	pBenefColDelMun  	CHAR(40), 
	pBenefPais  		CHAR(45), 
	pBenefTelPart 		CHAR(20), -- se adapta a la longitud del campo benef_tel_particular 
	pBenefTelCel  		CHAR(20), -- se adapta a la longitud del campo benef_tel_celular 
	pBenefEmail  		CHAR(40), 
	pBenefPaisNac  		CHAR(2), 
	pBenefNacionalidad 	CHAR(15), 
	pBenefSexo  		CHAR(1), 
	pBenefCiudadNac		CHAR(20), 
	pBenefEdoNac		CHAR(20), 
	pBenefCodPais		CHAR(3), 
	pBenefCodMoneda		CHAR(3), 
	pMontoOrigen		CHAR(10), 
	pMontoDestino		CHAR(10), 
	pMoneyTransferKey	CHAR(10), 
	pNewMtcn			CHAR(16), 
	pMtcn				CHAR(10), 
	pConfPago			CHAR(1), 
	pForeignRefNumRq	CHAR(16), 
	pFechaHrRq			DATETIME YEAR TO SECOND, 
	pRetCode			CHAR(5), 
	pDatosBufer			CHAR(500), 
	pMtcnRp				CHAR(10), 
	pPuntosGanados		CHAR(4), 
	pWuFechaPago		CHAR(16), 
	pForeignSystemIdRp	CHAR(11), 
	pForeingRefNumRp	CHAR(16), 
	pForeignRsCantIdRp	CHAR(11), 
	pDesError			CHAR(250), 
	pPartnerIdErr		CHAR(10), 
	pFechaHoraRp		DATETIME YEAR TO SECOND, 
	pUserInsert			CHAR(8), 
	pFechaInsert		DATETIME YEAR TO SECOND,
	pSecondIdType		CHAR(1),  --DSB: 03/11/2015 (1508) Antonio Cebreros Pérez.
	pSecondPaisExp		CHAR(44), --DSB: 03/11/2015 (1508) Antonio Cebreros Pérez.
	pSecondIDNumber   	CHAR(30)  --DSB: 03/11/2015 (1508) Antonio Cebreros Pérez.
)

RETURNING  CHAR(5) AS cod_err, CHAR(30) AS error_desc;

	--DEFINICION DE VARIABLES--
    DEFINE	iSqlErr				INTEGER;
	DEFINE 	iIsamErr			INTEGER;
    DEFINE	cCodRet				CHAR(5);
	DEFINE  cRetCode			CHAR(5);
	DEFINE  cDesc_Error         CHAR(250);
	DEFINE	cCodRetAux			CHAR(5);
	DEFINE	cTxnStatus			CHAR(1);
	DEFINE	cNombreSP			CHAR(45);
	DEFINE 	cCadena_ent			CHAR(100);
	DEFINE cError_Desc  		CHAR(30);
	DEFINE dFechaProceso    	DATETIME YEAR TO SECOND;
	DEFINE cChannelType 		CHAR(3);
    DEFINE cChannelName 		CHAR(3); 
    DEFINE cChannelVersion		CHAR(4);
	DEFINE cForeignSystemId		CHAR(11); 
	DEFINE cForeignRsCntRq  	CHAR(11);
	DEFINE cTemplateId          CHAR(10);
	DEFINE cSucursal		CHAR(4);
	
	--INICIALIZACION DE VARIABLES--
    LET	iSqlErr				= 0;
	LET	iIsamErr 			= 0;
    LET cCodRet				= '00000';
	LET cRetCode			= '00000';
	LET cDesc_Error			= "";
	LET cCodRetAux			= '00000';
	LET cTxnStatus			= 'C';
	LET	cNombreSP			= 'sp_sac_wu_guardarespuesta_pay';
	LET cCadena_ent			= TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pMoneyTransferKey,'NULL'))||'|'||TRIM(NVL(pNewMtcn,'NULL'));
    LET cError_Desc 		= "Error en el proceso";
	LET dFechaProceso		=  CURRENT::DATETIME YEAR TO SECOND;
	LET cChannelType 	 	= "";	
    LET cChannelName 	 	= "";	 
    LET cChannelVersion	 	= "";
	LET cForeignSystemId 	= ""; 
	LET cForeignRsCntRq  	= "" ;
	LET cTemplateId			= "";
	LET cSucursal 			= "";

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;

			EXECUTE PROCEDURE "informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSqlErr,iIsamErr,cCadena_ent,pUsuario,dFechaProceso) 
			INTO cCodRetAux;

			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF
			--	2014.11.11 FRG-i	En caso de error No Controlado,  se asiga valor "C" a cTxnStatus:
				LET cTxnStatus		 = 'C';
			--	2014.11.11 FRG-f

			INSERT INTO "informix".sac_wu_pay
					(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1,    benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type, benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago, foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp, puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err, fecha_hora_rp, user_insert, fecha_insert, benef_second_id_type, benef_second_pais_expedicion, benef_second_id_number)
			
			VALUES
					(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun, pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac,  pBenefNacionalidad, pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey, pNewMtcn, pMtcn, pConfPago, cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, pRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago,pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp, pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current, pSecondIdType, pSecondPaisExp, pSecondIDNumber);

			RETURN cCodRet, cError_Desc;
		END IF;

	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_guardarespuesta_pay.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF pRetCode = '504' THEN
	    LET cRetCode = '99999';
		LET pDesError = 'Aplicativo WU no activo, validar';
		
	END  IF;

	IF pRetCode <>  '504' AND pRetCode <> '00000' AND pRetCode <> '66666' THEN		
        IF pRetCode <> '20001' then
            LET cRetCode = '99998';
            LET pDesError = 'Sin respuesta del aplicativo, validar';
        ELIF pRetCode = '20001' then
            LET cRetCode = '20001';
            LET pDesError = 'Caracter invalido en la cadena';
        END IF;
	END IF;

	IF pRetCode = '66666' THEN
		LET cDesc_Error = pDesError;
		LET cRetCode = pRetCode;
	END IF
	
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
	----Sacar de sac_param los valres de cChannelType,cChannelName,cChannelVersion,cForeignSystemId,cForeignRsCntRq
		IF (SELECT valor FROM "informix".sac_param WHERE cod_param ='87054') = pMarca
		OR (SELECT valor FROM "informix".sac_param WHERE cod_param ='87055') = pMarca
		OR (SELECT valor FROM "informix".sac_param WHERE cod_param ='87056') = pMarca THEN
			IF pUsuario = "sys_wu" THEN
				LET cSucursal = '9250';
			ELSE
				SELECT sucursal
				INTO cSucursal
				FROM bdinteg:"informix".si_ejecut
				WHERE empresa = pEmpresa AND ejecutivo = pUsuario;
			END IF;
			IF pUsuario = 'sys_wu' OR cSucursal <> '' THEN
			
				SELECT fsid ,counter_id
				INTO cForeignSystemId ,cForeignRsCntRq
				FROM "informix".sac_wu_identificadores
				WHERE empresa = pEmpresa AND marca = pMarca AND sucursal = cSucursal;

				IF cForeignSystemId IS NULL OR cForeignSystemId = '' OR cForeignRsCntRq IS NULL OR cForeignRsCntRq = '' THEN
					LET cCodRet = '00027';
					LET cError_Desc	= 'Usuario no tiene Id. Asignado';
				END IF;
			ELSE
				LET	cCodRet = '00026'; --- Usuario no se encuentra
				LET cError_Desc	= 'NO EXISTE USUARIO';
		   END IF;
		ELSE
			LET	cCodRet = '00003'; --- Marca Inválida
			LET cError_Desc	= 'NO EXISTE MARCA EN SAC PARAM';
		END IF;
		
		SELECT valor
		INTO cChannelType
		FROM "informix".sac_param 
		WHERE cod_param = '87050';  
		 
		SELECT valor
		INTO cChannelName
		FROM "informix".sac_param 
		WHERE cod_param = '87051'; 
		 
		SELECT valor
		INTO cChannelVersion
		FROM "informix".sac_param 
		WHERE cod_param = '87052'; 
		
		SELECT valor
		INTO cTemplateId
		FROM "informix".sac_param 
		WHERE cod_param = '87063';

		--	2014.11.11 FRG-i	Se asigna el valor 'A' para el la variable "cTxnStatus".
			LET	cTxnStatus	= 'A';
		--	2014.11.11 FRG-f
	
		INSERT INTO "informix".sac_wu_pay	
				(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1, benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type,benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago,foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp,puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err,fecha_hora_rp, user_insert, fecha_insert, benef_second_id_type, benef_second_pais_expedicion, benef_second_id_number)
						
		VALUES
				(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun,pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac, pBenefNacionalidad,pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey,pNewMtcn, pMtcn, pConfPago,cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, cRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago, pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp,pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current, pSecondIdType, pSecondPaisExp, pSecondIDNumber);
					   
		IF  cCodRet <> '00000' THEN
			
			IF cCodRet =  '00027' OR cCodRet =  '00026'  THEN		
				RETURN cCodRet,cError_Desc;	
			END IF;
		  
            RETURN cCodRet,cError_Desc;		
	    ELSE	
			
			IF cCodRet = '00000' THEN
				LET cError_Desc = "Ejecucion SP exitosa";
			END IF;	
			
           RETURN cCodRet,cError_Desc;
	    END IF;	
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se crea SP para guardar los campos del mensaje  <receive-money-pay> (request-reply) en la tabla bdisac:sac_wu_pay',  
'AUTOR: Christian Echavarria',			
'FECHA: 17/Jul/2013',
'DESCRIPCION: Se modifica para que consulte los campos counter_id y  fsid de sac_wu_identificadores',  
'AUTOR: Mario Gallardo',			
'FECHA: 03/10/2013',
'DESCRIPCION: Se modifica SP  para guardar el campo fecha_insert con fecha-hora-sistema central (current)',  
'AUTOR: FRG',
'FECHA: 30/Jul/2014',
'BD: bdisac',
'AUTOR: Mario Olivo',
'Empleado: 95358919',
'Folio: 1457',
'Centro: 230202',
'Descripcion: Se aumenta la longitud del parametro pBenefPais por que se aumento la longitud en la tabla sac_wu_pay para',
'			  guardar el nombre completo del pais.',
'Fecha:10/SEP/2014',
'Version: 20140910.1627',
'AUTOR: Pedro Jimenez',
'Empleado: 95689966',
'Folio: 1485',
'Centro: 230202',
'Descripcion: Se aumenta la longitud de los parametro pBenefCiudad,pBeneCP,pBenefTelPart,pBenefTelCel  por que se aumento la longitud en la tabla sac_wu_pay',
'Fecha:26/02/2015',
'Version: 20150226.1651',
'-----------------------------------------------------------------------------------------------------------------------------------------------------------------',
'AUTOR: Antonio Cebreros',
'Empleado: 96273763',
'Folio: 1508 - MttoRemWUyOVoVFrontNte',
'Centro: 230202',
'Descripcion: Se agregan 3 parámetros de entrada al sp debido a que tales parámetros representan 3 nuevas columnas para la tabla sac_wu_pay. En tal caso también se modificaron los insert del sp agregando las columnas correspondientes. Se cambia prefijo de variable productiva cFechaProceso por dFechaProceso.',
'Fecha:04/11/2015',
'Version: 20151104.1200';

CREATE PROCEDURE "informix".sac_bts_movspaso (vempresa char (3))

RETURNING CHAR (5), CHAR (100), CHAR (1), CHAR (1), CHAR (1), CHAR (1), CHAR (1), INTEGER, INTEGER, INTEGER;

--****************************************************************************************************
-- DESCRIPCION:  Proceso de movimientos histórico a tablas _paso para Conciliación Remesas BTS.
-- AUTOR : FRG
-- FECHA : 21/Ene/2014
-- BD: BDISAC
-- SISTEMA : BTS
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE ccodret 				CHAR (5);
DEFINE itot_movssac 		INTEGER;
DEFINE itot_movschqs 		INTEGER;
DEFINE itot_movsbts 		INTEGER;
DEFINE isqlerr      		INTEGER;
DEFINE iisamerr     		INTEGER;
DEFINE cinfoerr     		CHAR (100);
DEFINE cstatussac			CHAR (1);
DEFINE cstatmvhst			CHAR (1);
DEFINE ccuenta_bts			CHAR (20);
DEFINE ctrns_ctrl_efecte	CHAR (4);
DEFINE ctrns_ctrl_crgocte 	CHAR (4);
DEFINE imovsbts_payi		INTEGER;
DEFINE imovsbts_payc		INTEGER;
DEFINE cflg_sac				CHAR (1);
DEFINE cflg_chqs			CHAR (1);
DEFINE cflg_btscj			CHAR (1);
DEFINE cflg_btsab			CHAR (1);
DEFINE cflg_btsrev			CHAR (1);
DEFINE cproceso				CHAR (8);
DEFINE dfechamovs			DATE;
DEFINE iprocsac				INTEGER;
DEFINE cdiamovs				CHAR (2);
DEFINE cmesmovs				CHAR (2);
DEFINE cstmovsbts			CHAR (1);
-- 2014.02.11 FRG-i
DEFINE caniomovs			CHAR (4);
DEFINE cbts_dt				CHAR (8);
-- 2014.02.11 FRG-f

--2014.05.06 EPG
DEFINE cReferencia1         CHAR(20);	
DEFINE iFlagCen             INTEGER;
DEFINE iFlagSuc             INTEGER;
DEFINE cFolio               CHAR(16);
DEFINE dFecha_Pago           DATE;
DEFINE iCuantos             INTEGER;
DEFINE cDescripcionSPJ	 	CHAR(100);
	
	--SET DEBUG FILE TO  '/informix/adrian/sac_bts_movspaso.out';
	--TRACE ON;

/* INICIALIZACION DE VARIABLES */
LET ccodret 				= '00000';
LET itot_movssac 			= 0;
LET itot_movschqs 			= 0;
LET itot_movsbts  			= 0;
LET isqlerr  				= 0;
LET iisamerr  				= 0;
LET cinfoerr 				= "";
LET cstatussac				= "";
LET cstatmvhst				= "";
LET ccuenta_bts				= "";
LET ctrns_ctrl_efecte		= "";
LET ctrns_ctrl_crgocte 		= "";
LET imovsbts_payi			= 0;
LET imovsbts_payc			= 0;
LET cflg_sac				= "0";
LET cflg_chqs				= "0";
LET cflg_btscj				= "0";
LET cflg_btsab				= "0";
LET cflg_btsrev				= "0";
LET cproceso				= "MOVS_BTS";
LET dfechamovs				= CURRENT;
LET iprocsac				= 0;
LET cdiamovs				= "";
LET cmesmovs				= "";
LET cstmovsbts				= "";
-- 2014.02.11 FRG-i
LET caniomovs				= "";
LET cbts_dt			    	= "";
-- 2014.02.11 FRG-i

--2014.05.06 EPG
LET cReferencia1  		    = '';
LET iFlagCen      		    = 0;                 
LET iFlagSuc      		    = 0; 
LET cFolio        		    = ''; 
LET dFecha_Pago             = DATE(1);	
LET	iCuantos      		    = 0;
LET cDescripcionSPJ	 		= 'Inserta movimientos historicos (T-1) BTS a tablas de paso';

	BEGIN
    ON EXCEPTION SET isqlerr, iisamerr, cinfoerr
        IF isqlerr <> 0 THEN
            LET ccodret = isqlerr;
            EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
            RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
        END IF;
    END EXCEPTION;

/*
	Obtención fecha-SAC:
*/
	set isolation to dirty read;
	select {+INDEX(bdisac:sac_fechas 105_11)}
	fecha_hoy 
	into dfechamovs
	from bdisac:sac_fechas
	where empresa = vempresa;
	
	LET dfechamovs = dfechamovs-1;
	
	let cdiamovs = SUBSTR (dfechamovs, 4, 2);
	let cmesmovs = SUBSTR (dfechamovs, 1, 2);
	let caniomovs = SUBSTR (dfechamovs, 7, 4);
	let cbts_dt = caniomovs||cmesmovs||cdiamovs;	
	
	--INSERTA EN BITACORA
	EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_BTS_MP', dfechamovs, '0', 'informix', 'sac_bts_movspaso', cDescripcionSPJ);

	if	cmesmovs = '01' AND cdiamovs = '01'
		then
			LET dfechamovs = dfechamovs-1;
		else
			if	cmesmovs = '12' AND cdiamovs = '25'
				then
					LET dfechamovs = dfechamovs-1;
			end if;
	end if;

/*
	Validación término exitoso en proceso de pase movimientos SAC al histórico:
*/
	set isolation to dirty read;
	select count (*) into iprocsac
	from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
	if iprocsac > 0
		then
			select status into cstatussac
			from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
			if cstatussac <> "1"
				then
					update "informix".sac_procesos set fecha_insert = current where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';					
				else
			end if;
		else
			INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			values (cproceso, dfechamovs, '0', 'informix', current);
	end if;
/*
	Obtención valores parametrizados de transacciones BTS:
*/
	set isolation to dirty read;
	select {+INDEX(bdisac:sac_convenios 103_4)}
	cuenta_prestadora, trans_cen_efectivo_cliente, trans_cen_cargo_cliente
	into ccuenta_bts, ctrns_ctrl_efecte, ctrns_ctrl_crgocte
	from bdisac:sac_convenios
	where numcategoria = '07' and numconvenio = '004';

/*
	Validación termino exitoso en proceso de pase movimientos Cheques al histórico:
*/
	set isolation to dirty read;
	select {+INDEX(bdinteg:sx_contproc 255_612)}
	status_proc into cstatmvhst
	from bdinteg:sx_contproc where fecha = dfechamovs and proceso = 'PasaMovsHist' and sistema = '01';
	
	select status into cstatussac
		from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
	if	cstatussac <> "1" or cstatussac is null
		then
			LET ccodret = "00001";
			LET isqlerr = 0;
			LET iisamerr = 0;
			LET cinfoerr = "Pase de Movimientos Servicios del día a Histórico no ha concluido.";
            EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
            RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
		else
		if	cstatmvhst <> "F" or cstatmvhst is null
			then
				set isolation to dirty read;
				select count (*) into iprocsac
				from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
				if iprocsac > 0
					then
						select status into cstatussac
						from "informix".sac_procesos where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';
						if cstatussac <> "1" or cstatussac is null
							then
								update "informix".sac_procesos set fecha_insert = current where fecha_proceso = dfechamovs and proceso = 'ACT_HISTOR';								
							else
								INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
								values (cproceso, dfechamovs, '0', 'informix', current);
						end if;
					else
						INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
						values (cproceso, dfechamovs, '0', 'informix', current);
				end if;
			LET ccodret = "00002";
			LET isqlerr = 0;
			LET iisamerr = 0;
			LET cinfoerr = "Pase de Movimientos Dia a Histórico no ha concluido.";
			EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
			RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
			else
			
			select status into cstmovsbts
			from bdisac:sac_Procesos where proceso = cproceso and fecha_proceso = dfechamovs;
			if cstmovsbts = '1'
				then
					LET ccodret = "00003";
					LET isqlerr = 0;
					LET iisamerr = 0;
					LET cinfoerr = "Pase de Movimientos a tablas _paso ya ha sido ejecutado exitosamente el dia de hoy.";
					EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (isqlerr, iisamerr, cinfoerr, "sac_bts_movspaso");
					RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
				else
					if cstmovsbts = '0'
						then
							update "informix".sac_procesos set fecha_insert = current where fecha_proceso = dfechamovs and proceso = cproceso;							
						else
							INSERT into bdisac:sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
							values (cproceso, dfechamovs, '0', 'informix', current);
					end if;
			end if;
			
/*
	se confirma flag_confirmacion_sucursal='1' si la remesa esta en cheques y servicios
*/
    FOREACH
        SELECT {+INDEX (bdisac:sac_movimientoshistorial idxsac_movhisfe)} referencia1,flag_confirmacion_central, flag_confirmacion_sucursal, folio_suc, fecha_pago
			INTO  cReferencia1, iFlagCen, iFlagSuc, cFolio, dFecha_Pago
        FROM bdisac:sac_movimientoshistorial
        WHERE numcategoria = '07'
            AND numconvenio = '004'
            AND fecha_pago = dfechamovs
            AND status_cancelado <> 'S'
            AND flag_confirmacion_sucursal = 0

        IF iFlagCen = 0 or iFlagSuc =0 THEN
            SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
            IF iCuantos = 0 THEN
                SELECT COUNT(*) INTO iCuantos FROM bdicheq:sc_movhis WHERE empresa = '001' AND folio_suc = cFolio AND fech_alt = dFecha_Pago;   
                IF iCuantos = 0 THEN
                    CONTINUE FOREACH;
                END IF;
            END IF;
            IF iCuantos > 0 THEN            
                UPDATE bdisac:sac_movimientoshistorial SET flag_confirmacion_sucursal='1'
                WHERE numcategoria = '07'
                    AND numconvenio = '004'
                    AND fecha_pago = dFecha_Pago
                    AND folio_suc = cFolio
                    AND referencia1 = cReferencia1
                    AND status_cancelado <> 'S'
                    AND flag_confirmacion_sucursal = 0;             
            END IF;
        END IF;
	END FOREACH;			
			
/*
	Conteo de registros BTS-SAC del día T-1:
*/
			set isolation to dirty read;
			select {+INDEX(bdisac:sac_movimientoshistorial idxsac_movhisfe)}
			count (*) into itot_movssac		
			from bdisac:sac_movimientoshistorial 
			where 
			numcategoria = '07' and numconvenio = '004'
			and fecha_pago = dfechamovs;

/*
	Conteo de registros BTS-Cheques del día T-1:
*/		
			set isolation to dirty read;
			select {+INDEX(bdicheq:sc_movhis idxsac_movhisfe)}
			count (*) into itot_movschqs
			from bdicheq:sc_movhis
			where 
			empresa = vempresa and 
			fech_alt = dfechamovs
			and cuenta = ccuenta_bts
			and transacc in (ctrns_ctrl_efecte, ctrns_ctrl_crgocte);

/*
	Conteo de registros BTS-Payi del día T-1:
*/			
			set isolation to dirty read;
			select {+INDEX(bdisac:sac_bts_payi idx_sac_bts_payi3)}
			count (*) into imovsbts_payi
			from "informix".sac_bts_payi
			where 
-- 2014.02.11 FRG-i
			--	fecha_insert::DATE = dfechamovs
			agent_dt = cbts_dt
-- 2014.02.11 FRG-f
			and opcode = '1100';

/*
	Conteo de registros BTS-Payc del día T-1:
*/			
			set isolation to dirty read;
			select {+INDEX(bdisac:sac_bts_payc idx_sac_bts_payc)}
			count (*) into imovsbts_payc
			from "informix".sac_bts_payc
			where 
-- 2014.02.11 FRG-i
			--fecha_insert::DATE = dfechamovs
			agent_dt = cbts_dt
-- 2014.02.11 FRG-f
			and opcode = '1100';
			
			LET itot_movsbts = imovsbts_payi + imovsbts_payc;
			
/*
	Proceso de Inserción de registros del día T-1 en tablas _paso:
*/
			set isolation to dirty read;
			INSERT INTO bdisac:"informix".sac_cheques_paso
				SELECT {+INDEX(bdicheq:sc_movhis idxsac_movhisfe)}
				folio_suc, fech_alt
				FROM bdicheq:"informix".sc_movhis
				WHERE cuenta = ccuenta_bts
				AND fech_alt = dfechamovs 
				AND transacc in (ctrns_ctrl_efecte, ctrns_ctrl_crgocte)
				and cancelad <> 'S';
				
			set isolation to dirty read;
			INSERT INTO bdisac:"informix".sac_chequesrev_paso
				SELECT {+INDEX(bdicheq:sc_movhis idxsac_movhisfe)}
				folio_suc, fech_alt
				FROM bdicheq:"informix".sc_movhis
				WHERE cuenta = ccuenta_bts
				AND fech_alt = dfechamovs 
				AND transacc in (ctrns_ctrl_efecte, ctrns_ctrl_crgocte)
				and cancelad = 'S'
				and referencia = 'REV';
			
			LET cflg_chqs = "1";
			
			INSERT INTO bdisac:"informix".sac_servicios_paso
				SELECT {+INDEX(bdisac:sac_movimientoshistorial idxsac_movhisfe)}
				folio_suc, referencia1, status_cancelado, flag_confirmacion_sucursal, fecha_pago, fecha_insert
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria= '07'  
				AND numconvenio='004'
				AND fecha_pago= dfechamovs;
				
			INSERT INTO bdisac:"informix".sac_serviciosrev_paso
				SELECT {+INDEX(bdisac:sac_movimientoshistorial idxsac_movhisfe)}
				folio_suc, referencia1, status_cancelado, fecha_pago
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria= '07'  
				AND numconvenio='004'
				AND fecha_pago= dfechamovs
				AND status_cancelado = 'S';
			
			LET cflg_sac = "1";
			
			INSERT INTO bdisac:"informix".sac_abono_paso
				SELECT {+INDEX(bdisac:sac_bts_payc idx_sac_bts_payc)}
				confirmation_nm, bank_ref_nm, 
--	2014.02.12 -i
				SUBSTR (agent_dt, 5, 2)||SUBSTR (agent_dt, 7, 2)||SUBSTR (agent_dt, 1, 4)
--	2014.02.12 -f
				FROM bdisac:"informix".sac_bts_payc
				WHERE 
-- 2014.02.11 FRG-i
				--	fecha_insert::DATE = dfechamovs
				agent_dt = cbts_dt
-- 2014.02.11 FRG-f
				and opcode = '1100'
				and process_type_code = 'PAYC';
			
			LET cflg_btsab = "1";
			
			INSERT INTO bdisac:"informix".sac_btscaja_paso
-- 2014.02.11 FRG-i
				--	SELECT confirmation_nm, bank_ref_nm, fecha_insert
				SELECT confirmation_nm, bank_ref_nm, --agent_dt::date
--	2014.02.12 -i
				SUBSTR (agent_dt, 5, 2)||SUBSTR (agent_dt, 7, 2)||SUBSTR (agent_dt, 1, 4)
--	2014.02.12 -f
				FROM bdisac:"informix".sac_bts_payi
				WHERE 
-- 2014.02.11 FRG-i
				--	fecha_insert::DATE = dfechamovs
				agent_dt = cbts_dt
-- 2014.02.11 FRG-f
				and opcode = '1100';
			
			LET cflg_btscj = "1";
			
			INSERT INTO bdisac:"informix".sac_btsrevi_paso
				SELECT confirmation_nm, bank_ref_nm, --fecha_insert
--	2014.02.12 -i
				SUBSTR (agent_dt, 5, 2)||SUBSTR (agent_dt, 7, 2)||SUBSTR (agent_dt, 1, 4)
--	2014.02.12 -f
				FROM bdisac:"informix".sac_bts_revi
				WHERE 
-- 2014.02.11 FRG-i
				--	fecha_insert::DATE = dfechamovs
				agent_dt = cbts_dt
-- 2014.02.11 FRG-f
				and opcode = '1200';
			
			LET cflg_btsrev = "1";
			
			if	cflg_chqs = "1" and cflg_sac = "1" and cflg_btsab = "1" and cflg_btscj = "1" and cflg_btsrev = "1"
				then
					LET cinfoerr = 'Inserción en tablas _paso exitoso.';
					update bdisac:sac_procesos set status = '1' where proceso = cproceso and fecha_proceso::date = dfechamovs;
					--ACTUALIZA STATUS EN BITACORA
					EXECUTE PROCEDURE "informix".sp_bitacoraspj (1, 'IND_BTS_MP', dfechamovs, '1', 'informix', 'sac_bts_movspaso', cDescripcionSPJ);
					RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
				else
					LET ccodret = "00002";
					LET cinfoerr = 'Error en proceso inserción en tablas _paso. Validar Tabla sac_MensajeError.';
					RETURN ccodret, cinfoerr, cflg_sac, cflg_chqs, cflg_btscj, cflg_btsab, cflg_btsrev, itot_movssac, itot_movschqs, itot_movsbts;
			end if;
		end if;
	end if;
	END;	
END PROCEDURE;