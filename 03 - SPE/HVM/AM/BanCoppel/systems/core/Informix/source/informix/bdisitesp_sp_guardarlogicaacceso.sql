CREATE PROCEDURE "informix".sp_guardarlogicaacceso(p_cempresa CHAR(3),p_cse CHAR(1), p_ccausa INTEGER, p_carea CHAR(2), p_iperfil INTEGER, p_ctipo_mov CHAR(2), p_cmarcado INTEGER, p_usuario CHAR(8))
        RETURNING CHAR(5);

    DEFINE vcCodRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE v_fecha_hoy  datetime year to second;

    LET vcCodRet = '000';
    LET viSqlErr = 0;

		 --*******************************************************
	 -- Creado por Vladimir Felix Galvez    19/marzo/2008		   --*
     -- Modificado por Walber Castro 20/Feb/2009
	 -- Debug del Procedure								   --*
     -- SET DEBUG FILE TO "/tmp/walber/sp_AltaLogicaAcceso.out";  --*
     -- TRACE ON;                                          --*
	 --*******************************************************
	BEGIN
        ON EXCEPTION SET viSqlErr
            LET vcCodRet = viSqlErr;
            RETURN vcCodRet;
        END EXCEPTION;

        --VALIDA QUE LOS PARAMETROS DE ENTRADA SEAN VALIDOS
        IF ( p_cempresa <> "" AND NOT p_cempresa IS NULL ) AND (p_cse <> "" AND NOT p_cse IS NULL) AND (p_ccausa <> 0 AND NOT p_ccausa IS NULL) AND ((p_cmarcado = 0 OR p_cmarcado = 1) AND NOT p_cmarcado IS NULL) AND
           (p_ctipo_mov <> "" AND NOT p_ctipo_mov IS NULL) AND (p_carea <> "" AND NOT p_carea IS NULL) AND (p_iperfil <> 0 AND NOT p_iperfil IS NULL) AND (p_usuario <> '' AND NOT p_usuario IS NULL) THEN

           --VALIDA QUE EL REGISTRO NO EXISTA PARA HACER LA INSERCION
           IF NOT EXISTS(SELECT * FROM bdisitesp:se_logicaacceso WHERE empresa = p_cempresa AND situacion = trim(p_cse) AND causa = p_ccausa AND idarea = trim(p_carea)
                         AND idperfil =  p_iperfil AND idtipomov = trim(p_ctipo_mov)) AND p_cmarcado = 1 THEN

                --Obtener la fecha actual del servidor
                SELECT {+ INDEX(bdinteg:si_fechas idx_si_fechas)} CURRENT + ( fecha_hoy - CURRENT::datetime year to day ) INTO v_fecha_hoy FROM bdinteg:si_fechas WHERE empresa = p_cempresa;
                
                INSERT INTO bdisitesp:se_logicaacceso (situacion, causa, idtipomov, idarea, idperfil, empresa, usralta, fchalta, usrmodifica, fchmodifica)
                VALUES (p_cse, p_ccausa, p_ctipo_mov, p_carea, p_iperfil, p_cempresa, p_usuario, v_fecha_hoy, '', DATE(1));

            ELSE
                IF p_cmarcado = 0 THEN --VALIDACIÓN QUE SE HACE PARA SABER SI ES UN REGISTRO QUE DEBE ELIMINARSE
                    --ELIMINA EL REGISTRO DE LA TABLA
                    DELETE FROM bdisitesp:se_logicaacceso WHERE empresa = p_cempresa AND situacion = trim(p_cse) AND causa = p_ccausa AND idarea = trim(p_carea)
                         AND idperfil =  p_iperfil AND idtipomov = trim(p_ctipo_mov);
                END IF;
			END IF;
        ELSE
            LET vcCodRet = '999';
		END IF;
        RETURN vcCodRet;
	END;

END PROCEDURE;