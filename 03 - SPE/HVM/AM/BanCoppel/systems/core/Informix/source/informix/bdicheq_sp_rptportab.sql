CREATE PROCEDURE "informix".sp_rptportab(fInicial date, fFinal date, TpoSol int, NPag int, NReg int)
	RETURNING  	CHAR(5),	-- COD-RET
				CHAR(10),   -- FECHA ARCHIVO
				CHAR(30),   -- FOLIO 
				CHAR(20),	-- ESTATUS SOLICITUD
				CHAR(20),	-- ESTATUS RECHAZO
				CHAR(10),    -- FECHA DE RESPUESTA
				CHAR(18),	-- CUENTA
				CHAR(20),   -- BANCO
				CHAR(90);   -- CLIENTE
	
	DEFINE sql_err		INTEGER;
    DEFINE vcodret1     CHAR(5);
    DEFINE vfecharch	CHAR(10);
    DEFINE vfolio		CHAR(30);
    DEFINE vestatusol	CHAR(20);
	DEFINE vestatusre	CHAR(20);
	DEFINE vcuenta		CHAR(18);
	DEFINE vbanco		CHAR(20);
	DEFINE vcliente		CHAR(90);
	DEFINE vfechaini	CHAR(8);
	DEFINE vfechafin	CHAR(8);
	DEFINE cfec_resp	CHAR(10);	
			
			
	LET vcodret1 = "000";
    LET sql_err  = 0;
    LET vfecharch = "";
    LET vfolio = "";
	LET vestatusol = "";
	LET vestatusre = "";
	LET vcuenta = "";
	LET vbanco = "";
	LET vcliente = "";
	LET vfechaini = "";
	LET vfechafin = ""; 
    LET cfec_resp = "";
	
	

BEGIN
	
	------  Control de Errores no Controlados
		ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            Let vcodret1 = sql_err;    
            RETURN vcodret1, vfecharch, vfolio, vestatusol, vestatusre, cfec_resp ,vcuenta, vbanco, vcliente;
        END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/informix/VILLELA/sp_rptportab.out";
		--TRACE ON;
  
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF LENGTH(NVL(fInicial,'')) = 0 OR LENGTH(NVL(fFinal,'')) = 0 OR LENGTH(NVL(TpoSol,'')) = 0 OR LENGTH(NVL(NPag,'')) = 0 OR LENGTH(NVL(NReg,'')) = 0 THEN
			LET vcodret1='001';
			RETURN vcodret1, vfecharch, vfolio, vestatusol, vestatusre,cfec_resp,vcuenta, vbanco, vcliente;
		END IF;
        

        LET vfechaini = YEAR(fInicial)||LPAD(MONTH(fInicial),2,0)||LPAD(DAY(fInicial),2,0); 
        LET vfechafin = YEAR(fFinal)||LPAD(MONTH(fFinal),2,0)||LPAD(DAY(fFinal),2,0); 

        -- SOLICITUDES ENVIADAS 

		IF TpoSol=1 THEN

			FOREACH
				SELECT SKIP NPag FIRST NReg
				NVL(fecha_presentacion,""), folio_solicitud, ep.descripcion, er.descripcion, fecha_respuesta ,SUBSTR(cta_receptora,7,11), 
				vchrnombrecorto, cta_ordenante ||'-'|| TRIM(nombre1) || ' ' || TRIM(NVL(nombre2,""))  
				|| ' ' || TRIM(NVL(apell_paterno,"")) || ' ' || TRIM(NVL(apell_materno,"")) 
				INTO  vfecharch, vfolio, vestatusol, vestatusre, cfec_resp ,vcuenta, vbanco, vcliente
				FROM "informix".sc_portacec_solicitud sol 
					INNER JOIN "informix".sc_portacec_estatus_portabilidad ep ON sol.estatus_portabilidad=ep.estatus_portabilidad
					LEFT JOIN "informix".sc_portacec_estatus_respuesta er ON sol.estatus_respuesta=er.estatus_respuesta
					INNER JOIN bdinteg:si_bancos bco ON sol.bco_ordenante=bco.cvecesif
					INNER JOIN bdinteg:si_cliente cte ON sol.num_cte=cte.numcte
				WHERE fecha_presentacion between vfechaini and vfechafin
				AND clave_origen in (1,2)
        
				LET vcodret1='000';
                LET vfecharch=SUBSTR(vfecharch,7,2) || '/' || SUBSTR(vfecharch,5,2)|| '/' || SUBSTR(vfecharch,1,4); 
                LET cfec_resp=SUBSTR(cfec_resp,7,2) || '/' || SUBSTR(cfec_resp,5,2)|| '/' || SUBSTR(cfec_resp,1,4); 
				RETURN vcodret1, vfecharch, vfolio, vestatusol, vestatusre, cfec_resp ,vcuenta, vbanco, vcliente WITH RESUME;
		
			END FOREACH;

		-- SOLICITUDES RECIBIDAS

		ELIF TpoSol=2 THEN

			FOREACH
				SELECT SKIP NPag FIRST NReg
				NVL(fecha_presentacion,""), folio_solicitud, ep.descripcion, er.descripcion, fecha_respuesta,case when (length(sol.cta_ordenante)>'16') then SUBSTR(sol.cta_ordenante,7,11)
				 else (select sc.cuenta                                                
				from bdicheq: sc_tarjeta sc
				where empresa = 001
				and sc.num_tarjeta = sol.cta_ordenante ) end , 
				(select vchrnombrecorto
                from bdinteg:si_bancos
                where cvecesif= sol.bco_receptor), TRIM(nombre1) || ' ' || TRIM(NVL(nombre2,"")) || ' ' || TRIM(NVL(apell_paterno,"")) 
				|| ' ' || TRIM(NVL(apell_materno,"")) 
				INTO  vfecharch, vfolio, vestatusol, vestatusre, cfec_resp ,vcuenta, vbanco, vcliente
				FROM "informix".sc_portacec_solicitud sol 
					INNER JOIN "informix".sc_portacec_estatus_portabilidad ep ON sol.estatus_portabilidad=ep.estatus_portabilidad
					LEFT JOIN "informix".sc_portacec_estatus_respuesta er ON sol.estatus_respuesta=er.estatus_respuesta
					INNER JOIN bdinteg:si_bancos bco ON sol.bco_ordenante=bco.cvecesif
					LEFT JOIN bdinteg:si_cliente cte ON sol.num_cte=cte.numcte
				WHERE fecha_presentacion between vfechaini and vfechafin
				AND clave_origen =3
        
				LET vcodret1='000';
                LET vfecharch=SUBSTR(vfecharch,7,2) || '/' || SUBSTR(vfecharch,5,2)|| '/' || SUBSTR(vfecharch,1,4); 
                LET cfec_resp=SUBSTR(cfec_resp,7,2) || '/' || SUBSTR(cfec_resp,5,2)|| '/' || SUBSTR(cfec_resp,1,4); 
		
				LET vcodret1='000';

				RETURN vcodret1, vfecharch, vfolio, vestatusol, vestatusre, cfec_resp ,vcuenta, vbanco, vcliente WITH RESUME;
		
			END FOREACH;


		-- TIPO SOLICITUD INCORRECTA
		ELSE
	
			LET vcodret1='002';

			RETURN vcodret1, vfecharch, vfolio, vestatusol, vestatusre, cfec_resp,vcuenta, vbanco, vcliente;

		END IF;
    
END
END PROCEDURE;