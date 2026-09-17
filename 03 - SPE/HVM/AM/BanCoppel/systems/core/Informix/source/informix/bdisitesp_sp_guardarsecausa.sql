CREATE PROCEDURE "informix".sp_guardarsecausa(p_sEmpresa CHAR(3), p_sSE CHAR(3), p_iCausa INTEGER, p_sDescripcion CHAR(75),
											 p_iAlcance INTEGER, p_cve_Inst_InfCred CHAR(5), p_iDespliegue INTEGER, p_usuario char(8))
    RETURNING CHAR(5);

    DEFINE vcCodRet 			CHAR(5);
    DEFINE viSqlErr 			INTEGER;

	DEFINE v_sDescripcion		CHAR(75);
	DEFINE v_iAlcance			INTEGER;
	DEFINE v_cve_Inst_InfCred	CHAR(5);
	DEFINE v_iDespliegue		INTEGER;
    DEFINE v_fecha_hoy  		datetime year to second;

	--------------------------------------------------------------------------
	-- Creado por Erick Zamora 09/02/2009
	-- Modificado por José Almeida 11/05/2009  el campo p_cve_Inst_InfCred ya no es obligatorio
    --SET DEBUG FILE TO "/respaldos/subedepaso/sp_guardarsecausa.out";
    --TRACE ON;

	--Fecha: 14/05/2009
	--Modifico: Abraham Ayala
	--Evitar que se repitan las descripciones.
	--------------------------------------------------------------------------

	LET vcCodRet 			= '000';
    LET viSqlErr 			= 0;

    LET v_sDescripcion 		= '';
	LET v_iAlcance 			= '';
	LET v_cve_Inst_InfCred 	= '';
	LET v_iDespliegue 		= '';

	BEGIN
        ON EXCEPTION SET viSqlErr
            LET vcCodRet = viSqlErr;
            RETURN vcCodRet;
        END EXCEPTION;

		--SI ALGUNO DE LOS PARAMETROS ES NULO SE ENVIA UN ERROR
        IF (p_sEmpresa = '' OR p_sEmpresa IS NULL) OR (p_sSE = '' OR p_sSE IS NULL) OR (p_iCausa IS NULL OR p_iCausa = 0)
			OR (p_sDescripcion = '' OR p_sDescripcion IS NULL) OR (p_iAlcance IS NULL) OR (p_iDespliegue IS NULL) THEN
            LET vcCodRet = '999';
		ELSE
            --Obtener la fecha actual del servidor
            SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + (fecha_hoy - CURRENT) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = p_sEmpresa;

            --VALIDA SI YA EXISTE EL REGISTRO PARA REALIZAR LA ACTUALIZACIÓN, CASO CONTRARIO SE INSERTA EN LA TABLA.
            IF EXISTS (SELECT {+ INDEX(bdisitesp:se_catsitesp idx_catsitesp)} situacion FROM bdisitesp:se_catsitesp WHERE situacion = p_sSE AND causa = p_iCausa AND empresa = p_sEmpresa) THEN
                UPDATE bdisitesp:se_catsitesp
                SET descripcion = p_sDescripcion, alcance = p_iAlcance, cveccasociada = p_cve_Inst_InfCred,
					despliegue = p_iDespliegue, usrmodifica = p_usuario, fchmodifica = v_fecha_hoy
                WHERE situacion = p_sSE AND causa = p_iCausa AND empresa = p_sEmpresa;
            ELSE
				IF NOT EXISTS (SELECT {+ INDEX(bdisitesp:se_catsitesp idx_catsitesp)} situacion FROM bdisitesp:se_catsitesp WHERE empresa = p_sEmpresa AND descripcion = p_sDescripcion) THEN
	                INSERT INTO bdisitesp:se_catsitesp (empresa, situacion, causa, descripcion, alcance, cveccasociada, despliegue, usralta, fchalta, usrmodifica, fchmodifica)
	                VALUES (p_sEmpresa, p_sSE, p_iCausa, p_sDescripcion, p_iAlcance, p_cve_Inst_InfCred, p_iDespliegue, p_usuario, v_fecha_hoy, '', DATE(1));
				ELSE
					LET vcCodRet = '003';
					RETURN vcCodRet;
				END IF;
            END IF;
        END IF;
        RETURN vcCodRet;
    END;
END PROCEDURE;