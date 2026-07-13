CREATE PROCEDURE  "informix".sp_valida_dv_gobjalisco(pNumRef CHAR(32), pImporte CHAR(7))
RETURNING 
	CHAR (5) AS CodigoRetorno;

--DEFINICION DE LAS VARIABLES	
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;
DEFINE sI SMALLINT;
DEFINE sNoPeso SMALLINT;
DEFINE sSuma SMALLINT;
DEFINE sAux SMALLINT;
DEFINE iValorDigito INTEGER;
DEFINE sDigVerCapturado SMALLINT;
DEFINE sResiduo SMALLINT;
DEFINE dFechaHoy DATE;
DEFINE dFechaformat DATE;
DEFINE cFechaRef CHAR(10);
DEFINE cDia CHAR(2);
DEFINE cMes CHAR(2);
DEFINE cAnio CHAR(4);
DEFINE cCadenaRef CHAR(31);
DEFINE cConstGobJal CHAR(6);
DEFINE cTipoImpuesto CHAR(2);
DEFINE cExiste CHAR(1);
DEFINE cExisteHistorial CHAR(1);

--INICIALIZACION DE LAS VARIABLES
LET cCodRet = '00000';
LET iSqlErr = 0; 
LET sI = 0;
LET sNoPeso = 1;
LET sSuma = 0;
LET sAux = 0;
LET iValorDigito = 0;
LET sDigVerCapturado = 0;
LET sResiduo = 0;
LET dFechaHoy = DATE('01/01/1900');
LET dFechaformat = DATE('01/01/1900');
LET	cFechaRef = '';
LET cDia = '';
LET cMes = '';
LET cAnio = '';
LET cCadenaRef = '';
LET cConstGobJal = '';
LET cTipoImpuesto = '';
LET cExiste = '';
LET cExisteHistorial = '';

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet;
	   END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/Alexis/133/sp_valida_dv_gobjalisco.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF NVL(pImporte,'') = '' THEN
		--Primer flujo, ocurre al dar enter en la primer caja de captura de la referencia,
		--validando unicamente el digito verificador y la fecha vigencia, dejando fuera la validacion del importe
		--ya que aun no se conoce. El importe se conoce despues de la captura ciega.

		--Verifica la longitud de referencia de pago
		IF LENGTH(TRIM(pNumRef)) = 32 THEN

			LET cConstGobJal = SUBSTR(pNumRef,1,6);
			LET cTipoImpuesto = SUBSTR(pNumRef,14,2);

			--------Validar que la referencia de pago exista no haya sido utilizada anteriormente, en caso de ya haber sido utilizada		
			SELECT '1' 
			INTO cExiste
			FROM bdisac:"informix".sac_movimientoshistorial 
			WHERE referencia1= pNumRef 
			AND numcategoria='08' 
			AND numconvenio='003' 
			AND  status_cancelado = 'N' 
			AND flag_confirmacion_central=1 
			AND flag_confirmacion_sucursal=1;

			SELECT '1' 
			INTO cExisteHistorial
			FROM bdisac:"informix".sac_movimientos 
			WHERE referencia1= pNumRef 
			AND numcategoria='08' 
			AND numconvenio='003' 
			AND  status_cancelado = 'N' 
			AND flag_confirmacion_central=1 
			AND flag_confirmacion_sucursal=1;
			
			IF NVL(cExiste,'') <> '1' AND NVL(cExisteHistorial,'') <> '1' THEN
					LET cExiste = '';
					LET cExisteHistorial = '';

					--Validacion de la constante para el gobierno de Jalisco		
					IF cConstGobJal = '900400' THEN
					
						SELECT '1'
						INTO cExiste
						FROM bdisac:"informix".sac_impuestosgobjalisco
						WHERE clave = cTipoImpuesto;
						
						--Validacion de la existencia del tipo de impuesto/tramite que se quiere pagar
						IF NVL(cExiste,'') = '1' THEN
							LET cExiste = '';
			
							SELECT fecha_hoy
							INTO dFechaHoy
							FROM bdisac:"informix".sac_fechas
							WHERE empresa = '001';
							
							LET cDia = SUBSTR(pNumRef,19,2);
							LET cMes = SUBSTR(pNumRef,21,2);
							LET cAnio = SUBSTR(pNumRef,23,2);
							LET cAnio = CAST(cAnio AS INTEGER) + 2000;
							LET dFechaformat = LPAD(TRIM(cMes),2,'0')||'/'||LPAD(TRIM(cDia),2,'0')||'/'||TRIM(cAnio);
							
							--validacion de la vigencia de la referencia de pago
							IF dFechaHoy <= dFechaformat THEN

									--La referencia de captura esta vigente
									LET sDigVerCapturado = SUBSTR(pNumRef,32,1)::INTEGER;
									LET cCadenaRef = SUBSTR(pNumRef,1,31);
									
									--Ciclo para sacar el digito verificador
									FOR sI = 1 TO LENGTH(cCadenaRef)	
										LET iValorDigito = SUBSTR(cCadenaRef,sI,1)::SMALLINT;
										LET sAux = iValorDigito * sNoPeso;

										IF sNoPeso = 1 THEN
											LET sNoPeso = 3;
										ELIF sNoPeso = 3 THEN
											LET sNoPeso = 7;
										ELIF sNoPeso = 7 THEN
											LET sNoPeso = 1;								
										END IF;

										LET sSuma = sSuma + sAux;

									END FOR;
									
									LET sResiduo = MOD(sSuma , 9);
									LET iValorDigito = sResiduo + 1;

									IF iValorDigito = sDigVerCapturado THEN
										--El digito calculado coincide con el digito verificador de la referencia de pago
										LET cCodRet = '00000';
									ELSE
										--El digito verificador es incorrecto.
										LET cCodRet = '00109';
									END IF;
							ELSE
								LET cCodRet = '00140';
							END IF;
							
						ELSE
							LET cCodRet = '00142';
						END IF;			
						
					ELSE
						LET cCodRet = '00082';
					END IF;
			ELSE
				LET cCodRet = '00143';
			END IF
		ElSE
			--ESCENARIO: LONGITUD DE REFERENCIA NO VALIDA.
			LET cCodRet = '00047';
		END IF
	
	ELSE
		-- Validacion del monto
		IF  LENGTH(TRIM(pImporte)) = 7 THEN			
			IF pImporte = SUBSTR(pNumRef,25,7) THEN
				LET cCodRet = '00000';
			ELSE
				LET cCodRet = '00083';
			END IF;
		ELSE
			LET cCodRet = '00082';
		END IF;
	END IF;

	RETURN cCodRet;
		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea rutina en central para las validaciones de la referencia de pago para los impuestos del gobierno de jalisco',
'ELABORO: OSCAR ALEXIS IBARRA VERDUGO',
'SOLICITO: JAIME GONZALEZ PRADO',
'FECHA: 07/10/2016',
'BD: bdisac';

CREATE PROCEDURE  "informix".sp_valida_dv_gobsinaloa(pNumRef CHAR(30), pImporte CHAR(9))
RETURNING 
	CHAR (5) AS CodigoRetorno;

--DEFINICION DE LAS VARIABLES	
DEFINE cCodRet     		CHAR(5);
DEFINE iSqlErr	  		INTEGER;
DEFINE sI 		   		SMALLINT;
DEFINE sNoPeso	   		SMALLINT;
DEFINE sSuma	  		SMALLINT;
DEFINE sAux		   		SMALLINT;
DEFINE iValorDigito	    INTEGER;
DEFINE sDigVerCapturado SMALLINT;
DEFINE sResiduo			SMALLINT;
DEFINE cFechaHoy		DATE;
DEFINE cFechaformat	    DATE;
DEFINE cFechaRef		CHAR(10);
DEFINE cDia				CHAR(2);
DEFINE cMes				CHAR(2);
DEFINE cAnio			CHAR(4);
DEFINE cCadenaRef		CHAR(29);
DEFINE cConstGobSln		CHAR(2);
DEFINE cTipoImpuesto	CHAR(2);
DEFINE cOficinaSln		CHAR(3);
DEFINE cExiste			CHAR(1);

--INICIALIZACION DE LAS VARIABLES
LET cCodRet 		  	= '00000';
LET iSqlErr	  		  	= 0; 
LET sI 		   		  	= 0;
LET sNoPeso	   		  	= 1;
LET sSuma	  		  	= 0;
LET sAux		      	= 0;
LET iValorDigito	  	= 0;
LET sDigVerCapturado  	= 0;
LET sResiduo		  	= 0;	
LET cFechaHoy		  	= DATE('01/01/1900');
LET cFechaformat     	= DATE('01/01/1900');
LET	cFechaRef			= '';
LET cDia			  	= '';
LET cMes			  	= '';
LET cAnio			  	= '';
LET cCadenaRef		  	= '';
LET cConstGobSln		= '';
LET cTipoImpuesto		= '';
LET cOficinaSln			= '';
LET cExiste				= '';

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet;
	   END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/alex/sp_valida_dv_gobsinaloa.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

   
   	IF NVL(pImporte,'') = '' THEN
		--Primer flujo, ocurre al dar enter en la primer caja de captura de la referencia,
		--validando unicamente el digito verificador y la fecha vigencia, dejando fuera la validacion del importe
		--ya que aun no se conoce. El importe se conoce despues de la captura ciega.
	
		IF LENGTH(TRIM(pNumRef)) = 30 THEN
		
           	LET cConstGobSln = SUBSTR(pNumRef,1,2);
            LET cOficinaSln = SUBSTR(pNumRef,3,3);
			LET cTipoImpuesto = SUBSTR(pNumRef,6,2);
						

        	--Validacion de la constante para el gobierno de Sinaloa			
			IF cConstGobSln = '95' THEN
			
				SELECT '1'
				INTO cExiste
				FROM bdisac:'informix'.sac_impuestosgobsinaloa
				WHERE clave = cTipoImpuesto;
				
				--Validacion de la existencia del tipo de impuesto/tramite que se quiere pagar				
				IF NVL(cExiste,'') = '1' THEN
					LET cExiste = '';
					
					SELECT '1'
					INTO cExiste
					FROM bdisac:'informix'.sac_oficinasgobsinaloa
					WHERE clave = cOficinaSln;
					
					--Validacion de la existencia de la oficina en la que se quiere pagar					
					IF NVL(cExiste,'') = '1' THEN
						
						SELECT fecha_hoy
						INTO cFechaHoy
						FROM bdisac:'informix'.sac_fechas
						WHERE empresa = '001';
						
						LET cDia = SUBSTR(pNumRef,15,2);
						LET cMes = SUBSTR(pNumRef,17,2);
						LET cAnio = SUBSTR(pNumRef,19,2);
						LET cAnio = CAST(cAnio AS INTEGER) + 2000;
						LET cFechaformat = LPAD(TRIM(cMes),2,'0')||'/'||LPAD(TRIM(cDia),2,'0')||'/'||TRIM(cAnio);
						
						--validacion de la vigencia de la referencia de pago
						IF cFechaHoy <= cFechaformat THEN
							--La referencia de captura esta vigente
							LET sDigVerCapturado = SUBSTR(pNumRef,30,1)::INTEGER;
							LET cCadenaRef = SUBSTR(pNumRef,1,29);

							--Ciclo para sacar el digito verificador
							FOR sI = 1 TO LENGTH(cCadenaRef)			

								LET iValorDigito = SUBSTR(cCadenaRef,sI,1)::SMALLINT;
								LET sAux = iValorDigito * sNoPeso;

								IF sNoPeso = 1 THEN
									LET sNoPeso = 3;
								ELIF sNoPeso = 3 THEN
									LET sNoPeso = 7;
								ELIF sNoPeso = 7 THEN
									LET sNoPeso = 1;								
								END IF;

								LET sSuma = sSuma + sAux;

							END FOR;
							
							LET sResiduo = MOD(sSuma , 9);
							LET iValorDigito = sResiduo + 1;

							IF iValorDigito = sDigVerCapturado THEN
								--El digito calculado coincide con el digito verificador de la referencia de pago
								LET cCodRet = '00000';
							ELSE
								--El digito verificador es incorrecto.
								LET cCodRet = '00109';
							END IF;
								
						ELSE
							--La referencia de captura esta vencida
							LET cCodRet = '00140';
						END IF;						
						
					ELSE
						--la oficina en la que se quiere pagar no existe.
						LET cCodRet = '00141';					
					END IF;					
					
				ELSE
					--El tipo de impuesto/tramite que se quiere pagar no existe.
					LET cCodRet = '00142';				
				END IF;
			ELSE
				--la constante es incorrecta
				LET cCodRet = '00082';					
			END IF;			
		ELSE
			--ESCENARIO: LONGITUD DE REFERENCIA NO VALIDA.
			LET cCodRet = '00047';
		END IF;

	ELSE
		-- Validacion del monto
		IF  LENGTH(TRIM(pImporte)) = 9 THEN			
			IF pImporte = SUBSTR(pNumRef,21,9) THEN
				LET cCodRet = '00000';
			ELSE
				LET cCodRet = '00083';
			END IF;
		ELSE
			LET cCodRet = '00082';
		END IF;
	END IF;

	RETURN cCodRet;
		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea rutina en central para las validaciones de la referencia de pago para los impuestos del gobierno de sinaloa',
'ELABORO: Rigoberto Gonzalez Llanes',
'SOLICITO: Leonardo Hernández',
'FECHA: 15/08/2016',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_sacreportedetalletransaccionsucursal (cConvenio CHAR (5), cSucursal CHAR(4), dFechaIni DATE, dFechaFin DATE)

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
            SELECT {+INDEX(bdisac:sac_convenios idx_sac_convenios)} b.usuario, b.folio_suc, TRIM(a.nomconvenio) AS nomconvenio, b.referencia1, b.referencia2, b.importe_pago, b.importe_comision_convenio, b.iva_comision_convenio,
            b.importe_comision_cte, b.iva_comision_cte, b.forma_pago, b.cuenta_cargo, e.nombre
            --INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, deImportePago, deImpComisionConvenio, deIVAComisionConvenio, deImpComisionCte, deIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
            FROM bdisac:sac_convenios a, bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d, bdinteg:si_regional e
            WHERE b.fecha_pago >= dFechaIni
            AND b.fecha_pago <= dFechaFin
            AND a.numcategoria = b.numcategoria
            AND a.numconvenio = b.numconvenio
            AND b.id_sucursal = cSucursal
            AND b.status_cancelado <> 'S'
            AND flag_confirmacion_central = 1
            AND flag_confirmacion_sucursal = 1
            AND c.sucursal = b.id_sucursal
            AND d.plaza = c.plaza
            AND e.regional = d.regional
            INTO TEMP tmp_movs WITH NO LOG;
            --ORDER BY 3, 2 ASC
            FOREACH
                SELECT usuario, folio_suc, nomconvenio, referencia1, referencia2, importe_pago, importe_comision_convenio, iva_comision_convenio,
                    importe_comision_cte, iva_comision_cte, forma_pago, cuenta_cargo, nombre
                INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                FROM bdisac:tmp_movs ORDER BY folio_suc, nomconvenio

                RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                WITH RESUME;
            END FOREACH;
            DROP TABLE bdisac:tmp_movs;
        ELSE   --Un convenio y una sucursal
            FOREACH
                SELECT {+INDEX(bdisac:sac_convenios idx_sac_convenios)} b.usuario, b.folio_suc, TRIM(a.nomconvenio) AS nomconvenio, b.referencia1, b.referencia2, b.importe_pago, b.importe_comision_convenio, b.iva_comision_convenio,
                b.importe_comision_cte, b.iva_comision_cte, b.forma_pago, b.cuenta_cargo, e.nombre
                INTO cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                FROM bdisac:sac_convenios a, bdisac:sac_movimientoshistorial b, bdinteg:si_sucursales c, bdinteg:si_plazas d, bdinteg:si_regional e
                WHERE b.fecha_pago >= dFechaIni
                AND b.fecha_pago <= dFechaFin
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
                AND e.regional = d.regional

                ORDER BY 3  ASC
                RETURN cCodRet, cUsuario, cFolioSuc, cNomConvenio, cReferencia1, cReferencia2, mImportePago, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, cFormaPago, cCuentaCargo, cRegion
                WITH RESUME;
            END FOREACH;
        END IF;
    END IF;
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

CREATE PROCEDURE "informix".sp_repmen_remesasporsuc(pFecha DATE)
RETURNING
CHAR(5)		AS codigo_respuesta,
CHAR(80)	AS mensaje_respuesta;

	DEFINE iSqlErr              	INTEGER;
	DEFINE iIsamErr             	INTEGER;
	DEFINE cInfoErr             	CHAR(100);
	DEFINE cCodRet              	CHAR(5);
	DEFINE cMensaje					CHAR(80);	
	DEFINE cDescripcionINS			CHAR(100);		
	DEFINE cDescripcionGEN			CHAR(100);	
	DEFINE dFechaIni				DATE;		
	DEFINE dFechaFin				DATE;		
	DEFINE cMes						CHAR(2);
	DEFINE cAnio 					CHAR(4);
	DEFINE cRutaArch 				CHAR(100);
	DEFINE cStmt					LVARCHAR(1500);
	DEFINE cStatus					CHAR(1);

	DEFINE cNum_Sucursal			CHAR(4);
	DEFINE cEstado					CHAR(30);
	DEFINE ibts_num_ope_efe			INTEGER;
	DEFINE dbts_mon_tot_efe			DECIMAL(16,2);
	DEFINE ibts_num_ope_venabo		INTEGER;
	DEFINE dbts_mon_tot_venabo		DECIMAL(16,2);
	DEFINE ibts_num_ope_aboaut		INTEGER;
	DEFINE dbts_mon_tot_aboaut		DECIMAL(16,2);
	DEFINE iwu_num_ope_efe			INTEGER;
	DEFINE dwu_mon_tot_efe			DECIMAL(16,2);
	DEFINE iwu_num_ope_venabo		INTEGER;
	DEFINE dwu_mon_tot_efe_venabo	DECIMAL(16,2);
	DEFINE iwu_num_ope_aboaut		INTEGER;
	DEFINE dwu_mon_tot_aboaut		DECIMAL(16,2);
	DEFINE iov_num_ope_efe			INTEGER;
	DEFINE dov_mon_tot_efe			DECIMAL(16,2);
	DEFINE iov_num_ope_venabo		INTEGER;
	DEFINE dov_mon_tot_efe_venabo	DECIMAL(16,2);
	DEFINE iov_num_ope_aboaut		INTEGER;
	DEFINE dov_mon_tot_aboaut		DECIMAL(16,2);
	DEFINE ivg_num_ope_efe			INTEGER;
	DEFINE dvg_mon_tot_efe			DECIMAL(16,2);
	DEFINE ivg_num_ope_venabo		INTEGER;
	DEFINE dvg_mon_tot_efe_venabo	DECIMAL(16,2);
	DEFINE ivg_num_ope_aboaut		INTEGER;
	DEFINE dvg_mon_tot_aboaut		DECIMAL(16,2);
	DEFINE iapp_num_ope_efe			INTEGER;
	DEFINE dapp_mon_tot_efe			DECIMAL(16,2);
	DEFINE iapp_num_ope_venabo		INTEGER;
	DEFINE dapp_mon_tot_efe_venabo	DECIMAL(16,2);
	DEFINE iapp_num_ope_aboaut		INTEGER;
	DEFINE dapp_mon_tot_aboaut		DECIMAL(16,2);
	
	LET cCodRet  					= "00000";
	LET cMensaje 					= 'PROCESO EXITOSO';	
	LET cDescripcionINS		 		= 'Inserta info remesas para reporte mensual se ejecuta 4:00 hrs aprox.';
	LET cDescripcionGEN		 		= 'Genera reporte mensual de remesas por sucursal se ejecuta 4:00 hrs aprox.';
	LET dFechaIni					= DATE(1);		
	LET dFechaFin					= DATE(1);	
	LET cMes						= '';
	LET cAnio 					    = '';
	LET cRutaArch 					= '';
	LET cStmt						= '';
	LET cStatus						= '0';
	
	LET cNum_Sucursal				= '';
	LET cEstado						= '';
	LET ibts_num_ope_efe			= 0;
	LET dbts_mon_tot_efe			= 0;
	LET ibts_num_ope_venabo			= 0;
	LET dbts_mon_tot_venabo			= 0;
	LET ibts_num_ope_aboaut			= 0;
	LET dbts_mon_tot_aboaut			= 0;
	LET iwu_num_ope_efe				= 0;
	LET dwu_mon_tot_efe				= 0;
	LET iwu_num_ope_venabo			= 0;
	LET dwu_mon_tot_efe_venabo		= 0;
	LET iwu_num_ope_aboaut			= 0;
	LET dwu_mon_tot_aboaut			= 0;
	LET iov_num_ope_efe				= 0;
	LET dov_mon_tot_efe				= 0;
	LET iov_num_ope_venabo			= 0;
	LET dov_mon_tot_efe_venabo		= 0;
	LET iov_num_ope_aboaut			= 0;
	LET dov_mon_tot_aboaut			= 0;
	LET ivg_num_ope_efe				= 0;
	LET dvg_mon_tot_efe				= 0;
	LET ivg_num_ope_venabo			= 0;
	LET dvg_mon_tot_efe_venabo		= 0;
	LET ivg_num_ope_aboaut			= 0;
	LET dvg_mon_tot_aboaut			= 0;
	LET iapp_num_ope_efe			= 0;
	LET dapp_mon_tot_efe			= 0;
	LET iapp_num_ope_venabo			= 0;
	LET dapp_mon_tot_efe_venabo		= 0;
	LET iapp_num_ope_aboaut			= 0;
	LET dapp_mon_tot_aboaut			= 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_repmen_remesasporsuc");
                RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;				
		
		IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_jobs where proceso='INS_REM_REPMEN' and fecha_proceso = pFecha) THEN								
			--INSERTA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'INS_REM_REPMEN', pFecha, '0', 'informix', 'sp_repmen_remesasporsuc', cDescripcionINS);	
		ELSE
			SELECT status 
			INTO cStatus
			FROM bdisac:"informix".sac_procesos_jobs 
			WHERE proceso='INS_REM_REPMEN' and fecha_proceso = pFecha;
			IF cStatus = '0' THEN
				DELETE {+INDEX(bdisac:"informix".sac_totalremesasporsuc idxsac_totalremesasporsucfn)} FROM bdisac:"informix".sac_totalremesasporsuc WHERE fecha = pFecha;
			END IF;
		END IF;
		
		--SE EJECUTA SOLO SI NO HAY REGISTRO EXITOSO
		IF cStatus = '0' THEN			
			set isolation to dirty read;
			INSERT INTO bdisac:"informix".sac_totalremesasporsuc (fecha,num_sucursal,estado,bts_num_ope_efe,bts_mon_tot_efe,bts_num_ope_venabo,bts_mon_tot_venabo,
			bts_num_ope_aboaut,bts_mon_tot_aboaut,wu_num_ope_efe,wu_mon_tot_efe,wu_num_ope_venabo,wu_mon_tot_efe_venabo,wu_num_ope_aboaut,wu_mon_tot_aboaut,
			ov_num_ope_efe,ov_mon_tot_efe,ov_num_ope_venabo,ov_mon_tot_efe_venabo,ov_num_ope_aboaut,ov_mon_tot_aboaut,vg_num_ope_efe,vg_mon_tot_efe,vg_num_ope_venabo,
			vg_mon_tot_efe_venabo,vg_num_ope_aboaut,vg_mon_tot_aboaut,app_num_ope_efe,app_mon_tot_efe,app_num_ope_venabo,app_mon_tot_efe_venabo,app_num_ope_aboaut,
			app_mon_tot_aboaut)		
			SELECT pFecha AS fecha,
			a.sucursal AS num_sucursal, 
			CASE WHEN a.sucursal = '9250' THEN 'ABONO DIRECTO EN CUENTA BTS'
			WHEN a.sucursal = '9764' THEN 'ABONO DIRECTO EN CUENTA APP'
			ELSE NVL(m.nombre,'') END AS estado,
			NVL(b.num_operaciones,0) AS bts_num_ope_efe,
			NVL(b.monto_total,0) AS bts_mon_tot_efe,
			NVL(c.num_operaciones,0) AS bts_num_ope_venabo,
			NVL(c.monto_total,0) AS bts_mon_tot_venabo,
			NVL(d.num_operaciones,0) AS bts_num_ope_aboaut,
			NVL(d.monto_total,0) AS bts_mon_tot_aboaut,
			NVL(e.num_operaciones,0) AS wu_num_ope_efe, 
			NVL(e.monto_total,0) AS wu_mon_tot_efe,
			NVL(f.num_operaciones,0) AS wu_num_ope_venabo, 
			NVL(f.monto_total,0) AS wu_mon_tot_efe_venabo,
			0 AS wu_num_ope_aboaut,
			0 AS wu_mon_tot_aboaut,
			NVL(g.num_operaciones,0) AS ov_num_ope_efe,
			NVL(g.monto_total,0) AS ov_mon_tot_efe,
			NVL(h.num_operaciones,0) AS ov_num_ope_venabo,
			NVL(h.monto_total,0) AS ov_mon_tot_efe_venabo,
			0 AS ov_num_ope_aboaut,
			0 AS ov_mon_tot_aboaut,
			NVL(i.num_operaciones,0) AS vg_num_ope_efe,
			NVL(i.monto_total,0) AS vg_mon_tot_efe,
			NVL(j.num_operaciones,0) AS vg_num_ope_venabo,
			NVL(j.monto_total,0) AS vg_mon_tot_efe_venabo,
			0 AS vg_num_ope_aboaut,
			0 AS vg_mon_tot_aboaut,
			NVL(k.num_operaciones,0) AS app_num_ope_efe,
			NVL(k.monto_total,0) AS app_mon_tot_efe,
			NVL(l.num_operaciones,0) AS app_num_ope_venabo,
			NVL(l.monto_total,0) AS app_mon_tot_efe_venabo,
			NVL(n.num_operaciones,0) AS app_num_ope_aboaut,
			NVL(n.monto_total,0) AS app_mon_tot_aboaut		 
			FROM bdinteg:si_sucursales a 
			LEFT JOIN --BTS EFECTIVO
			TABLE (MULTISET(select a.sucursal as num_sucursal,count(*) as num_operaciones,sum(a.monto_tot) as monto_total from
			bdicheq:"informix".sc_movhis a, bdisac:"informix".sac_movimientoshistorial b
			where a.transacc = '1110'
			and a.empresa = '001'
			and a.cuenta = '16000000080'
			and a.cancelad <> 'S'
			and a.usuario <> 'sys_bts'
			and a.fech_alt = pFecha
			and a.folio_suc = b.folio_suc
			and a.sucursal = b.id_sucursal
			and b.numcategoria = '07'
			and b.numconvenio = '004'
			and b.fecha_pago = a.fech_alt
			and b.status_cancelado <> 'S'
			group by a.sucursal)) b
			ON a.sucursal = b.num_sucursal
			LEFT JOIN --BTS VENTANILLA ABONO CUENTA
			TABLE (MULTISET(select a.sucursal as num_sucursal,count(*) as num_operaciones,sum(a.monto_tot) as monto_total from
			bdicheq:"informix".sc_movhis a, bdisac:"informix".sac_movimientoshistorial b
			where a.transacc = '1140'
			and a.empresa = '001'
			and a.cuenta = '16000000080'
			and a.cancelad <> 'S'
			and a.usuario <> 'sys_bts'
			and a.fech_alt = pFecha
			and a.folio_suc = b.folio_suc
			and a.sucursal = b.id_sucursal
			and b.numcategoria = '07'
			and b.numconvenio = '004'
			and b.fecha_pago = a.fech_alt
			and b.status_cancelado <> 'S'
			and b.forma_pago = '4'
			group by a.sucursal)) c
			ON a.sucursal = c.num_sucursal
			LEFT JOIN --BTS ABONO CUENTA DIRECTA AUTOMATICA
			TABLE (MULTISET(select a.sucursal as num_sucursal,count(*) as num_operaciones,sum(a.monto_tot) as monto_total from
			bdicheq:"informix".sc_movhis a, bdisac:"informix".sac_movimientoshistorial b
			where a.transacc = '1140'
			and a.empresa = '001'
			and a.cuenta = '16000000080'
			and a.cancelad <> 'S'
			and a.usuario = 'sys_bts'
			and a.fech_alt = pFecha
			and a.folio_suc = b.folio_suc
			and a.sucursal = b.id_sucursal
			and b.numcategoria = '07'
			and b.numconvenio = '004'
			and b.fecha_pago = a.fech_alt
			and b.status_cancelado <> 'S'
			and b.forma_pago = '4'
			group by a.sucursal)) d
			ON a.sucursal = d.num_sucursal
			LEFT JOIN --WU EFECTIVO
			TABLE (MULTISET(select a.sucursal as num_sucursal,count(*) as num_operaciones,sum(a.monto_tot) as monto_total from
			bdicheq:"informix".sc_movhis a, bdisac:"informix".sac_movimientoshistorial b
			where a.transacc = '1121'
			and a.empresa = '001'
			and a.cuenta = '22000001574'
			and a.cancelad <> 'S'
			and a.fech_alt = pFecha
			and a.folio_suc = b.folio_suc
			and a.sucursal = b.id_sucursal
			and b.numcategoria = '07'
			and b.numconvenio = '006'
			and b.fecha_pago = a.fech_alt
			and b.status_cancelado <> 'S'
			group by a.sucursal)) e
			ON a.sucursal = e.num_sucursal
			LEFT JOIN --WU VENTANILLA ABONO CUENTA
			TABLE (MULTISET(select a.sucursal as num_sucursal,count(*) as num_operaciones,sum(a.monto_tot) as monto_total from
			bdicheq:"informix".sc_movhis a, bdisac:"informix".sac_movimientoshistorial b
			where a.transacc = '1151'
			and a.empresa = '001'
			and a.cuenta = '22000001574'
			and a.cancelad <> 'S'
			and a.fech_alt = pFecha
			and a.folio_suc = b.folio_suc
			and a.sucursal = b.id_sucursal
			and b.numcategoria = '07'
			and b.numconvenio = '006'
			and b.fecha_pago = a.fech_alt
			and b.status_cancelado <> 'S'
			and b.forma_pago = '4'
			group by a.sucursal)) f
			ON a.sucursal = f.num_sucursal
			LEFT JOIN --OV EFECTIVO
			TABLE (MULTISET(select a.sucursal as num_sucursal,count(*) as num_operaciones,sum(a.monto_tot) as monto_total from
			bdicheq:"informix".sc_movhis a, bdisac:"informix".sac_movimientoshistorial b
			where a.transacc = '1122'
			and a.empresa = '001'
			and a.cuenta = '22000001574'
			and a.cancelad <> 'S'
			and a.fech_alt = pFecha
			and a.folio_suc = b.folio_suc
			and a.sucursal = b.id_sucursal
			and b.numcategoria = '07'
			and b.numconvenio = '007'
			and b.fecha_pago = a.fech_alt
			and b.status_cancelado <> 'S'
			group by a.sucursal)) g
			ON a.sucursal = g.num_sucursal
			LEFT JOIN --OV VENTANILLA ABONO CUENTA
			TABLE (MULTISET(select a.sucursal as num_sucursal,count(*) as num_operaciones,sum(a.monto_tot) as monto_total from
			bdicheq:"informix".sc_movhis a, bdisac:"informix".sac_movimientoshistorial b
			where a.transacc = '1152'
			and a.empresa = '001'
			and a.cuenta = '22000001574'
			and a.cancelad <> 'S'
			and a.fech_alt = pFecha
			and a.folio_suc = b.folio_suc
			and a.sucursal = b.id_sucursal
			and b.numcategoria = '07'
			and b.numconvenio = '007'
			and b.fecha_pago = a.fech_alt
			and b.status_cancelado <> 'S'
			and b.forma_pago = '4'
			group by a.sucursal)) h
			ON a.sucursal = h.num_sucursal
			LEFT JOIN --VG EFECTIVO
			TABLE (MULTISET(select a.sucursal as num_sucursal,count(*) as num_operaciones,sum(a.monto_tot) as monto_total from
			bdicheq:"informix".sc_movhis a, bdisac:"informix".sac_movimientoshistorial b
			where a.transacc = '1123'
			and a.empresa = '001'
			and a.cuenta = '22000001574'
			and a.cancelad <> 'S'
			and a.fech_alt = pFecha
			and a.folio_suc = b.folio_suc
			and a.sucursal = b.id_sucursal
			and b.numcategoria = '07'
			and b.numconvenio = '008'
			and b.fecha_pago = a.fech_alt
			and b.status_cancelado <> 'S'
			group by a.sucursal)) i
			ON a.sucursal = i.num_sucursal
			LEFT JOIN --VG VENTANILLA ABONO CUENTA
			TABLE (MULTISET(select a.sucursal as num_sucursal,count(*) as num_operaciones,sum(a.monto_tot) as monto_total from
			bdicheq:"informix".sc_movhis a, bdisac:"informix".sac_movimientoshistorial b
			where a.transacc = '1153'
			and a.empresa = '001'
			and a.cuenta = '22000001574'
			and a.cancelad <> 'S'
			and a.fech_alt = pFecha
			and a.folio_suc = b.folio_suc
			and a.sucursal = b.id_sucursal
			and b.numcategoria = '07'
			and b.numconvenio = '008'
			and b.fecha_pago = a.fech_alt
			and b.status_cancelado <> 'S'
			and b.forma_pago = '4'
			group by a.sucursal)) j
			ON a.sucursal = j.num_sucursal
			LEFT JOIN --APP EFECTIVO
			TABLE (MULTISET(select a.sucursal as num_sucursal,count(*) as num_operaciones,sum(a.monto_tot) as monto_total from
			bdicheq:"informix".sc_movhis a, bdisac:"informix".sac_movimientoshistorial b
			where a.transacc = '1325'
			and a.empresa = '001'
			and a.cuenta = '16000000322'
			and a.cancelad <> 'S'
			and a.fech_alt = pFecha
			and a.folio_suc = b.folio_suc
			and a.sucursal = b.id_sucursal
			and b.numcategoria = '07'
			and b.numconvenio = '009'
			and b.fecha_pago = a.fech_alt
			and b.status_cancelado <> 'S'
			group by a.sucursal)) k
			ON a.sucursal = k.num_sucursal
			LEFT JOIN --APP VENTANILLA ABONO CUENTA
			TABLE (MULTISET(select a.sucursal as num_sucursal,count(*) as num_operaciones,sum(a.monto_tot) as monto_total from
			bdicheq:"informix".sc_movhis a, bdisac:"informix".sac_movimientoshistorial b
			where a.transacc = '1355'
			and a.empresa = '001'
			and a.cuenta = '16000000322'
			and a.cancelad <> 'S'
			and a.fech_alt = pFecha
			and a.folio_suc = b.folio_suc
			and a.sucursal = b.id_sucursal
			and b.numcategoria = '07'
			and b.numconvenio = '009'
			and b.fecha_pago = a.fech_alt
			and b.status_cancelado <> 'S'
			and b.forma_pago = '4'
			and b.usuario <> 'sys_apz'
			group by a.sucursal)) l
			ON a.sucursal = l.num_sucursal
			LEFT JOIN --APP ABONO DIRECTO EN CUENTA
			TABLE (MULTISET(select a.sucursal as num_sucursal,count(*) as num_operaciones,sum(a.monto_tot) as monto_total from
			bdicheq:"informix".sc_movhis a, bdisac:"informix".sac_movimientoshistorial b
			where a.transacc = '1355'
			and a.empresa = '001'
			and a.cuenta = '16000000322'
			and a.cancelad <> 'S'
			and a.fech_alt = pFecha
			and a.folio_suc = b.folio_suc
			and a.sucursal = b.id_sucursal
			and b.numcategoria = '07'
			and b.numconvenio = '009'
			and b.fecha_pago = a.fech_alt
			and b.status_cancelado <> 'S'
			and b.forma_pago = '4'			
			and b.usuario = 'sys_apz'
			group by a.sucursal)) n
			ON a.sucursal = n.num_sucursal
			INNER JOIN bdinteg:"informix".si_estados m ON a.estado = m.estado
			WHERE a.sucursal BETWEEN '0001' AND '4999' 
			AND a.tpo_sucursal = 'S'
			OR a.sucursal = '9250'
			OR a.sucursal = '9764'
			ORDER BY a.sucursal;
			
			set pdqpriority 0;
			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_totalremesasporsuc;
			--ACTUALIZA STATUS DE INSERTA INFO
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'INS_REM_REPMEN', pFecha, '1', 'informix', 'sp_repmen_remesasporsuc', cDescripcionINS);
		END IF;
		
		--GENERA EL REPORTE MENSUAL EL DIA 3 DE CADA MES
		IF DAY(pFecha) = 02 THEN
			--INSERTA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'GEN_REM_REPMEN', pFecha, '0', 'informix', 'sp_repmen_remesasporsuc', cDescripcionGEN);
			--OBTIENE EL PRIMER Y ULTIMO DIA DEL MES A GENERAR
			LET dFechaIni = mdy(MONTH(pFecha), 01, YEAR(pFecha))- 1 UNITS MONTH;
			LET dFechaFin = dFechaIni + 1 UNITS MONTH;			
			LET cMes = LPAD(MONTH(dFechaIni::DATE), 2, '0');
			LET cAnio = LPAD(YEAR(dFechaIni::DATE),4,'0');		
			--OBTIENE LA RUTA Y NOMBRE DEL ARCHIVO A GENERAR
			SELECT valor
			INTO cRutaArch
			FROM bdisac:"informix".sac_param
			WHERE cod_param = 113;
			
			--REEMPLAZA LA FECHA EN EL NOMBRE DEL ARCHIVO
			LET cRutaArch = REPLACE(cRutaArch,'aaaa',cAnio);
			LET cRutaArch = REPLACE(cRutaArch,'mm',cMes);			

			--GENERA ENCABEZADO
			LET cStmt = 'echo "' || "No. Sucursal" || "|" || "ESTADO" || "|" || "BTS # OPERACIONES EFECTIVO" || "|" || "BTS MONTO TOTAL EFECTIVO" || "|" || "BTS # OPERACIONES ABONO VENTANILLA" || "|" || "BTS MONTO TOTAL ABONO VENTANILLA" || "|" || "BTS # OPERACIONES ABONO DIRECTO EN CUENTA" || "|" || "BTS MONTO TOTAL ABONO DIRECTO EN CUENTA" || "|" || "WU # OPERACIONES EFECTIVO" || "|" || "WU MONTO TOTAL EFECTIVO" || "|" || "WU # OPERACIONES ABONO VENTANILLA" || "|" || "WU MONTO TOTAL ABONO VENTANILLA" || "|" || "WU # OPERACIONES ABONO DIRECTO EN CUENTA" || "|" || "WU MONTO TOTAL ABONO DIRECTO EN CUENTA" || "|" || "OV # OPERACIONES EFECTIVO" || "|" || "OV MONTO TOTAL EFECTIVO" || "|" || "OV # OPERACIONES ABONO VENTANILLA" || "|" || "OV MONTO TOTAL ABONO VENTANILLA" || "|" || "OV # OPERACIONES ABONO DIRECTO EN CUENTA" || "|" || "OV MONTO TOTAL ABONO DIRECTO EN CUENTA" || "|" || "VG # OPERACIONES EFECTIVO" || "|" || "VG MONTO TOTAL EFECTIVO" || "|" || "VG # OPERACIONES ABONO VENTANILLA" || "|" || "VG MONTO TOTAL ABONO VENTANILLA" || "|" || "VG # OPERACIONES ABONO DIRECTO EN CUENTA" || "|" || "VG MONTO TOTAL ABONO DIRECTO EN CUENTA" || "|" || "APP # OPERACIONES EFECTIVO" || "|" || "APP MONTO TOTAL EFECTIVO" || "|" || "APP # OPERACIONES ABONO VENTANILLA" || "|" || "APP MONTO TOTAL ABONO VENTANILLA" || "|" || "APP # OPERACIONES ABONO DIRECTO EN CUENTA" || "|" || "APP MONTO TOTAL ABONO DIRECTO EN CUENTA" || '" > ' || cRutaArch;			
			SYSTEM cStmt;			
			
			FOREACH
				SELECT num_sucursal,estado,SUM(bts_num_ope_efe),SUM(bts_mon_tot_efe),SUM(bts_num_ope_venabo),SUM(bts_mon_tot_venabo),
					SUM(bts_num_ope_aboaut), SUM(bts_mon_tot_aboaut),SUM(wu_num_ope_efe),SUM(wu_mon_tot_efe),SUM(wu_num_ope_venabo),SUM(wu_mon_tot_efe_venabo),SUM(wu_num_ope_aboaut),SUM(wu_mon_tot_aboaut),
					SUM(ov_num_ope_efe),SUM(ov_mon_tot_efe),SUM(ov_num_ope_venabo),SUM(ov_mon_tot_efe_venabo),SUM(ov_num_ope_aboaut),SUM(ov_mon_tot_aboaut),SUM(vg_num_ope_efe),SUM(vg_mon_tot_efe),SUM(vg_num_ope_venabo),
					SUM(vg_mon_tot_efe_venabo),SUM(vg_num_ope_aboaut),SUM(vg_mon_tot_aboaut),SUM(app_num_ope_efe),SUM(app_mon_tot_efe),SUM(app_num_ope_venabo),SUM(app_mon_tot_efe_venabo),SUM(app_num_ope_aboaut),
					SUM(app_mon_tot_aboaut)
				INTO cNum_Sucursal, cEstado, ibts_num_ope_efe, dbts_mon_tot_efe, ibts_num_ope_venabo, dbts_mon_tot_venabo, ibts_num_ope_aboaut, dbts_mon_tot_aboaut, iwu_num_ope_efe,			
					dwu_mon_tot_efe, iwu_num_ope_venabo, dwu_mon_tot_efe_venabo, iwu_num_ope_aboaut, dwu_mon_tot_aboaut, iov_num_ope_efe, dov_mon_tot_efe, iov_num_ope_venabo,		
					dov_mon_tot_efe_venabo,	iov_num_ope_aboaut,	dov_mon_tot_aboaut,	ivg_num_ope_efe, dvg_mon_tot_efe, ivg_num_ope_venabo, dvg_mon_tot_efe_venabo, ivg_num_ope_aboaut,		
					dvg_mon_tot_aboaut, iapp_num_ope_efe, dapp_mon_tot_efe,	iapp_num_ope_venabo, dapp_mon_tot_efe_venabo, iapp_num_ope_aboaut, dapp_mon_tot_aboaut
				FROM bdisac:"informix".sac_totalremesasporsuc
				WHERE fecha >= dFechaIni
				AND fecha < dFechaFin
				GROUP BY num_sucursal, estado
				ORDER BY num_sucursal
				
				--GENERA ENCABEZADO
				LET cStmt = 'echo "' || NVL(TRIM(cNum_Sucursal),'') || "|" || NVL(TRIM(cEstado),'') || "|" || NVL(ibts_num_ope_efe,0) || "|" || NVL(dbts_mon_tot_efe,0) || "|" || NVL(ibts_num_ope_venabo,0) || "|" || NVL(dbts_mon_tot_venabo,0) || "|" || NVL(ibts_num_ope_aboaut,0) || "|" || NVL(dbts_mon_tot_aboaut,0) || "|" || NVL(iwu_num_ope_efe,0) || "|" || NVL(dwu_mon_tot_efe,0) || "|" || NVL(iwu_num_ope_venabo,0) || "|" || NVL(dwu_mon_tot_efe_venabo,0) || "|" || " " || "|" || " " || "|" || NVL(iov_num_ope_efe,'') || "|" || NVL(dov_mon_tot_efe,0) || "|" || NVL(iov_num_ope_venabo,0) || "|" || NVL(dov_mon_tot_efe_venabo,0) || "|" || " " || "|" || " " || "|" || NVL(ivg_num_ope_efe,0) || "|" || NVL(dvg_mon_tot_efe,0) || "|" || NVL(ivg_num_ope_venabo,0) || "|" || NVL(dvg_mon_tot_efe_venabo,0) || "|" || " " || "|" || " " || "|" || NVL(iapp_num_ope_efe,0) || "|" || NVL(dapp_mon_tot_efe,0) || "|" || NVL(iapp_num_ope_venabo,0) || "|" || NVL(dapp_mon_tot_efe_venabo,0) || "|" || NVL(iapp_num_ope_aboaut,0) || "|" || NVL(dapp_mon_tot_aboaut,0) || '" >> ' || cRutaArch;
				SYSTEM cStmt;
			
			END FOREACH;
			--ACTUALIZA STATUS DE GENERA REPORTE
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'GEN_REM_REPMEN', pFecha, '1', 'informix', 'sp_repmen_remesasporsuc', cDescripcionGEN);
			
		END IF;
		
		RETURN cCodRet, cMensaje;

	END;
END PROCEDURE;