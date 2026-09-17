CREATE PROCEDURE "informix".sp_consulta_sdo_retenido_credcap (pEmpresa CHAR(3), pCuenta CHAR(20), pProducto CHAR(4), pRegistro INTEGER)
RETURNING
CHAR(6),       -- Codigo de RetoNO cCodRet
DATE,			--dFechaAlta
CHAR(16),			--FOLIO SUCURSAL
DECIMAL (18,2),
CHAR(40),		--REFERENCIA
INTEGER;		--DIAS RESTANTES

--Declaracion de  Variables
DEFINE cCodRet          CHAR (6);
DEFINE vSqlErr          SMALLINT;
DEFINE cCodRet1			CHAR(6);
DEFINE cMensajeRet		CHAR(80);
DEFINE iResultado		INTEGER;
DEFINE cNombreBanco		CHAR(40);
DEFINE cSucursal		CHAR(4);
DEFINE dFechaAlta		DATE;
DEFINE dMonto			DECIMAL(18,2);
DEFINE iNumCheq			INTEGER;
DEFINE cFolioSuc		CHAR(16);
DEFINE dFechaAlta1		DATE;
DEFINE cReferencia		CHAR(40);
DEFINE iDiasRetenido	INTEGER;
DEFINE iDiasRestantes	INTEGER;
DEFINE cFolioSuc2		CHAR(16);
DEFINE dMonto2			DECIMAL(18,2);
DEFINE iCont		INTEGER;
DEFINE iCont2		INTEGER;
DEFINE iPaginacion		INTEGER;

--Inicializo Variables
LET cCodRet           = '000000';
LET vSqlErr           = 0;
LET cCodRet1		= '';
LET cMensajeRet		= '';
LET iResultado		= 0;
LET cNombreBanco	= '' ;
LET cSucursal		= '';
LET dFechaAlta		= '';
LET dMonto			= 0;
LET iNumCheq		= 0;
LET cFolioSuc		= '';
LET dFechaAlta1	= '';
LET cReferencia		= '';
LET iDiasRetenido	= 0;
LET iDiasRestantes	= 0;
LET cFolioSuc2		= '';
LET dMonto2			= 0;
LET iCont			= 0;
LET iCont2			= 0;
LET iPaginacion		= 0;
	

	BEGIN
		--Manejo de excepciones (errores)
		ON EXCEPTION SET vSqlErr
			IF vSqlErr <> 0 THEN
				let cCodRet = vSqlErr;
				RETURN cCodRet, dFechaAlta, NVL(cFolioSuc,'') , NVL(dMonto,0), cReferencia, NVL(iDiasRestantes,0) WITH RESUME;
			END IF;
		END EXCEPTION;

		--sET DEBUG FILE TO "/tmp/sp_consulta_sdo_retenido_credcap.out";
		--TRACE ON; 
		
		IF pEmpresa = '' OR pEmpresa IS NULL OR pCuenta = ''OR pCuenta IS NULL OR pProducto = ''  OR pProducto IS NULL THEN
			LET cCodRet = '00001' ; --FALTAN PARAMETROS DE ENTRADA
			RETURN cCodRet, dFechaAlta, NVL(cFolioSuc,'') , NVL(dMonto,0), cReferencia, NVL(iDiasRestantes,0) WITH RESUME;
		END IF;
		
		--Valida el producto para determinar si mandara llamar al procedimiento de captacion o el de credito.
		IF EXISTS(SELECT 1 FROM bdicred:sd_definicion WHERE num_producto = pProducto) THEN  
			FOREACH 	
				--Llama al procedimiento para obtener los movimientos retenidos de credito
				execute procedure bdicred:sp_consulta_sbc_retenido_general(pEmpresa, pCuenta)
				into cCodRet1, cMensajeRet, iResultado, cNombreBanco, cSucursal, dFechaAlta1, dMonto, iNumCheq, cFolioSuc, dFechaAlta, cFolioSuc2, 
					 dMonto2, cReferencia, iDiasRetenido, iDiasRestantes

				IF cCodRet1 <> '000000' THEN
					LET cCodRet= '000002';
					RETURN cCodRet, dFechaAlta, NVL(cFolioSuc,'') , NVL(dMonto,0), cReferencia, NVL(iDiasRestantes,0);
				END IF

				IF iResultado <> 2 THEN  --Valida que los resultados sean saldo retenido y no salvo buen cobro
					CONTINUE FOREACH;
				END IF;

				IF cSucursal <> '' OR cSucursal IS NOT NULL THEN  --Valida que hay informacion
					LET iPaginacion = iPaginacion +1;		

					IF iPaginacion <= pRegistro THEN
						CONTINUE FOREACH;
					END IF;				

					LET iCont = 1 ;
					RETURN cCodRet, dFechaAlta, NVL(cFolioSuc,'') , NVL(dMonto,0), cReferencia, NVL(iDiasRestantes,0) WITH RESUME;
				END IF
			END FOREACH;
			
		ELSE 
		
			FOREACH

				--Llama al procedimiento para obtener los movimientos retenidos de captacion
				execute procedure bdicheq:sp_consulta_sdo_retenido_captacion(pEmpresa, pCuenta)
				into cCodRet1, cSucursal, dFechaAlta, dMonto, iNumCheq, cFolioSuc, cReferencia, iDiasRetenido, iDiasRestantes

				IF cCodRet1 <> '000000' THEN
					LET cCodRet= '000002';
					RETURN cCodRet, dFechaAlta, NVL(cFolioSuc,'') , NVL(dMonto,0), cReferencia, NVL(iDiasRestantes,0);
				END IF		

				IF cSucursal <> '' OR cSucursal IS NOT NULL THEN 
					LET iPaginacion = iPaginacion +1;		

					IF iPaginacion <= pRegistro THEN
						CONTINUE FOREACH;
					END IF;				

					LET iCont2 = 1 ;

					RETURN cCodRet, dFechaAlta, NVL(cFolioSuc,'') , NVL(dMonto,0), cReferencia, NVL(iDiasRestantes,0) WITH RESUME;
				END IF			 

			END FOREACH;
		END IF;
		
		IF iCont = 0 AND iCont2 = 0 THEN
			LET cCodRet = '000001';
	       RETURN cCodRet, dFechaAlta, NVL(cFolioSuc,'') , NVL(dMonto,0), cReferencia, NVL(iDiasRestantes,0) WITH RESUME;	
	    END IF

END;
END PROCEDURE
DOCUMENT
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION: SE MANDA LLAMAR A LOS PROCEDIMIENTOS QUE OBTIENEN SALDO RETENIDO Y MOVTOS, VALIDANDO SI SE EJECUTA PARA CTA DE CREDITO O CAPTACION',
'FECHA: MARZO 2011',
'VERSION: 20110415.1200';

CREATE PROCEDURE "informix".sp_consulta_ctas_cap_activas_pba(pEmpresa CHAR(3), pNumCte CHAR(20), pNumTarj CHAR(20), pNumCta CHAR(20))

RETURNING 
CHAR(5)  AS Retorno,
CHAR(20) AS NumeroCliente,
CHAR(20) AS Cuenta,
CHAR(20) AS NumTarjeta,
CHAR(4)  AS ProductoTarj;


DEFINE cCodRet        CHAR(5);
DEFINE sql_err        INTEGER;
DEFINE cMensaje       CHAR(60);  

DEFINE cNumCte        CHAR(20);
DEFINE cCuenta        CHAR(20);
DEFINE cNumTarjeta    CHAR(20);
DEFINE cProducto  CHAR(4);
DEFINE iBand		  INTEGER;


LET cCodRet       = '00000';
LET sql_err       = 0;
LET cMensaje      = '';

LET cNumCte       = '';
LET cCuenta       = '';
LET cNumTarjeta   = '';
LET cProducto = '';

LET iBand         = 0;

  --  SET DEBUG FILE TO "/tmp/sp_consulta_ctas_cap_activas.out";
   -- TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err --, isam_err, error_info
        LET cCodRet = sql_err;
      --LET cMensaje = error_info;
       RETURN cCodRet, TRIM(cNumCte), TRIM(cCuenta), TRIM(cNumTarjeta), TRIM(cProducto);
    END EXCEPTION;    
    
    IF NVL(pEmpresa,'') = '' THEN
        LET pEmpresa = NULL;
    END IF;
    
    IF NVL(pNumCte,'') = '' THEN
        LET pNumCte = NULL;
    END IF;
    
    IF NVL(pNumTarj,'') = '' THEN
        LET pNumTarj = NULL;
    END IF;
    
    IF NVL(pNumCta,'') = '' THEN
        LET pNumCta = NULL;
    END IF;
     
    
    IF (pEmpresa IS NULL) OR (pNumCte IS NULL) AND (pNumTarj IS NULL) AND  (pNumCta IS NULL) THEN
        LET cCodRet = '00002'; --"Faltan parametros para su ejecucion"
        LET cNumCte = 'Faltan parametros';
        RETURN cCodRet, TRIM(cNumCte), TRIM(cCuenta), TRIM(cNumTarjeta), TRIM(cProducto);
    END IF	
	
    LET iBand = '0';
	-- Valida el tipo de busqueda: Cte, Cta o Tarjeta
	IF pNumCte IS NOT NULL  THEN
	
		--Selecciono la o las cuenats del cliente k tengan almenos una tarjeta y el producto sea valido
		Foreach								
									
			SELECT mae.num_cte, mae.cuenta, Mae.producto
			INTO cNumCte, cCuenta, cProducto
			FROM bdicheq:sc_maechq Mae
			INNER JOIN bdicheq:sc_tarjeta Tarj ON (Mae.empresa = Tarj.empresa and Mae.cuenta = Tarj.cuenta)
			INNER JOIN bdicred:sd_productos_sdoret prod on (Mae.empresa = prod.empresa and mae.producto = prod.num_producto)
			WHERE  Mae.status_cta    = '1'
			AND Mae.empresa = pEmpresa	--Revisar indice	 			
			AND Mae.num_cte = pNumCte 
			And Tarj.empresa = pEmpresa
			And Tarj.cuenta = mae.cuenta
			AND Tarj.secuencia = (SELECT  MAX(secuencia) FROM bdicheq:sc_tarjeta 
										WHERE empresa = pEmpresa
										AND cuenta = mae.cuenta)				
		   			   
			--Busco la tarjeta del cliente titular
			SELECT  Tarj.num_tarjeta
			INTO cNumTarjeta
			FROM bdicheq:sc_tarjeta Tarj
			WHERE empresa= pEmpresa
			AND cuenta= cCuenta			
			AND Tarj.secuencia = (SELECT  MAX(secuencia) FROM bdicheq:sc_tarjeta 
									WHERE cuenta = cCuenta
									AND  empresa = pEmpresa 
									AND tipo_tarjeta = 'T')	
			AND Tarj.tipo_tarjeta = 'T' ;
			
			
			--Si no hay tarjeta Cliente Titular, Selecciona la adicional
			if cNumTarjeta is null then
				SELECT  Tarj.num_tarjeta
				INTO cNumTarjeta
				FROM bdicheq:sc_tarjeta Tarj
				WHERE empresa= pEmpresa
				AND cuenta= cCuenta			
				AND Tarj.secuencia = (SELECT  MAX(secuencia) FROM bdicheq:sc_tarjeta 
										WHERE cuenta = cCuenta
										AND  empresa = pEmpresa 
										AND tipo_tarjeta = 'A')	
				AND Tarj.tipo_tarjeta = 'A' ;
			END IF	
		   
		   RETURN cCodRet, TRIM(cNumCte), TRIM(cCuenta), TRIM(cNumTarjeta), TRIM(cProducto) WITH RESUME;	
		END foreach;
		
	ELIF pNumCta IS NOT NULL THEN
	
		FOREACH 
			SELECT mae.num_cte, mae.cuenta, Mae.producto
			INTO cNumCte, cCuenta, cProducto
			FROM bdicheq:sc_maechq Mae
			INNER JOIN bdicheq:sc_tarjeta Tarj ON (Mae.empresa = Tarj.empresa and Mae.cuenta = Tarj.cuenta)
			INNER JOIN bdicred:sd_productos_sdoret prod on (Mae.empresa = prod.empresa and mae.producto = prod.num_producto)
			WHERE  Mae.status_cta = '1'
			AND Mae.empresa = pEmpresa	
			AND Mae.cuenta =pNumCta 
			And Tarj.empresa = pEmpresa
			And Tarj.cuenta = mae.cuenta
			AND Tarj.secuencia = (SELECT  MAX(secuencia) FROM bdicheq:sc_tarjeta 
										WHERE empresa = pEmpresa
										AND cuenta = mae.cuenta)		
										
			--Busco la tarjeta del cliente titular
			SELECT  Tarj.num_tarjeta
			INTO cNumTarjeta
			FROM bdicheq:sc_tarjeta Tarj
			WHERE empresa= pEmpresa
			AND cuenta= cCuenta			
			AND Tarj.secuencia = (SELECT  MAX(secuencia) FROM bdicheq:sc_tarjeta 
									WHERE cuenta = cCuenta
									AND  empresa = pEmpresa 
									AND tipo_tarjeta = 'T')	
			AND Tarj.tipo_tarjeta = 'T' ;
			
			
			--Si no hay tarjeta Cliente Titular, Selecciona la adicional
			if cNumTarjeta is null then
				SELECT  Tarj.num_tarjeta
				INTO cNumTarjeta
				FROM bdicheq:sc_tarjeta Tarj
				WHERE empresa= pEmpresa
				AND cuenta= cCuenta			
				AND Tarj.secuencia = (SELECT  MAX(secuencia) FROM bdicheq:sc_tarjeta 
										WHERE cuenta = cCuenta
										AND  empresa = pEmpresa 
										AND tipo_tarjeta = 'A')	
				AND Tarj.tipo_tarjeta = 'A' ;
			END IF	
			
			RETURN cCodRet, TRIM(cNumCte), TRIM(cCuenta), TRIM(cNumTarjeta), TRIM(cProducto) WITH RESUME;	
		END foreach;

    ELIF pNumTarj IS NOT NULL AND iBand = '0' THEN
	
		SELECT a.numcte, a.cuenta, a.prodtarjeta
		INTO cNumCte, cCuenta, cProducto
		FROM bdicheq:sc_tarjeta a
		INNER JOIN bdicheq:sc_maechq b ON (a.empresa = b.empresa and a.cuenta = b.cuenta)
		INNER JOIN bdicred:sd_productos_sdoret prod on (a.empresa = prod.empresa and  b.producto = prod.num_producto)
		WHERE a.num_tarjeta  = pNumTarj
		AND b.empresa = pEmpresa
		AND b.status_cta = '1';

		RETURN cCodRet, TRIM(cNumCte), TRIM(cCuenta), TRIM(pNumTarj), TRIM(cProducto);

	END IF
	
	IF cNumCte IS NULL OR cNumCte = '' THEN
        LET cCodRet = '00001';  --El cliente no presenta tarjetas activas relacionadas
        LET cNumCte = 'No se Encuentra';
        
       RETURN cCodRet, TRIM(cNumCte), TRIM(cCuenta), TRIM(cNumTarjeta), TRIM(cProducto);
    END IF;
	
END
END PROCEDURE




DOCUMENT
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION: OBTIENE LAS CUENTAS ACTIVAS DE CAPTACION DE UN CLIENTE',
'FECHA : MARZO DE 2011',
'VERSION: 20110418.1113';

CREATE PROCEDURE "informix".sp_consulta_ctas_cap_activas(pEmpresa CHAR(3), pNumCte CHAR(20), pNumTarj CHAR(20), pNumCta CHAR(20))

RETURNING 
CHAR(5)  AS Retorno,
CHAR(20) AS NumeroCliente,
CHAR(20) AS Cuenta,
CHAR(20) AS NumTarjeta,
CHAR(4)  AS ProductoTarj;


DEFINE cCodRet        CHAR(5);
DEFINE sql_err        INTEGER;
DEFINE cMensaje       CHAR(60);  

DEFINE cNumCte        CHAR(20);
DEFINE cCuenta        CHAR(20);
DEFINE cNumTarjeta    CHAR(20);
DEFINE cProducto  CHAR(4);
DEFINE iBand		  INTEGER;


LET cCodRet       = '00000';
LET sql_err       = 0;
LET cMensaje      = '';

LET cNumCte       = '';
LET cCuenta       = '';
LET cNumTarjeta   = '';
LET cProducto = '';

LET iBand         = 0;

  --  SET DEBUG FILE TO "/tmp/sp_consulta_ctas_cap_activas.out";
   -- TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err --, isam_err, error_info
        LET cCodRet = sql_err;
      --LET cMensaje = error_info;
       RETURN cCodRet, TRIM(cNumCte), TRIM(cCuenta), TRIM(cNumTarjeta), TRIM(cProducto);
    END EXCEPTION;    
    
    IF NVL(pEmpresa,'') = '' THEN
        LET pEmpresa = NULL;
    END IF;
    
    IF NVL(pNumCte,'') = '' THEN
        LET pNumCte = NULL;
    END IF;
    
    IF NVL(pNumTarj,'') = '' THEN
        LET pNumTarj = NULL;
    END IF;
    
    IF NVL(pNumCta,'') = '' THEN
        LET pNumCta = NULL;
    END IF;
     
    
    IF (pEmpresa IS NULL) OR (pNumCte IS NULL) AND (pNumTarj IS NULL) AND  (pNumCta IS NULL) THEN
        LET cCodRet = '00002'; --"Faltan parametros para su ejecucion"
        LET cNumCte = 'Faltan parametros';
        RETURN cCodRet, TRIM(cNumCte), TRIM(cCuenta), TRIM(cNumTarjeta), TRIM(cProducto);
    END IF	
	
    LET iBand = '0';
	-- Valida el tipo de busqueda: Cte, Cta o Tarjeta
	IF pNumCte IS NOT NULL  THEN
	
		--Selecciono la o las cuenats del cliente k tengan almenos una tarjeta y el producto sea valido
		Foreach								
									
			SELECT mae.num_cte, mae.cuenta, Mae.producto
			INTO cNumCte, cCuenta, cProducto
			FROM bdicheq:sc_maechq Mae
			INNER JOIN bdicheq:sc_tarjeta Tarj ON (Mae.empresa = Tarj.empresa and Mae.cuenta = Tarj.cuenta)
			INNER JOIN bdicred:sd_productos_sdoret prod on (Mae.empresa = prod.empresa and mae.producto = prod.num_producto)
			WHERE  Mae.status_cta    = '1'
			AND Mae.empresa = pEmpresa	--Revisar indice	 			
			AND Mae.num_cte = pNumCte 
			And Tarj.empresa = pEmpresa
			And Tarj.cuenta = mae.cuenta
			AND Tarj.secuencia = (SELECT  MAX(secuencia) FROM bdicheq:sc_tarjeta 
										WHERE empresa = pEmpresa
										AND cuenta = mae.cuenta)				
		   			   
			--Busco la tarjeta del cliente titular
			SELECT  Tarj.num_tarjeta
			INTO cNumTarjeta
			FROM bdicheq:sc_tarjeta Tarj
			WHERE empresa= pEmpresa
			AND cuenta= cCuenta			
			AND Tarj.secuencia = (SELECT  MAX(secuencia) FROM bdicheq:sc_tarjeta 
									WHERE cuenta = cCuenta
									AND  empresa = pEmpresa 
									AND tipo_tarjeta = 'T')	
			AND Tarj.tipo_tarjeta = 'T' ;
			
			
			--Si no hay tarjeta Cliente Titular, Selecciona la adicional
			if cNumTarjeta is null then
				SELECT  Tarj.num_tarjeta
				INTO cNumTarjeta
				FROM bdicheq:sc_tarjeta Tarj
				WHERE empresa= pEmpresa
				AND cuenta= cCuenta			
				AND Tarj.secuencia = (SELECT  MAX(secuencia) FROM bdicheq:sc_tarjeta 
										WHERE cuenta = cCuenta
										AND  empresa = pEmpresa 
										AND tipo_tarjeta = 'A')	
				AND Tarj.tipo_tarjeta = 'A' ;
			END IF	
		   
		   RETURN cCodRet, TRIM(cNumCte), TRIM(cCuenta), TRIM(cNumTarjeta), TRIM(cProducto) WITH RESUME;	
		END foreach;
		
	ELIF pNumCta IS NOT NULL THEN
	
		FOREACH 
			SELECT mae.num_cte, mae.cuenta, Mae.producto
			INTO cNumCte, cCuenta, cProducto
			FROM bdicheq:sc_maechq Mae
			INNER JOIN bdicheq:sc_tarjeta Tarj ON (Mae.empresa = Tarj.empresa and Mae.cuenta = Tarj.cuenta)
			INNER JOIN bdicred:sd_productos_sdoret prod on (Mae.empresa = prod.empresa and mae.producto = prod.num_producto)
			WHERE  Mae.status_cta = '1'
			AND Mae.empresa = pEmpresa	
			AND Mae.cuenta =pNumCta 
			And Tarj.empresa = pEmpresa
			And Tarj.cuenta = mae.cuenta
			AND Tarj.secuencia = (SELECT  MAX(secuencia) FROM bdicheq:sc_tarjeta 
										WHERE empresa = pEmpresa
										AND cuenta = mae.cuenta)		
										
			--Busco la tarjeta del cliente titular
			SELECT  Tarj.num_tarjeta
			INTO cNumTarjeta
			FROM bdicheq:sc_tarjeta Tarj
			WHERE empresa= pEmpresa
			AND cuenta= cCuenta			
			AND Tarj.secuencia = (SELECT  MAX(secuencia) FROM bdicheq:sc_tarjeta 
									WHERE cuenta = cCuenta
									AND  empresa = pEmpresa 
									AND tipo_tarjeta = 'T')	
			AND Tarj.tipo_tarjeta = 'T' ;
			
			
			--Si no hay tarjeta Cliente Titular, Selecciona la adicional
			if cNumTarjeta is null then
				SELECT  Tarj.num_tarjeta
				INTO cNumTarjeta
				FROM bdicheq:sc_tarjeta Tarj
				WHERE empresa= pEmpresa
				AND cuenta= cCuenta			
				AND Tarj.secuencia = (SELECT  MAX(secuencia) FROM bdicheq:sc_tarjeta 
										WHERE cuenta = cCuenta
										AND  empresa = pEmpresa 
										AND tipo_tarjeta = 'A')	
				AND Tarj.tipo_tarjeta = 'A' ;
			END IF	
			
			RETURN cCodRet, TRIM(cNumCte), TRIM(cCuenta), TRIM(cNumTarjeta), TRIM(cProducto) WITH RESUME;	
		END foreach;

    ELIF pNumTarj IS NOT NULL AND iBand = '0' THEN
	
		SELECT a.numcte, a.cuenta, a.prodtarjeta
		INTO cNumCte, cCuenta, cProducto
		FROM bdicheq:sc_tarjeta a
		INNER JOIN bdicheq:sc_maechq b ON (a.empresa = b.empresa and a.cuenta = b.cuenta)
		INNER JOIN bdicred:sd_productos_sdoret prod on (a.empresa = prod.empresa and  b.producto = prod.num_producto)
		WHERE a.num_tarjeta  = pNumTarj
		AND b.empresa = pEmpresa
		AND b.status_cta = '1';

		RETURN cCodRet, TRIM(cNumCte), TRIM(cCuenta), TRIM(pNumTarj), TRIM(cProducto);

	END IF
	
	IF cNumCte IS NULL OR cNumCte = '' THEN
        LET cCodRet = '00001';  --El cliente no presenta tarjetas activas relacionadas
        LET cNumCte = 'No se Encuentra';
        
       RETURN cCodRet, TRIM(cNumCte), TRIM(cCuenta), TRIM(cNumTarjeta), TRIM(cProducto);
    END IF;
	
END
END PROCEDURE




DOCUMENT
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION: OBTIENE LAS CUENTAS ACTIVAS DE CAPTACION DE UN CLIENTE',
'FECHA : MARZO DE 2011',
'VERSION: 20110418.1113';

CREATE PROCEDURE "informix".pasechq_globalvar(pempresa char(3))
    returning char(5);

    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';
	DEFINE GLOBAL vfecha_hoy            DATE        DEFAULT TODAY;
	
	DEFINE vcodret 						CHAR(5);
	
	LET vcodret = '000';

	-- // Extrae parametros globales
    select valor 
      into vgcodigo_mn
      from bdinteg:si_param
     where cod_param > 0
       and empresa = pempresa 
       and descripcion = "codigo mn";
    
    select sistema 
      into vg_sistema
      from bdinteg:si_sistema
     where sistema <> '00'
       and siglas = "SC";

    select valor 
      into vgtransacc_t1
      from sc_param
     where empresa = pempresa 
       and codparam = "tranlibsbc";

    select valor 
      into vgtransacc_t2
      from sc_param
     where empresa = pempresa 
       and codparam = "tranlibdomi";

    select valor 
      into vgcta_iva
      from sc_param
     where empresa = pempresa 
       and codparam = "ctaiva";

    select valor 
      into vgcta_itr
      from sc_param
     where empresa = pempresa 
       and codparam = "ctaitr";

    select valor 
      into vgtransacc_corresp
      from sc_param
     where empresa = pempresa 
       and codparam = "trancorrespchq";
	   
	 return vcodret;

end procedure;