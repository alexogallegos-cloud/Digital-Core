CREATE PROCEDURE "informix".sp_cat_aumlincred_latinia()

RETURNING CHAR(6);

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE vempresa				CHAR(3);
DEFINE vproceso				CHAR(30);
DEFINE pusuario             CHAR(8);
DEFINE vnum_credito			CHAR(20);
DEFINE vtelefono			CHAR(10);
DEFINE vtarjeta				CHAR(20);
DEFINE vapellido_pat 		CHAR(30);
DEFINE vfecha				DATE;	
DEFINE vnumcte              CHAR(20);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE vdia				    DATE;
DEFINE vhora				CHAR(8);
DEFINE ctipocampania        CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE dFechaProcIni        DATE;
DEFINE dFechaProcHoy        DATE;
define sPaso				smallint;
define cNombreArchivo 		char(40);
define vregistros			decimal(18,2);
define vcontador			integer;
define vfechas				char(6);
define VlDescripcion    char(50); 
define vlValorAlfabetico char(50);

--SET DEBUG FILE TO "/informix/gpe/Pruebas_de_carta_por_prioridad/incrementos_latinia.out";
--TRACE ON;

--Inicializació® ¤e variables
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso				= '2085';
LET vempresa				= '001';
LET pusuario                = USER;
LET vnumcte                 = "";
LET vnum_credito			= "";
LET vtelefono				= "";
LET vtarjeta				= "";
LET vapellido_pat 			= "";
LET vfecha					= DATE(1);
LET cempresa                = "001";
LET cdelimitador            = "";
LET vdia				    = DATE(1);
LET vhora				    = "";
LET ctipocampania           = "";
LET cCod_RetIB              = "000000";
LET dFechaProcIni           = DATE(1);
LET dFechaProcHoy           = DATE(1);
let sPaso					=0;
let cNombreArchivo			='';
let vregistros				=0;
let vcontador 				=0;
let vfechas 				= '';
let VlDescripcion   = '';
let vlValorAlfabetico = '';


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02')
                Returning cCod_RetIB;
        RETURN cCod_ret;
	END EXCEPTION;

--Set debug file to 'aumlincred.out';
--trace on;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '01')
            Returning cCod_RetIB;

	
    SELECT fecha_hoy
        INTO  dFechaProcHoy
      FROM bdinteg:"informix".si_fechas
      WHERE empresa = '001';
--let dFechaProcHoy = '01-05-2012';------------------------------------------------------------------------PRUEBAS	
	let dFechaProcIni = date(dFechaProcHoy) - 1 units month;
	
   -- Valida que exista la informacion
    IF dFechaProcIni IS NULL OR dFechaProcHoy IS NULL THEN
        LET cCod_Ret=  '20013';
        SELECT descripcion INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen = 2 AND codigo_error = cCod_Ret;

        IF cMensaje IS NULL THEN
            LET cMensaje = "";
        END IF;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '02')
            Returning cCod_RetIB;
        Return cCod_Ret;
    END IF

	select valor_numerico into vregistros
	from bdicobranza:cb_param_campania
	where tipo_campania = 50 and num_parametro= 59; 
	
	SELECT limit vregistros a.numcte, cred.num_credito,SUBSTR(tel2.telefono,(LENGTH(tel2.telefono) + 1 - 10),10) telefono,
			substr(t.num_tarjeta,13,17) tarjeta, 
			CASE WHEN LENGTH(a.nombre1) <=  3 THEN TRIM(a.nombre1)||' '||TRIM(SUBSTR(a.nombre2,1,9 - LENGTH(a.nombre1))) ELSE
																					SUBSTR(a.nombre1,1,10) END nombre,
			d.fecha_insert,
			TRUNC((((d.lincred_sugerida - decode(d.lincred_actual,0,1, d.lincred_actual)) / d.lincred_actual)*100),2) porcentaje
	
	from bdicred:sd_maecred cred
    join bdicred:sd_bitacora_aumlincred d  on (cred.empresa = d.empresa and cred.num_credito = d.num_solicitud   
                                    and cred.numcte = d.numcte and d.status = 'AT') 
    join bdinteg:si_cliente a on (a.empresa = cred.empresa and a.numcte = cred.numcte) 
    join bdicred:sd_tarjeta t on (cred.empresa =t.empresa and cred.num_credito = t.num_credito 
                                    and t.tipo_tarjeta ='T'  and t.status_tar = 'A' 
                                    and t.secuencia = (select max(tar.secuencia) from bdicred:sd_tarjeta tar 
													where tar.empresa = cred.empresa  and tar.num_credito = cred.num_credito 
													and tar.tipo_tarjeta ='T' and tar.status_tar = 'A') ) 
    join bdinteg:si_telefonos_actual tel2 on (tel2.empresa = cred.empresa and tel2.numcte= cred.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V' and tel2.status_tel = 'A'
										and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual 
															where numcte = cred.numcte and tipo_tel = 2 and cofetel ='V' and status_tel = 'A'))
    join bdicred:sd_maesdos dos on (cred.num_credito = dos.num_credito ) 
    where cred.status_cred in ('AA','E1')  and (dos.monto_vencido + dos.mto_venc_trasp) = 0 and tel2.telefono is not null and tel2.telefono <> '' 
    and d.fecha_insert >= dFechaProcIni
    and d.fecha_insert < dFechaProcHoy
	into temp sd_temp_incrementos_latinia;
	
ForEach	
	
	select numcte, num_credito,telefono,tarjeta, nombre--, fecha_insert
	into vnumcte,vnum_credito, vtelefono, vtarjeta, vapellido_pat--, vfecha
	from sd_temp_incrementos_latinia
	order by porcentaje
	
	let vfecha = date(dFechaProcHoy) + 30 units day;
	let vfecha = mdy(month(vfecha),day(20),year(vfecha));
	let vfechas = lpad(day(vfecha),2,'0')||'-'|| decode (month(vfecha),01,'Ene',02,'Feb',03,'Mar',04,'Abr',05,'May',06,'Jun',
																   07,'Jul',08,'Ago',09,'Sep',10,'Oct',11,'Nov',12,'Dic');

	
	/*insert into bdicobranza:cb_administativa_latinia(num_campania,numcte,num_credito,telefono,tarjeta ,apellido_pat,fecha,fecha_insert)
    values (3,vnumcte,vnum_credito, vtelefono, vtarjeta, vapellido_pat, vfecha,today);*/
	call bdimnsj:"informix".sp_registra_evento (2, 'INCR_CRED' , vnumcte, vnum_credito,'', 2,
							vapellido_pat,vfechas,'','','',0,0,0,0,0, '', '')RETURNING cCod_ret;
	--let vcontador = vcontador + 1;
 
End ForEach;

  foreach
    select descripcion,  trim(valor_alfabetico)
      into VlDescripcion, vlValorAlfabetico
      from bdicred:sd_param_campania 
     where tipo_campania = 60  AND GRUPO_PARAMETRO = 'TELSMSFIJO'
	 and num_parametro in (1,2,3)
	 
	 select numcte,num_credito
	  into vnumcte,vnum_credito
	  from bdicred:sd_maecred
	 where num_credito = vlValorAlfabetico; --in ('600109267697','600030001041','600109267432')
	 
	 select CASE WHEN LENGTH(a.nombre1) <=  3 THEN TRIM(a.nombre1)||' '||TRIM(SUBSTR(a.nombre2,1,9 - LENGTH(a.nombre1))) ELSE
																					SUBSTR(a.nombre1,1,10) END nombre into vapellido_pat
    from bdinteg:si_cliente a where numcte = vnumcte;  
				
    call bdimnsj:"informix".sp_registra_evento (2, 'INCR_CRED' , vnumcte, vnum_credito,'', 2,
							vapellido_pat,vfechas,'','','',0,0,0,0,0, '', '')RETURNING cCod_ret;

  end foreach;
	
	/*if (vcontador >= 1) then 
	CALL bdicobranza:"informix".sp_sms_reporte(3,0,0,0) RETURNING 	cCod_ret;*/
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, cCod_ret, cMensaje, '03')
        Returning cCod_RetIB;
	--end if;
	
	RETURN cCod_ret;

END;
END PROCEDURE;