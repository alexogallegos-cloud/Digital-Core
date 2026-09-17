CREATE PROCEDURE "informix".sp_carga_telefonos(ptipo_campania char(1))
       RETURNING char(6), char(150);

-- Modificado por: Martha A Hernandez. Noviembre 2011. Se modifica para que procese tipo cobranza = R  de manera diaria.
-- Modificado por: MAHR Abril 2012. Se limita la generacion de archivos CAT, parametrizado por tipo cobranza.


--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(150);
DEFINE cCod_ret                     CHAR(6);
DEFINE vvcCod_ret                   CHAR(6);
DEFINE vempresa                     CHAR(3);
DEFINE vnumcte                      CHAR(20);
DEFINE vtelefono_casa               CHAR (13);
DEFINE vtelefono_celular            CHAR(13);
DEFINE vtelefono_trabajo            CHAR(13);
DEFINE vextension                   CHAR(5);
DEFINE vestatus                     CHAR(2);
DEFINE cproceso                     CHAR(4);
DEFINE wCod_Ret						CHAR(6);
DEFINE vtipored						CHAR(10);
DEFINE vnumero_carrier				CHAR(3);
DEFINE vtelefono_ref                CHAR(13);
DEFINE vnum_credito                 CHAR(20);
DEFINE vfech_insert                 DATE;

--SET DEBUG FILE TO "/ids10_uc9/jtrujillo/sp_carga_telefonos.out";
--TRACE ON; 

LET cCod_ret      = '000000';
LET sql_err       = 0;
LET isam_err      = 0;
LET error_info    = '';
LET cMensaje      = 'PROCESO EXITOSO';
LET vempresa      = '001';
LET vestatus      = 'AC';
LET cproceso      = '0008';   
LEt vnumcte       = '';      
      
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

    SELECT MAX(fecha_insert)  INTO vfech_insert 
        FROM bdicobranza:"informix".cb_cat_directorio_cte 
        WHERE empresa = vempresa 
        AND tipo_cobranza = ptipo_campania;
            
/*    SET ISOLATION TO dirty READ;
    SELECT {+INDEX(cb_cat_directorio_cte idx_cat_directorio2)} b.numcte, b.num_credito  
        FROM bdicobranza:"informix".cb_cat_directorio_cte b
        WHERE b.empresa = vempresa
        AND b.tipo_cobranza = ptipo_campania
        AND b.fecha_insert = vfech_insert
        AND b.numcte not in (select numcte from cb_telefonos)
        INTO TEMP tmp_dir_cte WITH NO LOG;

    ------------------------------- Se obtienen DATOS del CLIENTE y SALDOS---------------------------------------
    SET ISOLATION TO dirty READ;
    FOREACH

        SELECT     {+INDEX(bdinteg:si_direcciones_actual idx_diract_ctetpo)} b.numcte,   --- cliente
                       a.telefono1,                                                     --- t_casa
                       substr(a.telefono2,length(a.telefono2)-9,10),                    --- t_celular
                       a.telefono3,                                                     --- t_trabajo
                       a.extension,                                                     --- ext
                       b.num_credito
            INTO vnumcte, vtelefono_casa, vtelefono_celular,
                 vtelefono_trabajo, vextension, vnum_credito
            FROM bdinteg:"informix".si_direcciones_actual a, tmp_dir_cte b
            WHERE a.numcte = b.numcte
            AND a.tipo_dir = '1'
                       
        SELECT LIMIT 1 telefono_ref INTO vtelefono_ref
            FROM bdisolic:"informix".ss_refpersonales
            WHERE empresa = vempresa
            AND num_solicitud = vnum_credito
            AND numcte = vnumcte
            AND numcte_ref = 'R1';


        IF NOT EXISTS(SELECT {+INDEX (cb_telefonos idx_cons_telefono)} empresa FROM bdicobranza:"informix".cb_telefonos
                      WHERE empresa= vempresa and numcte = vnumcte AND telefono = vtelefono_casa and tipo_telefono = 1) THEN

            IF (vtelefono_casa <> '' AND vtelefono_casa <> '0' ) THEN
                EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (vempresa, vtelefono_casa) into wCod_ret , vtipored , vnumero_carrier;
                INSERT INTO bdicobranza:"informix".cb_telefonos (empresa,origen, numcte, tipo_telefono, telefono, extension, 
                                          estatus, tipored , fecha_insert, user_insert , numero_carrier)
                    VALUES(vempresa,2, vnumcte, 1, vtelefono_casa, '', vestatus, vtipored , today, user , vnumero_carrier);
            END IF;
        END IF;

        IF NOT EXISTS(SELECT {+INDEX (cb_telefonos idx_cons_telefono) } empresa FROM bdicobranza:"informix".cb_telefonos
                      WHERE empresa= vempresa and numcte = vnumcte AND telefono = vtelefono_celular and tipo_telefono = 2) THEN

            IF ( vtelefono_celular <> '' AND vtelefono_celular <> '0' ) THEN
                EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (vempresa, vtelefono_celular) into wCod_ret , vtipored , vnumero_carrier;

                INSERT INTO bdicobranza:"informix".cb_telefonos (empresa,origen, numcte, tipo_telefono, telefono, extension, 
                                          estatus, tipored , fecha_insert, user_insert , numero_carrier)
                    VALUES(vempresa, 2,vnumcte, 2, vtelefono_celular, '', vestatus, vtipored , today, user , vnumero_carrier);
            END IF;
        END IF;

        IF NOT EXISTS(SELECT {+INDEX (cb_telefonos idx_cons_telefono) } empresa FROM bdicobranza:"informix".cb_telefonos
                      WHERE empresa= vempresa AND numcte = vnumcte AND telefono = vtelefono_trabajo AND tipo_telefono= 3) THEN

            IF (vtelefono_trabajo <> '' AND vtelefono_trabajo <> '0' ) THEN

                EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (vempresa, vtelefono_trabajo) into wCod_ret , vtipored , vnumero_carrier;
                INSERT INTO bdicobranza:"informix".cb_telefonos (empresa,origen, numcte, tipo_telefono, telefono, extension, 
                                          estatus, tipored , fecha_insert, user_insert , numero_carrier)
                    VALUES(vempresa,2, vnumcte, 3, vtelefono_trabajo, '', vestatus, vtipored , today, user , vnumero_carrier);
            END IF;
        END IF;

        IF NOT EXISTS(SELECT {+INDEX (cb_telefonos idx_cons_telefono) } empresa FROM bdicobranza:"informix".cb_telefonos
                      WHERE empresa= vempresa and numcte = vnumcte AND telefono = vtelefono_ref and tipo_telefono = 4) THEN

            IF (vtelefono_ref <> '' AND vtelefono_ref <> '0' ) THEN
                EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (vempresa, vtelefono_ref) into wCod_ret , vtipored , vnumero_carrier;
                INSERT INTO bdicobranza:"informix".cb_telefonos (empresa,origen, numcte, tipo_telefono, telefono, extension, 
                                          estatus, tipored , fecha_insert, user_insert , numero_carrier)
                    VALUES(vempresa,2, vnumcte, 4, vtelefono_ref, '', vestatus, vtipored , today, user , vnumero_carrier);
            END IF;
        END IF;
               
    END FOREACH;
*/
    CALL bdicobranza:sp_cat_sintelefonos(ptipo_campania)
        RETURNING cCod_ret, cMensaje;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje , '03')
        RETURNING vvcCod_ret;

if (ptipo_campania = 'R') then
    IF (SELECT valor_numerico FROM bdicobranza:cb_param_campania WHERE empresa = '001' AND tipo_campania = 1
            AND grupo_parametro = 'CATARCHACT' AND valor_alfabetico = ptipo_campania) = 1 THEN

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso,cCod_ret, ' Inicia Archivos CAT' ,'02' ) RETURNING vvcCod_ret;

        CALL bdicobranza:"informix".sp_ctbcpl_gen_arcgeneracion(vempresa,vfech_insert,ptipo_campania) RETURNING vvcCod_ret ;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso,cCod_ret, 'Finaliza Generacion:'||vvcCod_ret,'02' ) RETURNING vvcCod_ret;  

        CALL bdicobranza:"informix".sp_ctbcpl_gen_arctelefonos(vempresa, ptipo_campania,vfech_insert,'AC') RETURNING vvcCod_ret;    
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso,cCod_ret, 'Finaliza Telefonos:'||vvcCod_ret,'02' ) RETURNING vvcCod_ret;

    END IF;
end if;
   
    RETURN cCod_ret, cMensaje;  

END;
END PROCEDURE;