CREATE PROCEDURE "informix".sp_auronix_msj()
       RETURNING char(6), char(150);

DEFINE sql_err 			INTEGER;
DEFINE isam_err 		INTEGER;
DEFINE error_info		CHAR(150);
DEFINE cCod_ret         CHAR(6);
DEFINE cMensaje 		CHAR(150);
DEFINE vnumcte          CHAR(20);
DEFINE vnum_credito     CHAR(20);
DEFINE vpagos_vencidos  INTEGER;
DEFINE vsituacion       CHAR(1);
DEFINE vcausa           SMALLINT;
DEFINE vinstruccion     CHAR(1);
DEFINE vempresa         CHAR(3);
DEFINE vtFechaLimite    DATE;
DEFINE vtfechacorte     DATE;
DEFINE vcelular         CHAR(13);
DEFINE cccCod_ret       CHAR(6);
DEFINE cccMensaje       CHAR(150);
DEFINE vfecha_insert    DATE;
DEFINE vnombre          CHAR(110);
DEFINE vciudad          CHAR(20);
DEFINE vestado          CHAR(20);

    LET vempresa      = '001';
    LET cCod_ret      = '000000';
    LET sql_err       = 0;
    LET cMensaje      = 'PROCESO EXITOSO';

--SET DEBUG FILE TO '/tmp/sp_datos_admin_auronix.out';
--TRACE ON;

BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
            RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

    SET ISOLATION TO dirty READ; 
    TRUNCATE bdicobranza:cb_ctes_mensajes;

    SELECT limit 1 fecha_insert 
    INTO vfecha_insert
    FROM cb_cat_directorio_cte where tipo_cobranza = 'A';

    SET ISOLATION TO dirty READ;
    FOREACH

        SELECT LIMIT 40000 a.numcte
            ,a.num_credito
            ,a.pago_venc
            ,substr(b.telefono,length(b.telefono)-9,10) celular
            ,trim(a.nombre1) || " " || trim(a.nombre2) || " " ||
             trim(a.apell_paterno) || " " || trim(a.apell_materno) Nombre
            ,a.ciudad
        INTO vnumcte, vnum_credito, vpagos_vencidos, vcelular, vnombre, vciudad
        FROM cb_cat_directorio_cte a, cb_telefonos b
        where a.numcte = b.numcte
        and b.tipo_telefono = 2
		and b.origen = 2
		and b.tipored is not null
        and a.tipo_cobranza = 'A'
        and a.fecha_insert = vfecha_insert
        and a.status_cliente IN ('AC', 'PR')
        and a.pago_venc between 1 and 3
        

        SELECT first 1 a.ciudad_coppel || '-' || trim(b.inicialciudad) Ciudad    --- ciudad
               ,b.numeroestado || '-' || trim(b.inicialestado) Estado   --- estado*/
        INTO vciudad, vestado
        FROM bdinteg:si_ciudades a, bdinteg:si_catciudades b
        WHERE a.ciudad_coppel = b.numerociudad
        AND a.ciudad = vciudad;


                        LET vsituacion = NULL;
                        LET vcausa     = NULL;

                        SELECT {+INDEX(bdisitesp:se_ctessitespcte se_ctessitespcte_idx1)} FIRST 1 nvl(situacion, ''),  nvl(causa, 0)
                        INTO   vsituacion, vcausa
                        FROM bdisitesp:se_ctessitespcte
                        WHERE numcte = vnumcte;

                         LET vinstruccion = 1;

                    IF ((vsituacion IS NOT NULL) AND (vcausa IS NOT NULL)) THEN

                                SELECT FIRST 1 instruccion
                                INTO vinstruccion
                                FROM bdisitesp:se_situacionaccion
                                WHERE situacion= vsituacion
                                AND causa= vcausa
                                AND idaccion = 9
                                AND empresa = vempresa;

                    END IF;

                    IF (vinstruccion = 1) THEN

                        INSERT INTO "informix".cb_ctes_mensajes(cliente, credito, ciudad, estado, nombre, t_celular, pago_venc, fecha_ejecucion, causa, situacion) 
                        VALUES(vnumcte, vnum_credito, vciudad, vestado, vnombre, vcelular, vpagos_vencidos, TODAY, nvl(vcausa, 0), nvl(vsituacion, ''));
                        
                    END IF;

END FOREACH;

	CALL bdicobranza:"informix".sp_target_phone()
    RETURNING cccCod_ret, cccMensaje;
 
    RETURN cCod_ret, cMensaje;

	END;
END PROCEDURE;