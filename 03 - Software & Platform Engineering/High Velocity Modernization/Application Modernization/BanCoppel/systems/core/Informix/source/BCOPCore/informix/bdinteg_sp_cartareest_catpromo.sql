CREATE PROCEDURE "informix".sp_cartareest_catpromo(pEmpresa char(3))
returning
          char(06) as resultado,
          char(80) as mensaje;

-- MAHR Agosto 2012. Se parametriza ruta destino: /resplogifx/archivoscartera/
--GEV Junio 2013 Se unen los archivos enviados al CAT en uno solo, se hace la union del nombre en un solo campo,
--se unen los telefonos,se acote a cuentas con atraso entre 3 a 5 meses de atraso y adeudo mayor a $2,000 pesos. 
--AAME INC 27 067 Se modifica el tipo de dato de smallint a entero del campo vregistros debido a que el parametro 
--de registros aumento su valor.
define Sql_error Integer;
define cSql char(20000);
define cCodRet char(06);
define iCodRet integer;
define cMensajeRet CHAR(80);
define dHoy date;
define dFCorte date;
define vDia  char(2);
define vMes  char(2);
define vAnio char(4);
define cNombreArchivo char(50);
define cTasa decimal (9,6);
define cFTasa decimal (9,6);
Define cRutaArch CHAR (50);
define sPaso	smallint;
define iTotalRegistros   integer;
define vregistros	integer; --smallint
define cProceso		char(4);
define vvalor integer;
define vcontador integer;
define cNumCte char(20);
define cNumCred	char(20);				
define vnombre char(10);
define viPrioridad      integer;
define cdelimitador         CHAR(1);
define VlDescripcion    char(50); 
define vlValorAlfa      char(50);
define vlValorAlfabetico char(50); 
define vlCteDuplicado char(20);
define viMinVencdo  Integer; 
define viMaxVencdo  Integer; 
define ctmppaso char(50);

let cCodRet = '000000';
let iCodRet = 0;
let cMensajeRet = 'El proceso de REPORTES DE REESTRUCTURAS se realizó correctamente';
let sPaso = 0;
let cProceso = '0101';
let vcontador = 0;
let cNumCte = '';
let cNumCred = '';				
let vnombre = '';
LET viPrioridad     = 0;
let cdelimitador            = "";
let VlDescripcion   = '';
let vlValorAlfabetico = '';
let vlCteDuplicado = '';
let viMinVencdo = 0; 
let viMaxVencdo = 0; 
let ctmppaso = '0';

BEGIN
    on exception set iCodRet, Sql_error, cMensajeRet
            if iCodRet <> 0 then
--            execute procedure sp_obtener_hora() into vhora_fin;
            let cCodRet = iCodRet;
           -- let cMensajeRet ='Error al generar los REPORTES DE REESTRUCTURAS ';
			  CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, cMensajeRet || ctmppaso, '02')
				RETURNING cCodRet;
            return cCodRet,cMensajeRet ;
        end if;
    end exception;

--Set debug file to "/home/sysaccapp4/cobranza/029/sp_cartareest_catpromo.out";
--Trace on;

	let dHoy  = '';
	let vDia  = '';
	let vMes  = '';
	let vAnio = '';
	let cNombreArchivo = '';

	let dHoy  = date((Select fecha_hoy from bdicred:sd_fechas WHERE empresa = '001')) ;
	let dFCorte = date((Select fecha_ant from bdicred:sd_fechas WHERE empresa = '001')) ;
	let vDia = lpad(day(dHoy),2,'0');
	let vMes = lpad(month(dHoy),2,'0');
	let vAnio = lpad(year(dHoy),4,'0');

	Let cTasa = 1+.754;
	Let cFTasa = 0;
	Let  cSql = '';
	Let iTotalRegistros = 0;
	let vregistros = 0;
	let vvalor = 0;
	/*
	select a.valor
	  into vlvalor
	from bdinteg:si_fechavalor a
	where a.empresa = '001'
	  and a.tasa='CRDREEST'
	  and a.fecha = (SELECT MAX(r.fecha)
					 FROM bdinteg:si_fechavalor r
					WHERE r.empresa = '001' AND r.tasa = a.tasa);
	*/
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, cMensajeRet, '01')
	RETURNING cCodRet;

	SET ISOLATION TO dirty READ;
	SET LOCK MODE TO WAIT 3;

	SELECT valor INTO cRutaArch FROM bdinteg:"informix".si_param WHERE cod_param = 137;

	--LET cRutaArch = '/home/sysaccapp4/cobranza/029/archivoscartera/'; ---  QUITAR JAHJ

	SELECT valor_alfabetico INTO cdelimitador FROM bdicred:"informix".sd_param_campania WHERE empresa = pempresa
			AND tipo_campania = 61 AND grupo_parametro = 'ARCHIVOSEP' AND num_parametro = 336;

	LET cdelimitador = TRIM(cdelimitador);

	BEGIN; 
		truncate table bdinteg:"informix".si_carta_reestructura; 
	COMMIT;


-----TABLA--------------
	SELECT 
		COUNT(tabid)INTO sPaso 	
		FROM systables 
		WHERE tabname= 'sd_temp_invitacion_reest';

	IF NVL(sPaso,0) > 0 THEN
		DROP TABLE sd_temp_invitacion_reest;
	END IF;
			
	let ctmppaso = '01';

	CREATE TABLE sd_temp_invitacion_reest
	(
		tipo_promocion char(3),
		tipo_logica smallint,
		fecha date,
		num_credito1 char(20),
		sucursal char(4),
		numcte1 char(20),
		ult_4dig char(4),
		status smallint,
		prioridad integer,--smallint,--serial,
		apell_p char(30),
		apell_m char(30),
		nombre1 char(30),
		nombre2 char(30),
		sexo char(2),
		estado_civil char(2),
		correo char(60),
		estado char(30),
		municipio char(30),
		num_credito3 char(20),
		numcte char(20),
		meses_vencidos smallint,
		monto_vencido decimal(18,2),
		plazo6 decimal(18,2),
		plazo12 decimal(18,2),
		plazo18 decimal(18,2),
		plazo24 decimal(18,2),
		plazo36 decimal(18,2),
		monto_bonificacion decimal(18,2),
		monto_total decimal(18,2),
		pago_minimo decimal(18,2),
		telefono1            CHAR(13),
		telefono2            CHAR(13),
		telefono3            CHAR(13),
		telefono4            CHAR(13),
		extension            CHAR(05));
    create index ix_tmp_invrest on sd_temp_invitacion_reest (numcte1, num_credito1);

-----------------------------------------
	select valor_numerico into vregistros
	from bdicobranza:cb_param_campania
	where tipo_campania = 50 and num_parametro= 51;

	-- Obtiene los parametros que indican el min y maximo de vencidos para reestructuras. Se cambia de (3 a 5) a  (2 a 5)
	SELECT valor::INTEGER INTO viMinVencdo FROM bdicred:sd_param WHERE empresa = '001' AND cod_param = '111';
	SELECT valor::INTEGER INTO viMaxVencdo FROM bdicred:sd_param WHERE empresa = '001' AND cod_param = '169';


--from bdicred:sd_maecred a ,bdinteg:si_cliente c, bdicred:sd_maesdos a1  , bdinteg:si_direcciones_actual d, bdicred:sd_tarjeta b ,

	select a.numcte, a.sucursal , a1.*
	 from bdicred:sd_maecred a , bdicred:sd_maesdos a1
	--bdinteg:si_telefonos_actual tel
	where a.empresa = '001'  
		and a.empresa = a1.empresa
		and a.num_credito = a1.num_credito
		and a.num_producto in ('6001')
		--and tel.numcte = a.numcte
		--and a.status_cred = 'BT'
		--IFRS Se contempla el estatus por Etapa y el Act para los vencidos
		and a.status_cred IN ('BT','E2','E3')
		and a1.sdo_cap_insoluto >= 2000
		and a.campo_trab3 = ''
		--and a1.mto_fin_ven_trasp between 3 and 5
		and a1.mto_fin_ven_trasp between viMinVencdo and viMaxVencdo -- mahr Cambio de meses vencidos de (3 a 5) a (2 a 5)
		--and tel.contacto = 1
		into temp CreditoTmp with no log;

	create index ix_CreditoTemp on  CreditoTmp (numcte) ONLINE;
	update statistics medium for table CreditoTmp;

    FOREACH 
      SELECT 
		numcte into vlCteDuplicado
		from CreditoTmp
		group by numcte
		having count(*) >1

		delete from CreditoTmp 
			where numcte = vlCteDuplicado and sdo_cap_insoluto = (select max(sdo_cap_insoluto) 
																	from CreditoTmp 
																	where numcte = vlCteDuplicado);
    END FOREACH;

	select  dir.* 
		from bdinteg:si_direcciones_actual dir, CreditoTmp cred 
		where dir.numcte = cred.numcte and dir.tipo_dir = 1
		into temp TempDirecciones with no log;
	
	create index ix_Direcciones on  TempDirecciones (numcte, tipo_dir) ONLINE;
	update statistics medium for table TempDirecciones;

--IFR Se contempla el capital_status 6 en vencidos
	select
	   dfCorte fecha,
	   a1.numcte, -- numero de cliente
	   a1.num_credito, -- numero de credito
	   b.num_tarjeta, -- numero de tarjeta
	   a1.sucursal, --Sucursal
	   --d.telefono1,
	   --d.telefono2,
	   --d.telefono3,
	   --d.extension,
	   tel1.telefono  telefono1,
	   tel2.telefono  telefono2,
	   tel3.telefono  telefono3,
	   tel4.telefono  telefono4,
	   tel3.extension extension,
	   a1.mto_fin_ven_trasp,
	   --trim(c.apell_paterno)||' '||trim(c.apell_materno)||' '||trim(c.nombre1)||' '||trim(c.nombre2) nombre,
	   Trim(c.nombre1) nombre1,
	   Trim(c.nombre2) nombre2,
	   Trim(c.apell_paterno) apell_paterno,
	   Trim(c.apell_materno) apell_materno,  -- nombre cliente
	   trim(e.nombrecalle) nombrecalle,
	   Trim(d.numeroextcalle) numeroextcalle,
	   trim(replace(d.numerointcalle, '|','')) numerointcalle, -- direccion CN
	   f.nombrezona,  -- direccion_col
	   g.nombreciudad,   -- direccion_del
	   h.nombre,  -- edo_cd
	   d.cod_postal,  -- codigo_postal
	   d.entre_calles,  --entre_calles
	   d.observaciones ,  --observaciones
	   LPAD(d.numerociudad ,4,'0') numerociudad,
	   LPAD(f.centro,6,'0') centro,
	   LPAD(f.jefegrupozona,8,'0') jefegrupozona,
	   LPAD(f.supervisorzona,8,'0') supervisorzona,
	   LPAD(d.numerocolonia,4,'0') numerocolonia,
	   LPAD(d.numerocalle,6,'0') numerocalle,
	   LPAD(TRIM(d.numeroextcalle),5,'0')numeroextccalle  ,
	   monto_financiado  +
	   (select sum(interes_debe - interes_pagado + iva_debe - iva_pagado) from bdicred:sd_amortiza_credito where a1.empresa = empresa and a1.num_credito = num_credito and capital_status in ('2','7','6')) +
		case when(select sum(mora_provi_ordi + mora_provi_cope + mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag ) from bdicred:sd_amortiza_credito where empresa = '001' and a1.num_credito = num_credito and capital_status in ('2','7','6'))  > 0
				  then round((select sum(mora_provi_ordi + mora_provi_cope + mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag ) from bdicred:sd_amortiza_credito where empresa = '001' and a1.num_credito = num_credito and capital_status in ('2','7','6')) * (1+ i.iva),2)
			 else 0
		end  pago_minimo ,
		( round(( a1.sdo_cap_insoluto  + a1.sdo_retenido +
		 ( select sum ( NVL(interes_debe,0) - NVL(interes_pagado,0) + NVL(iva_debe,0) - NVL(iva_pagado,0)) from bdicred:sd_amortiza_credito where empresa = '001' and  num_credito = a1.num_credito and capital_status in ('2','7','6')) +
		 ( (select  SUM ( NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) +
														 NVL(mora_sdo_cope,0)   - NVL(mora_sdo_cope_pag,0) )
							from bdicred:sd_amortiza_credito
							where empresa = '001' and num_credito = a1.num_credito
							and capital_status in ('2','7','6') ) *(1+ i.iva)) )/6, 2)) Pago6 ,
		( round(( a1.sdo_cap_insoluto  + a1.sdo_retenido +
		 ( select sum ( NVL(interes_debe,0) - NVL(interes_pagado,0) + NVL(iva_debe,0) - NVL(iva_pagado,0)) from bdicred:sd_amortiza_credito where empresa = '001' and  num_credito = a1.num_credito and capital_status in ('2','7','6')) +
		 ( (select  SUM ( NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) +
														 NVL(mora_sdo_cope,0)   - NVL(mora_sdo_cope_pag,0) )
							from bdicred:sd_amortiza_credito
							where empresa = '001' and num_credito = a1.num_credito
							and capital_status in ('2','7','6') ) *(1+ i.iva)) )/12, 2)) Pago12 ,
		( round(( a1.sdo_cap_insoluto  + a1.sdo_retenido +
		 ( select sum ( NVL(interes_debe,0) - NVL(interes_pagado,0) + NVL(iva_debe,0) - NVL(iva_pagado,0)) from bdicred:sd_amortiza_credito where empresa = '001' and  num_credito = a1.num_credito and capital_status in ('2','7','6')) +
		 ( (select  SUM ( NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) +
														 NVL(mora_sdo_cope,0)   - NVL(mora_sdo_cope_pag,0) )
							from bdicred:sd_amortiza_credito
							where empresa = '001' and num_credito = a1.num_credito
							and capital_status in ('2','7','6') ) *(1+ i.iva)) )/18, 2)) Pago18 ,
		( round(( a1.sdo_cap_insoluto  + a1.sdo_retenido +
		 ( select sum ( NVL(interes_debe,0) - NVL(interes_pagado,0) + NVL(iva_debe,0) - NVL(iva_pagado,0)) from bdicred:sd_amortiza_credito where empresa = '001' and  num_credito = a1.num_credito and capital_status in ('2','7','6')) +
		 ( (select  SUM ( NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) +
														 NVL(mora_sdo_cope,0)   - NVL(mora_sdo_cope_pag,0) )
							from bdicred:sd_amortiza_credito
							where empresa = '001' and num_credito = a1.num_credito
							and capital_status in ('2','7','6') ) *(1+ i.iva)) )/24, 2)) Pago24 ,
		( round(( a1.sdo_cap_insoluto  + a1.sdo_retenido +
		 ( select sum ( NVL(interes_debe,0) - NVL(interes_pagado,0) + NVL(iva_debe,0) - NVL(iva_pagado,0)) from bdicred:sd_amortiza_credito where empresa = '001' and  num_credito = a1.num_credito and capital_status in ('2','7','6')) +
		 ( (select  SUM ( NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) +
														 NVL(mora_sdo_cope,0)   - NVL(mora_sdo_cope_pag,0) )
							from bdicred:sd_amortiza_credito
							where empresa = '001' and num_credito = a1.num_credito
							and capital_status in ('2','7','6') ) *(1+ i.iva)) )/36, 2)) Pago36 ,

		case when (select sum(mora_provi_cope + mora_sdo_cope - mora_sdo_cope_pag ) from bdicred:sd_amortiza_credito where empresa = '001' and a1.num_credito = num_credito and capital_status in ('2','7','6'))  > 0
				  then round((select sum(mora_provi_cope +  mora_sdo_cope - mora_sdo_cope_pag ) from bdicred:sd_amortiza_credito where empresa = '001' and a1.num_credito = num_credito and capital_status in ('2','7','6')) * (1+ i.iva),2)
			 else 0
			end  intereses_moratorios,  -- intereses moratorios

		( round(( a1.sdo_cap_insoluto  + a1.sdo_retenido +
		 ( select sum ( NVL(interes_debe,0) - NVL(interes_pagado,0) + NVL(iva_debe,0) - NVL(iva_pagado,0)) from bdicred:sd_amortiza_credito where empresa = '001' and  num_credito = a1.num_credito and capital_status in ('2','7','6')) +
		 ( (select  SUM ( NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) +
														 NVL(mora_sdo_cope,0)   - NVL(mora_sdo_cope_pag,0) )
							from bdicred:sd_amortiza_credito

							where empresa = '001' and num_credito = a1.num_credito
							and capital_status in ('2','7','6') ) *(1+ i.iva)) ),2)  )
		deuda_total

		from CreditoTmp a1
		join bdinteg:si_cliente c 		on (a1.numcte = c.numcte )
		join TempDirecciones d on (a1.numcte = d.numcte  and d.tipo_dir = '1' )
		join bdicred:sd_tarjeta b   	on (a1.empresa = b.empresa   and a1.num_credito = b.num_credito  and  b.tipo_tarjeta='T'   
										and b.secuencia = (select max(secuencia) from bdicred:sd_tarjeta where a1.empresa = empresa and a1.num_credito = num_credito and tipo_tarjeta='T') )
		join  bdinteg:si_sucursales  i 	on (a1.sucursal = i.sucursal)
		join  bdinteg:si_catcalles   e  on (d.numerocalle = e.numerocalle)
		join  bdinteg:si_catzonas    f  on (d.numerociudad = f.numerociudad   and d.numerocolonia = f.numerocolonia)
		join  bdinteg:si_catciudades g  on (d.numerociudad= g.numerociudad )
		join  bdinteg:si_estados  h 	on (d.estado= h.estado)
		left join bdinteg:si_telefonos_actual tel1  on (tel1.empresa = '001' and tel1.numcte= a1.numcte and tel1.tipo_tel = 1 and tel1.cofetel ='V')
		left join bdinteg:si_telefonos_actual tel2  on (tel2.empresa = '001' and tel2.numcte= a1.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V')
		left join bdinteg:si_telefonos_actual tel3  on (tel3.empresa = '001' and tel3.numcte= a1.numcte and tel3.tipo_tel = 3 and tel3.cofetel ='V')
		left join bdinteg:si_telefonos_actual tel4  on (tel4.empresa = '001' and tel4.numcte= a1.numcte and tel4.tipo_tel = 4 and tel4.cofetel ='V')
		into temp pros_reestructura with no log;

	create index inx_pros_reestructura on pros_reestructura( num_credito ) ONLINE;
	update statistics high for table pros_reestructura;

	let ctmppaso = '02';


	insert into bdinteg:"informix".si_carta_reestructura
		( fecha, numcte, num_credito, num_tarjeta, sucursal, nombre1, nombre2, apell_paterno, apell_materno
			,calle, numeroextcalle, numerointcalle, colonia, ciudad, estado, codigopostal,
		entrecalles, 
		observaciones, 
		numerociudad, num_centro, num_jefe, num_supervisor, num_coloniacte,	num_callecte, 
		num_casacte, 
		telefono_casa, 
		telefono_celular, 
		telefono_trabajo, 
		extension_trabajo, 
		meses_vencidos, monto_vencido, pago_minimo, pago_6, pago_12, pago_18, pago_24, pago_36, intereses_moratorio, deuda_total )
	select 
		fecha, numcte,num_credito, num_tarjeta, sucursal, nombre1, nombre2, apell_paterno, apell_materno,
		replace(nombrecalle,'|',''), replace(numeroextcalle,'|',''), replace(numerointcalle,'|',''), nombrezona, nombreciudad, nombre, cod_postal,
		nvl ( replace ( replace( entre_calles , '|' , ' ' ), '\' , ' ' ), ' ' )	entrecalles,
		nvl ( replace ( replace( observaciones , '|' , ' ' ), '\' , ' ' ), ' ' )observaciones,
		numerociudad, centro, jefegrupozona, supervisorzona, numerocolonia,	numerocalle,
		numeroextccalle,
		nvl ( replace ( replace( telefono1 , '|' , ' ' ), '\' , ' ' ), ' ' )telefono_casa,
		nvl ( replace ( replace( telefono2 , '|' , ' ' ), '\' , ' ' ), ' ' )telefono_celular,
		nvl ( replace ( replace( telefono3 , '|' , ' ' ), '\' , ' ' ), ' ' )telefono_trabajo,
		nvl ( replace ( replace( extension , '|' , ' ' ), '\' , ' ' ), ' ' )extension_trabajo,
		mto_fin_ven_trasp, pago_minimo, pago_minimo, pago6, pago12, pago18, pago24, pago36, intereses_moratorios,deuda_total
	from pros_reestructura res
		where (select count(*) from bdicred:sd_amortiza_credito
         --where empresa = '001' and res.num_credito = num_credito and capital_status in ('2','7','6')) >= 3
        where empresa = '001' and res.num_credito = num_credito and capital_status in ('2','7','6')) >= viMinVencdo    -- mahr Cambio de vencidos de (3 a 5) a (2 a 5)
        and res.num_credito not in (select numcred 
										from bdisitesp:se_ctessitespcred_his
										where res.numcte =numcte
										and res.num_credito = numcred and situacion = 'P' and causa = 35);



  -- Se eliminan cliente con situacion especial 61
	DELETE FROM si_carta_reestructura WHERE num_credito IN (SELECT numcred 
																FROM bdisitesp:se_ctessitespcred
																WHERE situacion = 'P' AND causa = 61);


	let ctmppaso = '03';


	/*INSERT INTO  sd_temp_invitacion_reest (tipo_promocion,tipo_logica ,fecha ,num_credito1 ,sucursal ,numcte1 ,ult_4dig
		,status ,prioridad , apell_p ,apell_m ,nombre1 ,nombre2 ,sexo ,estado_civil ,correo ,estado ,municipio 
		,num_credito3 ,	numcte ,meses_vencidos ,monto_vencido ,plazo6 ,plazo12 ,plazo18 ,plazo24 ,plazo36 
		,monto_bonificacion, monto_total, pago_minimo,telefono1,telefono2,telefono3,telefono4,extension)*/
	
	select 'RES' tipo_promocion, 2 tipo_logica, a.fecha,a.num_credito num_credito1,a.sucursal, a.numcte numcte1, substr(a.num_tarjeta,13) ult_4dig,
			0 status, 0 prioridad, a.apell_paterno, a.apell_materno, a.nombre1, a.nombre2, cte.sexo, cte.estado_civil, co.correo_elec, a.estado, a.ciudad, a.num_credito 
			, a.numcte,a.meses_vencidos, a.pago_minimo monto_vencido, a.pago_6, a.pago_12, a.pago_18, a.pago_24, a.pago_36, 
			a.intereses_moratorio, a.deuda_total, a.pago_minimo, b.telefono1, b.telefono2, b.telefono3, b.telefono4, extension
		from bdinteg:"informix".si_carta_reestructura a
		join pros_reestructura b on (b.num_credito = a.num_credito)	
		left join bdinteg:si_ctepf cte on (cte.numcte = a.numcte)
		left join bdinteg:si_correos co on (co.empresa  = '001' and co.numcte = a.numcte and status_correo ='A'
							and co.secuencia = (select max(secuencia) from bdinteg:si_correos 
												where empresa  = '001' and numcte = a.numcte and status_correo ='A'))
												INTO TEMP tmp_invitacion_reest;

	let ctmppaso = '04';


	--update sd_temp_invitacion_reest 
	UPDATE tmp_invitacion_reest 
		SET telefono4 = nvl(substr(telefono4,length(telefono4)-9,10),''),
			telefono1 = nvl(substr(telefono1,length(telefono1)-9,10),''), 
			telefono2 = nvl(substr(telefono2,length(telefono2)-9,10),''),
			telefono3 = nvl(substr(telefono3,length(telefono3)-9,10),''); 
		
		
	--delete from sd_temp_invitacion_reest  
	DELETE FROM tmp_invitacion_reest
		where nvl(telefono1,'') ='' and nvl(telefono2,'')='' and nvl(telefono3,'')='' and nvl(telefono4,'')='';

	--update sd_temp_invitacion_reest 
	UPDATE tmp_invitacion_reest
	set telefono2 = ''
	where nvl(telefono1,'')= nvl(telefono2,'');

	--update sd_temp_invitacion_reest 
	UPDATE tmp_invitacion_reest
	set telefono3 = ''
	where nvl(telefono3,'')= nvl(telefono2,'') or nvl(telefono3,'')= nvl(telefono1,'');

	--update sd_temp_invitacion_reest 
	UPDATE tmp_invitacion_reest
	set telefono4 = ''
	where nvl(telefono1,'')= nvl(telefono4,'') or nvl(telefono2,'')= nvl(telefono4,'') or nvl(telefono3,'')= nvl(telefono4,''); 
	
	--update sd_temp_invitacion_reest 
	UPDATE tmp_invitacion_reest
		set telefono4 = nvl(telefono4,''),
			telefono1 = nvl(telefono1,''), 
			telefono2 = nvl(telefono2,''),
			telefono3 = nvl(telefono3,'');
			
	--update sd_temp_invitacion_reest 
	UPDATE tmp_invitacion_reest
	set telefono4 = case when val_num(telefono4) then telefono4 else '' end,
		telefono1 = case when val_num(telefono1) then telefono1 else '' end, 
		telefono2 = case when val_num(telefono2) then telefono2 else '' end,
		telefono3 = case when val_num(telefono3) then telefono3 else '' end;
      
   
	let ctmppaso = '05';   

	--update sd_temp_invitacion_reest 
	UPDATE tmp_invitacion_reest
		set telefono4 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono4,1,2) in ('55','33','81')  then 
									SUBSTR(telefono4,1,2) else SUBSTR(telefono4,1,3) end 
						   AND a.serie = case when SUBSTR(telefono4,1,2) in ('55','33','81')  then SUBSTR(telefono4,3,4) else SUBSTR(telefono4,4,3) end 
						   AND (SUBSTR(telefono4,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono4,7,4)*1)*1 <= a.numeracion_final ),'')||telefono4 ,
			telefono1 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono1,1,2) in ('55','33','81')  then 
									SUBSTR(telefono1,1,2) else SUBSTR(telefono1,1,3) end 
						   AND a.serie = case when SUBSTR(telefono1,1,2) in ('55','33','81')  then SUBSTR(telefono1,3,4) else SUBSTR(telefono1,4,3) end 
						   AND (SUBSTR(telefono1,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono1,7,4)*1)*1 <= a.numeracion_final ),'')||telefono1 ,		 
			telefono2 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono2 ,1,2) in ('55','33','81')  then 
									SUBSTR(telefono2 ,1,2) else SUBSTR(telefono2 ,1,3) end 
						   AND a.serie = case when SUBSTR(telefono2 ,1,2) in ('55','33','81')  then SUBSTR(telefono2 ,3,4) else SUBSTR(telefono2,4,3) end 
						   AND (SUBSTR(telefono2,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono2,7,4)*1)*1 <= a.numeracion_final ),'')||telefono2 ,
			telefono3 = nvl((SELECT  decode(trim(a.tipored),'MOVIL','1','') 
						  FROM bdinteg:si_cattelefono a 
						 WHERE a.nir = case when SUBSTR(telefono3,1,2) in ('55','33','81')  then 
									SUBSTR(telefono3,1,2) else SUBSTR(telefono3,1,3) end 
						   AND a.serie = case when SUBSTR(telefono3,1,2) in ('55','33','81')  then SUBSTR(telefono3,3,4) else SUBSTR(telefono3,4,3) end 
						   AND (SUBSTR(telefono3,7,4)*1)*1 >= a.numeracion_inicial 
						   AND (SUBSTR(telefono3,7,4)*1)*1 <= a.numeracion_final ),'')||telefono3; 
			
	--update sd_temp_invitacion_reest
	UPDATE tmp_invitacion_reest
		set telefono4 = decode(telefono4,'',null, telefono4),
			telefono1 = decode(telefono1,'',null, telefono1), 
			telefono2 = decode(telefono2,'',null, telefono2),
			telefono3 = decode(telefono3,'',null, telefono3); 
			
	INSERT INTO  sd_temp_invitacion_reest 
			(tipo_promocion,	tipo_logica,	fecha,			num_credito1,	sucursal,	numcte1,		ult_4dig,	status,		prioridad,
			apell_p,			apell_m,		nombre1,		nombre2,		sexo,		estado_civil,	correo,		estado,		municipio,
			num_credito3,		numcte,			meses_vencidos,	monto_vencido,	plazo6,		plazo12,		plazo18,	plazo24,	plazo36,
			monto_bonificacion,	monto_total,	pago_minimo,	telefono1,		telefono2,	telefono3,		telefono4,	extension)
	SELECT * FROM tmp_invitacion_reest;


	let ctmppaso = '06';

			
	-- Actualiza el orden de prioridad de acuerdo a la fecha de vigencia de la solicitud
	 LET viPrioridad = 1;

    FOREACH
        SELECT numcte1, num_credito1 INTO cNumCte, cNumCred 
        FROM sd_temp_invitacion_reest WHERE tipo_promocion = 'RES'
        --ORDER BY meses_vencidos desc,monto_total desc

        UPDATE sd_temp_invitacion_reest SET prioridad = viPrioridad 
            WHERE numcte1 = cNumCte AND num_credito1 = cNumCred;
        
        LET viPrioridad = viPrioridad + 1;
    END FOREACH;

	let ctmppaso = '07';

	select count(*) into iTotalRegistros from sd_temp_invitacion_reest;
	
	INSERT INTO bdicred:sd_totalcte_campania(empresa, fecha_insert, tipocampania, total)
	VALUES('001', dHoy , 'CARTA_REEST', iTotalRegistros);
 
-------------------------- Archivo Promociones -------------------------------------------------

	let cNombreArchivo = trim('Reestructuras_' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');

	let cSql = 'echo " Unload to ' ||  trim(cRutaArch) || 'archivo_promociones.unl' || ' delimiter ' || '''|''' ||
	' select tipo_promocion,tipo_logica,num_credito1,numcte1,sucursal,prioridad,'||
	'TRIM(apell_p)||'||''' '''||'||TRIM(apell_m)||'||''' '''||'||TRIM(nombre1)||'||''' '''||'||TRIM(nombre2),sexo ,estado_civil ,correo ,estado,'||
	'meses_vencidos ,monto_vencido ,plazo6 ,plazo12 ,plazo18 ,plazo24 ,plazo36 ,monto_bonificacion,monto_total,pago_minimo, ' ||
	--'telefono2, telefono3,telefono4, extension '||
	'telefono1,telefono2,telefono3,telefono4 ,extension '||
	'from sd_temp_invitacion_reest order by prioridad  ' ||
	 '" > ' || trim(cRutaArch) || 'Archivo_Promociones.sql' ;


	let ctmppaso = '08';

	system cSql;
	let cSql='';
	let cSql = 'dbaccess bdinteg ' || trim(cRutaArch) || 'Archivo_Promociones.sql';
	system cSql;

	let ctmppaso = '81';


	let csql = 'echo "Tipo_Promocion'|| cdelimitador || 'Tipo_Logica'|| cdelimitador || 'Numero_de_Credito'|| cdelimitador || 'Numero_de_Cliente'|| cdelimitador || 'Sucursal'|| cdelimitador || 'Prioridad'|| cdelimitador ||
				 'Nombre'|| cdelimitador ||'sexo' || cdelimitador || 'Estado_Civil' || cdelimitador || 'email' || cdelimitador || 'Estado'|| cdelimitador || 'Meses_Vencidos' || cdelimitador ||'Monto_Vencido' ||
				 cdelimitador || 'Pago_Plazo_6'|| cdelimitador || 'Pago_Plazo_12' || cdelimitador || 'Pago_Plazo_18' || cdelimitador || 'Pago_Plazo_24' || cdelimitador || 'Pago_Plazo_36' || cdelimitador || 'Monto_Bonificacion' ||
				 cdelimitador || 'Monto_Total' || cdelimitador || 'Pago_Minimo' || cdelimitador || 'Tel_cons_tipo_1' || cdelimitador || 'Tel_cons_tipo_2' || cdelimitador || 'Tel_cons_tipo_3' || cdelimitador || 'Tel_cons_tipo_4' || cdelimitador ||
				 'Extension' ||  ' " > ' || trim(cRutaArch) || cNombreArchivo;
	system csql;

	let ctmppaso = '82';

	system csql;


	let ctmppaso = '09';

	let cSql='';
	let cSql = "sed 's/|$//g' " || trim(cRutaArch) || "archivo_promociones.unl >> " || trim(cRutaArch) ||  cNombreArchivo;
	system cSql;

	let cSql='';
	let cSql = 'rm ' || trim(cRutaArch) || 'Archivo_Promociones.sql';
	system cSql;

	let cSql='';
	let cSql = 'rm ' || trim(cRutaArch) || 'archivo_promociones.unl';
	system cSql;



	let ctmppaso = '10';
-------------------- Última carta--------------------------------------

	let cNombreArchivo = trim('Carta_Invitacion_Reest' || trim(vdia) || trim(vMes) || trim(vAnio) || '.txt');
	let cSql = 'echo " Unload to ' || trim(cRutaArch) || cNombreArchivo || ' delimiter ' || '''|''' ||
	' select  fecha, (Trim(nombre1) || ' || ' "''" "''" || Trim(nombre2) || ' || ' "''" "''" || Trim(apell_paterno) || ' || ' "''" "''" || Trim(apell_materno)) nombre_cliente, ' ||
	'        trim(calle) || ' || ' "''" "''" || Trim(numeroextcalle)|| ' || ' "''" "''" || Trim(numerointcalle) direccion , ' ||
	'        colonia, ciudad,estado, codigopostal, entrecalles, observaciones, ' ||
	' LPAD(numerociudad ,4,''0'') || "''"/"''" || ' ||
	' LPAD(num_centro,6,''0'') || "''"/"''" || ' ||
	' LPAD(num_jefe,8,''0'') || "''"/"''" || ' ||
	' LPAD(num_supervisor,8,''0'')|| "''"/"''" || ' ||
	' LPAD(num_coloniacte,4,''0'') || "''"/"''" || ' ||
	' LPAD(num_callecte,6,''0'') || "''"/"''" || ' ||
	' LPAD(TRIM(num_casacte),5,''0'') clave_ruta, ' ||
	' pago_minimo, pago_12, pago_18, pago_24, pago_36, intereses_moratorio,num_credito,num_tarjeta,numcte ' ||
	' from si_carta_reestructura ' ||
	' where numerociudad in  (4,10,14,17,24,26,31,32,38,40,41,44,46,47,48,54,55,57,58,59,62,66,70,78,80,87,89,91,92,97,107,121,124,164,167,'||
						   ' 168,169,170,174,175,179,181,182,183,184,191,208,282,283,286,289,294,295,298,308,310,311,312,315,335,340,361,364)" '||
	'> ' || trim(cRutaArch) || 'Archivo_UltimaCarta.sql ';

	system cSql;
	let cSql='';
	let cSql = 'dbaccess bdinteg ' || trim(cRutaArch) || 'Archivo_UltimaCarta.sql';
	system cSql;


		let ctmppaso = '11';


	let cSql='';
	let cSql = 'rm ' || trim(cRutaArch) || 'Archivo_UltimaCarta.sql';
	system cSql;

	select valor_numerico into vvalor
	from bdicobranza:cb_param_campania	where tipo_campania = 50 and num_parametro = 58;

	--INSERT INTO bdicobranza:cb_administativa_latinia--(num_campania,numcte,telefono,tarjeta ,apellido_pat,fecha)
    /*select limit vvalor  a.numcte,a.num_credito, SUBSTR(tel2.telefono,(LENGTH(tel2.telefono) + 1 - 10),10) telefono,
						CASE WHEN LENGTH(a.nombre1) <=  3 THEN TRIM(a.nombre1)||' '||
															TRIM(SUBSTR(a.nombre2,1,9 - LENGTH(a.nombre1)))
						ELSE SUBSTR(a.nombre1,1,10) END nombre,a.fecha
	from bdinteg:"informix".si_carta_reestructura a
	join bdinteg:si_telefonos_actual tel2 on (tel2.empresa = '001' and tel2.numcte= a.numcte and tel2.tipo_tel = 2 and tel2.cofetel ='V' and tel2.status_tel = 'A'
                            and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual
                                                 where numcte = a.numcte and tipo_tel = 2 and cofetel ='V' and status_tel = 'A'))
	where tel2.telefono is not null and tel2.telefono <> '' into temp catpromo_reest;*/


	let ctmppaso = '12';
	
	SELECT tel2.numcte, tel2.telefono, tel2.cofetel 
	FROM bdinteg:"informix".si_carta_reestructura a
	INNER JOIN bdinteg:si_telefonos_actual tel2 ON a.numcte = tel2.numcte AND tel2.status_tel = 'A' AND tel2.tipo_tel = 2 
	into temp tmp_catpromo_reest;
	
	SELECT  a.numcte,a.num_credito, SUBSTR(b.telefono,(LENGTH(b.telefono) + 1 - 10),10) telefono,
						CASE WHEN LENGTH(a.nombre1) <=  3 THEN TRIM(a.nombre1)||' '||
															TRIM(SUBSTR(a.nombre2,1,9 - LENGTH(a.nombre1)))
						ELSE SUBSTR(a.nombre1,1,10) END nombre,a.fecha
	FROM bdinteg:si_carta_reestructura a 
	INNER JOIN tmp_catpromo_reest b ON a.numcte = b.numcte AND cofetel ='V' into temp catpromo_reest; 

    create index ix_tmp_cat_prom on catpromo_reest (numcte,num_credito);
	
	{
	select count(*) into vcontador from catpromo_reest;
		
	if (vcontador >= 1) then 
	FOREACH
		select numcte,num_credito, nombre
			into cNumCte, cNumCred,vnombre
		from catpromo_reest
	
		call bdimnsj:"informix".sp_registra_evento (2, 'INV_REEST' , cNumCte, cNumCred,'', 2,
										vnombre,'','','','',0,0,0,0,0, '', '')RETURNING cCodRet;
	
	END FOREACH;
		--CALL bdicobranza:"informix".sp_sms_reporte(2,0,0,0) RETURNING 	cCodRet;
	end if;


	let ctmppaso = '13';
	
	FOREACH
		select descripcion,  trim(valor_alfabetico)
		  into VlDescripcion, vlValorAlfabetico
		  from bdicred:sd_param_campania 
		 where tipo_campania = 60  
		   AND GRUPO_PARAMETRO = 'TELSMSFIJO'
		   and num_parametro in (1,2,3,5,6)
		   
		select numcte,num_credito
		  into cNumCte,cNumCred
		  from bdicred:sd_maecred
		 where num_credito  = vlValorAlfabetico; --in ('600109267697','600030001041','600109267432')
		 
		 select CASE WHEN LENGTH(a.nombre1) <=  3 THEN TRIM(a.nombre1)||' '||TRIM(SUBSTR(a.nombre2,1,9 - LENGTH(a.nombre1))) ELSE
																					SUBSTR(a.nombre1,1,10) END nombre into vnombre
    from bdinteg:si_cliente a where numcte = cNumCte; 
							
    call bdimnsj:"informix".sp_registra_evento (2, 'INV_REEST' , cNumCte, cNumCred,'', 2,
										vnombre,'','','','',0,0,0,0,0, '', '')RETURNING cCodRet;
          
          	
    END FOREACH;}
	
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', cProceso, cCodRet, cMensajeRet, '03')RETURNING cCodRet;
return cCodRet,cMensajeRet ;
end;
end procedure;