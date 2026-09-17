CREATE PROCEDURE "informix".sp_carga_ctes_reestructura(pEmpresa CHAR(3))
RETURNING CHAR(6)   AS codigo_retorno,
          CHAR(80)  AS mensaje_retorno;

DEFINE nrows            INTEGER;
DEFINE iSqlErr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRet      CHAR(80);
DEFINE cRutaRep         CHAR(40);
DEFINE cNombreArchivo1  CHAR(60);
DEFINE CNombreArchivo2  CHAR(60);
DEFINE CNombreArchivo3  CHAR(60);
DEFINE CNombreArchivo4  CHAR(60);
DEFINE dtFechaProc      DATE;
DEFINE dtFechaFin       DATE;
DEFINE idCampania       INTEGER;
DEFINE dtFechaCuotaAux  DATE;
DEFINE iRangoDia1       SMALLINT;
DEFINE iRangoDia2       SMALLINT;
DEFINE iRangoDia3       SMALLINT;
DEFINE cNumCred         CHAR(20);
DEFINE cNumCte          CHAR(20);
DEFINE cSucursal        CHAR(4);
DEFINE dtFechaReest     DATE;
DEFINE dMontoReest      DECIMAL(18,2);
DEFINE dMontoProxPago   DECIMAL(18,2);
DEFINE dIntMasIvaCorte  DECIMAL(18,2);
DEFINE dMontoProxPago2   DECIMAL(18,2);
DEFINE dIntMasIvaCorte2  DECIMAL(18,2);
DEFINE dSdoCorte        DECIMAL(18,2);
DEFINE dtFechaProxPago  DATE;
DEFINE dCapCorte        DECIMAL(18,2);
DEFINE cNomCte          CHAR(104);
DEFINE cTelCasa         CHAR(13);
DEFINE cTelCel          CHAR(13);
DEFINE cTelOfi          CHAR(13);
DEFINE cNumExt          CHAR(13);
DEFINE cRef1            CHAR(104);
DEFINE cTelRef1         CHAR(13);
DEFINE cRef2            CHAR(104);
DEFINE cTelRef2         CHAR(13);
DEFINE cVarReg          CHAR(5);
DEFINE cSql             CHAR(2024);
DEFINE iInserta         Integer;
DEFINE fecha_aux_inicio DATE;
DEFINE fecha_aux_fin    DATE;

BEGIN 

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      DELETE FROM bdicobranza:"informix".cb_campanias 
            WHERE empresa = pEmpresa 
              AND id_tipo = 'REPA'
              AND id_campania = idCampania;

      DELETE FROM "informix".sd_seguimientocrd 
            WHERE empresa = pEmpresa
              AND id_tipo = 'REPA'
              AND id_campania = idCampania;

      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, cMensajeRet;
    END IF;
END EXCEPTION;
--pruebas
--SET DEBUG FILE TO '/pisa/leo/repctesree/sp_carga_ctes_reestructura.out';
--TRACE ON;

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se realizó la carga de clientes correctamente';

LET cRutaRep        = '';
LET dtFechaProc     = DATE(1);
LET dtFechaFin      = DATE(1);
LET idCampania      = 0;
LET dtFechaCuotaAux = DATE(1);
LET iRangoDia1      = 0;
LET iRangoDia2      = 0;
LET iRangoDia3      = 0;
LET cNumCred        = '';
LET cNumCte         = '';
LET cSucursal       = '';
LET dtFechaReest    = DATE(1);
LET dMontoReest     = 0;
LET dMontoProxPago  = 0;
LET dIntMasIvaCorte = 0;
LET dMontoProxPago2 = 0;
LET dIntMasIvaCorte2= 0;
LET dSdoCorte       = 0;
LET dtFechaProxPago = DATE(1);
LET dCapCorte       = 0;
LET cNomCte         = '';
LET cTelCasa        = '';
LET cTelCel         = '';
LET cTelOfi         = '';
LET cNumExt         = '';
LET cRef1           = '';
LET cTelRef1        = '';
LET cRef2           = '';
LET cTelRef2        = '';
LET cVarReg         = '';
LET cSql            = '';
LET iInserta        = 0;
LET fecha_aux_inicio = DATE(1);
LET fecha_aux_fin    = DATE(1);


IF NVL(pEmpresa,'') = '' THEN
  LET pEmpresa = NULL;
END IF;

IF pEmpresa IS NULL THEN
   LET cCodRet     = '000001';
   LET cMensajeRet = 'No se indicó el parámetro correctamente';
   RETURN cCodRet, cMensajeRet;
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT TRIM(valor)
INTO cRutaRep
FROM bdicobranza:"informix".cb_param
WHERE empresa   = pEmpresa
AND cod_param = 1;

   LET nrows = DBINFO("sqlca.sqlerrd2");
   IF nrows  = 0 THEN
      LET cCodRet  = '000002';
      LET cMensajeRet = 'No esta definida la ruta del reporte a generar';
      RETURN cCodRet, cMensajeRet;
   ELSE
      LET cRutaRep = TRIM(cRutaRep);
   END IF;


SELECT fecha_hoy
  INTO dtFechaProc
  FROM "informix".sd_fechas
 WHERE empresa = pEmpresa;


SELECT MAX(id_campania)
  INTO idCampania
  FROM bdicobranza:"informix".cb_campanias
 WHERE empresa = pEmpresa
   AND id_tipo = 'REPA';

   IF idCampania IS NULL THEN
     LET idCampania = 1;
   ELSE
     LET idCampania = idCampania + 1;
   END IF;

   IF DAY(dtFechaProc) in (5,6,7,8,9,10) THEN
        LET fecha_aux_inicio =  MDY(MONTH(dtFechaProc),10,YEAR(dtFechaProc));
        LET fecha_aux_fin = MDY(MONTH(dtFechaProc),17,YEAR(dtFechaProc));
        LET dtFechaCuotaAux = MDY(MONTH(fecha_aux_fin), 17, YEAR(fecha_aux_fin));
        LET iRangoDia1 = 17;
        LET iRangoDia2 = 31;
        LET iRangoDia3 = 2;    
   ELIF DAY(dtFechaProc) in (20,21,22,23,24,25) THEN
        LET fecha_aux_inicio =  MDY(MONTH(dtFechaProc),25,YEAR(dtFechaProc));
            IF MONTH(dtFechaProc) = 12 THEN
               LET fecha_aux_fin = MDY(MONTH(dtFechaProc + 1 UNITS MONTH),2,YEAR(dtFechaProc  + 1 UNITS YEAR));
            ELSE
               LET fecha_aux_fin = MDY(MONTH(dtFechaProc + 1 UNITS MONTH),2,YEAR(dtFechaProc));
            END IF;  
        LET dtFechaCuotaAux = MDY(MONTH(fecha_aux_fin),2, YEAR(fecha_aux_fin));    
        LET iRangoDia1 = 3;
        LET iRangoDia2 = 16;
        LET iRangoDia3 = 0;
    ELSE
        LET cCodRet     = '000003';
        LET cMensajeRet = 'Hoy no es un día válido para ejecutar el proceso';
        RETURN cCodRet, cMensajeRet;        
   END IF;


  IF NOT EXISTS( SELECT id_tipo FROM bdicobranza:cb_tipos_campanias WHERE empresa = pEmpresa AND id_tipo ='REPA') THEN
     LET cCodRet     = -691;
     LET cMensajeRet = 'No existe registro REPA en la tabla cb_tipos_campanias en la bd bdicobranza';
     RETURN cCodRet, cMensajeRet;
  END IF;

  IF EXISTS(SELECT id_tipo FROM bdicobranza:cb_campanias WHERE empresa = pEmpresa AND id_tipo = 'REPA' 
            AND fecha_inicio = fecha_aux_inicio and fecha_fin = fecha_aux_fin) THEN
     LET cCodRet     = -268;
     LET cMensajeRet = 'Campaña REPA en la tabla cb_campanias en la bd bdicobranza ya ejecutada';
     RETURN cCodRet, cMensajeRet;

  ELSE

    INSERT INTO bdicobranza:"informix".cb_campanias (empresa, id_tipo, id_campania, fecha_inicio, fecha_fin, total_llamadas)
    VALUES (pEmpresa, 'REPA', idCampania, fecha_aux_inicio, fecha_aux_fin, 0);

  END IF;

FOREACH

    SELECT a.num_credito, a.numcte, a.sucursal, a.fecha_apertura, b.monto_otorgado
      INTO cNumCred, cNumCte, cSucursal, dtFechaReest, dMontoReest
      FROM "informix".sd_maecredcrd a, "informix".sd_maesdoscrd b
     WHERE a.empresa = b.empresa
       AND a.num_credito = b.num_credito
       AND a.empresa = pEmpresa
       AND (DAY(a.fecha_apertura) >= iRangoDia1 and DAY(a.fecha_apertura) <= iRangoDia2 or DAY(a.fecha_apertura) <= iRangoDia3)

    SELECT SUM(round((capital_debe + ((capital_mto_cuota - capital_debe) /1.15) + (capital_mto_cuota - capital_debe - ((capital_mto_cuota - capital_debe) /1.15)))- capital_pagado - interes_pagado - iva_pagado,2)),
           0--round(SUM(interes_debe - interes_pagado) + SUM(iva_debe - iva_pagado))
     INTO dMontoProxPago, dIntMasIvaCorte
      FROM bdicred:sd_amortiza_creditocrd
     WHERE empresa     = pEmpresa
      AND num_credito = cNumCred
      AND fecha_cuota <= fecha_aux_fin--dtFechaCuotaAux   -------**validacion de fecha **---------
      AND capital_status IN ('2','3','7','6');

      IF NVL(dMontoProxPago,0) = 0 THEN
          CONTINUE FOREACH;
       END IF;

    SELECT sdo_capital + cap_tras_no_venci + sdo_no_exig + monto_vencido + mto_venc_trasp
      INTO dCapCorte
      FROM "informix".sd_maesdoshistcrd h
    WHERE h.empresa = pEmpresa
       AND h.num_credito = cNumCred
       AND h.fecha   = (SELECT max(z.fecha)
                      FROM bdicred:"informix".sd_maesdoshistcrd z
                      WHERE z.empresa = pEmpresa
                      AND z.num_credito = cNumCred);


    LET dSdoCorte = dCapCorte + dIntMasIvaCorte;

    SELECT fecha_cuota
      INTO dtFechaProxPago
      FROM "informix".sd_amortiza_creditocrd
     WHERE empresa = pEmpresa
       AND num_credito = cNumCred
       AND fecha_cuota = fecha_aux_fin;


    SELECT DECODE(NVL(razon_social,''),'',
                  TRIM(NVL(nombre1,'')) ||' '||
                  TRIM(NVL(nombre2,'')) ||' '||
                  TRIM(NVL(apell_paterno,'')) ||' '||
                  TRIM(NVL(apell_materno,'')),
                  TRIM(razon_social))
      INTO cNomCte
      FROM bdinteg:"informix".si_cliente
     WHERE empresa = pEmpresa
       AND numcte = cNumCte;

    /*SELECT TRIM(a.telefono1), TRIM(a.telefono2), TRIM(a.telefono3), TRIM(a.extension)
      INTO cTelCasa, cTelCel, cTelOfi, cNumExt
      FROM bdinteg:"informix".si_direcciones a
     WHERE a.numcte = cNumCte
       AND a.tipo_dir = '1'
       AND a.secuencia = (SELECT MAX(b.secuencia)
                             FROM bdinteg:"informix".si_direcciones b
                            WHERE b.numcte = a.numcte
                              AND b.tipo_dir = '1');*/
							  
		select  telefono 
			into  cTelCasa
		from bdinteg:si_telefonos_actual 
		where numcte = cNumCte 
				and tipo_tel = 1 and cofetel ='V'
				and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = cNumCte and tipo_tel = 1 and cofetel ='V');
										
		select  telefono 
			into  cTelCel
		from bdinteg:si_telefonos_actual 
		where numcte = cNumCte 
				and tipo_tel = 2 and cofetel ='V'
				and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = cNumCte and tipo_tel = 2 and cofetel ='V');
												
		select  telefono ,extension
			into  cTelOfi, cNumExt
		from bdinteg:si_telefonos_actual 
		where numcte = cNumCte 
				and tipo_tel = 3 and cofetel ='V'
				and secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
													where numcte = cNumCte and tipo_tel = 3 and cofetel ='V');
      SELECT LIMIT 1 nombre_ref, telefono_ref
        INTO cRef1, cTelRef1
        FROM bdisolic:"informix".ss_refpersonales 
       WHERE empresa = pEmpresa
         AND numcte  = cNumCte
         AND TRIM(numcte_ref) = 'R1';

      SELECT LIMIT 1 nombre_ref, telefono_ref
        INTO cRef2, cTelRef2
        FROM bdisolic:"informix".ss_refpersonales 
       WHERE empresa = pEmpresa
         AND numcte  = cNumCte
         AND TRIM(numcte_ref) = '';


         
    INSERT INTO "informix".sd_seguimientocrd ( empresa, id_tipo, id_campania, num_credito, fecha_corte, sucursal, numcte,
                                              nombre_cliente, tel_casa, tel_celular, tel_oficina, num_extension, nombre_referencia1,
                                              telefono_referencia1, nombre_referencia2, telefono_referencia2,
                                              fecha_reestruc, monto_reestruc, fecha_prox_pago, monto_prox_pago,
                                              saldo_corte )
        VALUES ( pEmpresa, 'REPA', idCampania, cNumCred, NVL(fecha_aux_fin,DATE(1)), NVL(cSucursal,''), NVL(cNumCte,''),
                 NVL(cNomCte,''), NVL(cTelCasa,''), NVL(cTelCel,''), NVL(cTelOfi,''), NVL(cNumExt,''), NVL(cRef1,''), 
                 NVL(cTelRef1,''), NVL(cRef2,''), NVL(cTelRef2,''), 
                 NVL(dtFechaReest,DATE(1)), NVL(dMontoReest,0), NVL(dtFechaProxPago,DATE(1)), NVL(dMontoProxPago,0),
                 NVL(dSdoCorte,0));

    LET iInserta = iInserta + 1;

END FOREACH;

LET cNombreArchivo1 = 'RegistrosCRD' || LPAD(TRIM(DAY(fecha_aux_inicio::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(fecha_aux_inicio::DATE)::CHAR(2)),2,'0') ||YEAR(fecha_aux_inicio::DATE) || '.unl';
LET cNombreArchivo2 = 'QueryCRD' || LPAD(TRIM(DAY(fecha_aux_inicio::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(fecha_aux_inicio::DATE)::CHAR(2)),2,'0') ||YEAR(fecha_aux_inicio::DATE) || '.sql';
LET cNombreArchivo3 = 'Encabezado_CRD' || LPAD(TRIM(DAY(fecha_aux_inicio::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(fecha_aux_inicio::DATE)::CHAR(2)),2,'0') ||YEAR(fecha_aux_inicio::DATE) || '.unl';
LET cNombreArchivo4 = 'ReporteReestructuraCRD_' || LPAD(TRIM(DAY(fecha_aux_inicio::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(fecha_aux_inicio::DATE)::CHAR(2)),2,'0') ||YEAR(fecha_aux_inicio::DATE) || '.unl';

   IF iInserta = 0 THEN
      DELETE FROM bdicobranza:"informix".cb_campanias 
       WHERE empresa = pEmpresa 
         AND id_tipo = 'REPA'
         AND id_campania = idCampania;

          LET cSql = '';
          LET cSql = 'echo 000004 No se encontró información >> ' || SUBSTR(cRutaRep,1,LENGTH(cRutaRep))|| SUBSTR(cNombreArchivo3,1,LENGTH(cNombreArchivo3));
          LET cSql = cSql;
          SYSTEM cSql;

          LET cSql = '';
          LET cSql = "sed 's/ /	/g' " || SUBSTR(cRutaRep,1,LENGTH(cRutaRep))|| SUBSTR(cNombreArchivo3,1,LENGTH(cNombreArchivo3)) || ' > ' || SUBSTR(cRutaRep,1,LENGTH(cRutaRep))|| SUBSTR(cNombreArchivo4,1,LENGTH(cNombreArchivo4));
    	  LET cSql = cSql;
          SYSTEM cSql;

          LET cSql = '';
          LET cSql = 'rm ' ||SUBSTR(cRutaRep,1,LENGTH(cRutaRep))||SUBSTR(cNombreArchivo3,1,LENGTH(cNombreArchivo3));
          SYSTEM cSql;

      LET cCodRet  = '000004';
      LET cMensajeRet = 'No se encontró información';
      RETURN cCodRet, cMensajeRet; 

   ELSE
           LET cSql = "";
           LET cSql = ' UNLOAD TO ' || TRIM(cRutaRep) || TRIM(cNombreArchivo1) || ' DELIMITER ' || '''"	"''';
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  ' SELECT ' ;
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.empresa,' || '''" "''' || '")",';
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.fecha_corte,' || '''" "''' || '")",';
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.sucursal,' || '''" "''' || '")",';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.num_credito,' || '''" "''' || '")",';        
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.numcte,' || '''" "''' || '")",';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.nombre_cliente,' || '''" "''' || '")",';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.tel_casa,' || '''" "''' || '")",';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.tel_celular,' || '''" "''' || '")",';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.tel_oficina,' || '''" "''' || '")",';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.num_extension,' || '''" "''' || '")",';              
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.nombre_referencia1,' || '''" "''' || '")",';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.telefono_referencia1,' || '''" "''' || '")",';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.nombre_referencia2,' || '''" "''' || '")",';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.telefono_referencia2,' || '''" "''' || '")",';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.fecha_reestruc,' || '''" "''' || '")",';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.monto_reestruc,' || '''" "''' || '")",';              
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.fecha_prox_pago,' || '''" "''' || '")",';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.monto_prox_pago,' || '''" "''' || '")",';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  '  nvl"("a.saldo_corte,' || '''" "''' || '")"';           
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;
           LET cSql =  ' FROM "informix".sd_seguimientocrd a where a.id_campania = ' || idCampania ||' ORDER BY a.sucursal '||''';''';
          CALL sp_genera_archivo ( TRIM(cRutaRep) || TRIM(cNombreArchivo2) ,cSql) returning cVarReg;

          LET cSql = '';
          LET cSql = 'dbaccess bdicred ' || TRIM(cRutaRep) || TRIM(cNombreArchivo2);
          SYSTEM cSql;

          LET cSql = '';
          LET cSql = 'echo Empresa Fecha_de_Corte Número_de_Sucursal Número_de_crédito Número_de_Cliente Nombre_Completo Télefono_Casa Télefono_Celular Télefono_Of. Ext. Nombre_Referencia_1 Télefono Nombre_Referencia_2 Télefono Fecha_Reestructuración Monto_Reestructuración Fecha_Prox_Pago Monto_Prox_Pago Saldo_al_Corte  >> ' || SUBSTR(cRutaRep,1,LENGTH(cRutaRep))|| SUBSTR(cNombreArchivo3,1,LENGTH(cNombreArchivo3));
	   LET cSql = cSql;
          SYSTEM cSql;

          LET cSql = '';
          LET cSql = "sed 's/ /	/g' " || SUBSTR(cRutaRep,1,LENGTH(cRutaRep))|| SUBSTR(cNombreArchivo3,1,LENGTH(cNombreArchivo3)) || ' > ' || SUBSTR(cRutaRep,1,LENGTH(cRutaRep))|| SUBSTR(cNombreArchivo4,1,LENGTH(cNombreArchivo4));
	   LET cSql = cSql;
          SYSTEM cSql;

          LET cSql = '';
          LET cSql = 'cat ' ||SUBSTR(cRutaRep,1,LENGTH(cRutaRep))||SUBSTR(cNombreArchivo1,1,LENGTH(cNombreArchivo1)) || ' >> ' ||SUBSTR(cRutaRep,1,LENGTH(cRutaRep))||SUBSTR(cNombreArchivo4,1,LENGTH(cNombreArchivo4));
          SYSTEM cSql;

          LET cSql = '';
          LET cSql = 'rm ' ||SUBSTR(cRutaRep,1,LENGTH(cRutaRep))||SUBSTR(cNombreArchivo1,1,LENGTH(cNombreArchivo1))|| ' ' ||SUBSTR(cRutaRep,1,LENGTH(cRutaRep))||SUBSTR(cNombreArchivo2,1,LENGTH(cNombreArchivo2)) || ' ' ||SUBSTR(cRutaRep,1,LENGTH(cRutaRep))||SUBSTR(cNombreArchivo3,1,LENGTH(cNombreArchivo3));
          SYSTEM cSql;

   END IF;

RETURN cCodRet, cMensajeRet; 

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para cargar',
'los clientes en reestructura y generar',
'su reporte correspondiente',
'AUTOR : Paul Ivan Quintero Varela',
'        Ramon Romero',        
'FECHA : 06/07/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_apertura_credito_aut(P_EMPRESA       VARCHAR(3),
                                                P_SOLICITUD     VARCHAR(20),
                                                P_NUMTARJETA    CHAR(20),
                                                P_PLAZO         INTEGER,
                                                P_MTOSOL        DECIMAL(14,2),
                                                --P_MTOENGANCHE   DECIMAL(14,2), --SE REALIZA MODIFICACION PARA AGREGAR EL MONTO ENGACHE 
												P_MTOENGANCHE   DECIMAL(18,2),	 --A LA TABLA SD_MAECRECRD
                                                P_NUMCTE        CHAR(20),
                                                P_NUMCTA        CHAR(20),
                                                P_SUCURSAL      CHAR(4),
                                                P_TPSOL         CHAR(4),
                                                P_PRODUCTO      CHAR(4),
                                                P_EJECUTIVO     CHAR(8),
                                                P_MONTOADEUDO   CHAR(20))

	RETURNING CHAR(5)     ,  --CodRet
			  DECIMAL(9,6),  --TasaInteres
			  DECIMAL(9,6),  --TasaMora
			  DECIMAL(9,6),  --Cat
			  CHAR(1)     ;  --Mercadeo

	--*****************************************************
	--DECLARACION DE VARIABLES
	--*****************************************************
	---Variables de control de errores
	DEFINE vCodRet            	VARCHAR(8);
	DEFINE CodRet             	VARCHAR(8);
	DEFINE p_mensaje           	VARCHAR(80);
	DEFINE error_info          	VARCHAR(80);
	DEFINE sql_err             	INTEGER;
	DEFINE isam_err            	INTEGER;
	DEFINE wBegin              	CHAR(1);
	DEFINE vFechaApertura      	DATE;
	DEFINE vFechaVenc          	DATE;
	DEFINE i                   	INTEGER;
	DEFINE vPlazo              	INTEGER;
	DEFINE vFactor_FAV         	CHAR(1);
	DEFINE vMercadeo           	CHAR(1);
	DEFINE vNumCredito         	CHAR(20);
	DEFINE vProducto           	CHAR(4);
	DEFINE vDivisa             	CHAR(2);
	DEFINE vSucursal           	CHAR(4);
	DEFINE vFolio	           	CHAR(16);
	DEFINE vFactor	           	CHAR(1);
	DEFINE vMensaje            	CHAR(200);
	DEFINE vPerPlazo           	CHAR(1);
	
	DEFINE vTipoCalculo        	CHAR(2);
	DEFINE vCodTasInt          	CHAR(8);
	DEFINE vFacSobreTAsa       	CHAR(1);
	DEFINE vTasaFijVar         	CHAR(1);
	DEFINE vCodTasaMora        	CHAR(8);
	DEFINE vFacSobretMora      	CHAR(1);
	DEFINE vPerPagCap          	CHAR(1);
	DEFINE vPerPagInt          	CHAR(1);
	DEFINE vFecApert           	DATE;
	DEFINE vFecVenc            	DATE;
	DEFINE vFechaT             	DATE;
	DEFINE vDiaCorte           	SMALLINT;
	DEFINE vCapDebe            	DECIMAL(14,2);
	DEFINE vPagCuota           	DECIMAL(14,2);
	DEFINE vCatIva             	DECIMAL(9,6);
	DEFINE vTasaInteres        	DECIMAL(9,6);
	DEFINE vTasaMora           	DECIMAL(9,6);
	DEFINE vSobretasa          	DECIMAL(9,6);
	DEFINE vTasaFavor          	DECIMAL(9,6);
	DEFINE vSobretMora         	DECIMAL(9,6);
	DEFINE vMtoReestruc        	CHAR(20);
	DEFINE vCuenta			   	SMALLINT;  -- BGM 21-May-2010 se define variable para numero de cuota
	DEFINE vproxfechapag       	DATE;
	--DEFINE vproxfechapagaux    DATE;
	--Variables de cargo y abono a cuenta
	DEFINE vt_sucursal      	CHAR(4);
	DEFINE vt_codigo_mn     	CHAR(2);
	DEFINE vt_sdocta        	DECIMAL(14,2);
	DEFINE vt_bloqueo       	CHAR(1);
	DEFINE vt_sdodisp       	MONEY(14,2);
	DEFINE vt_dummy         	CHAR(4);
	DEFINE vt_dummy1        	DATE;
	DEFINE vfechacheq       	DATE;
	--valida comisiones jomm ini
	DEFINE vcom_pendiente   	DECIMAL(9,6);
	--valida comisiones jomm fin
	DEFINE vExiste				INTEGER;
	DEFINE bEsNumero          	BOOLEAN;
	-- Valida que la sol existen sea del mismo cliente
	DEFINE vNumCredTdcAux   	CHAR(20);
	DEFINE vNumCteAux       	CHAR(20);
	--- Cuenta Clabe
	DEFINE vcod_ret				CHAR (6);
	DEFINE cta_Clabe			CHAR (18);
	DEFINE cIFRS				CHAR(1);
	DEFINE cStatus_cred 		CHAR(2);
	DEFINE iAtr_Act_ifrs		INTEGER;
	
	
    ON EXCEPTION SET sql_err, isam_err, error_info
		--SET DEBUG FILE TO "Principal.err";
		---TRACE sql_err||" * "||isam_err||" * "||error_info;
		-- FMV 15mar13: Seguimiento al error -268 rastreo de la causa
		INSERT INTO  bdicred:"informix".sd_bitacora_mec values 
		('001', '6011', today, sql_err, 'isam_err:'||isam_err||':error_info:'||error_info, user, today, current );
		LET vCodRet   = sql_err;
		LET p_mensaje = error_info;
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END EXCEPTION;

	ON EXCEPTION IN (-535)
		LET wBegin = "S";
		ROLLBACK WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;

	  LET cIFRS				= '';
	  LET cStatus_cred 		= '';
	  LET iAtr_Act_ifrs		= 0;
      LET wBegin = "N";

      BEGIN WORK;

	--SET DEBUG FILE TO '/tmp/sp_apertura_credito.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;	
	SET LOCK MODE TO WAIT 3;

	--***********************
	--INICIALIZA VARIABLE
	--***********************
	LET  vCodRet        	 = '00000';
	LET  p_mensaje       	= 'PROCESO EXITOSO';
	LET  vTasaInteres   	= 0;
	LET  vTasaMora      	= 0;
	LET  vSobretasa     	= 0;
	LET  vTasaFavor     	= 0;
	LET  vFactor	  		= '';
	LET  vFechaApertura 	= '';
	LET  vFechaVenc     	= '';
	LET  vFactor_FAV    	= '';
	LET  vProducto      	= '';
	LET  vDivisa        	= '';
	LET  vSucursal      	= '';
	LET  vFolio	  			= '';
	LET  vMensaje       	= '';
	LET  vFechaT        	= '';
	LET  vDiaCorte      	= 0;
	LET  vCatIva	  		= 0;
	LET  vMercadeo      	= '';
	LET  vNumCredito    	= '';
	LET  i              	= 0;
	LET vCapDebe        	= 0;
	LET vPagCuota       	= 0;
	LET  vPerPlazo      	= '';
	LET  vPlazo         	= 0;
	LET  vDivisa        	= '';
	LET  vTipoCalculo   	= '';
	LET  vCodTasInt     	= '';
	LET  vFacSobreTAsa  	= '';
	LET  vTasaFijVar    	= '';
	LET  vCodTasaMora   	= '';
	LET  vFacSobretMora 	= '';
	LET  vSobretMora    	= 0;
	LET  vPerPagCap     	= '';
	LET  vPerPagInt     	= '';
	LET  vFecApert      	= '';
	LET  vFecVenc       	= '';
	LET  vMtoReestruc   	= '';
	LET  vCUenta = 1;  -- BGM 21-May-2010 se inicializa variable para nÃ?Â?Ã?Âºmero de cuota
	LET  vt_sdocta      	= 0;
	LET  vt_bloqueo     	= '';
	LET vproxfechapag   	= DATE(1);
	LET vcom_pendiente  	= 0;
	LET bEsNumero       	= 't';
	LET vExiste 		 	=  0;

	LET  P_MTOSOL       	= P_MTOSOL;
	LET P_MTOENGANCHE   	= NVL(P_MTOENGANCHE,0);
	LET P_MONTOADEUDO   	= P_MONTOADEUDO;
	
	--- Cuenta Clabe
	LET vcod_ret			= '000';
	LET cta_Clabe			= '';	

	-- FMV 10-JUL-2013: Se adiciona validacion al recibir incorrecto el No. Solicitud, por el error 24 tiempo de espera agotado
	EXECUTE PROCEDURE bdinteg:"informix".val_num (P_SOLICITUD) INTO bEsNumero;
	IF bEsNumero = 'f' OR trim(P_SOLICITUD) = '' OR P_SOLICITUD is null THEN
		LET vCodRet='242'; --EL NUMERO DE SOLICITUD NO EXISTE
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;

	--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
	--//Cat
	SELECT valor INTO vCatIva
	FROM   bdicred:"informix".sd_param
	WHERE  cod_param = '321';
	IF vCatIva IS NULL THEN
		LET vCatIva = 0;
	END IF;

	SELECT fecha_hoy
	INTO vFechaApertura
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = P_EMPRESA;
	
	SELECT NVL(valor,'I') INTO cIFRS FROM bdicred:sd_param WHERE cod_param = '700';
	IF cIFRS = 'A' THEN
		LET cStatus_cred = 'VP';
		LET iAtr_Act_ifrs = 0;
	ELSE
		LET cStatus_cred = 'VP';
		LET iAtr_Act_ifrs = null;
	END IF;	

	--//Folio
	SELECT P_EJECUTIVO
	|| REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
	INTO vFolio
	FROM bdicred:"informix".sd_FECHAS; --PRODUCE SEQUENTIAL

	SELECT num_credito
	INTO vNumCredito
	FROM bdicred:"informix".sd_tarjeta
	WHERE empresa      = P_EMPRESA
	AND num_tarjeta  = P_NUMTARJETA;

	--//Sucursal
	SELECT sucursal
	INTO vt_sucursal
	FROM bdicheq:"informix".sc_maechq
	WHERE empresa = P_EMPRESA
	AND cuenta  = P_NUMCTA;

	--//Tipo de Moneda
	SELECT valor
	INTO vt_codigo_mn
	FROM bdinteg:"informix".si_param
	WHERE empresa = P_EMPRESA
	AND descripcion ="codigo mn";

	--------------------------------------------------------
	---     GENERA LA SOLICITUD DE REESTRUCTURA          ---
	--------------------------------------------------------
	-- CGP 18-12-2014 se modifica para evitar el error -268
	SELECT COUNT(num_solicitud) INTO vExiste FROM bdisolic:"informix".ss_solicitudes WHERE empresa = P_EMPRESA AND num_solicitud = P_SOLICITUD;
    --IF NOT EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_solicitudes WHERE empresa = P_EMPRESA AND num_solicitud = P_SOLICITUD) THEN
	IF vExiste = 0 THEN
		--FMV 20dic12 : Se eliminan las tablas previo a insertar datos por duplicidad y error -268 informix en el proceso.
		DELETE FROM bdisolic:"informix".ss_solicitudes WHERE empresa = P_EMPRESA
														AND num_solicitud = P_SOLICITUD; -- se le quita el estatus de la solicitud CGP

		DELETE FROM bdisolic:"informix".ss_anexosol WHERE empresa = P_EMPRESA
														AND num_solicitud = P_SOLICITUD;

		DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = P_EMPRESA
														AND num_solicitud = P_SOLICITUD
														AND status_solicitud = 'PC';


		INSERT INTO bdisolic:"informix".ss_solicitudes
		(empresa         , num_solicitud, numcte           , sucursal  , tipo_solicitud,
		status_solicitud, num_producto , monto_solicitado ,user_insert, fecha_insert)
		VALUES
		(P_EMPRESA      , P_SOLICITUD   , P_NUMCTE   , P_SUCURSAL, P_TPSOL      ,
		"PC"           , P_PRODUCTO    , P_MTOSOL   ,P_EJECUTIVO, vFechaApertura);

		INSERT INTO bdisolic:"informix".ss_anexosol
		(empresa  , num_solicitud, fecha_sol   , ejecutivo_sol, otro_presta,
		user_insert, fecha_insert, otro_copresta,num_acta)
		VALUES
		(P_EMPRESA, P_SOLICITUD , vFechaApertura, P_EJECUTIVO  , P_MTOENGANCHE,
		P_EJECUTIVO, vFechaApertura, P_MONTOADEUDO, P_NUMTARJETA);

		INSERT INTO bdisolic:"informix".ss_autorizacion
		(empresa      , ejecutivo_auto, num_solicitud, status_solicitud, comentario,
		fecha_entrada, fecha_salida  , user_insert  , fecha_insert)
		VALUES
		(P_EMPRESA    , P_EJECUTIVO   , P_SOLICITUD  , "PC"            , "Solicitud Pre-Calificada  por sistema",
		vFechaApertura, vFechaApertura , P_EJECUTIVO  , vFechaApertura);

    ELSE
        --Obtiene el credito existen en base de datos y compara que sea el mismo cliente.
        SELECT limit 1 numcte, credito_externo INTO vNumCteAux, vNumCredTdcAux FROM bdicred:"informix".sd_maecredcrd 
		WHERE empresa = P_EMPRESA AND num_credito = P_SOLICITUD;
        LET P_NUMCTE = P_NUMCTE;
        LET vNumCredito = vNumCredito;

        IF vNumCteAux != P_NUMCTE OR vNumCredTdcAux != vNumCredito THEN
			LET vCodRet = '366'; -- Ya existe registro previo del credito con cliente y credito 6001 diferente
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
        END IF;
    END IF;

  --------------------------------------------------------
  ---     GENERA MOVIMIENTO DE CARGO Y ABONO           ---
  --------------------------------------------------------
--//Valida comisiones pendientes JOM INI
    SELECT NVL(com_pendiente ,0)
    INTO vcom_pendiente
    FROM bdicheq:"informix".sc_maechq 
    WHERE empresa = P_EMPRESA 
    AND cuenta = P_NUMCTA;

    IF vcom_pendiente > 0 then
		LET vCodRet='400';
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
        RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
    END IF;

	--//Valida comisiones pendientes JOM INI

	---INI CAS
	IF P_MTOENGANCHE > 0 THEN
	--//Valida Saldo de la Cuenta
		EXECUTE PROCEDURE bdicheq:"informix".cons_saldo(P_NUMCTA)
		INTO vCodRet, vt_sdocta, vt_bloqueo;

		IF vCodRet = "000" AND vt_bloqueo='1' AND vt_sdocta >= P_MTOENGANCHE THEN

			SELECT fecha_proceso
			INTO vfechacheq
			FROM bdicheq:"informix".sc_maechq
			WHERE cuenta=P_NUMCTA;

			IF vfechacheq<>vFechaApertura THEN
				LET vCodRet='549';
				ROLLBACK WORK;
				IF (wBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
			END IF;
			--//Aplicar el Abono del prestamo
			EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
											   P_NUMCTA, 0,P_MTOSOL - P_MTOENGANCHE, P_MTOSOL - P_MTOENGANCHE,
											   0,0,0,vt_codigo_mn, TRIM(P_SOLICITUD) ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
			INTO vCodRet;
		   --//Verifica si el abono fue exitoso
			IF vCodRet <> "000" THEN
				ROLLBACK WORK;
				IF (wBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
			END IF;
			--JMAH RQM 10 495 
			--//Ejecutar cargo total de la reestructura
			EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(P_EMPRESA,vt_sucursal,p_ejecutivo,'0279',"0000",vFolio,P_NUMCTA,0,P_MTOSOL,
										vt_codigo_mn,'REESTRUCTURA CREDITO',P_NUMTARJETA,p_ejecutivo)
			INTO vCodRet, vt_dummy,vt_dummy1,vt_sdodisp,vt_sdocta;

		   --//Verifica si el cargo fue exitoso
			IF vCodRet <> "000" THEN
				--//Ejecutar cargo igual al monto del abono de la reestructura
				--          EXECUTE PROCEDURE bdicheq:cargo_ref(P_EMPRESA,vt_sucursal,p_ejecutivo,'0227',"0000",vFolio,P_NUMCTA,0,P_MTOSOL - P_MTOENGANCHE,
				--                                      vt_codigo_mn,'REESTRUCTURA CREDITO',"",p_ejecutivo)
				--          INTO vCodRet, vt_dummy,vt_dummy1,vt_sdodisp,vt_sdocta;

				EXECUTE PROCEDURE "informix".reversion(P_EMPRESA,vt_sucursal,p_ejecutivo,vFolio,'B')
				INTO vCodRet;

				IF vCodRet <> "000" THEN
				ROLLBACK WORK;
				IF (wBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
				END IF;
				ROLLBACK WORK;
				IF (wBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
			END IF;
		ELSE
				ROLLBACK WORK;
				IF (wBegin = "S") THEN
					BEGIN WORK;
				END IF;

			IF vCodRet = "000" AND vt_sdocta < P_MTOENGANCHE THEN
				LET vCodRet = "400";
				ELIF vt_bloqueo<>'1' THEN
				LET vCodRet = "432";
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
		END IF;
	END IF;
    
	---FIN CAS

	-----------------------------------------------------------
	--- REVISA QUE NO EXISTA REESTRUCTURA EN TABLAS Y BORRA ---
	-----------------------------------------------------------

	DELETE FROM bdicred:"informix".sd_MAESDOSCRD
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MOVDIA
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MOVDIACRD     --FMV 20dic12: Se adiciona por error informix -268
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MAECREDANEXOCRD
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	UPDATE bdisolic:"informix".ss_solicitudes 
	SET status_solicitud = "AT"
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD;

	DELETE FROM bdisolic:"informix".ss_autorizacion
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND status_solicitud = "AP";

	DELETE FROM bdicred:"informix".sd_amortiza_creditocrd
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MAECREDCRD
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_ctascarg
	WHERE EMPRESA     = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_indicador_cred_crd  --FMV 15may13
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	-----------------------------------------
	--- PROCESO DE LIQUIDACION DE CREDITO ---
	-----------------------------------------
	CALL "informix".sp_liquida_credito(p_empresa,vNumCredito,vFolio) RETURNING vCodRet,p_mensaje;

	IF vCodRet <> '00000' THEN
	ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		IF P_MTOENGANCHE>0 THEN
			EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
											   P_NUMCTA, 0,P_MTOENGANCHE, P_MTOENGANCHE,
											   0,0,0,vt_codigo_mn, P_SOLICITUD ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
			INTO vCodRet;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;

	--**Monto Minimo Para Consulta Generalizada Y Tabla De Amortizacion
	SELECT MIN(fecha_cuota)
	INTO vFechaT
	FROM bdicred:"informix".sd_proyecta
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD;

	LET vproxfechapag=vFechaT;

	IF DAY(vFechaT) = '17' THEN
		LET vDiaCorte = 17;
	ELIF DAY(vFechaT) = '02' THEN
		LET vDiaCorte = 2;
	END IF;

         --** Fecha Vencimiento Del Credito

	LET  vFechaVenc= (SELECT MAX(fecha_cuota)
						FROM bdicred:"informix".sd_proyecta
						WHERE empresa = P_EMPRESA
						AND num_solicitud = P_SOLICITUD);
	IF vfechavenc IS NULL THEN LET vfechavenc=DATE(1); END IF;

	-- ****************************
	-- Determina Tasas de Interes *
	-- ****************************
	--INTERES ORDINARIO
	SELECT c.valor, a.factor_sobretasa, a.sobretasa --, a.dia_cuota
	INTO vTasaInteres, vFactor, vSobretasa        --, vDiaCorte
	FROM bdicred:"informix".sd_definicion a, 
	bdisolic:"informix".ss_solicitudes b,
	bdinteg:"informix".si_fechavalor c
	WHERE b.empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto
	AND c.empresa = a.empresa
	AND c.tasa = a.cod_tasa_base
	AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
					WHERE r.empresa = P_EMPRESA
					AND r.tasa = a.cod_tasa_base);


	IF vFactor = "+" THEN
		LET vTasaInteres = vTasaInteres + vSobretasa;
	ELIF vFactor = "-" THEN
		LET vTasaInteres = vTasaInteres - vSobretasa;
	ELIF vFactor = "*" THEN
		LET vTasaInteres = vTasaInteres * vSobretasa;
	ELSE
		LET vTasaInteres = vTasaInteres / vSobretasa;
	END IF

	--INTERES MORATORIO
	SELECT {+INDEX ("informix".sd_definicioncrd)}
		c.valor, a.fact_sobret_mora, a.sobretasa_mora
	INTO vTasaMora   , vFactor, vSobretasa
	FROM bdicred:"informix".sd_definicioncrd a, 
		bdisolic:"informix".ss_solicitudes b,
		bdinteg:"informix".si_fechavalor c
	WHERE b.empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto
	AND c.empresa = a.empresa
	AND c.tasa = a.cod_tasa_mora
	AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
					WHERE r.empresa = P_EMPRESA
					AND r.tasa = a.cod_tasa_mora);

	IF vFactor = "+" THEN
		LET vTasaMora = vTasaMora + vSobretasa;
	ELIF vFactor = "-" THEN
		LET vTasaMora = vTasaMora - vSobretasa;
	ELIF vFactor = "*" THEN
		LET vTasaMora = vTasaMora * vSobretasa;
	ELSE
		LET vTasaMora = vTasaMora / vSobretasa;
	END IF

        --INTERES A FAVOR DEL CLIENTE
        SELECT {+INDEX ("informix".sd_definicioncrd)}
			c.valor, a.factor_sobretasa, a.sobretasa
		INTO vTasaFavor   , vFactor_FAV, vSobretasa
		FROM bdicred:"informix".sd_definicioncrd a, 
			bdisolic:"informix".ss_solicitudes b,
			bdinteg:"informix".si_fechavalor c
         WHERE b.empresa = P_EMPRESA
			AND num_solicitud = P_SOLICITUD
			AND a.empresa = b.empresa
			AND a.num_producto = b.num_producto
			AND c.empresa = a.empresa
			AND c.tasa = a.cod_tasa_base
			AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
							WHERE r.empresa = P_EMPRESA
                            AND r.tasa = a.cod_tasa_base);



        IF vFactor_FAV = "+" THEN
            LET vTasaFavor = vTasaFavor + vSobretasa;
        ELIF vFactor_FAV = "-" THEN
            LET vTasaFavor = vTasaFavor - vSobretasa;
        ELIF vFactor_FAV = "*" THEN
            LET vTasaFavor = vTasaFavor * vSobretasa;
        ELSE
			LET vTasaFavor = vTasaFavor / vSobretasa;
        END IF
		
	--- Genera cuenta Clabe
	EXECUTE PROCEDURE bdicred:"informix".sp_gen_clabe_interbancaria (P_EMPRESA,P_SOLICITUD,P_PRODUCTO)
		INTO vcod_ret, cta_Clabe;

	--**INSERTA LA CUENTA PARA COBRO
	INSERT INTO "informix".sd_ctascarg
		(EMPRESA           ,NUMERO          ,
		CON_CAP_INTE      ,NATURALEZA      ,
		NUM_CREDITO       ,TIPO_CTA        ,
		NUM_CTA           , NUM_NOMINA)
	VALUES
		(P_EMPRESA        , 0               ,
		''               , 'A'             ,
		P_SOLICITUD      , ''              ,
		P_NUMCTA         , ''              );


	--***** ACTUALIZA SD_MAECRED

	INSERT INTO bdicred:"informix".sd_maecredcrd
		(EMPRESA                ,NUM_CREDITO
		,NUM_PRODUCTO           ,EJECUTIVO
		,NUMCTE                 ,DIVISA
		,SUCURSAL               ,ID_ORIGEN
		,ORIGEN                 ,COD_TIPO_LINEA
		,COD_LINEA
		,STATUS_CRED            ,BANDERA_RENOVAC
		,BANDERA_PRORROGA       ,PERIODO_PLAZO
		,PLAZO                  ,FECHA_APERTURA
		,FECHA_VENCIM           ,PERIOD_PAGO_CAP
		,PERIOD_PAG_INT         ,DIAS_TRASP_CAP
		,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR
		,COD_TASA_BASE          ,FACTOR_SOBRETASA
		,SOBRETASA              ,TASA_INTERES
		,COD_TASA_MORA          ,SOBRETASA_MORA
		,FACT_SOBRET_MORA       ,TASA_MORATORIOS
		,FECHA_PAGO_CAP         ,FECHA_PAGO_INT
		,ES_FISICA              ,BANDERA_FI_FO
		,ACTIVIDAD
		,TIPO_CALCULO
		,NUM_APER_ANT           ,REV_TASA_VAR_PER
		,DIA_PARA_REVISAR       ,COD_PROD
		,BANDERA_MINISTRA
		,CREDITO_EXTERNO        ,PAGOS_SOSTENIDOS
		,CAMPO_TRAB1            ,CAMPO_TRAB2
		,CAMPO_TRAB3            ,CAMPO_TRAB4
		,valor_preferencial --PRUEBAS 16082018)
		,cuenta_clabe)
	SELECT {+INDEX ("informix".sd_definicioncrd)}
		SOL.EMPRESA                ,P_SOLICITUD
		,SOL.NUM_PRODUCTO           ,ANX.EJECUTIVO_SOL
		,SOL.NUMCTE                 ,DEF.DIVISA
		,SOL.SUCURSAL               ,''
		,''                         ,''
		,''
		--,'VP'                       ,'S'                   --** Credito Vencido Y Renovado Para Pago Sostenido
		,cStatus_cred				,'S'
		,'N'                        ,DEF.PERIODO_PLAZO
		,P_PLAZO                    ,vFechaApertura
		,vFechaVenc               ,"3"
		,"2"                        ,CTR.DIAS_TRAS_CAP
		,CTR.DIAS_TRAS_INT          ,DEF.TASA_FIJA_O_VAR
		,DEF.COD_TASA_BASE          ,DEF.FACTOR_SOBRETASA
		,DEF.SOBRETASA              ,vTasaInteres
		,DEF.COD_TASA_MORA          ,DEF.SOBRETASA_MORA
		,DEF.FACT_SOBRET_MORA       ,vTasaMora
		,''                         ,''
		,TIP.ES_FISICA              ,''
		,''
		,DEF.TIPO_CALCULO
		,''                         ,SOL.REV_TASA_VAR_PER
		,DEF.DIA_PARA_REVISAR       ,''
		,'M'
		,vNumCredito                ,0
		,0                          ,0
		,''                         ,''
		,P_MTOENGANCHE --PRUEBAS 16082018
		,cta_Clabe
	FROM   bdisolic:"informix".ss_SOLICITUDES SOL
		, bdisolic:"informix".ss_ANEXOSOL    ANX
		, bdinteg:"informix".si_CLIENTE      CLI
		, bdinteg:"informix".si_TIPPER       TIP
		, "informix".SD_CODTRASP             CTR
		, "informix".SD_DEFINICIONCRD           DEF
	WHERE  DEF.EMPRESA         = SOL.EMPRESA
	AND    DEF.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
	AND    CTR.PERIOD_PAG_INT  = "3"
	AND    CTR.PERIOD_PAGO_CAP = "2"
	AND    CTR.NUM_PRODUCTO    = DEF.NUM_PRODUCTO
	AND    CTR.EMPRESA         = DEF.EMPRESA
	AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
	AND    CLI.NUMCTE          = SOL.NUMCTE
	AND    CLI.EMPRESA         = SOL.EMPRESA
	AND    ANX.NUM_SOLICITUD   = SOL.NUM_SOLICITUD
	AND    ANX.EMPRESA         = SOL.EMPRESA
	AND    SOL.NUM_SOLICITUD   = P_SOLICITUD
	AND    SOL.EMPRESA         = P_EMPRESA;

	--**ACTUALIZA  LA TARJETA CON EL NO. DE CREDITO REESTRUCTURADO

	UPDATE bdicred:"informix".sd_MAECRED
	SET credito_externo = P_SOLICITUD
	WHERE empresa     = P_EMPRESA
	AND num_credito = vNumCredito;

	--***** ACTUALIZA SD_MAECREDANEXO (DATOS PARA TARJETA DE CREDITO)
	-- CALL bdicred:"informix".monthadd(mdy(month(vFechaApertura),'01',year(vFechaApertura)),1) RETURNING vproxfechapagaux;
	-- CALL bdicred:"informix".sp_valfechabil(mdy(month(vproxfechapagaux),vDiaCorte,year(vproxfechapagaux)),'+') RETURNING vCodRet, vproxfechapag;

	INSERT INTO bdicred:"informix".sd_maecredanexocrd
			(empresa,               num_credito,
			dia_corte,             dias_gracia_mora,
			tp_dias_calc_mora,     dias_fecha_max_pago,
			tp_dias_fecha_pago,    cod_tasa_base_cte,
			factor_sobretasa_cte,  sobretasa_cte,
			tasa_interes_cte,      prox_fecha_pago,
			fecha_proceso)
	SELECT {+INDEX ("informix".sd_definicioncrd)}
		   P_EMPRESA,               P_SOLICITUD,
		   vDiaCorte          ,           def.campo_3,
		   def.pago_adic_sig_cuota,   def.tpo_persona,
		   def.maneja_linea,        def.cod_tasa_base,
		   def.factor_sobretasa,    def.sobretasa,
		   vTasaFavor,            vproxfechapag,
		   vFechaApertura
	FROM bdicred:"informix".sd_definicioncrd def,
		bdisolic:"informix".ss_solicitudes c
	WHERE c.empresa = P_EMPRESA
	AND c.num_solicitud = P_SOLICITUD
	AND def.empresa = c.empresa
	AND def.num_producto = c.num_producto;

      --***** ACTUALIZA SD_MAESDOS
         INSERT INTO bdicred:"informix".sd_MAESDOScrd 
                                (EMPRESA                ,NUM_CREDITO
                                ,FECHA_ULT_MOV          ,SDO_INT_ANTICIP
                                ,SDO_INT_ANT_DEV        ,SDO_INTERESES
                                ,SDO_DIA_ANT_INT        ,SDO_MES_ANT_INT
                                ,SDO_ACUM_MES_INT       ,SDO_RETENIDO
                                ,SDO_ACUM_CAP_INT       ,SDO_EXIG_INT
                                ,SDO_NO_EXIG            ,PROVISION_NORMAL
                                ,DIAS_ACUM_INT          ,SDO_MORATORIO
                                ,SDO_DIA_ANT_MOR        ,SDO_MES_ANT_MOR
                                ,SDO_CONTAB_MORA        ,DIAS_ACUM_MORA
                                ,SDO_CAPITAL            ,SDO_CAP_INSOLUTO
                                ,SDO_DIA_ANT_CAP        ,SDO_MES_ANT_CAP
                                ,SDO_ACUM_MES_CAP       ,MTO_CAPITALIZADO
                                ,MTO_MINISTRA_CAP       ,CARGOS_DIA_CAP
                                ,ABONOS_DIA_CAP         ,CARGOS_MES_CAP
                                ,ABONOS_MES_CAP         ,DIAS_ACUM_CAP
                                ,MONTO_VENCIDO          ,MTO_VENC_TRASP
                                ,MONTO_FINANCIADO       ,MONTO_RESERVADO
                                ,SDO_ACUM_VENCIDO       ,DIAS_ACUM_INTPER
                                ,SDO_GLOBAL_INT         ,SDO_ACUM_INTPER
                                ,MONTO_OTORGADO         ,PROVI_VENC_NORMAL
                                ,PROVI_VENC_ANTICIP     ,CAP_TRAS_NO_VENCI
                                ,MTO_VENC_INT           ,MTO_VENC_TRA_INT
                                ,MTO_FINAN_VDO          ,MTO_RESER_INT
                                ,MTO_FIN_VEN_TRASP      ,MTO_FIN_VIG_TRASP
                                ,INT_TRA_NO_EXIG        ,SDO_TRAB4
								,ATR
                                )
                          SELECT SOL.EMPRESA            ,P_SOLICITUD
                                ,vFechaApertura         ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,CASE WHEN cIFRS = 'A' THEN SOL.MONTO_SOLICITADO-P_MTOENGANCHE ELSE 0 END ,SOL.MONTO_SOLICITADO-P_MTOENGANCHE
                                ,0                      ,SOL.MONTO_SOLICITADO-P_MTOENGANCHE
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,vPagCuota              ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,SOL.MONTO_SOLICITADO-P_MTOENGANCHE   ,0
                                ,0                      ,CASE WHEN cIFRS = 'A' THEN 0 ELSE SOL.MONTO_SOLICITADO-P_MTOENGANCHE END
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,vPagCuota
								,iAtr_Act_ifrs
                          FROM   bdisolic:"informix".ss_SOLICITUDES SOL
                          WHERE  SOL.NUM_SOLICITUD = P_SOLICITUD
                          AND    SOL.EMPRESA   = P_EMPRESA;

	--  FMV 23abr13: Inserta cascaron para indicadores de prestamo a plazo
	INSERT INTO bdicred:"informix".sd_indicador_cred_crd
			(empresa, num_credito, fecha_alta)
	VALUES (P_EMPRESA, P_SOLICITUD, vFechaApertura);

    -- *********************************************************
                  -- INSERTA LA  TABLA DE AMORTIZACIONES *
    -- *********************************************************
	
	FOREACH
		SELECT fecha_cuota,capital_cuota,sum(capital_cuota + interes_cuota + iva_cuota)
		INTO vFechaT, vCapDebe,vPagCuota
		FROM bdicred:"informix".sd_proyecta
		WHERE empresa = P_EMPRESA
		AND num_solicitud = P_SOLICITUD
		GROUP BY 1,2
		ORDER BY fecha_cuota  -- BGM 21-Mayo-10 se ordena por fecha cuota
		INSERT INTO sd_amortiza_creditocrd values   
				(P_EMPRESA,P_SOLICITUD,vFechaT,"3",vPagCuota,vCapDebe,0,"4","0","",  -- BGM 21-May-2010 se considera 4 estatus de capital
				0,0,"3","0","", 0,0,"1","0","", 0,0,0,0,0,0,0,"1", 0,0,"1","",   -- BGM 21-May-2010 se considera variable para nÃ?Â?Ã?Âºmero de cuota en el campo num_pago
				vCuenta,0,0,"","");
			   
		LET vCuenta=vCuenta+1;  -- BGM 21-May-2010 se incrementa variable para nÃ?Â?Ã?Âºmero de cuota en el campo num_pago

	END FOREACH;

	UPDATE bdicred:"informix".sd_amortiza_creditocrd set capital_status = '3'   -- BGM 21-May-2010 se actualiza capital status de primer cuota a 3
	WHERE num_credito = P_SOLICITUD AND num_pago = 1;

    -- **************************************
    -- Actualiza el Estatus de la Solicitud *
    -- Complemento De Datos                 *
    -- **************************************

    SELECT periodo_plazo    , plazo          , divisa          ,tipo_calculo,
			cod_tasa_base    , sobretasa      , factor_sobretasa,
			tasa_interes     , tasa_fija_o_var, cod_tasa_mora   ,
			fact_sobret_mora , sobretasa_mora , tasa_moratorios ,
			period_pago_cap  , period_pag_int , fecha_apertura  ,
			fecha_vencim
    INTO vPerPlazo          , vPlazo         , vDivisa         , vTipoCalculo,
			vCodTasInt         , vSobretasa     , vFacSobreTasa   ,
			vTasaInteres       , vTasaFijVar    , vCodTasaMora    ,
			vFacSobretMora     , vSobretMora    , vTasaMora       ,
			vPerPagCap         , vPerPagInt     , vFecApert       ,
			vFecVenc
	FROM bdicred:"informix".sd_maecredcrd
	WHERE empresa = P_EMPRESA
	AND num_credito = P_SOLICITUD;

    UPDATE bdisolic:"informix".ss_solicitudes
                SET status_solicitud = "AP",
                    tipo_prestamo    = "C",
                    periodo_plazo    = vPerPlazo,
                    plazo            = vPlazo,
                    divisa           = vDivisa,
                    tipo_calculo     = vTipoCalculo,
                    cod_tasa_base    = vCodTasInt,
                    sobretasa        = vSobretasa,
                    factor_sobretasa = vFacSobreTasa,
                    tasa_interes     = vTasaInteres,
                    tasa_fija_o_var  = vTasaFijVar ,
                    cod_tasa_mora    = vCodTasaMora,
                    factor_moratorio = vFacSobretMora,
                    sobretasa_mora   = vSobretMora,
                    tasa_moratorios  = vTasaMora ,
                    periodo_pag_cap  = vPerPagCap,
                    periodo_pag_int  = vPerPagInt,
                    fecha_apert_prop = vFecApert,
                    fecha_venc_prop  = vFecVenc,
                    co_numcte        = P_NUMCTA
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD;

	SELECT nombre INTO vMensaje
	FROM bdinteg:"informix".si_ejecut
	WHERE ejecutivo = P_EJECUTIVO
	AND empresa = P_EMPRESA;

    LET vMensaje = "Apertura de Credito Autorizada por: " || TRIM(vMensaje);

    INSERT INTO bdisolic:"informix".ss_autorizacion
        (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
         comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
	VALUES(P_EMPRESA, P_EJECUTIVO, P_SOLICITUD, "AP", vMensaje,
	    vFechaApertura, vFechaApertura, USER, TODAY);


    -- Resta el Valor de la Tasa Moratoria con la de Intereses
    -- Solicitado por el Banco JLP 23May2008

    LET vTasaMora = vTasaMora - vTasaInteres;
    IF vTasaMora < 0 THEN --Si es Menor a Cero la vuelve Positivo
		LET vTasaMora = vTasaMora * -1;
    END IF

	SELECT {+INDEX ("informix".sd_definicioncrd)}
		a.num_producto, a.divisa, b.monto_solicitado, b.sucursal
	INTO vProducto, vDivisa, P_MTOSOL, vSucursal
	FROM bdisolic:"informix".ss_solicitudes b, 
		bdicred:"informix".sd_definicioncrd a
	WHERE b.empresa = P_EMPRESA
	AND b.num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto;


	--** EXTRAE EL MONTO DE LA REESTRUCTURA
	SELECT otro_copresta
	INTO   vMtoReestruc
	FROM   bdisolic:"informix".ss_anexosol
	WHERE  num_solicitud = P_SOLICITUD;

	 --**GENERA MOVIMIENTO DE APERTURA

	EXECUTE PROCEDURE "informix".GENMOVCRD( P_EMPRESA       , P_SOLICITUD,
		vProducto       , 2,
		"001"           , vFechaApertura,
		P_MTOSOL-P_MTOENGANCHE        , vFolio,
		vSucursal       ,vDivisa,
		"0000","APERTURA REESTRUCTURA","")
	INTO vCodRet, P_MENSAJE;

	IF vCodRet <> '000000' THEN
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		IF P_MTOENGANCHE>0 THEN
			EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
											   P_NUMCTA, 0,P_MTOENGANCHE, P_MTOENGANCHE,
											   0,0,0,vt_codigo_mn, P_SOLICITUD ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
			INTO vCodRet;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;

	EXECUTE PROCEDURE "informix".GENMOVCRD( P_EMPRESA       , P_SOLICITUD,
					vProducto       , 1,
					"002"           , vFechaApertura,
					P_MTOSOL-P_MTOENGANCHE        , vFolio,
					vSucursal       ,vDivisa,
					"0000","APERTURA REESTRUCTURA","")
	INTO vCodRet, P_MENSAJE;

	IF vCodRet <> '000000' THEN
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		IF P_MTOENGANCHE>0 THEN
			EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
										   P_NUMCTA, 0,P_MTOENGANCHE, P_MTOENGANCHE,
										   0,0,0,vt_codigo_mn, P_SOLICITUD ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
			INTO vCodRet;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;
	
	--SE realiza el marcaje del cliente RQI 27 100 JMAH
	EXECUTE PROCEDURE bdisitesp:"informix".sp_marcajesitesp('001',2,P_NUMCTE, p_ejecutivo)
	INTO vCodRet, P_MENSAJE;
	
	LET vCodRet  = '00000';
	COMMIT WORK;
	IF (wBegin = "S") THEN
		BEGIN WORK;
	END IF;
	RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
END PROCEDURE
DOCUMENT
'FOLIO: 438-RQM 10 1024-ActualizaciÃ?Â³n de las tablas de amortizaciÃ?Â³n para PrÃ?Â©stamo Personal y Reestructura',
'MODIFICÃ?Â?: 95358897 - ISARAI BOJORQUEZ',
'MODIFICACIÃ?Â?N: SE MODIFICA PROCEDIMIENTO PARA AGREGAR EL MONTO DE ENGANCHE AL CAMPO valor_preferencial DE LA TABLA sd_maecredcrd Y CAMBIAR',
'VALOR DEL PARAMETRO P_MTOENGANCHE DECIMAL (18,2)',
'FECHA: 29/08/2018 ',
'BD:BDICRED';

CREATE PROCEDURE "informix".sp_apertura_credito_web(P_EMPRESA       VARCHAR(3),
                                                P_SOLICITUD     VARCHAR(20),
                                                P_NUMTARJETA    CHAR(20),
                                                P_PLAZO         INTEGER,
                                                P_MTOSOL        DECIMAL(14,2),
                                                --P_MTOENGANCHE   DECIMAL(14,2), --SE REALIZA MODIFICACION PARA AGREGAR EL MONTO ENGACHE 
												P_MTOENGANCHE   DECIMAL(18,2),	 --A LA TABLA SD_MAECRECRD
                                                P_NUMCTE        CHAR(20),
                                                P_NUMCTA        CHAR(20),
                                                P_SUCURSAL      CHAR(4),
                                                P_TPSOL         CHAR(4),
                                                P_PRODUCTO      CHAR(4),
                                                P_EJECUTIVO     CHAR(8),
                                                P_MONTOADEUDO   CHAR(20))

	RETURNING CHAR(5)     ,  --CodRet
			  DECIMAL(9,6),  --TasaInteres
			  DECIMAL(9,6),  --TasaMora
			  DECIMAL(9,6),  --Cat
			  CHAR(1)     ;  --Mercadeo

	--*****************************************************
	--DECLARACION DE VARIABLES
	--*****************************************************
	---Variables de control de errores
	DEFINE vCodRet            	VARCHAR(5);
	DEFINE CodRet             	VARCHAR(8);
	DEFINE p_mensaje           	VARCHAR(80);
	DEFINE error_info          	VARCHAR(80);
	DEFINE sql_err             	INTEGER;
	DEFINE isam_err            	INTEGER;
	DEFINE wBegin              	CHAR(1);
	DEFINE vFechaApertura      	DATE;
	DEFINE vFechaVenc          	DATE;
	DEFINE i                   	INTEGER;
	DEFINE vPlazo              	INTEGER;
	DEFINE vFactor_FAV         	CHAR(1);
	DEFINE vMercadeo           	CHAR(1);
	DEFINE vNumCredito         	CHAR(20);
	DEFINE vProducto           	CHAR(4);
	DEFINE vDivisa             	CHAR(2);
	DEFINE vSucursal           	CHAR(4);
	DEFINE vFolio	           	CHAR(16);
	DEFINE vFactor	           	CHAR(1);
	DEFINE vMensaje            	CHAR(200);
	DEFINE vPerPlazo           	CHAR(1);
	
	DEFINE vTipoCalculo        	CHAR(2);
	DEFINE vCodTasInt          	CHAR(8);
	DEFINE vFacSobreTAsa       	CHAR(1);
	DEFINE vTasaFijVar         	CHAR(1);
	DEFINE vCodTasaMora        	CHAR(8);
	DEFINE vFacSobretMora      	CHAR(1);
	DEFINE vPerPagCap          	CHAR(1);
	DEFINE vPerPagInt          	CHAR(1);
	DEFINE vFecApert           	DATE;
	DEFINE vFecVenc            	DATE;
	DEFINE vFechaT             	DATE;
	DEFINE vDiaCorte           	SMALLINT;
	DEFINE vCapDebe            	DECIMAL(14,2);
	DEFINE vPagCuota           	DECIMAL(14,2);
	DEFINE vCatIva             	DECIMAL(9,6);
	DEFINE vTasaInteres        	DECIMAL(9,6);
	DEFINE vTasaMora           	DECIMAL(9,6);
	DEFINE vSobretasa          	DECIMAL(9,6);
	DEFINE vTasaFavor          	DECIMAL(9,6);
	DEFINE vSobretMora         	DECIMAL(9,6);
	DEFINE vMtoReestruc        	CHAR(20);
	DEFINE vCuenta			   	SMALLINT;  -- BGM 21-May-2010 se define variable para numero de cuota
	DEFINE vproxfechapag       	DATE;
	--DEFINE vproxfechapagaux    DATE;
	--Variables de cargo y abono a cuenta
	DEFINE vt_sucursal      	CHAR(4);
	DEFINE vt_codigo_mn     	CHAR(2);
	DEFINE vt_sdocta        	DECIMAL(14,2);
	DEFINE vt_bloqueo       	CHAR(1);
	DEFINE vt_sdodisp       	MONEY(14,2);
	DEFINE vt_dummy         	CHAR(4);
	DEFINE vt_dummy1        	DATE;
	DEFINE vfechacheq       	DATE;
	--valida comisiones jomm ini
	DEFINE vcom_pendiente   	DECIMAL(9,6);
	--valida comisiones jomm fin
	DEFINE vExiste				INTEGER;
	DEFINE bEsNumero          	BOOLEAN;
	-- Valida que la sol existen sea del mismo cliente
	DEFINE vNumCredTdcAux   	CHAR(20);
	DEFINE vNumCteAux       	CHAR(20);
	--- Cuenta Clabe
	DEFINE vcod_ret				CHAR (6);
	DEFINE cta_Clabe			CHAR (18);
	
	DEFINE cIFRS				CHAR(1);
	DEFINE cStatus_cred 		CHAR(2);
	DEFINE iAtr_Act_ifrs		INTEGER;

	ON EXCEPTION SET sql_err, isam_err, error_info
		--SET DEBUG FILE TO "Principal.err";
		---TRACE sql_err||" * "||isam_err||" * "||error_info;
		-- FMV 15mar13: Seguimiento al error -268 rastreo de la causa
		INSERT INTO  bdicred:"informix".sd_bitacora_mec values 
		('001', '6011', today, sql_err, 'isam_err:'||isam_err||':error_info:'||error_info, user, today, current );
		LET vCodRet   = sql_err;
		LET p_mensaje = error_info;
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END EXCEPTION;

	ON EXCEPTION IN (-535)
		LET wBegin = "S";
		ROLLBACK WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;

      LET wBegin = "N";

      BEGIN WORK;

	--SET DEBUG FILE TO '/tmp/sp_apertura_credito.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;	
	SET LOCK MODE TO WAIT 3;

	--***********************
	--INICIALIZA VARIABLE
	--***********************
	LET  vCodRet        	 = '00000';
	LET  p_mensaje       	= 'PROCESO EXITOSO';
	LET  vTasaInteres   	= 0;
	LET  vTasaMora      	= 0;
	LET  vSobretasa     	= 0;
	LET  vTasaFavor     	= 0;
	LET  vFactor	  		= '';
	LET  vFechaApertura 	= '';
	LET  vFechaVenc     	= '';
	LET  vFactor_FAV    	= '';
	LET  vProducto      	= '';
	LET  vDivisa        	= '';
	LET  vSucursal      	= '';
	LET  vFolio	  			= '';
	LET  vMensaje       	= '';
	LET  vFechaT        	= '';
	LET  vDiaCorte      	= 0;
	LET  vCatIva	  		= 0;
	LET  vMercadeo      	= '';
	LET  vNumCredito    	= '';
	LET  i              	= 0;
	LET vCapDebe        	= 0;
	LET vPagCuota       	= 0;
	LET  vPerPlazo      	= '';
	LET  vPlazo         	= 0;
	LET  vDivisa        	= '';
	LET  vTipoCalculo   	= '';
	LET  vCodTasInt     	= '';
	LET  vFacSobreTAsa  	= '';
	LET  vTasaFijVar    	= '';
	LET  vCodTasaMora   	= '';
	LET  vFacSobretMora 	= '';
	LET  vSobretMora    	= 0;
	LET  vPerPagCap     	= '';
	LET  vPerPagInt     	= '';
	LET  vFecApert      	= '';
	LET  vFecVenc       	= '';
	LET  vMtoReestruc   	= '';
	LET  vCUenta = 1;  -- BGM 21-May-2010 se inicializa variable para numero de cuota
	LET  vt_sdocta      	= 0;
	LET  vt_bloqueo     	= '';
	LET vproxfechapag   	= DATE(1);
	LET vcom_pendiente  	= 0;
	LET bEsNumero       	= 't';
	LET vExiste 		 	=  0;

	LET  P_MTOSOL       	= P_MTOSOL;
	LET P_MTOENGANCHE   	= NVL(P_MTOENGANCHE,0);
	LET P_MONTOADEUDO   	= P_MONTOADEUDO;
	
	--- Cuenta Clabe
	LET vcod_ret			= '000';
	LET cta_Clabe			= '';	
	
	LET cIFRS				= '';
	LET cStatus_cred 		= '';
	LET iAtr_Act_ifrs       = 0;

	-- FMV 10-JUL-2013: Se adiciona validacion al recibir incorrecto el No. Solicitud, por el error 24 tiempo de espera agotado
	EXECUTE PROCEDURE bdinteg:"informix".val_num (P_SOLICITUD) INTO bEsNumero;
	IF bEsNumero = 'f' OR trim(P_SOLICITUD) = '' OR P_SOLICITUD is null THEN
		LET vCodRet='00242'; --EL NUMERO DE SOLICITUD NO EXISTE
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;

	--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
	--//Cat
	SELECT valor INTO vCatIva
	FROM   bdicred:"informix".sd_param
	WHERE  cod_param = '321';
	IF vCatIva IS NULL THEN
		LET vCatIva = 0;
	END IF;

	SELECT fecha_hoy
	INTO vFechaApertura
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = P_EMPRESA;
	
	
	SELECT NVL(valor,'I') INTO cIFRS FROM bdicred:sd_param WHERE cod_param = '700';
	IF cIFRS = 'A' THEN
		LET cStatus_cred = 'VP';
		LET iAtr_Act_ifrs = 0;
	ELSE
		LET cStatus_cred = 'VP';
		LET iAtr_Act_ifrs = null;
	END IF;		

	--//Folio
	SELECT P_EJECUTIVO
	|| REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
	INTO vFolio
	FROM bdicred:"informix".sd_FECHAS; --PRODUCE SEQUENTIAL

	SELECT num_credito
	INTO vNumCredito
	FROM bdicred:"informix".sd_tarjeta
	WHERE empresa      = P_EMPRESA
	AND num_tarjeta  = P_NUMTARJETA;

	--//Sucursal
	SELECT sucursal
	INTO vt_sucursal
	FROM bdicheq:"informix".sc_maechq
	WHERE empresa = P_EMPRESA
	AND cuenta  = P_NUMCTA;

	--//Tipo de Moneda
	SELECT valor
	INTO vt_codigo_mn
	FROM bdinteg:"informix".si_param
	WHERE empresa = P_EMPRESA
	AND descripcion ="codigo mn";

	--------------------------------------------------------
	---     GENERA LA SOLICITUD DE REESTRUCTURA          ---
	--------------------------------------------------------
	-- CGP 18-12-2014 se modifica para evitar el error -268
	SELECT COUNT(num_solicitud) INTO vExiste FROM bdisolic:"informix".ss_solicitudes WHERE empresa = P_EMPRESA AND num_solicitud = P_SOLICITUD;
    --IF NOT EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_solicitudes WHERE empresa = P_EMPRESA AND num_solicitud = P_SOLICITUD) THEN
	IF vExiste = 0 THEN
		--FMV 20dic12 : Se eliminan las tablas previo a insertar datos por duplicidad y error -268 informix en el proceso.
		DELETE FROM bdisolic:"informix".ss_solicitudes WHERE empresa = P_EMPRESA
														AND num_solicitud = P_SOLICITUD; -- se le quita el estatus de la solicitud CGP

		DELETE FROM bdisolic:"informix".ss_anexosol WHERE empresa = P_EMPRESA
														AND num_solicitud = P_SOLICITUD;

		DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = P_EMPRESA
														AND num_solicitud = P_SOLICITUD
														AND status_solicitud = 'PC';


		INSERT INTO bdisolic:"informix".ss_solicitudes
		(empresa         , num_solicitud, numcte           , sucursal  , tipo_solicitud,
		status_solicitud, num_producto , monto_solicitado ,user_insert, fecha_insert)
		VALUES
		(P_EMPRESA      , P_SOLICITUD   , P_NUMCTE   , P_SUCURSAL, P_TPSOL      ,
		"PC"           , P_PRODUCTO    , P_MTOSOL   ,P_EJECUTIVO, vFechaApertura);

		INSERT INTO bdisolic:"informix".ss_anexosol
		(empresa  , num_solicitud, fecha_sol   , ejecutivo_sol, otro_presta,
		user_insert, fecha_insert, otro_copresta,num_acta)
		VALUES
		(P_EMPRESA, P_SOLICITUD , vFechaApertura, P_EJECUTIVO  , P_MTOENGANCHE,
		P_EJECUTIVO, vFechaApertura, P_MONTOADEUDO, P_NUMTARJETA);

		INSERT INTO bdisolic:"informix".ss_autorizacion
		(empresa      , ejecutivo_auto, num_solicitud, status_solicitud, comentario,
		fecha_entrada, fecha_salida  , user_insert  , fecha_insert)
		VALUES
		(P_EMPRESA    , P_EJECUTIVO   , P_SOLICITUD  , "PC"            , "Solicitud Pre-Calificada  por sistema",
		vFechaApertura, vFechaApertura , P_EJECUTIVO  , vFechaApertura);

    ELSE
        --Obtiene el credito existen en base de datos y compara que sea el mismo cliente.
        SELECT limit 1 numcte, credito_externo INTO vNumCteAux, vNumCredTdcAux FROM bdicred:"informix".sd_maecredcrd 
		WHERE empresa = P_EMPRESA AND num_credito = P_SOLICITUD;
        LET P_NUMCTE = P_NUMCTE;
        LET vNumCredito = vNumCredito;

        IF vNumCteAux != P_NUMCTE OR vNumCredTdcAux != vNumCredito THEN
			LET vCodRet = '00366'; -- Ya existe registro previo del credito con cliente y credito 6001 diferente
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
        END IF;
    END IF;

  --------------------------------------------------------
  ---     GENERA MOVIMIENTO DE CARGO Y ABONO           ---
  --------------------------------------------------------
--//Valida comisiones pendientes JOM INI
    SELECT NVL(com_pendiente ,0)
    INTO vcom_pendiente
    FROM bdicheq:"informix".sc_maechq 
    WHERE empresa = P_EMPRESA 
    AND cuenta = P_NUMCTA;

    IF vcom_pendiente > 0 then
		LET vCodRet='00400';
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
        RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
    END IF;

	--//Valida comisiones pendientes JOM INI

	---INI CAS
	--//Valida Saldo de la Cuenta
	EXECUTE PROCEDURE bdicheq:"informix".cons_saldo(P_NUMCTA)
	INTO vCodRet, vt_sdocta, vt_bloqueo;

    IF vCodRet = "000" AND vt_bloqueo='1' AND vt_sdocta >= P_MTOENGANCHE THEN

		SELECT fecha_proceso
		INTO vfechacheq
		FROM bdicheq:"informix".sc_maechq
		WHERE cuenta=P_NUMCTA;

		IF vfechacheq<>vFechaApertura THEN
			LET vCodRet='00549';
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
		END IF;
		--//Aplicar el Abono del prestamo
		EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
                                           P_NUMCTA, 0,P_MTOSOL - P_MTOENGANCHE, P_MTOSOL - P_MTOENGANCHE,
	                    		           0,0,0,vt_codigo_mn, TRIM(P_SOLICITUD) ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
	    INTO vCodRet;
       --//Verifica si el abono fue exitoso
        IF vCodRet <> "000" THEN
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN '00'||vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
        END IF;
		--JMAH RQM 10 495 
        --//Ejecutar cargo total de la reestructura
        EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(P_EMPRESA,vt_sucursal,p_ejecutivo,'0279',"0000",vFolio,P_NUMCTA,0,P_MTOSOL,
                                    vt_codigo_mn,'REESTRUCTURA CREDITO',P_NUMTARJETA,p_ejecutivo)
        INTO vCodRet, vt_dummy,vt_dummy1,vt_sdodisp,vt_sdocta;

       --//Verifica si el cargo fue exitoso
        IF vCodRet <> "000" THEN
			--//Ejecutar cargo igual al monto del abono de la reestructura
			--          EXECUTE PROCEDURE bdicheq:cargo_ref(P_EMPRESA,vt_sucursal,p_ejecutivo,'0227',"0000",vFolio,P_NUMCTA,0,P_MTOSOL - P_MTOENGANCHE,
			--                                      vt_codigo_mn,'REESTRUCTURA CREDITO',"",p_ejecutivo)
			--          INTO vCodRet, vt_dummy,vt_dummy1,vt_sdodisp,vt_sdocta;

            EXECUTE PROCEDURE "informix".reversion(P_EMPRESA,vt_sucursal,p_ejecutivo,vFolio,'B')
            INTO vCodRet;

			IF vCodRet <> "000" THEN
				ROLLBACK WORK;
				IF (wBegin = "S") THEN
					BEGIN WORK;
				END IF;
				RETURN '00'||vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
			END IF;
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN '00'||vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
        END IF;

    ELSE
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;

		IF vCodRet = "000" AND vt_sdocta < P_MTOENGANCHE THEN
			LET vCodRet = "00400";
		ELIF vt_bloqueo<>'1' THEN
			LET vCodRet = "00432";
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
    END IF;
	---FIN CAS

	-----------------------------------------------------------
	--- REVISA QUE NO EXISTA REESTRUCTURA EN TABLAS Y BORRA ---
	-----------------------------------------------------------

	DELETE FROM bdicred:"informix".sd_MAESDOSCRD
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MOVDIA
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MOVDIACRD     --FMV 20dic12: Se adiciona por error informix -268
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MAECREDANEXOCRD
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	UPDATE bdisolic:"informix".ss_solicitudes 
	SET status_solicitud = "AT"
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD;

	DELETE FROM bdisolic:"informix".ss_autorizacion
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND status_solicitud = "AP";

	DELETE FROM bdicred:"informix".sd_amortiza_creditocrd
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MAECREDCRD
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_ctascarg
	WHERE EMPRESA     = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_indicador_cred_crd  --FMV 15may13
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	-----------------------------------------
	--- PROCESO DE LIQUIDACION DE CREDITO ---
	-----------------------------------------
	CALL "informix".sp_liquida_credito(p_empresa,vNumCredito,vFolio) RETURNING vCodRet,p_mensaje;

	IF vCodRet <> '00000' THEN
	ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		IF P_MTOENGANCHE>0 THEN
			EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
											   P_NUMCTA, 0,P_MTOENGANCHE, P_MTOENGANCHE,
											   0,0,0,vt_codigo_mn, P_SOLICITUD ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
			INTO vCodRet;
		END IF;
		RETURN '00'||vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;

	--**Monto Minimo Para Consulta Generalizada Y Tabla De Amortizacion
	SELECT MIN(fecha_cuota)
	INTO vFechaT
	FROM bdicred:"informix".sd_proyecta
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD;

	LET vproxfechapag=vFechaT;

	IF DAY(vFechaT) = '17' THEN
		LET vDiaCorte = 17;
	ELIF DAY(vFechaT) = '02' THEN
		LET vDiaCorte = 2;
	END IF;

         --** Fecha Vencimiento Del Credito

	LET  vFechaVenc= (SELECT MAX(fecha_cuota)
						FROM bdicred:"informix".sd_proyecta
						WHERE empresa = P_EMPRESA
						AND num_solicitud = P_SOLICITUD);
	IF vfechavenc IS NULL THEN LET vfechavenc=DATE(1); END IF;

	-- ****************************
	-- Determina Tasas de Interes *
	-- ****************************
	--INTERES ORDINARIO
	SELECT c.valor, a.factor_sobretasa, a.sobretasa --, a.dia_cuota
	INTO vTasaInteres, vFactor, vSobretasa        --, vDiaCorte
	FROM bdicred:"informix".sd_definicion a, 
	bdisolic:"informix".ss_solicitudes b,
	bdinteg:"informix".si_fechavalor c
	WHERE b.empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto
	AND c.empresa = a.empresa
	AND c.tasa = a.cod_tasa_base
	AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
					WHERE r.empresa = P_EMPRESA
					AND r.tasa = a.cod_tasa_base);


	IF vFactor = "+" THEN
		LET vTasaInteres = vTasaInteres + vSobretasa;
	ELIF vFactor = "-" THEN
		LET vTasaInteres = vTasaInteres - vSobretasa;
	ELIF vFactor = "*" THEN
		LET vTasaInteres = vTasaInteres * vSobretasa;
	ELSE
		LET vTasaInteres = vTasaInteres / vSobretasa;
	END IF

	--INTERES MORATORIO
	SELECT {+INDEX ("informix".sd_definicioncrd)}
		c.valor, a.fact_sobret_mora, a.sobretasa_mora
	INTO vTasaMora   , vFactor, vSobretasa
	FROM bdicred:"informix".sd_definicioncrd a, 
		bdisolic:"informix".ss_solicitudes b,
		bdinteg:"informix".si_fechavalor c
	WHERE b.empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto
	AND c.empresa = a.empresa
	AND c.tasa = a.cod_tasa_mora
	AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
					WHERE r.empresa = P_EMPRESA
					AND r.tasa = a.cod_tasa_mora);

	IF vFactor = "+" THEN
		LET vTasaMora = vTasaMora + vSobretasa;
	ELIF vFactor = "-" THEN
		LET vTasaMora = vTasaMora - vSobretasa;
	ELIF vFactor = "*" THEN
		LET vTasaMora = vTasaMora * vSobretasa;
	ELSE
		LET vTasaMora = vTasaMora / vSobretasa;
	END IF

        --INTERES A FAVOR DEL CLIENTE
        SELECT {+INDEX ("informix".sd_definicioncrd)}
			c.valor, a.factor_sobretasa, a.sobretasa
		INTO vTasaFavor   , vFactor_FAV, vSobretasa
		FROM bdicred:"informix".sd_definicioncrd a, 
			bdisolic:"informix".ss_solicitudes b,
			bdinteg:"informix".si_fechavalor c
         WHERE b.empresa = P_EMPRESA
			AND num_solicitud = P_SOLICITUD
			AND a.empresa = b.empresa
			AND a.num_producto = b.num_producto
			AND c.empresa = a.empresa
			AND c.tasa = a.cod_tasa_base
			AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
							WHERE r.empresa = P_EMPRESA
                            AND r.tasa = a.cod_tasa_base);



        IF vFactor_FAV = "+" THEN
            LET vTasaFavor = vTasaFavor + vSobretasa;
        ELIF vFactor_FAV = "-" THEN
            LET vTasaFavor = vTasaFavor - vSobretasa;
        ELIF vFactor_FAV = "*" THEN
            LET vTasaFavor = vTasaFavor * vSobretasa;
        ELSE
			LET vTasaFavor = vTasaFavor / vSobretasa;
        END IF
		
	--- Genera cuenta Clabe
	EXECUTE PROCEDURE bdicred:"informix".sp_gen_clabe_interbancaria (P_EMPRESA,P_SOLICITUD,P_PRODUCTO)
		INTO vcod_ret, cta_Clabe;

	--**INSERTA LA CUENTA PARA COBRO
	INSERT INTO "informix".sd_ctascarg
		(EMPRESA           ,NUMERO          ,
		CON_CAP_INTE      ,NATURALEZA      ,
		NUM_CREDITO       ,TIPO_CTA        ,
		NUM_CTA           , NUM_NOMINA)
	VALUES
		(P_EMPRESA        , 0               ,
		''               , 'A'             ,
		P_SOLICITUD      , ''              ,
		P_NUMCTA         , ''              );


	--***** ACTUALIZA SD_MAECRED

	INSERT INTO bdicred:"informix".sd_maecredcrd
		(EMPRESA                ,NUM_CREDITO
		,NUM_PRODUCTO           ,EJECUTIVO
		,NUMCTE                 ,DIVISA
		,SUCURSAL               ,ID_ORIGEN
		,ORIGEN                 ,COD_TIPO_LINEA
		,COD_LINEA
		,STATUS_CRED            ,BANDERA_RENOVAC
		,BANDERA_PRORROGA       ,PERIODO_PLAZO
		,PLAZO                  ,FECHA_APERTURA
		,FECHA_VENCIM           ,PERIOD_PAGO_CAP
		,PERIOD_PAG_INT         ,DIAS_TRASP_CAP
		,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR
		,COD_TASA_BASE          ,FACTOR_SOBRETASA
		,SOBRETASA              ,TASA_INTERES
		,COD_TASA_MORA          ,SOBRETASA_MORA
		,FACT_SOBRET_MORA       ,TASA_MORATORIOS
		,FECHA_PAGO_CAP         ,FECHA_PAGO_INT
		,ES_FISICA              ,BANDERA_FI_FO
		,ACTIVIDAD
		,TIPO_CALCULO
		,NUM_APER_ANT           ,REV_TASA_VAR_PER
		,DIA_PARA_REVISAR       ,COD_PROD
		,BANDERA_MINISTRA
		,CREDITO_EXTERNO        ,PAGOS_SOSTENIDOS
		,CAMPO_TRAB1            ,CAMPO_TRAB2
		,CAMPO_TRAB3            ,CAMPO_TRAB4
		,valor_preferencial --PRUEBAS 16082018)
		,cuenta_clabe)
	SELECT {+INDEX ("informix".sd_definicioncrd)}
		SOL.EMPRESA                ,P_SOLICITUD
		,SOL.NUM_PRODUCTO           ,ANX.EJECUTIVO_SOL
		,SOL.NUMCTE                 ,DEF.DIVISA
		,SOL.SUCURSAL               ,''
		,''                         ,''
		,''
		,'VP'                       ,'S'                   --** Credito Vencido Y Renovado Para Pago Sostenido
		,'N'                        ,DEF.PERIODO_PLAZO
		,P_PLAZO                    ,vFechaApertura
		,vFechaVenc               ,"3"
		,"2"                        ,CTR.DIAS_TRAS_CAP
		,CTR.DIAS_TRAS_INT          ,DEF.TASA_FIJA_O_VAR
		,DEF.COD_TASA_BASE          ,DEF.FACTOR_SOBRETASA
		,DEF.SOBRETASA              ,vTasaInteres
		,DEF.COD_TASA_MORA          ,DEF.SOBRETASA_MORA
		,DEF.FACT_SOBRET_MORA       ,vTasaMora
		,''                         ,''
		,TIP.ES_FISICA              ,''
		,''
		,DEF.TIPO_CALCULO
		,''                         ,SOL.REV_TASA_VAR_PER
		,DEF.DIA_PARA_REVISAR       ,''
		,'M'
		,vNumCredito                ,0
		,0                          ,0
		,''                         ,''
		,P_MTOENGANCHE --PRUEBAS 16082018
		,cta_Clabe
	FROM   bdisolic:"informix".ss_SOLICITUDES SOL
		, bdisolic:"informix".ss_ANEXOSOL    ANX
		, bdinteg:"informix".si_CLIENTE      CLI
		, bdinteg:"informix".si_TIPPER       TIP
		, "informix".SD_CODTRASP             CTR
		, "informix".SD_DEFINICIONCRD           DEF
	WHERE  DEF.EMPRESA         = SOL.EMPRESA
	AND    DEF.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
	AND    CTR.PERIOD_PAG_INT  = "3"
	AND    CTR.PERIOD_PAGO_CAP = "2"
	AND    CTR.NUM_PRODUCTO    = DEF.NUM_PRODUCTO
	AND    CTR.EMPRESA         = DEF.EMPRESA
	AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
	AND    CLI.NUMCTE          = SOL.NUMCTE
	AND    CLI.EMPRESA         = SOL.EMPRESA
	AND    ANX.NUM_SOLICITUD   = SOL.NUM_SOLICITUD
	AND    ANX.EMPRESA         = SOL.EMPRESA
	AND    SOL.NUM_SOLICITUD   = P_SOLICITUD
	AND    SOL.EMPRESA         = P_EMPRESA;

	--**ACTUALIZA  LA TARJETA CON EL NO. DE CREDITO REESTRUCTURADO

	UPDATE bdicred:"informix".sd_MAECRED
	SET credito_externo = P_SOLICITUD
	WHERE empresa     = P_EMPRESA
	AND num_credito = vNumCredito;

	--***** ACTUALIZA SD_MAECREDANEXO (DATOS PARA TARJETA DE CREDITO)
	-- CALL bdicred:"informix".monthadd(mdy(month(vFechaApertura),'01',year(vFechaApertura)),1) RETURNING vproxfechapagaux;
	-- CALL bdicred:"informix".sp_valfechabil(mdy(month(vproxfechapagaux),vDiaCorte,year(vproxfechapagaux)),'+') RETURNING vCodRet, vproxfechapag;

	INSERT INTO bdicred:"informix".sd_maecredanexocrd
			(empresa,               num_credito,
			dia_corte,             dias_gracia_mora,
			tp_dias_calc_mora,     dias_fecha_max_pago,
			tp_dias_fecha_pago,    cod_tasa_base_cte,
			factor_sobretasa_cte,  sobretasa_cte,
			tasa_interes_cte,      prox_fecha_pago,
			fecha_proceso)
	SELECT {+INDEX ("informix".sd_definicioncrd)}
		   P_EMPRESA,               P_SOLICITUD,
		   vDiaCorte          ,           def.campo_3,
		   def.pago_adic_sig_cuota,   def.tpo_persona,
		   def.maneja_linea,        def.cod_tasa_base,
		   def.factor_sobretasa,    def.sobretasa,
		   vTasaFavor,            vproxfechapag,
		   vFechaApertura
	FROM bdicred:"informix".sd_definicioncrd def,
		bdisolic:"informix".ss_solicitudes c
	WHERE c.empresa = P_EMPRESA
	AND c.num_solicitud = P_SOLICITUD
	AND def.empresa = c.empresa
	AND def.num_producto = c.num_producto;

      --***** ACTUALIZA SD_MAESDOS
         INSERT INTO bdicred:"informix".sd_MAESDOScrd 
                                (EMPRESA                ,NUM_CREDITO
                                ,FECHA_ULT_MOV          ,SDO_INT_ANTICIP
                                ,SDO_INT_ANT_DEV        ,SDO_INTERESES
                                ,SDO_DIA_ANT_INT        ,SDO_MES_ANT_INT
                                ,SDO_ACUM_MES_INT       ,SDO_RETENIDO
                                ,SDO_ACUM_CAP_INT       ,SDO_EXIG_INT
                                ,SDO_NO_EXIG            ,PROVISION_NORMAL
                                ,DIAS_ACUM_INT          ,SDO_MORATORIO
                                ,SDO_DIA_ANT_MOR        ,SDO_MES_ANT_MOR
                                ,SDO_CONTAB_MORA        ,DIAS_ACUM_MORA
                                ,SDO_CAPITAL            ,SDO_CAP_INSOLUTO
                                ,SDO_DIA_ANT_CAP        ,SDO_MES_ANT_CAP
                                ,SDO_ACUM_MES_CAP       ,MTO_CAPITALIZADO
                                ,MTO_MINISTRA_CAP       ,CARGOS_DIA_CAP
                                ,ABONOS_DIA_CAP         ,CARGOS_MES_CAP
                                ,ABONOS_MES_CAP         ,DIAS_ACUM_CAP
                                ,MONTO_VENCIDO          ,MTO_VENC_TRASP
                                ,MONTO_FINANCIADO       ,MONTO_RESERVADO
                                ,SDO_ACUM_VENCIDO       ,DIAS_ACUM_INTPER
                                ,SDO_GLOBAL_INT         ,SDO_ACUM_INTPER
                                ,MONTO_OTORGADO         ,PROVI_VENC_NORMAL
                                ,PROVI_VENC_ANTICIP     ,CAP_TRAS_NO_VENCI
                                ,MTO_VENC_INT           ,MTO_VENC_TRA_INT
                                ,MTO_FINAN_VDO          ,MTO_RESER_INT
                                ,MTO_FIN_VEN_TRASP      ,MTO_FIN_VIG_TRASP
                                ,INT_TRA_NO_EXIG        ,SDO_TRAB4
                                ,ATR)
                          SELECT SOL.EMPRESA            ,P_SOLICITUD
                                ,vFechaApertura         ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                --,0                      ,SOL.MONTO_SOLICITADO-P_MTOENGANCHE
								,CASE WHEN cIFRS = 'A' THEN  SOL.MONTO_SOLICITADO-P_MTOENGANCHE ELSE 0 END, SOL.MONTO_SOLICITADO-P_MTOENGANCHE
                                ,0                      ,SOL.MONTO_SOLICITADO-P_MTOENGANCHE
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,vPagCuota              ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,SOL.MONTO_SOLICITADO-P_MTOENGANCHE   ,0
                                --,0                      ,SOL.MONTO_SOLICITADO-P_MTOENGANCHE
								,0    ,CASE WHEN cIFRS = 'A' THEN  0 ELSE SOL.MONTO_SOLICITADO-P_MTOENGANCHE END 
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,vPagCuota
								,iAtr_Act_ifrs
                          FROM   bdisolic:"informix".ss_SOLICITUDES SOL
                          WHERE  SOL.NUM_SOLICITUD = P_SOLICITUD
                          AND    SOL.EMPRESA   = P_EMPRESA;

	--  FMV 23abr13: Inserta cascaron para indicadores de prestamo a plazo
	INSERT INTO bdicred:"informix".sd_indicador_cred_crd
			(empresa, num_credito, fecha_alta)
	VALUES (P_EMPRESA, P_SOLICITUD, vFechaApertura);

    -- *********************************************************
                  -- INSERTA LA  TABLA DE AMORTIZACIONES *
    -- *********************************************************
	
	FOREACH
		SELECT fecha_cuota,capital_cuota,sum(capital_cuota + interes_cuota + iva_cuota)
		INTO vFechaT, vCapDebe,vPagCuota
		FROM bdicred:"informix".sd_proyecta
		WHERE empresa = P_EMPRESA
		AND num_solicitud = P_SOLICITUD
		GROUP BY 1,2
		ORDER BY fecha_cuota  -- BGM 21-Mayo-10 se ordena por fecha cuota
		INSERT INTO sd_amortiza_creditocrd values   
				(P_EMPRESA,P_SOLICITUD,vFechaT,"3",vPagCuota,vCapDebe,0,"4","0","",  -- BGM 21-May-2010 se considera 4 estatus de capital
				0,0,"3","0","", 0,0,"1","0","", 0,0,0,0,0,0,0,"1", 0,0,"1?","",   -- BGM 21-May-2010 se considera variable para numero de cuota en el campo num_pago
				vCuenta,0,0,"","");
			   
		LET vCuenta=vCuenta+1;  -- BGM 21-May-2010 se incrementa variable para numero de cuota en el campo num_pago

	END FOREACH;

	UPDATE bdicred:"informix".sd_amortiza_creditocrd set capital_status = '3'   -- BGM 21-May-2010 se actualiza capital status de primer cuota a 3
	WHERE num_credito = P_SOLICITUD AND num_pago = 1;

    -- **************************************
    -- Actualiza el Estatus de la Solicitud *
    -- Complemento De Datos                 *
    -- **************************************

    SELECT periodo_plazo    , plazo          , divisa          ,tipo_calculo,
			cod_tasa_base    , sobretasa      , factor_sobretasa,
			tasa_interes     , tasa_fija_o_var, cod_tasa_mora   ,
			fact_sobret_mora , sobretasa_mora , tasa_moratorios ,
			period_pago_cap  , period_pag_int , fecha_apertura  ,
			fecha_vencim
    INTO vPerPlazo          , vPlazo         , vDivisa         , vTipoCalculo,
			vCodTasInt         , vSobretasa     , vFacSobreTasa   ,
			vTasaInteres       , vTasaFijVar    , vCodTasaMora    ,
			vFacSobretMora     , vSobretMora    , vTasaMora       ,
			vPerPagCap         , vPerPagInt     , vFecApert       ,
			vFecVenc
	FROM bdicred:"informix".sd_maecredcrd
	WHERE empresa = P_EMPRESA
	AND num_credito = P_SOLICITUD;

    UPDATE bdisolic:"informix".ss_solicitudes
                SET status_solicitud = "AP",
                    tipo_prestamo    = "C",
                    periodo_plazo    = vPerPlazo,
                    plazo            = vPlazo,
                    divisa           = vDivisa,
                    tipo_calculo     = vTipoCalculo,
                    cod_tasa_base    = vCodTasInt,
                    sobretasa        = vSobretasa,
                    factor_sobretasa = vFacSobreTasa,
                    tasa_interes     = vTasaInteres,
                    tasa_fija_o_var  = vTasaFijVar ,
                    cod_tasa_mora    = vCodTasaMora,
                    factor_moratorio = vFacSobretMora,
                    sobretasa_mora   = vSobretMora,
                    tasa_moratorios  = vTasaMora ,
                    periodo_pag_cap  = vPerPagCap,
                    periodo_pag_int  = vPerPagInt,
                    fecha_apert_prop = vFecApert,
                    fecha_venc_prop  = vFecVenc,
                    co_numcte        = P_NUMCTA
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD;

	SELECT nombre INTO vMensaje
	FROM bdinteg:"informix".si_ejecut
	WHERE ejecutivo = P_EJECUTIVO
	AND empresa = P_EMPRESA;

    LET vMensaje = "Apertura de Credito Autorizada por: " || TRIM(vMensaje);

    INSERT INTO bdisolic:"informix".ss_autorizacion
        (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
         comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
	VALUES(P_EMPRESA, P_EJECUTIVO, P_SOLICITUD, "AP", vMensaje,
	    vFechaApertura, vFechaApertura, USER, TODAY);


    -- Resta el Valor de la Tasa Moratoria con la de Intereses
    -- Solicitado por el Banco JLP 23May2008

    LET vTasaMora = vTasaMora - vTasaInteres;
    IF vTasaMora < 0 THEN --Si es Menor a Cero la vuelve Positivo
		LET vTasaMora = vTasaMora * -1;
    END IF

	SELECT {+INDEX ("informix".sd_definicioncrd)}
		a.num_producto, a.divisa, b.monto_solicitado, b.sucursal
	INTO vProducto, vDivisa, P_MTOSOL, vSucursal
	FROM bdisolic:"informix".ss_solicitudes b, 
		bdicred:"informix".sd_definicioncrd a
	WHERE b.empresa = P_EMPRESA
	AND b.num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto;


	--** EXTRAE EL MONTO DE LA REESTRUCTURA
	SELECT otro_copresta
	INTO   vMtoReestruc
	FROM   bdisolic:"informix".ss_anexosol
	WHERE  num_solicitud = P_SOLICITUD;

	 --**GENERA MOVIMIENTO DE APERTURA

	EXECUTE PROCEDURE "informix".GENMOVCRD( P_EMPRESA       , P_SOLICITUD,
		vProducto       , 2,
		"001"           , vFechaApertura,
		P_MTOSOL-P_MTOENGANCHE        , vFolio,
		vSucursal       ,vDivisa,
		"0000","APERTURA REESTRUCTURA","")
	INTO vCodRet, P_MENSAJE;

	IF vCodRet <> '000000' THEN
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		IF P_MTOENGANCHE>0 THEN
			EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
											   P_NUMCTA, 0,P_MTOENGANCHE, P_MTOENGANCHE,
											   0,0,0,vt_codigo_mn, P_SOLICITUD ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
			INTO vCodRet;
		END IF;
		RETURN '00'||vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;

	EXECUTE PROCEDURE "informix".GENMOVCRD( P_EMPRESA       , P_SOLICITUD,
					vProducto       , 1,
					"002"           , vFechaApertura,
					P_MTOSOL-P_MTOENGANCHE        , vFolio,
					vSucursal       ,vDivisa,
					"0000","APERTURA REESTRUCTURA","")
	INTO vCodRet, P_MENSAJE;

	IF vCodRet <> '000000' THEN
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		IF P_MTOENGANCHE>0 THEN
			EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
										   P_NUMCTA, 0,P_MTOENGANCHE, P_MTOENGANCHE,
										   0,0,0,vt_codigo_mn, P_SOLICITUD ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
			INTO vCodRet;
		END IF;
		RETURN '00'||vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;
	
	--SE realiza el marcaje del cliente RQI 27 100 JMAH
	EXECUTE PROCEDURE bdisitesp:"informix".sp_marcajesitesp('001',2,P_NUMCTE, p_ejecutivo)
	INTO vCodRet, P_MENSAJE;
	
	LET vCodRet  = '00000';
	COMMIT WORK;
	IF (wBegin = "S") THEN
		BEGIN WORK;
	END IF;
	RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
END PROCEDURE
DOCUMENT
'FOLIO: 438-RQM 10 1024-Actualizacion de las tablas de amortizacion para Prestamo Personal y Reestructura',
'MODIFICO: 95358897 - ISARAI BOJORQUEZ',
'MODIFICACION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR EL MONTO DE ENGANCHE AL CAMPO valor_preferencial DE LA TABLA sd_maecredcrd Y CAMBIAR',
'VALOR DEL PARAMETRO P_MTOENGANCHE DECIMAL (18,2)',
'FECHA: 29/08/2018 ',
'BD:BDICRED';

CREATE PROCEDURE "informix".sp_consulta_credito_hoy_iccat(pEmpresa char (3), pNumCred char(12), pFecha date)
	returning char(5), DECIMAL(14,2), DECIMAL(14,2), DECIMAL(14,2), DECIMAL(14,2), 
				DECIMAL(14,2),DECIMAL(14,2),DECIMAL(14,2),DECIMAL(14,2),DECIMAL(14,2);
   -----------------------------------------------------------------------
   --Elaboró: Ramon Octavio Romero Mascareño							--
   --Actividad: consulta estado de cuenta de credito al dia de hoy		--
   --Solicito: Mauricio León											--
   --Fecha: 14/05/09													--
   -----------------------------------------------------------------------
   --DEFINE
    DEFINE cod_ret 				char(5);
    DEFINE sql_err 				integer;
	DEFINE vCapital 			DECIMAL(14,2);
	DEFINE vCapitalVen 			DECIMAL(14,2);
	DEFINE vInteresesVen 		DECIMAL(14,2);
	DEFINE vIvaInteresesVen 	DECIMAL(14,2);
	DEFINE vIntMoratorios 		DECIMAL(14,2);
	DEFINE vIvaIntMoratorios 	DECIMAL(14,2);
	DEFINE vPagoNoIntereses 	DECIMAL(14,2);
	DEFINE vPagoMinimo 			DECIMAL(14,2);
	DEFINE vSaldoHoy 			DECIMAL(14,2);
	--temporales
	DEFINE vIvaDebe 			DECIMAL(14,2);
	DEFINE vFechaCouta 			DECIMAL(14,2);
	DEFINE vCapitalStatus 		DECIMAL(14,2);
	DEFINE vInteresesVenTem		DECIMAL(14,2);
	DEFINE vSdoMora				DECIMAL(14,2);
	
	--Inicializa
	LET cod_ret 				= '000';
	LET vCapital 				= 0;
	LET vCapitalVen 			= 0;
	LET vInteresesVen 			= 0;
	LET vIvaInteresesVen 		= 0;
	LET vIntMoratorios 			= 0;
	LET vIvaIntMoratorios 		= 0;
	LET vPagoNoIntereses 		= 0;
	LET vPagoMinimo 			= 0;
	LET vSaldoHoy 				= 0;
	--temporales
	LET vIvaDebe 				= 0;
	LET vFechaCouta 			= 0;
	LET vCapitalStatus 			= 0;
	LET vInteresesVenTem		= 0;
	LET vSdoMora				= 0;

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vCapital, vCapitalVen ,vInteresesVen ,vIvaInteresesVen ,vIntMoratorios ,vIvaIntMoratorios ,vPagoNoIntereses ,vPagoMinimo ,vSaldoHoy;
      END IF ;
   END EXCEPTION ;

   if pNumCred == '' then
	let cod_ret = '001';
   end if
	   
    SET ISOLATION DIRTY READ ;

		select sdo_capital, (monto_vencido + mto_venc_trasp), int_tra_no_exig, (sdo_moratorio + sdo_contab_mora), sdo_cap_insoluto
		into vCapital, vCapitalVen, vInteresesVen, vIntMoratorios, vPagoNoIntereses
		from sd_maesdos
		where empresa = pEmpresa and num_credito = pNumCred;

		select (iva_debe - iva_pagado), capital_status 
		into vIvaInteresesVen, vCapitalStatus
		from sd_amortiza_credito
		where empresa = pEmpresa and num_credito = pNumCred and fecha_cuota = pFecha;
		
		if vCapitalStatus <> 2 and vCapitalStatus <> 7 and vCapitalStatus <> 6 then
			let vIvaInteresesVen = 0;
		end if
		
		let vIvaIntMoratorios = (vIntMoratorios * .15);
	
   RETURN cod_ret, vCapital, vCapitalVen ,vInteresesVen ,vIvaInteresesVen ,vIntMoratorios ,vIvaIntMoratorios ,vPagoNoIntereses ,vPagoMinimo ,vSaldoHoy;
END

END PROCEDURE;