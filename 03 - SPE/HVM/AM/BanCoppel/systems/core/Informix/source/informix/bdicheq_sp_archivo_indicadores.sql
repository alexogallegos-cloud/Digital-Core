CREATE PROCEDURE "informix".sp_archivo_indicadores
(
)
RETURNING
	CHAR(6),
	CHAR(80)
---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);

	DEFINE cRuta			CHAR(100);
	DEFINE v_sql        	CHAR(1000);
	DEFINE cArchivo			CHAR(27);
	DEFINE cFechaHoy		CHAR(10);
	DEFINE cAnioMesAnte		CHAR(6);


	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";

	LET cRuta				= "";
	LET v_sql  				= "";
	LET cArchivo			= "";
	LET cFechaHoy			= "";
	LET cAnioMesAnte		= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/vamilan/sp_archivo_indicadores.out';
	--TRACE ON;
	
	LET cRuta = "/resplogifx/indicadores/";
	
	SELECT fecha_hoy, YEAR(fecha_hoy - 1 units MONTH) || LPAD(MONTH(fecha_hoy - 1 units MONTH),2,"0")
	INTO cFechaHoy, cAnioMesAnte
	FROM "informix".sc_fechas
	WHERE empresa = "001";
	
	LET cArchivo = SUBSTR(YEAR(cFechaHoy),3,2) || LPAD(MONTH(cFechaHoy),2,"0") || LPAD(DAY(cFechaHoy),2,"0") || "_internet_indicadores";

	--// HACE LA DESCARGA DEL ARCHIVO DE INDICADORES DE LOS CLIENTES CON INTERNET
	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cArchivo) || '.txt' || 
		' SELECT t1.anio_mes, t3.numcte, t1.cuenta, t1.producto, num_depositos_vent, imp_acum_depositos_vent, ' ||
		' num_depositos_entrecta, imp_acum_depositos_entrecta, num_depositos_terc, imp_acum_depositos_terc, ' ||
		' num_depositos_corresp, imp_acum_depositos_corresp, num_deposito_spei, imp_acum_deposito_spei, ' ||
		' num_retiros_vent, imp_acum_retiros_vent, num_retiros_entrecta, imp_acum_retiros_entrecta, ' ||
		' num_retiros_terc, imp_acum_retiros_terc, num_retiros_atm, imp_acum_retiros_atm, ' ||
		' num_retiros_cashback, imp_acum_retiros_cashback, num_compra_pos, imp_acum_compra_pos, ' ||
		' num_compra_interred, imp_acum_compra_interred, num_retiro_spei, imp_acum_retiro_spei ' ||
		' FROM "informix".sc_indicadores t1, "informix".sc_maechq t2, bdinteg: "informix".si_cliente t3 ' ||
		' WHERE t1.anio_mes = ''' || cAnioMesAnte || ''' AND t1.cuenta = t2.cuenta AND t2.num_cte = t3.numcte AND t1.internet = 1; "'||
		' > query_descarga_archivo_internet_indicadores.sql';
	LET v_sql = TRIM(v_sql);
	SYSTEM v_sql;
	LET v_sql = "dbaccess bdicheq query_descarga_archivo_internet_indicadores.sql";
	SYSTEM v_sql;
	
	LET cArchivo = SUBSTR(YEAR(cFechaHoy),3,2) || LPAD(MONTH(cFechaHoy),2,"0") || LPAD(DAY(cFechaHoy),2,"0") || "_sdoprom_indicadores";
	LET v_sql = "";
	
	--// HACE LA DESCARGA DEL ARCHIVO DE INDICADORES DE LOS CLIENTES CON SU SALDO PROMEDIO Y SALDO MAXIMO EN EL MES
	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cArchivo) || '.txt' || 
	    ' SELECT {+ MULTI_INDEX(informix.sc_indicadores)} t1.anio_mes, t3.numcte, t1.cuenta, t1.producto, t1.saldo_maximo_mes, t1.saldo_promedio ' ||
		' FROM "informix".sc_indicadores t1, "informix".sc_maechq t2, bdinteg: "informix".si_cliente t3 ' ||
		' WHERE t1.anio_mes = ''' || cAnioMesAnte || ''' AND t1.cuenta = t2.cuenta AND t2.num_cte = t3.numcte; "'||
		' > query_descarga_archivo_sdoprom_indicadores.sql';
	LET v_sql = TRIM(v_sql);
	SYSTEM v_sql;
	LET v_sql = "dbaccess bdicheq query_descarga_archivo_sdoprom_indicadores.sql";
	SYSTEM v_sql;
	
	RETURN cCodRet, cDescRet;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para ',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2014';

CREATE PROCEDURE "informix".sp_generarchivoportab(pfecha_reg date,pnombrearchivo CHAR(30))
RETURNING 	CHAR(3),   --COT_RET
			INTEGER,   --TOTAL SOLICITUDES
			CHAR(80);  -- RUTA ARCHIVO


DEFINE sql_err		INTEGER;
DEFINE vcodret1     CHAR(5);

DEFINE vtotalSol	INTEGER;
DEFINE vruta		CHAR(80);
DEFINE vsSQL 		CHAR(1400);
DEFINE vsSQL1 		CHAR(400);
DEFINE vsSQL2 		CHAR(1500);
DEFINE vsSQL3 		CHAR(350);
DEFINE vsSQL4 		CHAR(350);
DEFINE vsumario		CHAR(360);
DEFINE vfiltra		CHAR(200);
DEFINE vencabezado	CHAR(100);
DEFINE vsumFuturo	CHAR(255);
DEFINE vRegistros	CHAR(7);
DEFINE vfecha_reg	CHAR(8);
DEFINE vsecuencia	CHAR(7);
DEFINE vRegisTot	SMALLINT;

LET vcodret1 = "001";
LET sql_err  = 0;

LET vtotalSol 	= "";
LET vruta 		= "";
LET vsSQL 		= "";
LET vsSQL1 		= "";
LET vsSQL2 		= "";
LET vsSQL3 		= "";
LET vsSQL4 		= "";
LET vsumario	= "";
LET vfiltra	    = "";
LET vencabezado	= "";
LET vRegistros	= "";
LET vfecha_reg	= "";
LET vsecuencia  = "";
LET vRegisTot   = 0;
LET vsumFuturo  = LPAD('',255);


BEGIN
	
	------  Control de Errores no Controlados
		ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            Let vcodret1 = sql_err;    
            RETURN vcodret1, vtotalSol, vruta;
        END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/informix/VILLELA/sp_generarchivoportab.out";
		--TRACE ON;


		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF LENGTH(NVL(pfecha_reg,'')) = 0 OR LENGTH(NVL(pnombrearchivo,'')) = 0 THEN
			LET vcodret1='001';
			RETURN vcodret1, vtotalSol, vruta;
		END IF;

        LET vfecha_reg = TRIM(YEAR(pfecha_reg)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0));

        SELECT valor
		INTO vruta 
		FROM BDICHEQ:sc_param 
		WHERE empresa = "001" 
		AND codparam = 'rta_ptsol';

        SELECT count(*)
        INTO vRegistros
		FROM sc_portacec_archivotemp;


        -- PROCESO DE GENERACION DE ARCHIVO
            LET vsecuencia= vRegistros + 2;
       
        IF vRegistros < 10 THEN
            LET vRegistros= LPAD(cast(vRegistros as CHAR(1)),7,'0');						
       
	    ELIF  vRegistros >= 10  AND  vRegistros < 100  THEN
            LET vRegistros= LPAD(cast(vRegistros as CHAR(2)),7,'0');			
       
	    ELSE		
		    LET vRegistros= LPAD(cast(vRegistros as CHAR(3)),7,'0');

        END IF;
        
	   	   
        IF vsecuencia < 10 THEN
            LET vsecuencia= LPAD(cast(vsecuencia as CHAR(1)),7,'0');
			
		ELIF  vsecuencia >= 10  AND vsecuencia < 100   THEN 
             LET vsecuencia= LPAD(cast(vsecuencia as CHAR(2)),7,'0');		
        ELSE
            LET vsecuencia= LPAD(cast(vsecuencia as CHAR(3)),7,'0');

        END IF;

   
		LET vsSQL1 = 'echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vruta) ||  'Solicitudes.txt';
LET vsSQL2 = "SELECT '0100000012040137E" || vfecha_reg || "'||LPAD('',248) FROM sc_portacec_archivotemp UNION " ||
"SELECT  '02'||CASE WHEN secuencia+1 <= 9 THEN LPAD(cast(secuencia+1 as char(1)),7,'0') WHEN  secuencia+1 >= 10 AND  secuencia+1 < 100 THEN  TRIM(LPAD(cast(secuencia+1 as char(2)),7,'0'))ELSE TRIM(LPAD(cast(secuencia+1 as char(3)),7,'0')) END||'20'||folio_solicitud||fecha_solicitud||nombre_cte||" ||
"CASE WHEN rfc_cte is null or rfc_cte = '' or (length(rfc_cte) < 13) then 'ND' ||LPAD('',11) else rfc_cte end||cta_receptora||" ||
"tipo_cta_receptora||bco_receptor||CASE WHEN (length(cta_ordenante)<18) then '00'||TRIM(cta_ordenante) else cta_ordenante end||" ||
 "CASE WHEN (length(tipo_cta_ordenante)<2) then '0'||TRIM(tipo_cta_ordenante) else tipo_cta_ordenante end||bco_ordenante||fecha_nacimiento||" ||
"CASE WHEN rfc_empresa is null or rfc_empresa = '' or (length(rfc_empresa) < 13) or valrfcemp_cecoban(rfc_empresa) = '1' then 'ND' ||LPAD('',11) else rfc_empresa end||estatus_respuesta||" || 

"fecha_respuesta||CASE WHEN (curp_cte is null or curp_cte = '') or (length(curp_cte) < 18) then 'ND' ||LPAD('',16) else curp_cte end||" ||
"LPAD('',13) FROM sc_portacec_archivotemp";
	
			 
		LET vsSQL3 = '" >' || TRIM(vruta) || 'queryTem.sql';
		LET vsSQL = TRIM(vsSQL1) || ' ' || TRIM(vsSQL2) || ' ' || TRIM(vsSQL3);
  
        LET vfiltra= "sed 's/|$//g;/^$/d' " ||  TRIM(vruta) ||  "Solicitudes.txt " || " > " || TRIM(vruta) || TRIM(pnombrearchivo)||'.txt';
        LET vsumario = "echo '09"|| vsecuencia || "20" || vRegistros || vsumFuturo || "' >> " || TRIM(vruta) ||  TRIM(pnombrearchivo)||'.txt';
        
        
			IF LENGTH(NVL(vsSQL,'')) > 0 THEN
				SYSTEM vsSQL;
				LET vsSQL4 = '';
				LET vsSQL4 = '/ifxsif01/bin/dbaccess bdicheq ' || TRIM(vruta) || 'queryTem.sql';
                --LET vsSQL4 = 'dbaccess bdicheq ' || TRIM(vruta) || 'queryTem.sql';
				SYSTEM vsSQL4;
                LET vcodret1='000';
            END IF
        
        
        SYSTEM vfiltra;
        SYSTEM vsumario;
       
       -- PROCESO DE ACTUALIZACION DE SOLICITUDES

           IF vcodret1='000' THEN
                           
				UPDATE {+ INDEX(sc_portacec_solicitud idx_sc_portacec_solicitud2)} sc_portacec_solicitud SET fecha_presentacion=vfecha_reg, estatus_cecoban='', fecha_estatus_cecoban='' 
				WHERE folio_solicitud IN(SELECT {+ INDEX(sc_portacec_archivotemp idx_sc_portacec_archivotemp)} folio_solicitud FROM sc_portacec_archivotemp);

				LET vcodret1='000';
				LET vtotalSol=vRegistros;
				LET vruta=TRIM(vruta) ||  TRIM(pnombrearchivo)||'.txt';
           END IF;

        RETURN vcodret1, vtotalSol, vruta;
END
END PROCEDURE
;