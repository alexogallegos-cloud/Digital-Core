CREATE PROCEDURE "informix".spei_pasemovspeich(pfechaejecuta date)
returning char(5),char(100);

    DEFINE vsql_err     integer;
    DEFINE visam_err    integer;
    DEFINE vcodret      char (10);
    DEFINE vcodret2     char (100);
    DEFINE vestadoctrl  char(1);
    DEFINE vsql         char(250);
    DEFINE vmes         Char(2);
    DEFINE vdia         Char(2);
    DEFINE vanio        char(4);
    DEFINE vfechaarch   char(8);
    DEFINE vstmt        char(150);
    
    DEFINE vComienza            SMALLINT;
    DEFINE vAbierto             CHAR(1);
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    
    DEFINE vintfoliopago        INTEGER;
    DEFINE vintpkpago           INTEGER;
    DEFINE vintcvecausadev      INTEGER;
    DEFINE vintpkpaqueteenv     INTEGER;
    DEFINE vmnyimporte          DECIMAL(19,2);
    DEFINE vcvecesifbcoord      INTEGER;
    DEFINE vcvecesifbcodest     INTEGER;
    DEFINE vchrestatusenvio     CHAR(1);
    DEFINE vvchrnombreord       CHAR(40);
    DEFINE vvchrcuentaord       CHAR(20);
    DEFINE vvchrrfcord          CHAR(18);
    DEFINE vvchrnombrebenef     CHAR(40);
    DEFINE vintcvetipoctabene   INTEGER;
    DEFINE vvchrcuentabenef     CHAR(20);
    DEFINE vvchrrfcbenef        CHAR(18);
    DEFINE vvchrnombrebenef2    CHAR(40);
    DEFINE vintcvetipoctabene2  INTEGER;
    DEFINE vvchrcuentabenef2    CHAR(20);
    DEFINE vvchrrfcbenef2       CHAR(18);
    DEFINE vvchrconceptopago    CHAR(210);
    DEFINE vmnyiva              DECIMAL(19,2);
    DEFINE vintrefnumerica      DECIMAL(7,0);
    DEFINE vvchrrefcobranza     CHAR(40);
    DEFINE vvchrclavepago       CHAR(10);
    DEFINE vvchrconceptopago2   CHAR(40);
    DEFINE vdtfechavalor        DATE;
    DEFINE vdtfechacaptura      DATE;
    DEFINE vvchrclaverastreo    CHAR(30);
    DEFINE vchrusuarioprom      CHAR(20);
    DEFINE vchrfolioprom        CHAR(16);
    DEFINE vchrusuariovent      CHAR(20);
    DEFINE vchrfolioliqu        CHAR(16);
    DEFINE vintcvetipopago      INTEGER;
    DEFINE vintfolioservidor    INTEGER;
    DEFINE vintcvetipoctaord    INTEGER;
    DEFINE vdtmhoracargo        DATETIME YEAR TO SECOND;
    DEFINE vintcvetpooperacion  CHAR(2);
    DEFINE vintfoliocargo       INTEGER;
    DEFINE vintfoliocancela     INTEGER;
    DEFINE vintfolioservcanc    INTEGER;
    DEFINE vdtmhoracancela      DATETIME YEAR TO SECOND;
    DEFINE vchrsentidopago      CHAR(1);
    DEFINE vchrmotivocanc       CHAR(1);
    DEFINE vchrmotivodev        CHAR(1);
    DEFINE vchrtopologia        CHAR(1);
    DEFINE vchrprioridad        CHAR(1);
    DEFINE vtxtcde              REFERENCES BYTE;
    DEFINE vchrtxop             CHAR(4);
    DEFINE vvchrcverastreoorig  CHAR(30);
    DEFINE vchrctacheques       CHAR(11);
    DEFINE vvchrcverastreodev   CHAR(20);
    DEFINE vsintlongcverastreo  SMALLINT;
    DEFINE vintpkpagoorig       INTEGER;
    DEFINE vvchrmotivodev       CHAR(255);
    
    DEFINE vmedioentrega integer;
    DEFINE vusuario      char(50);
    DEFINE vusuario_aut  char(50);
    DEFINE vusuario_can  char(50);
    DEFINE vhora_liq     datetime year to second;
    DEFINE vhora_dev     datetime year to second;
    DEFINE vhora_cap     datetime year to second;
    DEFINE vchnumcelord char(10);
    DEFINE vchnumcelben char(20);
    DEFINE vchdigidord char(3);
    DEFINE vchdigidben char(3);
    DEFINE vchfechalimpago char(16);
    DEFINE vchindbenef char(2);
    DEFINE vintpagocomision integer;
    DEFINE vcomision decimal(14,2);
    DEFINE vchnumseriecert char(20);
    DEFINE vchfolioplataforma char(20);
	DEFINE aux1 integer;
	DEFINE aux2 integer;
	
	DEFINE v_existe char(1);

    LET vcodret     = '000';
    LET vcodret2    = '';
    LET vsql_err    = 0;
    LET visam_err   = 0;
    LET vestadoctrl = '';
    LET vsql        = '';
    LET vmes        = '';
    LET vdia        = '';
    LET vanio       = '';
    LET vfechaarch  = '';
    LET vstmt       = '';
    
    LET vComienza           = -1;
    LET vAbierto            = '0';
    LET vContador1          = 0;
    LET vContador2          = 0;
    
    LET vintfoliopago       = 0;
    LET vintpkpago          = 0;
    LET vintcvecausadev     = 0;
    LET vintpkpaqueteenv    = 0;
    LET vmnyimporte         = 0.00;
    LET vcvecesifbcoord     = 0;
    LET vcvecesifbcodest    = 0;
    LET vchrestatusenvio    = '';
    LET vvchrnombreord      = '';
    LET vvchrcuentaord      = '';
    LET vvchrrfcord         = '';
    LET vvchrnombrebenef    = '';
    LET vintcvetipoctabene  = 0;
    LET vvchrcuentabenef    = '';
    LET vvchrrfcbenef       = '';
    LET vvchrnombrebenef2   = '';
    LET vintcvetipoctabene2 = 0;
    LET vvchrcuentabenef2   = '';
    LET vvchrrfcbenef2      = '';
    LET vvchrconceptopago   = '';
    LET vmnyiva             = 0.00;
    LET vintrefnumerica     = 0.00;
    LET vvchrrefcobranza    = '';
    LET vvchrclavepago      = '';
    LET vvchrconceptopago2  = '';
    LET vdtfechavalor       = '';
    LET vdtfechacaptura     = '';
    LET vvchrclaverastreo   = '';
    LET vchrusuarioprom     = '';
    LET vchrfolioprom       = '';
    LET vchrusuariovent     = '';
    LET vchrfolioliqu       = '';
    LET vintcvetipopago     = 0;
    LET vintfolioservidor   = 0;
    LET vintcvetipoctaord   = 0;
    LET vdtmhoracargo       = '';
    LET vintcvetpooperacion = '';
    LET vintfoliocargo      = 0;
    LET vintfoliocancela    = 0;
    LET vintfolioservcanc   = 0;
    LET vdtmhoracancela     = '';
    LET vchrsentidopago     = '';
    LET vchrmotivocanc      = '';
    LET vchrmotivodev       = '';
    LET vchrtopologia       = '';
    LET vchrprioridad       = '';
    LET vchrtxop            = '';
    LET vvchrcverastreoorig = '';
    LET vchrctacheques      = '';
    LET vvchrcverastreodev  = '';
    LET vsintlongcverastreo = 0;
    LET vintpkpagoorig      = 0;
    LET vvchrmotivodev      = '';
	LET aux1  = 0;
	LET aux2 = 0;
    
    LET vmedioentrega = 0;
    LET vusuario      = '';
    LET vusuario_aut  = '';
    LET vusuario_can  = '';
    LET vhora_liq     = '';
    LET vhora_dev     = '';
    LET vhora_cap     = '';
	
	LET v_existe = '';

    BEGIN
    
    ON EXCEPTION SET vsql_err, visam_err
		SET DEBUG FILE TO "/resplogifx/conciliachq/spei_pasemovspeich.err";
		TRACE ON;
        IF vsql_err <> 0 THEN
            let vcodret = vsql_err;
            let vcodret2 = visam_err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;            
            RETURN  vcodret, vcodret2;
        END IF;
    END EXCEPTION;
    
    --- SET debug file to '/resplogifx/conciliachq/spei_pasemovspeich.out.';
    --- trace on;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
-- // Obtiene fecha de ejecuciÃ³n
	SELECT fecha_hoy
	  INTO pfechaejecuta
	  FROM bdicheq:sc_fechas; 

    -- // Valida la fecha del Movimiento
    IF (pfechaejecuta is null) or (pfechaejecuta = '') THEN
        LET vcodret = '001'; -- Falta parametro Fecha de Operacion
        LET vcodret2 = 'Falta parametro Fecha de Operacion';
        RETURN vcodret, vcodret2;
    END IF;

    --//Valida que el proceso no se haya ejecutado antes	
    SELECT chrstatus  
      INTO vestadoctrl
      FROM tblctrlproceso
     WHERE intcveproceso = 3
       AND dtfecha = pfechaejecuta;	

    LET vmes = SUBSTR(pfechaejecuta,0,2);
    LET vdia = SUBSTR(pfechaejecuta,4,2);
    LET vanio = SUBSTR(pfechaejecuta,7,4);
    LET vfechaarch = vanio||vmes||vdia;
    
    IF (vestadoctrl IS NULL) OR (vestadoctrl = '') OR (vestadoctrl = '0') THEN
        DELETE FROM tblctrlproceso 
         WHERE intcveproceso = 3 
           AND dtfecha = pfechaejecuta; 
           
        INSERT INTO tblctrlproceso VALUES
        (3, pfechaejecuta, CURRENT HOUR TO SECOND, 'informix', 0);

        
		SELECT COUNT(dbsname) INTO aux1
		FROM sysmaster:systabnames 
		WHERE partnum > 0 AND tabname = 'tblhistpago_temp';
		
		SELECT COUNT(tabname) INTO aux2
		FROM sysmaster:systabnames 
		WHERE partnum > 0 AND tabname = 'tblhistpago_temp';
		
		IF (aux1 <> 0 AND aux2 <> 0) THEN
			DROP TABLE bdispei:"informix".tblhistpago_temp;
		END IF;
		/*IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tblhistpago_temp') THEN
            DROP TABLE bdispei:"informix".tblhistpago_temp;
        END IF;*/

        CREATE RAW TABLE "informix".tblhistpago_temp(
            intfoliopago integer,
            intpkpago integer,
            intcvecausadev integer,
            intpkpaqueteenv integer,
            mnyimporte decimal(19,2),
            cvecesifbcoord integer,
            cvecesifbcodest integer,
            chrestatusenvio char(1),
            vchrnombreord varchar(40),
            vchrcuentaord varchar(20),
            vchrrfcord varchar(18),
            vchrnombrebenef varchar(40),
            intcvetipoctabene integer,
            vchrcuentabenef varchar(20),
            vchrrfcbenef varchar(18),
            vchrnombrebenef2 varchar(40),
            intcvetipoctabene2 integer,
            vchrcuentabenef2 varchar(20),
            vchrrfcbenef2 varchar(18),
            vchrconceptopago varchar(210),
            mnyiva decimal(19,2),
            intrefnumerica decimal(7,0),
            vchrrefcobranza varchar(40),
            vchrclavepago varchar(10),
            vchrconceptopago2 varchar(40),
            dtfechavalor date,
            dtfechacaptura date,
            vchrclaverastreo varchar(30),
            chrusuarioprom varchar(20),
            chrfolioprom char(16),
            chrusuariovent varchar(20),
            chrfolioliqu char(16),
            intcvetipopago integer,
            intfolioservidor integer,
            intcvetipoctaord integer,
            dtmhoracargo datetime year to second,
            intcvetpooperacion char(2),
            intfoliocargo integer,
            intfoliocancela integer,
            intfolioservcanc integer,
            dtmhoracancela datetime year to second,
            chrsentidopago char(1),
            chrmotivocanc char(1),
            chrmotivodev char(1),
            chrtopologia char(1),
            chrprioridad char(1),
            txtcde byte,
            chrtxop char(4),
            vchrcverastreoorig varchar(30),
            chrctacheques char(11),
            vchrcverastreodev varchar(20),
            sintlongcverastreo smallint,
            intpkpagoorig integer,
            vchrmotivodev varchar(255),
            medioentrega integer,
            usuario varchar(50),
            usuario_aut varchar(50),
            usuario_can varchar(50),
            hora_liq  datetime year to second,
            hora_dev  datetime year to second,
            hora_cap  datetime year to second,
            numcelord char(10),  
            numcelben char(20),  
            digidord char(3), 
            digidben char(3), 
            fechalimpago char(16),
            indbenef char(2), 
            pagocomision integer, 
            comision decimal(14,2),
            numseriecert char(20),
            folioplataforma char(20)
             ) IN dbs_bdispei_his_03_01 extent size 2250 next size 225 lock mode row; --produccion
        --extent size 2250 next size 225 lock mode row;
        create index idx_tblhistpago_temp on "informix".tblhistpago_temp(dtfechacaptura) using btree;
        create index idx_tblhistpago_temp2 on "informix".tblhistpago_temp(dtfechavalor) using btree;

		/* --Se comenta por reemplazo a dbload
        let vsql = '';
        let vsql = 'echo "load from /home/sysspei/MovSPEICH'||vfechaarch||'.txt insert into tblhistpago_temp;" > /home/sysspei/query.sql';
        system vsql;
        
        let vstmt = '';
        let vstmt = 'dbaccess bdispei /home/sysspei/query.sql';
        system vstmt;
		
		*/ --Se comenta por reemplazo a dbload
		
		LET vsql = ''; 
 	    LET vsql = 'echo "file /RESPALDOSNEW/SYSSPEI/MovSPEICH'||vfechaarch||'.txt delimiter ''|'' 71; INSERT INTO tblhistpago_temp;" > /RESPALDOSNEW/SYSSPEI/tblhistpago_temp.sql';
        SYSTEM vsql;
        
		LET vsql = ''; 
        LET vsql = 'dbload -d bdispei -c /RESPALDOSNEW/SYSSPEI/tblhistpago_temp.sql -l /RESPALDOSNEW/SYSSPEI/err_MovSPEICH'||vfechaarch||'.log -e 2500 -n 1000';
        SYSTEM vsql;
        LET vsql = ''; 
        
        /* #######################
        INSERT INTO tblhistpago
        SELECT * 
          FROM tblhistpago_temp;
        ####################### */
        
        FOREACH WITH HOLD
            SELECT {+INDEX (bdispei:"informix".tblhistpago_temp idx_tblhistpago_temp)}
					intfoliopago, intpkpago, intcvecausadev, intpkpaqueteenv, mnyimporte, cvecesifbcoord, cvecesifbcodest, chrestatusenvio, 
                   vchrnombreord, vchrcuentaord, vchrrfcord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, vchrrfcbenef, vchrnombrebenef2, 
                   intcvetipoctabene2, vchrcuentabenef2, vchrrfcbenef2, vchrconceptopago, mnyiva, intrefnumerica, vchrrefcobranza, vchrclavepago, 
                   vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, chrusuarioprom, chrfolioprom, chrusuariovent, chrfolioliqu, 
                   intcvetipopago, intfolioservidor, intcvetipoctaord, dtmhoracargo, intcvetpooperacion, intfoliocargo, intfoliocancela, 
                   intfolioservcanc, dtmhoracancela, chrsentidopago, chrmotivocanc, chrmotivodev, chrtopologia, chrprioridad, 
                   txtcde, chrtxop, vchrcverastreoorig, chrctacheques, vchrcverastreodev, sintlongcverastreo, intpkpagoorig, vchrmotivodev,
                   medioentrega, usuario, usuario_aut, usuario_can, hora_liq, hora_dev, hora_cap,
                   numcelord,numcelben,digidord,digidben,fechalimpago,indbenef,pagocomision,comision,numseriecert,folioplataforma
              INTO vintfoliopago, vintpkpago, vintcvecausadev, vintpkpaqueteenv, vmnyimporte, vcvecesifbcoord, vcvecesifbcodest, vchrestatusenvio, 
                   vvchrnombreord, vvchrcuentaord, vvchrrfcord, vvchrnombrebenef, vintcvetipoctabene, vvchrcuentabenef, vvchrrfcbenef, vvchrnombrebenef2, 
                   vintcvetipoctabene2, vvchrcuentabenef2, vvchrrfcbenef2, vvchrconceptopago, vmnyiva, vintrefnumerica, vvchrrefcobranza, vvchrclavepago, 
                   vvchrconceptopago2, vdtfechavalor, vdtfechacaptura, vvchrclaverastreo, vchrusuarioprom, vchrfolioprom, vchrusuariovent, vchrfolioliqu, 
                   vintcvetipopago, vintfolioservidor, vintcvetipoctaord, vdtmhoracargo, vintcvetpooperacion, vintfoliocargo, vintfoliocancela, 
                   vintfolioservcanc, vdtmhoracancela, vchrsentidopago, vchrmotivocanc, vchrmotivodev, vchrtopologia, vchrprioridad, 
                   vtxtcde, vchrtxop, vvchrcverastreoorig, vchrctacheques, vvchrcverastreodev, vsintlongcverastreo, vintpkpagoorig, vvchrmotivodev,
                   vmedioentrega, vusuario, vusuario_aut, vusuario_can, vhora_liq, vhora_dev, vhora_cap,
                   vchnumcelord,vchnumcelben,vchdigidord,vchdigidben,vchfechalimpago ,vchindbenef,vintpagocomision,vcomision,vchnumseriecert ,vchfolioplataforma
              FROM bdispei:"informix".tblhistpago_temp 
            
            IF vComienza = -1 THEN
                LET vComienza = 0;
                BEGIN WORK;
                LET vAbierto = '1';
            END IF;
            
            IF vdtfechavalor is null OR vdtfechavalor = ' '  THEN
                /*
                UPDATE tblhistpago_temp 
                   SET dtfechavalor = pfechaejecuta
                 WHERE vchrclaverastreo = vvchrclaverastreo;
                */
                 
                LET vdtfechavalor = pfechaejecuta;
            END IF;
            
            IF vdtfechacaptura is null OR vdtfechacaptura = ' ' THEN
                /*
                UPDATE tblhistpago_temp 
                   SET dtfechacaptura = pfechaejecuta
                 WHERE vchrclaverastreo = vvchrclaverastreo;
                */
                 
                LET vdtfechacaptura = pfechaejecuta;
            END IF;
			
	  select first 1 '1'
      into v_existe
      from bdispei:"informix".tblhistpago 
      where intpkpago = vintpkpago 
      and mnyimporte = vmnyimporte
      and vchrclaverastreo = vvchrclaverastreo;
      
      IF v_existe = '' OR v_existe is null OR v_existe <> '1' THEN 
            
            INSERT INTO bdispei:"informix".tblhistpago
            ( intfoliopago, intpkpago, intcvecausadev, intpkpaqueteenv, mnyimporte, cvecesifbcoord, cvecesifbcodest, chrestatusenvio, 
              vchrnombreord, vchrcuentaord, vchrrfcord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, vchrrfcbenef, vchrnombrebenef2, 
              intcvetipoctabene2, vchrcuentabenef2, vchrrfcbenef2, vchrconceptopago, mnyiva, intrefnumerica, vchrrefcobranza, vchrclavepago, 
              vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, chrusuarioprom, chrfolioprom, chrusuariovent, chrfolioliqu, 
              intcvetipopago, intfolioservidor, intcvetipoctaord, dtmhoracargo, intcvetpooperacion, intfoliocargo, intfoliocancela, 
              intfolioservcanc, dtmhoracancela, chrsentidopago, chrmotivocanc, chrmotivodev, chrtopologia, chrprioridad, 
              txtcde, chrtxop, vchrcverastreoorig, chrctacheques, vchrcverastreodev, sintlongcverastreo, intpkpagoorig, vchrmotivodev,
              medioentrega, usuario, usuario_aut, usuario_can, hora_liq, hora_dev, hora_cap,
              numcelord,numcelben,digidord,digidben,fechalimpago,indbenef,pagocomision,comision,numseriecert,folioplataforma)
            VALUES
            ( vintfoliopago, vintpkpago, vintcvecausadev, vintpkpaqueteenv, vmnyimporte, vcvecesifbcoord, vcvecesifbcodest, vchrestatusenvio, 
              vvchrnombreord, vvchrcuentaord, vvchrrfcord, vvchrnombrebenef, vintcvetipoctabene, vvchrcuentabenef, vvchrrfcbenef, vvchrnombrebenef2, 
              vintcvetipoctabene2, vvchrcuentabenef2, vvchrrfcbenef2, vvchrconceptopago, vmnyiva, vintrefnumerica, vvchrrefcobranza, vvchrclavepago, 
              vvchrconceptopago2, vdtfechavalor, vdtfechacaptura, vvchrclaverastreo, vchrusuarioprom, vchrfolioprom, vchrusuariovent, vchrfolioliqu, 
              vintcvetipopago, vintfolioservidor, vintcvetipoctaord, vdtmhoracargo, vintcvetpooperacion, vintfoliocargo, vintfoliocancela, 
              vintfolioservcanc, vdtmhoracancela, vchrsentidopago, vchrmotivocanc, vchrmotivodev, vchrtopologia, vchrprioridad, 
              vtxtcde, vchrtxop, vvchrcverastreoorig, vchrctacheques, vvchrcverastreodev, vsintlongcverastreo, vintpkpagoorig, vvchrmotivodev,
              vmedioentrega, vusuario, vusuario_aut, vusuario_can, vhora_liq, vhora_dev, vhora_cap,
              vchnumcelord,vchnumcelben,vchdigidord,vchdigidben,vchfechalimpago ,vchindbenef,vintpagocomision,vcomision,vchnumseriecert ,vchfolioplataforma);
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador2 = vcontador2 + 1;
			
	   END IF;
            
            IF vcontador2 >= 1000 THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
        END FOREACH;
        
        IF vAbierto = '1' THEN
            COMMIT WORK;
            LET vAbierto = '0';
        END IF;
        
        UPDATE tblctrlproceso 
           SET chrstatus = 1
         Where intcveproceso = 3
           and dtfecha = pfechaejecuta;
		   
		LET vsql = ''; 		
		LET vsql = 'rm -f /RESPALDOSNEW/SYSSPEI/MovSPEICH'||vfechaarch||'.txt '; --Elimina archivo MovSPEICH.
		SYSTEM vsql;

        RETURN vcodret, 'Exitoso';	
    ELSE 
        LET vcodret = '001';
        LET vcodret2 = "El proceso ya se ejecuto para esa fecha. Favor de validar si el proceso concluyo exitosamente ";
    END IF;

    RETURN vcodret, vcodret2;
    
    END;

END PROCEDURE

DOCUMENT 'AUTOR: MARIO GONZALEZ VAZQUEZ',
'FECHA: 04-JULIO-2025',
'DESCRIPCION: Se agrega index a consulta de la tabla tblhistpago_temp, se implementa dbload para la carga del archivo MovSPEICH, se incrementa el tamaÃ±o de la variable vsql a 250, se agrega validacion de existe a insert tblhistpago, se cambia ruta de archivo MOV y elimina el archivo MOV despues de cargarlo ',
'BD: bdispei';

CREATE PROCEDURE "informix".spei_pasemovspeich_2(pfechaejecuta_var VARCHAR(15))
returning char(5),char(100);

    DEFINE vsql_err     integer;
    DEFINE visam_err    integer;
    DEFINE vcodret      char (10);
    DEFINE vcodret2     char (100);
    DEFINE vestadoctrl  char(1);
    DEFINE vsql         char(250);
    DEFINE vmes         Char(2);
    DEFINE vdia         Char(2);
    DEFINE vanio        char(4);
    DEFINE vfechaarch   char(8);
    DEFINE vstmt        char(150);
	
	DEFINE pfechaejecuta date;
    
    DEFINE vComienza            SMALLINT;
    DEFINE vAbierto             CHAR(1);
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    
    DEFINE vintfoliopago        INTEGER;
    DEFINE vintpkpago           INTEGER;
    DEFINE vintcvecausadev      INTEGER;
    DEFINE vintpkpaqueteenv     INTEGER;
    DEFINE vmnyimporte          DECIMAL(19,2);
    DEFINE vcvecesifbcoord      INTEGER;
    DEFINE vcvecesifbcodest     INTEGER;
    DEFINE vchrestatusenvio     CHAR(1);
    DEFINE vvchrnombreord       CHAR(40);
    DEFINE vvchrcuentaord       CHAR(20);
    DEFINE vvchrrfcord          CHAR(18);
    DEFINE vvchrnombrebenef     CHAR(40);
    DEFINE vintcvetipoctabene   INTEGER;
    DEFINE vvchrcuentabenef     CHAR(20);
    DEFINE vvchrrfcbenef        CHAR(18);
    DEFINE vvchrnombrebenef2    CHAR(40);
    DEFINE vintcvetipoctabene2  INTEGER;
    DEFINE vvchrcuentabenef2    CHAR(20);
    DEFINE vvchrrfcbenef2       CHAR(18);
    DEFINE vvchrconceptopago    CHAR(210);
    DEFINE vmnyiva              DECIMAL(19,2);
    DEFINE vintrefnumerica      DECIMAL(7,0);
    DEFINE vvchrrefcobranza     CHAR(40);
    DEFINE vvchrclavepago       CHAR(10);
    DEFINE vvchrconceptopago2   CHAR(40);
    DEFINE vdtfechavalor        DATE;
    DEFINE vdtfechacaptura      DATE;
    DEFINE vvchrclaverastreo    CHAR(30);
    DEFINE vchrusuarioprom      CHAR(20);
    DEFINE vchrfolioprom        CHAR(16);
    DEFINE vchrusuariovent      CHAR(20);
    DEFINE vchrfolioliqu        CHAR(16);
    DEFINE vintcvetipopago      INTEGER;
    DEFINE vintfolioservidor    INTEGER;
    DEFINE vintcvetipoctaord    INTEGER;
    DEFINE vdtmhoracargo        DATETIME YEAR TO SECOND;
    DEFINE vintcvetpooperacion  CHAR(2);
    DEFINE vintfoliocargo       INTEGER;
    DEFINE vintfoliocancela     INTEGER;
    DEFINE vintfolioservcanc    INTEGER;
    DEFINE vdtmhoracancela      DATETIME YEAR TO SECOND;
    DEFINE vchrsentidopago      CHAR(1);
    DEFINE vchrmotivocanc       CHAR(1);
    DEFINE vchrmotivodev        CHAR(1);
    DEFINE vchrtopologia        CHAR(1);
    DEFINE vchrprioridad        CHAR(1);
    DEFINE vtxtcde              REFERENCES BYTE;
    DEFINE vchrtxop             CHAR(4);
    DEFINE vvchrcverastreoorig  CHAR(30);
    DEFINE vchrctacheques       CHAR(11);
    DEFINE vvchrcverastreodev   CHAR(20);
    DEFINE vsintlongcverastreo  SMALLINT;
    DEFINE vintpkpagoorig       INTEGER;
    DEFINE vvchrmotivodev       CHAR(255);
    
    DEFINE vmedioentrega integer;
    DEFINE vusuario      char(50);
    DEFINE vusuario_aut  char(50);
    DEFINE vusuario_can  char(50);
    DEFINE vhora_liq     datetime year to second;
    DEFINE vhora_dev     datetime year to second;
    DEFINE vhora_cap     datetime year to second;
    DEFINE vchnumcelord char(10);
    DEFINE vchnumcelben char(20);
    DEFINE vchdigidord char(3);
    DEFINE vchdigidben char(3);
    DEFINE vchfechalimpago char(16);
    DEFINE vchindbenef char(2);
    DEFINE vintpagocomision integer;
    DEFINE vcomision decimal(14,2);
    DEFINE vchnumseriecert char(20);
    DEFINE vchfolioplataforma char(20);
	  DEFINE aux1 integer;
	  DEFINE aux2 integer;
    DEFINE v_existe char(1);
 

    LET vcodret     = '000';
    LET vcodret2    = '';
    LET vsql_err    = 0;
    LET visam_err   = 0;
    LET vestadoctrl = '';
    LET vsql        = '';
    LET vmes        = '';
    LET vdia        = '';
    LET vanio       = '';
    LET vfechaarch  = '';
    LET vstmt       = '';
    
    LET vComienza           = -1;
    LET vAbierto            = '0';
    LET vContador1          = 0;
    LET vContador2          = 0;
    
    LET vintfoliopago       = 0;
    LET vintpkpago          = 0;
    LET vintcvecausadev     = 0;
    LET vintpkpaqueteenv    = 0;
    LET vmnyimporte         = 0.00;
    LET vcvecesifbcoord     = 0;
    LET vcvecesifbcodest    = 0;
    LET vchrestatusenvio    = '';
    LET vvchrnombreord      = '';
    LET vvchrcuentaord      = '';
    LET vvchrrfcord         = '';
    LET vvchrnombrebenef    = '';
    LET vintcvetipoctabene  = 0;
    LET vvchrcuentabenef    = '';
    LET vvchrrfcbenef       = '';
    LET vvchrnombrebenef2   = '';
    LET vintcvetipoctabene2 = 0;
    LET vvchrcuentabenef2   = '';
    LET vvchrrfcbenef2      = '';
    LET vvchrconceptopago   = '';
    LET vmnyiva             = 0.00;
    LET vintrefnumerica     = 0.00;
    LET vvchrrefcobranza    = '';
    LET vvchrclavepago      = '';
    LET vvchrconceptopago2  = '';
    LET vdtfechavalor       = '';
    LET vdtfechacaptura     = '';
    LET vvchrclaverastreo   = '';
    LET vchrusuarioprom     = '';
    LET vchrfolioprom       = '';
    LET vchrusuariovent     = '';
    LET vchrfolioliqu       = '';
    LET vintcvetipopago     = 0;
    LET vintfolioservidor   = 0;
    LET vintcvetipoctaord   = 0;
    LET vdtmhoracargo       = '';
    LET vintcvetpooperacion = '';
    LET vintfoliocargo      = 0;
    LET vintfoliocancela    = 0;
    LET vintfolioservcanc   = 0;
    LET vdtmhoracancela     = '';
    LET vchrsentidopago     = '';
    LET vchrmotivocanc      = '';
    LET vchrmotivodev       = '';
    LET vchrtopologia       = '';
    LET vchrprioridad       = '';
    LET vchrtxop            = '';
    LET vvchrcverastreoorig = '';
    LET vchrctacheques      = '';
    LET vvchrcverastreodev  = '';
    LET vsintlongcverastreo = 0;
    LET vintpkpagoorig      = 0;
    LET vvchrmotivodev      = '';
	LET aux1  = 0;
	LET aux2 = 0;
    
    LET vmedioentrega = 0;
    LET vusuario      = '';
    LET vusuario_aut  = '';
    LET vusuario_can  = '';
    LET vhora_liq     = '';
    LET vhora_dev     = '';
    LET vhora_cap     = '';
    LET v_existe = '';

    BEGIN
    
    ON EXCEPTION SET vsql_err, visam_err
		SET DEBUG FILE TO "/resplogifx/conciliachq/spei_pasemovspeich.err";
		TRACE ON;
        IF vsql_err <> 0 THEN
            let vcodret = vsql_err;
            let vcodret2 = visam_err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;            
            RETURN  vcodret, vcodret2;
        END IF;
    END EXCEPTION;
    
     --SET debug file to '/resplogifx/conciliachq/spei_pasemovspeich.out';
     --trace on;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


/*	--se comenta para prueba controlada
-- // Obtiene fecha de ejecuciÃÂ³n
	SELECT fecha_hoy
	  INTO pfechaejecuta
	  FROM bdicheq:sc_fechas; 
*/  --se comenta para prueba controlada

LET pfechaejecuta = to_date(pfechaejecuta_var,'%Y/%m/%d' ); --se ejecuta para prueba controlada

    -- // Valida la fecha del Movimiento
    IF (pfechaejecuta is null) or (pfechaejecuta = '') THEN
        LET vcodret = '001'; -- Falta parametro Fecha de Operacion
        LET vcodret2 = 'Falta parametro Fecha de Operacion';
        RETURN vcodret, vcodret2;
    END IF;


/* --se comenta para prueba controlada
    --//Valida que el proceso no se haya ejecutado antes	
    SELECT chrstatus  
      INTO vestadoctrl
      FROM tblctrlproceso
     WHERE intcveproceso = 3
       AND dtfecha = pfechaejecuta;	
*/ --se comenta para prueba controlada


    LET vmes = SUBSTR(pfechaejecuta,0,2);
    LET vdia = SUBSTR(pfechaejecuta,4,2);
    LET vanio = SUBSTR(pfechaejecuta,7,4);
    LET vfechaarch = vanio||vmes||vdia;
	
	LET vestadoctrl = '0';
    
    IF (vestadoctrl IS NULL) OR (vestadoctrl = '') OR (vestadoctrl = '0') THEN
	
		/* --se comenta para prueba controlada
        DELETE FROM tblctrlproceso 
         WHERE intcveproceso = 3 
           AND dtfecha = pfechaejecuta; 
           
        INSERT INTO tblctrlproceso VALUES
        (3, pfechaejecuta, CURRENT HOUR TO SECOND, 'informix', 0);
		*/ --se comenta para prueba controlada
        
		SELECT COUNT(dbsname) INTO aux1
		FROM sysmaster:systabnames 
		WHERE partnum > 0 AND tabname = 'tblhistpago_temp';
		
		SELECT COUNT(tabname) INTO aux2
		FROM sysmaster:systabnames 
		WHERE partnum > 0 AND tabname = 'tblhistpago_temp';
		
		IF (aux1 <> 0 AND aux2 <> 0) THEN
			DROP TABLE bdispei:"informix".tblhistpago_temp;
		END IF;
		/*IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'tblhistpago_temp') THEN
            DROP TABLE bdispei:"informix".tblhistpago_temp;
        END IF;*/

        CREATE RAW TABLE "informix".tblhistpago_temp(
            intfoliopago integer,
            intpkpago integer,
            intcvecausadev integer,
            intpkpaqueteenv integer,
            mnyimporte decimal(19,2),
            cvecesifbcoord integer,
            cvecesifbcodest integer,
            chrestatusenvio char(1),
            vchrnombreord varchar(40),
            vchrcuentaord varchar(20),
            vchrrfcord varchar(18),
            vchrnombrebenef varchar(40),
            intcvetipoctabene integer,
            vchrcuentabenef varchar(20),
            vchrrfcbenef varchar(18),
            vchrnombrebenef2 varchar(40),
            intcvetipoctabene2 integer,
            vchrcuentabenef2 varchar(20),
            vchrrfcbenef2 varchar(18),
            vchrconceptopago varchar(210),
            mnyiva decimal(19,2),
            intrefnumerica decimal(7,0),
            vchrrefcobranza varchar(40),
            vchrclavepago varchar(10),
            vchrconceptopago2 varchar(40),
            dtfechavalor date,
            dtfechacaptura date,
            vchrclaverastreo varchar(30),
            chrusuarioprom varchar(20),
            chrfolioprom char(16),
            chrusuariovent varchar(20),
            chrfolioliqu char(16),
            intcvetipopago integer,
            intfolioservidor integer,
            intcvetipoctaord integer,
            dtmhoracargo datetime year to second,
            intcvetpooperacion char(2),
            intfoliocargo integer,
            intfoliocancela integer,
            intfolioservcanc integer,
            dtmhoracancela datetime year to second,
            chrsentidopago char(1),
            chrmotivocanc char(1),
            chrmotivodev char(1),
            chrtopologia char(1),
            chrprioridad char(1),
            txtcde byte,
            chrtxop char(4),
            vchrcverastreoorig varchar(30),
            chrctacheques char(11),
            vchrcverastreodev varchar(20),
            sintlongcverastreo smallint,
            intpkpagoorig integer,
            vchrmotivodev varchar(255),
            medioentrega integer,
            usuario varchar(50),
            usuario_aut varchar(50),
            usuario_can varchar(50),
            hora_liq  datetime year to second,
            hora_dev  datetime year to second,
            hora_cap  datetime year to second,
            numcelord char(10),  
            numcelben char(20),  
            digidord char(3), 
            digidben char(3), 
            fechalimpago char(16),
            indbenef char(2), 
            pagocomision integer, 
            comision decimal(14,2),
            numseriecert char(20),
            folioplataforma char(20)
             ) --IN datos03;
             IN dbs_bdispei_his_03_01 extent size 2250 next size 225 lock mode row; --produccion
       
        create index idx_tblhistpago_temp on "informix".tblhistpago_temp(dtfechacaptura) using btree;
        create index idx_tblhistpago_temp2 on "informix".tblhistpago_temp(dtfechavalor) using btree;

/*
        let vsql = '';
        let vsql = 'echo "load from /home/sysspei/MovSPEICH'||vfechaarch||'.txt insert into tblhistpago_temp;" > /home/sysspei/query.sql';
        system vsql;
        
        let vstmt = '';
        let vstmt = 'dbaccess bdispei /home/sysspei/query.sql';
        system vstmt;
 */


      LET vsql = ''; 
 	    LET vsql = 'echo "file /RESPALDOSNEW/SYSSPEI/MovSPEICH'||vfechaarch||'.txt delimiter ''|'' 71; INSERT INTO tblhistpago_temp;" > /RESPALDOSNEW/SYSSPEI/tblhistpago_temp.sql';
        SYSTEM vsql;
        
		LET vsql = ''; 
        LET vsql = 'dbload -d bdispei -c /RESPALDOSNEW/SYSSPEI/tblhistpago_temp.sql -l /RESPALDOSNEW/SYSSPEI/err_MovSPEICH'||vfechaarch||'.log -e 2500 -n 1000';
        SYSTEM vsql;
        LET vsql = ''; 
 
        /* #######################
        INSERT INTO tblhistpago
        SELECT * 
          FROM tblhistpago_temp;
        ####################### */
        
        FOREACH WITH HOLD
            SELECT {+INDEX (bdispei:"informix".tblhistpago_temp idx_tblhistpago_temp)}
			intfoliopago, intpkpago, intcvecausadev, intpkpaqueteenv, mnyimporte, cvecesifbcoord, cvecesifbcodest, chrestatusenvio, 
                   vchrnombreord, vchrcuentaord, vchrrfcord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, vchrrfcbenef, vchrnombrebenef2, 
                   intcvetipoctabene2, vchrcuentabenef2, vchrrfcbenef2, vchrconceptopago, mnyiva, intrefnumerica, vchrrefcobranza, vchrclavepago, 
                   vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, chrusuarioprom, chrfolioprom, chrusuariovent, chrfolioliqu, 
                   intcvetipopago, intfolioservidor, intcvetipoctaord, dtmhoracargo, intcvetpooperacion, intfoliocargo, intfoliocancela, 
                   intfolioservcanc, dtmhoracancela, chrsentidopago, chrmotivocanc, chrmotivodev, chrtopologia, chrprioridad, 
                   txtcde, chrtxop, vchrcverastreoorig, chrctacheques, vchrcverastreodev, sintlongcverastreo, intpkpagoorig, vchrmotivodev,
                   medioentrega, usuario, usuario_aut, usuario_can, hora_liq, hora_dev, hora_cap,
                   numcelord,numcelben,digidord,digidben,fechalimpago,indbenef,pagocomision,comision,numseriecert,folioplataforma
              INTO vintfoliopago, vintpkpago, vintcvecausadev, vintpkpaqueteenv, vmnyimporte, vcvecesifbcoord, vcvecesifbcodest, vchrestatusenvio, 
                   vvchrnombreord, vvchrcuentaord, vvchrrfcord, vvchrnombrebenef, vintcvetipoctabene, vvchrcuentabenef, vvchrrfcbenef, vvchrnombrebenef2, 
                   vintcvetipoctabene2, vvchrcuentabenef2, vvchrrfcbenef2, vvchrconceptopago, vmnyiva, vintrefnumerica, vvchrrefcobranza, vvchrclavepago, 
                   vvchrconceptopago2, vdtfechavalor, vdtfechacaptura, vvchrclaverastreo, vchrusuarioprom, vchrfolioprom, vchrusuariovent, vchrfolioliqu, 
                   vintcvetipopago, vintfolioservidor, vintcvetipoctaord, vdtmhoracargo, vintcvetpooperacion, vintfoliocargo, vintfoliocancela, 
                   vintfolioservcanc, vdtmhoracancela, vchrsentidopago, vchrmotivocanc, vchrmotivodev, vchrtopologia, vchrprioridad, 
                   vtxtcde, vchrtxop, vvchrcverastreoorig, vchrctacheques, vvchrcverastreodev, vsintlongcverastreo, vintpkpagoorig, vvchrmotivodev,
                   vmedioentrega, vusuario, vusuario_aut, vusuario_can, vhora_liq, vhora_dev, vhora_cap,
                   vchnumcelord,vchnumcelben,vchdigidord,vchdigidben,vchfechalimpago ,vchindbenef,vintpagocomision,vcomision,vchnumseriecert ,vchfolioplataforma
              FROM bdispei:"informix".tblhistpago_temp 
            
            IF vComienza = -1 THEN
                LET vComienza = 0;
                BEGIN WORK;
                LET vAbierto = '1';
            END IF;
            
            IF vdtfechavalor is null OR vdtfechavalor = ' '  THEN
                /*
                UPDATE tblhistpago_temp 
                   SET dtfechavalor = pfechaejecuta
                 WHERE vchrclaverastreo = vvchrclaverastreo;
                */
                 
                LET vdtfechavalor = pfechaejecuta;
            END IF;
            
            IF vdtfechacaptura is null OR vdtfechacaptura = ' ' THEN
                /*
                UPDATE tblhistpago_temp 
                   SET dtfechacaptura = pfechaejecuta
                 WHERE vchrclaverastreo = vvchrclaverastreo;
                */ 
                 
                LET vdtfechacaptura = pfechaejecuta;
            END IF;


	 
			let vvchrnombreord = replace( replace( replace(vvchrnombreord,'/',' ') , '\\\\\', ' '), '#', ' ');
			let vvchrnombrebenef = replace( replace( replace(vvchrnombrebenef,'/',' ') , '\\\\\', ' '), '#', ' ');
			let vvchrnombrebenef2 = replace( replace( replace(vvchrnombrebenef2,'/',' ') , '\\\\\', ' '), '#', ' ');
			let vvchrconceptopago = replace( replace( replace(vvchrconceptopago,'/',' ') , '\\\\\', ' '), '#', ' ');
      
      select first 1 '1'
      into v_existe
      from bdispei:"informix".tblhistpago 
      where intpkpago = vintpkpago 
      and mnyimporte = vmnyimporte
      and vchrclaverastreo = vvchrclaverastreo;
      
      IF v_existe = '' OR v_existe is null OR v_existe <> '1' THEN 
	  

      
      INSERT INTO bdispei:"informix".tblhistpago
            ( intfoliopago, intpkpago, intcvecausadev, intpkpaqueteenv, mnyimporte, cvecesifbcoord, cvecesifbcodest, chrestatusenvio, 
              vchrnombreord, vchrcuentaord, vchrrfcord, vchrnombrebenef, intcvetipoctabene, vchrcuentabenef, vchrrfcbenef, vchrnombrebenef2, 
              intcvetipoctabene2, vchrcuentabenef2, vchrrfcbenef2, vchrconceptopago, mnyiva, intrefnumerica, vchrrefcobranza, vchrclavepago, 
              vchrconceptopago2, dtfechavalor, dtfechacaptura, vchrclaverastreo, chrusuarioprom, chrfolioprom, chrusuariovent, chrfolioliqu, 
              intcvetipopago, intfolioservidor, intcvetipoctaord, dtmhoracargo, intcvetpooperacion, intfoliocargo, intfoliocancela, 
              intfolioservcanc, dtmhoracancela, chrsentidopago, chrmotivocanc, chrmotivodev, chrtopologia, chrprioridad, 
              txtcde, chrtxop, vchrcverastreoorig, chrctacheques, vchrcverastreodev, sintlongcverastreo, intpkpagoorig, vchrmotivodev,
              medioentrega, usuario, usuario_aut, usuario_can, hora_liq, hora_dev, hora_cap,
              numcelord,numcelben,digidord,digidben,fechalimpago,indbenef,pagocomision,comision,numseriecert,folioplataforma)
            VALUES
            ( vintfoliopago, vintpkpago, vintcvecausadev, vintpkpaqueteenv, vmnyimporte, vcvecesifbcoord, vcvecesifbcodest, vchrestatusenvio, 
              vvchrnombreord, vvchrcuentaord, vvchrrfcord, vvchrnombrebenef, vintcvetipoctabene, vvchrcuentabenef, vvchrrfcbenef, vvchrnombrebenef2, 
              vintcvetipoctabene2, vvchrcuentabenef2, vvchrrfcbenef2, vvchrconceptopago, vmnyiva, vintrefnumerica, vvchrrefcobranza, vvchrclavepago, 
              vvchrconceptopago2, vdtfechavalor, vdtfechacaptura, vvchrclaverastreo, vchrusuarioprom, vchrfolioprom, vchrusuariovent, vchrfolioliqu, 
              vintcvetipopago, vintfolioservidor, vintcvetipoctaord, vdtmhoracargo, vintcvetpooperacion, vintfoliocargo, vintfoliocancela, 
              vintfolioservcanc, vdtmhoracancela, vchrsentidopago, vchrmotivocanc, vchrmotivodev, vchrtopologia, vchrprioridad, 
              vtxtcde, vchrtxop, vvchrcverastreoorig, vchrctacheques, vvchrcverastreodev, vsintlongcverastreo, vintpkpagoorig, vvchrmotivodev,
              vmedioentrega, vusuario, vusuario_aut, vusuario_can, vhora_liq, vhora_dev, vhora_cap,
              vchnumcelord,vchnumcelben,vchdigidord,vchdigidben,vchfechalimpago ,vchindbenef,vintpagocomision,vcomision,vchnumseriecert ,vchfolioplataforma);
              
            LET vcontador1 = vcontador1 + 1; 
            LET vcontador2 = vcontador2 + 1;
      
      END IF 
            

            
            IF vcontador2 >= 1000 THEN
                LET vcontador2 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
        END FOREACH;
        
        IF vAbierto = '1' THEN
            COMMIT WORK;
            LET vAbierto = '0';
        END IF;
        
		/* --se comenta para prueba controlada
        UPDATE tblctrlproceso 
           SET chrstatus = 1
         Where intcveproceso = 3
           and dtfecha = pfechaejecuta;
		*/ --se comenta para prueba controlada
		
		
        RETURN vcodret, 'Exitoso';	
    ELSE 
        LET vcodret = '001';
        LET vcodret2 = "El proceso ya se ejecuto para esa fecha. Favor de validar si el proceso concluyo exitosamente ";
    END IF;

    RETURN vcodret, vcodret2;
    
    END;

END PROCEDURE;