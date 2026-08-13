CREATE PROCEDURE "informix".sp_consultar_info_tdc_garantizada (pEmpresa CHAR(3),pNumCredito CHAR(20))
	RETURNING
	CHAR(6)  AS COD_RET, 
	CHAR(80) AS MENSAJE_RETORNO,
	CHAR(20) AS NUM_CREDITO,
	CHAR(20) AS NUM_CLIENTE,
	CHAR(107)  AS NOMBRE_CLIENTE,
	CHAR(10) AS FECHA_SOLICITUD,
	CHAR(2)  AS GARANTIZADA,
	DECIMAL(18,2) AS LINEA_CREDITO,
	CHAR(20) AS NUM_CUENTA,
	CHAR(10) AS FECHA_ALTA,
	CHAR(10) AS FECHA_BAJA,
	CHAR(11) AS MOTIVO_BAJA;
	
---DECLARACIONES
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr        	INTEGER;
DEFINE cErrorInfo      	CHAR(80);
DEFINE cCodRet         	CHAR(6);
DEFINE cMensajeRet     	CHAR(80);

DEFINE cNumcte      	CHAR(20);
DEFINE cNombreCte      	CHAR(107);
DEFINE dtFechaSol     	DATE;
DEFINE cGarantizada    	CHAR(2);
DEFINE dLineaCredito   	DECIMAL(18,2);
DEFINE cNumCta       	CHAR(20);
DEFINE dtFechaAlta     	DATE;
DEFINE dtFechaBaja    	DATE;
DEFINE cMotivoBaja     	CHAR(11);


---INICIALIZACIONES
LET iSqlErr            	= 0;
LET iIsamErr           	= 0;
LET cErrorInfo         	= "";
LET cCodRet            	= "00000";
LET cMensajeRet        	= "PROCESO EXITOSO";   


LET cNumcte      		= "";
LET cNombreCte      	= "";
LET dtFechaSol     		= DATE(1);
LET cGarantizada    	= "";
LET dLineaCredito   	= 0;
LET cNumCta       		= "";
LET dtFechaAlta     	= DATE(1);
LET dtFechaBaja    		= DATE(1);
LET cMotivoBaja     	= "";
	
BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet,cMensajeRet,"","","","","",0,"","","","";
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_consultar_info_tdc_garantizada.out";
	--TRACE ON;
	
	-- VALIDA LOS PARAMETROS DE ENTRADA
	IF NVL(pEmpresa,"") =  "" OR NVL(pNumCredito,"") = "" THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Parametros de entrada incompletos,verifique';
	ELSE
		SELECT a.numcte,TRIM(d.nombre1)||" "||TRIM(d.nombre2)||" "||TRIM(d.apell_paterno)||" "||TRIM(d.apell_materno),
		   c.fecha_insert,b.monto_otorgado,NVL(e.garantizada,"NO"), NVL(e.num_cuenta,""),NVL(e.fecha_alta,""), NVL(e.fecha_baja,""), NVL(e.motivo_baja,"")
		INTO cNumcte,cNombreCte,dtFechaSol,dLineaCredito, cGarantizada,cNumCta,dtFechaAlta,dtFechaBaja,cMotivoBaja
		FROM bdicred:"informix".sd_maecred a
		INNER JOIN bdicred:"informix".sd_maesdos b ON (a.empresa = b.empresa AND a.num_credito = b.num_credito)
		INNER JOIN bdisolic:"informix".ss_solicitudes c ON (a.empresa = c.empresa AND c.num_solicitud = a.num_credito)
		INNER JOIN bdinteg:"informix".si_cliente d ON (a.empresa = d.empresa AND a.numcte = d.numcte)	
		LEFT OUTER JOIN bdicred:"informix".sd_tarjeta_garantizada e ON (a.empresa = e.empresa  AND a.num_credito = e.num_credito) 
		WHERE a.empresa = pEmpresa
		AND a.num_credito = pNumCredito;
	
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '000002';
			LET cMensajeRet = 'No existe el número de crédito proporcionado';		
		END IF; 				
		IF cGarantizada = "S" THEN
			LET cGarantizada = "SI";
		ELIF cGarantizada = "N" THEN
			LET cGarantizada = "NO";
		END IF;
	END IF;	
	
	RETURN cCodRet,cMensajeRet,pNumCredito,cNumcte,cNombreCte,dtFechaSol,NVL(cGarantizada,"NO"), dLineaCredito, cNumCta,NVL(dtFechaAlta,""),NVL(dtFechaBaja,""),cMotivoBaja;	    
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta para obtener la información general del cliente y los saldos del credito', 
'AUTOR: Jesús Aguilar ',
'FECHA: 16 ENERO 2012',
'BD: BDICRED',
'VERSION: 20120116.1641';

CREATE PROCEDURE "informix".sp_actualizar_info_tdc_garantizada( pEmpresa CHAR(3),
																 pNumCredito CHAR(20),
																 pNumCte CHAR(20) ,
																 pGarantizada CHAR(2) ,
																 pLinCred DECIMAL(18,2),
																 pNumCta CHAR(20),
																 pFechaAlta CHAR(10),
																 pFechaBaja CHAR(10),
																 pMotivoBaja CHAR(11),
															 	 pTpMovto  CHAR(1)
															   )
RETURNING
CHAR(6)  AS COD_RET, 
CHAR(80) AS MENSAJE_RETORNO;
	
---DECLARACIONES
DEFINE iSqlErr         	INTEGER;
DEFINE iIsamErr        	INTEGER;
DEFINE cErrorInfo      	CHAR(80);
DEFINE cCodRet         	CHAR(6);
DEFINE cMensajeRet     	CHAR(80);

---INICIALIZACIONES
LET iSqlErr            	= 0;
LET iIsamErr           	= 0;
LET cErrorInfo         	= "";
LET cCodRet            	= "00000";
LET cMensajeRet        	= "PROCESO EXITOSO";   

BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet,cMensajeRet;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_actualizar_info_tdc_garantizada.out";
	--TRACE ON;
	
	-- VALIDA LOS PARAMETROS DE ENTRADA
	IF NVL(pEmpresa,"") =  "" OR NVL(pNumCredito,"") = "" OR NVL(pTpMovto,"") NOT IN ("1","2") THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'Parametros de entrada incompletos,verifique';
	ELSE --se actualiza la informacion del cliente
		IF pTpMovto = "1" THEN---alta
		
		    IF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_tarjeta_garantizada
						WHERE empresa = pEmpresa
						AND    num_credito = pNumCredito) THEN 
						
				UPDATE bdicred:"informix".sd_tarjeta_garantizada
					SET num_cliente   = pNumCte,
						garantizada	  = pGarantizada,
						linea_credito = pLinCred,
						num_cuenta	  = pNumCta,
						fecha_alta	  = pFechaAlta,
						fecha_baja    = NULL,
						motivo_baja	  = ""
				WHERE empresa = pEmpresa
				AND    num_credito = pNumCredito;
			ELSE 
				INSERT INTO bdicred:"informix".sd_tarjeta_garantizada
				(empresa ,num_credito ,num_cliente,garantizada,linea_credito ,num_cuenta ,fecha_alta ,fecha_baja ,motivo_baja )
				VALUES(pEmpresa,pNumCredito,pNumCte,pGarantizada,pLinCred,pNumCta,pFechaAlta,"","");  
			END IF;
		ELSE --baja
			UPDATE bdicred:"informix".sd_tarjeta_garantizada
			SET garantizada	  = pGarantizada,
				fecha_baja    = pFechaBaja,
				motivo_baja	  = pMotivoBaja
			WHERE empresa = pEmpresa
			AND    num_credito = pNumCredito;
		END IF;
		
	END IF;	
	
	RETURN cCodRet,cMensajeRet;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta para obtener la información general del cliente y los saldos del credito', 
'AUTOR: Jesús Aguilar ',
'FECHA: 16 ENERO 2012',
'BD: BDICRED',
'VERSION: 20120116.1641',
'DESCRIPCION: Se modifica para no borrar la información de la ultima fecha de baja de la tarjeta garantizada', 
'AUTOR: Jesús Aguilar ',
'FECHA: 16 ENERO 2012',
'BD: BDICRED',
'VERSION: 20120116.1641';

CREATE PROCEDURE "informix".cargoref_tc_ofipba(o_empresa  CHAR(3),
				 o_sucursal CHAR(4),
				 o_usuario  CHAR(8),
				 o_tarjeta  CHAR(20),
				 o_monto    DECIMAL(14,2),
				 o_folio    CHAR(16),
				 o_transuc  CHAR(4))

RETURNING CHAR(5),       -- Codigo Retorno
	  DECIMAL(14,2), -- Saldo Disponible 
          DECIMAL(14,2), -- Importe Cargado
	  DECIMAL(14,2), -- Importe Comision
          DECIMAL(14,2); -- Iva de Comisiones

-- **************************************************************************
-- *                      DEFINICION DE VARIABLES                           *
-- **************************************************************************
DEFINE cod_ret             CHAR(5);
DEFINE cod_ret2            CHAR(5);
DEFINE sql_err             SMALLINT;
DEFINE isam_err            SMALLINT;
DEFINE error_info          CHAR(40);
DEFINE Saldo               MONEY(14,2);
DEFINE SaldoCom            MONEY(14,2);
DEFINE v_monto		   MONEY(14,2);
DEFINE v_codparam	   CHAR(4);
DEFINE v_fecha             DATE;
DEFINE v_num_credito       CHAR(20);
DEFINE v_divisa		   CHAR(2);
DEFINE MtoCgo		   MONEY(14,2);
DEFINE MtoCom		   MONEY(12,2);
DEFINE v_faplica           CHAR(1);
DEFINE v_factor		   DECIMAL(9,6);
DEFINE v_rangos		   CHAR(1);
DEFINE v_rmax	           MONEY(14,2);
DEFINE vIva		   MONEY(14,2);

-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************

ON EXCEPTION SET sql_err, isam_err, error_info
   SET DEBUG FILE TO "CargoLineaCredito.err";
--   TRACE sql_err||" * "||isam_err||" * "||error_info;
   LET cod_ret = sql_err;
   LET Saldo = 0;
   RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;
END EXCEPTION;



-- **************************************************************************
-- *                      ASIGNACION DE VARIABLES                           *
-- **************************************************************************

LET cod_ret       = "000";
LET Saldo         = 0;
LET cod_ret2      = "000";
LET SaldoCom      = 0;
LET MtoCgo	  = 0;
LET MtoCom	  = 0;
LET vIva          = 0;

 SET DEBUG FILE TO "/tmp/cargofi.out";
 TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	-- **************************
	-- **************************
	SELECT a.num_credito, b.divisa
	  INTO v_num_credito, v_divisa
	  FROM sd_tarjeta a, sd_maecred b
	 WHERE a.empresa = o_empresa
	   AND a.num_tarjeta = o_tarjeta
	   AND b.empresa = a.empresa
	   AND b.num_credito = a.num_credito;

	IF v_num_credito IS NULL THEN
		LET cod_ret = "008";
	        RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;
	END IF



	-- ***********************************************
	-- Extrae Comision por disposicion en ventanilla *
	-- ***********************************************
	{SELECT valor INTO v_codparam
	  FROM sd_param
	 WHERE empresa = o_empresa
	   AND cod_param = "334";


	SELECT form_aplica, monto, apli_factor, consi_rango, monto_max
	  INTO v_faplica, v_monto, v_factor, v_rangos, v_rmax
	  FROM sd_tpcomis
	 WHERE empresa = o_empresa
	   AND cod_comis = v_codparam;

	IF v_faplica = 2 THEN
		LET v_monto = o_monto * (v_factor/100);
	END IF

	IF v_rangos = "1" THEN
		IF v_monto < v_rmax THEN
			LET v_monto = v_rmax;
		END IF
	END IF}

	EXECUTE PROCEDURE cargo_ref_cel(o_tarjeta, o_sucursal, o_usuario,
					o_transuc, o_transuc,  o_folio,
					v_num_credito, 1, o_monto, 0,
					" ", " ", v_divisa, "",  
					o_sucursal, o_usuario, "",
					"", "", v_num_credito,
					1, 0, v_divisa, " ", "2",
					"F"," ", " ", " ", 0, 0, " ", " ")
	INTO cod_ret, v_codparam, v_fecha, Saldo, MtoCgo, 
	     cod_ret2, v_codparam, v_fecha, SaldoCom, MtoCom;

	SELECT SUM(monto_com) INTO vIva 
          FROM sd_detcomi
	 WHERE num_credito = v_num_credito
           AND cod_comis IN ("6260","6261")
	   AND num_solicitud = o_folio
           AND empresa = o_empresa
	   AND num_credito=v_num_credito;

	SELECT SUM(monto_com) INTO MtoCom 
          FROM sd_detcomi
	 WHERE num_credito = v_num_credito
           AND cod_comis IN ("6902","6901")
	   AND num_solicitud = o_folio
           AND empresa = o_empresa
	   AND num_credito=v_num_credito;

       SELECT sdo_cap_insoluto + sdo_retenido    
         INTO SaldoCom                        
         FROM sd_maesdos                         
        WHERE empresa = o_empresa
          AND num_credito=v_num_credito;

	IF MtoCom IS NULL THEN
		LET MtoCom = 0;
		LET vIva   = 0;
	END IF


   RETURN cod_ret, SaldoCom, MtoCgo, MtoCom, vIva;

END PROCEDURE
				 
;