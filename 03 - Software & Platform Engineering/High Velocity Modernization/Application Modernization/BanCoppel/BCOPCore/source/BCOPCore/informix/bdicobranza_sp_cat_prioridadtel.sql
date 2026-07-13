CREATE PROCEDURE "informix".sp_cat_prioridadtel(vtipo_cobranza SMALLINT)
       RETURNING char(6), char(150);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(150);
DEFINE cCod_ret                     CHAR(6);
DEFINE vempresa                     CHAR(3);
DEFINE vnumcte                      CHAR(20);
DEFINE vtelefono                    CHAR (13);
DEFINE vtipo_telefono               INTEGER;
DEFINE vmes_marcado                 INTEGER;
DEFINE vveces_marcado               INTEGER;
DEFINE vcodigo_resultado            INTEGER;
DEFINE vstatus_siguiente            CHAR(2);
DEFINE vextension                   CHAR(5);
DEFINE vestatus                     CHAR(2);
DEFINE vveces_contemplado           INTEGER;
DEFINE vvcCod_ret                   CHAR(6);
DEFINE cproceso                     CHAR(4);

    --SET DEBUG FILE TO "/ids10_uc9/jtrujillo/sp_carga_telefonos.out";
    --TRACE ON; 

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
      LET vempresa      = '001';
      LET cproceso      = '0011';
            
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

FOREACH

    SELECT a.empresa, a.numcte, a.telefono, a.tipo_telefono,
            a.estatus, b.mes_marcado, b.veces_marcado, b.codigo_resultado, a.extension, b.veces_contemplado
    INTO vempresa, vnumcte, vtelefono, vtipo_telefono,
            vestatus, vmes_marcado, vveces_marcado, vcodigo_resultado, vextension, vveces_contemplado
    FROM bdicobranza:cb_telefonos a, bdicobranza:cb_registro_llamadas b
    WHERE a.empresa = b.empresa
    AND a.numcte = b.numcte
    AND a.telefono = b.telefono
    AND a.tipo_telefono = b.tipo_telefono
    --go
    
---BUSQUEDA  DE ESTATUS---
    LET vstatus_siguiente ='';
    SELECT nvl(status_siguiente, '') status_siguiente
    INTO vstatus_siguiente
    FROM bdicobranza:cb_cattelefonos_logica
    WHERE empresa= vempresa
    AND codigo_resultado = vcodigo_resultado
    AND total_llamadas = vveces_marcado
    AND llamadas_por_mes = vmes_marcado
    AND status_actual = vestatus
    AND veces_contemplado = vveces_contemplado;

---VALIDACION DE ESTATUS Y ACTUALIZACION EN TABLA DE TELEFONOS---
    IF vstatus_siguiente <> '' THEN

        UPDATE bdicobranza:cb_telefonos
        SET estatus = vstatus_siguiente
        WHERE empresa = vempresa
        AND numcte = vnumcte
        AND telefono = vtelefono
        AND tipo_telefono = vtipo_telefono
        and extension = vextension;

    END IF;

END FOREACH;

	    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
        RETURNING vvcCod_ret;

        RETURN cCod_ret, cMensaje;

	END;
END PROCEDURE;