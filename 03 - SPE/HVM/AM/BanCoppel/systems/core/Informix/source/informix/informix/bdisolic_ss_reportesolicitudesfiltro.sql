CREATE PROCEDURE "informix".ss_reportesolicitudesfiltro()
returning   char(06),
            char(70);
     
			

--Autor: María Janeth Peinado Cuevas
--Fecha: 26/04/2016
--Actividad: 
----------------------------------------------------------


--Declaracion de variables
define chrcodret			char(06);
define chrmensaje           char(70);
define chrnumsolicitud		char(20);
define chrnumcte			char(20);
define chrnumctecoppel		char(20);
define chrsucursal			char(4);
define chrcodpostal			char(5);
define chrestado            char(30);
define vchrciudad           varchar(200);
define chrstatussol			char(2);
define dtefechasol			date;
define chrnumproducto		char(4);
define chrrespuesta			char(1);
define mnyingreso           money(14,2);
define mnyingresosmb        money(14,2);
define declincred			decimal(18,2);
define deceficponderada		decimal(5,2);
define ctipoc               char(03);
define cFiltroC             char(10);
define dSdoropa             decimal(14,2);
define dSdomuebles          decimal(14,2);
define dSdoprestamo         decimal(14,2);
define dSdolineatienda      decimal(14,2);
define cbcscore             char(04);
define cPrueba              char(03);
DEFINE v_causa          VARCHAR(255);
DEFINE v_status       	VARCHAR(255);
DEFINE v_compromisos 	DECIMAL(14,2);
DEFINE v_fecha_apert     DATE;
DEFINE v_edad            SMALLINT;
DEFINE v_email           CHAR(60);
DEFINE v_tel_ofi         CHAR(13);
DEFINE v_tel_cel         CHAR(13);
DEFINE v_fuente          CHAR(10);
define vchrrespuestacc		varchar(100);
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
define vchrrespuesta13		varchar(80);
--PQ
define vchrrespuesta15      varchar(80);
define vchrrespuesta16      varchar(80);
define vchrpregunta17       varchar(80);
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
define vchrrespuesta30      varchar(80); -- INI se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03
define vchrrespuesta31      varchar(80);
define vchrrespuesta32      varchar(80);
define vchrrespuesta33      varchar(80);
define vchrrespuesta34      varchar(80);
define vchrrespuesta35      varchar(80); -- FIN se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03
--MJPC Valores Puntuales
define varpuntual18 		decimal(10,4);
define varpuntual19 		decimal(10,4);
define varpuntual20 		decimal(10,4);
define varpuntual21 		decimal(10,4);
define varpuntual22 		decimal(10,4);
define varpuntual23 		decimal(10,4);
define varpuntual24 		decimal(10,4);
define varpuntual25 		decimal(10,4);
define varpuntual26 		decimal(10,4);
define varpuntual27 		decimal(10,4);
define varpuntual28 		decimal(10,4);
define varpuntual29 		decimal(10,4);
define varpuntual30 		decimal(10,4); -- INI se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03
define varpuntual31 		decimal(10,4);
define varpuntual32 		decimal(10,4);
define varpuntual33 		decimal(10,4);
define varpuntual35 		decimal(10,4); -- FIN se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03
--JOM
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
define decvalor13			decimal(5,2);
--PQ
define decvalor15			decimal(5,2);
define decvalor16			decimal(5,2);
define decvalor17			decimal(5,2);
--PQ
--JOM INI AGREGAR VARIABLES PRUEBA TESTIGO
define decvalor18			decimal(5,2);
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
define decvalor30			decimal(5,2);
define decvalor31			decimal(5,2);
define decvalor32			decimal(5,2);
define decvalor33			decimal(5,2);
define decvalor34			decimal(5,2);
define decvalor35			decimal(5,2);
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
define decseccion1			decimal(14,2);
define decseccion2			decimal(14,2);
define decsuma				decimal(14,2);

define intcontador			smallint;
define intgrupo             smallint;
define intelemento			smallint;
define intsmb               smallint;
define intgrupoaux          smallint;
define intelementoaux       smallint;
define intcont              smallint;
define dtefecharesp			date;
define intcodret			integer;
define mnyimporte           money(9,2);

--PQ
define dEvaluacion1         decimal(14,2);
define dEvaluacion2         decimal(14,2);
define dSuma                decimal(14,2);
define iCantidad            integer;
--PQ
define icontadorcommit      integer;

--JANETH INI AGREGAR VARIABLES PARA CALCULO DE COMPROMISOS
--DEFINE scod_ret      VARCHAR(255);
DEFINE vfecha        	DATE;


--JANETH FIN AGREGAR VARIABLES PARA CALCULO DE COMPROMISOS
--MJPC respuestas puntuales
define vchsvariable			varchar(80);
define decvalor_punt		decimal(10,4);

-- AGREGAR VARIABLES RQM 07 048-02 Adendum Modificaciones al SolicAAAAMMDD. Septiembre 2012
DEFINE mnyabonomensualmuebles      money(14,2);
DEFINE mnyabonomensualropa         money(14,2); 
DEFINE mnyabonomensualprestamos    money(14,2);
DEFINE mnypago_minimo              money(14,2);
DEFINE chrevalua_cc                char(1);
DEFINE vDia                        char(10);
DEFINE vHora                       char(28);
DEFINE iIsamErr				             integer;
DEFINE cMensajeRet                 char(100);
DEFINE cgrupo_solic                CHAR(1);
 
 --debug flag
 --set debug file to "/informix/macf/ss_reportesolicitudes.trc";
 --trace on;

	--Inicializacion de variables
	let chrcodret			="000000";
    let chrmensaje          = 'El proceso REPORTE DE SOLICITUDES se ejecutó exitosamente';
	let chrnumsolicitud		="";
	let chrsucursal			="";
	let chrstatussol		="";
	let chrnumproducto		="";
	let chrrespuesta		="";
	let chrnumcte			="";
	let chrnumctecoppel		="";
	let chrcodpostal		="";
	let chrestado           ="";
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
	let vchrrespuesta13		="";
--PQ
	let vchrrespuesta15		="";
	let vchrrespuesta16		="";
	let vchrpregunta17		="";
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
	let vchrrespuesta30		="";
	let vchrrespuesta31		="";
	let vchrrespuesta32		="";
	let vchrrespuesta33		="";
	let vchrrespuesta34		="";
	let vchrrespuesta35		="";
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO

    let vchrrespuestacc		="";
    let vchrciudad          ="";

--MJPC Valores Puntuales
	let varpuntual18 		=0;
	let varpuntual19 		=0;
	let varpuntual20 		=0;
	let varpuntual21 		=0;
	let varpuntual22 		=0;
	let varpuntual23 		=0;
	let varpuntual24 		=0;
	let varpuntual25 		=0;
	let varpuntual26 		=0;
	let varpuntual27 		=0;
	let varpuntual28 		=0;
	let varpuntual29 		=0;
	let varpuntual30 		=0;
	let varpuntual31 		=0;
	let varpuntual32 		=0;
	let varpuntual33 		=0;
	let varpuntual35 		=0;
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
	let decvalor13			=0;
--PQ
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
    let decvalor30         =0;
    let decvalor31         =0;
    let decvalor32         =0;
    let decvalor33         =0;
    let decvalor34         =0;
    let decvalor35         =0;
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO
	let decseccion1			=0;
	let decseccion2			=0;
	let decsuma				=0;
	let intcontador			=0;
	let intcodret			=0;
	let intgrupo            =0;
	let intelemento			=0;
    let intsmb              =0;
    let intgrupoaux         =0;
    let intelementoaux      =0;
    let intcont             =0;
    let mnyingreso          =0;
    let mnyingresosmb       =0;
    let mnyimporte          =0;

--PQ
    let dEvaluacion1        =0;
    let dEvaluacion2        =0;
    let dSuma               =0;
    let iCantidad           =0;
    let icontadorcommit     =0;
    let dSdoropa             =0;
    let dSdomuebles          =0;
    let dSdoprestamo         =0;
    let dSdolineatienda      =0;
    let cPrueba              = '';
    let cFiltroC             = '';
    let cbcscore             = '';
    let ctipoc               = '';
	 --LET scod_ret      = "";
     LET v_compromisos = 0;
	 LET v_causa       = "";
	 LET v_status   = "";
     LET v_fecha_apert = DATE(1);
	 LET v_edad        = 0;
	 LET v_email       = "";
	 LET v_tel_ofi     = "";
	 LET v_tel_cel     = "";
	 LET v_fuente      = "";
	let vchsvariable = "";
	let decvalor_punt = 0;

    let mnyabonomensualmuebles   =0;
    let mnyabonomensualropa      =0; 
    let mnyabonomensualprestamos =0;
    let mnypago_minimo           =0;
    let chrevalua_cc        ="";
    let vDia = '';       let vHora = '';
    let iIsamErr = 0;    let cMensajeRet = ''; 
    LET cgrupo_solic = '';

begin

    on exception set intcodret,  iIsamErr, cMensajeRet
    if intcodret <> 0 then
        let chrcodret  = intcodret;
        
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vDia FROM sysmaster:sysshmvals;
        --SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO FRACTION INTO vHora FROM sysmaster:sysshmvals;

        /*INSERT INTO "informix".ss_bitacora_os(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
        VALUES('Reporte de Solicitudes', substr(chrcodret,2,5), cMensajeRet, 'informix', today, vHora);*/
        
        let chrmensaje = 'Error en la ejecución del REPORTE DE SOLICITUDES FILTRO' || chrnumsolicitud;
        rollback work;
        return chrcodret,chrmensaje;
    end if;
 end exception;

  set isolation to dirty read;
  set lock mode to wait 3;

  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vDia FROM sysmaster:sysshmvals;
  SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO FRACTION INTO vHora FROM sysmaster:sysshmvals;

  /*INSERT INTO "informix".ss_bitacora_os(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
    VALUES('Reporte de Solicitudes', '00000', 'Inicio del proceso', 'informix', today, vHora);*/
	
--	begin work;

	drop table "informix".ss_solicitudes_filtro;

    CREATE TABLE "informix".ss_solicitudes_filtro (
        numsolicitud  	CHAR(20),
        numcte        	CHAR(20),
        numctecoppel  	CHAR(20),
        sucursal      	CHAR(4),
        codpostal     	CHAR(5),
        estado        	CHAR(30),
        localidad     	VARCHAR(200),
        statussol     	CHAR(2),
        fechasol      	DATE,
        numproducto   	CHAR(4),
        respuesta     	CHAR(1),
        ingresomensual	MONEY,
        ingresosmb    	MONEY,
        lincred       	DECIMAL(18,2),
        eficponderada 	DECIMAL(5,2),
        tipocliente     CHAR(03),
        filtrocliente   CHAR(10),
        saldoropa       DECIMAL(18,2),
        saldomuebles    DECIMAL(18,2),
        saldoprestamo   DECIMAL(18,2),
        lineatienda     DECIMAL(18,2),
        bcscore         CHAR(04),
        prueba          CHAR(03),
		causa           VARCHAR(255),
		status       	VARCHAR(255),
		compromisos     DECIMAL(14,2),
		fecha_apert     DATE,
		edad_1          SMALLINT,
		email           CHAR(60),
		tel_ofi         CHAR(13),
		tel_cel         CHAR(13),
		fuente          CHAR(10),        
        respuestacc   			VARCHAR(100),
        sexo    				VARCHAR(80),
        valor_sexo        		DECIMAL(5,2),
        estado_civil    		VARCHAR(80),
        valor_estado_civil      DECIMAL(5,2),
        tmpo_edo_civ_act    	VARCHAR(80),
        valor_tmpo_edo_civ_act  DECIMAL(5,2),
        tipo_residencia    		VARCHAR(80),
        valor_tipo_residencia   DECIMAL(5,2),
        tmpo_dom_act    		VARCHAR(80),
        valor_tmpo_dom_act      DECIMAL(5,2),
        ocupacion    			VARCHAR(80),
        valor_ocupacion        	DECIMAL(5,2),
        tmpo_ocup_act    		VARCHAR(80),
        valor_tmpo_ocup_act     DECIMAL(5,2),
        tmpo_ocup_ant    		VARCHAR(80),
        valor_tmpo_ocup_ant     DECIMAL(5,2),
        edad    				VARCHAR(80),
        valor_edad        		DECIMAL(5,2),
        depend_econ   			VARCHAR(80),
        valor_depend_econ      	DECIMAL(5,2),
        seguro_popular   		VARCHAR(80),
        valor_seguro_popular    DECIMAL(5,2),
        escolaridad   			VARCHAR(80) DEFAULT '',
        valor_escolaridad      	DECIMAL(5,2) DEFAULT 0.00,
        hab_domic   			VARCHAR(80) DEFAULT '',
        valor_hab_domic       	DECIMAL(5,2) DEFAULT 0.00,
        pregunta17    			VARCHAR(80) DEFAULT '',
        respuesta17   			VARCHAR(80) DEFAULT '',
        valor17       			DECIMAL(5,2) DEFAULT 0.00,
        BC_1   				VARCHAR(80) DEFAULT '',
		puntual_BC_1		DECIMAL(10,4) DEFAULT 0.00,
        valor_BC_1      	DECIMAL(5,2) DEFAULT 0.00,
        BC_101   			VARCHAR(80) DEFAULT '',
		puntual_BC_101		DECIMAL(10,4) DEFAULT 0.00,
        valor_BC_101       	DECIMAL(5,2) DEFAULT 0.00,
        BC_117   			VARCHAR(80) DEFAULT '',
		puntual_BC_117		DECIMAL(10,4) DEFAULT 0.00,
        valor_BC_117      	DECIMAL(5,2) DEFAULT 0.00,
        BC_119   			VARCHAR(80) DEFAULT '',
		puntual_BC_119		DECIMAL(10,4) DEFAULT 0.00,
        valor_BC_119      	DECIMAL(5,2) DEFAULT 0.00,
        BC_20   			VARCHAR(80) DEFAULT '',
		puntual_BC_20		DECIMAL(10,4) DEFAULT 0.00,
        valor_BC_20       	DECIMAL(5,2) DEFAULT 0.00,
        BC_421   			VARCHAR(80) DEFAULT '',
		puntual_BC_421		DECIMAL(10,4) DEFAULT 0.00,
        valor_BC_421       	DECIMAL(5,2) DEFAULT 0.00,
        BC_85   			VARCHAR(80) DEFAULT '',
		puntual_BC_85		DECIMAL(10,4) DEFAULT 0.00,
        valor_BC_85       	DECIMAL(5,2) DEFAULT 0.00,
        BC_93   			VARCHAR(80) DEFAULT '',
		puntual_BC_93		DECIMAL(10,4) DEFAULT 0.00,
        valor_BC_93       	DECIMAL(5,2) DEFAULT 0.00,
        calc_PCT_saldo_linea				VARCHAR(80) DEFAULT '',
		puntual_calc_PCT_saldo_linea		DECIMAL(10,4) DEFAULT 0.00,
        valor_calc_PCT_saldo_linea       	DECIMAL(5,2) DEFAULT 0.00,
        meses_historia   			VARCHAR(80) DEFAULT '',
		puntual_meses_historia		DECIMAL(10,4) DEFAULT 0.00,
        valor_meses_historia       	DECIMAL(5,2) DEFAULT 0.00,
        situacion_pago   			VARCHAR(80) DEFAULT '',
		puntual_situacion_pago		DECIMAL(10,4) DEFAULT 0.00,
        valor_situacion_pago       	DECIMAL(5,2) DEFAULT 0.00,
        ratio_saldo_credit_limit   	VARCHAR(80) DEFAULT '',
		puntual_ratio_saldo_credit_limit		DECIMAL(10,4) DEFAULT 0.00,
        valor_ratio_saldo_credit_limit      	DECIMAL(5,2) DEFAULT 0.00,
        seccion1      	DECIMAL(14,2),
        seccion2      	DECIMAL(14,2),
        sumascoring   	DECIMAL(14,2),
        abono_muebles                money(14,2), -- abonomensualmuebles
        abono_ropa                   money(14,2), -- abonomensualropa
        abono_prestamos              money(14,2), -- abonomensualprestamos
        compromisos_mensuales        money(14,2), -- pago_minimo
        evalua_cc                    char(1),
        VI_EdoCiv_TmpoEdoCiv            VARCHAR(80) DEFAULT '',
		puntual_VI_EdoCiv_TmpoEdoCiv	DECIMAL(10,4) DEFAULT 0.00,
        valor_VI_EdoCiv_TmpoEdoCiv      DECIMAL(5,2) DEFAULT 0.00,
        VI_MesesHist_CteNvo             VARCHAR(80) DEFAULT '',
		puntual_VI_MesesHist_CteNvo     DECIMAL(10,4) DEFAULT 0.00,
        valor_VI_MesesHist_CteNvo       DECIMAL(5,2) DEFAULT 0.00,
        VI_CalcPctSdoLin_CteNvo   		VARCHAR(80) DEFAULT '',
		puntual_VI_CalcPctSdoLin_CteNvo DECIMAL(10,4) DEFAULT 0.00,
        valor_VI_CalcPctSdoLin_CteNvo   DECIMAL(5,2) DEFAULT 0.00,
        VI_SitPago_CteNvo   			VARCHAR(80) DEFAULT '',
		puntual_VI_SitPago_CteNvo       DECIMAL(10,4) DEFAULT 0.00,
        valor_VI_SitPago_CteNvo         DECIMAL(5,2) DEFAULT 0.00,
        region_cobranza                 VARCHAR(80),
        valor_region_cobranza           DECIMAL(5,2),
        Meses_ult_cons_buro_iq   		VARCHAR(80) DEFAULT '',
		puntual_Meses_ult_cons_buro_iq	DECIMAL(10,4) DEFAULT 0.00,
        valor_Meses_ult_cons_buro_iq     DECIMAL(5,2) DEFAULT 0.00,
        grupo                           CHAR(1)
        );

--    alter table ss_riesgos_os type (RAW);

	foreach with hold 
        select nvl(trim(sol.num_solicitud),''),nvl(trim(sol.numcte),''),nvl(trim(sol.sucursal),''),nvl(trim(cli.numcte_ref),''),
               trim(sol.status_solicitud),sol.fecha_insert,trim(sol.num_producto),nvl(sol.monto_solicitado,0),
               nvl(res.situacion_pago,0),nvl(trim(res.motivo_cc),''),
               nvl(res.saldoropa,0), nvl(res.saldomuebles,0), nvl(res.saldoprestamos,0), nvl(res.linea_tienda,0),case when dia_para_revisar is not null or dia_para_revisar <> '' then 'E84' else '' end,--cPrueba
               case when evalua_cc = 'X' then 'NO HIT' else 'HIT' end,          --cFiltroC
               case when meses_historia >= 13 and situacion_pago >= 85 then 'I'
                    when meses_historia >= 6 and situacion_pago >= 85 then 'II'
               else 'III' end, res.grupo
        into chrnumsolicitud,chrnumcte,chrsucursal,chrnumctecoppel,
             chrstatussol,dtefechasol,chrnumproducto,declincred,
             deceficponderada,vchrrespuestacc,
             dSdoropa,dSdomuebles,dSdoprestamo,dSdolineatienda, cPrueba, cFiltroC,ctipoc, cgrupo_solic
		from bdisolic:ss_solicitudes sol
		inner join bdisolic:ss_filtro_paramtr fil on (sol.empresa=fil.empresa and sol.num_solicitud=fil.num_solicitud)
        left outer join bdinteg:si_cliente cli on(cli.numcte=sol.numcte)
        left outer join bdisolic:ss_resum_scor_fin res on(res.empresa=sol.empresa and res.num_solicitud=sol.num_solicitud)
        left outer join bdinteg:si_ctepf cte on(cte.numcte=cli.numcte)
        left outer join bdinteg:si_sucursales suc on(suc.sucursal=sol.sucursal and suc.empresa=sol.empresa)
        where sol.empresa='001' and fil.fecha_insert >= mdy(02,25,2016) and cli.tpo_persona='01'  

        if (icontadorcommit = 0) then
          begin work;
        end if;

		----- jpc
		select trim(e.descripcion),
              (select descripcion from ss_status_sol where empresa='001' and status_solicitud = a.status_solicitud),
--            c.comentario , 
			b.fecha_apertura, 
			trunc((a.fecha_insert - cte.fecha_nac)/365,0) edad,  
            (select telefono from bdinteg:si_telefonos_actual b where a.empresa = b.empresa and a.numcte = b.numcte 
                                                        and b.tipo_tel = '4') tel_ofi,
			(select telefono from bdinteg:si_telefonos_actual b where a.empresa = b.empresa and a.numcte = b.numcte 
                                                       and b.tipo_tel = '2') tel_cel,
			decode(f.fuente,'T','TIENDA','B','BANCO','','BANCO'),pago_minimo
				into v_causa, v_status, v_fecha_apert, v_edad, v_tel_ofi, v_tel_cel, v_fuente, v_compromisos	 
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
        if v_edad is null then let v_edad = ''; end if;    if v_tel_ofi is null then let v_tel_ofi = ''; end if;
        if v_tel_cel is null then let v_tel_cel = ''; end if;    if v_fuente is null then let v_fuente = ''; end if;    if v_compromisos is null then let v_compromisos = 0; end if;
		
		--Obtengo el email
		select nvl(trim(corre.correo_elec),'')
			into v_email
			from bdinteg:si_correos corre
		   where corre.empresa = '001' 
		    and corre.numcte = chrnumcte
			and corre.status_correo = 'A'
			and corre.secuencia = 
			(
				select max(secuencia) 
				  from bdinteg:si_correos 
			     where empresa = corre.empresa
				   and numcte = chrnumcte
				   and status_correo = corre.status_correo
			);
		
		if v_email is null then let v_email = ''; end if;
        --Obtiene la direccion del cliente(persona fisica)
        select nvl(trim(dir.cod_postal),''),nvl(trim(edo.nombre),''),nvl(trim(ciu.nombreciudad),'')
        into chrcodpostal,chrestado,vchrciudad
		from bdinteg:si_direcciones_actual dir
		left outer join bdinteg:si_estados edo on(edo.pais='001' and edo.estado=dir.estado)
        left outer join bdinteg:si_catciudades ciu on(ciu.numeroestado=dir.estado and ciu.numerociudad=dir.ciudad)
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

        --Obtiene el parametro del Salario Minimo BanCoppel
        select nvl(valor,0)*1 into intsmb
        from bdisolic:ss_param
        where secuencia = 303 and empresa = '001';
		
		--Obtiene el ingreso mensual declarado por el cliente y el ingreso en SMB
        --Obtener los abonosmensuales en ropa, muebles y prestamo, el pago minimo y evalua_cc
        select round(nvl(ingreso_mensual,0),2), nvl(abonomensualmuebles,0), nvl(abonomensualropa,0), nvl(abonomensualprestamos,0), nvl(pago_minimo,0), evalua_cc
        into mnyingreso,mnyabonomensualmuebles,mnyabonomensualropa,mnyabonomensualprestamos,mnypago_minimo,chrevalua_cc
        from bdisolic:ss_resum_scor_fin
        where empresa = '001' and num_solicitud = chrnumsolicitud;
		
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
        let vchrrespuesta13     ="";
        --PQ
        let vchrrespuesta15     ="";
        --let vchrpregunta16      ="";
        let vchrrespuesta16     ="";
        let vchrpregunta17      ="";
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
        let vchrrespuesta30     ="";
        let vchrrespuesta31     ="";
        let vchrrespuesta32     ="";
        let vchrrespuesta33     ="";
        let vchrrespuesta34     ="";
        let vchrrespuesta35     ="";
--MJPC Valores putuales
		let varpuntual18         =0;
        let varpuntual19         =0;
        let varpuntual20         =0;
        let varpuntual21         =0;
        let varpuntual22         =0;
        let varpuntual23         =0;
        let varpuntual24         =0;
        let varpuntual25         =0;
        let varpuntual26         =0;
        let varpuntual27         =0;
        let varpuntual28         =0;
        let varpuntual29         =0;
        let varpuntual30         =0;
        let varpuntual31         =0;
        let varpuntual32         =0;
        let varpuntual33         =0;
        let varpuntual35         =0;
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
        --let decvalor11          =0;
        --let decvalor12          =0;
        let decvalor13          =0;
        --PQ
        --let decvalor14         =0;
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
        let decvalor30         =0;
        let decvalor31         =0;
        let decvalor32         =0;
        let decvalor33         =0;
        let decvalor34         =0;
        let decvalor35         =0;
--JOM FIN AGREGAR VARIABLES PRUEBA TESTIGO

--Obtener la edad como valor puntual respuesta9
		select case when month(fecha_nac) < month(a.fecha_insert)
						then year(a.fecha_insert) - year(fecha_nac)
				else case when month(fecha_nac) = month(a.fecha_insert) and day(fecha_nac) <= day(a.fecha_insert) 
						then year(a.fecha_insert) - year(fecha_nac)
		    else year(a.fecha_insert) - year(fecha_nac) - 1 
				end 
		end edad
		into vchrrespuesta9
		from bdisolic:ss_solicitudes a
		inner join bdinteg:si_ctepf cte on(cte.numcte=a.numcte)
		where a.empresa='001' and a.num_solicitud= chrnumsolicitud;
		
        let intcontador        =0;
		foreach
		select variable,nvl(valor,0) 
		into vchsvariable,decvalor_punt 
		from bdisolic:ss_detalle_modelo where empresa = '001'
			   and num_solicitud = chrnumsolicitud 
			   
		if vchsvariable = 'BC_1' then
			let varpuntual18 = decvalor_punt;
		elif vchsvariable = 'BC_101' then
			let varpuntual19 = decvalor_punt;
		elif vchsvariable = 'BC_117' then
			let varpuntual20 = decvalor_punt;
		elif vchsvariable = 'BC_119' then
			let varpuntual21 = decvalor_punt;
		elif vchsvariable = 'BC_20' then
			let varpuntual22 = decvalor_punt;
		elif vchsvariable = 'BC_421' then
			let varpuntual23 = decvalor_punt;
		elif vchsvariable = 'BC_85' then
			let varpuntual24 = decvalor_punt;
		elif vchsvariable = 'BC_93' then
			let varpuntual25 = decvalor_punt;
		elif vchsvariable = 'CALC_PCT_SALDO_LIMIT' then
			let varpuntual29 = decvalor_punt;
		elif vchsvariable = 'CALC_PCT_SALDO_LINEA' then
			let varpuntual26 = decvalor_punt;
		elif vchsvariable = 'PMESESHIST' then
			let varpuntual27 = decvalor_punt;
		elif vchsvariable = 'PSITUACIONPAGOCOPPEL' then
			let varpuntual28 = decvalor_punt;
		elif vchsvariable = 'EDO_CIVIL_&_TIEMPO_ESTADO_CIVIL' then
			let varpuntual30 = decvalor_punt;
		elif vchsvariable = 'MESES_HISTORIA_&_CLIENTE_NUEVO' then
			let varpuntual31 = decvalor_punt;
		elif vchsvariable = 'CALC_PCT_SALDO_LINEA_&_CLIENTE_NUEVO' then
			let varpuntual32 = decvalor_punt;
		elif vchsvariable = 'SITUACION_PAGO_&_CLIENTE_NUEVO' then
			let varpuntual33 = decvalor_punt;
		elif vchsvariable = 'MESES_ULTIMA_CONSULTA' then
			let varpuntual35 = decvalor_punt;
		end if;
		end foreach; 

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
				let decvalor9 = decvalor;
			elif intgrupo = 11 then
				let vchrrespuesta10 = vchrrespuesta;
				let decvalor10 = decvalor;
			--PQ
			elif intgrupo = 16 then
				let vchrrespuesta13 = vchrrespuesta;
				let decvalor13 = decvalor;
            --PQ
			elif intgrupo = 21  then
				let vchrrespuesta15 = vchrrespuesta;
				let decvalor15 = decvalor;
			elif intgrupo = 22  then
				let vchrrespuesta16 = vchrrespuesta;
				let decvalor16 = decvalor;
			elif intgrupo = 23  then
				let vchrpregunta17 = vchrpregunta;
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
			elif intgrupo = 44  then   -- INI se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03
				let vchrrespuesta30 = vchrrespuesta;
				let decvalor30 = decvalor;
			elif intgrupo = 45  then
				let vchrrespuesta31 = vchrrespuesta;
				let decvalor31 = decvalor;
			elif intgrupo = 46  then
				let vchrrespuesta32= vchrrespuesta;
				let decvalor32 = decvalor;
			elif intgrupo = 47  then   
				let vchrrespuesta33 = vchrrespuesta;
				let decvalor33 = decvalor;
			elif intgrupo = 42  then   
				let vchrrespuesta34 = vchrrespuesta;
				let decvalor34 = decvalor;
			elif intgrupo = 43  then   
				let vchrrespuesta35 = vchrrespuesta;
				let decvalor35 = decvalor;  -- FIN se agregan variables interactivas Nvo Parametrico TDC RQM 07 048-03

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
                                          decvalor8 + decvalor9 + decvalor10 + decvalor13 +
                                          decvalor15 +  decvalor16 + decvalor17;
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
	
		--Inserta en ss_solicitudes_filtro para consulta del area de Riesgos

		insert into bdisolic:ss_solicitudes_filtro (numsolicitud,numcte,numctecoppel,sucursal,codpostal,estado,localidad,
					statussol,fechasol,numproducto,respuesta,
					ingresomensual,ingresosmb,lincred,eficponderada,
					tipocliente,filtrocliente,
					saldoropa,saldomuebles,saldoprestamo,lineatienda,bcscore,prueba,causa,
					status,compromisos,fecha_apert,edad_1,email,tel_ofi,tel_cel,fuente,respuestacc,	
					sexo,valor_sexo,estado_civil,valor_estado_civil,tmpo_edo_civ_act,valor_tmpo_edo_civ_act,
					tipo_residencia,valor_tipo_residencia,tmpo_dom_act,valor_tmpo_dom_act,ocupacion,valor_ocupacion,
					tmpo_ocup_act,valor_tmpo_ocup_act,tmpo_ocup_ant,valor_tmpo_ocup_ant,edad,valor_edad,
					depend_econ,valor_depend_econ,
                    seguro_popular,valor_seguro_popular,escolaridad,valor_escolaridad,
                    hab_domic,valor_hab_domic,pregunta17,respuesta17,valor17,
					
                    BC_1,puntual_BC_1,valor_BC_1,BC_101,puntual_BC_101,valor_BC_101,BC_117,puntual_BC_117,valor_BC_117, 
                    BC_119,puntual_BC_119,valor_BC_119,BC_20,puntual_BC_20,valor_BC_20,BC_421,puntual_BC_421,valor_BC_421, 
                    BC_85,puntual_BC_85,valor_BC_85,BC_93,puntual_BC_93,valor_BC_93,calc_PCT_saldo_linea,puntual_calc_PCT_saldo_linea,valor_calc_PCT_saldo_linea, 
                    meses_historia,puntual_meses_historia,valor_meses_historia,situacion_pago,puntual_situacion_pago,valor_situacion_pago,ratio_saldo_credit_limit,puntual_ratio_saldo_credit_limit,valor_ratio_saldo_credit_limit, 
                    	
					seccion1,seccion2,sumascoring,abono_muebles,abono_ropa,abono_prestamos,compromisos_mensuales,evalua_cc,

                    VI_EdoCiv_TmpoEdoCiv, puntual_VI_EdoCiv_TmpoEdoCiv, valor_VI_EdoCiv_TmpoEdoCiv,
                    VI_MesesHist_CteNvo, puntual_VI_MesesHist_CteNvo, valor_VI_MesesHist_CteNvo,
                    VI_CalcPctSdoLin_CteNvo, puntual_VI_CalcPctSdoLin_CteNvo, valor_VI_CalcPctSdoLin_CteNvo,
                    VI_SitPago_CteNvo, puntual_VI_SitPago_CteNvo, valor_VI_SitPago_CteNvo,
                    region_cobranza, valor_region_cobranza,
                    Meses_ult_cons_buro_iq, puntual_Meses_ult_cons_buro_iq, valor_Meses_ult_cons_buro_iq, grupo  )
		values (chrnumsolicitud,chrnumcte,chrnumctecoppel,chrsucursal,chrcodpostal,chrestado,vchrciudad,
				chrstatussol,dtefechasol,chrnumproducto,chrrespuesta,
				mnyingreso,mnyingresosmb,declincred,deceficponderada,
				ctipoc,cFiltroC,
				dSdoropa,dSdomuebles,dSdoprestamo,dSdolineatienda,cbcscore,cPrueba,v_causa,
				v_status,v_compromisos,v_fecha_apert, v_edad, v_email, v_tel_ofi, v_tel_cel, v_fuente,vchrrespuestacc,
				vchrrespuesta1,decvalor1,vchrrespuesta2,decvalor2,vchrrespuesta3,decvalor3,
				vchrrespuesta4,decvalor4,vchrrespuesta5,decvalor5,vchrrespuesta6,decvalor6,
				vchrrespuesta7,decvalor7,vchrrespuesta8,decvalor8,vchrrespuesta9,decvalor9,
				vchrrespuesta10,decvalor10,
                vchrrespuesta13,decvalor13,vchrrespuesta15,decvalor15,
                vchrrespuesta16,decvalor16,vchrpregunta17,vchrrespuesta17,decvalor17,
				
                vchrrespuesta18,varpuntual18,decvalor18,vchrrespuesta19,varpuntual19,decvalor19,vchrrespuesta20,varpuntual20,decvalor20, 
                vchrrespuesta21,varpuntual21,decvalor21,vchrrespuesta22,varpuntual22,decvalor22,vchrrespuesta23,varpuntual23,decvalor23, 
                vchrrespuesta24,varpuntual24,decvalor24,vchrrespuesta25,varpuntual25,decvalor25,vchrrespuesta26,varpuntual26,decvalor26, 
                vchrrespuesta27,varpuntual27,decvalor27,vchrrespuesta28,varpuntual28,decvalor28,vchrrespuesta29,varpuntual29,decvalor29, 
                
				decseccion1,decseccion2,decsuma,mnyabonomensualmuebles,mnyabonomensualropa,mnyabonomensualprestamos,mnypago_minimo,chrevalua_cc,				
				
                vchrrespuesta30,varpuntual30,decvalor30, vchrrespuesta31,varpuntual31,decvalor31, -- INI se agregan variables interactivas RQM 07 048-03
                vchrrespuesta32,varpuntual32,decvalor32, vchrrespuesta33,varpuntual33,decvalor33,
                vchrrespuesta34,decvalor34, vchrrespuesta35,varpuntual35,decvalor35, cgrupo_solic ); -- INI se agregan variables interactivas RQM 07 048-03

                let icontadorcommit = icontadorcommit + 1;

                if (icontadorcommit >= 100) then
                   commit work;
                   let icontadorcommit = 0;
                end if;

	end foreach;

    if ( icontadorcommit > 0) then
        commit work;
    end if;


    CREATE INDEX "informix".inx_ss_solicitudes_filtro ON "informix".ss_solicitudes_filtro(numsolicitud);
    update statistics medium for table "informix".ss_solicitudes_filtro;

    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME YEAR TO FRACTION INTO vHora FROM sysmaster:sysshmvals;

    /*INSERT INTO "informix".ss_bitacora_os(proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert) 
      VALUES('Reporte de Solicitudes', substr(chrcodret,2,5), 'Termina proceso', 'informix', today, vHora);*/

--	commit work;

return chrcodret,chrmensaje;
end;

end procedure;