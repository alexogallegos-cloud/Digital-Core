CREATE PROCEDURE "informix".sp_reporte_bimestral_reest_pp()
RETURNING   CHAR(5) 	AS retorno; --,
            --CHAR(100)   AS mensaje_ret;

--DeclaraciÃÂ³n de variables.
     
                         
                       


DEFINE v_num_credito            CHAR(20); 
DEFINE v_folio_credito          CHAR(20);
DEFINE v_fecha_apertura         CHAR(12);
DEFINE v_reestructura	        SMALLINT;
DEFINE v_condonaciones          DECIMAL(18,2);

DEFINE iSqlErr      			INTEGER;
DEFINE iIsamErr         		INTEGER;
DEFINE cErrorInfo       		CHAR(100);
DEFINE cCodRet          		CHAR(6);
DEFINE cMensajeRet    			CHAR(100);
DEFINE pPeriodo              	DATE;
DEFINE piniPeriodo				DATE;
DEFINE flag_aniobis				INTEGER;
DEFINE cRuta CHAR (50);
DEFINE cBitCamp CHAR (50);
DEFINE cCadena  CHAR (1500);

--INICIALIZACION DE VARIABLES

LET v_num_credito            =''; 
LET v_folio_credito          ='';
LET v_fecha_apertura         ='';
LET v_reestructura	         =0;
LET v_condonaciones          =0;

LET iSqlErr                  = 0;
LET iIsamErr         		 = 0;
LET cErrorInfo       		 = "";
LET cCodRet          		 = "00000";
LET cMensajeRet    			 = "REPORTE BIMESTRAL REESTRUCTURA se realizÃÂ³ correctamente";
LET cRuta = '';
LET cBitCamp = '';
LET cCadena = '';


BEGIN
    --Errores no controlados.
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;

          RETURN cCodRet; --, cMensajeRet;
    END EXCEPTION;

    --SET DEBUG FILE TO "/RESPALDOSNEW/SI1556/sp_reporte_bimestral_pp.out";
    --TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;

   -- LET pPeriodo = mdy(month(today),1,year(today)) - 1 units day;
   --IPCB  Se cambia por consulta a la BD
	SELECT pri_dia_mes-1 units day , pri_dia_mes-2 units month  
	INTO pPeriodo, piniPeriodo
	FROM bdicred:sd_fechas;
	
	
	LET cRuta="/resplogifx/archivosriesgos/";	
	LET cBitCamp="bim_reestructuras_pp";
	LET cBitCamp= TRIM(cBitCamp)||'_'||YEAR(today)||LPAD(MONTH(today),2,0)||LPAD(DAY(today),2,0)||'.unl';

--Reproceso de Junio
--LET pPeriodo = mdy('06','30','2018');
--LET piniPeriodo = mdy('06','01','2018');
--Reproceso de Junio	

--Valida Anio Bisiesto
IF mod(year(pPeriodo),4) = 0 AND ((mod(year(pPeriodo),4)) = 0 OR (mod(year(pPeriodo),4) = 0)) THEN
	LET flag_aniobis = 1;
ELSE
	LET flag_aniobis = 0;
END IF;
	
	
    FOREACH WITH HOLD
        
        SELECT 
        num_credito, 
		fecha_apertura, --TO_CHAR(fecha_apertura, '%Y/%m/%d') as fecha_apertura, 
		500 as reestructura,
		monto_condonado as condonaciones
		INTO v_num_credito, v_fecha_apertura, v_reestructura, v_condonaciones
        FROM sd_insumos_calif_reest_pp 	
        WHERE num_producto in('8600')
		AND status_fin_mes in('AA','BA','BT','VP','E1','E2','E3')
		and fecha_cierre=pPeriodo --MES PAR	
		
		select credito_externo INTO v_folio_credito
		from sd_maecredcrd
		where num_credito=v_num_credito;		
				
        BEGIN WORK;
		
			INSERT INTO sd_reporte_bimestral_reest_pp ( fecha_cierre, num_credito, fecha_apertura, reestructura, condonaciones, num_credito2)
			VALUES( pPeriodo, v_folio_credito, v_fecha_apertura, v_reestructura, v_condonaciones, v_num_credito);
		COMMIT WORK;
		
	END FOREACH; 
	
	LET cCadena = '';
	LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitCamp)  ||'  delimiter '';'' SELECT num_credito, fecha_apertura, reestructura, condonaciones, num_credito2 FROM bdicred:"informix".sd_reporte_bimestral_reest_pp WHERE fecha_cierre= ''' ||mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo))|| '''" >'||TRIM(cRuta)||'bim_reestructuras_pp.sql';
	SYSTEM cCadena;				
	LET cCadena='chmod 777 '|| TRIM(cRuta)||'bim_reestructuras_pp.sql';
	System cCadena;				
	let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bim_reestructuras_pp.sql';
	System cCadena;				
	LET cCadena = '' ;
	LET cCadena = 'rm ' || TRIM(cRuta) || 'bim_reestructuras_pp.sql';
	SYSTEM cCadena;
	
    LET cCodRet     = "00000";
    LET cMensajeRet = "REPORTE DE BIMESTRALES REESTRUCTURAS PP OK ";

	RETURN cCodRet; --, cMensajeRet;
END
END PROCEDURE
;