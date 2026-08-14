CREATE PROCEDURE "informix".sp_consultabittascomi_pm(pCliente CHAR(20), pCuenta CHAR(20),pComision CHAR(4),pFechaInicial CHAR(10),pFechaFinal CHAR(10))
RETURNING 	CHAR(6)  AS cCodRet,
			CHAR(10) AS Fecha,
			CHAR(50) AS Nombre_Comision,
			CHAR(20) AS Cuenta,
			CHAR(30) AS ValorAnterior,
			CHAR(30) AS ValorFinal,
			CHAR(45) AS Nombre_usuario;
			

--DECLARACIONES DE VARIABLES Y SU TIPO DE DATO
DEFINE cCodRet  CHAR(6);
DEFINE iSqlErr  INTEGER;	
DEFINE cDescripcion CHAR(50);
DEFINE cfecha		CHAR(10);
DEFINE iSecuen		INTEGER;
DEFINE cUsu_mod		CHAR(8);
DEFINE cNombre		CHAR(45);
DEFINE dtFecha_ini	DATE;
DEFINE dtFecha_fin	DATE;	
DEFINE cCuenta		CHAR(20);
DEFINE cCod_Comi	CHAR(4);	

DEFINE dcTasa_rend       	DECIMAL(14,2);
DEFINE mSdo_prom_mm      	MONEY(14,2);
DEFINE mMon_min_aper        MONEY(14,2);
DEFINE mCom_cgo_no_smm      MONEY(14,2);
DEFINE mCom_cbo_acla_np     MONEY(14,2);
DEFINE mCom_chq_gir_cob     MONEY(14,2);
DEFINE mCom_ina_cta         MONEY(14,2);
DEFINE mServ_tran_spei      MONEY(14,2);
DEFINE mServ_tran_tef   	MONEY(14,2);
DEFINE mServ_anualidad      MONEY(14,2);
DEFINE mServ_reenv_token    MONEY(14,2);
DEFINE mServ_reep_token     MONEY(14,2);
DEFINE mDisp_cta_bcoppel    MONEY(14,2);
DEFINE mDisp_cta_otrobco    MONEY(14,2);
DEFINE mDisp_linea          MONEY(14,2);
DEFINE mValorAnterior       CHAR(30);
DEFINE mValorFinal          CHAR(30);
DEFINE cCadena		        CHAR(30);
DEFINE i                    INTEGER;
DEFINE ilongi               INTEGER;
DEFINE cPar					CHAR(4);
DEFINE cPar1				CHAR(4);
DEFINE cPar2				CHAR(4);

DEFINE cCadena1		        CHAR(30);
DEFINE i1                   INTEGER;
DEFINE ilongi1              INTEGER;
DEFINE cParc				CHAR(4);
DEFINE cPar11				CHAR(4);
DEFINE cPar21				CHAR(4);

DEFINE dcTasa_rend1       	DECIMAL(14,2);
DEFINE mSdo_prom_mm1      	MONEY(14,2);
DEFINE mMon_min_aper1       MONEY(14,2);
DEFINE mCom_cgo_no_smm1     MONEY(14,2);
DEFINE mCom_cbo_acla_np1    MONEY(14,2);
DEFINE mCom_chq_gir_cob1    MONEY(14,2);
DEFINE mCom_ina_cta1        MONEY(14,2);
DEFINE mServ_tran_spei1     MONEY(14,2);
DEFINE mServ_tran_tef1   	MONEY(14,2);
DEFINE mServ_anualidad1     MONEY(14,2);
DEFINE mServ_reenv_token1   MONEY(14,2);
DEFINE mServ_reep_token1    MONEY(14,2);
DEFINE mDisp_cta_bcoppel1   MONEY(14,2);
DEFINE mDisp_cta_otrobco1   MONEY(14,2);
DEFINE mDisp_linea1         MONEY(14,2);

--INICIALIZACIONES DEVALORES DEFAULT DE VARIABLES
LET cCodRet			= '000000';
LET iSqlErr			= 0;	
LET cDescripcion	= "";	
LET cfecha			= "";	
LET iSecuen		    = 0;
LET cUsu_mod		= "";
LET cNombre			= "";
LET dtFecha_ini    	= "";
LET dtFecha_fin    	= "";	
LET cCuenta	    	= "";	
LET cCod_Comi    	= "";		

LET dcTasa_rend       	 = NULL;
LET mSdo_prom_mm      	 = NULL;
LET mMon_min_aper        = NULL;
LET mCom_cgo_no_smm      = NULL;
LET mCom_cbo_acla_np     = NULL;
LET mCom_chq_gir_cob     = NULL;
LET mCom_ina_cta         = NULL;
LET mServ_tran_spei      = NULL;
LET mServ_tran_tef   	 = NULL;
LET mServ_anualidad      = NULL;
LET mServ_reenv_token    = NULL;
LET mServ_reep_token     = NULL;
LET mDisp_cta_bcoppel    = NULL;
LET mDisp_cta_otrobco    = NULL;
LET mDisp_linea          = NULL;
LET mValorFinal          = NULL;
LET mValorAnterior       = NULL;

LET dcTasa_rend1       	= NULL;
LET mSdo_prom_mm1      	= NULL;
LET mMon_min_aper1      = NULL;
LET mCom_cgo_no_smm1    = NULL;
LET mCom_cbo_acla_np1   = NULL;
LET mCom_chq_gir_cob1   = NULL;
LET mCom_ina_cta1       = NULL;
LET mServ_tran_spei1    = NULL;
LET mServ_tran_tef1   	= NULL;
LET mServ_anualidad1    = NULL;
LET mServ_reenv_token1  = NULL;
LET mServ_reep_token1   = NULL;
LET mDisp_cta_bcoppel1  = NULL;
LET mDisp_cta_otrobco1  = NULL;
LET mDisp_linea1        = NULL;
LET cCadena				= "";
LET i					= 0;
LET ilongi				= 0;
LET cPar				= "";
LET cParc				= "";
LET cPar2				= "";
LET cCadena1			= "";
LET i1					= 0;
LET ilongi1				= 0;
LET cPar1				= "";
LET cPar11				= "";
LET cPar21				= "";
		
	--SET DEBUG FILE TO '/respaldosbd/josue/sp_consultabittascomi_pm.out';
	--TRACE ON;				
			
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cfecha,cDescripcion,pCuenta,mValorAnterior,mValorFinal,cNombre;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	

		IF NVL(pCliente,'') = '' OR NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' THEN
			LET cCodRet = '000001'; -- 'PARAMETROS VACIOS';
		ELSE	
			LET dtFecha_ini = TO_DATE(pFechaInicial,"%Y-%m-%d");
			LET dtFecha_fin = TO_DATE(pFechaFinal,"%Y-%m-%d");

			FOREACH				
				SELECT cuenta,comision_id,secuencia,tasa_rend,sdo_prom_mm,mon_min_aper,com_cgo_no_smm,com_cbo_acla_np,com_chq_gir_cob,com_ina_cta,serv_tran_spei,
				serv_tran_tef,serv_anualidad,serv_reenv_token,serv_reep_token,disp_cta_bcoppel,disp_cta_otrobco,disp_linea,fecha_oper, usuario_mod
				INTO cCuenta,cCod_Comi,iSecuen,dcTasa_rend,mSdo_prom_mm,mMon_min_aper,mCom_cgo_no_smm,mCom_cbo_acla_np,mCom_chq_gir_cob,mCom_ina_cta,
				mServ_tran_spei,mServ_tran_tef,mServ_anualidad,mServ_reenv_token,mServ_reep_token,mDisp_cta_bcoppel,
				mDisp_cta_otrobco,mDisp_linea,cfecha,cUsu_mod
				FROM "informix".sc_bitcomtasserv_pm 
				WHERE num_cte = pCliente
				AND cuenta = DECODE(pCuenta,'',cuenta,pCuenta)
				AND comision_id = DECODE(pComision,'',comision_id,pComision)
				AND fecha_oper BETWEEN dtFecha_ini AND dtFecha_fin
				ORDER BY fecha_oper,cuenta,comision_id,secuencia
				
				IF NVL(iSecuen,0) > 1 THEN
				
					IF dcTasa_rend IS NOT NULL THEN
						LET cCadena1 = dcTasa_rend;
						LET ilongi1 = LENGTH(cCadena1);
						
						FOR i1 = 1 TO ilongi1
							LET cParc = SUBSTR(cCadena1,i1,1);
							IF cParc = "." THEN
								LET cPar11 = SUBSTR(cCadena1,i1 + 1,2);
								IF cPar11 = "00" THEN
									LET	cPar21 = SUBSTR(cCadena1,1,i1 - 1);								
									LET cCadena1 = TRIM(cpar21)||"% CETES mes anterior";
									LET mValorFinal = cCadena1;
									
								ELSE
									LET mValorFinal = dcTasa_rend||"% CETES mes anterior";
								END IF
							END IF;
						END FOR
						
					END IF;
				
					--IF dcTasa_rend       IS NOT NULL THEN  LET mValorFinal = dcTasa_rend||"% CETES mes anterior";       END IF;					
					IF mSdo_prom_mm      IS NOT NULL THEN  LET mValorFinal = mSdo_prom_mm;      END IF;					
					IF mMon_min_aper 	 IS NOT NULL THEN  LET mValorFinal = mMon_min_aper;     END IF;					
					IF mCom_cgo_no_smm   IS NOT NULL THEN  LET mValorFinal = mCom_cgo_no_smm;   END IF;		
					IF mCom_cbo_acla_np  IS NOT NULL THEN  LET mValorFinal = mCom_cbo_acla_np;  END IF;		
					IF mCom_chq_gir_cob  IS NOT NULL THEN  LET mValorFinal = mCom_chq_gir_cob;  END IF;						
					IF mCom_ina_cta 	 IS NOT NULL THEN  LET mValorFinal = mCom_ina_cta;      END IF;		
					IF mServ_tran_spei   IS NOT NULL THEN  LET mValorFinal = mServ_tran_spei;   END IF;		
					IF mServ_tran_tef    IS NOT NULL THEN  LET mValorFinal = mServ_tran_tef;    END IF;		
					IF mServ_anualidad   IS NOT NULL THEN  LET mValorFinal = mServ_anualidad;   END IF;		
					IF mServ_reenv_token IS NOT NULL THEN  LET mValorFinal = mServ_reenv_token; END IF;				
					IF mServ_reep_token  IS NOT NULL THEN  LET mValorFinal = mServ_reep_token;  END IF;		
					IF mDisp_cta_bcoppel IS NOT NULL THEN  LET mValorFinal = mDisp_cta_bcoppel; END IF;		
					IF mDisp_cta_otrobco IS NOT NULL THEN  LET mValorFinal = mDisp_cta_otrobco; END IF;		
					IF mDisp_linea       IS NOT NULL THEN  LET mValorFinal = mDisp_linea;       END IF;
					
					SELECT tasa_rend,sdo_prom_mm,mon_min_aper,com_cgo_no_smm,com_cbo_acla_np,com_chq_gir_cob,com_ina_cta,serv_tran_spei,
					serv_tran_tef,serv_anualidad,serv_reenv_token,serv_reep_token,disp_cta_bcoppel,disp_cta_otrobco,disp_linea
					INTO dcTasa_rend1,mSdo_prom_mm1,mMon_min_aper1,mCom_cgo_no_smm1,mCom_cbo_acla_np1,mCom_chq_gir_cob1,mCom_ina_cta1,
					mServ_tran_spei1,mServ_tran_tef1,mServ_anualidad1,mServ_reenv_token1,mServ_reep_token1,mDisp_cta_bcoppel1,
					mDisp_cta_otrobco1,mDisp_linea1
					FROM "informix".sc_bitcomtasserv_pm 
					WHERE num_cte = pCliente
					AND cuenta = cCuenta
					AND comision_id = cCod_Comi
					AND secuencia = iSecuen -1;
					
					IF dcTasa_rend1 IS NOT NULL THEN
						LET cCadena = dcTasa_rend1;
						LET ilongi = LENGTH(cCadena);
						
						FOR i = 1 TO ilongi
							LET cPar = SUBSTR(cCadena,i,1);
							IF cPar = "." THEN
								LET cPar1 = SUBSTR(cCadena,i + 1,2);
								IF cPar1 = "00" THEN
									LET	cPar2 = SUBSTR(cCadena, 1,i -1);								
									LET cCadena = TRIM(cPar2)||"% CETES mes anterior";
									LET mValorAnterior = cCadena;									
								ELSE
									LET mValorAnterior = dcTasa_rend1||"% CETES mes anterior";
								END IF
							END IF;
						END FOR
						
					END IF;
				
					--IF dcTasa_rend1       IS NOT NULL THEN  LET mValorAnterior = dcTasa_rend1||"% CETES mes anterior";       END IF;					
					IF mSdo_prom_mm1      IS NOT NULL THEN  LET mValorAnterior = mSdo_prom_mm1;      END IF;					
					IF mMon_min_aper1 	  IS NOT NULL THEN  LET mValorAnterior = mMon_min_aper1;     END IF;					
					IF mCom_cgo_no_smm1   IS NOT NULL THEN  LET mValorAnterior = mCom_cgo_no_smm1;   END IF;		
					IF mCom_cbo_acla_np1  IS NOT NULL THEN  LET mValorAnterior = mCom_cbo_acla_np1;  END IF;		
					IF mCom_chq_gir_cob1  IS NOT NULL THEN  LET mValorAnterior = mCom_chq_gir_cob1;  END IF;						
					IF mCom_ina_cta1 	  IS NOT NULL THEN  LET mValorAnterior = mCom_ina_cta1;      END IF;		
					IF mServ_tran_spei1   IS NOT NULL THEN  LET mValorAnterior = mServ_tran_spei1;   END IF;		
					IF mServ_tran_tef1    IS NOT NULL THEN  LET mValorAnterior = mServ_tran_tef1;    END IF;		
					IF mServ_anualidad1   IS NOT NULL THEN  LET mValorAnterior = mServ_anualidad1;   END IF;		
					IF mServ_reenv_token1 IS NOT NULL THEN  LET mValorAnterior = mServ_reenv_token1; END IF;				
					IF mServ_reep_token1  IS NOT NULL THEN  LET mValorAnterior = mServ_reep_token1;  END IF;		
					IF mDisp_cta_bcoppel1 IS NOT NULL THEN  LET mValorAnterior = mDisp_cta_bcoppel1; END IF;		
					IF mDisp_cta_otrobco1 IS NOT NULL THEN  LET mValorAnterior = mDisp_cta_otrobco1; END IF;		
					IF mDisp_linea1       IS NOT NULL THEN  LET mValorAnterior = mDisp_linea1;       END IF;
					
					IF NVL(cCod_Comi,'') <> '' THEN
						SELECT nombre INTO cDescripcion
						FROM "informix".sc_catcomtasserv_pm  
						WHERE idcomision = cCod_Comi;
					ELSE
						LET cDescripcion = '';
					END IF;				
					
					SELECT nombre INTO cNombre
					FROM bdinteg: "informix".si_ejecut WHERE ejecutivo = cUsu_mod;
					
				RETURN cCodRet,cfecha,cDescripcion,cCuenta,mValorAnterior,mValorFinal,cNombre WITH RESUME;
				END IF; 
				
				LET dcTasa_rend       	 = NULL;
				LET mSdo_prom_mm      	 = NULL;
				LET mMon_min_aper        = NULL;
				LET mCom_cgo_no_smm      = NULL;
				LET mCom_cbo_acla_np     = NULL;
				LET mCom_chq_gir_cob     = NULL;
				LET mCom_ina_cta         = NULL;
				LET mServ_tran_spei      = NULL;
				LET mServ_tran_tef   	 = NULL;
				LET mServ_anualidad      = NULL;
				LET mServ_reenv_token    = NULL;
				LET mServ_reep_token     = NULL;
				LET mDisp_cta_bcoppel    = NULL;
				LET mDisp_cta_otrobco    = NULL;
				LET mDisp_linea          = NULL;
				LET mValorFinal          = NULL;
				LET mValorAnterior       = NULL;

				LET dcTasa_rend1       	= NULL;
				LET mSdo_prom_mm1      	= NULL;
				LET mMon_min_aper1      = NULL;
				LET mCom_cgo_no_smm1    = NULL;
				LET mCom_cbo_acla_np1   = NULL;
				LET mCom_chq_gir_cob1   = NULL;
				LET mCom_ina_cta1       = NULL;
				LET mServ_tran_spei1    = NULL;
				LET mServ_tran_tef1   	= NULL;
				LET mServ_anualidad1    = NULL;
				LET mServ_reenv_token1  = NULL;
				LET mServ_reep_token1   = NULL;
				LET mDisp_cta_bcoppel1  = NULL;
				LET mDisp_cta_otrobco1  = NULL;
				LET mDisp_linea1        = NULL;				
			END FOREACH;
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '000002'; -- NO SE ENCONTRARON REGISTROS.
				RETURN cCodRet,cfecha,cDescripcion,cCuenta,mValorAnterior,mValorFinal,cNombre;
			END IF	
			
		END IF;

	END; 
END PROCEDURE
DOCUMENT
'Folio: 1409',
'Autor: 94912599',
'Fecha: 11/03/2014',
'Descripción: Se crea procedimiento para consultar la bitácora del cambio de tasas y comisiones',
'ya sea por cliente,cte y cuenta o por cte-cuenta-comision',
'Sustento: RQM10-360 Param de Comi Emp_firma_color.pdf',
'Solicita: Daniel Mayén Rivas',
'BD:BDICHEQ';

CREATE PROCEDURE "informix".sp_consultacatcomisiones_pm(pEmpresa CHAR(3),pIdComision CHAR(4))
RETURNING 	CHAR(6) AS cCodRet,
			CHAR(4) AS cComi,
			CHAR(50) AS cDescripcion;

--DECLARACIONES DE VARIABLES Y SU TIPO DE DATO
DEFINE cCodRet  CHAR(6);
DEFINE iSqlErr  INTEGER;	

DEFINE cComi        CHAR(4);
DEFINE cDescripcion CHAR(50);

--INICIALIZACIONES DEVALORES DEFAULT DE VARIABLES
LET cCodRet			= '000000';
LET iSqlErr			= 0;	
LET cComi        	= "";
LET cDescripcion	= "";		
			
	--SET DEBUG FILE TO '/respaldosbd/josue/sp_consultacatcomisiones_pm.out';
	--TRACE ON;				
			
	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cComi,cDescripcion;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;	

		IF NVL(pEmpresa,'') = '' THEN
			LET cCodRet = '000001'; -- 'PARAMETROS VACIOS';
		ELSE
			FOREACH
			  SELECT idcomision,nombre INTO cComi,cDescripcion
			  FROM "informix".sc_catcomtasserv_pm  
			  WHERE NVL(idcomision,'') = DECODE(pIdComision,'',idcomision,pIdComision)
			  
			  RETURN cCodRet,cComi,cDescripcion WITH RESUME;
			END FOREACH;
		END IF;

	END; 
END PROCEDURE
DOCUMENT
'Folio: 1409',
'Autor: 94912599 ',
'Fecha: 27/02/2014',
'Descripción: Consulta el catalogo de los diferentes tipos de comisiones que existen ',
'de la tabla sc_catcomtasserv_pm, puede ser de uno por uno mandando el numero de comision deseada',
'y o todos mandando vacia la comision',
'Sustento: RQM10-360 Param de Comi Emp_firma_color.pdf',
'Solicita: Daniel Mayén Rivas',
'BD:BDICHEQ';

CREATE PROCEDURE "informix".sp_corrigecomisiones( pEmpresa CHAR(3) )
RETURNING CHAR(5), INTEGER;
    
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iTransacc        SMALLINT;
    DEFINE iContador        INTEGER;
    DEFINE iSerialCom       INTEGER;
    DEFINE cCuenta          CHAR(20);
    DEFINE cFolioSuc        CHAR(16);
    DEFINE mMontoCom        DECIMAL(14,2);
    DEFINE cCodRetAbo       CHAR(5);
    DEFINE iExisteIva       SMALLINT;
    DEFINE iSerialIva       INTEGER;
    DEFINE mMontoIva        DECIMAL(14,2);
    DEFINE iExisComPend     SMALLINT;
    DEFINE mMontoComPend    DECIMAL(14,2);
    
    LET cCodRet       = '000';
    LET cCodRet2      = '';
    LET cCodRet3      = '';
    LET iSqlErr       = 0;
    LET iSamErr       = 0;
    LET cDesErr       = 0;
    LET iTransacc     = 0;
    LET iContador     = 0;    
    LET iSerialCom    = 0;
    LET cCuenta       = '';
    LET cFolioSuc     = '';
    LET mMontoCom     = 0.00;
    LET cCodRetAbo    = '';
    LET iExisteIva    = 0;
    LET iSerialIva    = 0;
    LET mMontoIva     = 0.00;
    LET iExisComPend  = 0;
    LET mMontoComPend = 0.00;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrigecomisiones.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet, iContador;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrigecomisiones.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
        
    FOREACH WITH HOLD
        SELECT num_serial, cuenta, folio_suc, monto_tot
          INTO iSerialCom, cCuenta, cFolioSuc, mMontoCom
          FROM sc_movdia
         WHERE transacc = '3290'
           AND cancelad <> 'S'
           AND producto IN('9900','9901','2600','2700','2800','8000')
           
        BEGIN WORK;
        LET iTransacc = 1;
        
        -- // CANCELA TRANSACCION DE COMISION
        UPDATE sc_movdia 
           SET cancelad = 'S'
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND num_serial = iSerialCom;
        
        -- // ACTUALIZA EL SALDO DE LA CUENTA
        UPDATE sc_maechq
           SET sdo_actual = sdo_actual + mMontoCom
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta;
            
        -- // VERIFICA SI COBRO IVA DE LA COMISION
        SELECT COUNT(*)
          INTO iExisteIva
          FROM sc_movdia
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND folio_suc = cFolioSuc
           AND transacc = '0260'
           AND cancelad <> 'S';
                   
        IF iExisteIva > 0 THEN
            SELECT num_serial, monto_tot
              INTO iSerialIva, mMontoIva
              FROM sc_movdia
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND folio_suc = cFolioSuc
               AND transacc = '0260'
               AND cancelad <> 'S';
               
            -- // CANCELA TRANSACCION DE IVA
            UPDATE sc_movdia 
               SET cancelad = 'S'
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND num_serial = iSerialIva;
               
            -- // ACTUALIZA EL SALDO DE LA CUENTA
            UPDATE sc_maechq
               SET sdo_actual = sdo_actual + mMontoIva
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta;
        END IF;
        
        -- // VERIFICA SI EL COBRO DE COMISION DEJO COMISION PENDIENTE
        SELECT COUNT(*), SUM(monto_com)
          INTO iExisComPend, mMontoComPend
          FROM sc_detcomis
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND folio_suc = cFolioSuc
           AND comision = '3290'
           AND fecha_alta = today
           AND estado_com = 'P';
                   
        IF iExisComPend > 0 THEN
            -- // ELIMINA RGISTROS DE COMISION PENDIENTE
            DELETE FROM sc_detcomis
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND folio_suc = cFolioSuc
               AND comision = '3290'
               AND fecha_alta = today
               AND estado_com = 'P';
               
            -- // ACTUALIZA EL SALDO DE LA CUENTA Y LA COMISION PENDIENTE
            UPDATE sc_maechq 
               SET sdo_actual = sdo_actual + mMontoComPend,
                   com_pendiente = com_pendiente - mMontoComPend
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta;
        END IF;
        
        LET iContador = iContador + 1;
        
        COMMIT WORK;
        LET iTransacc = 0;
        
        LET iSerialCom    = 0;
        LET cCuenta       = '';
        LET cFolioSuc     = '';
        LET mMontoCom     = 0.00;
        LET cCodRetAbo    = '';
        LET iExisteIva    = 0;
        LET iSerialIva    = 0;
        LET mMontoIva     = 0.00;
        LET iExisComPend  = 0;
        LET mMontoComPend = 0.00;
    END FOREACH;
    
    END;
    
    RETURN cCodRet, iContador; 
    
END PROCEDURE;