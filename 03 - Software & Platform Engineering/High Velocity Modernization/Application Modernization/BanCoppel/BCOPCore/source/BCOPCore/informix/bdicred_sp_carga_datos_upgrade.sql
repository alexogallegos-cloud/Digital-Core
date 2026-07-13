CREATE PROCEDURE "informix".sp_carga_datos_upgrade() 
RETURNING CHAR(6);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cCod_Ret CHAR(6);
DEFINE cCadena  CHAR (500);
DEFINE cRuta CHAR (50);
DEFINE cUpg CHAR (50);
DEFINE cBitUpg CHAR (50);
DEFINE vnum_cred CHAR (20);
DEFINE vnum_cte CHAR (20);
DEFINE vnum_tarj CHAR (20);
DEFINE vtipo_tar CHAR (3);
DEFINE vnombre CHAR (106);
DEFINE vnombre_emb CHAR (21);
DEFINE vnum_prod CHAR (4);
DEFINE cmiembro CHAR (2);
DEFINE dtUpgIni DATETIME YEAR TO SECOND;
DEFINE dtUpgFin DATETIME YEAR TO SECOND;

DEFINE wBegin                CHAR(1);

LET iSqlErr = 0;
LET cCodRet = '000001';
LET cCod_Ret = '000000';
LET cCadena = '';
LET cRuta = '';
LET cUpg = '';
LET cBitUpg = '';
LET vnum_cred = '';
LET vnum_cte = '';
LET vnum_tarj = '';
LET vtipo_tar = '';
LET vnombre = '';
LET vnombre_emb = '';
LET vnum_prod = '';
LET cmiembro = '';
LET wBegin = '';
LET dtUpgIni = CURRENT;
LET dtUpgFin = CURRENT;


BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		END IF;
	END EXCEPTION;
   	
   SET LOCK MODE TO WAIT 3;

   --SET DEBUG FILE TO '/resplogifx/archivoscredito/sp_carga_datos_upgrade.out';
   --TRACE ON;

    LET cUpg="datosupgrade";
    LET cBitUpg="bitacoraupgrade";
    LET cRuta="/resplogifx/archivoscredito/";                                                    
 
	
	IF NVL(cRuta,'') <> '' THEN
			IF NVL(cUpg,'') <> '' THEN

				LET dtUpgIni = CURRENT;
				LET cUpg = TRIM(cUpg)||'_'||YEAR(dtUpgIni)||LPAD(MONTH(dtUpgIni),2,0)||LPAD(DAY(dtUpgIni),2,0)||'.txt';                
                LET cBitUpg= TRIM(cBitUpg)||'_'||YEAR(dtUpgIni)||LPAD(MONTH(dtUpgIni),2,0)||LPAD(DAY(dtUpgIni),2,0)||'.txt'; 

				
				TRUNCATE TABLE sd_carga_upgrade;
				LET cCadena = '/usr/bin/echo "LOAD FROM ''' || SUBSTR(cRuta,1,LENGTH(cRuta)) || SUBSTR(cUpg,1,LENGTH(cUpg)) ||'''  delimiter ''|'' INSERT INTO bdicred:"informix".sd_carga_upgrade" >' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'datos_upgrade.sql';
                SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/ifxsif01/bin/dbaccess bdicred ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'datos_upgrade.sql';
				system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'datos_upgrade.sql';
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));
				LET cCadena = '/usr/bin/rm ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'datos_upgrade.sql';
                system 'chmod 755 ' || SUBSTR(cRuta,1,LENGTH(cRuta)) || 'datos_upgrade.sql';
				SYSTEM SUBSTR(cCadena,1,LENGTH(cCadena));                

				LET cCodRet = '000000';
			ELSE
				LET cCodRet = '000002';
			END IF;
            
            IF cCodRet = '000000' THEN 
                FOREACH WITH HOLD
                    SELECT num_credito, num_cte, num_tarjeta, tipo_tar, nombre, nombre_embosado, num_producto
                    INTO vnum_cred, vnum_cte, vnum_tarj, vtipo_tar, vnombre, vnombre_emb, vnum_prod
                    FROM sd_carga_upgrade                  
                    
                    IF NOT EXISTS ( SELECT num_credito  FROM "informix".sd_credito_upgrade
                        WHERE num_credito = vnum_cred and numcte = vnum_cte) THEN
						
						IF (SELECT status_cred FROM sd_maecred WHERE num_credito=vnum_cred ) IN ('AA','E1') THEN 
							IF (SELECT NVL(monto_vencido + mto_venc_trasp,0) FROM sd_maesdos WHERE num_credito=vnum_cred ) = 0 THEN 

								IF (SELECT sdo_retenido FROM sd_maesdos WHERE num_credito=vnum_cred)=0 THEN
									SELECT substr(YEAR(fecha_apertura),3,2)
									INTO cmiembro
									FROM bdicred:"informix".sd_maecred
									WHERE num_credito = vnum_cred;

									INSERT INTO  "informix".sd_credito_upgrade (empresa ,num_credito,numcte ,numerotarjeta ,numero_credito_upgrade, numerotarjeta_upgrade, num_producto_upgrade,tipoTar ,nombre,nombre_embosado ,bandtarjpersonal,tipo_proceso, nombre_archivo,master ,Tipo_dom,miembro,Resultado,bclonadocompleto,user_insert ,fecha_insert)
																		VALUES ('001' ,vnum_cred ,vnum_cte, vnum_tarj, "","",vnum_prod,vtipo_tar ,vNombre ,vnombre_emb, '1','1','','1' , '3' ,cmiembro,"0","0", 'informix' ,CURRENT);

									UPDATE "informix".sd_carga_upgrade SET cod_ret='000000', descripcion='Upgrade Exitoso' WHERE num_credito=vnum_cred AND num_cte= vnum_cte;
									
								ELSE --CREDITO CON SALDO RETENIDO
									UPDATE "informix".sd_carga_upgrade SET cod_ret='000001', descripcion='Credito con saldo Retenido' WHERE num_credito=vnum_cred AND num_cte= vnum_cte;
									 
								END IF;
							ELSE -- CREDITO NO VIGENTE
								UPDATE "informix".sd_carga_upgrade SET cod_ret='000002', descripcion='Credito no Vigente' WHERE num_credito=vnum_cred AND num_cte= vnum_cte;

							END IF;
                        ELSE -- CREDITO NO VIGENTE
                            UPDATE "informix".sd_carga_upgrade SET cod_ret='000002', descripcion='Credito no Vigente' WHERE num_credito=vnum_cred AND num_cte= vnum_cte;
                                
                        END IF;
					ELSE-- YA EXISTE UPGRADE
						UPDATE "informix".sd_carga_upgrade SET cod_ret='000003', descripcion='Ya existe la solicitud de Upgrade para este Credito' WHERE num_credito=vnum_cred AND num_cte= vnum_cte;
                           
                    END IF;
                END FOREACH 
				  
	
                LET cCadena = '';
				LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitUpg)  ||'  delimiter ''|'' SELECT num_credito,num_cte,num_tarjeta,cod_ret,descripcion FROM bdicred:"informix".sd_carga_upgrade" >'||TRIM(cRuta)||'bit_upgrade.sql';
				SYSTEM cCadena;				
				LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_upgrade.sql';
				System cCadena;				
				let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_upgrade.sql';
				System cCadena;				
				LET cCadena = '' ;
				LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_upgrade.sql';
				SYSTEM cCadena;

            END IF; 
	END IF;
	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : CONCEPCION ALVAREZ CARRILLO',
'FECHA : 05/SEP/2017',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_carteral_ppyr()
RETURNING CHAR(6);
--Creado por: maria elizabeth anzures ibarguen
--28-12-2011
--Proceso para la generacion de archivo cartera total prestamo personal y reestructura

--Modificado por: Jorge Tirado Villa
--12-05-2017
--Se aniadio los scoring de originacion al reporte mensual Cartera_totalddmmaaaa.txt 

--Modificado por: PAUL IVAN QUINTERO VARELA
--29-06-2017
--Se agrego el campo para el flag indicativo del segundo producto

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(80);
DEFINE cCod_ret				CHAR(6);
DEFINE cCod_ret2			CHAR(6);
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
DEFINE Vfecha_mov DATE;

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
DEFINE Vsecc2 decimal(10,4);
DEFINE sPaso integer;
DEFINE vlNumInsert SMALLINT;
DEFINE Vpri_dia_mes DATE;

	  --variables
DEFINE Vnumcreditortc       char(20);
DEFINE VcreditoConsulta       char(20);
DEFINE Vnumcuentartc      	char(20);
DEFINE Vnumtarjetatdc       char(20);
--DEFINE Vnumcte        		char(20);
DEFINE Vnumsucursal     	char(4);
DEFINE Vnumciudad			char(4);
DEFINE Vsaldoactual      	decimal(18,2);
DEFINE Vinteres       		decimal(18,2);
DEFINE Vsaldovencido     	decimal(18,2);
DEFINE Vinteresvencido   	decimal(18,2);
DEFINE vinteres_moratorio	decimal(18,2);
DEFINE Vabonobase			decimal(18,2);
DEFINE Vabonosvencidos		smallint;
DEFINE Vestadocredito		char(2);
DEFINE Vplazortc			smallint;
DEFINE Vtasainteres			decimal(18,2);
DEFINE Vfechalimitedepago	date;
DEFINE Vfechaultmov			date;
DEFINE Vtipoultimomov		char(2);
DEFINE Vfechacorte			date;
define cNombreArchivo		char(70);
define cNombreArchivo2		char(70);
define cNombreArchivoNvo	char(70);
--define sPaso				integer;
--define cempresa				char(3);
define Vprod				char(4);
define vmontor1				decimal(18,2);
define vmontor2				decimal(18,2);
DEFINE cMotivo	char(5);
-- RQM 09 440
DEFINE VsaldoCapital		decimal(18,2);
DEFINE VsaldoTrasp			decimal(18,2);
DEFINE VvenciNoExig			decimal(18,2);
DEFINE VvenciExig			decimal(18,2);
DEFINE VintVigente			decimal(18,2);
DEFINE VintVencido			decimal(18,2);
DEFINE VintVenc28			decimal(18,2);
DEFINE VintVenc29			decimal(18,2);
DEFINE VintVenc30			decimal(18,2);
DEFINE VintVenc31			decimal(18,2);

DEFINE dBcScore DECIMAL(5,2);
DEFINE dScoreProp DECIMAL(5,2);
DEFINE dFico DECIMAL(5,2);
DEFINE dFicoExtended DECIMAL(5,2);
DEFINE dIcc DECIMAL(5,2);
DEFINE v_selectcredito char(20);
DEFINE cFlag2Credito   VARCHAR(120,1);
DEFINE cStatus_Ini CHAR(2);
DEFINE cRevisado CHAR(2);
DEFINE cIdbox smallint;
DEFINE cIfe CHAR(2);
DEFINE dFechaVencto	DATE;
DEFINE cGrupo	CHAR(01);
DEFINE sMesesVencidos SMALLINT;
DEFINE sNumPagos	SMALLINT;
DEFINE dMontoPagos	decimal(18,2);
DEFINE dFechaVencido DATE;

--Inicializacion de variables

LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET cCod_Ret                = "000000";
LET cCod_Ret2                = "000000";
LET cMensaje                = 'PROCESO EXITOSO';
LET vproceso	            = '2060';
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
LET Vfecha_mov = DATE(1);

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

	  --variables
LET	Vnumcreditortc			= '';
LET Vnumcuentartc			= '';
LET	Vnumtarjetatdc			= '';
--LET	Vnumcte           	    = '';
LET	Vnumsucursal			= 0;
LET	Vnumciudad	            = '';
LET Vsaldoactual			= 0;
LET Vinteres                = 0;
LET Vsaldovencido           = 0;
LET Vinteresvencido         = 0;
LET Vabonobase              = 0;
LET Vabonosvencidos         = 0;
LET vinteres_moratorio		= 0;
LET Vestadocredito          = 0;
LET Vplazortc      			= 0;
LET Vtasainteres   		    = 0;
LET Vfechalimitedepago      = DATE(1);
LET	Vfechaultmov            = DATE(1);
LET Vtipoultimomov          = '';
LET Vfechacorte             = DATE(1);
let cempresa 				= '001';
let Vprod					='';
let vmontor1				= 0;
let vmontor2				= 0;
LET cMotivo = '';
-- RQM 09 440
LET VsaldoCapital			= 0;
LET VsaldoTrasp				= 0;
LET VvenciNoExig			= 0;
LET VvenciExig				= 0;
LET VintVigente				= 0;
LET VintVencido				= 0;
LET VintVenc28				= 0;
LET VintVenc29				= 0;
LET VintVenc30				= 0;
LET VintVenc31				= 0;

LET dScoreProp = "";
LET dBcScore = "";
LET dFico = "";
LET dFicoExtended = "";
LET dIcc  = "";
let  v_selectcredito = "";
LET cFlag2Credito = "" ;
LET cStatus_Ini = "";
LET cRevisado = "";
LET cIdbox = 0;
LET cIfe = "";
LET dFechaVencto = DATE(1);
LET cGrupo = '';
LET sMesesVencidos	= 0;
LET sNumPagos = 0;
LET dMontoPagos = 0;
LET dFechaVencido = DATE(1);


BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '02') returning cCod_ret2;
        RETURN cCod_ret;
	END EXCEPTION;

--	SET DEBUG FILE TO "CATERA_PPyR.out";
--	TRACE ON;


	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
	
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

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
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

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '01') returning cCod_ret2;
        Return cCod_Ret;
	END IF;
	
	-------------------------------GENERA TABLA-------------------------------------
		
	--DROP TABLE sd_cartera_total_PPyR;
	SELECT COUNT(tabid)INTO sPaso FROM systables WHERE tabname= 'sd_carteral_ppyr';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_carteral_ppyr;
            END IF;

					
    create table "informix".sd_carteral_ppyr
    ( 
	producto     		char(4),
    num_credito         char(20),
	numcte				char(20),
	num_tarjeta         char(20),
	num_sucursal		char(4),
	nom_suucursal		char(40),
	ingreso_mensual     money,
	monto_apertura      decimal(18,2), 
	fecha_apertura      date default '01/01/1900',
	 
	plazo smallint,
	estatus char (2),
	saldo_insoluto	decimal(18,2),
	capital_vigente	decimal(18,2),
	capital_transitorio	decimal(18,2),
	saldo_vencido_exigible	decimal(18,2),
	saldo_vencido_no_exigible	decimal(18,2),
	saldo_actual decimal(18,2), 
	saldo_cierre decimal(18,2), 
	--mes_vencido decimal(18,2), 
	mes_vencido integer,
	tipo_mov cHAR (1),
	fecha_mov DATE,
	 
	sexo char (1),
	fecha_nac date,
	nombre1 char(26),
	Nombre2 char(26),
	apellido_p char(26),
	apellido_m char(26),
	mail char (60),
	dir_calle char(30),
	dir_numero char(20),
	dir_colonia char(32),
	cp char(5),
	 
	dir_municipio char(60),
	num_estado smallint,
	dir_estado char(30),
	num_cd_coppel smallint,
	cd_coppel char(32),
	num_cd_banco smallint,
	cd_banco char(32),
	tel1 char(13),
	tel2 char(13),
	tel3 char(13),
	ext char(5),
	 
	ref_coppel char(20),
	eficiencia decimal(5,2),
	meses_historia smallint,
	hit char(6),
	secc1 decimal(5,2),
	secc2 decimal(10,4),
	motivo CHAR(5),
	bc_score decimal(5,2),
	score_prop decimal(5,2),
	fico decimal(5,2),
	fico_extended decimal(5,2),
	icc decimal(5,2),
	flag2credito VARCHAR(120,1),
	status CHAR(2),
	revisado CHAR(2),
	ife CHAR(2),
	grupo CHAR(1),
	meses_vencidos SMALLINT,
	num_pagos SMALLINT,
	monto_pagos DECIMAL(18,2)
	);
	
		
	SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'sd_pagosydisposicionescrd_cartera';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_pagosydisposicionescrd_cartera;
            END IF;


    create table sd_pagosydisposicionescrd_cartera
    (
	num_producto	char(4),
    numcreditortc	char(20) default '0',
    numcreditotdc	char(20) default '0',
    numcuentartc	char(20) default '0',
	numtarjetatdc   char(20) default '0',
	numcte          char(20),
	numsucursal     char(4),
	numciudad		char(4),
    fechareestructura   date,
    saldoactual     decimal(18,2),
    interes       	decimal(18,2),
    saldovencido    decimal(18,2),
    interesvencido  decimal(18,2),
	interes_moratorio	decimal(18,2),
    abonobase           decimal(18,2),
    abonosvencidos      smallint,
    estadocredito       char(2),
    plazortc    		smallint,
    tasainteres    		decimal(18,2),
    fechalimitedepago 	date,
	fechaultmov 		date,
    tipoultimomov		char(2),
    fechacorte          date,
	sdo_cap_vigente 			DECIMAL(18,2),
	sdo_cap_trasp_vigente 		DECIMAL(18,2),
	sdo_cap_noexig_vencido 		DECIMAL(18,2),
	sdo_cap_exig_vencido 		DECIMAL(18,2),
	sdo_int_vigente 			DECIMAL(18,2),
	sdo_int_vencido 			DECIMAL(18,2)
	);
	
	select max(fecha)
	into pfechacorte
	from bdicred:sd_maecredcontcrd
	where num_producto in ( '6011','6300','7600','7700');
	
	--Prueba de cartera
	--LET pfechacorte = mdy('03','31','2018');
	
	select empresa, num_credito, fecha_apertura, numcte , num_producto, credito_externo, sucursal, plazo, status_cred, tasa_interes, fecha
	from bdicred:sd_maecredcontcrd crd 
	where fecha =pfechacorte and empresa = '001'
	  and num_producto in ('6300','6011','7600','7700') and nvl(campo_trab3,'') <> 'BAJA'
	into temp CreditosCrd with no log;
	create index indx_creditos on CreditosCrd (num_credito );
			 update statistics medium for table CreditosCrd;
			 
	select crd.num_credito ,fecha_mov, codigo_fun, codigo_ref, monto
			from bdicred:sd_movhiscrd mov , CreditosCrd crd
			where 
              crd.num_credito = mov.num_credito
             and crd.fecha_apertura>=mov.fecha_mov 
              and ((codigo_fun = '338' and codigo_ref = 21 )
            or (codigo_fun = '338' and codigo_ref = 22 )
            or (codigo_fun   in ('020','021','022','023','024','025','027','028','222','225') and  codigo_ref = 1 )
            or (codigo_fun  = '001' and codigo_ref  in (3,4) )
            or ( codigo_fun  in ('001','002')  and codigo_ref in (1,2,66) ) )
			and reversado = 'N'             
			 into temp MovtosCred with no log;
			 create index indx_mov on MovtosCred (num_credito );
			 update statistics medium for table MovtosCred;
			 
	
		select num_credito num_solicitud,  nvl(ingreso_mensual,0) ingreso_mensual ,nvl(situacion_pago,0) situacion_pago ,nvl(meses_historia,0) meses_historia,
			DECODE ( NVL(evalua_cc,''),'','No Hit','X','No Hit','Hit')	evalua_cc, grupo			
		--into Vingreso_mensual,Vficiencia, Vmeses_historia, Vhit
		from CreditosCrd crd,bdisolic:ss_resum_scor_fin scor 
		where crd.empresa=scor.empresa
		  and crd.num_credito=scor.num_solicitud
		  --- Se agregan productos para corregir datos nullos en los campos Eficiencia y Meses historia.
		  and crd.num_producto in ('6300','7600','7700')
		  union 
		  select num_credito num_solicitud,  nvl(ingreso_mensual,0) ingreso_mensual ,nvl(situacion_pago,0) situacion_pago ,nvl(meses_historia,0) meses_historia,
			DECODE ( NVL(evalua_cc,''),'','No Hit','X','No Hit','Hit')	evalua_cc, grupo			
		--into Vingreso_mensual,Vficiencia, Vmeses_historia, Vhit
		from CreditosCrd crd,bdisolic:ss_resum_scor_fin scor 
		where crd.empresa=scor.empresa
		  and crd.credito_externo=scor.num_solicitud
		  and crd.num_producto ='6011'
		into temp scorfin with no log;
		create index indx_scor on scorfin (num_solicitud );
			 update statistics medium for table scorfin;
			 

		
	--------------------INSERTAR EN TABLA-----------------------------------
	
	 CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, 'Inicia Foreach', '02') returning cCod_ret2;

	FOREACH 
		select a.num_producto,a.num_credito,NVL(a.credito_externo,'0'),a.numcte,a.sucursal,suc.nombre,b.monto_otorgado ,NVL(a.fecha_apertura,DATE(1))
			, a.plazo, a.status_cred,b.sdo_cap_insoluto,b.sdo_capital,b.monto_vencido,b.mto_venc_trasp,b.cap_tras_no_venci, 
			nvl(b.mto_fin_ven_trasp,0),fecha_ult_pago,nvl(a.tasa_interes,0) ,NVL(c.prox_fecha_pago,'01/01/1900'),nvl(suc.ciudad,0),
			(CASE WHEN a.status_cred IN ('AA','BA','E1') THEN (sdo_intereses + sdo_no_exig) ELSE 0 END) ,
			(CASE WHEN a.status_cred NOT IN ('AA','BA','E1') THEN (sdo_intereses + sdo_no_exig + int_tra_no_exig) ELSE 0 END ), c.fecha_vencto
		into Vproducto ,  Vnum_credito,Vcreditoexterno  , Vnumcte,Vnum_sucursal,vnom_suucursal,vmonto_apertura,vfecha_apertura
			,vplazo,vestatus, vsaldo_insoluto,vcapital_vigente,vcapital_transitorio,vsaldo_vencido_exigible,vsaldo_vencido_no_exigible,
			vmes_vencido,Vfechaultmov,Vtasainteres,Vfechalimitedepago,Vnumciudad,
			Vinteres,Vinteresvencido,dFechaVencto
		from CreditosCrd a -- bdicred:sd_maecredcontcrd a
			inner join bdicred:sd_maesdoscontcrd b on (a.fecha = b.fecha and a.empresa = b.empresa and a.num_credito = b.num_credito)		
			left join bdinteg:si_sucursales suc on (suc.empresa = a.empresa and suc.sucursal = a.sucursal)					
			inner join bdicred:sd_maecredanexocrd  c on (c.num_credito = a.num_credito)
		 --where a.empresa ='001' and a.num_producto in ( '6011','6300')
		--and a.fecha = pfechacorte
		
		SELECT cte.numcte_ref,cte.nombre1, cte.nombre2, cte.apell_paterno  , cte.apell_materno,nvl(pf.sexo,''),nvl(pf.fecha_nac,'')
		INTO Vref_coppel,vnombre1 , vnombre2 ,vapellido_p ,vapellido_m,vsexo,vfecha_nac
		FROM  bdinteg:si_cliente cte 
		INNER JOIN bdinteg:si_ctepf pf on (pf.numcte = cte.numcte)
		WHERE cte.numcte = Vnumcte;
		
		SELECT first 1 ca.nombrecalle ,dir.numeroextcalle,zo.nombrezona,dir.cod_postal,cd.nombre as dir_mun,
		es.estado as num_estado,es.nombre as dir_estado,cd.ciudad_coppel as cd_coppel,cd.nombre ,
		zo.numerociudad as num_banco ,zo.poblacionzona as cd_banco
		INTO vdir_calle,vdir_numero,vdir_colonia,vcp
		,Vdir_municipio,  Vnum_estado ,Vdir_estado ,Vnum_cd_coppel ,Vcd_coppel ,Vnum_cd_banco ,Vcd_banco 
		FROM bdinteg:si_direcciones_actual dir  
		inner join bdinteg:si_catcalles ca on ( ca.numerocalle = dir.numerocalle)
		inner join bdinteg:si_catzonas zo on ( zo.numerociudad = dir.numerociudad   and zo.numerocolonia = dir.numerocolonia)
		inner join bdinteg:si_ciudades cd  on (cd.estado  = dir.estado  and  cd.ciudad = dir.ciudad)
		inner join bdinteg:si_estados es on (es.estado = dir.estado)
		WHERE dir.numcte = Vnumcte AND dir.tipo_dir = 1;
		
		SELECT nvl(cta.num_cta,0) 
		INTO Vnum_tarjeta 
		FROM bdicred:sd_ctascarg cta
		WHERE empresa ='001' 
		AND cta.num_credito = Vnum_credito;
		
		LET Vnumcuentartc = Vnum_tarjeta;	
		
		IF (Vproducto = '6011') THEN 				
			SELECT nvl(tar.num_tarjeta,0)
				INTO Vnumtarjetatdc 
			FROM bdicred:sd_tarjeta tar 
			WHERE tar.empresa ='001'
			and tar.num_credito = Vcreditoexterno
			and tar.tipo_tarjeta ='T' 
			and tar.secuencia = (select max(tar2.secuencia)
								from bdicred:sd_tarjeta tar2
								where tar2.empresa = '001' 
								and tar2.num_credito = Vcreditoexterno
								and tar2.tipo_tarjeta ='T' );						
		END IF;
		
		SELECT LIMIT 1 nvl(sc01,'')
			INTO  Vsecc1
		FROM bdiburo:br_sc  br 
		WHERE  br.num_cliente = Vnumcte;			
		
		select limit 1 correo_elec
		INTO Vmail
		from bdinteg:si_correos
		where numcte = Vnumcte
		AND status_correo = 'A';
		
		select LIMIT 1 a.telefono, b.telefono ,d.telefono,d.extension
			into Vtel1 , Vtel2 ,Vtel3 ,Vext
		from bdinteg:si_telefonos_actual a
		left outer join bdinteg:si_telefonos_actual b on ( b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_tel = 2 AND b.status_tel = 'A' and b.cofetel = 'V') 
		left outer join bdinteg:si_telefonos_actual d on ( d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_tel = 3 AND d.status_tel = 'A' and d.cofetel = 'V') 
		where a.empresa = '001' and a.numcte = vnumcte 
		and a.tipo_tel = 1
		AND a.status_tel = 'A' 
		and a.cofetel = 'V' ;	
			
		--IF (Vproducto = '6300') then		
			LET VcreditoConsulta =Vnum_credito;
		--ELSE
			--LET VcreditoConsulta =Vcreditoexterno;  
		--END IF;
				
		SELECT limit 1 nvl(sum(valor),0) into Vsecc2
		FROM bdisolic:ss_detalle_scoring 
		where empresa = '001'
		and num_solicitud = VcreditoConsulta;

		select limit 1  nvl(ingreso_mensual,0), nvl(situacion_pago,0), nvl(meses_historia,0), evalua_cc, nvl(grupo,'')
		into Vingreso_mensual,Vficiencia, Vmeses_historia, Vhit, cGrupo
		from scorfin
		where num_solicitud = VcreditoConsulta;
		
		
/*		if (vestatus in ('AA') OR (vestatus = 'E1' and iAtr_Act_ifrs = 0)) then
			let Vsaldo_cierre =  Vcapital_vigente + vsaldo_vencido_exigible;	
		end if;
		if (vestatus in ('BA') OR (vestatus in ('E1','E2') and iAtr_Act_ifrs > 0)) then
			let Vsaldo_cierre =  vcapital_vigente + vcapital_transitorio;	
		end if;
		if (vestatus in ('BT','VP') OR (vestatus = 'E3' and iAtr_Act_ifrs > 0)) then
			let Vsaldo_cierre = vsaldo_vencido_exigible + vsaldo_vencido_no_exigible; 
		end if;
		*/
		
		if (vestatus <> 'FF') THEN 
			LET Vsaldo_cierre = vsaldo_insoluto; 
		END IF;
			
		-------------------------BUSCAR ULTIMO MOVIMIENTO DEL CLIENTE-------------------------
		if exists(select num_credito 
			from MovtosCred 
			where  num_credito = Vnum_credito
			and codigo_ref = 1 and codigo_fun   in ('020','021','022','023','024','025','027','028','222','225')
			and fecha_mov = Vfechaultmov --(select max(fecha_mov)from bdicred:sd_movhiscrd )
			) then 	

			LET Vtipoultimomov = 'P';
			
			 IF  (Vproducto = '6011') THEN --para la segunda parte...
				/*select limit 1 nvl(monto,0) into vmontor1
				FROM MovtosCred
				where  num_credito = Vnum_credito 
				and codigo_fun = '338' and codigo_ref = 21 
				and fecha_mov = (select max(fecha_mov) from MovtosCred  where num_credito = Vnum_credito and codigo_fun = '338' and codigo_ref = 21 );
				*/
			
				/*select limit 1 nvl(monto,0) into vmontor2
				FROM MovtosCred
				where  num_credito = Vnum_credito 
				and codigo_fun = '338' and codigo_ref = 22 
				and fecha_mov = (select max(fecha_mov) from MovtosCred  where num_credito = Vnum_credito and codigo_fun = '338' and codigo_ref = 22 ); 
				*/
				
				--let Vinteres = vmontor1 + vmontor2;
				if   Vinteres is null then let Vinteres = 0; end if;			
			 
			 END IF;
			
		elif exists(select num_credito 
			from MovtosCred
			where 
			 num_credito = Vnum_credito
			and codigo_ref  in (3,4) and codigo_fun  = '001'
			and fecha_mov = (select max(fecha_mov)from MovtosCred where codigo_ref in(3,4) and codigo_fun  = '001' and num_credito = Vnum_credito)
			) then
			
			select max(fecha_mov) INTO Vfechaultmov from MovtosCred where codigo_ref in(3,4) and codigo_fun  = '001' and num_credito = Vnum_credito;
			
			IF  (Vproducto = '6011') THEN 
				LET Vtipoultimomov = 'L';
				LET Vfechaultmov = vfecha_apertura;
			ELSE
				LET Vtipoultimomov = 'A';
			END IF;		
			
		elif exists(select num_credito 
			from MovtosCred 
			where 
			 num_credito = Vnumcreditortc
			and codigo_ref in (1,2,66) and codigo_fun  in ('001','002') 
			and fecha_mov = (select max(fecha_mov)from MovtosCred where  num_credito = Vnumcreditortc and   codigo_ref in (1,2,66) and codigo_fun in ('001','002') )
			) then		
			
			select max(fecha_mov) INTO Vfechaultmov from MovtosCred where   num_credito = Vnumcreditortc and  codigo_ref in (1,2,66) and codigo_fun in ('001','002');
			
			IF  (Vproducto = '6011') THEN 
				LET Vtipoultimomov = 'A';				
			ELSE
				LET Vtipoultimomov = 'D';
			END IF;								
		end if;
			
		LET vlNumInsert = vlNumInsert + 1;
		IF vlNumInsert = 5000 then 
		   LET vlNumInsert = 1;
		  -- update statistics medium for table bdicred:"informix".sd_carteral_ppyr;
		END IF;

		select NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)
		into Vsaldovencido
		from sd_maesdoscrd 
		where empresa = '001'
		and num_credito = Vnum_credito;
		
		select 	nvl(sdo_capital,0)
				,nvl(monto_vencido,0)
				,nvl(cap_tras_no_venci,0)
				,nvl(mto_venc_trasp,0)
				,nvl(sdo_intereses,0) + nvl(sdo_no_exig,0)
		into 	VsaldoCapital
				,VsaldoTrasp
				,VvenciNoExig
				,VvenciExig
				,VintVigente
		from sd_maesdoscontcrd 
		where empresa = '001'
		and fecha = pfechacorte
		and num_credito = Vnum_credito;

		select int_venc_bal28,int_venc_bal29,int_venc_bal30,int_venc_bal31
		into VintVenc28,VintVenc29,VintVenc30,VintVenc31
		from bdicred:sd_sdodiariocrd 
		where fecha = MDY(month(pfechacorte), 1,year(pfechacorte))
		and num_credito = Vnum_credito;
		
		IF to_char(pfechacorte, "%d") = 28 THEN 
			Let VintVencido = VintVenc28;
		ELIF to_char(pfechacorte, "%d") = 29 THEN 
			Let VintVencido = VintVenc29;
		ELIF to_char(pfechacorte, "%d") = 30 THEN
			Let VintVencido = VintVenc30;
		ELIF to_char(pfechacorte, "%d") = 31 THEN 
			Let VintVencido = VintVenc31;
		END IF;
		
		IF Vproducto = '6011' THEN
			IF vestatus IN ('BT','VP','E3')  THEN
				Let VintVencido = Vinteresvencido;
			END IF;
		END IF;
		
		IF vestatus IN ('BT','VP','E3') THEN
			LET VintVigente = 0;
		END IF;
		
		select nvl(capital_mto_cuota,0)
		into Vabonobase
		from bdicred:sd_amortiza_creditocrd 
		where num_credito = Vnum_credito
		and fecha_cuota = (select max(fecha_cuota) from bdicred:sd_amortiza_creditocrd where num_credito = Vnum_credito);

		if (Vabonobase = '') then 
			LET Vabonobase = 0; 
		end if;

		SELECT --nvl(SUM(NVL(interes_debe,0) - NVL(interes_pagado,0)),0),
			   nvl(SUM(NVL(mora_provi_ordi,0) + NVL(mora_provi_cope,0) + NVL(mora_sdo_ordi,0) - NVL(mora_sdo_ordi_pag,0) + NVL(mora_sdo_cope,0) - NVL(mora_sdo_cope_pag,0)),0)
		INTO --Vinteresvencido,
		  vinteres_moratorio
		FROM "informix".sd_amortiza_creditocrd
		WHERE empresa     = '001'
		AND num_credito = Vnum_credito
		AND capital_status IN ('2','7','6')
		AND fecha_cuota = (select max(fecha_cuota) from bdicred:sd_amortiza_creditocrd where num_credito = Vnumcreditortc);

		--obtener causa solicitud
			select limit 1 nvl(a.causa_solicitud,'') into cMotivo
			from bdisolic:ss_autorizacion a
			where a.empresa = cEmpresa
			and a.num_solicitud = vNum_Credito
			and fecha_hora = (select max(fecha_hora) from bdisolic:ss_autorizacion where num_solicitud = vNum_Credito and status_solicitud = 'AT')
			and a.status_solicitud = 'AT';
			IF Vcreditoexterno not in ('0','') THEN
				select limit 1 nvl(a.causa_solicitud,'') into cMotivo
				from bdisolic:ss_autorizacion a
				where a.empresa = cEmpresa
				and a.num_solicitud = Vcreditoexterno
				and fecha_hora = (select max(fecha_hora) from bdisolic:ss_autorizacion where num_solicitud = Vcreditoexterno and status_solicitud = 'AT')
				and a.status_solicitud = 'AT';
			END IF;	
		
------------Obtenemos los valores de scores de originacion
			--valida si es prestamo o reestructura
				--si es reestructura, tmar el valor de vnum_credito
			if Vproducto = '6011' then
				let v_selectcredito = Vcreditoexterno;
			--si no es reestructura, tomar el valor de vcreditoexterno
			else 
				let v_selectcredito = Vnum_credito;
			end if
			
			select evaluacion 
			into dBcScore
			from bdisolic:ss_resumen_scoring 
			where empresa = '001' 
			and num_solicitud = v_selectcredito
			and seccion = 1;
		
			if dBcScore is null or dBcScore = "" then
				let dBcScore = "";
			end if
			select evaluacion 
			into dScoreProp
			from bdisolic:ss_resumen_scoring 
			where empresa = '001' 
			and num_solicitud = v_selectcredito
			and seccion = 2;
			if dScoreProp is null or dScoreProp = "" then
				let dScoreProp = "";
			end if
			select evaluacion 
			into dFico
			from bdisolic:ss_resumen_scoring 
			where empresa = '001' 
			and num_solicitud = v_selectcredito
			and seccion = 3;
			if dFico is null or dFico = "" then
				let dFico = "";
			end if
			select evaluacion 
			into dFicoExtended
			from bdisolic:ss_resumen_scoring 
			where empresa = '001' 
			and num_solicitud = v_selectcredito
			and seccion = 4;
			if dFicoExtended is null or dFicoExtended = "" then
				let dFicoExtended = "";
			end if
			select evaluacion 
			into dIcc
			from bdisolic:ss_resumen_scoring 
			where empresa = '001' 
			and num_solicitud = v_selectcredito
			and seccion = 5;
			if dIcc is null or dIcc = "" then
				let dIcc = "";
			end if
			
			SELECT LIMIT 1 DECODE(flag2creditoicc,'1','Evaluacion de segundo producto de credito en adelante','')
             INTO cFlag2Credito
             FROM bdisolic:"informix".ss_revision_determinacion
            WHERE empresa = '001'
			  AND num_solicitud = v_selectcredito;

			IF cFlag2Credito IS NULL THEN 
			   LET cFlag2Credito = ' ';
			END IF;
			
			-- MODIFICACION REPORTE RQM 09 459-2 (INICIO)
			SELECT status_ini
			 INTO cStatus_Ini
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			 AND num_solicitud = v_selectcredito;
			 
			IF cStatus_Ini IS NULL THEN
			   LET cStatus_Ini = ' ';
			END IF;
			
			SELECT CASE WHEN revisado = 'N' THEN 'C'ELSE 'R' END
			 INTO cRevisado
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			 AND num_solicitud = v_selectcredito;
			 
			IF cRevisado IS NULL THEN
			   LET cRevisado = ' ';
			END IF;			 
			
			SELECT COUNT(*) 
			 INTO cIdbox
			 FROM bdisolic:"informix".ss_solicitudes_mc a
			 RIGHT OUTER JOIN bdinteg:si_bitacora_ife b on ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
			WHERE empresa = '001'
			 AND num_solicitud = v_selectcredito;
			 			
			IF cIdbox >= 1 THEN 
			   LET cIFE = 'Si';
			ELSE   
			   LET cIFE = 'No'; 
			END IF;	
			-- MODIFICACION REPORTE RQM 09 459-2 (FIN)
			
			IF (vestatus IN ('BA','BT','VP','E1','E2','E3') AND  vmes_vencido > 0) THEN
				SELECT fecha_vencido INTO dFechaVencido
				FROM bdicred:sd_indicador_cred_crd_hist
				WHERE empresa = '001'
				AND fecha_insert = pfechacorte
				AND num_credito = Vnum_credito;
				
				LET sMesesVencidos = TRUNC((pfechacorte - dFechaVencido)/30.4);
			ELSE
				LET sMesesVencidos = 0;
			END IF;
		

         SELECT COUNT(*),SUM(monto) INTO sNumPagos,dMontoPagos
           FROM bdicred:sd_movhiscrd
          WHERE empresa = empresa
            AND fecha_mov >= MDY(MONTH(pfechacorte),1,YEAR(pfechacorte))
            AND fecha_mov <= pfechacorte
            AND num_credito = Vnum_credito
            AND codigo_fun IN (select cod_fun from bdicred:sd_conceptospagomanualcrd)
            AND codigo_ref = 1 
            AND reversado = 'N';

		IF dMontoPagos IS NULL OR dMontoPagos = '' THEN
			LET sNumPagos = 0;
			LET dMontoPagos = 0;
		END IF;

		INSERT INTO sd_carteral_ppyr 
			(producto , num_credito ,numcte	,num_tarjeta ,num_sucursal	,nom_suucursal	,ingreso_mensual ,
			monto_apertura  ,fecha_apertura  ,plazo ,estatus ,
			saldo_insoluto	,capital_vigente,	capital_transitorio	,saldo_vencido_exigible	,saldo_vencido_no_exigible	,saldo_actual , 
			saldo_cierre ,mes_vencido ,tipo_mov ,fecha_mov,sexo ,fecha_nac ,nombre1 ,Nombre2 ,apellido_p ,
			apellido_m ,mail ,dir_calle ,dir_numero ,dir_colonia ,cp ,
			dir_municipio ,num_estado ,dir_estado ,num_cd_coppel ,cd_coppel ,num_cd_banco ,
			cd_banco ,tel1 ,tel2 ,tel3 ,ext ,ref_coppel ,eficiencia ,meses_historia ,hit ,secc1 ,secc2, motivo,
			bc_score , score_prop, fico, fico_extended, icc, flag2credito, status, revisado, ife, grupo, meses_vencidos, num_pagos, monto_pagos)
		VALUES
			(Vproducto , Vnum_credito , Vnumcte,	Vnum_tarjeta ,Vnum_sucursal	, Vnom_suucursal,nvl(Vingreso_mensual,''),
			Vmonto_apertura , Vfecha_apertura , Vplazo ,Vestatus,Vsaldo_insoluto,Vcapital_vigente,
			Vcapital_transitorio	,Vsaldo_vencido_exigible,Vsaldo_vencido_no_exigible,Vsaldo_actual ,
			Vsaldo_cierre ,Vmes_vencido ,Vtipoultimomov ,Vfechaultmov, Vsexo ,Vfecha_nac, Vnombre1 , Vnombre2 ,Vapellido_p ,
			Vapellido_m ,nvl(Vmail,''),Vdir_calle, Vdir_numero , Vdir_colonia , Vcp ,
			Vdir_municipio,  Vnum_estado ,Vdir_estado ,Vnum_cd_coppel ,Vcd_coppel ,Vnum_cd_banco ,
			Vcd_banco , nvl(Vtel1,'') ,nvl(Vtel2,'') , nvl(Vtel3,'') ,nvl(Vext,'') , Vref_coppel ,Vficiencia , Vmeses_historia ,Vhit ,Vsecc1 , Vsecc2, cMotivo,
			nvl(dBcScore,''),nvl(dScoreProp,''), nvl(dFico,''), nvl(dFicoExtended,''), nvl(dIcc,''), cFlag2Credito, cStatus_Ini, cRevisado, cIfe, nvl(cGrupo,''), nvl(sMesesVencidos,0), nvl(sNumPagos,0), nvl(dMontoPagos,0));			
		
		IF Vnumtarjetatdc = '' THEN 
			LET Vnumtarjetatdc ='0';
		END IF
		IF Vnumcuentartc = '' THEN 
			LET Vnumcuentartc ='0';
		END IF
		IF Vnumcuentartc = '' THEN 
			LET Vnumcuentartc ='0';
		END IF
		
		INSERT INTO sd_pagosydisposicionescrd_cartera  VALUES
		(Vproducto,Vnum_credito,Vcreditoexterno,Vnumcuentartc,Vnumtarjetatdc,Vnumcte,Vnum_sucursal,Vnumciudad, 
		vfecha_apertura,Vsaldo_insoluto,Vinteres,Vsaldovencido,Vinteresvencido,vinteres_moratorio,
		Vabonobase,vmes_vencido,Vestatus,vplazo,Vtasainteres,Vfechalimitedepago,Vfechaultmov,Vtipoultimomov,pfechacorte,
		VsaldoCapital,VsaldoTrasp,VvenciNoExig,VvenciExig,VintVigente,VintVencido);	
	
		
		LET	Vnumcreditortc			= '';LET Vcreditoexterno			= '';LET Vnumcuentartc			= '';
		LET	Vnumtarjetatdc			= '';LET	Vnumcte           	    = '';LET	Vnumsucursal			= 0;
		LET	Vnumciudad	            = '';LET Vsaldoactual			= 0;LET Vinteres                = 0;
		LET Vsaldovencido           = 0;LET Vinteresvencido         = 0;LET Vabonobase              = 0;LET Vabonosvencidos         = 0;
		LET vinteres_moratorio		= 0;LET Vestadocredito          = 0;LET Vplazortc      			= 0;LET Vtasainteres   		    = 0;
		LET Vfechalimitedepago      = DATE(1);LET	Vfechaultmov            = DATE(1);LET Vtipoultimomov          = '';
		let Vprod					='';let vmontor1				= 0;let vmontor2				= 0;
					
			
		LET  Vsaldo_insoluto	= 0;	LET  Vcapital_vigente	= 0;	LET Vcapital_transitorio	= 0;	LET Vsaldo_vencido_exigible	= 0;
		LET Vsaldo_vencido_no_exigible	= 0;	LET Vsaldo_actual = 0;	LET  Vsaldo_cierre = 0;	
		LET Vproducto     		='';     LET Vnum_credito         = '';	 LET  Vnumcte				='';
		LET Vnum_tarjeta         ='';	 LET Vnum_sucursal		='';	 LET  Vnom_suucursal		='';	 LET  Vingreso_mensual    = 0;
		LET  Vmonto_apertura      = 0;	 LET  Vfecha_apertura     = date(1);	  LET  Vplazo = 0;
		LET Vestatus ='';	  
		LET Vmes_vencido = 0;	  LET Vtipo_mov ='';	  LET Vfecha_mov = DATE(1);
		LET Vsexo ='';	  LET Vfecha_nac = date(1);	  LET Vnombre1 ='';	  LET Vnombre2 ='';	  LET Vapellido_p ='';
		LET Vapellido_m ='';	  LET Vmail ='';	  LET Vdir_calle ='';	  LET Vdir_numero ='';	  LET Vdir_colonia ='';
		LET Vcp = '';	 	  LET Vdir_municipio ='';	  LET Vnum_estado = 0;	  LET Vdir_estado ='';	  LET Vnum_cd_coppel= 0;
		LET Vcd_coppel ='';	  LET Vnum_cd_banco = 0;	  LET  Vcd_banco ='';	  LET Vtel1 ='';	  LET  Vtel2 ='';
		LET Vtel3 ='';	  LET Vext ='';	 	  LET Vref_coppel ='';	  LET Vficiencia = 0;	  LET Vmeses_historia = 0;
		LET Vhit ='';	  LET Vsecc1 = '';	  LET Vsecc2 = 0;	LET cMotivo = '';
		
		LET VsaldoCapital			= 0;	LET VintVenc28	= 0;
		LET VsaldoTrasp				= 0;	LET VintVenc29	= 0;
		LET VvenciNoExig			= 0;	LET VintVenc30	= 0;
		LET VvenciExig				= 0;	LET VintVenc31	= 0;
		LET VintVigente				= 0;
		LET VintVencido				= 0;
		
    END FOREACH;	
--SET DEBUG FILE TO "prueba12052017-1.out";
--TRACE ON;	
--------------------------------------------------------GENERAR ARCHIVO--------------------------------------------------------
	--let cruta = '/informix/jorger/pruebas/';
	--let cruta = '/aplicacion/Jorge/Adendum_Reporte_Cartera/Nuevo/';
	let cnombre = 'Cartera_Total';
	
    LET cnomarchivo1 =  trim(cnombre)||'Aux'||to_char(pfechacorte,'%d%m%Y')||'.txt';
    LET cnomarchivo =  trim(cnombre)||to_char(pfechacorte,'%d%m%Y')||'.txt';
	 
	let cSql='';
	LET cSQL1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';
	LET cSQL2 = " select * from bdicred:sd_carteral_ppyr ";
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
	
	LET	Vnumcte           	    = '';
	LET  sPaso = 0;		

	--segundo archivo
	--CREAR  ARCHIVO
	LET cNombreArchivo2= 'CifrasControlCarterasPPyRTC' ||to_char(pfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivo ='cartera_reestructura_prestamo'||to_char(pfechacorte,'%d%m%Y')||'.txt';
	LET cNombreArchivoNvo ='cartera_reestructura_prestamo'||to_char(pfechacorte,'%d%m%Y')||'_Ant.txt';
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO ' || TRIM(cruta) ||'Pagos1.unl' || ' DELIMITER ' || '''|'''  ||
	' select * from sd_pagosydisposicionescrd_cartera;'||
	' " > '|| TRIM(cruta) || 'Pagosydisposiciones2crd.sql';

	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicred ' || TRIM(cruta) || 'Pagosydisposiciones2crd.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' " || TRIM(cruta) || 'Pagos1.unl >' || TRIM(cruta) || trim(cNombreArchivo);
	SYSTEM cSql;

	let cSql = '';

	LET cSql = "rm " || TRIM(cruta) || 'Pagos1.unl ' || TRIM(cruta) || 'Pagosydisposiciones2crd.sql';
	SYSTEM cSql;

	-- para Generar el archvio de Cifras.
	LET cSql = '';
	LET cSql = 'echo "UNLOAD TO ' || TRIM(cruta) || 'DirectorioCifrasControlRegistros.unl'|| ' DELIMITER ' || '''|'''  ||
	' SELECT count(*)::integer, sum(saldoactual), sum(saldovencido), fechacorte FROM bdicred:sd_pagosydisposicionescrd_cartera group by fechacorte ' ||
	' " > '|| TRIM(cruta) || 'DirectorioCifrasControlQuerys.sql';

	SYSTEM cSql;

	LET cSql = '';
	LET cSql = 'dbaccess bdicred ' || TRIM(cruta) ||'DirectorioCifrasControlQuerys.sql';
	SYSTEM cSql;

	LET cSql = '';
	LET cSql = "sed 's/|$//g' " || TRIM(cruta) ||'DirectorioCifrasControlRegistros.unl > '|| TRIM(cruta) || trim(cNombreArchivo2);
	SYSTEM cSql;

	let cSql = '';
	LET cSql = "rm " || TRIM(cruta) ||'DirectorioCifrasControlRegistros.unl ' || TRIM(cruta) ||'DirectorioCifrasControlQuerys.sql';
	SYSTEM cSql;
	
	LET cSql = '';
	LET cSql = "cut -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 -d '|' " || TRIM(cruta) || trim(cNombreArchivo) || ' >' || TRIM(cruta) || trim(cNombreArchivoNvo);
	SYSTEM cSql;
	
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cempresa, vproceso, cCod_ret, cMensaje, '03') returning cCod_ret2;
	RETURN cCod_ret;
	
END;
END PROCEDURE;