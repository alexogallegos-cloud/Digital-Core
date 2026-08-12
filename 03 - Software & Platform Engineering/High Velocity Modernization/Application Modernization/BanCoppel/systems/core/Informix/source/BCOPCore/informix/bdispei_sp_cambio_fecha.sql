CREATE PROCEDURE "informix".sp_cambio_fecha()
RETURNING CHAR(5), --codigo
          INTEGER, --isam_err
          VARCHAR(100); --mensaje de error

-- DefiniciÃ³n de Variables
DEFINE wchrempresa CHAR(3);
DEFINE wfecha_hoy DATE;
DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE wfech_habil DATE;
DEFINE wfecha_habil CHAR(10);
DEFINE isam_err INTEGER;
DEFINE error_info VARCHAR(100);

-- InicializaciÃ³n
LET wchrempresa = '001';
LET vcodret = '00000';
LET error_info = '';
LET isam_err = 0;

BEGIN

    ON EXCEPTION SET vsqlerr,isam_err,error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/cambio_fecha.err"; 
        TRACE ON;
        LET vcodret = vsqlerr;
        RETURN vcodret, isam_err, error_info;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy INTO wfecha_hoy
    FROM bdicheq:sc_fechas
    WHERE empresa = wchrempresa;

    INSERT INTO tblctrlproceso (intcveproceso, dtfecha, dthora, chrusuario, chrstatus)
    VALUES (9, wfecha_hoy, CURRENT, 'informix', '3');

    -- Llamada a validaciÃ³n externa
    CALL bdispei:sp_validafecha(wchrempresa, wfecha_hoy)
    RETURNING vcodret, wfech_habil;

    -- Si la validaciÃ³n lÃ³gica del otro SP falla
    IF vcodret <> "000" THEN
        RETURN vcodret, isam_err, "ERR_VALIDACION: Fecha no vÃ¡lida para operaciÃ³n";
    ELSE
        LET vcodret = "00000";
    END IF;

    -- Formateo y ActualizaciÃ³n
    LET wfecha_habil = TO_CHAR(wfech_habil, '%d/%m/%Y');

    UPDATE bdispei:tblparametros
    SET vchrvalor = wfecha_habil
    WHERE vchrcveparametro = 'FECHA_OPERACION';   

    RETURN vcodret, isam_err, "CAMBIO DE FECHA REALIZADO EXITOSAMENTE";

END;

END PROCEDURE
DOCUMENT
'CREADO POR: RICARDO RODRIGUEZ CRUZ',
'OBJETIVO: REALIZAR INSERT Y ACTUALIZACION PARA CAMBIO DE DIA DE SPEI',
'FECHA: 11/03/2025',
'BD: BDISPEI';

CREATE PROCEDURE "informix".spei_actualizamovspeich(pfechaejecuta date)
returning char(5),char(100);
define vsql_err integer;
define visam_err integer;
define vcodret char (10);
define vcodret2 char (100);
define vestadoctrl char(1);
define vsql char(250);
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

define vComienza SMALLINT;
define vAbierto CHAR(1);
define vContador1 INTEGER;

define vdtfecha date;

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

let vComienza = -1;
let vAbierto = '0';
let vContador1 = 0;

	Begin
	on exception set vsql_err, visam_err
		SET DEBUG FILE TO "/resplogifx/conciliachq/spei_actualizamovspeich.err";
		TRACE ON;
		IF vsql_err<>0 then
			let vcodret=vsql_err;
			let vcodret2=visam_err;
			IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;    
			
--MODIFICACION 25 03 2026, PARA EN FALLO REGISTRE EL ARCHIVO QUE PRESENTO FALLA

insert into bdispei:spei_mov_det_re_proceso(jobid,dia,estatus,fecha_insert)
values('321',to_char(pfechaejecuta,'%Y/%m/%d'),0,current);

--MODIFICACION 25 03 2026, PARA EN FALLO REGISTRE EL ARCHIVO QUE PRESENTO FALLA	
			
			return  vcodret,vcodret2;
		End if;
	end exception;
	
	--SET debug file to '/resplogifx/conciliachq/spei_actualizamovspeich.out';
	--trace on;
	
	set isolation to dirty read;
	set lock mode to wait 3;

-- // Obtiene fecha de ejecuciÃ³n
	SELECT fecha_hoy
	  INTO pfechaejecuta
	  FROM bdicheq:sc_fechas; 
	  
	  
--VALIDACION FECHA CORRECTA A EJECUTAR Y ACTUALIZAR MODIFICACION 25 03 2026

    SELECT max(dtfecha)
      INTO vdtfecha
      FROM bdispei:tblctrlproceso
     WHERE intcveproceso = 3
     AND chrstatus = 1;	

if pfechaejecuta > vdtfecha then

	SELECT fecha_ant
	  INTO pfechaejecuta
	  FROM bdicheq:sc_fechas; 

end if;

--VALIDACION FECHA CORRECTA A EJECUTAR Y ACTUALIZAR MODIFICACION 25 03 2026

	
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
	WHERE intcveproceso=4
	AND dtfecha=pfechaejecuta;	
	
	LET vmes=SUBSTR(pfechaejecuta,0,2);
	LET vdia=SUBSTR(pfechaejecuta,4,2);
	LET vanio=SUBSTR(pfechaejecuta,7,4);
	LET vfechaarch=vanio||vmes||vdia;
		
	IF (vestadoctrl IS NULL) OR (vestadoctrl = '') OR (vestadoctrl = '0') THEN
	   DELETE FROM tblctrlproceso WHERE intcveproceso = 4 AND dtfecha = pfechaejecuta;
	   INSERT INTO tblctrlproceso VALUES(4,pfechaejecuta,CURRENT HOUR TO SECOND,'informix',0);
	   
	   SELECT COUNT(dbsname) INTO vaux 
	   FROM sysmaster:systabnames
	   WHERE partnum > 0 AND tabname = 'tblhistpagoactuali_temp';
	   
	   SELECT COUNT(tabname) INTO vaux2
	   FROM sysmaster:systabnames
	   WHERE partnum > 0 AND tabname = 'tblhistpagoactuali_temp';
	    
	   IF (vaux <> 0  AND vaux2 <> 0)THEN
			DROP TABLE bdispei:"informix".tblhistpagoactuali_temp;
	   END IF;
	   /*IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames
                WHERE partnum > 0 AND tabname = 'tblhistpagoactuali_temp') THEN
        DROP TABLE bdispei:"informix".tblhistpagoactuali_temp;
       END IF;*/
	   
	   create raw table "informix".tblhistpagoactuali_temp 
       (
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
		folioplataforma char(20)
		) IN dbs_bdispei_his_03_01
		extent size 2250 next size 225 lock mode row;
		create index idx_tblhistpago_tempact on "informix".tblhistpagoactuali_temp(dtfechacaptura,vchrclaverastreo) using btree;
  
  
		/* -- Se comenta por reemplazo a dboload
		let vsql='';
		let vsql='echo "load from /home/sysspei/DetSPEICH'||vfechaarch||'.txt insert into tblhistpagoactuali_temp;" > /home/sysspei/query.sql';
		system vsql;
		let vstmt='';
		let vstmt='dbaccess bdispei /home/sysspei/query.sql';
		system vstmt;
		*/ -- Se comenta por reemplazo a dboload
		
		LET vsql = '';
		LET vsql = 'echo "file /RESPALDOSNEW/SYSSPEI/DetSPEICH'||vfechaarch||'.txt delimiter ''|'' 19; INSERT INTO tblhistpagoactuali_temp;" > /RESPALDOSNEW/SYSSPEI/tblhistpagoactuali_temp.sql';
        SYSTEM vsql;
        
		LET vsql = ''; 
        LET vsql = 'dbload -d bdispei -c /RESPALDOSNEW/SYSSPEI/tblhistpagoactuali_temp.sql -l /RESPALDOSNEW/SYSSPEI/err_DetSPEICH'||vfechaarch||'.log -e 2500 -n 1000';
        SYSTEM vsql;
        LET vsql = ''; 
  
		--UPDATE tblhistpago_temp set dtfechavalor=pfechaejecuta
		--WHERE chrestatusenvio='C';
		
		FOREACH	WITH HOLD
			SELECT {+INDEX (bdispei:"informix".tblhistpagoactuali_temp idx_tblhistpago_tempact)}
			dtfechacaptura,vchrclaverastreo,medioentrega,usuario,usuario_aut,usuario_can,hora_cap,hora_liq,hora_dev,
			numcelord,numcelben,digidord,digidben,fechalimpago,indbenef,pagocomision,comision,numseriecert,folioplataforma
			INTO vfecha,vclave,vmedio,vusuario,vusaut,vuscan,vhora_cap,vhoraliq,vhora_dev,
			vchnumcelord,vchnumcelben,vchdigidord,vchdigidben,vchfechalimpago ,vchindbenef,vintpagocomision,vcomision,vchnumseriecert ,vchfolioplataforma
			from tblhistpagoactuali_temp
			
			IF vComienza = -1 THEN
                LET vComienza = 0;
                BEGIN WORK;
                LET vAbierto = '1';
            END IF;			
			
				UPDATE tblhistpago SET  medioentrega=vmedio, usuario=vusuario, usuario_aut=vusaut,usuario_can=vuscan,
				hora_liq=vhoraliq, hora_dev=vhora_dev,hora_cap=vhora_cap
				WHERE dtfechacaptura=dtfechacaptura
				AND vchrclaverastreo=vclave;
				
				LET vcontador1 = vcontador1 + 1;
				
			IF vcontador1 >= 1000 THEN
                LET vcontador1 = 0;
                COMMIT WORK;
                BEGIN WORK;
            END IF;				
				
		END FOREACH;
		
		IF vAbierto = '1' THEN
            COMMIT WORK;
            LET vAbierto = '0';
        END IF;		
		
		UPDATE tblctrlproceso SET chrstatus=1
		Where intcveproceso=4
		and dtfecha=pfechaejecuta;
		
		LET vsql = ''; 		
		LET vsql = 'rm -f /RESPALDOSNEW/SYSSPEI/DetSPEICH'||vfechaarch||'.txt '; --Elimina archivo DetPEICH.
		SYSTEM vsql;		
	
		return vcodret, 'Exitoso';	
		   
	ELSE 
		LET vcodret = '001';
        LET vcodret2 = "El proceso ya se ejecuto para esa fecha. Favor de validar si el proceso concluyo exitosamente ";
	END IF;
	
	return vcodret, vcodret2;
END;

END PROCEDURE

DOCUMENT 
'AUTOR MODIFICACION: MARIO GONZALEZ VAZQUEZ',
'FECHA: 04-JULIO-2025',
'DESCRIPCION: Se agrega index a consulta de la tabla tblhistpagoactuali_temp, se implementa dbload para la carga del archivo DetSPEICH, se incrementa el tamaÃ±o de la variable a 250 vsql y se implementa commit parcial en update y se crean las variables para su funcionamiento',
'AUTOR MODIFICACION: MARIO GONZALEZ VAZQUEZ',
'FECHA: 25-MARZO-2026',
'DESCRIPCION: Se aÃ±ade validacion para consultar la ultima fecha de ejecucion del job 320 Control - M que es el job previo y ligado a este job 321 para validar contra fecha de bdicheq:sc_fechas que se este cargando la fecha correcta para la carga correcta del archivo';


CREATE PROCEDURE "informix".callsyn_procsign()
   DEFINE l_type char(15);
   DEFINE l_idmsg char(15);
   LET l_type = '1';
   LET l_idmsg = '1';
   -- code to execute if user tries to execute a specified

   SYSTEM 'syn_procsign bdispei ' || l_type || ' ' || l_idmsg || ' 1';

END PROCEDURE;