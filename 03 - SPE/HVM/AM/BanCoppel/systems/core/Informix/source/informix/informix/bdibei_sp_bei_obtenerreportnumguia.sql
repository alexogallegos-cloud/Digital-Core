CREATE PROCEDURE "informix".sp_bei_obtenerreportnumguia(pNumGuia char(30), pRegistros int)
				 returning char(5) as CodRet, char(30) as NumGuia, char(10) as FechaSolicitud, char(10) as Solicitud, char(9) as Numcliente,
				 char(4) as Sucursal, char(3) as NumEnvio, char(10) as FechaRegistro, char(3) as Estatus, char(8) as Envio;

   
    -- DEFINE
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
	DEFINE vNumGuia char(30);
	DEFINE vFechaSolicitud char(10);
	DEFINE vSolicitud char(10);
	DEFINE vCliente char(9);
	DEFINE vSucursal char(4);
	DEFINE vNumEnvio char(3);
	DEFINE vFechaRegistro char(10);
	DEFINE vEstatus char(3);
	DEFINE vEnvio char(8);
			
	-- INICIALIZAR
	LET cod_ret = '00000';
	LET vNumGuia = '';
	LET vFechaSolicitud = '01-01-1900';
	LET vSolicitud = '';
	LET vCliente = '';
	LET vSucursal = '';
	LET vNumEnvio = '';
	LET vFechaRegistro = '01-01-1900';
	LET vEstatus = '';
	LET vEnvio = '';
	
--	SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_bei_obtenerreportnumguia.out";
--	TRACE ON;

	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, NVL(vNumGuia,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vCliente,''), NVL(vSucursal,''), NVL(vNumEnvio,''), NVL(vFechaRegistro,''), vEstatus, NVL(vEnvio,'');
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF (pNumGuia IS NOT NULL AND pNumGuia <> '') THEN
				FOREACH
					SELECT SKIP pRegistros FIRST 10 DISTINCT e.num_guia, date(s.f_solicitud) as f_solicitud, s.solicitud, e.numcte, s.sucursal, e.num_envio, date(e.f_registro) as f_registro, e.id_status, s.usr_atiende
					INTO vNumGuia, vFechaSolicitud, vSolicitud, vCliente, vSucursal, vNumEnvio, vFechaRegistro, vEstatus, vEnvio
					FROM "informix".bei_envios e, "informix".bei_solicitudtoken s 
					WHERE s.solicitud = e.solicitud 
					AND s.numcte = e.numcte
					AND e.num_guia = pNumGuia
					
					
					RETURN cod_ret, NVL(vNumGuia,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vCliente,''), NVL(vSucursal,''), NVL(vNumEnvio,''), NVL(vFechaRegistro,''), vEstatus, NVL(vEnvio,'') WITH RESUME;
				
				END FOREACH;
				
				IF (vNumGuia = '') THEN
					LET cod_ret = "00011";
				END IF;
		ELSE 
			LET cod_ret = '00011'; 
		END IF;
		
		IF (cod_ret <> '00000') THEN
			RETURN cod_ret, NVL(vNumGuia,''), NVL(vFechaSolicitud,''), NVL(vSolicitud,''), NVL(vCliente,''), NVL(vSucursal,''), NVL(vNumEnvio,''), NVL(vFechaRegistro,''), vEstatus, NVL(vEnvio,'');
		END IF;
	END;
	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Consulta numeros de guia de los tokens.',
'AUTOR: Ilse Jazmin Gomez Perez',
'FECHA: 16 Julio 2013',
'VERSION: 20130716.1141',
'BD: bdibei',
'MODIFICO: Paul Alonzo Quintero Ramirez',
'FECHA: 01/Agosto/2018',
'SOLICITANTE: Arturo Alejandro VÃ¡zquez FernÃ¡ndez',
'DESCRIPCION: Se modifica parametro entrada y de retorno NumGuia a 30 caracteres',
'Folio: 427.1 RQI 03 712 - Mantenimiento AdmonToken',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_depura_bitacora_bei()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 		INTEGER;
DEFINE isam_err 	INTEGER;
DEFINE error_info	CHAR(150);
DEFINE cMensaje 	CHAR(150);
DEFINE cCod_ret     CHAR(6);
DEFINE Vid_oper		CHAR(4);
DEFINE Vid_usuario  INTEGER;
DEFINE iCont		INTEGER;
DEFINE cValor		CHAR(1);
DEFINE dFecha		DATE;	

DEFINE vcomienza        INTEGER;
DEFINE vcuantos  		INTEGER;
DEFINE vregistros INTEGER;
DEFINE vcontador INTEGER;
		

	--SET DEBUG FILE TO "/home/informix/BereniceOut/sp_depura_bitacora_bei.out";
    --TRACE ON; 

	LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info	= '';
	LET cMensaje    = 'PROCESO EXITOSO';
	LET iCont		= 0;
	LET cValor		= '';

	
	LET vcontador = -1;
	LET vcuantos = 0;
	LET vcomienza   = -1;	
	LET vregistros = 1000;
	
	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	select valor into cValor 
	from bdibpi:"informix".bpi_param
	where id_param = '20';

	select date(fecha_hoy - 1 units day) into dFecha 
	from bdicheq:"informix".sc_fechas
	where empresa = '001';

	select count(*) into iCont 
	from bdibei:"informix".temp_bei_bitacora_depurar;

	if iCont > 0 and cValor = '1' then

		update bdibpi:"informix".bpi_param set valor = '2'
		where id_param = '20';

	ELIF iCont > 0 and cValor = '0' then

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

    FOREACH WITH HOLD

		select id_cat_oper 
		into Vid_oper  
		from bdibei:"informix".temp_bei_bitacora_depurar

		FOREACH WITH HOLD

			select distinct(id_usuario)
			into Vid_usuario
			from bdibei:"informix".bei_bitacora
			where id_operacion = Vid_oper 
			 AND EXTEND(fecha_oper,YEAR to day) <= dFecha
	
				IF vcomienza = -1 THEN
							BEGIN WORK;
							LET vcontador = 1;
							LET vcomienza = 0;
				END IF;		
						
				DELETE FROM bdibei:"informix".bei_bitacora
				WHERE id_operacion = Vid_oper 
					and id_usuario = Vid_usuario
					and EXTEND(fecha_oper,YEAR to day) <= dFecha;
			
				IF (vcontador = vregistros) THEN
						COMMIT WORK;
						LET vcontador = 0;							
						LET vcomienza = -1;
				ELSE
						LET vcontador = vcontador + 1 ;						
				END IF;		
				
		END FOREACH;

	END FOREACH;

			IF (vcontador > 1) THEN
				COMMIT WORK;
				LET vcontador = 0;							
				LET vcomienza = -1;							
			END IF;		

	update bdibpi:"informix".bpi_param set valor = '0'
	where id_param = '20';

	delete bdibei:"informix".temp_bei_bitacora_depurar;
	
	RETURN cCod_ret;

	END;

END PROCEDURE;