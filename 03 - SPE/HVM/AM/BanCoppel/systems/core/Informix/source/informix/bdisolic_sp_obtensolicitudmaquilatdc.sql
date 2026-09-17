CREATE PROCEDURE "informix".sp_obtensolicitudmaquilatdc(pempresa CHAR(3),
pnumcte CHAR(20),
pnum_credito CHAR(20),
pnum_tarjeta CHAR(20),
ptipoenvio CHAR (1), --S= Sucursal o D= Domicilio
psucursal CHAR(5),
ptpomaquila CHAR(1),	--E=Embozada, N=Normal o S=Especial
ptpoejecucion CHAR(1),	--1=Apertura	2=Upgrade  3=Borrado
pejecutivo CHAR(10)
)
RETURNING CHAR(6)         AS codigo_retorno,
		CHAR(1) AS tpoenvio ,
		CHAR(5) AS sucursal,
		CHAR(1) AS tpomaquila,
		CHAR(20) AS numcte,
		CHAR(20) AS num_credito,
		CHAR(20) AS nomcliente1,
		CHAR(20) AS nomcliente2,
		CHAR(20) AS apellpatcliente,
		CHAR(20) AS apellmatcliente,
		CHAR(30) AS dir_calle1	,
		CHAR(30) AS dir_calle2,
		CHAR(50) AS dir_colonia,
		CHAR(15) AS dir_municipio,
		CHAR(13) AS dir_estado,
		CHAR(5) AS dir_cp,
		CHAR(2) AS tipotarjeta,
		CHAR(6) AS bintarjeta,
        CHAR(3) AS codproducto,
		CHAR(1) AS fimagen,
		CHAR(5) AS idimagen,
		CHAR(1) AS fmaster,
		CHAR(1) AS ftitular,
		CHAR(1) AS femision,
		CHAR(2) AS membersince,
		CHAR(1) AS welcomekit,
		CHAR(5) AS cat,
		CHAR(5) AS inanuord,
		CHAR(5) AS inanumor,
		CHAR(6) AS lineacredito,
		CHAR(5) AS cant_solicitadas,
		CHAR(19) AS fecha_sol,
		CHAR(9) AS num_empleado,
		CHAR(1) AS enviasms,
		CHAR(16) AS numtarjeta,
		CHAR(30) AS canal,
		CHAR(4) AS producto;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cMensajeRet   CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cCodRetTDif	 CHAR(6);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE vcodret		 char(5);
DEFINE cEmpresa      CHAR(3);
DEFINE ctpoenvio CHAR(1);
DEFINE csucursal CHAR(5);
DEFINE ctpomaquila CHAR(1);
DEFINE cnumcte CHAR(20);
DEFINE cnum_credito CHAR(20);
DEFINE cnum_creditoupg CHAR(20);
DEFINE cnomcliente1 CHAR(20);
DEFINE cnomcliente2 CHAR(20);
DEFINE capellpatcliente CHAR(20);
DEFINE capellmatcliente CHAR(20);
DEFINE cnombre_embosado CHAR(21);
DEFINE cdir_calle1 CHAR(30);
DEFINE cdir_calle2 CHAR(30);
DEFINE cdir_colonia CHAR(50);
DEFINE cdir_municipio CHAR(15);
DEFINE cdir_estado CHAR(13);
DEFINE cdir_cp CHAR(5);
DEFINE ctipotarjeta CHAR(2);
DEFINE cbintarjeta CHAR(6);
DEFINE ccodproducto CHAR(3);
DEFINE cfimagen CHAR(1);
DEFINE cidimagen CHAR(5);
DEFINE cfmaster CHAR(1);
DEFINE cftitular CHAR(1);
DEFINE cfemision CHAR(1);
DEFINE cmembersince CHAR(2);
DEFINE cwelcomekit  CHAR(1);
DEFINE ccat  CHAR(5);
DEFINE cinanuord CHAR(5);
DEFINE cinanumor CHAR(5);
DEFINE clineacredito CHAR(6);
DEFINE ccant_solicitadas CHAR(5);
DEFINE cfecha_sol CHAR(19);
DEFINE cnum_empleado CHAR(9);
DEFINE cenviasms CHAR(1);
DEFINE cnumtarjeta CHAR(16);
DEFINE ccanal CHAR(30);
DEFINE cuser_insert CHAR(8);
DEFINE dfecha_insert DATETIME YEAR to FRACTION(3);

--Direcciones
DEFINE vsecuencia       int ;
DEFINE vtipo_dir        char(1);
DEFINE vcalle           char(40);
DEFINE vcolonia         char(60);
DEFINE ventre_calles    char(40);
DEFINE vpais            char(3);
DEFINE vestado          char(2);
DEFINE vciudad          char(3);
DEFINE vmunicipio       char(5);
DEFINE vcod_postal      char(5);
DEFINE vapart_postal    char(11);
DEFINE vtipo_telef1     char(1);
DEFINE vtelefono1       char(13);
DEFINE vtipo_telef2     char(1);
DEFINE vtelefono2       char(13);
DEFINE vtipo_telef3     char(1);
DEFINE vtelefono3       char(13);
DEFINE vextension       char(5);
DEFINE vestado_inegi    char(2);
DEFINE vmunicipio_inegi char(3);
DEFINE vlocalidad_inegi char(4);
DEFINE vnumeroextcalle  char(10);
DEFINE vnumerointcalle  char(10);
DEFINE vnumerocalle     CHAR(30);
DEFINE vnumerocolonia   char(30);
DEFINE vdepartamento    char(6);
DEFINE vpuntocardinal   char(1);
DEFINE vunidadhabitac   char(1);
DEFINE vobservaciones   char(80);
DEFINE vNomEdo          char(30);
DEFINE vNomCiudad       char(30);
DEFINE vNomColonia      char(30);
DEFINE vNomCalle        char(30);
DEFINE vNomLote         char(30);
DEFINE vNomEntrada      char(30);
DEFINE vNomEdificio     char(30);
DEFINE vNomEtapa        char(30);
DEFINE vNomAndador      char(30);
DEFINE vNomOtros        char(30);
DEFINE vNomManzana      char(30);
DEFINE vmanzana         smallint ;
DEFINE vCiclo           smallint;
DEFINE votros           smallint ;
DEFINE vandador         smallint ;
DEFINE vetapa           smallint ;
DEFINE vlote            smallint ;
DEFINE vnumerociudad    smallint ;
DEFINE vedificio        smallint ;
DEFINE ventrada         smallint ;
DEFINE vCdCoppel        smallint;
DEFINE vSec             int;
DEFINE vNomMunicipio 	char(27);
DEFINE cnum_producto	CHAR(4);
DEFINE ctipo_proceso	CHAR(1);
--obtencion tasa
DEFINE V_TASA_INTERES        DECIMAL(9,6);
DEFINE V_TASA_MORA           DECIMAL(9,6);
DEFINE V_SOBRETASA           DECIMAL(9,6);
DEFINE V_FACTOR	             CHAR(1);
DEFINE V_SOBRETASA_MORA      DECIMAL(9,6);
DEFINE V_FACTOR_MORA         CHAR(1);
DEFINE vDiaCorte             SMALLINT;
--Embozado
DEFINE i integer;
DEFINE iContador integer;
DEFINE sCadena CHAR(21);
DEFINE sCampo_cadena CHAR(20);
--CAT
DEFINE vCatFinal            DECIMAL(21,10);
DEFINE dPagoReq      	DECIMAL(18,2);
DEFINE dMonto      	DECIMAL(18,2);
DEFINE dComisiones      	DECIMAL(18,2);
DEFINE dComisiones_gc      	DECIMAL(18,2);
DEFINE dAnualidad      	DECIMAL(18,2);
DEFINE codCat CHAR(3);

DEFINE cCobro_Apertu    CHAR(1);            -- INI RQM 10 993 CAT / RQM 10 1253 CAT
DEFINE cCodComis_Apert  CHAR(4);
DEFINE mMntoComApert    DECIMAL(18,2);      -- Monto Comision Apertura
DEFINE mMntoComAnual    DECIMAL(18,2);      -- Monto Comision Anualidad
DEFINE cCobrComisAnual  CHAR(1);
DEFINE dMtoComAnualTit  DECIMAL(18,2);
DEFINE dMtoComAnualAdi  DECIMAL(18,2);
DEFINE dClvComAnualTit  CHAR(4);
DEFINE dClvComAnualAdi  CHAR(4);      
DEFINE cCat_adicional   CHAR(1);            -- FIN RQM 10 993 CAT / RQM 10 1253 CAT
DEFINE ctipo_archivo    VARCHAR(100);		--- INI AAME 20190218 RQM 10682-4
DEFINE cnombre CHAR(80); 
DEFINE cNom1_ini CHAR(1); 
DEFINE cNom2_ini CHAR(1); 
DEFINE cApellPat_ini CHAR(1);
DEFINE cApellMat_ini CHAR(1); 
DEFINE cexiste  CHAR(20); --- FIN AAME 20190218 RQM 10682-4

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cMensajeRet   = '';
LET cCodRet       = '000000';
LET cCodRetTDif   = '';
LET cEmpresa      = '';
LET ctpoenvio = ptipoenvio;
LET csucursal = '';
LET ctpomaquila = ptpomaquila;
LET cnumcte = '';
LET cnum_credito = '';
LET cnum_creditoupg = '';
LET cnomcliente1 = '';
LET cnomcliente2 = '';
LET capellpatcliente = '';
LET capellmatcliente = '';
LET cnombre_embosado = '';
LET cdir_calle1 = '';
LET cdir_calle2 = '';
LET cdir_colonia = '';
LET cdir_municipio = '';
LET cdir_estado = '';
LET cdir_cp = '';
LET ctipotarjeta = '';
LET cbintarjeta = '';
LET ccodproducto = '';
LET cfimagen = 'F';
LET cidimagen = '';
LET cfmaster = 'V';
LET cftitular = '';
LET cfemision = '';
LET cmembersince = '';
LET cwelcomekit  = 'V';
LET ccat  = '';
LET cinanuord = '';
LET cinanumor = '';
LET clineacredito = '';
LET ccant_solicitadas = '1';
LET cfecha_sol = CURRENT YEAR TO SECOND;
LET cnum_empleado = pejecutivo;
LET cenviasms = 'V';
LET cuser_insert = user;
LET dfecha_insert = CURRENT YEAR TO SECOND;
--Direcciones
LET vcodret			   = '';
LET vsecuencia		   = '';
LET vtipo_dir          = '';
LET vcalle             = '';
LET vcolonia           = '';
LET ventre_calles      = '';
LET vpais              = '';
LET vestado            = '';
LET vciudad            = '';
LET vmunicipio         = '';
LET vcod_postal        = '';
LET vapart_postal      = '';
LET vtipo_telef1       = '';
LET vtelefono1         = '';
LET vtipo_telef2       = '';
LET vtelefono2         = '';
LET vtipo_telef3       = '';
LET vtelefono3         = '';
LET vextension         = '';
LET vestado_inegi      = '';
LET vmunicipio_inegi   = '';
LET vlocalidad_inegi   = '';
LET vnumerociudad      = 0;
LET vnumeroextcalle    = '';
LET vnumerointcalle    = '';
LET vdepartamento      = '';
LET vnumerocalle       = 0;
LET vnumerocolonia     = 0;
LET vpuntocardinal     = '';
LET vunidadhabitac     = '';
LET vmanzana           = 0;
LET votros             = 0;
LET vandador           = 0;
LET vetapa             = 0;
LET vlote              = 0;
LET vedificio          = 0;
LET ventrada           = 0;
LET vobservaciones     = '';
LET vNomEdo            = '';
LET vNomCiudad         = '';
LET vNomColonia        = '';
LET vNomCalle          = '';
LET vCdCoppel          = '';
LET vNomLote           = '';
LET vNomEntrada        = '';
LET vNomEdificio       = '';
LET vNomEtapa          = '';
LET vNomAndador        = '';
LET vNomOtros          = '';
LET vNomManzana        = '';
LET vSec               = 0;
LET vNomMunicipio      = '';
LET cnum_producto	   = '';
LET ctipo_proceso	   = '';
LET V_TASA_INTERES     = 0;
LET V_TASA_MORA        = 0;
LET V_SOBRETASA        = 0;
LET V_FACTOR	       = '';
LET V_SOBRETASA_MORA   = 0;	
LET V_FACTOR_MORA      = '';
LET vDiaCorte          = date(1);
LET cnumtarjeta  	   = '';
LET ccanal  		   = '';
LET codCat			   = '';
LET vCatFinal =0;
LET dPagoReq =0;
LET dMonto  = 0;
LET dComisiones =0;
LET dComisiones_gc =0;
LET dAnualidad =0;
--Embozado
LET i=0;
LET iContador = 0;
LET sCadena = "";
LET sCampo_cadena = "";

LET cCobro_Apertu   = '';       -- INI RQM 10 993 CAT / RQM 10 1253 CAT
LET cCodComis_Apert = '';
LET mMntoComApert   = 0;            -- Monto Comision Apertura
LET mMntoComAnual   = 0;            -- Monto Comision Anualidad
LET cCobrComisAnual = '';
LET dMtoComAnualTit = 0;
LET dMtoComAnualAdi = 0;
LET dClvComAnualTit = '';
LET dClvComAnualAdi = '';
LET cCat_adicional  = '';       -- FIN RQM 10 993 CAT / RQM 10 1253 CAT
LET ctipo_archivo   = '';  		--- INI AAME 20190218 RQM 10682-4
LET cNombre = ''; 
LET cNom1_ini = ''; 
LET cNom2_ini = ''; 
LET cApellPat_ini = ''; 
LET cApellMat_ini = ''; 
LET cexiste = ''; 				--- FIN AAME 20190218 RQM 10682-4

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet,ctpoenvio ,csucursal ,ctpomaquila ,cnumcte ,cnum_credito ,cnomcliente1 ,cnomcliente2 ,capellpatcliente ,capellmatcliente,cdir_calle1 ,cdir_calle2 ,cdir_colonia ,cdir_municipio ,cdir_estado ,cdir_cp ,ctipotarjeta ,cbintarjeta ,ccodproducto ,cfimagen ,cidimagen,cfmaster ,cftitular ,cfemision ,cmembersince ,cwelcomekit  ,ccat  ,cinanuord ,cinanumor ,clineacredito ,ccant_solicitadas ,cfecha_sol ,cnum_empleado ,cenviasms,cnumtarjeta,ccanal,cnum_producto;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/ifxsif01/roman/ambientacion/TDC_INFINITE/Spl/sp_obtensolicitudmaquilatdc_'||ptpoejecucion||'.out';
--TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT empresa
INTO cEmpresa
FROM bdinteg:si_empresas
WHERE empresa= pEmpresa;

IF TRIM(NVL(cEmpresa,'')) = '' OR TRIM(NVL(pnumcte,'')) = '' OR TRIM(NVL(pnum_credito,'')) = '' OR TRIM(NVL(ptpoejecucion,'')) = '' THEN
  LET cCodRet = '000001';
  RETURN cCodRet,ctpoenvio ,csucursal ,ctpomaquila ,cnumcte ,cnum_credito ,cnomcliente1 ,cnomcliente2 ,capellpatcliente ,capellmatcliente,cdir_calle1 ,cdir_calle2 ,cdir_colonia ,cdir_municipio ,cdir_estado ,cdir_cp ,ctipotarjeta ,cbintarjeta ,ccodproducto ,cfimagen ,cidimagen,cfmaster ,cftitular ,cfemision ,cmembersince ,cwelcomekit  ,ccat  ,cinanuord ,cinanumor ,clineacredito ,ccant_solicitadas ,cfecha_sol ,cnum_empleado ,cenviasms,cnumtarjeta,ccanal,cnum_producto;
END IF;

IF ptpoejecucion IN ('1','2') THEN

		IF ptpoejecucion = '1' THEN

			SELECT nombre_embosado,numero_solicitud_oro
			INTO cnombre_embosado,cnum_credito
			FROM bdisolic:"informix".ss_solicitudes_tdcoro
			WHERE numero_solicitud = pnum_credito and numcte = pnumcte;

			SELECT numcte,substr(YEAR(fecha_insert),3,2),num_producto,monto_solicitado,monto_solicitado,sucursal
			INTO cnumcte,cmembersince,cnum_producto,clineacredito,dMonto,csucursal
			FROM bdisolic:"informix".ss_solicitudes
			WHERE num_solicitud = cnum_credito;

			LET cftitular = 'T';
			LET cfemision = 'P';
			LET ccanal='OFI';

		ELIF ptpoejecucion = '2' THEN

			SELECT nombre_embosado,num_credito,numcte,tipo_dom, num_producto_upgrade,substr(tipotar,1,1),tipo_proceso,nombre_archivo--,numerotarjeta
			  INTO cnombre_embosado,cnum_credito,cnumcte,vtipo_dir,cnum_producto,cftitular,ctipo_proceso,ctipo_archivo--,cnumtarjeta
			  FROM bdicred:"informix".sd_credito_upgrade
			 WHERE num_credito = pnum_credito and numcte = pnumcte;
							
			IF NVL(cnum_credito,'') = '' THEN
				--AAME 22052019 RQM 10682-4 Si el credito que solicita el plastico no nacio por upgrade se obtiene sus datos, sucursal y miembro desde
				SELECT num_credito, numcte, num_producto, substr(YEAR(fecha_apertura),3,2),sucursal
				INTO cnum_credito, cnumcte, cnum_producto,cmembersince,csucursal
				FROM bdicred:"informix".sd_maecred 
				WHERE num_credito = pnum_credito;
				--Se consulta el tipo de tarjeta
				SELECT tipo_tarjeta INTO cftitular FROM bdicred:"informix".sd_tarjeta WHERE num_credito = pnum_credito and numcte = pnumcte AND status_tar='A';
				
				IF cftitular ='A' THEN
					SELECT tipo_dom, num_producto_upgrade,substr(tipotar,1,1),tipo_proceso,nombre_archivo--,numerotarjeta
					INTO vtipo_dir,cnum_producto,cftitular,ctipo_proceso,ctipo_archivo--,cnumtarjeta
					FROM bdicred:"informix".sd_credito_upgrade
					WHERE num_credito = cnum_credito and numcte = cnumcte;
				END IF;
				
				LET ctipo_proceso = '2';
				
				IF ctpoenvio = 'D' THEN
					LET vtipo_dir = '1';
				END IF;
				EXECUTE PROCEDURE bdicred:"informix".sp_nom_embozado_upgrade(cEmpresa, pNumcte)
				INTO cCodRet, cnomcliente1,cnomcliente2,capellpatcliente,capellmatcliente,cNom1_ini,cNom2_ini,cApellPat_ini,cApellMat_ini;
				IF cCodRet::INTEGER <> 0 THEN
					  LET cMensajeRet = 'Error al obtener el embozado del cliente';					 
				END IF;		
				IF cnomcliente1 <> '' AND cnomcliente2 <> '' THEN
					LET cnombre_embosado = TRIM (NVL(cNom1_ini,'')) || " " || TRIM(NVL(cnomcliente2,'')) || " " || TRIM(NVL(capellpatcliente,'')) || " " || TRIM(NVL(cApellMat_ini,''));
				ELSE 
					LET cnombre_embosado = TRIM (NVL(cnomcliente1,'')) || " " || TRIM(NVL(cNom2_ini,'')) || " " || TRIM(NVL(capellpatcliente,'')) || " " || TRIM(NVL(cApellMat_ini,''));
				END IF;
							
			ELSE
				--se obtiene sucursal y miembro desde
				SELECT substr(YEAR(fecha_apertura),3,2),sucursal
				INTO cmembersince,csucursal
				FROM bdicred:"informix".sd_maecred
				WHERE num_credito = pnum_credito;

			END IF;
			IF psucursal <> '' THEN
				LET csucursal=psucursal;
			END IF;

			--se obtiene linea de credito
			SELECT monto_otorgado,monto_otorgado
			INTO clineacredito,dMonto
			FROM bdicred:"informix".sd_maesdos
			WHERE num_credito = pnum_credito;

			--Se obtiene bandera si es primer asignacion o reposicion
			IF ctipo_proceso = 3 THEN
				LET cfemision = 'S'; --reposicion
				LET ccanal='OFI';
			ELSE
				--- AAME 20190218 RQM 10682-4 Se contempla solicitud de Reposicion por SOC
				IF substr(ctipo_archivo,1,13) = 'CAMBIOPRODTDC' Then
					LET cfemision = 'P'; --primer asignacion
				ELIF substr(ctipo_archivo,1,16) = 'CAMBIOPRODTDCREP' Then
					LET cfemision = 'S'; --reposicion
				ELSE
					LET cfemision = 'P'; --primer asignacion
				END IF;				
					LET ccanal='SOC';
			END IF;

		END IF;

			--se obtienen datos del cliente
			SELECT a.nombre1,
			a.nombre2,
			a.apell_paterno,
			a.apell_materno
			INTO cnomcliente1,cnomcliente2,capellpatcliente,capellmatcliente
			FROM bdinteg:"informix".si_cliente a
			WHERE a.numcte = pNumcte;

			LET cnomcliente1 = TRIM(nvl(cnomcliente1,''));
			LET cnomcliente2 = TRIM(nvl(cnomcliente2,''));
			LET capellpatcliente= TRIM(nvl(capellpatcliente,''));
			LET capellmatcliente= TRIM(nvl(capellmatcliente,''));
			LET cnombre = cnomcliente1 || " " || cnomcliente2 || " " || capellpatcliente || " " || capellmatcliente;
			
			--se obtienen datos la direccion del cliente
			IF ctpoenvio = 'D' THEN

			EXECUTE PROCEDURE bdinteg:"informix".sp_consdirec( cEmpresa,
														pNumcte,
														vtipo_dir)
			INTO vcodret, vsecuencia, vtipo_dir, vcalle, vcolonia, ventre_calles, vpais, vestado,
			   vciudad, vmunicipio, vcod_postal, vapart_postal, vtipo_telef1, vtelefono1, vtipo_telef2, vtelefono2,
			   vtipo_telef3, vtelefono3, vextension, vestado_inegi, vmunicipio_inegi, vlocalidad_inegi, vnumerociudad, vnumeroextcalle,
			   vnumerointcalle, vdepartamento, vnumerocalle, vnumerocolonia, vpuntocardinal, vunidadhabitac, vmanzana, votros,
			   vandador, vetapa, vlote, vedificio, ventrada, vobservaciones, vNomEdo, vNomCiudad,
			   vNomColonia, vNomCalle, vNomMunicipio, vNomLote, vNomEntrada, vNomEdificio, vNomEtapa, vNomAndador, vNomOtros, vNomManzana;

				IF vcodret <> '000' THEN
					  LET cMensajeRet = 'Error al obtener la informaciÃ³n del domicilio del Cliente';					 
						--- AAME 20190218 RQM 10682-4 SE GUARDA INFORMACIÃN DE REPORTERÃA
						/*EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cnum_credito ,cnumtarjeta,ccodproducto, ctipotarjeta, cnombre,'1','NO','NO',cMensajeRet,pejecutivo,ctipo_archivo,dfecha_insert)
						INTO cCodRet,cMensajeRet;*/
						
					RETURN vcodret,NVL(ctpoenvio,'') ,NVL(csucursal,'') ,NVL(ctpomaquila,'') ,NVL(cnumcte,'') ,NVL(cnum_credito,'') ,NVL(cnomcliente1,'') ,NVL(cnomcliente2,'') ,NVL(capellpatcliente,'') ,NVL(capellmatcliente,''),NVL(cdir_calle1,'') ,NVL(cdir_calle2,'') ,NVL(cdir_colonia,'') ,NVL(cdir_municipio,'') ,NVL(cdir_estado ,''),NVL(cdir_cp,'') ,NVL(ctipotarjeta,'') ,NVL(cbintarjeta,'') ,NVL(ccodproducto,'') ,NVL(cfimagen,'') ,NVL(cidimagen,''),NVL(cfmaster,'') ,NVL(cftitular,'') ,NVL(cfemision,'') ,NVL(cmembersince,'') ,NVL(cwelcomekit,'')  ,NVL(ccat,'')  ,NVL(cinanuord,'') ,NVL(cinanumor,'') ,NVL(clineacredito,'') ,NVL(ccant_solicitadas,''),NVL(cfecha_sol,'') ,NVL(cnum_empleado,''),NVL(cenviasms,''),NVL(cnumtarjeta,''),NVL(ccanal,''),NVL(cnum_producto,'');
				END IF;

				LET cdir_calle1 = TRIM(nvl(vcalle,''))||' '||TRIM(nvl(vnumerocalle,''))||' '||TRIM(nvl(vNomCalle,''));
				LET cdir_calle2 = TRIM(nvl(vnumeroextcalle,''))||' '|| TRIM(nvl(vnumerointcalle,'')) ||' '|| TRIM(nvl(vdepartamento,''));
				LET cdir_colonia = TRIM(nvl(vcolonia,''))||' '||TRIM(nvl(vnumerocolonia,''))||' '||TRIM(nvl(vNomColonia,''));
				LET cdir_municipio = TRIM(nvl(vmunicipio,'00000'))||' '||TRIM(nvl(vNomMunicipio,''));
				LET cdir_estado = TRIM(nvl(vestado,''))||' '||TRIM(nvl(vNomEdo,''));
				LET cdir_cp = vcod_postal;
			END IF;

			  -- ****************************
			  -- Determina Tasas de Interes *
			  -- ****************************
			--INTERES ORDINARIO E INTERES MORATORIO
			EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(cEmpresa , pnum_credito, cnum_producto) INTO cCodRetTDif, V_TASA_INTERES, V_TASA_MORA;
			IF cCodRetTDif <> '000000' THEN
				LET vcodret = cCodRetTDif;
				RETURN vcodret,NVL(ctpoenvio,'') ,NVL(csucursal,'') ,NVL(ctpomaquila,'') ,NVL(cnumcte,'') ,NVL(cnum_credito,'') ,NVL(cnomcliente1,'') ,NVL(cnomcliente2,'') ,NVL(capellpatcliente,'') ,NVL(capellmatcliente,''),NVL(cdir_calle1,'') ,NVL(cdir_calle2,'') ,NVL(cdir_colonia,'') ,NVL(cdir_municipio,'') ,NVL(cdir_estado ,''),NVL(cdir_cp,'') ,NVL(ctipotarjeta,'') ,NVL(cbintarjeta,'') ,NVL(ccodproducto,'') ,NVL(cfimagen,'') ,NVL(cidimagen,''),NVL(cfmaster,'') ,NVL(cftitular,'') ,NVL(cfemision,'') ,NVL(cmembersince,'') ,NVL(cwelcomekit,'')  ,NVL(ccat,'')  ,NVL(cinanuord,'') ,NVL(cinanumor,'') ,NVL(clineacredito,'') ,NVL(ccant_solicitadas,''),NVL(cfecha_sol,'') ,NVL(cnum_empleado,''),NVL(cenviasms,''),NVL(cnumtarjeta,''),NVL(ccanal,''),NVL(cnum_producto,'');
			END IF;
	
			/*SELECT c.valor, a.factor_sobretasa, a.sobretasa, a.dia_cuota
			  INTO V_TASA_INTERES, V_FACTOR, V_SOBRETASA, vDiaCorte
			  FROM bdicred:"informix".sd_definicion a,
				   bdinteg:"informix".si_fechavalor c
			 WHERE a.empresa = cEmpresa
			   AND a.num_producto = cnum_producto
			   AND c.empresa = a.empresa
			   AND c.tasa = a.cod_tasa_base
			   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
					   WHERE r.empresa = cEmpresa
						 AND r.tasa = a.cod_tasa_base);
			*/					--	RQM 10 1224						 

			SELECT a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.fact_sobret_mora, a.sobretasa_mora
			  INTO V_FACTOR,           V_SOBRETASA, vDiaCorte,   V_FACTOR_MORA,      V_SOBRETASA_MORA
			  FROM bdicred:"informix".sd_definicion a
			 WHERE a.empresa = cEmpresa AND a.num_producto = cnum_producto;
						 
			IF v_factor = "+" THEN
				LET V_TASA_INTERES = V_TASA_INTERES + V_SOBRETASA;
			ELIF v_factor = "-" THEN
				LET V_TASA_INTERES = V_TASA_INTERES - V_SOBRETASA;
			ELIF v_factor = "*" THEN
				LET V_TASA_INTERES = V_TASA_INTERES * V_SOBRETASA;
			ELSE
				LET V_TASA_INTERES = V_TASA_INTERES / V_SOBRETASA;
			END IF

			LET cinanuord = V_TASA_INTERES::CHAR(5);

				--INTERES MORATORIO
				/*SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
				  INTO V_TASA_MORA   , V_FACTOR, V_SOBRETASA
				  FROM bdicred:"informix".sd_definicion a,
					   bdinteg:"informix".si_fechavalor c
				 WHERE a.empresa = cEmpresa
				   AND a.num_producto = cnum_producto
				   AND c.empresa = a.empresa
				   AND c.tasa = a.cod_tasa_mora
				   AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
								   WHERE r.empresa = cEmpresa
									 AND r.tasa = a.cod_tasa_mora);
				*/				--	RQM 10 1224								 

				IF V_FACTOR_MORA = "+" THEN
						LET V_TASA_MORA = V_TASA_MORA + V_SOBRETASA_MORA;
				ELIF V_FACTOR_MORA = "-" THEN
						LET V_TASA_MORA = V_TASA_MORA - V_SOBRETASA_MORA;
				ELIF V_FACTOR_MORA = "*" THEN
						LET V_TASA_MORA = V_TASA_MORA * V_SOBRETASA_MORA;
				ELSE
						LET V_TASA_MORA = V_TASA_MORA / V_SOBRETASA_MORA;
				END IF

				LET V_TASA_MORA = V_TASA_MORA - V_TASA_INTERES;
				IF V_TASA_MORA < 0 THEN --Si es Menor a Cero la vuelve Positivo
				   LET V_TASA_MORA = V_TASA_MORA * -1;
				END IF

				LET cinanumor = V_TASA_MORA::CHAR(5);
				
				IF NVL(cinanumor, '') = '' THEN
					LET cinanumor = '0.000';
				END IF;

				-- AAME 18072019 INI Se agrega calculo del CAT igual al de Portada de Apertura RQM 10 1253
				LET dPagoReq = dMonto * (V_TASA_INTERES /100) / 360 * 30 ;
				/*IF cnum_producto in ('7000','8100') THEN
					IF cnum_producto ='7000' then
						LET dAnualidad = 1500;
					ELSE
						LET dAnualidad = 250;
					END IF;
					LET dComisiones = 0;
					LET dComisiones_gc = 0;

				ELSE
					LET dComisiones = 50;
					LET dAnualidad = 0;
				END IF;*/
				
				-- Extrae Parametro Comision Apertura y Comision por Anualidad (titular y adicional) para calculo del CAT
				SELECT nvl(cobro_comis_apertura,'0'), nvl(cod_comision_apertura,''), cobro_comision_anual, substr(cod_comision_anualidad,1,4), 
				   substr(cod_comision_anualidad,5,4), cat_comi_anual_adicional 
			    INTO cCobro_Apertu, cCodComis_Apert, cCobrComisAnual, dClvComAnualTit, dClvComAnualAdi, cCat_adicional               
			    FROM bdicred:sd_definicion WHERE num_producto = cnum_producto;	-- Obtiene clave de comision anualidad.
				IF cCobro_Apertu = '1' THEN    -- Si el producto tiene asignado cobro de comision por apertura.
					SELECT monto INTO mMntoComApert FROM bdicred:"informix".sd_tpcomis WHERE empresa = '001' AND cod_comis = cCodComis_Apert; 
					LET mMntoComApert = NVL(mMntoComApert,0);								-- Se toma cat originacion. Se agrega com apertura
				END IF;

				IF cCobrComisAnual = '1' THEN   -- Si el producto tiene cobro de comision por anualidad.
					SELECT monto INTO dMtoComAnualTit FROM bdicred:sd_tpcomis WHERE cod_comis = dClvComAnualTit;    -- Monto anualidad titular
					SELECT monto INTO dMtoComAnualAdi FROM bdicred:sd_tpcomis WHERE cod_comis = dClvComAnualAdi;    -- Monto anualidad adicional
					LET dMtoComAnualTit = nvl(dMtoComAnualTit,0);
					LET dMtoComAnualAdi = nvl(dMtoComAnualAdi,0);	
					
					IF cCat_adicional = '0' THEN LET dMtoComAnualAdi = 0; END IF; -- Si adicional no se agrega al CAT, se asigna valor cero.
					LET mMntoComAnual = dMtoComAnualTit + dMtoComAnualAdi;
				ELSE
					LET mMntoComAnual = 0;
				END IF;
				
				LET dComisiones = mMntoComApert;
				LET dAnualidad = mMntoComAnual;
				LET dComisiones_gc = 0;
				--/*
				--EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(dMonto,dPagoReq,36,36,dComisiones,dComisiones_gc,dAnualidad)
				EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(dMonto,dPagoReq,36,36,dComisiones,dComisiones_gc,dAnualidad, V_TASA_INTERES) 
				INTO cCodRet,cMensajeRet,vCatFinal;

				IF cCodRet::integer = 0 THEN
					LET ccat=vCatFinal;
				END IF;			-- AAME 18072019 FIN Se agrega calculo del CAT igual al de Portada de Apertura RQM 10 1253
			-- Se obtienen datos de la tarjeta del cliente
			IF cnum_producto ='8100' THEN
					SELECT clave_tipotarjeta,bin,codproductotarjeta
					INTO ctipotarjeta ,cbintarjeta ,ccodproducto
					FROM intercard:"informix".tipotarjeta
					WHERE tipo ='C' AND clave_tipotarjeta=10;
					--Codigo de valor del Cat de Oro
					LET codCat = '093';

			ELIF cnum_producto ='7000' THEN
					SELECT clave_tipotarjeta,bin,codproductotarjeta
					INTO ctipotarjeta ,cbintarjeta ,ccodproducto
					FROM intercard:"informix".tipotarjeta
					WHERE tipo ='C' AND clave_tipotarjeta=9;

					--Obtencion del valor del CAT Platino
					LET codCat = '091';

			ELIF cnum_producto ='6001' THEN
					SELECT clave_tipotarjeta,bin,codproductotarjeta
					INTO ctipotarjeta ,cbintarjeta ,ccodproducto
					FROM intercard:"informix".tipotarjeta
					WHERE tipo ='C' AND clave_tipotarjeta=2;

					--Obtencion del valor del CAT de TDC
					LET codCat = '034';
			
			ELIF cnum_producto ='5400' THEN
					SELECT clave_tipotarjeta,bin,codproductotarjeta
					INTO ctipotarjeta ,cbintarjeta ,ccodproducto
					FROM intercard:"informix".tipotarjeta
					WHERE tipo ='C' AND clave_tipotarjeta=78;

					--Obtencion del valor del CAT de TDC INFINITE
					LET codCat = '';
					--SE CAMBIA EL VALOR DE CAT PARA LA PRUEBA
					--LET ccat = '82.86';
			END IF;
			
			IF NVL(ccat,'') = '' THEN
				--AAME RQM 10 679 Se contempla nuevo parametro para el valor de CAT de TDC ORO
				SELECT valor INTO ccat
				FROM bdicred:"informix".sd_param
				WHERE empresa = pempresa
				AND cod_param = codCat;

				IF NVL(ccat,'') = '' THEN
					LET ccat = '0.0';
				END IF
			END IF;
			
			SELECT num_credito
			INTO cexiste
			FROM bdisolic:"informix".ss_solicitud_maquilatdc
			WHERE empresa = cEmpresa AND numcte = pnumcte AND num_credito = pnum_credito;
						
			IF  NVL(cexiste,'') = '' THEN

				INSERT INTO bdisolic:"informix".ss_solicitud_maquilatdc(empresa,tpoenvio,sucursal,tpomaquila,numcte,num_credito,nomcliente1,nomcliente2,apellpatcliente,apellmatcliente,nombre_embosado,dir_calle1,dir_calle2,dir_colonia,dir_municipio,dir_estado,dir_cp,tipotarjeta,bintarjeta,codproducto,fimagen,idimagen,fmaster,ftitular,femision,membersince,welcomekit,cat,inanuord,inanumor,lineacredito,cant_solicitadas ,fecha_sol,num_empleado,enviasms,numtarjeta,canal,producto,user_insert,fecha_insert)
				VALUES(cEmpresa,ctpoenvio ,csucursal ,ctpomaquila ,cnumcte ,cnum_credito ,cnomcliente1 ,cnomcliente2 ,capellpatcliente ,capellmatcliente,cnombre_embosado,cdir_calle1 ,cdir_calle2 ,cdir_colonia ,cdir_municipio ,cdir_estado ,cdir_cp ,ctipotarjeta ,cbintarjeta ,ccodproducto ,cfimagen ,cidimagen,cfmaster ,cftitular ,cfemision ,cmembersince ,cwelcomekit  ,ccat  ,cinanuord ,cinanumor ,clineacredito ,ccant_solicitadas ,cfecha_sol ,cnum_empleado ,cenviasms,cnumtarjeta,ccanal,cnum_producto,cuser_insert,dfecha_insert);

			END IF;
				-- AAME 20190218 RQM 10682-4 SE GUARDA INFORMACIÃN DE REPORTERÃA																			
			--EXECUTE PROCEDURE bdicred:"informix".sp_grabadetallearchivotdc(cnum_credito, cnumtarjeta, cnum_producto, ctipotarjeta, cnombre ,'0','SI','SI',cMensajeRet,pejecutivo,ctipo_archivo,dfecha_insert)
			--INTO cCodRet,cMensajeRet;
			
			LET cnombre_embosado = cnombre_embosado || " ";
			LET cnomcliente1 ="";
			LET cnomcliente2 ="";
			LET capellpatcliente="";
			LET capellmatcliente="";
			 For i = 1 To Length(cnombre_embosado) STEP 1
				 --Recorre la cadena leÃ­da del embozado y se divide en 4 campos
				 If substr(cnombre_embosado, i, 1) = " " Then
					LET iContador = iContador + 1;
					IF substr(cnombre_embosado, i-1, 1) = " " THEN
						LET sCampo_cadena = " ";
					END IF;
					If iContador= 1 THEN
						LET cnomcliente1 = sCampo_cadena;
						LET cnomcliente1 = cnomcliente1;
					Elif iContador= 2 THEN
						LET cnomcliente2 = sCampo_cadena;
						LET cnomcliente2 = cnomcliente2;
					Elif iContador= 3 THEN
						LET capellpatcliente = sCampo_cadena;
						LET capellpatcliente = capellpatcliente;
					/*Elif iContador= 4 THEN
						LET capellmatcliente = sCampo_cadena;
						LET capellmatcliente = capellmatcliente;*/
					End if
					LET sCampo_cadena = "";
				 Else
					LET sCampo_cadena = TRIM(sCampo_cadena) || substr(cnombre_embosado, i, 1);
					If i = Length(cnombre_embosado) AND capellpatcliente <> '' THEN
						LET capellmatcliente = sCampo_cadena;
					Else
						IF i = Length(cnombre_embosado) THEN
							LET capellpatcliente = sCampo_cadena;
						END IF;
					End if;

				 End If;

			END FOR;

ELIF ptpoejecucion = '3' THEN

	SELECT numero_solicitud_oro
	INTO cnum_credito
	FROM bdisolic:"informix".ss_solicitudes_tdcoro
	WHERE numero_solicitud = pnum_credito and numcte = pnumcte;

		IF cnum_credito IS NULL THEN
			/*SELECT numerotarjeta
			INTO cnumtarjeta


			FROM bdicred:"informix".sd_credito_upgrade
			WHERE num_credito = pnum_credito and numcte = pnumcte;*/

			DELETE FROM bdisolic:"informix".ss_solicitud_maquilatdc WHERE num_credito =cnum_credito;
			--DELETE FROM bdicred:"informix".sd_credito_upgrade WHERE num_credito = pnum_credito and numcte = pnumcte;

		ELSE
			DELETE FROM bdisolic:"informix".ss_solicitud_maquilatdc WHERE num_credito =cnum_credito;
			--02092019 INC 27 129 Se corrige nombre de BD.
			DELETE FROM bdisolic:"informix".ss_solicitudes_tdcoro WHERE numero_solicitud = pnum_credito and numcte = pnumcte;

		END IF

END IF;

  RETURN cCodRet,NVL(ctpoenvio,'') ,NVL(csucursal,'') ,NVL(ctpomaquila,'') ,NVL(cnumcte,'') ,NVL(cnum_credito,'') ,NVL(cnomcliente1,'') ,NVL(cnomcliente2,'') ,NVL(capellpatcliente,'') ,NVL(capellmatcliente,''),NVL(cdir_calle1,'') ,NVL(cdir_calle2,'') ,NVL(cdir_colonia,'') ,NVL(cdir_municipio,'') ,NVL(cdir_estado ,''),NVL(cdir_cp,'') ,NVL(ctipotarjeta,'') ,NVL(cbintarjeta,'') ,NVL(ccodproducto,'') ,NVL(cfimagen,'') ,NVL(cidimagen,''),NVL(cfmaster,'') ,NVL(cftitular,'') ,NVL(cfemision,'') ,NVL(cmembersince,'') ,NVL(cwelcomekit,'')  ,NVL(ccat,'')  ,NVL(cinanuord,'') ,NVL(cinanumor,'') ,NVL(clineacredito,'') ,NVL(ccant_solicitadas,''),NVL(cfecha_sol,'') ,NVL(cnum_empleado,''),NVL(cenviasms,''),NVL(cnumtarjeta,''),NVL(ccanal,''),NVL(cnum_producto,'');

END
END PROCEDURE
