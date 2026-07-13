CREATE PROCEDURE "informix".sp_obtienecomisiones(pConvenio CHAR(40))
	RETURNING CHAR(5),CHAR(5),MONEY(16,2),MONEY(16,2),MONEY(16,2),MONEY(16,2),CHAR(1);

---- VARIABLES  GENERALES---
DEFINE cSqlerr			INTEGER;
DEFINE cCodret      	CHAR(5);
DEFINE vsSQL    		CHAR(100);
DEFINE cConvenio        CHAR(40);
DEFINE pId_convenio		CHAR(5);
DEFINE cNumCategoria	CHAR(2);
DEFINE cNumConvenio	CHAR(3);
DEFINE cId_Convenio CHAR(5);
DEFINE mValorMinimoComision MONEY(16,2);
DEFINE mMontoMinimo MONEY(16,2);
DEFINE mMontoMaximo MONEY(16,2);
DEFINE mComision MONEY(16,2);
DEFINE cTipo CHAR(1);

--VALORES INICIALES
LET cSqlerr = '';
LET cCodret = '00000';
LET vsSQL    = '';
LET cConvenio 	=	'';
LET pId_convenio = '';
LET cNumCategoria	=	'';
LET cNumConvenio	=	'';
LET cId_Convenio =	'';
LET mValorMinimoComision =	0.00;
LET mMontoMinimo =	0.00;
LET mMontoMaximo =	0.00;
LET mComision =	0.00;
LET cTipo =	'';

--SET debug FILE TO "/tmp/sp_ObtieneComisiones.out";
--Trace ON;

Begin
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
			RETURN NVL(cCodret,''),NVL(cId_Convenio,''),NVL(mValorMinimoComision,''),NVL(mMontoMinimo,''),NVL(mMontoMaximo,''),NVL(mComision,''),NVL(cTipo,'');
        END IF;
	END EXCEPTION;

	--DEL  CONVENIO QUE SE RECIBE SE OBTIENE LA CATEGORIA Y EL NUMERO DE CONVENIO
	SELECT {+INDEX (bdisac:sac_convenios idxsac_conv3)} numcategoria,numconvenio INTO cNumCategoria,cNumConvenio FROM bdisac:sac_convenios WHERE nomconvenio = TRIM(pConvenio);
	LET pId_convenio = TRIM(cNumCategoria || cNumConvenio );
	--SE PUEDE VALIDAR SI NO REGRESA NADA ESE SELECT	
	FOREACH WITH HOLD 	
		SELECT {+INDEX (bdisac:sac_comisiones idxid_cov)} id_convenio,valorminimocomision,montominimo,montomaximo,comision,tipo
		INTO cId_Convenio, mValorMinimoComision, mMontoMinimo, mMontoMaximo, mComision, cTipo
		FROM bdisac:sac_comisiones
		WHERE id_convenio  = pId_convenio
		
		RETURN NVL(cCodret,''),NVL(cId_Convenio,''),NVL(mValorMinimoComision,''),NVL(mMontoMinimo,''),NVL(mMontoMaximo,''),NVL(mComision,''),NVL(cTipo,'') WITH RESUME;
	END FOREACH;	
END
END PROCEDURE
DOCUMENT
'AUTOR :César Valdéz Figueroa',
'DESCRIPCION:  Este Procedimiento Obtiene las comisiones parametrizadas filtrado por convenio y categoria.',
'FECHA : Octubre de 2009',
'BD    : BDISAC',
'VERSION: 20091022.0630';

CREATE PROCEDURE "informix".sp_sacreportemensualdish(cPeriodo CHAR(6))
RETURNING
	CHAR (6) AS retorno,
	CHAR(6) AS aniomes,
	DATE AS fecha,
	INTEGER AS num_operaciones,
	MONEY (16,2) AS comision,
	MONEY (16,2) AS iva;
    
DEFINE cCodRet					CHAR (6);
DEFINE cAnioMes					CHAR(6);
DEFINE dFecha					DATE ;
DEFINE iNumOperaciones			INTEGER;
DEFINE mComision				MONEY(16,2);
DEFINE mIva						MONEY(16,2);
DEFINE iSqlErr					INTEGER;
DEFINE iIsamErr					INTEGER;
DEFINE cInfoErr                 CHAR(100);

LET cCodRet				= '000000';
LET cAnioMes			= '';
LET dFecha				= '01-01-1900';
LET iNumOperaciones		= 0;
LET mComision			= 0;
LET mIva				= 0;
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cInfoErr			= '';

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualdish");
				RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;

	END EXCEPTION;

-- SET DEBUG FILE TO  '/tmp/sp_sacreportemensualdish.out';
-- TRACE ON;

	IF  cPeriodo = "" OR LENGTH(cPeriodo) <> 6 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
	ELSE   
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX (bdisac:sac_liquidacionmensualdish idx_sacliqmesdish)} aniomes, fecha, num_operaciones, comision, iva
			INTO cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			FROM bdisac : sac_liquidacionmensualdish
			WHERE aniomes = cPeriodo
			ORDER BY fecha
			
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramírez',
'DESCRIPCION: Obtiene la informacion para la generacion del reporte mensual dish',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Septiembre 2010',
'VERSION: 20100902.1709',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportemensualmastv(cPeriodo CHAR(6))
RETURNING
	CHAR (6) AS retorno,
	CHAR(6) AS aniomes,
	DATE AS fecha,
	INTEGER AS num_operaciones,
	MONEY (16,2) AS comision,
	MONEY (16,2) AS iva;
    
DEFINE cCodRet					CHAR (6);
DEFINE cAnioMes					CHAR(6);
DEFINE dFecha					DATE ;
DEFINE iNumOperaciones			INTEGER;
DEFINE mComision				MONEY(16,2);
DEFINE mIva						MONEY(16,2);
DEFINE iSqlErr					INTEGER;
DEFINE iIsamErr					INTEGER;
DEFINE cInfoErr                 CHAR(100);

LET cCodRet				= '000000';
LET cAnioMes			= '';
LET dFecha				= '01-01-1900';
LET iNumOperaciones		= 0;
LET mComision			= 0;
LET mIva				= 0;
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cInfoErr			= '';

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualmastv");
				RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;

	END EXCEPTION;

-- SET DEBUG FILE TO  '/tmp/sp_sacreportemensualmastv.out';
-- TRACE ON;

	IF  cPeriodo = "" OR LENGTH(cPeriodo) <> 6 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
	ELSE   
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT {+INDEX (bdisac:sac_liquidacionmensualmastv idx_sacliqmesmastv)} aniomes, fecha, num_operaciones, comision, iva
			INTO cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			FROM bdisac : sac_liquidacionmensualmastv
			WHERE aniomes = cPeriodo
			ORDER BY fecha
			
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Dulce Ramírez',
'DESCRIPCION: Obtiene la informacion para la generacion del reporte mensual mastv',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Septiembre 2010',
'VERSION: 20100902.1712',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportemensualsky(cPeriodo CHAR(6))
RETURNING
	CHAR (6) AS retorno,
	CHAR(6) AS aniomes,
	DATE AS fecha,
	INTEGER AS num_operaciones,
	MONEY (16,2) AS comision,
	MONEY (16,2) AS iva;
    
DEFINE cCodRet					CHAR (6);
DEFINE cAnioMes					CHAR(6);
DEFINE dFecha					DATE ;
DEFINE iNumOperaciones			INTEGER;
DEFINE mComision				MONEY(16,2);
DEFINE mIva						MONEY(16,2);
DEFINE iSqlErr					INTEGER;
DEFINE iIsamErr					INTEGER;
DEFINE cInfoErr                 CHAR(100);

LET cCodRet				= '000000';
LET cAnioMes			= '';
LET dFecha				= '01-01-1900';
LET iNumOperaciones		= 0;
LET mComision			= 0;
LET mIva				= 0;
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET cInfoErr			= '';

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

		IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				EXECUTE PROCEDURE sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportemensualsky");
				RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
		END IF;

	END EXCEPTION;

-- SET DEBUG FILE TO  '/tmp/sp_sacreportemensualsky.out';
-- TRACE ON;

	IF  cPeriodo = "" OR LENGTH(cPeriodo) <> 6 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva;
	ELSE   
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT aniomes, fecha, num_operaciones, comision, iva
			INTO cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			FROM bdisac : sac_liquidacionmensualsky
			WHERE aniomes = cPeriodo
			ORDER BY fecha
			
			RETURN cCodRet, cAnioMes, dFecha, iNumOperaciones, mComision, mIva
			WITH RESUME;
		END FOREACH;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: Obtiene la informacion para la generacion del reporte mensual sky',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Mayo 2010',
'VERSION: 20100524.1757',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_sacreportesemanalsky(Consecutivo INTEGER)
	RETURNING
		CHAR (6) AS retorno,
        INTEGER AS rec_lunes , 
        INTEGER AS rec_martes, 
        INTEGER AS rec_miercoles, 
        INTEGER AS rec_jueves, 
        INTEGER AS rec_viernes, 
        INTEGER AS rec_sabado, 
        INTEGER AS rec_domingo, 
        MONEY(16,2) AS cob_lunes, 
        MONEY(16,2) AS cob_martes, 
        MONEY(16,2) AS cob_miercoles, 
        MONEY(16,2) AS cob_jueves, 
        MONEY(16,2) AS cob_viernes, 
        MONEY(16,2) AS cob_sabado, 
        MONEY(16,2) AS cob_domingo, 
        INTEGER AS rec_efectivo, 
        INTEGER AS rec_chequemb, 
        INTEGER AS rec_chequeob, 
        INTEGER AS rec_tarcred, 
        MONEY(16,2) AS cob_efectivo, 
        MONEY(16,2) AS cob_cheqmb, 
        MONEY(16,2) AS cob_cheqob, 
        MONEY(16,2) AS cob_tarcred, 
        MONEY(16,2) AS liq_miercoles, 
        MONEY(16,2) AS liq_jueves, 
        MONEY(16,2) AS liq_viernes,
        MONEY(16,2) AS liq_lunes, 
        MONEY(16,2) AS liq_martes, 
        MONEY(16,2) AS aclaraciones, 
        MONEY(16,2) AS comision, 
        MONEY(16,2) AS iva_comision, 
        DATE AS fec_iniperiodo, 
        DATE AS fec_finperiodo, 
        INTEGER AS keyx;
     
		DEFINE cCodRet			CHAR (6);
        DEFINE iRecLunes		INTEGER; 
        DEFINE iRecMartes		INTEGER;
        DEFINE iRecMiercoles	INTEGER;
        DEFINE iRecJueves		INTEGER;
        DEFINE iRecViernes		INTEGER;
        DEFINE iRecSabado		INTEGER;
        DEFINE iRecDomingo		INTEGER;
        DEFINE mCobLunes		MONEY(16,2);
        DEFINE mCobMartes		MONEY(16,2); 
        DEFINE mCobMiercoles	MONEY(16,2);
        DEFINE mCobJueves		MONEY(16,2);
        DEFINE mCobViernes		MONEY(16,2);
        DEFINE mCobSabado		MONEY(16,2);
        DEFINE mCobDomingo		MONEY(16,2);
        DEFINE iRecEfectivo		INTEGER;
        DEFINE iRecChequemb		INTEGER;
        DEFINE iRecChequeob		INTEGER;
        DEFINE iRecTarcred		INTEGER;
        DEFINE mCobEfectivo		INTEGER;
        DEFINE mCobCheqmb		MONEY(16,2);
        DEFINE mCobCheqob		MONEY(16,2);
        DEFINE mCobTarcred		MONEY(16,2);
        DEFINE mLiqMiercoles	MONEY(16,2);
        DEFINE mLiqJueves		MONEY(16,2);
        DEFINE mLiqViernes		MONEY(16,2);
        DEFINE mLiqLunes		MONEY(16,2);
        DEFINE mLiqMartes		MONEY(16,2);
        DEFINE mAclaraciones	MONEY(16,2);
        DEFINE mComision		MONEY(16,2);
        DEFINE mIvaComision		MONEY(16,2);
        DEFINE dFecIniPeriodo	DATE;
        DEFINE dFecFinPeriodo	DATE;
        DEFINE iConsecutivo		INTEGER;
		DEFINE iSqlErr			INTEGER;
		DEFINE iIsamErr			INTEGER;
		DEFINE cInfoErr         CHAR(100);

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
        LET mCobEfectivo	= 0;
        LET mCobCheqmb		= 0;
        LET mCobCheqob		= 0;
        LET mCobTarcred		= 0;
        LET mLiqMiercoles	= 0;
        LET mLiqJueves		= 0;
        LET mLiqViernes		= 0;
        LET mLiqLunes		= 0;
        LET mLiqMartes		= 0;
        LET mAclaraciones	= 0;
        LET mComision		= 0;
        LET mIvaComision	= 0;
        LET dFecIniPeriodo	= '01-01-1900';
        LET dFecFinPeriodo	= '01-01-1900';
        LET iConsecutivo	= 0;
		LET iSqlErr			= 0;
		LET iIsamErr		= 0;
		LET cInfoErr		= '';

		BEGIN
			ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr

				IF iSqlErr <> 0 THEN
						LET cCodRet = iSqlErr;
						EXECUTE PROCEDURE sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_sacreportesemanalsky");
						RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
							mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
							mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
							mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo;
				END IF;

			END EXCEPTION;

	-- SET DEBUG FILE TO  '/tmp/sp_sacreportesemanalsky.out';
	-- TRACE ON;

			IF  Consecutivo IS NULL THEN
				LET cCodRet = "00001";
				RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
					mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
					mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
					mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo;
			ELSE   
				SET ISOLATION TO DIRTY READ;
					FOREACH
						SELECT rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, cob_martes, 
							cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, 
							cob_efectivo, cob_cheqmb, cob_cheqob, cob_tarcred, liq_miercoles, liq_jueves, liq_viernes, liq_lunes, liq_martes, 
							aclaraciones, comision, iva_comision, fec_iniperiodo, fec_finperiodo, keyx 
						INTO iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
							mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
							mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
							mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo 
						FROM bdisac : sac_liquidacionsemanalsky
						WHERE keyx  = Consecutivo
						
						
						RETURN cCodRet, iRecLunes, iRecMartes, iRecMiercoles, iRecJueves, iRecViernes, iRecSabado, iRecDomingo, mCobLunes, mCobMartes, 
							mCobMiercoles, mCobJueves, mCobViernes, mCobSabado, mCobDomingo, iRecEfectivo, iRecChequemb, iRecChequeob, iRecTarcred, mCobEfectivo, 
							mCobCheqmb, mCobCheqob, mCobTarcred, mLiqMiercoles, mLiqJueves, mLiqViernes, mLiqLunes, mLiqMartes, mAclaraciones, mComision, 
							mIvaComision, dFecIniPeriodo, dFecFinPeriodo, iConsecutivo
						WITH RESUME;
					END FOREACH;
			END IF;
		END;
	END PROCEDURE
	DOCUMENT
	'AUTOR : Raul Ruiz',
	'DESCRIPCION: Consulta la informacion para la generacion del reporte de liquidacion semanal de pagos sky',
	'EJECUTADO O LLAMADO POR: repsac.exe',
	'FECHA : Mayo 2010',
	'VERSION: 20100524.1755',
	'BD    : bdisac';

CREATE PROCEDURE "informix".sp_repservicios_totales (dFechaI char(10), dFechaF char(10))
    RETURNING CHAR(5),CHAR(50),INTEGER,MONEY(16,2),MONEY(16,2),MONEY(16,2),MONEY(16,2),MONEY(16,2),MONEY(16,2);
    -- Definicion de Variables
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INT;
    DEFINE cNomConvenio CHAR(50);
    DEFINE iNumPagos    INTEGER;
    DEFINE mImportePago  MONEY(16,2);
    DEFINE mIVAComisionConvenio MONEY(16,2);
    DEFINE mImpComisionCte     MONEY(16,2);
    DEFINE mImpComisionConvenio   MONEY(16,2);
    DEFINE mIVAComisionCte   MONEY(16,2);
    DEFINE cNumcategoria CHAR(5);
    DEFINE cNumconvenio CHAR(5);
    DEFINE Importe_total   MONEY(16,2);
    -- Inicializa variables
    LET cCodRet = "00000";
    LET iSql_err = 0;
    LET cNomConvenio = "";
    LET iNumPagos = 0;
    LET mImportePago = 0;
    LET mIVAComisionConvenio = 0;
    LET mImpComisionCte = 0;
    LET mImpComisionConvenio = 0;
    LET mIVAComisionCte = 0;
    LET Importe_total = 0;
    LET cNumcategoria = "";
    LET cNumconvenio = "";

     --SET DEBUG FILE TO "/home/informix/VHSM/sp_repservicios_totales.out";
     --TRACE ON;

    BEGIN
        ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet, cNomConvenio,iNumPagos, mImportePago, mImpComisionConvenio,mIVAComisionConvenio, mImpComisionCte,mIVAComisionCte,Importe_total;
            END IF;
        END EXCEPTION;

FOREACH
      SELECT {+INDEX (bdisac:sac_convenios 103_9)} TRIM(NVL(nomconvenio,'')), TRIM(NVL(numcategoria,'')), TRIM(NVL(numconvenio,''))
      INTO cNomConvenio, cNumcategoria, cNumconvenio
      FROM bdisac:sac_convenios
      where statusconvenio='A'
 
      SET ISOLATION TO DIRTY READ;
      SELECT count(*),nvl(sum(importe_pago),0),nvl(sum(importe_comision_convenio),0),nvl(sum(iva_comision_convenio),0),
      nvl(sum(importe_comision_cte),0)  ,nvl(sum(iva_comision_cte),0)
      INTO iNumPagos, mImportePago, mImpComisionConvenio,mIVAComisionConvenio, mImpComisionCte,mIVAComisionCte
      FROM bdisac:sac_movimientoshistorial
      WHERE fecha_pago::DATE >= dFechaI AND fecha_pago::DATE  <= dFechaF AND numcategoria = cNumcategoria AND
      numconvenio = cNumConvenio AND status_cancelado <> 'S'
      AND flag_confirmacion_central = 1
      AND flag_confirmacion_sucursal = 1;

      let Importe_total=mImportePago-mImpComisionConvenio-mIVAComisionConvenio-mImpComisionCte-mIVAComisionCte;

      RETURN cCodRet, cNomConvenio,iNumPagos, mImportePago, mImpComisionConvenio,mIVAComisionConvenio, mImpComisionCte,mIVAComisionCte,Importe_total WITH RESUME;

END FOREACH;

END;
END PROCEDURE;