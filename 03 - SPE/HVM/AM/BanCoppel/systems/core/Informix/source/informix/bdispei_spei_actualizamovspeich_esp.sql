CREATE PROCEDURE "informix".spei_actualizamovspeich_esp( pfechaejecuta date )
returning char(5),char(100);

    define vsql_err integer;
    define visam_err integer;
    define vcodret char (10);
    define vcodret2 char (100);
    define vestadoctrl char(1);
    define vsql char(150);
    define vmes Char(2);
    define vdia Char(2);
    define vanio char(4);
    define vfechaarch char(8);
    define vstmt char(150);
    define vfecha  date;
    define vclave varchar(30);
    define vmedio integer;
    define vusuario varchar(50);
    define vusaut varchar(50);
    define vuscan varchar(50);
    define vhora_cap datetime year to second;
    define vhoraliq datetime year to second;
    define vhora_dev datetime year to second;
    define vchnumcelord char(10);
    define vchnumcelben char(20);
    define vchdigidord char(3);
    define vchdigidben char(3);
    define vchfechalimpago char(16);
    define vchindbenef char(2);
    define vintpagocomision integer;
    define vcomision decimal(14,2);
    define vchnumseriecert char(20);
    define vchfolioplataforma char(20);
    define vaux integer;
    define vaux2 integer;

    let vcodret='000';
    let vcodret2='';
    let vsql_err=0;
    let visam_err=0;
    let vestadoctrl='';
    let vsql='';
    let vmes='';
    let vdia='';
    let vanio='';
    let vfechaarch='';
    let vstmt='';
    let vfecha='01011990';
    let vclave='';
    let vmedio=0;
    let vusuario='';
    let vusaut='';
    let vuscan='';
    let vhora_cap='';
    let vhoraliq='';
    let vhora_dev='';
    let vaux = 0;
    let vaux2 = 0;

    Begin
    
    on exception set vsql_err, visam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei_actualizamovspeich_esp.out";
        TRACE ON;
        IF vsql_err<>0 then
            let vcodret=vsql_err;
            let vcodret2=visam_err;
            return  vcodret,vcodret2;
        End if;
    end exception;

    --- SET debug file to '/resplogifx/conciliachq/spei_actualizamovspeich_esp.out';
    --- trace on;

    set isolation to dirty read;
    set lock mode to wait 3;

    -- // Valida la fecha del Movimiento
    IF (pfechaejecuta is null) or (pfechaejecuta = '') then
        LET vcodret = '001'; -- Falta parametro Fecha de Operacion
        LET vcodret2 = 'Falta parametro Fecha de Operacion';
        RETURN vcodret, vcodret2;
    END IF;

    --//Valida que el proceso no se haya ejecutado antes	
    SELECT chrstatus  
      INTO vestadoctrl
      FROM tblctrlproceso
     WHERE intcveproceso = 4
       AND dtfecha = pfechaejecuta;	

    LET vmes=SUBSTR(pfechaejecuta,0,2);
    LET vdia=SUBSTR(pfechaejecuta,4,2);
    LET vanio=SUBSTR(pfechaejecuta,7,4);
    LET vfechaarch=vanio||vmes||vdia;

    IF (vestadoctrl IS NULL) OR (vestadoctrl = '') OR (vestadoctrl = '0') THEN
        DELETE FROM tblctrlproceso 
         WHERE intcveproceso = 4 
           AND dtfecha = pfechaejecuta;
        
        INSERT INTO tblctrlproceso VALUES
        ( 4, pfechaejecuta, CURRENT HOUR TO SECOND, 'informix', 0 );

        SELECT COUNT(dbsname) 
          INTO vaux 
          FROM sysmaster:systabnames
         WHERE partnum > 0 
           AND tabname = 'tblhistpagoactuali_temp';

        SELECT COUNT(tabname) 
          INTO vaux2
          FROM sysmaster:systabnames
         WHERE partnum > 0 
           AND tabname = 'tblhistpagoactuali_temp';

        IF (vaux <> 0  AND vaux2 <> 0)THEN
            DROP TABLE bdispei:"informix".tblhistpagoactuali_temp;
        END IF;
        
        create raw table "informix".tblhistpagoactuali_temp(
            dtfechacaptura date,
            vchrclaverastreo varchar(30),
            medioentrega integer,
            usuario varchar(50),
            usuario_aut varchar(50),
            usuario_can varchar(50),
            hora_liq datetime year to second,
            hora_dev datetime year to second,
            hora_cap datetime year to second,
            numcelord char(10),  
            numcelben char(20),  
            digidord char(3), 
            digidben char(3), 
            fechalimpago char(16),
            indbenef char(2), 
            pagocomision integer, 
            comision decimal(14,2),
            numseriecert char(20),
            folioplataforma char(20) ) 
        extent size 2250 next size 225 lock mode row;
        create index idx_tblhistpago_tempact on "informix".tblhistpagoactuali_temp(dtfechacaptura,vchrclaverastreo) using btree;

        let vsql='';
        let vsql='echo "load from /home/sysspei/DetSPEICH'||vfechaarch||'.txt insert into tblhistpagoactuali_temp;" > /home/sysspei/query.sql';
        system vsql;
        let vstmt='';
        let vstmt='dbaccess bdispei /home/sysspei/query.sql';
        system vstmt;
        
        FOREACH	WITH HOLD
            SELECT dtfechacaptura,vchrclaverastreo,medioentrega,usuario,usuario_aut,usuario_can,hora_cap,hora_liq,hora_dev,
                   numcelord,numcelben,digidord,digidben,fechalimpago,indbenef,pagocomision,comision,numseriecert,folioplataforma
              INTO vfecha,vclave,vmedio,vusuario,vusaut,vuscan,vhora_cap,vhoraliq,vhora_dev,
                   vchnumcelord,vchnumcelben,vchdigidord,vchdigidben,vchfechalimpago ,vchindbenef,vintpagocomision,vcomision,vchnumseriecert ,vchfolioplataforma
              from tblhistpagoactuali_temp

            UPDATE tblhistpago 
               SET medioentrega=vmedio, 
                   usuario=vusuario, 
                   usuario_aut=vusaut,
                   usuario_can=vuscan,
                   hora_liq=vhoraliq, 
                   hora_dev=vhora_dev,
                   hora_cap=vhora_cap
             WHERE dtfechacaptura=dtfechacaptura
               AND vchrclaverastreo=vclave;
        END FOREACH	

        UPDATE tblctrlproceso 
           SET chrstatus=1
         Where intcveproceso=4
           and dtfecha=pfechaejecuta;
        
        return vcodret, 'Exitoso';	
    ELSE 
        LET vcodret = '001';
        LET vcodret2 = "El proceso ya se ejecuto para esa fecha. Favor de validar si el proceso concluyo exitosamente ";
    END IF;

    return vcodret, vcodret2;
    
    END;

END PROCEDURE;