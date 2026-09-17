CREATE PROCEDURE "informix".sp_medalia_atm(pEmpresa CHAR(3))
RETURNING VARCHAR(5), VARCHAR(5), VARCHAR(50), INTEGER;

--Definicion de variables
DEFINE vsql                 LVARCHAR(1800);
DEFINE vstmt                LVARCHAR(300);
DEFINE vNombreCliente       LVARCHAR(120);
DEFINE vcorreo              VARCHAR(100);
DEFINE Desc_Err             VARCHAR(80);
DEFINE vCodRet3             VARCHAR(80);
DEFINE vdesc_transacc       VARCHAR(80);
DEFINE vfecha_ant_ext1		VARCHAR(50);
DEFINE vfecha_ant_ext2		VARCHAR(50);
DEFINE vnombre_suc          VARCHAR(40);
DEFINE vstatus_transacc     VARCHAR(40);
DEFINE vnombre1             VARCHAR(30);
DEFINE vnombre2             VARCHAR(30);
DEFINE vapell_paterno       VARCHAR(30);
DEFINE vapell_materno       VARCHAR(30);
DEFINE vNumCliente          VARCHAR(20);
DEFINE vmodelo_cajero       VARCHAR(20);
DEFINE vubicacion_cajero    VARCHAR(20);
DEFINE vtel_casa            VARCHAR(13);
DEFINE vtel_movil           VARCHAR(13);
DEFINE vgenero              VARCHAR(10);
DEFINE vfecha_mov           VARCHAR(10);
DEFINE vfecha               VARCHAR(10);
DEFINE vsistema             VARCHAR(7);
DEFINE vCodRet1             VARCHAR(5);
DEFINE vCodRet2             VARCHAR(5);
DEFINE vSucursal            VARCHAR(4);
DEFINE vtransacc            VARCHAR(4);
DEFINE vno_tienda           VARCHAR(4);
DEFINE vsexo                VARCHAR(1);
DEFINE Sql_Err              INTEGER;
DEFINE Isam_Err             INTEGER;
DEFINE vContador1           INTEGER;
DEFINE vContador2           INTEGER;
DEFINE vComienza            INTEGER;
DEFINE vedad                INTEGER;
DEFINE vEnTransacc          SMALLINT;
DEFINE vfechahorainauth     DATETIME YEAR TO FRACTION(5);
DEFINE vFechaHoy            DATE;
DEFINE vfecha_ant           DATE;
DEFINE vfech_alt            DATE;
DEFINE vfecha_nac           DATE;
DEFINE vNum_cte   			VARCHAR(20);
DEFINE vCodtran    			CHAR(2);
DEFINE vCodigoiso  			CHAR(2);
DEFINE vIdterminal 			VARCHAR(16);
DEFINE dFechahorainauth 	DATETIME YEAR TO FRACTION(5);
DEFINE vEsnacional  		CHAR(1);
DEFINE vTrancajeropropio 	CHAR(1);
DEFINE vNumtarjeta 			VARCHAR(16);
DEFINE vNumbin				VARCHAR(6);
DEFINE vNumbin1				VARCHAR(6);
DEFINE vNumbin2				VARCHAR(6);
DEFINE vCred_debito			VARCHAR(7);
DEFINE vcomienza1    		SMALLINT;
DEFINE ven_transacc1 		SMALLINT;
DEFINE vconta        		INTEGER;

--Inicializacion de variables
LET Sql_Err           = 0;
LET Isam_Err          = 0;
LET Desc_Err          = '';
LET vCodRet1          = '00000';
LET vCodRet2          = '';
LET vCodRet3          = '';
LET vComienza         = -1;
LET vEnTransacc       = 0;
LET vContador1        = 0;
LET vContador2        = 0;
LET vFechaHoy         = '';
LET vNumCliente       = '';
LET vsql              = '';
LET vstmt             = '';
LET vfecha            = '';
LET vSucursal         = '';
LET vnombre1          = '';
LET vnombre2          = '';
LET vapell_paterno    = '';
LET vapell_materno    = '';
LET vfech_alt         = '';
LET vtransacc         = '';
LET vnombre_suc       = '';
LET vdesc_transacc    = '';
LET vfecha_nac        = '';
LET vsexo             = '';
LET vcorreo           = '';
LET vtel_casa         = '';
LET vtel_movil        = '';
LET vgenero           = '';
LET vfecha_mov        = '';
LET vedad             = 0;
LET vstatus_transacc  = '';
LET vno_tienda        = '';
LET vmodelo_cajero    = '';
LET vubicacion_cajero = '';
LET vsistema          = '';
LET vfechahorainauth  = '';
LET vfecha_ant_ext1   = '';
LET vfecha_ant_ext2   = '';
LET vNum_cte  		  = '';
LET vCodtran          = '';
LET vCodigoiso        = '';
LET vIdterminal       = '';
LET dFechahorainauth  = '';
LET vEsnacional       = '';
LET vTrancajeropropio = '';
LET vNumtarjeta       = '';
LET vNumbin           = '';
LET vNumbin1          = '';
LET vNumbin2          = '';
LET vCred_debito      = '';
LET vcomienza1 	  	  = -1;
LET ven_transacc1     = 0;
LET vconta            = 0;


BEGIN

   ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
      IF (Sql_Err <> 0) THEN
         SET DEBUG FILE TO "/resplogifx/conciliachq/medalia/sp_medalia_atm.err";
         TRACE ON;
		 
         LET vCodRet1 = Sql_Err;
         LET vCodRet2 = Isam_Err;
         LET vCodRet3 = Desc_Err;
         LET vNumCliente = vNumCliente;

         IF (vEnTransacc = 1) THEN
            ROLLBACK WORK;
         END IF;
         RETURN vCodRet1, vCodRet2, vCodRet3, vContador1;
     END IF;
   END EXCEPTION;


	--SET DEBUG FILE TO "/home/c98789058/SPL_ACCENTURE/sp_medalia_atm.out";
	--TRACE ON;
    

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
    
   SELECT fecha_hoy, fecha_ant 
     INTO vFechaHoy, vfecha_ant 
     FROM bdicheq:sc_fechas
    WHERE empresa = pEmpresa;
    
	
	--CALCULAMOS LA FECHA A PROCESAR
	LET vfecha_ant_ext1 = YEAR(vfecha_ant) || '-' || LPAD (MONTH(vfecha_ant), 2,'0') || '-' ||
                         LPAD (DAY(vfecha_ant), 2,'0') || ' 00:00:00.00000'; 
	
	LET vfecha_ant_ext1 = vfecha_ant_ext1;

	LET vfecha_ant_ext2 = YEAR(vfecha_ant) || '-' || LPAD (MONTH(vfecha_ant), 2,'0') || '-' ||
                         LPAD (DAY(vfecha_ant), 2,'0') || ' 23:59:59.99999'; 
	
	LET vfecha_ant_ext2 = vfecha_ant_ext2;

	--//Para pruebas en Desarrollo
	--LET vfecha_ant_ext1 = '2026-01-05 00:00:00.00000';
	--LET vfecha_ant_ext2 = '2026-01-05 23:59:59.99999';
 
  --Creamos tabla para acumular los registros del dÃ­a t-1
  --bicheq
  --Aprox 900,000 registros
  DROP TABLE IF EXISTS uni_cte_movimiento;
 
    CREATE TABLE uni_cte_movimiento
         (
            num_cte    VARCHAR(20),
            codtran    CHAR(2),
            codigoiso  CHAR(2),
            idterminal VARCHAR(16),
            fechahorainauth DATETIME YEAR TO FRACTION(5),  
	        esnacional  CHAR(1),
	        trancajeropropio CHAR(1),
	        numtarjeta VARCHAR(16),
			numbin     VARCHAR(6),
			cred_debito VARCHAR(7)

         )in dbs_idxinteg  extent size 55556 next size 27778 lock mode row;
		 
	CREATE INDEX idx_cte_movimiento ON uni_cte_movimiento(num_cte) ONLINE;
	UPDATE STATISTICS MEDIUM FOR TABLE uni_cte_movimiento;
	
    --Limpiamos la tabla Final	
    TRUNCATE TABLE sc_medalia_ctes_atm;
	UPDATE STATISTICS MEDIUM FOR TABLE sc_medalia_ctes_atm;
    
	--Cursor Foreach para obtener el cliente y clasificar si es crÃ©dito o dÃ©bito
	FOREACH cursor_1 WITH HOLD FOR
	
	
		 SELECT tarc.numcte, mov.codtran, mov.codigoiso, mov.idterminal, 
				mov.fechahorainauth, mov.esnacional, mov.trancajeropropio, 
				mov.numtarjeta,SUBSTR(mov.numtarjeta,1,6) as numbin
		 INTO vNum_cte,vCodtran,vCodigoiso,vIdterminal,
			  dFechahorainauth,vEsnacional,vTrancajeropropio,
			  vNumtarjeta, vNumbin1
		 FROM intercard:movimiento mov, 
			  intercard:tarjetacuenta trj,
			  bdicred:sd_tarjeta tarc
		 WHERE mov.fechahorainauth BETWEEN  vfecha_ant_ext1 AND vfecha_ant_ext2
		  AND mov.formato = "0200"
		  AND mov.transaccionorigen = "0010"
		  AND mov.movreversado = 'F'
		  AND trj.numtarjeta = mov.numtarjeta
		  AND tarc.num_tarjeta = trj.numtarjeta
		
		UNION 
		
		 SELECT tard.numcte,mov.codtran, mov.codigoiso, mov.idterminal, 
			   mov.fechahorainauth, mov.esnacional, mov.trancajeropropio,
			   mov.numtarjeta,SUBSTR(mov.numtarjeta,1,6) as numbin
		 FROM intercard:movimiento mov, 
			  intercard:tarjetacuenta trj, 
			  bdicheq:sc_tarjeta tard
		 WHERE mov.fechahorainauth BETWEEN  vfecha_ant_ext1 AND vfecha_ant_ext2
		  AND mov.formato = "0200"
		  AND mov.transaccionorigen = "0010"
		  AND mov.movreversado = 'F'
		  AND trj.numtarjeta = mov.numtarjeta
		  AND tard.num_tarjeta = trj.numtarjeta
		
		-- Abre la transaccion para commits
			   IF (vcomienza1 = -1) THEN
				  LET vcomienza1 = 0;
				  LET ven_transacc1 = 1;
				  BEGIN WORK;
			   END IF;
			   		   
		--Clasificamos si es CrÃ©dito Ã³ DÃ©bito el movimiento
		--CrÃ©dito   
		SELECT bin INTO vNumbin2 FROM intercard:bines WHERE creditodebito = 'C' AND bin = vNumbin1;


			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				LET vCred_debito = 'CREDITO';
			
			
				INSERT INTO bdicheq:uni_cte_movimiento(num_cte,codtran,codigoiso,idterminal,fechahorainauth,esnacional,trancajeropropio,numtarjeta,numbin,cred_debito)
				VALUES(vNum_cte,vCodtran,vCodigoiso,vIdterminal,dFechahorainauth,vEsnacional,vTrancajeropropio,vNumtarjeta,vNumbin2,vCred_debito);
			
			END IF;
			
		
		--DÃ©bito
		SELECT bin INTO vNumbin2 FROM intercard:bines WHERE creditodebito = 'D' AND bin = vNumbin1;
		
			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
			
				LET vCred_debito = 'DEBITO';
					
				INSERT INTO bdicheq:uni_cte_movimiento(num_cte,codtran,codigoiso,idterminal,fechahorainauth,esnacional,trancajeropropio,numtarjeta,numbin,cred_debito)
				VALUES(vNum_cte,vCodtran,vCodigoiso,vIdterminal,dFechahorainauth,vEsnacional,vTrancajeropropio,vNumtarjeta,vNumbin2,vCred_debito);
			
			END IF;
		
			LET vconta = vconta + 1;
			--Commit cada 10000 registros
			IF (vconta >= 10000) THEN
			  LET vconta = 0;
			  COMMIT WORK;
			  BEGIN WORK;
			END IF;
	
	END FOREACH;

		IF (ven_transacc1 = 1) THEN
		  LET ven_transacc1 = 0;
		  COMMIT WORK;
	    END IF;

	--Se reinician las variables 
	LET vNum_cte  		  = '';
	LET vCodtran          = '';
	LET vCodigoiso        = '';
	LET vIdterminal       = '';
	LET dFechahorainauth  = '';
	LET vEsnacional       = '';
	LET vTrancajeropropio = '';
	LET vNumtarjeta       = '';
	LET vNumbin           = '';
	LET vCred_debito      = '';
	
	LET vcomienza1 	  	  = -1;
	LET ven_transacc1     = 0;
	LET vconta            = 0;

   --Datos de cliente	
   FOREACH cursor_2 WITH HOLD FOR
	  
	  SELECT {+INDEX(uni_cte_movimiento idx_cte_movimiento )} 
	  ctemov.num_cte,ctemov.codtran,ctemov.codigoiso,ctemov.idterminal,ctemov.fechahorainauth,ctemov.esnacional,ctemov.trancajeropropio,ctemov.numtarjeta,ctemov.numbin,ctemov.cred_debito,TRIM(NVL(cte.nombre1,'')), TRIM(NVL(cte.nombre2,'')), TRIM(NVL(cte.apell_paterno,'')), TRIM(NVL(cte.apell_materno,'')), cpf.fecha_nac, cpf.sexo, TRIM(NVL(mail.correo_elec,'')),TRIM(NVL(tel1.telefono,'')), TRIM(NVL(tel2.telefono,''))
      INTO vNum_cte,vCodtran,vCodigoiso,vIdterminal,dFechahorainauth,vEsnacional,vTrancajeropropio,vNumtarjeta,vNumbin,vCred_debito,vnombre1, vnombre2, vapell_paterno, vapell_materno, vfecha_nac,vsexo,vcorreo, vtel_casa, vtel_movil
	   FROM bdicheq:uni_cte_movimiento ctemov 
	   LEFT JOIN bdinteg:si_cliente cte 
	   ON(ctemov.num_cte = cte.numcte)
       INNER JOIN bdinteg:si_ctepf cpf 
	   ON (cpf.numcte = cte.numcte)
       INNER JOIN bdinteg:si_tipper tip 
	   ON (tip.tpo_persona = cte.tpo_persona)
       LEFT JOIN bdinteg:si_correos mail 
	   ON (mail.numcte = cte.numcte AND mail.tipo_correo = 1 AND mail.status_correo = 'A' AND mail.secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_correos WHERE numcte = cte.numcte AND tipo_correo = 1 AND status_correo = 'A' ))
       LEFT JOIN bdinteg:si_telefonos_actual tel1 
	   ON (tel1.numcte = cte.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel = 'A' AND tel1.cofetel = 'V' )
       LEFT JOIN bdinteg:si_telefonos_actual tel2 
	   ON (tel2.numcte = cte.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel = 'A' AND tel2.cofetel = 'V' )
	  
        
		  LET vedad = ROUND(((vfecha_ant - vfecha_nac) / 365), 0);
		  LET vNombreCliente = TRIM(vnombre1)||' '||TRIM(vnombre2);
		  LET vNombreCliente = TRIM(vNombreCliente);
		  LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','A'),'Ã¡','a');
		  LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','E'),'Ã©','e');
		  LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','I'),'Ã­','i');
		  LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','O'),'Ã³','o');
		  LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','U'),'Ãº','u');
		  LET vNombreCliente = REPLACE(REPLACE(vNombreCliente,'Ã','N'),'Ã±','n');
		  LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','A'),'Ã¡','a');
		  LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','E'),'Ã©','e');
		  LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','I'),'Ã­','i');
		  LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','O'),'Ã³','o'); 
		  LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','U'),'Ãº','u');
		  LET vapell_paterno = REPLACE(REPLACE(vapell_paterno,'Ã','N'),'Ã±','n');
		  LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','A'),'Ã¡','a');
		  LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','E'),'Ã©','e');
		  LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','I'),'Ã­','i');
		  LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','O'),'Ã³','o');
		  LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','U'),'Ãº','u');
		  LET vapell_materno = REPLACE(REPLACE(vapell_materno,'Ã','N'),'Ã±','n');
       
      
         IF (vCodtran = '01') THEN
            LET vdesc_transacc = 'Retiro';
         ELIF vCodtran = '31' THEN
            LET vdesc_transacc = 'Consulta';
         END IF;
          

         IF (vCred_debito = 'DEBITO') THEN
            IF (vesnacional = 'V') THEN
               IF (vtrancajeropropio = 'V') THEN
                  LET vtransacc = '0952';
               ELSE
                  LET vtransacc = '0871';
               END IF;
            ELSE
               IF (vesnacional <> 'V') THEN
                  LET vtransacc = '0873';
               END IF;
            END IF;
         ELIF vCred_debito = 'CREDITO' THEN
            IF (vesnacional = 'V') THEN
               IF (vtrancajeropropio = 'V') THEN
                  LET vtransacc = '6952';
               ELSE
                  LET vtransacc = '6871';
               END IF;
            ELSE
               IF (vesnacional <> 'V') THEN
                  LET vtransacc = '6873';
               END IF;
            END IF;
         END IF;
            
		 IF (vsexo = 'F') THEN
			LET vgenero = 'FEMENINO';
		 ELSE
			LET vgenero = 'MASCULINO';
		 END IF;
			
         IF (vcodigoiso = '00') THEN
            LET vstatus_transacc = 'TRANSACCION APROBADA';
         ELSE
            LET vstatus_transacc = 'TRANSACCION RECHAZADA';
         END IF;



         SELECT sucursal, TRIM(NVL(modelo_cajero,'')), TRIM(NVL(ubicacion_cajero,''))
           INTO vSucursal, vmodelo_cajero, vubicacion_cajero
           FROM bdicheq:sc_cajeros
          WHERE id = vidterminal;
             
         SELECT TRIM(suc.nombre)
           INTO vnombre_suc
           FROM bdinteg:si_sucursales suc
          WHERE suc.sucursal = vSucursal;

         LET vfech_alt = DATE(dFechahorainauth);
         LET vfecha_mov = TO_CHAR(vfech_alt, '%d/%m/%Y');
         LET vno_tienda = vSucursal;
         LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','A'),'Ã¡','a');
         LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','E'),'Ã©','e');
         LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','I'),'Ã­','i');
         LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','O'),'Ã³','o');
         LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','U'),'Ãº','u');
         LET vnombre_suc = REPLACE(REPLACE(vnombre_suc,'Ã','N'),'Ã±','n');
            
         IF ((vSucursal IS NOT NULL AND vSucursal <> '' AND LENGTH(vSucursal) = 4) AND
             (vnombre_suc IS NOT NULL AND vnombre_suc <> '' AND vnombre_suc <> ' ')) THEN
			
		-- Abre la transaccion
			   IF (vcomienza1 = -1) THEN
				  LET vcomienza1 = 0;
				  LET ven_transacc1 = 1;
				  BEGIN WORK;
			   END IF;
			
         INSERT INTO bdicheq:sc_medalia_ctes_atm (fecha_insert, no_tienda, sucursal, nombre_suc, numcte, nombre_cte,
                                             apell_paterno, apell_materno, correo, genero, edad, segmento, id_atm,
                                             marca_atm, modelo_atm, plataforma_atm, transacc, tpo_transacc, 
                                             error_transacc, razon_error_atm, tarjeta_reten, cod_resp_atm, fecha_mov,
                                             status_transacc, tel_movil, tel_casa, ubic_cajero_suc, producto1, producto2,
                                             producto3, producto4, producto5, producto6, producto7, producto8, producto9,
                                             producto10, producto11, producto12, producto13, producto14, producto15,
                                             producto16, producto17, producto18, producto19, producto20, producto21,
                                             producto22, producto23, producto24, producto25, producto26 )
                 VALUES (vFechaHoy, vno_tienda, vSucursal, vnombre_suc, vNum_cte, vNombreCliente, vapell_paterno,
                         vapell_materno, vcorreo, vgenero, vedad, 'null', vidterminal, 'null', vmodelo_cajero, 'null',
                         vtransacc, vdesc_transacc, 'null', 'null', 'null', 'null', vfecha_mov, vstatus_transacc,
                         vtel_movil, vtel_casa, vubicacion_cajero, 'null', 'null', 'null', 'null', 'null', 'null',
                         'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null',
                         'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null', 'null');
         END IF;
          
         LET vContador2 = vContador2 + 1;
         
		 LET vconta = vconta + 1;
			--Commit cada 10000 registros
			IF (vconta >= 10000) THEN
			  LET vconta = 0;
			  COMMIT WORK;
			  BEGIN WORK;
			END IF;
		 
   
   END FOREACH;
    
	IF (ven_transacc1 = 1) THEN
		  LET ven_transacc1 = 0;
		  COMMIT WORK;
	END IF;

    
   LET vfecha = TO_CHAR(vfecha_ant, '%d_%m_%Y');
    
   LET vsql = '';
   LET vsql = 'echo "NUMERO_TIENDA|NUMERO_SUCURSAL|NOMBRE_SUCURSAL|NUMERO_CLIENTE|NOMBRE_CLIENTE|APELLIDOPATERNO_CLIENTE|APELLIDOMATERNO_CLIENTE|EMAIL_CLIENTE|GENERO_CLIENTE|EDAD_CLIENTE|SEGMENTO_CLIENTE|'|| 
              'ID_ATM|MARCA_ATM|MODELO_ATM|PLATAFORMA_ATM|ID_TRANSACCION|TIPO_TRANSACCION|ERROR_TRANSACCION|RAZON_ERROR_ATM|'||
              'TARJETA_RETENIDA|CODIGO_RESPUESTA_ATM|FECHA_TRANSACCION|ESTATUS_TRANSACCION|TELEFONO_CELULAR|TELEFONO_FIJO|UBICACION_CAJERO_SUCURSAL|'||
              'PRODUCTO_1|PRODUCTO_2|PRODUCTO_3|PRODUCTO_4|PRODUCTO_5|PRODUCTO_6|PRODUCTO_7|PRODUCTO_8|PRODUCTO_9|PRODUCTO_10|PRODUCTO_11|PRODUCTO_12|PRODUCTO_13|'||
              'PRODUCTO_14|PRODUCTO_15|PRODUCTO_16|PRODUCTO_17|PRODUCTO_18|PRODUCTO_19|PRODUCTO_20|PRODUCTO_21|PRODUCTO_22|PRODUCTO_23|PRODUCTO_24|PRODUCTO_25|PRODUCTO_26" > /resplogifx/conciliachq/originales/coppel_banco_atm_invitacion_'||vfecha||'.csv.enc';

   SYSTEM vsql;
   LET vsql = '';
     
   LET vsql = '';
   LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/originales/coppel_banco_atm_invitacion_'||vfecha||'.csv.det '||
              'SELECT no_tienda, sucursal, REPLACE(REPLACE(trim(nombre_suc),''SUC '',''''),''SUC. '',''''), numcte, nombre_cte, apell_paterno, apell_materno, correo, genero, edad, segmento, '||
              'id_atm, marca_atm, modelo_atm, plataforma_atm, transacc, tpo_transacc, error_transacc, razon_error_atm,  '||
              'tarjeta_reten, cod_resp_atm, fecha_mov, status_transacc, tel_movil, tel_casa, ubic_cajero_suc, '||
              'producto1, producto2, producto3, producto4, producto5, producto6, producto7, producto8, producto9, producto10, producto11, producto12, producto13, '||
              'producto14, producto15, producto16, producto17, producto18, producto19, producto20, producto21, producto22, producto23, producto24, producto25, producto26 '||
              'FROM bdicheq:sc_medalia_ctes_atm WHERE fecha_insert = '''||vFechaHoy||''' " >  /resplogifx/conciliachq/medalia/atm_medalia.sql';
               
   SYSTEM vsql;
   LET vsql = '';
    
   LET vstmt = '';
   LET vstmt = "/ifxsif01/bin/dbaccess bdicheq  /resplogifx/conciliachq/medalia/atm_medalia.sql"; 
   
   SYSTEM vstmt;
   LET vstmt = '';
    
   LET vsql = '';
   LET vsql = 'cat /resplogifx/conciliachq/originales/coppel_banco_atm_invitacion_'||vfecha||'.csv.enc  /resplogifx/conciliachq/originales/coppel_banco_atm_invitacion_'||vfecha||'.csv.det > /resplogifx/conciliachq/originales/coppel_banco_atm_invitacion_'||vfecha||'.csv';

   SYSTEM vsql;
   LET vsql = '';
    
   LET vsql = '';
   LET vsql = 'rm /resplogifx/conciliachq/originales/coppel_banco_atm_invitacion_'||vfecha||'.csv.enc';

   SYSTEM vsql;
   LET vsql = '';
    
   LET vsql = '';
   LET vsql = 'rm /resplogifx/conciliachq/originales/coppel_banco_atm_invitacion_'||vfecha||'.csv.det';

   SYSTEM vsql;
   LET vsql = '';
   
   LET vsql = '';
   LET vsql = 'rm /resplogifx/conciliachq/medalia/atm_medalia.sql';

   SYSTEM vsql;
   LET vsql = '';
 
END; 
    
RETURN vCodRet1, vCodRet2, vCodRet3, vContador1;
    
END PROCEDURE;