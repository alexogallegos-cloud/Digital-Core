create procedure "informix".sp_rep_convenios()
returning VARCHAR(6);


DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);
DEFINE cProceso  char(4);
DEFINE cMensaje  char (100);
DEFINE cCod_ret  smallint;
DEFINE sPaso				integer;

DEFINE cSQL                 CHAR(2204);
DEFINE vsql					CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cruta                CHAR(100);
DEFINE cdelimitador         CHAR(1);
DEFINE cnombre          CHAR(100);

DEFINE pnumcredito   char(20);
DEFINE pnumcte		 char(20);
DEFINE vstatus 		char(15);
DEFINE pfechacompac  DATE;
DEFINE pfecha_venci  DATE;
DEFINE vplazo		smallint;
DEFINE pimporte      DECIMAL(18,2);
define vmSuma1 		 DECIMAL(18,2);
define vmSuma2 		 DECIMAL(18,2);
DEFINE vpago_venc	 smallint;
DEFINE vpago_venc2	 smallint;
DEFINE vfecha_envio	date;
DEFINE vstatus_envio	char(15);
DEFINE pfechahoy     date;
define vfecha_ant	date;
define vfecha	date;


	let P_COD_RET = '111111';
	let cCod_ret = '';
    let cMensaje = '';
	let cproceso = '2074';
	let SQL_ERR            = 0;
	let ISAM_ERR           = 0;
	let ERROR_INFO         = '';
	let P_MENSAJE          = '';
	let sPaso 			=0;
	
let cSQL           = '';
let vsql			 = '';
let cSQL1           = '';
let cSQL2           = '';
let cSQL3            = '';
let cruta            = '';
let cdelimitador    = '';
let cnombre           = '';
	
let pnumcredito  	 = '';
let pnumcte			= '';
let vstatus 		= '';
let pfechacompac 	 =DATE(1);
let pfecha_venci 	 =DATE(1);
let vplazo			 = 0;
let pimporte    	   = 0;
let vmSuma1 		 = 0;
let vmSuma2 		 = 0;
let vpago_venc		 = 0;
let vpago_venc2	 	 = 0;
let vfecha_envio		= date(1);
let vstatus_envio	= '';
let pfechahoy   	 = date(1);
let vfecha_ant 		 = date(1);
let vfecha	 		 = date(1);
	

BEGIN 
  
    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, P_COD_RET, P_MENSAJE, '02')
        RETURNING P_COD_RET;
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
     RETURN P_COD_RET;
     END exception;
	 
-- SET DEBUG FILE TO 'compacrep.out';
-- TRACE ON;	
	
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'convenios';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE convenios;
            END IF;
			
	create table convenios
	( numcte		char(20),
	status 		char(15),
	fechacompac  	DATE,
	fecha_venci  	DATE,
	plazo			smallint,
	importe     	DECIMAL(18,2),
	mSuma1 		DECIMAL(18,2),
	mSuma2 		DECIMAL(18,2),
	pago_venc	 	smallint,
	pago_venc2	 	smallint,
	fecha_envio		date,
	status_envio	char(15));
	
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico)
	INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = '001'
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 2;
	--Valida que exista el caracter
	IF NVL(cDelimitador,'') = '' THEN
        LET P_COD_RET= '104004';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = P_COD_RET;
	        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
			END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '01')RETURNING P_COD_RET;	
        Return P_COD_RET;
	END IF;
		
	select trim(valor_alfabetico) into cruta
	from bdicobranza:cb_param_campania 
	where tipo_campania = 1
	and grupo_parametro = 'ARCHIVOS'
	and num_parametro = 34;
	--Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET P_COD_RET= '104005';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = P_COD_RET;
	        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
			END IF;
         CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '01')RETURNING P_COD_RET;	
	     Return P_COD_RET;
	END IF;
	
    Select Fecha_Hoy
        Into pfechahoy 
    From bdicred:sd_fechas
    Where empresa = '001'; 

--let pfechahoy = '07-03-2013'; ---pruebas-------------********************************

	let vfecha_ant = pfechahoy - 3 units day;
	let vfecha = pfechahoy - 1 units month;
	let vfecha = mdy(month(vfecha),day(01),year(vfecha));
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '01')
        RETURNING P_COD_RET;

	set isolation to dirty read;

	select cliente,cuenta,decode(estatus , 1,'ENVIADO' ,'NO ENVIADO' )estatus, date(fecha_hora_registro)fecha_hora_registro
	from bdimnsj:mnsjr_trx_batch
	where id_mensaje = 'TC_COMPACS' and date(fecha_hora_registro) <= vfecha_ant and  date(fecha_hora_registro) >= vfecha
	into temp batch;
		
	insert into batch 
	select cliente,cuenta,decode(estatus , 1,'ENVIADO' ,'NO ENVIADO' )estatus, date(fecha_hora_registro)fecha_hora_registro
	from bdimnsj:mnsjr_trx_batch_his
	where id_mensaje = 'TC_COMPACS' and date(fecha_hora_registro) <= vfecha_ant and  date(fecha_hora_registro) >= vfecha;
	
		create index idx_batch on batch(cliente,cuenta);   UPDATE STATISTICS medium FOR TABLE batch; 
	
			
	foreach 
		select bat.cuenta,bat.cliente,decode(c.flag_pago,1,'CUMPLIDO','NO CUMPLIDO'),c.fecha_compac,c.fecha_insert,c.plazo,c.importe,
		bat.fecha_hora_registro,bat.estatus 
		into pnumcredito,pnumcte,vstatus,pfechacompac,pfecha_venci,vplazo,pimporte,vfecha_envio,vstatus_envio
		from batch bat, bdicobranza:cb_compac_his c
		where c.empresa = '001' and bat.cuenta = c.numcuenta 
				and fecha_insert >=  vfecha + 2 units day and fecha_insert <= pfechahoy - 1 units day
		
		select pago_venc into vpago_venc
		from bdicobranza:cb_info_administrativa_his 
		where empresa = '001' and credito = pnumcredito	and num_campania = 15 and fecha_ejecucion = vfecha_envio;
		
		select mto_fin_ven_trasp into vpago_venc2 
		from bdicred:sd_maesdos where empresa = '001' and num_credito = pnumcredito; 
		
		-- SUMA DE LOS PAGOS DE LOS DÍAS ANTERIORES AL ENVI0(sc_movhis)  POR VENTANILLA, INTERNET y CHEQUES.
		SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0) INTO vmSuma1 
		FROM bdicred:sd_movhis 
		WHERE empresa = '001' and num_credito = pnumcredito and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1
			and fecha_mov >= pfechacompac and fecha_mov <= pfecha_venci  and reversado = 'N';	
			
		-- SUMA DE LOS PAGOS DE LOS DÍAS POSTERIOES AL ENVIO (sc_movhis)  POR VENTANILLA, INTERNET y CHEQUES.
		SELECT {+INDEX(bdicred:sd_movhis inx_movhis)} NVL(SUM(monto),0) INTO vmSuma2 
		FROM bdicred:sd_movhis 
		WHERE empresa = '001' and num_credito = pnumcredito and codigo_fun in ('033', '334', '335', '336', '337') and codigo_ref = 1
			and fecha_mov >= pfecha_venci - 2 units day and fecha_mov <= pfecha_venci and reversado = 'N';
			
		INSERT INTO convenios (numcte,status,fechacompac,fecha_venci,plazo,importe,mSuma1,mSuma2,pago_venc,pago_venc2,fecha_envio,status_envio)
		VALUES(pnumcte,vstatus,pfechacompac,pfecha_venci,vplazo,pimporte,vmSuma1,vmSuma2,vpago_venc,vpago_venc2,vfecha_envio,vstatus_envio);

	end foreach 
	
	--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
-- pruebas ruta*********************************
--let cruta = '/informix/eli/';
--**********************************************
	
	let cnombre = 'vencimiento_previo_convenio_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'.txt';
		let vsql = '';
		let cSql='';
		LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'archivo_convenios.unl' || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
		LET cSQL2 = " select * from convenios";
		LET cSQL3 = '">'||TRIM(cRuta)||'archivo_convenios.sql';
		LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
		System cSQL;
	
		LET vsql='chmod 777 '|| TRIM(cRuta)||'archivo_convenios.sql';
		System vsql;
		let vsql = '';
		let vsql= 'dbaccess bdicobranza ' || TRIM(cruta)||'archivo_convenios.sql';
		system vsql;
		let vsql ='';
		let vsql ='rm '|| TRIM(cruta)||'archivo_convenios.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' "||TRIM(cruta)||"archivo_convenios.unl >>"||TRIM(cruta)|| cnombre;		
		system vsql;
		let vsql ='rm '|| TRIM(cruta)||'archivo_convenios.unl ' ;
		system vsql; 
	 	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cproceso, cCod_ret, cMensaje, '03')
    RETURNING P_COD_RET;
	
end
RETURN P_COD_RET;
END PROCEDURE;