CREATE PROCEDURE "informix".sp_estadisticas_sac_altactes_estado
( fechaInicio date, fechaFin date )

RETURNING
	CHAR(5) AS codigo_respuesta,
	CHAR(80) AS mensaje_respuesta;

	DEFINE cCodRet CHAR(5);
	DEFINE cMensaje CHAR(80);
	
    DEFINE usuario CHAR(9);
	DEFINE iSqlErr INT;
    DEFINE iIsamErr INT;
    DEFINE cInfoErr CHAR;
    DEFINE Vsp CHAR(100);
    DEFINE Vid_sp INTEGER;
    DEFINE Vperiodo CHAR(25);
	
	DEFINE dFecha_insert DATE;
	DEFINE cTipo_cliente CHAR(1);
	DEFINE cSucursal CHAR(4);
	
	DEFINE cSPCodRet CHAR(5); 
	DEFINE iMensaje CHAR(50);
	DEFINE cid_ptf CHAR(5); 
	DEFINE ccve_pais CHAR(3);
	DEFINE cnompais CHAR(20);
	DEFINE ccalle VARCHAR(100); 
	DEFINE cnum_ext VARCHAR(6); 
	DEFINE cnum_int VARCHAR(5); 
	DEFINE ccve_col CHAR(8);
	DEFINE cnomcol VARCHAR(100);
	DEFINE ccve_mun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE ccve_localidad CHAR(14);
	DEFINE cnomlocalidad VARCHAR(60);
	DEFINE ccp CHAR(5); 
	DEFINE ccve_ciudad CHAR(3);
	DEFINE cnomciudad VARCHAR(60);
	DEFINE ccve_estado CHAR(2); 
	DEFINE cnomestado VARCHAR(30);
	DEFINE ctel1 VARCHAR(14); 
	DEFINE ctel2 VARCHAR(14);
	DEFINE ctipo VARCHAR(5);
    
	LET cCodRet = "00000";
	LET cMensaje = 'PROCESO EXITOSO';
	
    LET usuario ='informix';    
    LET Vsp = 'sp_estadisticas_sac_altactes_estado';
    LET Vid_sp = '9';

    LET Vperiodo = fechaInicio || ' a ' || fechaFin;
	
	LET dFecha_insert = '';
	LET cTipo_cliente = '';
	LET cSucursal = '';
	
	LET cSPCodRet = '00000';
	LET iMensaje = '';
	LET cid_ptf = '';
	LET ccve_pais = '';
	LET cnompais = '';
	LET ccalle = '';
	LET cnum_ext = ''; 
	LET cnum_int = '';
	LET ccve_col = '';
	LET cnomcol = '';
	LET ccve_mun = '';
	LET cnommunicipio = '';
	LET ccve_localidad = '';
	LET cnomlocalidad = '';
	LET ccp = '';
	LET ccve_ciudad = '';
	LET cnomciudad = '';
	LET ccve_estado = ''; 
	LET cnomestado = '';
	LET ctel1 = '';
	LET ctel2 = '';
	LET ctipo = '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/ifxsif01/Control-M/sp_estadisticas_sac_altactes_estado.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
                VALUES(current, Vid_sp, cCodRet, Vperiodo, usuario, current); -- Actualizado RALVAREZ 10/10/2022
				RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;
		
		DROP TABLE IF EXISTS TB_SAC_ALTACTES_ESTADO;
		
		CREATE TEMP TABLE TB_SAC_ALTACTES_ESTADO (estado CHAR(25),sucursal char(4), fecha_insert DATE, tipo_cte CHAR(1)) WITH NO LOG; 		

		FOREACH
			select {+INDEX(bdinteg:"informix".si_cliente.idx_fecha_insert)} 				  				
			C.fecha_insert, C.tipo_cliente, C.sucursal
			into dFecha_insert, cTipo_cliente, cSucursal
			from bdinteg:"informix".si_cliente C
			where C.fecha_insert >= mdy(month(fechaInicio),day(fechaInicio),year(fechaInicio)) 
			and C.fecha_insert <= mdy(month(fechaFin),day(fechaFin),year(fechaFin))
			
			execute procedure bdisac:"informix".sp_sac_consucursales(cSucursal) into cSPCodRet,iMensaje,cid_ptf,ccve_pais,cnompais,ccalle,cnum_ext, cnum_int,ccve_col,cnomcol,ccve_mun,cnommunicipio,ccve_localidad,cnomlocalidad,ccp,ccve_ciudad,cnomciudad,ccve_estado,cnomestado,ctel1,ctel2,ctipo;

			insert into TB_SAC_ALTACTES_ESTADO (estado,sucursal, fecha_insert, tipo_cte)
			values (cnomestado,cSucursal,dFecha_insert,cTipo_cliente);

		END FOREACH;
		
			insert into "informix".sac_estadisticas_altactes_estado (mes, anio, mesanio, estado, cant_sucursales, titulares, no_titulares, total, user_insert, fecha_insert, sp, periodo)
		select month(fecha_insert) as mes
			, year(fecha_insert) as anio
			, DECODE(MONTH(fecha_insert),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(fecha_insert) as mesanio 
			, estado
			, count(distinct(sucursal)) as cant_suc
			, sum(case tipo_cte when '1' then 1 else 0 end) as ctes_titulares
			, sum(case tipo_cte when '1' then 0 else 1 end) as ctes_notitulares
			, COUNT(*) as ctes_todos
			, usuario
			, current
			, trim(Vsp)
			, Vperiodo
		from TB_SAC_ALTACTES_ESTADO
			group by 2,1,3,4
			order by 2,1,3,4 asc;
		
		DROP TABLE IF EXISTS TB_SAC_ALTACTES_ESTADO;

		INSERT INTO "informix".tb_ejecucion_estadisticas_sac(fecha_hora_ejecucion, id_sp, resultado, periodo, usuario_insert, fecha_insert) 
                VALUES(current, Vid_sp, cCodRet, Vperiodo, usuario, current); -- Actualizado RALVAREZ 10/10/2022
		RETURN cCodRet, cMensaje;
	END;

END PROCEDURE;