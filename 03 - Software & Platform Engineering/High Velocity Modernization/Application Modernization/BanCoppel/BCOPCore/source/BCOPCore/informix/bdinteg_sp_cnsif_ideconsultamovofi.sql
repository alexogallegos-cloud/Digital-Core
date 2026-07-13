CREATE PROCEDURE "informix".sp_cnsif_ideconsultamovofi(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20),cPERIODO CHAR(06),pNumRegistro INTEGER,pRecuperacion INTEGER)
							
			returning   CHAR(5)     AS Cod_Retorno,
						DATE        AS Fecha,	      
						CHAR(20)    AS Cuenta,          
						CHAR(04)    AS Sucursal,
						MONEY(16,2) AS Importe,
                        CHAR(2)     AS SistemaCuenta;	      

							
DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;		

DEFINE v_cod_ret    CHAR(5);
DEFINE dFecha       DATE;
DEFINE cNumCuenta   CHAR(20);
DEFINE cSucursal    CHAR(04);
DEFINE mImporte     MONEY(16,2);
DEFINE mTotal       MONEY(16,2);
DEFINE cSistemaC    CHAR(2);
--DEFINE mTotalAux    MONEY(16,2);

--PARA PAGINACION
DEFINE iCont                INTEGER;

LET  v_cod_ret    = "00000";
LET dFecha        = "";
LET cNumCuenta    = "";
LET cSucursal     = "";
LET mImporte      = 0;
LET mTotal        = 0;
--LET mTotalAux     = 0;

--inicializando variables
LET  iexiste 		 = 0;
LET cCodRet 		 = "00000";
LET iSql_err 		 = 0 ;

LET iCont            = 0;
LET cSistemaC        ='00';
                              

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,dFecha,cNumCuenta,cSucursal,mImporte,cSistemaC;						
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_ideconsultamovofi_2.out";
	--TRACE ON;

	IF 	cID_USUARIOC  = '' 	OR
		cID_FUNCIONC  = '' 	OR
		cNUMCLIENTE   = ''	OR
		cPERIODO      = ''  THEN
		LET cCodRet = "00060";
		RETURN cCodRet,dFecha,cNumCuenta,cSucursal,mImporte,cSistemaC;
	END IF;	

    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet,dFecha,cNumCuenta,cSucursal,mImporte,cSistemaC;				
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,dFecha,cNumCuenta,cSucursal,mImporte,cSistemaC;
        END IF;
    END IF;  
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'23','2')
	INTO
	cCodRet;
	IF (cCodRet != '00000')  THEN
	    RETURN cCodRet,dFecha,cNumCuenta,cSucursal,mImporte,cSistemaC;
	END IF;
	-- TERMINA VALIDACION	
	FOREACH
		SELECT NVL(COUNT(num_cte),0) AS CONT INTO iexiste FROM bdilide:sl_movefec WHERE num_cte  = cNUMCLIENTE AND aniomes = cPERIODO
		UNION
		SELECT NVL(COUNT(num_cte),0) AS CONT FROM  bdilide:sl_movefec_his WHERE num_cte  = cNUMCLIENTE AND aniomes = cPERIODO ORDER BY CONT DESC
	END FOREACH;

	IF iexiste  = 0 THEN 
		LET cCodRet = "00061";
		RETURN cCodRet,dFecha,cNumCuenta,cSucursal,mImporte,cSistemaC;
	END IF;
	
	IF pNumRegistro = 0 THEN
	
		DELETE {+INDEX (bdinteg:si_tempomovofi idx_tempopermovofi)} FROM si_tempomovofi WHERE num_cte  = cNUMCLIENTE AND aniomes = cPERIODO AND ejecutivosif= cID_USUARIOC;
		SET ISOLATION TO DIRTY READ;		
		FOREACH
		
		    EXECUTE PROCEDURE bdilide:sp_ideconsultamovofi (cNUMCLIENTE, cPERIODO,0)
			INTO
			v_cod_ret, dFecha,cNumCuenta,cSucursal,mImporte	
			
			IF LENGTH(v_cod_ret) = 3 THEN
				LET  cCodRet = '00' || v_cod_ret;
			ELIF LENGTH(v_cod_ret) = 5 THEN
				LET  cCodRet = v_cod_ret;
			END IF
			
			IF cCodRet != '00000' THEN
				RETURN 	cCodRet,dFecha,cNumCuenta,cSucursal,mImporte,cSistemaC;
			END IF

			
			INSERT INTO si_tempomovofi(cod_ret,fecha,numcuenta,sucursal,importe,aniomes,num_cte, ejecutivosif)
			VALUES(v_cod_ret,dFecha,cNumCuenta,cSucursal,mImporte,cPERIODO,cNUMCLIENTE, cID_USUARIOC);		
			
		END FOREACH
		
	
	END IF
	
	SET ISOLATION TO DIRTY READ;
	
	FOREACH
	
		SELECT {+INDEX (bdinteg:si_tempomovofi idx_tempopermovofi)} SKIP pNumRegistro FIRST pRecuperacion
		cod_ret,fecha,numcuenta,sucursal,importe
		INTO
		v_cod_ret, dFecha,cNumCuenta,cSucursal,mImporte
		FROM si_tempomovofi
		WHERE num_cte  = cNUMCLIENTE
		AND aniomes = cPERIODO AND ejecutivosif= cID_USUARIOC ORDER BY fecha
		
		IF LENGTH(v_cod_ret) = 3 THEN
			LET  cCodRet = '00' || v_cod_ret;
		ELIF LENGTH(v_cod_ret) = 5 THEN
			LET  cCodRet = v_cod_ret;
		END IF
		
		LET iCont = iCont + 1;

        IF SUBSTR(cNumCuenta,1,1)='3' THEN
            LET cSistemaC='03';
        ELIF SUBSTR(cNumCuenta,1,1)='6' THEN
            LET cSistemaC='06';
        ELSE
            LET cSistemaC='01';
        END IF;
		
		RETURN 	cCodRet,dFecha,cNumCuenta,cSucursal,mImporte,cSistemaC WITH Resume;
		
	END FOREACH
	
	IF iCont = 0 THEN
		DELETE {+INDEX (bdinteg:si_tempomovofi idx_tempopermovofi)} FROM si_tempomovofi WHERE num_cte = cNUMCLIENTE AND aniomes = cPERIODO AND ejecutivosif= cID_USUARIOC;
		LET cCodRet = 1001; 
		RETURN 	cCodRet,dFecha,cNumCuenta,cSucursal,mImporte,cSistemaC;
	END IF; 
	
END
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información del Detalle de Movimientos en Efectivo para la consulta de Recaudaciones LIDE. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el  Número de Cliente.",
"FECHA : 16-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_valida_servicio_ctebm(pNumCliente VARCHAR(9))
RETURNING CHAR (5), VARCHAR(15), SMALLINT;
	--*********************************************************************************************************************************
	-- Objetivo: Valida que el cliente disponga del servicio de banca móvil y obtiene los datos numero celular y estatus del sevicio. 
	-- Autor: Francisco Rodrìguez
	-- Solicito: José de Jesús Nevarez
	-- Fecha: 13/09/2011
	--------------------------------------------------------------------------------------------
	-- Se agrega la validación de los intentos de ingreso
	-- Bibiana Gaxiola Verdugo.
	-- 21/01/2013
	--**********************************************************************************************************************************
	DEFINE sql_err INT;
	DEFINE vCod_ret CHAR (5);
	DEFINE vNumCel VARCHAR (15);
	DEFINE vStatus SMALLINT;
	DEFINE vIntentos CHAR(3);
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vNumCel, vStatus;
		  END IF ;
		END EXCEPTION ;
		
		--SET DEBUG FILE TO "/home/informix/bibiana/validabm.out";
		--TRACE ON;
		
		LET vCod_ret = '00000';
		LET vNumCel = '';
		LET vStatus= 0;
		LET vIntentos = '';
		
		SET LOCK MODE TO WAIT 3;
		
		IF  EXISTS (SELECT {+index (bdinteg:"informix"si_bm_usuarios "informix".idx_ctebmusuario)} numcte 
					FROM bdinteg:"informix".si_bm_usuarios WHERE numcte= pNumCliente) THEN
			SELECT numcel, id_status, numintacce INTO vNumCel,vStatus,vIntentos FROM bdinteg:"informix".si_bm_usuarios WHERE numcte= pNumCliente;
			LET vNumCel = TRIM(vNumCel);
			
			IF (vStatus = '30' AND vIntentos = '3') THEN
				LET vStatus = '50';
			END IF;
		ELSE
			LET vCod_ret = '00001'; -- Cliente no tiene el servicio de banca móvil.
		END IF;
		
		RETURN vCod_ret, vNumCel, vStatus;
	END;
END PROCEDURE;