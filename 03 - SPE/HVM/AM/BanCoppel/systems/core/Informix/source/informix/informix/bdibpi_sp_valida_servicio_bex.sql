CREATE PROCEDURE "informix".sp_valida_servicio_bex(pNumTel CHAR(10),pFechaNac DATE, pCtaTjCte VARCHAR(20), pUdid CHAR(150),pImei CHAR(150))
RETURNING CHAR(5) AS Cod_ret,
		 CHAR(50) AS mensaje,
		 CHAR(10) AS NumCte,
		 CHAR(26) AS Apell1,
		 CHAR(26) AS Apell2,
		 CHAR(26) as Nombre1,
		 CHAR(26) AS Nombre2,
		 CHAR(1) AS EstatusSer, 
		 INTEGER AS CtaDig, 
		 CHAR(30) AS Correo;
		 
		 -- Procedimiento que valida el servicio de bancoppel express para los parametros que recibe
		 -- Numero telefonico, Fecha de Nacimiento, TarjetaDebito/TarjetaCredito/Cuenta/NumeroCliente, Imei, Udid
		 -- Codigos de retorno (00000,00001,00002,00003 son codigos validos para continuar el paso del registro)
		 -- Cualquier otro codigo tiene un motivo

--Definimos de Variables
DEFINE sql_err  		INTEGER;
DEFINE vCod_ret 		CHAR(5);   
DEFINE vMensaje 		CHAR(50);
DEFINE iEntro           INTEGER;
DEFINE vxNumCred        VARCHAR(20);
DEFINE vNumcte  		CHAR(10);
DEFINE vxNumcte  		CHAR(10);
DEFINE vNumTel  		CHAR(10);
DEFINE vApell1  		CHAR(26);
DEFINE vApell2  		CHAR(26);
DEFINE vNombre1 		CHAR(26);
DEFINE vNombre2 		CHAR(26);
DEFINE vEstatusSer 	CHAR(1);
DEFINE vCtaDig		INTEGER;
DEFINE vCorreo		CHAR(30);
DEFINE vLong         INTEGER;
DEFINE vExistCred	INTEGER;
DEFINE l_Fecha		DATE;
DEFINE vVerif_val    INTEGER;
DEFINE vExistTD		INTEGER;
DEFINE vExistCelDisp INTEGER;
DEFINE vExistCel		INTEGER;
DEFINE vExistDispo	INTEGER;
DEFINE vExistCte		INTEGER;
DEFINE vExistCta		INTEGER;
DEFINE vExistTC		INTEGER;
DEFINE vBin      	CHAR(6);
DEFINE vIndtar      CHAR(1);
DEFINE vFecnac      DATE;

--InicializaciÃÂ³n de Variables
LET vCod_ret 		= '00000';
LET vMensaje 		= 'ERROR';
LET iEntro          = 0;
LET vxNumCred       = '';
LET vNumcte  		= '';
LET vxNumcte  		= '';
LET vNumTel			= '';
LET vApell1  		= '';
LET vApell2  		= '';
LET vNombre1 		= '';   
LET vNombre2 		= '';
LET vEstatusSer 		= '0';
LET vCtaDig 			= 0;
LET vCorreo			= '';
LET vLong            = 0;
LET vExistCred		= 0;
LET l_Fecha			= '';
LET vVerif_val       = 0;
LET vExistTD			= 0;
LET vExistCelDisp 	= 0;
LET vExistCel		= 0;
LET vExistDispo		= 0;
LET vExistCte		= 0;
LET vExistCta		= 0;
LET vExistTC			= 0;
LET vBin			= '';
LET vIndtar			= '';
LET vFecnac			= '';

      

--INICIO
BEGIN
--Atrapa excepciÃÂ³n
ON EXCEPTION SET sql_err
	IF sql_err <> 0 THEN
			LET vCod_ret = sql_err;
			LET vEstatusSer 	= '';
			RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo; 
	END IF;
END EXCEPTION;
--
-- insert into table_log values (today,1, '' pNumTel '');
--Valida campos vacios
IF( NVL(pNumTel,'')='' OR NVL(pFechaNac,'')='' OR NVL(pUdid,'')='' OR NVL(pImei,'')='')THEN
	LET vCod_ret = '00006';
	LET vMensaje = 'FALTAN DATOS';
	   RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo; 
END IF;
--
SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;
	
--Longitud (Parametro)
LET vLong = LENGTH(pCtaTjCte);
--Fecha de Hoy
LET l_Fecha = today;
-------------------------------------------------------------------------------------------------------------	
IF vLong <> 9 and vLong <> 11 and vLong <> 12 and vLong <> 16 THEN 
	LET vCod_ret = '00004';
	LET vMensaje = 'ERROR CONSULTA DATOS CTA';
    RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
END IF;
 
SELECT COUNT(DISTINCT(num_cliente)) 
		INTO vVerif_val 
		FROM bdibpi:bpi_registro_bex 
		WHERE fecha_registro >= l_Fecha  
		AND imei = pImei 
		AND udid = pUdid
		AND estatus_servicio = '2';
IF vVerif_val >= 2 THEN 
	LET vCod_ret = '00008';
	LET vMensaje = 'LIMITE DE REGISTROS';
	RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;					
END IF;


IF  vLong=9 THEN  

	LET vxNumcte = pCtaTjCte;

ELIF vLong=11 THEN  
	SELECT num_cte
	INTO vxNumcte 
	FROM bdicheq:sc_maechq 
	WHERE cuenta= pCtaTjCte;
	IF TRIM(NVL(vxNumcte,'')) = '' THEN
	    LET vCod_ret = '00004';
		LET vMensaje = 'ERROR CONSULTA DATOS CTA';
		RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
	END IF;				 
ELIF vLong=12 THEN	
	SELECT numcte
		  INTO vxNumcte
		  FROM bdicred:sd_maecred 
		 WHERE num_credito = pCtaTjCte;					
	IF TRIM(NVL(vxNumcte,'')) = '' THEN
	    LET vCod_ret = '00004';
		LET vMensaje = 'ERROR CONSULTA DATOS CTA';
		RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
	END IF;				 
ELSE
    LET vBin = SUBSTR(pCtaTjCte,1,6);
	SELECT creditodebito
        	INTO vIndtar 
	        FROM intercard:bines 
	        WHERE bin = vBin;
	IF TRIM(NVL(vIndtar,'')) = '' THEN
	    LET vCod_ret = '00004';
		LET vMensaje = 'ERROR CONSULTA DATOS TAR';
		RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
	END IF;				 
	IF  vIndtar = "D" THEN
    	  SELECT numcte 
				INTO vxNumcte 
				FROM bdicheq:sc_tarjeta 
				WHERE num_tarjeta = pCtaTjCte;
	    IF TRIM(NVL(vxNumcte,'')) = '' THEN
	       LET vCod_ret = '00004';
		   LET vMensaje = 'ERROR CONSULTA DATOS TAR';
		   RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
	    END IF;				 					
	ELSE
    	SELECT numcte 
				INTO vxNumcte 
				FROM bdicred:sd_tarjeta 
				WHERE num_tarjeta = pCtaTjCte;
	    IF TRIM(NVL(vxNumcte,'')) = '' THEN
	       LET vCod_ret = '00004';
		   LET vMensaje = 'ERROR CONSULTA DATOS TAR';
		   RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
	    END IF;
    END IF;		
END IF;

SELECT COUNT(DISTINCT(imei||udid)) 
				INTO vVerif_val 
				FROM bdibpi:bpi_registro_bex 
				WHERE fecha_registro >= l_Fecha 
				AND num_cliente = vxNumcte
				AND estatus_servicio = '2';
				
IF vVerif_val >= 2 THEN 
	LET vCod_ret = '00008';
	LET vMensaje = 'LIMITE DE REGISTROS';
	RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;					
END IF;

SELECT fecha_nac 
		INTO vFecnac 
		FROM bdinteg:si_ctepf 
		WHERE numcte = vxNumcte;

IF TRIM(NVL(vFecnac,'')) <> pFechaNac THEN
    LET vCod_ret = '00004';
    LET vMensaje = 'ERROR CONSULTA DATOS CTE';
    RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
END IF;

/* Se cambia la tabla de consulta de si_telefonos_actual por si_telefonos
SELECT telefono 
  	INTO vNumTel 
	FROM bdinteg:si_telefonos_actual 
	WHERE numcte = vxNumcte
	AND tipo_tel = '2' 
	AND status_tel = 'A';
	*/
	
SELECT telefono
  	INTO vNumTel 
	FROM bdinteg:si_telefonos
	WHERE numcte = vxNumcte
	--AND telefono = vNumtel
	AND tipo_tel = '2' 
	AND status_tel = 'A';	

IF TRIM(NVL(vNumtel,'')) <> pNumTel THEN
	LET vCod_ret = '00004';
	LET vMensaje = 'ERROR CONSULTA DATOS CTE';
	RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
END IF;
		
SELECT  numcte, apell_paterno, apell_materno, nombre1, nombre2
		INTO vNumcte, vApell1, vApell2, vNombre1, vNombre2 
		FROM bdinteg:si_cliente 
		WHERE numcte = vxNumcte;
IF TRIM(NVL(vNumcte,'')) = '' THEN
	LET vCod_ret = '00004';
	LET vMensaje = 'ERROR CONSULTA DATOS CTE';
	RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
END IF;		

SELECT correo_elec 
    	INTO vCorreo 
		FROM bdinteg:si_correos  
	   WHERE numcte = vxNumcte 
		 AND status_correo = 'A' 
		 AND tipo_correo = '1';
IF TRIM(NVL(vCorreo,'')) = '' THEN
    LET vCod_ret = '00007';
	LET vMensaje = 'CLIENTE SIN CORREO';
	RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
END IF;

SELECT LIMIT 1 1 , estatus_servicio
		INTO vExistCelDisp,vEstatusSer
		FROM bdibpi:bpi_registro_bex 
		WHERE no_celular = pNumTel 
		AND imei=pImei 
		AND udid=pUdid
		AND estatus_servicio <> '2';

IF vExistCelDisp > 0 THEN		
		LET vCod_ret = '00003';
		LET vMensaje = 'NUMERO Y DISPOSITIVO ACTIVO';
        RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
END IF;

SELECT LIMIT 1 1 ,estatus_servicio
  INTO vExistCel ,vEstatusSer
  FROM bdibpi:bpi_registro_bex
 WHERE no_celular = pNumTel
   AND estatus_servicio <> '2';
   
IF NVL(vExistCel,0) > 0 THEN 
	LET vCod_ret = '00001';
	LET vMensaje = 'NUMERO TELEFONICO CON BEX';
	
	SELECT {+INDEX(bdibpi:bpi_registro_bex idx_udidImei)} COUNT(imei) 
		INTO vExistDispo 
		FROM bdibpi:bpi_registro_bex 
		WHERE imei=pImei 
		AND udid=pUdid 
		AND estatus_servicio <> '2';
	IF vExistDispo > 0 THEN
		LET vCod_ret = '00002';
		LET vMensaje = 'DISPOSITIVO ACTIVO';
	END IF
       RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
	   
END IF;

SELECT {+INDEX(bdibpi:bpi_registro_bex idx_udidImei)} COUNT(imei) 
		INTO vExistDispo 
		FROM bdibpi:bpi_registro_bex 
		WHERE imei=pImei 
		AND udid=pUdid 
		AND estatus_servicio <> '2';
IF vExistDispo > 0 THEN
	LET vCod_ret = '00002';
	LET vMensaje = 'DISPOSITIVO ACTIVO';
    RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
END IF;

LET vCod_ret = '00000';
LET vMensaje 	= 'CORRECTO';
RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;

END

END PROCEDURE;