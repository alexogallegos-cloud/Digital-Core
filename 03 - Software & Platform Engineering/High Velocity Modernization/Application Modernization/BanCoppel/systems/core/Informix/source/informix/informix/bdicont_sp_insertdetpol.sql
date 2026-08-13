CREATE PROCEDURE "informix".sp_insertdetpol( pusuario CHAR(8), pcontrolpoliza INTEGER,
        pfechacaptura DATE , psecuencia INTEGER, pempresa CHAR(3), pccmayor CHAR(10),
        pccostoorig CHAR(4), pccsub CHAR(10), pccsubsub CHAR(10), pccssubsub CHAR(10),
        pccsssubsub CHAR(10), psector CHAR(10), pnroauxiliar CHAR(12), pciudad CHAR(3),
        psucursal CHAR(4), pnaturaleza CHAR(1), pmonto MONEY(18,2), pdescripciondet CHAR(80),
        pfechavalida DATE, pmoneda CHAR(2), pvalorcambio MONEY(12,7), pvalordivcambio MONEY(12,7),
        pmcaaplic CHAR(1), ppolizausuario CHAR(8), ptipomov CHAR(1) )

	RETURNING CHAR(6);
	---------------------------------------------------------------------------
	--Autor: Julio Cesar Polanco
	--Fecha de Creacion: 25/05/2009
	--Actividad: Insertar un registro en la tabla co_detpol,
	--     		 se validan unicamente los campos llave
	--Modificado:Vladimir Felix Galvez
	-- Fecha de Modificación: 28/05/2009
	--Modificación:    Agrega validación para verificar si el registro a insertar ya existe.
	--Modifacion:       Se cambió la firma del SP de insertarpolizadetalle por
	--                       sp_insertdetpol
	--Modificado por: César Andrés De Anda Alcántara
	--Fecha:              17/06/2009
	---------------------------------------------------------------------------

	DEFINE cCodRet       CHAR(6);
	DEFINE iSqlErr       INTEGER;

	LET cCodRet     = '000';
	LET iSqlErr     = 0;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

		IF pusuario IS NULL OR pusuario = '' OR pcontrolpoliza IS NULL OR pcontrolpoliza = ''
			OR pfechacaptura IS NULL OR pfechacaptura = '' OR psecuencia IS NULL OR psecuencia ='' THEN
			LET cCodRet = '001';
			RETURN cCodRet;
		END IF

		IF NOT EXISTS(SELECT control_poliza FROM bdicont:co_detpol WHERE usuario = pusuario AND control_poliza = pcontrolpoliza AND
					fecha_captura = pfechacaptura AND secuencia = psecuencia AND empresa = pempresa AND ccmayor = pccmayor AND
					ccosto_orig = pccostoorig AND ccsub = pccsub AND ccsubsub = pccsubsub AND ccssubsub = pccssubsub AND
					ccsssubsub = pccsssubsub AND sector = psector AND nro_auxiliar = pnroauxiliar AND ciudad = pciudad AND
					sucursal = psucursal AND naturaleza = pnaturaleza AND monto = pmonto AND descripcion_det = pdescripciondet AND
					fecha_valida = pfechavalida AND moneda = pmoneda AND valor_cambio = pvalorcambio AND valor_div_cambio = pvalordivcambio AND
					mca_aplic = pmcaaplic AND poliza_usuario = ppolizausuario AND tipo_mov = ptipomov) THEN

			 INSERT INTO bdicont:co_detpol ( usuario, control_poliza, fecha_captura, secuencia, empresa, ccmayor, ccosto_orig,
							ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, nro_auxiliar, ciudad, sucursal, naturaleza, monto,
							descripcion_det, fecha_valida, moneda, valor_cambio, valor_div_cambio, mca_aplic, poliza_usuario,tipo_mov )
			 VALUES( pusuario, pcontrolpoliza, pfechacaptura, psecuencia, pempresa, pccmayor, pccostoorig, pccsub, pccsubsub,
					 pccssubsub, pccsssubsub, psector, pnroauxiliar, pciudad, psucursal, pnaturaleza, pmonto, pdescripciondet,
					 pfechavalida, pmoneda, pvalorcambio, pvalordivcambio, pmcaaplic, ppolizausuario, ptipomov );

		END IF;
		RETURN cCodRet;
	END;
END PROCEDURE;