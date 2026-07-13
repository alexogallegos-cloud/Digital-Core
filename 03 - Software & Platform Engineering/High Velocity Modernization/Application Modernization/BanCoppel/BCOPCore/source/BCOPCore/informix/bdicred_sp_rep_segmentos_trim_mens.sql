CREATE PROCEDURE "informix".sp_rep_segmentos_trim_mens(pEmpresa CHAR(3))
RETURNING CHAR(6);

--Creado por:Guadalupe Espinoza 08/10/2013
--Proceso para generar Reporte trimestral y mensual de uso de linea 
--Modificado Softtek 20/10/2023
--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE pMensaje				CHAR(80);
DEFINE pCod_ret				CHAR(6);
DEFINE vcCodRet 			CHAR(6);
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
DEFINE cSQL					CHAR(8204);
DEFINE cSQL1				CHAR(6204);
DEFINE cSQL2				CHAR(6204);
DEFINE cSQL3				CHAR(100);
DEFINE cCod_RetIB			CHAR(6);
DEFINE dFechaHoy			DATE;
DEFINE dFecha 				DATE;
DEFINE dFechatrim 			DATE;
DEFINE dFecha2 				DATE;
DEFINE dFecha3 				DATE;
DEFINE dFechaprim 			DATE;
DEFINE dDiaprimero  		DATE;
DEFINE dDiaUltimo   		DATE;
DEFINE canio        		CHAR(4);
DEFINE vsegmentos 			CHAR(12);
DEFINE vtotaltrimestre 		DECIMAL(18,2);
DEFINE totalint 			DECIMAL(18,2);
DEFINE sPaso				SMALLINT;
DEFINE sPaso2				SMALLINT;
DEFINE creotabla			CHAR(1);
DEFINE creotabla2			CHAR(1);


DEFINE v_fecha          DATE;
DEFINE v_num_credito    CHAR(12);
DEFINE v_NumTrans       CHAR(2);
DEFINE v_E_0            DECIMAL(18,2);
DEFINE v_E0             DECIMAL(18,2);
DEFINE v_E25            DECIMAL(18,2);
DEFINE v_E50            DECIMAL(18,2);
DEFINE v_E75            DECIMAL(18,2);
DEFINE v_E100           DECIMAL(18,2);
DEFINE v1_E_100         DECIMAL(18,2);
DEFINE v_sdo_intereses  DECIMAL(18,2);
DEFINE v_monto_compra   DECIMAL(18,2);
DEFINE v_monto_disp     DECIMAL(18,2);
DEFINE v_camp1          CHAR(12);
DEFINE v_camp2          INTEGER;
DEFINE contador_commit   INTEGER;
DEFINE val_trans_Commit   SMALLINT;


--SET DEBUG FILE TO "/resplogifx/archivoscredito/sp_rep_segmentos_trim_mens.out";
--TRACE ON;

--InicializaciÃ³n de variables
LET sql_err					= 0;
LET isam_err				= 0;
LET error_info				= "";
LET pCod_Ret				= "000000";
LET vcCodRet 				= "000000";
LET pMensaje				= 'PROCESO EXITOSO';
LET pproceso				= '2111';
LET pempresa				= '001';
LET pusuario				= USER;
LET cruta					= "";
LET cnombre					= "";
LET ntrimestre 				= "";
LET cnomarchivo				= "";
LET cnomarchivo1			= "";
LET cnumcte					= "";
LET cnumcred				= "";
LET cSQL					= "";
LET cSQL1					= "";
LET cSQL2					= "";
LET cSQL3					= "";
LET cCod_RetIB				= "000000";
LET dFechaHoy				= DATE(1);
LET dFecha 					= DATE(1);
LET dFechatrim 				= DATE(1);
LET dFecha2					= DATE(1);
LET dFecha3 				= DATE(1);
LET dFechaprim 					= DATE(1);
LET dDiaprimero 			= '';
LET dDiaUltimo 				= '';
LET canio   				= '';
LET vsegmentos 				= '';
LET vtotaltrimestre 		= 0;
LET totalint 				= 0;
LET sPaso					=0;
LET sPaso2					=0;
LET creotabla 				= '';
LET creotabla2 				= '';



LET v_fecha          =DATE(1);
LET v_num_credito    ='';
LET v_NumTrans       ='';
LET v_E_0            =0;
LET v_E0             =0;
LET v_E25            =0;
LET v_E50            =0;
LET v_E75            =0;
LET v_E100           =0;
LET v1_E_100         =0;
LET v_sdo_intereses  =0;
LET v_monto_compra   =0;
LET v_monto_disp     =0;
LET v_camp1          ='';
LET v_camp2          =0;
LET contador_commit   =0;
LET val_trans_Commit  =0;
	
BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET pCod_ret = sql_err;
        LET pMensaje = error_info;
        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '02')
        Returning cCod_RetIB;
        IF (val_trans_Commit = -1) THEN
		    ROLLBACK WORK;
	    END IF; 
        RETURN pCod_ret;
    END EXCEPTION;
	
    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '01')
	Returning cCod_RetIB;
		
	SELECT fecha_hoy,pri_dia_mes, pri_dia_mes - 1 units DAY, pri_dia_mes - 3 units MONTH INTO dFechahoy,dFechaprim, dFecha, dFechatrim
	FROM bdicred:sd_fechas
    WHERE empresa = pempresa; -- Sftk 181023
	
	LET dFecha2 = dFechaprim - 1 units MONTH - 1 units DAY;	LET dFecha3 = dFechaprim - 2 units MONTH - 1 units DAY;	LET canio = lpad(year(dFechatrim),4,'0');
	
	SELECT TRIM(valor_alfabetico) 
	INTO cRuta
	FROM bdicred:"informix".sd_param_campania 
	WHERE empresa = '001' and tipo_campania = 50 
	AND grupo_parametro = 'CAT_PROMOS' 
	AND num_parametro = 2;
	--let cruta = '/resplogifx/archivoscredito/'; --pruebas

	
    SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'creditostransaccion';
    IF NVL(sPaso,0) > 0 THEN
        ---DROP TABLE creditostransaccion;
        TRUNCATE TABLE creditostransaccion;
    END IF;
	
        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, '30-Inicia consulta principal-Mensual', '02')
        Returning cCod_RetIB; 
        --Reporte Mensual 
        --INSERT INTO bdicred:creditostransaccion
        FOREACH WITH HOLD
            SELECT  ind.fecha, ind.num_credito,  	
            CASE   
                WHEN ((sdo.mto_fin_ven_trasp) = 1) THEN 'X1'
                WHEN ((sdo.mto_fin_ven_trasp) = 2) THEN 'X2'
                WHEN ((sdo.mto_fin_ven_trasp) = 3) THEN 'X3'
                WHEN ((sdo.mto_fin_ven_trasp) = 4) THEN 'X4'
                WHEN ((sdo.mto_fin_ven_trasp) = 5) THEN 'X5'
                WHEN ((sdo.mto_fin_ven_trasp) = 6) THEN 'X6'
                WHEN ((sdo.mto_fin_ven_trasp) > 6) THEN 'X7'
                WHEN ((nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) = 0) AND ((sdo.mto_fin_ven_trasp) = 0) THEN 'D0'
                WHEN (nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) = 1 THEN 'T1' 
                WHEN (nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) = 2 THEN 'T2' 
                WHEN (nvl(num_pos,0) + nvl(num_atm,0) + nvl(num_vtn,0)) >= 3 THEN 'T3'
            ELSE 'Y8' END NumTrans,  
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  <  0 THEN 1 ELSE 0 END) AS E_0,
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  = 0 THEN 1 ELSE 0 END) AS E0,
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 0 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <= 25 THEN 1 ELSE 0 END) AS E25,
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 25 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=50 THEN 1 ELSE 0 END) AS E50,
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 50 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=75 THEN 1 else 0 END) AS E75,
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 75 AND round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0) <=100 THEN 1 else 0 END) AS E100,
            (CASE WHEN round((sdo.sdo_cap_insoluto /decode (sdo.monto_otorgado, 0,1,sdo.monto_otorgado)) * 100,0)  > 100 THEN 1 ELSE 0 END) AS E_100,
            (sdo.sdo_no_exig) sdo_intereses, 
            (nvl(monto_pos,0)) monto_compra , (nvl(monto_atm,0) + nvl(monto_vtn,0) ) monto_disp 
            INTO v_fecha,v_num_credito,v_NumTrans,v_E_0,v_E0,v_E25,v_E50,v_E75,v_E100,v1_E_100,v_sdo_intereses,v_monto_compra,v_monto_disp
            FROM bdicred:sd_indicador_cred_hist ind, bdicred:"informix".sd_maesdoscont sdo, bdicred:"informix".sd_maecredcont mcnt, bdicred:"informix".sd_maecred mcr
            WHERE ind.empresa = sdo.empresa
            AND   ind.fecha = sdo.fecha
            AND   ind.num_credito = sdo.num_credito
            AND   ind.empresa = mcnt.empresa
            AND   ind.fecha = mcnt.fecha
            AND   ind.num_credito = mcnt.num_credito
            AND   ind.empresa = mcr.empresa
            AND   ind.num_credito = mcr.num_credito
            AND   sdo.empresa = mcnt.empresa
            AND   sdo.fecha = mcnt.fecha
            AND   sdo.num_credito = mcnt.num_credito
            AND   sdo.empresa = mcr.empresa
            AND   sdo.num_credito = mcr.num_credito
            AND   mcnt.empresa = mcr.empresa
            AND   mcnt.num_credito = mcr.num_credito
            AND   mcnt.num_producto = mcr.num_producto
            AND   mcnt.numcte = mcr.numcte 
            AND   ind.fecha = dFecha 
            AND   mcnt.status_cred <> 'CV'
            AND   mcr.campo_trab3 <> 'BAJA'			            				
            
            --update statistics medium for table creditostransaccion;
            
            IF (val_trans_Commit = 0) THEN
                BEGIN WORK;
                LET contador_commit = 0;
                LET val_trans_Commit = -1;
            END IF;
            
            INSERT INTO bdicred:creditostransaccion
            VALUES(v_fecha,v_num_credito,v_NumTrans,v_E_0,v_E0,v_E25,v_E50,v_E75,v_E100,v1_E_100,v_sdo_intereses,v_monto_compra,v_monto_disp);
            
            LET contador_commit = contador_commit  + 1;
			
			IF (contador_commit >= 10000) THEN
				COMMIT WORK;
				LET contador_commit = 0; 
				BEGIN WORK;
			END IF;            
            
        END FOREACH
        IF val_trans_Commit = -1 THEN
            COMMIT WORK;
        END IF;
        
        LET val_trans_Commit = 0;
        LET v_fecha          =DATE(1);
        LET v_num_credito    ='';
        LET v_NumTrans       ='';
        LET v_E_0            =0;
        LET v_E0             =0;
        LET v_E25            =0;
        LET v_E50            =0;
        LET v_E75            =0;
        LET v_E100           =0;
        LET v1_E_100         =0;
        LET v_sdo_intereses  =0;
        LET v_monto_compra   =0;
        LET v_monto_disp     =0;

        SELECT sum(sdo_intereses)		
        INTO totalint
        FROM creditostransaccion
        WHERE fecha =  dFecha;
         
        CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, '30-Inicia descarga-Mensual', '02')
        Returning cCod_RetIB;
        LET cnomarchivo1 =  'SegmentaMes'||'.unl';
        LET cnomarchivo =  'rep_segmentos_mensual'||to_char( dFechaHoy,'%m%d%Y')||'.txt';
        --Encabezado
        let cSql='';
        let csql = 'echo "Mes|Segmento|-0%|0%|25%|50%|75%|100%|+100%|Intereses|Porcentaje|Compras|' ||
                'Disposiciones'||
                '" >' ||TRIM(cruta)|| cnomarchivo;
        SYSTEM csql;
        LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || '''|'''||'';
        LET cSQL2 = ' select fecha, num_trans,sum(seg_e_0),sum(seg_e0),sum(seg_e25),sum(seg_e50),sum(seg_e75),sum(seg_e100),sum(seg_e_100),sum(sdo_intereses), ' 
                    ||'round((sum(sdo_intereses)/'|| NVL(totalint,0) ||')*100,2),sum(monto_compra), sum(monto_disp) from creditostransaccion '
                    ||' group by  1,2 order by fecha,num_trans ';
        LET cSQL3 = '">'||TRIM(cruta)||'ejecuta_rep_comp_mensual.sql';
        LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
        SYSTEM cSQL;
        LET cSQL='chmod 777 '|| TRIM(cruta)||'ejecuta_rep_comp_mensual.sql';
        SYSTEM cSQL;
        LET cSQL = 'dbaccess bdicred ' || TRIM(cruta) || 'ejecuta_rep_comp_mensual.sql';
        SYSTEM cSQL;
        LET cSql = cSql; 
        LET cSql = "sed 's/;$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
        SYSTEM cSql;
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || 'ejecuta_rep_comp_mensual.sql';
        SYSTEM cSQL;
        LET cSQL = '' ;
        LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
        SYSTEM cSQL;
    
   

	RETURN pCod_ret;

END
END PROCEDURE;