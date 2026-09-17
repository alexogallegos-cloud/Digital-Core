CREATE PROCEDURE "informix".sp_generaredoctaeje_factelect_pag(pEmpresa char(3))
    RETURNING   CHAR(5);
    
    DEFINE GLOBAL vidreg            INTEGER DEFAULT 0;
	DEFINE v_c_vcomienza            SMALLINT;
    DEFINE ven_transacc             SMALLINT;
    DEFINE v_c_vcontador            INTEGER;
    DEFINE vsqlerr                  INTEGER;
    DEFINE iIsamErr                 SMALLINT;
    DEFINE cErrorInfo               CHAR(80);
    DEFINE vcodret                  CHAR(5);
    DEFINE vsql                     CHAR(500);
	DEFINE vErrorInfo               CHAR(80);
	DEFINE vcStmt                   CHAR(250);
	DEFINE vcSql                    CHAR(600);
	DEFINE vfecha_ant               DATE;
	DEFINE vfecha_hoy               DATE;
	DEFINE dFechaEmision            DATE;
	DEFINE vultejec                 DATE;
	DEFINE vexiste_genedoctaeje     CHAR(3);
	DEFINE vcuenta                  CHAR(20);
	DEFINE vcta_cheques             CHAR(20);
	DEFINE dFechaInicioMovimientos  DATE;
	DEFINE dFechaFinMovimientos     DATE;
	DEFINE bInicia                  BOOLEAN;
	DEFINE vcodretEnc               CHAR(6);
	DEFINE vNum_cte                 CHAR(20);
	DEFINE vNombre_cte              CHAR(150);
	DEFINE vDireccion_cte           CHAR(200);
	DEFINE vDireccion_col           CHAR(120);
	DEFINE vDireccion_del           CHAR(120);
	DEFINE vEdo_cd                  CHAR(120);
	DEFINE vSucursal_nombre         CHAR(40);
	DEFINE vRFC_Cliente             CHAR(13);
	DEFINE vCP                      CHAR(5);
	DEFINE vCurp                    CHAR(60);
	DEFINE vFechaAltaEnc            DATE;
	DEFINE vFechaInicio             DATE;
	DEFINE vfechaFinal              DATE;
	DEFINE vSucursal_num            CHAR(4);
	DEFINE vCapitalInicial          DECIMAL(18,2);
	DEFINE vSaldoFinal              DECIMAL(18,2);
	DEFINE vInteresesPagados        DECIMAL(18,2);
	DEFINE vRetencionIsr            DECIMAL(18,2);
	DEFINE vInteresesNetos          DECIMAL(18,2);
	DEFINE viDias                   SMALLINT;
	DEFINE vTasa                    DECIMAL(9, 6);
	DEFINE vGAT                     DECIMAL(9, 6);
	DEFINE vMensajeProducto         CHAR(255);
	DEFINE vPiePagina               CHAR(255);
	DEFINE vestado                  CHAR(4);
	DEFINE vciudad                  VARCHAR(60); 
	DEFINE vtelefono                CHAR(14);
	DEFINE vgerente                 CHAR(40);
	DEFINE cNumProducto             CHAR(4);
	DEFINE vGATReal                 DECIMAL(9, 6);
	DEFINE vEnvioMovtos             SMALLINT;
	DEFINE vcorreo	                CHAR(100);
	DEFINE vsecuencia               INTEGER;
	DEFINE vnlinea                  INTEGER;
	DEFINE vmensaje                 CHAR(255);
	DEFINE vcomision                DECIMAL(18,2);
	DEFINE vaniomes                 CHAR(6);
	DEFINE vcodretDet               CHAR(6);
	DEFINE vdescripcion             CHAR(180);
	DEFINE vsdocuenta               MONEY(14,2);
	DEFINE vfechealt                DATE;
	DEFINE vdeposito                MONEY(14,2);
	DEFINE vretiro                  MONEY(14,2);
	DEFINE vruta_descarga           CHAR(60);
	DEFINE vfecha                   CHAR(8);
	DEFINE vanio 					INTEGER;
	DEFINE vresiduo				    INTEGER;
	DEFINE vaniobase                INTEGER;
	DEFINE vimpuesto                CHAR(3);
    DEFINE vtip_fact                CHAR(4);
	DEFINE vtasa_isr                DECIMAL(9,6);
	DEFINE vvalor_tasa              DECIMAL(9,6);
	DEFINE vvalor_tasa_base         DECIMAL(9,6);
	DEFINE vvalida_isr              DECIMAL(18,2);
	DEFINE vcanelada                INTEGER;   
	DEFINE vExportacion             CHAR(2);
	DEFINE vLongIden                CHAR(2);
	DEFINE vIdenRegFis              CHAR(3);
	DEFINE vObjImp                  CHAR(2); 
    DEFINE vbaseisr                 MONEY(16,2);
	DEFINE vBase                    MONEY (18,2);	
 
    LET v_c_vcomienza            = -1;	
    LET ven_transacc             = 0;
    LET v_c_vcontador            = 0;
    LET vsqlerr                  = 0; 
    LET iIsamErr                 = 0;
    LET cErrorInfo               = "";   
    LET vcodret                  = "";
    LET vsql                     = '';
	LET vultejec 			     = '';
	LET vErrorInfo               = "INICIO DEL PROCESO";
	LET vcStmt 				     = " "; 
	LET vfecha_ant               = ""; 
	LET vfecha_hoy               = ""; 
	LET dFechaEmision            = '';
	LET vcuenta 		         = ""; 
	LET vcta_cheques             = "";
	LET dFechaInicioMovimientos  = ''; 
	LET dFechaFinMovimientos 	 = '';
	LET bInicia    				= "F";
	LET vcodretEnC 				= ""; 
	LET vNum_cte  				= "";
	LET vNombre_cte 		    = "";
	LET vDireccion_cte 			= "";
    LET vDireccion_col 			= "";
    LET vDireccion_del 			= ""; 
    LET vEdo_cd 				= ""; 	
	LET vSucursal_nombre 		= ""; 
	LET vRFC_Cliente 			= "";
	LET vCP 					= "";
	LET vCurp 					= "";
	LET vFechaInicio 			= "";
	LET vfechaFinal 			= ""; 
	LET vSucursal_num  			= "";
	LET vSaldoFinal 			= 0;
	LET vInteresesPagados		= 0;
	LET vRetencionIsr 			= 0;
	LET vInteresesNetos 		= 0;
	LET viDias 					= 0;
	LET vTasa 					= 0;
	LET vGAT 					= 0;
	LET vMensajeProducto 		= '';
	LET vPiePagina 				= "";
	LET vestado                 = "";
	LET vciudad                 = "";
	LET vtelefono               = "";
	LET vgerente 				= "";
	LET cNumProducto 			= "";
	LET vGATReal 				= 0;
	LET vEnvioMovtos 			= 0;
	LET vcorreo 				= "";
	LET vidreg 					= 0;
	LET vCapitalInicial 		= 0;
	LET vsecuencia 				= 0;
	LET vnlinea 				= 0;
	LET vmensaje 				= '';
	LET vcomision 				= 0;
	LET vaniomes 				= " ";
	LET vcSql    				= " "; 
	LET vcodretDet 				= ""; 
	LET vdescripcion 			= "";
    LET vsdocuenta 				= 0;
	LET vfechealt 				= ""; 
	LET vdeposito 				= 0;
	LET vretiro 				= 0;
	LET vruta_descarga 			= '';
	LET vfecha 					= '';
	LET vaniobase               = 365;
	LET vimpuesto               = "ISR";
	LET vtip_fact               = "Tasa";
	LET vvalor_tasa             = 0;
	LET vExportacion            =  " ";
	LET vLongIden    		    =  " ";
	LET vIdenRegFis             =  " ";
	LET vObjImp                 =  "01";
	LET vbaseisr                = "0.0";
	LET vBase                   = 0.00;
	 
    BEGIN
	
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/edoctacfd/sp_generaredoctaeje_factelect_pag.err";
	 	    TRACE ON;
			LET vcodret = vsqlerr;
            LET vErrorInfo = cErrorInfo;
			
            IF  bInicia = "T" THEN	
                ROLLBACK WORK;
            END IF;
			LET vcSql = 'echo "UPDATE bdinvers:sv_contproc_edocta_factelect_pag '||
                        'SET status_proc = '''||'C'||''','||
                        'cod_ret = '''||vcodret||''','||
                        'mensaje = '''||vErrorInfo||''','||
                        'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdinvers:sc_fechas WHERE empresa = '''||pEmpresa||''') '||
                        'WHERE fecha = '''||vfecha_hoy||''' '||
                        'AND  status_proc = '''||'I'||''' '||
                        'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta_fe_pag.sql';
            SYSTEM vcSql;
            LET vcStmt = 'dbaccess bdinvers /tmp/contproc_edocta_fe_pag.sql';
            SYSTEM vcStmt;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
	
    --SET   DEBUG FILE TO '/RESPALDOSNEW/rsv/pagare/sp_generaredoctaeje_factelect_pag_log.txt';
    --TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;   
	
	 -- // Obtener la fecha de ayer y hoy
    SELECT fecha_ant,  fecha_hoy
    INTO   vfecha_ant, vfecha_hoy
    FROM   bdicheq:sc_fechas
    WHERE  empresa = pEmpresa;
	
	LET vanio    = YEAR(vfecha_hoy);
    LET vresiduo =  MOD(vanio, 4);
	  
    IF vresiduo  = 0 THEN 
       LET vaniobase = 366;
    END IF;
		
	SELECT valor
	INTO   vvalor_tasa
    FROM   bdinteg:si_fechavalor
    WHERE  tasa = 'I.S.R.'
    AND    fecha = (SELECT MAX(fecha)
                    FROM   bdinteg:si_fechavalor
                    WHERE  tasa = 'I.S.R.');
				 
	
	-- // Armar la fecha de emision
    LET dFechaEmision = vfecha_ant;
	
	--Obtiene la ultima fecha de ejecucion del proceso. 
    SELECT NVL(MAX(fecha),vfecha_ant)
    INTO   vultejec
    FROM   bdinvers:sv_contproc_edocta_factelect_pag
    WHERE  proceso = 'GENERA EDO CTA PAG'
    AND    empresa = pEmpresa
    AND    status_proc = 'F'
    AND    tipo_proc   = 'D';	
	
	IF vultejec >= vfecha_hoy THEN -- //se ejecuto hoy
       LET vcodret = '00000';
       RETURN vcodret;
    END IF;
	
	
	-- // si no hay registro de que el proceso haya quedado inconcluso se inserta uno nuevo, sino solo se actualiza
    SELECT empresa
    INTO   vexiste_genedoctaeje
    FROM   bdinvers:sv_contproc_edocta_factelect_pag
    WHERE  proceso = 'GENERA EDO CTA PAG'
    AND    fecha   = vfecha_hoy
    AND    empresa = pEmpresa
    AND    status_proc in ('I','C')
    AND    tipo_proc = 'D';
	
	IF vexiste_genedoctaeje is null OR vexiste_genedoctaeje = '' THEN
        LET vcSql = 'echo " INSERT INTO bdinvers:sv_contproc_edocta_factelect_pag (empresa, proceso, fecha, tipo_proc, status_proc, ejecutivo, hora_inicio, hora_fin, cod_ret, mensaje) '||
                    'VALUES('''||pEmpresa||''', '''||'GENERA EDO CTA PAG'||''', '''||vfecha_hoy||''', '''||'D'||''', '''||'I'||''', USER,'||
                    '(SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pEmpresa||'''),'||
                    'NULL,'''||vcodret||''', '''||vErrorInfo||''');" > /tmp/contproc_edocta_fe_pag.sql';
        SYSTEM vcSql;
        LET vcStmt = 'dbaccess bdinvers /tmp/contproc_edocta_fe_pag.sql';
        SYSTEM vcStmt;
    ELSE
        LET vcSql = 'echo " UPDATE bdinvers:sv_contproc_edocta_factelect_pag '||
                    'SET status_proc =  '''||'I'||''','||
                    'hora_inicio = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pEmpresa||'''),'||
                    'hora_fin = NULL '||
                    'WHERE fecha = '''||vfecha_hoy||''' AND status_proc = '''||'C'||''' AND  tipo_proc = '''||'D'||''';" > /tmp/contproc_edocta_fe_pag.sql';
        SYSTEM vcSql;
        LET vcStmt = 'dbaccess bdinvers /tmp/contproc_edocta_fe_pag.sql';
        SYSTEM vcStmt;
    END IF;
		
	-- Se obtiene el valor por el tipo de operacion del banco. 
	SELECT exportacion
	INTO   vExportacion
	FROM   bdicheq:sc_exportacion
	WHERE  exportacion = "01";

	-- // Obtener las cuentas a procesar para pagare
    FOREACH WITH HOLD
	
	        SELECT cuenta,  cta_cheques,  fecha_alta,              fecha_venc
            INTO   vcuenta, vcta_cheques, dFechaInicioMovimientos, dFechaFinMovimientos
	        FROM   bdinvers:sv_maeinv
            WHERE  status_cta <> 1
		    AND    cuenta NOT IN (SELECT num_cuenta_pag 
			                      FROM   bdinvers:sv_encabezado_edocta_factelect_pag
			                      WHERE  num_cuenta_pag = cuenta 
								  AND	 fechafinal = fecha_venc) 
		    AND fecha_venc BETWEEN vultejec AND vfecha_ant  
		    ---- AND fecha_venc BETWEEN '05102020' AND '05102020'
			---  AND fecha_venc BETWEEN '05052020' AND '05062020'
			
			LET vcanelada = 0;
			SELECT COUNT(*) 
			INTO   vcanelada
			FROM   bdinvers:sv_movhis 
			WHERE  cuenta = vcuenta
			AND    fech_alt BETWEEN dFechaInicioMovimientos AND dFechaFinMovimientos 
			AND    cancelad = 'S' 
			AND    transacc IN ('0500','0518');
			
			IF vcanelada = 0 THEN 
               BEGIN WORK;
               LET bInicia = "T";	
			   LET vidreg = vidreg + 1;
			   LET vcorreo = '';
			   
			   --Se ejecuta el proceso para obtener el encabezado del producto pagare
               EXECUTE PROCEDURE sp_generaredoctaejeencabezado_factelect_pag (pEmpresa,vcuenta,dFechaFinMovimientos)
                       INTO vcodretEnc, vNum_cte, vNombre_cte, vDireccion_cte, vDireccion_col, vDireccion_del, 
			           vEdo_cd,vSucursal_nombre, vRFC_Cliente, vCP, vCurp, vFechaAltaEnc, vFechaInicio, vfechaFinal, 
			           vSucursal_num, vCapitalInicial, vSaldoFinal,vInteresesPagados,vRetencionIsr, viDias, vTasa,
			   		   vGAT,vMensajeProducto, vPiePagina,vestado,vciudad, vtelefono, vgerente, cNumProducto, vGATReal, vEnvioMovtos; 
               
			   		
			   IF  TRIM(vcodretEnc) = '000' THEN
     		   	   SELECT correo_elec 
                   INTO   vcorreo
                   FROM   bdinteg:si_correos 
                   WHERE  numcte = vNum_cte 
                   AND    status_correo = 'A' 
                   AND    tipo_correo   = 1 
                   AND    valido        = 1
                   AND    secuencia = ( SELECT MAX(secuencia) 
			   						    FROM   bdinteg:si_correos 
			   						    WHERE  numcte        = vNum_cte 
			   						    AND    status_correo = 'A' 
			   						    AND    tipo_correo   = 1 
			   						    AND    valido        = 1 );
			   				 
			       IF  vcorreo IS NULL OR vcorreo = '' THEN  
			           LET vcorreo = ''; 
			       END IF; 
			   	
			   	   --TASA ISR 			
                   LET vvalor_tasa_base =  TRUNC( ( ( ( vvalor_tasa / 100 ) * viDias ) / vaniobase ), 6 );
			   	
			       /*	--VALIDA TASA
			       LET vvalida_isr = TRUNC((vCapitalInicial * vvalor_tasa_base),2);
			     	
			       IF vRetencionIsr <> vvalida_isr THEN 
			          LET vvalor_tasa_base = TRUNC((vvalor_tasa_base + 0.000001),6);
			       END IF; */
				   
				   
				   --Dependiendo de la longitud del RFC se definira un identificador:
			       --longitud de 12 posiciones = "601" - MORAL 
			       --longitud de 13 posiciones = "616" - FISICA
			       
			       LET vLongIden = LEN(vRFC_Cliente);
			       
			        SELECT indentificador
			        INTO   vIdenRegFis
			        FROM   bdicheq:sc_regfical
			        WHERE  longitud = vLongIden;
				   
                    LET vBase = vCapitalInicial;
				    
					IF  vBase > 0 THEN 
				        LET vObjImp = "02"; 
					ELSE 
					    LET vObjImp = "01";
					END IF;

			       INSERT INTO sv_encabezado_edocta_factelect_pag  
			   	   (
			   	   idreg,         fecha_emision,   num_cuenta_pag, num_cte,        nombre_cte,
			   	   direccion_cte, direccion_col,   direccion_del,  edo_cd,         sucursal_nombre,
                   rfc,           cp,              num_cuenta,     fechainicio,    mensajeproducto, 
			   	   fechafinal,    sucursal,        ciudad_suc,     siglas_edo_suc, telefono_suc,    
			   	   gerente_suc,   correo,          exportacion,    reg_fiscal,     obj_impuesto,      base
			   	   )
			   	   VALUES 
			   	   (
			   	   vidreg,         dFechaEmision,  vcuenta,        vNum_cte,     vNombre_cte,
			   	   vDireccion_cte, vDireccion_col, vDireccion_del, vEdo_cd,      vSucursal_nombre,
			   	   vRFC_Cliente,   vCP,            vcta_cheques,   vFechaInicio, vMensajeProducto,
			   	   vfechaFinal,    vSucursal_num,  vciudad,        vestado,      vtelefono,
			   	   vgerente,       vcorreo,        vExportacion,   vIdenRegFis,   vObjImp,            vBase                  
			   	   );
			   	
			   	   --Campo calculado para la validacion del campo retension ISR 
			   	   LET vbaseisr = vCapitalInicial;
				   
			   	   INSERT INTO sv_encabezado2_edocta_factelect_pag
			   	   (
			   	   idreg,        fecha_emision, num_cuenta_pag, capitalinicial, interesesganados, 
			   	   retencionisr, saldofinal,    diasperiodo,    tasa,           impuesto, 
			   	   tipo_factor,  tasa_isr,      baseisr
			   	   )
			   	   VALUES
			   	   (
			   	   vidreg,        dFechaEmision,    vcuenta, vCapitalInicial, vInteresesPagados,
			   	   vRetencionIsr, vSaldoFinal,      viDias,  vTasa,           vimpuesto,               
                   vtip_fact,     vvalor_tasa_base, vbaseisr                      
			   	   );
			   	   
			   	   --Inicializa las variables con el valor requerido. 
			   	   LET vsecuencia = 1;
                   LET vnlinea    = 1;
			   	
			   	
			   	   INSERT INTO sv_piepagina_edocta_factelect_pag
			   	   (
			   	   idreg,  fecha_emision, num_cuenta_pag, secuencia,  nlinea,  mensaje
			   	   )
			   	   VALUES
                   (
			   	   vidreg, dFechaEmision, vcuenta,        vsecuencia, vnlinea, vPiePagina
			   	   );	
               
			   	   --Ciclo utilizado para asignar la secuencia requerida 
                   FOREACH WITH HOLD  
			   	
                           SELECT nlinea,  mensaje,  secuencia
                           INTO   vnlinea, vmensaje, vsecuencia
                           FROM   bdinvers:sv_mensajes_producto
                           WHERE  producto = cNumProducto
                           AND    secuencia IN ('4','5','7','8','9')
                  
                           IF   vsecuencia = 2 THEN LET vsecuencia = 1; 
                           ELIF vsecuencia = 3 THEN LET vsecuencia = 2;
                           ELIF vsecuencia = 4 THEN LET vsecuencia = 3;
                           ELIF vsecuencia = 5 THEN LET vsecuencia = 4;
                           ELIF vsecuencia = 6 THEN LET vsecuencia = 5;
                           ELIF vsecuencia = 7 THEN LET vsecuencia = 6;
                           ELIF vsecuencia = 8 THEN LET vsecuencia = 7;
                           ELIF vsecuencia = 9 THEN LET vsecuencia = 9;
                           END IF;
                                                          
                           INSERT INTO sv_mensajes_edocta_factelect_pag
                           (
			   			   idreg,  fecha_emision, num_cuenta_pag, secuencia,  nlinea, mensaje
			   			   )
                           VALUES
                           (
			   			   vidreg, dFechaEmision, vcuenta,        vsecuencia, vnlinea,vmensaje
			   			   );
                   END FOREACH;
               
			   	
                   INSERT INTO sv_grafica_fe_pag
                   (
			   	   id_reg, fecha_emision, num_cuenta_pag, comisiones, gat,  gat_real
			   	   )
                   VALUES
                   (
			   	   vidreg, dFechaEmision, vcuenta,        vcomision,  vGAT, vGATReal
			   	   );
			   	
			       --Se asigna el valor anio mes del fin del campo fin de movimientos
			   	   LET vaniomes = TO_CHAR(dFechaFinMovimientos, '%Y%m');
			   	
                   
			   	   --// GENERA EL REGISTRO EN LA NUEVA TABLA DE CONSULTA DE ESTADOS DE CUENTA
                   INSERT INTO sv_maehis_factelect_pag
			   	   (
			   	   empresa, aniomes,  num_cuenta_pag, fechaini,                fechafin,            sdo_actual
			   	   )
                   VALUES
			   	   (
			   	   pEmpresa, vaniomes,vcuenta,        dFechaInicioMovimientos, dFechaFinMovimientos, vSaldoFinal
			   	   );	
		       
		       ELSE
                   ROLLBACK WORK;
                   LET bInicia = "F";
                   LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL ENCABEZADO ' || vcodretEnc;
                   LET vcodret = '003';
                   LET vcSql   = 'echo "UPDATE bdinvers:sv_contproc_edocta_factelect_pag '||
                                 'SET status_proc = '''||'C'||''','||
                                 'cod_ret = '''||vcodret||''','||
                                 'mensaje = '''||vErrorInfo||''','||
                                 'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pEmpresa||''') '||
                                 'WHERE fecha = '''||vfecha_hoy||''' '||
                                 'AND  status_proc = '''||'I'||''' '||
                                 'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta_fe_pag.sql';
                   SYSTEM vcSql;
                   LET vcStmt = 'dbaccess bdinvers /tmp/contproc_edocta_fe_pag.sql';
                   SYSTEM vcStmt;
                   RETURN vcodret;
               END IF;
               
			   -- // Ejecutar store para el detalle
               LET vsecuencia = 0;														   
	           
	           FOREACH
                     EXECUTE PROCEDURE sp_generaredoctaejedetalle_factelect_pag(pEmpresa, vcuenta, dFechaInicioMovimientos, dFechaFinMovimientos)
                             INTO vcodretDet, vdescripcion, vsdocuenta, vfechealt, vdeposito, vretiro
	           
	                 IF  TRIM(vcodretDet) <> "000"  AND TRIM(vcodretDet) <> '002' THEN
                         ROLLBACK WORK;
			   	         LET bInicia = "F";
                         LET vErrorInfo = 'FALLO EL PROCESO QUE GENERA EL DETALLE ' || vcodretDet;
                         LET vcodret = '004';
                         LET vcSql = 'echo "UPDATE bdinvers:sv_contproc_edocta_factelect_pag '||
                                     'SET status_proc = '''||'C'||''','||
                                     'cod_ret = '''||vcodret||''','||
                                     'mensaje = '''||vErrorInfo||''','||
                                     'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||''') '||
                                     'WHERE fecha = '''||vfecha_hoy||''' '||
                                     'AND  status_proc = '''||'I'||''' '||
                                     'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta_fe_pag.sql';
                         SYSTEM vcSql;
                         LET vcStmt = 'dbaccess bdinvers /tmp/contproc_edocta_fe_pag.sql';
                         SYSTEM vcStmt;
                         RETURN vcodret;
                     END IF;
               END FOREACH;
			   						
			   COMMIT WORK;
               LET bInicia = "F";  
            END IF; 			   
			
    END FOREACH;
	
	SELECT valor
    INTO   vruta_descarga
    FROM   bdicheq:sc_param
    WHERE  empresa = pEmpresa
    AND    codparam = 'RutaDescargaFED';
	
	LET vfecha = TO_CHAR(vfecha_ant, '%m%d%Y');
	
	-- // GENERA EL ARCHIVO DE LA TABLA sv_encabezado_edocta_factelect_pag
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(vruta_descarga)||'sv_encabezado_edocta_factelect_pag_'||vfecha||'.txt'||
               ' SELECT * FROM bdinvers:sv_encabezado_edocta_factelect_pag WHERE fecha_emision = '''|| vfecha_ant ||''' ORDER BY num_cuenta_pag" > '|| TRIM(vruta_descarga) ||'dskrga_fed_pag.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/edoctacfd/dskrga_fed_pag.sql";
    SYSTEM vsql;
	
	
	-- // GENERA EL ARCHIVO DE LA TABLA sv_encabezado2_edocta_factelect_pag
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(vruta_descarga)||'sv_encabezado2_edocta_factelect_pag_'||vfecha||'.txt'||
               ' SELECT * FROM bdinvers:sv_encabezado2_edocta_factelect_pag WHERE fecha_emision = '''|| vfecha_ant ||''' ORDER BY num_cuenta_pag" > '|| TRIM(vruta_descarga) ||'dskrga_fed_pag.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/edoctacfd/dskrga_fed_pag.sql";
    SYSTEM vsql;
    
    
	-- // GENERA EL ARCHIVO DE LA TABLA sv_detalle_edocta_factelect_pag
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(vruta_descarga)||'sv_detalle_edocta_factelect_pag_'||vfecha||'.txt'||
               ' SELECT * FROM bdinvers:sv_detalle_edocta_factelect_pag WHERE fecha_emision = '''|| vfecha_ant ||''' ORDER BY num_cuenta_pag" > '|| TRIM(vruta_descarga) ||'dskrga_fed_pag.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/edoctacfd/dskrga_fed_pag.sql";
    SYSTEM vsql;	
	
	
	-- // GENERA EL ARCHIVO DE LA TABLA sv_piepagina_edocta_factelect_pag
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(vruta_descarga)||'sv_piepagina_edocta_factelect_pag_'||vfecha||'.txt'||
               ' SELECT * FROM sv_piepagina_edocta_factelect_pag WHERE fecha_emision = '''|| vfecha_ant ||''' ORDER BY num_cuenta_pag" > '|| TRIM(vruta_descarga) ||'dskrga_fed_pag.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/edoctacfd/dskrga_fed_pag.sql";
    SYSTEM vsql;
	
	
	-- // GENERA EL ARCHIVO DE LA TABLA sv_mensajes_edocta_factelect_pag
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(vruta_descarga)||'sv_mensajes_edocta_factelect_pag_'||vfecha||'.txt'||
               ' SELECT * FROM bdinvers:sv_mensajes_edocta_factelect_pag WHERE fecha_emision = '''|| vfecha_ant ||''' ORDER BY num_cuenta_pag" > '|| TRIM(vruta_descarga) ||'dskrga_fed_pag.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/edoctacfd/dskrga_fed_pag.sql";
    SYSTEM vsql;
	
	
	 -- // GENERA EL ARCHIVO DE LA TABLA sv_grafica_fe_pag
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(vruta_descarga)||'sv_grafica_fe_pag_'||vfecha||'.txt'||
               ' SELECT * FROM bdinvers:sv_grafica_fe_pag WHERE fecha_emision = '''|| vfecha_ant ||''' ORDER BY num_cuenta_pag" > '|| TRIM(vruta_descarga) ||'dskrga_fed_pag.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/edoctacfd/dskrga_fed_pag.sql";
    SYSTEM vsql;
	
	
	-- // GENERA EL ARCHIVO DE LA TABLA sv_aclaraciones_edocta_factelect_pag
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(vruta_descarga)||'sv_aclaraciones_edocta_factelect_pag_'||vfecha||'.txt'||
               ' SELECT * FROM bdinvers:sv_aclaraciones_edocta_factelect_pag WHERE fecha_emision = '''|| vfecha_ant ||''' ORDER BY num_cuenta_pag" > '|| TRIM(vruta_descarga) ||'dskrga_fed_pag.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/edoctacfd/dskrga_fed_pag.sql";
    SYSTEM vsql;
	
	
	-- // COMPRESION DE ARCHIVOS DESCARGADOS
    LET vsql = '';
    LET vsql = '/usr/bin/gzip -9 '||TRIM(vruta_descarga)||'sv_encabezado_edocta_factelect_pag_'||vfecha||'.txt';
    SYSTEM vsql;
       
    LET vsql = '';
    LET vsql = '/usr/bin/gzip -9 '|| TRIM(vruta_descarga) ||'sv_encabezado2_edocta_factelect_pag_'||vfecha||'.txt';
    SYSTEM vsql;
       
    LET vsql = '';
    LET vsql = '/usr/bin/gzip -9 '||TRIM(vruta_descarga)||'sv_detalle_edocta_factelect_pag_'||vfecha||'.txt';
    SYSTEM vsql;
       
    LET vsql = '';
    LET vsql = '/usr/bin/gzip -9 '||TRIM(vruta_descarga)||'sv_piepagina_edocta_factelect_pag_'||vfecha||'.txt';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = '/usr/bin/gzip -9 '||TRIM(vruta_descarga)||'sv_mensajes_edocta_factelect_pag_'||vfecha||'.txt';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = '/usr/bin/gzip -9 '||TRIM(vruta_descarga)||'sv_grafica_fe_pag_'||vfecha||'.txt';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = '/usr/bin/gzip -9 '||TRIM(vruta_descarga)||'sv_aclaraciones_edocta_factelect_pag_'||vfecha||'.txt';
    SYSTEM vsql;
	
	
	-- // Actualizar el control de proceso
    LET vErrorInfo = 'PROCESO EXITOSO';
	LET vcodret = '00000';
    LET vcSql = 'echo "UPDATE bdinvers:sv_contproc_edocta_factelect_pag '||
                'SET status_proc = '''||'F'||''', '||
                'cod_ret = '''||vcodret||''', '||
                'mensaje = '''||vErrorInfo||''', '||
                'hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdicheq:sc_fechas WHERE empresa = '''||pempresa||''') '||
                'WHERE fecha = '''||vfecha_hoy||''' '||
                'AND status_proc = '''||'I'||''' '||
                'AND tipo_proc  = '''||'D'||''';" > /tmp/contproc_edocta_fe_pag.sql';
    SYSTEM vcSql;
    LET vcStmt = 'dbaccess bdinvers /tmp/contproc_edocta_fe_pag.sql';
    SYSTEM vcStmt;
	
	RETURN vcodret;
    END;
   
END PROCEDURE;