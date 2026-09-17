CREATE PROCEDURE "informix".constarcred_web(pempresa CHAR(3),
                                        pnumtarjeta  CHAR(20))
                                                         
 Returning	CHAR(5),CHAR(3),CHAR(20),CHAR(20),CHAR(20),DATE,CHAR(1),CHAR(1),CHAR(14),CHAR(30),DATE;

 define vcodret		CHAR(5);
 define vsqlerr     INTEGER;
 define vempresa	CHAR(3);
 define vnum_cred       CHAR(20);
 define vnum_tar        CHAR(20);
 define vnumcte         CHAR(20);
 define vexpiracion     DATE;
 define vtipo_tar       CHAR(1);
 define vstatus_tar     CHAR(1);
 define vlimite_aut     CHAR (14);
 define vnombre         CHAR(30);
 define vfecha_nac      DATE;
 DEFINE vLinCredInf             DECIMAL(18,2);
 DEFINE c_confirma_incremento   CHAR(1);


 let vsqlerr     = 0;
 let vempresa    =  "";
 let vnum_cred   =     "";
 let vnum_tar    =     "";
 let vnumcte     =     "";
 let vexpiracion =    "";
 let vtipo_tar   =    "";
 let vstatus_tar =    "";
 let vlimite_aut =    "";
 let vnombre     =    "";
 let vfecha_nac  =    "";
 LET vLinCredInf                = 0;
 LET c_confirma_incremento      = "";

 BEGIN

	On exception set vsqlerr
		if vsqlerr<>0 then
			let vcodret = vsqlerr;
			return vcodret,vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre,vfecha_nac;
		end if;
	end exception;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;
        
	
        -- SET DEBUG FILE TO '/home/e90306329/TRACE/'||TRIM(vnum_cred)||'.out'; 
        -- TRACE ON;



	if pnumtarjeta is null or pnumtarjeta= "" then
	   let vcodret = '00101';
           return vcodret,vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre,vfecha_nac;
	end if;


        select num_tarjeta
        into   vnum_tar
        from   sd_tarjeta
        where  empresa = pempresa and num_tarjeta = pnumtarjeta;

        if vnum_tar is not null or vnum_tar <> "" then


	select empresa,num_credito,num_tarjeta,numcte,expiracion,tipo_tarjeta,status_tar,limite_aut,nombre 
        into   vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre 
        from   bdicred:sd_tarjeta
	where  empresa=pempresa and num_tarjeta=pnumtarjeta;

	
        select fecha_nac into vfecha_nac 
        from bdinteg:si_ctepf
        where numcte = vnumcte;

        SELECT FIRST 1 confirma_incremento 
                INTO c_confirma_incremento
                FROM bdicred:sd_bitacora_incremento_inflacion 
                WHERE num_credito = vnum_cred 
                AND bandera_aceptacion_rechazo  = "1" ;

        IF c_confirma_incremento = '1' THEN
                SELECT monto_otorgado 
                        INTO  vLinCredInf 
                        FROM bdicred:sd_maesdos  
                        WHERE num_credito = vnum_cred;

                LET vlimite_aut = vLinCredInf; 
        END IF;


        let vcodret     = '00000';
        return vcodret,vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre,vfecha_nac;
   else
        let vcodret     = '00001';
        return vcodret,vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre,vfecha_nac;
       end if;
 
 END
 END PROCEDURE
DOCUMENT 
'----------------------------------------------------------------------------',
'Descripcion : Determinar si un cliente ha aceptado el incremento y en caso afirmativo, actualizar el limite de credito asociado al cliente',
'Modifico    : SECP',
'Fecha       : 07/10/2024',
'BD          : BDICRED',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_reduce_pagoanticipado(pEmpresa CHAR(3), pNumCred CHAR(20), vTipoReduce INTEGER, pFolioSuc CHAR(16),vPerioriodos INTEGER)
RETURNING   CHAR(5)         AS Codigo, 		  -- CODIGO DE RETORNO	
			CHAR(2000) AS vValor;

-- VARIABLES DE CONTROL DE ERRORES
DEFINE isqlerr      	INTEGER;			-- CODIGO DE ERROR
DEFINE isam_err         	INTEGER;
DEFINE error_info       	VARCHAR(60);


DEFINE cCodRet     		CHAR(5); 			-- CODIGO DE RETORNO DE ERROR
DEFINE dSdoInsoluto DECIMAL(18,2);
DEFINE sPlazoMax INTEGER;
DEFINE cProducto  CHAR(4);
DEFINE dCapNoVencido DECIMAL(18,2);
DEFINE dSdoCap DECIMAL(18,2);
DEFINE cTasaFija CHAR(6);			-- TASA DE INTERES FIJA ANUAL PARA PP Y RTC
DEFINE vImporte INTEGER;
DEFINE vPlazo INTEGER;
DEFINE vPagosRealizados INTEGER;
DEFINE vTipo INTEGER;
DEFINE vValor CHAR(2000);
DEFINE dtFechaActual		DATE;				-- FECHA DEL CAMPO  fecha_hoy DE LA TABLA sd_fechas

DEFINE dIva DECIMAL(18,2);

DEFINE mTasaIVA DECIMAL(18,6);		-- TASA ANUAL CON IVA
DEFINE numpagospend INTEGER;
DEFINE calcnvopago 	DECIMAL(18,2);
DEFINE mTasaInt  DECIMAL(18,6); 
DEFINE mTipoPago INTEGER;
DEFINE mPerPlazo CHAR(1);
DEFINE mFechaCuota DATE;
DEFINE vMensualidad 	DECIMAL(18,2);
DEFINE dSucursal CHAR(4);
DEFINE pNumPago     INTEGER;
DEFINE wBegin             CHAR(1);

LET cCodRet 		= "00000";
LET iSqlErr 		= 0;
LET dSdoInsoluto = 0;
LET dIva = 0;
LET numpagospend = 0;
LET mTasaIVA 	 = 0;
LET sPlazoMax = 0;
LET dCapNoVencido = 0;
LET dSdoCap = 0;
LET cTasaFija = 0;
LET vPagosRealizados = 0;
LET vImporte = 0;
LET vPlazo = 0;
LET calcnvopago = 0;
LET isam_err = 0;
LET error_info          	= "";
LET vTipo = 0;
LET vValor = "";
LET dtFechaActual			= DATE(1);
LET mTipoPago = 0;
LET mPerPlazo = "";
LET mFechaCuota = DATE(1);
LET vMensualidad 	= 0;
LET dSucursal = '';
LET pNumPago = 0;
LET mTasaInt = 0; 


BEGIN

	ON EXCEPTION  SET iSqlErr, isam_err, error_info
		IF iSqlErr <> 0  THEN
			LET  cCodRet  = iSqlErr;
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN cCodRet,"";
		END IF;
	  
	END  EXCEPTION
	
	 ON EXCEPTION IN (-535)
      LET wBegin = "S";
      COMMIT WORK;
      BEGIN WORK;
	END EXCEPTION WITH RESUME;
	
	LET wBegin = "N";
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	

		 --SET DEBUG FILE TO "sp_reduce_pagoanticipado.out";
		 --TRACE ON;
		--vValor DE IVA
		
		-- CONSULTA SALDO INICIAL PARA PP Y RTC, MONTO DE TOTAL A PAGAR PARA PRESTAMO PERSONAL
		SELECT  NVL(a.sdo_cap_insoluto,0),NVL(b.plazo,0),NVL(a.cap_tras_no_venci,0),NVL(a.sdo_capital,0),b.tasa_interes::CHAR(6),b.periodo_plazo::CHAR(1),b.fecha_apertura,b.sucursal,b.num_producto
		INTO  dSdoInsoluto,sPlazoMax,dCapNoVencido,dSdoCap,cTasaFija,mPerPlazo,mFechaCuota,dSucursal,cProducto
		FROM "informix".sd_maesdoscrd a INNER JOIN sd_maecredcrd b 
		ON (a.num_credito = b.num_credito)
		WHERE a.num_credito = pNumCred
		AND a.empresa = pEmpresa;
		
		LET cProducto= TRIM(NVL(cProducto,""));
		
		IF (vTipoReduce == 2 AND dSdoInsoluto > 0) THEN
		
		SELECT valor
		INTO dIva
		FROM "informix".sd_param
		WHERE empresa = '001'
		AND cod_param = '12';
		
		--FECHA ACTUAL
		SELECT fecha_hoy
		INTO dtFechaActual
		FROM "informix".sd_fechas
		WHERE empresa = pEmpresa;
		
		IF (mPerPlazo == 'Q') THEN 
			LET mTipoPago = 2;
		ELSE
			LET mTipoPago = 0;
		END IF;
	
		
		--NUMERO DE PAGOS REALIZADOS
		SELECT COUNT(num_credito)
		INTO vPagosRealizados
		FROM "informix".sd_amortiza_creditocrd
		WHERE empresa = pEmpresa
		AND num_credito = pNumCred
		AND capital_status = '5';
		
		
		--Mensualidad Cuota Actual
		SELECT capital_mto_cuota
		INTO vMensualidad
		FROM "informix".sd_amortiza_creditocrd
		WHERE empresa = pEmpresa
		AND num_credito = pNumCred
		AND capital_status = '3';
	
		
		
		-- SE OBTIENE LA TASA ANUAL CON IVA
		LET mTasaIVA = (cTasaFija * (1 + dIva))/100; 
		LET mTasaInt = cTasaFija/100;
	

		
			LET numpagospend = 	vPerioriodos - vPagosRealizados;
			
			IF (numpagospend <= 1) THEN 
			 RETURN "08001","";
			END IF;

			--Reduce Cuota
			EXECUTE PROCEDURE bdisolic:  "informix".sp_obtiene_aproximacion(dSdoInsoluto, -- MONTO DEL PRESTAMO
																		numpagospend, -- PLAZO 
																		0,            -- MENSUALIDAD
																		mTasaInt,	  -- TASA ANUAL
																		mTasaIVA,	  -- TASA ANUAL CON IVA
																		dtFechaActual,-- FECHA DE APERTURA
																		dIva,	      -- IVA QUE SE MANEJA EN LA SUCURSAL
																		0.05,	      -- CANTIDAD PARA DELIMITAR EL LIMITE SUPERIOR Y EL LIMITE INFERIOR
																		0.20,	      -- CANTIDAD MAXIMA PARA DIFERENCIA DE ULTIMA MENSUALIDAD
																		mTipoPago,    --VALIDA EL TIPO DE PRODUCTO, SI ES PRESTAMO O CREDINOMINA.   
																		pNumCred      -- NUMERO DE CREDITO
																		) INTO cCodRet,vImporte ;
			
			LET calcnvopago = vImporte;
			LET vTipo = vTipoReduce;

		
			IF (vImporte <= 0 OR vImporte >= vMensualidad) THEN 
			 RETURN "08080","";
			END IF;
			
			
			-- German: Se consulta el numero de pago para condicional
			select num_pago into pNumPago from sd_amortiza_creditocrd 
			where empresa = pEmpresa AND num_credito = pNumCred AND capital_status = '3';
			

			BEGIN WORK;	
			--RESPALDAR EN sd_amortiza_creditocrd_anticipado
            INSERT INTO sd_amortiza_creditocrd_pago_anticipado (empresa, num_credito, fecha_cuota, tipo_cuota, capital_mto_cuota, capital_debe, capital_pagado, capital_status, capital_status_ant, capital_fecha_pago, interes_debe, interes_pagado, interes_status, interes_status_ant, interes_fecha_pago, iva_debe, iva_pagado, iva_status, iva_status_ant, iva_fecha_pago, mora_provi_ordi, mora_provi_cope, mora_sdo_ordi, mora_sdo_ordi_pag, mora_sdo_cope, mora_sdo_cope_pag, mora_bonificado, mora_status, mora_iva_debe, mora_iva_pagado, mora_iva_status, mora_iva_fecha_pago, num_pago, campo_trabajo1, campo_trabajo2, campo_trabajo3, campo_trabajo4,folio_suc,fecha_mov, fecha)
                SELECT empresa, num_credito, fecha_cuota, tipo_cuota, capital_mto_cuota, capital_debe, capital_pagado, capital_status, capital_status_ant, capital_fecha_pago, interes_debe, interes_pagado, interes_status, interes_status_ant, interes_fecha_pago, iva_debe, iva_pagado, iva_status, iva_status_ant, iva_fecha_pago, mora_provi_ordi, mora_provi_cope, mora_sdo_ordi, mora_sdo_ordi_pag, mora_sdo_cope, mora_sdo_cope_pag, mora_bonificado, mora_status, mora_iva_debe, mora_iva_pagado, mora_iva_status, mora_iva_fecha_pago, num_pago, campo_trabajo1, campo_trabajo2, campo_trabajo3, campo_trabajo4,pFolioSuc,CURRENT, dtFechaActual
                FROM sd_amortiza_creditocrd 
                    WHERE empresa           = pEmpresa
                        AND num_credito     = pNumCred
                        AND num_pago        = 1;
            
			
			-- German: Se agrega condicional para evitar registros duplicados en el primer pago anticipado
            IF(pNumPago > 1) THEN
                INSERT INTO sd_amortiza_creditocrd_pago_anticipado (empresa, num_credito, fecha_cuota, tipo_cuota, capital_mto_cuota, capital_debe, capital_pagado, capital_status, capital_status_ant, capital_fecha_pago, interes_debe, interes_pagado, interes_status, interes_status_ant, interes_fecha_pago, iva_debe, iva_pagado, iva_status, iva_status_ant, iva_fecha_pago, mora_provi_ordi, mora_provi_cope, mora_sdo_ordi, mora_sdo_ordi_pag, mora_sdo_cope, mora_sdo_cope_pag, mora_bonificado, mora_status, mora_iva_debe, mora_iva_pagado, mora_iva_status, mora_iva_fecha_pago, num_pago, campo_trabajo1, campo_trabajo2, campo_trabajo3, campo_trabajo4,folio_suc,fecha_mov, fecha)
                SELECT empresa, num_credito, fecha_cuota, tipo_cuota, capital_mto_cuota, capital_debe, capital_pagado, capital_status, capital_status_ant, capital_fecha_pago, interes_debe, interes_pagado, interes_status, interes_status_ant, interes_fecha_pago, iva_debe, iva_pagado, iva_status, iva_status_ant, iva_fecha_pago, mora_provi_ordi, mora_provi_cope, mora_sdo_ordi, mora_sdo_ordi_pag, mora_sdo_cope, mora_sdo_cope_pag, mora_bonificado, mora_status, mora_iva_debe, mora_iva_pagado, mora_iva_status, mora_iva_fecha_pago, num_pago, campo_trabajo1, campo_trabajo2, campo_trabajo3, campo_trabajo4,pFolioSuc,CURRENT, dtFechaActual
                FROM sd_amortiza_creditocrd 
                    WHERE empresa               = pEmpresa
                        AND num_credito         = pNumCred
                        AND capital_status      = "3" ;
            END IF;
		--- ACTUALIZA EL NUEVO MONTO CUOTA DEL PERIODO 1 Y EL PERIODO EN CURSO		 
				
		  UPDATE "informix".sd_amortiza_creditocrd
		  SET 	 capital_mto_cuota   = calcnvopago 
		   WHERE empresa             = pEmpresa
			 AND num_credito         = pNumCred
			 AND num_pago = 1;
			 
		IF(pNumPago > 1) THEN
		  UPDATE "informix".sd_amortiza_creditocrd
			 SET 	 capital_mto_cuota   = calcnvopago 
		   WHERE empresa             = pEmpresa
			 AND num_credito         = pNumCred
			 AND capital_status      = "3" ;
		 END IF;
		 
		--REESTRUCTURA 6011, 8600
		IF cProducto  IN ("8600","6011")THEN
			 UPDATE "informix".sd_amortiza_creditocrd
				 SET 	 capital_mto_cuota   = calcnvopago 
			   WHERE empresa             = pEmpresa
				 AND num_credito         = pNumCred
				 AND capital_status      = "4" ;
		END IF;
		COMMIT WORK;
						 			 
				 
					 
	LET cCodRet = cCodRet;
			
	END IF;
	IF (wBegin = "S") THEN
		BEGIN WORK;
	END IF;
	
			
	  RETURN cCodRet,vValor;
		
		
END;
END PROCEDURE
DOCUMENT
'AUTOR: 98640909 - LUIS ALBERTO BELTRAN RODRIGUEZ',
'Descripcion:  REDUCE MONTO DE PAGO O PLAZO EN LINEAS DE CREDITOS NO REVOLVENTES',
'Fecha: 2024/01/09',
'Version: 20240109.1242',
'-------------------------------------------------------------------------------',
'AUTOR: 99806218 - LUIS GERMAN DIEP RENDON',
'Descripcion:  MEJORA PARA NUEVA TABLA DE BACKUP DE SD_AMORTIZA_CREDITOCRD_PAGO_ANTICIPADO AGREGANDOLE EL CAMPO REVERSADO Y FECHA',
'Fecha: 2024/11/05',
'Version: 20241105.1352';

CREATE PROCEDURE "informix".sp_pago_anticipado_rr(pEmpresa    CHAR(3),
                                                  pNumCredito CHAR(20),
                                                  pUsuario    CHAR(8),
                                                  pSucursal   CHAR(4),
                                                  pFolio      CHAR(16),
                                                  pTransacc   CHAR(4),
                                                  pMonto      DECIMAL(18,2),
                                                  pbanderarespaldo char(1),
												  pTipoReduce INTEGER)
RETURNING  CHAR(5)        AS cod_ret,
           CHAR(125)      AS mens_ret,
           DECIMAL(18,2)  AS sdo_ant,
           DECIMAL(18,2)  AS comision,
           DECIMAL(18,2)  AS iva_com,
           DECIMAL(18,2)  AS int_mora,
           DECIMAL(18,2)  AS iva_int_mora,
           DECIMAL(18,2)  AS int_vdo,
           DECIMAL(18,2)  AS iva_int_vdo,
           DECIMAL(18,2)  AS int_ordi,
           DECIMAL(18,2)  AS iva_int_ordi,
           DECIMAL(18,2)  AS capital,
           DECIMAL(18,2)  AS monto_pago,
           CHAR(20)       AS cuenta_eje,
           DECIMAL(18,2)  AS sdo_act,
           DECIMAL(18,2)  AS pago_min,
           CHAR(17)       AS fecha_limite_pago;

-- Modifico: Roque Solis
-- Fechas: 30/12/2009
-- Modificacion: se valido que el pago anticipado con cargo a cuenta
--              realice el cargo y la validaciones correspondientes
--              a la cuenta efectiva.

-- Modifico: Paul Ivan Quintero Varela
-- Fecha: 2010/01/20
-- Comentario: Se agrega la actualizacion del campo capital_status_ant

-- Modifico: Roque Solis
-- Fecha: 25/02/2010
-- Comentario: Se modifico para que en el saldo anterior se coloque el saldo total para liquidar
--                  antes de realizar el pago.

--  modificacion: Paul Ivan Quintero Varela
-- Fecha: 25/02/2010
-- Comentario:  Se modifica para que el procedimiento regrese los siguientes campos:
--                      "usted debe al dia de hoy"
--                      "Su pago Minimo hoy"
--                      "total que pago el cliente"
--                      "Cargo en cuenta eje"
--                      "Fecha  de pago"

-- modificacion: Paul Ivan Quintero Varela
-- Fecha: 26/02/2010
-- Comentario:  Se modifica con la finalidad de reorganizar los codigos de retorno

-- Modifico:Jesus Manuel Aguilar Heredia
-- Fecha: 12-05-2011
-- Comentario: se realiza modificacion para contemplar nuevas transacciones de pago desde sucursal.

DEFINE iSqlErr            INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE cCodRet            CHAR(5);
DEFINE cCodRetAux         CHAR(6);
DEFINE cMensajeRet        VARCHAR(125,1);

DEFINE GLOBAL g_NumCredito      CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_CodFun          CHAR(3)        DEFAULT "221";
DEFINE GLOBAL g_CodFunProv      CHAR(3)        DEFAULT "606";
DEFINE GLOBAL g_Folio           CHAR(16)       DEFAULT "";
DEFINE GLOBAL g_dtFechaHoy      DATE           DEFAULT today;
DEFINE GLOBAL g_cEmpresa        CHAR(3)        DEFAULT "";
DEFINE GLOBAL g_dTasaInt        DECIMAL(9,6)   DEFAULT 0;
DEFINE GLOBAL g_dIvaSuc         DECIMAL(5,3)   DEFAULT 0;
DEFINE GLOBAL g_TransaccSuc     CHAR(4)        DEFAULT "";

DEFINE GLOBAL g_Cuenta               CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_NumTarjDeb           CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_SdoCta               DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL g_StatusCtaCap         CHAR(1)        DEFAULT "";
DEFINE GLOBAL g_TranRet              CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_FechaCargo           DATE           DEFAULT today;
DEFINE GLOBAL g_SdoDisp              DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL g_MtoRet               DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL g_Sucursal             CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_Usuario              CHAR(8)        DEFAULT "";
DEFINE GLOBAL g_TranCargo            CHAR(4)        DEFAULT "0227";
DEFINE GLOBAL g_cheque               INTEGER        DEFAULT 0;
DEFINE GLOBAL g_Divisa               CHAR(2)        DEFAULT "";
DEFINE GLOBAL g_Leyenda              CHAR(40)       DEFAULT "CRG. CTA. ";
DEFINE GLOBAL g_Autoriza             CHAR(8)        DEFAULT "";
DEFINE GLOBAL g_TranCapt			 CHAR(4)		DEFAULT "";

DEFINE dtFechaApert       DATE;
DEFINE iIntAux            INTEGER;
DEFINE cCharAux           CHAR(80);
DEFINE dDecAux            DECIMAL(18,2);
DEFINE dtDateAux          DATE;
DEFINE cCodigoFun         CHAR(3);
DEFINE iCodRef            INTEGER;
DEFINE cNumCred           CHAR(20);
DEFINE cNumCte            CHAR(20);
DEFINE cSucursal          CHAR(4);
DEFINE dTasaInt           DECIMAL(9,6);
DEFINE dtFechApert        DATE;
DEFINE cNumProd           CHAR(4);
DEFINE cDivisa            CHAR(2);
DEFINE dSdoCapital        DECIMAL(18,2);
DEFINE dCapitalIns        DECIMAL(18,2);
DEFINE dSdoAnt            DECIMAL(18,2);
DEFINE dSdoAdeudTotal     DECIMAL(18,2);
DEFINE dSdoAdeudTotalAct  DECIMAL(18,2);
DEFINE dPagoMinAct        DECIMAL(18,2);
DEFINE dIntDebe           DECIMAL(14,2);
DEFINE dIntPag            DECIMAL(14,2);
DEFINE dIvaDebe           DECIMAL(14,2);
DEFINE dIvaPag            DECIMAL(14,2);
DEFINE cCapStatus         CHAR(1);
DEFINE dtIvaFechPag       DATE;
DEFINE dCapMtoCuota       DECIMAL(14,2);
DEFINE dIvaIntReal        DECIMAL(18,2);
DEFINE dTotalAdeudInt     DECIMAL(18,2);
DEFINE dFactorInt         DECIMAL(18,2);
DEFINE dPagoInt           DECIMAL(18,2);
DEFINE dPagoIvaInt        DECIMAL(18,2);
DEFINE dtIntFechPag       DATE;
DEFINE dTasaCom           DECIMAL(9,6);
DEFINE dPagoCapital       DECIMAL(18,2);
DEFINE dPagoCom           DECIMAL(18,2);
DEFINE dPagoIvaCom        DECIMAL(18,2);
DEFINE cFolio             CHAR(16);
DEFINE dIntMora           DECIMAL(18,2);
DEFINE dIvaIntMora        DECIMAL(18,2);
DEFINE dIntVdo            DECIMAL(18,2);
DEFINE dIvaIntVdo         DECIMAL(18,2);
DEFINE iNumPago           INTEGER;
DEFINE cIndicador         CHAR(1);
DEFINE dIntDevengado      DECIMAL(18,2);
DEFINE dIvaIntDevengado   DECIMAL(18,2);
DEFINE dtFechaFinMes      DATE;
DEFINE dtFechaHoy         DATE;
DEFINE dInteFinMes        DECIMAL(18,2);
DEFINE dIvaIntFinMes      DECIMAL(18,2);
DEFINE dProvInte          DECIMAL(18,2);
DEFINE dProvIvaInt        DECIMAL(18,2);
DEFINE dtFechaFinMesAnt   DATE;
DEFINE dIntGrav      	  DECIMAL(18,2);
DEFINE dIntExen       	  DECIMAL(18,2);
DEFINE dFechaT            DATE;
DEFINE dMontoPago         DECIMAL(18,2);
DEFINE dtFechaProxPago    DATE;
DEFINE cFechaLimite       CHAR(17);
DEFINE dtFechaApertura    DATE;
DEFINE dtFechaCompa       DATE;
DEFINE wBegin             CHAR(1);
DEFINE cStatusCred        CHAR(2);
DEFINE cNomProd    		  CHAR(40);
DEFINE cCodRetMarc	      CHAR(6);
DEFINE cMensajeRetMarc	  CHAR(80);
DEFINE GLOBAL gRespaldoActivo        CHAR(1) DEFAULT "0";
DEFINE ATR_Cred           INTEGER;
DEFINE VarAux1            INTEGER;
DEFINE BanderaIFRS           CHAR(1);
/*LABR*/
DEFINE iCodRetornoPagAnt  CHAR(5);
DEFINE imsgPagAnt		  CHAR(2000);

---LABR
DEFINE pCodigo 		  CHAR(5);       
DEFINE pPeriodo          INTEGER;       
DEFINE pFechaCouta	 	  DATE;          
DEFINE pSaldoInicial  	  MONEY(18,2);   
DEFINE pMensualidad	  DECIMAL(18,2); 
DEFINE pIntereses	  	  MONEY(14,2);   
DEFINE pIvaInteres	  	  MONEY(14,2);  
DEFINE pCapital		  DECIMAL(18,2); 
DEFINE pSaldoFinal	 	  DECIMAL(18,2); 
DEFINE pDiasPeriodo      INTEGER;       
DEFINE pFechaAper	  	  DATE;          
DEFINE pNumMesesPago 	  CHAR(3);       
DEFINE pMontoContratado  DECIMAL(18,2);
DEFINE pMontoTotalaPagar DECIMAL(18,2);
DEFINE pTasaAnualFija 	  DECIMAL(18,2); 
DEFINE pTotLiq 	  DECIMAL(18,2);
DEFINE pAhorro	  DECIMAL(18,2);

DEFINE pFlgReduccion INTEGER;
---LABR

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
   END IF;
END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

   LET wBegin = "N";
   BEGIN WORK;

LET  g_Cuenta              = "";
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = "00000";
LET cCodRetAux            = "000000";
LET cMensajeRet           = "Se ejecuto el pago anticipado correctamente";

LET g_NumCredito          = pNumCredito;
LET dtFechaApert          = DATE(1);
LET g_Folio               = pFolio;
LET g_cEmpresa            = pEmpresa;
LET iIntAux               = 0;
LET cCharAux              = "";
LET dDecAux               = 0;
LET dtDateAux             = DATE(1);
LET cCodigoFun            = "";
LET iCodRef               = 0;
LET cNumCred              = "";
LET cNumCte               = "";
LET dTasaInt              = 0;
LET dtFechApert           = DATE(1);
LET cNumProd              = "";
LET cDivisa               = "";
LET dSdoCapital           = 0;
LET dCapitalIns           = 0;
LET dSdoAnt               = 0;
LET dSdoAdeudTotal        = 0;
LET dSdoAdeudTotalAct     = 0;
LET dPagoMinAct           = 0;
LET dIntDebe              = 0;
LET dIntPag               = 0;
LET dIvaDebe              = 0;
LET dIvaPag               = 0;
LET cCapStatus            = "";
LET dtIvaFechPag          = DATE(1);
LET dCapMtoCuota          = 0;
LET dIvaIntReal           = 0;
LET dTotalAdeudInt        = 0;
LET dFactorInt            = 0;
LET dPagoInt              = 0;
LET dPagoIvaInt           = 0;
LET dtIntFechPag          = DATE(1);
LET dTasaCom              = 0;
LET dPagoCapital          = 0;
LET dPagoCom              = 0;
LET dPagoIvaCom           = 0;
LET cFolio                = "";
LET dIntMora              = 0;
LET dIvaIntMora           = 0;
LET dIntVdo               = 0;
LET dIvaIntVdo            = 0;
LET iNumPago              = 0;
LET cIndicador            = "N";
LET dIntDevengado         = 0;
LET dIvaIntDevengado      = 0;
LET dtFechaFinMes         = DATE(1);
LET dtFechaHoy            = DATE(1);
LET dInteFinMes           = 0;
LET dIvaIntFinMes         = 0;
LET dProvInte             = 0;
LET dProvIvaInt           = 0;
LET dtFechaFinMesAnt      = DATE(1);
LET dIntGrav              = 0;
LET dIntExen              = 0;
LET dFechaT               = DATE(1);
LET dMontoPago            = 0;
LET dtFechaProxPago       = DATE(1);
LET cFechaLimite          = "";
LET dtFechaApertura       = DATE(1);
LET dtFechaCompa          = DATE(1);
LET g_Sucursal            = pSucursal;
LET g_Usuario             = pUsuario;
LET cStatusCred           = "";
LET cSucursal             = pSucursal;
LET g_CodFun         	  =  "221";
LET g_CodFunProv          = "606";
LET g_TranCargo    	      = "0227";
LET g_TranCapt			  = "";
LET g_cheque              = 0;
LET g_Leyenda             = "CRG. CTA. ";
LET g_Autoriza            = "";
LET cNomProd    		  = "";
LET cCodRetMarc	        = "";
LET cMensajeRetMarc	   = "";
LET ATR_Cred           = 0;
LET VarAux1            = 0;
LET BanderaIFRS           = '';

/*LABR*/
LET iCodRetornoPagAnt = '';
LET imsgPagAnt		  = '';

---LABR
LET pCodigo 		  = "00000";       
LET pPeriodo          = 0;       
LET pFechaCouta	 	  = DATE(1);          
LET pSaldoInicial  	  = 0;   
LET pMensualidad	  = 0; 
LET pIntereses	  	  = 0;  
LET pIvaInteres	  	  = 0;   
LET pCapital		  = 0;  
LET pSaldoFinal	 	  = 0; 
LET pDiasPeriodo      = 0;     
LET pFechaAper	  	  = DATE(1);          
LET pNumMesesPago 	  ="";     
LET pMontoContratado  = 0;
LET pMontoTotalaPagar = 0;
LET pTasaAnualFija 	  = 0;
LET pTotLiq 	      = 0;
LET pAhorro	          = 0;

LET pFlgReduccion = 0;
---LABR
--SET DEBUG FILE TO "/tmp/sp_pago_anticipado_rr.out";
--TRACE ON;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-------------------------------------------------------------
-- Transacciones de Pago (Central):                        --
   -- 7462 -- Pago Anticipado Ventanilla.                  --
   -- 7469 -- Pago Anticipado Cargo a Cuenta.              --
   -- 7476 -- Pago Anticipado Salvo Buen Cobro (Cheque).   --
   -- 8335 -- Pago SPEI									   --
-------------------------------------------------------------

IF NVL(g_cEmpresa,"")= "" OR  NVL(g_NumCredito,"") = "" OR NVL(pUsuario,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pTransacc,"") NOT IN ("7462","7469","7476","7431","7970","7998","8205","8286","8335","8701", "4320", "9888") OR NVL(pMonto,0) <= 0 OR NVL(g_Folio,"") = "" THEN
     LET cCodRet      = "00411";
     LET cMensajeRet  = "NO HAY ARGUMENTOS (PARAMETROS)";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
     RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

IF EXISTS (SELECT a.num_credito
             FROM "informix".sd_amortiza_creditocrd a
			WHERE a.empresa     = g_cEmpresa
              AND a.num_credito = g_NumCredito
              AND a.capital_status IN ("1","2","7","6")) THEN
     LET cCodRet      = "00041";
     LET cMensajeRet  = "No es posible recibir el pago anticipado";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
     RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

SELECT a.num_credito,a.numcte,a.tasa_interes,a.fecha_apertura,a.num_producto,a.divisa
  INTO cNumCred,cNumCte,g_dTasaInt,dtFechaApert,cNumProd,cDivisa
  FROM "informix".sd_maecredcrd a
 WHERE a.num_credito = g_NumCredito
   AND a.empresa     = g_cEmpresa;

  
select NVL(valor,'I')
   INTO BanderaIFRS 
   from "informix".sd_param 
   WHERE empresa = '001' 
      AND cod_param='700'; 


SELECT nombre_prod INTO cNomProd
FROM "informix".sd_definicion
WHERE num_producto = cNumProd;

LET g_Leyenda = TRIM(g_Leyenda)||' '||TRIM(NVL(cNomProd,""));

IF cNumCred IS NULL THEN
    LET cCodRet      = "00224";
    LET cMensajeRet  = "NO EXISTE NUMERO DE CREDITO";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
    RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

LET pTransacc = pTransacc;
LET cNumProd = cNumProd;

IF pTransacc IN ("7462","7469","7476","7431","7970","7998","8205","8286","8335","8701", "4320", "9888") THEN
       SELECT transacc_rel  INTO g_CodFun
		FROM "informix".sd_conceptospagomanualcrd
		WHERE transacc = pTransacc
		AND num_producto = cNumProd;
ELSE
		LET cCodRet      = "00189";
		LET cMensajeRet  = "Transaccion incorrecta";
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;

		RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(g_cEmpresa,g_NumCredito)
             INTO cCodRetAux,cMensajeRet,cCharAux,cCharAux,dtDateAux,dtDateAux,dDecAux,dtDateAux,
                   iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
                   dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
                   dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotal,dIntDevengado,dIvaIntDevengado,
                   dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
                   cCharAux,cCharAux,iIntAux,cCharAux;

IF cCodRetAux <> "000000" THEN
      LET cCodRet      = "00042";
      LET cMensajeRet  = "Ocurrio un error al obtener el adeudo total del cliente";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
      RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

IF pMonto > NVL(dSdoAdeudTotal,0) THEN
      LET cCodRet      = "00043";
      LET cMensajeRet  = "ESTA PAGANDO MAS DE LO QUE DEBE, REALIZAR CONSULTA DE SALDO Y PAGAR IMPORTE";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
      RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

SELECT fecha_hoy, ult_dia_mes
  INTO dtFechaHoy, dtFechaFinMes
  FROM "informix".sd_fechas
 WHERE empresa=pEmpresa;

LET g_dtFechaHoy=dtFechaHoy;
--	CALL bdicred:monthadd(dtFechaApert,1) RETURNING dFechaT;
 --   CALL bdicred:sp_valfechabil(dFechaT,'+') RETURNING cCodRet, dFechaT;

IF pMonto < NVL(dSdoAdeudTotal,0) and pMonto >= NVL(dSdoAdeudTotal-dPagoCom-dPagoIvaCom,0)  THEN --and dtFechaHoy < dFechaT
      LET cCodRet      = "00082";
      LET cMensajeRet  = "El cliente no alcanza a liquidar su comision, por favor realizar consulta de saldo y pagar el importe correspondiente";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
      RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

LET dtFechaFinMesAnt=DATE(MDY(MONTH(dtFechaFinMes),'01',YEAR(dtFechaFinMes))-1);

SELECT status_cred
  INTO cStatusCred
  FROM "informix".sd_maecredcrd
 WHERE empresa=pEmpresa
   AND num_credito=g_NumCredito;

--validacion para pago anticipado con cargo a cuenta
IF pTransacc IN ("7431","7998", "9888")  THEN    --> FMV   PAGO ANTICIPADO DE CAPITAL CON CARGO EN CUENTA
	-- Se obtiene la cuenta a la cual se le realizo el deposito del prestamo.
	SELECT a.num_cta
	  INTO g_Cuenta
	  FROM "informix".sd_ctascarg a
	 WHERE a.num_credito  = g_NumCredito
	   AND a.empresa      = g_cEmpresa
	   AND a.naturaleza   = "A";

	  IF NVL(g_Cuenta,"") = "" THEN
		  LET cCodRet      = "00044";
	      LET cMensajeRet  = "No se pudo consultar la cuenta efectiva";
           ROLLBACK WORK;

           IF (wBegin = "S") THEN
               BEGIN WORK;
           END IF;
          RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
	  END IF;

	  -- Se obtiene el numero de tarjeta.
	  SELECT a.num_tarjeta
		INTO g_NumTarjDeb
		FROM bdicheq:"informix".sc_tarjeta a
	   WHERE a.empresa   = g_cEmpresa
		 AND a.cuenta    = g_Cuenta
		 AND a.secuencia = (SELECT MAX(b.secuencia)
							  FROM bdicheq:"informix".sc_tarjeta b
							 WHERE b.empresa      = a.empresa
							   AND b.cuenta       = a.cuenta
							   AND b.secuencia    = b.secuencia
							   AND b.tipo_tarjeta = "T");

		IF g_NumTarjDeb IS NULL THEN
		   LET g_NumTarjDeb = "";
		END IF;

		-- Se obtiene el saldo de la cuenta identificada.
		CALL bdicheq:"informix".cons_saldo(g_Cuenta) RETURNING cCodRetAux,g_SdoCta,g_StatusCtaCap;

		IF (cCodRetAux <> "000") THEN
			 LET cCodRet      = "00187";
			 LET cMensajeRet  = "No es posible obtener el saldo actual de la cuenta cliente";
               ROLLBACK WORK;

               IF (wBegin = "S") THEN
                   BEGIN WORK;
               END IF;
             RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;

		-- Valida si el saldo esta activo para poder usarlo .
		IF g_StatusCtaCap <> "1" THEN
		     LET cCodRet      = "00188";
			 LET cMensajeRet  = "El saldo no esta activo para poder usarlo";
               ROLLBACK WORK;

               IF (wBegin = "S") THEN
                   BEGIN WORK;
               END IF;
             RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;

		-- Valida el saldo obtenido de la cuenta.
		IF NVL(g_SdoCta,0) <= 0 or NVL(g_SdoCta,0) < pMonto THEN
			 LET cCodRet      = "00050";
			 LET cMensajeRet  = "El saldo no es valido";
               ROLLBACK WORK;

               IF (wBegin = "S") THEN
                   BEGIN WORK;
               END IF;
             RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;

		IF pTransacc = "9888" THEN
			LET g_TranCapt = "0551";
			
			EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
											  g_Sucursal,
											  g_Usuario,
											  g_TranCapt,
											  g_TranCapt,
											  g_Folio,
											  g_Cuenta,
											  g_cheque,
											  pMonto,
											  cDivisa,
											  pNumCredito||" "||g_Leyenda,
											  g_NumTarjDeb,
											  g_Autoriza)
						INTO cCodRetAux, g_TranRet, g_FechaCargo, g_SdoDisp, g_MtoRet;
		ELSE
		  -- Realiza el cargo del adeudo a la cuenta
		  EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
											  g_Sucursal,
											  g_Usuario,
											  g_TranCargo,
											  pTransacc,
											  g_Folio,
											  g_Cuenta,
											  g_cheque,
											  pMonto,
											  cDivisa,
											  pNumCredito||" "||g_Leyenda,
											  g_NumTarjDeb,
											  g_Autoriza)
						INTO cCodRetAux, g_TranRet, g_FechaCargo, g_SdoDisp, g_MtoRet;
			END IF;
		   IF cCodRetAux <> "000" THEN
			   LET cCodRet      = "00051";
			   LET cMensajeRet  = "Ocurrio un error al aplicar el cargo a la cuenta de captacion";
               ROLLBACK WORK;

               IF (wBegin = "S") THEN
                   BEGIN WORK;
               END IF;
               RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
           END IF;
END IF;

SELECT a.iva
  INTO g_dIvaSuc
  FROM bdinteg:"informix".si_sucursales a
 WHERE a.sucursal = cSucursal
   AND a.empresa  = g_cEmpresa;

IF NVL(g_dIvaSuc,0) = 0 THEN
    LET cCodRet      = "00052";
    LET cMensajeRet  = "Ocurrio un error al obtener el iva de la sucursal";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
    RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

SELECT a.sdo_capital + a.cap_tras_no_venci,        -- Saldo Capital
       a.sdo_cap_insoluto,    -- Saldo Capital Insoluto
	   a.provision_normal,     --porcion que restas de la provision fin de mes de los intereses
	   a.sdo_global_int,      --porcion que resta de la provision de fin de mes del iva de intereses
       NVL(a.ATR,-1)
  INTO dSdoCapital,
       dCapitalIns,
	   dInteFinMes,
	   dIvaIntFinMes,
       ATR_Cred
  FROM "informix".sd_maesdoscrd a
 WHERE a.num_credito = g_NumCredito
   AND a.empresa     = g_cEmpresa;

    IF dSdoCapital IS NULL THEN LET dSdoCapital = 0; END IF;
    IF dCapitalIns IS NULL THEN LET dCapitalIns = 0; END IF;
    IF dInteFinMes IS NULL THEN LET dInteFinMes=0;   END IF;
    IF dIvaIntFinMes IS NULL THEN LET dIvaIntFinMes = 0; END IF;

    LET dSdoAnt = dSdoCapital;

/*SELECT a.sdo_intereses,        -- intereses a fin de mes
       a.sdo_global_int    -- iva de intereses a fin de mes
  INTO dInteFinMes,
       dIvaIntFinMes
  FROM "informix".sd_maesdoscontcrd a
 WHERE a.fecha = dtFechaFinMesAnt
   AND a.num_credito = g_NumCredito
   AND a.empresa     = g_cEmpresa;

   IF dInteFinMes IS NULL THEN
      LET dInteFinMes=0;
   END IF;

   IF dIvaIntFinMes IS NULL THEN
      LET dIvaIntFinMes = 0;
   END IF;
*/


SELECT a.interes_debe,      -- Interes Ordinario Vigente
       a.interes_pagado,    -- Interes Ordinario Vigente Pagado
       a.iva_debe,          -- Iva de Interes Ordinario Vigente
       a.iva_pagado,        -- Iva de Interes Ordinario Vigente Pagado
       a.capital_status,    -- Estatus de la Mensualidad
       a.capital_mto_cuota, -- Capital Monto Cuota
       a.num_pago
  INTO dIntDebe,
       dIntPag,
       dIvaDebe,
       dIvaPag,
       cCapStatus,
       dCapMtoCuota,
       iNumPago
  FROM "informix".sd_amortiza_creditocrd a
 WHERE a.empresa         = g_cEmpresa
   AND a.num_credito     = g_NumCredito
   AND a.capital_status  = "3";
         -- Se generaÂ¡ el movimiento uno del anticipo realizado
	    IF g_TransaccSuc ="4320" THEN --MODIFICACION ATM PAGO NORMAL EFECTIVO				    
			-- Se genera el primer movimiento por el total del abono para pagos en ATM.
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,89,g_CodFun,g_dtFechaHoy,pMonto,g_Folio,cSucursal,cDivisa,g_TransaccSuc,"ANTICIPO","")
						RETURNING cCodRetAux, cMensajeRet;
		ELIF g_TransaccSuc = "9888" THEN --MODIFICACION ATM PAGO NORMAL CGO CTA	
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,88,g_CodFun,g_dtFechaHoy,pMonto,g_Folio,cSucursal,cDivisa,g_TransaccSuc,"ANTICIPO","")
						RETURNING cCodRetAux, cMensajeRet;
		ELSE
			-- Se genera el movimiento uno del anticipo realizado
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,1,g_CodFun,g_dtFechaHoy,pMonto,g_Folio,cSucursal,cDivisa,g_TransaccSuc,"ANTICIPO","")
						RETURNING cCodRetAux, cMensajeRet;
		END IF;

    IF (cCodRetAux <> "000000") THEN
         LET cCodRet      = "00053";
         LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de Pago";
           ROLLBACK WORK;

           IF (wBegin = "S") THEN
               BEGIN WORK;
           END IF;
         RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
    END IF;

    LET dMontoPago = pMonto;

   -- Se respalda el credito
   IF pbanderarespaldo ='1' AND gRespaldoActivo = '0' THEN
      CALL "informix".sp_respalda_credito_rr(g_cEmpresa, g_NumCredito, USER) RETURNING cCodRetAux;

      IF cCodRetAux <> "000000" THEN
          LET cCodRet      = "00054";
          LET cMensajeRet  = "Ocurrio un error respaldar la informacion del credito";
           ROLLBACK WORK;

           IF (wBegin = "S") THEN
               BEGIN WORK;
           END IF;
          RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
      END IF;
   END IF;

IF g_dtFechaHoy = dtFechaApert THEN ---????cas
   -- Si se realiza el anticipo en dia de la apertura no realiza cobro de interes ni iva.
   LET dTotalAdeudInt  = 0;
ELSE
    -- Se toma el iva de interes devengado obtenido de la consulta generalizada
     LET dIvaIntReal = dIvaIntDevengado;
     LET dTotalAdeudInt = dIntDevengado + dIvaIntReal;
END IF;

IF dTotalAdeudInt > 0 AND dIntDevengado > 0 THEN
    IF (pMonto <= dTotalAdeudInt) THEN
         LET dFactorInt    = (dIntDebe - dIntPag) / dTotalAdeudInt;
         LET dPagoInt      = ROUND(dFactorInt * pMonto,2);
         LET dPagoIvaInt   = pMonto - dPagoInt;
         LET pMonto        = pMonto - dPagoIvaInt - dPagoInt;
    ELSE
         LET dPagoIvaInt   = dIvaIntReal;
         LET dPagoInt      = dIntDebe - dIntPag;
         LET pMonto        = pMonto - dPagoIvaInt - dPagoInt;
    END IF;

         LET cIndicador = "S";

     -- Se actualizan los intereses e ivas de la amortizacion
      UPDATE "informix".sd_amortiza_creditocrd
         SET interes_pagado      = interes_pagado + dPagoInt,
             iva_debe            = iva_debe + dPagoIvaInt,
             iva_pagado          = iva_pagado + dPagoIvaInt,
             interes_fecha_pago  = (CASE WHEN (dPagoInt <= (dIntDebe - dIntPag)) THEN TO_CHAR(g_dtFechaHoy) ELSE interes_fecha_pago END),
             iva_fecha_pago      = (CASE WHEN (dPagoIvaInt = dIvaIntReal) THEN g_dtFechaHoy ELSE iva_fecha_pago END)
       WHERE empresa             = g_cEmpresa
         AND num_credito         = g_NumCredito
         AND capital_status      = "3";

		  IF dInteFinMes > 0 THEN
		     IF dInteFinMes > dPagoInt THEN
		        LET dProvInte = dInteFinMes - dPagoInt;
			 ELSE
			    LET dProvInte = 0;
			 END IF;
		 ELSE
		   LET dProvInte =dInteFinMes;
		END IF;

		 IF dIvaIntFinMes > 0 THEN
		     IF dIvaIntFinMes > dPagoIvaInt THEN
		        LET dProvIvaInt = dIvaIntFinMes - dPagoIvaInt;
			 ELSE
			    LET dProvIvaInt = 0;
			 END IF;
		 ELSE
		   LET dProvIvaInt =dIvaIntFinMes;
		END IF;

     if dProvInte < 0   then let dProvInte = 0; end if;
     if dProvIvaInt < 0 then let dProvIvaInt = 0; end if;

      UPDATE "informix".sd_maesdoscrd
         SET sdo_intereses    = sdo_intereses - dPagoInt,
             sdo_acum_mes_int = sdo_acum_mes_int - dPagoInt,
			 provision_normal = dProvInte,
             sdo_global_int   = dProvIvaInt
       WHERE num_credito      = g_NumCredito
         AND empresa          = g_cEmpresa;

	IF dInteFinMes < dPagoInt THEN
                                                     --> FMV: PAGO ANTICIPADO DE INTERES CON CARGO EN CUENTA
	    LET dProvInte             = dPagoInt - dInteFinMes;
		
		IF g_TransaccSuc = '8701'  THEN
			-- Movimiento contable para reconocimiento de interes vigente DE QUITAS
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,13,'128',g_dtFechaHoy,dProvInte,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			RETURNING cCodRetAux, cMensajeRet;		
		ELSE
			-- Movimiento contable para reconocimiento de interes vigente
            IF(cStatusCred='AA' or cStatusCred='BA' or cStatusCred='BT' or (BanderaIFRS='I' and cStatusCred='VP')) THEN
                IF(cStatusCred='AA') THEN
                    LET VarAux1 = 3;
                ELSE
                    LET VarAux1 = 2;
                END IF;
            ELIF(cStatusCred='E1' or cStatusCred='E2' or cStatusCred='E3' or (BanderaIFRS='A' and cStatusCred='VP')) THEN
                IF(cStatusCred='E1') THEN
                    LET VarAux1 = 3;
                ELIF (cStatusCred='E2') THEN
                    LET VarAux1 = 7078;
                ELSE
                    LET VarAux1 = 2;
                END IF;
            END IF;
			
			     IF g_TransaccSuc = '9888' AND (VarAux1 = 3 OR VarAux1 = 7078) THEN 
				    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'41','059',g_dtFechaHoy,dProvInte,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			             RETURNING cCodRetAux, cMensajeRet;	
				 ELIF g_TransaccSuc = '9888' AND VarAux1 = 2 THEN
				    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'45','059',g_dtFechaHoy,dProvInte,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			             RETURNING cCodRetAux, cMensajeRet;	
				 ELSE
				    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,'606',g_dtFechaHoy,dProvInte,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			             RETURNING cCodRetAux, cMensajeRet;	
				 END IF;
		END IF;

		IF (cCodRetAux <> "000000") THEN
           LET cCodRet      = "00055";
		   LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable provision de interes vigente";
           ROLLBACK WORK;

           IF (wBegin = "S") THEN
               BEGIN WORK;
           END IF;
           RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;
	END IF;
                                        --> FMV : PAGO ANTICIP DE IVA INTERES VIGENTE CON CARGO EN CTA
	IF dIvaIntFinMes < dPagoIvaInt THEN
		LET dProvIvaInt           = dPagoIvaInt - dIvaIntFinMes;
		IF g_TransaccSuc = '8701'  THEN
			 -- Movimiento contable para reconocimiento de iva de interes vigente
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,14,'128',g_dtFechaHoy,dProvIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			RETURNING cCodRetAux, cMensajeRet;
		ELSE
			 -- Movimiento contable para reconocimiento de iva de interes vigente
        IF(cStatusCred='AA' or cStatusCred='BA' or cStatusCred='BT' or (BanderaIFRS='I' and cStatusCred='VP')) THEN
            IF(cStatusCred='AA') THEN
                LET VarAux1 = 24;
            ELSE
                LET VarAux1 = 25;
            END IF;
        ELIF(cStatusCred='E1' or cStatusCred='E2' or cStatusCred='E3' or (BanderaIFRS='A' and cStatusCred='VP')) THEN
            IF(cStatusCred='E1') THEN
                LET VarAux1 = 24;
            ELIF (cStatusCred='E2') THEN
                LET VarAux1 = 7084;
            ELSE
                LET VarAux1 = 25;
            END IF;
        END IF;
		        IF g_TransaccSuc = '4320' AND (VarAux1 = 24 OR VarAux1 = 7084) THEN
			        CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'40','059',g_dtFechaHoy,dProvIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
                       RETURNING cCodRetAux, cMensajeRet;
				ELIF g_TransaccSuc = '9888' AND VarAux1 = 25 THEN	   
				    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'45','059',g_dtFechaHoy,dProvIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
                       RETURNING cCodRetAux, cMensajeRet;
			    ELSE
			        CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,'222',g_dtFechaHoy,dProvIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
                      RETURNING cCodRetAux, cMensajeRet; 
			    END IF;
		END IF;

		IF (cCodRetAux <> "000000") THEN
			 LET cCodRet      = "00057";
			 LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago iva interes vigente";
               ROLLBACK WORK;

               IF (wBegin = "S") THEN
                   BEGIN WORK;
               END IF;
             RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;
	ELIF dPagoIvaInt > 0 AND g_TransaccSuc = '8701'  THEN
	
		 -- Movimiento contable para reconocimiento de iva de interes vigente
     IF(cStatusCred='AA' or cStatusCred='BA' or cStatusCred='BT' or (BanderaIFRS='I' and cStatusCred='VP')) THEN
          LET VarAux1 = 14;
      ELIF(cStatusCred='E1' or cStatusCred='E2' or cStatusCred='E3' or (BanderaIFRS='A' and cStatusCred='VP')) THEN
          LET VarAux1 = 14;
      END IF;

		CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,'128',g_dtFechaHoy,dProvIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
		RETURNING cCodRetAux, cMensajeRet;
			
		IF (cCodRetAux <> "000000") THEN
			 LET cCodRet      = "00057";
			 LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago iva interes vigente";
               ROLLBACK WORK;

               IF (wBegin = "S") THEN
                   BEGIN WORK;
               END IF;
             RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;
	END IF;
---ini cas, Se agrega el movimiento aplicativo de interes gravable y exento
                IF dProvInte>0 and dProvIvaInt<=0 then
                    LET dIntGrav = dProvInte;
                    LET dIntExen = 0;
                ELSE
                    LET dIntGrav = dProvIvaInt/g_dIvaSuc;
                    LET dIntExen = dProvInte-dIntGrav;
                END IF;

                IF dIntGrav>0 THEN
                    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,12,g_CodFunProv,g_dtFechaHoy,dIntGrav,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
                    RETURNING cCodRetAux, cMensajeRet;

                    IF (cCodRetAux <> "000000") THEN
                         LET cCodRet      = "00086";
                         LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de Interes Gravado";
                           ROLLBACK WORK;

                           IF (wBegin = "S") THEN
                               BEGIN WORK;
                           END IF;
          				 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
                    END IF;
                END IF;
                IF dIntExen>0 THEN
                    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,13,g_CodFunProv,g_dtFechaHoy,dIntExen,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
                    RETURNING cCodRetAux, cMensajeRet;

                    IF (cCodRetAux <> "000000") THEN
                         LET cCodRet      = "00087";
                         LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de Interes Exento";
                           ROLLBACK WORK;

                           IF (wBegin = "S") THEN
                               BEGIN WORK;
                           END IF;
          				 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
                    END IF;
                END IF;
---fin cas, Se agrega el movimiento aplicativo de interes gravable y exento

    -- Movimiento contable pago de interes vigente
    --> FMV: PAGO DE INTERES VIGENTE EN CARGO A CUENTA

      IF(cStatusCred='AA' or cStatusCred='BA' or cStatusCred='BT' or (BanderaIFRS='I' and cStatusCred='VP')) THEN
        IF(cStatusCred='AA') THEN
          LET VarAux1 = 28;
        ELSE
          LET VarAux1 = 30;
        END IF;
      ELIF(cStatusCred='E1' or cStatusCred='E2' or cStatusCred='E3' or (BanderaIFRS='A' and cStatusCred='VP')) THEN
        IF(cStatusCred='E1') THEN
          LET VarAux1 = 1112;
        ELIF (cStatusCred='E2') THEN
          LET VarAux1 = 1114;
        ELSE
          LET VarAux1 = 1121;
        END IF;
      END IF;

		IF g_TransaccSuc = '8701'  THEN
		CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,g_CodFun,g_dtFechaHoy,dInteFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
			RETURNING cCodRetAux, cMensajeRet;
		ELIF g_TransaccSuc = '9888' AND (VarAux1 = 28 OR VarAux1 = 1112 OR VarAux1 = 1114 OR VarAux1 = 1121) THEN
			  CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'39','059',g_dtFechaHoy,dInteFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
			   RETURNING cCodRetAux, cMensajeRet;
		ELIF g_TransaccSuc = '9888' AND VarAux1 = 30 THEN
		  CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'43','059',g_dtFechaHoy,dInteFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
		   RETURNING cCodRetAux, cMensajeRet;			   
		ELSE
		CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,g_CodFun,g_dtFechaHoy,dPagoInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")  --AEH
			RETURNING cCodRetAux, cMensajeRet;	
		END IF;
    IF (cCodRetAux <> "000000") THEN
            LET cCodRet      = "00058";
        LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago interes vigente";
        ROLLBACK WORK;

        IF (wBegin = "S") THEN
             BEGIN WORK;
        END IF;
        RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
    END IF;

    -- Movimiento Contable Pago de Iva de Interes Vigente
    --> FMV: PAGO DE IVA DE INTERES VIGENTE EN CARGO A CUENTA

      IF(cStatusCred='AA' or cStatusCred='BA' or cStatusCred='BT' or (BanderaIFRS='I' and cStatusCred='VP')) THEN
        IF(cStatusCred='AA') THEN
          LET VarAux1 = 47;
        ELSE
          LET VarAux1 = 45;
        END IF;
      ELIF(cStatusCred='E1' or cStatusCred='E2' or cStatusCred='E3' or (BanderaIFRS='A' and cStatusCred='VP')) THEN
        IF(cStatusCred='E1') THEN
          LET VarAux1 = 1113;
        ELIF (cStatusCred='E2') THEN
          LET VarAux1 = 1115;
        ELSE
          LET VarAux1 = 1122;
        END IF;
      END IF;
		IF g_TransaccSuc = '8701'  THEN
			
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,g_CodFun,g_dtFechaHoy,dIvaIntFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
		RETURNING cCodRetAux, cMensajeRet;
		ELIF g_TransaccSuc = '9888' AND (VarAux1= 47 OR VarAux1 = 1113 OR VarAux1 = 1115 OR VarAux1 = 1122) THEN	
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'40','059',g_dtFechaHoy,dIvaIntFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
			  RETURNING cCodRetAux, cMensajeRet;
		ELIF g_TransaccSuc = '9888' AND VarAux1= 45 THEN	
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'44','059',g_dtFechaHoy,dIvaIntFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
			  RETURNING cCodRetAux, cMensajeRet;						 
		ELSE
		CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,g_CodFun,g_dtFechaHoy,dPagoIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
			RETURNING cCodRetAux, cMensajeRet;
		END IF;

    IF (cCodRetAux <> "000000") THEN
         LET cCodRet      = "00059";
         LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago iva interes vigente";
          ROLLBACK WORK;

          IF (wBegin = "S") THEN
              BEGIN WORK;
          END IF;
         RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
    END IF;
END IF;
IF pMonto > 0  THEN
  IF pMonto > dSdoCapital THEN
    LET dPagoCapital = dSdoCapital;
    LET pMonto = pMonto - dSdoCapital;
  ELSE
    LET dPagoCapital = pMonto;
    LET pMonto  = 0;
  END IF;
END IF;

IF dPagoCapital > 0 THEN
	
  -- Actualiza el Saldo a Capital

  IF cStatusCred IN ('AA','E1','E2','E3') or (cStatusCred = 'VP' and BanderaIFRS = 'A') THEN
      UPDATE "informix".sd_maesdoscrd
         SET sdo_capital       = sdo_capital  - dPagoCapital,
             sdo_cap_insoluto  = sdo_cap_insoluto - dPagoCapital
       WHERE num_credito       = g_NumCredito
         AND empresa           = g_cEmpresa;
		 
	-- Bandera para reduccion de monto en caso de que tipo sea 2 puede obtener aprox monto_cuota	 
	LET pFlgReduccion = 1;
 
  END IF;
  
 
 

  IF (cStatusCred='VP' and BanderaIFRS = 'I') THEN
      UPDATE "informix".sd_maesdoscrd
         SET cap_tras_no_venci = cap_tras_no_venci - dPagoCapital,
             sdo_cap_insoluto  = sdo_cap_insoluto - dPagoCapital
       WHERE num_credito       = g_NumCredito
         AND empresa = g_cEmpresa;
  END IF;


     -- Movimiento contable pago capital anticipado
     -- FMV : PAGO ANTICIPADO DE CAPITAL CON CARGO EN CUENTA
     -- FMV 3may13: Validacion CASE de pago de capital Vigente o Vencido en sucursal

      IF(cStatusCred='AA' or cStatusCred='BA' or cStatusCred='BT' or (BanderaIFRS='I' and cStatusCred='VP')) THEN
        IF(cStatusCred='AA') THEN
          LET VarAux1 = 10;
        ELSE
          LET VarAux1 = 12;
        END IF;
      ELIF(cStatusCred='E1' or cStatusCred='E2' or cStatusCred='E3' or (BanderaIFRS='A' and cStatusCred='VP')) THEN
        IF(cStatusCred='E1' and ATR_Cred <1 ) THEN
          LET VarAux1 = 1106;
        ELIF(cStatusCred='E1' and ATR_Cred >0 ) THEN
          LET VarAux1 = 1107;
        ELIF (cStatusCred='E2') THEN
          LET VarAux1 = 1108;
        ELSE
          LET VarAux1 = 1118;
        END IF;
      END IF;

	      IF g_TransaccSuc = '9888' AND (VarAux1 = 1106 OR VarAux1 = 10 OR VarAux1 = 12) THEN
		   CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'33','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '4320' AND (VarAux1 = 1106 OR VarAux1 = 10 OR VarAux1 = 12) THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'90','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '9888' AND VarAux1 = 1107 THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'34','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '4320' AND VarAux1 = 1107 THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'91','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '9888' AND VarAux1 = 1108 THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'36','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '4320' AND VarAux1 = 1108 THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'93','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '9888' AND VarAux1 = 1118 THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'37','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  ELIF g_TransaccSuc = '4320' AND VarAux1 = 1118 THEN
		     CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,'95','059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") 
		        RETURNING cCodRetAux, cMensajeRet;
		  
		  ELSE
				CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,VarAux1,g_CodFun,g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"") --AEH
				RETURNING cCodRetAux, cMensajeRet;

		  END IF;	

    IF (cCodRetAux <> '000000') THEN
        LET cCodRet      = "00062";
        LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago capital anticipado";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
        RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
    END IF;
END IF;

-- FMV 13-MAY-10: Se omite el cargo de comision por pago anticipado de Reestructura

   LET cIndicador = "S";

  SELECT sdo_cap_insoluto
    INTO dSdoCapital
    FROM "informix".sd_maesdoscrd
   WHERE empresa=g_cEmpresa
     AND num_credito=g_NumCredito;

     IF dSdoCapital IS NULL THEN
     	LET dSdoCapital =0;
     END IF;

   IF dSdoCapital <= 0 THEN
			UPDATE "informix".sd_amortiza_creditocrd
               SET capital_status_ant = capital_status,
                   capital_status = "5",
                   capital_pagado = capital_debe
			 WHERE empresa = g_cEmpresa
               AND num_credito = g_NumCredito
               AND fecha_cuota > g_dtFechaHoy;

			UPDATE "informix".sd_maecredcrd
               SET status_cred = "FF",
                   fecha_vencim = g_dtFechaHoy
			 WHERE num_credito = g_NumCredito
               AND empresa = g_cEmpresa;

			UPDATE "informix".sd_maecredanexocrd
               SET prox_fecha_pago=date(1)--,
                  -- fecha_vencim = g_dtFechaHoy
			 WHERE num_credito = g_NumCredito
               AND empresa = g_cEmpresa;
				--SE realiza el marcaje del cliente RQI 27 100 JMAH
				EXECUTE PROCEDURE bdisitesp:"informix".sp_marcajesitesp('001',3,cNumCte, pUsuario)
				INTO cCodRetMarc, cMensajeRetMarc;
    END IF;


IF cIndicador = "S" THEN
  UPDATE "informix".sd_maecredanexocrd
     SET fecha_ult_pago  = g_dtFechaHoy
   WHERE num_credito     = g_NumCredito
     AND empresa         = g_cEmpresa;
END IF;

EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(g_cEmpresa,g_NumCredito)
             INTO cCodRetAux,cMensajeRet,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinAct,dtDateAux,
                  iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
                  dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
                  dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotalAct,dIntDevengado,dIvaIntDevengado,
                  dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
                  cCharAux,cCharAux,iIntAux,cCharAux;

IF cCodRetAux <> "000000" THEN
      LET cCodRet      = "00042";
      LET cMensajeRet  = "Ocurrio un error al obtener el adeudo actual del cliente";
       ROLLBACK WORK;

       IF (wBegin = "S") THEN
           BEGIN WORK;
       END IF;
      RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

 EXECUTE PROCEDURE "informix".monthadd(dtFechaApertura,1) INTO dtFechaCompa;
 EXECUTE PROCEDURE "informix".sp_valfechabil(dtFechaCompa,'+') INTO cCodRet, dtFechaCompa;

 IF dtFechaProxPago > DATE(1) THEN
     LET cFechaLimite = DAY(dtFechaProxPago) || ' de ' || DECODE(MONTH(dtFechaProxPago),"1","ene","2","feb","3","mar"
                                                                                        ,"4","abr" ,"5","may","6","jun"
                                                                                        ,"7","jul","8","ago","9","sep"
                                                                                        ,"10","oct","11","nov","12","dic")
                                              || ' de ' || YEAR(dtFechaProxPago);
 ELSE
     LET cFechaLimite = ' ';
 END IF;

 IF g_dtFechaHoy = dtFechaProxPago THEN
    LET cFechaLimite = ' ';
 END IF;

 IF cCodRet = "000"  THEN
    LET cCodRet     = "00000";
    LET cMensajeRet = "Se ejecuto el pago anticipado correctamente";
 END IF;

    IF(cCodRet <> "00000") THEN
        ROLLBACK WORK;
    ELSE
        COMMIT WORK;
    END IF;
	--Se agrega validacion tipo se monto y flg despues de reducir sdo_capital para calcular el nuevo monto_cuota
	IF(pTipoReduce == 2 AND pFlgReduccion == 1) THEN
		-- LABR PLAZO REMANENTE DEL CREDITO	
		FOREACH EXECUTE PROCEDURE bdicred: "informix".sp_obtiene_tabla_amortizacion_web(pEmpresa,pNumCredito,pSucursal, 0) 
			INTO pCodigo, pPeriodo, pFechaCouta, pSaldoInicial, pMensualidad, 
				 pIntereses, pIvaInteres, pCapital, pSaldoFinal, pDiasPeriodo, pFechaAper,
				 pNumMesesPago,pMontoContratado,pMontoTotalaPagar,pTasaAnualFija,pTotLiq,pAhorro 
				 
				END FOREACH;
				
		  IF pPeriodo > 0 THEN
			 EXECUTE PROCEDURE "informix".sp_reduce_pagoanticipado
			 (pEmpresa, pNumCredito, pTipoReduce, pFolio,pPeriodo) INTO iCodRetornoPagAnt,imsgPagAnt;
		  END IF;
	END IF;

    IF (wBegin = "S") THEN
        BEGIN WORK;
    END IF;
	
	

 RETURN cCodRet,cMensajeRet,NVL(dSdoAdeudTotal,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");


END PROCEDURE
DOCUMENT
'AUTOR: 98640909 - LUIS ALBERTO BELTRAN RODRIGUEZ',
'Descripcion:  REDUCE MONTO DE PAGO O PLAZO EN LINEAS DE CREDITOS NO REVOLVENTES',
'Fecha: 2024/01/09',
'Version: 20240109.1242';

CREATE PROCEDURE "informix".sp_pago_anticipado_pp(pEmpresa    CHAR(3),
                                                  pNumCredito CHAR(20),
                                                  pUsuario    CHAR(8),
                                                  pSucursal   CHAR(4),
                                                  pFolio      CHAR(16),
                                                  pTransacc   CHAR(4),
                                                  pMonto      DECIMAL(18,2),
											      pbanderarespaldo char(1),
												  pTipoReduce INTEGER)
RETURNING  CHAR(5)        AS cod_ret,
           CHAR(125)      AS mens_ret,
           DECIMAL(18,2)  AS sdo_ant,
           DECIMAL(18,2)  AS comision,
           DECIMAL(18,2)  AS iva_com,
           DECIMAL(18,2)  AS int_mora,
           DECIMAL(18,2)  AS iva_int_mora,
           DECIMAL(18,2)  AS int_vdo,
           DECIMAL(18,2)  AS iva_int_vdo,
           DECIMAL(18,2)  AS int_ordi,
           DECIMAL(18,2)  AS iva_int_ordi,
           DECIMAL(18,2)  AS capital,
           DECIMAL(18,2)  AS monto_pago,
           CHAR(20)       AS cuenta_eje,
           DECIMAL(18,2)  AS sdo_act,
           DECIMAL(18,2)  AS pago_min,
           CHAR(17)       AS fecha_limite_pago;

-- Modifico: Roque Solis
-- Fechas: 30/12/2009
-- Modificacion: se valido que el pago anticipado con cargo a cuenta
--              realice el cargo y la validaciones correspondientes
--              a la cuenta efectiva.

-- Modifico: Paul Ivan Quintero Varela
-- Fecha: 2010/01/20
-- Comentario: Se agrega la actualizacion del campo capital_status_ant

-- Modifico: Roque Solis
-- Fecha: 25/02/2010
-- Comentario: Se modifico para que en el saldo anterior se coloque el saldo total para liquidar
--                  antes de realizar el pago.

-- Modifico: Paul Ivan Quintero Varela
-- Fecha: 25/02/2010
-- Comentario:  Se modifica para que el procedimiento regrese los siguientes campos:
--                      "usted debe al dia de hoy"
--                      "Su pago minimo hoy"
--                      "total que pago el cliente"
--                      "Cargo en cuenta eje"
--                      "Fecha limite de pago"

-- Modifico: Paul Ivan Quintero Varela
-- Fecha: 26/02/2010
-- Comentario:  Se modifica con la finalidad de reorganizar los codigos de retorno

-- Modifico:Jesus Manuel Aguilar Heredia
-- Fecha: 12-05-2011
-- Comentario: se realiza modificacion para contemplar nuevas transacciones de pago desde sucursal.
DEFINE iSqlErr            INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE cCodRet            CHAR(5);
DEFINE cCodRetAux         CHAR(6);
DEFINE cMensajeRet        VARCHAR(125,1);
DEFINE wBegin             CHAR(1);

DEFINE GLOBAL g_NumCredito      CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_CodFun          CHAR(3)        DEFAULT "020";
DEFINE GLOBAL g_CodRef          CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_CodFunProv      CHAR(3)        DEFAULT "606";
DEFINE GLOBAL g_Folio           CHAR(16)       DEFAULT "";
DEFINE GLOBAL g_dtFechaHoy      DATE           DEFAULT today;
DEFINE GLOBAL g_cEmpresa        CHAR(3)        DEFAULT "";
DEFINE GLOBAL g_dTasaInt        DECIMAL(9,6)   DEFAULT 0;
DEFINE GLOBAL g_dIvaSuc         DECIMAL(5,3)   DEFAULT 0;
DEFINE GLOBAL g_TransaccSuc     CHAR(4)        DEFAULT "";

DEFINE GLOBAL g_Cuenta               CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_NumTarjDeb           CHAR(20)       DEFAULT "";
DEFINE GLOBAL g_SdoCta               DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL g_StatusCtaCap         CHAR(1)        DEFAULT "";
DEFINE GLOBAL g_TranRet              CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_FechaCargo           DATE           DEFAULT today;
DEFINE GLOBAL g_SdoDisp              DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL g_MtoRet               DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL g_Sucursal             CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_Usuario              CHAR(8)        DEFAULT "";
DEFINE GLOBAL g_TranCargo            CHAR(4)        DEFAULT "0253";
DEFINE GLOBAL g_cheque               INTEGER        DEFAULT 0;
DEFINE GLOBAL g_Divisa               CHAR(2)        DEFAULT "";
DEFINE GLOBAL g_Leyenda              CHAR(40)       DEFAULT "CRG. CTA. ";
DEFINE GLOBAL g_Autoriza             CHAR(8)        DEFAULT "";
DEFINE GLOBAL g_TranCapt			 CHAR(4)		DEFAULT "";

DEFINE cNumCredito      CHAR(20);
DEFINE cCodigo_Fun      CHAR(3);
DEFINE cNumCreditocrd    CHAR(20);
DEFINE dtFechaApert       DATE;
DEFINE iIntAux            INTEGER;
DEFINE cCharAux           CHAR(80);
DEFINE dDecAux            DECIMAL(18,2);
DEFINE dtDateAux          DATE;
DEFINE dFechaAmortiza    	 DATE;
DEFINE cCodigoFun         CHAR(3);
DEFINE iCodRef            INTEGER;
DEFINE cNumCred           CHAR(20);
DEFINE cNumCte            CHAR(20);
DEFINE cSucursal          CHAR(4);
DEFINE dTasaInt           DECIMAL(9,6);
DEFINE dtFechApert        DATE;
DEFINE cNumProd           CHAR(4);
DEFINE cDivisa            CHAR(2);
DEFINE dSdoCapital        DECIMAL(18,2);
DEFINE dCapitalIns        DECIMAL(18,2);
DEFINE dSdoAnt            DECIMAL(18,2);
DEFINE dSdoAdeudTotal     DECIMAL(18,2);
DEFINE dSdoAdeudTotalAct  DECIMAL(18,2);
DEFINE dPagoMinAct        DECIMAL(18,2);
DEFINE dIntDebe           DECIMAL(14,2);
DEFINE dIntPag            DECIMAL(14,2);
DEFINE dIvaDebe           DECIMAL(14,2);
DEFINE dIvaPag            DECIMAL(14,2);
DEFINE cCapStatus         CHAR(1);
DEFINE dtIvaFechPag       DATE;
DEFINE dCapMtoCuota       DECIMAL(14,2);
DEFINE dIvaIntReal        DECIMAL(18,2);
DEFINE dTotalAdeudInt     DECIMAL(18,2);
DEFINE dFactorInt         DECIMAL(18,17);
DEFINE dPagoInt           DECIMAL(18,2);
DEFINE dPagoIvaInt        DECIMAL(18,2);
DEFINE dtIntFechPag       DATE;
DEFINE dTasaCom           DECIMAL(9,6);
DEFINE dPagoCapital       DECIMAL(18,2);
DEFINE dPagoCom           DECIMAL(18,2);
DEFINE dPagoIvaCom        DECIMAL(18,2);
DEFINE cFolio             CHAR(16);
DEFINE dIntMora           DECIMAL(18,2);
DEFINE dIvaIntMora        DECIMAL(18,2);
DEFINE dIntVdo            DECIMAL(18,2);
DEFINE dIvaIntVdo         DECIMAL(18,2);
DEFINE iNumPago           INTEGER;
DEFINE cIndicador         CHAR(1);
DEFINE dIntDevengado      DECIMAL(18,2);
DEFINE dIvaIntDevengado   DECIMAL(18,2);
DEFINE dtFechaFinMes      DATE;
DEFINE dtFechaHoy         DATE;
DEFINE dInteFinMes        DECIMAL(18,2);
DEFINE dIvaIntFinMes      DECIMAL(18,2);
DEFINE dProvInte          DECIMAL(18,2);
DEFINE dProvIvaInt        DECIMAL(18,2);
DEFINE dtFechaFinMesAnt   DATE;
DEFINE dIntGrav      	  DECIMAL(18,2);
DEFINE dIntExen       	  DECIMAL(18,2);
DEFINE dFechaT            DATE;
DEFINE dMontoPago         DECIMAL(18,2);
DEFINE dtFechaProxPago    DATE;
DEFINE cFechaLimite       CHAR(17);
DEFINE dtFechaApertura    DATE;
DEFINE cNomProd    		  CHAR(40);
DEFINE vcodigo_bloq 	  CHAR (2);
DEFINE clStatusCred		  CHAR(2);
DEFINE c_Folio_Suc		  CHAR(16);
--DEFINE dtFechaCompa       DATE;

---LABR
DEFINE pCodigo 		  CHAR(5);       
DEFINE pPeriodo          INTEGER;       
DEFINE pFechaCouta	 	  DATE;          
DEFINE pSaldoInicial  	  MONEY(18,2);   
DEFINE pMensualidad	  DECIMAL(18,2); 
DEFINE pIntereses	  	  MONEY(14,2);   
DEFINE pIvaInteres	  	  MONEY(14,2);  
DEFINE pCapital		  DECIMAL(18,2); 
DEFINE pSaldoFinal	 	  DECIMAL(18,2); 
DEFINE pDiasPeriodo      INTEGER;       
DEFINE pFechaAper	  	  DATE;          
DEFINE pNumMesesPago 	  CHAR(3);       
DEFINE pMontoContratado  DECIMAL(18,2);
DEFINE pMontoTotalaPagar DECIMAL(18,2);
DEFINE pTasaAnualFija 	  DECIMAL(18,2); 
DEFINE pTotLiq 	  DECIMAL(18,2);
DEFINE pAhorro	  DECIMAL(18,2);

DEFINE pFlgReduccion INTEGER;
---LABR

--FMV 01-Sep-11: Se adicionan el indicador y transaccion de la comision de Credinomina
DEFINE cind_comision   CHAR(1);
DEFINE ctran_comision  CHAR(4);
DEFINE mMontoEfec     MONEY(14,2);
DEFINE mMontoCargo    MONEY(14,2);
DEFINE mMonto		  MONEY(14,2);
DEFINE v_iva_cs       DECIMAL(14,2);
DEFINE cfolio_mov     CHAR(16);
DEFINE sCountExists   INTEGER;

DEFINE psaldoInteresApoyo	DECIMAL(14,2);
DEFINE psaldoIvaApoyo		DECIMAL(14,2);
DEFINE dTotalAdeudInt_apoyo	DECIMAL(14,2);
DEFINE sdo_apoyo			DECIMAL(14,2);
DEFINE vretenido			DECIMAL(14,2);
DEFINE GLOBAL gRespaldoActivo        CHAR(1) DEFAULT "0";
DEFINE GLOBAL gprocesa 		INT        DEFAULT 0;

/*LABR*/
DEFINE iCodRetornoPagAnt  CHAR(5);
DEFINE imsgPagAnt		  CHAR(2000);

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
   END IF;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

   LET wBegin = "N";
   BEGIN WORK;

LET g_Cuenta              = "";
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = "00000";
LET cCodRetAux            = "000000";
LET cMensajeRet           = "Se ejecuto el pago anticipado correctamente";

LET cNumCredito           = '';
LET cNumCreditocrd        = "";
LET dFechaAmortiza    	  = DATE(1);
LET g_NumCredito          = pNumCredito;
LET dtFechaApert          = DATE(1);
LET g_Folio               = pFolio;
LET g_cEmpresa            = pEmpresa;
LET iIntAux               = 0;
LET cCharAux              = "";
LET dDecAux               = 0;
LET dtDateAux             = DATE(1);
LET cCodigoFun            = "";
LET iCodRef               = 0;
LET cNumCred              = "";
LET cNumCte               = "";
LET cSucursal             = "";
LET dTasaInt              = 0;
LET dtFechApert           = DATE(1);
LET cNumProd              = "";
LET cDivisa               = "";
LET dSdoCapital           = 0;
LET dCapitalIns           = 0;
LET dSdoAnt               = 0;
LET dSdoAdeudTotal        = 0;
LET dSdoAdeudTotalAct     = 0;
LET dPagoMinAct           = 0;
LET dIntDebe              = 0;
LET dIntPag               = 0;
LET dIvaDebe              = 0;
LET dIvaPag               = 0;
LET cCapStatus            = "";
LET dtIvaFechPag          = DATE(1);
LET dCapMtoCuota          = 0;
LET dIvaIntReal           = 0;
LET dTotalAdeudInt        = 0;
LET dFactorInt            = 0;
LET dPagoInt              = 0;
LET dPagoIvaInt           = 0;
LET dtIntFechPag          = DATE(1);
LET dTasaCom              = 0;
LET dPagoCapital          = 0;
LET dPagoCom              = 0;
LET dPagoIvaCom           = 0;
LET cFolio                = "";
LET dIntMora              = 0;
LET dIvaIntMora           = 0;
LET dIntVdo               = 0;
LET dIvaIntVdo            = 0;
LET iNumPago              = 0;
LET cIndicador            = "N";
LET dIntDevengado         = 0;
LET dIvaIntDevengado      = 0;
LET dtFechaFinMes         = DATE(1);
LET dtFechaHoy            = DATE(1);
LET dInteFinMes           = 0;
LET dIvaIntFinMes         = 0;
LET dProvInte             = 0;
LET dProvIvaInt           = 0;
LET dtFechaFinMesAnt      = DATE(1);
LET dIntGrav              = 0;
LET dIntExen              = 0;
LET dFechaT               = DATE(1);
LET dMontoPago            = 0;
LET dtFechaProxPago       = DATE(1);
LET cFechaLimite          = "";
LET dtFechaApertura       = DATE(1);
--LET dtFechaCompa          = DATE(1);
LET g_Sucursal            = pSucursal;
LET g_Usuario             = pUsuario;
LET g_CodFun         	  =  "020";
LET g_CodRef			  = "";
LET g_CodFunProv          = "606";
LET g_TranCargo           = "0253";
LET g_TranCapt			  = "";
LET g_cheque              = 0 ;
LET g_Leyenda             = "CRG. CTA. ";
LET g_Autoriza            = "" ;
LET cNomProd    		  = "";
LET cCodigo_Fun    		  = "";
LET clStatusCred		= "";

LET cind_comision   ='';
LET ctran_comision  ='';
LET vcodigo_bloq = '';

LET mMontoEfec          = 0;
LET mMontoCargo         = 0;
LET mMonto		        = pMonto;
LET v_iva_cs            = 0;
LET cfolio_mov          = "";
LET c_Folio_Suc     	='';
LET sCountExists		= 0;

LET psaldoInteresApoyo	= 0;
LET psaldoIvaApoyo	 	= 0;
LET dTotalAdeudInt_apoyo = 0;
LET sdo_apoyo			= 0;
LET vretenido			= 0;

/*LABR*/
LET iCodRetornoPagAnt  ='';
LET imsgPagAnt		  	='';

---LABR
LET pCodigo 		  = "00000";       
LET pPeriodo          = 0;       
LET pFechaCouta	 	  = DATE(1);          
LET pSaldoInicial  	  = 0;   
LET pMensualidad	  = 0; 
LET pIntereses	  	  = 0;  
LET pIvaInteres	  	  = 0;   
LET pCapital		  = 0;  
LET pSaldoFinal	 	  = 0; 
LET pDiasPeriodo      = 0;     
LET pFechaAper	  	  = DATE(1);          
LET pNumMesesPago 	  ="";     
LET pMontoContratado  = 0;
LET pMontoTotalaPagar = 0;
LET pTasaAnualFija 	  = 0;
LET pTotLiq 	      = 0;
LET pAhorro	          = 0;

LET pFlgReduccion = 0;
---LABR

-- SET DEBUG FILE TO "/pisa/leo/sp_pago_anticipado_pp.out";
--TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-------------------------------------------------------------
-- Transacciones de Pago (Central):                        --
   -- 7462 -- Pago Anticipado Ventanilla.                  --
   -- 7469 -- Pago Anticipado Cargo a Cuenta.              --
   -- 7476 -- Pago Anticipado Salvo Buen Cobro (Cheque).   --
-------------------------------------------------------------

IF NVL(g_cEmpresa,"")= "" OR  NVL(g_NumCredito,"") = "" OR NVL(pUsuario,"") = "" OR NVL(pSucursal,"") = "" OR NVL(pTransacc,"") NOT IN ("7462","7469","7476","7970","7998","4210","8205","8150","8160","8283","7990",'8317','7590','8335','8671','8654','8738','5025','4250','4260','4266','9888','4320') OR NVL(pMonto,0) <= 0 OR NVL(g_Folio,"") = "" THEN
	 LET cCodRet      = "00411";
	 LET cMensajeRet  = "NO HAY ARGUMENTOS (PARAMETROS)";
	   ROLLBACK WORK;
		IF (wBegin = "S") THEN
		   BEGIN WORK;
		END IF;
	 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

--09/003/2017
SELECT max( a.fecha_cuota )
	INTO dFechaAmortiza
FROM "informix".sd_amortiza_creditocrd a
WHERE a.empresa = pEmpresa
	AND a.num_credito = g_NumCredito;
--09/003/2017

LET sCountExists = 0;
SELECT count(a.num_credito ) INTO sCountExists
  FROM "informix".sd_amortiza_creditocrd a
 WHERE a.empresa     = g_cEmpresa
   AND a.num_credito = g_NumCredito
   AND a.capital_status IN ("1","2","7","6")
   AND a.fecha_cuota = dFechaAmortiza;

/*IF EXISTS (SELECT a.num_credito
			 FROM "informix".sd_amortiza_creditocrd a
			WHERE a.empresa     = g_cEmpresa
			  AND a.num_credito = g_NumCredito
			  AND a.capital_status IN ("1","2","7")
			  and a.fecha_cuota = dFechaAmortiza ) THEN */
IF sCountExists > 0 THEN			  
	 LET cCodRet      = "00041";
	 LET cMensajeRet  = "No es posible recibir el pago anticipado";
	   ROLLBACK WORK;
		IF (wBegin = "S") THEN
		   BEGIN WORK;
		END IF;
	 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

SELECT a.num_credito,a.numcte,a.tasa_interes,a.fecha_apertura,a.num_producto,a.divisa,b.ind_comision,b.tran_comision, id_origen,status_cred
  INTO cNumCred,cNumCte,g_dTasaInt,dtFechaApert,cNumProd,cDivisa, cind_comision, ctran_comision, vcodigo_bloq, clStatusCred
  FROM "informix".sd_maecredcrd a, "informix".sd_definicion b
 WHERE a.num_credito  = g_NumCredito
   AND a.empresa      = g_cEmpresa
   AND a.num_producto = b.num_producto
   AND a.empresa      = b.empresa;


IF  vcodigo_bloq = '1' THEN
	LET cCodRet      = "00199";
	LET cMensajeRet  = "Cuenta bloqueada";
	ROLLBACK WORK;
	IF (wBegin = "S") THEN
		BEGIN WORK;
	END IF;
	RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

IF  clStatusCred = 'FF' THEN
	LET cCodRet      = "01092";
	LET cMensajeRet  = "Imposible aplicar Pago el credito tiene estatus Liquidada 'FF'";
	ROLLBACK WORK;
	IF (wBegin = "S") THEN
		BEGIN WORK;
	END IF;
	RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

IF  clStatusCred = 'CV' THEN
	LET cCodRet      = "01091";
	LET cMensajeRet  = "Imposible aplicar Pago el credito tiene estatus Vendida 'CV'";
	ROLLBACK WORK;
	IF (wBegin = "S") THEN
		BEGIN WORK;
	END IF;
	RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

SELECT nombre_prod INTO cNomProd
FROM "informix".sd_definicion
WHERE num_producto = cNumProd;

LET g_Leyenda = TRIM(g_Leyenda)||' '||TRIM(NVL(cNomProd,""));


   LET cSucursal = pSucursal;

IF cNumCred IS NULL THEN
	LET cCodRet      = "00224";
	LET cMensajeRet  = "NO EXISTE NUMERO DE CREDITO";
	ROLLBACK WORK;
		IF (wBegin = "S") THEN
		   BEGIN WORK;
		END IF;
	RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;
LET pTransacc = pTransacc;

IF pTransacc IN ("7462","7469","7476","7970","7998","4210","8205","8150","8160","8286",'8317','7590','8335','8671','8654','8738','5025','4250','4260','4266','9888','4320') THEN
	   SELECT transacc_rel INTO g_CodFun
		FROM "informix".sd_conceptospagomanualcrd
		WHERE transacc = pTransacc
		AND num_producto = cNumProd;
--        AND transacc_suc = '620';
ELSE
		LET cCodRet      = "00189";
		LET cMensajeRet  = "Transaccion incorrecta";
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;

		RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(g_cEmpresa,g_NumCredito)
			 INTO cCodRetAux,cMensajeRet,cCharAux,cCharAux,dtDateAux,dtDateAux,dDecAux,dtDateAux,
				   iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
				   dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
				   dDecAux,dPagoCom,dPagoIvaCom,dDecAux,dSdoAdeudTotal,dIntDevengado,dIvaIntDevengado,
				   dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
				   cCharAux,cCharAux,iIntAux,cCharAux;

IF cCodRetAux <> "000000" THEN
	  LET cCodRet      = "00042";
	  LET cMensajeRet  = "Ocurrio un error al obtener el adeudo total del cliente";
	   ROLLBACK WORK;
		IF (wBegin = "S") THEN
		   BEGIN WORK;
		END IF;
	  RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

--- se obtienen los  montos de INT e IVA de la maeretenido del prorama de apoyo
SELECT monto
	INTO psaldoInteresApoyo
FROM bdicred:sd_maeretenido 
WHERE num_credito = g_NumCredito
	AND transacc = '8374'
	AND estatus = 'R';

	IF psaldoInteresApoyo IS NULL THEN
		LET psaldoInteresApoyo = 0;
	END IF;

SELECT monto
	INTO psaldoIvaApoyo
FROM bdicred:sd_maeretenido 
WHERE num_credito = g_NumCredito
	AND transacc ='8375'
	AND estatus = 'R';

	IF psaldoIvaApoyo IS NULL THEN
		LET psaldoIvaApoyo = 0;
	END IF;
	
---	Se suman los montos de interes e IVA del programa de apoyo a la deuda total
-- IF psaldoInteresApoyo > 0 THEN
-- 	LET dSdoAdeudTotal = dSdoAdeudTotal + psaldoInteresApoyo + psaldoIvaApoyo;
-- END IF;
-- 
IF pMonto > NVL(dSdoAdeudTotal,0) THEN
	  LET cCodRet      = "00043";
	  LET cMensajeRet  = "ESTA PAGANDO MAS DE LO QUE DEBE, REALIZAR CONSULTA DE SALDO Y PAGAR IMPORTE";
	   ROLLBACK WORK;
		IF (wBegin = "S") THEN
		   BEGIN WORK;
		END IF;
	  RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

SELECT fecha_hoy, ult_dia_mes
  INTO dtFechaHoy, dtFechaFinMes
  FROM "informix".sd_fechas
 WHERE empresa=pEmpresa;
 
 IF  cNumProd = '6800' then --RQM 10 1155
    Select fecha_proceso  INTO dtFechaHoy --Fecha proceso credito
	FROM bdicred:"informix".sd_maecredanexocrd 
	WHERE empresa = pEmpresa
	AND num_credito = g_NumCredito;
 END IF;

LET g_dtFechaHoy=dtFechaHoy;

IF pMonto < NVL(dSdoAdeudTotal,0) and pMonto >= NVL(dSdoAdeudTotal-dPagoCom-dPagoIvaCom,0)  THEN --and dtFechaHoy < dFechaT
	  LET cCodRet      = "00082";
	  LET cMensajeRet  = "El cliente no alcanza a liquidar su comision, por favor realizar consulta de saldo y pagar el importe correspondiente";
	   ROLLBACK WORK;
		IF (wBegin = "S") THEN
		   BEGIN WORK;
		END IF;
	  RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

LET dtFechaFinMesAnt=DATE(MDY(MONTH(dtFechaFinMes),'01',YEAR(dtFechaFinMes))-1);


LET g_Cuenta = " ";
--validacion para pago anticipado con cargo a cuenta--Se quita la transaccion del cargo a cuenta para credisolucion y realizarlo ligado al credito
IF pTransacc IN("7469","7998","8150","9888") THEN
	-- Se obtiene la cuenta a la cual se le realizo el deposito del prestamo.
	IF pTransacc = "8150" THEN
		 -- DSB TH 20161108
		SELECT a.numcta
		INTO g_Cuenta
		FROM  "informix".sd_verif_cuentas_crd a
		WHERE a.empresa      = g_cEmpresa 
		  AND a.numcredisol  = g_NumCredito;
		LET g_TranCargo = '0438';
		--ME 17/04/2018
		SELECT num_credito
		INTO  cNumCredito
		FROM "informix".sd_promocion_credito
		WHERE  empresa= pEmpresa
		and num_sol_prestamo = pNumCredito;	
		LET pNumCredito = cNumCredito;
	ELSE
		  SELECT a.num_cta
		  INTO g_Cuenta
		  FROM "informix".sd_ctascarg a
		  WHERE a.num_credito  = g_NumCredito
		   AND a.empresa      = g_cEmpresa
		   AND a.naturaleza   = "A";
	END IF;
	
	  IF NVL(g_Cuenta,"") = "" THEN
		  LET cCodRet      = "00044";
		  LET cMensajeRet  = "No se pudo consultar la cuenta efectiva";
		   ROLLBACK WORK;
			IF (wBegin = "S") THEN
			   BEGIN WORK;
			END IF;
		  RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
	  END IF;

	  -- Se obtiene el numero de tarjeta.
	  SELECT a.num_tarjeta
		INTO g_NumTarjDeb
		FROM bdicheq:"informix".sc_tarjeta a
	   WHERE a.empresa   = g_cEmpresa
		 AND a.cuenta    = g_Cuenta
		 AND a.secuencia = (SELECT MAX(b.secuencia)
							  FROM bdicheq:"informix".sc_tarjeta b
							 WHERE b.empresa      = a.empresa
							   AND b.cuenta       = a.cuenta
							   AND b.secuencia    = b.secuencia
							   AND b.tipo_tarjeta = "T");

		IF g_NumTarjDeb IS NULL THEN
		   LET g_NumTarjDeb = "";
		END IF;

		-- Se obtiene el saldo de la cuenta identificada.
		CALL bdicheq:"informix".cons_saldo(g_Cuenta) RETURNING cCodRetAux,g_SdoCta,g_StatusCtaCap;

		IF (cCodRetAux <> "000") THEN
			 LET cCodRet      = "00187";
			 LET cMensajeRet  = "No es posible obtener el saldo actual de la cuenta cliente";
			   ROLLBACK WORK;
				IF (wBegin = "S") THEN
				   BEGIN WORK;
				END IF;
			 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;

		-- Valida si el saldo esta activo para poder usarlo .
		IF g_StatusCtaCap <> "1" THEN
			 LET cCodRet      = "00188";
			 LET cMensajeRet  = "El saldo no esta activo para poder usarlo";
			   ROLLBACK WORK;
				IF (wBegin = "S") THEN
				   BEGIN WORK;
				END IF;
			 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;

		-- Valida el saldo obtenido de la cuenta.
		IF NVL(g_SdoCta,0) <= 0 or NVL(g_SdoCta,0) < pMonto THEN
			 LET cCodRet      = "00050";
			 LET cMensajeRet  = "El saldo no es valido";
			   ROLLBACK WORK;
				IF (wBegin = "S") THEN
				   BEGIN WORK;
				END IF;
			 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;
		--INC 25 170 AAME 30072018 Se omite el cargo del adeudo a la cuenta para que se realice en el pago al credito por cargo a cuenta
		IF pTransacc NOT IN("8150") THEN
		  -- Realiza el cargo del adeudo a la cuenta
			IF pTransacc IN ("9888") THEN
						    CASE cNumProd
							   WHEN '6300' THEN LET g_TranCapt = '0548';
							   WHEN '7700' THEN LET g_TranCapt = '0548';
							   WHEN '7600' THEN LET g_TranCapt = '0548';
							   WHEN '6800' THEN LET g_TranCapt = '0549';
							   WHEN '9300' THEN LET g_TranCapt = '0553';
							   WHEN '6400' THEN LET g_TranCapt = '0550';
							   WHEN '9100' THEN LET g_TranCapt = '0554';
							   WHEN '6011' THEN LET g_TranCapt = '0551';
							   ELSE
								  RAISE EXCEPTION 100; --valor invalido
							END CASE;
							
							EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
																			g_Sucursal,
																			g_Usuario,
																			g_TranCapt,
																			g_TranCapt,
																			g_Folio,
																			g_Cuenta,
																			g_cheque,
																			pMonto,
																			cDivisa,
																			TRIM(pNumCredito)||" "||g_Leyenda,
																			g_NumTarjDeb,
																			g_Autoriza)
							INTO cCodRetAux, g_TranRet, g_FechaCargo, g_SdoDisp, g_MtoRet;
							
						ELSE
						  EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
															  g_Sucursal,
															  g_Usuario,
															  g_TranCargo,
															  pTransacc,
															  g_Folio,
															  g_Cuenta,
															  g_cheque,
															  pMonto,
															  cDivisa,
															  TRIM(pNumCredito)||" "||g_Leyenda,
															  g_NumTarjDeb,
															  g_Autoriza)

							INTO cCodRetAux, g_TranRet, g_FechaCargo, g_SdoDisp, g_MtoRet;
						END IF;

		   IF cCodRetAux <> "000" THEN
			   LET cCodRet      = "00051";
			   LET cMensajeRet  = "Ocurrio un error al aplicar el cargo a la cuenta de captacion";
			   ROLLBACK WORK;
				IF (wBegin = "S") THEN
				   BEGIN WORK;
				END IF;
			   RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		   END IF;
		END IF;
END IF;

SELECT a.iva
  INTO g_dIvaSuc
  FROM bdinteg:"informix".si_sucursales a
 WHERE a.sucursal = cSucursal
   AND a.empresa  = g_cEmpresa;

IF NVL(g_dIvaSuc,0) = 0 THEN
	LET cCodRet      = "00052";
	LET cMensajeRet  = "Ocurrio un error al obtener el iva de la sucursal";
	   ROLLBACK WORK;
		IF (wBegin = "S") THEN
		   BEGIN WORK;
		END IF;
	RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

SELECT a.sdo_capital,        -- Saldo Capital
	   a.sdo_cap_insoluto,    -- Saldo Capital Insoluto
	   a.provision_normal,     --porcion que restas de la provision fin de mes de los intereses
	   a.sdo_global_int      --porcion que resta de la provision de fin de mes del iva de intereses
  INTO dSdoCapital,
	   dCapitalIns,
	   dInteFinMes,
	   dIvaIntFinMes
  FROM "informix".sd_maesdoscrd a
 WHERE a.num_credito = g_NumCredito
   AND a.empresa     = g_cEmpresa;

	IF dSdoCapital IS NULL THEN LET dSdoCapital = 0; END IF;
	IF dCapitalIns IS NULL THEN LET dCapitalIns = 0; END IF;
	IF dInteFinMes IS NULL THEN LET dInteFinMes=0;   END IF;
	IF dIvaIntFinMes IS NULL THEN LET dIvaIntFinMes = 0; END IF;

	LET dSdoAnt = dSdoCapital;

SELECT a.interes_debe,      -- Interes Ordinario Vigente
	   a.interes_pagado,    -- Interes Ordinario Vigente Pagado
	   a.iva_debe,          -- Iva de Interes Ordinario Vigente
	   a.iva_pagado,        -- Iva de Interes Ordinario Vigente Pagado
	   a.capital_status,    -- Estatus de la Mensualidad
	   a.capital_mto_cuota, -- Capital Monto Cuota
	   a.num_pago
  INTO dIntDebe,
	   dIntPag,
	   dIvaDebe,
	   dIvaPag,
	   cCapStatus,
	   dCapMtoCuota,
	   iNumPago
  FROM "informix".sd_amortiza_creditocrd a
 WHERE a.empresa         = g_cEmpresa
   AND a.num_credito     = g_NumCredito
   AND a.capital_status  = "3";

   -- Se genera el movimiento uno del anticipo realizado
	IF pTransacc = "9888" THEN
		CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,88,'059',g_dtFechaHoy,pMonto,g_Folio,cSucursal,cDivisa,g_TransaccSuc,"ANTICIPO","")
		RETURNING cCodRetAux, cMensajeRet;
	ELIF pTransacc = "4320" THEN
		CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,89,'059',g_dtFechaHoy,pMonto,g_Folio,cSucursal,cDivisa,g_TransaccSuc,"ANTICIPO","")
		RETURNING cCodRetAux, cMensajeRet;
	ELSE
		CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,1,g_CodFun,g_dtFechaHoy,pMonto,g_Folio,cSucursal,cDivisa,g_TransaccSuc,"ANTICIPO","")
		RETURNING cCodRetAux, cMensajeRet;
	END IF;

    IF (cCodRetAux <> "000000") THEN
         LET cCodRet      = "00053";
         LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de Pago";
           ROLLBACK WORK;
            IF (wBegin = "S") THEN
               BEGIN WORK;
            END IF;
         RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
    END IF;

    LET dMontoPago = pMonto;

   -- Se respalda el credito
   IF pbanderarespaldo ='1' AND gRespaldoActivo = '0' THEN
      CALL "informix".sp_respalda_credito_pp(g_cEmpresa, g_NumCredito, USER) RETURNING cCodRetAux;

      IF cCodRetAux <> "000000" THEN
          LET cCodRet      = "00054";
          LET cMensajeRet  = "Ocurrio un error respaldar la informacion del credito";
           ROLLBACK WORK;
            IF (wBegin = "S") THEN
               BEGIN WORK;
            END IF;
          RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
      END IF;
   END IF;

   ---- Flujo para anticipo de Interes e IVA del programa de apoyo
IF psaldoInteresApoyo > 0 THEN

	LET dTotalAdeudInt_apoyo = psaldoInteresApoyo + psaldoIvaApoyo;
   
	IF (pMonto < dTotalAdeudInt_apoyo) THEN
		LET dFactorInt    = psaldoInteresApoyo / dTotalAdeudInt_apoyo;
		LET dPagoInt      = dFactorInt * pMonto;
		LET dPagoIvaInt   = pMonto - dPagoInt;
		LET pMonto        = pMonto - dPagoIvaInt - dPagoInt;
		 
		UPDATE bdicred:sd_maeretenido 
			SET monto = monto - dPagoInt 
		WHERE num_credito =  g_NumCredito AND transacc = '8374';
		
		UPDATE bdicred:sd_maeretenido 
			SET monto = monto - dPagoIvaInt 
		WHERE num_credito =  g_NumCredito AND transacc = '8375';
		
		UPDATE "informix".sd_maesdoscrd
			SET sdo_retenido = sdo_retenido - (dPagoInt + dPagoIvaInt)
		WHERE num_credito      = g_NumCredito
			AND empresa          = g_cEmpresa;
		 
	ELSE
		LET dPagoIvaInt   = psaldoIvaApoyo;
		LET dPagoInt      = psaldoInteresApoyo;
		LET pMonto        = pMonto - dPagoIvaInt - dPagoInt;
		 
		UPDATE bdicred:sd_maeretenido 
			SET monto = monto - dPagoInt,estatus = 'S' 
		WHERE num_credito =  g_NumCredito AND transacc = '8374';
		
		UPDATE bdicred:sd_maeretenido 
			SET monto = monto - dPagoIvaInt,estatus = 'S' 
		WHERE num_credito =  g_NumCredito AND transacc = '8375';
		
		UPDATE "informix".sd_maesdoscrd
			SET sdo_retenido = sdo_retenido - (dPagoInt + dPagoIvaInt)
		WHERE num_credito      = g_NumCredito
			AND empresa          = g_cEmpresa;
		 
	END IF;

	IF clStatusCred='AA' OR clStatusCred='BA' OR clStatusCred='BT' THEN 
		LET g_CodRef ='11';
	ELIF clStatusCred='E1' OR clStatusCred='E2' OR clStatusCred='E3' THEN
		LET g_CodRef ='11';
	END IF;

	-- Movimiento contable pago de interes del programa de apoyo
	CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFun,g_dtFechaHoy,dPagoInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
	RETURNING cCodRetAux, cMensajeRet;

	IF (cCodRetAux <> "000000") THEN
		LET cCodRet      = "00058";
		LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago interes vigente";
		   ROLLBACK WORK;
			IF (wBegin = "S") THEN
			   BEGIN WORK;
			END IF;
		RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
	END IF;

	IF clStatusCred='AA' OR clStatusCred='BA' OR clStatusCred='BT' THEN 
		LET g_CodRef ='12';
	ELIF clStatusCred='E1' OR clStatusCred='E2' OR clStatusCred='E3' THEN
		LET g_CodRef ='12';
	END IF;

	-- Movimiento Contable Pago de Iva del programa de apoyo
	CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFun,g_dtFechaHoy,dPagoIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
	RETURNING cCodRetAux, cMensajeRet;

	IF (cCodRetAux <> "000000") THEN
		 LET cCodRet      = "00059";
		 LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago iva interes vigente";
		   ROLLBACK WORK;
			IF (wBegin = "S") THEN
			   BEGIN WORK;
			END IF;
		 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
	END IF;
END IF;
   ---- Flujo para anticipo de Interes e IVA del programa de apoyo
  
IF g_dtFechaHoy = dtFechaApert THEN ---????cas
   -- Si se realiza el anticipo en dia de la apertura no realiza cobro de interes ni iva.
   LET dTotalAdeudInt  = 0;
ELSE
	-- Se toma el iva de interes devengado obtenido de la consulta generalizada
	 LET dIvaIntReal = dIvaIntDevengado;
	 LET dTotalAdeudInt = dIntDevengado + dIvaIntReal;
END IF;

IF pMonto > 0  THEN
	IF dTotalAdeudInt > 0 AND dIntDevengado > 0 THEN
		IF (pMonto <= dTotalAdeudInt) THEN
			 LET dFactorInt    = (dIntDebe - dIntPag) / dTotalAdeudInt;
			 --LET dPagoInt      = ROUND(dFactorInt * pMonto,2);
			 LET dPagoInt      = dFactorInt * pMonto;
			 LET dPagoIvaInt   = pMonto - dPagoInt;
			 LET pMonto        = pMonto - dPagoIvaInt - dPagoInt;
		ELSE
			 LET dPagoIvaInt   = dIvaIntReal;
			 LET dPagoInt      = dIntDebe - dIntPag;
			 LET pMonto        = pMonto - dPagoIvaInt - dPagoInt;
		END IF;

			 LET cIndicador = "S";

		 -- Se actualizan los intereses e ivas de la amortizacion
		  UPDATE "informix".sd_amortiza_creditocrd
			 SET interes_pagado      = interes_pagado + dPagoInt,
				 iva_debe            = iva_debe + dPagoIvaInt,
				 iva_pagado          = iva_pagado + dPagoIvaInt,
				 interes_fecha_pago  = (CASE WHEN (dPagoInt <= (dIntDebe - dIntPag)) THEN TO_CHAR(g_dtFechaHoy) ELSE interes_fecha_pago END),
				 iva_fecha_pago      = (CASE WHEN (dPagoIvaInt = dIvaIntReal) THEN g_dtFechaHoy ELSE iva_fecha_pago END)
		   WHERE empresa             = g_cEmpresa
			 AND num_credito         = g_NumCredito
			 AND capital_status      = "3";

			  IF dInteFinMes > 0 THEN
				 IF dInteFinMes > dPagoInt THEN
					LET dProvInte = dInteFinMes - dPagoInt;
				 ELSE
					LET dProvInte = 0;
				 END IF;
			 ELSE
			   LET dProvInte =dInteFinMes;
			END IF;

			 IF dIvaIntFinMes > 0 THEN
				 IF dIvaIntFinMes > dPagoIvaInt THEN
					LET dProvIvaInt = dIvaIntFinMes - dPagoIvaInt;
				 ELSE
					LET dProvIvaInt = 0;
				 END IF;
			 ELSE
			   LET dProvIvaInt =dIvaIntFinMes;
			END IF;

		 if dProvInte < 0   then let dProvInte = 0; end if;
		 if dProvIvaInt < 0 then let dProvIvaInt = 0; end if;

		  UPDATE "informix".sd_maesdoscrd
			 SET sdo_intereses    = sdo_intereses - dPagoInt,
				 sdo_acum_mes_int = sdo_acum_mes_int - dPagoInt,
				 provision_normal = dProvInte,
				 sdo_global_int   = dProvIvaInt
		   WHERE num_credito      = g_NumCredito
			 AND empresa          = g_cEmpresa;

		IF dInteFinMes < dPagoInt THEN
			LET dProvInte = dPagoInt - dInteFinMes;

			IF clStatusCred='AA' OR clStatusCred='BA' OR clStatusCred='BT' THEN 
				LET g_CodRef ='6';
			ELIF clStatusCred='E1' OR clStatusCred='E2' OR clStatusCred='E3' THEN
				LET g_CodRef ='7034';
			END IF;
			
			IF pTransacc = "9888" THEN
				LET g_CodRef = '70';
			ELIF pTransacc = "4320" THEN
				LET g_CodRef = '119';
			END IF;
			IF g_TransaccSuc = '8671'  THEN
				-- Movimiento contable para reconocimiento de interes vigente
				CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,'127',g_dtFechaHoy,dProvInte,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
				RETURNING cCodRetAux, cMensajeRet;
			ELIF g_TransaccSuc IN ('9888','4320') THEN
			   CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,'059',g_dtFechaHoy,dProvInte,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
				RETURNING cCodRetAux, cMensajeRet;
			ELSE			
				-- Movimiento contable para reconocimiento de interes vigente
				CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFunProv,g_dtFechaHoy,dProvInte,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
				RETURNING cCodRetAux, cMensajeRet;
			END IF;

			IF (cCodRetAux <> "000000") THEN
			   LET cCodRet      = "00055";
			   LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable provision de interes vigente";
			   ROLLBACK WORK;
				IF (wBegin = "S") THEN
				   BEGIN WORK;
				END IF;
			   RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
			END IF;
		END IF;

		IF dIvaIntFinMes < dPagoIvaInt THEN
			LET dProvIvaInt           = dPagoIvaInt - dIvaIntFinMes;

			IF clStatusCred='AA' OR clStatusCred='BA' OR clStatusCred='BT' THEN 
				LET g_CodRef ='7';
			ELIF clStatusCred='E1' OR clStatusCred='E2' OR clStatusCred='E3' THEN
				LET g_CodRef ='7031';
			END IF;
			
			IF pTransacc = "9888" THEN
				LET g_CodRef = '71';
			ELIF pTransacc = "4320" THEN
				LET g_CodRef = '120';
			END IF;
			IF g_TransaccSuc = '8671'  THEN
				 -- Movimiento contable para reconocimiento de iva de interes vigente
				CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,'127',g_dtFechaHoy,dProvIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
				RETURNING cCodRetAux, cMensajeRet;
			ELIF g_TransaccSuc IN ('9888','4320') THEN
			    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,'059',g_dtFechaHoy,dProvIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
				RETURNING cCodRetAux, cMensajeRet;
			ELSE
				 -- Movimiento contable para reconocimiento de iva de interes vigente
				CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFunProv,g_dtFechaHoy,dProvIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
				RETURNING cCodRetAux, cMensajeRet;
			
			END  IF;

			IF (cCodRetAux <> "000000") THEN
				 LET cCodRet      = "00057";
				 LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago iva interes vigente";
				   ROLLBACK WORK;
					IF (wBegin = "S") THEN
					   BEGIN WORK;
					END IF;
				 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
			END IF;
		ELIF  dPagoIvaInt > 0 AND g_TransaccSuc = '8671'  THEN
		----	LET dProvIvaInt           = dPagoIvaInt - dIvaIntFinMes;
			 -- Movimiento contable para reconocimiento de iva de interes vigente para quitas
			 
			IF clStatusCred='AA' OR clStatusCred='BA' OR clStatusCred='BT' THEN 
				LET g_CodRef ='7';
			ELIF clStatusCred='E1' OR clStatusCred='E2' OR clStatusCred='E3' THEN
				LET g_CodRef ='7031';
			END IF;

			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,'127',g_dtFechaHoy,dPagoIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			RETURNING cCodRetAux, cMensajeRet;

			IF (cCodRetAux <> "000000") THEN
				 LET cCodRet      = "00057";
				 LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago iva interes vigente";
				   ROLLBACK WORK;
					IF (wBegin = "S") THEN
					   BEGIN WORK;
					END IF;
				 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
			END IF;
		END IF;
	---ini cas, Se agrega el movimiento aplicativo de interes gravable y exento
					IF dProvInte>0 and dProvIvaInt<=0 then
						LET dIntGrav = dProvInte;
						LET dIntExen = 0;
					ELSE
						LET dIntGrav = dProvIvaInt/g_dIvaSuc;
						LET dIntExen = dProvInte-dIntGrav;
					END IF;

					IF dIntGrav>0 THEN

						IF clStatusCred='AA' OR clStatusCred='BA' OR clStatusCred='BT' THEN 
							LET g_CodRef ='12';
						ELIF clStatusCred='E1' OR clStatusCred='E2' OR clStatusCred='E3' THEN
							LET g_CodRef ='12';
						END IF;

						IF pTransacc = "9888" THEN
							LET g_CodRef = '71';
						ELIF pTransacc = "4320" THEN
							LET g_CodRef = '120';
						END IF;
						
						    IF g_TransaccSuc IN ('9888','4320') THEN
							   CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,'059',g_dtFechaHoy,dIntGrav,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
								RETURNING cCodRetAux, cMensajeRet;
						    ELSE
								CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFunProv,g_dtFechaHoy,dIntGrav,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
								RETURNING cCodRetAux, cMensajeRet;
							END IF;

						IF (cCodRetAux <> "000000") THEN
							 LET cCodRet      = "00083";
							 LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de Interes Gravado";
							   ROLLBACK WORK;
								IF (wBegin = "S") THEN
								   BEGIN WORK;
								END IF;
							 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
						END IF;
					END IF;
					IF dIntExen>0 THEN

						IF clStatusCred='AA' OR clStatusCred='BA' OR clStatusCred='BT' THEN 
							LET g_CodRef ='13';
						ELIF clStatusCred='E1' OR clStatusCred='E2' OR clStatusCred='E3' THEN
							LET g_CodRef ='13';
						END IF;
						
						   IF g_TransaccSuc NOT IN ('9888','4320') THEN
								CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFunProv,g_dtFechaHoy,dIntExen,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
								RETURNING cCodRetAux, cMensajeRet;
							END IF;

						/*IF pTransacc = "9888" THEN
							LET g_CodRef = '69';
						ELIF pTransacc = "4320" THEN
							LET g_CodRef = '118';
						END IF;
						   IF g_TransaccSuc IN ('9888','4320') THEN
							    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,'059',g_dtFechaHoy,dIntExen,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
								RETURNING cCodRetAux, cMensajeRet;
						    ELSE
								CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFunProv,g_dtFechaHoy,dIntExen,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
								RETURNING cCodRetAux, cMensajeRet;
							END IF;
						*/

						IF (cCodRetAux <> "000000") THEN
							 LET cCodRet      = "00084";
							 LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de Interes Exento";
							   ROLLBACK WORK;
								IF (wBegin = "S") THEN
								   BEGIN WORK;
								END IF;
							 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
						END IF;
					END IF;
	---fin cas, Se agrega el movimiento aplicativo de interes gravable y exento

		IF clStatusCred='AA' OR clStatusCred='BA' OR clStatusCred='BT' THEN 
			LET g_CodRef ='5';
		ELIF clStatusCred='E1' OR clStatusCred='E2' OR clStatusCred='E3' THEN
			LET g_CodRef ='962';
		END IF;
		IF pTransacc = "9888" THEN
			IF clStatusCred = 'E1' THEN
				LET g_CodRef = '56';
			ELIF clStatusCred = 'E2' THEN
				LET g_CodRef = '60';
			ELIF clStatusCred = 'E3' THEN
				LET g_CodRef = '64';
			ELSE
				LET g_CodRef = '64';
			END IF;
		END IF;
		
		IF pTransacc = "4320" THEN
			IF clStatusCred = 'E1' THEN
				LET g_CodRef = '105';
			ELIF clStatusCred = 'E2' THEN
				LET g_CodRef = '109';
			ELIF clStatusCred = 'E3' THEN
				LET g_CodRef = '113';
			ELSE
				LET g_CodRef = '113';
			END IF;
		END IF;
		
		IF g_TransaccSuc = '8671'  THEN
			-- Movimiento contable pago de interes vigente
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFun,g_dtFechaHoy,dInteFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			RETURNING cCodRetAux, cMensajeRet;
		ELSE
			-- Movimiento contable pago de interes vigente
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFun,g_dtFechaHoy,dPagoInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			RETURNING cCodRetAux, cMensajeRet;
		END IF;

		IF (cCodRetAux <> "000000") THEN
			LET cCodRet      = "00058";
			LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago interes vigente";
			   ROLLBACK WORK;
				IF (wBegin = "S") THEN
				   BEGIN WORK;
				END IF;
			RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;

		IF clStatusCred='AA' OR clStatusCred='BA' OR clStatusCred='BT' THEN 
			LET g_CodRef ='8';
		ELIF clStatusCred='E1' OR clStatusCred='E2' OR clStatusCred='E3' THEN
			LET g_CodRef ='963';
		END IF;

		IF pTransacc = "9888" THEN
			IF clStatusCred = 'E1' THEN
				LET g_CodRef = '67';
			ELIF clStatusCred = 'E2' THEN
				LET g_CodRef = '67';
			ELIF clStatusCred = 'E3' THEN
				LET g_CodRef = '67';
			ELSE
				LET g_CodRef = '67';
			END IF;
		END IF;
		
		IF pTransacc = "4320" THEN
			IF clStatusCred = 'E1' THEN
				LET g_CodRef = '116';
			ELIF clStatusCred = 'E2' THEN
				LET g_CodRef = '116';
			ELIF clStatusCred = 'E3' THEN
				LET g_CodRef = '116';
			ELSE
				LET g_CodRef = '116';
			END IF;
		END IF;
		IF g_TransaccSuc = '8671'  THEN
			-- Movimiento Contable Pago de Iva de Interes Vigente
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFun,g_dtFechaHoy,dIvaIntFinMes,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			RETURNING cCodRetAux, cMensajeRet;
		ELSE
			-- Movimiento Contable Pago de Iva de Interes Vigente
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFun,g_dtFechaHoy,dPagoIvaInt,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			RETURNING cCodRetAux, cMensajeRet;
		END IF;	

		IF (cCodRetAux <> "000000") THEN
			 LET cCodRet      = "00059";
			 LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago iva interes vigente";
			   ROLLBACK WORK;
				IF (wBegin = "S") THEN
				   BEGIN WORK;
				END IF;
			 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;
	END IF;
END IF;
IF pMonto > 0  THEN
  IF pMonto > dSdoCapital THEN
	LET dPagoCapital = dSdoCapital;
	LET pMonto = pMonto - dSdoCapital;
  ELSE
	LET dPagoCapital = pMonto;
	LET pMonto  = 0;
  END IF;
END IF;

IF dPagoCapital > 0 THEN

  -- Actualiza el Saldo a Capital
  UPDATE "informix".sd_maesdoscrd
	 SET sdo_capital       = sdo_capital  - dPagoCapital,
		 sdo_cap_insoluto  = sdo_cap_insoluto - dPagoCapital
   WHERE num_credito       = g_NumCredito
	 AND empresa           = g_cEmpresa;
  -- Bandera para reduccion de monto en caso de que tipo sea 2 puede obtener aprox monto_cuota	 
  LET pFlgReduccion = 1;
	 	
--IPCB 12_2017 - Se actualiza la linea_disponible, para prestamo flexibles	
  UPDATE bdicred:sd_linea_prestamo 
     SET linea_disponible = linea_disponible + dPagoCapital , fecha_ult_mod = current 
		  WHERE empresa = g_cEmpresa
			AND num_credito = g_NumCredito;		 
	 
	 -- Movimiento contable pago capital anticipado

	IF clStatusCred='AA' OR clStatusCred='BA' OR clStatusCred='BT' THEN 
		LET g_CodRef ='16';
	ELIF clStatusCred='E1' OR clStatusCred='E2' OR clStatusCred='E3' THEN
		LET g_CodRef ='958';
	END IF;

	IF pTransacc = "9888" THEN
		IF clStatusCred = 'E1' THEN
			LET g_CodRef = '57';
		ELIF clStatusCred = 'E2' THEN
			LET g_CodRef = '61';
		ELIF clStatusCred = 'E3' THEN
			LET g_CodRef = '65';
		ELSE
			LET g_CodRef = '65';
		END IF;
	END IF;
	
	IF pTransacc = "4320" THEN
		IF clStatusCred = 'E1' THEN
			LET g_CodRef = '106';
		ELIF clStatusCred = 'E2' THEN
			LET g_CodRef = '110';
		ELIF clStatusCred = 'E3' THEN
			LET g_CodRef = '114';
		ELSE
			LET g_CodRef = '114';
		END IF;
	END IF;
	
		IF pTransacc = "4320" or pTransacc = "9888"  THEN
		    CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,'059',g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			RETURNING cCodRetAux, cMensajeRet;
		ELSE
			CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFun,g_dtFechaHoy,dPagoCapital,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
			RETURNING cCodRetAux, cMensajeRet;
		END IF;

	IF (cCodRetAux <> '000000') THEN
		LET cCodRet      = "00062";
		LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago capital anticipado";
		   ROLLBACK WORK;
			IF (wBegin = "S") THEN
			   BEGIN WORK;
			END IF;
		RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
	END IF;
END IF;
 --FMV 2-SEP-11: Se adiciona parametro de comision
IF pMonto > 0 THEN
  IF iNumPago = 1 and cind_comision = '1' THEN
	 SELECT apli_factor/100
	   INTO dTasaCom
	   FROM "informix".sd_tpcomis
		WHERE cod_comis=ctran_comision;

	-- Se realiza el calculo para identificar los montos de comision, iva de comision y el pago a capital
	  LET dPagoCom     = pMonto / (1 + g_dIvaSuc);
	  LET pMonto = pMonto - dPagoCom;

   -- Movimiento Contable pago comision
	IF clStatusCred='AA' OR clStatusCred='BA' OR clStatusCred='BT' THEN 
		LET g_CodRef ='17';
	ELIF clStatusCred='E1' OR clStatusCred='E2' OR clStatusCred='E3' THEN
		LET g_CodRef ='17';
	END IF;

	CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFun,g_dtFechaHoy,dPagoCom,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
	RETURNING cCodRetAux, cMensajeRet;

	IF (cCodRetAux <> "000000") THEN
	   LET cCodRet      = "00060";
	   LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago comision";
	   ROLLBACK WORK;
		IF (wBegin = "S") THEN
		   BEGIN WORK;
		END IF;
	   RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
	END IF;

	  LET dPagoIvaCom = pMonto;
	-- Movimiento contable pago iva de comision
	IF clStatusCred='AA' OR clStatusCred='BA' OR clStatusCred='BT' THEN 
		LET g_CodRef ='18';
	ELIF clStatusCred='E1' OR clStatusCred='E2' OR clStatusCred='E3' THEN
		LET g_CodRef ='18';
	END IF;

	CALL "informix".genmovcrd(g_cEmpresa,g_NumCredito,cNumProd,g_CodRef,g_CodFun,g_dtFechaHoy,dPagoIvaCom,g_Folio,cSucursal,cDivisa,g_TransaccSuc,iNumPago,"")
	RETURNING cCodRetAux, cMensajeRet;

	IF (cCodRetAux <> "000000") THEN
		 LET cCodRet      = "00061";
		 LET cMensajeRet  = "Ocurrio un error al registrar el movimiento contable de pago iva comision";
		   ROLLBACK WORK;
			IF (wBegin = "S") THEN
			   BEGIN WORK;
			END IF;
		RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
	END IF;
  END IF;

  LET cIndicador = "S";

END IF;

	IF (cNumProd = '6900' or cNumProd = '8900') AND pTransacc IN ("8150","8160","8654") THEN

		IF pTransacc ="8150" THEN
			LET mMontoCargo = mMonto;
		END IF;

		IF pTransacc in ("8160","8654") THEN
			LET mMontoEfec = mMonto;
		END IF;

		LET sCountExists = 0;
		SELECT count(folio) INTO sCountExists FROM "informix".sd_montopagcrd WHERE folio = g_Folio;
		IF sCountExists = 0 THEN
		--IF NOT EXISTS (select folio from "informix".sd_montopagcrd where folio = g_Folio) THEN
			INSERT INTO "informix".sd_montopagcrd (empresa,monto,mv_interes_cs,mv_iva_cs,mv_capital_cs,folio)
			VALUES (pempresa,dMontoPago,dPagoInt,dPagoIvaInt,dPagoCapital,g_Folio);
		ELSE
			--INC 25 170 Se actualiza el monto capital por la suma del total pagado por el cliente cuando se trate del pago en mesiversario
			UPDATE "informix".sd_montopagcrd SET monto = monto + dMontoPago, mv_capital_cs= mv_capital_cs + dMontoPago WHERE folio =g_Folio;
		END IF;

		/*CALL "informix".sp_actualizasaldos_cred(pempresa,g_NumCredito,cNumProd,mMontoEfec,mMontoCargo,g_Folio,pSucursal, pUsuario)
		 RETURNING cCodRetAux, cMensajeRet;

		-- DELETE FROM "informix".sd_montopagcrd WHERE folio = g_Folio;

	   IF (cCodRetAux <> "000000") THEN
		   LET cCodRet      = "00053";
		   LET cMensajeRet  = "Ocurrio un error al registrar el movimiento de Pago";
		   --ROLLBACK WORK;
			IF (wBegin = "S") THEN
			   BEGIN WORK;
			END IF;
		   RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
		END IF;*/

		--EM 24/03/2017
		SELECT num_sol_prestamo, folio_suc, num_credito
		INTO cNumCreditocrd, c_Folio_Suc, cNumCredito
		FROM "informix".sd_promocion_credito
		WHERE  empresa= pEmpresa
		and num_sol_prestamo = g_NumCredito;
		--EM 24/03/2017
		LET g_NumCredito = cNumCreditocrd;

	END IF;

  SELECT sdo_cap_insoluto
    INTO dSdoCapital
    FROM "informix".sd_maesdoscrd
   WHERE empresa=g_cEmpresa
     AND num_credito=g_NumCredito;

     IF dSdoCapital IS NULL THEN
     	LET dSdoCapital =0;
     END IF;
	 
	SELECT sdo_retenido
		INTO vretenido
	FROM "informix".sd_maesdoscrd 
	WHERE empresa=g_cEmpresa 
		AND num_credito=g_NumCredito;
	 
   IF dSdoCapital <= 0 AND vretenido = 0 THEN
			UPDATE "informix".sd_amortiza_creditocrd
			   SET capital_status = "5",
				   capital_status_ant = "3",
				   capital_pagado = capital_debe,
				   capital_fecha_pago = g_dtFechaHoy -- FMV 29oct13: En pago anticipado se actualiza fecha de pago
			 WHERE empresa = g_cEmpresa
			   AND num_credito = g_NumCredito
			   AND capital_status = "3";

			UPDATE "informix".sd_maecredcrd
			   SET status_cred = "FF",
				   fecha_vencim = g_dtFechaHoy
			 WHERE num_credito = g_NumCredito
			   AND empresa = g_cEmpresa;

             -- PA_2023 (BAJA del programa de apoyo)
			UPDATE "informix".sd_programa_apoyo_crd
			  SET bandera = 'B', fecha_inactivacion = g_dtFechaHoy
			WHERE num_credito = g_NumCredito;


			UPDATE "informix".sd_maecredanexocrd
			   SET prox_fecha_pago=date(1)--,
				  -- fecha_vencim = g_dtFechaHoy
			 WHERE num_credito = g_NumCredito
			   AND empresa = g_cEmpresa;

		/*IF cNumProd = '6900' AND pTransacc IN("8150","8160") THEN
			--Seccion para Quitar Retenido Excedente
			SELECT monto_actual,monto_int_iva,folio_movto INTO mMonto,v_iva_cs,cfolio_mov
			FROM "informix".sd_promocion_credito
			WHERE empresa = g_cEmpresa
			 AND num_sol_prestamo = g_NumCredito;

			  UPDATE bdicred: "informix".sd_maesdos
				SET sdo_retenido = sdo_retenido - (mMonto + v_iva_cs)
			   WHERE empresa = '001'
				 AND num_credito = cNumCredito;

			  UPDATE bdicred: "informix".sd_promocion_credito
				 SET monto_actual=0,monto_int_iva = 0, status = 6
			   WHERE empresa = '001'
				 AND num_sol_prestamo = g_NumCredito;

			UPDATE bdicred: "informix".sd_maeretenido
			 SET monto = 0
			WHERE empresa = '001'
			 AND num_credito = cNumCredito
			  AND nvl(substr(referencia,1,16),'') = cfolio_mov
			  AND nvl(substr(referencia,18,3),'')= 'RET'
			  AND estatus = 'R';

			UPDATE bdicred: "informix".sd_maeretenido
			  SET monto = 0
			WHERE empresa = '001'
			  AND num_credito = cNumCredito
			  AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
			  AND nvl(substr(referencia,18,3),'')= 'PAG'
			  AND estatus = 'R';
		END IF;*/
   END IF;

IF cIndicador = "S" THEN
  UPDATE "informix".sd_maecredanexocrd
	 SET fecha_ult_pago  = g_dtFechaHoy
   WHERE num_credito     = g_NumCredito
	 AND empresa         = g_cEmpresa;
END IF;

EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(g_cEmpresa,g_NumCredito)
		 INTO cCodRetAux,cMensajeRet,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinAct,dtDateAux,
			  iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
			  dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
			  dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotalAct,dIntDevengado,dIvaIntDevengado,
			  dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
			  cCharAux,cCharAux,iIntAux,cCharAux;

IF cCodRetAux <> "000000" THEN
	  LET cCodRet      = "00042";
	  LET cMensajeRet  = "Ocurrio un error al obtener el adeudo actual del cliente";
		   ROLLBACK WORK;
			IF (wBegin = "S") THEN
			   BEGIN WORK;
			END IF;
	  RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");
END IF;

 IF dtFechaProxPago > DATE(1) THEN
	 LET cFechaLimite = DAY(dtFechaProxPago) || ' de ' || DECODE(MONTH(dtFechaProxPago),"1","ene","2","feb","3","mar"
																						,"4","abr" ,"5","may","6","jun"
																						,"7","jul","8","ago","9","sep"
																						,"10","oct","11","nov","12","dic")
											  || ' de ' || YEAR(dtFechaProxPago);
 ELSE
	 LET cFechaLimite = ' ';
 END IF;

 IF g_dtFechaHoy = dtFechaProxPago THEN
	LET cFechaLimite = ' ';
 END IF;

 IF cCodRet = "000"  THEN
	LET cCodRet     = "00000";
	LET cMensajeRet = "Se ejecuto el pago anticipado correctamente";
 END IF;
 
 	COMMIT WORK;
	--Se agrega validacion tipo se monto y flg despues de reducir sdo_capital para calcular el nuevo monto_cuota
	IF(pTipoReduce == 2 AND pFlgReduccion == 1) THEN
		-- LABR PLAZO REMANENTE DEL CREDITO	
		FOREACH EXECUTE PROCEDURE bdicred: "informix".sp_obtiene_tabla_amortizacion_web(pEmpresa,pNumCredito,pSucursal, 0) 
			INTO pCodigo, pPeriodo, pFechaCouta, pSaldoInicial, pMensualidad, 
				 pIntereses, pIvaInteres, pCapital, pSaldoFinal, pDiasPeriodo, pFechaAper,
				 pNumMesesPago,pMontoContratado,pMontoTotalaPagar,pTasaAnualFija,pTotLiq,pAhorro 
				 
				END FOREACH;
				
		 /*AGREGAR EL SP sp_reduce_pagoanticipado */ 
		 IF pPeriodo > 0 THEN
			 EXECUTE PROCEDURE "informix".sp_reduce_pagoanticipado
			 (pEmpresa, pNumCredito, pTipoReduce, pFolio,pPeriodo) INTO iCodRetornoPagAnt,imsgPagAnt;
		END IF;
	END IF;
	
	IF (wBegin = "S") THEN
		BEGIN WORK;
	END IF;
	

 RETURN cCodRet,cMensajeRet,NVL(dSdoAnt,0),NVL(dPagoCom,0),NVL(dPagoIvaCom,0),NVL(dIntMora,0),NVL(dIvaIntMora,0),NVL(dIntVdo,0),NVL(dIvaIntVdo,0),NVL(dPagoInt,0),NVL(dPagoIvaInt,0),NVL(dPagoCapital,0),NVL(dMontoPago,0),NVL(g_Cuenta,""),NVL(dSdoAdeudTotalAct,0), NVL(dPagoMinAct,0),NVL(cFechaLimite,"");

END PROCEDURE
DOCUMENT
'Descripcion : Se modifica para agregar max( a.fecha_cuota ) al filtro de consulta de la ttabla consulta sd_amortiza_creditocrd ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 09/03/2017',
'BD          : bdicred',
'-------------------------------------------------------------------------',
'Modifico: 95992243 - Trinidad Hernadez',
'Folio: 188',
'Modificacion: Se quitan movimientos a la sd_movdia',
'BD: bdicred',
'Fecha: 25/04/2017',
'=======================================================',
'AUTOR: 98640909 - LUIS ALBERTO BELTRAN RODRIGUEZ',
'Descripcion:  REDUCE MONTO DE PAGO O PLAZO EN LINEAS DE CREDITOS NO REVOLVENTES',
'Fecha: 2024/01/09',
'Version: 20240109.1242';

CREATE PROCEDURE "informix".sp_actpromo_x_msi(pFechaCort DATE)
--EXECUTE PROCEDURE "informix".sp_actpromo_x_msi(MDY('03','20','2023'));
RETURNING CHAR(5) AS CodigoRetorno;

	---DECLARACIONES
    DEFINE iSqlErr					INTEGER;
    DEFINE iIsamErr					INTEGER;
    DEFINE cErrorInfo				VARCHAR(80);
    DEFINE cCodRet					CHAR(5);
	DEFINE vNumCred					CHAR(20);
	DEFINE vFolioMov				CHAR(16);
	DEFINE vNumCte					CHAR(20);
	DEFINE vNumTarjeta				CHAR(20);
	DEFINE vNumMsi					CHAR(20);
	DEFINE vFechaCompra				DATE;
	DEFINE vDetCompra				VARCHAR(40);
	DEFINE vComercio				CHAR(19);
	DEFINE vMtoCompra				DECIMAL(19,2);
	DEFINE contador_commit			INTEGER;
	DEFINE val_trans_Commit			INTEGER;
	DEFINE vBanderaMsi				CHAR(1);
		
	---INICIALIZACIONES
	LET iSqlErr						= 0;
	LET iIsamErr					= 0;
	LET cErrorInfo					= '';
	LET cCodRet						= '00000';
	LET vNumCred					= '';
	LET vFolioMov					= '';
	LET vNumCte 					= '';
	LET vNumTarjeta					= '';
	LET vNumMsi						= '';
	LET vFechaCompra				= DATE(1);
	LET vDetCompra					= '';
	LET vComercio					= '';
	LET vMtoCompra					= 0.0;
	LET contador_commit 			= 0;	
	LET val_trans_Commit 			= 0;
	LET vBanderaMsi					= '';
	
	
-- Autor: David Ulises Cuenca Montesinos
-- Modificacion: Store Procedure para actualizar informacion de compras a meses sin intereses


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			IF (contador_commit <> 0) THEN
				rollback work;
			END IF;  
			RETURN TRIM(cCodRet);			
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/informix/ulises/ModifProcMsiEdc/sps/sp_actpromo_x_msi.out";
	--TRACE ON;

	--LET pFechaCort = MDY('03','20','2023'); -- PRUEBAS
	
	-- Obtiene creditos activos de meses sin intereses
	SELECT folio_movto, num_credito, num_cte, num_tarjeta, num_sol_prestamo, num_pro_prestamo, status, banderact_msi
	FROM bdicred:sd_promocion_credito WHERE num_pro_prestamo = '8900' AND status = 2
	AND fecha <= pFechaCort
	INTO TEMP creds_msi WITH NO LOG;
	
	FOREACH WITH HOLD
	
		SELECT 	pc.num_credito, pc.folio_movto,	pc.num_cte,	pc.num_tarjeta,	pc.num_sol_prestamo,	imov.fechahorainauth,	imov.infreceptor,	imov.idretailer,	imov.monto,	pc.banderact_msi
		  INTO 	vNumCred, 		vFolioMov, 		vNumCte, 	vNumTarjeta, 	vNumMsi, 				vFechaCompra, 			vDetCompra, 		vComercio, 			vMtoCompra,	vBanderaMsi
		FROM intercard:movimiento imov
		INNER JOIN creds_msi pc ON imov.numtarjeta = pc.num_tarjeta
		WHERE imov.secuenciaextendida = SUBSTR(pc.folio_movto,2,15)
			UNION ALL
		SELECT pc.num_credito, pc.folio_movto,	pc.num_cte,	pc.num_tarjeta,	pc.num_sol_prestamo,	imov.fechahorainauth,	imov.infreceptor,	imov.idretailer,	imov.monto,	pc.banderact_msi
		FROM intercard:movimientohistorico imov
		INNER JOIN creds_msi pc ON imov.numtarjeta = pc.num_tarjeta
		WHERE imov.secuenciaextendida = SUBSTR(pc.folio_movto,2,15)
		
		--Valida si el credito ya se actualizo con datos de la compra.
		IF NVL(vBanderaMsi,'') = '1' THEN
			CONTINUE FOREACH;
		ELSE 
			UPDATE "informix".sd_promocion_credito 
				SET fecha_compra_msi = NVL(vFechaCompra,DATE(1)), detalle_compra_msi = NVL(vDetCompra,''), comercio_msi = NVL(vComercio,''), mto_compra_msi = NVL(vMtoCompra,''), banderact_msi = '1'
				WHERE num_sol_prestamo = vNumMsi AND num_pro_prestamo = '8900' AND status = 2;
			
			LET contador_commit = contador_commit + 1;
		END IF;
		
		-- Realiza COMMIT por cada mil registros
		IF contador_commit >= 1000 THEN
			BEGIN WORK;
			LET contador_commit = 0; 
			COMMIT WORK;
		END IF;
		
		LET vBanderaMsi = '';
	
	END FOREACH;
	
	BEGIN; UPDATE STATISTICS MEDIUM FOR TABLE sd_promocion_credito; COMMIT;
   
	RETURN cCodRet;
		
	END;
END PROCEDURE;