CREATE PROCEDURE "informix".sp_cartera_total_ppyr_pba()

RETURNING CHAR(6);
--Creado por: maria elizabeth anzures ibarguen
--28-12-2011    
--Proceso para la generación de archivo cartera total prestamo personal y reestructura

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_ret2				CHAR(6);
DEFINE cErrorInfo           CHAR(80);
DEFINE  vproceso			CHAR(30);
DEFINE pusuario             CHAR(8);
DEFINE cruta                CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE cnomarchivo          CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cSQL                 CHAR(2204);
DEFINE cSQL1                CHAR(200);
DEFINE cSQL2                CHAR(2004);
DEFINE cSQL3                CHAR(100);
DEFINE cempresa             CHAR(3);
DEFINE cdelimitador         CHAR(1);
DEFINE cCod_RetIB           CHAR(6);
DEFINE pfechacorte date;
DEFINE Vult_dia_mes DATE;
--Structura
DEFINE Vcreditoexterno          char(20);
DEFINE Vproducto     		char(4);
DEFINE Vnum_credito         char(20);
DEFINE VcreditoConsulta       char(20);
DEFINE  Vnumcte				char(20);
DEFINE Vnum_tarjeta         char(20);
DEFINE Vnum_sucursal		char(4);
DEFINE  Vnom_suucursal		char(40);
DEFINE  Vingreso_mensual    money;
DEFINE  Vmonto_apertura      decimal(18,2); 
DEFINE  Vfecha_apertura      date;

DEFINE  Vplazo smallint;
DEFINE Vestatus char (2);
DEFINE  Vsaldo_insoluto	decimal(18,2);
DEFINE  Vcapital_vigente	decimal(18,2);
DEFINE Vcapital_transitorio	decimal(18,2);
DEFINE Vsaldo_vencido_exigible	decimal(18,2);
DEFINE Vsaldo_vencido_no_exigible	decimal(18,2);
DEFINE Vsaldo_actual decimal(18,2); 
DEFINE  Vsaldo_cierre decimal(18,2); 
DEFINE Vmes_vencido decimal(18,2); 
DEFINE Vtipo_mov cHAR (1);


DEFINE Vsexo char (1);
DEFINE Vfecha_nac date;
DEFINE Vnombre1 char(26);
DEFINE Vnombre2 char(26);
DEFINE Vapellido_p char(26);
DEFINE Vapellido_m char(26);
DEFINE Vmail char (60);
DEFINE Vdir_calle char(30);
DEFINE Vdir_numero char(20);
DEFINE Vdir_colonia char(32);
DEFINE Vcp char(5);

DEFINE Vdir_municipio char(60);
DEFINE Vnum_estado smallint;
DEFINE Vdir_estado char(30);
DEFINE Vnum_cd_coppel smallint;
DEFINE Vcd_coppel char(32);
DEFINE Vnum_cd_banco smallint;
DEFINE  Vcd_banco char(32);
DEFINE Vtel1 char(13);
DEFINE  Vtel2 char(13);
DEFINE Vtel3 char(13);
DEFINE Vext char(5);

DEFINE Vref_coppel char(20);
DEFINE Vficiencia decimal(5,2);
DEFINE Vmeses_historia smallint;
DEFINE Vhit char(6);
DEFINE Vsecc1 char (4);
DEFINE Vsecc2 decimal(5,2);
DEFINE sPaso integer;
DEFINE vlNumInsert SMALLINT;
DEFINE Vpri_dia_mes DATE;
DEFINE Vfechaultmov DATE;
DEFINE	vTotalCommit	INTEGER;
--Inicialización de variables

LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cCod_Ret2                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso	            = '2006';
LET pusuario                = USER;
LET cruta                   = "";
LET cnombre		    = "";
LET cnomarchivo             = "";
LET cnomarchivo1            = "";
LET cSQL                    = "";
LET cSQL1                   = "";
LET cSQL2                   = "";
LET cSQL3                   = "";
LET cempresa                = "001";
LET cdelimitador            = ";";
LET cCod_RetIB              = "000000";
LET pfechacorte = date(1);
LET Vult_dia_mes = DATE(1);
LET Vpri_dia_mes = DATE(1);

-----VARIABLES
LET Vcreditoexterno = '';
LET Vproducto     		='';
LET Vnum_credito         = '';
LET VcreditoConsulta         = '';
LET  Vnumcte				='';
LET Vnum_tarjeta         ='';
LET Vnum_sucursal		='';
LET  Vnom_suucursal		='';
LET  Vingreso_mensual    = 0;
LET  Vmonto_apertura      = 0;
LET  Vfecha_apertura     = date(1);

LET  Vplazo = 0;
LET Vestatus ='';
LET  Vsaldo_insoluto	= 0;
LET  Vcapital_vigente	= 0;
LET Vcapital_transitorio	= 0;
LET Vsaldo_vencido_exigible	= 0;
LET Vsaldo_vencido_no_exigible	= 0;
LET Vsaldo_actual = 0;
LET  Vsaldo_cierre = 0;
LET Vmes_vencido = 0;
LET Vtipo_mov ='';


LET Vsexo ='';
LET Vfecha_nac = date(1);
LET Vnombre1 ='';
LET Vnombre2 ='';
LET Vapellido_p ='';
LET Vapellido_m ='';
LET Vmail ='';
LET Vdir_calle ='';
LET Vdir_numero ='';
LET Vdir_colonia ='';
LET Vcp = '';

LET Vdir_municipio ='';
LET Vnum_estado = 0;
LET Vdir_estado ='';
LET Vnum_cd_coppel= 0;
LET Vcd_coppel ='';
LET Vnum_cd_banco = 0;
LET  Vcd_banco ='';
LET Vtel1 ='';
LET  Vtel2 ='';
LET Vtel3 ='';
LET Vext ='';

LET Vref_coppel ='';
LET Vficiencia = 0;
LET Vmeses_historia = 0;
LET Vhit ='';
LET Vsecc1 = '';
LET Vsecc2 = 0;
LET  sPaso = 0;
LET vlNumInsert = 0;
LET Vfechaultmov = DATE(1);
LET vTotalCommit = 0;

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02') returning cCod_Ret2;			
        RETURN cCod_ret;
	END EXCEPTION;
--SET DEBUG FILE TO "/informix/fmartinez_2/PruebasCartera1/CATERA_PPyR.sql";
--TRACE ON;

	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_Ret2;
	
	--Obtener caracter delimitador
	SELECT trim(valor_alfabetico)
	INTO cdelimitador
	FROM bdicobranza:cb_param_campania
	WHERE empresa = cempresa
	AND tipo_campania = 1
	AND grupo_parametro = 'ARCHIVOS'
	AND num_parametro = 26;
	
	--Valida que exista el caracter
	IF NVL(cDelimitador,'') = '' THEN
        LET cCod_Ret= '104004';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_Ret2;
        Return cCod_Ret;
	END IF;
		
	select trim(valor_alfabetico) into cruta
	from bdicobranza:cb_param_campania 
	where tipo_campania = 1
	and grupo_parametro = 'ARCHIVOS'
	and num_parametro = 36;
	
	--Valida que exista la carpeta
	IF NVL (cruta,'') = '' THEN
        LET cCod_Ret= '104005';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
        IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_Ret2;
        Return cCod_Ret;
	END IF;
	
    TRUNCATE TABLE sd_cartera_total_PPyR;
	--------------------INSERTAR EN TABLA-----------------------------------
	select fecha_hoy
	  into pfechacorte
  	  from bdicred:sd_fechas 
     where empresa = '001';

-- Selecciona los creditos a procesar
   select  empresa, num_credito, fecha_apertura, numcte , num_producto, credito_externo, sucursal, plazo, status_cred, tasa_interes
	 from bdicred:sd_maecredcrd 
	where empresa = '001' 
      and status_cred not in ('FF','CV')
	  and num_producto in ('6300','6011') 
	into temp CreditosCrd with no log;
	create unique index indx_creditos on CreditosCrd (num_credito);
    create index indx_creditos_ext on CreditosCrd (credito_externo);
	create index indx_creditos2 on CreditosCrd (sucursal,empresa);
	update statistics medium for table CreditosCrd;

-- Obtiene datos de la tabla resum_scoring 
--Por Num_credito
   select crd.num_credito num_credito, num_solicitud num_solicitud,  nvl(ingreso_mensual,0) ingreso_mensual ,nvl(situacion_pago,0) situacion_pago ,nvl(meses_historia,0) meses_historia,
        DECODE ( NVL(evalua_cc,''),'','No Hit','X','No Hit','Hit')	evalua_cc			
    from CreditosCrd crd,bdisolic:ss_resum_scor_fin scor 
    where crd.num_credito=scor.num_solicitud
      and scor.empresa = '001'
    into temp scorfin with no log;
--Por credito_externo
   insert into scorfin 
   select crd.num_credito num_credito, num_solicitud num_solicitud,  nvl(ingreso_mensual,0) ingreso_mensual ,nvl(situacion_pago,0) situacion_pago ,nvl(meses_historia,0) meses_historia,
        DECODE ( NVL(evalua_cc,''),'','No Hit','X','No Hit','Hit')	evalua_cc			
    from CreditosCrd crd,bdisolic:ss_resum_scor_fin scor 
    where crd.credito_externo=scor.num_solicitud
      and scor.empresa = '001';
    create unique index indx_scor on scorfin (num_solicitud);
    create unique index indx_scor_cred on scorfin (num_credito);
    update statistics medium for table scorfin;	

--ultimo movimiento de pago
  select crd.num_credito, fecha_ult_pago fecha_mov
    from CreditosCrd crd, bdicred:sd_maecredanexocrd mov
    where mov.empresa = '001'
      and crd.num_credito = mov.num_credito      
    --group by crd.num_credito
    into temp MovtosCred with no log;
    create unique index indx_mov on MovtosCred(num_credito);
    update statistics medium for table MovtosCred;
	 
	FOREACH WITH HOLD
        select  a.num_producto,a.num_credito,NVL(a.credito_externo,'0'),a.numcte,a.sucursal,suc.nombre,b.monto_otorgado ,NVL(a.fecha_apertura,DATE(1))
                , a.plazo, a.status_cred,b.sdo_cap_insoluto,b.sdo_capital,b.monto_vencido,b.mto_venc_trasp,b.cap_tras_no_venci, 
                round(b.mto_fin_ven_trasp),fecha_ult_pago
            into Vproducto , Vnum_credito,Vcreditoexterno  , Vnumcte,Vnum_sucursal,vnom_suucursal,vmonto_apertura,vfecha_apertura
                ,vplazo,vestatus, vsaldo_insoluto,vcapital_vigente,vcapital_transitorio,vsaldo_vencido_exigible,vsaldo_vencido_no_exigible,
                vmes_vencido,Vfechaultmov
            from CreditosCrd a
                inner join bdicred:sd_maesdoscrd b on ( a.num_credito = b.num_credito and  b.empresa ='001' )		
                left join bdinteg:si_sucursales suc on ( suc.sucursal = a.sucursal and suc.empresa = a.empresa)					
                inner join bdicred:sd_maecredanexocrd  c on (c.num_credito = a.num_credito)
             --where a.empresa ='001' and a.num_producto in ( '6011','6300')		

            SELECT cte.numcte_ref,cte.nombre1, cte.nombre2, cte.apell_paterno  , cte.apell_materno,nvl(pf.sexo,''),nvl(pf.fecha_nac,'')
            INTO Vref_coppel,vnombre1 , vnombre2 ,vapellido_p ,vapellido_m,vsexo,vfecha_nac
            FROM  bdinteg:si_cliente cte 
            INNER JOIN bdinteg:si_ctepf pf on (pf.numcte = cte.numcte)
            WHERE cte.numcte = Vnumcte;	

		    SELECT first 1 ca.nombrecalle ,dir.numeroextcalle,zo.nombrezona,dir.cod_postal,
            cd.nombre as dir_mun,es.estado as num_estado,es.nombre as dir_estado, zo.numerociudadcoppel as cd_coppel,zo.nombrezonacoppel ,
            zo.numerociudad as num_banco ,zo.poblacionzona as cd_banco
            INTO vdir_calle,vdir_numero,vdir_colonia,vcp
            ,Vdir_municipio,  Vnum_estado ,Vdir_estado ,Vnum_cd_coppel ,Vcd_coppel ,Vnum_cd_banco ,Vcd_banco 
            FROM bdinteg:si_direcciones_actual dir  
            inner join bdinteg:si_catcalles ca on ( ca.numerocalle = dir.numerocalle)
            inner join bdinteg:si_catzonas zo on ( zo.numerociudad = dir.numerociudad   and zo.numerocolonia = dir.numerocolonia)
            inner join bdinteg:si_ciudades cd  on (cd.estado  = dir.estado  and  cd.ciudad = dir.ciudad)
            inner join bdinteg:si_estados es on (es.estado = dir.estado)
            WHERE dir.numcte = Vnumcte AND dir.tipo_dir = 1;

-- lee el ultimo correo valido
            select nvl(correo_elec,'')
              into Vmail
              from bdinteg:si_correos a
             where numcte = Vnumcte
               and secuencia = (select max(secuencia) from bdinteg:si_correos where a.numcte = numcte AND status_correo = 'A')
               AND status_correo = 'A';
		
            select LIMIT 1 a.telefono
             into Vtel1 
             from bdinteg:si_telefonos_actual a             
            where a.empresa = '001' 
              and a.numcte = vnumcte 
              and a.tipo_tel = 1
              AND a.status_tel = 'A' 
              and a.cofetel = 'V' ;	
			  
			 select LIMIT 1  b.telefono 
             into Vtel2 
             from bdinteg:si_telefonos_actual b             
            where b.empresa = '001' 
              and b.numcte = vnumcte 
              and b.tipo_tel = 2
              AND b.status_tel = 'A' 
              and b.cofetel = 'V' ;	

            select LIMIT 1 d.telefono,d.extension
             into Vtel3 ,Vext
             from bdinteg:si_telefonos_actual d             
            where d.empresa = '001' 
              and d.numcte = vnumcte 
              and d.tipo_tel = 3
              AND d.status_tel = 'A' 
              and d.cofetel = 'V' ;	
			  
			
            select  limit 1 cta.num_cta 
            into Vnum_tarjeta
            FROM bdicred:sd_ctascarg cta
            where cta.empresa = '001'
            and cta.num_credito = Vnum_credito;
 
            select limit 1  nvl(ingreso_mensual,0) ,nvl(situacion_pago,0)  ,nvl(meses_historia,0), evalua_cc, num_solicitud				
            into Vingreso_mensual,Vficiencia, Vmeses_historia, Vhit, VcreditoConsulta
            from scorfin
            where num_credito = Vnum_credito;

            SELECT limit 1 nvl(sum(valor),0) into Vsecc2
            FROM bdisolic:ss_detalle_scoring 
            where empresa = '001'
            and num_solicitud = VcreditoConsulta;

            select limit 1 nvl(sc01,'') into Vsecc1
            from bdiburo:br_sc 
            where num_cliente = Vnumcte; 

            if (vestatus in ('AA')) then
                let Vsaldo_cierre =  Vcapital_vigente;
        	elif (vestatus in ('BA')) then
                let Vsaldo_cierre =  vcapital_vigente + vcapital_transitorio;
            elif (vestatus in  ('BT','VP')) then
                let Vsaldo_cierre = vsaldo_vencido_exigible + vsaldo_vencido_no_exigible; 
            end if;

            LET Vsaldo_cierre = vsaldo_insoluto; 
		
	-------------------------BUSCAR ULTIMO MOVIMIENTO DEL CLIENTE-------------------------
    
            select fecha_mov
              into Vfechaultmov
              from MovtosCred
            where num_credito = Vnum_credito;

            if (Vfechaultmov is null) then
                let Vfechaultmov = vfecha_apertura;
                LET Vtipo_mov = 'A';	
            else
                LET Vtipo_mov = 'P';	
            end if;
			
			begin work;
            INSERT INTO sd_cartera_total_PPyR 
                (producto , num_credito ,numcte	,num_tarjeta ,num_sucursal	,nom_suucursal	,ingreso_mensual ,
                monto_apertura  ,fecha_apertura  ,plazo ,estatus ,
                saldo_insoluto	,capital_vigente,	capital_transitorio	,saldo_vencido_exigible	,saldo_vencido_no_exigible	,saldo_actual , 
                saldo_cierre ,mes_vencido ,tipo_mov ,fecha_mov,sexo ,fecha_nac ,nombre1 ,Nombre2 ,apellido_p ,
                apellido_m ,mail ,dir_calle ,dir_numero ,dir_colonia ,cp ,
                dir_municipio ,num_estado ,dir_estado ,num_cd_coppel ,cd_coppel ,num_cd_banco ,
                cd_banco ,tel1 ,tel2 ,tel3 ,ext ,ref_coppel ,eficiencia ,meses_historia ,hit ,secc1 ,secc2 )
            VALUES
                (Vproducto , Vnum_credito , Vnumcte,	Vnum_tarjeta ,Vnum_sucursal	, Vnom_suucursal,Vingreso_mensual,
                Vmonto_apertura , Vfecha_apertura , Vplazo ,Vestatus,Vsaldo_insoluto,Vcapital_vigente,
                Vcapital_transitorio	,Vsaldo_vencido_exigible,Vsaldo_vencido_no_exigible,Vsaldo_actual ,
                Vsaldo_cierre ,Vmes_vencido ,Vtipo_mov ,Vfechaultmov, Vsexo ,Vfecha_nac, Vnombre1 , Vnombre2 ,Vapellido_p ,
                Vapellido_m ,Vmail,Vdir_calle, Vdir_numero , Vdir_colonia , Vcp ,
                Vdir_municipio,  Vnum_estado ,Vdir_estado ,Vnum_cd_coppel ,Vcd_coppel ,Vnum_cd_banco ,
                Vcd_banco , Vtel1 ,Vtel2 ,Vtel3 ,Vext , Vref_coppel ,Vficiencia , Vmeses_historia ,Vhit ,Vsecc1 , Vsecc2 );
			
			COMMIT WORK;
			

              LET  Vsaldo_insoluto	= 0;	LET  Vcapital_vigente	= 0;	LET Vcapital_transitorio	= 0;	LET Vsaldo_vencido_exigible	= 0;
              LET Vsaldo_vencido_no_exigible	= 0;	LET Vsaldo_actual = 0;	LET  Vsaldo_cierre = 0;	
              LET Vproducto     		='';     LET Vnum_credito         = '';	 LET  Vnumcte				='';
              LET Vnum_tarjeta         ='';	 LET Vnum_sucursal		='';	 LET  Vnom_suucursal		='';	 LET  Vingreso_mensual    = 0;
              LET  Vmonto_apertura      = 0;	 LET  Vfecha_apertura     = date(1);	  LET  Vplazo = 0;
              LET Vestatus ='';	  
              LET Vmes_vencido = 0;	  LET Vtipo_mov ='';	  LET Vfechaultmov = DATE(1);
              LET Vsexo ='';	  LET Vfecha_nac = date(1);	  LET Vnombre1 ='';	  LET Vnombre2 ='';	  LET Vapellido_p ='';
              LET Vapellido_m ='';	  LET Vmail ='';	  LET Vdir_calle ='';	  LET Vdir_numero ='';	  LET Vdir_colonia ='';
              LET Vcp = '';	 	  LET Vdir_municipio ='';	  LET Vnum_estado = 0;	  LET Vdir_estado ='';	  LET Vnum_cd_coppel= 0;
              LET Vcd_coppel ='';	  LET Vnum_cd_banco = 0;	  LET  Vcd_banco ='';	  LET Vtel1 ='';	  LET  Vtel2 ='';
              LET Vtel3 ='';	  LET Vext ='';	 	  LET Vref_coppel ='';	  LET Vficiencia = 0;	  LET Vmeses_historia = 0;
              LET Vhit ='';	  LET Vsecc1 = '';	  LET Vsecc2 = 0;

    END FOREACH;

	IF vTotalCommit>0 THEN
        COMMIT WORK;
        update statistics medium for table bdicred:"informix".sd_cartera_total_PPyR;
    END IF; 
    

	---------------------------------------GENERAR ARCHIVO------------------------------------------------------------------
	--let cruta = '/informix/fmartinez_2/PruebasCartera1/';
	let cnombre = 'Cartera_Total';
	
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(pfechacorte,'%d%m%Y')||'.txt';
    LET cnomarchivo =  trim(cnombre)||to_char(pfechacorte,'%d%m%Y')||'.txt';
	 
	let cSql='';
	LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
	LET cSQL2 = " select * from bdicred:sd_cartera_total_ppyr ";
	LET cSQL3 = '">'||TRIM(cRuta)||'Ejecuta.sql';
	LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    System cSQL;

    LET cSQL='chmod 777 '|| TRIM(cRuta)||'Ejecuta.sql';
    System cSQL;

    let cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || 'Ejecuta.sql';
    System cSQL;

    LET cSql = cSql;
    LET cSql = "sed 's/"||cDelimitador||"$//g' "|| TRIM(cRuta) || TRIM(cnomarchivo1) || " >> " || TRIM(cRuta) || TRIM(cnomarchivo);
    SYSTEM cSql;
	
	--Borra el archivo de control.
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'Ejecuta.sql';
	SYSTEM cSQL;

    LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;  
	
--END IF;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03') returning cCod_Ret2;
	RETURN cCod_ret;
	
END;
END PROCEDURE;