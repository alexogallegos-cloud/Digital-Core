CREATE PROCEDURE "informix".sp_inserta_doctos_admin_web(pEmpresa CHAR(3),pSucursal CHAR(4),pNumeroCaja CHAR(10),pTipoDocto SMALLINT,pFechaInicio DATE,pFechaFinal DATE,pEstatus CHAR(1),pUsuarioRegistra CHAR(8),pUsuarioAutoriza CHAR(8))
--DATOS A REGRESAR---
RETURNING	CHAR(5) AS cCodRet;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet			CHAR(5);
DEFINE  cSuc			CHAR(4);
DEFINE  cCajaAnt		CHAR(10);
DEFINE  sTipoDoctoT		SMALLINT;
DEFINE  cEstatus		CHAR(10);
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet			= '00000';
LET cSuc			= '';
LET cCajaAnt		= '';
LET sTipoDoctoT		= 0;
LET cEstatus		= '';
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/tmp/jairo/sp_inserta_doctos_admin.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' AND NVL(pNumeroCaja,'') <> '' AND NVL(pTipoDocto,0) <> 0 AND NVL(pFechaInicio,'') <> '' AND NVL(pFechaFinal,'') <> '' AND NVL(pEstatus,'') <> '' AND NVL(pUsuarioRegistra,'') <> '' AND NVL(pUsuarioAutoriza,'') <> '' THEN

		SELECT sucursal INTO cSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa AND sucursal = pSucursal;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '01309';
		ELSE
			SELECT numerocaja,estatus INTO cCajaAnt,cEstatus
			FROM bdisuc:"informix".ss_numcajas 
			WHERE empresa = pEmpresa AND numsucursal = pSucursal
			AND numerocaja = pNumeroCaja;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodret = '01309';
			ELSE
				
				IF cEstatus = 'Cerrada' THEN
					LET cCodret = '01328';
				ELIF cEstatus = 'Enviada' THEN
					LET cCodret = '01329';
				ELIF cEstatus = 'Eliminada' THEN
					LET cCodret = '01330';
				ELIF cEstatus = 'Activa' THEN
					
					SELECT tipodocumento INTO sTipoDoctoT
					FROM bdisuc:"informix".ss_cattipodocumento
					WHERE empresa = pEmpresa AND tipodocumento = pTipoDocto AND estatus = 'a';

					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodret = '01309';
					ELSE
						INSERT INTO bdisuc:"informix".ss_documentosadmon (empresa,numerocaja,tipodocumento,fechainicio,fechafinal,sucursal,estatus,usuarioregistra,usuarioautoriza,fecha_insert) 
						VALUES(pEmpresa,pNumeroCaja,pTipoDocto,pFechaInicio,pFechaFinal,pSucursal,pEstatus,pUsuarioRegistra,pUsuarioAutoriza,CURRENT);
					END IF;					
				END IF;							
			END IF;
		END IF;
	ELSE
		LET cCodRet ='01308';
	END IF
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'00000 - Exito',
'01309 - No Existe la Sucursal en si_sucursales',
'01328 - La caja se encuentra Cerrada.',
'01329 - La caja se encuentra Enviada.',
'01330 - La caja se encuentra Eliminada.',
'DESCRIPCION: Genera l numero de caja',
'AUTOR: Claudio Almodovar',
'Folio: 1759',
'Solicita: Rodolfo GÃ³mez',
'FECHA: 16/10/2015',
'BD: bdisuc',
'DESCRIPCION: Se modifica sp para retornar nuevos codigos cuando los estatus de cajas sean Cerrada,Enviada y Activa.',
'AUTOR: Jairo Valdez Gonzalez',
'Folio: 1772',
'Solicita: Rodolfo GÃ³mez',
'FECHA: 10/12/2015',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_inserta_numcaja_web(pEmpresa CHAR(3),pSucursal CHAR(4),pNumeroCaja CHAR(10),pUsuario CHAR(8),pSucursalCaja CHAR(4))
--DATOS A REGRESAR---
RETURNING	CHAR(5) AS cCodRet;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet			CHAR(5);
DEFINE  cSuc			CHAR(4);
DEFINE  cCajaAnt		CHAR(10);
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet			= '00000';
LET cSuc			= '';
LET cCajaAnt		= '';
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_inserta_numcaja.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' AND NVL(pNumeroCaja,'') <> '' AND NVL(pUsuario,'') <> '' AND NVL(pSucursalCaja,'') <> '' THEN

		SELECT sucursal INTO cSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa AND sucursal = pSucursal;

		IF NVL(cSuc,'') = '' THEN
			LET cCodret = '01309';
		ELSE
			SELECT sucursal INTO cSuc
			FROM bdinteg:"informix".si_sucursales
			WHERE empresa = pEmpresa AND sucursal = pSucursalCaja;

			IF NVL(cSuc,'') = '' THEN
				LET cCodret = '01309';
			ELSE
				SELECT numerocaja INTO cCajaAnt
				FROM bdisuc:"informix".ss_numcajas WHERE empresa = pEmpresa
				AND numsucursal = pSucursalCaja AND numerocaja = pNumeroCaja;

				IF NVL(cCajaAnt,'') <> '' THEN
					LET cCodret = '01312';
				ELSE
					INSERT INTO bdisuc:"informix".ss_numcajas (empresa,numerocaja,numsucursal,numsuc_crea,tipopaquete,fecha_insert,estatus,usuarioalta,fechaalta,numempleado_cajaocupada,fecha_cajaocupada)
					VALUES (pEmpresa,pNumeroCaja,pSucursalCaja,pSucursal,3,CURRENT,'Activa',pUsuario,CURRENT,pUsuario,CURRENT);
				END IF;
			END IF;
		END IF;
	ELSE
		LET cCodRet ='01308';
	END IF
	RETURN cCodRet;
END;
END PROCEDURE
;