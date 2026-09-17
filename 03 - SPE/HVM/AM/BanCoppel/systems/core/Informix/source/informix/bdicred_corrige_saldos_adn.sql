CREATE PROCEDURE "informix".corrige_saldos_adn(eEmpresa CHAR(3))
RETURNING CHAR(5);



DEFINE NumCred     CHAR(20);
DEFINE Insoluto    DECIMAL(14,2);
DEFINE dDias_mora    INTEGER;
DEFINE dDiaAcumMora    INTEGER;
DEFINE dSaldoInt     DECIMAL(14,2);
DEFINE SdoMoratorio     DECIMAL(14,2);
DEFINE vSdoAcumMora     DECIMAL(14,2);  
DEFINE dRetenido     DECIMAL(14,2);  
DEFINE sql_err     INTEGER;
DEFINE isam_err    INTEGER;
DEFINE error_info  VARCHAR(60);
DEFINE CodRet      CHAR(5);
DEFINE MtoVencido DECIMAL(14,2);
DEFINE cSql              CHAR(2024);
DEFINE cRuta			 CHAR(100);
DEFINE cStatusCred			 CHAR(2);

   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "dupintercard.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

 --SET DEBUG FILE TO "/informix/jesus/scripts/factura.out";
 --TRACE ON;

LET CodRet ="000";
LET NumCred  ="";
LET Insoluto    =0;
LET dDias_mora    =0;
LET dDiaAcumMora    =0;
LET dSaldoInt     =0;
LET SdoMoratorio     =0;
LET vSdoAcumMora      =0;  
LET dRetenido      =0;
LET sql_err      =0;
LET isam_err    =0;
LET error_info = "";
LET cRuta = "/respaldos/";
LET cSql = "";
LET MtoVencido =0;
LET cStatusCred ='';
	  
	 
	 --- Crear una tabla temporal para insertar los datos de la consulta	
		IF NOT EXISTS (SELECT tabname FROM systables  WHERE tabname = 'sd_factura') THEN					 
				CREATE TABLE "informix".sd_factura (      
					num_credito        	CHAR(20) NOT NULL,
					dias_acum_mora     integer,
					saldo_int        	DECIMAL(14,2)   , 
					indicador 			CHAR(1) default '0',
					PRIMARY KEY(num_credito)
				)EXTENT SIZE 3540 NEXT SIZE 3548
				LOCK MODE ROW;				
						
			LET cSql = 'echo "LOAD FROM ' || TRIM(cRuta) || 'creditos_reconstruidos.unl' || ' INSERT INTO sd_factura (num_credito,dias_acum_mora,saldo_int  ); " > '|| TRIM(cRuta) || 'Ejecuta_Archivo.sql';
			SYSTEM cSql;		  

			--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
			LET cSql = "";
			LET cSql = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta_Archivo.sql';
			SYSTEM cSql;	

			LET cSql = "";
			LET cSQL = "rm " ||TRIM(cRuta)||'Ejecuta_Archivo.sql';		
			SYSTEM cSql; 
	
		END IF;

  
   update statistics medium for table sd_factura;
	
	  FOREACH WITH hold
		  SELECT a.num_credito,a.dias_acum_mora,a.saldo_int,b.status_cred
		  INTO NumCred, dDias_mora, dSaldoInt,cStatusCred
		  FROM "informix".sd_factura a, "informix".sd_maecred b
		  Where a.num_credito = b.num_credito 
		  AND  b.status_cred  IN('AA','BA','BT')
		  AND a.indicador = '0'
		 
		  --corrige mora
		 begin work;
		 
			IF  cStatusCred IN('BA','BT') then
				SELECT SUM(mora_provi_ordi +mora_provi_cope), SUM((mora_sdo_ordi- mora_sdo_ordi_pag) + ( mora_sdo_cope- mora_sdo_cope_pag))--,today - min(fecha_cuota)
					INTO SdoMoratorio , vSdoAcumMora--, dDiaAcumMora
				FROM  sd_amortiza_credito
				WHERE empresa = eEmpresa AND num_credito = NumCred 
				AND capital_status in (2,7);
			ELSE 
			LET SdoMoratorio  = 0;
			LET vSdoAcumMora  = 0;
			
			END IF 
					
			IF cStatusCred IN('BA','BT') AND dDias_mora > 0 THEN
				LET  dDiaAcumMora = dDias_mora +9 ;
			ELSE 
				LET  dDiaAcumMora = 0 ;
			END IF		
			--retenidos
			SELECT SUM(monto)
			INTO dRetenido
			FROM sd_maeretenido
			WHERE  empresa = eEmpresa
			AND num_credito = NumCred
			AND estatus = "P";

			UPDATE sd_maesdos
				SET sdo_int_anticip =NVL(dSaldoInt,0),
				sdo_intereses =NVL(dSaldoInt,0),
				sdo_acum_mes_int =NVL(dSaldoInt,0),
				sdo_retenido = NVL(dRetenido,0),
				dias_acum_int =30,
				sdo_moratorio = NVL(vSdoAcumMora,0),
				sdo_contab_mora   = NVL(SdoMoratorio,0),  	
				dias_acum_mora =dDiaAcumMora				
			WHERE num_credito = NumCred
			AND empresa = eEmpresa;
			
			UPDATE "informix".sd_factura 
			SET indicador ='1'
			WHERE num_credito = NumCred;
			
		   commit work;
	  END FOREACH
	  

RETURN CodRet;

END PROCEDURE
;