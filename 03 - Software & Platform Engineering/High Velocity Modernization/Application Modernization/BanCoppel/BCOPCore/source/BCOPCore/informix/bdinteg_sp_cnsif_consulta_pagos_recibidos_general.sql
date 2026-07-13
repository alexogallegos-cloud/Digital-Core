CREATE PROCEDURE "informix".sp_cnsif_consulta_pagos_recibidos_general(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)       AS Codigo_Retorno,       
						  DATE          AS dfecha_movimientoimiento,
						  DECIMAL(18,2) AS deccapital_vigenteente,
						  DECIMAL(18,2) AS deccapital_vencidodo,
						  DECIMAL(18,2) AS decinteres_vigenteente,
						  DECIMAL(18,2) AS iva_decinteres_vigente,
						  DECIMAL(18,2) AS interes_vencido,
						  DECIMAL(18,2) AS iva_interes_vencido,
						  DECIMAL(18,2) AS interes_mora,
						  DECIMAL(18,2) AS iva_mora,
						  DECIMAL(18,2) AS total_pagado,
						  CHAR(16)      AS folio_sucursal;					
							
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;

--VARIABLES PARA EL STORE
DEFINE cCodRetS 		      CHAR(6);
DEFINE cMensaje               CHAR(80);
DEFINE cnum_credito	      	  CHAR(20);      
DEFINE dfecha_movimiento	  DATE;          
DEFINE deccapital_vigente	  DECIMAL(18,2); 
DEFINE deccapital_vencido	  DECIMAL(18,2); 
DEFINE decinteres_vigente	  DECIMAL(18,2); 
DEFINE deciva_interes_vig     DECIMAL(18,2); 
DEFINE decinteres_orden_abono DECIMAL(18,2); 
DEFINE deciva_orden_abono	  DECIMAL(18,2); 
DEFINE decinteres_mora		  DECIMAL(18,2); 
DEFINE deciva_mora		      DECIMAL(18,2);
DEFINE dectotal_pagado	      DECIMAL(18,2); 
DEFINE cfolio_sucursal	      CHAR(16);  
DEFINE iCont                  INTEGER;

--INICIALIZA VARIABLES
LET cnum_credito	       = "";
LET dfecha_movimiento	   = "";
LET deccapital_vigente	   = 0;
LET deccapital_vencido	   = 0;
LET decinteres_vigente	   = 0;
LET deciva_interes_vig     = 0;
LET decinteres_orden_abono = 0;
LET deciva_orden_abono	   = 0;
LET decinteres_mora	       = 0;
LET deciva_mora	           = 0;
LET dectotal_pagado	       = 0;
LET cfolio_sucursal	       = "";
LET iCont                  = 0;
LET cCodRetS               = "";

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
			deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consulta_pagos_recibidos_general.out";
	--TRACE ON;
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA  = ''	THEN 
		LET cCodRet = "00045";
		RETURN
			cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
			deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
	END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN
			cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
			deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;					
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN
                cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
                deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
        END IF;
    END IF;    
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN
			cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
			deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
	END IF;
	-- TERMINA VALIDACION	
    FOREACH
	SELECT LIMIT 1 NVL(COUNT(num_credito),0) AS CONT INTO iexiste FROM bdicred:sd_maecred WHERE num_credito  = cNUMCUENTA
    UNION
    SELECT NVL(COUNT(num_credito),0) AS CONT FROM bdicred:sd_maecredcrd WHERE num_credito  = cNUMCUENTA ORDER BY CONT DESC
    END FOREACH;
	IF iexiste  = 0 THEN 
		LET cCodRet = "00046";
		RETURN 
		cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
		deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
	END IF;
	
	IF pNumRegistro = 0 THEN
		DELETE FROM si_tempopagosrecibidos WHERE ejecutivosif= cID_USUARIOC;
		SET ISOLATION TO DIRTY READ;		
		FOREACH
		
			EXECUTE PROCEDURE bdicred:sp_consulta_pagos_recibidos_general  ('001',cNUMCUENTA)
			INTO
			cCodRetS,cMensaje,cnum_credito,dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
		    deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal
			
			LET cCodRet = SUBSTR(cCodRetS,2,6);
	
			IF cCodRet  != '00000' THEN	   
                IF cCodRet='00002' THEN
                    LET cCodRet ='00017';
                END IF;
                IF LENGTH(cCodRet)=3 THEN
                    LET cCodRet='00'||cCodRet;
                END IF;
				RETURN  
					cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
					deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
			END IF;
				
			INSERT INTO si_tempopagosrecibidos(cod_ret, fecha_movimiento, capital_vigente, capital_vencido, interes_vigente, iva_interes_vigente, interes_orden_abono, 
			                                   iva_orden_abono, interes_mora, iva_mora, total_pagado, folio_sucursal, cuenta, ejecutivosif) 
			VALUES(cCodRetS,dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
				   deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal,cNUMCUENTA,cID_USUARIOC);
			
		END FOREACH;

	END IF
	
	SET ISOLATION TO DIRTY READ;
		
	FOREACH
		SELECT SKIP pNumRegistro FIRST pRecuperacion
		cod_ret, fecha_movimiento, capital_vigente, capital_vencido, interes_vigente, iva_interes_vigente, interes_orden_abono, iva_orden_abono,
		interes_mora, iva_mora, total_pagado, folio_sucursal
		INTO
		cCodRetS,dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
		deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal
		FROM si_tempopagosrecibidos
		WHERE cuenta = cNUMCUENTA AND ejecutivosif= cID_USUARIOC ORDER BY fecha_movimiento DESC
		
		LET cCodRet = SUBSTR(cCodRetS,2,6);
		
		LET iCont=iCont + 1;
		
		RETURN 
				cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
				deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal WITH RESUME;
	END FOREACH;
	
	IF iCont = 0 THEN
		DELETE FROM si_tempopagosrecibidos WHERE ejecutivosif= cID_USUARIOC;
		LET cCodRet = 1001; 
		RETURN  
			cCodRet, dfecha_movimiento, deccapital_vigente, deccapital_vencido, decinteres_vigente, deciva_interes_vig, decinteres_orden_abono, 
			deciva_orden_abono, decinteres_mora, deciva_mora, dectotal_pagado, cfolio_sucursal;
	END IF 	

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de los Pagos Recibidos asociados a una Cuenta de Crédito. ",
"El SP obtendrá los datos de la Base de Datos central de Informix, enviando como parámetro el  No. de Cuenta.",
"FECHA : 05-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE  "informix".sp_cnsif_consultamovtosgeneraldomi(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),pNumcte CHAR(20),pTipoConsulta CHAR(1),pFechaInicio CHAR(10),pFechaFin CHAR(10),pNumRegistro INTEGER,pRecuperacion INTEGER)
	
	RETURNING CHAR(5)        AS Cod_Retorno,
			  DATE			 AS Fecha_Cargo, 
			  CHAR(20)		 AS Numero_Cuenta, 
			  MONEY(16,2)    AS Importe,
			  CHAR(40)		 AS Referencia,
			  CHAR(50)		 AS BancoRec_BancoPres,
			  CHAR(20)		 AS Status,
			  CHAR(02)       AS Causa_Rechazo,
			  CHAR(60)		 AS Desc_Causa_Rechazo,
			  CHAR(04)		 AS Sucursal;

---- VARIABLES  GENERALES---
DEFINE  cSqlerr				INTEGER;
DEFINE 	iExiste				INTEGER;
DEFINE 	dFecha_Ini			DATE;
DEFINE 	dFecha_Fin			DATE;
DEFINE 	dFechaCargo			DATE;
DEFINE	cEsFisica			CHAR(1);
DEFINE	cServicioDomi		CHAR(1);
DEFINE	cAutorizadoCteDomi	CHAR(1);
DEFINE	cTipper				CHAR(2);
DEFINE	cBancoPresentador	CHAR(3);
DEFINE	cBancoReceptor		CHAR(3);
DEFINE	cClaVeBancaria		CHAR(3);
DEFINE  cCodret     		CHAR(5);
DEFINE  cFechaFormarINI		CHAR(8);
DEFINE  cFechaFormarFIN		CHAR(8);
DEFINE  cFechaNac			CHAR(10);
DEFINE  cNumCte				CHAR(20);
DEFINE  cCuenta				CHAR(20);
DEFINE  cCuenta_clabe		CHAR(20);
DEFINE  cTarjeta			CHAR(20);
DEFINE 	cDescripcionEstatus CHAR(20);
DEFINE  cBanRecDescrip		CHAR(20);
DEFINE  cBanPresDescrip 	CHAR(20);
DEFINE  cRFC     			CHAR(18);
DEFINE  cRazon_social		CHAR(60);
DEFINE 	cDescripcionRechazo	CHAR(60);
DEFINE  cNombreCte     		CHAR(200);

DEFINE  cFecha_cargo		CHAR(8);
DEFINE 	cNCuenta			CHAR(20);
DEFINE  mImporte			MONEY(16,2);
DEFINE	cReferencia			CHAR(40);
DEFINE 	cBancosParticipantes CHAR(7);
DEFINE 	cEstatus			CHAR(20);
DEFINE 	cCausaRechazo		CHAR(20);
DEFINE  cTarjetaAux			CHAR(20);

DEFINE iCont            INTEGER;
DEFINE cSucursal        CHAR(04);
DEFINE cCuentaAux		CHAR(20);


--VALORES INICIALES
LET cSqlerr 		= 0;
LET iExiste			= 0;
LET cCodret 		= '00000';
LET cNombreCte 		= '';
LET cRFC 			= '';
LET cRazon_social	= '';
LET cFechaNac		= '';
LET cTipper			= '';
LET cEsFisica		= '';
LET cServicioDomi 	= '';
LET cAutorizadoCteDomi	= '';
LET cDescripcionEstatus = '';
LET cDescripcionRechazo = '';
LET cBanPresDescrip	= '';
LET cBanRecDescrip	= '';
LET dFechaCargo		= '';
LET cClaVeBancaria	= '';
LET dFecha_Ini		= '';
LET dFecha_Fin		= '';
LET cBancoPresentador	= '';
LET cBancoReceptor	= '';
LET cFecha_cargo	= '';
LET cNCuenta		= '';
LET mImporte		= '';
LET cReferencia		= '';
LET cBancosParticipantes	= '';
LET cEstatus		= '';
LET cCausaRechazo	= '';

LET iCont            = 0;
LET cSucursal        = '';
LET cCuentaAux       = '';
LET cTarjetaAux      = '';

	--  SET debug FILE TO "/tmp/CNSIF/sp_cnsif_consultamovtosgeneraldomi.out";
    --  Trace ON;

BEGIN
	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;
            RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
        END IF;
    END EXCEPTION;
	IF cID_USUARIOC='' OR cID_FUNCIONC='' OR pTipoConsulta = '' OR pNumcte = '' OR pFechaInicio = '' OR pFechaFin = ''  THEN
		LET cCodret = '00083';
		RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
	END IF

    IF pNumRegistro<0 THEN
        LET cCodret='00098';
        RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodret='00098';
            RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
        END IF;
    END IF;   	
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, pNumcte,'28','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
	END IF;
	-- TERMINA VALIDACION	
	
		LET dFecha_Ini = pFechaInicio;
		LET dFecha_Fin = pFechaFin;
		LET cFechaFormarINI = YEAR(dFecha_Ini)||LPAD(MONTH(dFecha_Ini),2,'0')||LPAD(DAY(dFecha_Ini),2,'0');
		LET cFechaFormarFIN = YEAR(dFecha_Fin)||LPAD(MONTH(dFecha_Fin),2,'0')||LPAD(DAY(dFecha_Fin),2,'0');
	
		--	se extrae el valor del prefijo correspondiente a la cuenta de debito.
	SELECT valor INTO cClaVeBancaria FROM bdidomi:dom_parametros WHERE cod_param = '05';

	--	Valida que tenga un valor el prefijo correspondiente a la cuenta de debito.
	IF cClaVeBancaria = '' OR cClaVeBancaria IS NULL Then
		LET cCodRet = '00084';
		RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
	END IF;
		
	  FOREACH WITH HOLD
	  
		SELECT LPAD(TRIM(cuenta),20,'0'), LPAD(TRIM(cuenta_clabe),20,'0') , TRIM(cuenta) 
		INTO cCuenta,cCuenta_clabe,cCuentaAux  
		FROM bdicheq:sc_maechq 
		WHERE num_cte = pNumcte
		
		SELECT LPAD(TRIM(num_tarjeta),20,'0'),TRIM(num_tarjeta) 
		INTO cTarjeta,cTarjetaAux 
		FROM bdicheq:sc_tarjeta 
		WHERE cuenta = cCuentaAux 
		AND numcte = pNumcte AND status_tar='A';
		
		/*SELECT TRIM(num_tarjeta)
		INTO cTarjetaAux 
		FROM bdicheq:sc_tarjeta 
		WHERE cuenta = cCuentaAux 
		AND numcte = pNumcte;*/
		
		IF pTipoConsulta = 'P' THEN
		  FOREACH WITH HOLD
			SELECT {+INDEX (bdidomi:dom_status_pago 133_356)}  SKIP pNumRegistro FIRST pRecuperacion
			--Det.fecha_presentacion,Det.num_cta_ord,Det.importe/100,Det.ref_leyenda,Det.banco_receptor,Det.banco_presentador,Det.cve_estatus,sTatPago.descripcion ,Det.motivo_dev,Dev.descripcion
            Det.fecha_presentacion,cCuentaAux,Det.importe/100,Det.ref_leyenda,Det.banco_receptor,Det.banco_presentador,Det.cve_estatus,sTatPago.descripcion ,Det.motivo_dev,Dev.descripcion
			INTO cFecha_cargo,cNCuenta,mImporte,cReferencia,cBancoReceptor,cBancoPresentador,cEstatus,cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo
			FROM bdidomi:dom_cce_detalle AS Det
			INNER JOIN bdidomi:dom_status_pago AS sTatPago ON (Det.cve_estatus = sTatPago.cve_status)
			INNER JOIN bdidomi:dom_cat_devoluciones AS Dev ON (Det.motivo_dev = Dev.motivo_dev)
			WHERE Det.num_cta_ord IN (cCuenta,cCuenta_clabe,cTarjeta)
			AND Det.fecha_presentacion >= cFechaFormarINI
			AND Det.fecha_presentacion <= cFechaFormarFIN
			AND Det.banco_presentador = cClaVeBancaria
			ORDER BY Det.fecha_presentacion DESC
			
			
			SELECT vchrnombrecorto INTO cBanRecDescrip FROM bdinteg:si_bancos WHERE banco = cBancoReceptor;
			SELECT vchrnombrecorto INTO cBanPresDescrip FROM bdinteg:si_bancos WHERE banco = cBancoPresentador;
			LET dFechaCargo = SUBSTR(cFecha_cargo,5,2)||'/'|| SUBSTR(cFecha_cargo,7,2) ||'/'|| SUBSTR(cFecha_cargo,1,4);
			
			SELECT cve_sucursal
			INTO cSucursal
			FROM bdidomi:dom_autorizaciones
			WHERE cuenta IN(cCuentaAux,cTarjetaAux);
			
			LET iCont = iCont + 1;
			
			RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal WITH RESUME;		
			
  		  END FOREACH;
		  
		END IF;
		
		IF pTipoConsulta = 'R' THEN
		  FOREACH WITH HOLD
			SELECT {+INDEX (bdidomi:dom_status_pago 133_356)} SKIP pNumRegistro FIRST pRecuperacion
			--Det.fecha_presentacion,Det.num_cta_rec,Det.importe/100,Det.ref_leyenda,Det.banco_receptor,Det.banco_presentador,Det.cve_estatus,sTatPago.descripcion ,Det.motivo_dev,Dev.descripcion
            Det.fecha_presentacion,cCuentaAux,Det.importe/100,Det.ref_leyenda,Det.banco_receptor,Det.banco_presentador,Det.cve_estatus,sTatPago.descripcion ,Det.motivo_dev,Dev.descripcion
			INTO cFecha_cargo,cNCuenta,mImporte,cReferencia,cBancoReceptor,cBancoPresentador,cEstatus,cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo
			FROM bdidomi:dom_cce_detalle AS Det
			INNER JOIN bdidomi:dom_status_pago AS sTatPago ON (Det.cve_estatus = sTatPago.cve_status)
			INNER JOIN bdidomi:dom_cat_devoluciones AS Dev ON (Det.motivo_dev = Dev.motivo_dev)
			WHERE Det.num_cta_rec IN (cCuenta,cCuenta_clabe,cTarjeta)
			AND Det.fecha_presentacion >= cFechaFormarINI
			AND Det.fecha_presentacion <= cFechaFormarFIN
			AND Det.banco_receptor = cClaVeBancaria
            ORDER BY Det.fecha_presentacion DESC
			
			
			SELECT vchrnombrecorto INTO cBanRecDescrip FROM bdinteg:si_bancos WHERE banco = cBancoReceptor;
			SELECT vchrnombrecorto INTO cBanPresDescrip FROM bdinteg:si_bancos WHERE banco = cBancoPresentador;
			LET dFechaCargo = SUBSTR(cFecha_cargo,5,2)||'/'|| SUBSTR(cFecha_cargo,7,2) ||'/'|| SUBSTR(cFecha_cargo,1,4);
			
			SELECT cve_sucursal
			INTO cSucursal
			FROM bdidomi:dom_autorizaciones
			WHERE cuenta IN(cCuentaAux,cTarjetaAux);
						
			LET iCont = iCont + 1;
			
			RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal WITH RESUME;		
			
		  END FOREACH;
		  
		END IF;
		
	  END FOREACH;
      IF pNumRegistro=0 AND iCont = 0 THEN
		LET cCodret = '00091'; 
		RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
      END IF;

	  IF iCont = 0 THEN
		LET cCodret = '1001'; 
		RETURN cCodret,dFechaCargo,cNCuenta,mImporte,cReferencia,TRIM(cBanRecDescrip)|| ' / ' ||TRIM(cBanPresDescrip),cDescripcionEstatus,cCausaRechazo,cDescripcionRechazo,cSucursal;
	  END IF
END
END PROCEDURE
DOCUMENT
"AUTOR :Arturo Cervantes Peña",
"DESCRIPCION:Obtener la información de los Movimientos de Cargo de las Domiciliaciones asociadas a un Cliente. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Número de Cliente.",
"FECHA : 02 ABRIL DEL 2012",
"BD    : BDINTEG",
"VERSION: 1.0";

CREATE PROCEDURE "informix".sp_cnsif_consultausuariofuncion(cID_USUARIOC char(8),cID_FUNCIONC char(10),cID_USUARIO CHAR(8),pNumRegistro INTEGER,pRecuperacion INTEGER)
    RETURNING CHAR(5),CHAR(8),CHAR(10),CHAR(100),CHAR(6),CHAR(20),INTEGER,CHAR(60),INTEGER, CHAR(1), CHAR(1);
													
	DEFINE iexiste 				INT;
	DEFINE cCodRet 				CHAR(5);
	DEFINE iSql_err 			INT;
	DEFINE cID_USUARIO_2 		CHAR(8);
	DEFINE cID_FUNCION			CHAR(10);
	DEFINE cD_FUNCION			CHAR(100);
	DEFINE cID_MODULO			CHAR(6);
	DEFINE cD_MODULO			CHAR(20);
	DEFINE iID_SUBMODULO		INTEGER;
	DEFINE cD_SUBMODULO			CHAR(60);
	DEFINE iORDEN				INTEGER;
	DEFINE cSTATUS_FUNCION		CHAR(1);
	DEFINE cSTATUS_FUNCIONU		CHAR(1);
    DEFINE iCont            INTEGER;
	
	
	
	LET iexiste = 0;
	LET cCodRet = "00000";	
	LET iSql_err = 0;
	LET cID_USUARIO_2 = " ";
	LET cID_FUNCION = " ";
	LET cD_FUNCION	= " ";
	LET cID_MODULO = " ";	
	LET cD_MODULO	= " ";	
	LET iID_SUBMODULO = 0	;
	LET cD_SUBMODULO =  " ";
	LET iORDEN	= 0;
	LET cSTATUS_FUNCION = " ";
	LET cSTATUS_FUNCIONU = " ";
    LET iCont=0;
	
	
	BEGIN
		ON EXCEPTION SET iSql_err
            IF iSql_err <> 0 THEN
                LET cCodRet = iSql_err;
                RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
            END IF;
        END EXCEPTION;
		--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_consultausuariofuncion.out";
		--TRACE ON;
		IF 	cID_USUARIOC ='' OR 
		cID_FUNCIONC = '' 	OR
		cID_USUARIO = ''	THEN
			LET cCodRet = "00003";
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
		END IF;		

        IF pNumRegistro<0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
        ELSE
            IF pRecuperacion<=0 THEN
                LET cCodRet='00098';
                RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
            END IF;
        END IF; 
		
		EXECUTE FUNCTION sp_cnsif_confirmaejecutivo (cID_USUARIOC,cID_FUNCIONC)
		INTO cCodRet;
		  
		IF cCodRet = '00028' THEN 
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
		END IF;		
		
		SELECT nvl(COUNT(id_usuario),0) INTO iexiste  FROM si_seg_usuarios_funciones WHERE id_usuario= cID_USUARIO;
		IF iexiste = 0 THEN
			LET cCodRet = "00074";
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
		END IF;

        SELECT NVL(COUNT(UF.id_funcion),0) INTO iexiste
        FROM  si_seg_usuarios_funciones UF
        LEFT JOIN si_seg_funciones FU
        ON UF.id_funcion  = FU.id_funcion 
        LEFT JOIN si_seg_modulos MO
        ON MO.id_modulo = FU.Id_modulo
        LEFT JOIN si_seg_submodulo SU
        ON SU.id_submodulo = FU.id_submodulo
        WHERE id_usuario= cID_USUARIO;

		IF iexiste = 0 THEN
			LET cCodRet = "00074";
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
		END IF;

		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion UF.id_usuario, UF.id_funcion, FU.d_funcion, FU.id_modulo,MO.d_modulo, FU.id_submodulo, SU.d_submodulo, FU.orden, FU.status, UF.status 
			INTO
			cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU
			FROM  si_seg_usuarios_funciones UF
			LEFT JOIN si_seg_funciones FU
			ON UF.id_funcion  = FU.id_funcion 
			LEFT JOIN si_seg_modulos MO
			ON MO.id_modulo = FU.Id_modulo
			LEFT JOIN si_seg_submodulo SU
			ON SU.id_submodulo = FU.id_submodulo
			WHERE id_usuario= cID_USUARIO
            ORDER BY id_submodulo,orden

            LET iCont=iCont+1;
			RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU with resume;
		END FOREACH
         IF iCont = 0 THEN
            LET cCodRet = 1001; 
            RETURN cCodRet,cID_USUARIO_2,cID_FUNCION,cD_FUNCION, cID_MODULO,cD_MODULO,iID_SUBMODULO,cD_SUBMODULO,iORDEN,cSTATUS_FUNCION,cSTATUS_FUNCIONU;
        END IF 
    END
END PROCEDURE	
DOCUMENT		
"AutOR : Antonio Flores",
"FUNCIONAMIENTO: Este SP devolvera las funciones del usuarios dependiendo del id_usuario que ingresen para la consulta",
"FECHA : 26-12-2011",
"BD    : bdinteg",
"VER   : 1.0",
"Modificación: Victor Hugo Sánchez. Se agrego parametrización para la recuperacion de informacion";

CREATE PROCEDURE "informix".sp_extrae_telefonos_comp( pcEmpresa CHAR(3) )
RETURNING CHAR(5)  AS vcCodRet1,
          CHAR(5)  AS vcCodRet2,
          CHAR(50) AS vcCodRet3,
          INTEGER  AS viContador1,
          INTEGER  AS viContador2;
    
    DEFINE vcCodRet1        CHAR(5);
    DEFINE vcCodRet2        CHAR(5);
    DEFINE vcCodRet3        CHAR(50);
    DEFINE viSqlErr         INTEGER;
    DEFINE viIsamErr        INTEGER;
    DEFINE vcDescErr        CHAR(50);
    DEFINE viComienza       SMALLINT;
    DEFINE viComienza2      SMALLINT;
    DEFINE viEnTransacc     SMALLINT;
    DEFINE viContador1      INTEGER;
    DEFINE viContador2      INTEGER;
    
    DEFINE vcCteMin         CHAR(20);
    DEFINE vcCteMax         CHAR(20);
    DEFINE vcCteMini        CHAR(20);
    DEFINE vcCteMaxi        CHAR(20);
    DEFINE vcNumCte         CHAR(20);
    DEFINE viSecuencia      SMALLINT;
    DEFINE vcTipoDir        CHAR(1);
    DEFINE vcTipoTelef1     CHAR(1);
    DEFINE vcTelefono1      CHAR(50);
    DEFINE vcTipoTelef2     CHAR(1);
    DEFINE vcTelefono2      CHAR(50);
    DEFINE vcTipoTelef3     CHAR(1);
    DEFINE vcTelefono3      CHAR(50);
    DEFINE vcExtension      CHAR(50);
    DEFINE vcUserInsert     CHAR(50);
    DEFINE vdFechaInsert    CHAR(50);
    DEFINE vCodRetValTel    CHAR(5);
    DEFINE vcValCasa        CHAR(1);
    DEFINE vcValCelular     CHAR(1);
    DEFINE vcValOficina     CHAR(1);
    DEFINE viCofetel        CHAR(1);    
    DEFINE vExisteTel       INTEGER;
    DEFINE vExisteTelAct    INTEGER;
    DEFINE vcTipoTelefono   CHAR(1);
    DEFINE vcTelefono       CHAR(50);
    DEFINE viTipoTel        SMALLINT;
    
    LET vcCodRet1    = '000';
    LET vcCodRet2    = '000';
    LET vcCodRet3    = 'PROCESO CONCLUIDO CORRECTAMENTE';
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET viComienza   = -1;
    LET viComienza2  = -1;
    LET viEnTransacc = 0;
    LET viContador1  = 0;
    LET viContador2  = 0;
    
    LET vcCteMin       = '';
    LET vcCteMax       = '';
    LET vcCteMini      = '';
    LET vcCteMaxi      = '';
    LET vcNumCte       = '';
    LET viSecuencia    = 0;
    LET vcTipoDir      = '';
    LET vcTipoTelef1   = '';
    LET vcTelefono1    = '';
    LET vcTipoTelef2   = '';
    LET vcTelefono2    = '';
    LET vcTipoTelef3   = '';
    LET vcTelefono3    = '';
    LET vcExtension    = '';
    LET vcUserInsert   = '';
    LET vdFechaInsert  = '';
    LET vCodRetValTel  = '';
    LET vcValCasa      = '';
    LET vcValCelular   = '';
    LET vcValOficina   = '';
    LET viCofetel      = 'F';
    LET vExisteTel     = 0;
    LET vExisteTelAct  = 0;
    LET vcTipoTelefono = '';
    LET vcTelefono     = '';
    LET viTipoTel      = 0;
    
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/informix/jivan/sp_extrae_telefonos_comp.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet1 = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            IF viEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador1, viContador2 ;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/informix/jivan/sp_extrae_telefonos_comp.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF ( pcEmpresa is null OR pcEmpresa = '' ) THEN
        LET vcCodRet1 = '110';
        RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador1, viContador2;
    END IF;
    
    -- // TABLA PARA TODAS LAS CUENTAS
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_telefonos_tmp_comp') THEN
        DROP TABLE si_telefonos_tmp_comp;        
    END IF;
    
    CREATE TABLE si_telefonos_tmp_comp
      (
        numcte          CHAR(20),
        tipo_dir        CHAR(1), 
        secuencia       SMALLINT, 
        tipo_telefono   CHAR(1), 
        telefono        CHAR(13), 
        extension       CHAR(5), 
        user_insert     CHAR(8), 
        fecha_insert    DATE
      )
    EXTENT SIZE 10000 NEXT SIZE 1000 LOCK MODE ROW;
    
    SELECT MIN(numcte), MAX(numcte)
      INTO vcCteMin, vcCteMax
      FROM bdinteg:"informix".si_cliente;
      
    SELECT numcte
      FROM bdinteg:"informix".si_direcciones
     WHERE numcte BETWEEN vcCteMin AND vcCteMax
       AND fecha_insert >= '06/15/2012'
    INTO TEMP tmp_ctes WITH NO LOG;
    CREATE INDEX idx_cte_tmp ON tmp_ctes(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes;
    
    SELECT MIN(numcte), MAX(numcte)
      INTO vcCteMin, vcCteMax
      FROM tmp_ctes;
    
    FOREACH WITH HOLD
        SELECT numcte
          INTO vcNumCte
          FROM tmp_ctes   
         WHERE numcte BETWEEN vcCteMin AND vcCteMax
         
        IF viComienza = -1 THEN
            LET viComienza = 0;
        END IF;
         
        BEGIN WORK;
        LET viEnTransacc = 1;
        
        FOREACH
            SELECT secuencia, tipo_dir, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, user_insert, fecha_insert
              INTO viSecuencia, vcTipoDir, vcTipoTelef1, vcTelefono1, vcTipoTelef2, vcTelefono2, vcTipoTelef3, vcTelefono3, vcExtension, vcUserInsert, vdFechaInsert
              FROM bdinteg:"informix".si_direcciones
             WHERE numcte = vcNumCte
               AND fecha_insert >= '06/15/2012'
             ORDER BY secuencia DESC
             
            IF ( vcTipoTelef1 is not null AND vcTipoTelef1 <> '' ) AND ( vcTelefono1 is not null AND vcTelefono1 <> '' AND LENGTH(vcTelefono1) > 6 ) THEN
                INSERT INTO bdinteg:"informix".si_telefonos_tmp_comp(numcte, tipo_dir, secuencia, tipo_telefono, telefono, extension, user_insert, fecha_insert)
                VALUES(vcNumCte, vcTipoDir, viSecuencia, vcTipoTelef1, vcTelefono1, '', vcUserInsert, vdFechaInsert);
            END IF;
            
            IF ( vcTipoTelef2 is not null AND vcTipoTelef2 <> '' ) AND ( vcTelefono2 is not null AND vcTelefono2 <> '' AND LENGTH(vcTelefono2) > 6 ) THEN
                INSERT INTO bdinteg:"informix".si_telefonos_tmp_comp(numcte, tipo_dir, secuencia, tipo_telefono, telefono, extension, user_insert, fecha_insert)
                VALUES(vcNumCte, vcTipoDir, viSecuencia, vcTipoTelef2, vcTelefono2, '', vcUserInsert, vdFechaInsert);
            END IF;
            
            IF ( vcTipoTelef3 is not null AND vcTipoTelef3 <> '' ) AND ( vcTelefono3 is not null AND vcTelefono3 <> '' AND LENGTH(vcTelefono3) > 6 ) THEN
                INSERT INTO bdinteg:"informix".si_telefonos_tmp_comp(numcte, tipo_dir, secuencia, tipo_telefono, telefono, extension, user_insert, fecha_insert)
                VALUES(vcNumCte, vcTipoDir, viSecuencia, vcTipoTelef3, vcTelefono3, vcExtension, vcUserInsert, vdFechaInsert);
            END IF;
            
            LET viSecuencia   = 0;
            LET vcTipoDir     = '';
            LET vcTipoTelef1  = '';
            LET vcTelefono1   = '';
            LET vcTipoTelef2  = '';
            LET vcTelefono2   = '';
            LET vcTipoTelef3  = '';
            LET vcTelefono3   = '';
            LET vcExtension   = '';
            LET vcUserInsert  = '';
            LET vdFechaInsert = '';
        END FOREACH;
        
        LET viContador1 = viContador1 + 1;
        
        COMMIT WORK;
        LET viEnTransacc = 0;
        
        LET vcNumCte = '';
    END FOREACH;
    
    CREATE INDEX idx_teltmp_ctecomp ON si_telefonos_tmp_comp(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE si_telefonos_tmp_comp;
    
    SELECT MIN(numcte), MAX(numcte)
      INTO vcCteMini, vcCteMaxi
      FROM bdinteg:"informix".si_telefonos_tmp_comp;
    
    FOREACH WITH HOLD
        SELECT UNIQUE numcte
          INTO vcNumCte
          FROM bdinteg:"informix".si_telefonos_tmp_comp
         WHERE numcte BETWEEN vcCteMini AND vcCteMaxi
           
        IF viComienza2 = -1 THEN
            LET viComienza2 = 0;
        END IF;
         
        BEGIN WORK;
        LET viEnTransacc = 1;
            
        FOREACH
            SELECT tipo_dir, secuencia, tipo_telefono, telefono, extension, user_insert, fecha_insert
              INTO vcTipoDir, viSecuencia, vcTipoTelefono, vcTelefono, vcExtension, vcUserInsert, vdFechaInsert
              FROM bdinteg:"informix".si_telefonos_tmp_comp
             WHERE numcte = vcNumCte
             ORDER BY secuencia
            
            IF   vcTipoDir = '1' AND vcTipoTelefono = 'P' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 1; --- CASA
            ELIF vcTipoDir = '1' AND vcTipoTelefono = 'C' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 2; --- CELULAR
            ELIF vcTipoDir = '1' AND vcTipoTelefono = 'O' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 4; --- OTRO
            ELIF vcTipoDir = '2' AND vcTipoTelefono = 'P' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 3; --- TRABAJO
            ELIF vcTipoDir = '2' AND vcTipoTelefono = 'C' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 2; --- CELULAR
            ELIF vcTipoDir = '2' AND vcTipoTelefono = 'O' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 4; --- OTRO
            ELIF vcTipoDir = '3' AND vcTipoTelefono = 'P' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 3; --- TRABAJO
            ELIF vcTipoDir = '3' AND vcTipoTelefono = 'C' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 2; --- CELULAR
            ELIF vcTipoDir = '3' AND vcTipoTelefono = 'O' AND ( vcTelefono is not null AND vcTelefono <> '' AND LENGTH(vcTelefono) > 6 ) THEN
                LET viTipoTel = 4; --- OTRO
            END IF;
            
            -- // VALIDA SI YA EXISTE EL TELEFONO
            SELECT COUNT(*)
              INTO vExisteTel
              FROM bdinteg:"informix".si_telefonos_actual
             WHERE numcte = vcNumCte
               AND tipo_tel = viTipoTel
               AND telefono = vcTelefono;
            
            IF vExisteTel = 0 THEN
                -- // VALIDA SI EL TELEFONO ES VALIDO PARA COFETEL
                EXECUTE PROCEDURE bdinteg:"informix".sp_validatelefono(pcEmpresa, vcTelefono, vcTelefono, vcTelefono)
                INTO vCodRetValTel, vcValCasa, vcValCelular, vcValOficina;
                
                IF vcValCasa = '1' OR vcValCelular = '1' OR vcValOficina = '1' THEN
                    LET viCofetel = 'V';
                END IF;
                
                UPDATE bdinteg:"informix".si_telefonos
                   SET status_tel = 'C'
                 WHERE numcte = vcNumCte
                   AND tipo_tel = viTipoTel;
                   
                -- // OBTIENE EL NUMERO DE SECUENCIA
                SELECT MAX(secuencia)
                  INTO viSecuencia
                  FROM bdinteg:"informix".si_telefonos
                 WHERE numcte = vcNumCte;
                         
                IF viSecuencia is null OR viSecuencia = '' THEN
                    LET viSecuencia = 0;
                END IF;
                
                LET viSecuencia = viSecuencia + 1;
                
                INSERT INTO bdinteg:"informix".si_telefonos
                (empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert)
                VALUES
                (pcEmpresa, vcNumCte, vcTelefono, viTipoTel, 'A', viSecuencia, vcExtension, 0, 1, 0, viCofetel, vdFechaInsert, vcUserInsert);
            END IF;
            
            LET vcTipoDir      = '';
            LET viSecuencia    = 0;
            LET vcTipoTelefono = '';
            LET vcTelefono     = '';
            LET vcExtension    = '';
            LET vcUserInsert   = '';
            LET vdFechaInsert  = '';
            LET viTipoTel      = 0;
            LET vCodRetValTel  = '';
            LET vcValCasa      = '';
            LET vcValCelular   = '';
            LET vcValOficina   = '';
            LET viCofetel      = 'F';
            LET vExisteTel     = 0;
            LET vExisteTelAct  = 0;
        END FOREACH;  
            
        LET viContador2 = viContador2 + 1;
        
        COMMIT WORK;
        LET viEnTransacc = 0;
        
        LET vcNumCte = '';
    END FOREACH;
    
    END;

    RETURN vcCodRet1, vcCodRet2, vcCodRet3, viContador1, viContador2;

END PROCEDURE;