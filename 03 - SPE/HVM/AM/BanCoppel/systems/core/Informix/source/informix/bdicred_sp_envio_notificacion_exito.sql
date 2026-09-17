CREATE PROCEDURE "informix".sp_envio_notificacion_exito(
	p_empresa 		CHAR(3),	-- Numero de empresa.
	p_num_credito 	CHAR(20)	-- Numero de credito.
)
RETURNING 
	CHAR(5)	AS cCodRet;

-- CONTROL DE CAMBIOS:
---------------------------------------------------------------------------------
-- Autor: SECP.
-- Modificacion: Envio de notificacion exitosa del incremento de linea de credito por inflacion
-- Fecha de Modificacion: 07-10-2024.
-- Peticion: RQM 10 1647 â Incremento  linea de credito TDC por inflacion.
---------------------------------------------------------------------------------

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE cCodRet					    	CHAR(5);
DEFINE cCodRetSms				    	CHAR(5);
DEFINE sErrorCont						SMALLINT;
DEFINE iSqlErr							INTEGER;
DEFINE dFechaInteg				    	DATE;
DEFINE dFechaSistema					DATE;
DEFINE cNumCte					    	CHAR(20);
DEFINE cNumCredito						CHAR(20);
DEFINE cTelefono						CHAR(20);
DEFINE cRespIncremento		        	CHAR(9);
DEFINE cCodRetBit						CHAR(6);
DEFINE cErrorInfo                   	CHAR(80);
DEFINE iSamErr							INTEGER;
DEFINE cProceso 						CHAR(4);
DEFINE cMensajeRet						CHAR(125);
DEFINE d_linea_oferta               	DECIMAL(18,2);        
DEFINE d_fin_vigencia               	DATE;
DEFINE i_intento_botificacion       	INTEGER;
DEFINE i_dia_fin_vigencia 				CHAR(5);
DEFINE i_mes_fin_vigencia 				CHAR(5);
DEFINE i_anio_fin_vigencia 				CHAR(5);
DEFINE cIncrementoActivo 				CHAR(1);
DEFINE cCodRetCon 						CHAR(6);
DEFINE cLinea_credito 					DECIMAL(18,2);  
DEFINE c_term_tarjeta 					CHAR(20);
DEFINE cCodretConBue 					CHAR(5);
DEFINE cMensaje 						CHAR(80);
DEFINE cIsCtePros 						CHAR(1);
DEFINE c_num_cte 						CHAR(20); 
DEFINE cNombre 							CHAR(120);
DEFINE cRFC 							CHAR(13);
DEFINE dtFechaSol 						DATE;
DEFINE dtFechaAut 						DATE; 
DEFINE dLinCredAct 						DECIMAL(18,2);
DEFINE dLinCredCal 						DECIMAL (18,2);
DEFINE cOrigen 							CHAR(1);
DEFINE cStatus 							CHAR(2);
DEFINE cDescStatus 						CHAR(40);
DEFINE cComentario 						CHAR(80);
DEFINE cNumSol 							CHAR(20);
DEFINE c_nombre_cliente 				CHAR(50);
DEFINE c_num_tarjeta 					CHAR(20);
DEFINE c_email_cliente 					CHAR(50);
DEFINE d_fecha_hoy 						DATE;
DEFINE c_num_producto 					CHAR(4);
DEFINE d_linea_actual 					DECIMAL(18,2);
DEFINE c_nombre_prod 					CHAR(50);
DEFINE c_fin_vigencia                   CHAR(10);
DEFINE c_sucursal						CHAR(4); 
DEFINE c_nombre_sucursal                CHAR(40);
DEFINE c_lugar_correo                   CHAR(50);
DEFINE c_folio							CHAR(16);
DEFINE s_secuencia_tarjeta              SMALLINT;	
DEFINE s_envio_email                    SMALLINT;
DEFINE s_envio_sms                      SMALLINT;

-- ********************************************** ******************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************


LET cCodRet					    = "00000";
LET cCodRetSms			        = "";
LET sErrorCont 					= 0;
LET iSqlErr						= 0;
LET dFechaInteg					= DATE(1);
LET dFechaSistema               = DATE(1);  
LET cNumCte					    = '';
LET cNumCredito					= '';
LET cTelefono					= '';
LET cRespIncremento				= '';
LET cCodRetBit					= '';	
LET cErrorInfo                  = '';
LET iSamErr 					= 0;
LET cProceso 					= '0117';
LET cMensajeRet 				= '';
LET d_linea_oferta              = 0;        
LET d_fin_vigencia           	= DATE(1);
LET i_intento_botificacion      = 0; 
LET i_dia_fin_vigencia 			= 0;
LET i_mes_fin_vigencia 			= 0;
LET i_anio_fin_vigencia 		= 0;
LET cIncrementoActivo			= "";
LET cCodRetCon 					= "";
LET cLinea_credito 				= 0; 
LET c_term_tarjeta 				= "";
LET cCodretConBue 				= "";
LET cMensaje 					= "";
LET cIsCtePros 					= "";
LET c_num_cte 					= ""; 
LET cNombre 					= "";
LET cRFC 						= "";
LET cNumSol 					= "";
LET c_num_tarjeta 				= "";
LET c_email_cliente 			= "";
LET d_fecha_hoy 				= DATE(1);
LET c_num_producto 				= "";
LET d_linea_actual 				= 0;
LET c_nombre_prod 				= "";
LET c_fin_vigencia              = "";
LET c_lugar_correo              = "";
LET c_folio                     = "";
LET c_nombre_sucursal           = "";
LET c_sucursal					= "";
LET s_secuencia_tarjeta         = 0;
LET s_envio_email               = 0;
LET s_envio_sms                 = 0;	
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************


BEGIN
	ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
		IF iSqlErr != 0 THEN 
			LET cCodRet=iSqlErr;
			LET cMensajeRet = cErrorInfo||' '||iSamErr;
			EXECUTE PROCEDURE bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCodRet, cMensajeRet, '02') 
				INTO cCodRetBit;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/e90306329/TRACE/sp_envio_exito.out';
	--TRACE ON;


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	

	-- Obtiene la fecha del dia
	SELECT fecha_hoy
		INTO d_fecha_hoy 
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = p_empresa;

	
        SELECT num_cliente, num_credito, celular_cliente, linea_oferta, fin_vigencia , intento_notificacion , num_producto, nombre_cliente,linea_actual,email_cliente,sucursal
			INTO cNumCte, cNumCredito, cTelefono, d_linea_oferta, d_fin_vigencia, i_intento_botificacion, c_num_producto,c_nombre_cliente, d_linea_actual,c_email_cliente ,c_sucursal
            FROM bdicred:"informix".sd_bitacora_incremento_inflacion 
            WHERE num_credito = p_num_credito AND fecha_aceptacion_oferta = (
				SELECT MAX(fecha_aceptacion_oferta) 
					FROM bdicred:sd_bitacora_incremento_inflacion 
					WHERE  num_credito = p_num_credito 
					AND bandera_aceptacion_rechazo  = "1");
            
		LET i_dia_fin_vigencia = DAY(d_fin_vigencia);
			
        IF i_dia_fin_vigencia < 10 THEN
            LET i_dia_fin_vigencia = "0" || i_dia_fin_vigencia;
        END IF;

        LET i_mes_fin_vigencia = MONTH(d_fin_vigencia);

        IF i_mes_fin_vigencia < 10 THEN
			LET i_mes_fin_vigencia = "0" || i_mes_fin_vigencia;
        END IF;
            
		LET i_anio_fin_vigencia = SUBSTR(YEAR(d_fin_vigencia),3);

		LET c_fin_vigencia = TRIM(i_dia_fin_vigencia)||'/'||TRIM(i_mes_fin_vigencia)||'/'||TRIM(i_anio_fin_vigencia);

		SELECT MAX(secuencia) 
			INTO s_secuencia_tarjeta 
			FROM bdicred:sd_tarjeta 
			WHERE num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A';

        SELECT num_tarjeta 
            INTO c_num_tarjeta 
            FROM bdicred:"informix".sd_tarjeta 
            WHERE num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A' AND secuencia = s_secuencia_tarjeta;

        SELECT  descripcion
			INTO c_nombre_prod 
			FROM bdicred:"informix".sd_param_incremento_inf_tc 
			WHERE producto = c_num_producto; 

		SELECT folio_suc 
			INTO c_folio
			FROM bdicred:"informix".sd_movdia 
			WHERE secuencia = (SELECT MAX(secuencia) from sd_movdia where num_credito =cNumCredito AND codigo_fun = '008' and codigo_ref = 1)  ;
		

		SELECT nombre
			INTO   c_nombre_sucursal
			FROM   bdinteg:si_sucursales
			WHERE  sucursal = c_sucursal;  

		LET c_lugar_correo = TRIM(c_sucursal)  || TRIM(c_nombre_sucursal);

		IF cTelefono IS NOT NULL OR cTelefono != '' THEN	
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','SMS_RECI','SMS_INCEXTI',cNumCte,'',SUBSTR(c_num_tarjeta,13),'1','',c_fin_vigencia,'','',c_nombre_prod,'','','','','','','',0,0,0,0,0,'','') INTO cCodRetSms;
			IF cCodRetSms != '00000' THEN
				LET s_envio_sms = 1;
			END IF;
				
		END IF;	

        IF c_email_cliente IS NOT NULL OR c_email_cliente != '' THEN	
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CRED_EMAIL','INC_EXITO',cNumCte,'',SUBSTR(c_num_tarjeta,13),'1',d_linea_actual,d_linea_oferta,c_folio,'',c_lugar_correo,c_nombre_prod,'','','','','','',0,0,0,0,0,'','') INTO cCodRetSms;
			IF cCodRetSms != '00000' THEN
				LET s_envio_email = 1;
			END IF;
        END IF;
		
		IF s_envio_sms = 0 THEN 
			LET cCodRet = '00001';
		END IF;
		
		IF s_envio_email = 0 THEN 
			LET cCodRet = '00002';
		END IF;
		
		IF s_envio_email = 0 AND s_envio_sms = 0 THEN
			LET cCodRet = '00003';
		END IF;

RETURN cCodRet;	

END

END PROCEDURE
DOCUMENT 
'----------------------------------------------------------------------------',
'Descripcion : Envio de notificacion exitosa del incremento de linea de credito por inflacion',
'Modifico    : SECP',
'Fecha       : 07/10/2024',
'BD          : BDICRED',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_procesa_calc_cat_publicidad()
RETURNING CHAR(5) AS cCodRet,CHAR(50) AS vcat;
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);

    DEFINE vnum_producto        CHAR(4);
    DEFINE vrelacion            SMALLINT;
    DEFINE vlinea_total         DECIMAL;
    DEFINE vlimite_credito      DECIMAL;
    DEFINE vcatcontrato         DECIMAL;
    DEFINE vcat                 DECIMAL;

    DEFINE vfecha_ini DATE;
    DEFINE vfecha_fin DATE;
    DEFINE vfecha_insumos DATE;
    
    DEFINE  vTasa           DECIMAL;
    DEFINE  cComision       DECIMAL;
    DEFINE  cAnualidad      DECIMAL;
    
    DEFINE cRutaGral    CHAR(150);

    DEFINE cnum_credito        CHAR(20);
    DEFINE cnum_producto       CHAR(4);
    DEFINE cnumcte             CHAR(9);
    DEFINE dfecha_apertura     DATE;
    DEFINE cstatus_cred        CHAR(2);
    DEFINE irelacion           SMALLINT;
    DEFINE dlinea_autorizada   DECIMAL;
    DEFINE dlimite_credito     DECIMAL;
    DEFINE inum_pagos_vencidos SMALLINT;
    DEFINE dfecha              DATE;
    DEFINE dcatorigina         DECIMAL;
    DEFINE dtasa               DECIMAL;
    DEFINE danualidad          DECIMAL;
    DEFINE dcomision           DECIMAL;
    DEFINE icont_commit        INTEGER;
    DEFINE dcuentas                   DECIMAL;
    DEFINE dLinea_de_credito_total    DECIMAL;
    DEFINE dcat_origina DECIMAL;
    DEFINE iCommit  INTEGER;
    DEFINE iCont  INTEGER;
	DEFINE dlinea_solicitud	   DECIMAL;
	DEFINE dfecha_cat_historico		DATE;

    
    LET cCodRet         = '00000';
    LET vcat            = '00000';
    LET icont_commit    = 0;
    LET iCommit         = 0;
    LET dlinea_solicitud = 0;
	

    

    BEGIN
        
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                IF  icont_commit <> 0 OR iSqlErr=-535 THEN
                    COMMIT WORK;
		    ELIF iSqlErr=-958 THEN
		        DROP TABLE bdicred:tmpcreditos_cat;
            END IF;
                RETURN cCodRet,vcat;
            END IF;
        END EXCEPTION;
        
        --SET DEBUG FILE TO '/ifxsif01/aastorga/sp_procesa_calc_cat_publicidad_v9.out';
        --TRACE ON;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;


        SELECT ADD_MONTHS((pri_dia_mes),-12),(pri_dia_mes -1)   
        INTO vfecha_ini, vfecha_fin  
        FROM bdicred:sd_fechas
    	WHERE empresa = '001';

        -- RECUEPRA de los parametros el valor que controla los commit
        SELECT valor
        INTO iCommit
        FROM bdicred:"informix".sd_param
        WHERE cod_param = '87'
        LIMIT 1;
							
		SELECT NVL(fecha_fin,'1900-01-01')
		INTO dfecha_cat_historico 
		FROM bdicred:sd_calc_cat_historico
		WHERE producto IN ('6001','6600','7000','8100','8500','5400')
		LIMIT 1;
		
		IF (dfecha_cat_historico != vfecha_fin) THEN
			TRUNCATE TABLE sd_calc_cat_publi;
			TRUNCATE TABLE sd_calc_cat_historico;
            TRUNCATE TABLE sd_calc_cat_insumos;
		END IF;
		

	   SELECT a.num_credito, a.num_producto, a.numcte, h.fecha_apertura,a.status_cred,
            NVL(b.numeric2,0) AS relacion,         --as relacion
            d.limite_aut AS linea_autorizada,        --as linea_autorizada, 
            e.monto_otorgado AS limite_credito,    --as limite_credito ,
            e.mto_fin_ven_trasp AS num_pagos_vencidos, --as num_pagos_vencidos,
            a.fecha,
		    0.00 AS catorigina,
            h.tasa_interes AS tasa, 
		    0.00 AS anualidad, 0.00 AS comision 
        FROM bdicred:sd_maecredcont       a
        INNER JOIN bdicred:sd_maecred       h   
            ON (a.num_Credito   = h.num_credito 
                AND h.fecha_apertura >= vfecha_ini
				AND h.fecha_apertura <= vfecha_fin)
        INNER JOIN bdinteg:si_cliente       b   
            ON (b.numcte =   a.numcte 
                AND NVL(b.numeric2,0) IN (0,8))
        INNER JOIN bdicred:sd_tarjeta       d   
            ON (d.numcte = a.numcte
				AND d.num_Credito = a.num_credito)   
        INNER JOIN bdicred:sd_maesdoscont   e   
            ON (e.num_Credito = a.num_credito 
                AND e.fecha = a.fecha 
                AND e.mto_fin_ven_trasp = 0
                AND e.monto_otorgado > 0 )
        INNER JOIN bdicred:sd_calc_cat_int_producto sccip
	    ON (sccip.num_producto = a.num_producto)     
        WHERE a.fecha = vfecha_fin   
          AND a.status_cred IN ('E1')
	      AND d.tipo_tarjeta  = 'T' 
          AND d.secuencia = (SELECT MAX(secuencia) FROM bdicred:"informix".sd_tarjeta 
								WHERE empresa = d.empresa AND num_credito =a.num_credito 
								AND numcte = d.numcte AND tipo_tarjeta  = 'T') 
	      AND d.empresa = '001'
	    ORDER BY a.num_credito, a.num_producto, a.numcte
        INTO TEMP tmpcreditos_cat WITH NO LOG;
	
		----------------------------------------------
    ---------------------Valida la linea autorizada----------------
        FOREACH WITH HOLD
            SELECT t.num_credito,t.num_producto,t.numcte,t.linea_autorizada,s.monto_solicitado 
            INTO cnum_credito, cnum_producto, cnumcte, dlinea_autorizada, dlinea_solicitud   
            FROM bdicred:tmpcreditos_cat t
            INNER JOIN bdisolic:ss_solicitudes s
                ON t.num_credito = s.num_solicitud 
    		AND t.num_producto = s.num_producto 
    		AND t.numcte = s.numcte
            WHERE t.linea_autorizada <= 2000
    	    ORDER BY t.num_producto,t.num_credito DESC
	
            UPDATE bdicred:tmpcreditos_cat
			SET linea_autorizada = dlinea_solicitud 
			WHERE num_credito = cnum_credito
				AND num_producto = cnum_producto
				AND numcte = cnumcte;
				

        END FOREACH;

		-----
    	UPDATE bdicred:tmpcreditos_cat
    	SET limite_credito = linea_autorizada 
        	WHERE limite_credito <=2000 
    	AND linea_autorizada > limite_credito;
		
		--Se agrega instruccion para eliminar los creditos que nacieron con un limite de credito incorrecto $0 o $1
		DELETE FROM tmpcreditos_cat
		WHERE limite_credito <= 1;

        FOREACH WITH HOLD
            SELECT  i.num_producto, count(i.limite_credito), i.limite_credito,
                count(i.limite_credito) * i.limite_credito, i.tasa
            INTO cnum_producto,dcuentas,dlimite_credito,dLinea_de_credito_total,vTasa
            FROM bdicred:tmpcreditos_cat i
            LEFT JOIN bdicred:sd_calc_cat_historico h
                ON(h.producto = i.num_producto 
                    AND i.limite_credito = h.limite_credito)
            WHERE h.producto IS NULL 
                AND h.limite_credito IS NULL
            GROUP BY i.num_producto,i.limite_credito, i.tasa
    	    ORDER BY i.num_producto DESC 

            IF  icont_commit = 0 THEN
                BEGIN WORK;
            END IF

            -- Se realiza el insert en la tabla 
            INSERT INTO bdicred:sd_calc_cat_historico(producto,cuentas,limite_credito,catorigina,Linea_de_credito_total,cat_origina_total,tasa,anualidad,comision,fecha_ini,fecha_fin)
            VALUES(cnum_producto,dcuentas,dlimite_credito,0,dLinea_de_credito_total,0,vTasa,0,0,vfecha_ini, vfecha_fin);


            LET icont_commit = icont_commit + 1;
            IF  icont_commit = iCommit THEN
                COMMIT WORK;
                LET icont_commit = 0;            
            END IF  
        
        END FOREACH;

        IF  icont_commit <> 0 THEN
            COMMIT WORK;
            LET icont_commit = 0;
        END IF
         
----------------------------------------------------------------------------
-------------------------- ACTUALIZACION DE CAT -----------------------------
        FOREACH WITH HOLD
            SELECT producto,limite_credito,linea_de_credito_total,tasa
            INTO vnum_producto,vlimite_credito,vlinea_total,vTasa
            FROM bdicred:sd_calc_cat_historico
            WHERE catorigina = 0
				AND anualidad = 0
    	    ORDER BY producto DESC
             
            EXECUTE PROCEDURE bdicred:"informix".sp_calculo_cat_publicidad(vnum_producto, vlimite_credito, vTasa)                  
            INTO cCodRet,vcat,cComision,cAnualidad;


            UPDATE sd_calc_cat_historico
            SET catorigina  = vcat,
                anualidad  = cAnualidad,
                comision   = cComision,
                cat_origina_total = (vlinea_total * vcat)
            WHERE producto =vnum_producto 
                AND limite_credito = vlimite_credito;

        END FOREACH;


    -------------------------- REGISTRANDO CAT PUBLI-----------------------------
    ----------------------------------------------------------------------------
        FOREACH WITH HOLD
            SELECT h.producto,h.tasa,h.anualidad,h.comision,
                (sum(h.cat_origina_total)/sum(h.linea_de_credito_total)) * 100 as cat_origina
            INTO vnum_producto, dtasa, danualidad, dcomision, dcat_origina    
            FROM bdicred:sd_calc_cat_historico h
            LEFT JOIN sd_calc_cat_publi p
                ON h.producto = p.producto
            WHERE p.producto IS NULL
            GROUP BY h.producto,h.tasa,h.anualidad,h.comision
    	    ORDER BY h.producto DESC

            IF  icont_commit = 0 THEN
                BEGIN WORK;
            END IF
                    
            INSERT INTO sd_calc_cat_publi(producto, tasa, anualidad, comision, cat_origina, fecha_ini, fecha_fin) 
            VALUES(vnum_producto, dtasa, danualidad, dcomision, dcat_origina, vfecha_ini, vfecha_fin);

            LET icont_commit = icont_commit + 1;
            IF  icont_commit = iCommit THEN
                COMMIT WORK;
                LET icont_commit = 0;            
            END IF  

        END FOREACH;

        IF  icont_commit <> 0 THEN
            COMMIT WORK;
            LET icont_commit = 0;
        END IF

    ----------------------------------------------
    ----------------------INSUMOS PARA LOS REPORTES----------------
        FOREACH WITH HOLD
            SELECT t.num_credito,t.num_producto,t.numcte,t.fecha_apertura,t.status_cred,t.relacion,t.linea_autorizada,t.limite_credito,t.num_pagos_vencidos,t.fecha
            INTO cnum_credito, cnum_producto, cnumcte, dfecha_apertura, cstatus_cred, irelacion, dlinea_autorizada, dlimite_credito, inum_pagos_vencidos,dfecha    
            FROM bdicred:tmpcreditos_cat t
            LEFT JOIN bdicred:sd_calc_cat_insumos p
                ON t.num_credito = p.num_credito 
    		AND t.num_producto = p.num_producto 
    		AND t.numcte = p.numcte
            WHERE p.num_producto IS NULL
    	    ORDER BY t.num_producto DESC

            IF  icont_commit = 0 THEN
                BEGIN WORK;
            END IF
                    
            --Se realiza el insert en la tabla 
            INSERT INTO bdicred:sd_calc_cat_insumos(num_credito,num_producto,numcte,fecha_apertura,status_cred,relacion,linea_autorizada,limite_credito,num_pagos_vencidos,fecha,catorigina,tasa,anualidad,comision)
            VALUES(cnum_credito, cnum_producto, cnumcte, dfecha_apertura, cstatus_cred, irelacion, dlinea_autorizada, dlimite_credito, inum_pagos_vencidos, dfecha,0,0,0,0);


            LET icont_commit = icont_commit + 1;
            IF  icont_commit = iCommit THEN
                COMMIT WORK;
                LET icont_commit = 0;            
            END IF  

        END FOREACH;

        IF  icont_commit <> 0 THEN
            COMMIT WORK;
            LET icont_commit = 0;
        END IF
    ----------------------------------------------
    ---------------------- REPORTES---------------- 
        
        FOREACH
            EXECUTE PROCEDURE bdicred:"informix".sp_calculo_cat_publicidad_rep()
            INTO cCodRet,cRutaGral
                    
            RETURN  cCodRet,cRutaGral WITH RESUME;
        END FOREACH;
       
        -- DROP TABLE bdicred:tmpcreditos_cat;     
        ----------------------------------------------
        -------------------- CAT X PRODUCTO------------------
        FOREACH WITH HOLD
            SELECT  producto,cat_origina 
            INTO vnum_producto,vcat
            FROM sd_calc_cat_publi
    	    ORDER BY producto ASC
            
            RETURN  vnum_producto,CAST(vcat AS DECIMAL(12,6)) WITH RESUME;
        END FOREACH;

        RETURN  cCodRet,cCodRet;

    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para Automatizar el calculo del CAT para un anio', 
'AUTOR : Adrian Curiel',
'Folio: RQM 10 1491 Automatizacion Calculo de CAT publicitario',
'Solicita: Christian Yair Rojas Velazquez',
'FECHA : 25/01/2024',

'MODIFICO :Jorge Arturo Astorga Matinez',
'DESCRIPCION:  Se modifica el componente se agrego uso de tabla temporal y ',
'se reacomodo la tabla de insumos.',
'FECHA : 14/05/2024',

'MODIFICO :Jorge Arturo Astorga Matinez',
'DESCRIPCION:  Se modifican las condiciones del query principal ', 
'se agrega NVL(b.numeric2,0) y e.monto_otorgado > 0; asi como tambien, se agrega obtencion correcta de linea_autorizada',
'FECHA : 18/06/2024',

'MODIFICO :Jorge Arturo Astorga Matinez - Keevin Adrian Gil Valenzuela',
'DESCRIPCION:  Se modifican debido a incidencia por creditos  con linea de credito $0', 
'FECHA : 22/08/2024',

'MODIFICO :Keevyn Adrian Gil Valenzuela',
'DESCRIPCION: Se modifica el query principal que obtiene los creditos para que muestre la fecha_apertura desde la maecred,', 
'Se ajusta validacion que se obtenga correctamente los creditos principales basado en el rango de fechas correspondiente',
'Se modifica para que la tasa del credito se obtenga desde la maecred',
'FECHA : 20/11/2024';

CREATE PROCEDURE "informix".sp_calculo_cat_publicidad(cProducto DECIMAL,cCredito DECIMAL, cTasa DECIMAL)
RETURNING CHAR(5) AS CodRet,DECIMAL AS cat,DECIMAL AS Comision,DECIMAL AS Anualidad;
    DEFINE iSqlErr INTEGER;
    DEFINE cCodRet CHAR(5);
    
    DEFINE cComision    DECIMAL;
    DEFINE cAnualidad   DECIMAL;
  
    DEFINE  i               INTEGER;
    
    DEFINE  vPmin           DECIMAL;
    DEFINE  vCod_comision   DECIMAL;   
    DEFINE  vComision       DECIMAL;
    DEFINE  vAnualidad      DECIMAL;
    DEFINE  vCobranza       DECIMAL;
    DEFINE  vSaldo          FLOAT;
    DEFINE  vIntereses      FLOAT;
    DEFINE  vSaldos         FLOAT;
    DEFINE  vPago           FLOAT;
    DEFINE  vDisposicion	FLOAT;
    DEFINE  vFlujo_Neto     FLOAT;

    
    DEFINE guess            DECIMAL(20, 5);
    DEFINE epsilon          DECIMAL(20, 5);
    DEFINE iterations       INTEGER;
    DEFINE npv              DECIMAL(32, 5);
    DEFINE tir              DECIMAL(20, 5);
    DEFINE cat              DECIMAL(32, 5);

	DEFINE vBanderaComisionApertura	CHAR(1);

     -- Establecer valores iniciales
    LET guess = 0.1;        -- Valor inicial 
    LET epsilon = 0.00001;  -- Valor segun necesidades
    LET iterations = 100;   -- Valor segun necesidades
    
    
    LET cCodRet     = '00000';
    LET cat         = '00000';
    LET cComision   = '00000';
    --LET cTasa       = '00000';
    LET cAnualidad  = '00000';
	LET vBanderaComisionApertura = '0';

    BEGIN
        
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;

                RETURN cCodRet,cat,cComision,cAnualidad;
            END IF;
        END EXCEPTION;
        
        --SET DEBUG FILE TO '/home/e99805728/sp_calculo_cat_publicidad.out';
		--SET DEBUG FILE TO '/ifxsif01/aastorga/sp_calculo_cat_publicidad2.out';
        --TRACE ON;

        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;


        TRUNCATE TABLE sd_calc_cat_calculo;

        ----------MES 1 Periodo 0 , 
        ----------------------------
        INSERT INTO sd_calc_cat_calculo ( Mes, Periodo, Linea, Comision, Anualidad, Cobranza, Saldo, Intereses, Saldos, Pago, Disposicion, Flujo_Neto )
        VALUES (1,0,cCredito,0,0,0,0,0,0,0,cCredito,-cCredito);  
        ----------------------------
        ----------------------------
              
        
        IF cProducto = 6600 THEN
           LET vAnualidad = 0 ;
        ELSE
            SELECT monto    -- Anualidad
            INTO cAnualidad
            FROM sd_tpcomis
            WHERE cod_comis = 
                CASE cProducto
                    WHEN 8500 THEN 'CATG'
                    WHEN 8100 THEN 'CAOT'
                    WHEN 7000 THEN 'CAPT'
                    WHEN 6001 THEN 'CAVT'
		    WHEN 5400 THEN 'CA54'
                END; 
        END IF;
        
        --Agregar validacion de bandera para definir monto a cobrar por anualidad
		
        SELECT d.factor_pago_min,d.cod_comision_apertura, d.cobro_comis_apertura, NVL(t.monto,0.00)  
        INTO vPmin,vCod_comision, vBanderaComisionApertura, vComision
        FROM sd_definicion d            
        LEFT JOIN sd_tpcomis t
        ON (t.cod_comis = d.cod_comision_apertura
			AND t.empresa = d.empresa)
        WHERE  d.num_producto = cProducto
		AND d.empresa = '001';
        
        LET cComision = 0;
        LET vCobranza = 0;

        IF vComision > 0.00 THEN 
            LET cComision = vComision;
        END IF ;
		
		IF vBanderaComisionApertura = '1' THEN
			LET cAnualidad = 0;
		END IF;
		
        -- i = Periodos
        FOR i = 1 TO 36
            IF i IN (1, 13, 25) THEN
             LET vAnualidad = cAnualidad;
            ELSE
                LET vAnualidad = 0 ;
            END IF ; 
            
            SELECT Saldos,Pago,Disposicion 
            INTO vSaldos,vPago,vDisposicion
            FROM sd_calc_cat_calculo
            WHERE Mes = i;
            
            LET vSaldo  = ROUND (vSaldos - vPago + vDisposicion, 6);
            LET vIntereses = ROUND ((((vSaldo * cTasa ) / 360)*30)/100, 6);
            LET vSaldos = ROUND (vComision + vAnualidad + vCobranza + vSaldo + vIntereses, 6);
        
            IF i = 36 THEN
             
                LET vPago = vSaldos;                
                LET vDisposicion = 0;
                
            ELSE
                LET vPago = ROUND ((vSaldos  * vPmin)/100, 6);
                
                IF cCredito < (vSaldos - vPago ) THEN
                 
                    LET vDisposicion = 0;
                ELSE
                
                    LET vDisposicion = ROUND (cCredito - (vSaldos - vPago ), 6);
                END IF;    
            END IF;            
        
            LET vFlujo_Neto = ROUND(vPago - vDisposicion,6);
            
            INSERT INTO sd_calc_cat_calculo( Mes, Periodo, Linea, Comision, Anualidad, Cobranza, Saldo, Intereses, Saldos, Pago, Disposicion, Flujo_Neto )
            VALUES (i+1,i,cCredito,vComision,vAnualidad,vCobranza,vSaldo,vIntereses,vSaldos,vPago,vDisposicion,vFlujo_Neto);         
        
            LET vComision = 0 ;
            
        END FOR;

            -- Calcular la TIR utilizando el metodo de Newton-Raphson
        LET tir = guess;
        LET npv = (SELECT SUM(flujo_neto / POWER(1 + tir, mes)) FROM sd_calc_cat_calculo);
        LET iterations = iterations - 1;

        WHILE ABS(npv) > epsilon AND iterations > 0
            LET tir = tir - npv / (SELECT SUM(-mes * flujo_neto / POWER(1 + tir, mes + 1)) FROM sd_calc_cat_calculo);
            LET npv = (SELECT SUM(flujo_neto / POWER(1 + tir, mes)) FROM sd_calc_cat_calculo);
            LET iterations = iterations - 1;
        END WHILE;

        LET cat = POWER(1 + tir,12) - 1;

        RETURN cCodRet,cat,cComision,cAnualidad;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento que devuelve el CAT del producto con el limite recibido', 
'AUTOR : Adrian Curiel',
'Folio: RQM 10 1491 Automatizacion Calculo de CAT publicitario',
'Solicita: Christian Yair Rojas Velazquez',
'FECHA : 25/01/2024',

'MODIFICO :Jorge Arturo Astorga Martinez',
'DESCRIPCION:  Se agrego validacion de la bandera cobro_comis_apertura.',
'FECHA : 18/06/2024',

'MODIFICO :Jorge Arturo Astorga Matinez',
'DESCRIPCION:  En la consulta donde se recupera el monto de la anulidad se agrego < WHEN 5400 THEN CA54 >,', 
'tambien, se agrego un join para realizar la asignacion de forma correcta',
'FECHA : 11/07/2024',

'MODIFICO :Keevyn Adrian Gil Valenzuela',
'DESCRIPCION: Se corrige validaciÃ³n para cuando la bandera cobro_comis_apertura estÃ© encendida, se cobra $0 de anualidad,', 
'Se recibe parametro de la tasa del credito',
'FECHA : 20/11/2024';

CREATE PROCEDURE "informix".sp_buscarctesamigrar_web(pnumcte CHAR(20),iOpcion INTEGER, pSucursal CHAR(4), pNombreEmbozado CHAR(60), pNumEjecutivo CHAR(8), pMigracionVisaActiva CHAR(1))
RETURNING	 CHAR(6), --Codigo Retorno
             CHAR(20), --Numero de Cliente
			 CHAR(20), --Numero de Credito
			 CHAR(60), --Direccion de la sucursal
			 CHAR(4), --Sucursal
			 CHAR(1), -- Bandera Verifica Estatus
			 CHAR(20),--Descripcion Estatus
			 CHAR(20),-- Fecha de solicitud
			 CHAR(10),--MONTO LINEA
			 CHAR(10),--IVA
			 CHAR(10),--INTERES MORATORIO
			 CHAR(10),--INTERES ORDINARIO
			 CHAR(6),--BIN
			 CHAR(8),--CODIGO DEL PRODUCTO
			 CHAR(8); --CLAVE TAJETA
			
             										 
DEFINE iSqlerr				INTEGER;
DEFINE iExiste				INTEGER;
DEFINE cCodret				CHAR(5);
DEFINE cCliente     		CHAR(20);
DEFINE cSucursal    		CHAR(20);
DEFINE iFlagstatus  		CHAR(1);
DEFINE cStatus      		CHAR(20);
DEFINE cFchsoli     		CHAR(20);
DEFINE cNomSuc      		CHAR(60);
DEFINE cLineaCredito 		CHAR(10);
DEFINE cCat          		CHAR(10);
DEFINE cInteresOrdinario 	CHAR(10);
DEFINE cInteresMoratorio 	CHAR(10);
DEFINE cCodBin      		CHAR(6);
DEFINE cCodProd 			CHAR(8);
DEFINE cCodClaveTar 		CHAR(8);
DEFINE cNumCredito 			CHAR(20);
DEFINE cDireccionSucursal 	CHAR(80);
DEFINE cSolOro 				VARCHAR(20);
DEFINE cLineaTeorica 		DECIMAL(18,2);
DEFINE v_valor		 		MONEY(14,2);
DEFINE v_capacidad_pago 	MONEY(14,2);
DEFINE iPlazo 				INTEGER; 
DEFINE sNombreCliente 		CHAR(100);
DEFINE sNumTarjeta			CHAR(16);
DEFINE sMiembro				CHAR(2);
DEFINE sCodRetOro           CHAR(6);
DEFINE sMsjRetOro           VARCHAR(100);

LET sCodRetOro              = '';
LET sMsjRetOro              = '';
--INICIALIZANDO VARIABLES
LET iSqlerr    			= 0;
LET iExiste	   			= 0;
LET cCodret    			= "00000";
LET cCliente  	 		= "";
LET iFlagstatus			= "";
LET cStatus    			= "";
LET cFchsoli   			= "";
LET cSucursal  			= "";
LET cNomSuc    			= "";
LET cLineaCredito		= "";
LET cCat                = "";
LET cInteresOrdinario	= "";
LET cInteresMoratorio	= "";
LET cCodBin				= "";
LET cCodProd			= "";
LET cCodClaveTar		= "";
LET cNumCredito 		= "";
LET cDireccionSucursal 	= "";
LET cSolOro 			= "";
LET cLineaTeorica 		= "";
LET v_valor		  		= 0;
LET v_capacidad_pago 	= 0;
LET iPlazo 		  		= 0;
LET sNombreCliente		= "";
LET sNumTarjeta			= "";
LET sMiembro			= "";


BEGIN
	ON EXCEPTION SET iSqlerr
		IF iSqlerr <> 0 THEN
			LET cCodret = iSqlerr;
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/Oscar/736/sp_buscarctesamigrar.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pnumcte IS NULL OR pnumcte = '' OR iOpcion is NULL  THEN
		LET cCodret="00100";
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
	

	SELECT numcte,num_credito,nomsuc,sucursal,flagstatussol,status,fchsoli 
	INTO cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli
	FROM bdicred:"informix".sd_ctesamigrar WHERE numcte = TRIM(pnumcte);
   
	IF iOpcion=0  THEN
		IF DBINFO("sqlca.sqlerrd2") = '0' THEN -- No existe el cliente
			LET cCodret="00001";
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		ELSE
			IF (iFlagstatus IS NULL OR iFlagstatus='' OR iFlagstatus=3) THEN
				RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
			END IF;
		END IF;
	END IF;
	
	IF iOpcion=1  THEN -- Solicitud Rechazada
		IF NVL(pSucursal,'') = '' THEN
			LET cCodret="00100";
		ELSE
			SELECT TRIM(suc.nombre), (TRIM(nvl(suc.direccion1,'')) || ", " || TRIM(nvl(suc.direccion2,'')) || ", " || TRIM(nvl(ciu.nombre,'')) || ", " || TRIM(nvl(est.nombre,''))) As Direccion  -- CAX se modifica para evitar error en update sd_ctesamigrar
			INTO cNomSuc,cDireccionSucursal
			FROM bdinteg: "informix".si_sucursales suc
			LEFT JOIN bdinteg: "informix".si_estados est
			ON est.estado = suc.estado
			LEFT JOIN bdinteg: "informix".si_ciudades ciu
			ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
			WHERE  suc.empresa = '001'
			AND sucursal = pSucursal
			AND suc.tpo_sucursal = 'S';
			
			UPDATE  bdicred:"informix".sd_ctesamigrar SET  flagstatussol='3',status="Rechazada",fchsoli=TO_CHAR(current), sucursal = pSucursal, nomsuc =  cNomSuc, domsuc = TRIM(cDireccionSucursal) WHERE numcte=pnumcte;
		END IF;
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
   
	IF iOpcion=2 THEN -- Solicitud Aceptada
		IF NVL(pSucursal, '') = '' OR NVL(pNombreEmbozado,'') = '' OR NVL(pNumEjecutivo,'') = '' THEN
			LET cCodret="00100";
		ELSE
			SELECT TRIM(suc.nombre), (TRIM(nvl(suc.direccion1,'')) || ", " || TRIM(nvl(suc.direccion2,'')) || ", " || TRIM(nvl(ciu.nombre,'')) || ", " || TRIM(nvl(est.nombre,''))) As Direccion -- CAX se modifica para evitar error en update sd_ctesamigrar
			INTO cNomSuc,cDireccionSucursal
			FROM bdinteg: "informix".si_sucursales suc
			LEFT JOIN bdinteg: "informix".si_estados est
			ON est.estado = suc.estado
			LEFT JOIN bdinteg: "informix".si_ciudades ciu
			ON suc.ciudad = ciu.ciudad and suc.estado = ciu.estado
			WHERE  suc.empresa = '001'
			AND sucursal = pSucursal
			AND suc.tpo_sucursal = 'S';			
			
			SELECT TRIM(apell_paterno) || " " || TRIM(apell_materno) || " " || TRIM(nombre1) || " " || TRIM(nombre2) AS Nombre, b.num_tarjeta , SUBSTR(YEAR(c.fecha_apertura),3,2)
			INTO sNombreCliente, sNumTarjeta, sMiembro
			FROM bdicred:"informix".sd_ctesamigrar a			
			INNER JOIN bdicred:"informix".sd_tarjeta b ON a.num_credito = b.num_credito
			INNER JOIN bdicred:"informix".sd_maecred c ON c.num_credito = a.num_credito
			WHERE a.numcte = pnumcte 
			AND a.num_credito = cNumCredito 
			AND b.numcte = a.numcte
			AND c.numcte = b.numcte
			AND b.status_tar in ('A','C') 
			AND b.secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta b WHERE B.num_credito = cNumCredito);  
			
			UPDATE  bdicred:"informix".sd_ctesamigrar SET  flagstatussol = '1',status = "Aceptada", fchsoli = TO_CHAR(current), sucursal = pSucursal, nomsuc =  cNomSuc, domsuc = TRIM(cDireccionSucursal) 
			WHERE numcte = pnumcte;
			
			LET sNombreCliente = REPLACE(sNombreCliente,"  ", " ");
			
			--INSERT INTO bdicred:"informix".sd_credito_upgrade(empresa, num_credito, numcte, numerotarjeta, numero_credito_upgrade, numerotarjeta_upgrade, num_producto_upgrade, tipotar, nombre, nombre_embosado, bandtarjpersonal, tipo_proceso, nombre_archivo, master, tipo_dom, miembro, resultado, bclonadocompleto, user_insert, fecha_insert, fecha_cancelaupgrade)
			--VALUES('001', cNumCredito, pnumcte, sNumTarjeta, '', '', '8100', 'TIT', TRIM(sNombreCliente), TRIM(pNombreEmbozado), '1', '1', '', '1', '1', sMiembro, '0', '0', pNumEjecutivo,CURRENT,NULL);

            EXECUTE PROCEDURE "informix".sp_graba_prod_upgrade('001', cNumCredito, pnumcte, sNumTarjeta, 'TIT', TRIM(sNombreCliente), 
             TRIM(pNombreEmbozado), '1', '1', pNumEjecutivo, '3', '', '8100') INTO sCodRetOro, sMsjRetOro;
			 LET sCodRetOro = SUBSTR(sCodRetOro, 2,5);
		
		    IF sCodRetOro <> "00000" THEN  -- Error en sp_graba_prod_upgrade
                LET cCodret = sCodRetOro;    
                UPDATE  bdicred:"informix".sd_ctesamigrar SET  flagstatussol = null,status = '', fchsoli = '' 
                WHERE numcte = pnumcte;
                    
                RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
            END IF
			
		END IF;		
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
  
	IF iOpcion=3 THEN
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
  
	IF iOpcion=4 THEN
	  --SE OBTIENE EL VALOR DE LA TASA DE INTERES ORDINARIO
	  SELECT a.valor,b.cat_caratula,b.monto_min_cred INTO cInteresOrdinario,Ccat,cLineaCredito
	  FROM bdinteg:"informix".si_fechavalor AS a,bdicred:"informix".sd_definicion AS b
	  WHERE a.tasa = b.cod_tasa_base AND fecha = (SELECT MAX(fecha)
	  FROM bdinteg:"informix".si_fechavalor
	  WHERE  tasa=b.cod_tasa_base)    --
	  AND b.num_producto = '8100';

	--SE OBTIENE EL VALOR DE LA TASA DE INTERES MORATORIO
	  SELECT a.valor INTO cInteresMoratorio
	  FROM bdinteg:"informix".si_fechavalor AS a, bdicred:"informix".sd_definicion AS b
	  WHERE a.tasa = b.cod_tasa_mora AND fecha = (SELECT MAX(fecha)
	  FROM bdinteg:"informix".si_fechavalor 
	  WHERE  tasa=b.cod_tasa_mora) AND b.num_producto = '8100';  -- FMV 13-MAY-11 SE OMITE a.tasa para mostrar las tasas en reporte
	  LET cInteresMoratorio = cInteresMoratorio - cInteresOrdinario;
		IF cInteresMoratorio < 0 THEN
				LET cInteresMoratorio= cInteresMoratorio * -1;
		END IF;
	RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
 
	IF iOpcion=5 then
		if pMigracionVisaActiva = '1' then
			let cCodProd = '008';
			let cCodClaveTar = '100';
		else 
			let cCodProd = '005';
			let cCodClaveTar = '007';
		end if;

		SELECT codproductotarjeta,clave_tipotarjeta,bin  
		INTO cCodProd,cCodClaveTar,cCodBin 
		FROM intercard:"informix".tipotarjeta 
		WHERE codproductotarjeta = cCodProd
		AND Tipo = 'C'
		AND clave = cCodClaveTar;
		
		RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
	END IF;
	
	IF iOpcion = 6 THEN
		IF NVL(pnumcte,'') = '' THEN
			LET cCodret="00100";
		ELSE
			DELETE bdicred:"informix".sd_credito_upgrade WHERE numcte = pnumcte AND num_credito = cNumCredito;		
			UPDATE bdicred:"informix".sd_ctesamigrar SET sucursal = '',nomsuc = '',domsuc = '',flagstatussol = null,status = '',fchsoli = '' WHERE numcte = pnumcte;
			RETURN cCodret,cCliente,cNumCredito,cNomSuc,cSucursal,iFlagstatus,cStatus,cFchsoli,cLineaCredito,cCat,cInteresOrdinario,cInteresMoratorio,cCodBin, cCodProd,cCodClaveTar;
		END IF;
	END IF;
	
  
END;
END PROCEDURE
DOCUMENT
'Se crea SP para consultar los  de clientes candidatos a actualizar su Tarjeta de Credito Visa Bancoppel a Tarjeta de Credito Oro Bancoppel',
'asi como actualizar su estatus (Aceptada, Rechazada) e insertar la solicitud.',
'AUTOR : Oscar Marquez 98681011',
'FECHA : 26/03/2021',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_reporte_pagos_atm()
RETURNING CHAR(5),     -- Codigo de Retorno
          CHAR(80);   -- Mensaje de retorno
		    

---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(5);
DEFINE cMensajeRet		CHAR(80);

DEFINE cRuta 			CHAR(80);
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_bloqueocuenta
DEFINE cBCCodret		CHAR(6);   
DEFINE CBCMensajeRet	CHAR(80); 

DEFINE cSql            	CHAR(2600);
DEFINE cNombreArchivo  	CHAR(100);
DEFINE cNombreArchivo1  CHAR(100);
DEFINE cConsulta		CHAR(2300);
DEFINE cEncabezado		CHAR(2300);


---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '00000';
LET cMensajeRet			= 'Proceso Exitoso';
LET cRuta 				= "";
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_bloqueocuenta
LET cBCCodret		= "";
LET CBCMensajeRet   = "";
LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr
   IF iSqlErr != 0 THEN
	  LET cCodRet = iSqlErr;
	  LET cMensajeRet = iIsamErr;
	  RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/informix/IvanZazueta/sp_reporte_pagos_atm.out";
--TRACE ON;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO WAIT 3;
--SET ISOLATION COMMITTED READ;
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

--RUTA PARA GENERAR EL ARCHIVO
SELECT valor
INTO cRuta
FROM "informix".sd_param  
WHERE empresa = '001' 
AND cod_param='49';

--SINO EXISTE LA RUTA DEL ARCHIVO	
IF dbinfo("sqlca.sqlerrd2") = 0 THEN
	LET cCodRet = '00001';
	LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
	RETURN cCodRet,cMensajeRet;
END IF;	 

--GENERA EL NOMBRE DEL ARCHIVO
LET cNombreArchivo = TRIM('concil_cob_atm_')||TO_CHAR(TODAY - 1,'%y%m%d')|| '.txt';
--LET cNombreArchivo1 = TRIM('SaldosInmateriales_aux')||TO_CHAR(TODAY,'%d%m%y')|| '.txt';
		
--SELECCIONA LOS DATOS QUE FUERON INSERTADOS EN LA TABLA 
LET cConsulta = "SELECT a.fecha, a.cajero, a.hora, a.folio, a.num_credito, a.monto_pagado, " 
				|| "CASE WHEN a.transacc IN ('0555', '0556', '0557', '0558', '0559', '0560', '0561') THEN " || "'Pago en Efectivo'" || " ELSE " 
                || " a.num_cuenta_tdd " || " END, " 
                || "CASE WHEN a.transacc IN ('0555', '0556', '0557', '0558', '0559', '0560', '0561') THEN " || "0.00" || " ELSE " 
                || " a.monto_pagado " || " END,0 " 
				|| "FROM bdicred:sd_pagos_reporte_atm a INNER JOIN bdicred:sd_definicion b ON b.num_producto = a.num_producto " 
				|| "WHERE fecha = TODAY - 1 AND a.codigo_retorno_bd = '00000' ORDER BY a.secuencia; " ;

--CREACION DE TEMPORALESS USADOS PARA LA CREACION DE ARCHIVO
LET cSql = '';
LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRuta)||TRIM(cNombreArchivo)||' DELIMITER '||'''|'''||' '||TRIM(cConsulta)||' "> '|| TRIM(cRuta) ||'pagos_atm.sql';
SYSTEM TRIM(cSql);

LET cSql = '';
LET cSql = "dbaccess bdicred "|| TRIM(cRuta) || "pagos_atm.sql";
SYSTEM TRIM(cSql);

/*
LET cSql = cSql;
LET cSql = "sed 's/|$SYSTEM cSql;
*/
	
--BORRADO DE TEMPORALES QUE FUERON USADOS PARA LA CREACION DE ARCHIVO
LET cSql = '';
LET cSQL = "rm "||TRIM(cRuta)||'pagos_atm.sql';		
SYSTEM TRIM(cSql); 
/*
LET cSQL = '' ;
LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
SYSTEM cSQL;   
*/
RETURN cCodRet,cMensajeRet;

END
END PROCEDURE
;