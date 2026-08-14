CREATE PROCEDURE "informix".sp_dinya_calcularcomisioniva_bei (pCategoria CHAR(2), pConvenio CHAR(3), pMonto MONEY)
	RETURNING  CHAR(5) ,MONEY, MONEY ,MONEY, CHAR(1), MONEY;

	DEFINE cCodRet 				CHAR(5);
	DEFINE mMontoMax			MONEY;
	DEFINE mMontoMin			MONEY;
	DEFINE mIva					MONEY;
	DEFINE mComision			MONEY;
	DEFINE mTotIvaComision		MONEY;
	DEFINE cTipo				CHAR(1);
	DEFINE iSqlErr				INTEGER;
	DEFINE isam_error			INTEGER;
	
	
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_dinya_calcularcomisioniva_bei.out";
	--TRACE ON;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr,isam_error
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
			END IF;
		END EXCEPTION;

		LET cCodRet 				= '00000';
		LET mMontoMax				= '0.00';
		LET mMontoMin				= '0.00';
		LET mIva					= 0;
		LET mComision				= '0.00';
		LET mTotIvaComision			= '0.00';
		LET cTipo					= '';
		LET iSqlErr					= 0;
		LET isam_error				= 0;


		IF pCategoria IS NULL OR pConvenio IS NULL THEN
			LET cCodRet = '00001';
			RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
		END IF;
		
		IF  pMonto = 0.0 THEN
		
			FOREACH
				SELECT montomaximo, iva_comcte, comision_cte, tipo 
				INTO mMontoMax, mIva, mComision, cTipo
				FROM bdisac:"informix".sac_comisiones_x_canal 
				WHERE numcategoria = pCategoria
				AND numconvenio = pConvenio and cve_canal = '15'
				
				IF mMontoMax IS NULL OR mIva IS NULL OR mComision IS NULL OR cTipo IS NULL THEN
					LET cCodRet = '00001';
					RETURN cCodRet, mMontoMax, mIva, mComision, cTipo, mTotIvaComision WITH RESUME ;
				END IF;
				
				
				IF cTipo = 1 THEN
					LET mComision = mComision;
				END IF;
				
				LET mIva = mIva/100;
				
				RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision WITH RESUME;
				
			END FOREACH;
		
		ELSE 
			
			FOREACH
				SELECT montominimo, montomaximo, iva_comcte, comision_cte, tipo 
				INTO mMontoMin, mMontoMax, mIva, mComision, cTipo
				FROM bdisac:"informix".sac_comisiones_x_canal 
				WHERE numcategoria = pCategoria
				AND numconvenio = pConvenio and cve_canal = '15'
				
				IF mMontoMax IS NULL OR mIva IS NULL OR mComision IS NULL OR cTipo IS NULL THEN
					LET cCodRet = '00001';
					--RETURN cCodRet, mMontoMax, mIva, mComision, cTipo, mTotIvaComision WITH RESUME ;
				END IF;
				
				IF pMonto <= mMontoMax AND pMonto >= mMontoMin THEN
					
					IF cTipo = 1 THEN
						LET mComision = mComision;
					END IF;
					
					LET mIva = mComision * (mIva/100);
					LET mTotIvaComision = mIva + mComision;
				
					EXIT FOREACH;
					--RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision WITH RESUME;
					
				END IF;
				
			END FOREACH;
			
			RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
		END IF ;
	END
END PROCEDURE
Document
'DESCRIPCION: Calcula el IVA y Comision de un importe y regresa las comisiones para Ordenes de Pago para EmpresaNEt', 
'AUTOR: Bibiana Gaxiola',
'FECHA: 03/03/2015',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_dinya_calcularcomisioniva_bpi (pCategoria CHAR(2), pConvenio CHAR(3), pMonto MONEY)
	RETURNING  CHAR(5) ,MONEY, MONEY ,MONEY, CHAR(1), MONEY;
	DEFINE cCodRet 				CHAR(5);
	DEFINE mMontoMax			MONEY;
	DEFINE mMontoMin			MONEY;
	DEFINE mIva					MONEY;
	DEFINE mComision			MONEY;
	DEFINE mTotIvaComision		MONEY;
	DEFINE cTipo				CHAR(1);
	DEFINE iSqlErr				INTEGER;
	DEFINE isam_error			INTEGER;


	--SET DEBUG FILE TO "/home/sysifx/ilse/sp_dinya_calcularcomisioniva_bpi.out";
	--TRACE ON;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	BEGIN
		ON EXCEPTION SET iSqlErr,isam_error
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
			END IF;
		END EXCEPTION;
		LET cCodRet 				= '00000';
		LET mMontoMax				= '0.00';
		LET mMontoMin				= '0.00';
		LET mIva					= 0;
		LET mComision				= '0.00';
		LET mTotIvaComision			= '0.00';
		LET cTipo					= '';
		LET iSqlErr					= 0;
		LET isam_error				= 0;
		IF pCategoria IS NULL OR pConvenio IS NULL THEN
			LET cCodRet = '00001';
			RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
		END IF;

		IF  pMonto = 0.0 THEN

			FOREACH
				SELECT montomaximo, iva_comcte, comision_cte, tipo
				INTO mMontoMax, mIva, mComision, cTipo
				FROM bdisac:"informix".sac_comisiones_x_canal
				WHERE numcategoria = pCategoria
				AND numconvenio = pConvenio and cve_canal = '3'

				IF mMontoMax IS NULL OR mIva IS NULL OR mComision IS NULL OR cTipo IS NULL THEN
					LET cCodRet = '00001';
					RETURN cCodRet, mMontoMax, mIva, mComision, cTipo, mTotIvaComision WITH RESUME ;
				END IF;


				IF cTipo = 1 THEN
					LET mComision = mComision;
				END IF;

				-- COMISION CON %
				IF cTipo = 2 THEN
					LET mComision = mComision/100;
				END IF;

				LET mIva = mIva/100;

				RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision WITH RESUME;

			END FOREACH;

		ELSE

			FOREACH
				SELECT montominimo, montomaximo, iva_comcte, comision_cte, tipo
				INTO mMontoMin, mMontoMax, mIva, mComision, cTipo
				FROM bdisac:"informix".sac_comisiones_x_canal
				WHERE numcategoria = pCategoria
				AND numconvenio = pConvenio

				IF mMontoMax IS NULL OR mIva IS NULL OR mComision IS NULL OR cTipo IS NULL THEN
					LET cCodRet = '00001';
					--RETURN cCodRet, mMontoMax, mIva, mComision, cTipo, mTotIvaComision WITH RESUME ;
				END IF;

				IF pMonto <= mMontoMax AND pMonto >= mMontoMin THEN

					IF cTipo = 1 THEN
						LET mComision = mComision;
					END IF;

					-- COMISION EN %
					IF cTipo = 2 THEN
						LET mComision = pMonto * (mComision/100);

					END IF;
					LET mIva = mComision * (mIva/100);
					LET mTotIvaComision = mIva + mComision;

					EXIT FOREACH;
					--RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision WITH RESUME;

				END IF;

			END FOREACH;

			RETURN cCodRet,mMontoMax,mIva,mComision,cTipo, mTotIvaComision;
		END IF ;
	END
END PROCEDURE
Document
'DESCRIPCION: Calcula el IVA y Comision de un importe y regresa las comisiones para Ordenes de Pago',
'AUTOR: Ilse Gómez',
'FECHA: 15 de enero de 2015',
'VERSION: 20141216.0900',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_dinya_insertaenvios3 
	(mMontoEnvio MONEY(16,2),
	pMontoCargo MONEY(16,2),
	pCuentaCargo CHAR(20),
	pSucursal CHAR(4),
	cEjecutivo CHAR(8),
	pFolioSuc CHAR(16))

	RETURNING  CHAR(5), CHAR(16);

	DEFINE cCodRet 			 		CHAR(5);
	DEFINE iSqlErr			 		INTEGER;
	DEFINE cCuentaPrestadora 		CHAR(20);
	DEFINE cTransaccAbonoEnvio		CHAR(4);
	DEFINE cTransaccAbonoIva		CHAR(4);
	DEFINE cTransaccAbonoComision	CHAR(4);
	DEFINE mTotComision				MONEY (16,2);
	DEFINE mTotIVA					MONEY (16,2);
	DEFINE mTotIvaComision			MONEY (16,2);
	DEFINE pImporte					MONEY (16,2);
	DEFINE mTotalaCobrar			MONEY (16,2);
	DEFINE cTransaccSuc				CHAR(4);
	DEFINE cTransaccCargoEnvio 		CHAR(4);
	DEFINE ctranret					CHAR(4);
	DEFINE dfechoy					DATE;
	DEFINE msdodisp					MONEY (14,2);
	DEFINE mmontoret				MONEY (14,2);
	DEFINE dFecha_hoy				DATE;
	DEFINE isam_error				INTEGER;
	DEFINE cDescripcion				CHAR(200);
	DEFINE cTransaccCargoiva		CHAR(4);
	DEFINE cTransaccCargocomi		CHAR(4);
	DEFINE cTransaccCargocomiCte	CHAR(4);
	DEFINE cTransaccCargoivaCte		CHAR(4);

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (iSqlErr,isam_error,cDescripcion,'sp_dinya_insertaenvios3',dFecha_hoy,CURRENT );
				RETURN cCodRet, pFolioSuc;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/home/informix/bibiana/sp_dinya_InsertaEnvios3.out";
		--TRACE ON;

		LET cCodRet 			   = '00000';
		LET iSqlErr			 	   = 0;
		LET cCuentaPrestadora 	   = '';
		LET cTransaccAbonoEnvio	   = '';
		LET cTransaccAbonoIva	   = '';
		LET cTransaccAbonoComision = '';
		LET mTotComision		   = '';
		LET mTotIVA				   = '';
		LET mTotIvaComision 	   = '';
		LET pImporte			   = '';
		LET mTotalaCobrar		   = '';	
		LET cTransaccSuc		   = '';
		LET cTransaccCargoEnvio	   = '';
		LET ctranret			   = '';
		LET dfechoy				   = '';
		LET msdodisp			   = '';
		LET mmontoret			   = '';
		LET dFecha_hoy			   = '';
		LET isam_error			   = '';
		LET cDescripcion		   = '';
		LET cTransaccCargoiva	='';
		LET cTransaccCargocomi	='';
		LET cTransaccCargocomiCte	='';
		LET cTransaccCargoivaCte		='';

		--Obtiene parametros
		SELECT valor INTO cCuentaPrestadora
		FROM Bdisac:sac_param
		WHERE cod_param='75';

		SELECT valor INTO cTransaccAbonoEnvio
		FROM Bdisac:sac_param
		WHERE cod_param='5070012';

		SELECT valor INTO cTransaccCargoEnvio
		FROM Bdisac:sac_param
		WHERE cod_param='414070021';

		SELECT valor INTO cTransaccAbonoComision
		FROM Bdisac:sac_param
		WHERE cod_param='511070012';

		SELECT valor INTO cTransaccAbonoIva
		FROM Bdisac:sac_param
		WHERE cod_param='510070012';

		SELECT valor INTO cTransaccSuc
		FROM Bdisac:sac_param
		WHERE cod_param='807001';	

		SELECT valor INTO cTransaccCargocomiCte
		FROM Bdisac:sac_param
		WHERE cod_param='413070011';

		SELECT valor INTO cTransaccCargoivaCte
		FROM Bdisac:sac_param
		WHERE cod_param='4070011';

		SELECT valor INTO cTransaccCargocomi
		FROM Bdisac:sac_param
		WHERE cod_param='413070012';

		SELECT valor INTO cTransaccCargoiva
		FROM Bdisac:sac_param
		WHERE cod_param='4070012';		
		
		SELECT fecha_hoy 
		INTO dFecha_hoy
		FROM Bdisac:sac_fechas;			

		
		IF pSucursal = '5003' THEN

			--Calcula la comision e Iva bpi
			CALL  bdisac:"informix".sp_dinya_calcularcomisioniva_bpi ('07', '001', mMontoEnvio)
			RETURNING cCodRet,pImporte,mTotIVA,mTotComision,mTotalaCobrar,mTotIvaComision;  
			
			LET mTotalaCobrar=pImporte+mTotIvaComision;
			
		ELIF pSucursal = '5008' THEN
		
			CALL  bdisac:"informix".sp_dinya_calcularcomisioniva_bei ('07', '001', mMontoEnvio)
			RETURNING cCodRet,pImporte,mTotIVA,mTotComision,mTotalaCobrar,mTotIvaComision;  
			
			LET mTotalaCobrar=pImporte+mTotIvaComision;	
			
		ELSE
		
			--Calcula la comision e Iva
			CALL  bdisac:sp_DinYa_CalcularComisionIva ('07001',mMontoEnvio,pSucursal)
			RETURNING cCodRet,mTotComision,mTotIVA,mTotIvaComision,pImporte,mTotalaCobrar;
			
		END IF;
		
		IF cCodRet <> 0 THEN
			LET cCodRet = '00015'; --Error en el calculo de comision e iva
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Cargo a la cuenta del cte por orden de pago	
		LET pMontoCargo= pMontoCargo- mTotIvaComision;
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoEnvio, cTransaccSuc, pFolioSuc, 
		pCuentaCargo, 0, pMontoCargo,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
			LET cCodRet = '00016'; --Error en el cargo de el importe
			RETURN cCodRet,pFolioSuc;
		END IF;	

		--Abono a la cuenta prestadora de servicios por el monto del Envio
		CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoEnvio, cTransaccSuc , pFolioSuc, 
		cCuentaPrestadora,0, pMontoCargo, mMontoEnvio, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;  

		IF cCodRet <> 0 THEN
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00017'; --Error en el abono de el importe
			RETURN cCodRet,pFolioSuc;
		END IF;		
		
		--Cargo a la cte del cliente por el monto de la comision
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargocomiCte, cTransaccSuc, pFolioSuc, 
		pCuentaCargo, 0, mTotComision,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00018'; --Error en el cargo de la comision
			RETURN cCodRet,pFolioSuc;
		END IF;
		
		--Abono a la cuenta receptora (Comision)
		CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoComision ,cTransaccSuc , pFolioSuc, 
		cCuentaPrestadora,0, mTotComision, mTotComision, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00019'; --Error en el abono de la comision
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Cargo a la cuenta del cliente por el Iva			
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoivaCte, cTransaccSuc, pFolioSuc, 
		pCuentaCargo, 0, mTotIVA,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
			LET cCodRet = '00020'; --Error en el cargo por el Iva
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Abono a la cuenta receptora (Iva)
		CALL bdicheq:abono_ref ("001", pSucursal, cEjecutivo, cTransaccAbonoIva , cTransaccSuc , pFolioSuc, 
		cCuentaPrestadora,0, mTotIVA, mTotIVA, 0, 0, 0, "01", " ", '', cEjecutivo) Returning cCodRet;
		
		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion del abono y cargo
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;	
			LET cCodRet = '00021'; --Error en el abono del iva
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Cargo a la cuenta prestadora por la comision			
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargocomi, cTransaccSuc, pFolioSuc, 
		cCuentaPrestadora, 0, mTotComision,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
			LET cCodRet = '00023'; --Error en el cargo por el Iva
			RETURN cCodRet,pFolioSuc;
		END IF;

		--Cargo a la cuenta prestadora por el iva		
		CALL bdicheq:cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoiva, cTransaccSuc, pFolioSuc, 
		cCuentaPrestadora, 0, mTotIVA,"01", " ", '', cEjecutivo) 
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
		--LLamado a realizar la reversion.
			CALL bdicheq:reversion ('001', pSucursal, cEjecutivo,pFolioSuc, "M") Returning cCodRet;		
			LET cCodRet = '00024'; --Error en el cargo por el Iva
			RETURN cCodRet,pFolioSuc;
		END IF;
		
		RETURN cCodRet,pFolioSuc; 

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: GENERA EL ENVIO CON PAGO CON CARGO A CUENTA DE MONTO ENVIO, COMISION E IVA, ACTIVA ENVIO EN SAC_ENVIOSDINEROYA', 
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'FECHA: DICIEMBRE 2009',
'VERSION: 20100125.1024',
'MODIFICACION: Se agrega validacion para ejecutar el sp sp_dinya_calcularcomisioniva_bpi cuando se realize una orden de pago desde la BPI', 
'AUTOR: Ilse Gomez',
'FECHA: 15 de enero de 2015',
'VERSION: 20141216.0900',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_sac_pasemovshistorial()
    RETURNING CHAR(5), char(10);  --Códigos de retorno

DEFINE cCodRet                      CHAR(5);
DEFINE vfecha_insert                DATETIME YEAR to FRACTION(5);
DEFINE vtotregshist                 CHAR (40);
DEFINE iSqlErr                      INTEGER;
DEFINE iContBorra                   INTEGER;
DEFINE vmax_fechaold                DATE;
DEFINE vfecharesp                   DATE;
DEFINE vfechacomp                   DATE;
DEFINE  Cid_sucursal               	CHAR(4);
DEFINE  Cnumcategoria              	CHAR(2);
DEFINE  Cnumconvenio               	CHAR(5);
DEFINE  Creferencia1               	CHAR(40);
DEFINE  Creferencia2               	CHAR(40);
DEFINE  Cforma_pago                	CHAR(1);
DEFINE  Mimporte_pago              	MONEY;
DEFINE  Mimporte_comision_convenio 	MONEY;
DEFINE  Miva_comision_convenio     	MONEY;
DEFINE  Mimporte_comision_cte      	MONEY;
DEFINE  Miva_comision_cte          	MONEY;
DEFINE  Ccuenta_cargo              	CHAR(12);
DEFINE  Cusuario                   	CHAR(8);
DEFINE  Cfolio_suc                 	CHAR(16);
DEFINE  Ctransacc_suc              	CHAR(4);
DEFINE  Sflag_confirmacion_central 	SMALLINT;
DEFINE  Sflag_confirmacion_sucursal	SMALLINT;
DEFINE  Dfecha_pago                	DATE;
DEFINE  Dfecha_insert              	DATETIME YEAR to FRACTION(3);
DEFINE  Cstatus_cancelado          	CHAR(1);

 --SET DEBUG FILE TO "/informix/EPG/sp_sac_pasemovshistorial.out";
 --TRACE ON;

 LET cCodRet                    = '00000';
LET vfecha_insert               = CURRENT;
LET vtotregshist                = '0000000000000000000000000000000000000000';
LET iSqlErr                     = 0;
LET iContBorra                  = 0;
LET vmax_fechaold               = '';
LET vfecharesp                  = '';
LET vfechacomp                  = '';
LET Cid_sucursal                ='';
LET Cnumcategoria               ='';
LET Cnumconvenio                ='';
LET Creferencia1                ='';
LET Creferencia2                ='';
LET Cforma_pago                 ='';
LET Mimporte_pago               = 0;
LET Mimporte_comision_convenio  = 0;
LET Miva_comision_convenio      = 0;
LET Mimporte_comision_cte       = 0;
LET Miva_comision_cte           = 0;
LET Ccuenta_cargo               ='';
LET Cusuario                    ='';
LET Cfolio_suc                  ='';
LET Ctransacc_suc               ='';
LET Sflag_confirmacion_central  ='';
LET Sflag_confirmacion_sucursal ='';
LET Dfecha_pago                 ='';
LET Dfecha_insert               ='';
LET Cstatus_cancelado           ='';

BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, vtotregshist;
		END IF;
   END EXCEPTION;
	
	SELECT MAX (fecha_pago) INTO vmax_fechaold
	  FROM "c92357113".sac_movimientoshistorial_old;
	
	let vfecharesp = vmax_fechaold + 1;
	let vfechacomp = TODAY - 91;

  SELECT COUNT({+INDEX ("informix".sac_movimientoshistorial)}referencia1) 
	INTO vtotregshist 
	FROM "informix".sac_movimientoshistorial
   WHERE fecha_pago BETWEEN vfecharesp AND vfechacomp;

  FOREACH cursor_borra WITH HOLD FOR
		
		 SELECT id_sucursal, numcategoria, numconvenio, referencia1, referencia2, forma_pago, importe_pago, importe_comision_convenio,
				iva_comision_convenio, importe_comision_cte, iva_comision_cte, cuenta_cargo, usuario, folio_suc, transacc_suc,
				flag_confirmacion_central, flag_confirmacion_sucursal, fecha_pago, fecha_insert, status_cancelado
		   INTO	Cid_sucursal, Cnumcategoria, Cnumconvenio, Creferencia1, Creferencia2, Cforma_pago, Mimporte_pago, Mimporte_comision_convenio,
				Miva_comision_convenio, Mimporte_comision_cte, Miva_comision_cte, Ccuenta_cargo, Cusuario, Cfolio_suc, Ctransacc_suc,
				Sflag_confirmacion_central, Sflag_confirmacion_sucursal, Dfecha_pago, Dfecha_insert, Cstatus_cancelado
           FROM "informix".sac_movimientoshistorial
          WHERE fecha_pago >= vfecharesp
		    AND fecha_pago <= vfechacomp

		IF iContBorra = 0 THEN
		   BEGIN WORK;
		END IF;
		
		INSERT INTO "c92357113".sac_movimientoshistorial_old VALUES (Cid_sucursal, Cnumcategoria, Cnumconvenio, Creferencia1, Creferencia2, Cforma_pago, 
				Mimporte_pago, Mimporte_comision_convenio,Miva_comision_convenio, Mimporte_comision_cte, Miva_comision_cte, Ccuenta_cargo, Cusuario, 
				Cfolio_suc, Ctransacc_suc,Sflag_confirmacion_central, Sflag_confirmacion_sucursal, Dfecha_pago, Dfecha_insert, Cstatus_cancelado);
         
		DELETE FROM "informix".sac_movimientoshistorial WHERE numcategoria = Cnumcategoria AND numconvenio = Cnumconvenio AND fecha_pago = Dfecha_pago AND folio_suc = Cfolio_suc;

		LET iContBorra = iContBorra + 1;

		IF iContBorra = 1000 THEN
		   COMMIT WORK;
		   LET iContBorra = 0;
		END IF;
  
  END FOREACH;

  IF iContBorra < 1000 AND vtotregshist > 0 THEN
     COMMIT WORK;
  END IF;

END;
RETURN cCodRet, vtotregshist;
END PROCEDURE
DOCUMENT
'AUTOR : EPG',
'DESCRIPCION: Elimina registros de tabla bdisac:"informix".sac_movimientoshistorial por medio de cursor',
'y los respalda en bdisac:"informix".sac_movimientoshistorial_old.',
'EJECUTADO O LLAMADO POR: Proceso especial (se ejecuta por script en casos especiales).',
'FECHA : Abril/2014',
'VERSION: 20140413',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_envpag_valmontmax
(
	pModalidad   SMALLINT,  	--Modalidad
	pImporte     MONEY(14,2),  	--Monto a enviar-recibir
	pNombre1   	 CHAR (26), 	--nombre cliente-usuario
	pNombre2	 CHAR (26),
	pApellidoPat CHAR (26),
	pApellidoMat CHAR (26)
)

RETURNING CHAR (6) AS cCodRet;

	DEFINE cCodRet				CHAR(6);
	DEFINE iSqlErr 		  		INTEGER;
	DEFINE mLimite_envio  		MONEY(14,2);
	DEFINE iDias_limit   		INTEGER;
	DEFINE dtFecha_hoy   		DATE;
	DEFINE dtFecha_limit 		DATE;
	DEFINE mImporte_ya	 		MONEY(14,2);
	DEFINE mImporte_yahis 		MONEY(14,2);
	DEFINE mImporte_ya_movhis 	MONEY(14,2);
		
	LET cCodRet		 			= '000000';
	LET iSqlErr 				= 0;
	LET mLimite_envio   		= 0.00;
	LET iDias_limit     		= 0;
	LET dtFecha_hoy     		= DATE(1);
	LET dtFecha_limit   		= DATE(1);
	LET mImporte_ya				= 0.00;
	LET mImporte_yahis			= 0.00;
	LET mImporte_ya_movhis		= 0.00;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/adrian/sp_envpag_valmontmax_aia.out';
		--TRACE ON;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;  		
				
		IF NVL(pModalidad,0) NOT IN (1,2) OR NVL(pNombre1,'') ='' OR NVL(pApellidoPat,'') ='' THEN 
			LET cCodRet = '000001';
			RETURN cCodRet;
		END IF;
		
		-- BUSCANDO LA CANTIDAD LIMITE PERMITIDA
		SELECT NVL(valor,0) 
		INTO mLimite_envio
		FROM "informix".sac_param 
		WHERE cod_param = '6070033';
		
		/*
		-- BUSCANDO LOS DIAS LIMITES PARA EL CALCULO DE LA FECHA RANGO
		SELECT NVL(valor,0) 
		INTO iDias_limit
		FROM "informix".sac_param 
		WHERE cod_param = '6070034';
		*/
		
		--CONSULTAR FECHAHOY
		SELECT fecha_hoy 
		INTO dtFecha_hoy
		FROM "informix".sac_fechas
		WHERE empresa ='001';		
		
		--OBTENER FECHA LIMITE
		LET dtFecha_limit = MDY(MONTH(dtFecha_hoy),01,YEAR(dtFecha_hoy));
		
		-- ASEGURANDO DATOS EN MAYUSCULA
		LET pNombre1 = UPPER(pNombre1);
		LET pNombre2 = UPPER(pNombre2);
		LET pApellidoPat = UPPER(pApellidoPat);
		LET pApellidoMat = UPPER(pApellidoMat);		
		
		--ENVIO DE LA ORDEN DEL PAGO
		IF NVL(pImporte, 0) = 0 THEN
				LET cCodRet = '000001';
				RETURN cCodRet;
			END IF;
			
		IF pModalidad = 1 THEN							
			-- BUSCANDO LA SUMATORIA DE MOVIMIENTOS DE PAGOS EN EFECTIVO PARA EL ORDENANTE				
			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_envio,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientos WHERE numcategoria ='07' AND numconvenio ='001' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8701') THEN importe_envio END),0)
			INTO mImporte_ya
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_rem = pNombre1
			AND envio.seg_nom_rem = pNombre2
			AND envio.apell_pat_rem = pApellidoPat
			AND envio.apell_mat_rem = pApellidoMat;
			
			SELECT NVL(SUM(CASE WHEN NVL(enviohis.importe_envio,0) <> 0 AND enviohis.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='001' AND referencia1 = enviohis.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1'  AND transacc_suc  = '8701') THEN importe_envio END),0)
			INTO mImporte_yahis
			FROM "informix".sac_enviosdineroyahis enviohis
			WHERE enviohis.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (enviohis.estatus ='01' OR enviohis.estatus ='04') -- ACTIVOS Y PAGADOS
			AND enviohis.pri_nom_rem = pNombre1
			AND enviohis.seg_nom_rem = pNombre2
			AND enviohis.apell_pat_rem = pApellidoPat
			AND enviohis.apell_mat_rem = pApellidoMat;

			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_envio,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='001' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8701') THEN importe_envio END),0)
			INTO mImporte_ya_movhis
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_rem = pNombre1
			AND envio.seg_nom_rem = pNombre2
			AND envio.apell_pat_rem = pApellidoPat
			AND envio.apell_mat_rem = pApellidoMat;
						
		ELSE
			-- BUSCANDO LA SUMATORIA DE MOVIMIENTOS DE COBROS EN EFECTIVO PARA EL BENEFICIARIO
			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_pago,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientos WHERE numcategoria ='07' AND numconvenio ='002' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8702') THEN importe_pago END),0)
			INTO mImporte_ya
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_ben = pNombre1
			AND envio.seg_nom_ben = pNombre2
			AND envio.apell_pat_ben = pApellidoPat
			AND envio.apell_mat_ben = pApellidoMat;
			
			SELECT NVL(SUM(CASE WHEN NVL(enviohis.importe_pago,0) <> 0 AND enviohis.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='002' AND referencia1 = enviohis.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8702') THEN importe_pago END),0)
			INTO mImporte_yahis
			FROM "informix".sac_enviosdineroyahis enviohis
			WHERE enviohis.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (enviohis.estatus ='01' OR enviohis.estatus ='04') -- ACTIVOS Y PAGADOS
			AND enviohis.pri_nom_ben = pNombre1
			AND enviohis.seg_nom_ben = pNombre2
			AND enviohis.apell_pat_ben = pApellidoPat
			AND enviohis.apell_mat_ben = pApellidoMat;
			
			SELECT NVL(SUM(CASE WHEN NVL(envio.importe_pago,0) <> 0 AND envio.no_control IN( SELECT LPAD(referencia1,12,'0') FROM "informix".sac_movimientoshistorial WHERE numcategoria ='07' AND numconvenio ='002' AND referencia1 = envio.no_control AND flag_confirmacion_central=1 AND flag_confirmacion_sucursal=1 AND status_cancelado ='N' AND forma_pago='1' AND transacc_suc  = '8702') THEN importe_pago END),0)
			INTO mImporte_ya_movhis
			FROM "informix".sac_enviosdineroya envio				
			WHERE envio.fecha_envio BETWEEN dtFecha_limit AND dtFecha_hoy
			AND (envio.estatus ='01' OR envio.estatus ='04') -- ACTIVOS Y PAGADOS
			AND envio.pri_nom_ben = pNombre1
			AND envio.seg_nom_ben = pNombre2
			AND envio.apell_pat_ben = pApellidoPat
			AND envio.apell_mat_ben = pApellidoMat;
					
		END IF;
		
		IF (NVL(mImporte_ya,0) + NVL(mImporte_yahis,0) + NVL(mImporte_ya_movhis,0) + NVL(pImporte,0)) > mLimite_envio THEN
				LET cCodRet = '000004';
				RETURN cCodRet;
		END IF
		
	RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que validará el monto máximo mensual en efectivo por usuario para envíos y/o cobros previa validación de los parámetros de entrada ',
'AUTOR: Antonio Cebreros Perez',
'FECHA DE CREACION: 13 de Octubre del 2014',
'VERSION: 20141030.1500',
'BD: bdisac',
'Folio: 1464 - LimiteOrdPagEfec',

'DESCRIPCION: Ahora se contemplará Envios/Cobros para la sumatoria del acumulado cuando ocurre el siguiente caso',
'por ejemplo: Hoy se realiza un envío y no es cobrado',
'AUTOR: Francisco Eduardo Benitez Baez',
'FECHA DE CREACION: 01 de Diciembre del 2014',
'VERSION: 20141201.1552',
'BD: BDISAC',
'Folio: 1474 - MttoLimiteOrdPagEfec',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE FUNCTION "informix".fn_instr(pString VARCHAR(255),pToken VARCHAR(255),pStar INTEGER DEFAULT 1 )
RETURNING SMALLINT ;

	DEFINE i,j SMALLINT ;
	DEFINE w_1 VARCHAR(255) ;

	IF ( pString IS NULL) OR (pToken IS NULL ) THEN
		RETURN -1 ;
	END IF ;
	LET j = LENGTH(pString);
	FOR i = pStar TO j 
		IF ( SUBSTR(pString,I,1) = SUBSTR(pToken,1,1) ) THEN
			LET w_1 = SUBSTR(pString,i,LENGTH(pToken)) ;
			IF ( w_1 = pToken) THEN
				RETURN i ;
			END IF ;
		END IF ;
	END FOR ;
RETURN 0 ;
END FUNCTION ;