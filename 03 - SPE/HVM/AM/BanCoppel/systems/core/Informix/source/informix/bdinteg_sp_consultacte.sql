CREATE PROCEDURE "informix".sp_consultacte(cOpcion CHAR(1), cTipoTar  CHAR(1), cNumTarjeta  CHAR(16), cNumCliente CHAR(20), cRFCmh CHAR(13))
	RETURNING 
	CHAR(6),    -- Codigo de retorno
	CHAR(20),   -- # Cliente
	CHAR(110),  -- Nombre Cliente
	CHAR(13),   -- RFC
	CHAR(10), 	-- Fecha nacimiento
	CHAR(30);   -- Tipo Documento
	
	DEFINE cCodRet  	CHAR(6);
	DEFINE cNumeroCte	CHAR(20);
	DEFINE cNombreCte 	CHAR(110);
	DEFINE cRFC     	CHAR(13);
	DEFINE cFechaNac	CHAR(10);
	DEFINE cNumIdenti	CHAR(30);
	DEFINE iSqlErr  	INTEGER;
	DEFINE iExists		INTEGER;
	DEFINE iSecuencia 	INTEGER;
	
	LET cCodRet  	= "000000";
	LET cNumeroCte 	= "";
	LET cNombreCte 	= "";
	LET cRFC 		= "";
	LET cFechaNac 	= "";
	LET cNumIdenti 	= "";
	LET iSqlErr 	= 1;
	LET iExists		= 0;
	LET iSecuencia	= 0;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
BEGIN

		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCodRet = iSqlErr;				
				RETURN cCodRet,cNumeroCte,cNombreCte,cRFC,cFechaNac,cNumIdenti;	
			END IF;
		END EXCEPTION;			
		
		--SET DEBUG FILE TO "/home/sysifx/Oscar/sp_consultaCte.out";
		--TRACE ON;
		IF (cOpcion = '' OR cOpcion IS NULL) THEN
			LET cCodRet = '000001';
		ELSE
			IF cOpcion = '1' THEN
				IF (cTipoTar = '' OR cTipoTar IS NULL) OR (cNumTarjeta = '' OR cNumTarjeta IS NULL) THEN
					LET cCodRet = '000001';
				ELSE
					IF cTipoTar = 'C' THEN
						SELECT 1 INTO iExists FROM bdicred:"informix".sd_tarjeta WHERE num_tarjeta = cNumTarjeta and status_tar = 'A';
						IF iExists > 0 THEN
							SELECT cte.numcte, TRIM(cte.nombre1) || ' ' || TRIM(cte.nombre2) || ' ' || TRIM(cte.apell_paterno) || ' ' || TRIM(cte.apell_materno) AS nombreCte, cte.rfc, dcte.fecha_nac, dcte.numidentifi  --Por numero tarjeta bdicred
							INTO cNumeroCte, cNombreCte, cRFC, cFechaNac, cNumIdenti
							FROM bdinteg:"informix".si_cliente cte 
							INNER JOIN bdinteg:"informix".si_ctepf dcte ON cte.numcte = dcte.numcte
							INNER JOIN bdicred:"informix".sd_tarjeta trj ON cte.numcte = trj.numcte
							WHERE trj.num_tarjeta = cNumTarjeta;
							IF cRFC <> cRFCmh THEN
								LET cCodRet = '000005';
							END IF;
						ELSE
							LET cCodRet = '000003';
						END IF;
					ELIF cTipoTar = 'D' THEN	
						SELECT 1 INTO iExists FROM bdicheq:"informix".sc_tarjeta WHERE num_tarjeta = cNumTarjeta and status_tar = 'A';
						IF iExists > 0 THEN
							SELECT cte.numcte, TRIM(cte.nombre1) || ' ' || TRIM(cte.nombre2) || ' ' || TRIM(cte.apell_paterno) || ' ' || TRIM(cte.apell_materno) AS nombreCte, cte.rfc, dcte.fecha_nac, dcte.numidentifi  --Por numero tarjeta bdicheq
							INTO cNumeroCte, cNombreCte, cRFC, cFechaNac, cNumIdenti
							FROM bdinteg:"informix".si_cliente cte 
							INNER JOIN bdinteg:"informix".si_ctepf dcte ON cte.numcte = dcte.numcte
							INNER JOIN bdicheq:"informix".sc_tarjeta trj ON cte.numcte = trj.numcte
							WHERE trj.num_tarjeta = cNumTarjeta;
							IF cRFC <> cRFCmh THEN
								LET cCodRet = '000005';
							END IF;
						ELSE
							LET cCodRet = '000003';
						END IF;
					END IF;				
				END IF;	
				IF cNumeroCte IS NULL THEN
					LET cCodRet = '000002';
				END IF;	
			ELIF cOpcion = '2' THEN
				IF (cNumCliente = '' OR cNumCliente IS NULL) THEN
					LET cCodRet = '000001';
				ELSE
					SELECT MAX(secuencia) INTO iSecuencia
					FROM bdinteg:"informix".si_huella_temp
					WHERE numcte = cNumCliente;
					
					DELETE FROM bdinteg:"informix".si_huella_temp WHERE numcte = cNumCliente AND secuencia = iSecuencia;
				END IF;
			ELSE
				LET cCodRet = '000004';
			END IF;
		END IF;	
		RETURN cCodRet,cNumeroCte,cNombreCte,cRFC,cFechaNac,NVL(cNumIdenti,'');

END
END PROCEDURE
DOCUMENT
'Se crea SP para la consuta de los datos del cliente por numero de tarjeta. Anexo a eso',
'se incluye la opcion del borrado del template temporal de la huella del cliente en caso de fallar el mantenimiento de huella y biometria',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 22/10/2019',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_guardabithbio(cNumCte CHAR(20), cSucursal CHAR(4), cNumUsuario CHAR(10), cIPMaquina CHAR(14), cTipoProceso CHAR(1), 
								 cNumGteAutoriza CHAR(10), cTipoIdent CHAR(1), cNumIdent CHAR(30))
RETURNING CHAR(6)    

DEFINE cCodRet  	CHAR(6);
DEFINE iSqlErr		INTEGER;

LET cCodRet	= "000000";
LET iSqlErr = 1;

BEGIN	

	ON EXCEPTION SET iSqlErr
	    IF iSqlErr <> 0 THEN
	        LET cCodRet = iSqlErr;
	        RETURN cCodRet;
	    END IF;
	END EXCEPTION;
	
		--SET DEBUG FILE TO "/home/sysifx/Oscar/sp_guardabithbio.out";
		--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF (cNumCte = '' OR cNumCte IS NULL) OR (cSucursal = '' OR cSucursal IS NULL) OR (cNumUsuario = '' OR cNumUsuario IS NULL) OR (cIPMaquina = '' OR cIPMaquina IS NULL) 
		OR (cTipoProceso = '' OR cTipoProceso IS NULL) OR (cNumGteAutoriza = '' OR cNumGteAutoriza IS NULL) OR (cTipoIdent = '' OR cTipoIdent IS NULL) THEN
		LET cCodRet = '000001';
	ELSE				
		INSERT INTO bdinteg:"informix".si_bitmant_huellarostro(numcte, sucursal, ejecutivo, ip_maquina, fecha_hora, tipo_proceso, numgte_autoriza, tipo_ident, num_ident)
		VALUES(cNumCte, cSucursal, cNumUsuario, cIPMaquina, CURRENT, cTipoProceso, cNumGteAutoriza, cTipoIdent, cNumIdent);			
	END IF;
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Se crea SP para el guardado de bitacora al realizarce mantenimiento de huella y biometria facial del cliente de manera correcta',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 22/10/2019',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".considentificacion(p_numcte char(10))
   RETURNING CHAR(5), CHAR(20), CHAR(20);

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE p_mensaje           CHAR(80);
   DEFINE nrows               SMALLINT;

   DEFINE v_tipoIdent		CHAR(50);
   DEFINE v_noIdent			CHAR(50);

   LET v_tipoIdent = "";
   LET v_noIdent   = "";
	

	--SET DEBUG FILE TO "/respaldosbd/mario/trace.sql";
	--TRACE ON;
BEGIN	
	ON EXCEPTION SET sql_err, isam_err, error_info
		--SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cod_ret = sql_err;
		RETURN  cod_ret,v_tipoIdent, v_noIdent;
	END EXCEPTION;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	

	LET cod_ret = '000';
	LET p_mensaje = "Operacion Realizada Exitosamente";


	
	

	SELECT tipo_ident, num_ident
	INTO v_tipoIdent,v_noIdent 
	FROM "informix".si_bitmant_huellarostro
    	WHERE numcte = trim(p_numcte) AND  fecha_hora = (SELECT MAX(fecha_hora) FROM bdinteg:"informix".si_bitmant_huellarostro WHERE NUMCTE = trim(p_numcte));
    	
    
    
    IF trim(v_noIdent) is null then
		let cod_ret = "104";
		RETURN  cod_ret,trim(v_tipoIdent), trim(v_noIdent);
    end if

    RETURN  cod_ret,trim(v_tipoIdent), trim(v_noIdent);
END
END PROCEDURE

DOCUMENT
'SPL Extrae tipo y numero de identificacion ingresados en manhuella',
"MODIFICO : CRISTIAN IBARRA",
"FECHA : 27/Febrero/2021",
"Ver.  : 1.0",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sps_obt_numcte_status(pEmpresa char(3), pIdUsuario char(20), pUsuario char(50), pIndicador CHAR(1))
                      returning char(5),char(20),smallint;

	-- Creador: Moises Soriano	
	-- Objetivo: Obtener el número y estatus del cliente,
	-- Se clona sp_obt_numcte_status, se agrega parametro de entrada
	-- Solicitó: Alejandro Vazquez
	-- Fecha: 11/04/2016
					
					  
-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define sql_err integer;
   define v_id_status smallint ;
   define v_num_cte char (20);
   define pNumCte char (20);
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret       = "000";
   let v_id_status = 0;
   let v_num_cte = "";
   
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_obt_numcte_status.out";
	--TRACE ON;

BEGIN
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret, v_num_cte, v_id_status;
      end if
   end exception;

SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   

   IF pIndicador = '' AND pIdUsuario <> '' THEN
      LET  pIndicador = '1';
   END IF;

  IF pIdUsuario <> '' THEN
		IF pIndicador = '1' THEN  -- pIdUsuario = id_usuario
			SELECT numcliente INTO pNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pIdUsuario AND st_portal = 'activo';
		ELIF pIndicador = '2' THEN -- pIdUsuario = numcliente
			LET pNumCte = pIdUsuario;
		END IF;
	
        IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = pNumCte ) THEN

             SELECT numcte,id_status INTO v_num_cte, v_id_status FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumCte;
			 LET v_num_cte = pNumCte;
             LET cod_ret = '000';

        ELSE

            LET cod_ret = '001';

        END IF ;

  ELSE

        IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND usuario = pUsuario ) THEN

             SELECT numcte,id_status INTO v_num_cte,v_id_status FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND usuario = pUsuario;

             LET cod_ret = '000';

        ELSE

            LET cod_ret = '002';

        END IF ;

  END IF ;
  
  RETURN cod_ret, v_num_cte, v_id_status;

END

END PROCEDURE ;