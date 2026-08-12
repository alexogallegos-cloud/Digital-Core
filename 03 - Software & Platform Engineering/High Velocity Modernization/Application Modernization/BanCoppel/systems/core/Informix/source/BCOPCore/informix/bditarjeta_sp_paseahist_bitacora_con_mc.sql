CREATE PROCEDURE "informix".sp_paseahist_bitacora_con_mc(psCve_Usuario VARCHAR(10))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;
        DEFINE  SQL_ERR          INTEGER;
        DEFINE  ISAM_ERR         INTEGER;
        DEFINE  ERROR_INFO       VARCHAR(80);
        DEFINE  P_COD_RET        VARCHAR(6);
        DEFINE  P_COD_RET2       VARCHAR(6);
        DEFINE  P_MENSAJE        VARCHAR(80);
        DEFINE  iDias            INTEGER;
        DEFINE  dFechaFin        DATE;
        DEFINE  iNumReg          INTEGER;
        --  Variables para control de contadores
        DEFINE  vsflagentransaccion     char(1);
        DEFINE  vicontadorregistros     integer;
        DEFINE  vicontadorregistros2    integer;
		--  Variables de consulta
		DEFINE viconsecutivo INTEGER;
		DEFINE vielemento    INTEGER;
		DEFINE vdfecha_hora  datetime year to fraction(5);
		DEFINE vcactividad   CHAR(250);
		DEFINE vccve_usuario CHAR(10);

        --SET DEBUG FILE TO "/RESPALDOSNEW/case/ss_conciliacionautomatica_mc/trans_bit_mc_to_hist.out";
        --TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;

                EXECUTE PROCEDURE sp_bit_conc_hist_mc(50
                ,'Error en sp_tras_bitacorahis_con ' || SQL_ERR || ' ' || P_MENSAJE
                ,psCve_usuario) into P_COD_RET;
      RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--************************************************************
-- Creado por Softtek case3
-- fecha : 06/03/2024
-- Funcion: Traspaso de Informacion de bitacora concilicacion MasterCard a historico
--************************************************************
   LET vsflagentransaccion = 'F';
   LET vicontadorregistros = 0;
   LET vicontadorregistros2 = 0;
   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO TRASNFERENCIA DE BITACORA CONCILIACION MASTERCARD A HISTORICOS';
   LET iDias = 0;
   LET iNumReg = 0;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        SELECT valor INTO iDias FROM bditarjeta:"informix".td_param_conciliacion_mc WHERE codigo = '355';


        IF (iDias == 0) THEN
           LET P_COD_RET = '00000';
           LET P_MENSAJE = 'NO EXISTEN DIAS A SUBSTRAER.. ';
        ELSE

		set isolation to dirty read;
        foreach cusor1 with hold
            for
				SELECT consecutivo,elemento,fecha_hora,actividad,cve_usuario
				INTO viconsecutivo,vielemento,vdfecha_hora,vcactividad,vccve_usuario
				FROM bditarjeta:"informix".td_bitacora_conciliacion_mc
				WHERE date(fecha_hora)<=TODAY-iDias

			    if(vsflagentransaccion = 'F') then
                    begin work;
					let vsflagentransaccion = 'V';
				end if;

                INSERT INTO bditarjeta:"informix".td_bitacora_conciliacion_hist_mc(consecutivo,elemento,fecha_hora,actividad,cve_usuario)
				VALUES(viconsecutivo,vielemento,vdfecha_hora,vcactividad,vccve_usuario);



				DELETE FROM bditarjeta:"informix".td_bitacora_conciliacion_mc
				WHERE consecutivo=viconsecutivo
				AND elemento=vielemento
				AND fecha_hora=vdfecha_hora
				AND actividad=vcactividad
				AND cve_usuario=vccve_usuario;

				let vicontadorregistros = vicontadorregistros + 1;
                let vicontadorregistros2 = vicontadorregistros2 + 1;

                if (vicontadorregistros2 = 100000) then
                    update statistics medium for table bditarjeta:"informix".td_bitacora_conciliacion_hist_mc;
                    let vicontadorregistros2 = 0;
                end if;

                if (vicontadorregistros = 1000) then
                    commit work;
                    let vsflagentransaccion = 'F';
                    let vicontadorregistros = 0;
                    continue foreach;
                end if;
        end foreach;

                if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
                                commit work;
                                update statistics medium for table bditarjeta:"informix".td_bitacora_conciliacion_hist_mc;
                                let vsflagentransaccion = 'F';
                end if;

				EXECUTE PROCEDURE sp_bit_conc_hist_mc(50
                ,'Exito en Traspaso de  Bitacora conc. MasterCard a Hist (sp_tras_bitacorahis_con_mc) '
                ,psCve_usuario) into P_COD_RET;


                EXECUTE PROCEDURE sp_bit_conc_hist_mc(50
                ,'Exito en eliminacion de registros de Bitacora conciliaciÃ³n MasterCard a Historico (sp_tras_bitacorahis_con_mc)'
                ,psCve_usuario) into P_COD_RET;

        END IF;
        RETURN P_COD_RET,P_MENSAJE;

END;
END PROCEDURE;