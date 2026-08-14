CREATE PROCEDURE "informix".sp_generaarchivoaltacliente(pempresa CHAR(3), pFechaAct DATE)
RETURNING CHAR(6);
										 
--DEFINICION DE VARIABLES
--CLIENTE
DEFINE vClave CHAR(1); --DEFAULT A
DEFINE vcaja SMALLINT;DEFINE varea CHAR(1); --DEFAULT N
DEFINE vcliente_ref CHAR(20); --Cliente Coppel --INT
DEFINE vnombre1 CHAR(26);
DEFINE vnombre2 CHAR(26);
DEFINE vapell_paterno CHAR(26);
DEFINE vapell_materno CHAR(26);
DEFINE vcurp CHAR(18);
DEFINE vclaveelector CHAR(18);
DEFINE vclaveidentificacion CHAR(2);
DEFINE videntificacion CHAR(8); --DEFAULT BLANCO
DEFINE vciudad SMALLINT;
DEFINE vcolonia INTEGER;
DEFINE vcalle INTEGER;
DEFINE snumerocasa INTEGER;
DEFINE vdeptointerior CHAR(4);
DEFINE vrumbo CHAR(1);
DEFINE vcomplemento CHAR(80);
DEFINE ventrecalles CHAR(40);
DEFINE vflaguhc SMALLINT;
DEFINE vuhcmanzana SMALLINT;
DEFINE vuhcotros SMALLINT;
DEFINE vuhcandador SMALLINT;
DEFINE vuhcetapa SMALLINT; 
DEFINE vuhclote  SMALLINT;
DEFINE vuhcedificio SMALLINT;
DEFINE vuhcentrada SMALLINT;
DEFINE vtelefono INT8;
DEFINE vtelefonocelular INT8;
DEFINE vcasapropia CHAR(1);
DEFINE vniptitular CHAR(7); --DEFAULT BLANCO
DEFINE vnipadicional CHAR(7); --DEFAULT BLACO
DEFINE vsexo CHAR(1);
DEFINE vestadocivil CHAR(1);
DEFINE cfechanac CHAR(10);
DEFINE cfechadesdecuandovive CHAR(10);
DEFINE vpersonasvivenendomicilio INTEGER;
DEFINE vescolaridad CHAR(1);
DEFINE vtiposueldo CHAR(1);
DEFINE vnumerodependientes SMALLINT;
DEFINE vpersonastrabajan SMALLINT;
DEFINE vlimitecredito SMALLINT;
DEFINE vingresomensual SMALLINT;
DEFINE vsituacionespecial CHAR(1);
DEFINE vcausasituacionespecial SMALLINT;
DEFINE vclaveautrechaza CHAR(1); --DEFAULT 2
DEFINE vaceptadosupervisadorechazado CHAR(1); --DEFAULT BLACO
DEFINE vclientenuevo CHAR(1); --DEFAULT N
DEFINE vcreditojoven CHAR(1);
DEFINE vlugartrabajo CHAR(20);
DEFINE vciudadtrabajo SMALLINT;
DEFINE vcoloniatrabajo  SMALLINT;
DEFINE vcalletrabajo  INTEGER;
DEFINE snumerocasatrabajo INTEGER;
DEFINE vdeptoointeriortrabajo CHAR(4);
DEFINE vrumbotrabajo CHAR(1);
DEFINE vcomplementotrabajo CHAR(80);
DEFINE ventrecallestrabajo CHAR(40);
DEFINE vflaguht SMALLINT;
DEFINE vuhtmanzana SMALLINT;
DEFINE vuhtotros SMALLINT;
DEFINE vuhtandador SMALLINT;
DEFINE vuhtetapa SMALLINT;
DEFINE vuhtlote SMALLINT;
DEFINE vuhtedificio SMALLINT;
DEFINE vuhtentrada SMALLINT;
DEFINE vtelefonotrabajo INT8;
DEFINE vextensiontrabajo INTEGER;
DEFINE vpuesto CHAR(1);
DEFINE vopcionpuesto SMALLINT;
DEFINE cfechaantiguedtrab CHAR(10);
--CONYUGE
DEFINE vclienteconyuge CHAR(20); --INT
DEFINE vnombreunoconyuge CHAR(26);
DEFINE vnombredosconyuge CHAR(26);
DEFINE vapellidopaternoconyuge CHAR(26);
DEFINE vapellidomaternoconyuge CHAR(26);
DEFINE vlugartrabajoconyuge CHAR(20);
DEFINE vciudadconyuge SMALLINT;
DEFINE vcoloniaconyuge INTEGER;
DEFINE vcalletrabajoconyuge INTEGER;
DEFINE snumerocasaconyugue INTEGER;
DEFINE vdeptoointeriorconyuge CHAR(4);
DEFINE vrumbotrabajoconyuge CHAR(1);
DEFINE vcomplementoconyuge CHAR(80);
DEFINE ventrecallesconyuge CHAR(40);
DEFINE vflaguhy SMALLINT;
DEFINE vuhymanzana SMALLINT;
DEFINE vuhyotros SMALLINT;
DEFINE vuhyandador  SMALLINT;
DEFINE vuhyetapa SMALLINT;
DEFINE vuhylote SMALLINT;
DEFINE vuhyedificio SMALLINT;
DEFINE vuhyentrada SMALLINT;
DEFINE vtelefonotrabajoconyuge INT8;
DEFINE vtelefonocelularconyuge INT8;
DEFINE vclaveconyugefamilia CHAR (1);
--REFERENCIA 1
DEFINE vclientereferencia CHAR(20); --INT
DEFINE vnombreunoreferencia CHAR(26);
DEFINE vnombredosreferencia CHAR(26);
DEFINE vapellidopaternoreferencia CHAR(26);
DEFINE vapellidomaternoreferencia CHAR(26);
DEFINE vciudadreferencia SMALLINT;
DEFINE vcoloniareferencia INTEGER;
DEFINE vcallereferencia INTEGER;
DEFINE snumerocasaref INTEGER;
DEFINE vdeptoointeriorreferencia CHAR(4);
DEFINE vrumboreferencia CHAR(1);
DEFINE vcomplementoreferencia CHAR(80);
DEFINE ventrecallesreferencia1 CHAR(40);
DEFINE vflaguhr SMALLINT;
DEFINE vuhrmanzana SMALLINT ;
DEFINE vuhrotros SMALLINT ;
DEFINE vuhrandador SMALLINT;
DEFINE vuhretapa SMALLINT;
DEFINE vuhrlote SMALLINT;
DEFINE vuhredificio SMALLINT;
DEFINE vuhrentrada SMALLINT;
DEFINE vtelefonoreferencia INT8;       
DEFINE vtelefonocelularreferencia INT8;
DEFINE vclavereferencia1 CHAR(1);
--REFERENCIA 2
DEFINE vclientereferencia2 CHAR(20);
DEFINE vnombreunoreferencia2 CHAR(26);
DEFINE vnombredosreferencia2 CHAR(26);
DEFINE vapellidopaternoreferencia2 CHAR(26);
DEFINE vapellidomaternoreferencia2 CHAR(26);
DEFINE vciudadreferencia2 SMALLINT;
DEFINE vcoloniareferencia2 INTEGER;
DEFINE vcallereferencia2 INTEGER;
DEFINE snumerocasaref2 INTEGER;
DEFINE vdeptoointeriorreferencia2 CHAR(4);
DEFINE vrumboreferencia2 CHAR(1);
DEFINE vcomplementoreferencia2 CHAR(80);
DEFINE ventrecallesreferencia2 CHAR(40);
DEFINE vflaguhr2 SMALLINT;
DEFINE vuhrmanzana2 SMALLINT;
DEFINE vuhrotros2 SMALLINT;
DEFINE vuhrandador2 SMALLINT;
DEFINE vuhretapa2 SMALLINT;
DEFINE vuhrlote2 SMALLINT;
DEFINE vuhredificio2 SMALLINT;
DEFINE vuhrentrada2 SMALLINT;
DEFINE vtelefonoreferencia2 INT8;
DEFINE vtelefonocelularreferencia2 INT8;
DEFINE vclavereferencia2 CHAR(1);
------
DEFINE vreferencia2 INTEGER; --DEFAULT 0
DEFINE vreferencia3 INTEGER; --DEFAULT 0
DEFINE vmarcadatosin CHAR(1); --DEFAULT BLACO
DEFINE vtiporeposicion SMALLINT; --DEFAULT 0
DEFINE vreposicion INTEGER; --DEFAULT 0
DEFINE vflagentregotarjeta CHAR(1); --DEFAULT BLACO
DEFINE vefectuo INTEGER;
DEFINE vtiendafolio SMALLINT;
DEFINE vfolio CHAR(20);DEFINE cfechaaltacte CHAR (10);
DEFINE vflagnoreconocehuella CHAR(1); --DEFAULT BLACO
DEFINE vfoliotienda INTEGER; --DEFAULT 0
DEFINE vrfc CHAR(13); 
DEFINE vcveburo CHAR(2); --DEFAULT BLACO
DEFINE vfolioaut CHAR(4); --DEFAULT BLACO
DEFINE vfolioconsulta CHAR(9); --DEFAULT BLACO
DEFINE vfolioconcir CHAR(10); --DEFAULT BLACO
DEFINE vnegocio SMALLINT; --DEFAULT 0
DEFINE vsubnegocio SMALLINT; --DEFAULT 0
DEFINE vempleadoautorizo INTEGER; --DEFAULT 0
DEFINE vtipo CHAR(1); --DEFAULT BLACO
DEFINE cfechamovto CHAR (19);
DEFINE vnumerosolicituddecredito CHAR(20);
DEFINE vnumcte CHAR(20);
DEFINE vtiendafolioanterior SMALLINT;DEFINE vfolioanterior INTEGER; --DEFAULT BLACO
DEFINE vclaveproducto SMALLINT; --6500
DEFINE vflagactualizacion INTEGER; --DEFAULT BLACO
--------
DEFINE vSistsegsocial SMALLINT; --DEFAULT 0
DEFINE vTiposueldoext SMALLINT; --DEFAULT 0
DEFINE vNumempleados SMALLINT; --DEFAULT 0
DEFINE vSubopcionpuesto SMALLINT; --DEFAULT 0
DEFINE vPuestoext SMALLINT; --DEFAULT 0
DEFINE vOpcionpuestoext SMALLINT; --DEFAULT 0
DEFINE vNumempleadosext SMALLINT; --DEFAULT 0
DEFINE vSubopcionpuestoext SMALLINT; --DEFAULT 0
DEFINE vTipoOrigen CHAR(1);
DEFINE vTipoProducto CHAR(5);


--OTRAS VARIABLES
DEFINE vletrasnumcasa VARCHAR (10);
DEFINE vletrasnumtrabajo VARCHAR(10);
DEFINE vletrasnumtrabconyuge VARCHAR(10);
DEFINE vletrasnumcasaref VARCHAR(10);
DEFINE vletrasnumcasaref2 VARCHAR(10);
DEFINE cFolioSucursal CHAR(4);
DEFINE vHora DATETIME HOUR TO FRACTION(3);
DEFINE cflaguht CHAR(1);
DEFINE vfechanacimiento DATE; 
--DEFINE vfechadesdecuandoviveahi DATE; 
DEFINE iAniosHabita INTEGER;
--DEFINE vfechaantiguedadtrabajo DATE;
DEFINE vfechaaltacliente DATE;
DEFINE vfechamovto DATE;
DEFINE vcasa INTEGER;
DEFINE vcasatrabajo INTEGER; --INT
DEFINE vcasatrabajoconyuge CHAR(10);
DEFINE vcasareferencia CHAR(10);
DEFINE vcasareferencia2 CHAR(10);
DEFINE cUnidadHabit CHAR(1);
DEFINE vTipo_Dir CHAR(2);
DEFINE vFecha_Hoy DATE;
DEFINE vNombre CHAR(104);
DEFINE vEdad INTEGER;
DEFINE vsSQL LVARCHAR (32000);
DEFINE iSqlErr INTEGER;
DEFINE vCodRetorno Char(6);
DEFINE dFechaAlta DATE;
DEFINE cValor CHAR(20);
DEFINE iIngreso INTEGER;
DEFINE iPuntuacion INTEGER;
DEFINE cFecha_hoy CHAR (10);
DEFINE dEvaluacion1 DECIMAL(5,2);
DEFINE dEvaluacion2 DECIMAL(5,2);
DEFINE iSecuencia INTEGER;
DEFINE iElemento INTEGER;
DEFINE vcodret CHAR(5);
--DEFINE vfolio2 CHAR(20);
--DEFINE dfechasolicitud DATE;
--DEFINE vtiendafolio2 CHAR(5);
--DEFINE dFechaResidencia date;
--DEFINE dFechaLaborando date;
DEFINE vciudadbanco SMALLINT;
DEFINE vcoloniabanco INTEGER;

-- INICIALIZACION DE VARIABLES
--CLIENTE
LET vClave = 'A'; --DEFAULT A
LET vcaja = 100;LET varea = 'N'; --DEFAULT N
LET vcliente_ref = '0'; --Cliente Coppel --INT
LET vnombre1 = '';
LET vnombre2 = '';
LET vapell_paterno = '';
LET vapell_materno = '';
LET vcurp = '';
LET vclaveelector = '';
LET vclaveidentificacion = '';
LET videntificacion = ''; --DEFAULT BLANCO
LET vciudad = 0;
LET vcolonia = 0;
LET vcalle = 0;
LET snumerocasa = 0;
LET vdeptointerior = '';
LET vrumbo = '';
LET vcomplemento = '';
LET ventrecalles = '';
LET vflaguhc = 0;
LET vuhcmanzana = 0;
LET vuhcotros = 0;
LET vuhcandador = 0;
LET vuhcetapa = 0; 
LET vuhclote  = 0;
LET vuhcedificio = 0;
LET vuhcentrada = 0;
LET vtelefono = 0;
LET vtelefonocelular = 0;
LET vcasapropia = '';
LET vniptitular = ''; --DEFAULT BLANCO
LET vnipadicional = ''; --DEFAULT BLACO
LET vsexo = '';
LET vestadocivil = '';
LET cfechanac = '1900/01/01';
LET cfechadesdecuandovive = '1900/01/01';
LET vpersonasvivenendomicilio = 0;
LET vescolaridad = '';
LET vtiposueldo = '';
LET vnumerodependientes = 0;
LET vpersonastrabajan = 0;
LET vlimitecredito = 0;
LET vingresomensual = 0;
LET vsituacionespecial = '';
LET vcausasituacionespecial = 0;
LET vclaveautrechaza = '2'; --DEFAULT 2
LET vaceptadosupervisadorechazado = ''; --DEFAULT BLACO
LET vclientenuevo = 'N'; --DEFAULT N
LET vcreditojoven = '';
LET vlugartrabajo = '';
LET vciudadtrabajo = 0;
LET vcoloniatrabajo  = 0;
LET vcalletrabajo  = 0;
LET snumerocasatrabajo = 0;
LET vdeptoointeriortrabajo = '';
LET vrumbotrabajo = '';
LET vcomplementotrabajo = '';
LET ventrecallestrabajo = '';
LET vflaguht = 0;
LET vuhtmanzana = 0;
LET vuhtotros = 0;
LET vuhtandador = 0;
LET vuhtetapa = 0;
LET vuhtlote = 0;
LET vuhtedificio = 0;
LET vuhtentrada = 0;
LET vtelefonotrabajo = 0;
LET vextensiontrabajo = 0;
LET vpuesto = '0';
LET vopcionpuesto = 0;
LET cfechaantiguedtrab = '1900/01/01'; 
--CONYUGE
LET vclienteconyuge = '0'; --INT
LET vnombreunoconyuge = '';
LET vnombredosconyuge = '';
LET vapellidopaternoconyuge = '';
LET vapellidomaternoconyuge = '';
LET vlugartrabajoconyuge = '';
LET vciudadconyuge = 0;
LET vcoloniaconyuge = 0;
LET vcalletrabajoconyuge = 0;
LET snumerocasaconyugue = 0;
LET vdeptoointeriorconyuge = '';
LET vrumbotrabajoconyuge = '';
LET vcomplementoconyuge = '';
LET ventrecallesconyuge = '';
LET vflaguhy = 0;
LET vuhymanzana = 0;
LET vuhyotros = 0;
LET vuhyandador  = 0;
LET vuhyetapa = 0;
LET vuhylote = 0;
LET vuhyedificio = 0;
LET vuhyentrada = 0;
LET vtelefonotrabajoconyuge = 0;
LET vtelefonocelularconyuge = 0;
LET vclaveconyugefamilia = '';
--REFERENCIA 1
LET vclientereferencia = '0'; --INT
LET vnombreunoreferencia = '';
LET vnombredosreferencia = '';
LET vapellidopaternoreferencia = '';
LET vapellidomaternoreferencia = '';
LET vciudadreferencia = 0;
LET vcoloniareferencia = 0;
LET vcallereferencia = 0;
LET snumerocasaref = 0;
LET vdeptoointeriorreferencia = '';
LET vrumboreferencia = '';
LET vcomplementoreferencia = '';
LET ventrecallesreferencia1 = '';
LET vflaguhr = 0;
LET vuhrmanzana = 0 ;
LET vuhrotros = 0 ;
LET vuhrandador = 0;
LET vuhretapa = 0;
LET vuhrlote = 0;
LET vuhredificio = 0;
LET vuhrentrada = 0;
LET vtelefonoreferencia = 0;       
LET vtelefonocelularreferencia = 0;
LET vclavereferencia1 = '';
--REFERENCIA 2
LET vclientereferencia2 = '0';
LET vnombreunoreferencia2 = '';
LET vnombredosreferencia2 = '';
LET vapellidopaternoreferencia2 = '';
LET vapellidomaternoreferencia2 = '';
LET vciudadreferencia2 = 0;
LET vcoloniareferencia2 = 0;
LET vcallereferencia2 = 0;
LET snumerocasaref2 = 0;
LET vdeptoointeriorreferencia2 = '';
LET vrumboreferencia2 = '';
LET vcomplementoreferencia2 = '';
LET ventrecallesreferencia2 = '';
LET vflaguhr2 = 0;
LET vuhrmanzana2 = 0;
LET vuhrotros2 = 0;
LET vuhrandador2 = 0;
LET vuhretapa2 = 0;
LET vuhrlote2 = 0;
LET vuhredificio2 = 0;
LET vuhrentrada2 = 0;
LET vtelefonoreferencia2 = 0;
LET vtelefonocelularreferencia2 = 0;
LET vclavereferencia2 = '';
------
LET vreferencia2 = 0; --DEFAULT 0
LET vreferencia3 = 0; --DEFAULT 0
LET vmarcadatosin = ''; --DEFAULT BLACO
LET vtiporeposicion = 0; --DEFAULT 0
LET vreposicion = 0; --DEFAULT 0
LET vflagentregotarjeta = ''; --DEFAULT BLACO
LET vefectuo = 0;
LET vtiendafolio = 0;
LET vfolio = '0';LET cfechaaltacte = '1900/01/01';
LET vflagnoreconocehuella = ''; --DEFAULT BLACO
LET vfoliotienda = 0; --DEFAULT 0
LET vrfc = ''; 
LET vcveburo = ''; --DEFAULT BLACO
LET vfolioaut = ''; --DEFAULT BLACO
LET vfolioconsulta = ''; --DEFAULT BLACO
LET vfolioconcir = ''; --DEFAULT BLACO
LET vnegocio = 0; --DEFAULT 0
LET vsubnegocio = 0; --DEFAULT 0
LET vempleadoautorizo = 0; --DEFAULT 0
LET vtipo = ''; --DEFAULT BLACO
LET cfechamovto = '1900/01/01';
LET vnumerosolicituddecredito = '';
LET vnumcte = '';
LET vtiendafolioanterior = 0;LET vfolioanterior = 0; --DEFAULT BLACO
LET vclaveproducto = 6500; --6500
LET vflagactualizacion = 0; --DEFAULT BLACO
--------
LET vSistsegsocial = 0; --DEFAULT 0
LET vTiposueldoext = 0; --DEFAULT 0
LET vNumempleados = 0; --DEFAULT 0
LET vSubopcionpuesto = 0; --DEFAULT 0
LET vPuestoext = 0; --DEFAULT 0
LET vOpcionpuestoext = 0; --DEFAULT 0
LET vNumempleadosext = 0; --DEFAULT 0
LET vSubopcionpuestoext = 0; --DEFAULT 0
LET vTipoOrigen = 'G';
LET vTipoProducto = '11000';

--OTRAS VARIABLES
LET vletrasnumcasa = "";
LET vletrasnumtrabajo = "";
LET vletrasnumtrabconyuge = "";
LET vletrasnumcasaref = "";
LET vletrasnumcasaref2 = "";
LET cFolioSucursal = '';
LET vHora = '';
LET cflaguht = '';
LET vfechanacimiento = DATE(1); 
--LET vfechadesdecuandoviveahi = DATE(1); 
LET iAniosHabita = 0;
--LET vfechaantiguedadtrabajo = DATE(1);
LET vfechaaltacliente = DATE(1);
LET vfechamovto = DATE(1);
LET vcasa = 0;
LET vcasatrabajo = 0; --INT
LET vcasatrabajoconyuge = '';
LET vcasareferencia = '';
LET vcasareferencia2 = '';
LET cUnidadHabit = '';
LET vTipo_Dir = '';
LET vFecha_Hoy = DATE(1);
LET vNombre = '';
LET vEdad = 0;
LET vsSQL = "";
LET vCodRetorno = '000000';
LET dFechaAlta = DATE(1);
LET cValor = '';
LET iIngreso = 0;
LET iPuntuacion = 0;
LET cFecha_hoy = '1900/01/01';
LET dEvaluacion1 = 0;
LET dEvaluacion2 = 0;
LET iSecuencia = 0;
LET iElemento = 0;
LET vcodret = '';
--LET vfolio2 = '';
--LET dfechasolicitud = date(1);
--LET vtiendafolio2 = '';
LET vciudadbanco = 0;
LET vcoloniabanco = 0;

--Set debug file to '/tmp/sp_GeneraArchivoAltaCliente.out';
--trace on;
BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET vCodRetorno = iSqlErr;
			RETURN vCodRetorno;
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;

	IF pFechaAct <> mdy(1,1,1900) OR pFechaAct IS NOT NULL THEN
	
		SELECT fecha_hoy INTO vFecha_Hoy FROM bdinteg:"informix".si_fechas;
		
		IF vFecha_Hoy = mdy(1,1,1900) OR vFecha_Hoy IS NULL THEN
			LET vCodRetorno = '000002';
		ELSE
	  
			FOREACH
				SELECT DISTINCT sss.num_solicitud, sss.numcte, ssa.fecha_entrada, sss.sucursal
				INTO vnumerosolicituddecredito, vnumcte, vfechaaltacliente, cFolioSucursal
				FROM bdisolic:"informix".ss_autorizacion ssa, bdisolic:"informix".ss_solicitudes sss
				WHERE sss.num_solicitud = ssa.num_solicitud AND sss.num_producto = '6500' 
				AND ssa.fecha_entrada = pFechaAct AND ssa.status_solicitud = 'AP' AND sss.status_solicitud = ssa.status_solicitud
				
				IF vnumerosolicituddecredito <> '' OR vnumcte <> '' THEN 
					SELECT a.numcte, a.numcte_ref
					INTO vnumcte, vcliente_ref
					FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_adiccoppel b
					WHERE a.numcte = vnumcte AND a.empresa = pempresa AND b.empresa = pempresa AND a.numcte_ref = b.numctecoppel 
					AND a.numcte = b.numcte;
					
					IF NVL(vnumcte, '') <> '' THEN
						
						--Calcula Edad del Cliente
						EXECUTE PROCEDURE "informix".consedadcte (pempresa, vnumcte) INTO vCodRetorno, vNombre, vEdad;
						--OBTIENE LOS DATOS GENERALES DEL CLIENTE
						--Datos Clientes
						SELECT cte.nombre1, cte.nombre2, cte.apell_paterno, cte.apell_materno, cte.numcte, cte.ejecut_autoriza, cte.rfc, 
						cte.fecha_insert, cte.ejecut_autoriza, cte.numcte_ref, TRIM(NVL(cte.string2,0))::INTEGER
						INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vnumcte, vefectuo, vrfc, 
						vfechamovto, vefectuo, vcliente_ref, vpersonasvivenendomicilio
						FROM bdinteg:"informix".si_cliente cte
						WHERE cte.empresa = pempresa AND cte.numcte = vnumcte;
						
						IF NVL(vcliente_ref, '') = '' THEN
							LET vcliente_ref = '0';
						END IF;

						--Datos Generales Clientes
						SELECT iden.estado_civil, iden.curp, iden.numidentifi, iden.codidentifi, iden.habita_en, iden.sexo, iden.fecha_nac, iden.escolaridad
						INTO vestadocivil, vcurp, vclaveelector, vclaveidentificacion, vcasapropia, vsexo, vfechanacimiento, vescolaridad
						FROM bdinteg:"informix".si_ctepf iden
						WHERE iden.numcte = vnumcte;

						--Direccion Clientes
                        SELECT dir.numerociudad, dir.numerocolonia, dir.numerocalle, dir.numeroextcalle, dir.departamento, dir.puntocardinal, 
                        dir.observaciones, dir.entre_calles, dir.unidadhabitac, dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote, 
                        dir.edificio, dir.entrada, TRIM(NVL(tel1.telefono,0)), TRIM(NVL(tel2.telefono,0)), dir.tipo_dir 
                        INTO vciudadbanco, vcoloniabanco, vcalle, vcasa, vdeptointerior, vrumbo, vcomplemento, ventrecalles, cUnidadHabit, vuhcmanzana, vuhcotros,
                        vuhcandador, vuhcetapa, vuhclote, vuhcedificio, vuhcentrada, vtelefono, vtelefonocelular, vTipo_Dir
                        FROM bdinteg:"informix".si_direcciones_actual dir
                        LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
                        LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
                        WHERE dir.numcte = vnumcte AND dir.tipo_dir = '1';
						--- AND dir.secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones WHERE numcte = vnumcte AND tipo_dir = '1');
						
						IF NVL(vcomplemento, '') = '' THEN
							LET vcomplemento = 'E';
						END IF;
						
						--Convierte ciudad, colonia Bancoppel - Coppel
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
						INTO vciudad, vcolonia
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;

						--Trabajo Clientes
						SELECT ing.tipo_ingreso, ing.nombre_empresa, ing.puesto, ing.claveopcionpuesto --ing.ingreso_mensual
						INTO vtiposueldo , vlugartrabajo, vpuesto, vopcionpuesto --vingresomensual
						FROM bdinteg:"informix".si_ingresos ing
						WHERE ing.numcte = vnumcte
						AND ing.sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = vnumcte AND tipo_ingreso = 'T');					
						
						IF NVL(vpuesto, '') = '' THEN
							LET vpuesto = '0';
						END IF;
						
						--DEFINE EL TIPO DE UNIDAD HABITACIONAL
						IF cUnidadHabit = 'S' THEN
							LET vflaguhc = 1;
						ELSE
							LET vflaguhc= 0;
						END IF;
						SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
						-- DARLE FORMATO A LAS FECHAS 
						LET cfechanac = YEAR(vfechanacimiento)||"/"||LPAD(MONTH(vfechanacimiento),2,0)||"/"||LPAD(DAY(vfechanacimiento),2,0);
						LET cfechaaltacte = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH(vfechaaltacliente),2,0)||"/"||LPAD(DAY(vfechaaltacliente),2,0);
						IF pFechaAct <> vFecha_Hoy THEN
							LET cfechamovto = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0)||" "||vHora;
							LET cFecha_hoy = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0);
						ELSE
							LET cfechamovto = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0)||" "||vHora;
							LET cFecha_hoy = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0);
						END IF;
						
						--EVALUA EL TIPO DE SUELDO
						IF vtiposueldo = 'T' THEN
							LET vtiposueldo = '1';
						ELSE 
							LET vtiposueldo = '2';
						END IF;
						
						--DA FORMATO A NUMERO DE CASA DE CLIENTE
						EXECUTE PROCEDURE "informix".sp_ConvierteNumerodeCasa(vcasa) INTO vCodRetorno, snumerocasa, vletrasnumcasa; 
						
						IF snumerocasa = 0 THEN
							LET snumerocasa = 1;
						END IF;
						
						--EVALUA SI ES CREDITO JOVEN
						IF vsexo = 'M' THEN
							IF vEdad >= '16' AND vEdad <='20' THEN 
								LET vcreditojoven = 'J';
							END IF;
						ELSE
							IF  vsexo = 'F' THEN
								IF vEdad >='16' AND vEdad <='17' THEN 
									LET vcreditojoven = 'J';
								END IF;
							END IF;
						END IF;
						
						--OBTIENE LOS DATOS DE LA DIRECCION DEL TRABAJO
                        SELECT dir.numerociudad, dir.numerocolonia, dir.numerocalle, dir.numeroextcalle,dir.departamento, dir.puntocardinal,
                        dir.observaciones, dir.entre_calles,dir.unidadhabitac,dir.manzana, dir.otros,dir.andador, dir.etapa,dir.lote,
                        dir.edificio, dir.entrada, TRIM(NVL(tel3.telefono,0)), tel3.extension 
                        INTO vciudadbanco,vcoloniabanco,vcalletrabajo,vcasatrabajo,vdeptoointeriortrabajo, vrumbotrabajo,
                        vcomplementotrabajo,ventrecallestrabajo,cflaguht,vuhtmanzana, vuhtotros,vuhtandador,vuhtetapa,vuhtlote,vuhtedificio,
                        vuhtentrada,vtelefonotrabajo,vextensiontrabajo					
                        FROM bdinteg:"informix".si_cliente cte
                        INNER JOIN bdinteg:"informix".si_direcciones_actual dir ON ( cte.numcte = dir.numcte AND dir.tipo_dir = '2' )
                        LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel3 ON ( tel3.numcte = cte.numcte AND tel3.tipo_tel = 3 )
                        WHERE cte.numcte = vnumcte;
						--- AND	dir.secuencia = (SELECT NVL (MAX(secuencia),0)FROM bdinteg:"informix".si_direcciones WHERE numcte = vnumcte AND  tipo_dir = '2');
						
						IF NVL(vcomplementotrabajo, '') = '' THEN
							LET vcomplementotrabajo = 'E';
						END IF;
						
						--Convierte ciudad, colonia Bancoppel - Coppel
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
						INTO vciudadtrabajo, vcoloniatrabajo
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
						
						--OBTIENE EL TIPO DE UNIDAD HABITACIONAL DEL TRABAJO
						IF cflaguht = 'S' THEN
							LET vflaguht = 1;
						ELSE
							LET vflaguht = 0;
						END IF;
						
						--DA FORMATO A NUMERO DE TRABAJO
						EXECUTE PROCEDURE "informix".sp_ConvierteNumerodeCasa(vcasatrabajo) INTO vCodRetorno, snumerocasatrabajo, vletrasnumtrabajo; --NO
						
						--********************************************************************************************************************
						--OBTIENE LOS DATOS DE LAS REFERENCIAS CUANDO EL CLIENTE ES CASADO
						IF 	vestadocivil = 'C' THEN
							LET vclaveconyugefamilia = 'E';
							--OBTIENE LOS DATOS DEL CONYUGE CUANDO EL CLIENTE ES CASADO
							SELECT cte2.numcte_banco, cte2.nombre1, cte2.nombre2, cte2.apell_paterno, cte2.apell_materno, cte2.parentesco
							INTO vclienteconyuge,vnombreunoconyuge,vnombredosconyuge,vapellidopaternoconyuge,vapellidomaternoconyuge,vclaveconyugefamilia
							FROM bdinteg:"informix".si_refclientes cte2
							WHERE cte2.empresa = pempresa AND cte2.numcte = vnumcte 
							AND cte2.secuencia = (SELECT MAX(refc2.secuencia) FROM bdinteg:"informix".si_refclientes refc2 WHERE refc2.numcte = vnumcte 
								AND refc2.secuencia  <> (SELECT MAX(refc.secuencia) FROM bdinteg:"informix".si_refclientes refc WHERE refc.numcte = vnumcte));

							IF NVL(vclienteconyuge, '') = '' THEN
								LET vclienteconyuge = '0';
							END IF;
								
							SELECT dir2.numerociudad,dir2.numerocolonia,dir2.numerocalle,dir2.numeroextcalle,dir2.departamento,dir2.puntocardinal,
							dir2.observaciones,dir2.entre_calles,dir2.unidadhabitac,dir2.manzana,dir2.otros,dir2.andador,dir2.etapa,dir2.lote, 
							dir2.edificio,dir2.entrada,TRIM(NVL(dir2.telefono1,0)),TRIM(NVL(dir2.telefono2,0))
							INTO vciudadbanco,vcoloniabanco,vcalletrabajoconyuge,vcasatrabajoconyuge,vdeptoointeriorconyuge,vrumbotrabajoconyuge,
							vcomplementoconyuge,ventrecallesconyuge,cflaguht,vuhymanzana,vuhyotros,vuhyandador,vuhyetapa,vuhylote,vuhyedificio,
							vuhyentrada,vtelefonotrabajoconyuge,vtelefonocelularconyuge
							FROM bdinteg:"informix".si_refdirecciones dir2
							WHERE dir2.numcte = vnumcte AND dir2.secuencia = (SELECT MAX(ref1.secuencia) FROM bdinteg:"informix".si_refdirecciones ref1 WHERE ref1.numcte =  vnumcte 
								AND ref1.secuencia <> (SELECT MAX(ref2.secuencia) FROM bdinteg:"informix".si_refdirecciones ref2 WHERE ref2.numcte = vnumcte));
								
							IF NVL(vcomplementoconyuge, '') = '' THEN
								LET vcomplementoconyuge = 'E';
							END IF;
								
							--Convierte ciudad, colonia Bancoppel - Coppel
							SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
							INTO vciudadconyuge, vcoloniaconyuge
							FROM bdinteg:"informix".si_catzonas
							WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
								
							SELECT ing.nombre_empresa
							INTO vlugartrabajoconyuge
							FROM bdinteg:"informix".si_ingresos ing
							WHERE ing.numcte = vnumcte AND ing.sec_ingreso =(SELECT MAX(sec_ingreso)FROM bdinteg:"informix".si_ingresos WHERE numcte = vnumcte);
							
							--DEFINE TIPO DE UNIDAD HABITACIONAL
							IF cflaguht = 'S' THEN
								LET vflaguhy = 1;
							ELSE
								LET vflaguhy = 0;
							END IF;
							--DA FORMATO A NUMERO DE CASA DE CONYUGE
							EXECUTE PROCEDURE "informix".sp_ConvierteNumerodeCasa(vcasatrabajoconyuge) INTO vCodRetorno, snumerocasaconyugue, vletrasnumtrabconyuge;
							
							--OBTIENE LOS DATOS DE LA REFERENCIA 2 
							SELECT cte2.numcte_ref,cte2.nombre1,cte2.nombre2,cte2.apell_paterno,cte2.apell_materno,dir2.numerociudad,dir2.numerocolonia,
							dir2.numerocalle,dir2.numeroextcalle,dir2.departamento,dir2.puntocardinal,dir2.observaciones,dir2.entre_calles,dir2.unidadhabitac,
							dir2.manzana,dir2.otros,dir2.andador,dir2.etapa,dir2.lote,dir2.edificio,dir2.entrada,TRIM(NVL(dir2.telefono1, ''))::INT8,
							TRIM(NVL(dir2.telefono2,''))::INT8,cte2.parentesco
							INTO vclientereferencia2,vnombreunoreferencia2,vnombredosreferencia2,vapellidopaternoreferencia2,vapellidomaternoreferencia2,
							vciudadbanco,vcoloniabanco,vcallereferencia2,vcasareferencia2,vdeptoointeriorreferencia2,vrumboreferencia2,
							vcomplementoreferencia2,ventrecallesreferencia2,cflaguht,vuhrmanzana2,vuhrotros2,vuhrandador2,vuhretapa2,vuhrlote2,vuhredificio2,
							vuhrentrada2,vtelefonoreferencia2,vtelefonocelularreferencia2,vclavereferencia2
							FROM bdinteg:"informix".si_refclientes cte2, bdinteg:"informix".si_refdirecciones dir2
							WHERE cte2.numcte = vnumcte AND cte2.numcte = dir2.numcte AND cte2.numcte = cte2.numcte AND cte2.numcte = dir2.numcte	
							AND dir2.tipo_dir = '1' AND cte2.secuencia = (SELECT NVL(MAX(secuencia), 0) FROM bdinteg:"informix".si_refclientes WHERE numcte = vnumcte)
							AND dir2.secuencia = (SELECT NVL(MAX(secuencia), 0) FROM bdinteg:"informix".si_refdirecciones WHERE numcte = vnumcte );
							
							IF NVL(vcomplementoreferencia2, '') = '' THEN
								LET vcomplementoreferencia2 = 'E';
							END IF;
							
							--Convierte ciudad, colonia Bancoppel - Coppel
							SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
							INTO vciudadreferencia2, vcoloniareferencia2
							FROM bdinteg:"informix".si_catzonas
							WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
							
							IF NVL(vclientereferencia2, '') = '' THEN
								LET vclientereferencia2 = '0';
							END IF;
						
						--OBTIENE TIPO DE UNIDAD HABITACIONAL
							IF cflaguht = 'S' THEN
								LET vflaguhr2 = 1;
							ELSE
								LET vflaguhr2 = 0;
							END IF;
						--DA FORMATO A NUMERO DE CASA DE REFERENCIA 2 
							EXECUTE PROCEDURE "informix".sp_ConvierteNumerodeCasa(vcasareferencia2) INTO vCodRetorno, snumerocasaref2, vletrasnumcasaref2; 
						END IF;	
						
						--********************************************************************************************************************
						--OBTIENE LOS DATOS DE LAS REFERENCIAS CUANDO EL CLIENTE NO ES CASADO
						IF 	vestadocivil <> 'C' THEN
							--OBTIENE LOS DATOS DE LA REFERENCIA 1
							SELECT cte2.numcte,cte2.nombre1,cte2.nombre2,cte2.apell_paterno,cte2.apell_materno,dir2.numerociudad,dir2.numerocolonia,
							dir2.numerocalle,dir2.numeroextcalle,dir2.departamento,dir2.puntocardinal,dir2.observaciones,dir2.entre_calles,dir2.unidadhabitac,
							dir2.manzana,dir2.otros,dir2.andador,dir2.etapa,dir2.lote,dir2.edificio,dir2.entrada,TRIM(NVL(dir2.telefono1, ''))::INT8,
							TRIM(NVL(dir2.telefono2,''))::INT8,cte2.parentesco
							INTO vclientereferencia,vnombreunoreferencia,vnombredosreferencia,vapellidopaternoreferencia,vapellidomaternoreferencia,
							vciudadbanco,vcoloniabanco,vcallereferencia,vcasareferencia,vdeptoointeriorreferencia,vrumboreferencia,
							vcomplementoreferencia,ventrecallesreferencia1,cflaguht,vuhrmanzana,vuhrotros,vuhrandador,vuhretapa,vuhrlote,vuhredificio,
							vuhrentrada,vtelefonoreferencia,vtelefonocelularreferencia,vclavereferencia1
							FROM bdinteg:"informix".si_refclientes cte2, bdinteg:"informix".si_refdirecciones dir2                                                                                                                                      
							WHERE cte2.numcte = vnumcte AND cte2.numcte =  dir2.numcte AND dir2.tipo_dir = '1'     
							AND cte2.secuencia = (SELECT MAX(refc2.secuencia) FROM bdinteg:"informix".si_refclientes refc2 WHERE refc2.numcte = vnumcte 
								AND refc2.secuencia  <> (SELECT MAX(refc.secuencia) FROM bdinteg:"informix".si_refclientes refc WHERE refc.numcte = vnumcte))  
							AND dir2.secuencia = (SELECT MAX(ref1.secuencia) FROM bdinteg:"informix".si_refdirecciones ref1 WHERE ref1.numcte = vnumcte  
							AND ref1.secuencia <> (SELECT MAX(ref2.secuencia) FROM bdinteg:"informix".si_refdirecciones ref2 WHERE ref2.numcte = vnumcte));
							
							IF NVL(vcomplementoreferencia, '') = '' THEN
								LET vcomplementoreferencia = 'E';
							END IF;
							
							--Convierte ciudad, colonia Bancoppel - Coppel
							SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
							INTO vciudadreferencia, vcoloniareferencia
							FROM bdinteg:"informix".si_catzonas
							WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
							
							IF NVL(vclientereferencia, '') = '' THEN
								LET vclientereferencia = '0';
							END IF;
							
							--TIPO DE UNIDAD HABITACIONAL
							IF cflaguht = 'S' THEN
								LET vflaguhr = 1;
							ELSE
								LET vflaguhr = 0;
							END IF;
						
							--DA FORMATO A NUMERO DE CASA DE REFERENCIA 1
							EXECUTE PROCEDURE "informix".sp_ConvierteNumerodeCasa(vcasareferencia) INTO vCodRetorno, snumerocasaref, vletrasnumcasaref;
						
							--OBTIENE LOS DATOS DE REFERENCIA 2
							SELECT cte2.numcte,cte2.nombre1,cte2.nombre2,cte2.apell_paterno,cte2.apell_materno,dir2.numerociudad,dir2.numerocolonia,
							dir2.numerocalle,dir2.numeroextcalle,dir2.departamento,dir2.puntocardinal,dir2.observaciones,dir2.entre_calles,dir2.unidadhabitac,
							dir2.manzana,dir2.otros,dir2.andador,dir2.etapa,dir2.lote,dir2.edificio,dir2.entrada,TRIM(NVL(dir2.telefono1, ''))::INT8,
							TRIM(NVL(dir2.telefono2,''))::INT8,cte2.parentesco
							INTO vclientereferencia2,vnombreunoreferencia2,vnombredosreferencia2,vapellidopaternoreferencia2,vapellidomaternoreferencia2,
							vciudadbanco,vcoloniabanco,vcallereferencia2,vcasareferencia2,vdeptoointeriorreferencia2,vrumboreferencia2,
							vcomplementoreferencia2,ventrecallesreferencia2,cflaguht,vuhrmanzana2,vuhrotros2,vuhrandador2,vuhretapa2,vuhrlote2,vuhredificio2,
							vuhrentrada2,vtelefonoreferencia2,vtelefonocelularreferencia2,vclavereferencia2
							FROM bdinteg:"informix".si_refclientes cte2, bdinteg:"informix".si_refdirecciones dir2	
							WHERE cte2.numcte = vnumcte AND cte2.numcte = dir2.numcte AND dir2.tipo_dir = '1 '
							AND cte2.secuencia = (SELECT NVL ( MAX (secuencia),0)  FROM bdinteg:"informix".si_refclientes  WHERE numcte = vnumcte)
							AND dir2.secuencia = (SELECT NVL ( MAX(secuencia),0) FROM bdinteg:"informix".si_refdirecciones  WHERE numcte = vnumcte); 
							
							IF NVL(vcomplementoreferencia2, '') = '' THEN
								LET vcomplementoreferencia2 = 'E';
							END IF;
							
							--Convierte ciudad, colonia Bancoppel - Coppel
							SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel, numerocoloniacoppel 
							INTO vciudadreferencia2, vcoloniareferencia2
							FROM bdinteg:"informix".si_catzonas
							WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;

							IF NVL(vclientereferencia2, '') = '' THEN
								LET vclientereferencia2 = '0';
							END IF;
							
							IF cflaguht = 'S' THEN
								LET vflaguhr2 = 1;
							ELSE
								LET vflaguhr2 = 0;
							END IF;
						
							--DA FORMATO A NUMERO DE CASA DE REFERENCIA 2	
							EXECUTE PROCEDURE "informix".sp_ConvierteNumerodeCasa(vcasareferencia2) INTO vCodRetorno, snumerocasaref2, vletrasnumcasaref2;
						END IF;
						--********************************************************************************************************************
						
						SELECT elemento INTO vnumerodependientes FROM bdisolic:"informix".ss_detalle_scoring
						WHERE grupo = 11 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
						
						SELECT elemento INTO vpersonastrabajan FROM bdisolic:"informix".ss_detalle_scoring
						WHERE grupo = 37 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
						
						--TIEMPO DE RESIDENCIA 
						SELECT elemento
						INTO iElemento
						FROM bdisolic:"informix".ss_detalle_scoring 
						WHERE empresa = pempresa AND grupo = 6 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
						
						IF iElemento IS NULL THEN
							LET iElemento = 0;
						END IF;
						
						IF iElemento =  7 THEN
							LET iAniosHabita = 20;
						ELIF iElemento = 8 THEN
							LET iAniosHabita = 10;
						ELIF iElemento = 9 THEN
							LET iAniosHabita = 8;
						ELIF iElemento = 10 THEN
							LET iAniosHabita = 5;
						ELIF iElemento = 11 THEN
							LET iAniosHabita = 3;
						ELIF iElemento = 12 THEN
							LET iAniosHabita = 2;
						ELIF iElemento = 13 THEN
							LET iAniosHabita = 1;
						ELIF iElemento = 14 THEN
							LET iAniosHabita = 0;
						ELSE
							LET iAniosHabita = 0;
						END IF;
						
						IF iAniosHabita = 0 THEN
							LET cfechadesdecuandovive = "1990/01/01";
						ELSE
							LET cfechadesdecuandovive = YEAR(vfechaaltacliente) - iAniosHabita; 
							LET cfechadesdecuandovive = TRIM(cfechadesdecuandovive)||'/01/01';
						END IF;
						
						--TIEMPO LABORANDO
						SELECT  elemento
						INTO iElemento
						FROM bdisolic:"informix".ss_detalle_scoring 
						WHERE empresa = pempresa AND grupo = 8 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;
						
						IF iElemento IS NULL THEN
							LET iElemento = 0;
						END IF;

						IF iElemento =  24 THEN
							LET iAniosHabita = 10;
						ELIF iElemento =  23 THEN
							LET iAniosHabita = 9;
						ELIF iElemento =  22 THEN
							LET iAniosHabita = 8;
						ELIF iElemento =  21 THEN
							LET iAniosHabita = 7;
						ELIF iElemento =  20 THEN
							LET iAniosHabita = 6;
						ELIF iElemento =  19 THEN
							LET iAniosHabita = 5;
						ELIF iElemento =  18 THEN
							LET iAniosHabita = 4;
						ELIF iElemento =  17 THEN
							LET iAniosHabita = 3;
						ELIF iElemento =  16 THEN
							LET iAniosHabita = 2;
						ELIF iElemento =  15 THEN
							LET iAniosHabita = 1;
						ELIF iElemento =  14 THEN
							LET iAniosHabita = 0;
						ELSE
							LET iAniosHabita = 0;
						END IF;
						
						IF iAniosHabita = 0 THEN
							LET cfechaantiguedtrab = "1990/01/01";
						ELSE
							LET cfechaantiguedtrab = YEAR(vfechaaltacliente) - iAniosHabita;
							LET cfechaantiguedtrab = TRIM(cfechaantiguedtrab)||'/01/01';
						END IF;

						--OBTENER ESCOLARIDAD
						EXECUTE PROCEDURE "informix".sp_ObtieneEscolaridad (vnumcte, '') INTO vcodret,vescolaridad; 
						
						--FOLIO
						SELECT secuencia INTO vfolio FROM bdisolic:"informix".ss_osclientesupervisar WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito AND fechasolicitud = fechasolicitud;
						IF NVL(vfolio, '') = '' THEN
							LET vfolio = '0';
						END IF;
						
						--INGRESO MENSUAL
						SELECT ingreso_mensual INTO iIngreso FROM bdisolic:"informix".ss_resum_scor_fin WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito;
						SELECT valor INTO cValor FROM bdisolic:"informix".ss_param WHERE secuencia = 303;
						LET vingresomensual = ROUND(NVL(iIngreso,0)/cValor)::INTEGER;
					
						--MONTO OTORGADO				
						IF  vingresomensual < 2  OR vingresomensual = 2 THEN
							SELECT creditoautorizado INTO vlimitecredito FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 0 AND limitesuperior = 2;
						ELIF vingresomensual = 3 OR vingresomensual > 3 AND vingresomensual < 4 OR vingresomensual = 4 THEN
							SELECT creditoautorizado INTO vlimitecredito FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 3 AND limitesuperior = 4;
						ELIF vingresomensual = 5  OR vingresomensual > 5 AND vingresomensual < 6 OR vingresomensual = 6  THEN
							SELECT creditoautorizado INTO vlimitecredito FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 5 AND limitesuperior = 6;
						ELIF vingresomensual = 7  OR vingresomensual > 7 AND vingresomensual < 8 OR vingresomensual = 8 THEN
							SELECT creditoautorizado INTO vlimitecredito FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 7 AND limitesuperior = 8;
						ELIF vingresomensual = 9 OR vingresomensual > 9 THEN
							SELECT creditoautorizado INTO vlimitecredito FROM bdisolic:"informix".ss_catsmcoppel WHERE limiteinferior = 9;
						END IF;

						--VALIDA EL TIPO DE PRODUCTO QUE TIENE EL CLIENTE
						IF EXISTS(SELECT * FROM bdisolic:"informix".ss_solicitudes WHERE numcte = vnumcte AND num_producto ='6001') THEN
							LET vTipoProducto = '11000';
						END IF;
						
						--TOTAL DE PUNTOS SCORING/BURO
						SELECT EVALUACION INTO dEvaluacion1 FROM bdisolic:"informix".ss_resumen_scoring WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito AND seccion = 1;
						SELECT EVALUACION INTO dEvaluacion2 FROM bdisolic:"informix".ss_resumen_scoring WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito AND seccion = 2;
						
						LET iPuntuacion = (dEvaluacion1+dEvaluacion2);
						
						--SECUENCIA DE ARCHIVO
						IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
							IF EXISTS (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
								LET iSecuencia = (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
							ELSE
								LET iSecuencia = (SELECT NVL(MAX(secuencia), 0) + 1 FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
							END IF;
						ELSE
							IF EXISTS (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
								LET iSecuencia = (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = pempresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
							ELSE
								LET iSecuencia = 1;
							END IF;
						END IF;
						
						LET vsSQL = TRIM(vclave)||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(NVL(vcliente_ref, '0'))||"|"||TRIM(NVL(vnombre1, ''))||"|"||TRIM(NVL(vnombre2, ''))||"|"||TRIM(NVL(vapell_paterno, ''))||"|"||TRIM(NVL(vapell_materno, ''))||"|"
								||TRIM(NVL(vcurp, ''))||"|"||TRIM(NVL(vclaveelector, ''))||"|"||TRIM(NVL(vclaveidentificacion, ''))||"|"||TRIM(videntificacion)||"|"||NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||NVL(vcalle, 0)||"|"||NVL(snumerocasa, 0)||"|"||TRIM(NVL(vdeptointerior, ''))||"|"
								||TRIM(NVL(vrumbo, ''));
						LET vsSQL = vsSQL ||"|"||TRIM(NVL(vcomplemento, ' '))||"|"||TRIM(NVL(ventrecalles, ''))||"|"||NVL(vflaguhc, 0)||"|"||NVL(vuhcmanzana, 0)||"|"||NVL(vuhcotros, 0)||"|"||NVL(vuhcandador, 0)||"|"||NVL(vuhcetapa, 0)||"|"||NVL(vuhclote, 0)||"|"
								||NVL(vuhcedificio, 0)||"|"||NVL(vuhcentrada, 0)||"|"||NVL(vtelefono, 0)||"|"||NVL(vtelefonocelular, 0)||"|"||TRIM(NVL(vcasapropia, ''))||"|"||TRIM(vniptitular)||"|"||TRIM(vnipadicional)||"|"||TRIM(NVL(vsexo, ''))||"|" 
								||TRIM(NVL(vestadocivil, ''))||"|"||TRIM(NVL(cfechanac, '1900/01/01'))||"|"||TRIM(NVL(cfechadesdecuandovive, '1900/01/01'))||"|"||NVL(vpersonasvivenendomicilio, 0)||"|"||TRIM(NVL(vescolaridad, ''))||"|"||TRIM(NVL(vtiposueldo, ''));
						LET vsSQL = vsSQL ||"|"||NVL(vnumerodependientes, 0)||"|"||NVL(vpersonastrabajan, 0)||"|"||NVL(vlimitecredito, 0)||"|"||NVL(vingresomensual, 0)||"|"||TRIM(NVL(vsituacionespecial, ''))||"|"||NVL(vcausasituacionespecial, 0)||"|"
								||TRIM(vclaveautrechaza)||"|"||TRIM(vaceptadosupervisadorechazado)||"|"||TRIM(vclientenuevo)||"|"||TRIM(NVL(vcreditojoven, ''))||"|"||TRIM(NVL(vlugartrabajo, ''))||"|"||NVL(vciudadtrabajo, 0)||"|" 
								||NVL(vcoloniatrabajo, 0)||"|"||NVL(vcalletrabajo, 0)||"|"||NVL(snumerocasatrabajo, 0)||"|"||TRIM(NVL(vdeptoointeriortrabajo, ''))||"|"||TRIM(NVL(vrumbotrabajo, ''))||"|"||TRIM(NVL(vcomplementotrabajo, ''))||"|"||TRIM(NVL(ventrecallestrabajo, ''));
						LET vsSQL = vsSQL ||"|"||NVL(vflaguht, 0)||"|"||NVL(vuhtmanzana, 0)||"|"||NVL(vuhtotros, 0)||"|"||NVL(vuhtandador, 0)||"|"||NVL(vuhtetapa, 0)||"|"||NVL(vuhtlote, 0)||"|"||NVL(vuhtedificio, 0)||"|"||NVL(vuhtentrada, 0)||"|"||NVL(vtelefonotrabajo, 0)||"|" 
								||NVL(vextensiontrabajo, 0)||"|"||TRIM(vpuesto)||"|"||NVL(vopcionpuesto, 0)||"|"||TRIM(NVL(cfechaantiguedtrab, '1900/01/01'))||"|"||TRIM(vclienteconyuge)||"|"||TRIM(NVL(vnombreunoconyuge, ''))||"|"||TRIM(NVL(vnombredosconyuge, ''))||"|"
								||TRIM(NVL(vapellidopaternoconyuge, ''))||"|"||TRIM(NVL(vapellidomaternoconyuge, ''))||"|"||TRIM(NVL(vlugartrabajoconyuge, ''))||"|"||NVL(vciudadconyuge, 0)||"|"||NVL(vcoloniaconyuge, 0)||"|"||NVL(vcalletrabajoconyuge, 0)||"|" 
								||NVL(snumerocasaconyugue, 0)||"|"||TRIM(NVL(vdeptoointeriorconyuge, ''))||"|"||TRIM(NVL(vrumbotrabajoconyuge, ''))||"|"||TRIM(NVL(vcomplementoconyuge, ''))||"|"
								||TRIM(NVL(ventrecallesconyuge,''));
						LET vsSQL = vsSQL||"|"||NVL(vflaguhy, 0)||"|"||NVL(vuhymanzana, 0)||"|"||NVL(vuhyotros, 0)||"|"||NVL(vuhyandador, 0)||"|"||NVL(vuhyetapa, 0)||"|"||NVL(vuhylote, 0)||"|"||NVL(vuhyedificio, 0)||"|"||NVL(vuhyentrada, 0)||"|"||NVL(vtelefonotrabajoconyuge, 0)||"|" 
								||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclaveconyugefamilia, ''))||"|"||TRIM(vclientereferencia)||"|"||TRIM(NVL(vnombreunoreferencia, ''))||"|"||TRIM(NVL(vnombredosreferencia, ''))||"|"   
								||TRIM(NVL(vapellidopaternoreferencia, ''))||"|"||TRIM(NVL(vapellidomaternoreferencia, ''))||"|"||NVL(vciudadreferencia, 0)||"|"||NVL(vcoloniareferencia, 0)||"|"||NVL(vcallereferencia, 0)||"|" 
								||NVL(snumerocasaref, 0)||"|"||TRIM(NVL(vdeptoointeriorreferencia, ''))||"|"||TRIM(NVL(vrumboreferencia,''))||"|"||TRIM(NVL(vcomplementoreferencia,''))||"|"||TRIM(NVL(ventrecallesreferencia1,''))||"|"||NVL(vflaguhr, 0)||"|" 
								||NVL(vuhrmanzana, 0)||"|"||NVL(vuhrotros, 0)||"|"||NVL(vuhrandador, 0)||"|"||NVL(vuhretapa, 0)||"|"||NVL(vuhrlote, 0)||"|"||NVL(vuhredificio, 0)||"|"||NVL(vuhrentrada, 0)||"|"||NVL(vtelefonoreferencia, 0)||"|"||NVL(vtelefonocelularreferencia, 0);				  
						LET vsSQL = vsSQL||"|"||TRIM(NVL(vclavereferencia1, ''))||"|"||TRIM(vclientereferencia2)||"|"||TRIM(NVL(vnombreunoreferencia2, ''))||"|"||TRIM(NVL(vnombredosreferencia2, ''))||"|"||TRIM(NVL(vapellidopaternoreferencia2, ''))||"|"||TRIM(NVL(vapellidomaternoreferencia2, ''))||"|" 
								||NVL(vciudadreferencia2, 0)||"|"||NVL(vcoloniareferencia2, 0)||"|"||NVL(vcallereferencia2, 0)||"|"||NVL(snumerocasaref2, 0)||"|"||TRIM(NVL(vdeptoointeriorreferencia2, ''))||"|"||TRIM(NVL(vrumboreferencia2, ''))||"|" 
								||TRIM(NVL(vcomplementoreferencia2, ''))||"|"||TRIM(NVL(ventrecallesreferencia2, ''))||"|"||NVL(vflaguhr2, 0)||"|"||NVL(vuhrmanzana2, 0)||"|"||NVL(vuhrotros2, 0)||"|"||NVL(vuhrandador2, 0)||"|"||NVL(vuhretapa2, 0)||"|"||NVL(vuhrlote2, 0)||"|" 
								||NVL(vuhredificio2, 0)||"|"||NVL(vuhrentrada2, 0)||"|"||NVL(vtelefonoreferencia2, 0)||"|"||NVL(vtelefonocelularreferencia2, 0)||"|"||TRIM(NVL(vclavereferencia2, ''))||"|"||vreferencia2||"|"||vreferencia3||"|"||TRIM(vmarcadatosin)||"|" 
								||vtiporeposicion||"|"||vreposicion||"|"||TRIM(vflagentregotarjeta)||"|"||NVL(vefectuo, 0)||"|"||TRIM(NVL(cFolioSucursal, '0'))||"|"||TRIM(vfolio)||"|"||TRIM(NVL(cfechaaltacte, '1900/01/01'))||"|"   
								||TRIM(vflagnoreconocehuella)||"|"||vfoliotienda||"|"||TRIM(NVL(vrfc, ''))||"|"||TRIM(vcveburo)||"|"||TRIM(vfolioaut)||"|"||TRIM(vfolioconsulta)||"|"||TRIM(vfolioconcir)||"|"||vnegocio||"|"||vsubnegocio||"|"   
								||vempleadoautorizo||"|"||TRIM(vtipo)||"|"||TRIM(NVL(cfechamovto, '1900/01/01'))||"|"||TRIM(NVL(vnumerosolicituddecredito, ''))||"|"||TRIM(NVL(vnumcte, ''))||"|"||vtiendafolioanterior||"|"||vfolioanterior||"|" 
								||vclaveproducto||"|"||vflagactualizacion||"|"||vSistsegsocial||"|"||vTiposueldoext||"|"||vNumempleados||"|"||vSubopcionpuesto||"|"||vPuestoext||"|"||vOpcionpuestoext||"|"
								||vNumempleadosext||"|"||vSubopcionpuestoext||"|"||TRIM(vTipoOrigen)||"|"||TRIM(vTipoProducto)||"|"||TRIM(NVL(cFolioSucursal, '0'))||"|"||TRIM(NVL(cFecha_hoy, '1900/01/01'))||"|"||NVL(iPuntuacion,0)||"|"||NVL(iSecuencia,0);
						LET vsSQL = NVL(vsSQL, '');

						INSERT  INTO  bdinteg:"informix".si_archivoscoppeldiario (empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
						VALUES (pempresa, iSecuencia, cFolioSucursal, vsSQL, vClave, pFechaAct); 
					ELSE
						LET vCodRetorno = '000004';
					END IF; 
				ELSE
					LET vCodRetorno = '000003';
				END IF;
			END FOREACH;
		END IF;
	ELSE
		LET vCodRetorno = '000001';
	END IF;
	
	IF EXISTS (SELECT empresa, secuencia, sucursal, trama, tipomovto, fecha_insert FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = pempresa AND tipomovto = 'A' AND fecha_insert = pFechaAct) THEN
		LET vCodRetorno = '000000';
	ELSE
		LET vCodRetorno = '000005';
	END IF;
	RETURN vCodRetorno WITH RESUME;
END;
--*************************************************************************
--| Procedimiento   : "informix".sp_GeneraArchivoAltaCliente
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Noviembre de 2008
--| Descripción     : Realiza la extracción de datos del alta de cliente.
--*************************************************************************
--| Modificado por  : Adrian Lara
--| Fecha Modifica  : Junio de 2011
--| Descripción     : Se generan archivos, se agreagan nuevas consultas y correcciones en la trama de datos.
--*************************************************************************
--| Modificado por  : Adrian Lara
--| Ultima Modif.   : Sptiembre de 2011
--| Descripción     : Se modifica para que el campo complemento se agregue el valor E.
--*************************************************************************
--| Modificado por  : Adrian Lara
--| Ultima Modif.   : Octubre de 2011
--| Descripción     : Se modifica el tipo de consulta para las altas de clientes con solicitudes AP.
--*************************************************************************
END PROCEDURE;