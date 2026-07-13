CREATE PROCEDURE "informix".sp_generaarchivocobranzacrediavancedospm(pCatConv CHAR(5))

--DEFINIR VARIABLES
DEFINE iSqlErr          INTEGER;
DEFINE cCodRet          CHAR      (5);
DEFINE cCategoria       CHAR      (2);
DEFINE cConvenio        CHAR      (3);
DEFINE cRutaArchCrediAv CHAR    (100);
DEFINE cNomArchivo		CHAR	 (30);
DEFINE dFecha_Hoy       DATE;
DEFINE dFechaHabilAnt   DATE;
DEFINE cFechaPago       CHAR      (8);
DEFINE cFolioSuc        CHAR     (16);
DEFINE cRef1            CHAR     (18);
DEFINE cImporte_pago    CHAR	 (11);
DEFINE cStmt		    CHAR    (500);
DEFINE bHeader 			BOOLEAN;
DEFINE cCodAux			CHAR      (5);
DEFINE dFechaIni        DATE;
DEFINE cDia				CHAR(2);
DEFINE cMes				CHAR(2);
DEFINE cAnio			CHAR(4);
DEFINE iForma_pago      CHAR(1);
DEFINE cForma_pago      CHAR(3);
DEFINE cSucursal        CHAR(4);
DEFINE ccve_ciudad      CHAR(3);
DEFINE cnomciudad       VARCHAR(60);
DEFINE ccve_estado      CHAR(2); 
DEFINE ccalle           VARCHAR(100);


--INICIALIZAR VARIABLES
LET iSqlErr          = 0;
LET cCodRet          = "00000";
LET cCategoria       = '';
LET cConvenio        = '';
LET cRutaArchCrediAv = '';
LET cNomArchivo		 = '';
LET dFechaHabilAnt   = DATE(1);
LET cFechaPago       = '';
LET cFolioSuc        = '';
LET cRef1            = '';
LET cImporte_pago    = '';
LET cStmt			 = '';
LET bHeader 		 = 'f';
LET cCodAux			 = '';
LET dFechaIni        = DATE(1);
LET cDia			 = '';
LET cMes			 = '';
LET cAnio            = '';
LET iForma_pago      = '';
LET cForma_pago      = '';
LET cSucursal        = '';
LET ccve_ciudad      = '';
LET cnomciudad       = '';
LET ccve_estado      = ''; 
LET ccalle           = '';


	--SET DEBUG FILE TO '/informix/enrique/sp_generaarchivocobranzacrediavance.out';
	--TRACE ON;
		
	BEGIN
		-- Errores de Informix
		ON EXCEPTION SET iSqlErr

         IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;

				INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
		        VALUES ('GEN_ARCH_COB_XDIA:  '||cCodRet,today,'0','informix',CURRENT,'1','sp_generaarchivocobranzacrediavancedospm','Generar archivo de cobranza crediavance dos pm');
            END IF;
		END EXCEPTION;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
        --Obtenemos categoria y convenio
        LET cCategoria  = SUBSTRING(pCatConv FROM 1 FOR 2); -- Separar  categoría 
        LET cConvenio   = SUBSTRING(pCatConv FROM 3 FOR 3); --    del convenio

        --Obtenemos fecha de bdisac:sac_fechas
        SELECT fecha_hoy 
        INTO   dFecha_Hoy
        FROM   bdisac:"informix".sac_fechas;


        --Obtenemos nombre de archivo de cobranza desde la tabla "bdisac:sac_convenios"
        SELECT TRIM(nombre_archivo_cobranza), TRIM(ruta_archivo_cobranza) 
        INTO   cNomArchivo, cRutaArchCrediAv
        FROM   bdisac:"informix".sac_convenios 
        WHERE  numcategoria = cCategoria
        AND    numconvenio  = cConvenio;

		--Reemplazamos el nombre del archivo consultado previamente en "bdisac:sac_convenios" y le agregamos los datos de la fecha actual.
        LET cDia = LPAD(DAY(dFecha_Hoy::DATE), 2, '0');
		LET cMes = LPAD(MONTH(dFecha_Hoy::DATE), 2, '0');
		LET cAnio = LPAD(YEAR(dFecha_Hoy ::DATE),4,'0');
     
        LET cNomArchivo = SUBSTR(cNomArchivo, 1, 3)  || -- CR_
                          cAnio                      || -- AAAA (Year)
                          cMes                       || -- MM   (Month)
                          cDia                       || -- DD   (Day)  
                          --SUBSTR(CURRENT, 12, 2)     || -- HH   (Hour) 
                          --SUBSTR(CURRENT, 14, 3)     || -- MM   (Minute) 
                          '1400.txt';						-- Resultado esperado: CR_AAAAMMDDHHMM.txt

        --Combinamos la ruta del archivo con el nombre de archivo actualizado.
        LET cNomArchivo = REPLACE(cNomArchivo,':','');
        LET cRutaArchCrediAv = TRIM(cRutaArchCrediAv) || TRIM(cNomArchivo);

        FOREACH				
            SELECT   SUBSTR(a.fecha_pago, 7, 4) || SUBSTR(a.fecha_pago, 1, 2) || SUBSTR(a.fecha_pago, 4, 2), 
                     LPAD(TRIM(a.folio_suc), 16, '0'), LPAD(TRIM(a.referencia1), 18, '0'), 
                     LPAD(REPLACE(REPLACE(a.importe_pago, '$', ''), '.', ''), 11, '0'),a.forma_pago,a.id_sucursal
            INTO     cFechaPago, cFolioSuc, cRef1, cImporte_pago,iForma_pago,cSucursal
            FROM     bdisac:"informix".sac_movimientos a
            WHERE    a.fecha_pago       = today       
            AND      extend (a.fecha_insert, hour to second) <= '14:00:00'
            AND      a.numcategoria     = cCategoria        
            AND      a.numconvenio      = cConvenio		
            AND      a.status_cancelado <> 'S' 
            AND     (a.flag_confirmacion_central = 1
            OR       a.flag_confirmacion_sucursal = 1)
            ORDER BY a.fecha_pago DESC
			
			--Este select se agrego para obtener el campo ciudad que se agrego al archivo de cobranza
			SELECT cve_estado,cve_ciudad,calle 
			INTO ccve_estado,ccve_ciudad,ccalle
			FROM bdinteg:si_ptf 
			WHERE id_ptf = cSucursal 
			AND tipo <> 'C'; 
			
			IF NVL(ccve_estado,'') = '' THEN 
				IF ccalle == 'INSURGENTES SUR' THEN 
					LET ccve_estado = '09';
				ELIF ccalle == 'AV. KIKI MURILLO' THEN
					LET ccve_estado = '25';
				ELSE 
					LET ccve_estado = '09';
				END IF;
			END IF;
			IF NVL(ccve_ciudad,'') != ''  THEN
				select nombre into cnomciudad from bdinteg:si_ciudades where estado = ccve_estado and ciudad = ccve_ciudad;
			ELIF ccalle == 'INSURGENTES SUR' THEN 
				LET cnomciudad = 'MIGUEL HIDALGO';
			ELIF ccalle == 'AV. KIKI MURILLO' THEN
				LET cnomciudad = 'CULIACAN';
			ELSE
				LET cnomciudad = 'MIGUEL HIDALGO';
			END IF;
			IF iForma_pago = "1"  THEN
				LET cForma_pago = "EFE";
			ELIF iForma_pago = "2"  THEN
				LET cForma_pago = "CC";
			ELSE
				LET cForma_pago = "O";
			END IF;

            IF bHeader = 't' THEN
                --Imprimir sólo filas de la consulta (sin encabezados)
                LET cStmt = 'echo "'
                ||cFechaPago || "|" || cFolioSuc || "|" || cRef1 || "|"	|| cImporte_pago || "|"	|| cForma_pago || "|"	|| cnomciudad || '" >> ' || cRutaArchCrediAv;

                SYSTEM cStmt;

                CONTINUE FOREACH;
            ELSE
                --Imprimir encabezados y primer fila de la consulta.
                LET cStmt = 'echo "' || 'Fecha    ' || 'Folio de operacion   ' 
                ||'Referencia      ' ||'Importe    ' ||'Instrumento monetario    ' ||'Ciudad o localidad    ' || '" >> ' || cRutaArchCrediAv;
                SYSTEM cStmt;

                LET cStmt = 'echo "' 
                ||cFechaPago || "|" || cFolioSuc || "|" || cRef1 || "|"	|| cImporte_pago || "|"	|| cForma_pago || "|"	|| cnomciudad || '" >> ' || cRutaArchCrediAv;		

                SYSTEM cStmt;

                LET bHeader = 't';

                CONTINUE FOREACH;

            END IF;

        END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
            --Consulta sin resultados, imprimir el archivo en blanco (sin encabezados, sin datos).
            LET cStmt = 'echo "" >> ' || cRutaArchCrediAv;
            SYSTEM cStmt;
        END IF;

		INSERT INTO sac_procesos_jobs (proceso,fecha_proceso,status,user_insert,fecha_insert,numero_ejecuciones,nombre_sp,descripcion)
		VALUES ('GEN_ARCH_COB_XDIA:  '||cCodRet,today,'1','informix',CURRENT,'1','sp_generaarchivocobranzacrediavancedospm','Generar archivo de cobranza crediavance dos pm');
	END
END PROCEDURE;