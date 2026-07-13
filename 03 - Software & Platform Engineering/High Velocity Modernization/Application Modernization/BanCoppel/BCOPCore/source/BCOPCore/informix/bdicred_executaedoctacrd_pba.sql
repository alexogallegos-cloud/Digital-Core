CREATE PROCEDURE "informix".executaedoctacrd_pba(pempresa  CHAR(3),pfechahoy DATE)
RETURNING CHAR(5);

DEFINE v_cod_ret	    CHAR(5);
DEFINE sql_err          INTEGER;
DEFINE v_cuantos		INTEGER;
DEFINE vStProc         	CHAR(1);
DEFINE v_nameProcess	CHAR(20);

--SET FILE TO "executaedoctacrd.out";
--TRACE ON;

BEGIN

  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;

			UPDATE "informix".sd_contproc
			   SET status_proc = "C",
                   hora_fin    = CURRENT,
                   cod_ret     = v_cod_ret,
			       mensaje     = "Estados de Cuenta de Reestructura Sin Generar"
			 WHERE empresa     = pEmpresa			
			   AND proceso     = v_nameProcess
			   AND fecha       = pfechahoy;
                       
			UPDATE bdinteg:sx_contproc
			   SET status_proc = "C",
                   hora_fin    = CURRENT,
			 	   codret      = v_cod_ret
			 WHERE proceso  = v_nameProcess
			   AND fecha    = pfechahoy
			   AND sistema = '06';

            RETURN v_cod_ret;
        END IF
   END EXCEPTION;

	LET v_nameProcess = "GeneraEdoCtaREES";
	LET v_cod_ret = "000";

	--     PREGUNTA POR EL CONTROL  DE PROCESOS     --

	SELECT status_proc INTO vStProc
	  FROM "informix".sd_contproc
	 WHERE empresa = pEmpresa
	   AND proceso  = v_nameProcess
	   AND fecha    = pfechahoy;
	   
	IF vStProc IS NULL OR vStProc = '' THEN
        	INSERT INTO "informix".sd_contproc (empresa, proceso, fecha, 
  	 	 		                     status_proc, ejecutivo,
          	  	                     hora_inicio, hora_fin, 
          	  	                     cod_ret, mensaje)
        	VALUES (pEmpresa, v_nameProcess, pfechahoy, 
	 	 		    'I', USER,
	 	 		    CURRENT, NULL, 
	 	 		    NULL, NULL);

			INSERT INTO bdinteg:sx_contproc (empresa, proceso, fecha, 
		 		                             sistema, status_proc,
	        	                             ejecutivo, hora_ini, 
	        	                             hora_fin, codret)
			     VALUES (pEmpresa, v_nameProcess, pfechahoy, 
		 		         '06', 'I', 
		 		         USER, CURRENT, 
		 		         NULL, '000');
	ELIF vStProc = "F" THEN
         	RETURN v_cod_ret;
	END IF
	
     EXECUTE PROCEDURE executaedoctageneralcrd (pempresa, pfechahoy) 
	 INTO v_cod_ret;

    IF v_cod_ret <> "000" THEN
        UPDATE sd_contproc
           SET status_proc = "C",
               hora_fin    = CURRENT,
               cod_ret     = v_cod_ret,
               mensaje     = v_cuantos || "Estados de Cuenta de Reestructura Sin Generar"
         WHERE empresa     = pEmpresa
           AND proceso     = v_nameProcess
           AND fecha       = pfechahoy;

        UPDATE bdinteg:sx_contproc
           SET status_proc = "C",
               hora_fin    = CURRENT,
               codret      = v_cod_ret
         WHERE proceso  = v_nameProcess
           AND fecha       = pfechahoy
           AND sistema = '06';
    ELSE
	    UPDATE sd_contproc
	       SET status_proc = "F",
	           hora_fin    = CURRENT,
        	   cod_ret     = v_cod_ret,
      	       mensaje     = "Proceso Concluido"
  	     WHERE empresa     = pEmpresa
	       AND proceso     = v_nameProcess
	       AND fecha       = pfechahoy;

          UPDATE bdinteg:sx_contproc
             SET status_proc = "F",
                 hora_fin = CURRENT,
                 codret   = v_cod_ret
           WHERE proceso  = v_nameProcess
             AND fecha    = pfechahoy
             AND sistema = '06';
    END IF
END;

	RETURN v_cod_ret;

END PROCEDURE
DOCUMENT
"Se crea procedimiento para realizar la consulta",
"a la bitacora de control de procesos y comenzar",
"con el proceso de generación de Edo. Cta.",
"reestructura",
"base de datos : bdicred",
"AUTOR : Jose de Jesus Almeida",
"FECHA : 20/Julio/2009";

CREATE PROCEDURE "informix".sp_rep_ctes_baja_cartera(pEmpresa CHAR(3))

RETURNING CHAR(6) AS CodigoRetorno,
		CHAR(80) AS Mensaje;

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE pMensaje				CHAR(80);
DEFINE pCod_ret				CHAR(6);
DEFINE cErrorInfo			CHAR(80);
DEFINE pempresa				CHAR(3);
DEFINE pproceso				CHAR(30);
DEFINE pusuario				CHAR(8);
DEFINE cruta				CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE ntrimestre 			CHAR(30);
DEFINE cnomarchivo			CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnumcte				CHAR(20);
DEFINE cnumcred				CHAR(20);
DEFINE cSucursal			CHAR(4);
DEFINE cSQL					CHAR(8204);
DEFINE cSQL1				CHAR(6204);
DEFINE cSQL2				CHAR(6204);
DEFINE cSQL3				CHAR(100);
DEFINE cCod_RetIB			CHAR(6);
DEFINE dFechaHoy			DATE;
DEFINE dFecha				DATE;
DEFINE sPaso				smallint;

--SET DEBUG FILE TO "/informix/gpe/sp_rep_ctes_baja_cartera.out";
--TRACE ON;

--Inicialización de variables
LET sql_err					= 0;
LET isam_err				= 0;
LET error_info				= "";
LET pCod_Ret				= "000000";
LET pMensaje				= 'Se generó correctamente Reporte Cliente Baja Cartera';
LET pproceso				= '3003';
LET pempresa				= '001';
LET pusuario				= USER;
LET cruta					= "";
LET cnombre					= "";
LET ntrimestre 				= "";
LET cnomarchivo				= "";
LET cnomarchivo1			= "";
LET cnumcte					= "";
LET cnumcred				= "";
LET cSucursal				= "";
LET cSQL					= "";
LET cSQL1					= "";
LET cSQL2					= "";
LET cSQL3					= "";
LET cCod_RetIB				= "000000";
LET dFechaHoy				= DATE(1);
LET dFecha					= DATE(1);
LET sPaso					=0;

BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
	LET pCod_ret = sql_err;
	LET pMensaje = error_info;
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '02')
	Returning cCod_RetIB;
		RETURN pCod_ret,pMensaje;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '01')
	Returning cCod_RetIB;
	
	select fecha_hoy,pri_dia_mes - 1 units day 
	into dFechaHoy,dFecha
	from bdicred:"informix".sd_fechas;
	
	--LET dFecha = mdy('06','30','2014');
	
	  SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'sd_baja_cartera';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_baja_cartera;
            END IF;

	select trim(valor_alfabetico) 
	into cRuta 
	from bdicred:"informix".sd_param_campania 
	where empresa = '001' and tipo_campania = 50 
	and num_parametro = 2;
	--let cruta = '/informix/gpe/'; --pruebas
	
	create  table sd_baja_cartera(
	numcte char(10),
	num_credito char(20),
	num_producto char(4),
	status_cred char(2),
	hit char(6),
	meses_vencidos char(6),
	correo char(100),
	estado char(30),
	numero_ciudad char(4),
	nombre_ciudad char(60),
	capital_vigente decimal(18,2),
	capital_transitorio decimal(18,2),
	capital_vencidoexigible decimal(18,2),
	capital_vencidonoexigible decimal(18,2),
	saldo_cierre decimal(18,2),
	sucursal char(4),
	situacion_pago decimal(5,2),
	meses_historia smallint,
	fecha_apertura date,
	fecha_baja date 
	--credito_externo char(20)
	) ;	
	select a.empresa,a.numcte,a.num_credito,a.sucursal,a.num_producto, a.status_cred,a.fecha_apertura,a.fecha,
	b.mto_fin_ven_trasp,b.sdo_capital,b.monto_vencido, b.mto_venc_trasp,b.cap_tras_no_venci, a.credito_externo
	from bdicred:sd_maecredcont a,
     bdicred:sd_maesdoscont b
	where a.empresa = '001'
	and a.fecha = dFecha
	and a.empresa = b.empresa
	and a.fecha = b.fecha
	and a.num_credito = b.num_credito		
	and a.campo_trab3 = 'BAJA'
	union all
	select a.empresa,a.numcte,a.num_credito,a.sucursal,a.num_producto, a.status_cred,a.fecha_apertura,a.fecha,
	b.mto_fin_ven_trasp,b.sdo_capital,b.monto_vencido, b.mto_venc_trasp,b.cap_tras_no_venci, a.credito_externo
	from bdicred:sd_maecredcontcrd a,
     bdicred:sd_maesdoscontcrd b
	where a.empresa = '001'
	and a.fecha = dFecha
	and a.empresa = b.empresa
	and a.fecha = b.fecha
	and a.num_credito = b.num_credito
	and a.campo_trab3 = 'BAJA'
	into temp sel_baja with no log;
	
	create unique index inx_sel_baja on sel_baja(num_credito);
	update statistics high for table sel_baja;
	
	select a.empresa,a.numcte,a.num_credito,a.sucursal,a.num_producto, a.status_cred,a.fecha_apertura,today as fecha,
	b.mto_fin_ven_trasp,b.sdo_capital,b.monto_vencido, b.mto_venc_trasp,b.cap_tras_no_venci, a.credito_externo
	from bdicred:sd_maecred a,
     bdicred:sd_maesdos b
	where a.empresa = '001'
	and a.empresa = b.empresa
	and a.num_credito = b.num_credito
	and a.status_cred = 'FF'
	and a.campo_trab3 = 'BAJA'
	union all
	select a.empresa,a.numcte,a.num_credito,a.sucursal,a.num_producto, a.status_cred,a.fecha_apertura,today as fecha ,
	b.mto_fin_ven_trasp,b.sdo_capital,b.monto_vencido, b.mto_venc_trasp,b.cap_tras_no_venci, a.credito_externo
	from bdicred:sd_maecredcrd a,
     bdicred:sd_maesdoscrd b
	where a.empresa = '001'
	and a.empresa = b.empresa
	and a.num_credito = b.num_credito
	and a.status_cred = 'FF'
	and a.campo_trab3 = 'BAJA'
	into temp sel_baja_ff with no log;
	
	create unique index inx_sel_baja_ff on sel_baja_ff(num_credito);
	update statistics high for table sel_baja_ff;
	
	delete sel_baja_ff 
	where num_credito in (select num_credito 
	from sel_baja);
	
	insert into sel_baja
	select * from sel_baja_ff;

	insert into sd_baja_cartera
	select a.numcte,a.num_credito, a.num_producto, a.status_cred,
		decode (nvl(scor.evalua_cc,''), '','NO HIT', 'X','NO HIT', 'HIT') Hit, a.mto_fin_ven_trasp meses_vencidos,
		corr.correo_elec correo,es.nombre Estado,dir.numerociudad numciudad,
		(select  ciu.nombreciudad  from bdinteg:si_catciudades ciu where ciu.numerociudad = dir.numerociudad)ciudad,
		a.sdo_capital Capita_Vigente,a.monto_vencido Capital_transitorio, a.mto_venc_trasp Capital_VencidoExigible,
		a.cap_tras_no_venci  Capital_VencidNOExigible, 
		(a.sdo_capital + a.monto_vencido + a.mto_venc_trasp + a.cap_tras_no_venci ) saldo_cierre,
		a.sucursal,cb.situacionpago eficienciapagocoppel,cb.meseshistoria meseshistoria,a.fecha_apertura fechaapertura,
		cb.fecha_baja fechadebajadecartera
	from bdicred:sel_baja a
	join bdisolic:ss_resum_scor_fin scor on ( a.empresa = scor.empresa and a.num_credito = scor.num_solicitud )
	join bdicobranza:cb_rep_cart_quebrantar cb on (cb.num_credito = a.num_credito and cb.excluido = 'B' )
	left outer join bdinteg:si_correos corr on (corr.numcte = a.numcte and corr.status_correo = 'A')	
	--join bdisolic:ss_solicitudes ss on ( a.empresa = ss.empresa and a.num_credito = ss.num_solicitud )
	left outer join bdinteg:si_direcciones_actual dir on ( a.numcte = dir.numcte and dir.tipo_dir = 1  )
	left outer join bdinteg:si_estados es on (es.estado = dir.estado)
	where a.empresa = '001' and a.num_producto <> '6011';
	
	insert into sd_baja_cartera
	select a.numcte,a.num_credito, a.num_producto, a.status_cred,
		decode (nvl(scor.evalua_cc,''), '','NO HIT', 'X','NO HIT', 'HIT') Hit, a.mto_fin_ven_trasp meses_vencidos,
		corr.correo_elec correo,es.nombre Estado,dir.numerociudad numciudad,
		(select  ciu.nombreciudad  from bdinteg:si_catciudades ciu where ciu.numerociudad = dir.numerociudad)ciudad,
		a.sdo_capital Capita_Vigente,a.monto_vencido Capital_transitorio, a.mto_venc_trasp Capital_VencidoExigible,
		a.cap_tras_no_venci  Capital_VencidNOExigible, 
		(a.sdo_capital + a.monto_vencido + a.mto_venc_trasp + a.cap_tras_no_venci ) saldo_cierre,
		a.sucursal,cb.situacionpago eficienciapagocoppel,cb.meseshistoria meseshistoria,a.fecha_apertura fechaapertura,
		cb.fecha_baja fechadebajadecartera
	from bdicred:sel_baja a
	join bdisolic:ss_resum_scor_fin scor on ( a.empresa = scor.empresa and a.credito_externo = scor.num_solicitud )
	join bdicobranza:cb_rep_cart_quebrantar cb on (cb.num_credito = a.num_credito and cb.excluido = 'B' )
	left outer join bdinteg:si_correos corr on (corr.numcte = a.numcte and corr.status_correo = 'A')	
	--join bdisolic:ss_solicitudes ss on ( a.empresa = ss.empresa and a.num_credito = ss.num_solicitud )
	left outer join bdinteg:si_direcciones_actual dir on ( a.numcte = dir.numcte and dir.tipo_dir = 1  )
	left outer join bdinteg:si_estados es on (es.estado = dir.estado)
	where a.empresa = '001' and a.num_producto = '6011';
	
	--and a.fecha = mdy('06','30','2014'); --dFecha;
	
	--Genera archivo
	LET cnomarchivo1 = 'Clientes_baja_cartera'||'.unl';
	LET cnomarchivo =  'Clientes_baja_cartera_'||to_char( dFecha,'% m%Y')||'.txt';
	--Encabezado
	let cSql='';
	let csql = 'echo "Número_de_cliente|Número_de_crédito|Producto|Status|Hit|Mesese_vencidos|'
	||'Correo|Estado|Número_ciudad|Nombre_ciudad|Capital_vigente|Capital_transitorio|Capital_vencidoexigible|Capital_vencidonoexigible|'
	||'Saldo_al_cierre|Sucursal|Eficiencia_de_pago|Meses_historia|Fecha_apertura|'
	||'Fecha_de_baja_de_cartera; " >' ||TRIM(cruta)|| cnomarchivo;
	system csql;
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || '''|'''||'';
	LET cSQL2 = ' select * from sd_baja_cartera';
	LET cSQL3 = '">'||TRIM(cruta)||'ejecuta_Clientes_baja_cartera_.sql';
	LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
	System cSQL;
	LET cSQL='chmod 777 '|| TRIM(cruta)||'ejecuta_Clientes_baja_cartera_.sql';
	System cSQL;
	LET cSQL = 'dbaccess bdicred ' || TRIM(cruta) || 'ejecuta_Clientes_baja_cartera_.sql';
	System cSQL;
	LET cSql = cSql; 
	LET cSql = "sed 's/;$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
	SYSTEM cSql;
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'ejecuta_Clientes_baja_cartera_.sql';
	SYSTEM cSQL;
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;
	
	drop table sd_baja_cartera;
	
	  CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '03')
		Returning cCod_RetIB;

	RETURN pCod_ret,pMensaje;

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para generar archivo mensual Clientes baja cartera',
'AUTOR : Guadalupe de Jesus Espinoza Valenzuela ',
'FECHA : 05/Julio/2014',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_ce_consultasdo (v_cuenta CHAR(20))

	RETURNING CHAR(5), MONEY(16,2), CHAR(1);
    
    -- Control:
	------------------------------------------------------------------------------>
    -- Objetivo: Sp Consulta de Saldos de cuentas asociadas a los créditos empresariales - Orión.
    -- Fecha Creación: 28/07/2014
	-- Envío a producción 05/08/2014
    -- Autor: SADCV
    ------------------------------------------------------------------------------>

    ------------------------------------------------------------------------------>
	--// Inicializa de Variables 

    DEFINE vSqlErr 			INTEGER;
    DEFINE cCodRet  		CHAR (5);

	DEFINE vcod_ret 		CHAR (5);
	DEFINE vcuenta    		char(20);
	DEFINE vsdodisp   		money(16,2);
	DEFINE vstatuscta 		char(1);
	
    ------------------------------------------------------------------------------>
	--// Inicializa variables
	
    LET vSqlErr 			= 0;
    LET cCodRet 			= '00000';
	
	LET vcod_ret 			= '';
	LET vcuenta    			= "";
    LET vsdodisp   			=  0;
    LET vstatuscta			= " ";
	
	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar Debug   
   -- SET DEBUG FILE TO "/informix/SD/Orion/sp_ce_aplicareversion.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
		
    ------------------------------------------------------------------------------>
	--//
    
    BEGIN

    ON EXCEPTION SET vSqlErr
        IF vSqlErr <> 0 THEN
            LET cCodRet = vSqlErr;
            -- ROLLBACK WORK;
            RETURN cCodRet, vsdodisp, vstatuscta;
        END IF;
    END EXCEPTION;

	--//
	------------------------------------------------------------------------------>


    SET ISOLATION DIRTY READ;
	
		CALL bdicheq:cons_saldo(v_cuenta)-- Producción
		-- CALL bdicheq_ce:cons_saldo(v_cuenta)-- Pruebas 127
			
		RETURNING vcod_ret,vsdodisp,vstatuscta;
		
		LET cCodRet = LPAD (TRIM(vcod_ret), 5, '0');
		
		RETURN cCodRet, vsdodisp, vstatuscta;
    
	END;
	
END PROCEDURE;