CREATE PROCEDURE "informix".sp_reporte_diario_cat()
	        RETURNING CHAR(06) AS resultado;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	--Variables--
	
	DEFINE cfechacaptura		DATETIME YEAR to FRACTION(5);
	DEFINE chfechacaptura		VARCHAR(16);
	DEFINE choracaptura			VARCHAR(16);
	DEFINE cfolio_csuac			VARCHAR(11);
	DEFINE cimporteoriginal     VARCHAR(16);
	DEFINE cempleado_registro	VARCHAR(9);
	DEFINE csucursal	        VARCHAR(4);
	DEFINE ctipo_movimiento     VARCHAR(20);
	DEFINE corigen_cargo        VARCHAR(20);
	DEFINE cnum_cliente			VARCHAR(9);
	DEFINE csucursal_apertura	VARCHAR(4);
	DEFINE cfecha_de_cargo	    DATE;
	DEFINE chfecha_de_cargo	    VARCHAR(16);
	DEFINE cfky_origen_evento   VARCHAR(4);
	DEFINE corigen			    VARCHAR(100);
	DEFINE cfky_tipo_evento		VARCHAR(4);
	DEFINE cevento			    VARCHAR(100);
	DEFINE ccanal	            VARCHAR(3);
	DEFINE cpreingreso          VARCHAR(11);
	
	DEFINE cfechahorallamada    VARCHAR(20);
	DEFINE cfecharesolucion     DATETIME YEAR to FRACTION(5);
	DEFINE chfecharesolucion    VARCHAR(16);
	DEFINE choraresolucion      VARCHAR(16);
	DEFINE cfolioconsecutivo    VARCHAR(15);
	DEFINE cprocede             CHAR(1);
	DEFINE cnumcte              VARCHAR(20);
	DEFINE cnumCteAnterior      VARCHAR(20);
	DEFINE cfechaCapturaTem     VARCHAR(16);
	DEFINE cfechaCaptAnterior   VARCHAR(16);
	
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
	DEFINE borraTablaFinal      INTEGER;

	LET borraTabla			=0;
	LET borraTablaFinal		=0;
	LET cfechacaptura		= ''; --DATE(1);
	LET chfechacaptura		='';
	LET choracaptura		='';
	LET cfolio_csuac		='';
	LET cimporteoriginal    ='';
	LET cempleado_registro	='';
	LET csucursal	        ='';
	LET ctipo_movimiento    ='';
	LET corigen_cargo       ='';
	LET cnum_cliente		='';
	LET csucursal_apertura	='';
	LET cfecha_de_cargo	    = DATE(1);
	LET chfecha_de_cargo	= DATE(1);
	LET cfky_origen_evento  ='';
	LET corigen			    ='';
	LET cfky_tipo_evento	='';
	LET cevento			    ='';
	LET ccanal	            ='';
	LET cpreingreso         ='';
	LET cfechahorallamada   ='';
    LET chfecharesolucion   ='';
	LET cfecharesolucion    ='';
	LET choraresolucion     ='';
	LET cfolioconsecutivo   ='';
	LET cprocede            ='';
	LET cnumCte             ='';
	LET cnumCteAnterior     ='';
	LET cfechaCapturaTem    ='';
	LET cfechaCaptAnterior  ='';
	
	LET dFechaHoy 		= DATE(1);
	LET iContador 		= 0;
	LET cCodRet      	= '00000';
	LET iSqlErr      	= 0;
	LET iIsamErr     	= 0;
	LET cQuery			= "";
	LET cRuta		 	= "/resplogifx/repaclaraciones/";
	LET cnom_Sql 		= 'Rep_Aclaracion_CAT_' ;

--****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

  BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            --LET cCodRet = iSqlErr;
			LET cCodRet = '00000';
			DROP TABLE "informix".acl_reporte_reporte_diario_cat;
			DROP TABLE "informix".acl_reporte_cat_temp;
			ROLLBACK WORK;
            --RETURN cCodRet,cMsjError;
			--RETURN cCodRet;
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/resplogifx/repaclaraciones/reporte_diario_cat.out';
    --TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

		SELECT count(*) INTO borraTabla
		FROM systables WHERE tabname ='acl_reporte_cat_temp';
		
		IF ( borraTabla > 0 ) THEN
			DROP TABLE "informix".acl_reporte_cat_temp;
		END IF;
		
		SELECT count(*) INTO borraTablaFinal
		FROM systables WHERE tabname ='acl_reporte_reporte_diario_cat';
		
		IF ( borraTablaFinal > 0 ) THEN
			DROP TABLE "informix".acl_reporte_reporte_diario_cat;
		END IF;

		BEGIN WORK;
	/* Crear tabla de descarga */
	    CREATE TABLE "informix".acl_reporte_reporte_diario_cat(
	    
	    numCte           VARCHAR(20),
	    fechahorallamada VARCHAR(25),
        folioconsecutivo VARCHAR(15),
		fecha_captura	 VARCHAR(20),
		hora_captura	 VARCHAR(20),
		folio_cs         VARCHAR(11),
		importeOriginal  VARCHAR(16),
		num_emp_registro VARCHAR(9),
		num_sucursal     VARCHAR(6),
		origen_cargo     VARCHAR(20),
		num_cliente      VARCHAR(9),
		num_suc_cta      VARCHAR(6),
		fecha_cargo   	 VARCHAR(20),
		tipo_origen      VARCHAR(4),
		origen_des       VARCHAR(100),  
		tipo_evento      VARCHAR(4),
		evento_des       VARCHAR(100),  
		canal            VARCHAR(3),
		fecharesolucion  VARCHAR(20),
		horaresolucion   VARCHAR(20),
		procede          CHAR(1),
	--	preingreso       VARCHAR(2),
		primary key (folio_cs)
		)extent size 74707 next size 11767 lock mode row;


		/* Fecha del dÃÂ­a*/
		SELECT fecha_hoy
	    into dFechaHoy
	    FROM bdinteg:"informix".si_fechas;
		-- pruebas
		--LET dFechaHoy = TODAY-8;
	
		
		SELECT  acl.num_cliente as numcte, 0 as folioconsecutivo, escor.nombre,acl.fechainicio,acl.folio_csuac,acl.importeoriginal,acl.num_empleado as empleado_registro, NVL(acl.num_sucursal,'CAT') as sucursal,
			acl.tipo_movimiento origen_cargo, -- V nacional F internacional
			acl.num_cliente, cred.sucursal as sucursal_apertura,date(mov.fechahora) as fecha_de_cargo, eve.fky_origen_evento,ori.descripcion as origen,
			acl.fky_tipo_evento, eve.descripcion as evento, can.descripcion as canal, /*, prod.numero_cuenta cuenta,tiprod.tipo_producto, tiprod.nombre*/
			acl.fecha_dictamen as fecharesolucion, acl.procede as procede
			FROM  "informix".acl_aclaracion acl
			LEFT JOIN  "informix".acl_movimiento  mov  ON mov.folio_csuac = acl.folio_csuac  AND acl.pky_aclaracion = mov.fky_aclaracion
			LEFT JOIN "informix".acl_tipo_evento eve ON acl.fky_tipo_evento = eve.pky_tipo_evento
			LEFT JOIN "informix".acl_origen_evento ori ON ori.pky_origen_evento= eve.fky_origen_evento AND ori.activo = 1
			LEFT JOIN "informix".acl_cat_tipo_aclaracion can ON can.pky_cat_tipo_aclaracion=acl.fky_cat_tipo_aclaracion
			LEFT JOIN "informix".acl_producto prod ON ( prod.pky_producto = acl.fky_producto)
			LEFT JOIN "informix".acl_tipo_producto tiprod ON (tiprod.pky_tipo_producto = prod.fky_tipo_producto)
			LEFT JOIN  bdicred:sd_maecred cred ON (prod.numero_cuenta=cred.num_credito  AND acl.num_cliente=cred.numcte )
			LEFT JOIN "informix".acl_estatus_corporativo escor ON (acl.fky_estatus_corp_analisis = escor.pky_estatus_corporativo)
            LEFT JOIN  "informix".acl_estatus_aclaracion esacl ON (acl.fky_estatus_aclaracion = esacl.pky_estatus_aclaracion)
			WHERE  fechacaptura >= dFechaHoy -- BETWEEN today-23 AND today-22
			AND fky_estatus_aclaracion > 1 --OR (acl.fky_estatus_aclaracion = 1  AND escor.nombre = 'PRE_INGRESO'))
			AND acl.folio_csuac IS NOT NULL 
			AND tiprod.tipo_producto = 1			
            INTO acl_reporte_cat_temp;

			INSERT INTO acl_reporte_cat_temp
			SELECT acl.num_cliente as numcte, 0 as folioconsecutivo, escor.nombre,acl.fechainicio,acl.folio_csuac,acl.importeoriginal, acl.num_empleado as empleado_registro, NVL(acl.num_sucursal,'CAT') as sucursal,
			acl.tipo_movimiento origen_cargo, -- V nacional F internacional
			acl.num_cliente,cheq.sucursal as sucursal_apertura,date(mov.fechahora) as fecha_de_cargo,eve.fky_origen_evento,ori.descripcion as origen,
			acl.fky_tipo_evento, eve.descripcion as evento, can.descripcion as canal,/* ,prod.numero_cuenta cuenta,tiprod.tipo_producto, tiprod.nombre,*/
			acl.fecha_dictamen as fecharesolucion, acl.procede as procede
			FROM "informix".acl_aclaracion acl
			LEFT JOIN "informix".acl_movimiento  mov  ON mov.folio_csuac = acl.folio_csuac  AND acl.pky_aclaracion = mov.fky_aclaracion
			LEFT JOIN "informix".acl_tipo_evento eve ON acl.fky_tipo_evento = eve.pky_tipo_evento
			LEFT JOIN "informix".acl_origen_evento ori ON ori.pky_origen_evento= eve.fky_origen_evento AND ori.activo = 1
			LEFT JOIN "informix".acl_cat_tipo_aclaracion can ON can.pky_cat_tipo_aclaracion=acl.fky_cat_tipo_aclaracion
			LEFT JOIN "informix".acl_producto prod ON ( prod.pky_producto = acl.fky_producto)
			LEFT JOIN "informix".acl_tipo_producto tiprod ON (tiprod.pky_tipo_producto = prod.fky_tipo_producto)
			LEFT JOIN bdicheq:sc_maechq cheq  ON (cheq.cuenta = prod.numero_cuenta AND cheq.num_cte = acl.num_cliente)
			LEFT JOIN  "informix".acl_estatus_corporativo escor ON (acl.fky_estatus_corp_analisis = escor.pky_estatus_corporativo)
            LEFT JOIN  "informix".acl_estatus_aclaracion esacl ON (acl.fky_estatus_aclaracion = esacl.pky_estatus_aclaracion)
			WHERE fechacaptura >= dFechaHoy -- BETWEEN today-22 AND today
			AND fky_estatus_aclaracion > 1-- OR (acl.fky_estatus_aclaracion = 1  AND escor.nombre = 'PRE_INGRESO'))
			AND acl.folio_csuac IS NOT NULL 
			AND tiprod.tipo_producto = 2;
		
	    FOREACH WITH HOLD
	        
	         SELECT numCte, folio_csuac, TO_CHAR(fechainicio,'%Y%m%d') AS fechaCapturaTem  INTO  cnumCte, cfolio_csuac, cfechaCapturaTem
			 FROM acl_reporte_cat_temp GROUP BY fechaCapturaTem, numCte, folio_csuac ORDER BY fechaCapturaTem, numCte
		
			 LET iContador = iContador + 1;
			 
			 IF cfechaCapturaTem <> cfechaCaptAnterior THEN
			    LET iContador = 1;
			 END IF;
			 
			 IF cnumCte = cnumCteAnterior AND cfechaCapturaTem = cfechaCaptAnterior THEN 
			    LET iContador = iContador - 1;
			    UPDATE acl_reporte_cat_temp SET folioconsecutivo= iContador WHERE folio_csuac = cfolio_csuac;
			 ELSE
			    UPDATE acl_reporte_cat_temp SET folioconsecutivo= iContador WHERE folio_csuac = cfolio_csuac;
			 END IF;
			 
			 LET cnumCteAnterior = cnumCte;
			 LET cfechaCaptAnterior = cfechaCapturaTem;
	    END FOREACH;
			
		LET iContador = 0;
		FOREACH WITH HOLD
            

			SELECT * INTO  cnumcte, cfolioconsecutivo, cpreingreso,cfechacaptura,cfolio_csuac,cimporteoriginal,cempleado_registro,csucursal,ctipo_movimiento,cnum_cliente,csucursal_apertura,cfecha_de_cargo,
			cfky_origen_evento,corigen,cfky_tipo_evento,cevento,ccanal, cfecharesolucion, cprocede
			FROM acl_reporte_cat_temp ORDER BY cfolio_csuac
			
			/* Formateo de Datos*/		
			
			IF cfechacaptura IS NOT NULL 
			THEN 
			LET chfechacaptura = TO_CHAR(cfechacaptura,"%d/%m/%Y");
			LET choracaptura = TO_CHAR(cfechacaptura,"%H:%M:%S");
			END IF;
			
			IF cfechacaptura IS NOT NULL
			THEN
			LET cfechahorallamada = TO_CHAR(cfechacaptura,"%d/%m/%Y %H:%M:%S");
			END IF;
			
			IF cfolioconsecutivo IS NOT NULL 
			THEN 
			LET cfolioconsecutivo = TO_CHAR(cfechacaptura,"%d%m%Y") || '_' || TRIM(cfolioconsecutivo);
			END IF;
			
			LET cfecharesolucion = cfecharesolucion;
			
			IF cfecharesolucion IS NOT NULL OR cfecharesolucion <> ''
			THEN 
			LET chfecharesolucion = TO_CHAR(cfecharesolucion,"%d/%m/%Y");
			LET choraresolucion = TO_CHAR(cfecharesolucion,"%H:%M:%S");
			ELSE
			LET chfecharesolucion = NULL;
			LET choraresolucion = NULL;
			END IF;	
			
			IF cfecha_de_cargo IS NOT NULL 
			THEN 
			LET chfecha_de_cargo = TO_CHAR(cfecha_de_cargo,"%d/%m/%Y");
			END IF;
					
			IF  ctipo_movimiento IS NOT NULL
			THEN
			LET ctipo_movimiento = DECODE(ctipo_movimiento,'V','Nacional','F','Internacional','',NULL,NULL,NULL);
			LET ctipo_movimiento = TRIM(ctipo_movimiento);
			END IF;
			
			
			/*IF  cpreingreso = 'PRE_INGRESO'
			THEN
			LET cpreingreso = 'SI';
			ELSE
			LET cpreingreso = 'NO';
			END IF;

			*/
			
			INSERT INTO acl_reporte_reporte_diario_cat(fechahorallamada, folioconsecutivo, fecha_captura, hora_captura ,folio_cs,importeOriginal,num_emp_registro,
			num_sucursal,origen_cargo,num_cliente,num_suc_cta,fecha_cargo,tipo_origen,origen_des,tipo_evento,evento_des,canal, fecharesolucion, horaresolucion, procede)
			VALUES(cfechahorallamada, cfolioconsecutivo, chfechacaptura, choracaptura ,cfolio_csuac,cimporteoriginal,cempleado_registro,csucursal,ctipo_movimiento,cnum_cliente,csucursal_apertura,chfecha_de_cargo,
			cfky_origen_evento,corigen,cfky_tipo_evento,cevento,ccanal, chfecharesolucion, choraresolucion, cprocede);
			
			LET cfechahorallamada   = NULL;
			LET cfolioconsecutivo   = NULL;
			LET cfechacaptura	    = NULL;
			LET chfechacaptura		= NULL;
			LET cfolio_csuac		= NULL;
			LET cimporteoriginal    = NULL;
            LET cempleado_registro  = NULL;
	        LET cfecha_de_cargo	    = NULL;
			LET csucursal           = NULL;
			LET ctipo_movimiento    = NULL;
			LET cnum_cliente  	    = NULL;
			LET csucursal_apertura  = NULL;
			LET cimporteoriginal    = NULL;
			LET cfky_origen_evento  = NULL;
			LET corigen				= NULL;
			LET cfky_tipo_evento    = NULL;
			LET cevento				= NULL;
			LET ccanal				= NULL;
			LET cpreingreso			= NULL;
			LET chfecharesolucion   = NULL;
			LET choraresolucion     = NULL;
			LET cfecharesolucion    = NULL;
			LET cprocede            = NULL;
					
			
			LET iContador = iContador + 1;
			IF iContador = 1000 THEN
			COMMIT WORK;
			LET iContador = 0;
			BEGIN WORK;
			END IF; 

			
		END FOREACH;
		COMMIT WORK;



		/*Generacion de Reporte Diario CAT*/
		LET cCons1 = "SELECT * FROM acl_reporte_reporte_diario_cat";

	--- Reportes Salida
		LET pArchDescarga  = cnom_Sql;

		/* COMENTAR PARA PRODUCCION */
		/*******************************************/
		--LET cRuta =  '/informix/PLL/';
		/*******************************************/

		LET cnom_Sql = 'salida_reporte_diario_cat.sql';
		LET cSQL1 = '">'||TRIM(cRuta)|| cnom_Sql;

	    -- LET pArchDescarga = TRIM(pArchDescarga) || lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
		LET pArchDescarga = TRIM(pArchDescarga) || lpad(year(dFechaHoy),4,'0') || lpad(month(dFechaHoy),2,'0') ||  lpad(day(dFechaHoy),2,'0') || '.txt';
				
		LET cQuery = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '|| TRIM(cRuta) ||"CuerpoR.txt delimiter '|'  "||TRIM(cCons1) || "" || cSQL1;
		SYSTEM TRIM(cQuery);

	    LET cQuery='chmod 777 '|| TRIM(cRuta)|| cnom_Sql;
		System cQuery;

		LET cQuery = 'dbaccess bdiaclaracion ' || TRIM(cRuta) || cnom_Sql;
		SYSTEM cQuery;
        
        LET cQuery = 'echo "FechayHoraLLamada|FolioConsecutivo|FechaIngreso|HoraIngreso|FolioCSUAC|Importe|EmpleadoRegristro|Suc|OriCargo|Cte|SucCta|FechaCargo|idOrigen|DescOrigen|idEvento|DescEvento|Canal|FechaResolucion|HoraResolucion|Dictamen">' 
		|| TRIM(cRuta) || "EncabezadoR.txt";
		SYSTEM cQuery;
        
		LET cQuery =  "/usr/bin/cat " || TRIM(cRuta)||"EncabezadoR.txt " || TRIM(cRuta)||"CuerpoR.txt > " || TRIM(cRuta) || pArchDescarga;
		SYSTEM cQuery;

		LET cSQL = '';
        LET cSQL = 'rm ' || TRIM(cRuta) || TRIM(cnom_Sql);
		SYSTEM cSQL;
		LET cSQL = 'rm ' || TRIM(cRuta) || "CuerpoR.txt";
		SYSTEM cSQL;
		LET cSQL = 'rm ' || TRIM(cRuta) || "EncabezadoR.txt";
        SYSTEM cSQL;

		DROP TABLE "informix".acl_reporte_reporte_diario_cat;
		DROP TABLE "informix".acl_reporte_cat_temp;

		RETURN cCodRet;
	END;
END PROCEDURE
;