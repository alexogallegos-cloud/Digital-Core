CREATE PROCEDURE "informix".sp_total_bitsmstelsms(pNumCliente CHAR(9),pNumTelefono CHAR(10))
   returning CHAR(5);

    DEFINE sql_err INTEGER ;
    DEFINE cCodRet CHAR(5);
	DEFINE iContador INTEGER;
	
	LET cCodRet='00000';
	
  --SET DEBUG FILE TO "/tmp/sp_total_bitsmstelsms.out";
  --TRACE ON;
  
BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCodRet = sql_err;
            RETURN cCodRet;
      END IF;
   END EXCEPTION;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	SELECT COUNT(numcte) 
	INTO iContador 
	FROM bdinteg:"informix".si_bitsmstelsms 
	WHERE numcte =pNumCliente AND DATE(fecha)=DATE(CURRENT);
	IF iContador>=10 THEN
		LET cCodRet='00001';
	ELSE
		LET cCodRet='00000';
	END IF;

	RETURN cCodRet;
	
END

END PROCEDURE
DOCUMENT
'FOLIO.........: 1616?BPI-ValidaNumeroCelular',
'AUTOR.........: Jose Ruben Lopez',
'FECHA.........: 30-11-2015',
'MODIFICACIÓN..: Se crea stored procedure para contabilizar las oportunidades de solicitud de clave nueva por sms',
'SOLICITA......: Walber Castro',
'BD............: BDINTEG',
'FOLIO.........: 1631-BPILogin',
'AUTOR.........: Edgar Alarcon',
'FECHA.........: 12-02-2016',
'MODIFICACIÓN..: Se verifica si es id de usuario o numero de cliente',
'SOLICITA......: Walber Castro',
'BD............: BDINTEG';

CREATE PROCEDURE "informix".sps_obtenerusuario(pNumCliente VARCHAR(9), pIndicador CHAR(1))
RETURNING CHAR (5), CHAR(50);

	-- Creador: Moises Soriano
	-- Objetivo: Se clona sp_obtenerusuario, se agrega parametro de entrada
	-- Solicitó: Moises Soriano
	-- Fecha: 08/04/2016
	
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vUsuario VARCHAR(50);
	DEFINE vNumCte VARCHAR(9);
	
	--SET DEBUG FILE TO "/home/informix/bibiana/sp_obtenerusuario.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vUsuario;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		LET vUsuario = '';
		
		SET LOCK MODE TO WAIT ;
		
		IF pIndicador = '1' THEN  -- pIndicador = id_usuario
			LET vNumCte = pNumCliente;
		ELIF pIndicador = '2' THEN -- pIndicador = numcliente
			SELECT id_usuario INTO vNumCte FROM bdibpi:"informix".bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
		END IF;
		
		SELECT usuario INTO vUsuario FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = vNumCte AND st_portal = 'activo';
		RETURN vCod_ret, vUsuario;
	END;

END PROCEDURE;