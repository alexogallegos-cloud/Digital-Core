CREATE PROCEDURE "informix".sp_genera_saldos_previos_edc(pempresa CHAR(3))
        RETURNING CHAR(5)
		
		
		DEFINE v_ruta      	VARCHAR(255);
        DEFINE cod_ret     	CHAR(5);
        DEFINE sql_err     	INTEGER;
        DEFINE v_sql        CHAR(8000);
        DEFINE v_sql1       CHAR(8000);
        DEFINE v_sql2       CHAR(8000);
        DEFINE v_sql3       CHAR(8000);
        DEFINE v_sql4       CHAR(8000);
        DEFINE v_fecha_hoy	DATE;
        DEFINE iFinDiaAnt   INTEGER;
		DEFINE iFinMesAnt   INTEGER;
		DEFINE iFinAnioAnt  INTEGER;
		DEFINE iMesAct   	INTEGER;
		DEFINE iAnioAct  	INTEGER;
		
		LET v_ruta      = "";
        LET v_sql       = "";
        LET v_sql1      = "";
        LET v_sql2      = "";
        LET v_sql3      = "";
        LET v_sql4      = "";
        LET iFinDiaAnt 	= 0;
		LET iFinMesAnt 	= 0;
		LET iFinAnioAnt = 0;
		LET iMesAct 	= 0;
		LET iAnioAct 	= 0;
		LET v_fecha_hoy = DATE(1);
		
/* 		SET DEBUG FILE TO "/informix/Rebeca/sp_genera_saldos_previos_edc.out";
        TRACE ON; */
		
		BEGIN

			ON EXCEPTION SET sql_err
				LET cod_ret = sql_err;
				RETURN cod_ret;
			END EXCEPTION;
			
			LET cod_ret = "00000";
			SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '033';
						
			select day(pri_dia_mes-1), month(add_months((pri_dia_mes),-1)) mes_ant, year(add_months((pri_dia_mes),-1)) anio_ant, month(fecha_hoy) mes_act, year(fecha_hoy) anio_act,fecha_hoy 
					into iFinDiaAnt,iFinMesAnt,iFinAnioAnt,iMesAct,iAnioAct,v_fecha_hoy
			from bdicred:sd_fechas; 
			
			LET v_sql1 = 	' echo set isolation to dirty read; ' ||
                            ' echo "UNLOAD TO '||trim(v_ruta)||'SaldosPreviosEdocta'||to_char(v_fecha_hoy,"%m%Y")||'.txt '||
							' select a.num_credito,'||
							'c.capvig21,c.captrans21,c.capvencnoexig21,c.capvenexig21,'||
							'c.capvig22,c.captrans22,c.capvencnoexig22,c.capvenexig22,'||
							'c.capvig23,c.captrans23,c.capvencnoexig23,c.capvenexig23,'||
							'c.capvig24,c.captrans24,c.capvencnoexig24,c.capvenexig24,'||
							'c.capvig25,c.captrans25,c.capvencnoexig25,c.capvenexig25,'||
							'c.capvig26,c.captrans26,c.capvencnoexig26,c.capvenexig26,'||
							'c.capvig27,c.captrans27,c.capvencnoexig27,c.capvenexig27,'||
							'c.capvig28,c.captrans28,c.capvencnoexig28,c.capvenexig28,'||
							'c.capvig29,c.captrans29,c.capvencnoexig29,c.capvenexig29,'||
							'c.capvig30,c.captrans30,c.capvencnoexig30,c.capvenexig30,'||
							'c.capvig29,c.captrans29,c.capvencnoexig29,c.capvenexig29,'||
							'c.capvig30,c.captrans30,c.capvencnoexig30,c.capvenexig30,'||
							'c.capvig31,c.captrans31,c.capvencnoexig31,c.capvenexig31,';
			
			LET v_sql2 =	'b.capvig1,b.captrans1,b.capvencnoexig1,b.capvenexig1,'||
							'b.capvig2,b.captrans2,b.capvencnoexig2,b.capvenexig2,'||
							'b.capvig3,b.captrans3,b.capvencnoexig3,b.capvenexig3,'||
							'b.capvig4,b.captrans4,b.capvencnoexig4,b.capvenexig4,'||
							'b.capvig5,b.captrans5,b.capvencnoexig5,b.capvenexig5,'||
							'b.capvig6,b.captrans6,b.capvencnoexig6,b.capvenexig6,'||
							'b.capvig7,b.captrans7,b.capvencnoexig7,b.capvenexig7,'||
							'b.capvig8,b.captrans8,b.capvencnoexig8,b.capvenexig8,'||
							'b.capvig9,b.captrans9,b.capvencnoexig9,b.capvenexig9,'||
							'b.capvig10,b.captrans10,b.capvencnoexig10,b.capvenexig10,'||
							'b.capvig11,b.captrans11,b.capvencnoexig11,b.capvenexig11,'||
							'b.capvig12,b.captrans12,b.capvencnoexig12,b.capvenexig12,'||
							'b.capvig13,b.captrans13,b.capvencnoexig13,b.capvenexig13,'||
							'b.capvig14,b.captrans14,b.capvencnoexig14,b.capvenexig14,'||
							'b.capvig15,b.captrans15,b.capvencnoexig15,b.capvenexig15,'||
							'b.capvig16,b.captrans16,b.capvencnoexig16,b.capvenexig16,'||
							'b.capvig17,b.captrans17,b.capvencnoexig17,b.capvenexig17,'||
							'b.capvig18,b.captrans18,b.capvencnoexig18,b.capvenexig18,'||
							'b.capvig19,b.captrans19,b.capvencnoexig19,b.capvenexig19,'||
							'b.capvig20,b.captrans20,b.capvencnoexig20,b.capvenexig20, a.tasa_interes '||
							'from bdicred:sd_maecred a ';
			LET v_sql3 = 	'join bdicred:sd_sdodiario b on (b.fecha=mdy('||iMesAct||',01,'||iAnioAct||') and  a.num_credito = b.num_credito) ' ||
							'join bdicred:sd_sdodiario c on (c.fecha=mdy('||iFinMesAnt||',01,'||iFinAnioAnt||') and  a.num_credito = c.num_credito) ' ||
							'where a.empresa = '''||pempresa||''' ' ||
							'and a.status_cred not in (''CV'') ' ||
							'and fecha_apertura <= mdy('|| month(v_fecha_hoy)||','||day(v_fecha_hoy)||','||year(v_fecha_hoy)||') ' ||
							'and a.sucursal = ''0002''" > queryNEC.sql';
			
			LET v_sql = trim(v_sql1)||trim(v_sql2)||' '||trim(v_sql3);
			SYSTEM v_sql;

			LET v_sql = "dbaccess bdicred queryNEC.sql";
			SYSTEM v_sql;
			
			LET v_sql = '';
			LET v_sql = 'rm queryNEC.sql ';
			SYSTEM v_sql;
			
		END;
	RETURN cod_ret;
END PROCEDURE;