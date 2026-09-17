CREATE PROCEDURE "informix".sp_generarchivoresport(pfecha_reg date,pnombrearchivo CHAR(30))
RETURNING 	CHAR(3),   --COT_RET
			INTEGER,   --TOTAL SOLICITUDES
			CHAR(80),  -- RUTA ARCHIVO
			CHAR(35);  -- NOMBRE ARCHIVO

			
DEFINE sql_err		INTEGER;
DEFINE vcodret1     CHAR(5);

DEFINE vtotalSol	INTEGER;
DEFINE vruta		CHAR(80);
DEFINE vsSQL 		CHAR(1050);
DEFINE vsSQL1 		CHAR(150);
DEFINE vsSQL2 		CHAR(850);
DEFINE vsSQL3 		CHAR(80);
DEFINE vsSQL4 		CHAR(150);
DEFINE vsumario		CHAR(450);
DEFINE vfiltra		CHAR(200);
DEFINE vencabezado	CHAR(100);
DEFINE vsumFuturo	CHAR(255);
DEFINE vRegistros	CHAR(7);
DEFINE vfecha_reg	CHAR(8);
DEFINE vsecuencia	CHAR(7);
DEFINE cArchivresp  CHAR(35);

DEFINE vRegisTot	SMALLINT;
LET vcodret1 = "000";
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
LET vsumFuturo	= LPAD('',255);
LET vRegistros	= "";
LET vfecha_reg	= "";
LET vsecuencia  = "";
LET cArchivresp  = "";
LET vRegisTot   = 0;


BEGIN
	
	------  Control de Errores no Controlados
		ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            Let vcodret1 = sql_err;    
            RETURN vcodret1, vtotalSol, vruta,cArchivresp;
        END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/informix/VILLELA/sp_generarchivoresport.out";
		--TRACE ON;



		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF LENGTH(NVL(pfecha_reg,'')) = 0 OR LENGTH(NVL(pnombrearchivo,'')) = 0 THEN
			LET vcodret1='001';
			RETURN vcodret1, vtotalSol, vruta,cArchivresp;
		END IF;

        LET vfecha_reg = TRIM(YEAR(pfecha_reg)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0));

		
		SELECT valor
		INTO vruta 
		FROM BDICHEQ:sc_param 
		WHERE empresa = "001" 
		AND codparam='rta_ptres';
		
		IF NVL(vruta,'') = '' THEN
			LET vcodret1='002';
			RETURN vcodret1, vtotalSol, vruta,cArchivresp;		
		END IF
		
		
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
      
  	   ELIF    vsecuencia >= 10  AND vsecuencia < 100   THEN 
			LET vsecuencia= LPAD(cast(vsecuencia as CHAR(2)),7,'0');
		ELSE
		    LET vsecuencia= LPAD(cast(vsecuencia as CHAR(3)),7,'0');
		END IF;
		
		
     
		LET vsSQL1 = 'echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vruta) ||  'Solicitudes.txt';
	    LET vsSQL2 = "SELECT '0100000012140137E" || vfecha_reg || "'||LPAD('',248) FROM sc_portacec_archivotemp UNION " ||
	"SELECT '02'||CASE WHEN secuencia <= 9 THEN LPAD(cast(secuencia as char(1)),7,'0') WHEN  secuencia >= 10 AND  secuencia < 100 THEN  TRIM(LPAD(cast(secuencia as char(2)),7,'0'))ELSE TRIM(LPAD(cast(secuencia as char(3)),7,'0')) END||'21'||folio_solicitud||fecha_solicitud||nombre_cte||" ||                   
                     "CASE WHEN rfc_cte is null or rfc_cte = '' then 'ND' ||LPAD('',11) else rfc_cte end||cta_receptora||" ||
                     "tipo_cta_receptora||bco_receptor||cta_ordenante||tipo_cta_ordenante||bco_ordenante||fecha_nacimiento||" ||
                     "CASE WHEN rfc_empresa is null or rfc_empresa = '' then 'ND' ||LPAD('',11) else rfc_empresa end||estatus_respuesta" || 
                     "||fecha_respuesta||CASE WHEN curp_cte is null or curp_cte = '' then 'ND' ||LPAD('',16) else curp_cte end||" ||
                     "LPAD('',13) FROM sc_portacec_archivotemp";	           
		LET vsSQL3 = '" >' || TRIM(vruta) || 'queryTem.sql';
		LET vsSQL = TRIM(vsSQL1) || ' ' || TRIM(vsSQL2) || ' ' || TRIM(vsSQL3);
  
        LET vfiltra= "sed 's/|$//g;/^$/d' " ||  TRIM(vruta) ||  "Solicitudes.txt " || " > " || TRIM(vruta) || TRIM(pnombrearchivo)||substr(YEAR(pfecha_reg),3,2)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0)||'01'||'.txt';
        LET vsumario = "echo '09"|| vsecuencia || "21" || vRegistros || vsumFuturo || "' >> " || TRIM(vruta) ||  TRIM(pnombrearchivo)||substr(YEAR(pfecha_reg),3,2)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0)||'01'||'.txt';
        
        
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

        LET vcodret1='000';
        LET vtotalSol=vRegistros;
		LET vruta=TRIM(vruta);

		LET cArchivresp= TRIM(pnombrearchivo) || substr(YEAR(pfecha_reg),3,2)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0)||'01' || '.txt';
		
		
        RETURN vcodret1, vtotalSol, vruta, cArchivresp;
END
END PROCEDURE

;