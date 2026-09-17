CREATE PROCEDURE "informix".sp_conciliacion_sepomex(p_Usuario char(8))
RETURNING char(5), char(80);
-----------------------------------------------------------------------------------------------------------------------------------
 --DECLARACION DE VARIABLES
	DEFINE sql_err 		integer;
	DEFINE v_cod_ret 	char(5);
	DEFINE vMensaje 	char(80);
	DEFINE vv_cod_ret 	char(5);
	DEFINE vvMensaje 	char(80);
	DEFINE vvvMensaje 	CHAR(80);
	DEFINE vNumEstado   INTEGER;
	DEFINE cNombreProceso CHAR(30);
	DEFINE vCodRet       CHAR(5);
	DEFINE ISAM_ERR      INTEGER;
    DEFINE ERROR_INFO    VARCHAR(80);
	DEFINE iRegistros    INTEGER;
	DEFINE v_fecha       DATE;

 --INICIALIZACION DE VARIABLES
	LET v_cod_ret 		= '00000';
	LET vvvMensaje 		= "Proceso Finalizado";
	LET vNumEstado      = 0;
	LET cNombreProceso  = 'CONCILIACION CATALOGOS SEPOMEX';
	LET vCodRet         = '11111';
	LET vMensaje        = 'PROCESO INICIALIZADO';
	LET iRegistros      = 0;
	LET v_fecha         = DATE(1);

BEGIN

   on exception set sql_err, ISAM_ERR, ERROR_INFO
      if sql_err <> 0 then
            let v_cod_ret = sql_err;
			LET vMensaje  = ISAM_ERR || '-' || ERROR_INFO;
			
			  INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
              VALUES(cNombreProceso, v_cod_ret, vMensaje, iRegistros ,user, v_fecha,
              (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));
			
            return v_cod_ret, vvvMensaje;
      end if
	  
	  
   end exception;
   
   --SET DEBUG FILE TO "/informix/macf/sp_conciliacion_sepomex.trc";
   --TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   
   SELECT fecha_hoy 
     into v_fecha
     from bdinteg:si_fechas
	 where empresa = '001';
   
   --LET v_fecha = MDY('06','18','2021');  -- Solo test MACF
   
 --VALIDA QUE EL ESTADO Y/O USUARIO NO ESTEN VACIOS
	IF (p_Usuario IS NULL) OR (p_Usuario = "") THEN
		RETURN "00001", "Faltan parametros";
	END IF;
	

	INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
        VALUES(cNombreProceso, vCodRet, vMensaje, iRegistros ,user, v_fecha,
        (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

	
    --Let vMensaje = 'Error en sp_cargarcatalogosepomex';
    --CALL bdinteg:"informix".sp_cargarcatalogosepomex()  -- Ya se realiza en el 206_27_6 los viernes 
    --RETURNING vv_cod_ret, vvMensaje;                    -- Ya se realiza en el 206_27_6 los viernes 
	
	---Modif 20190919 Aquí se podrían truncar las tablas
	TRUNCATE bdinteg:si_catsepomex_colonias;
	TRUNCATE bdinteg:si_catsepomex_ciudades;
	
		--FOREACH
		FOREACH WITH HOLD
	--ALL. SE SACA EL NUMERO DE ESTADO PARA METERLO COMO PARAMETRO EN LOS SP QUE SE MANDAN LLAMAR DENTRO DEL CICLO	
		SELECT ESTADO
				INTO vNumEstado
				FROM bdinteg:si_estados
	
			Let vMensaje = 'Error en sp_conciliar_ciudades_sepomex';
			CALL bdinteg:"informix".sp_conciliar_ciudades_sepomex(vNumEstado, p_Usuario)
			RETURNING vv_cod_ret;
			
			Let vMensaje = 'Error en sp_actualizar_catalogos_sepomex 1';
			CALL bdinteg:"informix".sp_actualizar_catalogos_sepomex(p_Usuario)
			RETURNING vv_cod_ret;
			
			
			Let vMensaje = 'Error en sp_conciliar_colonias_sepomex';
			CALL bdinteg:"informix".sp_conciliar_colonias_sepomex(vNumEstado, p_Usuario)
			RETURNING vv_cod_ret;
			
	
			Let vMensaje = 'Error en sp_actualizar_catalogos_sepomex 2';
			CALL bdinteg:"informix".sp_actualizar_catalogos_sepomex(p_Usuario)
			RETURNING vv_cod_ret;
			
			
		END FOREACH;
    
	
	LET vCodRet = vv_cod_ret;
	--LET vMensaje  = 'PROCESO EXITOSO';
	
	--- MODIF MACF 20210701
	IF vv_cod_ret = '00000' THEN 
	   LET vMensaje  = 'PROCESO EXITOSO';
	ELSE
	   LET vMensaje = 'ERROR EN PROCESO';
	END IF;
	--- MODIF MACF 20210701
	
    INSERT INTO bdinteg:si_bitacora_dom (proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert) 
          VALUES(cNombreProceso, vCodRet, vMensaje, iRegistros ,user, v_fecha,
          (SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND from sysmaster:sysshmvals));

		  
	RETURN v_cod_ret, vvvMensaje;
	
END;

END PROCEDURE
DOCUMENT
"AUTOR: MACF",
"DESCRIPCION: Agregar hold en for each. Agregar registro en bitácora",
"FECHA: 20190926";

CREATE PROCEDURE "informix".sp_elimina_huellas_vacias() RETURNING CHAR(5) AS cod_retorno;



--DEFINICION DE VARIABLES
DEFINE vcodRet 		    VARCHAR(6); 	-- CODIGO DE RETORNO
DEFINE iSqlErr      	integer;
DEFINE cMensaje		    VARCHAR(100);
DEFINE nContador        INT;
DEFINE nfecha			DATE;
DEFINE pnumcte			CHAR(20);


--INICIALIZACION DE VARIABLES
LET vcodRet 			= '00000';
LET iSqlErr             = 0;
LET cMensaje		    = 'ERROR EN PASO: ';
LET nContador       	= 0;
LET nfecha				= '';
LET pnumcte				= '';


	
BEGIN 
			ON EXCEPTION SET iSqlErr
						IF iSqlErr <> 0 THEN
							LET vcodRet = iSqlErr;
						END IF;
			END EXCEPTION;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		--SET DEBUG FILE TO "/tmp/masv/huellas/sp_elimina_huellas_vacias.out";
		--TRACE ON;
	
		Select fecha_hoy into nfecha from si_fechas;
		
		FOREACH WITH HOLD
		
			select cte_hu.numcte into pnumcte from si_cte_huella cte_hu 
			join si_cliente cte ON cte.numcte  =  cte_hu.numcte
			where cte_hu.fecha_alta = nfecha 
			and cte_hu.dmapa LIKE 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA%' 
			and cte.tipo_cliente = 2

			select count(*) into nContador from si_cte_huella_resp resp where resp.numcte = pnumcte;
			
			IF nContador <> 0 THEN 
			
				delete from si_cte_huella_resp resp where  resp.numcte = pnumcte;			
				delete from si_cte_huella cte_hu where cte_hu.numcte = pnumcte;
			end if;
			
			IF nContador == 0 THEN 
				delete from si_cte_huella cte_hu where cte_hu.numcte = pnumcte;
			end if;
			
		END FOREACH; 
		
	LET vCodRet ='00000';
	
	

	return vCodRet;
END;
END PROCEDURE ;