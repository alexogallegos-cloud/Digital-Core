CREATE PROCEDURE "informix".sp_generaarchivocobranzagobjalisco(pCatConv CHAR (5))

--DEFINIR VARIABLES
DEFINE iSqlErr          	INTEGER;
DEFINE cCodRet          	CHAR(5);
DEFINE cCategoria       	CHAR(2);
DEFINE cConvenio        	CHAR(3);
DEFINE cRutaArch			CHAR(100);
DEFINE cNomArchivo			CHAR(21);
DEFINE dFecha_Hoy       	DATE;
DEFINE cFechaPago       	CHAR(8);
DEFINE cRef1				CHAR(27);
DEFINE cRef2            	CHAR(25);
DEFINE cStmt		    	CHAR(200);
DEFINE cIdentificador		CHAR(2);
DEFINE cIdSucursal			CHAR(4);
DEFINE cHoraFecha			CHAR(5);
DEFINE iTotRegistros    	INTEGER;
DEFINE cImporte_pago		CHAR(16);
DEFINE deImporte_archivo 	DECIMAL(16,2);
DEFINE deImporte_pago	 	DECIMAL(16,2);
DEFINE cNombreSuc			CHAR(25);
DEFINE dFechaIni            DATE;
DEFINE cDia                 CHAR(2);
DEFINE cMes                 CHAR(2);
DEFINE cAnio                CHAR(4);

--INICIALIZAR VARIABLES
LET iSqlErr         	= 0;
LET cCodRet         	= '00000'; 
LET cCategoria      	= '';
LET cConvenio       	= '';
LET cRutaArch			= '';
LET cNomArchivo			= '';
LET dFecha_Hoy			= DATE(1);
LET cFechaPago      	= '';
LET cRef1				= '';
LET cRef2           	= '';
LET cStmt				= '';
LET cIdentificador  	= '';
LET cIdSucursal			= '';
LET cHoraFecha			= '';
LET iTotRegistros		= 0;
LET cImporte_pago   	= '';
LET deImporte_archivo 	= 0;
LET deImporte_pago    	= 0;
LET cNombreSuc			='';
LET dFechaIni           = DATE(1);
LET cDia                = '';
LET cMes                = '';
LET cAnio               = '';

	--SET DEBUG FILE TO '/respaldosbd/Ismael/sp_generaarchivocobranzagobjalisco.out';
	--TRACE ON;
		
	BEGIN
		-- Errores de Informix
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;

				UPDATE bdisac:"informix".sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND   numconvenio = cConvenio;
            END IF;
		END EXCEPTION;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
		--Validamos parámetros de entrada
		IF NVL(pCatConv,'') = '' THEN
            UPDATE bdisac:"informix".sac_controlarchivoscobranza
            SET    fecha_ultimo_archivo = CURRENT::DATE, retorno = cCodRet
            WHERE  numcategoria = '08' AND numconvenio = '003';

		ELSE
			--Obtenemos categoria y convenio
			LET cCategoria  = SUBSTRING(pCatConv FROM 1 FOR 2); -- Separar  categoría 
			LET cConvenio   = SUBSTRING(pCatConv FROM 3 FOR 3); --    del convenio
		
			--Obtenemos nombre de archivo de cobranza desde la tabla "bdisac:sac_convenios"
			SELECT TRIM(nombre_archivo_cobranza), TRIM(ruta_archivo_cobranza) 
			INTO   cNomArchivo, cRutaArch
			FROM   bdisac:"informix".sac_convenios 
			WHERE  numcategoria = cCategoria
			AND    numconvenio  = cConvenio;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
                UPDATE bdisac:"informix".sac_controlarchivoscobranza
                SET    fecha_ultimo_archivo = CURRENT::DATE, retorno = cCodRet
                WHERE  numcategoria = cCategoria AND numconvenio = cConvenio;
				
			ELSE						
				--Obtenemos fecha de bdisac:sac_fechas
				SELECT fecha_hoy 
				INTO   dFecha_Hoy
				FROM   bdisac:"informix".sac_fechas;
				
				SELECT fecha_ultimo_archivo
				INTO dFechaIni
				FROM bdisac:"informix".sac_controlarchivoscobranza
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				
                LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
                LET cMes = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
                LET cAnio = LPAD(YEAR(dFecha_Hoy ::DATE),4,'0');

				--Reemplazamos el nombre del archivo consultado previamente en "bdisac:sac_convenios" y le agregamos los datos de la fecha actual.
				LET cFechaPago = cAnio ||       -- AAAA (Year)
								 cMes  ||       -- MM   (Month)
								 cDia;          -- DD   (Day)
								
				LET cHoraFecha =SUBSTR(CURRENT, 12, 2)   ||     -- HH   (Hour)
								SUBSTR(CURRENT, 15, 2);         -- MM   (Minute)
				LET cNomArchivo = SUBSTR(cNomArchivo, 1, 3)  || -- GJ_
								  cFechaPago ||
								  TRIM(cHoraFecha) ||
								  '.txt';						-- Resultado esperado: GJ_AAAA/MM/DD.txt
				
				--Combinamos la ruta del archivo con el nombre de archivo actualizado.
				LET cRutaArch = TRIM(cRutaArch) || TRIM(cNomArchivo);
				
				FOREACH				
					SELECT					
					LPAD(TRIM(id_sucursal), 4, '0'),
					SUBSTR(fecha_pago, 7, 4) || SUBSTR(fecha_pago, 1, 2) || SUBSTR(fecha_pago, 4, 2),
					SUBSTRING(fecha_insert::DATETIME HOUR TO SECOND FROM 1 FOR 5),
					LPAD(TRIM(referencia1), 27, '0'),
					RPAD(SUBSTRING(referencia1 FROM 28 FOR 5), 25, '0'),
					LPAD(REPLACE(importe_pago, '$', ''), 16, '0'),
					NVL(importe_pago, 0)
					INTO     cIdSucursal, cFechaPago, cHoraFecha, cRef1, cRef2, cImporte_pago, deImporte_pago
					FROM     bdisac:"informix".sac_movimientoshistorial
					WHERE    numcategoria     = cCategoria 
					AND	     numconvenio      = cConvenio
					AND fecha_pago > dFechaIni
					AND fecha_pago <= dFecha_Hoy
					AND      status_cancelado = 'N'
                    AND (flag_confirmacion_central = 1
                    OR  flag_confirmacion_sucursal = 1)
					ORDER BY fecha_pago DESC
					
					SELECT NVL(REPLACE(nombre,',',' '),'')
					INTO cNombreSuc
					FROM bdinteg:"informix".si_sucursales
					WHERE sucursal = cIdSucursal;
										
					
					--Imprimir sólo filas de la consulta (sin encabezados)
					LET cIdentificador = RPAD('1', 2, ' ');
					
					LET cStmt = 'echo "'
					||cIdentificador || "," || RPAD(cNombreSuc, 25, ' ') || "," ||cFechaPago || "," || cHoraFecha || "," || cRef1 || "," || cRef2 || ","|| cImporte_pago || '" >> ' || cRutaArch;
					
					SYSTEM cStmt;
					
					LET iTotRegistros = iTotRegistros +1;
					LET deImporte_archivo = deImporte_archivo + deImporte_pago;
					
				END FOREACH;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
						--Consulta sin resultados, imprimir el archivo en blanco (sin encabezados, sin datos).
						LET cStmt = 'echo "" >> ' || cRutaArch;
						SYSTEM cStmt;
				ELSE
				
					LET cIdentificador = RPAD('2', 2, ' ');
					LET cRef2			= '000000000000000000000000000';
					
					LET cFechaPago = cAnio  ||   -- AAAA (Year)
									 cMes   ||   -- MM   (Month)
									 cDia;       -- DD   (Day)
									
					LET cHoraFecha =SUBSTR(CURRENT, 12, 2)   || -- HH   (Hour)
									SUBSTR(CURRENT, 14, 3);		-- MM   (Minute)
									
					LET cStmt = 'echo "'
					||cIdentificador || "," || 'REGISTRO DE CONTROL      ' || "," ||cFechaPago || "," || cHoraFecha || "," || LPAD(iTotRegistros, 27, 0) || ","	|| cRef2 || ","|| LPAD(deImporte_archivo, 16, 0) || '" >> ' || cRutaArch;
					
					SYSTEM cStmt;
					
				END IF;					
			END IF;

		END IF;		
        
        UPDATE bdisac:"informix".sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

    END
END PROCEDURE
DOCUMENT
'Autor: 97343331 - Ismel Ernesto Lizarraga Fernandez',
'Folio: 133 - Pagos inmpuestos del gobierno de Jalisco',
'Descripción: Genera el reporte de liquidación de pagos del gobierno de Jalisco.',
'Fecha: 29/09/2016',
'Versión: 201608151210',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidaciongjalisco(pConvenio CHAR(5))

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);  --08
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);  --004
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/informix/alex/sp_reporteliquidaciongjalisco.out';
	--TRACE ON;

	BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                UPDATE "informix".sac_controlreportesespeciales
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND numconvenio = cConvenio;
                EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidaciongjalisco");
            END IF;
        END EXCEPTION;

        
        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM "informix".sac_fechas;
 
       
        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: Vazquez Herrera Hugo Guadalupe ',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (GOBIERNO DE JALISCO)',
'SUSTENTO:  ',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de p_ProcesoCierreSAC()',
'FECHA: 31/08/2016',
'Solicita: Leonardo Hernandez',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidaciongobsinaloa(pConvenio CHAR(5))

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);  --08
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);  --004
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
--	SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_reporteliquidaciongobsinaloa.out';
--	TRACE ON;

	BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                UPDATE "informix".sac_controlreportesespeciales
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND numconvenio = cConvenio;
                EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidaciongobsinaloa");
            END IF;
        END EXCEPTION;

       
        SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
        INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
        FROM "informix".sac_fechas;

       
        IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 	rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE
DOCUMENT
'AUTOR: Vazquez Herrera Hugo Guadalupe ',
'DESCRIPCIÓN: Genera la información para los Reportes Semanal y Mensual de Pagos referenciados (GOBIERNO DE SINALOA)',
'SUSTENTO:  ',
'EJECUTADO O LLAMADO POR: sp_GeneraInformacionReportesEspeciales(), el cual  es llamado de p_ProcesoCierreSAC()',
'FECHA: 31/08/2016',
'Solicita: Leonardo Hernandez',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_generaarchivocobranzagobsinaloa(pCatConv CHAR (5))

--DEFINIR VARIABLES
DEFINE iSqlErr          	INTEGER;
DEFINE cCodRet          	CHAR(5);
DEFINE cCategoria       	CHAR(2);
DEFINE cConvenio        	CHAR(3);
DEFINE cRutaArch			CHAR(100);
DEFINE cNomArchivo			CHAR(21);
DEFINE dFecha_Hoy       	DATE;
DEFINE cFechaPago       	CHAR(8);
DEFINE cRef1				CHAR(25);
DEFINE cRef2            	CHAR(25);
DEFINE cStmt		    	CHAR(200);
DEFINE cIdentificador		CHAR(2);
DEFINE cIdSucursal			CHAR(4);
DEFINE cHoraFecha			CHAR(5);
DEFINE iTotRegistros    	INTEGER;
DEFINE cImporte_pago		CHAR(16);
DEFINE deImporte_archivo 	DECIMAL(16,2);
DEFINE deImporte_pago	 	DECIMAL(16,2);
DEFINE cNombreSuc			CHAR(25);
DEFINE dFechaIni            DATE;
DEFINE cDia                 CHAR(2);
DEFINE cMes                 CHAR(2);
DEFINE cAnio                CHAR(4);


--INICIALIZAR VARIABLES
LET iSqlErr         	= 0;
--LET cCodRet         	= '00002'; --Inicializado como error, cambia durante la ejecucion del sp en caso de exito.
LET cCodRet             = "00000";
LET cCategoria      	= '';
LET cConvenio       	= '';
LET cRutaArch			= '';
LET cNomArchivo			= '';
LET dFecha_Hoy			= DATE(1);
LET cFechaPago      	= '';
LET cRef1				= '';
LET cRef2           	= '';
LET cStmt				= '';
LET cIdentificador  	= '';
LET cIdSucursal			= '';
LET cHoraFecha			= '';
LET iTotRegistros		= 0;
LET cImporte_pago   	= '';
LET deImporte_archivo 	= 0;
LET deImporte_pago    	= 0;
LET cNombreSuc			='';
LET dFechaIni           = DATE(1);
LET cDia                = '';
LET cMes                = '';
LET cAnio               = '';

	--SET DEBUG FILE TO '/informix/alex/sp_generaarchivocobranzagobsinaloa.out';
	--TRACE ON;
		
	BEGIN
		-- Errores de Informix
		ON EXCEPTION SET iSqlErr

            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;

				UPDATE bdisac:"informix".sac_controlarchivoscobranza
                SET retorno = cCodRet
                WHERE numcategoria = cCategoria
                AND   numconvenio = cConvenio;
            END IF;
		END EXCEPTION;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		

        --Obtenemos categoria y convenio
        LET cCategoria  = SUBSTRING(pCatConv FROM 1 FOR 2); -- Separar  categoría 
        LET cConvenio   = SUBSTRING(pCatConv FROM 3 FOR 3); --    del convenio
				
        --Obtenemos fecha de bdisac:sac_fechas
        SELECT fecha_hoy 
        INTO   dFecha_Hoy
        FROM   bdisac:"informix".sac_fechas;

        SELECT fecha_ultimo_archivo
        INTO dFechaIni
        FROM bdisac:"informix".sac_controlarchivoscobranza
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;

        --Obtenemos nombre de archivo de cobranza desde la tabla "bdisac:sac_convenios"
        SELECT TRIM(nombre_archivo_cobranza), TRIM(ruta_archivo_cobranza) 
        INTO   cNomArchivo, cRutaArch
        FROM   bdisac:"informix".sac_convenios 
        WHERE  numcategoria = cCategoria
        AND    numconvenio  = cConvenio;


        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
		LET cMes = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
		LET cAnio = LPAD(YEAR(dFecha_Hoy ::DATE),4,'0');

        --Reemplazamos el nombre del archivo consultado previamente en "bdisac:sac_convenios" y le agregamos los datos de la fecha actual.
        LET cNomArchivo = SUBSTR(cNomArchivo, 1, 7)  || -- COPPEL_
                          cAnio     || "-" ||-- AAAA/ (Year)
                          cMes      || "-" ||-- MM/   (Month)
                          cDia      || -- DD   (Day)
                          '.txt';						-- Resultado esperado: COPPEL_AAAA/MM/DD.txt

        --Combinamos la ruta del archivo con el nombre de archivo actualizado.
        LET cRutaArch = TRIM(cRutaArch) || TRIM(cNomArchivo);

        FOREACH				
            SELECT					
            LPAD(TRIM(id_sucursal), 4, '0'),
            SUBSTR(fecha_pago, 7, 4) || SUBSTR(fecha_pago, 1, 2) || SUBSTR(fecha_pago, 4, 2),
            SUBSTRING(fecha_insert::DATETIME HOUR TO SECOND FROM 1 FOR 5),
            LPAD(TRIM(referencia1), 25, '0'),
            RPAD(SUBSTRING(referencia1 FROM 26 FOR 5), 25, '0'),
            LPAD(REPLACE(importe_pago, '$', ''), 16, '0'),
            NVL(importe_pago, 0)
            INTO     cIdSucursal, cFechaPago, cHoraFecha, cRef1, cRef2, cImporte_pago, deImporte_pago
            FROM     bdisac:"informix".sac_movimientoshistorial
            WHERE    numcategoria     = cCategoria 
            AND	     numconvenio      = cConvenio
            AND fecha_pago > dFechaIni
            AND fecha_pago <= dFecha_Hoy
            AND status_cancelado <> 'S' 
            AND (flag_confirmacion_central = 1
            OR  flag_confirmacion_sucursal = 1)
            ORDER BY fecha_pago DESC

            SELECT NVL(REPLACE(nombre,',',' '),'')
            INTO cNombreSuc
            FROM bdinteg:"informix".si_sucursales
            WHERE sucursal = cIdSucursal;


            --Imprimir solo filas de la consulta (sin encabezados)
            LET cIdentificador = RPAD('1', 2, ' ');

            LET cStmt = 'echo "'
            ||cIdentificador || "," || RPAD(cNombreSuc, 25, ' ') || "," ||cFechaPago || "," || cHoraFecha || "," || cRef1 || "," || cRef2 || ","|| cImporte_pago || '" >> ' || cRutaArch;

            SYSTEM cStmt;

            LET iTotRegistros = iTotRegistros +1;
            LET deImporte_archivo = deImporte_archivo + deImporte_pago;

        END FOREACH;

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
                --Consulta sin resultados, imprimir el archivo en blanco (sin encabezados, sin datos).
                LET cStmt = 'echo "" >> ' || cRutaArch;
                SYSTEM cStmt;
        ELSE

            LET cIdentificador = RPAD('2', 2, ' ');
            LET cRef2			= '0000000000000000000000000';

            LET cFechaPago = cAnio   || -- AAAA (Year)
                             cMes    || -- MM   (Month)
                             cDia;		-- DD   (Day)

            LET cHoraFecha =SUBSTR(CURRENT, 12, 2)   || -- HH   (Hour)
                            SUBSTR(CURRENT, 14, 3);		-- MM   (Minute)

            LET cStmt = 'echo "'
            ||cIdentificador || "," || 'REGISTRO DE CONTROL      ' || "," ||cFechaPago || "," || cHoraFecha || "," || LPAD(iTotRegistros, 25, 0) || ","	|| cRef2 || ","|| LPAD(deImporte_archivo, 16, 0) || '" >> ' || cRutaArch;

            SYSTEM cStmt;

        END IF;					

        UPDATE bdisac:"informix".sac_controlarchivoscobranza
        SET retorno = cCodRet, fecha_ultimo_archivo = dFecha_Hoy
        WHERE numcategoria = cCategoria
        AND numconvenio = cConvenio;


	END
END PROCEDURE
DOCUMENT
'Autor: 93893061 - Rigoberto Gonzalez Llanes',
'Folio: 100 - Pagos del gobierno de Sinaloa',
'DescripciÃ³n: Genera el reporte de liquidaciÃ³n de pagos del gobierno de Sinaloa.',
'Fecha: 15/08/2016',
'VersiÃ³n: 201608151210',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_reporteliquidacioncoppelcom(pConvenio CHAR(5))

--DEFINICION DE VARIABLES
DEFINE cCodret           CHAR(5);
DEFINE cCodRet2          CHAR(5);
DEFINE cAnioMes          CHAR(6);
DEFINE cInfoErr          CHAR(100);
DEFINE cCategoria        CHAR(2);
DEFINE cConvenio         CHAR(3);
DEFINE cFechaLiq         CHAR(10);
DEFINE iSqlErr           INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE iRecEfe           INTEGER;
DEFINE iRecEfeAux        CHAR(16);
DEFINE iRecCC            INTEGER;
DEFINE iRecCCAux         CHAR(16);
DEFINE iRecMix           INTEGER;
DEFINE iRecEfeT          INTEGER;
DEFINE iRecCCT           INTEGER;
DEFINE iRecMixT          INTEGER;
DEFINE iRecTot           INTEGER;
DEFINE iRecAux           INTEGER;
DEFINE iRecLun           INTEGER;
DEFINE iRecMAr           INTEGER;
DEFINE iRecMie           INTEGER;
DEFINE iRecJue           INTEGER;
DEFINE iRecVie           INTEGER;
DEFINE iRecSab           INTEGER;
DEFINE iRecDom           INTEGER;
DEFINE iNumOpe           INTEGER;
DEFINE iDias             INTEGER;
DEFINE mLiqlun           MONEY(16,2);
DEFINE mLiqMar           MONEY(16,2);
DEFINE mLiqMier          MONEY(16,2);
DEFINE mLiqJue           MONEY(16,2);
DEFINE mLiqVie           MONEY(16,2);
DEFINE mLiqResguardo     MONEY(16,2);
DEFINE mCobEfe           MONEY(16,2);
DEFINE mCobEfeAux        MONEY(16,2);
DEFINE mCobMix           MONEY(16,2);
DEFINE mCobCC            MONEY(16,2);
DEFINE mCobCCAux         MONEY(16,2);
DEFINE mCobEfeT          MONEY(16,2);
DEFINE mCobMixT          MONEY(16,2);
DEFINE mCobCCT           MONEY(16,2);
DEFINE mCobTot           MONEY(16,2);
DEFINE mCobAux           MONEY(16,2);
DEFINE mCobLun           MONEY(16,2);
DEFINE mCobMar           MONEY(16,2);
DEFINE mCobMie           MONEY(16,2);
DEFINE mCobJue           MONEY(16,2);
DEFINE mCobVie           MONEY(16,2);
DEFINE mCobSab           MONEY(16,2);
DEFINE mCobDom           MONEY(16,2);
DEFINE mTotComision      MONEY(16,2);
DEFINE mTotIvaCom        MONEY(16,2);
DEFINE mComision         MONEY(16,2);
DEFINE mComisionAux      MONEY(16,2);
DEFINE mIvaCom           MONEY(16,2);
DEFINE mIvaComAux        MONEY(16,2);
DEFINE mAcumulado        MONEY(16,2);
DEFINE dFechaAux         DATE;
DEFINE dfecha_Hoy        DATE;
DEFINE dFechaIni         DATE;
DEFINE dPriDiaMes        DATE;
DEFINE dUltDiaMes        DATE;
DEFINE iFlagCen          INTEGER;
DEFINE iFlagSuc          INTEGER;
DEFINE cFolio            CHAR(16);
DEFINE iCuantos          INTEGER;

--INICIALIZACION DE VARIABLES
LET cCodRet2	= "00000";
LET cCodret		= "000000";
LET cInfoErr	= '';
LET cAnioMes	= '';
LET mCobEfe		= 0;
LET mCobEfeAux	= 0;
LET mCobCC		= 0;
LET mCobCCAux	= 0;
LET mCobMix		= 0;
LET iRecEfe		= 0;
LET iRecEfeAux	= '';
LET iRecCC		= 0;
LET iRecCCAux	= '';
LET iRecMix		= 0;
LET mComision	= 0;
LET mComisionAux	= 0;
LET mIvaCom		= 0;
LET mIvaComAux	= 0;
LET mCobEfeT	= 0;
LET mCobCCT		= 0;
LET iRecEfeT	= 0;
LET iRecCCT		= 0;
LET mTotComision	= 0;
LET mTotIvaCom	= 0;
LET iRecLun		= 0;
LET mCobLun		= 0;
LET iRecMar		= 0;
LET mCobMar		= 0;
LET iRecMie		= 0;
LET mCobMie		= 0;
LET iRecJue		= 0;
LET mCobJue		= 0;
LET iRecVie		= 0;
LET mCobVie		= 0;
LET iRecSab		= 0;
LET mCobSab		= 0;
LET iRecDom		= 0;
LET mCobDom		= 0;
LET cCategoria	= SUBSTRING(pConvenio FROM 1 FOR 2);
LET cConvenio	= SUBSTRING(pConvenio FROM 3 FOR 3);
LET dFechaAux	= '';
LET dfecha_Hoy	= '';
LET dFechaIni	= '';
LET dPriDiaMes	= '';
LET dUltDiaMes	= '';
LET iNumOpe		= 0;
LET mLiqlun		= 0;
LET mLiqMar		= 0;
LET mLiqMier	= 0;
LET mLiqJue		= 0;
LET mLiqVie		= 0;
LET cFechaLiq	= "";
LET mLiqResguardo	= 0;
LET mAcumulado	= 0;
LET iFlagCen	= 0;
LET iFlagSuc	= 0;
LET cFolio		= '';
LET iCuantos	= 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/respaldosbd/hugovaz/sp_reporteliquidacioncoppelcom.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				UPDATE "informix".sac_controlreportesespeciales
				SET retorno = cCodRet
				WHERE numcategoria = cCategoria
				AND numconvenio = cConvenio;
				EXECUTE PROCEDURE "informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_reporteliquidacioncoppelcom");
			END IF;
		END EXCEPTION;

		SELECT fecha_hoy, pri_dia_mes, ult_dia_mes
		INTO dfecha_Hoy, dPriDiaMes, dUltDiaMes
		FROM "informix".sac_fechas;

		IF TO_CHAR(dfecha_Hoy,"%A") = "Sunday" THEN

			LET dFechaAux = dfecha_Hoy - 6;
			LET dFechaIni = dFechaAux;

			SELECT NVL(liq_resguardo ,0)
			INTO mAcumulado
			FROM "informix".sac_liquidacionsemanal
			WHERE id_convenio = cCategoria||cConvenio
			AND consecutivo_convenio = (SELECT MAX(consecutivo_convenio)
								FROM "informix".sac_liquidacionsemanal
								WHERE id_convenio = cCategoria||cConvenio
								AND consecutivo_convenio <> 0);

			IF mAcumulado IS NULL THEN
				LET mAcumulado = 0;
			END IF;
			
			WHILE dFechaAux <= dfecha_Hoy

				LET mCobEfe = 0.00;
				LET mCobCC = 0.00;
				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iRecEfe = 0;
				LET iRecCC = 0;

				FOREACH
					SELECT
						NVL(efe,0),
						NVL(cc,0),
						NVL(Rec1,''),
						NVL(Rec2,""),
						NVL(comision, 0),
						NVL(iva_com,0),
						flag_confirmacion_central,
						flag_confirmacion_sucursal,
						folio_suc
					INTO
						mCobEfeAux,
						mCobCCAux,
						iRecEfeAux,
						iRecCCAux,
						mComisionAux,
						mIvaComAux,
						iFlagCen,
						iFlagSuc,
						cFolio
					FROM TABLE(
						MULTISET(
							SELECT importe_comision_convenio AS comision, iva_comision_convenio AS iva_com,
									CASE WHEN forma_pago = 1 THEN NVL(importe_pago, 0) END AS efe,
									CASE WHEN forma_pago = 2 THEN NVL(importe_pago, 0) END AS cc,
									CASE WHEN forma_pago = 1 THEN folio_suc END AS Rec1,
									CASE WHEN forma_pago = 2 THEN folio_suc END AS Rec2,
									flag_confirmacion_central,
									flag_confirmacion_sucursal,
									folio_suc
							FROM "informix".sac_movimientoshistorial
							WHERE numcategoria = cCategoria
							AND numconvenio = cConvenio
							AND fecha_pago  = dFechaAux
							AND status_cancelado = 'N'
							AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)))

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mCobEfe = mCobEfe + mCobEfeAux;
								LET mCobCC = mCobCC + mCobCCAux;
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
									LET iRecEfe = iRecEfe +1;
								END IF;
								IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
									LET iRecCC = iRecCC +1;
								END IF;
							END IF;
						ELSE
							LET mCobEfe = mCobEfe + mCobEfeAux;
							LET mCobCC = mCobCC + mCobCCAux;
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
								LET iRecEfe = iRecEfe +1;
							END IF;
							IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
								LET iRecCC = iRecCC +1;
							END IF;
						END IF;
					ELSE
						LET mCobEfe = mCobEfe + mCobEfeAux;
						LET mCobCC = mCobCC + mCobCCAux;
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						IF LENGTH(TRIM(iRecEfeAux)) > 0 THEN
							LET iRecEfe = iRecEfe +1;
						END IF;
						IF LENGTH(TRIM(iRecCCAux)) > 0 THEN
							LET iRecCC = iRecCC +1;
						END IF;
					END IF;
				END FOREACH;

				LET mCobEfeT = mCobEfeT + mCobEfe;
				LET mCobCCT = mCobCCT + mCobCC;
				LET iRecEfeT = iRecEfeT + iRecEfe ;
				LET iRecCCT = iRecCCT + iRecCC;
				LET mTotComision = mTotComision + mComision;
				LET mTotIvaCom = mTotIvaCom + mIvaCom;

				EXECUTE PROCEDURE bditef:"informix".cal_fecha_pre_fh(dFechaAux)
				INTO cCodRet2,cFechaLiq;

				IF CAST(cCodRet2 AS INTEGER) = 0 THEN

					LET iDias =  cFechaLiq::DATE - dFechaAux::DATE;

					IF TO_CHAR(dFechaAux,"%A") = "Monday" THEN
						LET iRecLun = iRecEfe + iRecCC ;
						LET mCobLun = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMar = mLiqMar + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqMar = mLiqMar + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobLun;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;


					IF TO_CHAR(dFechaAux,"%A") = "Tuesday" THEN
						LET iRecMar = iRecEfe + iRecCC ;
						LET mCobMar = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqMier =  mLiqMier + mCobMar;
							IF mAcumulado <> 0 THEN
							    LET mLiqMier = mLiqMier + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMar;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Wednesday" THEN
						LET iRecMie = iRecEfe + iRecCC ;
						LET mCobMie = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqJue = mLiqJue + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqJue = mLiqJue + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobMie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Thursday" THEN
						LET iRecJue = iRecEfe + iRecCC ;
						LET mCobJue = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqVie = mLiqVie + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqVie = mLiqVie + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobJue;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Friday"  THEN
						LET iRecVie = iRecEfe + iRecCC ;
						LET mCobVie = mCobEfe + mCobCC ;

						IF iDias >= 1 AND iDias <= 3 THEN
							LET mLiqlun =  mLiqlun + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobVie;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo =mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
					    END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Saturday"   THEN
						LET iRecSab = iRecEfe + iRecCC ;
						LET mCobSab = mCobEfe + mCobCC ;

						IF iDias >= 1  AND iDias <= 2 THEN
							LET mLiqlun =  mLiqlun + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqlun =mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobSab;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

					IF TO_CHAR(dFechaAux,"%A") = "Sunday" THEN
						LET iRecDom = iRecEfe + iRecCC ;
						LET mCobDom = mCobEfe + mCobCC ;

						IF iDias = 1 THEN
							LET mLiqlun =  mLiqlun + mCobDom;

							IF mAcumulado <> 0 THEN
								LET mLiqlun = mLiqlun + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						ELSE
							LET mLiqResguardo =  mLiqResguardo + mCobDom;
							IF mAcumulado <> 0 THEN
								LET mLiqResguardo = mLiqResguardo + mAcumulado;
								LET mAcumulado = 0;
							END IF;
						END IF;
					END IF;

				LET dFechaAux = dFechaAux + 1;

				END IF;
			END WHILE;

			IF cCodRet2::INTEGER = 0 THEN

				INSERT INTO "informix".sac_liquidacionsemanal (id_convenio, rec_lunes, rec_martes, 				rec_miercoles, rec_jueves, rec_viernes, rec_sabado, rec_domingo, cob_lunes, 			 cob_martes, cob_miercoles, cob_jueves, cob_viernes, cob_sabado, cob_domingo, 			   rec_efectivo, rec_chequemb, rec_chequeob, rec_tarcred, cob_efectivo,
							  cob_cheqmb,cob_cheqob, cob_tarcred, liq_lunes, liq_martes, liq_miercoles, liq_jueves, liq_viernes,aclaraciones,comision, iva_comision, fec_iniperiodo, fec_finperiodo, liq_resguardo, consecutivo_convenio, fecha_insert)
				VALUES(cCategoria||cConvenio, iRecLun, iRecMar, iRecMie, iRecJue, iRecVie, iRecSab, iRecDom, mCobLun, mCobMar, mCobMie, mCobJue, mCobVie, mCobSab, mCobDom,iRecEfeT, iRecCCT,0, 0,  mCobEfeT, mCobCCT, 0, 0,mLiqlun, mLiqMar, mLiqMier, mLiqJue, mLiqVie,0,mTotComision, mTotIvaCom, dFechaIni,dfecha_Hoy, mLiqResguardo,
					  (SELECT NVL(MAX(consecutivo_convenio + 1 ),1) FROM "informix".sac_liquidacionsemanal
					   WHERE id_convenio = cCategoria||cConvenio) , CURRENT);
			END IF;
		END IF;

		IF dfecha_Hoy = dUltDiaMes AND CAST(cCodRet2 AS INTEGER) = 0 THEN
			LET dFechaAux = dPriDiaMes;
			LET cAnioMes = TO_CHAR(dfecha_Hoy,"%Y%m");

			WHILE dFechaAux <= dfecha_Hoy

				LET mComision = 0.00;
				LET mIvaCom = 0.00;
				LET iNumOpe = 0;

				FOREACH
					SELECT NVL(importe_comision_convenio,0),NVL(iva_comision_convenio,0),
						flag_confirmacion_central, flag_confirmacion_sucursal,folio_suc
					INTO mComisionAux, mIvaComAux,iFlagCen,iFlagSuc,cFolio
					FROM bdisac:"informix".sac_movimientoshistorial
					WHERE numcategoria = cCategoria
					AND numconvenio = cConvenio
					AND fecha_pago  = dFechaAux
					AND status_cancelado = 'N'
					AND (flag_confirmacion_central = 1 OR flag_confirmacion_sucursal = 1)

					IF iFlagCen = 0 OR iFlagSuc =0 THEN
						SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movdia
						WHERE empresa = '001' AND folio_suc = cFolio;
						IF iCuantos = 0 THEN
							SELECT COUNT(folio_suc) INTO iCuantos FROM bdicheq:"informix".sc_movhis
							WHERE empresa = '001' AND folio_suc = cFolio;
							IF iCuantos = 0 THEN
								CONTINUE FOREACH;
							ELSE
								LET mComision = mComision + mComisionAux;
								LET mIvaCom = mIvaCom + mIvaComAux;
								LET iNumOpe = iNumOpe + 1;
							END IF;
						ELSE
							LET mComision = mComision + mComisionAux;
							LET mIvaCom = mIvaCom + mIvaComAux;
							LET iNumOpe = iNumOpe + 1;
						END IF;
					ELSE
						LET mComision = mComision + mComisionAux;
						LET mIvaCom = mIvaCom + mIvaComAux;
						LET iNumOpe = iNumOpe + 1;
					END IF;

				END FOREACH;

				INSERT INTO "informix".sac_liquidacionmensual(id_convenio, aniomes, fecha, num_operaciones, comision, iva, fecha_insert)
				VALUES(cCategoria||cConvenio, cAnioMes, dFechaAux, iNumOpe, mComision, mIvaCom, CURRENT);

				LET dFechaAux = dFechaAux + 1;
			END WHILE;

		END IF;

		IF CAST(cCodRet2 AS INTEGER) <> 0 THEN
			LET cCodRet = LPAD(TRIM(cCodRet2), 5, '0');
		END IF;

		UPDATE "informix".sac_controlreportesespeciales
		SET retorno = cCodret
		WHERE numcategoria = cCategoria
		AND numconvenio = cConvenio;

	END;
END PROCEDURE;