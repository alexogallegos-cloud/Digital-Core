CREATE PROCEDURE "informix".sp_obtiene_conexion_param(pEmpresa CHAR (3))
	
	RETURNING CHAR(5)   AS CodRetorno, 
	          CHAR(100) AS NumIp,
              CHAR(100) AS Puerto,
              CHAR(100) AS NomUsuario,
              CHAR(100) AS Password,
			  CHAR(100) AS NomBd,
			  CHAR(100) AS Tiempo,
			  CHAR(100) AS Limite;
			  

--Definicion de Variables
DEFINE iSqlErr        INTEGER;
DEFINE cCodRet        CHAR(5);
DEFINE cNumIp         CHAR(100);
DEFINE cPuerto        CHAR(100);
DEFINE cNomUsuario    CHAR(100);
DEFINE cPassword      CHAR(100);
DEFINE cNomBd         CHAR(100);
DEFINE iTiempo        INTEGER;
DEFINE cLimite        CHAR(100);

--Inicializacion de Variables
LET iSqlErr        = 0;
LET cCodRet        = '00000';
LET cNumIp         = '';
LET cPuerto        = '';
LET cNomUsuario    = '';
LET cPassword      = ''; 
LET cNomBd         = '';
LET iTiempo        = 0;
LET cLimite        = '';

--SET DEBUG FILE TO '/home/tmp/leonardo/sp_obtiene_conexion_param.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumIp, cPuerto, cNomUsuario, cPassword, cNomBd, iTiempo, cLimite;
		END IF;
	END EXCEPTION;
	IF (pEmpresa IS NULL OR NVL (pEmpresa, '') = '') THEN
		LET cCodRet = '00001';
    ELSE
	SET LOCK MODE TO WAIT 3;
		
		SELECT valor
		INTO cNumIp
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa
        AND cod_param = '300';
		
		SELECT valor
		INTO cPuerto
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa
        AND cod_param = '301';
		
		SELECT valor
		INTO cNomUsuario
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa
		AND cod_param = '157';
		
		SELECT valor
		INTO cPassword
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa 
		AND cod_param = '158';
		
		SELECT valor
		INTO cNomBd
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa 
		AND  cod_param = '159';
		
		SELECT valor
		INTO cLimite
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa
        AND cod_param = '166';
		
		SELECT CAST(valor AS INTEGER) 
		INTO iTiempo
		FROM bdinteg:"informix".si_param 
		WHERE empresa = pEmpresa
        AND cod_param = '167';
		
		IF  (cNumIp IS NULL OR cNumIp  = '') OR (cPuerto IS NULL OR cPuerto  = '') OR (cNomUsuario  IS NULL OR cNomUsuario  = '') 
			OR (cPassword IS NULL OR cPassword = '') OR (cNomBd IS NULL OR cNomBd  = '')  OR (iTiempo IS NULL OR iTiempo = '') 
			OR (cLimite IS NULL OR cLimite = '') THEN
			LET cCodRet = '00002';
		END IF;
	END IF;
	RETURN cCodRet, TRIM(cNumIp), TRIM(cPuerto), TRIM(cNomUsuario), TRIM(cPassword), TRIM(cNomBd), iTiempo, TRIM(cLimite);	
END;
END PROCEDURE
DOCUMENT
'Folio: 1559',
'AUTOR : 95594213',
'FECHA : 17-10-2013',
'DESCRIPCION: Se crea sp_obtiene_conexion_param para mandar llamar Ip, Puerto, Nombre Usuario, Password, BD, Nombre de Archivo, Ruta, Servicio, Usuariosub, Passwordsub, Rutadepo',
'SUSTENTO:RQM 12 023 Consulta de Transacciones.doc No viene documentado en el RQM ',
'SOLICITA: Norberto Corona Berruecos',
'BD: bdinteg',
'Folio: 1587',
'AUTOR : 95594213',
'FECHA : 20-02-2014',
'MODIFICACIÓN: Se Modifica sp_obtiene_conexion_param para hacer una conexion a postgres quitarle retornos y agregar uno nuevo.',
'SUSTENTO:DMP Integral Procesos',
'SOLICITA: Norberto Corona Berruecos',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_registra_actualiza_transfolio(pEmpresa   	CHAR(3), 
															 pSucursal      CHAR(4),
															 pOpcion        INTEGER, 
															 pFechaTran     CHAR(8),
															 pHoraTran      CHAR(6),
															 pNumTarje      CHAR(16), 
															 pFechaExp      CHAR(4), 
															 pCodSeg        CHAR(4), 
															 pCURP          CHAR(18), 
															 pFolio         CHAR(2), 
															 pCodResp       CHAR(2),
															 pMotRechazo    CHAR(3),
															 pNumEmpleado   CHAR (8),
															 pCveAfore	    CHAR(3),
															 pTipoTarjeta   CHAR(1),--'C' PARA CREDITO O 'D' PARA DEBITO
															 pFlagCteHuella CHAR(1))--'1' CLIENTE TITULAR	
																					--'2' NO ES DEL CLIENTE TITULAR	
RETURNING CHAR(5);																	--'3' HUELLA CORRESPONDE AL TITULAR DE LA TARJETA
																					--'4' SI LA TARJETA ES DEL TITULAR Y NO ESTA ACTIVA,NO ES DEL TITULAR Y NO ESTA ACTIVA
--DECLARACION DE VARIABLES;															--O HUELLA DEL CLIENTE NO COINCIDE 				
DEFINE cCodret         CHAR(5);
DEFINE iSqlerr	       INTEGER;
DEFINE cTipoTarjeta    CHAR(1);
DEFINE cFlagCteHuella  CHAR(1);
DEFINE cStatusTar      CHAR(1);

--INICIALIZACIÓN DE VARIABLES
LET cCodret        = '00000';
LET iSqlerr        = 0;
LET cTipoTarjeta   = '';
LET cFlagCteHuella = '';
LET cStatusTar     = '';

--SET DEBUG FILE TO '/respaldosbd/isarai/sp_registra_actualiza_transfolio.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	--CONTROLADOR DE ERRORES
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;
	
	--PARAMETROS VACIOS
	IF NVL(pEmpresa,'') = '' OR NVL(pFechaTran,'')= '' OR NVL(pFechaExp,'') = '' OR NVL(pNumTarje,'') = '' OR NVL(pOpcion,0) = 0 THEN
		LET cCodret = '00001';
		RETURN cCodret;
	END IF;
	
	IF NVL(pTipoTarjeta,'')  NOT IN ('','C','D') THEN
		LET cCodret = '00001'; --PARAMETROS INALIDOS
		RETURN cCodret;
	END IF;

	IF pOpcion = 1 THEN 
		--CONSULTA LA TABLA sd_tarjeta CUANDO EL NUMERO DE TARJETA ES DE CREDITO
		IF pTipoTarjeta = 'C' THEN
			SELECT tipo_tarjeta, status_tar
			INTO cTipoTarjeta,cStatusTar
			FROM bdicred: "informix".sd_tarjeta
			WHERE num_tarjeta = pNumTarje
			AND empresa = pEmpresa
			AND secuencia = (SELECT MAX(secuencia)
							FROM bdicred: "informix".sd_tarjeta
							WHERE empresa = pEmpresa
							AND num_tarjeta = pNumTarje)
			AND empresa = empresa 
			AND num_tarjeta = num_tarjeta	
			AND status_tar = status_tar;	
							
		--CONSULTA LA TABLA sc_tarjeta CUANDO EL NUMERO DE TARJETA ES DE DEDITO
		ELIF pTipoTarjeta = 'D' THEN
			SELECT tipo_tarjeta, status_tar
			INTO cTipoTarjeta,cStatusTar
			FROM bdicheq: "informix".sc_tarjeta
			WHERE num_tarjeta = pNumTarje
			AND empresa = pEmpresa
			AND secuencia = (SELECT MAX(secuencia)
							FROM bdicheq: "informix".sc_tarjeta
							WHERE empresa = pEmpresa
							AND num_tarjeta = pNumTarje)
			AND empresa = empresa 
			AND num_tarjeta = num_tarjeta	
			AND status_tar = status_tar;	
										
		ELSE
		
			--SI EL TIPO DE TARJETA NO ES DE ALGUN CLIENTE BANCOPPEL
			INSERT INTO "informix".si_folioafore (empresa, sucursal, fecha_transac, hora_transac, num_tarjeta, fecha_expira, cod_seguridad,curp_resp, folio_resp, codigo_resp, motivo_rechazo, 
							   fecha_insert, num_usuario,cve_afore, flag_cte_huella)
			VALUES(pEmpresa, pSucursal, pFechaTran, pHoraTran, pNumTarje, pFechaExp, TRIM(pCodSeg), pCURP, pFolio, pCodResp, pMotRechazo, CURRENT, pNumEmpleado,pCveAfore,cFlagCteHuella);
			
			RETURN cCodret;
		END IF;
		
		--SI NO EXISTEN REGISTROS EN NINGUNA DE LAS DOS TABLAS, EL SP RETORNARA UN ERROR CONTROLADO
		IF ( DBINFO('sqlca.sqlerrd2') = 0 ) THEN
			LET cCodret = '00004';
			RETURN cCodret;
		END IF;

		IF NVL(cTipoTarjeta,'') = 'T' AND NVL(cStatusTar,'') = 'A' THEN
			LET cFlagCteHuella = '1'; -- SI LA TARJETA ES DEL TITULAR Y ESTA ACTIVA
		ELIF NVL(cTipoTarjeta,'') = 'A' AND NVL(cStatusTar,'') = 'A' THEN
			LET cFlagCteHuella = '2'; -- SI LA TARJETA NO ES DEL TITULAR Y ESTA ACTIVA
			LET cCodret = '00005';
		ELIF (NVL(cTipoTarjeta,'') = 'T' AND NVL(cStatusTar,'') = 'C') THEN
			LET cFlagCteHuella = '5'; -- SI LA TARJETA ES DEL TITULAR Y ESTA CANCELADA
			LET cCodret = '00006';	
		ELIF (NVL(cTipoTarjeta,'') = 'A' AND NVL(cStatusTar,'') = 'C') THEN
			LET cFlagCteHuella = '2'; -- NO ES DEL TITULAR Y ESTA CANCELADA
			LET cCodret = '00005';
		END IF;
		
		--SE INSERTA EL REGISTRO EN LA PRIMERA VUELTA.
		INSERT INTO "informix".si_folioafore (empresa, sucursal, fecha_transac, hora_transac, num_tarjeta, fecha_expira, cod_seguridad,curp_resp, folio_resp, codigo_resp, motivo_rechazo, 
							   fecha_insert, num_usuario,cve_afore, flag_cte_huella)
		VALUES(pEmpresa, pSucursal, pFechaTran, pHoraTran, pNumTarje, pFechaExp, TRIM(pCodSeg), pCURP, pFolio, pCodResp, pMotRechazo, CURRENT, pNumEmpleado,pCveAfore,cFlagCteHuella);
	
	    RETURN cCodret;
		
	ELIF pOpcion = 2 THEN --CLIENTE BANCOPPEL
		IF pFlagCteHuella NOT IN ('3','4') THEN
			LET cCodret = '00001'; -- ERROR EN LOS PARAMETROS
		END IF;
			
		IF pCodResp = '01' AND NVL(pFolio,'') = '' AND pFlagCteHuella = '3' THEN 
			LET cCodret = '00002'; -- ERROR EN LOS PARAMETROS
		END IF;
		
	ELIF pOpcion = 3 THEN  --CLIENTE DE OTRO BANCO 
		IF pCodResp = '01' AND NVL(pFolio,'') = '' THEN
			LET cCodret = '00002'; --SI EL TIPO DE TARJETA NO ES DE ALGUN CLIENTE BANCOPPEL Y OCURRIO UN ERROR EN LA CONSULTA A PROSA
		END IF
	
	ELSE
		LET cCodret = '00007'; -- ERROR,NUMERO DE OPCION INVALIDA
	
	END IF
	
	IF cCodret::INTEGER = 0 THEN
	
		--ACTUALIZA EL NUMERO DE FOLIO,MOTIVO DE RECHAZO,CLAVE AFORE,FLAG_CTE_HUELLA EN LA SEGUNDA VUELTA
		UPDATE "informix".si_folioafore SET folio_resp = pFolio, codigo_resp = pCodResp, motivo_rechazo = pMotRechazo, cve_afore = pCveAfore,flag_cte_huella = pFlagCteHuella
		WHERE empresa = pEmpresa AND fecha_transac = pFechaTran AND hora_transac = pHoraTran AND num_tarjeta = pNumTarje;

	END IF

--RETURN PRINCIPAL
	RETURN cCodret;

END;
--*********************************************************
--| Procedimiento   : sp_registra_actualiza_transfolio
--| Versión         : 20110504
--| Creado por      : Adrian Lara
--| Fecha creacion  : 4 de mayo de 2011
--| Descripción     : Registra y actualiza las transacciones para la consulta de Folio de Estado de Cuenta a PROSA.
--**********************************************************
END PROCEDURE
DOCUMENT
'Modifico: Eduardo Lopez',
'Fecha: 21-03-2013',
'BD: bdinteg',
'ver.:20130321',
'Descripción: Se modifico para que guarde o actualice el nuevo campo(cve_afore) en la tabla si_folioafore',
'MODIFICO: ISARAI BOJORQUEZ AGUIRRE',
'FECHA: 24/02/2014',
'BD:BDINTEG',
'VERSION: 20140224.0948',
'DESCRIPCION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR LOS NUEVOS PARAMETROS pTipoTarjeta,pFlagCteHuella NECESARIOS EN LA INSERCCION O ACTUALIZACION DE LA TABLA',
'si_folioafore. SE AGREGA LA OPCION 3 EN CASO DE NO SER CLIENTE BANCOPPEL SE INSERTE O ACTUALICE EN LA MISMA TABLA.SE APLICAN REGLAS DE INFORMIX';

CREATE PROCEDURE "informix".sp_cnsif_guardanivelesaccesomodulos(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionC CHAR(8), pIdModulos CHAR(255), pNivelesAcceso CHAR(100))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNivelAcceso SMALLINT;
	DEFINE iRegsProcesados INTEGER;
	DEFINE iExiste SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNivelAcceso = 0;
	LET iRegsProcesados = 0;
	LET iExiste = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_guardanivelesaccesomodulos.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pIdFuncionC = '' OR pIdModulos = '' OR pNivelesAcceso = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACIÃN DE ACCESO AL PROCEDIMIENTO
		EXECUTE PROCEDURE "informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- Se valida que el usuario no este insertado ya en tabla, en ese caso solo se actualizaran sus niveles de acceso
		SELECT COUNT(id_usuario)
		INTO iExiste
		FROM "informix".si_seg_nivel_acceso_modulo
		WHERE id_usuario = pIdFuncionC;
		
		IF iExiste <> 0 THEN
			LET cCodRet = '00004';
			RETURN cCodRet;
		END IF;
		
		-- Se inserta al usuario en tablas
		INSERT INTO bdinteg:si_seg_nivel_acceso_modulo(id_usuario, id_modulo, nivel_acceso)
		SELECT pIdFuncionC, a.id_modulo, iNivelAcceso
		FROM bdinteg:si_seg_modulos a;
		
		EXECUTE PROCEDURE "informix".sp_cnsif_actualizanivelesaccesomodulos(pIdUsuario, pIdFuncion, pIdFuncionC, pIdModulos, pNivelesAcceso) INTO cCodRet, iRegsProcesados;
		IF cCodRet::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRet::INTEGER, 0, 'ERROR EN SP sp_cnsif_actualizanivelesaccesomodulos';
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/12/2013",
"DESCRIPCION: Procedimiento que guarda los niveles de acceso para un usuario",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_validaemail(pEmail	Char(100)) 
RETURNING CHAR(5) As Codigo_error,
 CHAR(1) As Valido;

DEFINE vlStrTemp  Char(1);
DEFINE vlContador  Smallint;
DEFINE vlEmail    char(100);
DEFINE vlValidaEmail char(1);
DEFINE sCodRet		char(5);
DEFINE vlPosArroba	smallint;
DEFINE	vlPosPunto	smallint;
DEFINE	vsqlerr		smallint;
DEFINE	vlPosGuionB	smallint;
DEFINE	vlPosGuionA	smallint;

LET vlStrTemp = '';
LET	vlcontador = '';
LET	vlEmail = '';	
LET vlValidaEmail ='V';
LET sCodRet ='00000';
LET vlPosArroba	=0;
LET	vlPosPunto	=0;
LET	vlPosGuionB	=0;
LET	vlPosGuionA	=0;

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scodret=vsqlerr;
      RETURN scodret,'F';
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "validaemail.out";
--TRACE ON;

  LET vlEmail = trim(pEmail);
  
  let vlContador = 1;
  
  If pEmail = "" Then
    let vlValidaEmail = 'F';
    let scodret =  '00001'; --"No se indicó ninguna dirección de mail para verificar"   
	RETURN scodret,vlValidaEmail;  
  ELIF length(vlEmail) < 7 then
    let vlValidaEmail = 'F';
    let scodret =  '00002'; --"La direccion no es valida favor de verificar"   
	RETURN scodret,vlValidaEmail;
  END IF;	
  
  While vlContador <= length(vlEmail) LOOP
     let vlStrTemp = Substr(vlEmail,vlContador,1);
     if (vlStrTemp not in ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z')) 
	     and
		 (vlStrTemp not in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'))
		 and
		 (vlStrTemp not in ('1','2','3','4','5','6','7','8','9','0'))
		 and 
		 (vlStrTemp not in ('-','.','@','_'))		 
		  then 
	   let sCodRet = '00003'; --La dirección cuenta con un caracter invalido
	   let vlValidaEmail = 'F';
	   RETURN scodret,vlValidaEmail;  
	 elif vlStrTemp in ('-','.','@','_') and (( vlContador = 1) or (vlContador = length(vlEmail) ) ) then
	   let sCodRet = '00004'; --La dirección de email no puede llevar -,.,@,_ ni al principio ni al final 
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;  
	 elif vlStrTemp = ' ' then
	   let sCodRet = '00006'; --La dirección de email no puede llevar espacios vacios
	   let vlValidaEmail = 'F';	     
	   RETURN scodret,vlValidaEmail;  
	 end if;
	 
	 if ((vlPosArroba >0)  and vlStrTemp in ('@') and (vlPosArroba +1 =vlContador) ) then	   
	   let sCodRet = '00008'; --No pueden ir  @@ 
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;  	
	 end if;

	if ((vlPosPunto >0)  and vlStrTemp in ('.') and  (vlPosPunto +1 =vlContador) ) then	   
	   let sCodRet = '00014'; --No pueden ir dos puntos juntos
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;   
	 end if; 	 
	if ((vlPosGuionB >0)  and vlStrTemp in ('_') and  (vlPosGuionB +1 =vlContador) ) then	   
	   let sCodRet = '00015'; --No pueden ir dos guiones bajo juntos
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if; 	 
	if ((vlPosGuionA >0)  and vlStrTemp in ('-') and  (vlPosGuionA +1 =vlContador) ) then	   
	   let sCodRet = '00016'; --No pueden ir dos guiones alto juntos
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if;

	 if vlStrTemp in ('.') then
	   let vlPosPunto = vlContador;
	 end if;
	 if vlStrTemp in ('@') then
	   let vlPosArroba = vlContador;
	 end if;

	if vlStrTemp in ('-') then
	   let vlPosGuionA = vlContador;
	 end if;

	if vlStrTemp in ('_') then
	   let vlPosGuionB = vlContador;
	 end if;


	 if ((vlPosPunto >0)  and (vlPosArroba > 0)) and ( (vlPosPunto +1 =vlPosArroba) or (vlPosPunto -1 = vlPosArroba) ) then	   
	   let sCodRet = '00005'; --No puede ir un punto antes ni despues del arroba
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 	
	 end if;  

	if ((vlPosGuionA >0)  and (vlPosArroba > 0)) and ( (vlPosGuionA +1 =vlPosArroba) or (vlPosGuionA -1 = vlPosArroba) ) then	   
	   let sCodRet = '00009'; --No puede ir un guion alto antes ni despues del arroba
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if;            

     if ((vlPosGuionB >0)  and (vlPosArroba > 0)) and ( (vlPosGuionB +1 =vlPosArroba) or (vlPosGuionB -1 = vlPosArroba) ) then	   
	   let sCodRet = '00010'; --No puede ir un guion bajo antes ni despues del arroba
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if;            
     if ((vlPosGuionB >0)  and (vlPosPunto > 0)) and ( (vlPosGuionB +1 =vlPosPunto) or (vlPosGuionB -1 = vlPosPunto) ) then	   
	   let sCodRet = '00011'; --No puede ir un guion bajo antes ni despues del punto
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if;            
     if ((vlPosGuionA >0)  and (vlPosPunto > 0)) and ( (vlPosGuionA +1 =vlPosPunto) or (vlPosGuionA -1 = vlPosPunto) ) then	   
	   let sCodRet = '00012'; --No puede ir un guion alto antes ni despues del punto
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;  
	 end if; 
     if ((vlPosGuionA >0)  and (vlPosGuionB > 0)) and ( (vlPosGuionA +1 =vlPosGuionB) or (vlPosGuionA -1 = vlPosGuionB) ) then	   
	   let sCodRet = '00013'; --No puede ir un guion alto antes ni despues del guion bajo
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;  	
	 end if;            

	 LET vlContador = vlContador +1;
  END LOOP;
  RETURN scodret,vlValidaEmail;
END;  
END PROCEDURE;