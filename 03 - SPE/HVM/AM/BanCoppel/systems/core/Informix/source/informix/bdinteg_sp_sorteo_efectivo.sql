CREATE PROCEDURE "informix".sp_sorteo_efectivo(p_fecha DATE)
RETURNING VARCHAR(5),VARCHAR(5), VARCHAR(50);

--******************
--Define Variables
--******************
-----------------------
--Variables de Proceso
-----------------------
DEFINE vcodret1         	VARCHAR(5);
DEFINE vcodret2         	VARCHAR(5);
DEFINE error_info			VARCHAR(50);
DEFINE sql_err          	INTEGER;
DEFINE isam_err         	INTEGER;
DEFINE vcontador1       	INTEGER;
DEFINE vcontador2       	INTEGER; 
DEFINE vsql             	CHAR(1500);
DEFINE vfechatxt			DATE;	
DEFINE vfecha				CHAR(10);	
DEFINE vfecha2				CHAR(8);	
---------------------------
--Variables de operaciones
---------------------------
DEFINE  v_fecha_info       DATE;
DEFINE  v_fecha_carga      DATE;
DEFINE  v_numbol           BIGINT;
DEFINE  v_estado 		   INTEGER;
DEFINE  v_ciudad		   CHAR(20);
DEFINE  v_tienda           CHAR(4);
DEFINE  v_area 		   	   CHAR(1);
DEFINE  v_caja 		   	   INTEGER;
DEFINE  v_tipomovimiento   INTEGER;
DEFINE  v_folio			   CHAR(16);
DEFINE  v_cliente          CHAR(20);
DEFINE  v_importe 		   CHAR(5);
DEFINE  v_tel			   CHAR(13);
DEFINE  v_telcel		   CHAR(13);
DEFINE  v_tel2			   CHAR(13);
DEFINE  v_telcel2		   CHAR(13);
DEFINE  v_nombre		   CHAR(50);
DEFINE  v_nombre2		   CHAR(50);
DEFINE  v_domicilio		   CHAR(70);
DEFINE  v_domicilio2	   CHAR(70);
DEFINE  v_des_estado 	   CHAR(25);	
DEFINE  v_fec_fecha		   DATETIME YEAR TO FRACTION(3);
DEFINE  v_origen 		   CHAR(7);
DEFINE	v_secuencia		   INTEGER;
DEFINE  v_cuenta           CHAR(20);
DEFINE  v_tarjeta          CHAR(20);
DEFINE  v_saldo        	   MONEY(16,2);
--DEFINE  v_cred_valid       INTEGER;
DEFINE  v_boletos          INTEGER;


--*********************
--Inicializa variables
--*********************
-----------------------
--Variables de Proceso
-----------------------
LET vcodret1         = '00000';
LET vcodret2         = '00000';
LET error_info		 = 'INICIA PROCESO, SE CARGAN VARIABLES';
LET sql_err	         = 0;
LET isam_err         = 0;
LET vcontador1       = 0;
LET vcontador2       = 0; 
LET vsql             = '';
LET vfechatxt		 = p_fecha+1;
LET vfecha			 = substr(vfechatxt, 7,4)||substr(vfechatxt, 1,2)||substr(vfechatxt, 4,2);
LET vfecha2			 = substr(p_fecha, 1,2)||substr(p_fecha, 4,2)||substr(p_fecha, 7,4);
LET 	v_fecha_info  		= '';
LET 	v_fecha_carga 		= '';
--LET 	v_numbol      		= 1001;
LET 	v_estado 	  		= 2;
LET		v_ciudad 			= ''; 
LET 	v_tienda      		= '';
LET     v_area        		= 'B';
LET     v_caja 	  	  		= 1;
LET     v_tipomovimiento 	= 10;
LET		v_folio 			= '0000000000000000';
LET 	v_cliente     		= '';
LET     v_importe     		= '00000';
LET		v_tel 				= '';
LET		v_telcel 			= '';
LET		v_tel2 				= '';
LET		v_telcel2 			= '';
LET 	v_nombre			= '';
LET 	v_nombre2			= '';
LET 	v_domicilio			= '';
LET 	v_domicilio2		= '';
LET     v_des_estado		= '';
LET 	v_fec_fecha	  		= '';
LET     v_origen 	  		= '0000000';
LET 	v_secuencia			= 0;
LET 	v_cuenta      		= '';
LET 	v_tarjeta     		= '';
LET 	v_saldo       		= 0;
--LET 	v_cred_valid  		= '';
LET 	v_boletos     		= 0;


 
BEGIN
 
	-------------------------
	--Manejo de excepciones--
	-------------------------
	ON EXCEPTION SET sql_err, isam_err, error_info
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vcodret2 = isam_err;
				LET error_info = error_info;
				COMMIT WORK;
			RETURN vcodret1,isam_err,error_info;
			END IF;
		END EXCEPTION;
	
	--//Inicia SPL
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
	
		
	--SET DEBUG FILE TO "/informix/allan/sorteo_efec/sp_sorteo_efectivo_pbades5.out"; --Se genera log en un archivo .out
 	--TRACE ON;
 
	LET v_numbol = (select max(num_boleto) from bdinteg@stag_ids1170:si_sorteo_efectivo); ---Obtiene el ultimo boleto asignado 
	---select count(*) from bdinteg@stag_ids1170:si_sorteo_efectivo
	--si los boletos son null inicializa en 0
	IF v_numbol is null then
	 	 let v_numbol =  0;
	end if	 
 
----**********************
----Obtiene datos cliente
----**********************
---Obtiene Nombre del Cliente y numero de boletos
	SELECT
	 a.fecha_info
	,a.fecha_carga 
	,a.num_cuenta
	,a.num_cliente
	,a.num_tarjeta
	,a.num_tienda
	,a.fec_fecha
	,a.saldo
	,CASE WHEN a.saldo >= 100200 THEN 1000 ELSE TRUNC((a.saldo/100)-2 )END as boletos --numero de boletos por saldo en cuanta (topado a 1000 boletos)
	,trim(b.nombre1)||' '||trim(b.nombre2)||' '||trim(b.apell_paterno)||' '||trim(b.apell_materno) as nom_nombre ---inicia por nombre
	,a.cred_valid
	FROM bdinteg:si_sorteo_efectivo_temp a
	LEFT JOIN bdinteg:si_cliente b 
	ON  a.num_cliente=b.numcte --obtiene nombre del cliente
	WHERE a.fecha_info = p_fecha
	AND   a.cred_valid = 1 --cuantas con credito valido
	INTO TEMP nomcuenta WITH NO LOG; --inserta datos en tabla temporal
	
	CREATE INDEX idx_tmp_nomcuenta ON nomcuenta(num_cuenta) ONLINE;
	CREATE INDEX idx_tmp_nomcuenta2 ON nomcuenta(num_cuenta,num_cliente) ONLINE;
    UPDATE STATISTICS HIGH FOR TABLE nomcuenta;
---Obtiene direccion y telefono

SELECT
	 a.num_cuenta
	,a.num_cliente
	,di.ciudad as des_ciudad
	,di.estado as des_estado--agregado
	,di.telefono as num_telefono 
	,di.telefonocel as num_telefonocelular
	,di.direccion as des_domicilio
	FROM nomcuenta a
	LEFT JOIN
	(
	SELECT {+MULTI_INDEX(bdinteg:si_direcciones_actual)}
	DOM.numcte
	,TRIM(CIU.NOMBRECIUDAD) as ciudad
	,TRIM(trim(SCA.NOMBRECALLE)||' '||trim(dom.numeroextcalle)||' '||trim(cat.nombrezona)) as direccion
	--,cat.codigopostalzona ||' '||trim(se.nombre)) as estado
	,TRIM(se.nombre) as estado
	,tel1.telefono
	,tel2.telefono as telefonocel
	FROM BDINTEG:SI_DIRECCIONES_ACTUAL DOM  
	LEFT OUTER JOIN BDINTEG:SI_CATCALLES SCA ON (DOM.NUMEROCALLE = SCA.NUMEROCALLE)
	LEFT OUTER JOIN BDINTEG:SI_CATZONAS CAT ON (DOM.NUMEROCIUDAD = CAT.NUMEROCIUDAD AND DOM.NUMEROCOLONIA = CAT.NUMEROCOLONIA)  
	LEFT JOIN BDINTEG:SI_CATCIUDADES CIU ON (DOM.NUMEROCIUDAD = CIU.NUMEROCIUDAD  )
	LEFT JOIN BDINTEG:SI_ESTADOS SE ON ( DOM.estado = SE.ESTADO )
	LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dom.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel ='A')
	LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dom.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel ='A')
	WHERE DOM.TIPO_DIR  = 1	)di---Obtiene direccion y telefono
	ON a.num_cliente = di.numcte
	INTO TEMP dircuenta WITH NO LOG; --inserta datos en tabla temporal

    CREATE INDEX idx_tmp_dircuenta ON dircuenta(num_cuenta) ONLINE;
	CREATE INDEX idx_tmp_dircuenta2 ON dircuenta(num_cuenta, num_cliente) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE dircuenta;
	
------------
--obtiene datos cuenta	
	
	SELECT
	 a.fecha_info
	,a.fecha_carga 
	,trim(a.num_cuenta)  as num_cuenta
	,trim(a.num_cliente) as num_cliente
	,trim(a.num_tarjeta) as num_tarjeta
	,a.num_tienda
	,a.fec_fecha
	,a.saldo
	,a.boletos --numero de boletos por saldo en cuanta (topado a 1000 boletos)
	,di.des_ciudad
	,'' as  num_folio 
	,di.num_telefono 
	,di.num_telefonocelular
	,a.nom_nombre ---inicia por nombre
	,di.des_domicilio
	,'' as num_secuncia 
	,a.cred_valid
	,di.des_estado
	FROM nomcuenta a
	INNER JOIN dircuenta di
	ON  a.num_cuenta = di.num_cuenta
	AND a.num_cliente = di.num_cliente 
	INTO TEMP datoscuenta WITH NO LOG; --inserta datos en tabla temporal
	
	CREATE INDEX idx_tmp_datoscuenta ON datoscuenta(num_cuenta) ONLINE;
	CREATE INDEX idx_tmp_datoscuenta2 ON datoscuenta(boletos) ONLINE;
	CREATE INDEX idx_tmp_datoscuenta3 ON datoscuenta(fecha_info) ONLINE;
	CREATE INDEX idx_tmp_datoscuenta4 ON datoscuenta(num_cuenta, num_cliente) ONLINE;
	UPDATE STATISTICS HIGH FOR TABLE datoscuenta;


-------------------------------------
/*	SELECT
	a.fecha_info
	,a.fecha_carga 
	,trim(a.num_cuenta)  as num_cuenta
	,trim(a.num_cliente) as num_cliente
	,trim(a.num_tarjeta) as num_tarjeta
	,a.num_tienda
	,a.fec_fecha
	,a.saldo
	,CASE WHEN a.saldo >= 100200 THEN 1000 ELSE TRUNC((a.saldo/100)-2 )END as boletos --numero de boletos por saldo en cuanta (topado a 1000 boletos)
	,di.ciudad as des_ciudad
	,'' as  num_folio 
	,di.telefono as num_telefono 
	,di.telefonocel as num_telefonocelular
	,trim(b.nombre1)||' '||trim(b.nombre2)||' '||trim(b.apell_paterno)||' '||trim(b.apell_materno) as nom_nombre ---inicia por nombre
	,di.direccion as des_domicilio
	,'' as num_secuncia 
	,a.cred_valid
	
	FROM bdinteg:si_sorteo_efectivo_temp a
	LEFT JOIN bdinteg:si_cliente b ON  a.num_cliente=b.numcte --obtiene nombre del cliente
	LEFT JOIN
	(
	SELECT 
	DOM.numcte
	,TRIM(CIU.NOMBRECIUDAD) as ciudad
	,TRIM(trim(SCA.NOMBRECALLE)||' '||trim(dom.numeroextcalle)||' '||trim(cat.nombrezona)) as direccion
	--,cat.codigopostalzona ||' '||trim(se.nombre)) as estado
	,tel1.telefono
	,tel2.telefono as telefonocel
	FROM BDINTEG:SI_DIRECCIONES_ACTUAL DOM  
	LEFT OUTER JOIN BDINTEG:SI_CATCALLES SCA ON (DOM.NUMEROCALLE = SCA.NUMEROCALLE)
	LEFT OUTER JOIN BDINTEG:SI_CATZONAS CAT ON (DOM.NUMEROCIUDAD = CAT.NUMEROCIUDAD AND DOM.NUMEROCOLONIA = CAT.NUMEROCOLONIA)  
	LEFT JOIN BDINTEG:SI_CATCIUDADES CIU ON (DOM.NUMEROCIUDAD = CIU.NUMEROCIUDAD  )
	LEFT JOIN BDINTEG:SI_ESTADOS SE ON ( DOM.estado = SE.ESTADO )
	LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON (tel1.numcte = dom.numcte AND tel1.tipo_tel = 1 AND tel1.status_tel ='A')
	LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON (tel2.numcte = dom.numcte AND tel2.tipo_tel = 2 AND tel2.status_tel ='A')
	WHERE DOM.TIPO_DIR  = 1	)di---Obtiene direccion y telefono
	ON a.num_cliente = di.numcte
	WHERE a.fecha_info = p_fecha
	AND   a.cred_valid =1 --cuantas con credito valido
	INTO TEMP datoscuenta WITH NO LOG; --inserta datos en tabla temporal
*/ 
	
	--Crea tabla temporal para Secuencia
	
	CREATE temp TABLE secuencia
	(num_cuenta CHAR (20),
	 numreg serial)
	WITH NO LOG;
	
	CREATE INDEX idx_tmp_secuencia ON secuencia(num_cuenta);
	UPDATE STATISTICS HIGH FOR TABLE secuencia;

	
	--Inserta Numeros de cuenta (unicos)-secuencia
		
	INSERT INTO secuencia (num_cuenta)
	select  distinct num_cuenta from datoscuenta order by num_cuenta;
	
	--*********************************************************************************
	--Obtiene datos de la cuenta, numero de boleto, secuencia e inserta en tabla final
	--*********************************************************************************
	FOREACH WITH HOLD  
	
	SELECT 	
	 a.fecha_info
	,a.fecha_carga 
	,NVL(a.des_ciudad,"Sin Ciudad") as des_ciudad
	,a.num_tienda
	,a.num_cliente
	,NVL(a.num_telefono,0) as num_telefono 
	,NVL(a.num_telefonocelular,0) as num_telefonocelular
	,NVL(a.nom_nombre,"Sin Nombre") as nom_nombre
	,NVL(a.des_domicilio, "Sin Domicilio") as des_domicilio
	,a.fec_fecha
	,a.num_cuenta
	,a.num_tarjeta
	,a.saldo
	,a.boletos --boletos por cuanta
	--,a.cred_valid
	,c.numreg as secuencia
	,NVL(a.des_estado,"Sin Estado") as des_estado
	INTO v_fecha_info,v_fecha_carga,v_ciudad,v_tienda,v_cliente,v_tel,v_telcel,v_nombre,
		 v_domicilio,v_fec_fecha,v_cuenta,v_tarjeta,v_saldo,v_boletos,v_secuencia,v_des_estado 


	FROM datoscuenta a,
	( SELECT LEVEL numrep FROM bdinteg:registro CONNECT BY LEVEL <= 1001 ) b, --repite registos por boleto (1 registro x 1 boleto)
	 secuencia c
	WHERE a.boletos >= b.numrep
	and a.num_cuenta = c.num_cuenta
	--TRUNC((c.saldo/100)-2 ) >= d.numrep
	and a.fecha_info = p_fecha
	--and a.cred_valid = 1
	--and a.saldo = 441770.5
	--and a.saldo <= 453.56 
	order by a.num_cuenta
	
	
	---Ejecuta SP para limpiar datos	
	EXECUTE PROCEDURE bdinteg:"informix".sp_quitar_acentos(v_nombre)
			INTO v_nombre2;
			
	EXECUTE PROCEDURE bdinteg:"informix".sp_quitar_acentos(v_domicilio)
			INTO v_domicilio2;

	EXECUTE PROCEDURE bdinteg:"informix".sp_limpia_telefono(v_tel)
			INTO v_tel2;
			
	EXECUTE PROCEDURE bdinteg:"informix".sp_limpia_telefono(v_telcel)
			INTO v_telcel2;			
			
			
	--Genera boletos
	 LET v_numbol = v_numbol + 1;
	 
	--LET v_folio = right('000000000000000'||cast((v_folio + 1) as char),16);
	 	 
		
	--/CADA 5000 REGISTROS ACTUALIZADOS SE TERMINA EL TRABAJO E INICA DE NUEVO
	
		IF vcontador1 = 0 THEN  --Inicia el trabajo 
				BEGIN WORK;
			END IF; 
				
		
		INSERT INTO bdinteg@stag_ids1170:"informix".si_sorteo_efectivo(fecha_info,fecha_carga,num_boleto,num_estado,des_ciudad,num_tienda,clv_area,num_caja,
		clv_tipomovimiento,num_folio,num_cliente,imp_importe,num_telefono,num_telefonocelular,nom_nombre,des_domicilio,fec_fecha,
		clv_origen,num_secuencia,num_cuenta,num_tarjeta,saldo,generico1)
		VALUES(v_fecha_info,v_fecha_carga,v_numbol,v_estado,v_ciudad,v_tienda,v_area,v_caja,
			   v_tipomovimiento,v_folio,v_cliente,v_importe,v_tel2,v_telcel2,v_nombre2,v_domicilio2,v_fec_fecha,
			   v_origen,v_secuencia,v_cuenta,v_tarjeta,v_saldo,v_des_estado);
 
					
			LET vcontador1 = vcontador1 + 1; --contador de registros
			
			IF vcontador1 = 5000 THEN  --reinicia el contador cada 5000 registros
				LET vcontador1 = 0;
				COMMIT WORK; 
			END IF; 
 
  
 END FOREACH;
 
 --Termina el trabajo en caso de no llegar a los 5000 registros para no bloquear las tablas.
  IF (vcontador1 > 0) THEN		
			COMMIT WORK;
		END IF;
  
  --******************************
  --Transfiere datos archivo .txt
  --******************************

  --Genera archivo de ejecucion 
 LET vsql = 'echo "set isolation to dirty read; unload to /resplogifx/syssorteo/efectivo/PasSorteoEfectivo'||TRIM(vfecha)||'.txt '||'DELIMITER '||'''?'' '||
 'select num_boleto||''|''||num_estado||''|''||TRIM(des_ciudad)||''|''||num_tienda||''|''||clv_area||''|''||num_caja||''|''||clv_tipomovimiento||''|''||num_folio||''|''||TRIM(num_cliente)||''|''||imp_importe||''|''||TRIM(num_telefono)||''|''||TRIM(num_telefonocelular)||''|''||TRIM(nom_nombre)||''|''||TRIM(des_domicilio)||''|''||NVL(fecha_info,CURRENT)||''|''||clv_origen||''|''||num_secuencia||''|''||TRIM(generico1) from bdinteg@stag_ids1170:si_sorteo_efectivo where fecha_info = '''||vfecha2||''';" > /resplogifx/syssorteo/efectivo/unload_sorteoefectivo.sql';
		SYSTEM vsql;
 LET vsql = '';		
 
 --ejecuta select y unload mediante archivo .sql
 LET vsql = "dbaccess bdinteg /resplogifx/syssorteo/efectivo/unload_sorteoefectivo.sql";
        SYSTEM vsql;	

--Elimina el caracter delimitador '?'.
 LET vsql = '' ;
 LET vsql =  "sed 's/?$//g' " ||'/resplogifx/syssorteo/efectivo/PasSorteoEfectivo'||TRIM(vfecha)||'.txt '||" > "||'/resplogifx/syssorteo/efectivo/SorteoEfectivo'||TRIM(vfecha)||'.txt';
 SYSTEM vsql;
 
 --Elimina archivo de paso.
 LET vsql = '';
 LET vsql = "rm " ||'/resplogifx/syssorteo/efectivo/PasSorteoEfectivo'||TRIM(vfecha)||'.txt '; 
 SYSTEM vsql;  
  
--Elimina archivo de ejecucion .sql	
 LET vsql = '';
 LET vsql = 'rm /resplogifx/syssorteo/efectivo/unload_sorteoefectivo.sql'; 
 SYSTEM vsql;

 
  --Elimina temporales
  DROP TABLE nomcuenta;
  DROP TABLE dircuenta;
  DROP TABLE datoscuenta;
  DROP TABLE secuencia;

--valores de salida
  --LET error_info = 'TOTAL DE CUENTAS CARGADAS DEL DIA '||substr(p_fecha, 4,2) || '/'|| substr(p_fecha, 1,2) || '/'|| substr(p_fecha, 7,4);
  LET error_info = 'Ejecucion Exitosa';
  RETURN vcodret1,vcodret2,error_info;
  
  
END;
END PROCEDURE

DOCUMENT
'CREADO POR: JONATHAN RUIZ',
'FECHA DE CREACION: 04 DE OCTUBRE DEL 2017',
'OBJETIVO: SE CREA PROCESO PARA CARGAR AUTOMATICAMENTE',
'          LAS CUENTAS QUE PARTICIPAN EN EL SORTEO',
'          EFECTIVO BANCOPPEL',
'          GENERA BOLETOS Y CARGA INFORMACION EN ARCHIVO DE TEXTO',
'BD: BDINTEG',
'MODIFICADO POR: JONATHAN RUIZ',
'FECHA DE MODIFICACION: 15 DE NOVIEMBRE DE 2017',
'OBJETIVO: LIMPIEZA DE NUMEROS TELEFONICOS',
'          SUSTITUIR LOS TELFONOS NULL POR CERO',
'BD: BDINTEG',
'MODIFICADO POR: JONATHAN RUIZ',
'FECHA DE MODIFICACION: 21 DE NOVIEMBRE DE 2017',
'OBJETIVO: SEGMENTAR CONSULTA DE DATOS CLIENTE',
'          BAJAR COSTOS EN DB',
'BD: BDINTEG',
'MODIFICADO POR: JONATHAN RUIZ',
'FECHA DE MODIFICACION: 20 DE DICIEMBRE DE 2017',
'OBJETIVO: CAMBIO REFERENCIA DE TABLA si_sorteo_efectivo del CB a STG',
'          BAJAR COSTOS EN CB',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_consulta_status_bpi(pEmpresa char(3), pNumCte char(9))
	RETURNING char (5),char (4),char (40), integer, date, date,char(1);

--Realizó: Javier A. Chávez Trujillo
--Fecha: 17/12/08
--Solicitó: Mauricio León
--Actividad: Retorna el número y nombre de sucursal asi como el status y la fecha en que se registro


--Realizó: Francisco Rodríguez Ibarra
--Fecha: 18/01/2013
--Solicitó: Walber Castro
--Actividad: Se modifica sp, para retornar el estatus de bloqueo_temporal del cliente de la tabla bpi_avatar.


--Define variables
define sql_err integer;
define cod_ret char (5);
define vSucursal char (4);
define vNombre char(40);
define vFstatus date;
define vIdStatus integer;
define vFregistro date;
define vStatus char(1);

--Inicializa variables
LET sql_err = 0;
LET cod_ret = '000';
LET vSucursal = '';
LET vNombre = '';
LET vFstatus = '';
LET vIdStatus = 0;
LET vFregistro = '';
LET vStatus='';

--SET DEBUG FILE TO "/tmp/Manuel/sp_consulta_status_bpi.out";
--TRACE ON;

BEGIN

 ON EXCEPTION SET sql_err
          LET cod_ret = sql_err;
      RETURN  cod_ret, vSucursal, vNombre, vIdStatus, vFstatus, vFregistro,vStatus;
   END EXCEPTION;
   
   SET ISOLATION TO DIRTY READ ;
   SET LOCK MODE TO WAIT 3 ;
   
   IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = pNumcte) THEN

		--Se agrega una fecha default para cuando obtiene las fechas vacias o nulas.
		--SELECT b.suc_registro, c.nombre, b.id_status, b.f_status, b.f_registro 
		SELECT b.suc_registro, c.nombre, b.id_status, NVL(b.f_status,(EXTEND(MDY(1,01,1900), YEAR to DAY))), NVL(b.f_registro,(EXTEND(MDY(1,01,1900), YEAR to DAY))) 
		INTO vSucursal, vNombre, vIdStatus, vFstatus, vFregistro
		FROM bdinteg:"informix".si_bpiusuarios b
		INNER JOIN bdinteg:"informix".si_sucursales c
		ON b.empresa = pEmpresa
			AND b.empresa = c.empresa
			AND b.suc_registro = c.sucursal
		WHERE b.numcte = pNumCte;
		
		--Se agrega este query para traerse el estatus de acceso avatar.
		SELECT bloqueo_temporal INTO vStatus FROM bdibpi:"informix".bpi_avatar WHERE num_cte=TRIM(pNumCte);
		
		IF(NVL(vStatus, '') = '') THEN
			LET vStatus='F';
		END IF;
	ELSE
		LET cod_ret = '001'; -- El cliente No existe
	END IF;

	RETURN cod_ret, vSucursal, vNombre, vIdStatus, vFstatus, vFregistro,vStatus;

END;

END PROCEDURE;