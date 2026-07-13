CREATE PROCEDURE "informix".sp_generaarchivoadicionalesr(p_Empresa CHAR(3), pFechaAct DATE)
RETURNING
     CHAR(6);
	 
--DEFINICION DE VARIABLES
--CLIENTE
DEFINE vClave CHAR(1); --DEFAULT 'R'
DEFINE vcaja SMALLINT;DEFINE varea CHAR(1); --DEFAULT 'N'
DEFINE vcliente_ref CHAR(20); --#TITULAR CHECAR QUE SEA EL NUMERO DEL TITULAR
DEFINE vnombre1 CHAR(26);
DEFINE vnombre2 CHAR(26);
DEFINE vapell_paterno CHAR(26);
DEFINE vapell_materno CHAR(26);
DEFINE vcurp CHAR(18);DEFINE vclaveelector CHAR(18); --DEFAULT BLANCO
DEFINE vclaveidentificacion CHAR(2); --DEFAULT BLANCO
DEFINE videntificacion CHAR(8); --DEFAULT BLANCO
DEFINE vciudad SMALLINT; --DEFAULT 0
DEFINE vcolonia INTEGER; --DEFAULT 0
DEFINE vcalle INTEGER; --DEFAULT 0
DEFINE snumerocasa INTEGER; --DEFAULT 0
DEFINE vdeptointerior CHAR(4); --DEFAULT BLANCO
DEFINE vrumbo CHAR(1); --DEFAULT BLANCO
DEFINE vcomplemento CHAR(80); --DEFAULT BLANCO
DEFINE ventrecalles CHAR(40); --DEFAULT BLANCO
DEFINE vflaguhc SMALLINT; --DEFAULT 0
DEFINE vuhcmanzana SMALLINT; --DEFAULT 0
DEFINE vuhcotros SMALLINT; --DEFAULT 0
DEFINE vuhcandador SMALLINT; --DEFAULT 0
DEFINE vuhcetapa SMALLINT; --DEFAULT 0
DEFINE vuhclote  SMALLINT; --DEFAULT 0
DEFINE vuhcedificio SMALLINT; --DEFAULT 0
DEFINE vuhcentrada SMALLINT; --DEFAULT 0
DEFINE vtelefono INT8; --DEFAULT 0
DEFINE vtelefonocelular INT8; --DEFAULT 0
DEFINE vcasapropia CHAR(1);DEFINE vniptitular CHAR(7); --DEFAULT BLANCO
DEFINE vnipadicional CHAR(7); --DEFAULT BLANCO
DEFINE vsexo CHAR(1); --DEFAULT BLANCO
DEFINE vestadocivil CHAR(1); --DEFAULT BLANCO
DEFINE cfechanac CHAR(10);
DEFINE cfechadesdecuandovive CHAR(10);
DEFINE vpersonasvivenendomicilio INTEGER; --DEFAULT 0
DEFINE vescolaridad CHAR(1); --DEFAULT BLANCO
DEFINE vtiposueldo CHAR(1); --DEFAULT BLANCO
DEFINE vnumerodependientes SMALLINT; --DEFAULT 0
DEFINE vpersonastrabajan SMALLINT;DEFINE vlimitecredito SMALLINT; --DEFAULT 0
DEFINE vingresomensual SMALLINT; --DEFAULT 0
DEFINE vsituacionespecial CHAR(1); --DEFAULT BLANCO
DEFINE vcausasituacionespecial SMALLINT; --DEFAULT 0
DEFINE vclaveautrechaza CHAR(1); --DEFAULT BLANCO
DEFINE vaceptadosupervisadorechazado CHAR(1); --DEFAULT BLANCO
DEFINE vclientenuevo CHAR(1); --DEFAULT BLANCO
DEFINE vcreditojoven CHAR(1); --DEFAULT BLANCO
DEFINE vlugartrabajo CHAR(20); --DEFAULT BLANCO
DEFINE vciudadtrabajo SMALLINT; --DEFAULT 0
DEFINE vcoloniatrabajo  SMALLINT; --DEFAULT 0
DEFINE vcalletrabajo INTEGER; --DEFAULT 0
DEFINE snumerocasatrabajo INTEGER; --DEFAULT 0
DEFINE vdeptoointeriortrabajo CHAR(4); --DEFAULT BLANCO
DEFINE vrumbotrabajo CHAR(1); --DEFAULT BLANCO
DEFINE vcomplementotrabajo CHAR(80); --DEFAULT BLANCO
DEFINE ventrecallestrabajo CHAR(40); --DEFAULT BLANCO
DEFINE vflaguht SMALLINT; --DEFAULT 0
DEFINE vuhtmanzana SMALLINT; --DEFAULT 0
DEFINE vuhtotros SMALLINT; --DEFAULT 0
DEFINE vuhtandador SMALLINT; --DEFAULT 0
DEFINE vuhtetapa SMALLINT; --DEFAULT 0
DEFINE vuhtlote SMALLINT; --DEFAULT 0
DEFINE vuhtedificio SMALLINT; --DEFAULT 0
DEFINE vuhtentrada SMALLINT; --DEFAULT 0
DEFINE vtelefonotrabajo INT8; --DEFAULT 0
DEFINE vextensiontrabajo INTEGER; --DEFAULT 0
DEFINE vpuesto CHAR(1); --DEFAULT BLANCO
DEFINE vopcionpuesto SMALLINT; --DEFAULT 0
DEFINE cfechaantiguedtrab CHAR(10);
--CONYUGE
DEFINE vclienteconyuge CHAR(20); --DEFAULT 0
DEFINE vnombreunoconyuge CHAR(26); --DEFAULT BLANCO
DEFINE vnombredosconyuge CHAR(26); --DEFAULT BLANCO
DEFINE vapellidopaternoconyuge CHAR(26); --DEFAULT BLANCO
DEFINE vapellidomaternoconyuge CHAR(26); --DEFAULT BLANCO
DEFINE vlugartrabajoconyuge CHAR(20); --DEFAULT BLANCO
DEFINE vciudadconyuge SMALLINT; --DEFAULT 0
DEFINE vcoloniaconyuge INTEGER; --DEFAULT 0
DEFINE vcalletrabajoconyuge INTEGER; --DEFAULT 0
DEFINE snumerocasaconyugue INTEGER; --DEFAULT 0
DEFINE vdeptoointeriorconyuge CHAR(4); --DEFAULT BLANCO
DEFINE vrumbotrabajoconyuge CHAR(1); --DEFAULT BLANCO
DEFINE vcomplementoconyuge CHAR(80); --DEFAULT BLANCO
DEFINE ventrecallesconyuge CHAR(40); --DEFAULT BLANCO
DEFINE vflaguhy SMALLINT; --DEFAULT 0
DEFINE vuhymanzana SMALLINT; --DEFAULT 0
DEFINE vuhyotros SMALLINT; --DEFAULT 0
DEFINE vuhyandador  SMALLINT; --DEFAULT 0
DEFINE vuhyetapa SMALLINT; --DEFAULT 0 
DEFINE vuhylote SMALLINT; --DEFAULT 0
DEFINE vuhyedificio SMALLINT; --DEFAULT 0
DEFINE vuhyentrada SMALLINT; --DEFAULT 0
DEFINE vtelefonotrabajoconyuge INT8; --DEFAULT 0
DEFINE vtelefonocelularconyuge INT8; --DEFAULT 0
DEFINE vclaveconyugefamilia CHAR (1);DEFINE vclientereferencia CHAR(20); --DEFAULT 0
DEFINE vnombreunoreferencia CHAR(26); --DEFAULT BLANCO
DEFINE vnombredosreferencia CHAR(26); --DEFAULT BLANCO
DEFINE vapellidopaternoreferencia CHAR(26); --DEFAULT BLANCO
DEFINE vapellidomaternoreferencia CHAR(26); --DEFAULT BLANCO
DEFINE vciudadreferencia SMALLINT; --DEFAULT 0
DEFINE vcoloniareferencia INTEGER; --DEFAULT 0
DEFINE vcallereferencia INTEGER; --DEFAULT 0
DEFINE snumerocasaref INTEGER; --DEFAULT 0
DEFINE vdeptoointeriorreferencia CHAR(4); --DEFAULT BLANCO
DEFINE vrumboreferencia CHAR(1); --DEFAULT BLANCO
DEFINE vcomplementoreferencia CHAR(80); --DEFAULT BLANCO
DEFINE ventrecallesreferencia1 CHAR(40); --DEFAULT BLANCO
DEFINE vflaguhr SMALLINT; --DEFAULT 0
DEFINE vuhrmanzana SMALLINT; --DEFAULT 0
DEFINE vuhrotros SMALLINT; --DEFAULT 0
DEFINE vuhrandador SMALLINT; --DEFAULT 0
DEFINE vuhretapa SMALLINT; --DEFAULT 0
DEFINE vuhrlote SMALLINT; --DEFAULT 0
DEFINE vuhredificio SMALLINT; --DEFAULT 0
DEFINE vuhrentrada SMALLINT; --DEFAULT 0
DEFINE vtelefonoreferencia INT8; --DEFAULT 0       
DEFINE vtelefonocelularreferencia INT8; --DEFAULT 0
DEFINE vclavereferencia1 CHAR(1); --DEFAULT BLANCO
--REFERENCIA 2
DEFINE vclientereferencia2 CHAR(20); --DEFAULT 0
DEFINE vnombreunoreferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE vnombredosreferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE vapellidopaternoreferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE vapellidomaternoreferencia2 CHAR(26); --DEFAULT BLANCO
DEFINE vciudadreferencia2 SMALLINT; --DEFAULT 0
DEFINE vcoloniareferencia2 INTEGER; --DEFAULT 0
DEFINE vcallereferencia2 INTEGER; --DEFAULT 0
DEFINE snumerocasaref2 INTEGER; --DEFAULT 0
DEFINE vdeptoointeriorreferencia2 CHAR(4); --DEFAULT BLANCO
DEFINE vrumboreferencia2 CHAR(1); --DEFAULT BLANCO
DEFINE vcomplementoreferencia2 CHAR(80); --DEFAULT BLANCO
DEFINE ventrecallesreferencia2 CHAR(40); --DEFAULT BLANCO
DEFINE vflaguhr2 SMALLINT; --DEFAULT 0
DEFINE vuhrmanzana2 SMALLINT; --DEFAULT 0
DEFINE vuhrotros2 SMALLINT; --DEFAULT 0
DEFINE vuhrandador2 SMALLINT; --DEFAULT 0
DEFINE vuhretapa2 SMALLINT; --DEFAULT 0
DEFINE vuhrlote2 SMALLINT; --DEFAULT 0
DEFINE vuhredificio2 SMALLINT; --DEFAULT 0
DEFINE vuhrentrada2 SMALLINT; --DEFAULT 0
DEFINE vtelefonoreferencia2 INT8; --DEFAULT 0
DEFINE vtelefonocelularreferencia2 INT8; --DEFAULT 0
DEFINE vclavereferencia2 CHAR(1); --DEFAULT BLANCO
------
DEFINE vreferencia2 INTEGER; --DEFAULT 0
DEFINE vreferencia3 INTEGER; --DEFAULT 0
DEFINE vmarcadatosin CHAR(1); --DEFAULT BLANCO
DEFINE vtiporeposicion SMALLINT; --DEFAULT 2
DEFINE vreposicion INTEGER; 
DEFINE vflagentregotarjeta CHAR(1); --DEFAULT A
DEFINE vefectuo INTEGER;
DEFINE vtiendafolio SMALLINT;
DEFINE vfolio CHAR(20); --DEFAULT 0
DEFINE cfechaaltacte CHAR (10);
DEFINE vflagnoreconocehuella CHAR(1); --DEFAULT BLANCO
DEFINE vfoliotienda INTEGER; --DEFAULT 0
DEFINE vrfc CHAR(13); --DEFAULT BLANCO
DEFINE vcveburo CHAR(2); --DEFAULT BLANCO
DEFINE vfolioaut CHAR(4); --DEFAULT BLANCO
DEFINE vfolioconsulta CHAR(9); --DEFAULT BLANCO
DEFINE vfolioconcir CHAR(10); --DEFAULT BLANCO
DEFINE vnegocio SMALLINT; --DEFAULT 0
DEFINE vsubnegocio SMALLINT; --DEFAULT 0
DEFINE vempleadoautorizo INTEGER; --DEFAULT 0
DEFINE vtipo CHAR(1); --DEFAULT BLANCO
DEFINE cfechamovto CHAR (19); 
DEFINE vnumerosolicituddecredito CHAR(20); --DEFAULT 0
DEFINE vnumcte CHAR(20); --DEFAULT 0
DEFINE vtiendafolioanterior SMALLINT;DEFINE vfolioanterior INTEGER; --DEFAULT 0
DEFINE vclaveproducto SMALLINT; --DEFAULT 0
DEFINE vflagactualizacion INTEGER; --DEFAULT 0.
--------
DEFINE vSistsegsocial SMALLINT; --DEFAULT 0
DEFINE vTiposueldoext SMALLINT; --DEFAULT 0
DEFINE vNumempleados SMALLINT; --DEFAULT 0
DEFINE vSubopcionpuesto SMALLINT; --DEFAULT 0
DEFINE vPuestoext SMALLINT; --DEFAULT 0
DEFINE vOpcionpuestoext SMALLINT; --DEFAULT 0
DEFINE vNumempleadosext SMALLINT; --DEFAULT 0
DEFINE vSubopcionpuestoext SMALLINT; --DEFAULT 0
DEFINE vTipoOrigen CHAR(1); --DEFAULT BLANCO
DEFINE vTipoProducto CHAR(5); --DEFAULT BLANCO

--OTRAS VARIABLES
DEFINE cFolioSucursal CHAR(4);
DEFINE vHora DATETIME HOUR TO FRACTION(3);
--DEFINE vfechanacimiento DATE; 
--DEFINE iAniosHabita INTEGER;
DEFINE vfechaaltacliente DATE;
DEFINE vfechamovto DATE;
--DEFINE vcasa INTEGER;
--DEFINE vcasatrabajo INTEGER; --INT
--DEFINE vcasatrabajoconyuge CHAR(10);
--DEFINE vcasareferencia CHAR(10);
--DEFINE vcasareferencia2 CHAR(10);
--DEFINE cUnidadHabit CHAR(1);
--DEFINE vTipo_Dir CHAR(2);
DEFINE vFecha_Hoy DATE;
DEFINE vNombre CHAR(104);
--DEFINE vEdad INTEGER;
DEFINE vsSQL LVARCHAR (32000);
DEFINE iSqlErr INTEGER;
DEFINE vCodRetorno Char(6);
DEFINE dFechaAlta DATE;
--DEFINE cValor CHAR(20);
--DEFINE iIngreso INTEGER;
DEFINE iPuntuacion INTEGER;
DEFINE cFecha_hoy CHAR (10);
--DEFINE dEvaluacion1 DECIMAL(5,2);
--DEFINE dEvaluacion2 DECIMAL(5,2);
DEFINE iSecuencia INTEGER;
--DEFINE iElemento INTEGER;
--DEFINE vfolio2 CHAR(20);
--DEFINE dfechasolicitud DATE;
--DEFINE vtiendafolio2 CHAR(5);
--DEFINE dFechaResidencia date;
--DEFINE dFechaLaborando date;
DEFINE iSecAdic INTEGER;

-- INICIALIZACION DE VARIABLES
--CLIENTE
LET vClave = 'R'; --DEFAULT R
LET vcaja = 100;LET varea = 'N'; --DEFAULT N
LET vcliente_ref = '0'; --Cliente Coppel --INT
LET vnombre1 = '';
LET vnombre2 = '';
LET vapell_paterno = '';
LET vapell_materno = '';
LET vcurp = ''; --DEFAULT BLANCO
LET vclaveelector = ''; --DEFAULT BLANCO
LET vclaveidentificacion = ''; --DEFAULT BLANCO
LET videntificacion = ''; --DEFAULT BLANCO
LET vciudad = 0; --DEFAULT 0
LET vcolonia = 0; --DEFAULT 0
LET vcalle = 0; --DEFAULT 0
LET snumerocasa = 0; --DEFAULT 0
LET vdeptointerior = ''; --DEFAULT BLANCO
LET vrumbo = ''; --DEFAULT BLANCO
LET vcomplemento = ''; --DEFAULT BLANCO
LET ventrecalles = ''; --DEFAULT BLANCO
LET vflaguhc = 0; --DEFAULT 0
LET vuhcmanzana = 0; --DEFAULT 0
LET vuhcotros = 0; --DEFAULT 0
LET vuhcandador = 0; --DEFAULT 0
LET vuhcetapa = 0; --DEFAULT 0
LET vuhclote  = 0; --DEFAULT 0
LET vuhcedificio = 0; --DEFAULT 0
LET vuhcentrada = 0; --DEFAULT 0
LET vtelefono = 0; --DEFAULT 0
LET vtelefonocelular = 0; --DEFAULT 0
LET vcasapropia = ''; --DEFAULT BLANCO
LET vniptitular = ''; --DEFAULT BLANCO
LET vnipadicional = ''; --DEFAULT BLANCO
LET vsexo = ''; --DEFAULT BLANCO
LET vestadocivil = ''; --DEFAULT BLANCO
LET cfechanac = '1900/01/01';
LET cfechadesdecuandovive = '1900/01/01';
LET vpersonasvivenendomicilio = 0; --DEFAULT 0
LET vescolaridad = ''; --DEFAULT BLANCO
LET vtiposueldo = ''; --DEFAULT BLANCO
LET vnumerodependientes = 0; --DEFAULT 0
LET vpersonastrabajan = 0; --DEFAULT 0
LET vlimitecredito = 0; --DEFAULT 0 
LET vingresomensual = 0; --DEFAULT 0
LET vsituacionespecial = ''; --DEFAULT BLANCO
LET vcausasituacionespecial = 0; --DEFAULT 0
LET vclaveautrechaza = ''; --DEFAULT BLANCO
LET vaceptadosupervisadorechazado = ''; --DEFAULT BLANCO
LET vclientenuevo = ''; --DEFAULT BLANCO
LET vcreditojoven = ''; --DEFAULT BLANCO
LET vlugartrabajo = ''; --DEFAULT BLANCO
LET vciudadtrabajo = 0; --DEFAULT 0
LET vcoloniatrabajo  = 0; --DEFAULT 0
LET vcalletrabajo  = 0; --DEFAULT 0
LET snumerocasatrabajo = 0; --DEFAULT 0
LET vdeptoointeriortrabajo = ''; --DEFAULT BLANCO
LET vrumbotrabajo = ''; --DEFAULT BLANCO
LET vcomplementotrabajo = ''; --DEFAULT BLANCO
LET ventrecallestrabajo = ''; --DEFAULT BLANCO
LET vflaguht = 0; --DEFAULT 0
LET vuhtmanzana = 0; --DEFAULT 0
LET vuhtotros = 0; --DEFAULT 0
LET vuhtandador = 0; --DEFAULT 0
LET vuhtetapa = 0; --DEFAULT 0
LET vuhtlote = 0; --DEFAULT 0
LET vuhtedificio = 0; --DEFAULT 0
LET vuhtentrada = 0; --DEFAULT 0
LET vtelefonotrabajo = 0; --DEFAULT 0
LET vextensiontrabajo = 0; --DEFAULT 0
LET vpuesto = ''; --DEFAULT BLANCO
LET vopcionpuesto = 0; --DEFAULT 0
LET cfechaantiguedtrab = '1900/01/01'; 
--CONYUGE
LET vclienteconyuge = '0'; --DEFAULT 0
LET vnombreunoconyuge = ''; --DEFAULT BLANCO
LET vnombredosconyuge = ''; --DEFAULT BLANCO
LET vapellidopaternoconyuge = ''; --DEFAULT BLANCO
LET vapellidomaternoconyuge = ''; --DEFAULT BLANCO
LET vlugartrabajoconyuge = ''; --DEFAULT BLANCO
LET vciudadconyuge = 0; --DEFAULT 0
LET vcoloniaconyuge = 0; --DEFAULT 0
LET vcalletrabajoconyuge = 0; --DEFAULT 0
LET snumerocasaconyugue = 0; --DEFAULT 0
LET vdeptoointeriorconyuge = ''; --DEFAULT BLANCO
LET vrumbotrabajoconyuge = ''; --DEFAULT BLANCO
LET vcomplementoconyuge = ''; --DEFAULT BLANCO
LET ventrecallesconyuge = ''; --DEFAULT BLANCO
LET vflaguhy = 0; --DEFAULT 0
LET vuhymanzana = 0; --DEFAULT 0
LET vuhyotros = 0; --DEFAULT 0
LET vuhyandador  = 0; --DEFAULT 0
LET vuhyetapa = 0; --DEFAULT 0
LET vuhylote = 0; --DEFAULT 0
LET vuhyedificio = 0; --DEFAULT 0
LET vuhyentrada = 0; --DEFAULT 0
LET vtelefonotrabajoconyuge = 0; --DEFAULT 0
LET vtelefonocelularconyuge = 0; --DEFAULT 0
LET vclaveconyugefamilia = ''; --DEFAULT BLANCO
--REFERENCIA 1
LET vclientereferencia = '0'; --DEFAULT 0
LET vnombreunoreferencia = ''; --DEFAULT BLANCO
LET vnombredosreferencia = ''; --DEFAULT BLANCO
LET vapellidopaternoreferencia = ''; --DEFAULT BLANCO
LET vapellidomaternoreferencia = ''; --DEFAULT BLANCO
LET vciudadreferencia = 0; --DEFAULT 0
LET vcoloniareferencia = 0; --DEFAULT 0
LET vcallereferencia = 0; --DEFAULT 0
LET snumerocasaref = 0; --DEFAULT 0
LET vdeptoointeriorreferencia = ''; --DEFAULT BLANCO
LET vrumboreferencia = ''; --DEFAULT BLANCO
LET vcomplementoreferencia = ''; --DEFAULT BLANCO
LET ventrecallesreferencia1 = ''; --DEFAULT BLANCO
LET vflaguhr = 0; --DEFAULT 0
LET vuhrmanzana = 0 ; --DEFAULT 0
LET vuhrotros = 0 ; --DEFAULT 0
LET vuhrandador = 0; --DEFAULT 0
LET vuhretapa = 0; --DEFAULT 0
LET vuhrlote = 0; --DEFAULT 0
LET vuhredificio = 0; --DEFAULT 0
LET vuhrentrada = 0; --DEFAULT 0
LET vtelefonoreferencia = 0; --DEFAULT 0   
LET vtelefonocelularreferencia = 0; --DEFAULT 0
LET vclavereferencia1 = ''; --DEFAULT BLANCO
--REFERENCIA 2
LET vclientereferencia2 = '0'; --DEFAULT 0
LET vnombreunoreferencia2 = ''; --DEFAULT BLANCO
LET vnombredosreferencia2 = ''; --DEFAULT BLANCO
LET vapellidopaternoreferencia2 = ''; --DEFAULT BLANCO
LET vapellidomaternoreferencia2 = ''; --DEFAULT BLANCO
LET vciudadreferencia2 = 0; --DEFAULT 0 
LET vcoloniareferencia2 = 0; --DEFAULT 0
LET vcallereferencia2 = 0; --DEFAULT 0
LET snumerocasaref2 = 0; --DEFAULT 0
LET vdeptoointeriorreferencia2 = ''; --DEFAULT BLANCO
LET vrumboreferencia2 = ''; --DEFAULT BLANCO
LET vcomplementoreferencia2 = ''; --DEFAULT BLANCO
LET ventrecallesreferencia2 = ''; --DEFAULT BLANCO
LET vflaguhr2 = 0; --DEFAULT 0 
LET vuhrmanzana2 = 0; --DEFAULT 0
LET vuhrotros2 = 0; --DEFAULT 0
LET vuhrandador2 = 0; --DEFAULT 0
LET vuhretapa2 = 0; --DEFAULT 0
LET vuhrlote2 = 0; --DEFAULT 0
LET vuhredificio2 = 0; --DEFAULT 0
LET vuhrentrada2 = 0; --DEFAULT 0
LET vtelefonoreferencia2 = 0; --DEFAULT 0
LET vtelefonocelularreferencia2 = 0; --DEFAULT 0
LET vclavereferencia2 = ''; --DEFAULT BLANCO
------
LET vreferencia2 = 0; --DEFAULT 0
LET vreferencia3 = 0; --DEFAULT 0
LET vmarcadatosin = ''; --DEFAULT BLANCO
LET vtiporeposicion = 0; --DEFAULT 2
LET vreposicion = 0; --DEFAULT 0
LET vflagentregotarjeta = ''; --DEFAULT A
LET vefectuo = 0;
LET vtiendafolio = 0;
LET vfolio = '0'; --DEFAULT 0
LET cfechaaltacte = '1900/01/01';
LET vflagnoreconocehuella = ''; --DEFAULT BLANCO
LET vfoliotienda = 0; --DEFAULT 0
LET vrfc = ''; 
LET vcveburo = ''; --DEFAULT BLANCO
LET vfolioaut = ''; --DEFAULT BLANCO
LET vfolioconsulta = ''; --DEFAULT BLANCO
LET vfolioconcir = ''; --DEFAULT BLANCO
LET vnegocio = 0; --DEFAULT 0
LET vsubnegocio = 0; --DEFAULT 0
LET vempleadoautorizo = 0; --DEFAULT 0
LET vtipo = ''; --DEFAULT BLANCO
LET cfechamovto = '1900/01/01';
LET vnumerosolicituddecredito = '0'; --DEFAULT 0
LET vnumcte = '';
LET vtiendafolioanterior = 0; --DEFAULT 0
LET vfolioanterior = 0; --DEFAULT 0
LET vclaveproducto = 0; --6500
LET vflagactualizacion = 0; --DEFAULT 0
--------
LET vSistsegsocial = 0; --DEFAULT 0
LET vTiposueldoext = 0; --DEFAULT 0
LET vNumempleados = 0; --DEFAULT 0
LET vSubopcionpuesto = 0; --DEFAULT 0
LET vPuestoext = 0; --DEFAULT 0
LET vOpcionpuestoext = 0; --DEFAULT 0
LET vNumempleadosext = 0; --DEFAULT 0
LET vSubopcionpuestoext = 0; --DEFAULT 0
LET vTipoOrigen = ''; --DEFAULT BLANCO
LET vTipoProducto = ''; --DEFAULT BLANCO

--OTRAS VARIABLES
LET cFolioSucursal = '';
LET vHora = '';
--LET vfechanacimiento = DATE(1); 
--LET iAniosHabita = 0;
LET vfechaaltacliente = DATE(1);
LET vfechamovto = DATE(1);
--LET vcasa = 0;
--LET vcasatrabajo = 0; --INT
--LET vcasatrabajoconyuge = '';
--LET vcasareferencia = '';
--LET vcasareferencia2 = '';
--LET cUnidadHabit = '';
--LET vTipo_Dir = '';
LET vFecha_Hoy = DATE(1);
LET vNombre = '';
--LET vEdad = 0;
LET vsSQL = "";
LET vCodRetorno = '000000';
LET dFechaAlta = DATE(1);
--LET cValor = '';
--LET iIngreso = 0;
LET iPuntuacion = 0;
LET cFecha_hoy = '1900/01/01';
--LET dEvaluacion1 = 0;
--LET dEvaluacion2 = 0;
LET iSecuencia = 0;
--LET iElemento = 0;
--LET vfolio2 = '';
--LET dfechasolicitud = date(1);
--LET vtiendafolio2 = '';
LET iSecAdic = 0;

--Set debug file to '/tmp/sp_GeneraArchivoAdicionalesR.out';
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
			--GENERAR ARCHIVO ADICIONAL PARA CLAVE "R"
			FOREACH
				SELECT numctebanco, numctecoppel, numtarjeta, secuencia, fecha
				INTO vnumcte, vcliente_ref, vreposicion, iSecAdic, vfechaaltacliente
				FROM bditarjcop:"informix".detallerepadic
				WHERE secuencia > 0 AND tipocliente = 'A' AND fecha = pFechaAct
				
				IF vnumcte <> '' AND vcliente_ref <> '' THEN
				
					SELECT nombre1, nombre2, apell_paterno, apell_materno
					INTO vnombre1,vnombre2, vapell_paterno,vapell_materno
					FROM bdinteg:"informix".si_cliente
					WHERE numcte = vnumcte;
					
					IF iSecAdic > 1 THEN
						LET vtiporeposicion = 2;
					ELSE
						LET vtiporeposicion = 0;
					END IF;
					
					IF vtiporeposicion <> 2 THEN
						LET vreposicion = '';
						LET vflagentregotarjeta = '';
					ELSE
						LET vflagentregotarjeta = 'A';
					END IF;
					
					SELECT sucursal, user_insert
					INTO cFolioSucursal, vefectuo
					FROM bdinteg:"informix".si_adiccoppel
					WHERE numcte = vnumcte AND secuencia > 1;
						
					--DA FORMATO A FECHAS
					SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
					--LET cfechanac = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH(vfechaaltacliente),2,0)||"/"||LPAD(DAY(vfechaaltacliente),2,0);
					LET cfechaaltacte = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH(vfechaaltacliente),2,0)||"/"||LPAD(DAY(vfechaaltacliente),2,0);
					--LET cfechadesdecuandovive = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH(vfechaaltacliente),2,'0')||"/"||LPAD(DAY(vfechaaltacliente),2,'0');
					--LET cfechaantiguedtrab = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH(vfechaaltacliente),2,'0')||"/"||LPAD(DAY(vfechaaltacliente),2,'0');
					
					IF pFechaAct <> vFecha_Hoy THEN
						LET cfechamovto = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0);
					ELSE
						LET cfechamovto = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0)||" "||vHora;
						LET cFecha_hoy = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0);
					END IF;
					
					--SECUENCIA DE ARCHIVO
					IF EXISTS (SELECT 1 FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = p_Empresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
						IF EXISTS (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = p_Empresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
							LET iSecuencia = (SELECT  {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = p_Empresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
						ELSE
							LET iSecuencia = (SELECT NVL(MAX(secuencia), 0) + 1  FROM bdinteg:"informix".si_archivoscoppelhistorial WHERE empresa = p_Empresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
						END IF;
					ELSE
						IF EXISTS (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} 1 FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = p_Empresa AND tipomovto <> 'TO' OR tipomovto = 'TO') THEN
							LET iSecuencia = (SELECT {+INDEX(bdinteg:"informix".si_archivoscoppeldiario idxr_archcoptipmovto)} MAX(secuencia) + 1  FROM bdinteg:"informix".si_archivoscoppeldiario WHERE empresa = p_Empresa AND tipomovto <> 'TO' OR tipomovto = 'TO');
						ELSE
							LET iSecuencia = 1;
						END IF;
					END IF;
						
					LET vsSQL = vclave||"|"||vcaja||"|"||varea||"|"||vcliente_ref||"|"||TRIM(NVL(vnombre1, ''))||"|"||TRIM(NVL(vnombre2, ''))||"|"||TRIM(NVL(vapell_paterno, ''))||"|"||TRIM(NVL(vapell_materno, ''))||"|"
							||vcurp||"|"||vclaveelector||"|"||vclaveidentificacion||"|"||videntificacion||"|"||vciudad||"|"||vcolonia||"|"||vcalle||"|"||snumerocasa||"|"||vdeptointerior||"|"
							||vrumbo;
					LET vsSQL = vsSQL || "|" ||vcomplemento||"|"||ventrecalles||"|"||vflaguhc||"|"||vuhcmanzana||"|"||vuhcotros||"|"||vuhcandador||"|"||vuhcetapa||"|"||vuhclote||"|"
							||vuhcedificio||"|"||vuhcentrada||"|"||vtelefono||"|"||vtelefonocelular||"|"||vcasapropia||"|"||vniptitular||"|"||vnipadicional||"|"||vsexo||"|" 
							||vestadocivil||"|"||TRIM(NVL(cfechanac, '1900/01/01'))||"|"||TRIM(NVL(cfechadesdecuandovive, '1900/01/01'))||"|"||vpersonasvivenendomicilio||"|"||vescolaridad||"|"||vtiposueldo;
					LET vsSQL = vsSQL || "|"  ||vnumerodependientes||"|"||vpersonastrabajan||"|"||vlimitecredito||"|"||vingresomensual||"|"||vsituacionespecial||"|"||vcausasituacionespecial||"|"
							||vclaveautrechaza||"|" ||vaceptadosupervisadorechazado||"|"||vclientenuevo||"|"||vcreditojoven||"|"||vlugartrabajo||"|"||vciudadtrabajo||"|" 
							||vcoloniatrabajo||"|"||vcalletrabajo||"|"||snumerocasatrabajo||"|"||vdeptoointeriortrabajo||"|"||vrumbotrabajo||"|"||vcomplementotrabajo||"|"||ventrecallestrabajo;
					LET vsSQL = vsSQL || "|" ||vflaguht||"|"||vuhtmanzana||"|"||vuhtotros||"|"||vuhtandador||"|"||vuhtetapa||"|"||vuhtlote||"|"||vuhtedificio||"|"||vuhtentrada||"|"||vtelefonotrabajo||"|" 
							||vextensiontrabajo||"|"||vpuesto||"|"||vopcionpuesto||"|"||TRIM(NVL(cfechaantiguedtrab, '1900/01/01'))||"|"||vclienteconyuge||"|"||vnombreunoconyuge||"|"||vnombredosconyuge||"|"
							||vapellidopaternoconyuge||"|"||vapellidomaternoconyuge||"|"||vlugartrabajoconyuge||"|"||vciudadconyuge||"|"||vcoloniaconyuge||"|"||vcalletrabajoconyuge||"|" 
							||snumerocasaconyugue||"|"||vdeptoointeriorconyuge||"|"||vrumbotrabajoconyuge||"|"||vcomplementoconyuge||"|"
							||ventrecallesconyuge;
					LET vsSQL = vsSQL|| "|" ||vflaguhy||"|"||vuhymanzana||"|"||vuhyotros||"|"||vuhyandador||"|"||vuhyetapa||"|"||vuhylote||"|"||vuhyedificio||"|"||vuhyentrada||"|"||vtelefonotrabajoconyuge||"|" 
							||vtelefonocelularconyuge||"|"||vclaveconyugefamilia||"|"||vclientereferencia||"|"||vnombreunoreferencia||"|"||vnombredosreferencia||"|"   
							||vapellidopaternoreferencia||"|"||vapellidomaternoreferencia||"|"||vciudadreferencia||"|"||vcoloniareferencia||"|"||vcallereferencia||"|" 
							||snumerocasaref||"|"||vdeptoointeriorreferencia||"|"||vrumboreferencia||"|"||vcomplementoreferencia||"|"||ventrecallesreferencia1||"|"||vflaguhr||"|" 
							||vuhrmanzana||"|"||vuhrotros||"|"||vuhrandador||"|"||vuhretapa||"|"||vuhrlote||"|"||vuhredificio||"|"||vuhrentrada||"|"||vtelefonoreferencia||"|"||vtelefonocelularreferencia;				  
					LET vsSQL = vsSQL|| "|" ||vclavereferencia1||"|"||vclientereferencia2||"|"||vnombreunoreferencia2||"|"||vnombredosreferencia2||"|"||vapellidopaternoreferencia2||"|"||vapellidomaternoreferencia2||"|" 
							||vciudadreferencia2||"|"||vcoloniareferencia2||"|"||vcallereferencia2||"|"||snumerocasaref2||"|"||vdeptoointeriorreferencia2||"|"||vrumboreferencia2|| "|" 
							||vcomplementoreferencia2||"|"||ventrecallesreferencia2||"|"||vflaguhr2||"|"||vuhrmanzana2||"|"||vuhrotros2||"|"||vuhrandador2||"|"||vuhretapa2||"|"||vuhrlote2||"|" 
							||vuhredificio2||"|"||vuhrentrada2||"|"||vtelefonoreferencia2||"|"||vtelefonocelularreferencia2||"|"||vclavereferencia2||"|"||vreferencia2||"|"||vreferencia3||"|"||vmarcadatosin||"|" 
							||vtiporeposicion||"|"||NVL(vreposicion, 0)|| "|" ||vflagentregotarjeta|| "|" || NVL(vefectuo, 0)|| "|" || NVL(vtiendafolio, 0) || "|" ||vfolio||"|"||TRIM(NVL(cfechaaltacte, '1900/01/01'))|| "|"   
							||vflagnoreconocehuella|| "|"||vfoliotienda|| "|" ||vrfc||"|"||vcveburo|| "|" ||vfolioaut|| "|" ||vfolioconsulta|| "|" ||vfolioconcir|| "|" ||vnegocio|| "|" ||vsubnegocio|| "|"   
							||vempleadoautorizo|| "|" ||vtipo|| "|"||TRIM(NVL(cfechamovto, '1900/01/01'))||"|"||vnumerosolicituddecredito|| "|" || TRIM(NVL(vnumcte, ''))|| "|" ||vtiendafolioanterior|| "|" ||vfolioanterior|| "|" 
							||vclaveproducto|| "|" ||vflagactualizacion|| "|" ||vSistsegsocial||"|"||vTiposueldoext|| "|" ||vNumempleados|| "|" ||vSubopcionpuesto|| "|" ||vPuestoext||"|"||vOpcionpuestoext||"|"
							||vNumempleadosext||"|"||vSubopcionpuestoext||"|"||vTipoOrigen||"|"||vTipoProducto||"|"|| NVL(cFolioSucursal, 0)||"|"||TRIM(NVL(cFecha_hoy, '1900/01/01'))||"|"||NVL(iPuntuacion,0)||"|"||NVL(iSecuencia,0);
					LET vsSQL = NVL(vsSQL, '');
					
					INSERT INTO bdinteg:"informix".si_archivoscoppeldiario(empresa,secuencia, sucursal,trama,tipomovto,fecha_insert)
					VALUES (p_Empresa,iSecuencia, cFolioSucursal,vsSQL, vClave,pFechaAct);
			
				ELSE
					LET vCodRetorno = '000003';
				END IF;
			END FOREACH;
		END IF;
	ELSE
		RETURN '000001';
	END IF;
	
	RETURN vCodRetorno;

END;
--**********************************************************************
--| Procedimiento   : "informix".sp_GeneraArchivoAdicionalesR
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Noviembre de 2008
--| Descripción     : Realiza la extracción de datos de clientes con tarjeta adicional de reposicion
--**********************************************************************
--| Modificado por  : Adrian Lara
--| Fecha Modifica  : Junio de 2011
--| Descripción     : Se generan archivos, se agreagan nuevas consultas y correcciones en la trama de datos.
--***********************************************************************
--| Modificado por  : Adrian Lara
--| Fecha Modifica  : Octubre de 2011
--| Descripción     : Se modifica tipo de consulta para obtener los datos de las Asignaciones y Reposiciones del Adcional.
--***********************************************************************
END PROCEDURE;