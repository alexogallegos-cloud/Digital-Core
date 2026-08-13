create procedure "informix".sp_rcda()
RETURNING char (05) as cod_ret,
		  char (180) as mensaje;
		  
--declaracion de variables
DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFecha           Date;
DEFINE  dFechafto        char(10);
DEFINE  dFechaCorte      Date;
DEFINE  dFechaAnt        Date;
DEFINE  dFechaAnioAnt    Date;
DEFINE  cFechaAnioAnt    char(06);
DEFINE  dFechahoy        Date;
DEFINE  dult_dia_mes     Date;	
DEFINE  iCuantos         INTEGER;
DEFINE  cVarDataErr      char(120);
DEFINE  cCodret          char(5);	
DEFINE  vpaso			 integer;	
DEFINE  iDiasMes         INTEGER;
DEFINE  dfechaantier     Date;

/*variables para el cambio de fechas*/	

DEFINE	bempresa			char(3);
DEFINE	bfecha_hoy			date;
DEFINE	bfecha_ant			date;
DEFINE	bprox_fecha			date;
DEFINE	bpri_dia_mes		date;
DEFINE	bpri_hab_mes		date;
DEFINE	bult_dia_mes		date;
DEFINE	bult_hab_mes		date;
	

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO || ' sp_rcda en paso ' || vpaso;
	  insert into mi_rptcierresucerror (fecha_cierre,estatus_ejec,codigo_error,desc_error )
	  select fecha_ant,'F',P_COD_RET, P_MENSAJE  from bdmis:mi_fechas;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;
   
	LET P_COD_RET = '000';
	LET P_MENSAJE = 'EL PROCESO PUEDE CONTINUAR';
   
   
--cambio de fechas de la bdmis

	let vpaso = 0; 
	set isolation to dirty read;

	select empresa,fecha_hoy,fecha_ant,prox_fecha,pri_dia_mes,pri_hab_mes,ult_dia_mes,ult_hab_mes
	into bempresa, bfecha_hoy, bfecha_ant, bprox_fecha, bpri_dia_mes, bpri_hab_mes, bult_dia_mes, bult_hab_mes
	from bdinteg:si_fechas;

	let vpaso = 1; 
	update bdmis:mi_fechas set empresa = bempresa, fecha_hoy = bfecha_hoy, fecha_ant = bfecha_ant,
	prox_fecha = bprox_fecha, pri_dia_mes = bpri_dia_mes, pri_hab_mes = bpri_hab_mes,
	ult_dia_mes = bult_dia_mes, ult_hab_mes = bult_hab_mes where empresa = '001';		  

	let vpaso = 2; 
	set isolation to dirty read;
	select fecha_ant,day(ult_dia_mes)::int, (fecha_ant-1), fecha_hoy, ult_dia_mes 
	into dFecha,iDiasMes, dfechaantier, dFechahoy, dult_dia_mes 
	from bdmis:mi_fechas;
	
	let vpaso = 3; 
--// Busca si ya existen las Temporales
	EXECUTE PROCEDURE sp_buscatemporal('solicis')
	   INTO cCodret, cVarDataErr, iCuantos;
	IF cCodret = '000' THEN
	   DROP TABLE solicis;
	END IF
	EXECUTE PROCEDURE sp_buscatemporal('mi_rptsolic2')
	   INTO cCodret, cVarDataErr, iCuantos;
	IF cCodret = '000' THEN
	   DROP TABLE mi_rptsolic2;
	END IF
	EXECUTE PROCEDURE sp_buscatemporal('tmpmi_cierresucacumtdc')
	   INTO cCodret, cVarDataErr, iCuantos;
	IF cCodret = '000' THEN
	   DROP TABLE tmpmi_cierresucacumtdc;
	END IF            
				
	EXECUTE PROCEDURE sp_buscatemporal('metaprod')
	   INTO cCodret, cVarDataErr, iCuantos;
	IF cCodret = '000' THEN
	   DROP TABLE metaprod;
	END IF
-- Se agregan nuevas tablas temporales utilizadas en el cálculo nuevo de las ponderaciones - HLA - 02/03/2012
	EXECUTE PROCEDURE sp_buscatemporal('metaprod_backup')
	   INTO cCodret, cVarDataErr, iCuantos;
	IF cCodret = '000' THEN
	   DROP TABLE metaprod_backup;
	END IF
				
	EXECUTE PROCEDURE sp_buscatemporal('metaprod_backup2')
	   INTO cCodret, cVarDataErr, iCuantos;
	IF cCodret = '000' THEN
	   DROP TABLE metaprod_backup2;
	END IF			
					
	let vpaso = 4; 
	IF (select count(ejecutivo) from mi_rptcierresuc where fecha_cierre = dFecha) = 0 THEN			

		begin work;
			UPDATE bdmis:mi_param SET estatus = 'F' WHERE descripcion = 'FLAG RPT CIERRE';				
		commit work;
				
		/*if day(dFechahoy)  = '2' or day(dFechahoy) = '02' then

			EXECUTE PROCEDURE sp_depurar_historico(dFecha)
			into P_COD_RET, P_MENSAJE;

			if cCodret <> '0' then
				return P_COD_RET, P_MENSAJE;
			end if;
		end if;*/

	else

		LET P_COD_RET = '001';
		LET P_MENSAJE = 'Fecha ya Procesada ';
		insert into mi_rptcierresucerror values (dFecha,'F',P_COD_RET,P_MENSAJE );

	end if

	return 	P_COD_RET, P_MENSAJE;
END	
end procedure;