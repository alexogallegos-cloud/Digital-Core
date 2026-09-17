CREATE PROCEDURE "informix".sp_pm_sdovenc_mensual(pEmpresa CHAR(3), pFechaIni DATE, pFechaFin DATE, pTipoEjec CHAR(1))
RETURNING CHAR(5)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno,
          CHAR(80) AS nombre_archivo;

---DECLARACIONES
DEFINE cCodRet        	   CHAR(5); 
DEFINE cMensajeRet         CHAR(80);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr            INTEGER;
DEFINE cErrorInfo          CHAR(80);

DEFINE cRuta		           CHAR(80);
DEFINE cNombreArchivo	     CHAR(80);
DEFINE vEmpresa            CHAR(3);
DEFINE vSucursal           CHAR(4); 
DEFINE vUsuario            CHAR(8);
DEFINE cConsulta		    CHAR(1000);
DEFINE cSql		 		      CHAR(2000);

DEFINE dtFecha		         DATE;
DEFINE dtFechaIni          DATE;
DEFINE dtFechaFin          DATE;
DEFINE vfecha_insert	     DATE;
DEFINE vcant_a_recup_pm    INTEGER;
DEFINE vcant_recup_pm      INTEGER;
DEFINE vPct_PM_Recup       DECIMAL(10,2);  
DEFINE vcount_con_pagomin  INTEGER;
DEFINE vcount_sin_pagomin  INTEGER; 
DEFINE vPct_cumpl_PM       DECIMAL(10,2);
DEFINE vcant_a_recup_sv    INTEGER;     
DEFINE vcant_recup_sv      INTEGER;
DEFINE vPct_SV_Recup			 DECIMAL(10,2); 
DEFINE vcount_con_sv       INTEGER;
DEFINE vcount_sin_sv       INTEGER; 
DEFINE vPct_cumpl_SV       DECIMAL(10,2);
DEFINE d_cant_a_recup_pm   DECIMAL(14,2);  
DEFINE d_cant_recup_pm     DECIMAL(14,2);
DEFINE d_cant_a_recup_sv   DECIMAL(14,2);
DEFINE d_cant_recup_sv     DECIMAL(14,2);
DEFINE vPct_Cump_Recup_Cartera       DECIMAL(10,2);
DEFINE vPct_PM_Recup_total DECIMAL(10,2);                 
DEFINE vPct_SV_Recup_total DECIMAL(10,2);
DEFINE vNumPagosMinOk      INTEGER;
DEFINE vNumPagosMinNok     INTEGER;
DEFINE vNumPagosVencOk     INTEGER;
DEFINE vNumPagosVencNok    INTEGER;
DEFINE cProceso            CHAR(4);
DEFINE vvcCod_ret          CHAR(6);
DEFINE dtFechaPrimerDia    DATE;
DEFINE dtFechaUltDiaMesAnt DATE;
DEFINE cNombreArchivo_2    CHAR(80);

---INICIALIZACIONES
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";
LET cCodRet              = "00000";
LET cMensajeRet          = "PROCESO EXITOSO";
LET vEmpresa             = '';
LET vSucursal            = ''; 
LET vUsuario             = '';
LET cRuta			 	         = "";
LET dtFecha				       = DATE(1);
LET dtFechaIni           = DATE(1);
LET dtFechaFin           = DATE(1);
LET vfecha_insert        = DATE(1);	    
LET vcant_a_recup_pm     = 0;
LET vcant_recup_pm       = 0;
LET vPct_PM_Recup        = 0;
LET vcount_con_pagomin   = 0;
LET vcount_sin_pagomin   = 0;
LET vPct_cumpl_PM        = 0;
LET vcant_a_recup_sv     = 0;
LET vcant_recup_sv       = 0;
LET vPct_SV_Recup			   = 0;
LET vcount_con_sv        = 0; 
LET vcount_sin_sv        = 0;
LET vPct_cumpl_SV        = 0;
LET d_cant_a_recup_pm    = 0;
LET d_cant_recup_pm      = 0;
LET d_cant_a_recup_sv    = 0;
LET d_cant_recup_sv      = 0;
LET vPct_Cump_Recup_Cartera = 0;
LET vPct_PM_Recup_total  = 0;                 
LET vPct_SV_Recup_total  = 0;
LET vNumPagosMinOk       = 0;
LET vNumPagosMinNok      = 0;
LET vNumPagosVencOk      = 0;
LET vNumPagosVencNok     = 0;
LET cProceso             = '0042';
LET vvcCod_ret           = '';
LET cNombreArchivo		  = 'Reporte_PagoMin_Cajero_';
LET cConsulta            = '';
LET cSql                 = '';
LET dtFechaPrimerDia     = DATE(1);
LET dtFechaUltDiaMesAnt  = DATE(1);
LET cNombreArchivo_2	   = 'Reporte_PagoMin_Suc_';

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet= iSqlErr;
    	  LET cMensajeRet = cErrorInfo;
    	  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '02')
          RETURNING vvcCod_ret;
        
        RETURN cCodRet, cMensajeRet,"";
    END EXCEPTION;

  --SET DEBUG FILE TO '/informix/macf/sp_pagomin_sdovenc_cajero.trc';
  --TRACE ON;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '01') RETURNING vvcCod_ret;

    IF NVL(pEmpresa,"") = "" THEN
       LET cCodRet= "00001";
       LET cMensajeRet = "Parametro no valido para realizar la consulta";
       RETURN cCodRet, cMensajeRet, "";
    END IF;
    
    SELECT fecha_hoy, pri_dia_mes   
		  INTO dtFecha, dtFechaPrimerDia 
		  FROM bdicred:sd_fechas
		 WHERE empresa = pEmpresa;


    IF pTipoEjec = 'A' THEN
      LET dtFechaUltDiaMesAnt = dtFechaPrimerDia - 1 UNITS day; 
      LET dtFechaIni =  mdy(month(dtFechaUltDiaMesAnt),1,year(dtFechaUltDiaMesAnt));
      LET dtFechaFin  = dtFechaUltDiaMesAnt;
    ELSE
      IF NVL(pFechaIni,"") = "" OR  NVL(pFechaFin,"") = "" THEN
      	LET cCodRet= "00001";
      	LET cMensajeRet = "Parametro no valido para realizar la consulta";
      	RETURN cCodRet, cMensajeRet, "";
      ELSE
        LET dtFechaIni  = pFechaIni;
        LET dtFechaFin  = pFechaFin;
      END IF;
      
    END IF;
         
    
    --se obtiene la ruta donde se almacenara el archivo generado.
    SELECT  TRIM(valor_alfabetico) 
    	INTO cRuta
    	FROM bdicobranza:"informix".cb_param_campania
    	WHERE tipo_campania = 11  
    	AND  grupo_parametro = 'RUTAS'
    	AND num_parametro =1;
	
    IF NVL(cRuta,"") = "" THEN
    	LET cCodRet= "00002";
    	LET cMensajeRet = "No se pudo obtener la ruta donde se almacenara el archivo";
    	RETURN cCodRet, cMensajeRet, "";
    END IF;	
		
		truncate "informix".sd_pmsv_validapagos;
    truncate "informix".sd_rep_pagos_pmsv_ctrlfinanc;  
    truncate "informix".sd_rep_pmsv_ctrlfinanc;
    
   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
         
        SELECT a.empresa, a.sucursal, a.fecha_insert, a.usuario, 
               case when a.pago_min > 0 then 1 else 0 end as num_pagos_min_ok,
               case when a.pago_min > 0 then case when pago_realizado >= pago_min then 1 else 0 end else 0 end num_pagos_min_nok,

               case when a.saldo_vencido > 0 then 1 else 0 end as num_pagos_venc_ok, 
               case when a.saldo_vencido > 0 then ( case when a.pago_realizado >= a.saldo_vencido then 1 else  0 end) else 0 end num_pagos_venc_nok
        INTO vEmpresa, vSucursal, vfecha_insert, vUsuario, vNumPagosMinOk, vNumPagosMinNok, vNumPagosVencOk, vNumPagosVencNok 
        from bdicobranza:cb_evaluacion_objetiva_his a
        WHERE a.fecha_insert >= dtFechaIni and fecha_insert <= dtFechaFin
          AND a.reversado = 'N'
          AND a.pago_min > 0
       
        
        begin;
          INSERT INTO "informix".sd_pmsv_validapagos(empresa, sucursal, fecha, usuario, num_pagos_min_ok, num_pagos_min_nok, num_pagos_venc_ok, num_pagos_venc_nok)
          VALUES(vEmpresa, vSucursal, vfecha_insert, vUsuario, vNumPagosMinOk, vNumPagosMinNok,vNumPagosVencOk,vNumPagosVencNok);
        commit;
      
        LET vSucursal = ''; LET vfecha_insert = '01/01/1900'; LET vUsuario = ''; LET vNumPagosMinOk = 0; LET vNumPagosMinNok = 0; LET vNumPagosVencOk = 0; LET vNumPagosVencNok = 0;
      
    END FOREACH;    
    
 
    FOREACH with hold
        SELECT sucursal, fecha_insert, usuario, pago_min,
               case when pago_min > 0 then pago_realizado else 0 end,
               pct_cump_pm,
               saldo_vencido,
               case when saldo_vencido > 0 then pago_realizado else 0 end,
               pct_cump_sv
          INTO vSucursal, vfecha_insert, vUsuario, d_cant_a_recup_pm, d_cant_recup_pm, vPct_PM_Recup, d_cant_a_recup_sv,  d_cant_recup_sv, vPct_SV_Recup
          FROM bdicobranza:cb_evaluacion_objetiva_his
         WHERE fecha_insert >= dtFechaIni 
           AND fecha_insert <= dtFechaFin
           AND reversado = 'N'
           AND pago_min > 0
           
           begin;
             INSERT INTO "informix".sd_rep_pagos_pmsv_ctrlfinanc(sucursal, fecha_insert, usuario, cant_a_recup_pm, cant_recup_pm, pct_pm_recup, cant_a_recup_sv, cant_recup_sv, pct_sv_recup )
              VALUES(vSucursal, vfecha_insert, vUsuario, d_cant_a_recup_pm, d_cant_recup_pm, vPct_PM_Recup, d_cant_a_recup_sv, d_cant_recup_sv, vPct_SV_Recup);
           commit;
           
    END FOREACH;
     
    FOREACH with hold
    
         SELECT sucursal, fecha_insert, usuario, 
                round(sum(cant_a_recup_pm),2), 
                round(sum(cant_recup_pm),2), 
                round(sum(Pct_PM_Recup),2),
                round(sum(cant_a_recup_sv),2), 
                round(sum(cant_recup_sv),2), 
                round(sum(Pct_SV_Recup),2)
           INTO vSucursal, vfecha_insert, vUsuario, 
                d_cant_a_recup_pm, 
                d_cant_recup_pm, 
                vPct_PM_Recup, 
                d_cant_a_recup_sv, 
                d_cant_recup_sv, 
                vPct_SV_Recup
           FROM "informix".sd_rep_pagos_pmsv_ctrlfinanc
           WHERE fecha_insert >= dtFechaIni 
             AND fecha_insert <= dtFechaFin
           GROUP BY 1,2,3
           
         SELECT sum(num_pagos_min_ok), 
                sum(num_pagos_min_nok),
                case when (round( (sum(num_pagos_min_nok) / sum(num_pagos_min_ok)* 100),2)) > 100 then 100 else (round( (sum(num_pagos_min_nok) /sum(num_pagos_min_ok)* 100),2)) end Pct_cumpl_PM,

                sum(num_pagos_venc_ok), 
                sum(num_pagos_venc_nok),
                --case when (round( (sum(num_pagos_venc_nok) / sum(num_pagos_venc_ok)* 100),2)) > 100 then 100 else (round( (sum(num_pagos_venc_nok) / sum(num_pagos_venc_ok)* 100),2)) end Pct_cumpl_SV
                case when sum(num_pagos_venc_ok) = 0 then 0 else 
                                                                  case when (round( (sum(num_pagos_venc_nok) / sum(num_pagos_venc_ok)* 100),2)) > 100 then 100 
                                                                       else (round( (sum(num_pagos_venc_nok) / sum(num_pagos_venc_ok)* 100),2)) 
                                                                  end 
                end Pct_cumpl_SV
           INTO vcount_con_pagomin, 
                vcount_sin_pagomin, 
                vPct_cumpl_PM, 
                vcount_con_sv, 
                vcount_sin_sv, 
                vPct_cumpl_SV
           FROM "informix".sd_pmsv_validapagos
          WHERE empresa  = '001'
            AND sucursal = vSucursal
            AND fecha    = vfecha_insert
            AND usuario = vUsuario; 
           
           
            IF vPct_PM_Recup > 0 and vcount_con_pagomin > 0 THEN
              LET vPct_PM_Recup_total = round(vPct_PM_Recup/vcount_con_pagomin,2);
            ELSE
              LET vPct_PM_Recup_total = 0;
            END IF;
                           
            IF vPct_SV_Recup > 0 AND vcount_con_sv > 0 THEN
              LET vPct_SV_Recup_total  = round(vPct_SV_Recup/vcount_con_sv,2);
            ELSE
              LET vPct_SV_Recup_total = 0;
            END IF;
           
                        
            IF d_cant_a_recup_sv > 0 THEN
               LET vPct_Cump_Recup_Cartera = round((vPct_PM_Recup_total + vPct_SV_Recup_total + vPct_cumpl_PM + vPct_cumpl_SV)/4,2);
            ELSE
               LET vPct_Cump_Recup_Cartera = round((vPct_PM_Recup_total +  vPct_cumpl_PM)/2,2);    
            END IF;
            
             	 
           BEGIN;
           
              INSERT INTO "informix".sd_rep_pmsv_ctrlfinanc(sucursal, fecha_insert, usuario, 
                                                            cant_a_recup_pm, 
                                                            cant_recup_pm, 
                                                            Pct_PM_Recup, 
                                                            count_con_pagomin, 
                                                            count_sin_pagomin,
                                                            Pct_cumpl_PM, 
                                                            cant_a_recup_sv, 
                                                            cant_recup_sv, 
                                                            Pct_SV_Recup, 
                                                            count_con_sv, 
                                                            count_sin_sv, 
                                                            Pct_cumpl_SV,
                                                            Pct_cump_recup_cartera)
              VALUES(vSucursal, vfecha_insert, vUsuario, 
                     d_cant_a_recup_pm,
                     d_cant_recup_pm, 
                     vPct_PM_Recup_total, 
                     vcount_con_pagomin, 
                     vcount_sin_pagomin, 
                     vPct_cumpl_PM, 
                     d_cant_a_recup_sv,
                     d_cant_recup_sv, 
                     vPct_SV_Recup_total, 
                     vcount_con_sv, 
                     vcount_sin_sv, 
                     vPct_cumpl_SV,
                     vPct_Cump_Recup_Cartera);
           COMMIT; 
          
          LET d_cant_a_recup_pm = 0; LET d_cant_recup_pm = 0; LET vPct_PM_Recup = 0; LET d_cant_a_recup_sv = 0; LET d_cant_recup_sv = 0; LET vPct_SV_Recup = 0;
          LET vcount_con_pagomin = 0; LET vcount_sin_pagomin = 0; LET vPct_cumpl_PM = 0; LET vcount_con_sv = 0; LET vcount_sin_sv = 0; LET vPct_cumpl_SV = 0;
          LET vPct_Cump_Recup_Cartera = 0;  LET vPct_PM_Recup_total = 0;   LET vPct_SV_Recup_total = 0;
          
    END FOREACH;
    
    -------------------------    CREACIÓN DE ARCHIVO POR CAJERO
    --LET cNombreArchivo= TRIM(cNombreArchivo)|| LPAD(TRIM(DAY(dtFecha)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || YEAR(dtFecha) || '.txt';
    LET cNombreArchivo= TRIM(cNombreArchivo)|| LPAD(TRIM(DAY(dtFecha)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || substr(YEAR(dtFecha),3,2) || '.txt';
    
    LET cConsulta = 'SELECT a.sucursal,' || 
                          ' a.fecha_insert,' || 
                          ' a.usuario,' || 
                          ' b.nombre,' ||
                          ' a.cant_a_recup_pm,' || 
                          ' a.cant_recup_pm,' || 
                          ' round(a.pct_pm_recup,2) as pct_pm_recup,' ||
                          ' a.count_con_pagomin as num_pagos_min_ok,' || 
                          ' a.count_sin_pagomin as num_pagos_min_nok,' ||
                          ' a.pct_cumpl_pm,' ||
                          ' a.cant_a_recup_sv,' ||
                          ' a.cant_recup_sv,' ||
                          ' round(a.pct_sv_recup,2) as pct_sv_recup,' ||
                          ' a.count_con_sv as num_pagos_venc_ok,' ||
                          ' a.count_sin_sv as num_pagos_venc_nok,' ||             
                          ' a.pct_cumpl_sv,' ||                          
                          ' a.pct_cump_recup_cartera' ||
                    ' FROM bdicred:sd_rep_pmsv_ctrlfinanc a left outer join bdinteg:si_ejecut b on a.usuario = b.ejecutivo ' ||
                    ' WHERE a.fecha_insert >= ' || "'" || dtFechaIni || "'" || ' and a.fecha_insert <=' || "'" || dtFechaFin || "'";  
 
		
		--LET cSql = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreArchivo) || ' DELIMITER '|| '''	'''|| ' ' || trim(cConsulta)||'" > '|| TRIM(cRuta) ||'query2.sql';
		LET cSql = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreArchivo) || ' DELIMITER '|| '''|''' || ' ' || trim(cConsulta)||'" > '|| TRIM(cRuta) ||'query2.sql';
		SYSTEM trim(cSql);
    SYSTEM 'chmod 777 ' || trim(cRuta) || 'query2.sql';
      			
			LET cSql = '';
			LET cSql = "dbaccess bdicobranza " ||trim(cRuta)||'query2.sql';
			SYSTEM trim(cSql);
   	
			-- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
			LET cSql = '';
			LET cSql = "rm " ||trim(cRuta)||'query2.sql';
			SYSTEM trim(cSql); 
			LET cSql = '';
			--LET cSQL = "rm " ||TRIM(cRuta)||TRIM(cNombreArchivo)||'.'||'unl';		
			--SYSTEM cSql; 		

   
    LET cSql = '';
    --LET cSQL = "gzip -f " ||trim(cRuta)|| cNombreArchivo;
    LET cSQL = "gzip " ||trim(cRuta)|| cNombreArchivo;
    SYSTEM trim(cSql);
    
    --------------- INICIO CREACION DE ARCHIVO POR SUCURSAL
    --LET cNombreArchivo_2 = TRIM(cNombreArchivo_2)|| LPAD(TRIM(DAY(dtFecha)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || substr(YEAR(dtFecha),3,2) || '.txt';
    LET cNombreArchivo_2 = TRIM(cNombreArchivo_2)|| LPAD(TRIM(DAY(dtFecha)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(dtFecha)::CHAR(2)),2,'0') || substr(YEAR(dtFecha),3,2); 
    
    LET cConsulta = 'SELECT sucursal,fecha_insert,cant_a_recup_pm,cant_recup_pm,Pct_PM_Recup,count_con_pagomin,count_sin_pagomin,' ||
                           'Pct_cumpl_PM,cant_a_recup_sv,cant_recup_sv,Pct_SV_Recup,count_con_sv,count_sin_sv,Pct_cumpl_SV, Pct_cump_recup_cartera ' || 
                    'FROM sd_rep_pagos_pmsv ' ||
                    'WHERE fecha_insert BETWEEN ' || "'" || dtFechaIni || "' AND '" || dtFechaFin  || "'";
 
			LET cSql = '';
			LET cSql = 'echo "UNLOAD TO ' ||TRIM(cRuta)||TRIM(cNombreArchivo_2)||'.'||'txt'|| ' '||TRIM(cConsulta)||'" > '|| TRIM(cRuta) ||'query001.sql';
		
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "dbaccess bdicred " ||TRIM(cRuta)||'query001.sql';
			SYSTEM TRIM(cSql);
		
		  LET cSql = '';
      LET cSql = 'echo "sucursal|Fecha|$ a Recup.PM|$ Recup.PM|%Cump.Recup PM|# de PM|# Sin PM|%Cump. #PM|$ a Recup.SV|$ Recup.SV|%Cump.Recup SV|# de Vencidos|# sin Vencidos|' ||
                      '%Cump. #Vencidos|%Cump.Recup.Cartera' || '" >> '|| TRIM(cRuta) || TRIM(cNombreArchivo_2) || '.txt';        	 
      SYSTEM TRIM(cSql);
	
	    LET cSql = '';
      LET cSql = "gzip " ||trim(cRuta)|| trim(cNombreArchivo_2) || '.' || 'txt';
      SYSTEM trim(cSql);
    
      LET cNombreArchivo_2 = trim(cNombreArchivo_2)||'.txt.gz';
    
    
    -------------- FIN CREACION DE ARCHIVO POR SUCURSAL
    
    
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '03') RETURNING vvcCod_ret;
    
    		
		RETURN cCodRet, cMensajeRet, cNombreArchivo;
END
END PROCEDURE
DOCUMENT 
'Procedimiento para generar info de pago mínimo y saldo vencido para estadistica de convenios',
'AUTOR : Marco A. Campos',
'FECHA : 2014/07/23',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_calculo_tiir( 
montoDisposicion DECIMAL(18,2),
pago_mensual DECIMAL(18,2),
numeroPeriodos INTEGER,
numeroPagosPeriodos INTEGER,
comision  DECIMAL(18,2)
)

RETURNING CHAR(6)  AS codigo_retorno,
          VARCHAR(80,1) AS mensaje_retorno,	
		   DECIMAL(18,2) AS cat; 
		   
---DECLARACIONES
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       VARCHAR(80,1);

DEFINE vCATMin          DECIMAL(18,2);
DEFINE vCAT            DECIMAL(21,10);
DEFINE vCATFin            DECIMAL(21,10);
DEFINE vCATMax          DECIMAL(21,10);
DEFINE vPrecision       DECIMAL(18,2);
DEFINE vPrecisionAux    DECIMAL(18,2);
DEFINE vPrecisionAux2    DECIMAL(18,2);
DEFINE vCiclado         INTEGER;
DEFINE iNumPago         INTEGER;

DEFINE vPagoSum         DECIMAL(18,2);
DEFINE vPlazo           DECIMAL(18,2); 
DEFINE vCATx            DECIMAL(21,10);
DEFINE vCATy            DECIMAL(32,10);
DEFINE vCATz            DECIMAL(21,10);
DEFINE vCatFinal            DECIMAL(21,1);
DEFINE vPagoCosto       DECIMAL(18,2);
DEFINE pago_mensualAux       DECIMAL(18,2);
DEFINE iContador      	INTEGER;
DEFINE iNumPagos      	INTEGER;
DEFINE iBanPrecision      	INTEGER;


---INICIALIZACIONES
LET iSqlErr             = 0;
LET iIsamErr            = 0;
LET cErrorInfo          = "";
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizó el cálculo correctamente";

LET vCATMin = 0;
LET vCAT = 10;
LET vCATFin = 1;
LET vCATMax =100;
LET vPrecision = 1;
LET vPrecisionAux = 1;
LET vPrecisionAux2 = 1;
LET vCiclado = 1;
LET iNumPago = 0;

LET vPagoSum = 0;
LET vPlazo = 0;
LET vCATx = 0;
LET vCATy = 0;
LET vCATz = 0;
LET vPagoCosto = 0;
LET pago_mensualAux = 0;
LET iContador = 1;
LET iNumPagos = 1;
LET vCatFinal =0;
LET iBanPrecision =0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	 LET cMensajeRet = cErrorInfo;
     RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(vCAT,0);
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/jesus/sp_calculo_tiir.out';
--TRACE ON;

LET pago_mensualAux = pago_mensual;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

WHILE (ABS(vPrecision) * 1000) > 1
	LET vPagoSum = 0;
	--LET vPlazo = 1;

	--LET pago_mensualAux = pago_mensual *12 ;
	WHILE iContador <=   numeroPeriodos
		
		IF iContador  = 0 THEN
			LET pago_mensualAux = (montoDisposicion * -1) + comision;
		ELSE 
			LET pago_mensualAux = pago_mensual;
		END IF;
		
		LET vCATx = 1 + (vCAT/100);
		LET vCATy = iNumPagos ;
		LET vCATz = pow(vCATx, vCATy);
		
	
		IF iContador = numeroPeriodos THEN
			LET pago_mensualAux = montoDisposicion +pago_mensualAux;
		END IF;		
		
		
		LET vPagoCosto = pago_mensualAux / vCATz;
		
		LET vPagoSum = vPagoSum + vPagoCosto;
		LET iContador = iContador +1;
		LET iNumPagos = iNumPagos +1 ;
	END WHILE	
	
	
		LET vPrecision = (montoDisposicion -comision)  - vPagoSum  ;		 IF vPrecision < 0 THEN
			LET vCATMin = vCAT;
			LET vCAT = (vCATMax + vCAT) / 2;
		 ELIF vPrecision > 0 THEN
			LET vCATMax = vCAT;
			LET vCAT = (vCATMin + vCAT) / 2;
		 END IF;
	
     IF  vCiclado > 100 THEN
		LET vPrecisionAux2 = vPrecision;	
		LET vPrecision = 0;	
		LET iBanPrecision =1;
	 ELSE 
		LET vPrecisionAux = vPrecision;
		
	 END IF;
	 
	 
LET iContador =1;
LET iNumPagos = 1 ;
LET vCiclado = vCiclado + 1;
	
END WHILE


IF  (vPrecisionAux2 <> vPrecisionAux) AND iBanPrecision =1 THEN
	LET vCAT =0;
END IF

LET vCATFin = vCAT; 

LET vCatFinal = ( pow(1+ (vCAT/100),12) - 1 ) * 100;


RETURN NVL(cCodRet,''),NVL(cMensajeRet,''),NVL(vCatFinal,0);

END
END PROCEDURE;