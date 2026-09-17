CREATE PROCEDURE "informix".sp_obtenercc(p_empresa CHAR(3), p_usuario CHAR(8), p_cuenta CHAR(19), p_smoneda CHAR(2))

    RETURNING CHAR(6), CHAR(50);

    DEFINE     sql_err                  INTEGER;
    DEFINE     isam_err                 INTEGER;
    DEFINE     error_info               CHAR(50);
    DEFINE     cod_ret                  CHAR(6);

    DEFINE     v_ccmayor                CHAR(4);
    DEFINE     v_ccsub                  CHAR(2);
    DEFINE     v_ccsubsub               CHAR(2);
    DEFINE     v_ccssubsub              CHAR(2);
    DEFINE     v_ccsssubsub             CHAR(2);
    DEFINE     v_sector                 CHAR(2);
    DEFINE     v_sucursal               CHAR(4);
    DEFINE     v_nombresucursal         CHAR(40);
    DEFINE     v_ccosto_orig            CHAR(4);
    DEFINE     v_cta_restringida_dest   CHAR(1);

    BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cod_ret = sql_err;
            SET DEBUG FILE TO "ErrPoliza.err";
            TRACE sql_err||" * "||isam_err|| " * "||error_info;
            RETURN cod_ret, isam_err;
        END EXCEPTION;

        --******************************************************
        --Creado por Vladimir Félix Gálvez 12/May/2009       --*
        --Debug del Procedure                                --*
        --SET DEBUG FILE TO "/tmp/subir/obtenercentrocostos.out";   --*
        --TRACE ON;                                          --*
		--Modificacion:     Se cambió la firma del SP de obtenercentrocostos a
		--                        a sp_obtenercc --*
		--Modificado por : César Andrés De Anda Alcántara --*
		--Fecha:               17/06/2009 --*
        --******************************************************

        --****************************************************************************
        --OBTENCION DE INFORMACION GENERAL PARA EL PROCESO                            **
        --****************************************************************************

        LET v_ccmayor      = substr(p_cuenta,1,4);
        LET v_ccsub        = substr(p_cuenta,6,2);
        LET v_ccsubsub     = substr(p_cuenta,9,2);
        LET v_ccssubsub    = substr(p_cuenta,12,2);
        LET v_ccsssubsub   = substr(p_cuenta,15,2);
        LET v_sector       = substr(p_cuenta,18,2);

        LET cod_ret = "000";


        SELECT cta_restringida_dest
        INTO   v_cta_restringida_dest
        FROM   bdinteg:si_catalog
        WHERE  ccmayor = v_ccmayor
        AND    ccsub = v_ccsub
        AND    ccsubsub = v_ccsubsub
        AND    ccssubsub = v_ccssubsub
        AND    ccsssubsub = v_ccsssubsub
        AND    sector = v_sector;

        IF v_cta_restringida_dest = 'N' THEN

            FOREACH

                SELECT sucursal, nombre
                INTO   v_sucursal, v_nombresucursal
                FROM   bdinteg:si_sucursales
                ORDER BY sucursal

                RETURN cod_ret, v_sucursal||" "||v_nombresucursal WITH RESUME;

            END FOREACH;

        ELSE

            FOREACH

                SELECT sucursal
                INTO   v_sucursal
                FROM   bdicont:co_cta_ccdest
                WHERE  empresa    = p_empresa
                AND    ccmayor    = v_ccmayor
                AND    ccsub      = v_ccsub
                AND    ccsubsub   = v_ccsubsub
                AND    ccssubsub  = v_ccssubsub
                AND    ccsssubsub = v_ccsssubsub
                AND    sector     = v_sector
                ORDER BY sucursal

                SELECT nombre
                INTO   v_nombresucursal
                FROM   bdinteg:si_sucursales
                WHERE  empresa    = p_empresa
                AND    sucursal = v_sucursal;

                RETURN cod_ret, v_sucursal||" "||v_nombresucursal WITH RESUME;

            END FOREACH;
        END IF;
    END
END PROCEDURE;