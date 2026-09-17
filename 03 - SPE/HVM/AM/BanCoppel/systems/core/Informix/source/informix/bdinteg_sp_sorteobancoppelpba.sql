CREATE PROCEDURE "informix".sp_sorteobancoppelpba(p_canal int,p_tpoper int,p_producto int, p_numcte char(9),p_sucursal char(4),p_foliosuc char(16),p_importe money(16,2),p_fecha date)
RETURNING CHAR(6) as cod_Ret,CHAR(80) as mensaje,INTEGER as rango_ini,INTEGER as rango_fin;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  v_RangoIni       INTEGER;
DEFINE  v_RangoFin       INTEGER;
DEFINE  v_cvesorteo      VARCHAR(6);
DEFINE  v_part1          INTEGER;
DEFINE  v_part2          INTEGER;
DEFINE  v_part3          INTEGER;
DEFINE  v_part4          INTEGER;
DEFINE  v_numbol         INTEGER;
DEFINE  v_persona        INTEGER;


BEGIN

 ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE,v_RangoIni,v_RangoFin;
   END EXCEPTION;

   --Set debug file to "/home/informix/man/manuel.out";
   --Trace on;

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   LET v_RangoIni = 0;
   LET v_RangoFin = 0;
   LET v_part1 = 0;
   LET v_part2 = 0;
   LET v_part3 = 0;
   LET v_part4 = 0;
   LET v_persona = 0;
   LET v_cvesorteo = '';


   LET SQL_ERR          = 0;
   LET ISAM_ERR         = 0;
   LET ERROR_INFO       = '';
   LET v_numbol         = 0;



SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

	FOREACH
			SELECT cve_sorteo INTO v_cvesorteo  FROM bdinteg:si_sorteo WHERE  p_fecha  BETWEEN f_ini AND  f_fin
			IF p_tpoper = '12' THEN
				LET v_persona = 1;
				LET p_producto = 9999;
            ELSE
--                SET LOCK MODE TO WAIT 3;
--                SET ISOLATION TO DIRTY READ;
				SELECT tpo_persona INTO v_persona  FROM bdinteg:si_cliente WHERE  numcte = p_numcte  AND empresa = '001';
			END IF;

--            SET LOCK MODE TO WAIT 3;
--            SET ISOLATION TO DIRTY READ;
			SELECT
			sum(case when tipo_participa = '1' and id_elemento = p_producto then 1 else 0 end) prod,
			sum(case when tipo_participa = '2' and id_elemento = p_tpoper then 1 else 0 end) trans,
			sum(case when tipo_participa = '3' and id_elemento = p_canal then 1 else 0 end) canal,
			sum(case when tipo_participa = '4' and id_elemento = v_persona then 1 else 0 end) tpo_per,
			sum(case when tipo_participa = '2' and id_elemento = p_tpoper  then (p_importe / val_min)::int  else 0 end) numbol
			INTO v_part1,v_part2,v_part3,v_part4,v_numbol
			FROM bdinteg:si_participa
			WHERE cve_sorteo = v_cvesorteo;

			IF v_part1 = 1 AND v_part2 = 1 AND v_part3 = 1 AND v_part4 = 1 AND v_numbol > 0 THEN
				--PIDE BOLETOS
				EXECUTE PROCEDURE bdinteg:sp_reparte_boletos(v_cvesorteo,p_numcte,p_sucursal,'B','1',p_tpoper,
			    p_foliosuc,p_importe,'',p_fecha,'0200000',v_numbol) INTO P_COD_RET,P_MENSAJE;

--                SET LOCK MODE TO WAIT 3;
--                SET ISOLATION TO DIRTY READ;
				--CONSULTA BOLETOS ENTREGADOS
				SELECT sum(case when secuencia = '1' then  boleto end )rango_ini,
				       sum(case when secuencia = v_numbol then boleto end )rango_fin
				INTO v_RangoIni,v_RangoFin
				FROM bdinteg:si_boleto
				WHERE foliosuc = p_foliosuc
				AND cve_sorteo = v_cvesorteo and numcte = p_numcte and importe = p_importe
				and fecha = p_fecha;
			ELSE
			   LET v_RangoIni = 0;
			   LET v_RangoFin = 0;
			   LET P_MENSAJE = 'NO CUMPLE CON PARAMETROS';
			END IF;

			RETURN P_COD_RET, P_MENSAJE,v_RangoIni,v_RangoFin;

	END FOREACH;

	IF v_cvesorteo = '' or v_cvesorteo is NULL THEN
		LET P_COD_RET = '00000';
		LET P_MENSAJE = 'NO EXISTE SORTEOS ACTIVOS EN ESTA FECHA';
     RETURN P_COD_RET, P_MENSAJE,v_RangoIni,v_RangoFin;
	END IF
END;
END PROCEDURE;