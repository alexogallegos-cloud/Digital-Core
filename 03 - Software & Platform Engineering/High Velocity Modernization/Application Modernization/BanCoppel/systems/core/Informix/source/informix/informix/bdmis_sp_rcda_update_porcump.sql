CREATE PROCEDURE "informix".sp_rcda_update_porcump()
RETURNING 	CHAR(06) AS cod_ret,
			CHAR(80) as mensaje;
			
--VARIABLES DE EETORNO
	DEFINE	cod_ret			 CHAR(06);
	DEFINE	mensaje			 CHAR(80);
	
--DEFINICION DE VARIABLES DE CONTROL DE ERRORES 
	DEFINE  SQL_ERR          INTEGER;   
	DEFINE  ERROR_INFO       VARCHAR(180);	
	DEFINE  ISAM_ERR         INTEGER;
--DEFINICION DE VARIABLES DE PROCESO
	DEFINE	vpaso			 INTEGER;
	DEFINE	dfecha			 DATE;
	
BEGIN	
  ON EXCEPTION SET SQL_ERR, ISAM_ERR,ERROR_INFO
	  LET  cod_ret      = 	SQL_ERR;
	  LET  mensaje  = 	ERROR_INFO || ' sp_rcda_update_porcump en paso ' || vpaso;	  
	  RETURN cod_ret, mensaje;
   END EXCEPTION;
   
   
   SET ISOLATION TO dirty read;
    let vpaso =1;
    SELECT suc.num_sucursal as sucursal, (tp.meta_monto_cap / 30.5)as  meta_monto_cap
    FROM mi_sucursalesinfo suc , mi_tiposuc tp
    WHERE aniomes = '201412' and  suc.tipo_suc = tp.id_tiposuc
    into temp tmp_meta_sdomes WITH NO LOG;

	let vpaso =1;
	foreach cursor1 WITH HOLD FOR
	SELECT 	DISTINCT(fecha)
	INTO	dfecha
	FROM 	mi_his_sdo 
	WHERE (fecha BETWEEN '01/05/2015' AND '01/15/2015') and tpo_reg = 2
	
		let vpaso =3;
		UPDATE mi_his_sdo  SET Incre_SdoDia = (select (mes.saldo_mes - dia.saldo_ant) FROM
		mi_acumsdo_mes mes
		join mi_sdodia_anterior dia on mes.sucursal = dia.sucursal
		WHERE mes.aniomes ='201412' and dia.fecha =dfecha and mes.sucursal= mi_his_sdo.sucursal
		)
		 WHERE tpo_reg = 2 and fecha =dfecha;

		let vpaso =4;
		UPDATE mi_his_sdo  SET por_CumpDia = (select ((mes.saldo_mes - dia.saldo_ant) / ((select meta_monto_cap  from tmp_meta_sdomes cap where cap.sucursal = mes.sucursal ) * day(dia.fecha) )) * 100 FROM
		mi_acumsdo_mes mes
		join mi_sdodia_anterior dia on mes.sucursal = dia.sucursal
		WHERE mes.aniomes ='201412' and dia.fecha =dfecha and mes.sucursal= mi_his_sdo.sucursal
		)
		 WHERE tpo_reg = 2 and fecha =dfecha;
	 
	END foreach;
	RETURN '000000','PROCESO EXITOSO'; 
END	 
END PROCEDURE;