CREATE PROCEDURE "informix".sp_sw_ro_consfacultadosxcta(pUsuario CHAR(8), pIdFunciON CHAR(10), pNumCuenta CHAR(20), pNumRegistros INT, 
												pRecuperaciON INT)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS no_cliente,
		CHAR(20) AS cuenta,
		CHAR(140) AS nombre,
		CHAR(1) AS tipo_participe,
		CHAR(30) AS participacion
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cNoCliente CHAR(20);
	DEFINE cNoCuenta CHAR(20);
	DEFINE cNombre CHAR(140);
	DEFINE cParticipaciON CHAR(1);
	DEFINE cDescParticipaciON CHAR(30);
	DEFINE iRegs INT;
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNoCliente = '';
	LET cNoCuenta = '';
	LET cNombre = '';
	LET cParticipaciON = '';
	LET cDescParticipaciON = '';
	LET iRegs = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNoCliente, cNoCuenta, cNombre, 
					cParticipacion, cDescParticipacion;
		END EXCEPTION;
		IF pUsuario = ''OR pIdFunciON = ''OR pNumCuenta = ''OR pNumRegistros = ''OR pRecuperaciON = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNoCliente, cNoCuenta, cNombre, 
					cParticipacion, cDescParticipacion;
		END IF;
		-- Busqueda como firmante en captacion
		LET cDescParticipaciON = 'FIRMANTE CAPTACION';
		LET cParticipaciON = '2';
		SET ISOLATION TO DIRTY READ;
		FOREACH SELECT skip pNumRegistros FIRST pRecuperaciON numcte, cuenta, TRIM(TRIM(nombre)||' '||TRIM(apellidos)) AS nombre 
				INTO cNoCliente, cNoCuenta, cNombre
				FROM bdicheq:sc_firmantes WHERE cuenta = pNumCuenta
					AND secuencia <> 1
					
			select trim(trim(trim(trim(nombre1)||' '||trim(nombre2))||' '||trim(apell_paterno))||' '||trim(apell_materno)||' '||trim(razon_social)) as nombre
			into cNombre
			from bdinteg:si_cliente
			where numcte = cNoCliente;
					
			LET iRegs = iRegs + 1;
			RETURN cCodRet, cNoCliente, cNoCuenta, cNombre, 
					cParticipacion, cDescParticipaciON 
				WITH resume;
		END FOREACH;
		--Busqueda como adicional en credito
		LET cDescParticipaciON = 'ADICIONAL CREDITO';
		LET cParticipaciON = '4';
		SET ISOLATION TO DIRTY READ;
		FOREACH 
			SELECT skip pNumRegistros FIRST pRecuperaciON numcte, num_credito, TRIM(nombre)
				INTO cNoCliente, cNoCuenta, cNombre
				FROM bdicred:sd_tarjeta 
				WHERE num_credito = pNumCuenta
				
			select trim(trim(trim(trim(nombre1)||' '||trim(nombre2))||' '||trim(apell_paterno))||' '||trim(apell_materno)||' '||trim(razon_social)) as nombre
			into cNombre
			from bdinteg:si_cliente
			where numcte = cNoCliente;	
				
			LET iRegs = iRegs + 1;
			RETURN cCodRet, cNoCliente, cNoCuenta, cNombre, 
						cParticipacion, cDescParticipaciON 
					WITH resume;
		END FOREACH;
		--Busqueda como cotitular en inversiones
		LET cDescParticipaciON = 'COTITULAR INVERSIONES';
		LET cParticipaciON = '5';
		SET ISOLATION TO DIRTY READ;
		FOREACH 
			SELECT a.numcte, a.cuenta, TRIM(TRIM(TRIM(b.nombre1)||' '||TRIM(b.nombre2))||' '||TRIM(TRIM(b.apell_paterno)||' '||TRIM(b.apell_materno))) AS nombre
				INTO cNoCliente, cNoCuenta, cNombre
				FROM bdinvers:sv_cotitular a LEFT JOIN bdinteg:si_cliente b ON b.numcte = a.numcte
				WHERE a.cuenta = pNumCuenta
				
			select trim(trim(trim(trim(nombre1)||' '||trim(nombre2))||' '||trim(apell_paterno))||' '||trim(apell_materno)||' '||trim(razon_social)) as nombre
			into cNombre
			from bdinteg:si_cliente
			where numcte = cNoCliente;	
				
			LET iRegs = iRegs + 1;
			RETURN cCodRet, cNoCliente, cNoCuenta, cNombre, 
					cParticipacion, cDescParticipaciON 
				WITH resume;
		END FOREACH;
		IF iRegs = 0 THEN
			LET cDescParticipaciON = '';
			LET cParticipaciON = '';
			LET cCodRet = '01001';
			RETURN cCodRet, cNoCliente, cNoCuenta, cNombre, 
					cParticipacion, cDescParticipacion;
		END IF;
	END
END PROCEDURE;