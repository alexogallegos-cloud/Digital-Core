CREATE PROCEDURE "informix".sp_carga_info_atento()
RETURNING CHAR(6), CHAR(80);

/* 	MARIA ELIZABETH ANZURES IBARGUEN
	06-MARZO-2012
	ARCHIVO QUE CARGA MOVIMEINTOS DEL CAT A TABLA MOVIMIENTOS Y PASA A 
		TABLAS CB-COMPAC CONVENIO Y TELEFONOS A CB_TELEFONOS LOS TELEFONOS NUEVOS DE CLIENTES*/

--DECLARACION DE VARIABLES
	DEFINE sql_err		INTEGER;
	DEFINE isam_err		INTEGER;
	DEFINE error_info	CHAR(80);
	DEFINE cCod_ret		CHAR(6);
	DEFINE vempresa     CHAR(3);
	DEFINE cproceso     CHAR(4);
	DEFINE vvcCod_ret   CHAR(6);
	DEFINE cMensaje		CHAR(80);
	DEFINE cCadena		CHAR(500);
	DEFINE vRuta		CHAR(100);
	DEFINE cSql         CHAR(2204);	
	DEFINE pNomArch 	CHAR(100);
	DEFINE vNomArch		CHAR(100);
	DEFINE X 			CHAR(100);
	DEFINE vfecha 		DATE;
	DEFINE vfecha_cat 	DATE;
	
	----variables
	DEFINE vnumcte					CHAR(20);
	DEFINE vtelefonoreconstruido	CHAR(13);
	DEFINE vtipotelefono			SMALLINT;
	DEFINE vsecuencia				SMALLINT;
	DEFINE vnumext					CHAR(5);
	DEFINE vfinllamada				SMALLINT;
	DEFINE vnumempleado				CHAR(8);
	DEFINE vnumcuenta				CHAR(20);
	DEFINE vplazo					CHAR(2);
	DEFINE vimporte					DECIMAL(18,2);
	DEFINE vtipoconvenio			CHAR(1);
	DEFINE vhorainicio				DATE;

	--SET DEBUG FILE TO "/informix/Elizabeth/sp_carga_info_atento.out ";
	--TRACE ON;

--DEFINICIAON DE VARIABLES
	LET cCod_ret  	= "000000";
	LET sql_err   	= 0;
	LET cMensaje  	= "PROCESO EXITOSO";
	LET cCadena   	= "";
	LET vRuta     	= "";
	LET cSql      	= "";
	LET vempresa    = '001';
	LET cproceso    = '2063';
	LET pNomArch 	= '';
	let vfecha 		= DATE(1);
	let vfecha_cat	= date(1);
	let vNomArch	= '';
	let X ='';
	
	---VARIABLES
	LET vnumcte					='';
	LET vtelefonoreconstruido	='';
	LET vtipotelefono			=0;
	LET vsecuencia				=0;
	LET vnumext					='';
	LET vfinllamada				=0;
	LET vnumempleado			='';
	LET vnumcuenta				='';
	LET vplazo					='';
	LET vimporte				=0;
	LET vtipoconvenio			='';
	LET vhorainicio				=DATE(1);

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
			LET cMensaje = error_info;
		  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
            RETURNING vvcCod_ret;
			    RETURN cCod_ret, cMensaje;	    
	    END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	--SE MANDA LLAMAR SP PARA INSERTAR EN BITACORA EL INICIO DE LA EJECUCION DE SP
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
        RETURNING vvcCod_ret;
 
	--SELECCIONAMOS LA FECHA DEL DIA
	select fecha_hoy 
		into vfecha 
	from bdicred:sd_fechas 
	where empresa = '001';

		--SELECCIONAMOS LA RUTA 
    select valor_alfabetico 
		into vRuta 
    from bdicobranza:cb_param_campania
    where empresa = '001'
		and tipo_campania = 1
		and grupo_parametro = 'ARCHIVOS'
		and num_parametro = 36;	
	
	---------------------------------------------CARGAR ARCHIVO A LA TABLA	---------------------------------------------------------------------
	
		--ASIGNAMOS NOMBRE AL ARCHIVO
		LET pNomArch = 'movimientos_atento'|| to_char(vfecha,'%d%m%Y')||'.txt';
		let vNomArch = pNomArch;
--let vRuta = '/informix/Elizabeth/';----PRUEBA	
		--DESCOMPRIMIMOS EL ARCHIVO
		--LET cSql = "gunzip "  || trim(vRuta) || trim(pNomArch); 
       -- system cSql;
	
		--TOMAMOS EL NOMBRE DE ARCHIVO YA DESCOMPRIMIDO SIN LOS 3 ULTIMOS CARACTERES 
		--LET X = length(pNomArch);
		--LET vNomArch = substr(pNomArch,0,X-3);
		
		LET cCadena = 'echo " load from ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || SUBSTR(vNomArch,1,
			LENGTH(vNomArch))  || ' insert into bdicobranza:cb_atento_movimientos " >' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl.sql';
			System SUBSTR(cCadena,1,LENGTH(cCadena));
			let cCadena = 'dbaccess bdicobranza ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl.sql';
		System SUBSTR(cCadena,1,LENGTH(cCadena));
		  
		--BORRA EL ARCHIVO 
        let cCadena = 'rm ' || SUBSTR(vRuta,1,LENGTH(vRuta)) || 'catmovimientosctbcpl.sql';
        System SUBSTR(cCadena,1,LENGTH(cCadena));
		
		--SE COMPRIME DE NUEVO EL ARCHIVO	
/*		LET cSql = "gzip " || trim(vRuta) || trim(vNomArch); 
*/		system cSql;
	

	---------------------------------CARGAR REGISTROS A TABLAS CORRESPONDINETES------------------------------------------------------------------
	select  max(date(horainicio)) into vfecha_cat
	from bdicobranza:cb_atento_movimientos; 
	
	FOREACH
	--------cb_telefonos-------
	SELECT cliente,tipotelefono,telefonoreconstruido,numext,finllamada,numempleado
		INTO  vnumcte,vtipotelefono,vtelefonoreconstruido,vnumext,vfinllamada,vnumempleado
	FROM  bdicobranza:cb_atento_movimientos
	WHERE DATE(horainicio) =  vfecha_cat and
		 telefonoreconstruido > 0
		AND sucursal = '0000'
		and cvemovimiento = 'T'
	
	select max(secuencia) into vsecuencia
	from bdicobranza:"informix".cb_telefonos 
	where numcte = vnumcte and empresa = '001';
	
	if vsecuencia is null then 
		let vsecuencia = 1;
	else 
		let vsecuencia = vsecuencia + 1;
	end if;
	if not exists (SELECT numcte FROM bdicobranza:"informix".cb_telefonos WHERE numcte= vnumcte AND telefono=vtelefonoreconstruido AND tipo_telefono=vtipotelefono)THEN
	INSERT INTO bdicobranza:"informix".cb_telefonos(empresa, origen, numcte, telefono, tipo_telefono, secuencia, extension, estatus,
		numvecesmarcado, tipored, fultimocontacto, codigo_resultado, quiencontestouc, orden_telefono, fecha_insert, user_insert, fecha_modifica, numero_carrier)
	VALUES('001', 6, vnumcte, vtelefonoreconstruido, vtipotelefono, vsecuencia, vnumext, 'A',
		null, null, NULL, vfinllamada, null, null, vfecha, vnumempleado, NULL, 0);
	END IF;
	END FOREACH;
	
	---------cb_compac----------
	FOREACH
		
	SELECT cliente,tipotelefono,telefonoreconstruido,numext,finllamada,numempleado,tienda,plazo,importe , tipoconvenio,date(horainicio)
		INTO vnumcte,vtipotelefono,vtelefonoreconstruido,vnumext,vfinllamada,vnumempleado,vnumcuenta,vplazo,vimporte , vtipoconvenio,vhorainicio
	FROM  bdicobranza:cb_atento_movimientos
	WHERE DATE(horainicio) = vfecha_cat and
		 plazo > 0 
		and sucursal = '0000'
		and cvemovimiento = 'C' 
		and importe > 0
	
	
	INSERT INTO bdicobranza:"informix".cb_compac(empresa, sucursal, origen, empleado_captura, numcliente, numcuenta, plazo, 
				importe, tipo_compac, activo, flag_pago, efectuo_compac, nombre_efectuo, fecha_compac, fecha_insert,  quien_convenio, nom_convenio, email, referenciacoppel, imp_pagado)
    VALUES('001', '9999', 4, vnumempleado, vnumcte, vnumcuenta, vplazo, 
				vimporte, vtipoconvenio, '1', '0', 0, '', vhorainicio, vhorainicio  + (vplazo * 7) , null,  null, '', '',  NULL);
	END FOREACH;
	
	--SE MANDA LLAMAR SP PARA INSERTAR EN BITACORA EL FINAL DE LA EJECUCION DE SP
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
		RETURNING vvcCod_ret;
		
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;