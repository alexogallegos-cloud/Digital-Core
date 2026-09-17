CREATE PROCEDURE "informix".sp_consultapreasignacionhuella(cEmpresa CHAR(3), cNumCte CHAR(20))

        --DATOS A REGRESAR---
        RETURNING
        CHAR (5),  ---- Código de Retorno
        CHAR (3),  ---- Empresa
        CHAR (20), ---- Número de Cliente
        SMALLINT,  ---- Secuencia
        CHAR (1),  ---- Status
        CHAR (8),  ---- Oerador
        CHAR (8),  ---- Empleado
        CHAR (8),  ---- Usuario3
        CHAR (4),  ---- Sucursal
        CHAR (20), ---- Nueva Identificacion
        CHAR (20), ---- Numero de Referencia
        DATE,      ---- Fecha de Alta
        CHAR (942), --- Dmapa
        CHAR (942); --- Imapa

        --DEFINICIÓN DE VARIABLES--
        DEFINE cCodRet      CHAR (5);
        DEFINE cEmpresa     CHAR (3);
        DEFINE cNumCliente  CHAR (20);
        DEFINE smSecuencia  SMALLINT;
        DEFINE cStatus      CHAR (1);
        DEFINE cOperador    CHAR (8);
        DEFINE cEmpleado    CHAR (8);
        DEFINE cUsuario3    CHAR (8);
        DEFINE cSucursal    CHAR (4);
        DEFINE cNueva_ident CHAR (20);
        DEFINE cNum_refer   CHAR (20);
        DEFINE dFecha_Alta  DATE;
        DEFINE cDmapa       CHAR (942);
        DEFINE cImapa       CHAR (942);
        DEFINE smSecuenciaMax SMALLINT;

        --INICIALIZACIÓN DE VARIABLES--
        LET cCodRet = "000";
        LET cNumCliente = "";
        LET cEmpresa = "";
        LET smSecuencia = 0;
        LET cStatus = "";
        LET cOperador = "";
        LET cEmpleado = "";
        LET cUsuario3 = "";
        LET cSucursal = "";
        LET cNueva_ident = "";
        LET cNum_refer = "";
        LET dFecha_Alta = "";
        LET cDmapa = "";
        LET cImapa = "";
        LET smSecuenciaMax = 0;

            IF cNumCte IS NULL OR Trim(cNumCte) = "" THEN
                LET cCodRet = "110";
                RETURN cCodRet,cEmpresa,cNumCliente,smSecuencia,cStatus,cOperador,cEmpleado,cUsuario3,
                       cSucursal, cNueva_ident, cNum_refer, dFecha_Alta, cDmapa,cImapa;
            END IF;

            IF NOT EXISTS (SELECT numcte  FROM bdinteg:si_huella_temp WHERE numcte = cNumCte) THEN
                    LET cCodRet = "001";
            END IF;

            SELECT MAX(secuencia)
            INTO smSecuenciaMax
            FROM bdinteg:si_huella_temp
            WHERE numcte = cNumCte;

            SELECT empresa,numcte,secuencia,status,operador,empleado,usuario3,sucursal, nueva_ident, num_refer, fecha_alta,dmapa,imapa
            INTO cEmpresa,cNumCliente,smSecuencia,cStatus,cOperador,cEmpleado,cUsuario3,cSucursal, cNueva_ident, cNum_refer, dFecha_Alta, cDmapa,cImapa
            FROM bdinteg:si_huella_temp
            WHERE numcte = cNumCte
            AND secuencia = smSecuenciaMax;

            RETURN cCodRet,cEmpresa,cNumCliente,smSecuencia,cStatus,cOperador,cEmpleado,cUsuario3,
                   cSucursal, cNueva_ident, cNum_refer, dFecha_Alta, cDmapa,cImapa;
END PROCEDURE
DOCUMENT
"Consulta Preasignación de Huella de cliente persona fisica",
"AutOR : Priscilla Mercado Campaña.",
"FECHA : 13-11-2008",
"BD    : bdinteg",
"VER   : 1.1",
"Se modifica para consultar si el cliente no existe en la tabla temporal de huellas",
"FECHA: 13-01-2009";

CREATE PROCEDURE "informix".sp_buscarcliente( p_sPrimerNombre CHAR(30), p_sSegundoNombre CHAR(30), p_sPrimerApellido CHAR(30), p_sSegundoApellido CHAR(30), p_sRFC CHAR(15), p_sEmpresa CHAR(3))
RETURNING 	CHAR(6) AS codRetorno,
			INTEGER AS numReg,
			CHAR(10) AS existe,
			CHAR(20) AS noCliente,
			CHAR(10) AS tipoCuenta,
			CHAR(20) AS noCuenta;

	--definicion de variables--	    
	DEFINE iSqlErr 					INTEGER;
	DEFINE v_sValRetorno 			CHAR(6);
	DEFINE v_sExiste 				CHAR(10);
	DEFINE v_sNoCliente 			CHAR(20);	
	DEFINE v_sTipoCuenta 			CHAR(10);
	DEFINE v_sNoCuentaCred 			CHAR(20);
	DEFINE v_sNoCuentaDeb 			CHAR(20);
	DEFINE v_iNumReg 				INTEGER;
	DEFINE v_snombre1 				CHAR(26);
	DEFINE v_snombre2				CHAR(26); 
	DEFINE v_sapell_paterno			CHAR(26);
	DEFINE v_sapell_materno			CHAR(26);	
	DEFINE v_encontro				INTEGER;		
	
	/*********************************************************************************/
	--Creado por: Erick Zamora  21/12/2008
	--Modificado: Fabiola Corrales 10/Ene/2009
	--	Se mejoró el tiempo de generción de la información, se optimizaron las consultas con los indices correspondientes.
	--Modificado: Erick Zamora 03/02/2009
	--	Se mejoró el tiempo de generación de los datos, se cambio la busqueda para que tome encuenta solo el RFC sin la homoclave
	--Devuelve todos los noCliente, tipoCuenta y NoCuenta de el cliente especificado en caso que exista.
	--SET DEBUG FILE TO "/tmp/sp_buscarclientes.out";
	--TRACE ON;
	/**********************************************************************************/

	LET v_iNumReg = 0;
	LET v_sValRetorno = '000';
	LET v_sExiste = '';
	LET v_sNoCliente =  '';
	LET v_sTipoCuenta = '';
	LET v_sNoCuentaCred = '';	
	LET v_sNoCuentaDeb = '';
	LET v_encontro = 0;	
		
    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN                
                RETURN iSqlErr,'','','','','';
            END IF;
        END EXCEPTION;								
		
		LET p_sRFC = SUBSTR(p_sRFC,1,10);		
		
		SELECT numcte, nombre1, nombre2, 
		apell_paterno, apell_materno, SUBSTR(rfc,1,10) AS rfc
		FROM bdinteg:si_cliente		
		WHERE apell_paterno = p_sPrimerApellido 
		AND apell_materno = p_sSegundoApellido
		INTO temp tmp_siClientes
		WITH NO LOG;	
		
		CREATE INDEX idx_rfc ON tmp_siClientes(rfc);
		UPDATE statistics high FOR TABLE tmp_siClientes(rfc);
				
		FOREACH
			SELECT numcte, nombre1, nombre2, apell_paterno, apell_materno
			INTO v_sNoCliente, v_snombre1,v_snombre2, v_sapell_paterno, v_sapell_materno
			FROM bdinteg:tmp_siClientes
			WHERE rfc = p_sRFC
					
			IF v_sNoCliente <> '' AND p_sPrimerNombre = v_snombre1 AND p_sSegundoNombre = v_snombre2 
			AND p_sPrimerApellido = v_sapell_paterno AND p_sSegundoApellido = v_sapell_materno THEN
				LET v_encontro = 1;
				EXIT FOREACH;
			END IF
		END FOREACH
		
		DROP TABLE tmp_siClientes;
		
		IF v_encontro = 1 THEN
			
			LET v_sExiste = "Si existe";			
			LET v_iNumReg = 1;
			
			FOREACH
				SELECT cred.num_credito INTO v_sNoCuentaCred
				FROM bdicred:sd_maecred cred 
				WHERE empresa = p_sEmpresa
				AND cred.numcte = v_sNoCliente
			
				LET v_sTipoCuenta = 'Credito';
				RETURN v_sValRetorno, v_iNumReg, v_sExiste, v_sNoCliente, v_sTipoCuenta, v_sNoCuentaCred WITH RESUME;	
			END FOREACH
		
			FOREACH
				SELECT chq.cuenta INTO v_sNoCuentaDeb
				FROM bdicheq:sc_maechq chq 
				WHERE empresa = p_sEmpresa
				AND chq.num_cte = v_sNoCliente
		
				LET v_sTipoCuenta = 'Debito';
				RETURN v_sValRetorno, v_iNumReg, v_sExiste, v_sNoCliente, v_sTipoCuenta , v_sNoCuentaDeb WITH RESUME;
			END FOREACH				
		ELSE
			LET v_sExiste = "No existe";
			LET v_iNumReg = 0;
			LET v_sNoCliente = '';
		END IF				
		IF v_sTipoCuenta = '' THEN			
			RETURN v_sValRetorno, v_iNumReg, v_sExiste, v_sNoCliente, '', '';		
		END IF		
		
    END

END PROCEDURE;