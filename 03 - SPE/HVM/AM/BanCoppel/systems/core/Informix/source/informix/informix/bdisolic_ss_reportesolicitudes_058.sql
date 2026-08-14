CREATE PROCEDURE "informix".ss_reportesolicitudes_058()
returning   char(06),
            char(70);
     
			
---------------------------------------------------------
--Autor: María Janeth Peinado Cuevas
--Fecha: 23/11/2012
--Actividad: Genera informacion de reporte de solicitudes historicas Junio 2010 Junio 2011
----------------------------------------------------------

--Declaracion de variables
define chrcodret			char(06);
define chrmensaje           char(70);
define chrnumsolicitud		char(20);
define chrsucursal			char(4);
define chrappaterno			char(26);
define chrapmaterno			char(26);
define chrnombre1			char(26);
define chrnombre2			char(26);
define chrstatussol			char(2);
define chrnumproducto		char(4);
define chrsitesp			char(1);
define chrrespuesta			char(1);
define chrnumcte			char(20);
define chrnumctecoppel		char(20);
define chrejecutivo			char(30);
define chrdescsitesp		char(80);
define chrrfc				char(13);
define chrnombrezona		char(30);
define chrnombrecalle		char(30);
define chrentrecalles		char(40);
define chrcodpostal			char(5);
define chrnumext			char(10);
define chrnumint			char(10);
define chrobservaciones	    char(80);
define chrestado            char(30);
define chrnombresuc         char(40);
define chrtelsuc            char(14);
define chrnombregte         char(40);
define chrtelefono          char(13);

define vchrpregunta         varchar(80);
define vchrrespuesta		varchar(80);
define vchrrespuesta1		varchar(80);
define vchrrespuesta2		varchar(80);
define vchrrespuesta3		varchar(80);
define vchrrespuesta4		varchar(80);
define vchrrespuesta5		varchar(80);
define vchrrespuesta6		varchar(80);
define vchrrespuesta7		varchar(80);
define vchrrespuesta8		varchar(80);
define vchrrespuesta9		varchar(80);
define vchrrespuesta10		varchar(80);
define vchrpregunta11		varchar(80);
define vchrrespuesta11		varchar(80);
define vchrrespuesta12		varchar(80);
define vchrrespuesta13		varchar(80);
--PQ
define vchrrespuesta14      varchar(80);
define vchrrespuesta15      varchar(80);
define vchrrespuesta16      varchar(80);
define vchrrespuesta17      varchar(80);
--PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
define vchrrespuesta18      varchar(80);
define vchrrespuesta19      varchar(80);
define vchrrespuesta20      varchar(80);
define vchrrespuesta21      varchar(80);
define vchrrespuesta22      varchar(80);
define vchrrespuesta23      varchar(80);
define vchrrespuesta24      varchar(80);
define vchrrespuesta25      varchar(80);
define vchrrespuesta26      varchar(80);
define vchrrespuesta27      varchar(80);
define vchrrespuesta28      varchar(80);
define vchrrespuesta29      varchar(80);
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
define vchrrespuestacc		varchar(100);
define vchrciudad           varchar(200);
--JOM
define vchrclaciucobr       varchar(10);
define vchrclaedocobr       varchar(10);
define vrhrclaregcobr		varchar(20);
--JOM

define declincred			decimal(18,2);
define deceficponderada		decimal(5,2);
define decvalor				decimal(5,2);
define decvalor1			decimal(5,2);
define decvalor2			decimal(5,2);
define decvalor3			decimal(5,2);
define decvalor4			decimal(5,2);
define decvalor5			decimal(5,2);
define decvalor6			decimal(5,2);
define decvalor7			decimal(5,2);
define decvalor8			decimal(5,2);
define decvalor9			decimal(5,2);
define decvalor10			decimal(5,2);
define decvalor11			decimal(5,2);
define decvalor12			decimal(5,2);
define decvalor13			decimal(5,2);
--PQ
define decvalor14			decimal(5,2);
define decvalor15			decimal(5,2);
define decvalor16			decimal(5,2);
define decvalor17			decimal(5,2);
--PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
define decvalor18			decimal(10,4);
define decvalor19			decimal(5,2);
define decvalor20			decimal(5,2);
define decvalor21			decimal(5,2);
define decvalor22			decimal(5,2);
define decvalor23			decimal(5,2);
define decvalor24			decimal(5,2);
define decvalor25			decimal(5,2);
define decvalor26			decimal(5,2);
define decvalor27			decimal(5,2);
define decvalor28			decimal(5,2);
define decvalor29			decimal(5,2);
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
define decseccion1			decimal(14,2);
define decseccion2			decimal(14,2);
define decsuma				decimal(14,2);
define decauxsec2			decimal(5,2);

define intmeses			    smallint;
define intcausasitesp		smallint;
define intcontador			smallint;
define intgrupo             smallint;
define intelemento			smallint;
define intsmb               smallint;
define intgrupoaux          smallint;
define intelementoaux       smallint;
define intnumcobranza       smallint;

define dtefechasol			date;
define dtefecharesp			date;
define dtefechanac			date;

define intcodret			integer;

define mnyingreso           money(14,2);
define mnyingresosmb        money(14,2);
define mnyimporte1          money(9,2);

--PQ
define dEvaluacion1         decimal(14,2);
define dEvaluacion2         decimal(14,2);
define dSuma                decimal(14,2);
define iCantidad            integer;
--PQ
define icontadorcommit      integer;
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
define dSdoropa             decimal(14,2);
define dSdomuebles          decimal(14,2);
define dSdoprestamo         decimal(14,2);
define dSdolineatienda      decimal(14,2);
define cPrueba              char(03);
define cFiltroC             char(10);
define cbcscore             char(04);
define ctipoc               char(10);
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO

--JANETH INI AGREGAR VARIABLES PARA CALCULO DE COMPROMISOS
--DEFINE scod_ret      VARCHAR(255);
DEFINE vfecha        		DATE;
DEFINE v_compromisos 		DECIMAL(14,2);
DEFINE v_causa           	VARCHAR(255);
DEFINE v_status       		VARCHAR(255);
DEFINE v_fecha_apert     DATE;
define v_fuente				char(10);
--define v_lincrerecom		DECIMAL(18,2);

--JANETH FIN AGREGAR VARIABLES PARA CREACION DEL ARCHIVO
define cNombreArchivo		char(70);
DEFINE cSQL                 CHAR(2204);

--debug flag
--set debug file to "ss_reportesolicitudes.out";
--trace on;

set isolation to dirty read;
set lock mode to wait 3;

begin

    on exception set intcodret
    if intcodret <> 0 then
        let chrcodret  = intcodret;
        let chrmensaje = 'Error en la ejecución del REPORTE DE SOLICITUDES ' || chrnumsolicitud;
        rollback work;
        return chrcodret,chrmensaje;
    end if;
    end exception;

	--Inicializacion de variables
	let chrcodret			="000000";
    let chrmensaje          = 'El proceso REPORTE DE SOLICITUDES se ejecutó exitosamente';
	let chrnumsolicitud		="";
	let chrsucursal			="";
	let chrappaterno		="";
	let chrapmaterno		="";
	let chrnombre1			="";
	let chrnombre2			="";
	let chrstatussol		="";
	let chrnumproducto		="";
	let chrsitesp			="";
	let chrrespuesta		="";
	let chrnumcte			="";
	let chrnumctecoppel		="";
	let chrejecutivo		="";
	let chrdescsitesp		="";
	let chrrfc				="";
	let chrnombrezona		="";
	let chrnombrecalle		="";
	let chrentrecalles		="";
	let chrcodpostal		="";
	let chrnumext			="";
	let chrnumint			="";
	let chrobservaciones	="";
    let chrestado           ="";
    let chrnombresuc        ="";
    let chrtelsuc           ="";
    let chrnombregte        ="";
    let chrtelefono         ="";
	let vchrpregunta		="";
	let vchrrespuesta		="";
	let vchrrespuesta1		="";
	let vchrrespuesta2		="";
	let vchrrespuesta3		="";
	let vchrrespuesta4		="";
	let vchrrespuesta5		="";
	let vchrrespuesta6		="";
	let vchrrespuesta7		="";
	let vchrrespuesta8		="";
	let vchrrespuesta9		="";
	let vchrrespuesta10		="";
	let vchrrespuesta11		="";
	let vchrrespuesta12		="";
	let vchrrespuesta13		="";
--PQ
	let vchrrespuesta14		="";
	let vchrrespuesta15		="";
	let vchrrespuesta16		="";
	let vchrrespuesta17		="";
--PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
	let vchrrespuesta18		="";
	let vchrrespuesta19 	="";
	let vchrrespuesta20		="";
	let vchrrespuesta21		="";
	let vchrrespuesta22		="";
	let vchrrespuesta23		="";
	let vchrrespuesta24		="";
	let vchrrespuesta25		="";
	let vchrrespuesta26		="";
	let vchrrespuesta27		="";
	let vchrrespuesta28		="";
	let vchrrespuesta29		="";
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO

    let vchrrespuestacc		="";
    let vchrciudad          ="";
--jom claves de cobranza
    let vchrclaciucobr      ="";
    let vchrclaedocobr      ="";
	let vrhrclaregcobr		="";
--jom claves de cobranza

	let declincred			=0;
	let deceficponderada	=0;
	let decvalor			=0;
	let decvalor1			=0;
	let decvalor2			=0;
	let decvalor3			=0;
	let decvalor4			=0;
	let decvalor5			=0;
	let decvalor6			=0;
	let decvalor7			=0;
	let decvalor8			=0;
	let decvalor9			=0;
	let decvalor10			=0;
	let decvalor11			=0;
	let decvalor12			=0;
	let decvalor13			=0;
--PQ
	let decvalor14			=0;
	let decvalor15			=0;
	let decvalor16			=0;
	let decvalor17			=0;
--PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
    let decvalor18         =0;
    let decvalor19         =0;
    let decvalor20         =0;
    let decvalor21         =0;
    let decvalor22         =0;
    let decvalor23         =0;
    let decvalor24         =0;
    let decvalor25         =0;
    let decvalor26         =0;
    let decvalor27         =0;
    let decvalor28         =0;
    let decvalor29         =0;
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
	let decseccion1			=0;
	let decseccion2			=0;
	let decsuma				=0;
	let intmeses			=0;
	let intcausasitesp		=0;
	let intcontador			=0;
	let intcodret			=0;
	let intgrupo            =0;
	let intelemento			=0;
    let intsmb              =0;
    let intgrupoaux         =0;
    let intelementoaux      =0;
-- jom let intnumcobranza   =0;
	let decauxsec2			=0;
    let mnyingreso          =0;
    let mnyingresosmb       =0;

--PQ
    let dEvaluacion1        =0;
    let dEvaluacion2        =0;
    let dSuma               =0;
    let iCantidad           =0;
--PQ
    let icontadorcommit     =0;
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
    let dSdoropa             =0;
    let dSdomuebles          =0;
    let dSdoprestamo         =0;
    let dSdolineatienda      =0;
    let cPrueba              = '';
    let cFiltroC             = '';
    let cbcscore             = '';
    let ctipoc               = '';
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO


--JANETH INI AGREGAR VARIABLES PARA CALCULO DE COMPROMISOS

	 --LET scod_ret      = "";
     LET v_compromisos 		= 0;
	 LET v_causa       		= "";
	 LET v_status   		= "";
     LET v_fecha_apert = DATE(1);
	 let v_fuente = "";

--JANETH FIN AGREGAR VARIABLES PARA CREACION DE ARCHIVO


--	begin work;

	drop table "informix".ss_solicitudes_demo;

    CREATE TABLE "informix".ss_solicitudes_demo (
        numsolicitud  	CHAR(20),
        numcte        	CHAR(20),
        numctecoppel  	CHAR(20),
        sucursal      	CHAR(4),
        nombresuc     	CHAR(40),
        telsuc        	CHAR(14),
        nombregte     	CHAR(40),
        appaterno     	CHAR(26),
        apmaterno     	CHAR(26),
        nombre1       	CHAR(26),
        nombre2       	CHAR(26),
        rfc           	CHAR(13),
        fechanac      	DATE,
        calle         	CHAR(30),
        numext        	CHAR(10),
        numint        	CHAR(10),
        colonia       	CHAR(30),
        claciucobr    	CHAR(10),
        claedocobr    	CHAR(10),
        codpostal     	CHAR(5),
        entrecalles   	CHAR(40),
        telefono      	CHAR(13),
        estado        	CHAR(30),
        localidad     	VARCHAR(200),
        observaciones 	CHAR(80),
        statussol     	CHAR(2),
        fechasol      	DATE,
        numproducto   	CHAR(4),
        respuesta     	CHAR(1),
        fecharesp     	DATE,
        ejecutivo     	CHAR(30),
        ingresomensual	MONEY,
        ingresosmb    	MONEY,
        lincred       	DECIMAL(18,2),
        eficponderada 	DECIMAL(5,2),
        meses         	SMALLINT,
        sitesp        	CHAR(1),
        causasitesp   	SMALLINT,
        descsitesp    	CHAR(80),
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
        tipocliente     CHAR(10),
        filtrocliente   CHAR(10),
        saldoropa       DECIMAL(18,2),
        saldomuebles    DECIMAL(18,2),
        saldoprestamo   DECIMAL(18,2),
        lineatienda     DECIMAL(18,2),
        bcscore         CHAR(04),
        prueba          CHAR(03),
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO        
        respuestacc   	VARCHAR(100),
        sexo    		VARCHAR(80),
        valor_sexo        	DECIMAL(5,2),
        edo_civil     		VARCHAR(80),
        valor_edocivil      DECIMAL(5,2),
        tmp_edocivil    	VARCHAR(80),
        valor_tmpedocivil       	DECIMAL(5,2),
        tipo_residencia    			VARCHAR(80),
        valor_tipo_residencia       DECIMAL(5,2),
        tmp_residencia    		VARCHAR(80),
        valor_tmp_resid       	DECIMAL(5,2),
        ocupacion    			VARCHAR(80),
        valor_ocupacion        	DECIMAL(5,2),
        tmp_ocup_actual    		VARCHAR(80),
        valor_ocup_actual       DECIMAL(5,2),
        tmp_trab_anterior    	VARCHAR(80),
        valor_trab_anterior     DECIMAL(5,2),
        edad_puntual    		VARCHAR(80),
        valor_edad        		DECIMAL(5,2),
        dep_econom   			VARCHAR(80),
        valor_dep_econom       	DECIMAL(5,2),
        respuesta11   			VARCHAR(80),
        valor11       			DECIMAL(5,2),
        decl_imptos   			VARCHAR(80),
        valor_decl_imptos      	DECIMAL(5,2),
        seguro_popular   		VARCHAR(80),
        valor_seguro_popular    DECIMAL(5,2),
        ingreso_cliente   		VARCHAR(80) DEFAULT '',
        valor_ingreso_cliente	DECIMAL(5,2) DEFAULT 0.00,
        escolaridad   			VARCHAR(80) DEFAULT '',
        valor_escolaridad       DECIMAL(5,2) DEFAULT 0.00,
        hab_domic   			VARCHAR(80) DEFAULT '',
        valor_hab_domic       	DECIMAL(5,2) DEFAULT 0.00,
        ant_plaza   			VARCHAR(80) DEFAULT '',
        valor_ant_plaza       	DECIMAL(5,2) DEFAULT 0.00,
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
        BC_1   			VARCHAR(80) DEFAULT '',
        valor_BC_1      DECIMAL(10,4) DEFAULT 0.00,
        BC_101   		VARCHAR(80) DEFAULT '',
        valor_BC_101    DECIMAL(5,2) DEFAULT 0.00,
        BC_117   		VARCHAR(80) DEFAULT '',
        valor_BC_117    DECIMAL(5,2) DEFAULT 0.00,
        BC_119   		VARCHAR(80) DEFAULT '',
        valor_BC_119    DECIMAL(5,2) DEFAULT 0.00,
        BC_20   		VARCHAR(80) DEFAULT '',
        valor_BC_20     DECIMAL(5,2) DEFAULT 0.00,
        BC_421   		VARCHAR(80) DEFAULT '',
        valor_BC_421    DECIMAL(5,2) DEFAULT 0.00,
        BC_85   		VARCHAR(80) DEFAULT '',
        valor_BC_85     DECIMAL(5,2) DEFAULT 0.00,
        BC_93   	VARCHAR(80) DEFAULT '',
        valor_BC_93       	DECIMAL(5,2) DEFAULT 0.00,
        calc_PCT_saldo_linea   	VARCHAR(80) DEFAULT '',
        valor_calc_PCT_saldo_linea       	DECIMAL(5,2) DEFAULT 0.00,
        meses_historia   	VARCHAR(80) DEFAULT '',
        valor_meses_historia       	DECIMAL(5,2) DEFAULT 0.00,
        situacion_pago   	VARCHAR(80) DEFAULT '',
        valor_situacion_pago       	DECIMAL(5,2) DEFAULT 0.00,
        ratio_saldo_credit_limit   	VARCHAR(80) DEFAULT '',
        valor_ratio_saldo_credit_limit       	DECIMAL(5,2) DEFAULT 0.00,
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
        seccion1      	DECIMAL(14,2),
        seccion2      	DECIMAL(14,2),
        sumascoring   	DECIMAL(14,2),
		--JANETH SE AGREGAN CAMPOS : CAUSAS/CANCELACION-RECHAZO, COMENTARIO STATUS, COMPROMISO MENSUAL, FECHA APERTURA, EDAD, E-MAIL, TEL OFIC, TEL CEL.	Y FUENTE
		causa           VARCHAR(255),
		status       VARCHAR(255),
		compromisos     DECIMAL(14,2),
		fecha_apert     DATE,
		claregcobr		char(20),
		lincrerecom		DECIMAL(18,2) DEFAULT 0.00,
		grupo     		CHAR(03)
        );

--    alter table ss_riesgos_os type (RAW);

	foreach with hold
        select nvl(trim(sol.num_solicitud),''),nvl(trim(sol.numcte),''),nvl(trim(sol.sucursal),''),nvl(trim(suc.nombre),''),
               nvl(trim(suc.telefono1),''),nvl(trim(suc.gerente),''),nvl(trim(cli.apell_paterno),''),nvl(trim(cli.apell_materno),''),
               nvl(trim(cli.nombre1),''),nvl(trim(cli.nombre2),''),nvl(trim(cli.numcte_ref),''),nvl(trim(cli.rfc),''),
               cte.fecha_nac,trim(sol.status_solicitud),sol.fecha_insert,trim(sol.num_producto),nvl(sol.monto_solicitado,0),
               nvl(res.situacion_pago,0),nvl(res.meses_historia,0),nvl(trim(sol.user_insert),''),nvl(trim(res.motivo_cc),''),
               nvl(res.saldoropa,0), nvl(res.saldomuebles,0), nvl(res.saldoprestamos,0), nvl(res.linea_tienda,0),case when dia_para_revisar is not null or dia_para_revisar <> '' then 'E84' else '' end,--cPrueba
               case when evalua_cc = 'X' then 'NO HIT' else 'HIT' end,          --cFiltroC
               case when meses_historia >= 13 and situacion_pago >= 85 then 'I'
                    when meses_historia >= 6 and situacion_pago >= 85 then 'II'
               else 'III' end
        into chrnumsolicitud,chrnumcte,chrsucursal,chrnombresuc,
             chrtelsuc,chrnombregte,chrappaterno,chrapmaterno,
             chrnombre1,chrnombre2,chrnumctecoppel,chrrfc,
             dtefechanac,chrstatussol,dtefechasol,chrnumproducto,declincred,
             deceficponderada,intmeses,chrejecutivo,vchrrespuestacc,
             dSdoropa,dSdomuebles,dSdoprestamo,dSdolineatienda, cPrueba, cFiltroC,ctipoc
		from bdisolic:ss_solicitudes sol
        left outer join bdinteg:si_cliente cli on(cli.numcte=sol.numcte)
        left outer join bdisolic:ss_resum_scor_fin res on(res.empresa=sol.empresa and res.num_solicitud=sol.num_solicitud)
        left outer join bdinteg:si_ctepf cte on(cte.numcte=cli.numcte)
        left outer join bdinteg:si_sucursales suc on(suc.sucursal=sol.sucursal and suc.empresa=sol.empresa)
        where sol.empresa='001' and cli.tpo_persona='01' and sol.fecha_insert >= '06-01-2010' and sol.fecha_insert <= '06-30-2011'

        if (icontadorcommit = 0) then
          begin work;
        end if;

		----- jpc
		select trim(e.descripcion),
              (select descripcion from ss_status_sol where empresa='001' and status_solicitud = a.status_solicitud),
--            c.comentario , 
			b.fecha_apertura,  
			decode(f.fuente,'T','TIENDA','B','BANCO','','BANCO'),pago_minimo
				into v_causa, v_status, v_fecha_apert,v_fuente, v_compromisos	 
				from  bdisolic:ss_solicitudes a 
                left join bdicred:sd_maecred b on (a.empresa = b.empresa and a.num_solicitud = b.num_credito)  
                inner join bdisolic:ss_autorizacion c on ( c.empresa = a.empresa
                                                    and c.num_solicitud = a.num_solicitud
                                                    and c.status_solicitud = a.status_solicitud
                                                    and c.rowid = (select max(rowid) 
																			 from bdisolic:ss_autorizacion 
																			  where empresa = a.empresa
																				and num_solicitud = a.num_solicitud
																				and status_solicitud = a.status_solicitud))                                                    
                left outer join bdisolic:ss_causas_sol e on (a.empresa = e.empresa 
                                                            and e.status_solicitud  = c.status_solicitud 
                                                            and e.causa_solicitud = c.causa_solicitud)
				inner join bdinteg:si_ctepf cte ON (a.numcte = cte.numcte)
				inner join bdisolic:ss_resum_scor_fin f on (a.empresa=f.empresa and a.num_solicitud=f.num_solicitud)
				where a.empresa = '001' and a.num_solicitud = chrnumsolicitud;

        if v_causa is null then let v_causa = ''; end if;    if v_status is null then let v_status = ''; end if;    if v_fecha_apert is null then let v_fecha_apert = ''; end if;
        if v_fuente is null then let v_fuente = ''; end if;    if v_compromisos is null then let v_compromisos = 0; end if;

        --Obtiene la direccion del cliente(persona fisica)
        select nvl(trim(replace(dir.entre_calles,'|','')),''),nvl(trim(dir.cod_postal),''),nvl(trim(dir.numeroextcalle),''),
               nvl(trim(dir.numerointcalle),''),nvl(trim(cal.nombrecalle),''),nvl(trim(zon.nombrezona),''),
               nvl(trim(replace(dir.observaciones,'|','')),''),nvl(trim(edo.nombre),''),nvl(trim(ciu.nombre),''),nvl(trim(dir.telefono1),''),
--JOM          nvl(zon.numerocobranzas,0)
               dir.numerociudad || '-' || trim(catciu.inicialciudad) Ciudad, -- Clave ciudad
               catciu.numeroestado || '-' || trim(catciu.inicialestado) Estado, -- Clave estado
			   reg.nombre_region Region --Region cobranza
        into chrentrecalles,chrcodpostal,chrnumext,
             chrnumint,chrnombrecalle,chrnombrezona,
             chrobservaciones,chrestado,vchrciudad,chrtelefono,
--JOM        intnumcobranza
             vchrclaciucobr, vchrclaedocobr,vrhrclaregcobr
		from bdinteg:si_direcciones_actual dir
        left outer join bdinteg:si_catcalles cal on(cal.numerocalle=dir.numerocalle)
        left outer join bdinteg:si_catzonas zon on(zon.numerociudad=dir.numerociudad and zon.numerocolonia=dir.numerocolonia)
        left outer join bdinteg:si_estados edo on(edo.pais='001' and edo.estado=dir.estado)
        left outer join bdinteg:si_ciudades ciu on(ciu.pais=dir.pais and ciu.estado=dir.estado and ciu.ciudad=dir.ciudad)
        left outer join bdinteg:si_catciudades catciu on (dir.numerociudad = catciu.numerociudad)
		left outer join bdinteg:si_regiones reg on (catciu.numero_region = reg.numero_region)
		where dir.numcte=chrnumcte and dir.tipo_dir='1';
 
        --Obtiene la respuesta de la os y su fecha
        select nvl(trim(status),''),fecha_respuesta
		into chrrespuesta,dtefecharesp
		from bdisolic:ss_solicitud_os
		where empresa='001' and num_solicitud = chrnumsolicitud and
		fecha_solicitud =
		(
			select max(fecha_solicitud) from bdisolic:ss_solicitud_os
			where empresa='001' and num_solicitud = chrnumsolicitud and fecha_solicitud > date(0)
		);

        if chrrespuesta is null then
            let chrrespuesta = '';
        end if;

		--Obtiene la situacion especial de la os y su causa
        select nvl(trim(situacionespecial),''),nvl(causasituacionespecial,0)
		into chrsitesp,intcausasitesp
		from bdisolic:ss_osclientesupervisar
		where empresa='001' and num_solicitud = chrnumsolicitud and
		fechasolicitud =
		(
			select max(fechasolicitud) from bdisolic:ss_osclientesupervisar
			where empresa='001' and num_solicitud = chrnumsolicitud and fechasolicitud > date(0)
		);

        if chrsitesp is not null and intcausasitesp is not null then
            --Obtiene la explicacion de la causa de la situacion especial del cliente
            if exists (select nvl(trim(descripcion),'') from bdicred:sd_causas_os
                where empresa = '001' and situacion = chrsitesp and causa = intcausasitesp) then

                select nvl(trim(descripcion),'') into chrdescsitesp from bdicred:sd_causas_os
                where empresa = '001' and situacion = chrsitesp and causa = intcausasitesp;
            else
                let chrdescsitesp = '';
            end if;
        else
            let intcausasitesp = 0;
            let chrsitesp = '';
            let chrdescsitesp = '';
        end if;

        --Obtiene el parametro del Salario Minimo BanCoppel
        select nvl(valor,0)*1 into intsmb
        from bdisolic:ss_param
        where secuencia = 303 and empresa = '001';

        --Obtiene el ingreso mensual declarado por el cliente y el ingreso en SMB
        select round(nvl(ingreso_mensual,0),2) into mnyingreso
        from bdisolic:ss_resum_scor_fin
        where empresa = '001' and num_solicitud = chrnumsolicitud;

        let mnyingresosmb = round(nvl(mnyingreso,0)/intsmb);

		--Obtiene el detalle del scoring seccion 2
        
        let vchrrespuesta1      ="";
        let vchrrespuesta2      ="";
        let vchrrespuesta3      ="";
        let vchrrespuesta4      ="";
        let vchrrespuesta5      ="";
        let vchrrespuesta6      ="";
        let vchrrespuesta7      ="";
        let vchrrespuesta8      ="";
        let vchrrespuesta9      ="";
        let vchrrespuesta10     ="";
        let vchrrespuesta11     ="";
        let vchrrespuesta12     ="";
        let vchrrespuesta13     ="";
        --PQ
        let vchrrespuesta14     ="";
        let vchrrespuesta15     ="";
        let vchrrespuesta16     ="";
        let vchrrespuesta17     ="";
        --PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
        let vchrrespuesta18     ="";
        let vchrrespuesta19     ="";
        let vchrrespuesta20     ="";
        let vchrrespuesta21     ="";
        let vchrrespuesta22     ="";
        let vchrrespuesta23     ="";
        let vchrrespuesta24     ="";
        let vchrrespuesta25     ="";
        let vchrrespuesta26     ="";
        let vchrrespuesta27     ="";
        let vchrrespuesta28     ="";
        let vchrrespuesta29     ="";
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
        let decvalor1           =0;
        let decvalor2           =0;
        let decvalor3           =0;
        let decvalor4           =0;
        let decvalor5           =0;
        let decvalor6           =0;
        let decvalor7           =0;
        let decvalor8           =0;
        let decvalor9           =0;
        let decvalor10          =0;
        let decvalor11          =0;
        let decvalor12          =0;
        let decvalor13          =0;
        --PQ
        let decvalor14         =0;
        let decvalor15         =0;
        let decvalor16         =0;
        let decvalor17         =0;
        --PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
        let decvalor18         =0;
        let decvalor19         =0;
        let decvalor20         =0;
        let decvalor21         =0;
        let decvalor22         =0;
        let decvalor23         =0;
        let decvalor24         =0;
        let decvalor25         =0;
        let decvalor26         =0;
        let decvalor27         =0;
        let decvalor28         =0;
        let decvalor29         =0;
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO

        let intcontador        =0;
		foreach
			select trim(a.descripcion),trim(c.descripcion),nvl(b.valor,0),a.grupo,c.elemento
			into vchrpregunta,vchrrespuesta,decvalor,intgrupo,intelemento
			from ss_scoring_grupo a, ss_detalle_scoring b, ss_scoring_element c
            where a.empresa = '001' and a.seccion = 2
			and b.num_solicitud = chrnumsolicitud
			and b.tpo_persona = '01'
			and a.empresa = b.empresa
            and a.grupo <> 25 --JCP Grupo OS Telefonica
			and a.grupo = b.grupo
			and a.grupo = c.grupo
			and a.seccion = b.seccion
			and a.seccion = c.seccion
			and b.elemento = c.elemento
			and b.tpo_persona = c.tpo_persona
			order by b.seccion, b.grupo, b.elemento

			if intgrupo = 2 then
				let vchrrespuesta1 = vchrrespuesta;
				let decvalor1 = decvalor;
			elif intgrupo = 3 then
                let intelementoaux = intelemento;
                let intgrupoaux = intgrupo;
				let vchrrespuesta2 = vchrrespuesta;
				let decvalor2 = decvalor;
			elif intgrupo = 4 then
                let vchrrespuesta3 = vchrrespuesta;
                let decvalor3 = decvalor;
			elif intgrupo = 5 then
				let vchrrespuesta4 = vchrrespuesta;
				let decvalor4 = decvalor;
			elif intgrupo = 6 then
				let vchrrespuesta5 = vchrrespuesta;
				let decvalor5 = decvalor;
			elif intgrupo = 7 then
				let vchrrespuesta6 = vchrrespuesta;
				let decvalor6 = decvalor;
			elif intgrupo = 8 then
                let intelementoaux = intelemento;
                let intgrupoaux = intgrupo;
				let vchrrespuesta7 = vchrrespuesta;
				let decvalor7 = decvalor;
			elif intgrupo = 9 then
                let vchrrespuesta8 = vchrrespuesta;
                let decvalor8 = decvalor;
            elif intgrupo = 10 then
				let vchrrespuesta9 = vchrrespuesta;
				let decvalor9 = decvalor;
			elif intgrupo = 11 then
				let vchrrespuesta10 = vchrrespuesta;
				let decvalor10 = decvalor;
			elif intgrupo = 12 then
				let vchrrespuesta11 = vchrrespuesta;
				let decvalor11 = decvalor;
			elif intgrupo = 13 or intgrupo = 14 or intgrupo = 15 then
				if intcontador = 0 then
					let vchrrespuesta12 = vchrrespuesta;
					let decvalor12 = decvalor;
					let intcontador = 1;
                --PQ
				elif intelemento in (1,3) then
                    if decvalor > decvalor12 then
                        let vchrrespuesta12 = vchrrespuesta;
                        let decvalor12 = decvalor;
                    end if;
				end if;
                --PQ
			elif intgrupo = 16 then
				let vchrrespuesta13 = vchrrespuesta;
				let decvalor13 = decvalor;
            --PQ
            elif intgrupo = 20  then
				let vchrrespuesta14 = vchrrespuesta;
				let decvalor14 = decvalor;
			elif intgrupo = 21  then
				let vchrrespuesta15 = vchrrespuesta;
				let decvalor15 = decvalor;
			elif intgrupo = 22  then
				let vchrrespuesta16 = vchrrespuesta;
				let decvalor16 = decvalor;
			elif intgrupo = 23  then
				let vchrrespuesta17 = vchrrespuesta;
				let decvalor17 = decvalor;
            --PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
			elif intgrupo = 26  then
				let vchrrespuesta18 = vchrrespuesta;
				let decvalor18 = decvalor;
			elif intgrupo = 27  then
				let vchrrespuesta19 = vchrrespuesta;
				let decvalor19 = decvalor;
			elif intgrupo = 28  then
				let vchrrespuesta20 = vchrrespuesta;
				let decvalor20 = decvalor;
			elif intgrupo = 29  then
				let vchrrespuesta21 = vchrrespuesta;
				let decvalor21 = decvalor;
			elif intgrupo = 30  then
				let vchrrespuesta22 = vchrrespuesta;
				let decvalor22 = decvalor;
			elif intgrupo = 31  then
				let vchrrespuesta23 = vchrrespuesta;
				let decvalor23 = decvalor;
			elif intgrupo = 32  then
				let vchrrespuesta24 = vchrrespuesta;
				let decvalor24 = decvalor;
			elif intgrupo = 33  then
				let vchrrespuesta25 = vchrrespuesta;
				let decvalor25 = decvalor;
			elif intgrupo = 34  then
				let vchrrespuesta26 = vchrrespuesta;
				let decvalor26 = decvalor;
			elif intgrupo = 35  then
				let vchrrespuesta27 = vchrrespuesta;
				let decvalor27 = decvalor;
			elif intgrupo = 36  then
				let vchrrespuesta28 = vchrrespuesta;
				let decvalor28 = decvalor;
			elif intgrupo = 37  then
				let vchrrespuesta29 = vchrrespuesta;
				let decvalor29 = decvalor;
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
            end if;

		end foreach;


                --PQ
                SELECT
                        nvl(SUM(decode(seccion, '1', nvl(evaluacion,0), 0)),0) AS seccion1,
                        nvl(SUM(decode(seccion, '2', nvl(evaluacion,0), 0)),0) AS seccion2,
                        nvl(SUM(nvl(evaluacion, 0)),0) AS Suma,
                        COUNT(num_solicitud) AS Cantidad
                INTO dEvaluacion1, dEvaluacion2, dSuma, iCantidad
                FROM bdisolic:ss_resumen_scoring
                WHERE empresa= '001'
                AND seccion in ('1', '2')
                AND num_solicitud = chrnumsolicitud;
                --PQ

                --PQ
                IF iCantidad = 2 THEN

                        let decseccion1= dEvaluacion1;
                        let decseccion2= dEvaluacion2;
                        let decsuma= dSuma;

                ELSE
{
                        --Obtiene el total del scoring de la seccion 1
                        select nvl(sum(nvl(puntuacion,0)),0)
                        into decseccion1
                        from bdisolic:ss_scoring_financ sf, bdisolic:ss_resum_scor_fin rsf
                        where rsf.empresa = '001' and rsf.num_solicitud = chrnumsolicitud and rsf.empresa = sf.empresa
                        and upper(sf.tp_solicitud) = 'T' and sf.circulo_credito = evalua_cc
                        and sf.min_mes_hist <= rsf.meses_historia
                        and sf.max_mes_hist >= rsf.meses_historia
                        and sf.min_porc_pago <= rsf.situacion_pago
                        and sf.max_porc_pago >= rsf.situacion_pago;
}
                        --Obtiene el total del scoring de la seccion 2
                        --PQ

                        let decseccion2 = decvalor1 + decvalor2 + decvalor3 + decvalor4 + decvalor5 + decvalor6 + decvalor7 +
                                          decvalor8 + decvalor9 + decvalor10 + decvalor11 + decvalor12 + decvalor13 +
                                          decvalor14 + decvalor15 +  decvalor16 + decvalor17;
                        --PQ
                        LET decseccion1 = dEvaluacion2 - decseccion2;

                        --Obtiene el total del scoring del cliente
                        let decsuma = decseccion1 + decseccion2;

                 END IF;
                 --PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
        select first 1 nvl(sc01,'')
          into cbcscore
          from bdiburo:br_sc
         where num_cliente = chrnumcte;

		--Inserta en ss_solicitudes_demo para consulta del area de Riesgos

		insert into bdisolic:ss_solicitudes_demo(numsolicitud,numcte,numctecoppel,sucursal,appaterno,apmaterno,nombre1,
					nombre2,statussol,numproducto,sitesp,respuesta,ejecutivo,descsitesp,lincred,eficponderada,
					meses,causasitesp,fechasol,fecharesp,seccion1,seccion2,sumascoring,respuestacc,
					sexo,valor_sexo,edo_civil,valor_edocivil,tmp_edocivil,valor_tmpedocivil,
					tipo_residencia,valor_tipo_residencia,tmp_residencia,valor_tmp_resid,ocupacion,valor_ocupacion,
					tmp_ocup_actual,valor_ocup_actual,tmp_trab_anterior,valor_trab_anterior,edad_puntual,valor_edad,
					dep_econom,valor_dep_econom,respuesta11,valor11,decl_imptos,valor_decl_imptos,
                    seguro_popular,valor_seguro_popular,ingreso_cliente,valor_ingreso_cliente,escolaridad,valor_escolaridad,
                    hab_domic,valor_hab_domic,ant_plaza,valor_ant_plaza, 
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
                    BC_1,valor_BC_1,BC_101,valor_BC_101,BC_117,valor_BC_117, 
                    BC_119,valor_BC_119,BC_20,valor_BC_20,BC_421,valor_BC_421, 
                    BC_85,valor_BC_85,BC_93,valor_BC_93,calc_PCT_saldo_linea,valor_calc_PCT_saldo_linea, 
                    meses_historia,valor_meses_historia,situacion_pago,valor_situacion_pago,ratio_saldo_credit_limit,valor_ratio_saldo_credit_limit, 
                    grupo,filtrocliente,saldoropa,saldomuebles,saldoprestamo,lineatienda,bcscore,prueba,
--AGREGAR VARIABLES JANETH	
					causa,status,compromisos,fecha_apert,tipocliente,				
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
                    calle,numext,numint,colonia,
                    codpostal,entrecalles,observaciones, estado,localidad,nombresuc,telsuc,nombregte,telefono,
                    ingresomensual,ingresosmb,rfc,fechanac,
                    claciucobr,claedocobr,claregcobr)
		values (chrnumsolicitud,chrnumcte,chrnumctecoppel,chrsucursal,chrappaterno,chrapmaterno,chrnombre1,chrnombre2,
				chrstatussol,chrnumproducto,chrsitesp,chrrespuesta,chrejecutivo,chrdescsitesp,declincred,deceficponderada,
				intmeses,intcausasitesp,dtefechasol,dtefecharesp,decseccion1,decseccion2,decsuma,vchrrespuestacc,
				vchrrespuesta1,decvalor1,vchrrespuesta2,decvalor2,vchrrespuesta3,decvalor3,
				vchrrespuesta4,decvalor4,vchrrespuesta5,decvalor5,vchrrespuesta6,decvalor6,
				vchrrespuesta7,decvalor7,vchrrespuesta8,decvalor8,vchrrespuesta9,decvalor9,
				vchrrespuesta10,decvalor10,vchrrespuesta11,decvalor11,vchrrespuesta12,decvalor12,
                vchrrespuesta13,decvalor13,vchrrespuesta14,decvalor14,vchrrespuesta15,decvalor15,
                vchrrespuesta16,decvalor16,vchrrespuesta17,decvalor17, 
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
                vchrrespuesta18,decvalor18,vchrrespuesta19,decvalor19,vchrrespuesta20,decvalor20, 
                vchrrespuesta21,decvalor21,vchrrespuesta22,decvalor22,vchrrespuesta23,decvalor23, 
                vchrrespuesta24,decvalor24,vchrrespuesta25,decvalor25,vchrrespuesta26,decvalor26, 
                vchrrespuesta27,decvalor27,vchrrespuesta28,decvalor28,vchrrespuesta29,decvalor29, 
                ctipoc,cFiltroC,dSdoropa,dSdomuebles,dSdoprestamo,dSdolineatienda,cbcscore,cPrueba,
--AGREGAR VARIABLES JANETH	
				v_causa, v_status,v_compromisos,v_fecha_apert,v_fuente,
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
                chrnombrecalle,chrnumext,chrnumint,chrnombrezona,chrcodpostal,chrentrecalles,chrobservaciones,
                chrestado,vchrciudad,chrnombresuc,chrtelsuc,chrnombregte,chrtelefono,mnyingreso,mnyingresosmb,chrrfc,dtefechanac,
                vchrclaciucobr,vchrclaedocobr,vrhrclaregcobr);

                let icontadorcommit = icontadorcommit + 1;

                if (icontadorcommit >= 70000) then
                   commit work;
                   let icontadorcommit = 0;
                   update statistics medium for table "informix".ss_solicitudes_demo;
                end if;

	end foreach;

    if ( icontadorcommit > 0) then
        commit work;
    end if;

    CREATE INDEX "informix".inx_ss_solicitudes_demo ON "informix".ss_solicitudes_demo(numsolicitud);
    update statistics medium for table "informix".ss_solicitudes_demo;

--	commit work;
	--CREAR  ARCHIVO
	LET cNombreArchivo ='ss_solicitudes_demo'||'1011'||'.txt';
	 LET cSql = '';
             LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/solic.txt''' || ' DELIMITER ' || '''|'''  ||
                ' select * from bdisolic:ss_solicitudes_demo;'||
                ' " > /resplogifx/archivoscartera/Query_solic.sql';

              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdisolic /resplogifx/archivoscartera/Query_solic.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/solic.txt > /resplogifx/archivoscartera/" || trim(cNombreArchivo);
              SYSTEM cSql;

              let cSql = '';

              LET cSql = "rm /resplogifx/archivoscartera/solic.txt /resplogifx/archivoscartera/Query_solic.sql";
              SYSTEM cSql;

return chrcodret,chrmensaje;
end;

end procedure;