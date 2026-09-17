CREATE PROCEDURE "informix".sp_graba_intentos_bpi(pEmpresa CHAR(3),pUsuario CHAR(50), pTipo CHAR(1), pMosaicoImg CHAR(50))
RETURNING   CHAR(5),--Codigo de retorno.
			INTEGER,--Número de intentos.
			CHAR(1);
			--CHAR(50); -- Mosaico de Avatares
                
--****************************************************************************************************
-- DESCRIPCION:  Si el pTipo es 0 guarda el intento fallido, si el 1 reinicia los intentos.
-- AUTOR : Berenice Noriega Guevara
-- FECHA : 01/02/2013
-- BD: bdibpi
-- SOLICITO :Ismael Hernandez
-- También deberá registrar el mosaico de avatares presentados en pantalla.
--***************************************************************************************************
		
--Declaración de variables
DEFINE vCodRet CHAR(5);
DEFINE sql_err INTEGER;
DEFINE vbloqueo CHAR(1);
DEFINE vfechaBloqueo DATETIME YEAR to SECOND;
DEFINE vIntentos INTEGER;
DEFINE vNumCliente CHAR(9);

--Inicializar variables
LET vCodRet='00000';
--LET sql_err = 0;
LET vfechaBloqueo=current;
LET vNumCliente = '';
LET vbloqueo = '';
LET vIntentos = 0;

	--set debug file to "/home/informix/bibiana/sp_graba_intentos_bpi.out";
	--trace on;
	
BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET vCodRet = sql_err;
			RETURN vCodRet, '', '';
		END IF ;
	END EXCEPTION ;
	
	IF(pEmpresa <> '' OR pEmpresa IS NOT NULL OR pUsuario <>'' OR pUsuario IS NOT NULL OR pTipo<>'' OR pTipo IS NOT NULL) THEN
	
		IF EXISTS (SELECT numcte FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND usuario=TRIM(pUsuario) ) THEN
		
			SELECT numcte INTO vNumCliente 
			FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND usuario=TRIM(pUsuario);

			SELECT  bloqueo_temporal, num_intentos_bloqtemp INTO vbloqueo, vIntentos 
			FROM  bdibpi:"informix".bpi_avatar WHERE num_cte=vNumCliente;
			
			IF(vbloqueo='F')THEN
				--Intento Fallido	
				IF (pTipo=0)THEN
					IF (vIntentos = 0)THEN
						LET vIntentos = vIntentos + 1;
						--Actualiza a 1 el número de intentos y registra el mosaico de avatares presentados.
						update bdibpi:"informix".bpi_avatar set num_intentos_bloqtemp=vIntentos, mosaico_img = pMosaicoImg WHERE num_cte=vNumCliente;
						update bdibpi:"informix".bpi_avatar set fecha_bloqtemp=vfechaBloqueo WHERE num_cte=vNumCliente;
					ELSE IF(vIntentos =1)THEN
						LET vIntentos = vIntentos + 1;
						update bdibpi:"informix".bpi_avatar set num_intentos_bloqtemp=vIntentos WHERE num_cte=vNumCliente;
					  ELSE IF(vIntentos = 2)THEN
						 LET vIntentos =vIntentos + 1;
						 LET vbloqueo='T'; 
						 update bdibpi:"informix".bpi_avatar set bloqueo_temporal=vbloqueo, num_intentos_bloqtemp=vIntentos WHERE num_cte=vNumCliente;
						 Else LET vCodRet='00003'; --Numero de intentos no corresponde al estatus 
						END IF; --ELIF =2
					  END IF; --ELIF =1
					END IF; --IF =0
			
				--Intento Exitoso
				ELSE IF (pTipo=1)THEN
					LET vIntentos=0;
					update bdibpi:"informix".bpi_avatar set num_intentos_bloqtemp=vIntentos, bloqueo_temporal = 'F', mosaico_img = '', fecha_bloqtemp= '' WHERE num_cte=vNumCliente;	
				ELSE LET vCodRet='00004'; --Tipo invalido
				END IF; --pTipo=1
				END IF; --pTipo=0
				
			ELSE LET vCodRet='00002'; --Usuario Bloqueado
			END IF;		
		ELSE
			LET vCodRet = '00005'; -- No existe el cliente
		END IF;
		
	ELSE LET vCodRet='00001';
	END IF;
		
	RETURN vCodRet, vIntentos, vbloqueo;
	
END
END PROCEDURE;