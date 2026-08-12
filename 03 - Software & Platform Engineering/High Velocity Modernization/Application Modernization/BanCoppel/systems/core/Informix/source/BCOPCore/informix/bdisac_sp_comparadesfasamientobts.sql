CREATE PROCEDURE "informix".sp_comparadesfasamientobts(pNombreBan CHAR(40), pNombreBTS CHAR(40))

    --DATOS A REGRESAR---
    RETURNING
    CHAR(5),   -- Codigo de Retorno
    CHAR(2); -- Porcentaje

    --DEFINICION DE VARIABLES--
    DEFINE sql_err      INT;
    DEFINE cCodRet      CHAR(5);
	DEFINE i            INTEGER;
	DEFINE iContador    INTEGER;
	DEFINE iCoicidencia INTEGER;
	DEFINE cCarBan      CHAR(1);
	DEFINE cCarBTS      CHAR(1);
    
        --INICIALIZACION DE VARIABLES--
    LET sql_err = 0;
    LET cCodRet =   '00000';
    LET i = 0;
	LET iContador = 1;
	LET iCoicidencia = 0;
	LET cCarBan = '';
	LET cCarBTS = '';
	
    --SET DEBUG FILE TO "/respaldosbd/Pedro/1536/sp_ComparaDesfasamientoBTS.out";
    --TRACE ON;

BEGIN
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN cCodRet, iCoicidencia;
        END IF;
    END EXCEPTION;
	
	--VALIDAR PRIMER NOMBRE CARACTER POR CARACTER
	LET pNombreBan= UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pNombreBan, 'Á', 'A'), 'É','E'), 'Í', 'I'), 'Ó', 'O'),'Ú','U'),'á', 'A'), 'é','E'), 'í', 'I'), 'ó', 'O'),'ú','U'),' ',''));
	
	LET pNombreBTS= UPPER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pNombreBTS, 'Á', 'A'), 'É','E'), 'Í', 'I'), 'Ó', 'O'),'Ú','U'),'á', 'A'), 'é','E'), 'í', 'I'), 'ó', 'O'),'ú','U'),' ',''));

	 FOR i = 1 TO LENGTH(pNombreBan)
	 
		LET cCarBan = SUBSTR(pNombreBan, i,1);
		LET cCarBTS = SUBSTR(pNombreBTS,iContador,1);
	
		IF cCarBan = cCarBTS THEN
			LET iCoicidencia = iCoicidencia + 1;
			LET iContador =  iContador + 1;
		ELSE
			LET cCarBTS = SUBSTR(pNombreBTS,iContador + 1, 1);
			
			IF cCarBan = cCarBTS THEN
			    LET iCoicidencia = iCoicidencia + 1;
				LET iContador = iContador + 2;
			ELSE 	
				LET iContador = iContador + 1;
     		END IF;
		END IF;
	END FOR
	
    RETURN cCodRet, iCoicidencia;
END
END PROCEDURE
DOCUMENT
'Compara el nombre capturado en Bancoppel contra el que envía BTS con desfasamiento en BTS',
'para obtener el número de coincidencias',
'AUTOR : Dulce Ramirez',
'FECHA : 25/Noviembre/2010',
'Ver.  : 1.1',
'BD    : bdisac',
'VER   : 1.1',
'AUTOR: 95689966, Pedro Jimenez Guzman',
'FOLIO: 1536-ElimEspBlanBTSWU',
'DESCRIPCION: Se elimina los espacios a la hora de comparar los nombres caracter por caracter ',
'FECHA: 10-02-2016 ',
'SUSTENTO: Se define con Jaime González en el requerimiento',
'RQM 62 298 ELIMINACION DE ESPACIOS EN BLANCO EN LA VALIDACION DE NOMBRES DE BTS Y WU',
'BD: BDISAC';

CREATE PROCEDURE  "informix".sp_calculadvsky(pNumReferencia CHAR(12))
RETURNING 
	CHAR (5) AS CodigoRetorno,
	SMALLINT AS IerrcomCodigo,
	SMALLINT AS IerrcomSistema;
	
--DEFINICION DE LAS VARIABLES


DEFINE iSqlerr			INTEGER;
DEFINE sI				SMALLINT;
DEFINE sNoPeso			SMALLINT;
DEFINE sSuma			SMALLINT;
DEFINE sValorDigito		SMALLINT;
DEFINE sAux				SMALLINT;
DEFINE cCodRet			CHAR(5);
DEFINE sFlagLetra		SMALLINT; 
DEFINE cNum1			CHAR(2);
DEFINE cNum2			CHAR(2);
DEFINE sDigVerCapturado SMALLINT;
DEFINE sDigVerCalculado SMALLINT;
DEFINE sIerrcomCodigo   SMALLINT;
DEFINE sIerrcomSistema  SMALLINT;


--INICIALIZACION DE LAS VARIABLES
LET iSqlerr 			= 0;
LET sI 					= 0;
LET sNoPeso 			= 0;
LET sSuma 				= 0;
LET sValorDigito 		= 0;
LET sAux 				= 0;
LET cCodRet 			= '00004';
LET sFlagLetra 			= 0;
LET cNum1 				= '';	
LET cNum2 				= '';
LET sDigVerCalculado 	= 0;
LET sDigVerCapturado 	= 0;
LET sIerrcomCodigo  	= 0;
LET sIerrcomSistema 	= 0;

		
BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet, sIerrcomCodigo, sIerrcomSistema;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/antoniocebreros/1483/migrado/sp_calculadvsky.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF LENGTH(TRIM(pNumReferencia))= 12 THEN	

		LET sDigVerCapturado = SUBSTR(pNumReferencia,12,1)::SMALLINT;
          
	    FOR sI = 1 TO 11
	   --FOR i IN 1..11 LOOP
	       IF MOD(sI,2)= 0 THEN
	          LET sNoPeso = 1;
	       ELSE
			  LET sNoPeso = 2;
	       END IF;
		  

                IF (ASCII(UPPER (SUBSTR(pNumReferencia,sI,1)) ) > 64 AND ASCII(UPPER (SUBSTR(pNumReferencia,sI,1)) ) < 91) OR ASCII(SUBSTR(pNumReferencia,sI,1) ) = 241 OR ASCII(SUBSTR(pNumReferencia,sI,1) ) = 209 THEN
					
					IF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'A' THEN
						LET sValorDigito = 1;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'B' THEN
						LET sValorDigito = 2;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'C' THEN
						LET sValorDigito = 3;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'D' THEN
						LET sValorDigito = 4;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'E' THEN
						LET sValorDigito = 5;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'F' THEN
						LET sValorDigito = 6;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'H' THEN
						LET sValorDigito = 7;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'I' THEN
						LET sValorDigito = 8;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'J' THEN
						LET sValorDigito = 9;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'K' THEN
						LET sValorDigito = 1;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'L' THEN
						LET sValorDigito = 2;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'M' THEN
						LET sValorDigito = 3;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'N' THEN
						LET sValorDigito = 4;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'O' THEN
						LET sValorDigito = 5;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'P' THEN
						LET sValorDigito = 6;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'Q' THEN
						LET sValorDigito = 7;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'R' THEN
						LET sValorDigito = 8;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'S' THEN
						LET sValorDigito = 9;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'T' THEN
						LET sValorDigito = 1;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'U' THEN
						LET sValorDigito = 2;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'V' THEN
						LET sValorDigito = 3;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'W' THEN
						LET sValorDigito = 4;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'X' THEN
						LET sValorDigito = 5;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'Y' THEN

						LET sValorDigito = 6;

					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'Z' THEN
						LET sValorDigito = 7;
					ELSE 
						LET sValorDigito = 1;
					END IF;
					
					
                  
                  IF sValorDigito IS NULL THEN
                    LET sFlagLetra = 1;
                    EXIT;
                  END IF;
                ELIF ASCII(SUBSTR(pNumReferencia,sI,1)) > 47 AND ASCII(SUBSTR(pNumReferencia,sI,1)) < 58 THEN
                   LET sValorDigito = SUBSTR(pNumReferencia,sI,1)::SMALLINT;
                END IF;

			LET sAux = sValorDigito * sNoPeso;
               
	       IF sAux > 9 THEN
	          --raise notice ''Multiplicacion Mayor a 9 = %'', sAux ;
	          LET cNum1 = SUBSTR(sAux::CHAR(2),1,1) ;
	          LET cNum2 = SUBSTR(sAux::CHAR(2),2,1) ;
	          LET sAux = cNum1::SMALLINT + cNum2::SMALLINT;
	       END IF; 

           --LET cReferenciaSky[sI] = sAux::CHAR;
	       LET sSuma = sSuma + sAux;
	       --raise notice ''Valor #%'', i || ''='' || cReferenciaSky[i] ; 
		END FOR;
	   --END LOOP;

           --raise notice ''Suma =%'', sSuma; 
        IF sFlagLetra = 0 THEN
			  IF SUBSTR(sSuma::CHAR(10),2,1)=1 THEN
				 LET sDigVerCalculado = 9;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=2 THEN
				  LET sDigVerCalculado = 8;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=3 THEN
				  LET sDigVerCalculado = 7;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=4 THEN
				  LET sDigVerCalculado = 6;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=5 THEN
				  LET sDigVerCalculado = 5;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=6 THEN
				  LET sDigVerCalculado = 4;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=7 THEN
				  LET sDigVerCalculado = 3;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=8 THEN
				  LET sDigVerCalculado = 2;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=9 THEN
				  LET sDigVerCalculado = 1;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=0 THEN
				  LET sDigVerCalculado = 0;
			  END IF; 

			  IF sDigVerCapturado = sDigVerCalculado THEN
				 LET cCodRet = '00000';  
			  ELSE
				 LET cCodRet = '00001';
				 LET sIerrcomCodigo = 91;
				 LET sIerrcomSistema = 24;
			  END IF; 

        ELIF sFlagLetra = 1 THEN
              LET  cCodRet = '00003'; --ESCENARIO: LA REFERENCIA DE CAPTURA NO ES VALIDA.
			  LET sIerrcomCodigo = 94;
			  LET sIerrcomSistema = 24;
        END IF;
    ELSE
            --raise notice ''Referencia no es de 12 digitos''; 
			--ESCENARIO: LONGITUD DE REFERENCIA INCORRECTA.
            LET cCodRet = '00002';
			LET sIerrcomCodigo = 47;
			LET sIerrcomSistema = 24;
    END IF;
	--END IF;
	
	--IF cCodRet = '00004' THEN
	--	LET cCodRet = '00000';
	--END IF;
	
    RETURN cCodRet, sIerrcomCodigo, sIerrcomSistema;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se convierte una funcion de sucursal a una rutina de central, atendiendo el folio 1483-MttoValRefPagServAVON, (procedimiento en central para validar el digito verificador para pago de servicios SKY)',
'MODIFICO: Antonio Cebreros Perez',
'FECHA: 24/02/2015',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_sacreportedetalletransaccionsucursal_soc (cConvenio CHAR (5), cSucursal CHAR(4), dFechaIni DATE, dFechaFin DATE, pEjecutivo CHAR(8))
-- DATOS A REGRESAR
RETURNING
CHAR(5)  AS retorno, --Codigo de Retorno
CHAR(8) AS usuario,
CHAR(16) AS folio_suc,
CHAR(40) AS nomconvenio,
CHAR(20) AS referencia1,
CHAR(20) AS referencia2,
MONEY(16,2) AS importe_pago,
MONEY(16,2) AS importe_comision_convenio,
MONEY(16,2) AS iva_comision_convenio,
MONEY(16,2) AS importe_comision_cte,
MONEY(16,2) AS iva_comision_cte,
CHAR(1) AS forma_pago,
CHAR(12) AS cuenta_cargo,
CHAR(40) AS region;


-- DEFINICION DE VARIABLES
DEFINE cCodRet                  CHAR(5);
DEFINE iSqlErr                  INTEGER;
DEFINE cUsuario                 CHAR(8);
DEFINE cFolioSuc                CHAR(16);
DEFINE cNumcategoria            CHAR(2);
DEFINE cNumconvenio             CHAR(3);
DEFINE cNomconvenio             CHAR(40);
DEFINE cReferencia1             CHAR(20);
DEFINE cReferencia2             CHAR(20);
DEFINE mImpComisionConvenio    MONEY(16,2);
DEFINE mIVAComisionConvenio    MONEY(16,2);
DEFINE mImpComisionCte         MONEY(16,2);
DEFINE mIVAComisionCte         MONEY(16,2);
DEFINE mImportePago            MONEY(16,2);
DEFINE cFormaPago               CHAR(1);
DEFINE cCuentaCargo             CHAR(12);
DEFINE cRegion                  CHAR(40);

--SET DEBUG FILE TO "/home/informix/exi.out";
--TRACE ON;


--INICIALIZACION DE VARIABLES--
LET cCodRet               = "00000";
LET cUsuario              = "";
LET cFolioSuc             = "";
LET cNumcategoria         = SUBSTRING(cConvenio FROM 1 FOR 2);
LET cNumconvenio          = SUBSTRING(cConvenio FROM 3 FOR 3);
LET cNomConvenio          = "";
LET cReferencia1          = "";
LET cReferencia2          = "";
LET mImportePago         = 0;
LET mImpComisionConvenio = 0;
LET mIVAComisionConvenio = 0;
LET mImpComisionCte      = 0;
LET mIVAComisionCte      = 0;
LET cFormaPago            = "";
LET cCuentaCargo          = "";
LET cRegion               = "";

BEGIN

    ON EXCEPTION SET iSqlErr

        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
        END IF;

    END EXCEPTION;

    IF cConvenio = "" OR  cSucursal = "" OR LENGTH(cConvenio) <> 5 OR LENGTH(cSucursal) <> 4 THEN
        LET cCodRet = "00001";
        RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
    ELSE
        IF cConvenio = "00000" THEN   -- Todos los convenios y una sucursal
            INSERT INTO tmp_movs_soc
            SELECT b.usuario, b.folio_suc, TRIM(a.nomconvenio) AS nomconvenio, b.referencia1, b.referencia2, b.importe_pago, b.importe_comision_convenio, b.iva_comision_convenio,
            b.importe_comision_cte, b.iva_comision_cte, b.forma_pago, b.cuenta_cargo, e.nombre, pEjecutivo
            FROM bdisac:sac_convenios a, bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d, bdinteg:si_regional e
            WHERE b.fecha_pago::DATE  >= dFechaIni
            AND b.fecha_pago::DATE  <= dFechaFin
            AND a.numcategoria = b.numcategoria
            AND a.numconvenio = b.numconvenio
            AND b.id_sucursal = cSucursal
            AND b.status_cancelado <> 'S'
            AND flag_confirmacion_central = 1
            AND flag_confirmacion_sucursal = 1
            AND c.sucursal = b.id_sucursal
            AND d.plaza = c.plaza
            AND e.regional = d.regional;
            
            --ORDER BY 3, 2 ASC
            /*FOREACH
                SELECT usuario, folio_suc, nomconvenio, referencia1, referencia2, importe_pago, importe_comision_convenio, iva_comision_convenio,
                    importe_comision_cte, iva_comision_cte, forma_pago, cuenta_cargo, nombre
                INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                FROM bdisac:tmp_movs_soc ORDER BY folio_suc, nomconvenio

                RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                WITH RESUME;
            END FOREACH;*/
        ELSE   --Un convenio y una sucursal
            --FOREACH
                INSERT INTO tmp_movs_soc
                SELECT b.usuario, b.folio_suc, TRIM(a.nomconvenio) AS nomconvenio, b.referencia1, b.referencia2, b.importe_pago, b.importe_comision_convenio, b.iva_comision_convenio,
                b.importe_comision_cte, b.iva_comision_cte, b.forma_pago, b.cuenta_cargo, e.nombre, pEjecutivo
                FROM bdisac:sac_convenios a, bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d, bdinteg:si_regional e
                WHERE b.fecha_pago::DATE >= dFechaIni
                AND b.fecha_pago::DATE  <= dFechaFin
                AND b.numcategoria = cNumcategoria
                AND b.numconvenio = cNumconvenio
                AND a.numcategoria = b.numcategoria
                AND a.numconvenio = b.numconvenio
                AND b.id_sucursal = cSucursal
                AND b.status_cancelado <> 'S'
                AND flag_confirmacion_central = 1
                AND flag_confirmacion_sucursal = 1
                AND c.sucursal = b.id_sucursal
                AND d.plaza = c.plaza
                AND e.regional = d.regional;
        END IF;
    END IF;
RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion;
END;
END PROCEDURE
DOCUMENT
'AUTOR : Raul Ruiz',
'DESCRIPCION: se encarga de obtener la conciliacion por convenio y sucursales en un rango de fechas especificas',
'             de la tabla bdisac:sac_movimientoshistorial de Central',
'EJECUTADO O LLAMADO POR: repsac.exe',
'FECHA : Agosto de 2008',
'VERSION: 20080906',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_reportedetalletransucursalsac(pUsuario CHAR(8), pIdfuncion CHAR(10), pConvenio CHAR(5), pSucursal CHAR(4), pFechaIni DATE, 
pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codigoretorno, --Codigo de Retorno
	CHAR(8) AS usuario,
	CHAR(16) AS foliosuc,
	CHAR(40) AS nomconvenio,
	CHAR(20) AS referencia1,
	CHAR(20) AS referencia2,
	MONEY(16,2) AS importePago,
	MONEY(16,2) AS importeComisionConvenio,
	MONEY(16,2) AS ivaComisionConvenio,
	MONEY(16,2) AS importeComisionCte,
	MONEY(16,2) AS ivaComisionCte,
	CHAR(1) AS formaCago,
	CHAR(12) AS cuentaCargo,
	CHAR(40) AS region,
	CHAR(3) AS numconvenio,
	CHAR(2) AS numcategoria;

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cUsuario CHAR(16);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cNomConvenio CHAR(40);
	DEFINE cReferencia1 CHAR(20);
	DEFINE cReferencia2 CHAR(20);
	DEFINE mImportePago MONEY(16,2);
	DEFINE mImporteComisionConvenio MONEY(16,2);
	DEFINE mIvaComisionConvenio MONEY(16,2);
	DEFINE mImporteComisionCte MONEY(16,2);
	DEFINE mIivaComisionCte MONEY(16,2);
	DEFINE cFormaCago CHAR(1);
	DEFINE cCuentaCargo CHAR(12);
	DEFINE cRegion CHAR(40);				
	DEFINE iRegistros INTEGER;
	DEFINE iNoRegs  INTEGER;
	DEFINE iRecuperacion  INTEGER;
	DEFINE cNumConvenio CHAR(3);
	DEFINE cNumCategoria CHAR(2);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET cUsuario = '';
	LET cFolioSuc  = '';
	LET cNomConvenio  = '';
	LET cReferencia1  = '';
	LET cReferencia2  = '';
	LET mImportePago = 0;
	LET mImporteComisionConvenio = 0;
	LET mIvaComisionConvenio  = 0;
	LET mImporteComisionCte  = 0;
	LET mIivaComisionCte  = 0;
	LET cFormaCago = '';
	LET cCuentaCargo = '';
	LET cRegion = '';				
	LET iRegistros = 0;
	LET iNoRegs  = 0;
	LET iRecuperacion = 0;
	LET cNumConvenio = '';
	LET cNumCategoria = '';
			
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodret = iSqlErr;
			RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImporteComisionConvenio,
			mIvaComisionConvenio, mImporteComisionCte, mIivaComisionCte, cFormaCago, cCuentaCargo, cRegion, cNumConvenio, cNumCategoria;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_reportedetalletransucursalsac.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdfuncion = '' OR LENGTH(pConvenio) <> 5 OR LENGTH(pSucursal) <> 4 OR pFechaIni = '' OR pFechaFin = '' OR pRegistros = '' OR pRecuperacion = ''THEN
			LET cCodret = '00003';
			RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImporteComisionConvenio,
			mIvaComisionConvenio, mImporteComisionCte, mIivaComisionCte, cFormaCago, cCuentaCargo, cRegion, cNumConvenio, cNumCategoria;
		END IF;
		IF pRecuperacion < 0 THEN
			LET cCodret = '00098';
			RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImporteComisionConvenio,
			mIvaComisionConvenio, mImporteComisionCte, mIivaComisionCte, cFormaCago, cCuentaCargo, cRegion, cNumConvenio, cNumCategoria;
		END IF;


		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImporteComisionConvenio,
			mIvaComisionConvenio, mImporteComisionCte, mIivaComisionCte, cFormaCago, cCuentaCargo, cRegion, cNumConvenio, cNumCategoria;
		END IF;
		
		FOREACH 
			EXECUTE PROCEDURE bdisac:sp_sacreportedetalletransaccionsucursal(pConvenio, pSucursal, pFechaIni, pFechaFin) INTO
			cCodRetSp, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImporteComisionConvenio,
			mIvaComisionConvenio, mImporteComisionCte, mIivaComisionCte, cFormaCago, cCuentaCargo, cRegion
			IF cCodRetSp = '00000' THEN
				IF iRegistros >= pRegistros THEN
					IF iRecuperacion < pRecuperacion THEN
						SELECT numconvenio, numcategoria  INTO cNumConvenio, cNumCategoria FROM bdisac:sac_convenios WHERE nomconvenio = cNomConvenio;
						LET iRecuperacion = iRecuperacion + 1;							
					RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImporteComisionConvenio,
						mIvaComisionConvenio, mImporteComisionCte, mIivaComisionCte, cFormaCago, cCuentaCargo, cRegion, cNumConvenio, cNumCategoria
						WITH RESUME;
						LET iNoRegs = iNoRegs + 1;
					END IF;
				END IF;
					LET iRegistros = iRegistros + 1;
			ELSE
				LET cCodRet = cCodRetSp;
				RETURN cCodRet, '', '', '', '', '', 0, 0, 0, 0, 0, '', '', '', '', '';
			END IF;
		END FOREACH;
		IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, '', '', '', '', '', 0, 0, 0, 0, 0, '', '', '', '', '';
		END IF;
		IF  iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, '', '', '', '', '', 0, 0, 0, 0, 0, '', '', '', '', '';
		END IF;
	END;
END PROCEDURE
DOCUMENT "AUTOR: Esparza Brenis Fernando Martin",
"FECHA:  12/12/2013 ",
"DESCRIPCION: SP para el detalle de las sucursales",
"DB: bdisac";

create procedure "informix".sp_actualizasac_bts_payc(dFecha_hoy date)

    RETURNING CHAR(5), char(40);  -- Código de retorno

    define cCodRet          char(5);
    define cCodMsj          char(40);
    define cInfoErr         char(100);
    define iSqlErr          integer;
    define iIsamErr         integer;
    define vfecharesp       date;
	define vfechacomp       date;
    define vmax_fechaold    date;
    define vmin_fechaact    date;
    define vcontregshist    integer;
    define vcontregsold     integer;
    define inumdias         integer;
    define cStatusJob       char(1);
    define iRegJob          char(1);


    let cCodRet          = '00000';
    let cCodMsj          = '';
    let cInfoErr         = '';
	let iSqlErr          = 0;
	let iIsamErr         = 0;
    let vfecharesp       = '';
    let vfechacomp       = '';
    let vmax_fechaold    = '';
    let vmin_fechaact    = '';
    let vcontregshist    = 0;
    let vcontregsold     = 0;
    let inumdias         = 0;    
    let cStatusJob       = '';
    let iRegJob          = '';

     --set DEBUG FILE to "/informix/alex/sp_actualizasac_bts_payc.out";
	 --trace on;

     begin

        on exception set iSqlErr, iIsamErr, cInfoErr
            if iSqlErr <> 0 then
                let cCodRet = iSqlErr;
                rollback work;
                execute procedure "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizasac_bts_payc");
                return cCodRet, cCodMsj;
            end if;
        end exception;
       
        --Verifico que el job se ejecute una sola vez en el dia
        select count(*) into iRegJob 
        from "informix".sac_procesos_jobs where proceso = 'MIG_REG_BTSPAYC' and fecha_proceso = today;

        if iRegJob = '0' then 
            --Se inserta un registro en la tabla sac_procesos_jobs
            insert into "informix".sac_procesos_jobs (proceso, fecha_proceso, status, user_insert, fecha_insert, 
                                                        numero_ejecuciones, nombre_sp, descripcion)
                      values ('MIG_REG_BTSPAYC', today, '0', 'informix', current, 1, 'sp_actualizasac_bts_payc', 'Migracion sac_bts_payc a historico');
        end if;              
                    
        --Se extrae el valur del campo status
        select status into cStatusJob 
        from "informix".sac_procesos_jobs where proceso = 'MIG_REG_BTSPAYC' and fecha_proceso = today;

        --Si el campo status contiene un valor '1' ya no se realiza el proceso porque ya fue ejecutado anteriormente
        --solo puede ejecutarce una vez al dia.
        if cStatusJob = '0' then
            --  Migración de registros de 'bdisac:sac_bts_payc' A 'bdisac:sac_bts_payc_old'
            --	Sólo se considera el último día (fecha_insert + 1) de la tabla sac_bts_payc_old'
            select max(fecha_insert) into vmax_fechaold
                from "informix".sac_bts_payc_old;

            let vfecharesp = vmax_fechaold + 1;
            let vfechacomp = dFecha_hoy - 90;  

            select count(*) into vcontregshist
                from "informix".sac_bts_payc
                where fecha_insert::date <= vfechacomp
                and fecha_insert::date >= vfecharesp;

            --	Insert de la tabla bdisac:sac_bts_payc a bdisac:sac_bts_payc_old
            insert into "informix".sac_bts_payc_old 
                    (cnxn_status, agent_trans_type_code, agent_cd, confirmation_nm, process_type_code, 
					bank_ref_nm, bank_concept1, agnt_region_sd, agnt_branch_sd, agnt_state_cd, agnt_country_cd, 
					agnt_user_name, agnt_terminal, agent_dt, agent_tm, type_cd, issuer_cd, issuer_state_cd, 
					issuer_country_cd, identif_nm, expiration_dt, benef_dob_dt, dir_remitente, cd_remitente, 
					rem_state_cd, rem_country_cd, rem_zip_code, rem_phone, opcode, process_msg, err_param_full_name, 
					trans_status_cd, trans_status_dt, process_dt, process_tm, bank_ref_num, promotion_cd, user_insert, fecha_insert)

            select cnxn_status, agent_trans_type_code, agent_cd, confirmation_nm, process_type_code, 
					bank_ref_nm, bank_concept1, agnt_region_sd, agnt_branch_sd, agnt_state_cd, agnt_country_cd, 
					agnt_user_name, agnt_terminal, agent_dt, agent_tm, type_cd, issuer_cd, issuer_state_cd, 
					issuer_country_cd, identif_nm, expiration_dt, benef_dob_dt, dir_remitente, cd_remitente, 
					rem_state_cd, rem_country_cd, rem_zip_code, rem_phone, opcode, process_msg, err_param_full_name, 
					trans_status_cd, trans_status_dt, process_dt, process_tm, bank_ref_num, promotion_cd, user_insert, fecha_insert

               from "informix".sac_bts_payc
                  where fecha_insert::date <= vfechacomp
                  and fecha_insert::date >= vfecharesp;


            select count(*) into vcontregsold
                from "informix".sac_bts_payc_old
                    where fecha_insert::date <= vfechacomp
                    and fecha_insert::date >= vfecharesp;
              

            if vcontregsold = vcontregshist then
                delete from "informix".sac_bts_payc 
                    where fecha_insert::date <= vfechacomp
                    and fecha_insert::date >= vfecharesp;

                -- Realizo un Upadate a la tabla sac_procesos_jobs en el campo status = 1 para que sólo se ejecute una sola vez el job
                update sac_procesos_jobs set status = '1' where proceso = 'MIG_REG_BTSPAYC' and fecha_proceso = today; 
                let cCodMsj = 'Proceso Exitoso';
                return cCodRet, cCodMsj;
            else
                let iSqlErr = 9999;
                let iIsamErr = 9999;
                let cInfoErr = 'No se insertaron todos los registros en la tabla bdisac:sac_bts_payc_old.';
                execute procedure "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_actualizasac_bts_payc");
            end if;         
        else
            let cCodMsj = 'Este proceso ya fue ejecutado';
            return cCodRet, cCodMsj;
        end if;    
        
    end;

end procedure;