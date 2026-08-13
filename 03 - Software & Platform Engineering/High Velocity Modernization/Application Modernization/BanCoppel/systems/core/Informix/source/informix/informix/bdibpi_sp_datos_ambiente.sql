CREATE PROCEDURE "informix".sp_datos_ambiente(pMovAhorro CHAR(4),
													pMovCredito CHAR(4),
													pEdoCtaAho CHAR(4),
													pEdoCtaCre CHAR(4),
													pTransCtasPro CHAR(4),
													pTDCPropia CHAR(4),
													pCtasTerceros CHAR(4),
													pPagoOtroBanco CHAR(4),
													pPagoTelmex CHAR(4),
													pPagoServSky CHAR(4),
													pCheques CHAR(4),
													pTransSpei CHAR(4),
													pTDCTercerosBC CHAR(4),
													pPagoAvon CHAR(4),
													pPagoSerDish CHAR(4),
													pPagoSerMasTv CHAR(4),
													pNumCte char(20),
													pRegistros SMALLINT
													)
RETURNING CHAR(5),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),CHAR(50),
CHAR(4),CHAR(8),CHAR(8),CHAR(150),CHAR(10),char(10),char(200),char(1);


	--DECLARACION DE VARIABLES
	DEFINE vCod_Ret CHAR(5);
	DEFINE sql_err INTEGER ;
	DEFINE vIdOpe CHAR(4);
	DEFINE vProducto CHAR(4);
	DEFINE vMovAhorro VARCHAR(50);
	DEFINE vMovCredito VARCHAR(50);
	DEFINE vEdoCtaAhorro VARCHAR(50);
	DEFINE vEdoCtaCredito VARCHAR(50);
	DEFINE vTransCtasPropias VARCHAR(50);
	DEFINE vTDCPropia VARCHAR(50);
	DEFINE vCtasTerceros VARCHAR(50);
	DEFINE vPagoTelmex VARCHAR(50);
	DEFINE vCheques VARCHAR(50);
	DEFINE vPagoOtroBanco VARCHAR(50);
	DEFINE vPagoServSKY VARCHAR(50);	
	DEFINE vTransSPEI VARCHAR(50);
	DEFINE vPagoAvon VARCHAR(50);
	DEFINE vPagoTDCTercerosBC VARCHAR(50);
	DEFINE vPagoSerDish VARCHAR(50);
	DEFINE vPagoSerMasTv VARCHAR(50);
--***************************************************
	--DECLARACION DE VARIABLES
	--DEFINE vCod_Ret CHAR(5);
	--DEFINE sql_err INTEGER ;
	DEFINE vIdOper CHAR(4);
	DEFINE vH_Ini_Baja CHAR(8);
	DEFINE vH_Fin_Baja	CHAR(8);
	DEFINE vMsn_TimeOut CHAR(150);
	DEFINE vFec_Baja CHAR(10);
	DEFINE vIcont INTEGER;
	DEFINE vDescAvatar char(10);
	DEFINE vFrase char(200);
	DEFINE vDescAvatar_ANT char(1);
	

--****************************************************


		
	--INICIALIZAR VALORES A VARIABLES;
	LET vCod_Ret='00000';
	LET vIdOpe = '';
	LET vProducto = '';
	
	LET vMovAhorro ='1004';
	LET vMovCredito ='1005';
	LET vEdoCtaAhorro ='1006';
	LET vEdoCtaCredito ='1007';
	LET vTransCtasPropias ='1008';
	LET vTDCPropia ='1011';
	LET vTransSPEI='1015';
	LET vCtasTerceros ='1016';
	LET vPagoOtroBanco ='1017';
	LET vPagoTelmex ='1020';
	LET vPagoServSKY ='1021';	
	LET vCheques ='1CHQ';
	LET vDescAvatar_ANT = '';
	LET vPagoAvon = '1033';
	LET vPagoTDCTercerosBC = '1027';
	LET vPagoSerDish = '1022';
	LET vPagoSerMasTv = '1023';
--********************************************************
	--INICIALIZAR VALORES A VARIABLES;
	--LET vCod_Ret='00000';
	LET vIdOper='';
	LET vH_Ini_Baja='01-01-1900';
	LET vH_Fin_Baja='01-01-1900';
	LET vMsn_TimeOut='';
	LET vFec_Baja='';
	
	LET vIcont=0;
	LET vDescAvatar='';
	LET vFrase='';
--*********************************************************	

	--Modifica: Walber Castro
    --Actividad: Se modifica a causa de errores de sintaxis así como se adecua de acuerdo a las nuevas reglas de informix.
    --Solicito: Diana Castellanos
    --Fecha: 08/07/2011
	--Modifica: Walber Castro
	--Actividad: Se agrega un nuevo parámetro de salida, es una bandera que indica 1 si el cte tiene avatar configurado con la versión anterior y 0 en caso contrario.
	--Fecha: 18/07/2011
	--Modifica: Ismael Hernandez
	--Actividad: Se modifica la consulta del nombre de la imagen del avatar para que convivan las dos versiones de portales, la actual y la reingenieria.
	--Fecha: 21/03/2013
    --Clave: 210313
	--Modifica: Roberto Castro
	--Actividad: Se agregan dos nuevos id's de operacion: Pago de Servicios Avon y pago TDC Terceros Bancoppel
	--Fecha: 25/08/2014

	--SET DEBUG FILE TO '/home/sysifx/roberto/Trace/sp_datos_ambiente.out';
	--TRACE ON;
SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_Ret = sql_err;
				RETURN vCod_Ret,vMovAhorro,vMovCredito,vEdoCtaAhorro,vEdoCtaCredito,vTransCtasPropias,vTDCPropia,vCtasTerceros,vPagoOtroBanco,vPagoTelmex,vPagoServSKY,vCheques,vTransSPEI,vPagoTDCTercerosBC,vPagoAvon,vPagoSerDish,vPagoSerMasTv,vIdOper,vH_Ini_Baja,vH_Fin_Baja,vMsn_TimeOut,vFec_Baja,vDescAvatar, vFrase, vDescAvatar_ANT;
		  END IF ;
		END EXCEPTION ;

SET ISOLATION TO DIRTY READ;
	
	
	
		FOREACH
			SELECT id_oper,producto
				INTO vIdOpe,vProducto
				FROM bdibpi:"informix".bpi_pprod
				WHERE id_oper IN(pMovAhorro,pMovCredito,pEdoCtaAho,pEdoCtaCre,pTransCtasPro,pTDCPropia,pCtasTerceros,pPagoOtroBanco,pPagoTelmex,pPagoServSky,pCheques,pTransSpei,pTDCTercerosBC,pPagoAvon,pPagoSerDish,pPagoSerMasTv)
				ORDER BY id_oper
				
				IF(vIdOpe=pMovAhorro)     THEN	LET vMovAhorro=vMovAhorro||vProducto;	            END IF;
				IF(vIdOpe=pMovCredito)    THEN	LET vMovCredito=vMovCredito||vProducto;	            END IF;
				IF(vIdOpe=pEdoCtaAho)     THEN	LET vEdoCtaAhorro=vEdoCtaAhorro||vProducto;	        END IF;
				IF(vIdOpe=pEdoCtaCre)     THEN  LET vEdoCtaCredito=vEdoCtaCredito||vProducto;       END IF;
				IF(vIdOpe=pTransCtasPro)  THEN	LET vTransCtasPropias=vTransCtasPropias||vProducto;	END IF;
				IF(vIdOpe=pTDCPropia)     THEN	LET vTDCPropia=vTDCPropia||vProducto;	            END IF;
				IF(vIdOpe=pCtasTerceros)  THEN	LET vCtasTerceros=vCtasTerceros||vProducto;         END IF;
				IF(vIdOpe=pPagoOtroBanco) THEN	LET vPagoOtroBanco=vPagoOtroBanco||vProducto;	    END IF;
				IF(vIdOpe=pPagoTelmex)    THEN	LET vPagoTelmex=vPagoTelmex||vProducto;	            END IF;
				IF(vIdOpe=pPagoServSky)   THEN	LET vPagoServSKY=vPagoServSKY||vProducto;	        END IF;
				IF(vIdOpe=pCheques)       THEN	LET vCheques=vCheques||vProducto; 	                END IF;
				IF(vIdOpe=pTransSpei)	  THEN  LET vTransSPEI=vTransSPEI||vProducto;				END IF;
				IF(vIdOpe=pTDCTercerosBC) THEN	LET vPagoTDCTercerosBC=vPagoTDCTercerosBC||vProducto;  END IF;
				IF(vIdOpe=pPagoAvon)      THEN	LET vPagoAvon=vPagoAvon||vProducto;		            END IF;
				IF(vIdOpe=pPagoSerDish)   THEN	LET vPagoSerDish=vPagoSerDish||vProducto;			END IF;
				IF(vIdOpe=pPagoSerMasTv)  THEN	LET vPagoSerMasTv=vPagoSerMasTv||vProducto;			END IF;
				
		END FOREACH;
--************************************************************************************************
--Datos del Avatar
--***********************************************************************************************
---210313 
		IF EXISTS ( SELECT num_cte FROM bdibpi:"informix".bpi_avatar WHERE num_cte = pNumCte ) THEN
			--SELECT imagen, frase ,CASE WHEN LENGTH(TRIM(avatar)) > 0 THEN 1 ELSE 0 END
            SELECT CASE WHEN LENGTH(TRIM(imagen)) = 4 THEN "avatar" || substring(imagen FROM 4 FOR 1) ELSE imagen END, frase ,CASE WHEN LENGTH(TRIM(avatar)) > 0 THEN 1 ELSE 0 END
			INTO vDescAvatar, vFrase, vDescAvatar_ANT
			FROM bdibpi:"informix".bpi_avatar
			WHERE num_cte = pNumCte;		
		END IF;

--***********************************************************************************************FIN


--**********************************************************************************************************************************
--Horarios de Operacion
--**********************************************************************************************************************************

		FOREACH
		
			SELECT SKIP pRegistros FIRST 8 id_oper, h_ini_baja::CHAR(8), h_fin_baja::CHAR(8),msn_timeout,fecha_baja 
			INTO vIdOper,vH_Ini_Baja,vH_Fin_Baja,vMsn_TimeOut,vFec_Baja
			 FROM bdibpi:"informix".bpi_cat_operaciones
			     WHERE id_oper NOT IN ('1000','1001' ,'1002' ,'1003')
			 ORDER BY id_oper
			 
			 IF (vIdOper<>'' OR vIdOper IS NOT NULL) THEN
				LET vIcont=1;
				RETURN vCod_Ret,vMovAhorro,vMovCredito,vEdoCtaAhorro,vEdoCtaCredito,vTransCtasPropias,vTDCPropia,vCtasTerceros,vPagoOtroBanco,vPagoTelmex,vPagoServSKY,vCheques,vTransSPEI,vPagoTDCTercerosBC,vPagoAvon,vPagoSerDish,vPagoSerMasTv,vIdOper,vH_Ini_Baja,vH_Fin_Baja,vMsn_TimeOut,vFec_Baja,vDescAvatar, vFrase, vDescAvatar_ANT with resume;
			 END IF;
		 
		 END FOREACH;
		 
		 IF (vIcont=0) THEN
			LET vCod_Ret='00001';			RETURN vCod_Ret,vMovAhorro,vMovCredito,vEdoCtaAhorro,vEdoCtaCredito,vTransCtasPropias,vTDCPropia,vCtasTerceros,vPagoOtroBanco,vPagoTelmex,vPagoServSKY,vCheques,vTransSPEI,	vPagoTDCTercerosBC,vPagoAvon,vPagoSerDish,vPagoSerMasTv,vIdOper,vH_Ini_Baja,vH_Fin_Baja,vMsn_TimeOut,vFec_Baja,vDescAvatar, vFrase, vDescAvatar_ANT;
		 END IF;

--********************************************************************************************** FIN		
		END;
END PROCEDURE
DOCUMENT
'Folio: 1505',
'Autor: 95586776',
'Fecha: 21/10/2014',
'Modificación: Se agregan dos nuevos id operacion para pago de servicio Dish y MasTv',
'Sustento:RQI_03-330_PagoServicioseDishMasTVSky',
'Solicita: José de Jesus Nevarez Peinado',
'BD: Bdibpi';

CREATE PROCEDURE "informix".sp_valida_servicio_bex_pba(pNumTel CHAR(10),pFechaNac DATE, pUdid CHAR(150),pImei CHAR(150))
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