CREATE PROCEDURE "informix".sp_ctamec_obtienetiporegimenfirmas (pClave CHAR(1))

	-- DATOS A REGRESAR --
	RETURNING
	CHAR(5) AS COD_RET,    -- Codigo de retorno
	CHAR(2) AS CLAVE_REGIMEN,    -- Clave del regimen
	CHAR(20) AS DESCRIPCION,   -- Descripcion
	CHAR(20) AS COMBINACION;   -- Combinacion
	
	--	VARIABLES CONTROL DE ERRORES --
	DEFINE cCodRet  CHAR(5);
	DEFINE iSqlErr  INTEGER;
	
	-- VARIABLES --
	DEFINE cCodReg	CHAR(2);
	DEFINE cDesc    CHAR(20);
	DEFINE cComb    CHAR(20);
	DEFINE iParam SMALLINT;
	

	-- INICIALIZACION DE VARIABLES --
	LET cCodRet  = "000";
	LET cCodReg = "";
	LET cDesc = "";
	LET cComb = "";
	LET iParam = 0;
	LET iSqlErr = 0;

		
	--SET DEBUG FILE TO "/dbexport/victor/sp_ctamec_obtienetiporegimenfirmas.out";
	--TRACE ON;
	
	-- CONTROL DE ERRORES --	
BEGIN
	ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet,cCodReg,cDesc,cComb;
        END IF
	END EXCEPTION;

    set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
		
	IF pClave = "" THEN
		LET pClave = NULL;
	END IF
	
	IF pClave IS NULL THEN
	--SE REALIZA UNA CONSULTA COMPLETA Y REGRESA TODOS LOS REGISTROS
		
		FOREACH
			SELECT cve_regimen, descripcion, combinacion
			INTO cCodReg,cDesc,cComb
			FROM bdicntchq:"informix".sq_catregimen 
			ORDER BY cve_regimen
			RETURN cCodRet,cCodReg,cDesc,cComb WITH RESUME;
			
		LET iParam = 1;
		
		END FOREACH;
		
	ELSE 
	--SE REALIZA UNA BUSQUEDA CON CRITERIO
		LET cCodReg = pClave;
		
		SELECT descripcion, combinacion
		INTO cDesc,cComb
		FROM bdicntchq:"informix".sq_catregimen 
		WHERE cve_regimen = pClave;
		
		IF cDesc IS NULL THEN --NO EXISTE EL TIPO DE FIRMA
			LET cCodRet = '200';
			RETURN cCodRet,cCodReg,cDesc,cComb;
		END IF;
		
		RETURN cCodRet,cCodReg,cDesc,cComb;
		
	END IF;
	
	IF iParam = 0 THEN --NO HAY DATOS EN LA TABLA
		LET cCodRet = '300';
		RETURN cCodRet,cCodReg,cDesc,cComb;
	END IF
	
END
END PROCEDURE
DOCUMENT
'Procedimiento   : ObtenerTipoFirmaSPL',
'Versión         : 1.0',
'Creado por      : Victor Hugo Nuñez Velazquez',
'Fecha creacion  : 09 Junio 2011',
'Descripcion     : Obtiene Los tipo de Firma';

CREATE PROCEDURE "informix".sp_ctamec_obtienechequeras( pEmpresa CHAR(3),                                            
											pCliente CHAR(20),
                                            pCuenta  CHAR(20),
											pSucursal CHAR(4),
											pCamara  SMALLINT,
											pNumCheque INTEGER,
											pImporte MONEY(14,2),
											pFechaIni DATE,
											pFechaFin DATE
											)
	RETURNING     
			CHAR(5) 	AS 	cCodRet ,   		-- cCodRet
			CHAR(20) 	AS 	cNumCteSpChra,  	-- cNumCte
			CHAR(20) 	AS 	cCuentaSpChra,  	-- cCuenta
			CHAR(20) 	AS 	iReg_FirmasSpChra,  -- Reg_firmas, tipo de regimen
			DATE 		AS 	dFec_RecepSpChra,   -- Fecha de Recepcion
			CHAR(1) 	AS 	cStatusSpChra,   	-- Cve Estatus
			INTEGER 	AS 	iChqIniSpChra,  	-- numero de cheque inicial
			INTEGER 	AS 	iChqFinSpChra,   	-- numero de cheque final
			INTEGER 	AS 	iNumeroSpChra,   	-- numero de cheques
			CHAR(10) 	AS 	iConsecSpChra,   	-- consecutivo
			CHAR(50) 	AS 	cDetStatusSpChra,  	-- Detalle de Estatus
			CHAR(120) 	AS 	cNombreSpChra;  	-- nombre cliente
						
	--DEFINICION DE VARIABLES
	DEFINE  iSqlErr        		INTEGER;	
	--Variables Codigo
	DEFINE cCodRet        		CHAR(5);	
	DEFINE cCuenta		        CHAR(20);		
	DEFINE cCuentaCte	        CHAR(20);	
	DEFINE iReg_Firmas		    INTEGER;	
    DEFINE cEstado         		CHAR(3);
    DEFINE cEstado2        		CHAR(3);
	DEFINE cNumCteIntg     		CHAR(20);
    --Variables SP sp_conchequerav	
	DEFINE cCodRetSpChra     	CHAR(5);
	DEFINE cNumCteSpChra     	CHAR(20);	
	DEFINE cCuentaSpChra        CHAR(20);
	DEFINE iReg_FirmasSpChra 	INTEGER;
	DEFINE dFec_RecepSpChra     DATE;
	DEFINE cStatusSpChra        CHAR(13);
	DEFINE iChqIniSpChra		INTEGER;
    DEFINE iChqFinSpChra        INTEGER;
	DEFINE iNumeroSpChra        INTEGER;
	DEFINE iConsecSpChra		INTEGER;
	DEFINE cDetStatusSpChra     CHAR(50);
	DEFINE cNombreSpChra        CHAR(120);	
		
	--INICIALIZACION DE VARIABLES	
	LET  iSqlErr            = 0;
	--Variables Codigo
	LET cCodRet	    		= "00000";	
	LET cCuenta	    		= "";	
	LET cCuentaCte    		= "";	
    LET iReg_Firmas         = 0;	
	LET cEstado        		= "";
	LET cEstado2       		= "";
	LET cNumCteIntg 		= "";
	--Variables SP sp_conchequerav	
	LET cCodRetSpChra 		= "";  
	LET cNumCteSpChra       = "";  
	LET cCuentaSpChra       = "";  
	LET iReg_FirmasSpChra   = 0;
	LET dFec_RecepSpChra    = "";  
	LET cStatusSpChra       = "";  
	LET iChqIniSpChra		= 0;
    LET iChqFinSpChra       = 0;
	LET iNumeroSpChra       = 0;
	LET iConsecSpChra		= 0;
	LET cDetStatusSpChra    = "";  
	LET cNombreSpChra       = ""; 	
				
	--SET DEBUG FILE TO "/tmp/manuel/sp_ctamec_obtienechequeras.out";
    --TRACE ON;
   
	BEGIN
		ON EXCEPTION SET  iSqlErr
		   IF  iSqlErr <> 0 THEN
			  LET cCodRet =  iSqlErr;
			 RETURN cCodRet,cNumCteSpChra,cCuentaSpChra,iReg_FirmasSpChra,dFec_RecepSpChra,cStatusSpChra,
					iChqIniSpChra,iChqFinSpChra,iNumeroSpChra,iConsecSpChra,cDetStatusSpChra,cNombreSpChra;
		   END IF;
		END EXCEPTION;
		
        set isolation to dirty read;
		SET LOCK MODE TO WAIT 3;
		
		--Valido que al menos se proporcione la Empresa y un parametro.
		IF ((pEmpresa IS NULL OR pEmpresa = '') OR ((pCliente IS NULL OR pCliente ='') 	AND 	
			(pCuenta IS NULL OR pCuenta ='')	AND 	(pSucursal IS NULL OR pSucursal ='') 	AND 
			(pCamara IS NULL OR pCamara ='') 	AND 	(pNumCheque IS NULL OR pNumCheque ='') 	AND
			(pImporte IS NULL OR pImporte ='') 	AND 	((pFechaIni IS NULL OR pFechaIni ='') 	AND (pFechaFin IS NULL OR pFechaFin ='')) 
			)) THEN
			
		   LET cCodRet = "00001";		   RETURN cCodRet,cNumCteSpChra,cCuentaSpChra,iReg_FirmasSpChra,dFec_RecepSpChra,cStatusSpChra,
					iChqIniSpChra,iChqFinSpChra,iNumeroSpChra,iConsecSpChra,cDetStatusSpChra,cNombreSpChra;	   
		END IF; 
				
		--Verifica que traiga valor el parametro.
		IF pCamara IS NOT NULL THEN
			IF pCamara = 1 THEN
			   LET cEstado = "M";
			   LET cEstado2 = "N";
			ELSE
			   LET cEstado = "";
			   LET cEstado2 = "";
			END IF;
	    END IF;
		
		IF pCliente IS NOT NULL AND pCliente <> '' THEN
			SELECT numcte 
			INTO cNumCteIntg
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = pEmpresa
			AND numcte = pCliente;
			--Validar si existe el cliente en caso de que se mande en los parametros.
			IF cNumCteIntg IS NULL OR cNumCteIntg = '' THEN
				LET cCodRet = "00002";				RETURN cCodRet,cNumCteSpChra,cCuentaSpChra,iReg_FirmasSpChra,dFec_RecepSpChra,cStatusSpChra,
					iChqIniSpChra,iChqFinSpChra,iNumeroSpChra,iConsecSpChra,cDetStatusSpChra,cNombreSpChra;
			END IF;									
		END IF;			
									
		IF pSucursal IS NOT NULL AND pSucursal <> '' THEN 
			
			FOREACH -- 1 es cuando selecciono una sucursal 
				--Obtengo la Cuenta y el consecutivo en base a los parametros que se reciban.								
				SELECT DISTINCT cont.cuenta, cont.consec 
					INTO cCuenta, iReg_Firmas
				FROM bdicheq:"informix".sc_contch cont 
					INNER JOIN bdicheq:"informix".sc_contch_hist his ON (cont.cuenta = his.cuenta AND cont.numero = his.numchq AND cont.estado = his.status)
					INNER JOIN bdicheq:"informix".sc_maechq mae      ON (cont.cuenta = mae.cuenta AND cont.empresa = mae.empresa)
				WHERE 							
					cont.cuenta =      CASE WHEN pCuenta = ""    		THEN cont.cuenta    	ELSE pCuenta END
					AND cont.importe =     CASE WHEN pImporte IS NULL 	THEN cont.importe 		ELSE pImporte END
					AND cont.fecha_alta >= CASE WHEN pFechaIni IS NULL  THEN cont.fecha_alta  	ELSE pFechaIni END
					AND cont.fecha_alta <= CASE WHEN pFechaFin IS NULL  THEN cont.fecha_alta  	ELSE pFechaFin END																			
					AND his.sucursal =     CASE WHEN pSucursal = ""  	THEN his.sucursal  		ELSE pSucursal END									
					AND ((cont.estado =    CASE WHEN cEstado = ""    	THEN cont.estado 		ELSE cEstado END) 
					 OR (cont.estado =     CASE WHEN cEstado2 = ""   	THEN  cont.estado  		ELSE cEstado2 END))				
					AND cont.numero =      CASE WHEN pNumCheque IS NULL THEN  cont.numero 		ELSE pNumCheque END					
					AND mae.num_cte =      CASE WHEN pCliente = ""   	THEN mae.num_cte  		ELSE pCliente END				
				
				FOREACH  
					--Obtengo la informacion de Cuentas de Chequeras.
					EXECUTE PROCEDURE bdicntchq:"informix".sp_conchequerav(pEmpresa,cCuenta,iReg_Firmas)
						INTO cCodRetSpChra,cNumCteSpChra,cCuentaSpChra,iReg_FirmasSpChra,dFec_RecepSpChra,cStatusSpChra,
							 iChqIniSpChra,iChqFinSpChra,iNumeroSpChra,iConsecSpChra,cDetStatusSpChra,cNombreSpChra
							 										
					--valido si truena el sp por un error controlado o un error de informix.		
					IF cCodRetSpChra > "000" THEN				 				  	
						CONTINUE FOREACH;
					ELIF cCodRetSpChra < "000" THEN 
						LET cCodRet =  '00003'; --error informix de sp_consulta_saldos_general. 
						EXIT FOREACH;							
					END IF ;
								
					RETURN cCodRet,cNumCteSpChra,cCuentaSpChra,iReg_FirmasSpChra,dFec_RecepSpChra,cStatusSpChra,
						iChqIniSpChra,iChqFinSpChra,iNumeroSpChra,iConsecSpChra,cDetStatusSpChra,cNombreSpChra WITH resume;
				
				END FOREACH;															
			END FOREACH;
			
		ELSE

			FOREACH							
				--Obtengo la Cuenta y el consecutivo en base a los parametros que se reciban.
				SELECT DISTINCT cont.cuenta, cont.consec 
				INTO cCuenta, iReg_Firmas
				FROM bdicheq:"informix".sc_contch cont
					LEFT OUTER JOIN bdicheq:"informix".sc_contch_hist his ON (cont.cuenta = his.cuenta AND cont.numero = his.numchq AND cont.estado = his.status)
					INNER JOIN bdicheq:"informix".sc_maechq mae       ON (cont.cuenta = mae.cuenta AND cont.empresa = mae.empresa)
				WHERE 					    
						cont.cuenta =      CASE WHEN pCuenta = ""    	THEN cont.cuenta    	ELSE pCuenta END
					AND cont.importe =     CASE WHEN pImporte IS NULL 	THEN cont.importe 		ELSE pImporte END
					AND cont.fecha_alta >= CASE WHEN pFechaIni IS NULL  THEN cont.fecha_alta  	ELSE pFechaIni END
					AND cont.fecha_alta <= CASE WHEN pFechaFin IS NULL  THEN cont.fecha_alta  	ELSE pFechaFin END													
					AND ((cont.estado =    CASE WHEN cEstado = ""    	THEN  cont.estado   	ELSE cEstado END) 
					 OR (cont.estado =     CASE WHEN cEstado2 = ""   	THEN  cont.estado  		ELSE cEstado2 END))				
					AND cont.numero =      CASE WHEN pNumCheque IS NULL THEN  cont.numero 		ELSE pNumCheque END					
					AND mae.num_cte =      CASE WHEN pCliente = ""   	THEN mae.num_cte  		ELSE pCliente END				
									   							
				FOREACH 
					--Obtengo la informacion de Cuentas de Chequeras.
					EXECUTE PROCEDURE bdicntchq:"informix".sp_conchequerav(pEmpresa,cCuenta,iReg_Firmas)
						INTO cCodRetSpChra,cNumCteSpChra,cCuentaSpChra,iReg_FirmasSpChra,dFec_RecepSpChra,cStatusSpChra,
							 iChqIniSpChra,iChqFinSpChra,iNumeroSpChra,iConsecSpChra,cDetStatusSpChra,cNombreSpChra
							 										
					--valido si truena el sp por un error controlado o un error de informix.		
					IF cCodRetSpChra > "000" THEN				 				  	
						CONTINUE FOREACH;
					ELIF cCodRetSpChra < "000" THEN 
						LET cCodRet =  '00003'; --error informix de sp_consulta_saldos_general. 
						EXIT FOREACH;							
					END IF ;
							
					RETURN cCodRet,cNumCteSpChra,cCuentaSpChra,iReg_FirmasSpChra,dFec_RecepSpChra,cStatusSpChra,
						iChqIniSpChra,iChqFinSpChra,iNumeroSpChra,iConsecSpChra,cDetStatusSpChra,cNombreSpChra WITH resume;
				
				END FOREACH;
								
			END FOREACH;
		END IF; 				
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '00004';  --No hay informacion.
			RETURN cCodRet,cNumCteSpChra,cCuentaSpChra,iReg_FirmasSpChra,dFec_RecepSpChra,cStatusSpChra,
					iChqIniSpChra,iChqFinSpChra,iNumeroSpChra,iConsecSpChra,cDetStatusSpChra,cNombreSpChra;
		END IF;				
	END; 	
END PROCEDURE                                                                                                                                                                                      
 DOCUMENT
'AUTOR: Guadalupe Payan',
'Proyecto: Cuenta Eje Empresarial',
'Solicito: Armando Mercado',
'Descripcion: Obtiene las Cuentas Chequeras segun los parametros proporcionados',
'Fecha: 2011/06/16',
'Version: 20110616.1750',
'BD: bdicntchq';

CREATE PROCEDURE "informix".sp_ctamec_obtienedetallecheq( pEmpresa CHAR(3),                                            
														pCliente CHAR(20),
														pCuenta  CHAR(20),
														pConsec  INTEGER,
														pSucursal CHAR(4),
														pCamara  SMALLINT,
														pNumCheque INTEGER,
														pImporte MONEY(14,2),
														pFechaIni DATE,
														pFechaFin DATE
														)
	RETURNING     
			CHAR(5) 		AS 	cCodRet ,   		-- cCodRet
			CHAR(20) 		AS 	cNumCte,  	-- cNumCte
			CHAR(20) 		AS 	cCuenta,  	-- cCuenta			
			INTEGER 		AS 	iReg_Firmas,  -- Reg_firmas, tipo de regimen
			INTEGER 		AS 	iFinal,   	-- numero de cheque final
			INTEGER 		AS 	iNumero,   	-- numero de cheques
			CHAR(50) 		AS 	cDescripCheq,  	-- Detalle de Estatus
			DATE 			AS 	dFechaAlta,   -- Fecha de Recepcion			
			MONEY(14,2) 	AS 	mImporte;  	-- numero de cheque inicial
					
						
	--DEFINICION DE VARIABLES
	DEFINE  iSqlErr        		INTEGER;	
	--Variables Codigo
	DEFINE cCodRet        		CHAR(5);	
	DEFINE cNumCte        		CHAR(20);	
	DEFINE cCuenta		        CHAR(20);			
	DEFINE iReg_Firmas		    INTEGER;	
	DEFINE iFinal		    INTEGER;
	DEFINE iNumero		    	INTEGER;
	DEFINE cEstadoCheq		    CHAR(1);
	DEFINE cDescripCheq		    CHAR(50);
	DEFINE dFechaAlta		    DATE;
	DEFINE mImporte		    	MONEY(14,2);	
    DEFINE cEstado         		CHAR(3);
    DEFINE cEstado2        		CHAR(3);
	DEFINE cNumCteIntg     		CHAR(20);   
		
	--INICIALIZACION DE VARIABLES	
	LET  iSqlErr            = 0;
	--Variables Codigo
	LET cCodRet	    		= "00000";	
	LET cNumCte	    		= "";		
	LET cCuenta	    		= "";		    
    LET iReg_Firmas         = 0;	
    LET iFinal         		= 0;		
    LET iNumero         	= 0;	
    LET cEstadoCheq         = "";	
    LET cDescripCheq        = "";	
    LET dFechaAlta         	= "";	
    LET mImporte       	  	= 0;	
	LET cEstado        		= "";
	LET cEstado2       		= "";
	LET cNumCteIntg 		= "";	
				
	--SET DEBUG FILE TO "/tmp/manuel/sp_ctamec_obtienedetallecheq.out";
    --TRACE ON;
   
	BEGIN
		ON EXCEPTION SET  iSqlErr
		   IF  iSqlErr <> 0 THEN
			  LET cCodRet =  iSqlErr;
			 RETURN cCodRet,cNumCte,cCuenta, iReg_Firmas,iFinal,iNumero,cDescripCheq,dFechaAlta,mImporte;
		   END IF;
		END EXCEPTION;
		
        set isolation to dirty read;
		SET LOCK MODE TO WAIT 3;
		
		--Valido que al menos se proporcione la Empresa y un parametro.
		IF ((pEmpresa IS NULL OR pEmpresa = '') OR (pCuenta IS NULL OR pCuenta ='') OR	
		   (pConsec IS NULL OR pConsec ='') 	
		   )THEN
			
		   LET cCodRet = "00001";		   RETURN cCodRet,cNumCte,cCuenta, iReg_Firmas,iFinal,iNumero,cDescripCheq,dFechaAlta,mImporte; 
		END IF; 
				
		--Verifica que traiga valor el parametro.
		IF pCamara IS NOT NULL THEN
			IF pCamara = 1 THEN
			   LET cEstado = "M";
			   LET cEstado2 = "N";
			ELSE
			   LET cEstado = "";
			   LET cEstado2 = "";
			END IF;
	    END IF;
		
		IF pCliente IS NOT NULL AND pCliente <> '' THEN
			SELECT numcte 
			INTO cNumCteIntg
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = pEmpresa
			AND numcte = pCliente;
			--Validar si existe el cliente en caso de que se mande en los parametros.
			IF cNumCteIntg IS NULL OR cNumCteIntg = '' THEN
				LET cCodRet = "00002";				RETURN cCodRet,cNumCte,cCuenta, iReg_Firmas,iFinal,iNumero,cDescripCheq,dFechaAlta,mImporte;
			END IF;									
		END IF;			
							
		
		IF pSucursal IS NOT NULL AND pSucursal <> '' THEN 
			
			FOREACH -- 1 es cuando selecciono una sucursal 
				--Obtengo la Cuenta y el consecutivo en base a los parametros que se reciban.								
				SELECT DISTINCT mae.num_cte,cont.cuenta, cont.consec,cont.numero, cont.estado, cont.fecha_alta, cont.importe, st.descripcion  
				INTO cNumCte,cCuenta, iReg_Firmas,iNumero,cEstadoCheq,dFechaAlta,mImporte,cDescripCheq
				FROM bdicheq:"informix".sc_contch cont 
					INNER JOIN bdicheq:"informix".sc_contch_hist his 	ON (cont.cuenta = his.cuenta AND cont.numero = his.numchq AND cont.estado = his.status)
					INNER JOIN bdicheq:"informix".sc_maechq mae      	ON (cont.cuenta = mae.cuenta AND cont.empresa = mae.empresa)
					INNER JOIN bdicntchq:"informix".sq_status_chequera st ON(st.status = estado)
				WHERE 							
					cont.cuenta =      CASE WHEN pCuenta = ""    		THEN cont.cuenta    	ELSE pCuenta END
					AND cont.importe =     CASE WHEN pImporte IS NULL 	THEN cont.importe 		ELSE pImporte END
					AND cont.fecha_alta >= CASE WHEN pFechaIni IS NULL  THEN cont.fecha_alta  	ELSE pFechaIni END
					AND cont.fecha_alta <= CASE WHEN pFechaFin IS NULL  THEN cont.fecha_alta  	ELSE pFechaFin END																			
					AND his.sucursal =     CASE WHEN pSucursal = ""  	THEN his.sucursal  		ELSE pSucursal END									
					AND ((cont.estado =    CASE WHEN cEstado = ""    	THEN cont.estado 		ELSE cEstado END) 
					 OR (cont.estado =     CASE WHEN cEstado2 = ""   	THEN  cont.estado  		ELSE cEstado2 END))				
					AND cont.numero =      CASE WHEN pNumCheque IS NULL THEN  cont.numero 		ELSE pNumCheque END					
					AND mae.num_cte =      CASE WHEN pCliente = ""   	THEN mae.num_cte  		ELSE pCliente END
					AND st.clave = 2
					AND cont.consec = pConsec
											
				--Obtengo numero de cheque final
				SELECT final  
				INTO iFinal
				FROM bdicntchq:"informix".sq_maechqra
				WHERE cuenta = cCuenta
				AND consec = iReg_Firmas;
				
				RETURN cCodRet,cNumCte,cCuenta, iReg_Firmas,iFinal,iNumero,cDescripCheq,dFechaAlta,mImporte	WITH resume;	
				                                   									
			END FOREACH;
			
		ELSE

			FOREACH							
				--Obtengo la Cuenta y el consecutivo en base a los parametros que se reciban.		
				SELECT DISTINCT mae.num_cte,cont.cuenta, cont.consec,cont.numero, cont.estado, cont.fecha_alta, cont.importe, st.descripcion
				INTO cNumCte,cCuenta, iReg_Firmas,iNumero,cEstadoCheq,dFechaAlta,mImporte,cDescripCheq
				FROM bdicheq:"informix".sc_contch cont
					LEFT OUTER JOIN bdicheq:"informix".sc_contch_hist his ON (cont.cuenta = his.cuenta AND cont.numero = his.numchq AND cont.estado = his.status)
					INNER JOIN bdicheq:"informix".sc_maechq mae       ON (cont.cuenta = mae.cuenta AND cont.empresa = mae.empresa)
					INNER JOIN bdicntchq:"informix".sq_status_chequera st ON(st.status = estado)
				WHERE 					    
						cont.cuenta =      CASE WHEN pCuenta = ""    	THEN cont.cuenta    	ELSE pCuenta END
					AND cont.importe =     CASE WHEN pImporte IS NULL 	THEN cont.importe 		ELSE pImporte END
					AND cont.fecha_alta >= CASE WHEN pFechaIni IS NULL  THEN cont.fecha_alta  	ELSE pFechaIni END
					AND cont.fecha_alta <= CASE WHEN pFechaFin IS NULL  THEN cont.fecha_alta  	ELSE pFechaFin END													
					AND ((cont.estado =    CASE WHEN cEstado = ""    	THEN  cont.estado   	ELSE cEstado END) 
					 OR (cont.estado =     CASE WHEN cEstado2 = ""   	THEN  cont.estado  		ELSE cEstado2 END))				
					AND cont.numero =      CASE WHEN pNumCheque IS NULL THEN  cont.numero 		ELSE pNumCheque END					
					AND mae.num_cte =      CASE WHEN pCliente = ""   	THEN mae.num_cte  		ELSE pCliente END				
					AND st.clave = 2
					AND cont.consec = pConsec
													
				--Obtengo numero de cheque final
				SELECT final  
				INTO iFinal
				FROM bdicntchq:"informix".sq_maechqra
				WHERE cuenta = cCuenta
				AND consec = iReg_Firmas;
				
				RETURN cCodRet,cNumCte,cCuenta, iReg_Firmas,iFinal,iNumero,cDescripCheq,dFechaAlta,mImporte	WITH resume;	
				
			END FOREACH;
		END IF; 				
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '00003';  --No hay informacion.
			
			RETURN cCodRet,cNumCte,cCuenta, iReg_Firmas,iFinal,iNumero,cEstadoCheq,dFechaAlta,mImporte;
			
		END IF;				
	END; 	
END PROCEDURE                                                                                                                                                                                      
 DOCUMENT
'AUTOR: Guadalupe Payan',
'Proyecto: Cuenta Eje Empresarial',
'Solicito: Armando Mercado',
'Descripcion: Obtiene el detalle de las cuentas de cheques segun los parametros ingresados',
'Fecha: 2011/06/20',
'Version: 20110616.1750',
'BD: bdicntchq';

CREATE PROCEDURE "informix".sp_ctamec_conschqactivos( pEmpresa CHAR(3), pCuenta  CHAR(20))
	RETURNING     
			CHAR(5) 		AS 	cCodRett ,   		 -- cCodRet						
			INTEGER 		AS 	iTotalCtaActivass;   -- Total de Cuentas Activas
						
	--DEFINICION DE VARIABLES
	DEFINE  iSqlErr        		INTEGER;	
	--Variables Codigo
	DEFINE cCodRet        		CHAR(5);			
	DEFINE cCuenta        		CHAR(20);			
	DEFINE iTotalCtaActivas	    INTEGER;		
	
	--INICIALIZACION DE VARIABLES	
	LET  iSqlErr                = 0;
	--Variables Codigo
	LET cCodRet	    			= "00000";		
	LET cCuenta	    			= "";			
    LET iTotalCtaActivas        = 0;	
	
	--SET DEBUG FILE TO "/tmp/manuel/sp_ctamec_conschqactivos.out";
    --TRACE ON;
   
	BEGIN
		ON EXCEPTION SET  iSqlErr
		   IF  iSqlErr <> 0 THEN
			  LET cCodRet =  iSqlErr;
			 RETURN cCodRet, iTotalCtaActivas;
		   END IF;
		END EXCEPTION;
		
        set isolation to dirty read;
		SET LOCK MODE TO WAIT 3;
		
		--Valido que se proporcione los dos parametros de entrada.
		IF ((pEmpresa IS NULL OR pEmpresa = '') OR (pCuenta IS NULL OR pCuenta =''))THEN					   		   
		   LET cCodRet = "00001";	--Falta proporcionar algun parametro.		   
		   RETURN cCodRet, iTotalCtaActivas;		   
		END IF; 
		
		--Valido que la cuenta exista en la maestra de cheques.
		SELECT cuenta  
		INTO cCuenta
		FROM bdicheq:"informix".sc_maechq 
		WHERE empresa = pEmpresa
		AND cuenta = pCuenta;
		
		--Validar si existe la cuenta.
		IF cCuenta IS NULL OR cCuenta = '' THEN
			LET cCodRet = "00002";	--La Cuenta no es valida.
			RETURN cCodRet, iTotalCtaActivas;
		END IF;									
		
		--Obtengo total de cuentas activas.		
		SELECT count(cuenta)
		INTO iTotalCtaActivas
		FROM bdicheq:"informix".sc_contch
		WHERE empresa = pEmpresa
		AND cuenta = pCuenta			
		AND estado = 'A';
	     				
		RETURN cCodRet, iTotalCtaActivas;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00003';  --No hay informacion.			
			RETURN cCodRet, iTotalCtaActivas;			
		END IF;				
		
	END; 	
END PROCEDURE                                                                                                                                                                                      
 DOCUMENT
'AUTOR: Guadalupe Payan',
'Proyecto: Cuenta Eje Empresarial',
'Solicito: Armando Mercado',
'Descripcion: Obtiene el total de cuentas activas',
'Fecha: 2011/06/20',
'Version: 20110620.1706',
'BD: bdicntchq';

CREATE PROCEDURE "informix".sp_obtieneparametrochequera (pCodParam SMALLINT)

RETURNING
        CHAR( 5) AS CODRET,     -- CODIGO DE RETORNO
        CHAR(80) AS MENSAJE,    -- MENSAJE DE RETORNO
        CHAR(60) AS VALOR;      -- VALOR DEL PARAMETRO CONSULTADO
       
		 
    --DECLARACION DE VARIABLES
    DEFINE iSqlErr      INTEGER;
    DEFINE cCodRet      CHAR( 5);
    DEFINE cMensaje     CHAR(80);
    DEFINE cValor       CHAR(60);    
			
	--Crea el control de errores
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet, cMensaje, cValor;
		END IF;
	END EXCEPTION; 		
	
	--SET DEBUG FILE TO "/respaldosbd/Armando/sp_ObtieneParametroChequera.out";
	--TRACE ON;
			
    --INICIALIZAR VARIABLES
    LET cCodRet 	= '00000';
    LET cMensaje	= '';    
    LET cValor		= '';    
	LET iSqlErr		=0;
    
    set isolation to dirty read;
    set lock mode to wait 3;
         
	BEGIN
	
	    --Validacion del parametro de entrada		
	    IF pCodParam is null then
			Let cCodRet = '001';
			Let cMensaje = 'Parametro de entrada con valor no valido, verificar';
			RETURN cCodRet, cMensaje, cValor;
	    END IF;

	    --Obtengo el valor del parametro a consultar
		SELECT TRIM(NVL(valor, ''))
		INTO cValor 
		FROM bdicntchq:"informix".sq_param 
		WHERE cod_param = pCodParam; 

		--Valido que se encontro el parametro
		IF cValor IS NULL OR cValor = '' THEN
			Let cCodRet = '002';
			Let cMensaje = 'Parametro consultado no existe';
			RETURN cCodRet, cMensaje, cValor;
		END  IF;
		
		--Retorno valor obtenido
		RETURN cCodRet, cMensaje, cValor;
			
	END
END PROCEDURE
DOCUMENT
'CREACION     : ARMANDO MERCADO FIGUEROA',
'DESCRIPCION  : OBTIENE PARAMETROS BASICOS PARA EL SISTEMA DE CHEQUERAS',
'FECHA    	  : MAYO 2011',
'BASE DE DATOS: BDICNTCHQ',
'VERSION  	  : 20110506';

create procedure "informix".sp_altachequeras_esp( pempresa char(3), --Empresa
                                            pcuenta  char(20), -- Cuenta
                                            pcanal   smallint, --Canal 1 NUEVA, 2 CAT , 3  Internet, 4 CENTRAL
                                            ptipo    Char(2),   -- Tipo de Chequera
                                            pusuario Char(8)    --Usuario
                                            )
       returning     char(5);   -- vcodret

   -- ********************************************************************
   --
   -- Nombre:              sp_altachequeras_esp
   --
   -- Version              1.0.2
   -- Objetivo:            Alta de  chequeras...SIN VALIDACION DE CHEQUES ACTIVOS
   -- Supuestos:           Ninguno
   -- Creado por:          Jorge Arango
   -- Modificado por:      Alejandro Rueda Sanchez
   -- Ultima Modificacion: Febrero  - 2010
   --
   --                      Reingenieria de SPL
   --
   -- ********************************************************************

   -- // Definicion de variables
   DEFINE vcodret         char(5);
   DEFINE vcodreterr      char(5);
   DEFINE vsqlerr         integer;
   DEFINE vno_cheques     smallint;
   DEFINE vconsec         integer;
   DEFINE v_hoy           date;
   DEFINE v_sucursal      char(4);
   DEFINE v_status        char(1);
   DEFINE v_valor         char(1);
   DEFINE v_inicial       INTEGER;
   DEFINE v_final         INTEGER;
   DEFINE a               SMALLINT;
   DEFINE vnumchq         INTEGER;
   DEFINE vnumactivos     INTEGER;
   DEFINE vmaxpermite     INTEGER;
   DEFINE vdummy          char(100);
   DEFINE vdummy1         char(100);
   DEFINE vfecha       	  DATETIME hour TO second;
   DEFINE vfecha1 	  char(8);
   DEFINE vhora           char(10);
   DEFINE vult_chq        INTEGER;
   DEFINE vsdopromant     DECIMAL(12,2);
   DEFINE vsdopromant_parm DECIMAL(12,2);
   DEFINE vfecha_alta 	  DATE;
   DEFINE vfechames  	  DATE;
   DEFINE vproducto  	  CHAR(4);
   DEFINE vval_chequeras  CHAR(1);



   LET vcodret      = " ";
   LET vno_cheques  = " ";
   LET vsqlerr      = 0;
   LET v_status     = " ";
   LET vno_cheques  = 0;
   LET vconsec      = 0;
   LET v_sucursal   = " ";
   LET v_status     = " ";
   LET v_inicial    = 0;
   LET v_final      = 0;
   LET a            = 0;
   LET v_valor      = " ";
   LET vnumchq      = 0;
   LET vmaxpermite  = 0;
   LET vdummy      = " ";
   LET vdummy1     = " ";
   LET vfecha1     = current hour to second;
   --LET vfecha1    = vfecha;
   LET vhora       = vfecha1; --trim(vfecha1[1,2])|":"|trim(vfecha1[4,5]);
   LET vsdopromant_parm = 0;
   LET vproducto   = "0000";
   LET vval_chequeras =  "N";




   --SET DEBUG FILE TO "/tmp/sp_altachequeras.out";
   --TRACE ON;

begin
    on exception set vsqlerr
       IF vsqlerr <> 0 then
          LET vcodret = vsqlerr;
          RETURN vcodret;
       END IF;
    END exception;

   --- Selecciona la fecha del dia.
   SELECT fecha_hoy INTO v_hoy FROM bdicheq:sc_fechas;

   --Validaciones de nulos en parametros de entrada
   IF pempresa = " " or pcuenta = " " or pcanal = 0 then
      LET vcodret = "001";
      call sp_errores( v_hoy, vhora, pcuenta, "001","sp_altachequeras","Error en Parametros de Entrada Nulos",pusuario);
      RETURN vcodret;
   END if

   --- Selecciona el numero de cheques por tipo de chequera.
   If ptipo = " " then
       SELECT valor INTO ptipo
       FROM sq_param
       WHERE cod_param = 2;
   END if

   --- Selecciona el numero de cheques por tipo de chequera.
   SELECT valor INTO vmaxpermite
     FROM sq_param
    WHERE cod_param = 3;
  
   --//Selecciona el monto minimo saldo promedio mes anterior
   SELECT valor INTO vsdopromant_parm
     FROM sq_param
    WHERE cod_param = 21;

   --//Selecciona el numero de cheques del tipo de chequera 
   SELECT no_cheques
     INTO vno_cheques
     FROM bdicntchq:sq_chequera
    WHERE chequera = ptipo;

   IF vno_cheques is null  then
      LET vcodret = "002";
      call sp_errores( v_hoy, vhora, pcuenta, "002","sp_altachequeras","Error al Consultar el Tipo de Chequera",pusuario);
      RETURN vcodret;
   END if

   --- Selecciona el numero maximo de cheques.
   SELECT max(numero)
     INTO vnumchq
     FROM bdicheq:sc_contch
    WHERE empresa = pempresa
      AND cuenta = pcuenta;

   IF vnumchq is null then
      LET vnumchq = 1;
   else
      LET vnumchq =  vnumchq + 1;
   END if

   --validacion de chequera maxima
   SELECT max(consec)
   INTO vconsec
   FROM bdicntchq:sq_maechqra
   WHERE cuenta = pcuenta;

   --Si la chequera es mayor o igual a 1 y el canal es OFI Regreso codigo de error
   If (vconsec >= 1 AND pcanal = 1) or (vconsec is null AND pcanal = 2) then
      LET vcodret = "004";
      call sp_errores( v_hoy, vhora, pcuenta, "004","sp_altachequeras","Error Existen Chequeras Asignadas a esta Cuenta, No Puede Darse de Alta Como Nueva",pusuario);
      RETURN vcodret;
   END if

   IF vconsec is null then
      LET vconsec = 1;
   else
      LET vconsec =  vconsec + 1;
   END if

   --Se trae el numero de sucursal y producto
   SELECT sucursal, status_cta, producto
     INTO v_sucursal, v_status, vproducto
    FROM bdicheq:sc_maechq
   WHERE empresa = pempresa
     AND cuenta = pcuenta;

   --Valida el status de la cuenta
   IF v_status <> "1" THEN
      LET vcodret = "005";
      call sp_errores( v_hoy, vhora, pcuenta, "005","sp_altachequeras","Error la Cuenta no Esta Activa",pusuario);
      RETURN vcodret;
   END IF

   --//Valida sea un producto de chequeras
   SELECT val_chequeras     
     INTO vval_chequeras
     FROM bdicheq:sc_producto
    WHERE empresa = pempresa 
      AND producto = vproducto;

   IF vval_chequeras <> "S" THEN
      LET vcodret = "007";
      call sp_errores( v_hoy, vhora, pcuenta, "007","sp_altachequeras","Error producto no acepta de chequeras",pusuario);
      RETURN vcodret;
   END IF

   --Inicia proceso de actualizacion de Datos

   LET v_inicial = vnumchq;
   LET v_final   = vnumchq + vno_cheques -1;

   If pcanal = 1 then --Apertura nueva


      INSERT INTO bdicntchq:sq_maechqra(empresa, cuenta, consec, inicial, final, fecha_req, fecha_rec, fecha_ent, status, proveedor, sucursal, usuario, origen)
       VALUES(pempresa, pcuenta, vconsec, v_inicial, v_final, v_hoy, " ", " ",
              'S', '000', v_sucursal, pusuario, pcanal);

      -- Inserta requerimiento de chequeras
       FOR a = vnumchq TO v_final

           INSERT INTO bdicheq:sc_contch(empresa, cuenta, numero, estado, fecha_alta, importe, consec)
           VALUES(pempresa, pcuenta, a, "S", v_hoy, 0, vconsec);

       END FOR
         
       --/Actualiza el maestro de cheques con el numero de cheques emitidos
       UPDATE bdicheq:sc_maechq
            SET ult_chq = v_final
          WHERE empresa = pempresa
            AND cuenta = pcuenta;

       LET vcodret = "000";
       RETURN vcodret;

   ELIF pcanal <> 1 then  --CAT 2; Internet 3; Central 4

/*        IF (SELECT COUNT(*) FROM bdicntchq:sq_maechqra WHERE empresa = pempresa AND cuenta = pcuenta AND status IN ('S','P','G','E','N','D')) > 0 THEN
             LET vcodret = "992";
             call sp_errores( v_hoy, vhora, pcuenta, "992","sp_altachequeras","Ya existe una chequera en curso",pusuario);
            RETURN vcodret;
        END IF    
*/
      --//Valida que el saldo promedio mes anterior, sea mayor ó igual al requerido en el parametro 21
      SELECT sdo_prom_mesant, fecha_alta
        INTO vsdopromant, vfecha_alta
        FROM bdicheq:sc_maenoc
       WHERE empresa = pempresa
         AND cuenta = pcuenta;

      --//Si tiene saldo promedio mayor a 0, no es apertura reciente
      IF vsdopromant > 0 THEN
         IF vsdopromant < vsdopromant_parm THEN 
              LET vcodret = "006";
              call sp_errores( v_hoy, vhora, pcuenta, "006","sp_altachequeras","Error el Saldo promedio mes anterior, es menor al necesario", pusuario);
              RETURN vcodret;
         END IF
      ELSE --//Verifica que no sea cuenta reciente para saldo promedio = 0
         EXECUTE PROCEDURE bdicheq:sp_mes_siguiente(vfecha_alta,1,day(vfecha_alta))
                      INTO vdummy, vfechames, vdummy;

         IF v_hoy > vfechames THEN
            IF vsdopromant < vsdopromant_parm THEN 
               LET vcodret = "006";
               call sp_errores( v_hoy, vhora, pcuenta, "006","sp_altachequeras","Error el Saldo promedio mes anterior, es menor al necesario", pusuario);
               RETURN vcodret;
            END IF
         END IF
      END IF

      --- Validacion de Cheque Activo.
       SELECT count(numero)
         INTO vnumactivos
         FROM bdicheq:sc_contch
        WHERE cuenta = pcuenta
          AND empresa = pempresa
          AND estado = "A";

/*       IF vnumactivos > vmaxpermite then
           LET vcodret = "003";
           call sp_errores( v_hoy, vhora, pcuenta, "003","sp_altachequeras","Error el Numero de Cheques Activos, Supera los Permitidos",pusuario);
           RETURN vcodret;
       END if
*/
      INSERT INTO bdicntchq:sq_maechqra(empresa, cuenta, consec, inicial, final, fecha_req, fecha_rec, fecha_ent, status, proveedor, sucursal, usuario, origen)
       VALUES(pempresa, pcuenta, vconsec, v_inicial, v_final, v_hoy, " ", " ",
              'S', '000', v_sucursal, pusuario, pcanal);

      -- Inserta requerimiento de chequeras
       FOR a = vnumchq TO v_final

           INSERT INTO bdicheq:sc_contch(empresa, cuenta, numero, estado, fecha_alta, importe, consec)
           VALUES(pempresa, pcuenta, a, "S", v_hoy, 0, vconsec);

       END FOR

      -- Actualiza el maestro de cuentas de cheques
      LET vult_chq = 0;
      SELECT ult_chq 
        INTO vult_chq
        FROM bdicheq:sc_maechq
       WHERE empresa = pempresa
         AND cuenta = pcuenta;

      IF v_final > vult_chq THEN
         UPDATE bdicheq:sc_maechq
            SET ult_chq = v_final
          WHERE empresa = pempresa
            AND cuenta = pcuenta;
      END IF


       LET vcodret = "000";
       RETURN vcodret;
   END if
end
END procedure;