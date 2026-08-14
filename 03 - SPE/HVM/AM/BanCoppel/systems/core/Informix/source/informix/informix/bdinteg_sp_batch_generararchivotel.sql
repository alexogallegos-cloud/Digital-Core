CREATE PROCEDURE "informix".sp_batch_generararchivotel(pFechaAct DATE)
RETURNING
     CHAR(6); ---cod_ret

    DEFINE v_cod_ret            CHAR(6);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE vDesErr              CHAR(60);
	DEFINE vRuta CHAR (90);
	DEFINE vsSQL LVARCHAR (32000);
	DEFINE sPreNomArchivoFinal VARCHAR(100);
	DEFINE sNombreArchivoFinal VARCHAR(100);
	DEFINE sAntNomArchivoFinal VARCHAR(100);
	DEFINE sAnterNomArchivoFinal VARCHAR(100);
	DEFINE cFecha_hoy CHAR(8);
	DEFINE vNombre CHAR (90);
	
	LET vsSQL = '' ;
	LET cFecha_hoy = '19000101';
	LET sPreNomArchivoFinal ='';
	LET sNombreArchivoFinal ='';
	LET sAntNomArchivoFinal ='';
	LET sAnterNomArchivoFinal='';
	LET vNombre = '';
	
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;	
SET ISOLATION COMMITTED READ;

	---SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
        END IF;
		drop table descarga;
        RETURN v_cod_ret;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/tmp/sp_batch_generararchivotel.out";
	--SET DEBUG FILE TO "/informix/Malena/sp_batch_generararchivotel.out";
	--TRACE ON;

	LET v_cod_ret = '000000';
	LET vDesErr = '';
	-- obtener la ruta donde se almacenara el archivo de telefonos
	SELECT TRIM(valor)
	INTO vRuta
	FROM "informix".si_param
	WHERE cod_param='193';
	--Obtener el nombre del archivo a crear 
	SELECT TRIM(valor) 
	INTO vNombre
	FROM bdisolic:"informix".ss_param 
	WHERE secuencia=378;	

	--LET vRuta = '/resplogifx/archivoscartera/altaunica/envios/';
	LET sNombreArchivoFinal = TRIM(vRuta)|| TRIM(vNombre);

	CREATE TABLE descarga (
	NumeroClienteCPL varchar(20),
	NumeroClienteBCPL varchar(20),
	Nombre1 varchar(26),
	Nombre2 varchar(26),
	ApellidoPaterno varchar(26),
	ApellidoMaterno varchar(26),
	Sexo Char(1),
	CPFDNI varchar (15),
	Empresa char(3),
	NumeroDeSolicitudCPL varchar(20),
	NumeroDeSolicitudBCPL varchar(20),
	TipoTelefono Char(1),
	NumeroTelefono varchar(10),
	ClaseTelefono char(1),
	FlagConfirmacion char(1),
	StatusSolicitud char(1),
	Antiguedad date
	);

	SELECT '0'NumeroClienteCPL,TRIM(tel1.numcte)numcte,trim(nombre1)nombre1, trim(nombre2)nombre2, trim(apell_paterno)apell_paterno, trim(apell_materno)apell_materno,sexo,''CPF,'B'Empresa ,TRIM(a.num_solicitud)num_solicitud,0::int8 NumeroDeSolicitudBCPL,'1' flag, TRIM(tel1.telefono)telefono,'F'tipo, '1'tipo2, 'A'status, a.fecha_insert
	FROM bdisolic:ss_solicitudes a
	INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud AND a.status_solicitud=b.status_solicitud
	and b.fecha_insert = pFechaAct AND b.fecha_entrada = (select MAX(fecha_entrada) from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert))
	INNER JOIN bdinteg:"informix".si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 1 and tel1.status_tel='A' and tel1.verificado <> 'V')
	LEFT OUTER join bdinteg:si_cliente c on (a.numcte = c.numcte)
	LEFT OUTER join bdinteg:si_ctepf d on (a.numcte = d.numcte)
	WHERE a.empresa='001'
	AND a.status_solicitud='AT'
	and a.num_producto = '6500'
	UNION ALL
	SELECT '0'NumeroClienteCPL,TRIM(tel1.numcte)numcte,trim(nombre1)nombre1, trim(nombre2)nombre2, trim(apell_paterno)apell_paterno, trim(apell_materno)apell_materno,sexo,''CPF,'B'Empresa ,TRIM(a.num_solicitud)num_solicitud,0::int8 NumeroDeSolicitudBCPL,'1' flag, TRIM(tel1.telefono)telefono,'M'tipo, '1'tipo2, 'A'status, a.fecha_insert
	FROM bdisolic:ss_solicitudes a
	INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud AND a.status_solicitud=b.status_solicitud
	and b.fecha_insert = pFechaAct  AND b.fecha_entrada = (select MAX(fecha_entrada) from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert))
	INNER JOIN bdinteg:"informix".si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 2 and tel1.status_tel='A' and tel1.verificado <> 'V')
	LEFT OUTER join bdinteg:si_cliente c on (a.numcte = c.numcte)
	LEFT OUTER join bdinteg:si_ctepf d on (a.numcte = d.numcte)
	WHERE a.empresa='001'
	AND a.status_solicitud='AT'
	and a.num_producto = '6500'
	INTO TEMP paso1;

	create index inx_paso on paso1(numcte);
	update statistics high for table paso1;

	SELECT '0'NumeroClienteCPL,TRIM(tel1.numcte)numcte,trim(nombre1)nombre1, trim(nombre2)nombre2, trim(apell_paterno)apell_paterno, trim(apell_materno)apell_materno,sexo,''CPF,'B'Empresa ,0 NumeroDeSolicitudCPL,TRIM(a.num_solicitud) Num_solicitudBCPL,'1' flag, TRIM(tel1.telefono)telefono,'F'tipo, '1'tipo2, 'A'status, a.fecha_insert
	 FROM bdisolic:ss_solicitudes a
	INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud AND a.status_solicitud=b.status_solicitud
	and b.fecha_insert = pFechaAct  AND b.fecha_entrada = (select MAX(fecha_entrada) from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert))
	INNER JOIN bdinteg:"informix".si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 1 and tel1.status_tel='A' and tel1.verificado <> 'V')
	LEFT OUTER join bdinteg:si_cliente c on (a.numcte = c.numcte)
	LEFT OUTER join bdinteg:si_ctepf d on (a.numcte = d.numcte)
	WHERE a.empresa='001'
	AND a.status_solicitud='AT'
	and a.num_producto = '6001'
	and a.numcte not in (select numcte from paso1)
	union all
	SELECT '0'NumeroClienteCPL,TRIM(tel1.numcte)numcte,trim(nombre1)nombre1, trim(nombre2)nombre2, trim(apell_paterno)apell_paterno, trim(apell_materno)apell_materno,sexo,''CPF,'B'Empresa ,0 NumeroDeSolicitudCPL,TRIM(a.num_solicitud) Num_solicitudBCPL,'1' flag, TRIM(tel1.telefono)telefono,'M'tipo, '1'tipo2, 'A'status, a.fecha_insert
		 FROM bdisolic:ss_solicitudes a
	INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud AND a.status_solicitud=b.status_solicitud
	and b.fecha_insert = pFechaAct   AND b.fecha_entrada = (select MAX(fecha_entrada) from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert))
	INNER JOIN bdinteg:"informix".si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 2 and tel1.status_tel='A' and tel1.verificado <> 'V')
	LEFT OUTER join bdinteg:si_cliente c on (a.numcte = c.numcte)
	LEFT OUTER join bdinteg:si_ctepf d on (a.numcte = d.numcte)
	WHERE a.empresa='001'
	AND a.status_solicitud='AT'
	and a.num_producto = '6001'
	and a.numcte not in (select numcte from paso1)
	INTO temp  paso2;

	insert into paso1 select * from paso2;
	drop table paso2;

	SELECT '0'NumeroClienteCPL,TRIM(tel1.numcte)numcte,trim(nombre1)nombre1, trim(nombre2)nombre2, trim(apell_paterno)apell_paterno, trim(apell_materno)apell_materno,sexo,''CPF,'B'Empresa ,0 NumeroDeSolicitudCPL,TRIM(a.num_solicitud) Num_solicitudBCPL,'1' flag, TRIM(tel1.telefono)telefono,'F'tipo, '1'tipo2, 'A'status, a.fecha_insert
	 FROM bdisolic:ss_solicitudes a
	INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud AND a.status_solicitud=b.status_solicitud
	and b.fecha_insert = pFechaAct   AND b.fecha_entrada = (select MAX(fecha_entrada) from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert))
	INNER JOIN bdinteg:"informix".si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 1 and tel1.status_tel='A' and tel1.verificado <> 'V')
	LEFT OUTER join bdinteg:si_cliente c on (a.numcte = c.numcte)
	LEFT OUTER join bdinteg:si_ctepf d on (a.numcte = d.numcte)
	WHERE a.empresa='001'
	AND a.status_solicitud='AT'
	and a.num_producto = '6300'
	and a.numcte not in (select numcte from paso1)
	union all
	SELECT '0'NumeroClienteCPL,TRIM(tel1.numcte)numcte,trim(nombre1)nombre1, trim(nombre2)nombre2, trim(apell_paterno)apell_paterno, trim(apell_materno)apell_materno,sexo,''CPF,'B'Empresa ,0 NumeroDeSolicitudCPL,TRIM(a.num_solicitud) Num_solicitudBCPL,'1' flag, TRIM(tel1.telefono)telefono,'M'tipo, '1'tipo2, 'A'status, a.fecha_insert
		 FROM bdisolic:ss_solicitudes a
	INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud AND a.status_solicitud=b.status_solicitud
	and b.fecha_insert = pFechaAct   AND b.fecha_entrada = (select MAX(fecha_entrada) from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert))
	INNER JOIN bdinteg:"informix".si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 2 and tel1.status_tel='A' and tel1.verificado <> 'V')
	LEFT OUTER join bdinteg:si_cliente c on (a.numcte = c.numcte)
	LEFT OUTER join bdinteg:si_ctepf d on (a.numcte = d.numcte)
	WHERE a.empresa='001'
	AND a.status_solicitud='AT'
	and a.num_producto = '6300'
	and a.numcte not in (select numcte from paso1)
	 INTO temp  paso2;

	insert into paso1 select * from paso2;
	drop table paso2;

  SELECT '0'NumeroClienteCPL,TRIM(tel1.numcte)numcte,trim(nombre1)nombre1, trim(nombre2)nombre2, trim(apell_paterno)apell_paterno, trim(apell_materno)apell_materno,sexo,''CPF,'B'Empresa ,0 NumeroDeSolicitudCPL,TRIM(a.num_solicitud) Num_solicitudBCPL,'1' flag, TRIM(tel1.telefono)telefono,'F'tipo, '1'tipo2, 'A'status, a.fecha_insert
     FROM bdisolic:ss_solicitudes a
    INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud AND a.status_solicitud=b.status_solicitud
    and b.fecha_insert = pFechaAct  AND b.fecha_entrada = (select MAX(fecha_entrada) from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert))
    INNER JOIN bdinteg:"informix".si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 1 and tel1.status_tel='A' and tel1.verificado <> 'V')
    LEFT OUTER join bdinteg:si_cliente c on (a.numcte = c.numcte)
    LEFT OUTER join bdinteg:si_ctepf d on (a.numcte = d.numcte)
    WHERE a.empresa='001'
    AND a.status_solicitud='AT'
    and a.num_producto = '7600'
    and a.numcte not in (select numcte from paso1)
    union all
    SELECT '0'NumeroClienteCPL,TRIM(tel1.numcte)numcte,trim(nombre1)nombre1, trim(nombre2)nombre2, trim(apell_paterno)apell_paterno, trim(apell_materno)apell_materno,sexo,''CPF,'B'Empresa ,0 NumeroDeSolicitudCPL,TRIM(a.num_solicitud) Num_solicitudBCPL,'1' flag, TRIM(tel1.telefono)telefono,'M'tipo, '1'tipo2, 'A'status, a.fecha_insert
         FROM bdisolic:ss_solicitudes a
    INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud AND a.status_solicitud=b.status_solicitud
    and b.fecha_insert = pFechaAct  AND b.fecha_entrada = (select MAX(fecha_entrada) from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert))
    INNER JOIN bdinteg:"informix".si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 2 and tel1.status_tel='A' and tel1.verificado <> 'V')
    LEFT OUTER join bdinteg:si_cliente c on (a.numcte = c.numcte)
    LEFT OUTER join bdinteg:si_ctepf d on (a.numcte = d.numcte)
    WHERE a.empresa='001'
    AND a.status_solicitud='AT'
    and a.num_producto = '7600'
    and a.numcte not in (select numcte from paso1)
     INTO temp  paso2;
    

    insert into paso1 select * from paso2;
     drop table paso2;

  SELECT '0'NumeroClienteCPL,TRIM(tel1.numcte)numcte,trim(nombre1)nombre1, trim(nombre2)nombre2, trim(apell_paterno)apell_paterno, trim(apell_materno)apell_materno,sexo,''CPF,'B'Empresa ,0 NumeroDeSolicitudCPL,TRIM(a.num_solicitud) Num_solicitudBCPL,'1' flag, TRIM(tel1.telefono)telefono,'F'tipo, '1'tipo2, 'A'status, a.fecha_insert
     FROM bdisolic:ss_solicitudes a
    INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud AND a.status_solicitud=b.status_solicitud
    and b.fecha_insert = pFechaAct AND b.fecha_entrada = (select MAX(fecha_entrada) from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert))
    INNER JOIN bdinteg:"informix".si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 1 and tel1.status_tel='A' and tel1.verificado <> 'V')
    LEFT OUTER join bdinteg:si_cliente c on (a.numcte = c.numcte)
    LEFT OUTER join bdinteg:si_ctepf d on (a.numcte = d.numcte)
    WHERE a.empresa='001'
    AND a.status_solicitud='AT'
    and a.num_producto = '7700'
    and a.numcte not in (select numcte from paso1)
    union all
    SELECT '0'NumeroClienteCPL,TRIM(tel1.numcte)numcte,trim(nombre1)nombre1, trim(nombre2)nombre2, trim(apell_paterno)apell_paterno, trim(apell_materno)apell_materno,sexo,''CPF,'B'Empresa ,0 NumeroDeSolicitudCPL,TRIM(a.num_solicitud) Num_solicitudBCPL,'1' flag, TRIM(tel1.telefono)telefono,'M'tipo, '1'tipo2, 'A'status, a.fecha_insert
         FROM bdisolic:ss_solicitudes a
    INNER JOIN bdisolic:ss_autorizacion b ON (a.empresa=b.empresa AND a.num_solicitud = b.num_solicitud AND a.status_solicitud=b.status_solicitud
    and b.fecha_insert = pFechaAct AND b.fecha_entrada = (select MAX(fecha_entrada) from bdisolic:ss_autorizacion where empresa = b.empresa and num_solicitud = b.num_solicitud AND status_solicitud = b.status_solicitud and fecha_insert = b.fecha_insert))
    INNER JOIN bdinteg:"informix".si_telefonos tel1 ON ( tel1.numcte = a.numcte AND tel1.tipo_tel = 2 and tel1.status_tel='A' and tel1.verificado <> 'V')
    LEFT OUTER join bdinteg:si_cliente c on (a.numcte = c.numcte)
    LEFT OUTER join bdinteg:si_ctepf d on (a.numcte = d.numcte)
    WHERE a.empresa='001'
    AND a.status_solicitud='AT'
    and a.num_producto = '7700'
    and a.numcte not in (select numcte from paso1)
     INTO temp  paso2;

	insert into paso1 select * from paso2;
	drop table paso2;
	 
--	 insert into paso1 select * from paso2;
	
	 insert into descarga select * from paso1;
	 drop table paso1;
	IF pFechaAct <> mdy(1,1,1900) OR pFechaAct IS NOT NULL THEN	
		LET cFecha_hoy = LPAD(DAY(pFechaAct),2,0)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(YEAR(pFechaAct),4,0);
		LET sNombreArchivoFinal = TRIM(vRuta)||TRIM(vNombre)|| cFecha_hoy || '.txt' ;
		LET sPreNomArchivoFinal = TRIM(vRuta)||'telefonosbatch.unl';
		LET sAntNomArchivoFinal = TRIM(vRuta)||'telefonosbatch2_batch.unl';
		LET sAnterNomArchivoFinal = TRIM(vRuta)||'telefonosbatch3_batch.unl';				
		LET vsSQL = ' echo "UNLOAD TO ' ||  TRIM(vRuta)|| 'telefonosbatchx.unl' || ' DELIMITER ' || '''|''' || 
					' SELECT * FROM descarga '||					
					' " > ' || TRIM(vRuta)|| 'Ejecutatelefonos_batch.sql';
					SYSTEM vsSQL;
					LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "Ejecutatelefonos_batch.sql";
					LET vsSQL = '';
					LET vsSQL = 'dbaccess bdinteg ' || TRIM(vRuta)|| 'Ejecutatelefonos_batch.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					LET vsSQL =  "sed 's/\\//g' " || TRIM(vRuta)|| "telefonosbatchx.unl > " || sPreNomArchivoFinal;
					SYSTEM vsSQL;					
					LET vsSQL = '';
					LET vsSQL =  "sed 's/|$//g' " || TRIM(vRuta)|| "telefonosbatch.unl > " || sAntNomArchivoFinal;
					SYSTEM vsSQL;
					-- SE AGREGA ARCHIVO DE PASO PARA AGREGAR ESPACIOS EN BLANCO A LOS CAMPOS VACÍOS
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "telefonosbatch2_batch.unl > " || sAnterNomArchivoFinal;
					SYSTEM vsSQL;				
					LET vsSQL = '';
					LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "telefonosbatch3_batch.unl > " || sNombreArchivoFinal;
					SYSTEM vsSQL;	
					--
					LET vsSQL = '';
					LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "telefonosderechos_batch.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm " || TRIM(vRuta)|| "telefonosderechos_batch.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm " || TRIM(vRuta)|| "telefonosbatch2_batch.unl";
					SYSTEM vsSQL;
					LET vsSQL = '';					
					LET vsSQL =  "rm " || TRIM(vRuta)|| "telefonosbatch3_batch.unl";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm " || TRIM(vRuta)|| "telefonosbatch.unl";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm " || TRIM(vRuta)|| "telefonosbatchx.unl";										
					SYSTEM vsSQL;
											
	ELSE
		LET v_cod_ret = '000001';
	END IF;
	drop table descarga;
	RETURN v_cod_ret;
END;
--###################################################################################
--## Procedimiento   : "informix".sp_batch_generararchivotel
--## Version         : 1.0
--## Creado por      : Maria Elena Angulo
--## Fecha creacion  : Diciembre de 2015
--## Descripcion     : Se realiza procedimiento para la generación del archivo plano   
--## con la información de telefonos no verificados del cliente para carteras.
--###################################################################################
END PROCEDURE;