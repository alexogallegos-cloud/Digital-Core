CREATE PROCEDURE "informix".sp_libera_cupones_retencion()
   RETURNING CHAR(5) as cCodRet;

-- Declaracion de variables 
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
    DEFINE vNumCte 			CHAR(9);
    DEFINE vSucursal 	    CHAR(4);
    DEFINE vEjecutivo 	    CHAR(8);
    DEFINE vFecha 			DATE; 
    DEFINE vMotivo 			CHAR(4);
    DEFINE vFolio 			CHAR(20);

    DEFINE vExiste           INTEGER;
	

	 LET cCodRet			  = '00000';
	 LET iSqlErr			  = 0;
     LET vNumCte              = '';
     LET vSucursal            = '';
     LET vEjecutivo           = '';
     LET vFecha               = '';
     LET vMotivo              = '';
     LET vFolio               = '';
     LET vExiste              = 0;
						
BEGIN  -- // MANEJADOR DE ERRORES //
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  

-- // ACTUALIZACION DE CUPONES //
              UPDATE bdicred:"informix".sd_cupones_retencion
              SET cliente = NULL  where   cliente is not null 
                  and sucursal is null
                  and ejecutivo is null
                  and fecha is null
                  and motivo is null;

	  RETURN cCodRet;
		
END;
END PROCEDURE

--'AUTOR : 98699921 - Abdon Obed Hernandez',
--'DESCRIPCION: SP que libera los cupones.',
--'FOLIO: 833-Cedula de Retencion',
--'FECHA : 04/02/2022',	
--'BD: BDICRED',;

CREATE PROCEDURE "informix".sp_oferta_recompensas_retencion (
	pEmpresa CHAR(3),
	pNumCte CHAR(9),
	pMotivoCancelacion  CHAR(4),
	pSemaforo  CHAR(1)
	)
RETURNING CHAR(5) AS codRet, SMALLINT as idTipoRecompensa, CHAR(20) as descripcionTipoRecompensa, CHAR(100) as descripcionRecompensa,
		money(14,2) as monto, CHAR(12) as idPlantilla, INTEGER as idCupon, CHAR(50) as tipoCupon,
		CHAR(20) as folio, DATE as vigencia,CHAR(120) as instrucciones,CHAR(4) as empresaCoppel, 
		CHAR(50) as url, CHAR(1) as promocion,CHAR(2) as plazo,CHAR(2)as tasa

--Variables para el manejo de errores
DEFINE iSqlErr 	  					INTEGER;  
DEFINE iIsamErr   					INTEGER;
-- Retorno general
DEFINE codRet 						CHAR(5);
DEFINE idTipoRecompensa 			SMALLINT;
DEFINE descripcionTipoRecompensa 	CHAR(20);
DEFINE descripcionRecompensa 		CHAR(100);DEFINE monto 						MONEY(14,2);DEFINE idPlantilla 					CHAR(12);DEFINE idCupon 						INTEGER;
DEFINE tipoCupon 					CHAR(50); --Tiempo aire, Dinero electronic etc
DEFINE folio 						CHAR(20);DEFINE vigencia 					DATE;DEFINE instrucciones 				CHAR(120);
DEFINE empresaCoppel 				CHAR(4);
DEFINE url 							CHAR(50);
--Retornos exclusivos pagos fijos
DEFINE promocion 					CHAR(1);
DEFINE plazo 						CHAR(2);
DEFINE tasa 						CHAR(2);
--Variables internas  
DEFINE ctesCount 				INTEGER;
DEFINE idDetalleCupon		 	INTEGER;
DEFINE idDetalleBonificacion 	INTEGER;
DEFINE idDetallePagoFijo 		INTEGER;
DEFINE mesesPromoRec 			CHAR(2);
DEFINE pNumCteBonificado		INTEGER;
DEFINE bonificacionesEnPeriodo	INTEGER;
DEFINE fechaHoy					DATE;
DEFINE nrowsupdate     			INTEGER;


BEGIN	
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN 
			LET codRet = iSqlErr;
			RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_aplica_bonificacion_retencion"".out";     
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3; 

	-- Inicializacion de variables
	LET codRet = '00000';
	LET idTipoRecompensa = null;
	LET descripcionTipoRecompensa = '';
	LET descripcionRecompensa = '';
	LET monto = null;
	LET idPlantilla = '';
	LET idCupon =null;
	LET tipoCupon='';
	LET folio='';
	LET vigencia = null;
	LET instrucciones ='';
	LET empresaCoppel ='';
	LET url ='';
	LET promocion ='';
	LET plazo ='';
	LET tasa  ='';
	--inicializar variables de proceso
	LET idDetalleCupon = null;
	LET idDetalleBonificacion = null;
	LET idDetallePagoFijo = null;
	LET mesesPromoRec = '';

	--Valida de parametros 
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' OR NVL(pMotivoCancelacion,'') = ''  OR NVL(pSemaforo,'') = ''
	 then 
		LET codRet = "00001";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
	END IF;
	-->Inicia Logica de SP
	-- inicia Validaciones de negocio -->V0002 creacion de bloque de validacion
	-- Se valida que el cliente exista 
	select numcte into pNumCte from bdinteg:si_cliente where empresa=pEmpresa and numcte=pNumCte;
	LET ctesCount = dbinfo("sqlca.sqlerrd2");
	if ctesCount = 0 then 
		LET codRet = "00002";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
	end if;
	-- Se valida que la recompensa buscada exista 
	select  tipo_recompensa, id_detalle_cupon, id_detalle_bonificacion, id_detalle_pago_fijo    
	INTO    idTipoRecompensa, idDetalleCupon, idDetalleBonificacion, idDetallePagoFijo
	from sd_recompensas_retencion  where  motivo_cancelacion = pMotivoCancelacion and semaforo = pSemaforo;
	if NVL(idTipoRecompensa,'')='' or idTipoRecompensa=0 then
		LET codRet = "00003";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;	
	end if;
	-- Se consulta la fecha actual del sistema 
	select fecha_hoy INTO fechaHoy from sd_fechas where empresa ='001';
	-- Se consulta el numero meses del periodo en el que el cliente no debe de tener una recompensa aceptada 
	select TRIM(valor) INTO mesesPromoRec from sd_param where empresa=pEmpresa and cod_param='VRR';
	if NVL(mesesPromoRec,'') = ''  THEN
		LET codRet = "00004";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;	
	end if;
	-- Se valida que no tenga una recompensa aceptada en un periodo de tiempo parametrizado 
	select numcte into pNumCteBonificado  from sd_bitacora_retencion 
	where numcte=pNumCte and fecha BETWEEN ADD_MONTHS(fechaHoy,cast(('-'||mesesPromoRec) as integer)) and fechaHoy and acepta_recompensa ='t' limit 1;
	LET bonificacionesEnPeriodo = dbinfo("sqlca.sqlerrd2");
	if bonificacionesEnPeriodo > 0 THEN
		LET codRet = "00005";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
	end if;
	-- Se valida que el tipo de recompensa exista y este configurado correctamente 
	select descripcion INTO descripcionTipoRecompensa from sd_tipos_recompensas_retencion where tipo_recompensa = idTipoRecompensa;																																	  
	if NVL(descripcionTipoRecompensa,'') = '' THEN
		LET codRet = "00006";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
	end if;
	if  (idTipoRecompensa not in (1,2,3)) or 
		(idTipoRecompensa = 1 and NVL(idDetalleCupon,'') ='' ) or 
		(idTipoRecompensa = 2 and NVL(idDetalleBonificacion,'') ='') or 
		(idTipoRecompensa = 3 and NVL(idDetallePagoFijo,'')='') then 
		LET codRet = "00006";
		RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
		folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
	end if	
	-->Termina Validaciones de negocio
	
	-- 1->Flujo de acuerdo al tipo de recompensa -->V0002 creacion de flujo
	if  idTipoRecompensa = 1  THEN
	-- 1.1 -> LA RECOMPENSA ES CUPON
		-- Se consulta la existencia de la configuracion del cupon 
		select sdcr.descripcion as descripcionRecompensa, sdcr.monto, sdcr.idplantilla, 
			stcr.descripcion, stcr.instrucciones, stcr.empresa_coppel, stcr.url
		INTO descripcionRecompensa, monto, idPlantilla,
			tipoCupon, instrucciones, empresaCoppel,url
		from sd_detalle_cupones_retencion sdcr
		inner join sd_tipos_cupones_retencion stcr on sdcr.id_tipo_cupon = stcr.id_tipo_cupon 
		where id_detalle_cupon = idDetalleCupon;
		
		-- se valida que exista la configuracion sd_detalle_cupones_retencion -> sd_tipos_cupones_retencion 
		if NVL(descripcionRecompensa,'') = '' THEN
			LET codRet = "00006";
			RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
			folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
		end if;
		
		--se consulta que exista disponible un cupon 
		select min(scr.id_cupon) INTO idCupon from sd_cupones_retencion scr where scr.id_detalle_cupon = idDetalleCupon and scr.cliente is null and scr.vigencia>=fechaHoy;		
		-- se valida que exista disponible un cupon  
		if NVL(idCupon,'') = '' THEN
			LET codRet = "00007";
			RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
			folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
		end if; 
				
		--Si todo va bien se obtiene aparta el cupon y se obtienen los datos adicionales
		update sd_cupones_retencion set cliente = pNumCte where id_cupon= idCupon and cliente is null;
		--Se valida que en el tiempo en el que se consulta y realiza el update no le hayan ganado el cupon si es asi se manda 00007 repita el proceso
		LET nrowsupdate = dbinfo("sqlca.sqlerrd2");
		IF nrowsupdate = 0 THEN
		    LET codRet = "00007";			RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
			folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
		end if;
		--consultar el folio asignado 
		select scr.folio,scr.vigencia INTO folio,vigencia from sd_cupones_retencion scr where id_cupon=idCupon; 	
	elif idTipoRecompensa = 2 THEN
	-- 1.2 -> LA RECOMPENSA ES BONIFICACION
		-- se consulta que exista el detalle de bonificacion 
		select sdbr.monto, sdbr.descripcion, sdbr.idplantilla 
		into monto, descripcionRecompensa, idPlantilla
		from sd_detalle_bonificaciones_retencion sdbr where id_detalle_bonificacion = idDetalleBonificacion;
		-- se valida que exista informacion  
		if trim(NVL(descripcionRecompensa,'')) = '' THEN
			LET codRet = "00006";
			RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
			folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
		end if;		
	elif idTipoRecompensa = 3 THEN  
	-- 1.3 -> LA RECOMPENSA ES PAGOS FIJOS
		-- se consulta que exista el detalle de la promocion de pagos fijos  
		select  sdpfr.promocion, sdpfr.descripcion, sdpfr.plazo, sdpfr.tasa, sdpfr.idplantilla 
		into promocion, descripcionRecompensa, plazo, tasa, idPlantilla		
		from sd_detalle_pagos_fijos_retencion sdpfr where id_detalle_pago_fijo=idDetallePagoFijo;
		--se valida que se encuentre la informacion 
		if trim(NVL(descripcionRecompensa,'')) = '' THEN
			LET codRet = "00006";
			RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
			folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
		end if;	
		
	end if;
	
	-->Termina Logica de SP	
	RETURN codRet, idTipoRecompensa, descripcionTipoRecompensa, descripcionRecompensa, monto, idPlantilla, idCupon, tipoCupon,
	folio, vigencia, instrucciones, empresaCoppel, url, promocion, plazo, tasa;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Alejandro Rodriguez Martinez', 
'DESCRIPCION: Valida la recompensa que le corresponde al cliente al intentar cancelar su credito',
'Codigo de retorno 00001 indica que se ha enviado parametros de entrada invalidos',
'Codigo de retorno 00002 No se encontro el cliente',
'Codigo de retorno 00003 El cliente no tiene recompensas disponibles',
'Codigo de retorno 00004 No se encuentra el parametro de periodo de bonificaciones VRR',
'Codigo de retorno 00005 El cliente cuenta con una bonificacion en el periodo parametrizado (actualmente 12 anteriores a la nueva validacion)',
'Codigo de retorno 00006 Se encuentra un problema en la configuracion de recompensas ',
'Codigo de retorno 00007 Para la parte de cupon, No se encontro un cupon disponible',
'FECHA : 03/Marzo/2022',
'BD    : BDICRED',
'FOLIO: 833 - Adendum RQM 10 1405 CÃ©lula de RetenciÃ³n TDC',
'MODIFICADO: Alejandro Rodriguez Martinez se agrego la parte de validaciones de negocio y creacion de flujo de acuerdo al tipo de recompensa. Etiqueta: V0002',
'FECHA: 07/Marzo/2022',
'MODIFICADO: Alejandro Rodriguez Martinez se cambio la longitud del parametro de salida instrucciones de 100 a 120 ',
'FECHA: 24/Marzo/2022';

CREATE PROCEDURE "informix".sp_repdiarioretencion()
    RETURNING
		CHAR(6) 		AS COD_RET,
		CHAR(80)		AS MENSAJE_RET;
    ---DECLARACIONES
		DEFINE iSqlErr			    INTEGER;
		DEFINE iIsamErr				INTEGER;
		DEFINE cTabla		      	CHAR(1);
		DEFINE v_empresa            CHAR(3);
		DEFINE cProceso             CHAR(4);
		DEFINE cCodRet,vvcCod_ret	CHAR(6);
		DEFINE cMensajeRet          CHAR(80);
		DEFINE cNombreArchivo       CHAR(80);
		DEFINE cRuta			    CHAR(80);
		DEFINE cConsulta		  	CHAR(2200);
		DEFINE cSql           		CHAR(1024);
		DEFINE dtFechaHoy           DATE;
		--DEFINE conDatos             INTEGER;
		---INICIALIZACIONES
		LET iSqlErr         = 0;   
		LET iIsamErr        = 0; 
		LET cCodRet         = "000000";
		LET cMensajeRet	    = "Proceso exitoso";
		LET cNombreArchivo 	= "Clientesretenidos_";   
		LET cTabla	        = "N"; 
		LET cConsulta		= ""; 
		LET cSql	        = ""; 
		LET cRuta	        = "";
		LET v_empresa       = '001';
		LET dtFechaHoy      = "";
		-- conDatos        = 0;
		
		BEGIN
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

--		SET DEBUG FILE TO "/informix/German/sp_repDiarioRetencion.out";
--		TRACE ON;
		--SE BORRAN LAS TABLAS TEMPORALES SI EXISTEN.
		--IF EXISTS (SELECT tabname  FROM sysmaster:systabnames WHERE tabname = "tmp_detallerepdiario" AND dbsname= "bdicred" AND partnum >1048577) THEN
		IF (SELECT COUNT(tabname) FROM sysmaster:systabnames WHERE tabname = "tmp_detallerepdiario" AND dbsname= "bdicred" AND partnum >1048577) > 0 THEN
			DROP  TABLE tmp_detallerepdiario;
		END IF;	
		
		--SE OBTIENE LA RUTA DE SI_PARAM.
        SELECT valor 
		INTO cRuta
		FROM bdinteg:"informix".si_param 
		WHERE cod_param = 503;
        --SE DEFINE EL NOMBRE DEL ARCHIVO EXCEL
        LET  cRuta = "/RESPALDOS" || cRuta || '/';
         --LET  cRuta = '/informix/resplogifx/archivoscredito/';

		--DETERMINACION DE FECHA CORTE:
		SELECT fecha_hoy
		  INTO dtFechaHoy
		  FROM bdicred:"informix".sd_fechas
          WHERE empresa = v_empresa;
		
        select distinct(trim(sic.nombre1) || ' ' || trim(sic.nombre2) || ' ' || trim(sic.apell_paterno) || ' ' || trim(sic.apell_materno)) nombre
            , sdbr.numcte numcte, sdbr.num_credito numcredito, sdbr.motivo_cancelacion motivo, sit.telefono celular, sico.correo_elec correo, 
            (to_char(sdbr.fecha,  '%d/%m/%y') ||' '||sdbr.hora_fin) fechahora
        from sd_bitacora_retencion sdbr, bdinteg: si_cliente sic, bdinteg: si_telefonos_actual sit,
            bdinteg:si_correos sico
        where sdbr.numcte = sic.numcte 
        and sic.numcte = sit.numcte 
        and sic.numcte = sico.numcte
        and sit.tipo_tel = 2
        and sdbr.acepta_recompensa = 't'
        and sdbr.fecha = dtFechaHoy
        into tmp_detallerepdiario; 
        
        --SE VALIDA QUE LA TABLA TEMPORAL SE HAYA CARGADO CON LOS DATOS
       -- select count(*) 
        --into conDatos
        --from tmp_detallerepdiario;
        
       -- if conDatos > 0 then
            LET cNombreArchivo = TRIM(cNombreArchivo)||YEAR(dtFechaHoy)||LPAD(MONTH(dtFechaHoy),2,0)||LPAD(DAY(dtFechaHoy),2,0);
            LET cConsulta = "SELECT nombre, numcte, numcredito, motivo, celular, correo, fechahora FROM tmp_detallerepdiario";		
            LET cSql = '';
            LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query1.sql';
            --LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.xls'|| ' DELIMITER '|| '''	'''||' '||TRIM(cConsulta);
            SYSTEM TRIM(cSql);
            
            LET cSql = '';
            LET cSql = "dbaccess bdicred " ||TRIM(cRuta)||'query1.sql';
            SYSTEM cSql;
            LET cSql = '';
            LET cSQL = "rm " ||TRIM(cRuta)||'query1.sql';	
            SYSTEM cSql; 
            --let cTabla = 'S';
		--else
		  --  let cCodRet = '00001';
		  --  let cMensajeRet = 'NO HAY DATOS GENERADOS ESTE DIA ' + dtFechaHoy;
		    --return cCodRet, cMensajeRet;
		--end if;
		IF cTabla="S" THEN
				DROP TABLE bdicobranza:"informix".tmp_detallerepdiario;
		END IF;
		LET cMensajeRet = TRIM(cNombreArchivo)||'.xls';
		
    RETURN cCodRet, cMensajeRet;
		
	END;
END PROCEDURE
DOCUMENT
"Procedimiento para generacion de archivo excel con recompensas aceptadas cedula de retencion",
"Creado por Luis GermÃ¡n Viveros Andrade 2022-02-22";

CREATE PROCEDURE "informix".respaldacredito()
   RETURNING CHAR(5);   --CodRet
                                                                                
                                                                                
   DEFINE CodRet              CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);
   --AAME INC 27 108
   DEFINE cnumcredito             CHAR(20);
                                                                                
   DEFINE wSecuenciaPago      LIKE sd_secpago.secuencia;                        
                                                                                
   DEFINE GLOBAL g_Empresa    CHAR(3)  DEFAULT ' ';                             
   DEFINE GLOBAL g_NumCredito CHAR(20) DEFAULT ' ';                             
   DEFINE GLOBAL g_Folio      CHAR(16) DEFAULT ' ';                             
                                                                                
   LET CodRet = "000";  
	--AAME INC 27 108   
   LET cnumcredito = '';
   
   	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ; 
	
	
   SELECT MAX(secuencia)                                                        
     INTO wSecuenciaPago                                                        
     FROM sd_secpago                                                            
    WHERE empresa = g_Empresa                                                   
      AND num_credito = g_NumCredito; 

--set debug file to "respaldacredito.out";
--trace on;
  
                                                                                
   IF(wSecuenciaPago = 0 OR wSecuenciaPago IS NULL) THEN                        
      LET wSecuenciaPago = 0;                                                   
   END IF;                                                                      
                                                                                
   LET wSecuenciaPago = wSecuenciaPago + 1;                                     
	--AAME INC 27 108 Se agrega validacion para que inserte siempre y cuando no se tenga ya el respaldo del folio a consultar
	SELECT count(num_credito) INTO cnumcredito FROM "informix".sd_secpago WHERE num_credito = g_NumCredito AND folio_suc = g_Folio;
	IF cnumcredito = 0 THEN
	   INSERT INTO                                                                  
		  sd_secpago (empresa, num_credito, folio_suc, secuencia)                   
	   VALUES                                                                       
		  (g_empresa, g_NumCredito, g_Folio, wSecuenciaPago);                       
																			
	-------------------------------------------------------                         
	--    RESPALDO DE MAECRED                            --                         
	-------------------------------------------------------                         
	   INSERT INTO                                                                  
		  sd_maecredrev                                                             
			(empresa,                                                               
			 num_credito,                                                           
			 folio,                                                                 
			 num_producto,                                                          
			 ejecutivo,                                                             
			 numcte,                                                                
			 divisa,                                                                
			 sucursal,                                                              
			 id_origen,                                                             
			 origen,                                                                
			 cod_tipo_linea,                                                        
			 cod_linea,                                                             
			 porc_rec_prop,                                                         
			 status_cred,                                                           
			 bandera_renovac,                                                       
			 bandera_prorroga,                                                      
			 periodo_plazo,                                                         
			 plazo,                                                                 
			 fecha_apertura,                                                        
			 fecha_vencim,                                                          
			 period_pago_cap,                                                       
			 period_pag_int,                                                        
			 dias_trasp_cap,                                                        
			 dias_trasp_int,                                                        
			 tasa_fija_o_var,                                                       
			 cod_tasa_base,                                                         
			 factor_sobretasa,                                                      
			 sobretasa,                                                             
			 tasa_interes,                                                          
			 cod_tasa_mora,                                                         
			 sobretasa_mora,                                                        
			 fact_sobret_mora,                                                      
			 tasa_moratorios,                                                       
			 fecha_pago_cap,                                                        
			 fecha_pago_int,                                                        
			 es_fisica,                                                             
			 bandera_fi_fo,                                                         
			 codigo_pro,                                                            
			 superficie,                                                            
			 actividad,                                                             
			 cal_edos_fin,                                                          
			 tipo_calculo,                                                          
			 admite_tlp,                                                            
			 rel_garcred,                                                           
			 id_unidad_prod,                                                        
			 num_aper_ant,                                                          
			 rev_tasa_var_per,                                                      
			 dia_para_revisar,                                                      
			 cod_prod,                                                              
			 bandera_ministra,                                                      
			 num_fideicomiso,                                                       
			 credito_externo,                                                       
			 gracia_capital,                                                        
			 diferimiento_int,                                                      
			 fecha_fin_prorrateo,                                                   
			 campo_trab1,                                                           
			 campo_trab2,                                                           
			 campo_trab3,                                                           
			 campo_trab4,                                                           
			 calificacion_riesgo,                                                   
			 cod_agricola,                                                          
			 tasa_base_piso,                                                        
			 sobretasa_piso,                                                        
			 factor_piso,                                                           
			 tasa_piso,                                                             
			 tasa_base_techo,                                                       
			 sobretasa_techo,                                                       
			 factor_techo,                                                          
			 tasa_techo,
			 cod_caract,
			 cod_caract_2
			 ,cuenta_clabe)                                                            
	   SELECT                                                                       
			empresa,                                                                
			 num_credito,                                                           
			 g_folio,                                                               
			 num_producto,                                                          
			 ejecutivo,                                                             
			 numcte,                                                                
			 divisa,                                                                
			 sucursal,                                                              
			 id_origen,                                                             
			 origen,                                                                
			 cod_tipo_linea,                                                        
			 cod_linea,                                                             
			 porc_rec_prop,                                                         
			 status_cred,                                                           
			 bandera_renovac,                                                       
			 bandera_prorroga,                                                      
			 periodo_plazo,                                                         
			 plazo,                                                                 
			 fecha_apertura,                                                        
			 fecha_vencim,                                                          
			 period_pago_cap,                                                       
			 period_pag_int,                                                        
			 dias_trasp_cap,                                                        
			 dias_trasp_int,                                                        
			 tasa_fija_o_var,                                                       
			 cod_tasa_base,                                                         
			 factor_sobretasa,                                                      
			 sobretasa,                                                             
			 tasa_interes,                                                          
			 cod_tasa_mora,                                                         
			 sobretasa_mora,                                                        
			 fact_sobret_mora,                                                      
			 tasa_moratorios,                                                       
			 fecha_pago_cap,                                                        
			 fecha_pago_int,                                                        
			 es_fisica,                                                             
			 bandera_fi_fo,                                                         
			 codigo_pro,                                                            
			 superficie,                                                            
			 actividad,                                                             
			 cal_edos_fin,                                                          
			 tipo_calculo,                                                          
			 admite_tlp,                                                            
			 rel_garcred,                                                           
			 id_unidad_prod,                                                        
			 num_aper_ant,                                                          
			 rev_tasa_var_per,                                                      
			 dia_para_revisar,                                                      
			 cod_prod,                                                              
			 bandera_ministra,                                                      
			 num_fideicomiso,                                                       
			 credito_externo,                                                       
			 gracia_capital,                                                        
			 diferimiento_int,                                                      
			 fecha_fin_prorrateo,                                                   
			 campo_trab1,                                                           
			 campo_trab2,                                                           
			 campo_trab3,                                                           
			 campo_trab4,                                                           
			 calificacion_riesgo,                                                   
			 cod_agricola,                                                          
			 tasa_base_piso,                                                        
			 sobretasa_piso,                                                        
			 factor_piso,                                                           
			 tasa_piso,                                                             
			 tasa_base_techo,                                                       
			 sobretasa_techo,                                                       
			 factor_techo,                                                          
			 tasa_techo,         
			 cod_caract,
			 cod_caract_2  
			 ,cuenta_clabe			 
	   FROM                                                                         
		sd_maecred                                                                  
	   WHERE                                                                        
		 num_credito = g_NumCredito                                                 
	   AND                                                                          
		 empresa = g_Empresa;                                                       
																					
	----------------------------------------------------------                      
	--            RESPALDO DE MAESDOS                                               
	----------------------------------------------------------                      
	   INSERT INTO                                
		  sd_maesdosrev                           
			 (empresa,                            
			  num_credito,                        
			  folio,                              
			  fecha_ult_mov,                      
			  sdo_int_anticip,                    
			  sdo_int_ant_dev,                    
			  sdo_intereses,                      
			  sdo_dia_ant_int,                    
			  sdo_mes_ant_int,                    
			  sdo_acum_mes_int,                   
			  sdo_retenido,                       
			  sdo_acum_cap_int,                   
			  sdo_exig_int,                       
			  sdo_no_exig,                        
			  provision_normal,                                                     
			  dias_acum_int,                                                        
			  sdo_moratorio,                                                        
			  sdo_dia_ant_mor,                                                      
			  sdo_mes_ant_mor,                                                      
			  sdo_contab_mora,                                                      
			  dias_acum_mora,                                                       
			  sdo_capital,                                                          
			  sdo_cap_insoluto,                                                     
			  sdo_dia_ant_cap,                                                      
			  sdo_mes_ant_cap,                                                      
			  sdo_acum_mes_cap,                                                     
			  mto_capitalizado,                                                     
			  mto_ministra_cap,                                                     
			  cargos_dia_cap,                                                       
			  abonos_dia_cap,                                                       
			  cargos_mes_cap,                                                       
			  abonos_mes_cap,                                                       
			  dias_acum_cap,                                                        
			  monto_vencido,                                                        
			  mto_venc_trasp,                                                       
			  monto_financiado,                                                     
			  monto_reservado,                                                      
			  sdo_acum_vencido,                                                     
			  dias_acum_intper,                                                     
			  sdo_global_int,                                                       
			  sdo_acum_intper,                                                      
			  monto_otorgado,                                                       
			  provi_venc_normal,                                                    
			  provi_venc_anticip,                                                   
			  cap_tras_no_venci,                                                    
			  mto_venc_int,                                                         
			  mto_venc_tra_int,                                                     
			  mto_finan_vdo,                                                        
			  mto_reser_int,                                                        
			  mto_fin_ven_trasp,                                                    
			  mto_fin_vig_trasp,                                                    
			  int_tra_no_exig,                                                      
			  sdo_trab4,
			  act)                                                            
	   SELECT                                                                       
			  empresa,                                                              
			  num_credito,                                                          
			  g_Folio,                                                              
			  fecha_ult_mov,                                                        
			  sdo_int_anticip,                                                      
			  sdo_int_ant_dev,                                                      
			  sdo_intereses,                                                        
			  sdo_dia_ant_int,                                                      
			  sdo_mes_ant_int,                                                      
			  sdo_acum_mes_int,                                                     
			  sdo_retenido,                                                         
			  sdo_acum_cap_int,                                                     
			  sdo_exig_int,                                                         
			  sdo_no_exig,                                                          
			  provision_normal,                                                     
			  dias_acum_int,                                                        
			  sdo_moratorio,                                                        
			  sdo_dia_ant_mor,                                                      
			  sdo_mes_ant_mor,                                                      
			  sdo_contab_mora,                                                      
			  dias_acum_mora,                                                       
			  sdo_capital,                                                          
			  sdo_cap_insoluto,                                                     
			  sdo_dia_ant_cap,                                                      
			  sdo_mes_ant_cap,                                                      
			  sdo_acum_mes_cap,                                                     
			  mto_capitalizado,                                                     
			  mto_ministra_cap,                                                     
			  cargos_dia_cap,                                                       
			  abonos_dia_cap,                                                       
			  cargos_mes_cap,                                                       
			  abonos_mes_cap,                                                       
			  dias_acum_cap,                                                        
			  monto_vencido,                                                        
			  mto_venc_trasp,                                                       
			  monto_financiado,                                                     
			  monto_reservado,                                                      
			  sdo_acum_vencido,                                                     
			  dias_acum_intper,                                                     
			  sdo_global_int,                                                       
			  sdo_acum_intper,                                                      
			  monto_otorgado,                                                       
			  provi_venc_normal,                                                    
			  provi_venc_anticip,                                                   
			  cap_tras_no_venci,                                                    
			  mto_venc_int,                                                         
			  mto_venc_tra_int,                                                     
			  mto_finan_vdo,                                                        
			  mto_reser_int,                                                        
			  mto_fin_ven_trasp,                                                    
			  mto_fin_vig_trasp,                                                    
			  int_tra_no_exig,                                                      
			  sdo_trab4,
			  act                                                           
	   FROM sd_maesdos                                                              
	   WHERE empresa     = g_Empresa                                                
	   AND num_credito = g_NumCredito;                                              
																					
																					
	-------------------------------------                                           
	-- Inicia respaldo de sd_pagocapit --                                           
	-------------------------------------                                           
	   INSERT INTO                                                                  
		  sd_pagocapitrev                                                           
			 (empresa,                                                              
			  num_credito,                                                          
			  folio,                                                                
			  fecha_cuota,                                                          
			  cuota_rec,                                                            
			  monto_cuota,                                                          
			  saldo_cuota,                                                          
			  imp_capitalizado,                                                     
			  factor_ajuste,                                                        
			  monto_real_pag,                                                       
			  fecha_pago,                                                           
			  factor_moratorio,                                                     
			  monto_moratorio,                                                      
			  fecha_moratorio,                                                      
			  dias_moratorios,                                                      
			  status_moratorio,                                                     
			  num_pagares,                                                          
			  porc_pago,                                                            
			  bandera_ministra,                                                     
			  status_cuota)                                                         
	   SELECT                                                                       
			  empresa,                                                              
			  num_credito,                                                          
			  g_Folio,                                                              
			  fecha_cuota,                                                          
			  cuota_rec,                                                            
			  monto_cuota,                                                          
			  saldo_cuota,                                                          
			  imp_capitalizado,                                                     
			  factor_ajuste,                                                        
			  monto_real_pag,                                                       
			  fecha_pago,                                                           
			  factor_moratorio,                                                     
			  monto_moratorio,                                                      
			  fecha_moratorio,                                                      
			  dias_moratorios,                                                      
			  status_moratorio,                                                     
			  num_pagares,                                                          
			  porc_pago,                                                            
			  bandera_ministra,                                                     
			  status_cuota                                                          
	   FROM                                                                         
			 sd_pagocapit                                                           
	   WHERE                                                                        
			 empresa = g_Empresa                                                    
	   AND                                                                          
			 num_credito = g_NumCredito;                                            
																					
																					
	-------------------------------------                                           
	--Inicia Respaldo de sd_paginter   --                                           
	-------------------------------------                                           
	   INSERT INTO                                                                  
		  sd_paginterrev                                                            
			 (empresa,                                                              
			  num_credito,                                                          
			  folio,                                                                
			  fecha_cuota,                                                          
			  cuota_rec,                                                            
			  monto_cuota,                                                          
			  monto_real_pag,                                                       
			  fecha_pag,                                                            
			  factor_moratorio,                                                     
			  monto_moratorio,                                                      
			  fecha_moratorio,                                                      
			  dias_moratorio,                                                       
			  status_moratorio,                                                     
			  bonifi_int_mora,                                                      
			  porc_pago,                                                            
			  status_cuota,                                                         
			  monto_financiado)                                                     
	   SELECT                                                                       
			  empresa,                                                              
			  num_credito,                                                          
			  g_Folio,                                                              
			  fecha_cuota,                                                          
			  cuota_rec,                                                            
			  monto_cuota,                                                          
			  monto_real_pag,                                                       
			  fecha_pag,                                                            
			  factor_moratorio,                                                     
			  monto_moratorio,                                                      
			  fecha_moratorio,                                                      
			  dias_moratorio,                                                       
			  status_moratorio,                                                     
			  bonifi_int_mora,                                                      
			  porc_pago,                                                            
			  status_cuota,                                                         
			  monto_financiado                                                      
	   FROM                                                                         
			  sd_paginter                                                           
	   WHERE                                                                        
			  empresa = g_Empresa                                                   
	   AND                                                                          
			  num_credito = g_NumCredito;                                           
	-----------------------------------                                             
	-- Inicia Respaldo de sd_detmora --                                             
	-----------------------------------                                             
	   {INSERT INTO                                                                 
		  sd_detmorarev                                                             
			  (empresa, num_credito, folio, fecha_cuota, identifi_rec,              
			   sdo_acum_mes_mora, tasa_ordinaria, provi_mora_ordi,                  
			   tasa_copete, provi_mora_cope, sdo_mora_ordi, sdo_mora_cope)          
	   SELECT                                                                       
			   empresa, num_credito, g_Folio, fecha_cuota, identifi_rec,            
			   sdo_acum_mes_mora, tasa_ordinaria, provi_mora_ordi, tasa_copete,     
			   provi_mora_cope, sdo_mora_ordi, sdo_mora_cope                        
		 FROM sd_detmora                                                            
		WHERE empresa = g_Empresa                                                   
		 AND num_credito = g_NumCredito;        
	-----------------------------------                                             
	-- Inicia Respaldo de sd_detcomi --                                             
	-----------------------------------                                             
			INSERT INTO sd_detcomirev                                               
					(empresa, folio, cod_comis, num_credito, fecha_alta, secuencia, 
					 fecha_pago, monto_com, monto_pag, apli_factor,                 
					 estado_com, num_solicitud, user_insert, fecha_insert)          
			SELECT empresa, g_Folio, cod_comis, num_credito, fecha_alta, secuencia, 
					 fecha_pago, monto_com, monto_pag, apli_factor,                 
					 estado_com, num_solicitud, user_insert, fecha_insert           
			 FROM sd_detcomi                                                        
			WHERE empresa = g_Empresa                                               
			  AND num_credito = g_NumCredito;  }                                    
																					
	----------------------------------------                                        
	-- Inicia Respaldo de sd_maecredanexo --                                        
	----------------------------------------                                        
	INSERT INTO sd_maecredanexorev                                                  
			(empresa,              num_credito,         folio,                    
			 dia_corte,            dias_gracia_mora,    tp_dias_calc_mora,
			 dias_fecha_max_pago,  tp_dias_fecha_pago,  cod_tasa_base_cte,
			 factor_sobretasa_cte, sobretasa_cte,       tasa_interes_cte,
			 fecha_vencto,         prox_fecha_pago,     fecha_proceso, 
			 fecha_ult_pago  )
	SELECT empresa,              num_credito,         g_Folio,                      
		   dia_corte,            dias_gracia_mora,    tp_dias_calc_mora,
		   dias_fecha_max_pago,  tp_dias_fecha_pago,  cod_tasa_base_cte,
		   factor_sobretasa_cte, sobretasa_cte,       tasa_interes_cte,
		   fecha_vencto,         prox_fecha_pago,     fecha_proceso, 
		   fecha_ult_pago  
	  FROM sd_maecredanexo                                                          
	 WHERE empresa = g_Empresa                                                      
	   AND num_credito = g_NumCredito;                                              
	-----------------------------------                                             
	-- Inicia Respaldo de sd_escrow --                                              
	-----------------------------------                                             
	{       INSERT INTO sd_escrowrev                                                
					(empresa, num_credito, folio, fecha_venc_seg, cod_comis,        
					 monto_poliza, monto_mensual, plazo, saldo, texto)              
			SELECT empresa, num_credito, g_Folio, fecha_venc_seg, cod_comis,        
					 monto_poliza, monto_mensual, plazo, saldo, texto               
			 FROM sd_escrow                                                         
			WHERE empresa = g_Empresa                                               
			  AND num_credito = g_NumCredito;                                       
	}                                                                               
																					
	-- ---------------------------------------------------------------------        


	---------------------------------------------
	--Inicia Respaldo de sd_amortiza_credito --
	---------------------------------------------
	INSERT INTO sd_amortiza_creditorev(
		   empresa                ,
		   folio                  ,
		   num_credito            ,
		   fecha_cuota            ,
		   tipo_cuota             ,
		   capital_mto_cuota      ,
		   capital_debe           ,
		   capital_pagado         ,
		   capital_status         ,
		   capital_status_ant     ,
		   capital_fecha_pago     ,
		   interes_debe           ,
		   interes_pagado         ,
		   interes_status         ,
		   interes_status_ant     ,
		   interes_fecha_pago     ,
		   iva_debe               ,
		   iva_pagado             ,
		   iva_status             ,
		   iva_status_ant         ,
		   iva_fecha_pago         ,
		   mora_provi_ordi        ,
		   mora_provi_cope        ,
		   mora_sdo_ordi          ,
		   mora_sdo_ordi_pag      ,
		   mora_sdo_cope          ,
		   mora_sdo_cope_pag      ,
		   mora_bonificado        ,
		   mora_status            ,
		   mora_iva_debe          ,
		   mora_iva_pagado        ,
		   mora_iva_status        ,
		   mora_iva_fecha_pago    ,
		   num_pago               ,
		   campo_trabajo1         ,
		   campo_trabajo2         ,
		   campo_trabajo3         ,
		   campo_trabajo4   )
	SELECT 
		   empresa                ,
		   g_folio                ,
		   num_credito            ,
		   fecha_cuota            ,
		   tipo_cuota             ,
		   capital_mto_cuota      ,
		   capital_debe           ,
		   capital_pagado         ,
		   capital_status         ,
		   capital_status_ant     ,
		   capital_fecha_pago     ,
		   interes_debe           ,
		   interes_pagado         ,
		   interes_status         ,
		   interes_status_ant     ,
		   interes_fecha_pago     ,
		   iva_debe               ,
		   iva_pagado             ,
		   iva_status             ,
		   iva_status_ant         ,
		   iva_fecha_pago         ,
		   mora_provi_ordi        ,
		   mora_provi_cope        ,
		   mora_sdo_ordi          ,
		   mora_sdo_ordi_pag      ,
		   mora_sdo_cope          ,
		   mora_sdo_cope_pag      ,
		   mora_bonificado        ,
		   mora_status            ,
		   mora_iva_debe          ,
		   mora_iva_pagado        ,
		   mora_iva_status        ,
		   mora_iva_fecha_pago    ,
		   num_pago               ,
		   campo_trabajo1         ,
		   campo_trabajo2         ,
		   campo_trabajo3         ,
		   campo_trabajo4
	 FROM sd_amortiza_credito
	 WHERE empresa     = g_empresa
	   and Num_credito = g_numcredito;
	--------------------------------------
	END IF;
   RETURN CodRet;

END PROCEDURE                                                                   
DOCUMENT
'Este SPL realiza el respaldo de las tablas de Credito involucradas',
'En el pago, para poder efectuar su reversion',
'AUTOR : Raul Mendoza D nes',
'FECHA : 20/Octubre/2003',
'BD    : BDICRED';

CREATE PROCEDURE "informix".principalrefer(p_Empresa  CHAR(3),
                           p_NumCredito             CHAR(20),
                           p_TpPago                 SMALLINT, 
                           p_Tarjeta                CHAR(20),
                           p_Usuario                CHAR(8),
                           p_Sucursal               CHAR(4),
                           p_Folio                  LIKE sd_movdia.Folio_Suc,
                           p_Transacc               LIKE sd_movdia.Transacc_Suc,
                           p_MontoSBC               MONEY(14,2),
                           p_MontoEfe               MONEY(14,2),
                           p_referencia             char(40))
  --Valores a Regresar
      RETURNING CHAR(5),     -- Codigo de Retorno
             MONEY(14,2), -- Remanente
             MONEY(14,2), -- Interes Moratorio Cobrado
             MONEY(14,2), -- Interes Vencido Cobrado
             MONEY(14,2), -- Capital Vencido Cobrado
             MONEY(14,2), -- Interes Vigente Cobrado
             MONEY(14,2), -- Capital Vigente Cobrado
             MONEY(14,2), -- Impuesto Cobrado
             MONEY(14,2), -- Comisiones Cobradas
             MONEY(14,2)  -- Seguro Cobrado

 DEFINE GLOBAL g_sistema       CHAR(2)     DEFAULT '06';

   DEFINE CodRet                CHAR(5);
   DEFINE sql_err               SMALLINT;
   DEFINE isam_err              SMALLINT;
   DEFINE error_info            CHAR(40);
   DEFINE nRows                 SMALLINT;
   DEFINE Mensaje               CHAR(80);
   DEFINE wBegin                CHAR(1);
   DEFINE vfecha_hoy            DATE;
   
   DEFINE g_IntMoraCob   MONEY(14,2);
   DEFINE g_IntVencCob   MONEY(14,2);
   DEFINE g_CapVencCob   MONEY(14,2);
   DEFINE g_IntVigCob    MONEY(14,2);
   DEFINE g_CapVigCob    MONEY(14,2);
   DEFINE g_Impuesto     MONEY(14,2);
   DEFINE g_Comision     MONEY(14,2);
   DEFINE g_Seguro       MONEY(14,2);
   DEFINE g_Remanente    MONEY(14,2);
   DEFINE g_NumProducto   CHAR(4);
   DEFINE g_NumCte        CHAR(20);
   DEFINE v_NumCredito    CHAR(20);
   DEFINE vSdoTdc_Crds 	  		DECIMAL(14,2);	-- Cobro sdo a favor para pago PFSI
   DEFINE dFechaCreds	  		DATE;
   DEFINE cNum_Credisol	  		CHAR(20);
   DEFINE dCap_Credisol	  		DECIMAL(14,2);
   DEFINE dMntoPagoCredis 		DECIMAL(14,2);
   DEFINE cNumCredito_Crds		CHAR(20);
   DEFINE cCta_Eje_Crds        	CHAR(20);
   DEFINE cProducto_Crds       	CHAR(40);
   DEFINE cNum_Cte_Crds        	CHAR(20);
   DEFINE cNom_Cte_Crds        	CHAR(150);
   DEFINE dPago_Efec_Crds      	DECIMAL(18,2);
   DEFINE dPago_Cta_Crds       	DECIMAL(18,2);
   DEFINE dMonto_Op_Crds     	DECIMAL(18,2);
   DEFINE dSaldo_Actual_Crds   	DECIMAL(18,2);
   DEFINE cStatus_Actual_Crds  	CHAR(60);
   DEFINE dFecha_ProxPago_Crds	DATE;									  
									        

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
      LET Mensaje = error_info;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
	     g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
   END EXCEPTION;

   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      --ROLLBACK WORK;
      COMMIT WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

   
    --SET DEBUG FILE TO "/informix/mahr/principalrefer-"||p_Transacc||".out";     
    --TRACE ON;

   LET wBegin = "N";
   LET vSdoTdc_Crds 	= 0;
   LET dFechaCreds		= DATE(1);
   LET cNum_Credisol 	= '';
   LET dCap_Credisol 	= 0;   
   LET dMntoPagoCredis	= 0;
   
   LET cNumCredito_Crds		= '';
   LET cCta_Eje_Crds        = '';
   LET cProducto_Crds       = '';
   LET cNum_Cte_Crds        = '';
   LET cNom_Cte_Crds        = '';
   LET dPago_Efec_Crds      = 0;
   LET dPago_Cta_Crds       = 0;
   LET dMonto_Op_Crds     	= 0;
   LET dSaldo_Actual_Crds   = 0;
   LET cStatus_Actual_Crds  = '';
   LET dFecha_ProxPago_Crds	= DATE(1);

   BEGIN WORK;

   LET CodRet = "000";
   LET v_NumCredito = "";
   LET vfecha_hoy = "";
   LET g_Seguro =0;
   
   SELECT descripcion
     INTO Mensaje
     FROM bdinteg:"informix".si_codret
    WHERE sistema = g_sistema
      AND codigo_retorno = CodRet;
	  
   SELECT fecha_hoy INTO vfecha_hoy FROM "informix".sd_fechas;

   LET p_Empresa     = p_Empresa;
   LET g_Remanente   = 0;
   LET g_IntMoraCob  = 0;
   LET g_IntVencCob  = 0;
   LET g_CapVencCob  = 0;
   LET g_IntVigCob   = 0;
   LET g_CapVigCob   = 0;
   LET g_Impuesto    = 0;
   LET g_Comision    = 0;
   LET g_Seguro      = 0;   
   LET nRows         = 0;
   
   --**Se selecciona el producto
   IF length(p_NumCredito) = 16 THEN
      LET p_Tarjeta = p_NumCredito;

      SELECT num_credito 
        INTO v_NumCredito
        FROM "informix".sd_tarjeta
       WHERE num_tarjeta = p_NumCredito
         AND empresa     = p_Empresa; 
   ELSE
      LET v_NumCredito = p_NumCredito;
   END IF

   --Pago de TDC por Efectivo
    IF p_MontoEfe < 1 and p_Transacc = '0600' THEN
		if p_MontoEfe > 0 THEN 
			let CodRet = '399';
		ELSE
			let CodRet = '284';
		END IF;
    ELSE
      if p_MontoEfe > 0 then
            CALL "informix".Principal(
                p_Empresa,
                v_NumCredito,
                p_TpPago,
                p_MontoEfe,
                p_Usuario,
                p_Sucursal,
                p_Folio,
                p_Transacc
            )
            returning CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
                   g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;

            IF (CodRet <> "000") THEN
                SELECT descripcion
                INTO   Mensaje
                FROM   bdinteg:"informix".si_codret
                WHERE  sistema        = "06"
                AND    codigo_retorno = CodRet;
                ROLLBACK WORK;
                IF (wBegin = "S") THEN
                   BEGIN WORK;
                END IF;
            ELSE
				if ( p_Transacc = '8324') then  --Se graba clave de rastreo para movimientos de credito SPEI
                    UPDATE "informix".sd_movdia
                       SET referencia = p_referencia
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                elif ( p_Transacc = '6246') then  -- Graba referencia saldo buen cobro            
                    UPDATE "informix".sd_movdia
                       SET referencia23 = p_referencia,
                           nro_tarjeta = p_Tarjeta
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                else
                    UPDATE "informix".sd_movdia
                       SET nro_tarjeta = p_Tarjeta
                     WHERE folio_suc = p_folio
                       AND sucursal = p_Sucursal; 
                end if;
				
				-- Pago de TDC termina correctamente. Realiza el cobro del saldo a favor si existe un PFSI activo (Sdo Inmediato - Apoyo 2020)
				SELECT sdo_cap_insoluto INTO vSdoTdc_Crds FROM bdicred:"informix".sd_maesdos WHERE empresa = p_Empresa AND num_credito = v_NumCredito;
				
				--IF vSdoTdc_Crds < -1 AND p_Transacc = '0600' THEN -- Solo entre cuando venga de pago tdc
				IF vSdoTdc_Crds < -1 THEN -- Solo entre cuando venga de pago tdc

					SELECT count(num_credito) INTO nRows FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND tipo_contrato = '3' AND status = 2;
					IF nRows > 0 THEN	-- Existe credisolucion vigente relacionado a la TDC
				  
						SELECT max(fecha) INTO dFechaCreds FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND tipo_contrato = '3' AND status = 2;
						SELECT num_sol_prestamo INTO cNum_Credisol FROM bdicred:sd_promocion_credito WHERE num_credito = v_NumCredito AND fecha = dFechaCreds AND tipo_contrato = '3' AND status = 2;
						SELECT nvl(sdo_cap_insoluto,0) INTO dCap_Credisol FROM bdicred:sd_maesdoscrd WHERE num_credito = cNum_Credisol;
						
						IF dCap_Credisol > 1 THEN	-- Aun se tiene deuda del credito 6900 y no vuelva a entrar en la 2da ejecucion del principalrefer 	
							IF abs(vSdoTdc_Crds) < dCap_Credisol THEN	-- El saldo excedente es menor que el monto de la deuda total del credito 6900. El excedente solo cubre parte del monto de deuda 6900
								LET dMntoPagoCredis = abs(vSdoTdc_Crds);
							ELSE										-- Parte del excedente cubre la deuda total del credito 6900
								LET dMntoPagoCredis = dCap_Credisol;
							END IF;
							
							-- Elimina el pago previo para casos iterativos y asÃÂ­ no sume el monto de ambos pagos a cargar a la tdc.
							SELECT count(folio) INTO nRows FROM bdicred:"informix".sd_montopagcrd WHERE folio = p_Folio;
							IF nRows > 0 THEN
								DELETE bdicred:"informix".sd_montopagcrd WHERE folio = p_Folio;
								LET nRows = 0;
							END IF;

							--EXECUTE PROCEDURE bdicred:sp_cs_pago_anticipado(p_Empresa, cNum_Credisol, '6900', dMntoPagoCredis, 0, p_Usuario, p_Sucursal, p_Folio, '618')
							BEGIN WORK;
							EXECUTE PROCEDURE bdicred:sp_cs_pago_anticipado(p_Empresa, cNum_Credisol, '6900', dMntoPagoCredis, 0, p_Usuario, p_Sucursal, p_Folio, '8654')
							   INTO CodRet, Mensaje, cNumCredito_Crds, cCta_Eje_Crds, cProducto_Crds, cNum_Cte_Crds, cNom_Cte_Crds, dPago_Efec_Crds, dPago_Cta_Crds, 
									  dMonto_Op_Crds, dSaldo_Actual_Crds, cStatus_Actual_Crds, dFecha_ProxPago_Crds;
							IF CodRet::SMALLINT = 0 THEN
								-- Se actualiza remanente
								LET g_Remanente = g_Remanente;
								LET CodRet = "000";
							END IF;										
							
						END IF;
					END IF;  
					LET nRows = 0;
				END IF;    
				
           END IF
      END IF
	END IF;
/*
--jom ini
   else
	if p_MontoEfe > 0 THEN 
	        let CodRet = '399';
	ELSE
		let CodRet = '284';
	end if;
--jom fin
   END IF;
*/
   --Pago de TDC por Cheque
   IF p_MontoSBC > 0 THEN
   	--realiza la grabacion del Movimiento

      SELECT num_producto
        INTO g_NumProducto
        FROM "informix".sd_maecred
       WHERE empresa     = p_Empresa
         AND num_credito = v_NumCredito
		 AND status_cred      not in ('CV','FC','FF','FI')	
         AND (id_unidad_prod is null or id_unidad_prod <> 1);
		      
	 --2012-09-18 se valida que el credino no este marcado para venta en pago SBC.
	LET nrows = dbinfo("sqlca.sqlerrd2");
   IF (nrows = 0) THEN   
       LET CodRet = "008";     
    ELSE
	
		CALL "informix".Genmovref(
		p_Empresa,
		v_NumCredito,
		g_NumProducto,
		p_MontoSBC,
		p_Folio ,
		p_Sucursal,
        p_Tarjeta,
		p_referencia)

		RETURNing CodRet;
		
    END IF;          	
	
      
  	IF (CodRet <> "000") THEN
   	    SELECT descripcion
            INTO   Mensaje
       	    FROM   bdinteg:"informix".si_codret
       	    WHERE  sistema        = "06"
             AND   codigo_retorno = CodRet;
       	     ROLLBACK WORK;
       	     IF (wBegin = "S") THEN
                 BEGIN WORK;
       	     END IF;
        END IF
   END IF;

   RETURN CodRet, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob,
               g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
END PROCEDURE;