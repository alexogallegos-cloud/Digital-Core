CREATE PROCEDURE "informix".sp_reporte_bim_bajas_nom()
RETURNING   CHAR(5) 	AS retorno; ---,
            --CHAR(100)   AS mensaje_ret;

--Declaración de variables.
DEFINE v_num_credito             	 CHAR(20);
DEFINE v_num_producto             	 CHAR(4);
DEFINE v_status_cred				 CHAR(2);
DEFINE v_tipo_credito                SMALLINT;
DEFINE v_baja_cred                   CHAR(12);
DEFINE v_tipo_baja_cred              SMALLINT;
DEFINE v_mto_perdonado               DECIMAL(18,2);
DEFINE iSqlErr      				 INTEGER;
DEFINE iIsamErr         			 INTEGER;
DEFINE cErrorInfo       			 CHAR(100);
DEFINE cCodRet          			 CHAR(6);
DEFINE cMensajeRet    				 CHAR(100);
DEFINE pPeriodo              		 DATE;
DEFINE piniPeriodo					 DATE;
DEFINE flag_aniobis					 INTEGER;
DEFINE cRuta CHAR (50);
DEFINE cBitCamp CHAR (50);
DEFINE cCadena  CHAR (1500);

--INICIALIZACION DE VARIABLES
LET v_num_credito             	  ="";
LET v_num_producto             	  ="";
LET v_status_cred				  ="";
LET v_tipo_credito                =0;
LET v_baja_cred                   ="";
LET v_tipo_baja_cred              =0;
LET v_mto_perdonado               =0.00;
LET iSqlErr                         = 0;
LET iIsamErr         				= 0;
LET cErrorInfo       				= "";
LET cCodRet          				= "00000";
LET cMensajeRet    					= "REPORTE BIMESTRAL BAJAS NOMINA se realizó correctamente";
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

    --SET DEBUG FILE TO "/ifxsif01/tmp/b_pp/proceso_dic_bajas_nomina/sp_reporte_bimestral_bajas_nom.out";
   -- TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;

   -- LET pPeriodo = mdy(month(today),1,year(today)) - 1 units day;
   --IPCB  Se cambia por consulta a la BD
	SELECT pri_dia_mes-1 units day , pri_dia_mes-2 units month  
	INTO pPeriodo, piniPeriodo
	FROM bdicred:sd_fechas;
	
	LET cRuta="/resplogifx/archivosriesgos/";	
	LET cBitCamp="bim_bajas_nom";
	LET cBitCamp= TRIM(cBitCamp)||'_'||YEAR(today)||LPAD(MONTH(today),2,0)||LPAD(DAY(today),2,0)||'.unl';

--Reproceso de Junio
--LET pPeriodo = mdy('06','30','2018');
--LET piniPeriodo = mdy('05','01','2018');
--Reproceso de Junio	

--Valida Anio Bisiesto
IF mod(year(pPeriodo),4) = 0 AND ((mod(year(pPeriodo),4)) = 0 OR (mod(year(pPeriodo),4) = 0)) THEN
	LET flag_aniobis = 1;
ELSE
	LET flag_aniobis = 0;
END IF;

	
    FOREACH WITH HOLD
        
        SELECT a.num_credito,
		30 as tipo_credito, 
		TO_CHAR(b.fecha_proceso, '%Y/%m/%d') as fecha_proc, 
		case when a.status_cred ='CV' then 50 else 60 end tipo_baja_cred,
		0.00 as mto_perdonado
		--INTO v_num_credito,v_tipo_credito,v_baja_cred,v_tipo_baja_cred,v_mto_perdonado
		FROM sd_maecredcrd a, 
		sd_maecredanexocrd b
		WHERE a.num_credito=b.num_credito
		and a.status_cred IN('FF','CV','FI', 'FC')
		and b.fecha_proceso>=piniPeriodo
		and b.fecha_proceso<=pPeriodo
		and a.num_producto in('6400')
	UNION ALL
		SELECT a.num_credito,
		30 as tipo_credito, 
		TO_CHAR(b.fecha_proceso, '%Y/%m/%d') as fecha_proc,  
		case when a.status_cred ='CV' then 50 else 60 end tipo_baja_cred,
		0.00 as mto_perdonado
		INTO v_num_credito,v_tipo_credito,v_baja_cred,v_tipo_baja_cred,v_mto_perdonado
		FROM sd_maecred a, 
		sd_maecredanexo b
		WHERE a.num_credito=b.num_credito
		and a.status_cred IN('FF','CV','FI', 'FC')
		and b.fecha_proceso>=piniPeriodo
		and b.fecha_proceso<=pPeriodo
		and a.num_producto in('7800')
							
        BEGIN WORK;
            INSERT INTO sd_reporte_bim_bajas_nom (fecha_cierre,num_credito,tipo_credito,fecha_baja_cred,tipo_baja_cred,mto_perdonado)
                 VALUES( pPeriodo,v_num_credito,v_tipo_credito,v_baja_cred,v_tipo_baja_cred,v_mto_perdonado);
      	COMMIT WORK;
	
	END FOREACH; 
	
	LET cCadena = '';
	LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitCamp)  ||'  delimiter '';'' SELECT num_credito,tipo_credito,fecha_baja_cred,tipo_baja_cred,mto_perdonado FROM bdicred:"informix".sd_reporte_bim_bajas_nom WHERE fecha_cierre= ''' ||mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo))|| '''" >'||TRIM(cRuta)||'bim_bajas_nom.sql';
	SYSTEM cCadena;				
	LET cCadena='chmod 777 '|| TRIM(cRuta)||'bim_bajas_nom.sql';
	System cCadena;				
	let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bim_bajas_nom.sql';
	System cCadena;				
	LET cCadena = '' ;
	LET cCadena = 'rm ' || TRIM(cRuta) || 'bim_bajas_nom.sql';
	SYSTEM cCadena;
	
    LET cCodRet     = "00000";
    LET cMensajeRet = "REPORTE BIMESTRAL BAJAS NOMINA OK ";

	RETURN cCodRet; --, cMensajeRet;
END
END PROCEDURE
;