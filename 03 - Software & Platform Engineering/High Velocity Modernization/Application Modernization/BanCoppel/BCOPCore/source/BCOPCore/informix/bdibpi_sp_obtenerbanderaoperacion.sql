CREATE PROCEDURE "informix".sp_obtenerbanderaoperacion(pTipoOper1 INT, pTipoOper2 INT, pTipoOper4 INT)
RETURNING CHAR (5), CHAR(1);

	-- Creador: Javier Calderón
	-- Objetivo: Obtiene el estado de la bandera de una operacion
	-- Solicitó: Diana Castellanos
	-- Fecha: 19/11/2010


	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vBandera BOOLEAN;
	DEFINE vResBandera CHAR(1);

	DEFINE vcCodRet CHAR (5);
	DEFINE vcCierreCred CHAR(1);
	DEFINE vcDisponCred CHAR(1);
	DEFINE vcCierreCheq CHAR(1);
	DEFINE vcDisponCheq CHAR(1);
	DEFINE vcCierreInv CHAR(1);
	DEFINE vcDisponInv CHAR(1);
	DEFINE vcCierreServ CHAR(1);

	--SET DEBUG FILE TO "/home/informix/bibiana/sp_obtenerbanderaoperacion.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vResBandera;
		  END IF ;
		END EXCEPTION ;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		LET vCod_ret = '00000';
		LET vBandera = 'f';
		LET vResBandera = 'f';

		LET vcCodRet = '00000';


		EXECUTE PROCEDURE bdinteg:"informix".verifica_sistemas()
		INTO vcCodRet, vcCierreCred, vcDisponCred, vcCierreCheq, vcDisponCheq, vcCierreInv, vcDisponInv, vcCierreServ;

		IF (pTipoOper1 = 1 and pTipoOper2 = 2 and pTipoOper4 = 4) THEN--GDF

			IF (vcDisponCheq = '1' and vcDisponCred = '1' and vcCierreServ = '1') THEN
				LET vResBandera = 'f';
			ELSE
				LET vResBandera = 't';
			END IF;

		ELIF (pTipoOper1 = 1 and pTipoOper2 = 2) THEN--TDC

			IF (vcDisponCheq = '1' and vcDisponCred = '1') THEN
				LET vResBandera = 'f';
			ELSE
				LET vResBandera = 't';
			END IF;

		ELIF (pTipoOper1 = 1 and pTipoOper4 = 4) THEN--Pagos de Servicios

			IF (vcDisponCheq = '1' and vcCierreServ = '1') THEN
				LET vResBandera = 'f';
			ELSE
				LET vResBandera = 't';
			END IF;

		ELIF (pTipoOper1 = 1) THEN-- ctas propias, terceros, TDC otros bancos, SPEI

			IF (vcDisponCheq = '1') THEN
				LET vResBandera = 'f';
			ELIF (vcDisponCheq = '0') THEN
				LET vResBandera = 't';
			END IF;

		END IF;


		RETURN vCod_ret, vResBandera;
	END;
END PROCEDURE
DOCUMENT
'Folio: 1440',
'Autor: 95586776',
'Fecha: 06/05/2014',
'Modificación: Se modifica para que ejecute el sp: verifica_sistemas y verifique los cierre de sistemas',
'Sustento: Independencia de Sistemas',
'Solicita: Alejandro Vazquez',
'BD: Bdibpi';

CREATE PROCEDURE "informix".sp_valida_servicio_bex(pNumTel CHAR(10),pFechaNac DATE, pUdid CHAR(150),pImei CHAR(150))
   returning CHAR(5) AS Cod_ret,CHAR(50) AS mensaje,CHAR(10) AS NumCte,CHAR(26) AS Apell1,CHAR(26) AS Apell2,CHAR(26) as Nombre1 ,CHAR(26) AS Nombre2 ,CHAR(1) AS EstatusSer, INTEGER AS CtaDig, CHAR(30) AS Correo;

   --Definimos variables
   DEFINE sql_err  		INTEGER;
   DEFINE vCod_ret 		CHAR(5);
   DEFINE vMensaje 		CHAR(50);
   DEFINE vNumcte1 		CHAR(10);
   DEFINE vNumcte  		CHAR(10);
   DEFINE vNumTel  		CHAR(10);
   DEFINE vApell1  		CHAR(26);
   DEFINE vApell2  		CHAR(26);
   DEFINE vNombre1 		CHAR(26);
   DEFINE vNombre2 		CHAR(26);
   DEFINE vEstatusSer 	CHAR(1);
   DEFINE vExistCte		INTEGER;
   DEFINE vCtaDig		INTEGER;
   DEFINE vCorreo		CHAR(30);
   
   LET vCod_ret 		= '00000';
   LET vNumcte  		= '';
   LET vApell1  		= '';
   LET vApell2  		= '';
   LET vNombre1 		= '';
   LET vNumTel			= '';
   LET vNombre2 		= '';
   LET vEstatusSer 		= '0';
   LET vExistCte		= 0;
   LET vCtaDig 			= 0;
   LET vMensaje 		= 'CORRECTO';
   LET vCorreo			= '';
   
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;   
   
	--SET DEBUG FILE TO "/informix/ireb/bdibpi/bex/sp_valida_servicio_bex2.out";
	--TRACE ON;
   
BEGIN

    ON EXCEPTION SET sql_err
            IF sql_err <> 0 THEN
                    LET vCod_ret = sql_err;
					LET vEstatusSer 	= '';
                    RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo; 
            END IF;
    END EXCEPTION;

	IF( NVL(pNumTel,'')='' OR NVL(pFechaNac,'')='' OR NVL(pUdid,'')='' OR NVL(pImei,'')='')THEN
		LET vCod_ret = '00006';
		LET vMensaje = 'FALTAN DATOS';
		   RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo; 
	END IF;
	
	
	--Valida Numero celular y dispositivo para el servicio BanCoppel Express
	
	IF EXISTS( SELECT no_celular FROM bdibpi:bpi_registro_bex WHERE no_celular = pNumTel AND imei=pImei AND udid=pUdid AND estatus_servicio <> '2') THEN
		
		SELECT estatus_servicio INTO vEstatusSer FROM bdibpi:bpi_registro_bex WHERE no_celular = pNumTel AND imei=pImei AND udid=pUdid AND estatus_servicio <> '2';
		
		LET vCod_ret = '00003';
		LET vMensaje = 'NUMERO Y DISPOSITIVO ACTIVO';
	END IF
	
	IF EXISTS( SELECT no_celular FROM bdibpi:bpi_registro_bex WHERE imei=pImei AND udid=pUdid AND estatus_servicio <> '2') THEN
		LET vCod_ret = '00002';
		LET vMensaje = 'DISPOSITIVO ACTIVO';
	END IF
	
	IF EXISTS( SELECT no_celular FROM bdibpi:bpi_registro_bex WHERE no_celular = pNumTel AND estatus_servicio <> '2') THEN
		LET vCod_ret = '00001';
		LET vMensaje = 'NUMERO TELEFONICO CON BEX';
	END IF
		
	
	
	--Valida que el telefono este dado de alta en bancoppel
	
	SELECT COUNT(numcte) INTO vExistCte FROM bdinteg:si_telefonos_actual b 
	WHERE status_tel = 'A' AND tipo_tel = '2' 
	AND telefono=pNumTel;
	
	IF vExistCte > 0 THEN

	--obtiene los datos del cliente
	
	SELECT a.numcte, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2 --, d.correo_elec
	INTO vNumcte, vApell1, vApell2, vNombre1, vNombre2 --,vCorreo
	FROM bdinteg:si_cliente a, bdinteg:si_telefonos_actual b, bdinteg:si_ctepf c --,  bdinteg:si_correos d
	WHERE a.numcte=b.numcte  AND a.numcte = c.numcte AND b.status_tel = 'A'  --AND a.numcte=d.numcte AND d.status_correo ='A' AND d.tipo_correo ='1'
	AND b.tipo_tel = '2'  AND b.telefono=pNumTel AND c.fecha_nac=pFechaNac;
	
	
	
	SELECT correo_elec into vCorreo FROM  bdinteg:si_correos  WHERE  numcte = vNumcte AND status_correo ='A' AND tipo_correo ='1';
	
	
		IF (NVL(vNumcte,'') <> '')	THEN
	
			--SELECT COUNT(telefono)	INTO vCtaDig  
			--FROM bdicheq:"informix".sc_cuenta_telefono 	WHERE num_cte=vNumcte	AND es_transfer='R'; --Valida que no tenga servicio cuenta digital Transfer
	
			IF vCod_ret = '00000' THEN
				LET vMensaje 	= 'CORRECTO';
			END IF			
			
			IF 	NVL(vCorreo,'') = '' THEN 
		
			LET vCod_ret = '00007';
			LET vMensaje = 'CLIENTE SIN CORREO';
		
			END IF			
				
		   RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
		
		ELSE 
			
			LET vCod_ret = '00004';
			LET vMensaje = 'ERROR CONSULTA DATOS CLIENTE';
			  
		END IF
		
		
	ELSE
		LET vCod_ret 	= '00005';
		LET vMensaje = 'CELULAR NO REGISTRADO EN BCPPEL';
	END IF
		
    RETURN vCod_ret,vMensaje,vNumcte, vApell1, vApell2, vNombre1, vNombre2, vEstatusSer, vCtaDig, vCorreo;
   
END

END PROCEDURE;