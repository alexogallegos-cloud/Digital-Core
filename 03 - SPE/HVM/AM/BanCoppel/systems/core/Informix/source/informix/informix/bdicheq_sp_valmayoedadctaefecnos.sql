CREATE PROCEDURE "informix".sp_valmayoedadctaefecnos()
RETURNING char(5);
    
    DEFINE cCodret          char(5);
    DEFINE cVar             char(5);
    DEFINE cEmpresa         char(3);
    DEFINE cCuenta          char(20);
    DEFINE cNumcte          char(9);
    DEFINE cCliente         char(70);
    DEFINE dFecha_nac       char(10);
    DEFINE cEdad            char(5);
    DEFINE cTelefono1       char(13);
    DEFINE cTelefono2       char(13);
    DEFINE cEmail           char(60);
    DEFINE mSdo_actual      money;
    DEFINE iSQL_ERR         integer;
    DEFINE iBandera         integer;
    DEFINE cDescripcion     char(35);
    DEFINE cFecha           char(10);
    DEFINE vabierto         CHAR(1);
    DEFINE vcomienza        INTEGER;
    DEFINE vexiste_ctabloq  CHAR(20);
    DEFINE vexiste_invcrec  SMALLINT;
    DEFINE vexiste_pagare   SMALLINT;
    DEFINE vdFechaHoy       DATE;
    DEFINE mSdoSBC          MONEY(14,2);
    DEFINE mSdoRet          MONEY(14,2);
    DEFINE mSdoCong         MONEY(14,2);
    DEFINE mSdoSBG          MONEY(14,2);
    DEFINE mComPend         MONEY(14,2);
    
    LET cCuenta     = "";		
    LET cNumcte     = "";		
    LET cCliente    = "";		
    LET cEdad       = 0.0;	
    LET cTelefono1  = "";		
    LET cTelefono2  = "";		
    LET cEmail      = "";		
    LET mSdo_actual = 000.00;	
    LET iSQL_ERR    = 100 ;
    LET cCodret     = "000";
    LET dFecha_nac  = "";
    LET iBandera    = 1;
    LET cEmpresa    = "";
    LET cVar        = "";
    LET vabierto    = "0";
    LET vcomienza   = -1;
    LET vexiste_ctabloq = '';
    LET vexiste_invcrec = 0;
    LET vexiste_pagare = 0;
    LET vdFechaHoy  = '';
    LET mSdoSBC = 0;
    LET mSdoRet = 0;
    LET mSdoCong = 0;
    LET mSdoSBG = 0;
    LET mComPend = 0;
    
    --- SET DEBUG FILE TO '/tmp/sp_valmayoedadctaefecnos.out';
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET iSQL_ERR
        LET cCodret = iSQL_ERR;
        IF vabierto = "1" THEN
            ROLLBACK WORK;
        END IF;
        RETURN cCodret;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vdFechaHoy
      FROM sc_fechas
     WHERE empresa = '001';
    
    FOREACH WITH HOLD
        SELECT mae.empresa, mae.cuenta, sicte.numcte, 
               TRIM(sicte.apell_paterno)||' '||TRIM(sicte.apell_materno)||' '||TRIM(sicte.nombre1)||' '||TRIM(sicte.nombre2) AS cliente,
               ctepf.fecha_nac, 
               SUBSTR( ( YEAR(fecha.fecha_hoy) + MONTH(fecha.fecha_hoy)/12 + DAY(fecha.fecha_hoy)/30/12 ) - 
                       ( YEAR(ctepf.fecha_nac) + MONTH(ctepf.fecha_nac)/12 + DAY(ctepf.fecha_nac)/30/12 ), 0, 4 ) AS edad,
               tel1.telefono, tel2.telefono, core.correo_elec, mae.sdo_actual, fecha.fecha_hoy,
               mae.imp_chq_sbc, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.com_pendiente
          INTO cEmpresa, cCuenta, cNumcte, cCliente, dFecha_nac, cEdad, cTelefono1, cTelefono2, cEmail, mSdo_actual, cFecha,
               mSdoSBC, mSdoRet, mSdoCong, mSdoSBG, mComPend
          FROM bdicheq:sc_maechq mae
         INNER JOIN bdinteg:si_cliente sicte ON sicte.numcte = mae.num_cte
         INNER JOIN bdinteg:si_ctepf ctepf ON ctepf.numcte = mae.num_cte
         INNER JOIN bdicheq:sc_fechas fecha ON (fecha.fecha_hoy > ctepf.fecha_nac AND fecha.empresa = mae.empresa)
	      left outer join bdinteg:si_telefonos_actual tel1 on (tel1.numcte = mae.num_cte and tel1.tipo_tel = 1)
	      left outer join bdinteg:si_telefonos_actual tel2 on (tel2.numcte = mae.num_cte and tel2.tipo_tel = 2)
	      left outer join bdinteg:si_correos core on (core.numcte = mae.num_cte and core.tipo_correo = 1 and core.status_correo ='A')
         WHERE mae.producto = '1500'
           AND mae.status_cta IN('1','4')
           AND ( ( YEAR(fecha.fecha_hoy) + MONTH(fecha.fecha_hoy)/12 + DAY(fecha.fecha_hoy)/30/12 ) - 
                 ( YEAR(ctepf.fecha_nac) + MONTH(ctepf.fecha_nac)/12 + DAY(ctepf.fecha_nac)/30/12 ) >= 18.5 )
         
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
            LET vabierto = "1";
        END IF;
        
        SELECT COUNT(*)
          INTO vexiste_invcrec
          FROM bdicheq:sc_maeinstrucc ins,
               bdicheq:sc_maechq mae
         WHERE ins.empresa = mae.empresa
           AND ins.cuenta = mae.cuenta
           AND ins.cuentadep = cCuenta
           AND mae.status_cta <> '2';
           
        SELECT COUNT(*)
          INTO vexiste_pagare
          FROM bdinvers:sv_maeinv
         WHERE status_cta = '1'
           AND cta_cheques = cCuenta;
           
        IF vexiste_invcrec = 0 AND vexiste_pagare = 0 THEN
            IF ( mSdo_actual = 0 AND mSdoSBC = 0 AND mSdoSBG = 0 AND mComPend = 0 ) THEN
                UPDATE bdicheq:sc_maechq 
                   SET status_cta = '2', 
                       motivo = "00",
                       fec_cancelac = vdFechaHoy
                 WHERE empresa = '001'
                   AND cuenta = cCuenta;
            
                INSERT INTO bdicheq:sc_movctaefecnos 
                (cuenta, status, fecha_ins) 
                VALUES 
                (cCuenta, '2', cFecha);
            ELSE
                CALL bloqueo_cta(cEmpresa, cCuenta, 0, '02', '2', cFecha, 'informix', '', '', '','','') 
                RETURNING cCodret, cVar;
                
                SELECT UNIQUE cuenta
                  INTO vexiste_ctabloq
                  FROM bdicheq:sc_ctabloqueo
                 WHERE cuenta = cCuenta;
                 
                IF vexiste_ctabloq is null OR vexiste_ctabloq = '' THEN            
                    INSERT INTO bdicheq:sc_ctabloqueo 
                    (cuenta, clave, opcion, cve_area,cod_area, cve_tipobloq, cod_tipobloq ) 
                    VALUES 
                    (cCuenta, '02', '2', '', '', '', '' );
                    
                    INSERT INTO bdicheq:sc_ctabloqueohist 
                    (cuenta, clave, opcion) 
                    VALUES 
                    (cCuenta, '02', '2');
                END IF
                
                INSERT INTO bdicheq:sc_movctaefecnos 
                (cuenta, status, fecha_ins) 
                VALUES 
                (cCuenta, '3', cFecha);
            END IF
        END IF;
    
        LET iBandera = cCodret;
            
        IF vabierto = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    IF vabierto = 1 THEN
        COMMIT WORK;
    END IF;
        
    IF iBandera <> 000 THEN
        LET cCodret = '000';
        LET cCliente = 'No se encontraron registros';
        RETURN cCodret;
    ELSE
        RETURN cCodret;
    END IF
    
    END;
    
END PROCEDURE;