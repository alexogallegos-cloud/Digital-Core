CREATE PROCEDURE "informix".sp_obtienepassuserip(cEmpresa CHAR(3))

	--DATOS A REGRESAR
	RETURNING 
	CHAR (5)  AS CodigoRetorno,
	CHAR(15)  AS Ip,
	CHAR(20)  AS Usuario,
	CHAR(20)  AS Password,
	CHAR(100) AS Ruta;

	---DEFINICION DE VARIABLES
	DEFINE cCodRet		CHAR(5);
	DEFINE iSqlErr		INTEGER;
	DEFINE cValorIP		CHAR(15);
	DEFINE cValorUser 	CHAR(20);
	DEFINE cValorPass 	CHAR(20);
	DEFINE cValorRuta	CHAR(100);
	
	---INICIALIZA VARIABLES
	LET cCodRet 	= '000';
	LET iSqlErr 	= 0;
	LET cValorIP 	= '';
	LET cValorUser 	= '';
	LET cValorPass 	= '';
	LET cValorRuta  = '';
	
	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_obtienepassuserip.out";
	--TRACE ON;	
	
	BEGIN

		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cValorIP, cValorUser, cValorPass, cValorRuta;
			END IF;
			
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;

		LET cCodRet= "000";

		SELECT TRIM(valor)
		INTO cValorIP
		FROM bdinteg:"informix".si_param
		WHERE descripcion = "IP SERVIDOR CENTRAL";
		
		SELECT TRIM(valor)
		INTO cValorUser
		FROM bdinteg:"informix".si_param
		WHERE descripcion = "USUARIO CONSOLA";
		
		SELECT TRIM(valor)
		INTO cValorPass
		FROM bdinteg:"informix".si_param
		WHERE descripcion = "PASSWORD CONSOLA";
		
		SELECT TRIM(valor)
		INTO cValorRuta
		FROM bdinteg:"informix".si_param
		WHERE cod_param = "58";
		
		RETURN cCodRet, cValorIP, cValorUser, cValorPass, cValorRuta;
		
	END
	
END PROCEDURE

DOCUMENT
'REALIZO:	Carmén Orozco',
'FECHA:		27-12-2008',
'FUNCION:	Obtiene el Password, Usuario de Red y la IP del servidor central',
'BDD:		bdinteg',

'MODIFICO:	Daniela Ramírez',
'FECHA:		27-02-2012',
'FUNCION:	Se aplicaron reglas de informix ademas se agrega parametro de retorno (ruta)',
'BDD:		bdinteg';

CREATE PROCEDURE "informix".sp_beneficiarios_club(pEmpresa CHAR(3), pCteBanCoppel CHAR(20), pCteCoppel CHAR(20), pSecuencia INTEGER, 
pNomBenef1 CHAR(26),pNomBene1 CHAR(26), pAPaternoBenef1 CHAR(26), pAMaternoBenef1 CHAR(26), pPorcentaje DECIMAL(5,2), pParentesco CHAR(1),
pFecNac1 DATE, pNomBenef2 CHAR(26),pNomBene2 CHAR(26), pAPaternoBenef2 CHAR(26), pAMaternoBenef2 CHAR(26), pPorcentaje2 CHAR(26),
pParentesco2 CHAR(1), pFecNac2 DATE, pNomBenef3 CHAR(26), pNomBene3 CHAR(26),pAPaternoBenef3 CHAR(26),pAMaternoBenef3 CHAR(26),
pPorcentaje3 DECIMAL(5,2), pParentesco3 CHAR(1), pFecNac3 DATE, pEjecutivo CHAR(8), pBorrarRegistros CHAR(1), pSucCambio CHAR(4), pTipoMov CHAR(1))
RETURNING CHAR(6) AS codRet;

--DEFINICION DE VARIABLES
DEFINE cCodret	CHAR(6);
DEFINE iSqlErr INTEGER;
--INICIALIZACION DE VARIABLES 
LET cCodret	= '000000';
LET iSqlErr = 0;

--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_beneficiarios_club.out';
  --  TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN cCodret;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF NVL(pSecuencia,0)=0 OR TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pCteBanCoppel,''))='' 
		OR TRIM(NVL(pCteCoppel,''))='' OR TRIM(NVL(pEjecutivo,''))='' OR TRIM(NVL(pBorrarRegistros,''))='' THEN
			LET cCodret = '000001';
		ELSE
			IF pSecuencia>3 THEN
				LET cCodret = '000002';
			ELSE
					IF pSecuencia>=1 THEN
						IF  TRIM(NVL(pNomBenef1,''))='' OR TRIM(NVL(pAPaternoBenef1,''))='' 
						OR NVL(pPorcentaje,0)=0 OR TRIM(NVL(pParentesco,''))='' OR TRIM(NVL(pFecNac1,''))='' THEN
							LET cCodret = '000001';
						END IF
					END IF
					IF pSecuencia>=2 THEN
						IF TRIM(NVL(pNomBenef2,''))='' OR TRIM(NVL(pAPaternoBenef2,''))='' OR NVL(pPorcentaje2,0)=0 OR TRIM(NVL(pParentesco2,''))='' 
						OR TRIM(NVL(pFecNac2,''))='' THEN
							LET cCodret = '000001';
						END IF
					END IF
					IF pSecuencia=3 THEN
						IF TRIM(NVL(pNomBenef3,''))='' OR TRIM(NVL(pAPaternoBenef3,''))='' OR NVL(pPorcentaje3,0)=0 OR TRIM(NVL(pParentesco3,''))='' 
						OR TRIM(NVL(pFecNac3,''))='' THEN
							LET cCodret = '000001';
						END IF
					END IF
					IF TRIM(NVL(pTipoMov,''))='C' THEN
						IF TRIM(NVL(pSucCambio,''))='' THEN
							LET cCodret = '000001';
						END IF
					END IF
					IF cCodret='000000' THEN
						IF pSecuencia<=3 THEN
							IF TRIM(NVL(pBorrarRegistros,'')) = 'S' THEN
								DELETE "informix".si_club_beneficiario
								WHERE empresa=TRIM(pEmpresa) AND numcte=TRIM(pCteBanCoppel)
								AND numcte_coppel = TRIM(pCteCoppel);
							END IF
							IF pSecuencia>=1 THEN
								INSERT INTO "informix".si_club_beneficiario (empresa,numcte,numcte_coppel,secuencia,primer_nombre,segundo_nombre,apell_paterno,apell_materno,porcentaje,parentesco,fecha_nacimiento,ejecutivo_modificacion,fecha_modificacion,ejecutivo_insert,fecha_insert,suc_cambio,tipo_mov) 
								VALUES(pEmpresa,pCteBanCoppel,pCteCoppel,1,pNomBenef1,pNomBene1,pAPaternoBenef1,pAMaternoBenef1,pPorcentaje,pParentesco,pFecNac1,pEjecutivo, CURRENT,pEjecutivo,CURRENT,pSucCambio,pTipoMov);
							END IF
							IF pSecuencia>=2 THEN
								INSERT INTO "informix".si_club_beneficiario (empresa,numcte,numcte_coppel,secuencia,primer_nombre,segundo_nombre,apell_paterno,apell_materno,porcentaje,parentesco,fecha_nacimiento,ejecutivo_modificacion,fecha_modificacion,ejecutivo_insert,fecha_insert,suc_cambio,tipo_mov) 
								VALUES(pEmpresa,pCteBanCoppel,pCteCoppel,2,pNomBenef2,pNomBene2,pAPaternoBenef2,pAMaternoBenef2,pPorcentaje2,pParentesco2,pFecNac2,pEjecutivo, CURRENT,pEjecutivo,CURRENT,pSucCambio,pTipoMov);
							END IF
							IF pSecuencia=3 THEN
								INSERT INTO "informix".si_club_beneficiario (empresa,numcte,numcte_coppel,secuencia,primer_nombre,segundo_nombre,apell_paterno,apell_materno,porcentaje,parentesco,fecha_nacimiento,ejecutivo_modificacion,fecha_modificacion,ejecutivo_insert,fecha_insert,suc_cambio,tipo_mov) 
								VALUES(pEmpresa,pCteBanCoppel,pCteCoppel,3,pNomBenef3,pNomBene3,pAPaternoBenef3,pAMaternoBenef3,pPorcentaje3,pParentesco3,pFecNac3,pEjecutivo, CURRENT,pEjecutivo,CURRENT,pSucCambio,pTipoMov);
							END IF
						END IF
					END IF
			END IF
		END IF
		RETURN cCodret;
END
END PROCEDURE
DOCUMENT
"Descripción: Inserta los beneficiarios de una póliza del club de protección.",
"Autor : Leslie Rendón",
"FECHA : 03/07/2014",
"Descripción: Se agregan campos suc_cambio y tipo_mov para identificar la sucursal cuando se realice un cambio",
"Modifico: Leslie Rendón",
"Fecha: 03/09/2014",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_generaarchivocifras_club_1()
--DATOS A REGRESAR--
RETURNING CHAR(6) AS CodigoRetorno;

--DEFINICION DE VARIABLES--
DEFINE cCodret CHAR(6);
DEFINE vMensajeRet VARCHAR(80);
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE vErrorInfo VARCHAR(80);
DEFINE vProceso VARCHAR(30);
DEFINE cSql CHAR(1024);
DEFINE dFechaHoy DATE;
DEFINE cRuta CHAR(100);
DEFINE cFechaArchivo CHAR(8);
DEFINE cSucursal CHAR(4);
DEFINE iCantMovtos INTEGER;
DEFINE iImporte INTEGER;
DEFINE cTipoMovtos CHAR(1);
DEFINE dFecha DATE;
DEFINE dtFechaHora DATETIME YEAR TO SECOND;

--INICIALIZACION DE VARIABLES--
LET cCodret = '000000';
LET vMensajeRet = '';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET vErrorInfo = '';
LET vProceso = 'sp_generaarchivocifras_club';
LET cSql = '';
LET dFechaHoy = '';
LET cRuta = '';
LET cFechaArchivo = '';
LET cSucursal = '';
LET iCantMovtos = 0;
LET iImporte = 0;
LET cTipoMovtos = '';
LET dFecha = '';
LET dtFechaHora = '';

--SET DEBUG FILE TO "/informix/IrisA/sp_generaarchivocifras_club.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodret = iSqlErr;
			LET vMensajeRet = vErrorInfo;
			INSERT INTO "informix".si_club_bitacoradomiciliacion(proceso, codigoretorno, mensajeretorno, fec_paquete)
				VALUES(vProceso, cCodret, vMensajeRet, dFechaHoy);
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 5;

	SELECT fecha_hoy INTO dFechaHoy 
	FROM "informix".si_fechas WHERE empresa = '001';

	IF TRIM(NVL(dFechaHoy,'')) <> '' THEN

		SELECT valor INTO cRuta 
		FROM "informix".si_param 
		WHERE empresa = '001' AND cod_param = 319;

		IF TRIM(NVL(cRuta,'')) <> '' THEN

			LET cFechaArchivo = YEAR(dFechaHoy) || LPAD(MONTH(dFechaHoy),2,'0') || LPAD(DAY(dFechaHoy),2,'0');

			TRUNCATE TABLE "informix".si_club_cifrastotales;

			FOREACH
				-- SUCURSAL
				SELECT sucursal INTO cSucursal 
				FROM "informix".si_sucursales 
				WHERE empresa = '001' AND tpo_sucursal = 'S'
				ORDER BY sucursal

				-- VENTA
				SELECT COUNT(num_poliza), SUM(monto_pagar::INT) INTO iCantMovtos, iImporte
				FROM "informix".si_club_proteccion 
				WHERE fecha_alta = today-1 AND suc_alta = cSucursal AND aceptada = '1';

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('A', iCantMovtos, cSucursal, iImporte, today-1 );
				END IF;

				-- ABONO
				SELECT COUNT(a.referencia1), SUM(a.importe_pago::INT) INTO iCantMovtos, iImporte
				FROM bdisac:sac_movimientoshistorial a, bdisac:"informix".sac_abono_seg b
				WHERE a.referencia1 = b.numcliente AND a.referencia2 = b.recibo AND a.fecha_pago = today-1  
				AND a.fecha_pago = DATE(b.fecha_insert) AND a.id_sucursal = cSucursal 
				AND a.transacc_suc = '8102' AND a.status_cancelado = 'N';

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('B', iCantMovtos, cSucursal, iImporte, today-1 );
				END IF;

				-- PAGO DE VENTA
				SELECT COUNT(a.referencia1), SUM(a.importe_pago::INT) INTO iCantMovtos, iImporte
				FROM bdisac:sac_movimientoshistorial a, bdisac:"informix".sac_vta_cambio_seg b
				WHERE a.referencia1 = b.numcliente AND a.referencia2 = b.recibo AND a.fecha_pago = today-1  
				AND a.fecha_pago = DATE(b.fecha_insert) AND a.id_sucursal = cSucursal
				AND a.transacc_suc = '8102' AND a.status_cancelado = 'N' AND b.tipomovimiento = 'C';

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('C', iCantMovtos, cSucursal, iImporte, today-1 );
				END IF;

				-- PAGO DE CAMBIO DE PLAN
				SELECT COUNT(a.referencia1), SUM(a.importe_pago::INT) INTO iCantMovtos, iImporte
				FROM bdisac:sac_movimientoshistorial a, bdisac:"informix".sac_vta_cambio_seg b
				WHERE a.referencia1 = b.numcliente AND a.referencia2 = b.recibo AND a.fecha_pago = today-1  
				AND a.fecha_pago = DATE(b.fecha_insert) AND a.id_sucursal = cSucursal
				AND a.transacc_suc = '8102' AND a.status_cancelado = 'N' AND b.tipomovimiento = 'K';

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('K', iCantMovtos, cSucursal, iImporte, today-1 );
				END IF;

				-- CAMBIO DE BENEFICIARIO
				SELECT COUNT(DISTINCT numcte) INTO iCantMovtos 
				FROM "informix".si_club_beneficiario 
				WHERE tipo_mov = 'C' AND fecha_modificacion = today-1  AND suc_cambio = cSucursal;

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('D', iCantMovtos, cSucursal, 0, today-1 );
				END IF;

				-- CAMBIO DE PLAN
				SELECT COUNT(num_poliza), SUM(monto_pagar::INT) INTO iCantMovtos, iImporte
				FROM "informix".si_club_proteccion 
				WHERE tipo_mov = 'C' AND fecha_cambio = today-1  AND suc_cambio = cSucursal;

				IF NVL(iCantMovtos,0) <> 0 THEN
					INSERT INTO "informix".si_club_cifrastotales(tipomovimiento, cantidadmovtos, sucursal, importe, fecha)
						VALUES('H', iCantMovtos, cSucursal, iImporte, today-1 );
				END IF;

			END FOREACH;

			UPDATE statistics medium FOR TABLE "informix".si_club_cifrastotales;

			LET cSql = '';
            LET cSql = 'echo "UNLOAD TO ' || TRIM(cRuta) || 'cifrasclub1' || TRIM(cFechaArchivo) || '.txt' || ' DELIMITER ' || '''|''' ||
                        ' SELECT tipomovimiento, cantidadmovtos, sucursal, importe, fecha' ||
                        ' FROM si_club_cifrastotales ' || ';' ||
                        ' " > cifrasclub.sql';
            SYSTEM cSql; 

            LET cSql = '';
            LET cSql = 'dbaccess bdinteg cifrasclub.sql';
            SYSTEM cSql;

			LET cSql = '';
            LET cSql = "sed 's/|$//g' " || TRIM(cRuta) || 'cifrasclub1' || TRIM(cFechaArchivo) || '.txt' || " > " || TRIM(cRuta) || 'cifrasclub2' || TRIM(cFechaArchivo) || '.txt';
            SYSTEM cSql; 

			LET cSql = '';
            LET cSql = "sed 's/$'/`echo \\\r`/ " || TRIM(cRuta) || 'cifrasclub2' || TRIM(cFechaArchivo) || '.txt' || " > " || TRIM(cRuta) || 'cifrasclub' || TRIM(cFechaArchivo) || '.txt';
            SYSTEM cSql;

            LET cSql = '';
            LET cSql = 'rm cifrasclub.sql';
            SYSTEM cSql; 

			LET cSql = '';
            LET cSql = 'rm ' || TRIM(cRuta) || 'cifrasclub1' || TRIM(cFechaArchivo) || '.txt';
            SYSTEM cSql; 

			LET cSql = '';
            LET cSql = 'rm ' || TRIM(cRuta) || 'cifrasclub2' || TRIM(cFechaArchivo) || '.txt';
            SYSTEM cSql; 

			FOREACH
				SELECT tipomovimiento, cantidadmovtos, sucursal, importe, fecha, fecha_hora
				INTO cTipoMovtos, iCantMovtos, cSucursal, iImporte, dFecha, dtFechaHora
				FROM "informix".si_club_cifrastotales

				INSERT INTO "informix".si_club_cifrastotales_hist(tipomovimiento, cantidadmovtos, sucursal, importe, fecha, fecha_hora)
					VALUES(cTipoMovtos, iCantMovtos, cSucursal, iImporte, dFecha, dtFechaHora);
			END FOREACH;

		ELSE
			LET cCodret = '002';
			LET vMensajeRet = 'No Existe Ruta';
		END IF;
	ELSE
		LET cCodret = '001';
		LET vMensajeRet = 'No Existe Fecha';
	END IF;

	IF cCodret <> '000000' THEN
		INSERT INTO "informix".si_club_bitacoradomiciliacion(proceso, codigoretorno, mensajeretorno, fec_paquete)
			VALUES(vProceso, cCodret, vMensajeRet, dFechaHoy);
	END IF;

	RETURN cCodret;
END;
END PROCEDURE;