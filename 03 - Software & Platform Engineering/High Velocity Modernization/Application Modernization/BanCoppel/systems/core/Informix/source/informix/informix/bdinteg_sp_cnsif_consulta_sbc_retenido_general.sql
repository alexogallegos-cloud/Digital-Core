CREATE PROCEDURE "informix".sp_cnsif_consulta_sbc_retenido_general(cID_USUARIOC char(08),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)        AS Cod_Retorno,       
						  CHAR(40)       AS banco,
						  CHAR(4)        AS sucursal,
						  CHAR(10)       AS fecha_alta,
						  DECIMAL(18,2)  AS monto,
						  INTEGER        AS num_cheque,
						  CHAR(16)       AS folio_sucursal,
						  DATE           AS fecha_ret,
						  CHAR(16)       AS folio_sucursal_ret,
						  DECIMAL(18,2)  AS monto_ret,
						  CHAR(40)       AS referencia,
						  INTEGER        AS dias_ret,
						  INTEGER        AS id_consulta;	-- 1 = Movimientos SBC / 2 = Movimientos Retenidos 
							
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;

--VARIABLES PARA EL STORE
DEFINE cCodRetS 		     CHAR(6);
DEFINE cMensaje              CHAR(80);
DEFINE cNombreBanco          CHAR(40);
DEFINE cSucursal             CHAR(4);
DEFINE cFechaAlta            CHAR(10);
DEFINE dMonto                DECIMAL(18,2);
DEFINE dMontoRet			 DECIMAL(18,2);
DEFINE iNumCheq              INTEGER;
DEFINE cFolioSuc             CHAR(16);
DEFINE cFolioSucRet			 CHAR(16);
DEFINE iResultado            INTEGER;
DEFINE dFechaRetenido        DATE;
DEFINE cReferencia           CHAR(40);
DEFINE iDiasRetenido         INTEGER;
DEFINE iContado              INTEGER;
DEFINE cTipCred              CHAR(2);
DEFINE iDiasRestantes		 INTEGER;

DEFINE iCont                 INTEGER;

--INICIALIZA VARIABLES
LET cSucursal                = '';
LET cFechaAlta               = '';
LET cNombreBanco             = '';
LET dMonto                   = 0;
LET dMontoRet                = 0;
LET iNumCheq                 = 0;
LET cFolioSuc                = '';
LET cFolioSucRet             = '';
LET iResultado               = 0;
LET dFechaRetenido           = '';
LET cReferencia              = '';
LET iDiasRetenido            = 0;
LET iContado                 = 0;
LET cTipCred                 = '';
LET iDiasRestantes			 = 0;
LET iCont                    = 0;
LET cCodRetS                 = "";

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN 
			cCodRet, NVL(cNombreBanco,''),NVL(cSucursal,''),
			NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
			NVL(cFolioSucRet,''), NVL(dMontoRet,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), iResultado;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/RVD/2018/salvoBuenCobro/sp_cnsif_consulta_sbc_retenido_general.out";
	--TRACE ON;
	--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_consulta_sbc_retenido_general.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCUENTA  = ''	THEN 
		LET cCodRet = "00045";
		RETURN
			cCodRet, NVL(cNombreBanco,''),NVL(cSucursal,''),
			NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
			NVL(cFolioSucRet,''), NVL(dMontoRet,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), iResultado;
    END IF

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
		RETURN
			cCodRet, NVL(cNombreBanco,''),NVL(cSucursal,''),
			NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
			NVL(cFolioSucRet,''), NVL(dMontoRet,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), iResultado;				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN
                cCodRet, NVL(cNombreBanco,''),NVL(cSucursal,''),
                NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
                NVL(cFolioSucRet,''), NVL(dMontoRet,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), iResultado;
            END IF;
    END IF;  
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
		RETURN 
			cCodRet, NVL(cNombreBanco,''),NVL(cSucursal,''),
			NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
			NVL(cFolioSucRet,''), NVL(dMontoRet,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), iResultado;
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
		cCodRet, NVL(cNombreBanco,''),NVL(cSucursal,''),
		NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
		NVL(cFolioSucRet,''), NVL(dMontoRet,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), iResultado;
	END IF;
	
	IF pNumRegistro = 0 THEN
		DELETE FROM si_temposbcretenido WHERE ejecutivosif= cID_USUARIOC;
		--SET ISOLATION TO DIRTY READ;		
		FOREACH
		
			EXECUTE PROCEDURE bdicred:sp_consulta_sbc_retenido_general('001',cNUMCUENTA)
			INTO
			cCodRetS,cMensaje,iResultado, cNombreBanco, cSucursal, cFechaAlta, dMonto, iNumCheq, cFolioSuc, dFechaRetenido,
            cFolioSucRet, dMontoRet, cReferencia, iDiasRetenido, iDiasRestantes
			
			LET cCodRet = SUBSTR(cCodRetS,2,6);
			
			IF cCodRet != '00000' THEN		
                IF cCodRet='00002' THEN
                    LET cCodRet ='00017';
                END IF;
				RETURN  
					cCodRet, NVL(cNombreBanco,''),NVL(cSucursal,''),
					NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
					NVL(cFolioSucRet,''), NVL(dMontoRet,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), iResultado;			   
			END IF;
				
			INSERT INTO si_temposbcretenido(cod_ret,banco,sucursal,fecha_alta,importe,num_cheque,folio_sucursal,fecha_ret,
			folio_sucursal_ret,importe_ret,referencia,dias_ret,cuenta,ejecutivosif,id_consulta) 
			VALUES(cCodRetS, cNombreBanco, cSucursal, cFechaAlta, dMonto, iNumCheq, cFolioSuc, dFechaRetenido,
                   cFolioSucRet, dMontoRet, cReferencia, iDiasRetenido,cNUMCUENTA, cID_USUARIOC, iResultado);

		END FOREACH;
	END IF;
	
	--SET ISOLATION TO DIRTY READ;
	FOREACH
        SELECT SKIP pNumRegistro FIRST pRecuperacion
        cod_ret,banco,sucursal,fecha_alta,importe,num_cheque,folio_sucursal,fecha_ret,
        folio_sucursal_ret,importe_ret,referencia,dias_ret,id_consulta
        INTO
        cCodRetS, cNombreBanco, cSucursal, cFechaAlta, dMonto, iNumCheq, cFolioSuc, dFechaRetenido,
        cFolioSucRet, dMontoRet, cReferencia, iDiasRetenido, iResultado
        FROM si_temposbcretenido
        WHERE cuenta = cNUMCUENTA AND ejecutivosif= cID_USUARIOC ORDER BY fecha_alta DESC

        LET cCodRet = SUBSTR(cCodRetS,2,6);

        LET iCont=iCont + 1;

        RETURN 
                cCodRet, NVL(cNombreBanco,''),NVL(cSucursal,''),
                NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
                NVL(cFolioSucRet,''), NVL(dMontoRet,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), iResultado  WITH RESUME;
			
	END FOREACH;
	
	IF iCont = 0 THEN
		DELETE FROM si_temposbcretenido WHERE ejecutivosif= cID_USUARIOC;
		LET cCodRet = 1001; 
		RETURN  
			cCodRet, NVL(cNombreBanco,''),NVL(cSucursal,''),
			NVL(cFechaAlta,''), NVL(dMonto,0), NVL(iNumCheq,0), NVL(cFolioSuc,''), NVL(dFechaRetenido,DATE(1)),
			NVL(cFolioSucRet,''), NVL(dMontoRet,0), trim(NVL(cReferencia,'')), NVL(iDiasRetenido,0), iResultado;
	END IF; 	

END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información del SBC-Retenido asociado a una Cuenta de Crédito,  referente a Salvo Buen Cobro y Movimientos Retenidos. ",
"El SP obtendrá la información desde la Base de Datos central de Informix, enviando como parámetro el  No. de Cuenta.",
"FECHA : 06-03-2012",
'AUTOR: L. Montserrat León Amador',
'FECHA 30/11/2018',
'DESCRIPCION: Se modifica SP para agregar nuevo retorno, mediante el cual se pueda hacer la separación de Movimientos correspondientes a id_consulta = 1 SBC y id_consulta = 2 Retenidos.',
'AUTOR: L. Montserrat León Amador',
'FECHA 06/12/2018',
'DESCRIPCION: Se realizan modificaciones solicitadas: SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;.',
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_cancela_autor_privacidad(pempresa CHAR(3), pcliente CHAR(20))
   returning char(5) AS codret;

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);

LET iSqlErr = 0;
LET cCodRet = '00000';
LET cNumCte = '';
--SET DEBUG FILE TO "/tmp/sp_cancela_autor_privacidad.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF iSqlErr <> 0 THEN
            RETURN iSqlErr;
        END IF;
    END EXCEPTION;

	lET pempresa = NVL(TRIM(pEmpresa),'');
	LET pcliente = NVL(TRIM(pcliente),'');
	
    IF pempresa = '' OR  pcliente = ''THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

        SELECT FIRST 1 numcte
        INTO cNumCte
        FROM bdinteg:si_cliente
        WHERE numcte IN (SELECT num_cte FROM bdicheq:sc_maechq WHERE num_cte = pcliente AND empresa = pEmpresa )
        OR numcte IN    (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = pEmpresa AND num_cte = pcliente)
        OR numcte IN    (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = pEmpresa AND numcte = pcliente)
        OR numcte IN    (SELECT numcte FROM bdisolic:ss_solicitudes WHERE empresa = pEmpresa AND numcte = pcliente);

        IF cNumCte = '' OR cNumCte IS NULL THEN
            UPDATE si_cliente SET tipo_cliente = '2' WHERE empresa = pEmpresa AND numcte = pcliente;
            LET cCodRet = '00000';
        ELSE
            LET cCodRet = '00001';
            RETURN cCodRet;
        END IF;

        SELECT FIRST 1 numcte
        INTO cNumCte
        FROM bdinteg:si_cliente
        WHERE numcte IN (SELECT num_cte FROM bdicheq:sc_maechq WHERE num_cte = pcliente )
        OR numcte IN    (SELECT num_cte FROM bdinvers:sv_maeinv WHERE empresa = pEmpresa AND num_cte = pcliente)
        OR numcte IN    (SELECT numcte FROM bdicred:sd_maecred WHERE empresa = pEmpresa AND numcte = pcliente)
        OR numcte IN    (SELECT numcte FROM bdisolic:ss_solicitudes WHERE empresa = pEmpresa AND numcte = pcliente)
        OR numcte IN    (SELECT numcte FROM bdicheq:sc_firmantes WHERE empresa = pEmpresa AND numcte = pcliente);

        IF cNumCte = '' OR cNumCte IS NULL THEN		
                DELETE FROM si_cte_huella WHERE numcte= pcliente AND estado = 'A' AND secuencia > 0;
                --DELETE FROM si_cte_rostro WHERE numcte= pcliente AND estado = 'A';
				UPDATE  si_cliente set tpo_biometria = '0'  WHERE empresa = '001' AND numcte= pcliente;            			
        END IF;

RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se optimiza procedimiento.',
'AUTOR: Cristian Valentina Aguilar.',
'BD: bdirostros';

CREATE PROCEDURE "informix".sp_cancela_autor_privacidad_altaunica(pempresa CHAR(3), pcliente CHAR(20))
   returning char(5) AS codret;

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);

LET iSqlErr = 0;
LET cCodRet = '00000';
LET cNumCte = '';
--SET DEBUG FILE TO "/tmp/sp_cancela_autor_privacidad_altaunica.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF iSqlErr <> 0 THEN
            RETURN iSqlErr;
        END IF;
    END EXCEPTION;

	lET pempresa = NVL(TRIM(pEmpresa),'');
	LET pcliente = NVL(TRIM(pcliente),'');
	
    IF pempresa = '' OR  pcliente = ''THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

        SELECT FIRST 1 numcte
        INTO cNumCte
        FROM "informix".si_cliente
        WHERE numcte IN (SELECT num_cte FROM bdicheq:"informix".sc_maechq WHERE num_cte = pcliente AND empresa = pEmpresa )
        OR numcte IN    (SELECT num_cte FROM bdinvers:"informix".sv_maeinv WHERE empresa = pEmpresa AND num_cte = pcliente)
        OR numcte IN    (SELECT numcte FROM bdicred:"informix".sd_maecred WHERE empresa = pEmpresa AND numcte = pcliente)
        OR numcte IN    (SELECT numcte FROM bdisolic:"informix".ss_solicitudes WHERE empresa = pEmpresa AND numcte = pcliente);

        IF cNumCte = '' OR cNumCte IS NULL THEN
            UPDATE "informix".si_cliente SET tipo_cliente = '2' WHERE empresa = pEmpresa AND numcte = pcliente;
            LET cCodRet = '00000';
        ELSE
            LET cCodRet = '00001';
            RETURN cCodRet;
        END IF;

        SELECT FIRST 1 numcte
        INTO cNumCte
        FROM "informix".si_cliente
        WHERE numcte IN (SELECT num_cte FROM bdicheq:"informix".sc_maechq WHERE num_cte = pcliente )
        OR numcte IN    (SELECT num_cte FROM bdinvers:"informix".sv_maeinv WHERE empresa = pEmpresa AND num_cte = pcliente)
        OR numcte IN    (SELECT numcte FROM bdicred:"informix".sd_maecred WHERE empresa = pEmpresa AND numcte = pcliente)
        OR numcte IN    (SELECT numcte FROM bdisolic:"informix".ss_solicitudes WHERE empresa = pEmpresa AND numcte = pcliente)
        OR numcte IN    (SELECT numcte FROM bdicheq:"informix".sc_firmantes WHERE empresa = pEmpresa AND numcte = pcliente);

        IF cNumCte = '' OR cNumCte IS NULL THEN		
                DELETE FROM "informix".si_cte_huella WHERE numcte= pcliente AND estado = 'A' AND secuencia > 0;
                --DELETE FROM si_cte_rostro WHERE numcte= pcliente AND estado = 'A';
				UPDATE "informix".si_cliente set tpo_biometria = '0'  WHERE empresa = '001' AND numcte= pcliente;
				
				LET cCodRet = '00002';
        END IF;

RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se optimiza procedimiento.',
'AUTOR: Paul Antonio Garcia Gastelum.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_obt_boleto_cte(pPerido char(2), pDato char(16),pRegistros INTEGER)

        RETURNING char(5), char(60),char(16),char(40),char(20),char(1);
	
       DEFINE vcodret    char(5);
	   DEFINE sql_err Integer;
       DEFINE vNomEnmasc CHAR(60);
       DEFINE vCtaEnmasc CHAR(16);
	   DEFINE vNomPro    CHAR(40);
	   DEFINE vBoleto    CHAR(20);
	   DEFINE vNumCte    CHAR(9);
	   DEFINE vBoletoGan Char(1); 
	   DEFINE n1Cliente    CHAR(26);
	   DEFINE n2Cliente    CHAR(26);
	   DEFINE apCliente    CHAR(26);
	   DEFINE amCliente    CHAR(26);
	   

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vNomEnmasc, vCtaEnmasc, vNomPro, vBoleto, vBoletoGan;
       END IF;
END EXCEPTION; 

	-- Actividad: Obtener boletos de un perido por cliente o nÃÂºmero de tarjeta
	-- Fecha:  22/02/2018

	--     Campo1- vCodRet            00000                    CHAR(5);   
	--     Campo2- vNomEnmasc         [A******** V******  ]    CHAR(60);
    --     Campo3- vCtaEnmasc         [**** ***1234]           CHAR(11);
    --     Campo4- vNomPro            [Cuenta Efectiva]        CHAR(40);
    --     Campo5- vBoleto            1 a 99999999999999999999 CHAR(20);
	--	   Campo6- vBoletoGan         0 ÃÂ³ 1                    Char(1);
	         
	-- DefiniciÃÂ³n de variables

LET vcodret    = '00000';
LET vNomEnmasc = "";
LET vCtaEnmasc = "";
LET vNomPro    = "";
LET vBoleto    = "";
LET vBoletoGan = "";
LET vNumCte = "";
LET n1Cliente = "";
LET n2Cliente = "";
LET apCliente = "";
LET amCliente = "";

BEGIN

--SET DEBUG FILE TO "/home/informix/raldana/sp_obt_boleto_cte.out";
--TRACE ON;

set isolation to dirty read;
set lock mode to wait 5;
 
	
	IF (pPerido) = 01 THEN
	    LET pPerido = 12;
	ELIF (pPerido) = 02 THEN
	    LET pPerido = 01;
	ELIF (pPerido) = 03 THEN
	    LET pPerido = 02;	
	ELIF (pPerido) = 04 THEN
	    LET pPerido = 03;			
	ELIF (pPerido) = 05 THEN
	    LET pPerido = 04;					
	ELIF (pPerido) = 06 THEN
	    LET pPerido = 05;							
	ELIF (pPerido) = 07 THEN
	    LET pPerido = 06;									
	ELIF (pPerido) = 08 THEN
	    LET pPerido = 07;											
	ELIF (pPerido) = 09 THEN
	    LET pPerido = 08;													
	ELIF (pPerido) = 10 THEN
	    LET pPerido = 09;															
	ELIF (pPerido) = 11 THEN
	    LET pPerido = 10;																	
	ELIF (pPerido) = 12 THEN
	    LET pPerido = 11;																			
	END IF;
		
			IF LENGTH(trim(pDato)) =9 THEN	
				SELECT LIMIT 1 num_cliente INTO vNumCte
				 FROM bdinteg@stag_ids1170:si_sorteo_efectivo_his a				 
				 WHERE num_cliente = trim(pDato) 
				 AND month(fecha_carga) = pPerido;
			END IF;
			 IF LENGTH(trim(pDato)) =11 THEN	
				SELECT LIMIT 1 num_cliente INTO vNumCte
				 FROM bdinteg@stag_ids1170:si_sorteo_efectivo_his a				 
				 WHERE  num_cuenta = trim(pDato) 
				 AND month(fecha_carga) = pPerido;
			END IF;	 
			IF LENGTH(trim(pDato)) =16 THEN	
				SELECT LIMIT 1 num_cliente INTO vNumCte
				 FROM bdinteg@stag_ids1170:si_sorteo_efectivo_his a				 
				 WHERE  num_tarjeta = trim(pDato) 
				 AND month(fecha_carga) = pPerido;
				 
			END IF;
			
			IF(vNumCte <> "")THEN
				SELECT  nombre1,nombre2,apell_paterno,apell_materno
				INTO n1Cliente, n2Cliente, apCliente, amCliente
				FROM bdinteg:si_cliente 
				WHERE numcte = vNumCte;

				IF(n1Cliente <> "") THEN
					 LET n1Cliente = RPAD(SUBSTR( trim(n1Cliente), 1,1)      , LENGTH(trim(n1Cliente)), '*') ;
				
				END IF;	
				
				IF(n2Cliente <> "") THEN
					LET n2Cliente = RPAD(SUBSTR( trim(n2Cliente), 1,1)      , LENGTH(trim(n2Cliente)), '*') ;
				ELSE 
					LET n2Cliente 	= "";
				END IF;				
				
				IF(apCliente <> "") THEN
					LET apCliente = RPAD(SUBSTR( trim(apCliente), 1,1)      , LENGTH(trim(apCliente)), '*') ;
					
				END IF;				
				
				IF(amCliente <> "") THEN
					LET amCliente = RPAD(SUBSTR( trim(amCliente), 1,1)      , LENGTH(trim(amCliente)), '*') ;
				ELSE
					LET amCliente ="";
				END IF;				
				
				LET vNomEnmasc = TRIM(n1Cliente) || ' '|| TRIM(n2Cliente)|| ' '||TRIM(apCliente)|| ' '|| TRIM(amCliente);
					 
				FOREACH			   
					SELECT SKIP pRegistros FIRST 10				        
						LPAD(SUBSTR( trim(a.num_tarjeta), 14,3), LENGTH(trim(a.num_tarjeta)), '*'),
						--'PRODUCTO BANCOPPEL',				  
						LPAD(SUBSTR( trim(a.num_cuenta), 8,4), LENGTH(trim(a.num_cuenta)), '*'),
						To_Char(a.num_boleto, '&&&&&&&&&&&&&&&&&&&&'),		   
						NVL(generico2,0)
					INTO vCtaEnmasc,vNomPro,vBoleto,vBoletoGan				
					FROM bdinteg@stag_ids1170:si_sorteo_efectivo_his a					
					WHERE a.num_cliente = vNumCte
					AND MONTH(a.fecha_carga) = pPerido

					RETURN vcodret, vNomEnmasc, vCtaEnmasc, vNomPro, vBoleto, vBoletoGan WITH RESUME;
				End FOREACH;
				
			ELSE 
				LET vcodret='00001';
			  RETURN vcodret, vNomEnmasc, vCtaEnmasc, vNomPro, vBoleto, vBoletoGan;		
			END IF;
END;

END PROCEDURE;