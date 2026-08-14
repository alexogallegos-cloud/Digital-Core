CREATE PROCEDURE "informix".sp_cartera_pagovencido(vfecha_insert DATE, vtipo_cobranza CHAR(1), vpago_venc INTEGER)
       RETURNING char(6), char(150);

--declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(150);
DEFINE cCod_ret                     CHAR(6);
DEFINE vvcCod_ret                   CHAR(6);
DEFINE vnombre                      CHAR(110);
DEFINE vempresa                     CHAR(3);
DEFINE vnumcte                      CHAR(20);
DEFINE vnum_credito                 CHAR(20);
DEFINE vnum_tarjeta                 CHAR(20);
DEFINE vtelefono_casa               CHAR (13);
DEFINE vtelefono_celular            CHAR(13);
DEFINE vtelefono_trabajo            CHAR(13);
DEFINE vext_trabajo                 CHAR(5);
DEFINE vsexo                        CHAR(1);
DEFINE vestado_civil                CHAR(2);
DEFINE vnombre_ref                  CHAR(110);
DEFINE vtelefono_ref                CHAR(13);
DEFINE vciudad                      CHAR(20);
DEFINE vestado                      CHAR(20);
DEFINE vsituacion                   CHAR(1);
DEFINE vcausa                       SMALLINT;
DEFINE vinstruccion                 CHAR(1);
DEFINE cproceso                     CHAR(4);
DEFINE vnombre1 CHAR(50);
DEFINE vnombre2 CHAR(50);
DEFINE vap CHAR(50);
DEFINE vam CHAR(50);

--SET DEBUG FILE TO 'sp_calcula_cobranza_administrativa_pbaaaa.out';
--TRACE ON;

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
      LET vempresa      = '001';
      LET cproceso      = '9999';

	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
                CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
                RETURNING vvcCod_ret;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;
	    
	    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
                RETURNING vvcCod_ret;

		SET ISOLATION TO dirty READ;

----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------
FOREACH
            SELECT numcte, num_credito
            INTO vnumcte, vnum_credito
            FROM cb_cat_directorio_cte 
            WHERE empresa = vempresa 
            AND fecha_insert = vfecha_insert
            AND numcte > '0'
            AND tipo_cobranza = vtipo_cobranza
            AND pago_venc= vpago_venc

----------------------------------------------------------------------------------------------------------------------------------

            SELECT limit 1 e.num_tarjeta,                                                    --- tarjeta
                   b.numerociudad || '-' || trim(j.inicialciudad) Ciudad,            --- ciudad
                   j.numeroestado || '-' || trim(j.inicialestado) Estado,            --- estado
                   trim(a.nombre1), /*|| " " || */trim(a.nombre2), /*|| " " ||*/
                   trim(a.apell_paterno), /*|| " " ||*/ trim(a.apell_materno) ,     --- nombre
                   aa.sexo Sexo,                                                     --- sexo
                   aa.estado_civil Estado_Civil,                                     --- civil
                --   b.telefono1 Telefono_Casa,                                        --- t_casa
                 --  b.telefono2 Telefono_Celular,                                     --- t_celular
                 --  b.telefono3 Telefono_Trabajo,                                     --- t_trabajo
                 --  b.extension Ext_Trabajo,                                          --- ext
				   tel1.telefono Telefono_Casa,                                        --- t_casa
                   tel2.telefono Telefono_Celular,                                     --- t_celular
                   tel3.telefono Telefono_Trabajo,                                     --- t_trabajo
                   tel3.extension Ext_Trabajo,                                          --- ext
                   i.nombre_ref,                                                     --- nombre_ref
                   i.telefono_ref 
            INTO vnum_tarjeta, vciudad, vestado, vnombre1,vnombre2,vap,vam, vsexo, vestado_civil, vtelefono_casa
                ,vtelefono_celular, vtelefono_trabajo, vext_trabajo, vnombre_ref, vtelefono_ref
            FROM bdinteg:si_direcciones b
            LEFT JOIN bdinteg:si_cliente a ON (a.numcte = vnumcte)
            LEFT JOIN bdinteg:si_ctepf aa ON (aa.numcte = vnumcte)
            LEFT JOIN bdicred:sd_tarjeta e ON (e.empresa = vempresa AND e.num_credito = vnum_credito
                                                AND e.secuencia = (SELECT MAX(secuencia) FROM bdicred:sd_tarjeta ab
                                                                    WHERE ab.empresa = vempresa
                                                                    AND ab.num_credito= vnum_credito)
                                                AND e.status_tar = 'A'
                                                AND e.tipo_tarjeta = 'T')
            LEFT JOIN bdisolic:ss_refpersonales i ON (i.empresa = vempresa AND i.numcte = vnumcte AND i.numcte_ref = 'R1')
            LEFT JOIN bdinteg:si_catciudades j ON (b.numerociudad = j.numerociudad) --AND numeroestado)
			left join bdinteg:si_telefonos tel1 on (tel1.numcte = vnumcte and tel1.tipo_tel = 1 and 
						  tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = vnumcte and tipo_tel = 1))
			left join bdinteg:si_telefonos tel2 on (tel2.numcte = vnumcte and tel2.tipo_tel = 2 and 
						  tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = vnumcte and tipo_tel = 2))
			left join bdinteg:si_telefonos tel3 on (tel3.numcte = vnumcte and tel3.tipo_tel = 3 and 
						  tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = vnumcte and tipo_tel = 3))
            WHERE b.numcte = vnumcte
            AND b.secuencia = ( select max(secuencia) from bdinteg:si_direcciones h
                              where h.tipo_dir = '1'
                              and h.numcte = vnumcte)
            AND b.tipo_dir = '1';

----------------------------------------------------------------------------------------------------------------------------------

                LET vtelefono_celular = '045' || substr(vtelefono_celular,length(vtelefono_celular)-9,10);

                IF vtelefono_celular = '045' THEN
                    LET vtelefono_celular = '';
                END IF;

----------------------------------------------------------------------

               IF (vpago_venc = 0) THEN
                   CONTINUE FOREACH;
               END IF;

                    LET vsituacion = NULL;
                    LET vcausa     = NULL;

                         SELECT  FIRST 1 situacion,  causa
                         INTO    vsituacion, vcausa
                         FROM    bdisitesp:se_ctessitespcte
                         WHERE   numcte = vnumcte;

                         LET vinstruccion = 1;
                   IF ((vsituacion IS NOT NULL) AND (vcausa IS NOT NULL)) THEN


                                SELECT FIRST 1 instruccion
                                INTO   vinstruccion
                                FROM   bdisitesp:se_situacionaccion
                                WHERE  situacion= vsituacion
                                AND    causa= vcausa
                                AND    idaccion = 9;

                    END IF;

                    IF (vinstruccion = 1) THEN

                        INSERT INTO cb_info_administrativa (cliente, credito, tarjeta, ciudad, estado, 
										nombre1 , nombre2,apell_paterno,  apell_materno, /*nombre, sexo, civil,
                                        t_casa,*/ t_celular, /*t_trabajo, ext, nombre_ref, t_ref,*/ pago_venc, 
                                        fecha_ejecucion)
                        VALUES(vnumcte, vnum_credito, vnum_tarjeta, vciudad, vestado,vnombre1,vnombre2,vap,vam,/* vnombre, vsexo, vestado_civil,
                                        vtelefono_casa,*/ vtelefono_celular, /*vtelefono_trabajo, vext_trabajo, vnombre_ref, 
                                        vtelefono_ref,*/ vpago_venc, current);
                    END IF;

END FOREACH;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
        RETURNING vvcCod_ret;
		RETURN cCod_ret, cMensaje;

	END;
END PROCEDURE;