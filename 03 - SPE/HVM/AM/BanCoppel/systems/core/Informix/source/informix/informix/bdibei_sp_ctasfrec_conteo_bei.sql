CREATE PROCEDURE "informix".sp_ctasfrec_conteo_bei
(
    pNum_Cte CHAR(20),
    pAlias CHAR(20),
    pClave_banco INTEGER, 
    pOtro  CHAR(20),	--numero de cuenta
    pOtro2  CHAR(60), --nombre titular
    p_CvePago  CHAR(2), --SPEI 03 o TERCEROS 02
    pTipoBusqueda SMALLINT --Todos=1 Alias=2, Banco=3, cuenta=4 y titular=5
 
)

RETURNING CHAR(5),INTEGER;

    --****************************************************************************************************
    -- DESCRIPCION: Cuenta la cantidad de registros de cuentas frecuentes SPEI o Terceros para saber 
    --              cuantas paginas mostrar  en pantalla.
    -- AUTOR : Berenice Noriega Guevara - BanCoppel - GM3
    -- FECHA : 16-Julio-2018
    -- BD: bdibei
	-- Modificado: Se agrega consulta por nombre de titular y por cuenta.
	-- Fecha	 : 17/Junio/2019
    --****************************************************************************************************

-- Variables para manejo de excepcion/resultado
	
	
    DEFINE sql_err INTEGER;
    DEFINE cod_ret CHAR(5);
    DEFINE iTotalReg INTEGER;
	DEFINE VAlias CHAR(20);
	DEFINE VOtro CHAR(20);
	DEFINE VOtro2 CHAR(60);

	
	--Set Debug File To '/home/informix/BereniceOut/sp_ctasfrec_conteo_bei.out';
	--Trace On;
	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 2;
	
	LET cod_ret  = '00000';
    LET iTotalReg = 0;
	LET VAlias = ('%' || TRIM(pAlias) || '%');
	LET VOtro = ('%' || TRIM(pOtro) || '%');
	LET VOtro2 = ('%' || TRIM(pOtro2) || '%');

	
		
BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
          RETURN cod_ret,iTotalReg;
      END IF ;
	END EXCEPTION;
  
		--***VALIDAR DATOS DE ENTRADA************************************************
        IF NVL(pNum_Cte,'')=='' THEN
            LET cod_ret = '00002'; --Numero de cliente vacio
            RETURN cod_ret,iTotalReg;
        END IF;
        IF NVL(p_CvePago,'')=='' THEN
            LET cod_ret = '00003'; -- Clave de de pago vacio
            RETURN cod_ret,iTotalReg;
        END IF;
        IF NVL(pTipoBusqueda,'')=='' THEN
            LET cod_ret = '00004'; --Tipo de busqueda vacio
            RETURN cod_ret,iTotalReg;
        END IF;
		
		IF ((NVL(p_CvePago,'')=='02') AND ((pClave_banco<>'137') OR ( NVL(pClave_banco,'')==''))) THEN
            LET cod_ret = '00005'; --banco no valido para terceros
            RETURN cod_ret,iTotalReg;
        END IF;

		--***CONTEO DE REGISTROS******************************************************
        IF NVL(pTipoBusqueda,'')=='1'  THEN ---Todos 
				SELECT COUNT(*)
				INTO iTotalReg
				FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
				WHERE ct.num_cte = pNum_Cte 
				AND ct.cve_cuenta = cp.cve_cuenta 
				AND ct.cve_estado = '01'
				AND cp.cve_pago = p_CvePago; ---02 Tercero 03SPEI
			
        ELIF NVL(pTipoBusqueda,'')=='2' THEN ---Alias
			  IF ((pAlias IS NULL) or ( NVL(pAlias,'')=='')) THEN
				 LET cod_ret = '00006'; -- Alias vacio, necesario para busqueda por Alias
				 RETURN  cod_ret, iTotalReg;
			  ElSE
				  SELECT COUNT(*)
				  INTO iTotalReg
				  FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
				  WHERE ct.num_cte = pNum_Cte
				  AND ct.cve_cuenta = cp.cve_cuenta       
				  AND ct.cve_estado = '01'
				  AND cp.cve_pago = p_CvePago---02 Tercero 03SPEI
				  AND ct.descrip_cta like VAlias;
				  
			   END IF;

        ELIF NVL(pTipoBusqueda,'')=='3' THEN --Banco
			  IF (p_CvePago <> '03') THEN
				 LET cod_ret = '00007'; -- clave de pago no corresponde para la busqueda por banco
				 RETURN cod_ret, iTotalReg;
			  ElSE
				  SELECT COUNT(*)
				  INTO iTotalReg
				  FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
				  WHERE ct.num_cte = pNum_Cte
				  AND ct.cve_cuenta = cp.cve_cuenta
				  AND ct.cve_estado = '01'		
				  AND cp.cve_pago = p_CvePago ---03SPEI		  
				  AND ct.cve_banco = pClave_banco;
			   END IF;
		  
		 ELIF NVL(pTipoBusqueda,'')=='4' THEN ---cuenta
			  IF ((pOtro IS NULL) or ( NVL(pOtro,'')=='')) THEN
				 LET cod_ret = '00008'; -- cuenta vacio, necesario para busqueda por numero de cuenta
				 RETURN  cod_ret, iTotalReg;
			  ElSE
				  SELECT COUNT(*)
				  INTO iTotalReg
				  FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
				  WHERE ct.num_cte = pNum_Cte
				  AND ct.cve_cuenta = cp.cve_cuenta       
				  AND ct.cve_estado = '01'
				  AND cp.cve_pago = p_CvePago---02 Tercero 03SPEI
				  AND ct.cuenta like VOtro;
				  
			   END IF; 
			   
	     ELIF NVL(pTipoBusqueda,'')=='5' THEN ---titular
			  IF ((pOtro2 IS NULL) or ( NVL(pOtro2,'')=='')) THEN
				 LET cod_ret = '00009'; -- nombre titular vacio, necesario para busqueda por nombre titular
				 RETURN  cod_ret, iTotalReg;
			  ElSE
				  SELECT COUNT(*)
				  INTO iTotalReg
				  FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
				  WHERE ct.num_cte = pNum_Cte
				  AND ct.cve_cuenta = cp.cve_cuenta       
				  AND ct.cve_estado = '01'
				  AND cp.cve_pago = p_CvePago---02 Tercero 03SPEI
				  AND ct.nombre like VOtro2;
				  
			   END IF;
		  
        END IF;
		
            
	   --***SI NO SE ENCUENTRA NINGUN REGISTRO************************************************
        IF (iTotalReg=0)THEN
		    LET cod_ret = '00001'; -- No se encontraron datos
            RETURN cod_ret, iTotalReg;
        END IF;
		
    RETURN cod_ret, iTotalReg;
END
END PROCEDURE;