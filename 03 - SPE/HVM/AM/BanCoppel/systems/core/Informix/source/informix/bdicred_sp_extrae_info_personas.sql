CREATE PROCEDURE "informix".sp_extrae_info_personas() 
	Returning char(7);

	/*DEFINICIÃ?N DE VARIABLES*/
	--Variables de retorno
	DEFINE vcodret				char(5);	
	DEFINE vsqlerr				integer;
	
	--Variable para ejecuciÃ³n de comandos
	DEFINE vsql	        		char(3000);
	

---INICializacion de variables
	
	let vcodret = "00000";
	let vsqlerr = 0;
	
	Let vsql='';


--SET DEBUG FILE TO "/RESPALDOSNEW/aclaraciones/sp_repaltaunicaidbox.out";
 --TRACE ON;
	--LET v_tiempo = CURRENT;
	begin	
		
		On exception set vsqlerr		
			if vsqlerr<>0 then
				let vcodret = vsqlerr;
				COMMIT WORK;
				return vcodret;
			end if;
		end exception;
		
		

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
      


	BEGIN WORK;
		--generacion de reporte 
		
		let vsql=  'echo "UNLOAD TO /bitacoras/cobranza/Temp_People.txt '||
			'SELECT customer_id,identity_code,seq,first_surname,first_name,sex,civil_status,address_type1,zone1,city1,use_this_1,address_type2,'||' '||
			'zone2,city2,use_this_2,telephone_type1,addr_tel_type1,telephone_type2,addr_tel_type2,income_payment_type,income_payment_day,'||' '||
			'reviewed,company,second_surname,midlle_name,birth_date,addres_number1,province1,country1,po_box1,strata1,addres_number2,'||' '||
			'province2,country2,po_box2,strata2,area_code1,telephone_number1,extention1,county_code1,area_code2,telephone_number2,'||' '||
			'extention2,county_code2,ocupation,profession,income,persons_in_charge,work_timetable_start,work_timetable_end,user_defined1,'||' '||
			'return_id,qualification,common_id,latitude1,longitude1,latitude2,longitude2 FROM ics_personas;">/bitacoras/cobranza/Temp_People.sql';
		system vsql;
		let vsql= 'dbaccess bdicred /bitacoras/cobranza/Temp_People.sql';
		system vsql;
		let vsql ='rm  /bitacoras/cobranza/Temp_People.sql';
		system vsql;
	
		let vcodret = '00000';					
	COMMIT WORK;		
	
		return vcodret;
		
	end;
end procedure
DOCUMENT
'Sp para generaciÃ³n de Reporte Mensual IDBox',
'AUTOR : Rey David Zavala Garcia.',
'Area: Bnaca Comercial',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Norberto Corona',
'FECHA : 21/Abril/2020',
'VERSION: 1.0.0',
'BD    :  bdinteg';

CREATE PROCEDURE "informix".sp_genera_ec_tdc_muestras()
--EXECUTE PROCEDURE sp_genera_ec_tdc_muestras();

RETURNING CHAR(5);

--DECLARACION
DEFINE vCodRet			CHAR(05);
DEFINE cMensaje    	 	CHAR(100); 
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr     	INTEGER;
DEFINE vMes				CHAR(02);
DEFINE vAnio			CHAR(04);
DEFINE vFecha			DATE;
DEFINE contador_ec  	INTEGER;
DEFINE numero_cre  		VARCHAR(20,1);
DEFINE fecha_emi  		DATE;
DEFINE centro_imp_var  	CHAR(06);
DEFINE centro_imptemp  	CHAR(06);
DEFINE centro_impanterior CHAR(06);
DEFINE numero_reg  		INTEGER;
DEFINE contador_aux 	CHAR(06);
DEFINE vCentroDis		INTEGER;

--INICIALIZACION
LET vCodRet        	= '00000';
LET cMensaje    	= 'Ejecucion Exitosa';
LET iSqlErr     	= 0;
LET iIsamErr    	= 0;
LET vMes			= '';
LET vAnio			= '';
LET vFecha			= date(1);
LET contador_ec  	= 0;
LET numero_cre 		= "";
LET fecha_emi 		= DATE(1);
LET centro_imp_var 	= "";	
LET centro_imptemp 	= "";
LET centro_impanterior 	= "";
LET numero_reg 		= 0;
LET contador_aux 	= '0';
LET vCentroDis		= 0;

--SET DEBUG FILE TO "/informix/ALEOUT/generacion_ec_tdc.out";
--TRACE ON; 

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
			LET vCodRet = iSqlErr;		
            LET cMensaje = 'Error en la ejecucion';
            RETURN vCodRet;
		END IF;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- Recupera la fecha
	SELECT LPAD(MONTH(fecha_hoy),2,0), YEAR(fecha_hoy)
	INTO vMes, vAnio
	FROM bdicred:sd_fechas
	WHERE empresa = '001';
	
	LET vFecha = MDY(vMes,20,vAnio);
	--LET vFecha = mdy('07','20','2021'); -- para pruebas
	
	SELECT centro FROM bdinteg:"informix".si_catzonas where centro is null
	into temp centros_distrib;
	
	FOREACH WITH HOLD
		SELECT centro INTO vCentroDis FROM centros_distrib
		
		IF vCentroDis is null THEN
		BEGIN;
			UPDATE bdinteg:"informix".si_catzonas SET centro = 999999 WHERE centro is null;
		COMMIT;
		END IF;
	END FOREACH;

	SELECT a.num_credito, a.fecha_emision, c.numerociudadcoppel, c.centro, c.jefegrupozona, c.supervisorzona, c.numerocoloniacoppel,
		   b.numerocalle, b.numeroextcalle, b.tipo_dir
	FROM bdicred:sd_encabezado_edocta a 
	INNER JOIN bdinteg:si_direcciones_actual b ON a.numcte = b.numcte AND b.tipo_dir = '1' 
	INNER JOIN bdinteg:si_catzonas c ON nvl(c.numerociudad,0) = nvl(b.numerociudad,0) AND nvl(c.numerocolonia,0) = nvl(b.numerocolonia,0)
	WHERE a.fecha_emision = vFecha AND a.num_credito NOT IN('000','100')
	and c.centro is not null
	INTO TEMP creditostdc_ec WITH NO LOG;

	INSERT INTO creditostdc_ec
	SELECT a.num_credito, a.fecha_emision, c.numerociudadcoppel, c.centro, c.jefegrupozona, c.supervisorzona, c.numerocoloniacoppel,
		   b.numerocalle, b.numeroextcalle, b.tipo_dir
	FROM bdicred:sd_encabezado_edocta a 
	LEFT OUTER JOIN bdinteg:si_direcciones_actual b ON a.numcte = b.numcte --AND b.tipo_dir = 1 
	LEFT OUTER JOIN bdinteg:si_catzonas c ON nvl(c.numerociudad,0) = nvl(b.numerociudad,0) AND nvl(c.numerocolonia,0) = nvl(b.numerocolonia,0)
	WHERE a.fecha_emision = vFecha AND a.num_credito NOT IN('000','100')
	and c.centro is not null
	AND a.num_credito NOT IN(select num_credito from creditostdc_ec);
	
	
	SELECT num_credito, fecha_emision, numerociudadcoppel, centro, jefegrupozona, supervisorzona, numerocoloniacoppel,
		   numerocalle, numeroextcalle, tipo_dir 
	FROM creditostdc_ec 
	group by centro, numerociudadcoppel,jefegrupozona, supervisorzona, numerocoloniacoppel,numerocalle, numeroextcalle, tipo_dir,fecha_emision,num_credito
	INTO TEMP tmpNumeroRegistros WITH NO LOG;
 

	FOREACH WITH HOLD 

		SELECT num_credito, fecha_emision, centro INTO numero_cre, fecha_emi, centro_imp_var FROM tmpNumeroRegistros
		ORDER BY centro::INTEGER, numerociudadcoppel, jefegrupozona, supervisorzona, numerocoloniacoppel, numerocalle, numeroextcalle
		
		IF centro_imp_var IS NULL THEN
			LET centro_imp_var = 999999;
		END IF;

		/*IF (contador_aux = 0) THEN

			LET centro_imptemp = centro_imp_var;

		END IF;*/
		
	BEGIN;

		IF (centro_impanterior = centro_imp_var) THEN

			/*IF( centro_impanterior <> centro_imp_var)THEN

				LET contador_ec = 0;

			END IF;*/

			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edocta
			SET ec_edocta = contador_ec
			WHERE num_credito = numero_cre
			AND fecha_emision = fecha_emi;

			LET contador_aux = contador_aux + 1;

		ELSE
		
			LET centro_impanterior = centro_imp_var;

			--LET contador_aux = 0;
			LET contador_ec = 0;
			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edocta
			SET ec_edocta = contador_ec
			WHERE num_credito = numero_cre
			AND fecha_emision = fecha_emi;

		END IF;
	COMMIT;
		
		--LET centro_impanterior = centro_imp_var;

	END FOREACH; 

	DROP TABLE IF EXISTS creditostdc_ec;
	DROP TABLE IF EXISTS tmpNumeroRegistros;
	
	BEGIN;
		UPDATE bdinteg:"informix".si_catzonas SET centro = NULL WHERE centro = 999999;
	COMMIT;
	
	END;

	RETURN vCodRet;

END PROCEDURE;