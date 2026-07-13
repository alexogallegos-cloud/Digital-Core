CREATE PROCEDURE "informix".sp_acl_es_cliente_sv (p_numCte CHAR(20), p_numCta CHAR(20), p_numTar CHAR(20))

     RETURNING
        INTEGER AS isSmartVista;

	--definicion de variables--
	DEFINE isSmartVista 		INTEGER;

	DEFINE iSqlErr                      	INTEGER;

     -- InicializaciÃ³n de las variables.
	LET isSmartVista = 0;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN isSmartVista;
			END IF;
		END EXCEPTION;

		IF p_numCte != '' or p_numCte IS NOT NULL THEN
            select COUNT(*)
            INTO isSmartVista
			from bdinteg:si_credito_sv
			where numcte=p_numCte;
	    END IF;
	    
        IF isSmartVista = 0 AND (p_numCta != '' or p_numCta IS NOT NULL) THEN
            select COUNT(*)
            INTO isSmartVista
            from bdinteg:si_credito_sv
            where num_cuenta_clabe=p_numCta;
        END IF;
        
        IF isSmartVista = 0 AND (p_numTar != '' or p_numTar IS NOT NULL) THEN
            select COUNT(*)
            INTO isSmartVista
            from bdinteg:si_credito_sv
            where num_tdc=p_numTar;
        END IF;
		RETURN isSmartVista;
	END
END PROCEDURE
DOCUMENT
'Valida si el cliente existe en la tabla pivite de SV';

CREATE PROCEDURE "informix".sp_reporte_evidencias_3410()
	        RETURNING CHAR(06) AS resultado;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************		
	--Variables--
	DEFINE id_tipo_flujo		INTEGER;
	DEFINE tipo_flujo 			DATETIME YEAR TO MINUTE;
	DEFINE cFoliocsuac			CHAR(11);
	DEFINE p_interact           CHAR(1);
	DEFINE cFechacaptura		DATE;
	DEFINE cNumcliente			CHAR(9);
	DEFINE cFoliosuc			CHAR(20);
	DEFINE cNumuenta			CHAR(20);
	DEFINE cNumtarjeta			CHAR(16);
	DEFINE cStatustarjeta		VARCHAR(3);
	DEFINE chFechacancelacion	VARCHAR(25);  
	DEFINE chFecha_act_cvv2	    VARCHAR(25);  
	DEFINE chFecha_act_pin	    VARCHAR(25);  
	DEFINE cFechacancelacion	DATETIME YEAR to MINUTE;
	DEFINE cFechacancelacion2	DATETIME YEAR to MINUTE;
	DEFINE fecha_act_cvv2 		DATETIME YEAR to MINUTE;
	DEFINE fecha_act_pin 		DATETIME YEAR to MINUTE;
	DEFINE cod_giro             VARCHAR(8);
    DEFINE idComer              VARCHAR(15); 
	DEFINE ctokens63in          CHAR(550);
	DEFINE tokenC0              CHAR(37); 
	DEFINE dFechaHoy            DATE;
	DEFINE iContador 			INTEGER;
	DEFINE iSqlErr      		INTEGER;
	DEFINE iIsamErr     		INTEGER;
	DEFINE cMsjError      		CHAR(500);	
	DEFINE cCodRet      		CHAR(6); 
	DEFINE cCons1				CHAR(1000);
	DEFINE pArchDescarga		CHAR(150);
	DEFINE cnom_Sql				CHAR(100);
	DEFINE cSQL1				CHAR(200);
	DEFINE cRuta				CHAR(100);
	DEFINE cSQL                 CHAR(100) ;
	DEFINE cQuery			    CHAR(6000);
	DEFINE borraTabla           INTEGER;
	DEFINE postokenC0			INTEGER;
	DEFINE v_ref_comercio		VARCHAR(50);
	DEFINE v_pky_producto		INTEGER;
	DEFINE v_fky_tipo_movimiento INTEGER;
	DEFINE v_transaccion 		VARCHAR(10);
	DEFINE v_folio_suc			CHAR(20);
	DEFINE v_sucursal			VARCHAR(10);
	DEFINE v_estado             VARCHAR(50);
	DEFINE v_cod_postal         VARCHAR(10);
	DEFINE v_municipio          VARCHAR(70);
	DEFINE v_telefono     		VARCHAR(15);
	DEFINE v_fecha_consumo		DATETIME YEAR TO FRACTION;
	DEFINE v_num_autorizacion   CHAR(20);
	DEFINE v_tipo_producto		CHAR(2);
	
	LET borraTabla			=0;
	LET postokenC0			=0;
	LET chFechacancelacion	= NULL;
	LET chFecha_act_cvv2	= NULL;
	LET chFecha_act_pin	    = NULL;
	LET cFoliocsuac			= NULL;
	LET cFechacaptura		= NULL;
	LET cNumcliente			= NULL;
	LET cFoliosuc			= NULL;
	LET cNumuenta			= NULL;
	LET cNumtarjeta			= NULL;
	LET cStatustarjeta		= NULL;
	LET cFechacancelacion	= NULL;
	LET cFechacancelacion2	= NULL;
	
	
	LET id_tipo_flujo 		= NULL;
	LET tipo_flujo			= NULL;
	
	LET fecha_act_cvv2		= NULL;
	LET fecha_act_pin		= NULL;
	LET p_interact			= NULL;
	LET cod_giro        	= NULL; 
	LET idComer         	= NULL; 
	LET ctokens63in          = NULL;
	LET tokenC0            = NULL;
	LET dFechaHoy 		    = DATE(1);
	LET iContador 			=0;
	LET cCodRet      	= '00000';
	LET iSqlErr      	= 0;
	LET iIsamErr     	= 0;
	LET cQuery			= "";
	LET cRuta		 	= "/resplogifx/repaclaraciones/"; 
	LET cnom_Sql 		= 'ACL_Reporte_evidencias3410_' ;
	LET v_ref_comercio  = NULL;
	LET v_pky_producto  = NULL;
	LET v_fky_tipo_movimiento = NULL;
	LET v_transaccion		  = NULL;
	LET v_folio_suc		= NULL;
	LET v_sucursal		= NULL;
    LET v_estado        = NULL;
	LET v_cod_postal    = NULL;
	LET v_municipio     = NULL;
	LET v_telefono      = NULL;
	LET v_fecha_consumo = NULL;
	LET v_num_autorizacion = NULL;
	
--****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

  BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            --LET cCodRet = iSqlErr;
			LET cCodRet = '00000';	
			DROP TABLE "informix".acl_reporte_evidencia_3410;
			ROLLBACK WORK;
            --RETURN cCodRet,cMsjError;
			--RETURN cCodRet;
        END IF;
    END EXCEPTION;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO '/resplogifx/repaclaraciones/sp_reporte_evidencias_3410.out';
   -- TRACE ON; 

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
	    
		SELECT count(*) INTO borraTabla
		FROM systables WHERE tabname ='acl_reporte_evidencia_3410';
		         
		IF ( borraTabla > 0 ) THEN
			DROP TABLE "informix".acl_reporte_evidencia_3410;
		END IF;
	
		BEGIN WORK;
	
	/* Crear tabla de descarga */
	    CREATE TABLE "informix".acl_reporte_evidencia_3410(
	    folio_cs        VARCHAR(11),
        fechaChipNip	VARCHAR(20),
		tokens_63in     CHAR(550),
        token_C0     	CHAR(37),
        fechaCvv2Din	VARCHAR(20),
        fechaCancela	VARCHAR(20),
        statusTjt		CHAR(4),
        giroComercio  	VARCHAR(12),
        idComercio		VARCHAR(18),
		ref_comercio    VARCHAR(50),
		sucursal		VARCHAR(10),
		transaccion     VARCHAR(10),
		num_celular 	VARCHAR(15),
		estado 			VARCHAR(50),
		cod_postal 		VARCHAR(10),
		municipio		VARCHAR(70),
		num_autorizacion CHAR(20),
		fecha_consumo   DATETIME YEAR to FRACTION(5),
				primary key (folio_cs)
		)extent size 74707 next size 11767 lock mode row;
			  
	
		/* Fecha del dÃÂ­a*/
		SELECT fecha_hoy 
	    into dFechaHoy
	    FROM bdinteg:"informix".si_fechas;
		
		LET iContador = 0;
		FOREACH WITH HOLD 
			
			SELECT acl.folio_csuac,fechacaptura,prod.num_cliente,mov.folio_suc,prod.numero_cuenta, prod.numero_tarjeta,
					tjt.codstatustarjeta,fecha, mov.ref_comercio, prod.pky_producto, mov.fky_tipo_movimiento, mov.fecha_consumo, mov.referencia, mov.num_sucursal
				INTO cFoliocsuac,cFechacaptura,cNumcliente,cFoliosuc,cNumuenta,cNumtarjeta,cStatustarjeta,cFechacancelacion2, 
					 v_ref_comercio, v_pky_producto, v_fky_tipo_movimiento, v_fecha_consumo, v_num_autorizacion, v_sucursal
				 FROM acl_aclaracion acl
				 LEFT JOIN "informix".acl_producto prod ON prod.pky_producto = acl.fky_producto 
				 LEFT JOIN "informix".acl_movimiento  mov  on mov.folio_csuac = acl.folio_csuac  and acl.pky_aclaracion = mov.fky_aclaracion
				 LEFT JOIN intercard:tarjeta tjt ON (tjt.numtarjeta  = prod.numero_tarjeta)
				 LEFT JOIN intercard:bitacoracancelaciontarjetas bitcan ON (bitcan.tarjeta = prod.numero_tarjeta)
				 WHERE acl.fechacaptura  >= today--BETWEEN today-6 AND today-1 
				 AND acl.folio_csuac is not null
				 /* Quitar para produccion */
				--  WHERE acl.fechacaptura >= today -28 
				-- AND acl.fky_estatus_aclaracion IN (2,3)
				 
            /*    
			SELECT MIN(fecha) INTO cFechacancelacion2
			FROM intercard:bitacoracancelaciontarjetas WHERE tarjeta IN (cNumtarjeta); 		
            */			
							
			/* Fecha de Alta de Chip+Nip CAMPO2 */
			SELECT MIN(fechahora_insert) INTO fecha_act_pin
			FROM intercard:bit_pinoffline WHERE tarjeta_edofinal = 1 
			AND  numtarjeta IN (cNumtarjeta);
		 
			SELECT MIN(fechacambio) 
			INTO  fecha_act_cvv2 
			FROM intercard:"informix".bitacoracambiostarjeta 
			WHERE tarjeta = cNumtarjeta AND  numcliente = cNumcliente AND identificadorcambio = 9;
			--ORDER BY secuencial desc;
			
			LET v_folio_suc = cFoliosuc;
				/* Giro comercion  */  
			LET p_interact= SUBSTRING(cFoliosuc FROM 0 FOR 2);
			IF 	(p_interact = 'i') THEN	 
			LET cFoliosuc = substr(cFoliosuc,2);
			END IF;
			
			select codgironeg,idretailer,tokens63in
			INTO cod_giro,idComer,ctokens63in
			from intercard:movimiento where numtarjeta in (cNumtarjeta)
			and secuenciaextendida= (cFoliosuc);
			
			IF cod_giro IS NULL OR idComer = '' 
			THEN 
				SELECT codgironeg,idretailer,tokens63in
				INTO cod_giro,idComer,ctokens63in
				FROM intercard:movimientohistorico where numtarjeta in (cNumtarjeta)
				AND secuenciaextendida= (cFoliosuc);
			END IF;
			
			IF ctokens63in IS NOT NULL 
			THEN
			LET postokenC0 = CHARINDEX('! C000026', ctokens63in);
			IF postokenC0 > 1 THEN
			LET tokenC0 = SUBSTR (ctokens63in, postokenC0, 37);
			END IF;
			END IF;
			
			----Obtener la transacciÃÂ³n del movimiento
			SELECT transaccion
				INTO v_transaccion
			FROM acl_tipo_movimiento 
			WHERE pky_tipo_movimiento = v_fky_tipo_movimiento;
			
			----Obtener la sucursal por del movimiento
			SELECT tp.tipo_producto
				INTO v_tipo_producto
			FROM acl_producto pro
				INNER JOIN acl_tipo_producto tp on tp.pky_tipo_producto = pro.fky_tipo_producto
			WHERE pro.pky_producto = v_pky_producto;
			
			IF v_sucursal IS NULL THEN
				--IF v_transaccion IS NOT NULL THEN
				
					IF v_tipo_producto = '1' THEN
						Select sucursal
							into v_sucursal
						from bdicred:sd_movdia where folio_suc = v_folio_suc and transacc_suc = v_transaccion;
						
						IF v_sucursal IS NULL OR v_sucursal = '' THEN
							Select sucursal
								into v_sucursal
							from bdicred:sd_movhis where folio_suc = v_folio_suc and transacc_suc = v_transaccion;
						END IF;
						
						--IF v_sucursal IS NULL OR v_sucursal = '' THEN
						--	Select sucursal
						--		into v_sucursal
						--	from bdicred:sd_movhis_old where folio_suc = v_folio_suc and transacc_suc = v_transaccion and ;
						--END IF;
										
					--END IF;
					
					IF v_tipo_producto = '2' THEN
						
						Select sucursal
							into v_sucursal
						from bdicheq:sc_movdia where folio_suc = v_folio_suc and transacc = v_transaccion;
						
						IF v_sucursal IS NULL OR v_sucursal = '' THEN
							Select sucursal
								into v_sucursal
							from bdicheq:sc_movhis where folio_suc = v_folio_suc and transacc = v_transaccion;
						END IF;
						
						IF v_sucursal IS NULL OR v_sucursal = '' THEN
							Select sucursal
								into v_sucursal
							from bdicheq:sc_movdia where folio_suc = v_folio_suc and transacc = v_transaccion;
						END IF;
						
						----Si no encuentar en debito busca en inversiones
						IF v_sucursal IS NULL OR v_sucursal = '' THEN
							SELECT sucursal
								into v_sucursal
							FROM bdinvers:sv_movdia
							WHERE folio_suc = v_folio_suc
								AND transacc=v_transaccion AND cuenta = cNumuenta;
						END IF;
						
						IF v_sucursal IS NULL OR v_sucursal = '' THEN
							SELECT sucursal
								into v_sucursal
							FROM bdinvers:sv_movhis
							WHERE folio_suc = v_folio_suc
								AND transacc=v_transaccion AND cuenta = cNumuenta;
						END IF;
					END IF;
				END IF;
			END IF;
			
			---Se obtienen los datos del cliente como celular, municipio, codigo postal y estado.
			select first 1 es.nombre ,si.cod_postal ,sz.municipiozona, ta.telefono
				INTO v_estado, v_cod_postal, v_municipio, v_telefono
			from bdinteg:si_direcciones_actual si
			left join bdinteg:si_estados es on si.estado=es.estado
			left join bdinteg:si_municipios mu on si.municipio=mu.municipio
			Left Outer Join bdinteg:si_catzonas sz on sz.numerociudad = si.numerociudad and sz.numerocolonia = si.numerocolonia
			INNER JOIN bdinteg:si_telefonos_actual ta on si.numcte = ta.numcte and ta.tipo_tel = '2' 
			Where  si.tipo_dir = 1 and si.numcte = cNumcliente;
			
			----Se obtiene el numero de autorizaciÃÂ³n
			LET v_num_autorizacion = substr(v_num_autorizacion,11);
			
			SELECT MIN(fechahora) INTO cFechacancelacion
			FROM intercard:bitacoracambiosstatustarjeta
            WHERE codstatustarjetanvo = 'CAN'
            AND tarjeta = cNumtarjeta;
			
			IF cFechacancelacion2 IS NOT NULL 
			THEN 
			LET cFechacancelacion = cFechacancelacion2;
			LET chFechacancelacion = TO_CHAR(cFechacancelacion,"%d/%m/%Y %H:%M");
			END IF;
			
			IF cFechacancelacion IS NOT NULL 
			THEN 
			LET chFechacancelacion = TO_CHAR(cFechacancelacion,"%d/%m/%Y %H:%M");
		    END IF;
			
			IF fecha_act_pin IS NOT NULL 
			THEN 
			LET chFecha_act_pin = TO_CHAR(fecha_act_pin,"%d/%m/%Y %H:%M");
		    END IF;
			
			IF fecha_act_cvv2 IS NOT NULL 
			THEN 
			LET chFecha_act_cvv2 = TO_CHAR(fecha_act_cvv2,"%d/%m/%Y %H:%M");
		    END IF;
			
			IF chFecha_act_pin IS NOT NULL 
			THEN 
			LET chFecha_act_pin = TRIM(chFecha_act_pin);
			END IF;
			
			IF chFecha_act_cvv2 IS NOT NULL 
			THEN 
			LET chFecha_act_cvv2 = TRIM(chFecha_act_cvv2);
			END IF;
					
			IF chFechacancelacion IS NOT NULL 
			THEN 
			LET chFechacancelacion = TRIM(chFechacancelacion);
			END IF;
			
			IF cod_giro IS NOT NULL 
			THEN 
			LET cod_giro = TRIM(cod_giro);
			END IF;
			
		    IF idComer IS NOT NULL 
			THEN 
			LET idComer = TRIM(idComer);
			END IF;
			
     		INSERT INTO acl_reporte_evidencia_3410(folio_cs,fechaChipNip,tokens_63in,token_C0,
			fechaCvv2Din,fechaCancela,statusTjt,giroComercio,idComercio, ref_comercio, sucursal,transaccion, num_celular,estado ,
			cod_postal, municipio,num_autorizacion, fecha_consumo)
			VALUES (cFoliocsuac,chFecha_act_pin,ctokens63in,tokenC0,chFecha_act_cvv2,chFechacancelacion,cStatustarjeta,cod_giro,idComer, 
			v_ref_comercio, v_sucursal, v_transaccion, v_telefono,v_estado , v_cod_postal, v_municipio,v_num_autorizacion, v_fecha_consumo);
			
			LET chFechacancelacion	= NULL;
	        LET chFecha_act_cvv2	= NULL;
	        LET chFecha_act_pin	    = NULL;
			LET tokenC0             = NULL;
			LET postokenC0          =0;
			LET ctokens63in         = NULL;
			LET cStatustarjeta      = NULL;
			LET cod_giro            = NULL;
			LET idComer             = NULL;
			LET v_ref_comercio  = NULL;
			LET v_pky_producto  = NULL;
			LET v_fky_tipo_movimiento = NULL;
			LET v_transaccion		  = NULL;
			LET v_folio_suc		= NULL;
			LET v_sucursal		= NULL;
			LET v_estado        = NULL;
			LET v_cod_postal    = NULL;
			LET v_municipio     = NULL;
			LET v_telefono      = NULL;
			LET v_fecha_consumo = NULL;
			LET v_num_autorizacion = NULL;
	
			
			LET iContador = iContador + 1;
					
			IF iContador = 1000 THEN
			COMMIT WORK;
			LET iContador = 0;
			BEGIN WORK;
			END IF; 

			
		END FOREACH;
		
		COMMIT WORK;
		
		
		
		/*Generacion de Reporte Diario CAT*/
		LET cCons1 = "SELECT * FROM acl_reporte_evidencia_3410";
				
	--- Reportes Salida
		LET pArchDescarga  = cnom_Sql; 
		
		/* COMENTAR PARA PRODUCCION */
		/*******************************************/
		--LET cRuta =  '/informix/PLL/';
		/*******************************************/
		
		LET cnom_Sql = 'salida_reporte_evidencias.sql';
		LET cSQL1 = '">'||TRIM(cRuta)|| cnom_Sql;
				
	    LET pArchDescarga = TRIM(pArchDescarga)  ||  lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
		LET cQuery = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(cRuta) ||"Cuerpo.txt delimiter '|'  "||TRIM(cCons1) || "" || cSQL1;
		SYSTEM TRIM(cQuery);
	
	    LET cQuery='chmod 777 '|| TRIM(cRuta)|| cnom_Sql;
		System cQuery;
	
		LET cQuery = 'dbaccess bdiaclaracion ' || TRIM(cRuta) || cnom_Sql;
		SYSTEM cQuery;
		
		LET cQuery = 'echo "Folio_csuac|Alta_Chip+Nip|Tokens63in|TokenC0|Alta_cvv2Din|Fecha_cancelacion|Estatus_cancelacion|Giro_Comer|Id_comer|REFERENCIA_COMERCIO|SUCURSAL|NUMERO_TRANSACCIÃN|CELULAR|ESTADO|CODIGO_POSTAL|MUNICIPIO|NUMERO_AUTORIZACIÃN|FECHA_CONSUMO|">' || TRIM(cRuta) || "Encabezado.txt";
		SYSTEM cQuery;
				
		LET cQuery =  "/usr/bin/cat " || TRIM(cRuta)||"Encabezado.txt " || TRIM(cRuta)||"Cuerpo.txt > " || TRIM(cRuta) || pArchDescarga;
		SYSTEM cQuery;
		
		LET cSQL = '';
        LET cSQL = 'rm ' || TRIM(cRuta) || TRIM(cnom_Sql);
		SYSTEM cSQL;
		LET cSQL = 'rm ' || TRIM(cRuta) || "Cuerpo.txt";
		SYSTEM cSQL;
		LET cSQL = 'rm ' || TRIM(cRuta) || "Encabezado.txt";
        SYSTEM cSQL;
		
		DROP TABLE "informix".acl_reporte_evidencia_3410;		
		RETURN cCodRet;
	END;
END PROCEDURE;