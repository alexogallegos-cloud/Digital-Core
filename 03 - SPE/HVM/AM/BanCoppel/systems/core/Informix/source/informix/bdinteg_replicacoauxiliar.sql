CREATE PROCEDURE "informix".replicacoauxiliar(pEmpleado CHAR(8), pSucursal CHAR(4), pApePat CHAR(26), pApeMat CHAR(26), pNom CHAR(50))
    RETURNING  CHAR(10);  -- Codigo de retorno

    DEFINE vCodRet      CHAR(5);
    DEFINE vNumAux      CHAR(12);
    DEFINE vNombre      CHAR(45);
    DEFINE vCanAfe      INTEGER;
    DEFINE vAnio        INTEGER;
    DEFINE vMesDia      CHAR(6);
    DEFINE vFecha       DATE;
    DEFINE vLongIni     INTEGER;
    DEFINE vLongFin     INTEGER;
    DEFINE vPosBlank1   INTEGER;
    DEFINE vPosBlank2   INTEGER;
    DEFINE vNombre1     CHAR(12);
    DEFINE vNombre2     CHAR(12);
    DEFINE vValor       CHAR(1);


--***************************************************
-- Creado por Fabiola Corrales Tapia 16/May/2007  --*
-- Debug del Procedure                            --*
--SET DEBUG FILE TO "/tmp/replicacoauxiliar.out";--*
--TRACE ON;                                      --*
--***************************************************

    LET vCodRet = "000";
    LET vNumAux = TRIM(pSucursal)||TRIM(pEmpleado);
    LET vCanAfe = 0;

	LET vNombre = TRIM(pNom) || " " || TRIM(pApePat) || " " || TRIM(pApeMat);
	LET vAnio   = 0;
	LET vMesDia = "";
    LET vFecha = "";

	BEGIN
        LET vLongFin = LENGTH(TRIM(pNom));
        LET vLongIni = 1;
        LET vPosBlank1 = 0;
        LET vPosBlank2 = 0;

        WHILE vLongIni <= vLongFin AND vPosBlank1 = 0
            LET vValor = SUBSTR(pNom::char(24),vLongIni,1);
             IF SUBSTR(pNom::char(24),vLongIni,1) = " " THEN
                LET vPosBlank1 = vLongIni;
                LET vPosBlank2 = vLongIni;
                LET vLongIni = vLongIni + 1;
             ELSE
                LET vLongIni = vLongIni + 1;
             END IF;
        END WHILE;

        IF vPosBlank1 > 13 THEN
        END IF

        IF vPosBlank1 = 0 THEN
            LET vNombre1 = TRIM(pNom::char(24));
            LET vNombre2 = "";
        ELSE
            LET vNombre1 = SUBSTR((TRIM(pNom)),1,(vPosBlank2-1));
            LET vNombre2 = SUBSTR((TRIM(pNom)),(vPosBlank2+1),12);
        END IF;
        --substr(claveparam::char(10),1,2) = '11'

        IF NOT EXISTS(SELECT numero FROM bdicont:co_auxiliar WHERE empresa = '001' AND numero = vNumAux) THEN
            -- ALTA DEL EMPLEADO EN CO_AUXILIAR
			SELECT
                YEAR(fecha_hoy), SUBSTRING(TO_CHAR(fecha_hoy, "%m/%d/%Y") FROM 1 FOR 6)
			INTO
				vAnio, vMesDia
			FROM
				bdinteg:si_fechas;

			LET vFecha = CAST((vMesDia || CAST(vAnio AS CHAR(4))) AS DATE);

            INSERT INTO bdicont:co_auxiliar
                (empresa, numero, tp_persona, apell_paterno, apell_materno, nombre1, nombre2, sucursal, estatus, nacionalidad, dom_calle_nro,
                 dom_colonia, dom_delegacion, dom_poblacion, dom_codpost,adicionado, fecha_alta, modificado, fecha_mod, sector, telefono, rfc_alfa, rfc_nro, rfc_homo, razon_soc)
			VALUES
                ('001', vNumAux, '01', pApePat, pApeMat, vNombre1, vNombre2, pSucursal, 'S','02','CONOCIDO','CONOCIDO', 'CONOCIDO', 'CONOCIDO', '00000',
                'automati', vFecha, 'automati', vFecha, '00', '0', '', '', '', '');
		END IF

		LET vCanAfe = DBINFO("sqlca.sqlerrd2");

        IF vCanAfe <= 0 THEN
            LET vCodRet = "001";
		END IF
	END

	RETURN vCodRet;
END PROCEDURE;