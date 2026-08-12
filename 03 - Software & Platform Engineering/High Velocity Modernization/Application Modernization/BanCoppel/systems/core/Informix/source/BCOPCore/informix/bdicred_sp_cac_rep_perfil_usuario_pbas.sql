CREATE PROCEDURE "informix".sp_cac_rep_perfil_usuario_pbas(pFechaIni CHAR (10), pFechaFin CHAR(10))
RETURNING CHAR(6)                         AS codigo_retorno,
          CHAR(80)                        AS mensaje_retorno,
		  CHAR(8)                         AS Numempleado,
		  CHAR(45)                        AS Nombre,
		  CHAR (25)                       AS Perfil_Puesto,
		  INTEGER                         AS Atendidas,
		  DECIMAL(18,2)                   AS PorcAtendidas,
		  INTEGER                         AS Canceladas,
		  DECIMAL(18,2)                   AS PorcCanceladas,
		  INTEGER                         AS Rechazadas,
		  DECIMAL(18,2)                   AS PorcRechazadas,
		  INTEGER                         AS Autorizadas,
		  DECIMAL(18,2)                   AS PorcAutorizadas,
		  
		  INTEGER                         AS TotalAtendidas,
		  DECIMAL(18,2)                   AS TotalPorcAtendidas,
		  INTEGER                         AS TotalCanceladas,
		  DECIMAL(18,2)                   AS TotalPorcCanceladas,
		  INTEGER                         AS TotalRechazadas,
		  DECIMAL(18,2)                   AS TotalPorcRechazadas,
		  INTEGER                         AS TotalAutorizadas,
		  DECIMAL(18,2)                   AS TotalPorcAutorizadas;

---DECLARACIONES   
DEFINE cCodRet              CHAR(6); 
DEFINE cMensajeRet          CHAR(80);
DEFINE iSqlErr      	    INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE dPorcAtendidas		DECIMAL(18,2);	
DEFINE dPorcCanceladas		DECIMAL(18,2);
DEFINE dPorcRechazadas		DECIMAL(18,2);
DEFINE dPorcAutorizados	    DECIMAL(18,2);
DEFINE cDescripcion 		CHAR(25);
DEFINE cNombre				CHAR(45);
DEFINE cBandera 			CHAR(1);
DEFINE iCanceladas			INTEGER;
DEFINE iAutorizadas	     	INTEGER;
DEFINE iRechazadas		    INTEGER;
DEFINE cEjecutivo           CHAR(8);
DEFINE cPuesto 				CHAR(2);
DEFINE cRangoAutorizacion	CHAR(2);
DEFINE iTotalReg 			INTEGER;
DEFINE iTotalPerfil			INTEGER;

DEFINE dTotalPorcAtendidas		DECIMAL(18,2);	
DEFINE dTotalPorcCanceladas		DECIMAL(18,2);
DEFINE dTotalPorcRechazadas		DECIMAL(18,2);
DEFINE dTotalPorcAutorizados	    DECIMAL(18,2);

DEFINE iTotalTotalPerfil			INTEGER;
DEFINE iTotalCanceladas			INTEGER;
DEFINE iTotalAutorizadas	     	INTEGER;
DEFINE iTotalRechazadas		    INTEGER;
---INICIALIZACIONES

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "Se realizó la consulta correctamente";
LET dPorcAtendidas		     = 0;
LET dPorcCanceladas		     = 0;
LET dPorcRechazadas		     = 0;
LET dPorcAutorizados	     = 0;
LET iCanceladas		     	 = 0;
LET iAutorizadas	     	 = 0;
LET iRechazadas		     	 = 0;
LET cEjecutivo				 = "";
LET cPuesto 				 = "";
LET cRangoAutorizacion		 = "";
LET iTotalReg				 = 0;
LET cDescripcion			 = "";
LET cNombre 				 = "";
LET cBandera				 = "";
LET iTotalPerfil			 = 0;

LET dTotalPorcAtendidas		     = 0;
LET dTotalPorcCanceladas		     = 0;
LET dTotalPorcRechazadas		     = 0;
LET dTotalPorcAutorizados	     = 0;

LET iTotalTotalPerfil			 = 0;
LET iTotalCanceladas		     	 = 0;
LET iTotalAutorizadas	     	 = 0;
LET iTotalRechazadas		     	 = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
    LET cCodRet= iSqlErr;
	LET cMensajeRet=cErrorInfo;	 
	
	
       RETURN cCodRet, cMensajeRet, NVL(cEjecutivo,' '), NVL(cNombre,' '), NVL(cDescripcion,' '), NVL(iTotalPerfil,0), NVL(dPorcAtendidas,0), NVL(iCanceladas,0), NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
		NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
   END IF;
END EXCEPTION;

	--set debug file to "/informix/jesus/sp_cac_rep_perfil_usuario.out";
	--trace on;

--se validan los parametros de entrada.
IF NVL(pFechaini,"") = "" OR NVL(pFechaFin,"")="" THEN
	LET cCodRet = "000001";
	LET cMensajeRet = "Falta un parámetro de fecha requerido para realizar  la consulta";
	RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
		NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
END IF;



SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
----se obtiene el total de registros de solicitudes atendidas.
	
		
	SELECT COUNT( b.num_solicitud) --total atendidas 
	INTO iTotalReg
	FROM  bdicred:"informix".sd_historica_cac_aumlincred h ,
	bdicred:"informix".sd_bitacora_aumlincred b			  
	WHERE  h.empresa = b.empresa 
	AND h.solicitud  = b.num_solicitud
	AND h.fecha_insert between  b.fecha_insert and b.fecha_status
	AND b.fecha_insert >= pFechaIni
	AND b.fecha_insert <= pFechaFin
	AND b.origen = "S";
	
	
	IF iTotalReg = 0 THEN
		LET cCodRet = "000003";
		LET cMensajeRet =  "No hay información con el rango de fechas solicitado";		
		RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
			NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
	END IF;	
	--Ciclo para obtener la cantidad de solicitudes atendidas por puesto y ejecutivo
	FOREACH WITH HOLD	
		SELECT h.puesto,h.ejecutivo,COUNT( b.num_solicitud), --total atendidas por usuario	
		SUM(CASE WHEN b.status='CM' THEN 1 ELSE 0 END),--Canceladas
		SUM(CASE WHEN b.status='RT' THEN 1 ELSE 0 END),--Rechazadas
		SUM(CASE WHEN b.status in ('AT','AP','IN') THEN 1 ELSE 0 END)--Autorizadas
		INTO cPuesto,cEjecutivo,iTotalPerfil,iCanceladas,iRechazadas,iAutorizadas
		FROM bdicred:"informix".sd_bitacora_aumlincred b, bdicred:"informix".sd_historica_cac_aumlincred h
		WHERE  h.empresa = b.empresa 
		AND h.solicitud  = b.num_solicitud
		AND h.fecha_insert between  b.fecha_insert and b.fecha_status
		AND b.fecha_insert >= pFechaIni
		AND b.fecha_insert <= pFechaFin
		AND b.origen = "S"
		GROUP BY h.puesto,h.ejecutivo
		ORDER BY h.puesto,h.ejecutivo
		
			
			LET dPorcCanceladas	=0;
			LET dPorcRechazadas	=0;
			LET dPorcAutorizados=0;
			LET dPorcAtendidas  =0;
			
			--Se obtiene el nombre del ejecutivo
			SELECT nombre
			INTO cNombre
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo=cEjecutivo;
			--Se obtiene la descripcion del puesto del ejecutivo
			SELECT descripcion_puesto
			INTO cDescripcion
			FROM bdicred:"informix".sd_puestos_cac_aumlincred
			WHERE puesto=cPuesto;
			
			--Calculo para obtener los porcentajes de las solicitudes atendidas,  canceladas, rechazadas y autorizadas. 
			IF NVL(iTotalPerfil,0) <> 0 THEN
			LET dPorcAtendidas = ((iTotalPerfil * 100) / iTotalReg);
			--Total
			LET iTotalTotalPerfil = iTotalTotalPerfil + iTotalPerfil;
			
			END IF;
			IF NVL(iCanceladas,0) <> 0 THEN
				LET dPorcCanceladas = ((iCanceladas * 100) / iTotalPerfil);
				--Total
				LET iTotalCanceladas = iTotalCanceladas + iCanceladas;
				
			END IF;
			IF NVL(iRechazadas,0) <> 0 THEN
				LET dPorcRechazadas	= ((iRechazadas * 100) / iTotalPerfil);
				--Total
				LET iTotalRechazadas = iTotalRechazadas + iRechazadas;
				
			END IF;
			IF NVL(iAutorizadas,0) <> 0 THEN
				LET dPorcAutorizados =((iAutorizadas * 100) / iTotalPerfil);
				--Total
				LET iTotalAutorizadas = iTotalAutorizadas + iAutorizadas;
				
			END IF;			
			
			
			LET dTotalPorcAtendidas = ((iTotalTotalPerfil * 100) / iTotalTotalPerfil); 
			LET dTotalPorcCanceladas = ((iTotalCanceladas * 100) / iTotalTotalPerfil);
			LET dTotalPorcRechazadas = ((iTotalRechazadas * 100) / iTotalTotalPerfil); 
			LET dTotalPorcAutorizados = ((iTotalAutorizadas * 100) / iTotalTotalPerfil);
			
			RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
				NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0) WITH RESUME;
		
	END FOREACH;	
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros para el reporte por perfil de usuario en un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111021.0902',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificación: Se agregan los totales de las atendidas, autorizadas, canceladas y rechazadas',
'Fecha de modificación: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_rep_convenios_sif_pba(pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE, pUsr CHAR(8))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
		      CHAR(80) AS Nombre_archivo; 
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


BEGIN

  ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
      LET cCodRet= iSqlErr;
  	LET cMensajeRet = cErrorInfo;
      	
    	
      RETURN cCodRet, cMensajeRet,"";
  END EXCEPTION;

  --SET DEBUG FILE TO '/informix/macf/sp_rep_convenios_sif.trc';
  --TRACE ON;

  LET dFecha_ini = pFechaIni;
  LET dFecha_fin = pFechaFin;
  LET cUsuario   = pUsr;
  
  LET dFecha_temp = dFecha_ini + 1 UNITS MONTH;
  
  LET dFecha_ini_2 = mdy(month(dFecha_ini),1,year(dFecha_ini));  
  LET dFecha_fin_2 = mdy(month(dFecha_temp),1,year(dFecha_temp)) - 1 UNITS DAY;
  

	---SELECT {+ INDEX (bdicobranza:cb_param_campania idx_cb_paramcampania_params1)} TRIM(valor_alfabetico) 
	SELECT TRIM(valor_alfabetico) 
	  INTO cRuta
	  FROM bdicobranza:cb_param_campania
	 WHERE tipo_campania = 11  
	   AND  grupo_parametro = 'RUTAS'
	   AND num_parametro =1;

  IF NVL(pEmpresa,"") = "" OR  NVL(dFecha_ini,"") = "" OR  NVL(dFecha_fin,"") = "" THEN
  	LET cCodRet= "000001";
  	LET cMensajeRet = "Parametro no valido para realizar la consulta";
  	RETURN cCodRet, cMensajeRet,"";
  END IF;

		SELECT fecha_hoy  INTO dtFecha 
		  FROM bdicred:sd_fechas
		 WHERE empresa = pEmpresa;
		 
		 
    ---SELECT {+ INDEX (bdicobranza:cb_param_archivos idx_cb_param_archivos_numarch)} tipo_archivo
    SELECT tipo_archivo
		  INTO  cTipoArchivo		
		  FROM  bdicobranza:"informix".cb_param_archivos 
		 WHERE num_archivo = 1;

	LET cNombreArchivo= TRIM(cNombreArchivo)|| LPAD(TRIM(DAY(dtFecha)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || YEAR(dtFecha);

  LET cFechaIni = year(dFecha_ini) || '/' || lpad(month(dFecha_ini),2,0) || '/' || lpad(day(dFecha_ini),2,0);
  LET cFechaFin = year(dFecha_fin) || '/' || lpad(month(dFecha_fin),2,0) || '/' || lpad(day(dFecha_fin),2,0);

  SET ISOLATION TO DIRTY READ;
  SET LOCK MODE TO WAIT 3;
  
   BEGIN;
      DELETE "informix".sd_convs_encabezados WHERE usuario = cUsuario;
   COMMIT;
   UPDATE statistics medium for table "informix".sd_convs_encabezados;
   
   BEGIN;
      DELETE "informix".sd_convs_detalle WHERE usuario = cUsuario;
   COMMIT;
   UPDATE statistics medium for table "informix".sd_convs_detalle;
    
			--INSERT INTO "informix".tme_encabezados (numctes_con_vencido,numctes_convenios,plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado) 
			--VALUES("NumCtes_Con_Venc", "NumCtes_convenios", "plaza","ciudad","sucursal","origen","tipo_compac","plazo","total","importe","importe pagado","cumplido","fecha_compac","fecha_vencimiento", "Pago_Programado");
			INSERT INTO "informix".sd_convs_encabezados (numctes_con_vencido,numctes_convenios,plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario) 
			VALUES("NumCtes_Con_Venc", "NumCtes_convenios", "plaza","ciudad","sucursal","origen","tipo_compac","plazo","total","importe","importe pagado","cumplido","fecha_compac","fecha_vencimiento", "Pago_Programado",cUsuario);
      
      LET cConsulta3 = ' SELECT numctes_con_vencido,numctes_convenios,plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento, pago_programado ' ||
                       ' FROM "informix".sd_convs_encabezados ' || 
                       ' WHERE usuario = ' || cUsuario ;

    FOREACH WITH HOLD
        SELECT {+INDEX(bdicobranza:cb_compac_his idx_compachisfi)} cch.numcuenta, sp.nombre plaza, sc.nombre ciudad, cch.sucursal, DECODE(cch.origen,1,'TIENDA',2,'SUCURSAL',3,'CAT') origen, cch.tipo_compac, cch.plazo,
         cch.importe, CASE WHEN cch.imp_pagado > cch.importe THEN cch.importe ELSE cch.imp_pagado END imp_pagado, 
         DECODE(cch.flag_pago,1,'CUMPLIDO','NO CUMPLIDO'), 
          cch.fecha_compac, cch.fecha_insert, cch.pago_programado
        INTO vNumcuenta, vPlaza, vCiudad, vSucursal, vOrigen, vTipoCompac, vPlazo, vImporte, vImpPagado, vCumplido, vFechaCompac, vFechaIns, cPagoProgramado
        FROM bdicobranza:cb_compac_his cch LEFT OUTER JOIN bdinteg:si_sucursales ss ON (cch.sucursal = ss.sucursal) 
                                       LEFT OUTER JOIN bdinteg:si_plazas sp ON (ss.plaza = sp.plaza and sp.empresa = '001')
                                       LEFT OUTER JOIN bdinteg:si_ciudades sc ON (ss.pais = sc.pais AND ss.estado = sc.estado AND ss.ciudad = sc.ciudad)
       WHERE cch.empresa= '001' 
         --AND cch.origen IN (1,2) 
         AND cch.fecha_insert BETWEEN dFecha_ini AND dFecha_fin  
       
        IF vOrigen = 'SUCURSAL' THEN
          IF vFechaCompac = vFechaIns THEN 
            BEGIN;
              INSERT INTO "informix".sd_convs_detalle(empresa,numcuenta,plaza,ciudad,sucursal,origen,tipo_compac,plazo,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
              VALUES(1,vNumcuenta,vPlaza, vCiudad, vSucursal, vOrigen, vTipoCompac, vPlazo, vImporte, vImpPagado, 'MISMO DIA', vFechaCompac, vFechaIns,cPagoProgramado,cUsuario);
            COMMIT;
          ELSE
            BEGIN; 
                INSERT INTO "informix".sd_convs_detalle(empresa,numcuenta,plaza,ciudad,sucursal,origen,tipo_compac,plazo,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
             VALUES(1,vNumcuenta,vPlaza, vCiudad, vSucursal, vOrigen, vTipoCompac, vPlazo, vImporte, vImpPagado, vCumplido, vFechaCompac, vFechaIns,cPagoProgramado,cUsuario);
            COMMIT;
          END IF
        ELIF vOrigen = 'TIENDA' THEN
            BEGIN;
              INSERT INTO "informix".sd_convs_detalle(empresa,numcuenta,plaza,ciudad,sucursal,origen,tipo_compac,plazo,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
             VALUES(1,vNumcuenta,vPlaza, vCiudad, vSucursal, vOrigen, vTipoCompac, vPlazo, vImporte, vImpPagado, vCumplido, vFechaCompac, vFechaIns,cPagoProgramado,cUsuario);
            COMMIT;
        ELSE
            BEGIN;
              INSERT INTO "informix".sd_convs_detalle(empresa,plaza,ciudad,sucursal,origen,tipo_compac,plazo,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
              VALUES(1,'CAT', 'CAT', 'CAT', vOrigen, vTipoCompac, vPlazo, vImporte, vImpPagado, vCumplido, vFechaCompac, vFechaIns, cPagoProgramado,cUsuario);
            COMMIT; 
        END IF;    
    END FOREACH;
  

  FOREACH WITH HOLD
  
    SELECT plaza, ciudad, sucursal, origen, tipo_compac, plazo, COUNT(empresa), SUM(importe), SUM(importe_pagado), cumplido,
           to_char(fecha_compac, '%d/%m/%Y'), to_char(fecha_vencimiento, '%d/%m/%Y'), case when pago_programado = 'S' then 'Intento Convenio Pago Programado' else '' end  pago_programado  
      INTO  vPlaza, vCiudad, cSuc, vOrigen, vTipoCompac, vPlazo, v_count_emp, cImporte, cImpPagado, vCumplido, cFechaCompac, cFechaIns, cPagoProgramado_2
      FROM "informix".sd_convs_detalle
     WHERE fecha_vencimiento BETWEEN dFecha_ini AND dFecha_fin   
       AND usuario = cUsuario
     group by plaza, ciudad, sucursal, origen, tipo_compac, plazo, cumplido, fecha_compac, fecha_vencimiento, pago_programado
     
     BEGIN;
        INSERT INTO "informix".sd_convs_encabezados(numctes_con_vencido,numctes_convenios,plaza,ciudad,sucursal,origen,tipo_compac,plazo,total,importe,importe_pagado,cumplido,fecha_compac,fecha_vencimiento,pago_programado,usuario)
        VALUES(0,0,vPlaza, vCiudad, cSuc, vOrigen, vTipoCompac, vPlazo, v_count_emp, cImporte, cImpPagado, vCumplido, cFechaCompac, cFechaIns, cPagoProgramado_2,cUsuario);
     COMMIT; 
  END FOREACH;    
    

      FOREACH WITH HOLD        
     
          select trim(sucursal) into cSucursal
            from "informix".sd_convs_encabezados
             where sucursal >= '0000'
             and   usuario = cUsuario
             group by 1
      
          SELECT sum(numctes_vencido) into iNumctes_vencido 
           from "informix".sd_vencidos_suc 
          where fecha_reg BETWEEN dFecha_ini AND dFecha_fin
            and sucursal = cSucursal 
          group by sucursal;

          select sum(cantidad) into iCantidad  
            from "informix".sd_convenios_sucursal
            where fecha between dFecha_ini AND dFecha_fin
             and sucursal = cSucursal  
            group by sucursal;
          
           BEGIN;
                UPDATE "informix".sd_convs_encabezados SET numctes_con_vencido = iNumctes_vencido, numctes_convenios = iCantidad WHERE sucursal = cSucursal and usuario = cUsuario;
           COMMIT;   
      
      END FOREACH;
   
			LET cSql = '';
			--LET cSql = 'echo "UNLOAD TO ' ||trim(cRuta)||trim(cNombreArchivo)||'.'||'unl'|| ' '||trim(cConsulta3)||'" > '|| trim(cRuta) ||'query1.sql';
			LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||TRIM(cTipoArchivo)|| ' DELIMITER '|| '''	'''|| ' ' || trim(cConsulta3)||'" > '|| TRIM(cRuta) ||'query1.sql';
			-- LET cSql = 'echo "UNLOAD TO ' ||trim(cRuta)||trim(cNombreArchivo)||'.'||cTipoArchivo|| ' '||trim(cConsulta3)||'" > '|| trim(cRuta) ||'query1.sql';  (probado que funciona) 
			SYSTEM trim(cSql);
			
			LET cSql = '';
			LET cSql = "dbaccess bdicred " ||trim(cRuta)||'query1.sql';
			SYSTEM trim(cSql);
   	
			-- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
			LET cSql = '';
			LET cSQL = "rm " ||trim(cRuta)||'query1.sql';
			SYSTEM trim(cSql); 
			LET cSql = '';
			--LET cSQL = "rm " ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||'unl';		
			--SYSTEM cSql; 		

		LET cNombreArchivo= trim(cNombreArchivo)||'.'||trim(cTipoArchivo);
    
    LET cSql = '';
    LET cSQL = "gzip -f " ||trim(cRuta)|| cNombreArchivo;
    SYSTEM trim(cSql);
    
    LET cNombreArchivo= trim(cNombreArchivo)||'.gz';
    
    --begin; UPDATE "informix".sd_param SET valor = 'N' WHERE cod_param = 'RPC'; commit;
    --update statistics medium for table "informix".sd_param;
       
		RETURN cCodRet, cMensajeRet,cNombreArchivo;
END
END PROCEDURE
 
;