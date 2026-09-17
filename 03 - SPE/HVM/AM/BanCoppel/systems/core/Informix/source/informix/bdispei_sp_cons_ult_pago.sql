CREATE procedure "informix".sp_cons_ult_pago(p_cta_ord      char(20),
                                         p_fecha        date,
                                         p_cta_receptor char(20),
                                         p_bco_receptor char(6))
RETURNING  char(5),char(16),char(40),char(210),char(1),decimal(19,2);

-- procedimiento para spei
-- VARIABLES PARA ERRORES
DEFINE sqlErr	INTEGER;
DEFINE isamErr  INTEGER;
DEFINE text     varchar(255);

DEFINE Cod_Retorno char(5);
DEFINE vc_CuentaOrdenante   CHAR(18); 

--VARIABLES PARA EL QUERY
DEFINE vc_chrfolioprom      CHAR(16); 
DEFINE vc_vchrnombrebenef   CHAR(40);
DEFINE vc_vchrconceppago    CHAR(210);
DEFINE vc_chrestatusenvio   CHAR(1);
DEFINE dc_mnyimporte        DECIMAL(19,2);

DEFINE tmp_NumError         INTEGER;
DEFINE tmp_FuenteError      CHAR(7);

--  SET DEBUG FILE TO "/home/ixdesa/gaby/Promocion/sp_cons_pago_spei.out";
--  TRACE ON;

--  INICIA LA FUNCIONALIDAD
BEGIN
-- MANEJO DE ERRORES CON (ON EXCEPTION SET)
ON exception
  SET sqlErr, isamErr, text
  IF (sqlErr <> 0) THEN
      raise exception sqlErr, isamErr, text;
      LET Cod_Retorno = sqlErr;
      RETURN Cod_Retorno,null,null,null,null,null;
  END IF;
END exception;

SET lock mode to wait 30;
SET ISOLATION TO DIRTY READ;

-- INICIALIZA VARIABLE
LET Cod_Retorno = '000';
LET vc_CuentaOrdenante = NULL;
LET tmp_NumError    = NULL;
LET tmp_FuenteError = NULL;

LET vc_CuentaOrdenante  = NULL;

LET vc_chrfolioprom     = NULL;
LET vc_vchrnombrebenef  = NULL;
LET vc_vchrconceppago   = NULL;
LET vc_chrestatusenvio  = NULL;
LET dc_mnyimporte       = NULL;

-- VALIDACION QUE VERIFICA QUE TODOS LOS PARAM.DE ENTRADA SE HAYAN ENVIADO.
-- Si alguno de los parámetros no tiene valor, Cod_Retorno  = '110'
IF p_cta_ord  IS NULL OR p_fecha IS NULL OR p_cta_receptor IS NULL OR
   p_bco_receptor IS NULL THEN
    LET Cod_Retorno ='110';
    return Cod_Retorno,null,null,null,null,null;
END IF;

-- SE OBTIENE LA CUENTA ORDENANTE        
      EXECUTE PROCEDURE bditef:spobtenerccc('060','',p_cta_ord)
      INTO tmp_NumError,tmp_FuenteError, vc_CuentaOrdenante;      

-- OBTENGO LOS VALORES
	SELECT chrfolioprom, vchrnombrebenef, vchrconceptopago2,
 	      chrestatusenvio, mnyimporte
        INTO  vc_chrfolioprom, vc_vchrnombrebenef,vc_vchrconceppago,
        vc_chrestatusenvio,dc_mnyimporte   
 	FROM  bdispei:tblpago
 	WHERE vchrcuentaord   = vc_CuentaOrdenante
 	AND   dtfechavalor  = p_fecha
 	AND   vchrcuentabenef = p_cta_receptor
 	AND   cvecesifbcodest = p_bco_receptor
        AND   intpkpago   = (SELECT MAX(intpkpago)
 	                        FROM  bdispei:tblpago
 	                        WHERE vchrcuentaord   = vc_CuentaOrdenante
 	                        AND   dtfechavalor  = p_fecha
 	                        AND   vchrcuentabenef = p_cta_receptor
 	                        AND   cvecesifbcodest = p_bco_receptor);      
      
END;	      
RETURN Cod_Retorno,vc_chrfolioprom, vc_vchrnombrebenef,
        vc_vchrconceppago,vc_chrestatusenvio,dc_mnyimporte;    
END procedure;