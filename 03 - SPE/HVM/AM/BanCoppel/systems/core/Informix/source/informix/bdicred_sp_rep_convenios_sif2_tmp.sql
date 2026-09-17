CREATE PROCEDURE "informix".sp_rep_convenios_sif2_tmp(pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE, pUsr CHAR(8), pProducto CHAR(4))
RETURNING CHAR(6)  AS codigo_retorno,
        CHAR(80) AS mensaje_retorno,
		CHAR(80) AS Nombre_archivo,
		CHAR(80) AS ruta;
		
---DECLARACIONES
DEFINE cCodRet        	CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cComentario      CHAR(80);
DEFINE iSqlErr      	  INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cNombreArchivo	  CHAR(80);
DEFINE iNumArchivo		  INTEGER;
DEFINE cTipoArchivo	    CHAR(80);
DEFINE cConsulta3		    CHAR(300);
DEFINE cSql		 		      CHAR(3000);
DEFINE cRuta		        CHAR(80);
DEFINE cTabla		        CHAR(1);
DEFINE dtFecha		      DATE;
DEFINE cFechaIni        CHAR(10);
DEFINE cFechaFin        CHAR(10);
DEFINE cSucursal        CHAR(4);
DEFINE iNumctes_vencido INTEGER;
DEFINE cNumcte          CHAR(20);
DEFINE dFecha_Reg       DATE;
DEFINE iRegistros       INTEGER;
DEFINE dFecha_ini       DATE;
DEFINE dFecha_fin       DATE;
DEFINE iCantidad        INTEGER;
DEFINE vPlaza       CHAR(40);
DEFINE vCiudad      CHAR(60);
DEFINE vSucursal    CHAR(4);
DEFINE vOrigen      CHAR(8);
DEFINE vTipoCompac  CHAR(1);
DEFINE vPlazo       CHAR(2);
DEFINE vImporte     DECIMAL(14,2);
DEFINE vImpPagado   DECIMAL(14,2);
DEFINE vCumplido    CHAR(11);
DEFINE vFechaCompac DATE;
DEFINE vFechaIns    DATE;
DEFINE dFecha_ini_2     DATE;
DEFINE dFecha_fin_2     DATE;
DEFINE dFecha_temp      DATE;
DEFINE dFecha_temp2     DATE; 
DEFINE vNumcuenta       CHAR(20); 
DEFINE cPagoProgramado  CHAR(1);
DEFINE iNumSesion       INTEGER;
DEFINE cArmaTabla       char(500);
DEFINE cValor           char(1);
DEFINE vFechaMov        DATE;
DEFINE cSuc             CHAR(10);
DEFINE v_count_emp      CHAR(10);
DEFINE cImporte         CHAR(20);
DEFINE cImpPagado       CHAR(20);
DEFINE cFechaCompac     CHAR(20);
DEFINE cFechaIns        CHAR(20);
DEFINE cPagoProgramado_2 CHAR(45);
DEFINE cUsuario         CHAR(8);
DEFINE vNumCuenta_2     LIKE sd_convs_detalle.numcuenta;
DEFINE vFecha_venc      DATE;


---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "PROCESO EXITOSO";
LET iNumArchivo			    = 0;
LET cNombreArchivo		  = "reporte_convenios_";
LET cTipoArchivo     	  = "";
LET cConsulta3			    = "";
LET cRuta				        = "";
LET cTabla				      = "N";
LET dtFecha				      = DATE(1);
LET cFechaIni           = ''; 
LET cFechaFin           = '';
LET cSucursal           = '';
LET iNumctes_vencido    = 0;
LET cNumcte             = '';
LET dFecha_Reg          = DATE(1);
LET iRegistros          = 0;
LET dFecha_ini          = DATE(1);
LET dFecha_fin          = DATE(1);
LET dFecha_temp         = DATE(1);
LET dFecha_temp2        = DATE(1);
LET iCantidad           = 0;

LET vPlaza              = '';
LET vCiudad             = '';
LET vSucursal           = '';
LET vOrigen             = '';
LET vTipoCompac         = '';
LET vPlazo              = '';
LET vImporte            = 0;
LET vImpPagado          = 0;
LET vCumplido           = '';
LET vFechaCompac        = DATE(1);
LET vFechaIns           = DATE(1);     
LET dFecha_ini_2        = DATE(1);
LET dFecha_fin_2        = DATE(1);
LET dFecha_temp         = DATE(1);
LET vNumcuenta          = '';
LET cPagoProgramado     = '';
LET iNumSesion          = 0;
LET cArmaTabla          = '';
LET cValor              = '';
LET cNumcte             = '';
LET vFechaMov           = DATE(1);
LET cSuc                = '';
LET v_count_emp         = '';
LET cImporte            = '';
LET cImpPagado          = '';
LET cFechaCompac        = '';
LET cFechaIns           = '';
LET cPagoProgramado_2   = '';
LET cUsuario            = '';
LET vFecha_venc         = date(1);

BEGIN

  ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      LET cCodRet= iSqlErr;
  	LET cMensajeRet = cErrorInfo;
      	
    	
      RETURN cCodRet, cMensajeRet,"", cRuta;
  END EXCEPTION;

  --SET DEBUG FILE TO '/tmp/mfinis/sp_rep_convenios_sif2_tmp.out';
  --TRACE ON;

  LET dFecha_ini = pFechaIni;
  LET dFecha_fin = pFechaFin;
  LET cUsuario   = pUsr;
  
  LET dFecha_temp = dFecha_ini + 1 UNITS MONTH;
  
  LET dFecha_ini_2 = mdy(month(dFecha_ini),1,year(dFecha_ini));  
  LET dFecha_fin_2 = mdy(month(dFecha_temp),1,year(dFecha_temp)) - 1 UNITS DAY;
  

	SELECT {+ INDEX (bdicobranza:cb_param_campania idx_cb_paramcampania_params1)} TRIM(valor_alfabetico) 
	  INTO cRuta
	  FROM bdicobranza:cb_param_campania
	 WHERE tipo_campania = 11  
	   AND  grupo_parametro = 'RUTAS'
	   AND num_parametro =1;

  IF NVL(pEmpresa,"") = "" OR  NVL(dFecha_ini,"") = "" OR  NVL(dFecha_fin,"") = "" OR pProducto = '' THEN
  	LET cCodRet= "000001";
  	LET cMensajeRet = "Parametro no valido para realizar la consulta";
  	RETURN cCodRet, cMensajeRet,"", cRuta;
  END IF;

		SELECT fecha_hoy  INTO dtFecha 
		  FROM bdicred:sd_fechas
		 WHERE empresa = pEmpresa;
		 
		 
    SELECT {+ INDEX (bdicobranza:cb_param_archivos idx_cb_param_archivos_numarch)} tipo_archivo
		  INTO  cTipoArchivo		
		  FROM  bdicobranza:"informix".cb_param_archivos 
		 WHERE num_archivo = 1;

	LET cNombreArchivo= TRIM(cNombreArchivo)|| LPAD(TRIM(DAY(dtFecha)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || YEAR(dtFecha) || '_' || (pProducto);

  LET cFechaIni = year(dFecha_ini) || '/' || lpad(month(dFecha_ini),2,0) || '/' || lpad(day(dFecha_ini),2,0);
  LET cFechaFin = year(dFecha_fin) || '/' || lpad(month(dFecha_fin),2,0) || '/' || lpad(day(dFecha_fin),2,0);

  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
  
   BEGIN;
      DELETE "informix".sd_convs_encabezados WHERE usuario = cUsuario;
   COMMIT;
   
   UPDATE statistics medium for table "informix".sd_convs_encabezados;
   
   BEGIN;
		DELETE "informix".sd_convs_detalle  WHERE  usuario = cUsuario;
   COMMIT;
	
 	INSERT INTO "informix".sd_convs_encabezados (numctes_con_vencido,numctes_convenios,plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario) 
	VALUES("NumCtes_Con_Venc", "NumCtes_convenios", "plaza","ciudad","sucursal","origen","tipo_compac","plazo","total","importe","importe pagado","cumplido","fecha_compac","fecha_vencimiento", "Pago_Programado",cUsuario);
      
     LET cConsulta3 = ' SELECT numctes_con_vencido,numctes_convenios,plaza,ciudad,sucursal,origen,tipo_compac,nvl(plazo,0),total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento, pago_programado ' ||
                       ' FROM "informix".sd_convs_encabezados ' || 
                       ' WHERE usuario = ' || "'" || cUsuario || "' order by plazo desc";
	
	IF pProducto = '6001' THEN 
            INSERT INTO "informix".sd_convs_detalle(empresa,numcuenta,plaza,ciudad,sucursal,origen,tipo_compac,plazo,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)                               
			SELECT 1,{+ INDEX  (bdicobranza:cb_compac_his idx_param)} cch.numcuenta, 
			DECODE(cch.origen,3,'CAT',sp.nombre) plaza, 
			DECODE(cch.origen,3,'CAT',sc.nombre) ciudad, 
			DECODE(cch.origen,3,'CAT',cch.sucursal) sucursal,
			DECODE(cch.origen,1,'TIENDA',2,'SUCURSAL',3,'CAT') origen, cch.tipo_compac, cch.plazo,
				cch.importe, CASE WHEN cch.imp_pagado > cch.importe THEN cch.importe ELSE cch.imp_pagado END imp_pagado
				, DECODE(cch.flag_pago,1,'CUMPLIDO','NO CUMPLIDO'), cch.fecha_compac, cch.fecha_insert, cch.pago_programado,cUsuario
			FROM bdicobranza:cb_compac_his cch 
					LEFT OUTER JOIN bdinteg:si_sucursales ss ON (cch.sucursal = ss.sucursal) 
					LEFT OUTER JOIN bdinteg:si_plazas sp ON (ss.plaza = sp.plaza) 
					LEFT OUTER JOIN bdinteg:si_ciudades sc ON (ss.pais = sc.pais AND ss.estado = sc.estado AND ss.ciudad = sc.ciudad)
					LEFT OUTER JOIN bdicred:"informix".sd_maecred cr  ON cr.num_credito = cch.numcuenta 
			WHERE cch.empresa= '001' 
				AND cch.fecha_insert BETWEEN dFecha_ini AND dFecha_fin
				AND cr.num_producto = pProducto;
		
			
		
	ELSE 	
			INSERT INTO "informix".sd_convs_detalle(empresa,numcuenta,plaza,ciudad,sucursal,origen,tipo_compac,plazo,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
			SELECT 1,cch.numcuenta, 
			DECODE(cch.origen,3,'CAT',sp.nombre) plaza, 
			DECODE(cch.origen,3,'CAT',sc.nombre) ciudad, 
			DECODE(cch.origen,3,'CAT',cch.sucursal) sucursal,
			DECODE(cch.origen,1,'TIENDA',2,'SUCURSAL',3,'CAT') origen, cch.tipo_compac, cch.plazo,
					cch.importe, CASE WHEN cch.imp_pagado > cch.importe THEN cch.importe ELSE cch.imp_pagado END imp_pagado, 
					DECODE(cch.flag_pago,1,'CUMPLIDO','NO CUMPLIDO'), 
					cch.fecha_compac, cch.fecha_insert, cch.pago_programado,cUsuario
			FROM bdicobranza:cb_compac_his cch 
				LEFT OUTER JOIN bdinteg:si_sucursales ss ON (cch.sucursal = ss.sucursal) 
				LEFT OUTER JOIN bdinteg:si_plazas sp ON (ss.plaza = sp.plaza) 
				LEFT OUTER JOIN bdinteg:si_ciudades sc ON (ss.pais = sc.pais AND ss.estado = sc.estado AND ss.ciudad = sc.ciudad)
				LEFT OUTER JOIN bdicred:"informix".sd_maecredcrd crd ON crd.num_credito = cch.numcuenta
			WHERE cch.empresa= '001' 
				AND cch.fecha_insert BETWEEN dFecha_ini AND dFecha_fin
				AND crd.num_producto = pProducto;
    END IF;
	
	UPDATE "informix".sd_convs_detalle SET
	cumplido='MISMO DIA'
	WHERE origen ='SUCURSAL' and 
	fecha_compac = fecha_vencimiento
	AND usuario = cUsuario;
  
	INSERT INTO "informix".sd_convs_encabezados(numctes_con_vencido,numctes_convenios,plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
	SELECT 0,0,plaza, ciudad, sucursal, origen, tipo_compac, plazo, COUNT(empresa), SUM(importe), SUM(importe_pagado), cumplido,
			   to_char(fecha_compac, '%d/%m/%Y'), to_char(fecha_vencimiento, '%d/%m/%Y'), case when pago_programado = 'S' then 'Intento Convenio Pago Programado' else '' end  pago_programado, cUsuario 
		  FROM "informix".sd_convs_detalle
		 WHERE fecha_vencimiento BETWEEN dFecha_ini AND dFecha_fin   
		   AND usuario = cUsuario
	group by plaza, ciudad, sucursal, origen, tipo_compac, plazo, cumplido, fecha_compac, fecha_vencimiento, pago_programado;
		
	DROP TABLE IF EXISTS bdicred: tme_sum_convenios_sif;	
	DROP TABLE IF EXISTS bdicred: tme_sum_convenios_sif2;	
	
	--UPDATE numctes_con_vencido 	
	SELECT DISTINCT(sucursal) sucursal,sum(numctes_vencido)  numctes_vencido
	from "informix".sd_vencidos_suc 
	where fecha_reg BETWEEN dFecha_ini AND dFecha_fin
	group by sucursal
	INTO TEMP tme_sum_convenios_sif WITH NO LOG;

	UPDATE "informix".sd_convs_encabezados enc SET 
	enc.numctes_con_vencido = (select numctes_vencido from tme_sum_convenios_sif tme where tme.sucursal=enc.sucursal)
	WHERE enc.sucursal >= '0000' and enc.sucursal <> 'sucursal'
	AND enc.usuario = cUsuario;	
   
   --UPDATE numctes_convenios
    select DISTINCT(sucursal) sucursal,sum(cantidad) cantidad  
	from "informix".sd_convenios_sucursal
	where fecha between dFecha_ini AND dFecha_fin
	group by sucursal
	INTO TEMP tme_sum_convenios_sif2 WITH NO LOG;

    UPDATE "informix".sd_convs_encabezados enc SET 
	enc.numctes_convenios = (select cantidad from tme_sum_convenios_sif2 tme where tme.sucursal=enc.sucursal)
	WHERE sucursal >= '0000' and enc.sucursal <> 'sucursal'
	AND enc.usuario = cUsuario;	
   
	LET cSql = '';
	
	LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||TRIM(cTipoArchivo)|| ' DELIMITER '|| '''	'''|| ' ' || trim(cConsulta3)||'" > '|| TRIM(cRuta) ||'query4.sql';
	
	SYSTEM trim(cSql);
	
	LET cSql = '';
	LET cSql = '/informix/bin/dbaccess bdicred ' ||trim(cRuta)||'query4.sql';
	SYSTEM trim(cSql);

	-- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
	LET cSql = '';
	LET cSQL = "rm " ||trim(cRuta)||'query4.sql';
	SYSTEM trim(cSql); 
	LET cSql = '';

	LET cNombreArchivo= trim(cNombreArchivo)||'.'||trim(cTipoArchivo);
    
    LET cSql = '';
    LET cSQL = "gzip -f " ||trim(cRuta)|| cNombreArchivo;
    SYSTEM trim(cSql);
    
    LET cNombreArchivo= trim(cNombreArchivo)||'.gz';
       
		RETURN cCodRet, cMensajeRet,cNombreArchivo , cRuta;
END
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 02/05/2016',
'DESCRIPCION:Se agrego el producto como parametro de entrada y que muestre la ruta al generar los reportes.',
'MODIFICACION: Martha Salgado Mendoza',
'FECHA: 01/08/2016',
'DESCRIPCION: Se modifico Delete de la tabla sd_convs_detalle para eliminar solo por usuario',
'BASE: dbicred ',
'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 03/08/2016',
'DESCRIPCION: Se modifico la direccion para que tenga acceso a la ruta especificada',
'AUTOR: Martha Salgado Mendoza',
'FECHA: 03/08/2016',
'DESCRIPCION: Se modifico update de la tabla sd_convs_detalle , se agrego el usuario',
'BASE: dbicred ',
'FECHA : 11/08/2016',
'AUTOR MODIFICACION: Guadalupe Angelica Hernandez Perez',
'Descripción: Se modifica el nombre del sql que se genera internamente';

CREATE PROCEDURE "informix".sp_traspasocuentas_cred2(pClienteTitular CHAR(20), pClienteTraspasaCtas CHAR(20), pUsuario CHAR(8)) 
RETURNING CHAR(5), CHAR(80);

--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INTEGER;
DEFINE vi_iSAMErr        INTEGER;
DEFINE vi_iSAMData        CHAR(80);
DEFINE vc_Mensaje       CHAR(80);
DEFINE vc_proceso       CHAR(50);
DEFINE vc_tabla         CHAR(30);
DEFINE vc_detalle_mov   CHAR(200);
DEFINE vc_detalle_mov2   CHAR(200);
DEFINE vi_MaxSec        INTEGER;
DEFINE iExiste      SMALLINT;

--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET vc_proceso = "FusionClientes";
LET vc_tabla = "";
LET vc_detalle_mov = "";
LET vc_detalle_mov2 = "";
LET vi_MaxSec = 0;
LET iExiste=0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            LET vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO bdinteg:"informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);
			
							
			 IF EXISTS(SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_si_refclienteTraspasaCtas')THEN
				DROP TABLE tmp_si_refclienteTraspasaCtas;
			END IF;
			
			 IF EXISTS(SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sirefdireccionesCliente')THEN
				DROP TABLE tmp_sirefdireccionesCliente;
			END IF;
			
            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

--SET DEBUG FILE TO "/home/sysifx/JesusBueno/sp_traspasocuentas_cred2.out";
--TRACE ON;

	 --**INICIA TRASPASO DE COBRANZA
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(num_credito) INTO iExiste FROM bdicobranza:cb_rep_cart_quebrantar WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN	
	
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT 'CART_QUEBRANTAR',"cb_rep_cart_quebrantar",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_rep_cart_quebrantar  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fusrep_cart_quebrantar (num_credito,numcte,apellido1,apellido2,nombre1,nombre2,fechanac,rfc,curp,sexo,edocivil,apellidocasada,nacionalidad,actividad,tipoidentificacion,numidentificacion,email,numestado,numciudad,poblacion,numcolonia,numcalle,numexterior,numinterior,codpostal,puntocardinal,manzana,andador,etapa,lote,edificio,entrada,departamento,complemento,entrecalles,antigdomic,telefono,otros,situacionesp,causasitesp,sector,lugartrabajo,antigtrab,puesto,ingresomensual,numestadotrab,numciudadtrab,poblaciontrab,numcoloniatrab,numcalletrab,numexteriortrab,numinteriortrab,codpostaltrab,puntocardinaltrab,manzanatrab,andadortrab,etapatrab,lotetrab,edificiotrab,entradatrab,departamentotrab,complementotrab,entrecallestrab,otrostrab,teltrab,exttrab,sucursal,fecha_ult_disp,monto_ult_disp,monto_comi_ult_disp,abono_mensual_al_qub,int_capit,iva_int_capit,sdo_mes_ant,sdo_actual,sdo_vencido,sdo_no_exig,fecha_ult_mov,tipo_ult_mov,monto_ult_mov,int_vencido,iva_int_vencido,int_mora_ordi,iva_int_mora_ordi,int_mora_cope,iva_int_mora_cope,meses_vencidos,numero_tarjeta,referenciacoppel,fechareporte)
	    SELECT num_credito,numcte,apellido1,apellido2,nombre1,nombre2,fechanac,rfc,curp,sexo,edocivil,apellidocasada,nacionalidad,actividad,tipoidentificacion,numidentificacion,email,numestado,numciudad,poblacion,numcolonia,numcalle,numexterior,numinterior,codpostal,puntocardinal,manzana,andador,etapa,lote,edificio,entrada,departamento,complemento,entrecalles,antigdomic,telefono,otros,situacionesp,causasitesp,sector,lugartrabajo,antigtrab,puesto,ingresomensual,numestadotrab,numciudadtrab,poblaciontrab,numcoloniatrab,numcalletrab,numexteriortrab,numinteriortrab,codpostaltrab,puntocardinaltrab,manzanatrab,andadortrab,etapatrab,lotetrab,edificiotrab,entradatrab,departamentotrab,complementotrab,entrecallestrab,otrostrab,teltrab,exttrab,sucursal,fecha_ult_disp,monto_ult_disp,monto_comi_ult_disp,abono_mensual_al_qub,int_capit,iva_int_capit,sdo_mes_ant,sdo_actual,sdo_vencido,sdo_no_exig,fecha_ult_mov,tipo_ult_mov,monto_ult_mov,int_vencido,iva_int_vencido,int_mora_ordi,iva_int_mora_ordi,int_mora_cope,iva_int_mora_cope,meses_vencidos,numero_tarjeta,referenciacoppel,fechareporte
		FROM bdicobranza:"informix".cb_rep_cart_quebrantar WHERE numcte=pClienteTraspasaCtas;

        UPDATE bdicobranza:"informix".cb_rep_cart_quebrantar SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;
    END IF;
    --**
	--***INICIA TRASPASO DE TABLA SS_SOLICITUDES_MC
    SET ISOLATION TO DIRTY READ; 
     SELECT {+INDEX (bdisolic:ss_solicitudes_mc idx_numcte2)} COUNT(num_solicitud) INTO iExiste FROM bdisolic:ss_solicitudes_mc WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
   
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdisolic:ss_solicitudes_mc idx_numcte2)}  'SOLICITUDES_MC',"ss_solicitudes_mc",pClienteTitular,pClienteTraspasaCtas,TRIM(num_solicitud)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdisolic:"informix".ss_solicitudes_mc  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fussolicitudes_mc  (empresa,num_solicitud,numcte,sucursal,num_producto,monto_solicitado,status_ini,status_fin,ejecutivo_atiende,ejecutivo_autoriza,observaciones,fecha_insert,hora_insert,fecha_determinacion,revisado,tipo_movimiento,motivo_os,revalua,ostel,tipo_alta) 
        SELECT {+INDEX (bdisolic:ss_solicitudes_mc idx_numcte2)} empresa,num_solicitud,numcte,sucursal,num_producto,monto_solicitado,status_ini,status_fin,ejecutivo_atiende,ejecutivo_autoriza,observaciones,fecha_insert,hora_insert,fecha_determinacion,revisado,tipo_movimiento,motivo_os,revalua,ostel,tipo_alta
		FROM bdisolic:"informix".ss_solicitudes_mc WHERE numcte=pClienteTraspasaCtas;

        UPDATE{+INDEX (bdisolic:ss_solicitudes_mc idx_numcte2)} bdisolic:"informix".ss_solicitudes_mc SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;
	
	END IF;
    
	--***INICIA TRASPASO DE TABLA SS_SOLICITUDES_SIC
    
    SET ISOLATION TO DIRTY READ; 
    SELECT {+INDEX (bdisolic:ss_solicitudes_sic idx_ss_solicitudes_sic_ctesol)}  COUNT(num_solicitud) INTO iExiste FROM bdisolic:ss_solicitudes_sic WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
			
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdisolic:ss_solicitudes_sic idx_ss_solicitudes_sic_ctesol)}  'SOLICITUDES_SIC',"ss_solicitudes_sic",pClienteTitular,pClienteTraspasaCtas,TRIM(num_solicitud)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdisolic:"informix".ss_solicitudes_sic  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fussolicitudes_sic (empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic) 
		SELECT {+INDEX (bdisolic:ss_solicitudes_sic idx_ss_solicitudes_sic_ctesol)} empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic
		FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdisolic:ss_solicitudes_sic idx_ss_solicitudes_sic_ctesol)} bdisolic:"informix".ss_solicitudes_sic SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;
 
    END IF;
    --***
    --***INICIA TRASPASO DE TABLA SS_SOLICITUDES_CAC
    SET ISOLATION TO DIRTY READ; 
       SELECT {+INDEX (bdisolic:ss_solicitudes_cac idx_numcte1)}  COUNT(num_solicitud) INTO iExiste FROM bdisolic:ss_solicitudes_cac WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
   	
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdisolic:ss_solicitudes_cac idx_numcte1)}  'SOLICITUDES_CAC',"ss_solicitudes_cac",pClienteTitular,pClienteTraspasaCtas,TRIM(num_solicitud)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdisolic:"informix".ss_solicitudes_cac  WHERE numcte= pClienteTraspasaCtas;
		
		INSERT INTO bdinteg:"informix".si_fussolicitudes_cac (empresa,num_solicitud,numcte,sucursal,num_producto,status,ejecutivo_atiende,ejecutivo_autoriza,comprobante_valido,observaciones,os,linea_determinada_sistema,fecha_insert,hora_insert,fecha_determinacion,ingreso_cac,compromisos_cac,comprobante_valido_cac,revisado)
		SELECT {+INDEX (bdisolic:ss_solicitudes_cac idx_numcte1)}  empresa,num_solicitud,numcte,sucursal,num_producto,status,ejecutivo_atiende,ejecutivo_autoriza,comprobante_valido,observaciones,os,linea_determinada_sistema,fecha_insert,hora_insert,fecha_determinacion,ingreso_cac,compromisos_cac,comprobante_valido_cac,revisado
		FROM bdisolic:"informix".ss_solicitudes_cac WHERE numcte=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdisolic:ss_solicitudes_cac idx_numcte1)}  bdisolic:"informix".ss_solicitudes_cac SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;

    END IF;
    
	--***INICIA TRASPASO DE TABLA
    SET ISOLATION TO DIRTY READ; 
    SELECT {+INDEX (bdicred: sd_camp_inactiv_nuncas inx3_inc_nun)} COUNT(num_credito) INTO iExiste FROM bdicred:sd_camp_inactiv_nuncas WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
			
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdicred: sd_camp_inactiv_nuncas inx3_inc_nun)}  'CAMPAÑAS INACTIVAS',"sd_camp_inactiv_nuncas",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM "informix".sd_camp_inactiv_nuncas  WHERE numcte= pClienteTraspasaCtas;
		
		INSERT INTO bdinteg:"informix".si_fuscamp_inactiv_nuncas (empresa,fecha_gen_campania,fecha_ejecucion,fecha_entreg_desde,fecha_entreg_hasta,tipo_campania,tipo_logica,num_sub_campania,grupo,num_credito,numcte,monto_otorgado,fecha_apertura,prioridad,status_cte,ap_paterno,ap_materno,primer_nombre,segundo_nombre,sexo,estado_civil,email,estado,ciudad,fecha_ultima_compra,fecha_ultimo_pago)
		SELECT {+INDEX (bdicred: sd_camp_inactiv_nuncas inx3_inc_nun)} empresa,fecha_gen_campania,fecha_ejecucion,fecha_entreg_desde,fecha_entreg_hasta,tipo_campania,tipo_logica,num_sub_campania,grupo,num_credito,numcte,monto_otorgado,fecha_apertura,prioridad,status_cte,ap_paterno,ap_materno,primer_nombre,segundo_nombre,sexo,estado_civil,email,estado,ciudad,fecha_ultima_compra,fecha_ultimo_pago
		FROM bdicred:"informix".sd_camp_inactiv_nuncas WHERE numcte=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdicred: sd_camp_inactiv_nuncas inx3_inc_nun)}  bdicred:"informix".sd_camp_inactiv_nuncas SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;

    END IF;

	--***INICIA TRASPASO DE TABLA CB_COMPAC
    SET ISOLATION TO DIRTY READ; 
  SELECT {+INDEX (bdicobranza:cb_compac idx_compac2)}  COUNT(numcuenta) INTO iExiste FROM bdicobranza:cb_compac WHERE empresa ='001' AND  numcliente=pClienteTraspasaCtas;
    IF iExiste>0 THEN
    
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdicobranza:cb_compac idx_compac2)}  'COMPAC COBRANZA',"cb_compac",pClienteTitular,pClienteTraspasaCtas,TRIM(numcuenta)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_compac  WHERE empresa ='001' AND  numcliente= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fuscompac (empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,imp_pagado,hora_insert, pago_programado,pago_minimo )
		SELECT {+INDEX (bdicobranza:cb_compac idx_compac2)} empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,imp_pagado,hora_insert, pago_programado,pago_minimo
		FROM bdicobranza:"informix".cb_compac WHERE empresa ='001' AND numcliente=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdicobranza:cb_compac idx_compac2)} bdicobranza:"informix".cb_compac SET numcliente = pClienteTitular where empresa ='001' AND  numcliente=pClienteTraspasaCtas;

    END IF;

	--***INICIA TRASPASO DE TABLA CB_COMPAC_HIS
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(numcuenta) INTO iExiste FROM bdicobranza:cb_compac_his WHERE numcliente=pClienteTraspasaCtas;
    IF iExiste>0 THEN
	
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT 'COMPAC COBRANZA HIS',"cb_compac_his",pClienteTitular,pClienteTraspasaCtas,TRIM(numcuenta)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_compac_his  WHERE numcliente= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fuscompac_his (empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,tipo_movto,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,imp_pagado,hora_insert, pago_programado,pago_minimo)
		SELECT empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,tipo_movto,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,imp_pagado,hora_insert, pago_programado,pago_minimo
		FROM bdicobranza:"informix".cb_compac_his WHERE  numcliente=pClienteTraspasaCtas;

        UPDATE bdicobranza:"informix".cb_compac_his SET numcliente = pClienteTitular where   numcliente=pClienteTraspasaCtas;

    END IF;
	
	--***INICIA TRASPASO DE TABLA CB_CAT_DIRECTORIO_CTE
    SET ISOLATION TO DIRTY READ; 
    SELECT {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_cte)}  COUNT(num_credito) INTO iExiste FROM bdicobranza:cb_cat_directorio_cte WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN
	
		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT  {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_cte)}  'DIRECTORIO COBRANZA',"cb_cat_directorio_cte",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_cat_directorio_cte  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fuscat_directorio_cte (empresa,tipo_cobranza,numcte,fecha_insert,num_credito,puntualidad,eficiencia,calificacion,pago_venc,prioridad,tipo_logica,keys,num_vuelta,usuario_insert,status_cliente,tipo_movto,fecha_modificacion,usuario_modifica,situacion,causa,pago_minimo,estado,ciudad,excepcion,saldo_total,apell_paterno,apell_materno,nombre1,nombre2,codigo_resultado,fecha_ultimo_contacto,intento_llamada,monto_vencido,moratorio,pagomin_total,fecha_ult_pago,pago_una_mora,num_pagos,monto_pagos,interes_iva,mto_venc_trasp)
        SELECT {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_cte)} empresa,tipo_cobranza,numcte,fecha_insert,num_credito,puntualidad,eficiencia,calificacion,pago_venc,prioridad,tipo_logica,keys,num_vuelta,usuario_insert,status_cliente,tipo_movto,fecha_modificacion,usuario_modifica,situacion,causa,pago_minimo,estado,ciudad,excepcion,saldo_total,apell_paterno,apell_materno,nombre1,nombre2,codigo_resultado,fecha_ultimo_contacto,intento_llamada,monto_vencido,moratorio,pagomin_total,fecha_ult_pago,pago_una_mora,num_pagos,monto_pagos,interes_iva,mto_venc_trasp
		FROM bdicobranza:"informix".cb_cat_directorio_cte WHERE numcte=pClienteTraspasaCtas;
		
        UPDATE {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio_cte)} bdicobranza:"informix".cb_cat_directorio_cte SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;

    END IF;
	--***
	--***INICIA TRASPASO DE TABLA CB_CAT_DIRECTORIO_CTE_HIST
    SET ISOLATION TO DIRTY READ; 
    SELECT COUNT(num_credito) INTO iExiste FROM bdicobranza:cb_cat_directorio_cte_his WHERE numcte=pClienteTraspasaCtas;
    IF iExiste>0 THEN

		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT 'DIRECTORIO COBRANZA HIS',"cb_cat_directorio_cte_his",pClienteTitular,pClienteTraspasaCtas,TRIM(num_credito)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_cat_directorio_cte_his  WHERE numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fuscat_directorio_cte_his (empresa,tipo_cobranza,numcte,fecha_insert,num_credito,puntualidad,eficiencia,calificacion,pago_venc,prioridad,tipo_logica,keys,num_vuelta,usuario_insert,status_cliente,tipo_movto,fecha_modificacion,usuario_modifica)
		SELECT empresa,tipo_cobranza,numcte,fecha_insert,num_credito,puntualidad,eficiencia,calificacion,pago_venc,prioridad,tipo_logica,keys,num_vuelta,usuario_insert,status_cliente,tipo_movto,fecha_modificacion,usuario_modifica
		FROM bdicobranza:"informix".cb_cat_directorio_cte_his WHERE numcte=pClienteTraspasaCtas;
		
        UPDATE bdicobranza:"informix".cb_cat_directorio_cte_his SET numcte = pClienteTitular where numcte=pClienteTraspasaCtas;

    END IF;
	
	--***INICIA TRASPASO DE TABLA CB_COMPAC_ERROR
    SET ISOLATION TO DIRTY READ; 
   SELECT {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} COUNT(numcuenta) INTO iExiste FROM bdicobranza:cb_compac_error WHERE numcliente=pClienteTraspasaCtas;
    IF iExiste>0 THEN

		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		SELECT {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} 'COMPAC COBRANZA ERROR',"cb_compac_error",pClienteTitular,pClienteTraspasaCtas,TRIM(numcuenta)||"|"||TRIM(pClienteTraspasaCtas),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdicobranza:"informix".cb_compac_error  WHERE  empresa ='001'  AND numcliente= pClienteTraspasaCtas;
		
		INSERT INTO bdinteg:"informix".si_fuscompac_error (empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,codigo_error,canal)
		SELECT {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} empresa,sucursal,origen,empleado_captura,numcliente,numcuenta,plazo,importe,tipo_compac,activo,flag_pago,efectuo_compac,nombre_efectuo,fecha_compac,fecha_insert,keyx,quien_convenio,nom_convenio,email,referenciacoppel,codigo_error,canal 
		FROM bdicobranza:"informix".cb_compac_error WHERE numcliente=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdicobranza:cb_compac_error idx_cb_compac_error)} bdicobranza:"informix".cb_compac_error SET numcliente = pClienteTitular where numcliente=pClienteTraspasaCtas;

    END IF;
	--***INICIA TRASPASO DE TABLA ADICOPPEL
    SET ISOLATION TO DIRTY READ; 
   SELECT {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel2)} COUNT(numcte) INTO iExiste FROM bdinteg:si_adiccoppel WHERE empresa ='001' AND numcte=pClienteTraspasaCtas;
	    IF iExiste>0 THEN

		INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
		-- BD -- SELECT  {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel)}  'ADICIONAL COPPEL',"si_adiccoppel",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(tipotar),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:"informix".si_adiccoppel   WHERE empresa='001' AND numcte= pClienteTraspasaCtas;
		SELECT 'ADICIONAL COPPEL',"si_adiccoppel",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(tipotar),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:"informix".si_adiccoppel   WHERE empresa='001' AND numcte= pClienteTraspasaCtas;
		
        INSERT INTO bdinteg:"informix".si_fusadiccoppel(empresa,numctecoppel,secuencia,sucursal,numtarcoppel,numcte,tipotar,status,parentesco,fechamov,user_insert)
	    SELECT {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel2)} empresa,numctecoppel,secuencia,sucursal,numtarcoppel,numcte,tipotar,status,parentesco,fechamov,user_insert
		FROM bdinteg:"informix".si_adiccoppel WHERE empresa='001' AND numcte=pClienteTraspasaCtas;

        UPDATE {+INDEX (bdinteg:si_adiccoppel idx_adiccoppel2)} bdinteg:"informix".si_adiccoppel SET numcte = pClienteTitular WHERE empresa ='001'  AND numcte=pClienteTraspasaCtas;
    
    END IF;
	
--***INICIA TRASPASO DE TABLA REFDIRECCIONES
	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(numcte) INTO iExiste FROM bdinteg:si_refdirecciones WHERE numcte=pClienteTraspasaCtas;

	IF iExiste > 0  THEN
			
			SELECT MAX(secuencia)  INTO vi_MaxSec FROM bdinteg:"informix".si_refdirecciones WHERE numcte=pClienteTitular;
			
			IF vi_MaxSec >0  THEN 
				
				CREATE TEMP TABLE tmp_sirefdireccionesCliente 
				  (
					posicion_secuencia serial,
					numcte CHAR(20) NOT NULL ,
					secuencia INTEGER ,
					tipo_dir CHAR(1),
					calle CHAR(40),
					colonia CHAR(60),
					entre_calles CHAR(40),
					pais CHAR(3),
					estado CHAR(2),
					ciudad CHAR(3),
					municipio CHAR(5),
					cod_postal CHAR(5),
					apart_postal CHAR(11),
					tipo_telef1 CHAR(1),
					telefono1 CHAR(13),
					tipo_telef2 CHAR(1),
					telefono2 CHAR(13),
					tipo_telef3 CHAR(1),
					telefono3 CHAR(13),
					extension CHAR(5),
					estado_inegi CHAR(2),
					municipio_inegi CHAR(3),
					localidad_inegi CHAR(4),
					numerociudad SMALLINT,
					numeroextcalle CHAR(10),
					numerointcalle CHAR(10),
					departamento CHAR(6),
					numerocalle INTEGER,
					numerocolonia INTEGER,
					puntocardinal CHAR(1),
					unidadhabitac CHAR(1),
					manzana SMALLINT,
					otros SMALLINT,
					andador SMALLINT,
					etapa SMALLINT,
					lote SMALLINT,
					edificio SMALLINT,
					entrada SMALLINT,
					observaciones CHAR(80),
					numcte_banco CHAR(20),
					user_insert CHAR(8),
					fecha_insert DATE,
					ind_cofeteltel1 CHAR(1) 
						DEFAULT 'F',
					ind_cofeteltel2 CHAR(1) 
						DEFAULT 'F',
					ind_cofeteltel3 CHAR(1) 
						DEFAULT 'F',
					movil_fijo1 CHAR(1) 
						DEFAULT '0',
					status_stel1 CHAR(1) 
						DEFAULT '',
					movil_fijo2 CHAR(1) 
						DEFAULT '0',
					status_stel2 CHAR(1) 
						DEFAULT '',
					movil_fijo3 CHAR(1) 
						DEFAULT '0',
					status_stel3 CHAR(1) 
						DEFAULT ''
				  );
				
				
				INSERT INTO tmp_sirefdireccionesCliente(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana	,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert	,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3)
				SELECT numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana	,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert	,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3
				FROM bdinteg:"informix".si_refdirecciones
				WHERE  numcte = pClienteTraspasaCtas;

				
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'REFERENCIAS DIRECCIONES',"si_refdirecciones",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(tipo_dir),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM tmp_sirefdireccionesCliente  WHERE numcte= pClienteTraspasaCtas;
				
				INSERT INTO bdinteg:"informix".si_fusrefdirecciones(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3)
				SELECT numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3
				FROM tmp_sirefdireccionesCliente
				WHERE numcte=pClienteTraspasaCtas;
				
				INSERT INTO bdinteg: si_refdirecciones (numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3)
				SELECT pClienteTitular,vi_MaxSec+posicion_secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3
				FROM tmp_sirefdireccionesCliente
				WHERE numcte=pClienteTraspasaCtas;
				
				DROP TABLE tmp_sirefdireccionesCliente;
				DELETE FROM bdinteg:"informix".si_refdirecciones WHERE numcte=pClienteTraspasaCtas;			
			
		ELSE 
			
				INSERT INTO bdinteg:"informix".si_fusrefdirecciones(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3)
									
				SELECT numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,tipo_telef1,telefono1,tipo_telef2,telefono2,tipo_telef3,telefono3,extension,estado_inegi,municipio_inegi,localidad_inegi,numerociudad,numeroextcalle,numerointcalle,departamento,numerocalle,numerocolonia,puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio,entrada,observaciones,numcte_banco,user_insert,fecha_insert,ind_cofeteltel1,ind_cofeteltel2,ind_cofeteltel3,movil_fijo1,status_stel1,movil_fijo2,status_stel2,movil_fijo3,status_stel3
				FROM  bdinteg:"informix".si_refdirecciones
				WHERE numcte=pClienteTraspasaCtas;

				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'REFERENCIAS DIRECCIONES',"si_refdirecciones",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas)||"|"||secuencia||"|"||TRIM(tipo_dir),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:"informix".si_refdirecciones  WHERE numcte= pClienteTraspasaCtas;
							
				UPDATE  bdinteg:"informix".si_refdirecciones SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
			END IF;	
 END IF;

--**********INICIA TRASPASO DE TABLA REFCLIENTES 
	
	SET ISOLATION TO DIRTY READ; 
	SELECT COUNT(numcte) INTO iExiste FROM bdinteg:si_refclientes WHERE numcte=pClienteTraspasaCtas;
		
	IF iExiste > 0 THEN 
						SELECT MAX(secuencia)  INTO vi_MaxSec FROM bdinteg:"informix".si_refclientes  WHERE numcte=pClienteTitular;
			IF vi_MaxSec> 0  THEN
				
				CREATE TEMP TABLE tmp_si_refclienteTraspasaCtas 
				  (	
					posicion_secuencia serial,
					empresa CHAR(3),
					num_solicitud CHAR(20) 
						DEFAULT '' NOT NULL ,
					numcte CHAR(20),
					sucursal CHAR(4),
					secuencia INTEGER ,
					apell_paterno CHAR(26),
					apell_materno CHAR(26),
					nombre1 CHAR(26),
					nombre2 CHAR(26),
					rfc CHAR(13),
					fecha_nac DATE,
					curp CHAR(20),
					sexo CHAR(1),
					estado_civil CHAR(2),
					nacionalidad CHAR(3),
					no_fm3 CHAR(18),
					codidentifi CHAR(2),
					numidentifi CHAR(30) 
						DEFAULT '',
					pers_domicilio CHAR(2),
					email CHAR(60),
					parentesco CHAR(2),
					apellido_cas CHAR(26),
					numcte_ref CHAR(20),
					numcte_banco CHAR(20),
					user_insert CHAR(8),
					fecha_insert DATE
				  );
				
				INSERT INTO tmp_si_refclienteTraspasaCtas (empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert)
				SELECT empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert
				FROM bdinteg:"informix".si_refclientes
				WHERE  numcte = pClienteTraspasaCtas;
				

				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'REFERENCIAS CLIENTES',"si_refclientes",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(num_solicitud),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM tmp_si_refclienteTraspasaCtas  WHERE numcte= pClienteTraspasaCtas;
				
				
				INSERT INTO bdinteg:si_fusrefclientes(empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert)
				SELECT empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert
				FROM tmp_si_refclienteTraspasaCtas
				WHERE numcte=pClienteTraspasaCtas;
				
				INSERT INTO bdinteg:"informix".si_refclientes (empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert)
				
				SELECT empresa,num_solicitud,pClienteTitular,sucursal,vi_MaxSec+posicion_secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert
				FROM tmp_si_refclienteTraspasaCtas
				WHERE numcte=pClienteTraspasaCtas;
				
				
				DROP TABLE tmp_si_refclienteTraspasaCtas;
				DELETE {+INDEX (bdinteg:si_refclientes idx_si_refclientes1)} FROM bdinteg:"informix".si_refclientes WHERE numcte=pClienteTraspasaCtas;
			
		ELSE 
			
				INSERT INTO bdinteg:si_fusrefclientes(empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert)
									
				SELECT empresa,num_solicitud,numcte,sucursal,secuencia,apell_paterno,apell_materno,nombre1,nombre2,rfc,fecha_nac,curp,sexo,estado_civil,nacionalidad,no_fm3,codidentifi,numidentifi,pers_domicilio,email,parentesco,apellido_cas,numcte_ref,numcte_banco,user_insert,fecha_insert
				FROM  bdinteg:si_refclientes
				WHERE numcte=pClienteTraspasaCtas;

				INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'REFERENCIAS CLIENTES',"si_refclientes",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||secuencia||"|"||TRIM(num_solicitud),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:si_refclientes  WHERE numcte= pClienteTraspasaCtas;
				
				UPDATE {+INDEX (bdinteg:si_refdirecciones idx_si_refdirecciones)} bdinteg:si_refclientes SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas;
		END IF;
	END IF;

	--******INICIA TRASPASO DE TABLA INGRESOS 
	SET ISOLATION TO DIRTY READ; 
	SELECT COUNT(numcte) INTO iExiste FROM bdinteg:si_ingresos WHERE numcte=pClienteTraspasaCtas;
	    IF iExiste>0 THEN
		SELECT COUNT(*) INTO iExiste FROM bdinteg:si_ingresos WHERE numcte=pClienteTitular;
			
			LET vc_tabla = "si_ingresos";
            LET vc_proceso='INGRESOS';
			
			INSERT INTO bdinteg:"informix".log_fusionclientes(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'INGRESOS',"si_ingresos",pClienteTitular,pClienteTraspasaCtas,trim(pClienteTraspasaCtas )||"|"||sec_ingreso||"|"||TRIM(tipo_ingreso),CURRENT HOUR TO FRACTION(3),pUsuario,CURRENT::DATE FROM bdinteg:"informix".si_ingresos   WHERE numcte= pClienteTraspasaCtas;
			
            INSERT INTO bdinteg:"informix".si_fusingresos (empresa,numcte,sec_ingreso,tipo_ingreso,nombre_empresa,puesto,puesto_esp,antiguedad,nombre_depto,jefe_inmediato,ingreso_mensual,user_insert,fecha_insert,clavepuesto,claveopcionpuesto,clavesubopcionpuesto,sis_cotiza,num_emp_lab,periosidad,tipo_ingreso_ext)
			SELECT {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} empresa,numcte,sec_ingreso,tipo_ingreso,nombre_empresa,puesto,puesto_esp,antiguedad,nombre_depto,jefe_inmediato,ingreso_mensual,user_insert,fecha_insert,clavepuesto,claveopcionpuesto,clavesubopcionpuesto,sis_cotiza,num_emp_lab,periosidad,tipo_ingreso_ext
			FROM bdinteg:"informix".si_ingresos WHERE numcte=pClienteTraspasaCtas;
				
			IF iExiste=0 THEN
					UPDATE {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} bdinteg:"informix".si_ingresos SET numcte = pClienteTitular WHERE numcte=pClienteTraspasaCtas ;
				ELSE
					DELETE {+INDEX (bdinteg:si_ingresos inx_ingresos_tipo1)} FROM bdinteg:"informix".si_ingresos WHERE numcte=pClienteTraspasaCtas;
			END IF;		
    END IF;	   
    IF vc_CodRet = "00000" THEN
		RETURN vc_CodRet, vc_Mensaje;
    END IF;
END;
END PROCEDURE
DOCUMENT
'Folio: 1447',
'Autor: 95347143 ',
'Fecha: 22/07/2014',
'Descripción: Optmizar sp sp_traspasocuentas_cred para reducir tiempos y costos de ejecución. Se secciono el sp, la segunda parte se llama',
'sp_traspasocuentas_cred2. Se eliminaron selec *, se eliminaron ciclos foreach (lo mas posible) y hacer uso de indices. ',
'Sustento: Analisis RQI64012 Optimizacion de proceso de fusion automatica.pdf',
'Solicita: Jose Angel Lopez Adams',
'BD: bdicred',
'----------------------------------------------',
'AUTOR: Rocio Karina Márquez Coronel',
'FECHA: 14/04/2015',
'DESCRIPCION: Se modificó estructuras de la fusión ya que se agregó un campo nuevo a la tabla cb_compac_his',
'SUSTENTO: RQI 64 081',
'SOLICITA: Jose Angel Lopez Adams',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_elimina_sd_prospectos()
RETURNING CHAR(6);

-- *********************************************************************
-- *                        DEFINICION DE VARIABLES                    *
-- *********************************************************************
DEFINE scod_ret         CHAR(6);
DEFINE vsqlerr          INTEGER;
DEFINE numcredito       CHAR(20);
DEFINE icontador        INTEGER;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret  = "000";
LET vsqlerr = 0;
LET numcredito="";
LET icontador=1;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "sp_elimina_sd_prospectos.out";
--TRACE ON;

  FOREACH WITH HOLD 

        SELECT num_credito
          INTO numcredito
	      FROM "informix".sd_prospectos 
		 WHERE num_producto = '6900'
		   AND num_promo = '7'		 

        IF icontador = 1 THEN
          BEGIN WORK;
        END IF;

        DELETE FROM "informix".sd_prospectos WHERE num_credito = numcredito AND num_producto = '6900' AND num_promo = '7';		
     
    IF icontador = 2000 then
        COMMIT WORK; 
        LET icontador = 1;
    ELSE
        LET icontador = icontador + 1;
    END IF;

  END FOREACH


  IF icontador > 1 THEN
        COMMIT WORK; 
  END IF;


  UPDATE statistics medium FOR TABLE "informix".sd_prospectos;


  RETURN scod_ret;
END
END PROCEDURE;