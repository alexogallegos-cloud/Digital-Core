CREATE PROCEDURE "informix".sp_replicar_exlimblo(pSucursal CHAR(4), pTotalDias INTEGER, pRegistros INTEGER)
RETURNING 
CHAR(6) AS cCodigoRet, 
CHAR(3) AS empresa, 
CHAR(4) AS sucursal,
CHAR(8) AS ejecutivo,
CHAR(50) AS nom_eject,
CHAR(3) AS num_alerta,
CHAR(1) AS movimiento,
CHAR(21) AS monto_exce,
CHAR(19) as fecha_alerta,
CHAR(6) AS hora_alerta,
CHAR(6) AS hora_reemb,
CHAR(21) AS import_reemb,
CHAR(1) AS bloqueo;


--Definicion
DEFINE cCodigoRet 	CHAR(6);
DEFINE iSqlErr  	INTEGER;
DEFINE empresa		CHAR(3);
DEFINE sucursal		CHAR(4);
DEFINE ejecutivo 	CHAR(8);
DEFINE nombre		CHAR(50);
DEFINE num_alerta	CHAR(3);
DEFINE movimiento 	CHAR(1);
DEFINE monto_exce	CHAR(21);
DEFINE hora_alerta  CHAR(19);
DEFINE hora_reemb	CHAR(19);
DEFINE import_reemb	CHAR(21);
DEFINE bloqueo		CHAR(1);
DEFINE vcont 		INTEGER;
DEFINE dfechaHoy   DATETIME YEAR TO DAY;
DEFINE dfechaHoyMenos   DATETIME YEAR TO DAY;
DEFINE fecha_alerta CHAR(19);


--Asignacion
LET cCodigoRet = '000000';
LET iSqlErr = 0;
LET empresa = '';
LET sucursal = '';
LET ejecutivo = '';
LET nombre = '';
LET num_alerta = '';
LET movimiento = '';
LET monto_exce = '';
LET hora_alerta = '';
LET hora_reemb = '';
LET import_reemb = '';
LET bloqueo = '';
LET vcont = 0;
LET dfechaHoy = '1900-01-01';
LET dfechaHoyMenos =  '1900-01-01';
LET fecha_alerta = '';


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodigoRet = iSqlErr;
			RETURN cCodigoRet,NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),NVL(nombre,''),NVL(num_alerta,''),NVL(movimiento,''),NVL(monto_exce,''),NVL(fecha_alerta,''),NVL(hora_alerta,''),NVL(hora_reemb,''),NVL(import_reemb,''),NVL(bloqueo,'');	
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	--SET DEBUG FILE TO "/home/sysifx/OmarLerma/sp_replicar_exlimblo.out";
	--TRACE ON;
	
	

	if NVL(pSucursal,'') <> '' AND NVL(pTotalDias,'') <> '' AND NVL(pRegistros,'') <> '' THEN 
		
		SELECT date(fecha_hoy)
		INTO dfechaHoy
		FROM bdinteg: "informix".si_fechas;
		
		SELECT date((fecha_hoy) - pTotalDias UNITS DAY )
		INTO dfechaHoyMenos
		FROM bdinteg: "informix".si_fechas;
	
		if pTotalDias > '0' then			
			
			FOREACH
			
				SELECT {+INDEX(bdinteg:"informix".idsi_fuera_rango)} f.empresa,f.sucursal,f.ejecutivo,e.nombre,f.num_alerta,f.movimiento,f.monto_exce,f.hora_alerta,SUBSTRING(f.hora_alerta FROM 11 FOR 6), SUBSTRING(f.hora_reemb FROM 11 FOR 6),f.import_reemb,f.bloqueo
				FROM "informix".si_fuera_rango f, "informix".si_ejecut e
				WHERE DATE(f.hora_alerta) >= dfechaHoyMenos
				AND DATE(f.hora_alerta) <= dfechaHoy 			
				AND f.ejecutivo = e.ejecutivo
				AND f.sucursal = pSucursal
				AND nvl(f.num_alerta,0) <> 0
				UNION ALL
				SELECT {+INDEX(bdinteg:"informix".idsi_fuera_rango)} f.empresa,f.sucursal,f.ejecutivo,e.nombre,f.num_alerta,f.movimiento,f.monto_exce,f.hora_reemb,SUBSTRING(f.hora_alerta FROM 11 FOR 6), SUBSTRING(f.hora_reemb FROM 11 FOR 6),f.import_reemb,f.bloqueo
				INTO empresa,sucursal,ejecutivo,nombre,num_alerta,movimiento,monto_exce,fecha_alerta,hora_alerta,hora_reemb,import_reemb,bloqueo
				FROM "informix".si_fuera_rango f, "informix".si_ejecut e
				WHERE DATE(f.hora_reemb) >= dfechaHoyMenos
				AND DATE(f.hora_reemb) <= dfechaHoy	 			
				AND f.ejecutivo = e.ejecutivo
				AND f.sucursal = pSucursal
				AND nvl(f.num_alerta,0) = 0 
				ORDER BY f.hora_alerta		
							
				IF vcont < pRegistros THEN
					 LET vcont = vcont + 1;
					 CONTINUE foreach;
				END IF;			
				
				RETURN cCodigoRet,NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),NVL(nombre,''),NVL(num_alerta,''),NVL(movimiento,''),NVL(monto_exce,''),NVL(fecha_alerta,''),NVL(hora_alerta,''),NVL(hora_reemb,''),NVL(import_reemb,''),NVL(bloqueo,'') WITH RESUME;	
				
				
			END FOREACH;
			
			
		ELSE
		
			FOREACH			
				
				SELECT {+INDEX(bdinteg:"informix".idsi_fuera_rango)} f.empresa,f.sucursal,f.ejecutivo,e.nombre,f.num_alerta,f.movimiento,f.monto_exce,f.hora_alerta ,SUBSTRING(f.hora_alerta FROM 11 FOR 6), SUBSTRING(f.hora_reemb FROM 11 FOR 6),f.import_reemb,f.bloqueo
				FROM "informix".si_fuera_rango f, "informix".si_ejecut e
				WHERE DATE(f.hora_alerta) = dfechaHoy	 			
				AND f.ejecutivo = e.ejecutivo
				AND f.sucursal = pSucursal
				AND nvl(num_alerta,0) <> 0
				UNION ALL
				SELECT {+INDEX(bdinteg:"informix".idsi_fuera_rango)} f.empresa,f.sucursal,f.ejecutivo,e.nombre,f.num_alerta,f.movimiento,f.monto_exce,f.hora_reemb,SUBSTRING(f.hora_alerta FROM 11 FOR 6), SUBSTRING(f.hora_reemb FROM 11 FOR 6),f.import_reemb,f.bloqueo
				INTO empresa,sucursal,ejecutivo,nombre,num_alerta,movimiento,monto_exce,fecha_alerta,hora_alerta,hora_reemb,import_reemb,bloqueo
				FROM "informix".si_fuera_rango f, "informix".si_ejecut e
				WHERE DATE(f.hora_reemb) = dfechaHoy		 			
				AND f.ejecutivo = e.ejecutivo
				AND f.sucursal = pSucursal
				AND NVL(f.num_alerta,0) = 0
				ORDER BY f.hora_alerta	
				
				IF vcont < pRegistros THEN
					 LET vcont = vcont + 1;
					 CONTINUE foreach;
				END IF;						
				
				RETURN cCodigoRet,NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),NVL(nombre,''),NVL(num_alerta,''),NVL(movimiento,''),NVL(monto_exce,''),NVL(fecha_alerta,''),NVL(hora_alerta,''),NVL(hora_reemb,''),NVL(import_reemb,''),NVL(bloqueo,'') WITH RESUME;	
				
				
			END FOREACH;			
			
			
		END IF;	
		
		IF DBINFO('sqlca.sqlerrd2') = 0  THEN
				LET cCodigoRet = '000001';
				RETURN cCodigoRet,NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),NVL(nombre,''),NVL(num_alerta,''),NVL(movimiento,''),NVL(monto_exce,''),NVL(fecha_alerta,''),NVL(hora_alerta,''),NVL(hora_reemb,''),NVL(import_reemb,''),NVL(bloqueo,'');	
		END IF;
		
	ELSE
	
		LET cCodigoRet = '000002';
		RETURN cCodigoRet,NVL(empresa,''),NVL(sucursal,''),NVL(ejecutivo,''),NVL(nombre,''),NVL(num_alerta,''),NVL(movimiento,''),NVL(monto_exce,''),NVL(fecha_alerta,''),NVL(hora_alerta,''),NVL(hora_reemb,''),NVL(import_reemb,''),NVL(bloqueo,'');	
		
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'Folio: 376',
'Autor: Omar Lerma 95572317 ',
'BD: bdinteg',	
'Solicita:	Abraham Narvaez',
'Fecha: 18/02/2018',
'Descripcion: Replicar la informacion de la tabla si_fuera_rango de informix a si_fuera_rango dePotsgres';

create procedure "informix".val_fechas_web(pempresa char(3), pfecha date)
	returning char(5);

	-- Define variables de trabajo
	define vcodret char(5);
	define vsqlerr integer;
	define vfecha_hoy date;

	begin
		on exception set vsqlerr
			if vsqlerr <> 0 then
				let vcodret = vsqlerr;
				return vcodret;
			end if
		end exception;

		-- Inicializa Variables
		let vcodret = "00000";

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--
		if pfecha = mdy('04','08','2014') then
			let vcodret = "00000";
			return vcodret;
		end if

		-- extrae fecha del sistema integral
		select fecha_hoy into vfecha_hoy
		from si_fechas where empresa = pempresa;
		if pfecha != vfecha_hoy then
			let vcodret = "00809";
			return vcodret;
		end if

		return vcodret;
	end
end procedure
DOCUMENT
"Valida fecha de OFI contra fechas del central",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel HernÂ ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_actualiza_status_token_bpi_web(pEmpresa char (3), pNumCte char(9), pStatus integer, pNSToken char(10))
	RETURNING char (5), integer;

--Realizo: Javier Calderon
--Fecha: 02/01/09
--Solicito: Mauricio Leon
--Actividad: Actualiza el status y fecha de status del token asignado al cliente

--Define variables
define sql_err integer;
define cod_ret char (5);


--Inicializa variables
LET sql_err = '';
LET cod_ret = '00000';


BEGIN

 ON EXCEPTION SET sql_err
          LET cod_ret = sql_err;
      RETURN  cod_ret, 0;
   END EXCEPTION;
   
   SET ISOLATION DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   IF EXISTS(SELECT numcte FROM bdinteg:si_bpiusuarios WHERE numcte = pNumcte AND empresa = pEmpresa) THEN
	IF pStatus = '160' THEN --Valida si el estatus es de Desbloqueo, lo cambia a activo 140 para poder ingresar al portal
            UPDATE bdinteg:si_bpitoken set id_status_token = '140', f_status = CURRENT
			WHERE empresa = pEmpresa AND num_cliente = pNumCte AND ns_token = pNSToken;

        ELSE
            UPDATE bdinteg:si_bpitoken SET id_status_token = pStatus, f_status = CURRENT
			WHERE empresa = pEmpresa AND num_cliente = pNumCte AND ns_token = pNSToken;
	END IF
	ELSE
		LET cod_ret = '00001'; -- El cliente No existe
	END IF;

	RETURN cod_ret, pStatus;

END;

END PROCEDURE;