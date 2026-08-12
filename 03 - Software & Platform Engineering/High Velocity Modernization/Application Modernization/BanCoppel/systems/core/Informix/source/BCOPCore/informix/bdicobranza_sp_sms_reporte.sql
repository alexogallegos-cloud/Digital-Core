CREATE PROCEDURE "informix".sp_sms_reporte(pcampania smallint,ppago_venc smallint,ptipo smallint,pnum smallint)
returning char (6);
-- execute PROCEDURE "informix".sp_sms_reporte(13,0,51,10)
------------------------------------------------------------------------------------
--Maria Elizabeth Anzures Ibarguen
--05-24-2012
--crea archivo con clientes a enviar mensajes a celular 


----DATOS QUE VAN EN LA TABLA

DEFINE	vgsm			char(20);
DEFINE	vdiferido	char(12);
DEFINE	vcaducidad	char(12);
DEFINE	vtexto  		char(160);
DEFINE	vetiqueta	char(50);
DEFINE	vplantilla	char(10);
DEFINE	vvariables_pantilla	char(2000);
DEFINE vtarjeta char(4);
define valor1	char(2);
define valor2	char(2);
define valor3	decimal(18,2);
define valor4	decimal(18,2);
define valor5	char(10);
define vnum_credito char(20);
define vpago_venc	smallint;
define vapell_paterno char(30);
define vnombre char(100);
define vvalor_numerico integer;
define vnumcte 			char(20);
define vnum_registros	integer;

---VARIABLES PARA CAPTURAR ERRORES
DEFINE SQL_ERR                INTEGER;
DEFINE ISAM_ERR               INTEGER;
DEFINE ERROR_INFO             VARCHAR(80);
DEFINE P_COD_RET              VARCHAR(5);
DEFINE P_MENSAJE              VARCHAR(80);
DEFINE vproceso				  CHAR (4);
DEFINE cMensaje				  CHAR(80);

---VARIABLES PARA QUERYS
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE vsql					CHAR(2204);
DEFINE icontador 			  SMALLINT;
DEFINE sPaso integer;
DEFINE cruta                CHAR(100);
DEFINE cdelimitador         CHAR(1);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnombre				CHAR(100);
define vfecha				DATE;
define vnum_total			integer;
define vfechaInfo			date;
define vcontar			integer;
define x 				integer;
define vnum				integer;
define vdia15			smallint;
define vtipo			char(10);
define vregistrostotal  integer;
define vregistros1		integer;
define vnumcte_param	char(20);


BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		 CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '02')RETURNING P_COD_RET;	
	RETURN P_COD_RET;
    END EXCEPTION;

----INICIALIZAN VARIABLES QUE VAN EN LA TABLA

LET	vgsm			= '';
LET	vdiferido	= '';
LET	vcaducidad	= '';
LET	vtexto  		= '';
LET	vetiqueta	= '';
LET	vplantilla	= '';
LET	vvariables_pantilla	= '';
LET vtarjeta = '';
LET valor1	= '';
LET valor2	= '';
LET valor3	= 0;
LET valor4	= 0;
LET valor5	= '';
let vnum_credito = '';
let vpago_venc = 0;
let vvalor_numerico = 0;
let vnumcte 		='';

---INICIALIZAN VARIABLES PARA QUERYS
LET  cSql		="";
LET cSQL1		= "";
LET cSQL2		= "";
LET cSQL3		= "";
let vsql		= '';
Let P_cod_ret	= "00000";
LET icontador 	= 0;
LET vproceso	='2090';
LET cMensaje    = 'PROCESO EXITOSO';
let sPaso 		=0;
let cruta       ='';
let cdelimitador 	 ='';
let cnomarchivo 	 ='';
let cnomarchivo1 	 ='';
let cnombre		='';
let vfecha		= date(1);
let vapell_paterno 	 ='';
let vnombre 	= '';
let vnum_total 	=0;
let vfechaInfo 	= date(1);
let vcontar		= 0;
let vnum_registros 	 = 0;
let vdia15		=0;
let vtipo		= '';
let vregistrostotal  = 0;
let vregistros1		 = 0;
let vnumcte_param 	 = '';



--  Set debug file to 'sms.out';
--  trace on;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01')RETURNING P_COD_RET;	
	
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'sms_latinia';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sms_latinia;
            END IF;

	create table sms_latinia
        (
        id			serial not null,
		gsm			char(20),
		diferido	char(12),
		caducidad	char(12),
		texto  		char(160),
		etiqueta	char(50),
		plantilla	char(50),
		variables_pantilla	char(2000)
		) ;

	
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

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01')RETURNING P_COD_RET;	
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

         CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01')RETURNING P_COD_RET;	
	     Return P_COD_RET;
	END IF;
	
	select fecha_hoy into vfecha from bdicred:sd_fechas where empresa = '001';
	
    set isolation to dirty read;
    set lock mode to wait 3;
	
	select valor into vnumcte_param from bdicobranza:cb_param where cod_param  = 57;
	
	select valor_numerico ,valor_alfabetico
	into vvalor_numerico,vplantilla
	from bdicobranza:cb_param_campania
	where tipo_campania = ptipo
	and grupo_parametro = 'LATINIA'
	and num_parametro = pnum;
	
	select  max(fecha_ejecucion) into vfechaInfo 
	from cb_info_administrativa 
	where num_campania = pcampania;
	
if (pcampania  in (5,11) and vpago_venc <> 0) then
	
	---- consulta para saber cuantos registros faltan por buscar al mes	
	select count(*) into vregistros1
		from bdicobranza:cb_info_administrativa_his
		where num_campania = pcampania
		and fecha_ejecucion >= mdy(month(vfecha),day(01),year(vfecha));

	let vregistrostotal = vvalor_numerico - vregistros1;
	if (vregistrostotal > 0) then
	FOREACH
	
		select limit vregistrostotal credito,t_celular,pago_venc,cliente
		into vnum_credito,vgsm,vpago_venc,vnumcte
		from bdicobranza:cb_info_administrativa
		where num_campania = pcampania
		and fecha_ejecucion = vfechaInfo
		and pago_venc = ppago_venc		
		
	if (vgsm <> '') then
		
		select  day(fecha_pago)::char(2),month(fecha_pago)::char(2),round(pago_req_sms),/*round(sdo_total) , round(pago_min) ,*/trim(apell_paterno)
			into valor1,valor2,valor3, /*valor4,*/vapell_paterno
		from bdicobranza:cb_info_administrativa a 
		where credito = vnum_credito
			and num_campania = pcampania
			and fecha_ejecucion = vfechaInfo
			and pago_venc = ppago_venc;
		
		if (vnumcte in (vnumcte_param)) then
			select  day(fecha_pago)::char(2),month(fecha_pago)::char(2),round(pago_req_sms),/*round(sdo_total) , round(pago_min),*/trim(apell_paterno)
			into valor1,valor2,valor3, /*valor4,*/vapell_paterno
			from bdicobranza:cb_info_administrativa a 
			where cliente = vnumcte
				and num_campania = pcampania
				and fecha_ejecucion = vfechaInfo
				and pago_venc = ppago_venc;
		end if;
	
	
	if (pcampania=5 and vpago_venc = 1 ) then 
	let vvariables_pantilla =  'apell_pat='||trim(vapell_paterno)||'##'||'importe1='||valor3; end if;

	if (pcampania=5 and vpago_venc = 2) then 
	let vvariables_pantilla =  'apell_pat='||trim(vapell_paterno)||'##'||'importe1='||valor3; end if;
		
	if (pcampania=11 and vpago_venc = 1) then 
	let vvariables_pantilla =  'apell_pat='||trim(vapell_paterno)||'##'||'importe1='||valor3; end if;
	
	if (pcampania=11 and vpago_venc = 2 ) then 
	let vvariables_pantilla =  'apell_pat='||trim(vapell_paterno)||'##'||'importe1='||valor3; end if;
	
	let vtipo = 'cobranza';
        INSERT INTO sms_latinia 
		(gsm,  plantilla, variables_pantilla )
	    VALUES (		
                        nvl ( replace ( replace( vgsm , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vplantilla , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vvariables_pantilla , '|' , ' ' ), '\' , ' ' ), ' ' ));

        IF icontador >= 1000 then
            update statistics medium for table sms_latinia;
			LET icontador=1;
		ELSE
			LET icontador=icontador+1;
		END IF;
	end if;
    End ForEach;
	end if;
end if;
if (pcampania in (16,17,12,14)) then
	
	---- consulta para saber cuantos registros faltan por buscar al mes	
	select count(*) into vregistros1
		from bdicobranza:cb_info_administrativa_his
		where num_campania = pcampania
		and fecha_ejecucion >= mdy(month(vfecha),day(01),year(vfecha));

	let vregistrostotal = vvalor_numerico - vregistros1;
	if (vregistrostotal > 0) then

	FOREACH
	
		select limit vregistrostotal credito,t_celular,pago_venc,cliente
		into vnum_credito,vgsm,vpago_venc,vnumcte
		from bdicobranza:cb_info_administrativa
		where num_campania = pcampania
		and fecha_ejecucion = vfechaInfo
		and pago_venc = ppago_venc
		
		
	if (vgsm <> '') then
		
		select  day(fecha_pago)::char(2),month(fecha_pago)::char(2),round(pago_req_sms),/*round(sdo_total) , round(pago_min) ,*/trim(apell_paterno)
			into valor1,valor2,valor3, /*valor4,*/vapell_paterno
		from bdicobranza:cb_info_administrativa a 
		where credito = vnum_credito
			and num_campania = pcampania
			and fecha_ejecucion = vfechaInfo
			and pago_venc = ppago_venc;
		
		if (vnumcte in (vnumcte_param)) then
			select  day(fecha_pago)::char(2),month(fecha_pago)::char(2),round(pago_req_sms),/*round(sdo_total) , round(pago_min) ,*/trim(apell_paterno)
			into valor1,valor2,valor3, /*valor4,*/vapell_paterno
			from bdicobranza:cb_info_administrativa a 
			where cliente = vnumcte
				and num_campania = pcampania
				and fecha_ejecucion = vfechaInfo
				and pago_venc = ppago_venc;
		end if;
	
	if (pcampania=16 ) then 
	let vvariables_pantilla ='apell_pat='||trim(vapell_paterno); end if;
	
	if (pcampania=17 ) then 
	let vvariables_pantilla =  'apell_pat='||trim(vapell_paterno)||'##'||'string1='||trim(valor1); end if;
	
	if (pcampania=12 ) then 
	let vvariables_pantilla = 'apell_pat='||trim(vapell_paterno)||'##'||'string1 ='||trim(valor1)||'##'||'importe1 ='||valor3;  end if;
	
	if (pcampania=14 and vpago_venc = 1 ) then 
	let vvariables_pantilla =  'apell_pat='||trim(vapell_paterno)||'##'||'importe1='||valor3; end if;
	
	if (pcampania=14 and vpago_venc = 2 ) then 
	let vvariables_pantilla =  'apell_pat='||trim(vapell_paterno)||'##'||'importe1='||valor3; end if;
	
	let vtipo = 'cobranza';

        INSERT INTO sms_latinia 
		(gsm,  plantilla, variables_pantilla )
	    VALUES (		
                        nvl ( replace ( replace( vgsm , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vplantilla , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vvariables_pantilla , '|' , ' ' ), '\' , ' ' ), ' ' ));

        IF icontador >= 1000 then
            update statistics medium for table sms_latinia;
			LET icontador=1;
		ELSE
			LET icontador=icontador+1;
		END IF;
	end if;
    End ForEach;
	end if;
end if;
if (pcampania in (18,9,13)) then
	
	---- consulta para saber cuantos registros faltan por buscar al mes	
	select count(*) into vregistros1
		from bdicobranza:cb_info_administrativa_his
		where num_campania = pcampania
		and fecha_ejecucion >= mdy(month(vfecha),day(01),year(vfecha));

	let vregistrostotal = vvalor_numerico - vregistros1;
	if (vregistrostotal > 0) then
	FOREACH
	
		select  limit vregistrostotal credito,t_celular,pago_venc,cliente
		into vnum_credito,vgsm,vpago_venc,vnumcte
		from bdicobranza:cb_info_administrativa
		where num_campania = pcampania
		and fecha_ejecucion = vfechaInfo
					
	if (vgsm <> '') then
		
		select  day(fecha_pago)::char(2),month(fecha_pago)::char(2),round(pago_req_sms),/*round(sdo_total) , round(pago_min),*/trim(apell_paterno)
			into valor1,valor2,valor3, /*valor4,*/vapell_paterno
		from bdicobranza:cb_info_administrativa a 
		where credito = vnum_credito
			and num_campania = pcampania
			and fecha_ejecucion = vfechaInfo;
		
			if (vnumcte in (vnumcte_param)) then
			select  day(fecha_pago)::char(2),month(fecha_pago)::char(2),round(pago_req_sms),/*round(sdo_total) , round(pago_min) ,*/trim(apell_paterno)
			into valor1,valor2,valor3, /*valor4,*/vapell_paterno
			from bdicobranza:cb_info_administrativa a 
			where cliente = vnumcte
				and num_campania = pcampania
				and fecha_ejecucion = vfechaInfo
				and pago_venc = ppago_venc;
		end if;
	
	if (pcampania=18 ) then 
	let vvariables_pantilla =  'apell_pat='||trim(vapell_paterno)||'##'||'importe1='||valor3; end if;
		
	if (pcampania=9 ) then 
	let vvariables_pantilla = 'apell_pat='||trim(vapell_paterno)||'##'||'string1='||trim(valor1)||'##'||'string2='||trim(valor2)||'##'||'importe1='||valor3;  end if;
	
	if (pcampania=13 ) then 
	let vvariables_pantilla = 'apell_pat='||trim(vapell_paterno)||'##'||'string1='||trim(valor1)||'##'||'string2='||trim(valor2)||'##'||'importe1='||valor3;  end if;
	
	let vtipo = 'cobranza';
	
        INSERT INTO sms_latinia 
		(gsm,  plantilla, variables_pantilla )
	    VALUES (		
                        nvl ( replace ( replace( vgsm , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vplantilla , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vvariables_pantilla , '|' , ' ' ), '\' , ' ' ), ' ' ));

        IF icontador >= 1000 then
            update statistics medium for table sms_latinia;
			LET icontador=1;
		ELSE
			LET icontador=icontador+1;
		END IF;
	end if;
    End ForEach;
	end if;
end if;

if (pcampania = 1 and ppago_venc = 0 and ptipo = 0 and pnum =  0) then

	select trim(valor_alfabetico) into vplantilla
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 57;
	select valor_numerico into vdia15
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 66;
	
	FOREACH

		select telefono,trim(apellido_pat),trim(day(fecha)::char(2)),
		decode (month(fecha), 01,'Enero',02,'Febrero',03,'Marzo',04,'Abril',05,'Mayo',06,'Junio',07,'Julio',08,'Agosto',09,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre')
		into vgsm,vapell_paterno,valor1,valor5
		from  bdicobranza:cb_administativa_latinia
		where num_campania = pcampania and fecha = date(vfecha) + vdia15 units day
		
	if (vgsm <> '') then
	
		let vvariables_pantilla =  'nombre='||trim(vapell_paterno)||'##'||'fecha='||trim(valor1)||'-'||valor5; 
		let vtipo = 'productos';
		
        INSERT INTO sms_latinia 
		(gsm,  plantilla, variables_pantilla )
	    VALUES (		
                        nvl ( replace ( replace( vgsm , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vplantilla , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vvariables_pantilla , '|' , ' ' ), '\' , ' ' ), ' ' ));

        IF icontador >= 1000 then
            update statistics medium for table sms_latinia;
			LET icontador=1;
		ELSE
			LET icontador=icontador+1;
		END IF;
	end if;
    End ForEach;
end if;
if (pcampania = 2 and ppago_venc = 0 and ptipo = 0 and pnum =  0) then

	select trim(valor_alfabetico) into vplantilla
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 58;
	
	FOREACH
	
		select a.telefono,trim(a.apellido_pat)
		into vgsm,vapell_paterno
		from  bdicobranza:cb_administativa_latinia a
		join bdicred:sd_maesdos  a1 on (a1.empresa = '001' and a.num_credito = a1.num_credito )
		where num_campania = pcampania and fecha_insert = today order by a1.sdo_cap_insoluto
		
	if (vgsm <> '') then
	
		let vvariables_pantilla =  'nombre='||trim(vapell_paterno); 
		let vtipo = 'productos';
		
        INSERT INTO sms_latinia 
		(gsm,  plantilla, variables_pantilla )
	    VALUES (		
                        nvl ( replace ( replace( vgsm , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vplantilla , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vvariables_pantilla , '|' , ' ' ), '\' , ' ' ), ' ' ));

        IF icontador >= 1000 then
            update statistics medium for table sms_latinia;
			LET icontador=1;
		ELSE
			LET icontador=icontador+1;
		END IF;
	end if;
    End ForEach;
end if;
if (pcampania = 3 and ppago_venc = 0 and ptipo = 0 and pnum =  0) then

	select trim(valor_alfabetico) into vplantilla
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 59;
	
	FOREACH
	
		select telefono,trim(apellido_pat),day(fecha)::char(2),
		decode (month(fecha), 01,'Enero',02,'Febrero',03,'Marzo',04,'Abril',05,'Mayo',06,'Junio',07,'Julio',08,'Agosto',09,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre')
		into vgsm,vapell_paterno,valor1,valor5
		from  bdicobranza:cb_administativa_latinia 
		where num_campania = pcampania and fecha_insert = today

	if (vgsm <> '') then
	
		let vvariables_pantilla =  'nombre='||trim(vapell_paterno)||'##'||'fecha='||trim(valor1)||'-'||valor5;  		
		let vtipo = 'productos';
		
        INSERT INTO sms_latinia		
		(gsm,  plantilla, variables_pantilla )
	    VALUES (		
                        nvl ( replace ( replace( vgsm , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vplantilla , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vvariables_pantilla , '|' , ' ' ), '\' , ' ' ), ' ' ));

        IF icontador >= 1000 then
            update statistics medium for table sms_latinia;
			LET icontador=1;
		ELSE
			LET icontador=icontador+1;
		END IF;
	end if;
    End ForEach;
end if;
if (pcampania = 4 and ppago_venc = 0 and ptipo = 0 and pnum =  0) then

	select trim(valor_alfabetico) into vplantilla
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 60;
	
	FOREACH
	
		select apellido_pat,telefono,trim(tarjeta),day(fecha)::char(2),
		decode (month(fecha), 01,'Enero',02,'Febrero',03,'Marzo',04,'Abril',05,'Mayo',06,'Junio',07,'Julio',08,'Agosto',09,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre')
		into vapell_paterno,vgsm,vtarjeta,valor1,valor5
		from  bdicobranza:cb_administativa_latinia 
		where num_campania = pcampania and fecha_insert = today

	if (vgsm <> '') then
	
		let vvariables_pantilla =  'nombre='||trim(vapell_paterno)||'##'||'tarjeta='||trim(vtarjeta)||'##'||'fecha='||trim(valor1)||'-'||valor5;  		
		let vtipo = 'productos';

        INSERT INTO sms_latinia		
		(gsm,  plantilla, variables_pantilla )
	    VALUES (		
                        nvl ( replace ( replace( vgsm , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vplantilla , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vvariables_pantilla , '|' , ' ' ), '\' , ' ' ), ' ' ));

        IF icontador >= 1000 then
            update statistics medium for table sms_latinia;
			LET icontador=1;
		ELSE
			LET icontador=icontador+1;
		END IF;
	end if;
    End ForEach;
end if;
if (pcampania = 5 and ppago_venc = 0 and ptipo = 0 and pnum =  0) then

	select trim(valor_alfabetico) into vplantilla
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 62;
	
	FOREACH
	
		select apellido_pat,telefono,trim(tarjeta),day(fecha)::char(2),
		decode (month(fecha), 01,'Enero',02,'Febrero',03,'Marzo',04,'Abril',05,'Mayo',06,'Junio',07,'Julio',08,'Agosto',09,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre')
		into vapell_paterno,vgsm,vtarjeta,valor1,valor5
		from  bdicobranza:cb_administativa_latinia 
		where num_campania = pcampania and fecha_insert = today

	if (vgsm <> '') then
	
		let vvariables_pantilla =  'nombre='||trim(vapell_paterno)||'##'||'tarjeta='||trim(vtarjeta)||'##'||'fecha='||trim(valor1)||'-'||valor5;  		
		let vtipo = 'productos';
		
        INSERT INTO sms_latinia		
		(gsm,  plantilla, variables_pantilla )
	    VALUES (		
                        nvl ( replace ( replace( vgsm , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vplantilla , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vvariables_pantilla , '|' , ' ' ), '\' , ' ' ), ' ' ));

        IF icontador >= 1000 then
            update statistics medium for table sms_latinia;
			LET icontador=1;
		ELSE
			LET icontador=icontador+1;
		END IF;
	end if;
    End ForEach;
end if;
if (pcampania = 6 and ppago_venc = 0 and ptipo = 0 and pnum =  0) then

	select trim(valor_alfabetico) into vplantilla
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 67;
	
	FOREACH
	
		select telefono,apellido_pat,day(fecha)::char(2),
		decode (month(fecha), 01,'Enero',02,'Febrero',03,'Marzo',04,'Abril',05,'Mayo',06,'Junio',07,'Julio',08,'Agosto',09,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre')
		into vgsm,vapell_paterno,valor1,valor5
		from  bdicobranza:cb_administativa_latinia 
		where num_campania = pcampania and fecha_insert = today

	if (vgsm <> '') then
	
		let vvariables_pantilla =  'nombre='||trim(vapell_paterno)||'##'||'fecha='||trim(valor1)||'-'||valor5;  		
		let vtipo = 'productos';
		
		INSERT INTO sms_latinia		
		(gsm,  plantilla, variables_pantilla )
	    VALUES (		
                        nvl ( replace ( replace( vgsm , '|' , ' ' ), '\' , ' ' ), ' ' ),
						nvl ( replace ( replace( vplantilla , '|' , ' ' ), '\' , ' ' ), ' ' ),
                        nvl ( replace ( replace( vvariables_pantilla , '|' , ' ' ), '\' , ' ' ), ' ' ));

        IF icontador >= 1000 then
            update statistics medium for table sms_latinia;
			LET icontador=1;
		ELSE
			LET icontador=icontador+1;
		END IF;
	end if;
    End ForEach;
end if;
--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
	select valor_numerico into vnum_registros
	from bdicobranza:cb_param_campania where tipo_campania = 1 and num_parametro = 53;
--let vnum_registros= 100; ----------------------PRUEBAS
	
	let cnombre = 'sms_'||trim(vplantilla)||'_'||day(today)||LPAD (MONTH(today),2,"0")||year(today)||'_';	
	select count(*),count(*) into vnum_total, vcontar
	from sms_latinia;
	
	if(vnum_total > 0) then
	
		if (vcontar <= vnum_registros) then
			LET vcontar = 1;
		else
			LET vcontar = vcontar / vnum_registros;
			let vcontar = trunc(vcontar)+1;
		end if;
		
		LET vnum = 0;
		
		for x in (1 to vcontar )
		
			if ((vnum_total - vnum) <= vnum_registros) then
				let vnum_registros = vnum_total - vnum;
			end if;
					
		let vsql = ' echo "BANCOPPEL|"'||trim(vtipo)||'"||sms3|"'||lower(trim(vplantilla))||'"|"'||vnum_registros||' >'|| TRIM(cruta)||TRIM(cnombre)||x||'.ready';		
		system vsql; 
		let vsql = ' echo "<EOF>">'||TRIM(cruta)||'sms_archivo_fin.txt';
		system vsql;
		let vsql = '';
		let cSql=''; 
		LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || 'archivo_sms.unl' || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
		LET cSQL2 = " SELECT skip "||vnum||" LIMIT "||vnum_registros||" * from sms_latinia ";
		LET cSQL3 = '">'||TRIM(cRuta)||'archivo_sms.sql';
		LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
		System cSQL;
		
		let vnum = vnum + vnum_registros;
		
		LET vsql='chmod 777 '|| TRIM(cRuta)||'archivo_sms.sql';
		System vsql;
		let vsql = '';
		let vsql= 'dbaccess bdicobranza ' || TRIM(cruta)||'archivo_sms.sql';
		system vsql;
		let vsql ='';
		let vsql ='rm '|| TRIM(cruta)||'archivo_sms.sql';
		system vsql;
		let vsql ='';
		let vsql = "sed 's/|$//g' "||TRIM(cruta)||"archivo_sms.unl >>"||TRIM(cruta)||TRIM(cnombre)||x||'.ready';		
		system vsql;
		let vsql = "sed 's/|$//g' "||TRIM(cruta)||"sms_archivo_fin.txt >>"||TRIM(cruta)||TRIM(cnombre)||x||'.ready';		
		system vsql;
		let vsql ='rm '|| TRIM(cruta)||'archivo_sms.unl ' ||TRIM(cruta)||'sms_archivo_fin.txt';
		system vsql; 
		
		end for
	end if;		
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03') RETURNING P_COD_RET;
    RETURN P_COD_RET;

end;
end procedure;