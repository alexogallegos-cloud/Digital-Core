CREATE PROCEDURE "informix".sp_verifica_aclaracion (
	pNumCta CHAR(20)
	)
RETURNING CHAR(5) AS codRet

--Variables para el manejo de errores
DEFINE iSqlErr 	  		INTEGER;  
DEFINE iIsamErr   		INTEGER;
-- Retorno general
DEFINE codRet 			CHAR(5);
--Variables internas  
DEFINE numCte 			INTEGER;

BEGIN	
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN 
			LET codRet = iSqlErr;
			RETURN codRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_verifica_aclaracion"".out";     
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	-- Inicializacion de variables
	LET codRet = '00000';

	--Validacion de parametros 
	IF NVL(pNumCta,'') = ''
	 then 
		LET codRet = "00001";
		RETURN codRet;
	END IF;
	
	-->Inicia Logica de SP
	--se valida si existe una aclaracion en estatus "ingresada"
	select a.num_cliente into numCte
	from bdiaclaracion:acl_aclaracion a 
	inner join bdiaclaracion:acl_producto b on  a.fky_producto = b.pky_producto 
	where a.fky_estatus_aclaracion = 2 and b.numero_cuenta = pNumCta limit 1;
	
	--Si se obtiene el numero de cliente se considera que tiene aclaracion ingresada  
	IF NVL(numCte,'') != '' THEN
		LET codRet = "02348";		RETURN codRet;
	end if;
	-->Termina Logica de SP	
	
	RETURN codRet;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Alejandro Rodriguez Martinez', 
'DESCRIPCION: Valida que el numero de credito no cuente con una aclaracion ingresada',
'Codigo de retorno 00000 Indica que el numero de credito no cuenta con aclaracion abierta',
'Codigo de retorno 00001 indica que se ha enviado parametros de entrada invalidos',
'Codigo de retorno 02348 Indica que el numero de credito si cuenta con aclaracion abierta',
'FECHA : 16/Marzo/2022',
'BD    : BDIACLARACION',
'FOLIO: 833 - Adendum RQM 10 1405 CÃ©lula de RetenciÃ³n TDC';

CREATE PROCEDURE "informix".sp_reportediarioacl() RETURNING CHAR(7);

define                ejecuta lvarchar(500);
define                  shell lvarchar(200);
define           num_reportes smallint;
define            num_reporte smallint;
define	  num_reporte_inicial smallint;
define             asincronia smallint;
define                      i smallint;
define             codigo_res varchar(7);

BEGIN

	ON EXCEPTION IN (-310, -111, -206, -319, -328) --tabla existente; registro, tabla, indice inexistente, campo existente
	END EXCEPTION WITH RESUME;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/resplogifx/repaclaraciones/sp_reportediarioacl.out";
	--TRACE ON;
	--set explain file to "/resplogifx/repaclaraciones/sp_reportediarioacl.exp";

	--Creacion de estructura de control de resultados
	if (select {+AVOID_FULL (systables)} count(*) from systables where tabname = "resultados_sp_reportediarioacl")= 0 then --ejecucion primera
		create table resultados_sp_reportediarioacl (ciclo smallint, codigo varchar(10), mensaje varchar(50), primary key (ciclo));
	else
		truncate table resultados_sp_reportediarioacl;
	end if;

	--Creacion de tablas para reportes
	if (select {+AVOID_FULL (systables)} count(*) from systables where tabname = "acl_reporte_diario") <> 0 then
		drop table acl_reporte_diario;
	end if;

	CREATE TABLE acl_reporte_diario
		(reporte				smallint,
		folio_csuac				varchar(11),
		fechacaptura           	DATE,
		fecha_dictamen          DATETIME YEAR to FRACTION(5),
		importeoriginal         money,
		num_empleado            varchar(8),
		modo_de_entrada         varchar(45),
		nombre                  varchar(45),
		descripcion             varchar(255),
		status_corp             varchar(255),
		status_analisis         varchar(255),
		num_suc                 varchar(4),
		origen                	varchar(50),
		cliente                 varchar(9),
		numero_cuenta           varchar(20),
		plastico                varchar(16),
		fecha_de_cargo          DATETIME YEAR to FRACTION(5),
		fecha_afectacion        DATETIME YEAR to FRACTION(5),
		referencia23			varchar(23),
		ref_comercio			VARCHAR(70),
		tipo_evento				integer,
		evento					varchar(50),
		procede					SMALLINT,
		sel_tran				varchar(50),
		resp_eglobal	    	varchar(255),
		montoprocedente			money,
		importereclamado		money,
		nombre_cliente			varchar(60),
		predictamen				lvarchar,
		fecha_predictamen		DATETIME YEAR to FRACTION(5),
		causa_cierre			integer,
		cierre_forzado			varchar(255),
		folio_suc				varchar(30),
		fecha_consumo			DATETIME YEAR to FRACTION(5),
		canal_entrada			varchar(30),
		telefono 				varchar(20),
		correo					varchar(100),
		eci   					char(1),
		medio					char(50),
		metodo					char(5),
		idterminal				VARCHAR(16),
		fecha_cvv2				DATETIME YEAR to FRACTION(5),
		status_tarjeta          varchar(10),
		fecha_cambio_status		DATETIME YEAR to FRACTION(5),
		primary key (reporte, folio_csuac)
	)  extent size 362695 next size 36484 lock mode row;

	--create index idx_acl_reporte_diario on acl_reporte_diario (reporte, folio_csuac) using btree in db_aclaracion01;

	--Creacion solo la primera vez de campo bandera para ejecucion de proceso asincrono
	if (select count(*) from acl_tipo_accion where nombre = "REPDIA_ASIN") = 0 then
		insert into  acl_tipo_accion(pky_tipo_accion, activo, descripcion, nombre)
		select max(pky_tipo_accion)+1, 1, "OBTENCION ASINCRONA DE REPORTES DIARIOS", "REPDIA_ASIN" from acl_tipo_accion;
		let asincronia = 1;
	else
		select activo into asincronia from acl_tipo_accion where nombre = "REPDIA_ASIN";
	end if;

	--Calculo del numero de reportes
	execute procedure sp_reportediarioacl_paralelo(0,-1) into codigo_res;
	let num_reportes = codigo_res;
	let codigo_res = "0000000";

	if asincronia = 1 then
		let ejecuta = 'echo "[$(date)] Inicio del stored procedure sp_reportediarioacl modo ASINCRONO">>/resplogifx/repaclaraciones/bitacora_sp_reportediarioacl';
		let num_reporte = 1;
	else
  		let ejecuta = 'echo "[$(date)] Inicio del stored procedure sp_reportediarioacl modo SINCRONO">>/resplogifx/repaclaraciones/bitacora_sp_reportediarioacl';
		let num_reporte = num_reportes;
	end if;
	SYSTEM ejecuta;

	let ejecuta = 'echo "[$(date)] Procesare '||num_reportes||' reportes" >>/resplogifx/repaclaraciones/bitacora_sp_reportediarioacl';
	SYSTEM ejecuta;

	while num_reporte <= num_reportes
		let  shell = '/resplogifx/repaclaraciones/ejecuta_reporte_acl'||num_reporte||'.sh';

		if asincronia = 1 then
			let num_reporte_inicial = num_reporte;
		else
			let num_reporte_inicial = 1;
		end if;

		let ejecuta = 'echo "echo \"execute procedure \"informix\".sp_reportediarioacl_paralelo('||num_reporte_inicial||','||num_reporte||
					  ')\" | dbaccess bdiaclaracion >&- 2>&-" > ' || shell;
		SYSTEM ejecuta;

  		let ejecuta = 'chmod 770 ' || shell;
  		SYSTEM ejecuta;

		if asincronia = 1 then
			let ejecuta = shell || ' &';  --ejecucion asincrona del SP en cada reporte
		else
			let ejecuta = shell;          --ejecucion sincrona del SP para las "n" reportes
		end if;
		SYSTEM ejecuta;

		let ejecuta = 'echo "[$(date)] Se ha iniciado el reporte: ' || num_reporte || '/' || num_reportes ||
					  '" >>/resplogifx/repaclaraciones/bitacora_sp_reportediarioacl';
		SYSTEM ejecuta;
		select {+AVOID_FULL (bdinteg:si_fechas)} sysmaster:yieldn(10) into i from bdinteg:si_fechas; --me duermo unos segundos para no traslape

		let num_reporte = num_reporte + 1;
	end while;

	while 1 = 1 and asincronia = 1 --espera a que todos los reportes se ejecuten
		select {+AVOID_FULL (resultados_sp_reportediarioacl)} count(*) into i from resultados_sp_reportediarioacl where ciclo > 0;

		if i <> 0 then
			let ejecuta = 'echo "[$(date)] Estoy esperando que los reportes terminen, llevo '||i||' de '||num_reportes||'" >>/resplogifx/repaclaraciones/bitacora_sp_reportediarioacl';
			SYSTEM ejecuta;
		end if;

		if i = num_reportes then
			exit;
		else
			select {+AVOID_FULL (bdinteg:si_fechas)} sysmaster:yieldn(60) into i from bdinteg:si_fechas; --me duermo para no saturar el log
		end if;
	end while;

	if (select {+AVOID_FULL (resultados_sp_reportediarioacl)} count(*) from resultados_sp_reportediarioacl
		 where ciclo > 0 and codigo <> "0000000") = 0 then
		select {+AVOID_FULL (resultados_sp_reportediarioacl)} first 1 codigo into codigo_res from resultados_sp_reportediarioacl
		 where ciclo > 0 and codigo = "0000000";
	else
		select {+AVOID_FULL (resultados_sp_reportediarioacl)} first 1 codigo into codigo_res from resultados_sp_reportediarioacl
		 where ciclo > 0 and codigo <> "0000000";
	end if;

	if SQLCODE = 100 then
		let codigo_res = "100";
	end if;

	let ejecuta = 'echo "[$(date)] Fin del stored procedure sp_reportediarioacl" >>/resplogifx/repaclaraciones/bitacora_sp_reportediarioacl';
	SYSTEM ejecuta;

	INSERT INTO resultados_sp_reportediarioacl VALUES (0, "-66", "Fin del proceso sp_reportediarioacl");

	let ejecuta = 'rm -rf /resplogifx/repaclaraciones/ejecuta_reporte_acl*.sh';
	SYSTEM ejecuta;

	return codigo_res;
END;
end procedure;