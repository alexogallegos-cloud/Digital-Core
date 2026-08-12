CREATE PROCEDURE "informix".sp_validatarjetaper(pNumCte varchar(13), pNumCuenta varchar(13), pEstatusSolicitud CHAR (1))
   RETURNING CHAR(5),CHAR(16),CHAR(50),CHAR(6);

   DEFINE cCodRet             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);

   DEFINE cDescripcion 	  CHAR(50);
   DEFINE cIdSolicitud 	  CHAR(6);
   DEFINE cNumtarjeta     CHAR(16);

   LET cCodRet 		      = '00001';
   LET cDescripcion	      = 'No existe tarjeta';
   LET cIdSolicitud	      = '000000';
   LET cNumtarjeta        = '0';
BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		--SET DEBUG FILE TO "VerifCte1.err";
		--TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cCodRet = sql_err;
		RETURN cCodRet,cNumtarjeta, cDescripcion, cIdSolicitud;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	--SET DEBUG FILE TO "/tmp/combinacion/SP_VALIDASOLPER.out";
	--TRACE ON;

	SELECT max(idsolicitud) INTO cIdSolicitud FROM intercard: solicitudtarjeta WHERE numcliente = pNumCte AND numcuenta = pNumCuenta AND estatusproceso = pEstatusSolicitud;

    SELECT numtarjeta INTO cNumtarjeta FROM intercard:detalle_maquila WHERE idsolicitud in (
    SELECT idsolicitud FROM  intercard:solicitudtarjeta WHERE idsolicitud=cIdSolicitud AND  numcliente = pNumCte  AND numcuenta =pNumCuenta);

    
	IF cNumtarjeta  <> "" THEN
		LET cCodRet = "00000";
		LET cDescripcion = "Tarjeta Valida";
	ELSE
		LET cCodRet = "00002";
	END IF;

	RETURN cCodRet,CNumtarjeta, cDescripcion, cIdSolicitud;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Jose Miguel Guicochea',
'FECHA: 03/10/2016',
'BD: bdicheq',
'Objetivo: Se crea procedimiento para validar que la tarjeta deslizada corresponda a la solicitud';

CREATE PROCEDURE "informix".consctesfirxnumctaper(pEmpresa CHAR(3), pNumeroCuenta CHAR(20), pNumeroCliente CHAR(20))
	-- DATOS A REGRESAR --
	RETURNING
	CHAR(5),     -- Codigo de retorno
	CHAR(20),    -- # Cliente
	CHAR(26),    -- Apellido paterno
	CHAR(26),    -- Apellido materno
	CHAR(26),    -- Nombre 1
	CHAR(26),    -- Nombre 2
	CHAR(13),    -- RFC
	CHAR(16),    -- # Tarjeta
	DATE,    	 --	Expiracion
	CHAR(4),     -- Producto tarjeta
	MONEY(14,2), -- Limite de retiro maximo por mes
	CHAR(1),     -- Status tarjeta
	CHAR(8),     -- Tipo de cliente
	CHAR(10),    -- Fecha de Nacimiento
	CHAR(4),     -- Producto de la cuenta
	CHAR(2);     -- Parentesco

	-- VARIABLES --
	DEFINE vCodRet  	CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE vTipCte  	CHAR(1);
	DEFINE vNumCte		CHAR(20);
	DEFINE vApePat  	CHAR(26);
	DEFINE vApeMat  	CHAR(26);
	DEFINE vNombre1 	CHAR(26);
	DEFINE vNombre2 	CHAR(26);
	DEFINE vRFC     	CHAR(13);
	DEFINE vNumTarj 	CHAR(16);
	DEFINE Vexpiracion  DATE;
	DEFINE Vprodtarjeta CHAR(4);
	DEFINE vLimTar  	MONEY(14,2);
	DEFINE vTipoCte 	CHAR(8);
	DEFINE vStatTjt 	CHAR(1);
	DEFINE vFechaNac 	CHAR(10);
	DEFINE vProductoCuenta CHAR(4);
	DEFINE vCantReg 	SMALLINT;
	DEFINE vParentesco 	CHAR(2);	
   --	DEFINE vFechaNac2 	DATE;
	-- INICIALIZACION DE VARIABLES --
	LET vCodRet  		= "000";
	LET iSqlErr   		= 0;
	LET vCantReg 		= 0;
	LET vTipCte 		= "";
	LET vNumCte 		= "";
	LET vApePat 		= "";
	LET vApeMat 		= "";
	LET vNombre1 		= "";
	LET vNombre2 		= "";
	LET vRFC 			= "";
	LET vNumTarj 		= "";
	LET Vexpiracion 	= "";
	LET Vprodtarjeta 	= "";
	LET vLimTar 		= "";
	LET vTipoCte 		= "";
	LET vStatTjt 		= "";
	LET vFechaNac 		= "";
	LET vProductoCuenta = "";
	LET vParentesco 	= "";	
  --  LET vFechaNac2 = "";

	--SET DEBUG FILE TO "/respaldosbd/ConsCtesFirXnumCtaPer.out";
	--TRACE ON;
	
	BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET vCodRet = iSqlErr;
				RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
						Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;


		-- CICLO PARA OBTENER A LOS FIRMANTES Y LAS TARJETAS DE DEBITO EN CASO DE QUE TENGAN --

		FOREACH
		
			SELECT DISTINCT si_cte.numcte, 
				si_cte.apell_paterno, si_cte.apell_materno, si_cte.nombre1, si_cte.nombre2, si_cte.rfc, 
				sc_fir.secuencia As tipo_cliente, si_pf.fecha_nac, sc_mcq.producto, sc_fir.parentesco
			INTO
                
				vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vTipoCte, vFechaNac, vProductoCuenta, vParentesco
			FROM
				bdicheq:"informix".sc_maechq sc_mcq,
				bdicheq:"informix".sc_firmantes AS sc_fir,
				bdinteg:"informix".si_cliente AS si_cte,
				bdinteg:"informix".si_ctepf AS si_pf
			WHERE sc_fir.empresa =  pEmpresa 
			  AND sc_fir.cuenta =  pNumeroCuenta 
			  -- AND sc_fir.numcte != pNumeroCliente 
			  AND sc_fir.numcte = si_cte.numcte 
			  AND si_cte.empresa = pEmpresa 
			  AND sc_fir.numcte = si_pf.numcte
			  AND sc_mcq.empresa = pEmpresa 
			  AND sc_mcq.cuenta = pNumeroCuenta
			  ORDER BY sc_fir.secuencia ASC
				
			IF vTipoCte = '1' THEN
				LET vTipoCte = 'Titular';
			ELSE
				LET vTipoCte = 'Firmante';
			END IF;

			-- OBTENER LA TARJETA DEL FIRMANTE --

			SELECT DISTINCT sc_tjt.expiracion, sc_tjt.prodtarjeta, sc_tjt.num_tarjeta, sc_tjt.limite_aut, sc_tjt.status_tar
			INTO
				Vexpiracion, Vprodtarjeta, vNumTarj, vLimTar, vStatTjt
			FROM
				bdicheq:"informix".sc_tarjeta AS sc_tjt
			WHERE sc_tjt.empresa = pEmpresa 
			  AND sc_tjt.cuenta = pNumeroCuenta
			  AND sc_tjt.numcte = vNumCte
			  --AND sc_tjt.tipo_tarjeta = 'A'
			  --AND sc_tjt.status_tar = 'A' 
			  AND sc_tjt.secuencia = (
					SELECT MAX(secuencia) 
					  FROM bdicheq:sc_tarjeta 
					 WHERE sc_tjt.empresa = empresa 
					   AND sc_tjt.cuenta = cuenta 
					   AND sc_tjt.numcte = numcte );
					   --AND sc_tjt.tipo_tarjeta = 'A');

			IF vNumTarj IS NULL THEN
				LET vNumTarj = "Sin tarjeta";
				LET vLimTar = 0;
				LET vStatTjt = "";
			END IF
          --  LET vFechaNac= vFechaNac;
           -- LET vFechaNac = YEAR(vFechaNac) || '-' || LPAD ( MONTH(vFechaNac-2), 2, '0') || '-' || LPAD ( DAY (vFechaNac-2), 2, '0');
			LET vCantReg = vCantReg + 1;
			RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
					Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco WITH RESUME;
		
		END FOREACH;

		IF vCantReg = 0 THEN
			LET vCodRet  	 = "000";
			LET vNumCte  	 = "";
			LET vApePat  	 = "";
			LET vApeMat  	 = "";
			LET vNombre1 	 = "";
			LET vNombre2 	 = "";
			LET vRFC     	 = "";
			LET vNumTarj 	 = "";
			LET Vexpiracion  = "";
			LET Vprodtarjeta = "";
			LET vLimTar  	 = 0;
			LET vStatTjt 	 = "";
			LET vTipoCte 	 = "";
			LET vFechaNac 	 = "";
			LET vParentesco	 = "";
           -- LET vFechaNac=vFechaNac2;
            LET vFechaNac = YEAR(vFechaNac) || '-' || LPAD ( MONTH(vFechaNac-2), 2, '0') || '-' || LPAD ( DAY (vFechaNac-2), 2, '0');
			RETURN vCodRet, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vRFC, vNumTarj, Vexpiracion, 
					Vprodtarjeta, vLimTar, vStatTjt, vTipoCte, vFechaNac, vProductoCuenta, vParentesco;
		
		END IF;
	
	END 
	
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se agrega filtro para obtener datos de tajertas unicamente Activas',
'EJECUTADO O LLAMADO POR: AperTP.exe',
'AUTOR : Elmer LÃÂ³pez',
'FECHA : 12/Octubre/2016',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".sp_actualiza_ctasconsbg( pNumCredito CHAR(20), pTramaResp CHAR(500) ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet  CHAR(5);
    DEFINE cIsamErr CHAR(5);
    DEFINE cDescErr CHAR(50);
    DEFINE iSqlErr  INTEGER;
    DEFINE iSamErr  INTEGER;
    DEFINE cDesErr  CHAR(50);
    DEFINE iExiste  SMALLINT;
    DEFINE cCodResp CHAR(5);
    
    LET cCodRet  = '000';
    LET cIsamErr = '';
    LET cDescErr = '';
    LET iSqlErr	 = 0;
    LET iSamErr  = 0;
    LET cDesErr  = '';
    LET iExiste  = 0;
    LET cCodResp = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_actualiza_ctasconsbg.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cIsamErr = iSamErr;
            LET cDescErr = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_actualiza_ctasconsbg.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pNumCredito is null OR pNumCredito = '' ) OR
       ( pTramaResp is null OR pTramaResp = '' ) THEN
        LET cCodRet = '110';
        RETURN cCodRet;
    END IF;
    
    SELECT COUNT(*)
      INTO iExiste
      FROM sc_limite_sbg
     WHERE num_credito = pNumCredito;
     
    IF iExiste = 0 THEN
        LET cCodRet = '100';
        RETURN cCodRet;
    ELSE
        LET cCodResp = SUBSTR(pTramaResp, 1, 5);
    
        IF cCodResp = '00000' THEN
            UPDATE sc_limite_sbg
               SET imp_acum_sbg = 0.00
             WHERE num_credito = pNumCredito;
        END IF;
        
        INSERT INTO sc_limite_sbg_resp
        ( fecha_hora, num_credito, trama_resp )
        VALUES
        ( current, pNumCredito, pTramaResp );
    END IF;
    
    END;
    
    RETURN cCodRet;
    
END PROCEDURE;