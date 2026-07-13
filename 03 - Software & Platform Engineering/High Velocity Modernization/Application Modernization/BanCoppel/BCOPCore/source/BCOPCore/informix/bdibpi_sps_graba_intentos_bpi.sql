CREATE PROCEDURE "informix".sps_graba_intentos_bpi(pEmpresa CHAR(3),pIdUsuario CHAR(11), pTipo CHAR(1), pMosaicoImg CHAR(50))
RETURNING   CHAR(5),--Codigo de retorno.
			INTEGER,--Número de intentos.
			CHAR(1);
--Declaración de variables
DEFINE cCodRet CHAR(5);
DEFINE iSql_err INTEGER;
DEFINE vbloqueo CHAR(1);
DEFINE dFechaBloqueo DATETIME YEAR to SECOND;
DEFINE iIntentos INTEGER;
DEFINE cNumCliente CHAR(9);

	--Descripción: Graba Intentos
	--22/04/2015

--Inicializar variables
LET cCodRet='00000';
LET dFechaBloqueo=current;
LET cNumCliente = '';
LET vbloqueo = '';
LET iIntentos = 0;

	--set debug file to "/home/informix/bibiana/sp_graba_intentos_bpi.out";
	--trace on;
	
BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, '', '';
		END IF ;
	END EXCEPTION ;
	
	IF(pEmpresa <> '' OR pEmpresa IS NOT NULL OR pIdUsuario <>'' OR pIdUsuario IS NOT NULL OR pTipo<>'' OR pTipo IS NOT NULL) THEN
	
		IF EXISTS (SELECT NUMCLIENTE FROM  bdibpi:"informix".bpi_usuario WHERE ID_USUARIO =TRIM(pIdUsuario) ) THEN
		
			SELECT NUMCLIENTE INTO cNumCliente 
			FROM bdibpi:"informix".bpi_usuario WHERE ID_USUARIO =TRIM(pIdUsuario);

			SELECT  bloqueo_temporal, num_intentos_bloqtemp INTO vbloqueo, iIntentos 
			FROM  bdibpi:"informix".bpi_avatar WHERE num_cte=cNumCliente;
			
			IF(vbloqueo='F')THEN
				--Intento Fallido	
				IF (pTipo=0)THEN
					IF (iIntentos = 0)THEN
						LET iIntentos = iIntentos + 1;
						--Actualiza a 1 el número de intentos y registra el mosaico de avatares presentados.
						update bdibpi:"informix".bpi_avatar set num_intentos_bloqtemp=iIntentos, mosaico_img = pMosaicoImg WHERE num_cte=cNumCliente;
						update bdibpi:"informix".bpi_avatar set fecha_bloqtemp=dFechaBloqueo WHERE num_cte=cNumCliente;
					ELSE IF(iIntentos =1)THEN
						LET iIntentos = iIntentos + 1;
						update bdibpi:"informix".bpi_avatar set num_intentos_bloqtemp=iIntentos WHERE num_cte=cNumCliente;
					  ELSE IF(iIntentos = 2)THEN
						 LET iIntentos =iIntentos + 1;
						 LET vbloqueo='T'; 
						 update bdibpi:"informix".bpi_avatar set bloqueo_temporal=vbloqueo, num_intentos_bloqtemp=iIntentos WHERE num_cte=cNumCliente;
						 Else LET cCodRet='00003'; --Numero de intentos no corresponde al estatus 
						END IF; --ELIF =2
					  END IF; --ELIF =1
					END IF; --IF =0
			
				--Intento Exitoso
				ELSE IF (pTipo=1)THEN
					LET iIntentos=0;
					update bdibpi:"informix".bpi_avatar set num_intentos_bloqtemp=iIntentos, bloqueo_temporal = 'F', mosaico_img = '', fecha_bloqtemp= '' WHERE num_cte=cNumCliente;	
				ELSE LET cCodRet='00004'; --Tipo invalido
				END IF; --pTipo=1
				END IF; --pTipo=0
				
			ELSE LET cCodRet='00002'; --Usuario Bloqueado
			END IF;		
		ELSE
			LET cCodRet = '00005'; -- No existe el cliente
		END IF;
		
	ELSE LET cCodRet='00001';
	END IF;
		
	RETURN cCodRet, iIntentos, vbloqueo;
	
END
END PROCEDURE;