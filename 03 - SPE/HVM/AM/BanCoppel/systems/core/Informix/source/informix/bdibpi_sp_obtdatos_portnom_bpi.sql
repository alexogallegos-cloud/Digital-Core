CREATE PROCEDURE "informix".sp_obtdatos_portnom_bpi(pEmpresa CHAR(3),pCliente CHAR(20))
RETURNING 
	CHAR(5)		AS 	CodRet,
	DATE 		AS 	FechaNac,
	CHAR(100) 	AS 	Correo,
	CHAR(13) 	AS 	Telefono,
	SMALLINT 	AS 	Compania;
	
	-- Creador: Moisés Soriano
	-- Objetivo: Obtiene los datos del cliente para la portabilidad de nómina.
	-- Solicitó: Alejandro Vazquez
	-- Fecha: 10/02/2016
	
	--DECLARACIN DE VARIABLES
	DEFINE cCodRet				CHAR(5);
	DEFINE cSqlErr				INT;
	DEFINE vdFechaNac			DATE;
	DEFINE vcCorreo				CHAR(100);
	DEFINE vcTelefono			CHAR(13);
	DEFINE viCompania			SMALLINT;
	
	--INICIALIZACION DE VARIABLES
	LET cCodRet					= '00000';
	LET cSqlErr					= 0;
	LET vdFechaNac				= '01-01-1900';
	LET vcCorreo				= '';
	LET vcTelefono				= '';
	LET viCompania				= 0;
	
	BEGIN	
		ON EXCEPTION SET cSqlErr
			IF cSqlErr <> 0 THEN
				LET cCodRet = cSqlErr;
				RETURN cCodRet,vdFechaNac,vcCorreo,vcTelefono,viCompania;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/home/sysifx/moises/bdicheq/sp_obtdatos_portnom_bpi.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pCliente, '') = '' THEN
			LET cCodRet = '001';
			RETURN cCodRet,vdFechaNac,vcCorreo,vcTelefono,viCompania;
		END IF;
		
		SELECT fecha_nac INTO vdFechaNac
		FROM BDINTEG:"informix".si_ctepf 
		WHERE numcte = pCliente;
		
		SELECT correo_elec INTO vcCorreo 
		FROM BDINTEG:"informix".si_correos 
		WHERE numcte = pCliente
		AND status_correo = 'A';
				
		SELECT telefono, carrier INTO vcTelefono, viCompania
		FROM BDINTEG:"informix".si_telefonos_actual 
		WHERE numcte = pCliente AND tipo_tel = '2';
		
		RETURN cCodRet,vdFechaNac,NVL(vcCorreo,''),NVL(vcTelefono,''),NVL(viCompania,0);
		
	END;
END PROCEDURE;