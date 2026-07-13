CREATE PROCEDURE "informix".sp_generatdcporentregar(pFechaEntrada DATE)
	RETURNING
		CHAR(5)  	AS CodRetorno;

	--DECLARARACION DE VARIBLES
	DEFINE cSqlErr					INTEGER;
	DEFINE cCodRet 					CHAR(5);	
	DEFINE cEmpresa        			CHAR(3);
	DEFINE cNumCte 					CHAR(20);
	DEFINE cNumCredito 				CHAR(20);
	DEFINE cCiudad 					CHAR(20);
	DEFINE cEstado 					CHAR(20);
	DEFINE cCelular			 		CHAR(13);
	--DEFINE cNombre 					CHAR(110);---Se comenta para mostrar el nombre por separado
	DEFINE cNumeroTarjeta 			CHAR(20);
	DEFINE cNombre1 				CHAR(50);
	DEFINE cNombre2 				CHAR(50);
	DEFINE cApellidoP 				CHAR(50);
	DEFINE cApellidoM 				CHAR(50);
	--Declaracion variables SP sp_tipored
	DEFINE 	cCodRetTipRed 			CHAR(5);
	DEFINE 	cTipoRed         		CHAR(10);
	DEFINE	cNum_Carrier_Cat 		CHAR (3);
	DEFINE cNumProducto 			CHAR(4);	
	DEFINE sNumCampania     		SMALLINT;
	DEFINE dtFechaHoy				DATE;
  DEFINE  cExiste           		CHAR(1);
	DEFINE cSituacion               CHAR(1);
	DEFINE sCausa                   SMALLINT;
  DEFINE cProceso         CHAR(4);	
  DEFINE vvcCod_ret       CHAR(6);
  DEFINE cMensaje 		CHAR(150);
		
	--INICIALIZACION DE VARIABLES	
	LET cSqlErr 			= 0;
	LET cCodRet 			= "000";
  LET cEmpresa      = '001';	
	LET cNumCte   			= '';
	LET cNumCredito 		= '';
	LET cCiudad  			= '';
	LET cEstado 			= '';
	LET cCelular 			= '';
	--LET cNombre 				= '';---Se comenta para mostrar el nombre por separado
	LET cNumeroTarjeta 		= ''; 
	LET cNombre1 			= '';
	LET cNombre2 			= '';
	LET cApellidoP 			= ''; 
	LET cApellidoM 			= ''; 
	---Inicializacion Variables SP sp_tipored
	LET cTipoRed        	='';
	LET cNum_Carrier_Cat 	='';
	LET cCodRetTipRed       ='00000';
	LET cNumProducto        = '';
	LET sNumCampania        = 0;
	LET dtFechaHoy          = '';
	LET cSituacion          = '';
	LET sCausa              = 0;
	LET cProceso      = '0054';
	LET vvcCod_ret = '';
	LET cMensaje   = 'PROCESO EXITOSO';
	
	--SET DEBUG FILE TO "/home/sysifx/SPs PAYAN/"informix".sp_generatdcporentregar.out";
	--TRACE ON;
	BEGIN
		ON EXCEPTION SET cSqlErr
			IF cSqlerr <> 0 THEN
				Let cCodRet = cSqlErr;
				CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, cMensaje, '02') RETURNING vvcCod_ret;
        RETURN cCodRet; 
				
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
	  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, '', '01') RETURNING vvcCod_ret; 
		
		IF pFechaEntrada IS NULL THEN 
		
			LET cCodRet = '001'; --Parametros no validos 
			RETURN cCodRet;
			
		END IF;
		
		--obtengo la fecha de hoy.
		SELECT NVL(fecha_hoy,'')
		INTO dtFechaHoy
		FROM bdicred:"informix".sd_fechas
	  WHERE empresa = cEmpresa;
		
		--obtengo el numero de producto de la campaña 8
		SELECT num_campania,num_producto
		INTO sNumCampania,cNumProducto
		FROM bdicobranza:"informix".cb_cat_campania
		WHERE empresa = cEmpresa 
      AND num_campania = 8;
		
		FOREACH
			---obtengo a los clientes con tdc por entregar.
			SELECT NVL(a.numcte,''), a.num_solicitud
			INTO  cNumCte, cNumCredito
			FROM  bdisolic:"informix".ss_solicitudes a, bdisolic:"informix".ss_autorizacion b
			WHERE b.empresa = a.empresa
				AND b.num_solicitud = a.num_solicitud
				AND b.status_solicitud = 'AT'
				AND b.fecha_entrada > DATE((pFechaEntrada) -7 units DAY)
						
				--obtengo el credito, ciudad y estado del cliente			
				/* No se actualiza cb_ctes_mensajes 
				SELECT NVL(a.credito,''), NVL(a.ciudad,''),NVL(a.estado,''),NVL(a.situacion,''),NVL(a.causa,0)
				INTO cNumCredito,cCiudad,cEstado,cSituacion,sCausa					
				FROM bdicobranza:"informix".cb_ctes_mensajes a, bdicred:"informix".sd_maecredanexo b
				WHERE a.empresa = cEmpresa
					AND a.cliente = cNumCte
					AND a.credito = b.num_credito
				*/
          SELECT LIMIT 1 e.nombre, c.nombre INTO cEstado, cCiudad
            FROM bdinteg:si_direcciones_actual d, bdinteg:si_estados e, bdinteg:si_ciudades c
           WHERE d.numcte = cNumCte
             AND d.ciudad = c.ciudad
             AND d.estado = e.estado
             AND c.estado = e.estado
             AND d.tipo_dir = 1;				
										
					--valido si ya existe el credito en la tabla si es true pues que continue con el siguiente credito						
					IF EXISTS (SELECT credito FROM bdicobranza:"informix".cb_info_administrativa WHERE credito = cNumCredito) THEN
						LET cExiste = 1;
					ELSE
						LET cExiste = 0;
					END IF;

					--si existe que continue con el siguiente credito y no inserte ningun registro
					IF cExiste = 1 THEN	
						DELETE bdicobranza:"informix".cb_info_administrativa WHERE num_campania = 8 AND credito = cNumCredito;
						CONTINUE FOREACH;
					END IF;	
		
					---obtengo el nombre del cliente por separado
					SELECT NVL(TRIM(nombre1),''), NVL(TRIM(nombre2),''), NVL(TRIM(apell_paterno),''), 
						 NVL(TRIM(apell_materno),'')
					INTO cNombre1,cNombre2,cApellidoP,cApellidoM
					FROM bdinteg:"informix".si_cliente
					WHERE empresa = cEmpresa
						AND numcte = cNumCte;
				/*	
					--obtengo el celular del cliente.
					SELECT limit 1 NVL(a.telefono2,'')
					INTO cCelular
					FROM bdinteg:"informix".si_direcciones_actual a
					WHERE a.numcte = cNumCte
            AND a.tipo_dir = '1';*/
			
				--obtengo el celular del cliente.
					SELECT limit 1 NVL(a.telefono,'')
					INTO cCelular
					FROM bdinteg:"informix".si_telefonos a
					WHERE a.numcte = cNumCte and tipo_tel = 2;
					 
					IF cCelular <> '' then
            LET cCelular = SUBSTR(cCelular,4,10);
          END IF;

					--valido celular
	                EXECUTE PROCEDURE bdinteg:"informix".sp_tipored (cEmpresa,cCelular)				
					INTO cCodRetTipRed,cTipoRed,cNum_Carrier_Cat;
						
					--valido si truena el sp por un error controlado o un error de informix.		
					IF cCodRetTipRed IS NULL OR cCodRetTipRed = '' THEN				 				  	
						CONTINUE FOREACH;
					ELIF cCodRetTipRed < "00000" THEN 
					        LET cCodRet =  '002';						    EXIT FOREACH;
					END IF ;
					
					--valida si es un celular correcto.
					IF cNum_Carrier_Cat NOT IN ( '0', '1', '2')  THEN
						CONTINUE FOREACH;
					END IF;	 
					
					--obtengo numero de tarjeta
					/* En este momento aún no hay tarjeta
					SELECT NVL(a.num_tarjeta,'') 
					INTO cNumeroTarjeta
					FROM bdicred:"informix".sd_tarjeta a				
					WHERE a.empresa = cEmpresa
					AND a.num_credito = cNumCredito
						AND a.tipo_tarjeta = 'T'
						AND a.secuencia = (SELECT NVL(MAX(b.secuencia),0)
											FROM bdicred:"informix".sd_tarjeta b
											WHERE b.empresa = a.empresa
												AND b.num_credito = a.num_credito
												AND tipo_tarjeta = 'T');
           */
           				
					--inserta informacion recabada 				
					INSERT INTO bdicobranza:"informix".cb_info_administrativa(empresa,num_campania,producto,fecha_ejecucion,cliente,credito,cuenta,tarjeta,ciudad,estado,nombre1,nombre2,
														apell_paterno,apell_materno,t_celular,sdo_total,pago_min,fecha_pago,sdo_venc_int_mora,pago_venc,
														pago_min_sin_vdo,situacion,causa)
								VALUES(cEmpresa,sNumCampania,cNumProducto,dtFechaHoy,cNumCte,cNumCredito,'',cNumeroTarjeta,cCiudad,cEstado,cNombre1,cNombre2,cApellidoP,cApellidoM,cCelular,0,0,'',0,0,0,cSituacion,sCausa);												
	
		END FOREACH;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cProceso, cCodRet, cMensaje, '03')  RETURNING vvcCod_ret;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '003';  --No hay informacion
			RETURN cCodRet;			
		END IF;	
		
       RETURN cCodRet;
	END;
END PROCEDURE

 DOCUMENT
'AUTOR: Guadalupe Payan',
'Proyecto: Mensajes SMS',
'Solicito: Jesus Antonio Bastidas',
'Descripcion: Obtiene a los clientes y credito con TDC por entregar e inserta en la tabla cb_info_administrativa',
'Fecha: 2011/05/11',
'Version: 20110511.1056',
'2011-10-25 Modifica MACF. Suprimir algunos queries adicionar registro en bitácora de ejecución.',
'BD: bdicobranza';

CREATE PROCEDURE "informix".sp_directorioaltasycambios()
returning char (5);

-- CONTROL DE CAMBIOS;
------------------------------------------------------------------------------------
--Paul Ivan Quintero Varela
--15-01-2008
--llena la tabla sd_directorioctesbancoppel , para generar el archivo txt del directorio de cte
-- que solicita edgar vilchis de forma semanal, ya sin el ultimo pipe "|" listo para ser
-- descargado en su ambiente postgres
------------------------------------------------------------------------------------
-- Viridiana Osobampo
-- 06-11-2009
-- Se modifica para que en el select que obtiene el tipo de casa no rellene con espacios
-- en blanco el dato encontrado.
-- Modificación para paso 2 de Alta Única con migración de catálogos.
------------------------------------------------------------------------------------
-- Frank Gaxiola Gaxiola
-- 06-11-2009
-- Se aplica filtro a la consulta a la tabla si_ingresos por tipo de ingresosea igual a "T"
------------------------------------------------------------------------------------

----DATOS QUE VAN EN LA TABLA
DEFINE cNumCliente            char(20);
DEFINE cApellido1             char(26);
DEFINE cApellido2             char(26);
DEFINE cNombre1               char(26);
DEFINE cNombre2               char(26);
DEFINE dFechaNac              date;
DEFINE cRfc                   char(13);
DEFINE cCurp                  char(20);
DEFINE cSexo                  char(1);
DEFINE cEdoCivil              char(2);
DEFINE cApellidoCasada        char(26);
DEFINE sNumDependientes       smallint;
DEFINE cNacionalidad          char(15);
DEFINE cPuesto                char(30); --ocupacion_oficio
DEFINE cActividad             char(45); --actividad_gironegocio
DEFINE cTipoIdentificacion    char(40);
DEFINE cNumIdentificacion     char(30);
DEFINE cEmail                 char(60);
DEFINE cEscolaridad           char(20);
DEFINE cNumEstado             integer;
DEFINE sNumCiudad             smallint;
--DEFINE cNomCiudad             char(25);
--DEFINE cNomMunicipio          char(25);
DEFINE iNumColonia            integer;
DEFINE iNumCalle              integer;
DEFINE cNumExterior           char(10);
DEFINE cNumInterior           char(10);
DEFINE cCodPostal             char(5);
DEFINE cPuntoCardinal         char(1);
DEFINE iManzana               integer;
DEFINE iAndador               integer;
DEFINE iEtapa                 integer;
DEFINE iLote                  integer;
DEFINE iEdificio              integer;
DEFINE iEntrada               integer;
DEFINE cDepartamento          char(6);
DEFINE cComplemento           char(80);
DEFINE cEntreCalles           char(40);
DEFINE cDescripcion           char(80);
DEFINE sOtros                 smallint;
DEFINE cSituacion             char(1);
DEFINE dFechaMovtoSit         DATETIME YEAR to SECOND;
DEFINE sCausa                 smallint;
DEFINE cSector                char(2);
DEFINE cActividadCte          char(30);
DEFINE cLugarTrabajo          char(60);
DEFINE cDescripPermTrabajo    char(80);
--DEFINE cPuesto                char(30);
DEFINE mIngresoMensual        money(14,2);
DEFINE sNumCiudadTrab         smallint;
--DEFINE cNomCiudadTrab         char(25);
--DEFINE cNomMunicipioTrab      char(25);
DEFINE iNumColoniaTrab        integer;
DEFINE iNumCalleTrab          integer;
DEFINE cNumExteriorTrab       char(10);
DEFINE cNumInteriorTrab       char(10);
DEFINE cCodPostalTrab         char(5);
DEFINE cPuntoCardinalTrab     char(1);
DEFINE iManzanaTrab           integer;
DEFINE iAndadorTrab           integer;
DEFINE iEtapaTrab             integer;
DEFINE iLoteTrab              integer;
DEFINE iEdificioTrab          integer;
DEFINE iEntradaTrab           integer;
DEFINE cDepartamentoTrab      char(6);
DEFINE cComplementoTrab       char(80);
DEFINE cEntreCallesTrab       char(40);
DEFINE sOtrosTrab             smallint;
DEFINE cExisteCC              char(2);
DEFINE cAntigCliente          SMALLINT;
DEFINE cSucursalCliente       char(4); ---????? valor
DEFINE cTipoCasa              char(2);
DEFINE cTelefonoCasa          char(13);
DEFINE cCelular               char(13);
DEFINE cnumpersdomici         char(3);
DEFINE cnumperstrab           char(3);
DEFINE Crumbotrab             char(3);
DEFINE cTelefonoTrabajo       char(13);
DEFINE cExtensionTrabajo      char(13);
DEFINE CreditoAutoriza        DECIMAL(18,2);
DEFINE cClaveMov              char(1);
DEFINE cSucursalEjecutivo     char(4);
DEFINE cNomEjecutivo          char(45);
DEFINE fecha_movto            date;
DEFINE cNumCte_Coppel         char(20);

---VARIABLES AUXILIARES
DEFINE dFechaInsertCte        date;
DEFINE dFechaInsert           date;
DEFINE cNumClienteInicio      char(16);
DEFINE cEmpresa               char(3);
DEFINE cNumCredito            char(20);
DEFINE cCteFinal              char(20);
DEFINE cNumSolicitud          char(20);
DEFINE sElementoRes           smallint;
DEFINE sElemResTrabajo        smallint;
DEFINE cEvaluacionCC          char(1);
DEFINE iContadorRegistros     integer;
DEFINE cNombreArchivo1	      CHAR(100);
DEFINE cNombreArchivo2	      CHAR(100);
DEFINE Ac                     char(1);
DEFINE Cc                     char(1);
DEFINE iContadorCambios       integer;
DEFINE iContadorAltas         integer;
DEFINE cEmpleadoInsert        char(8);
DEFINE dFechaMax              DATE;

---VARIABLES PARA CAPTURAR ERRORES
DEFINE SQL_ERR                INTEGER;
DEFINE ISAM_ERR               INTEGER;
DEFINE ERROR_INFO             VARCHAR(80);
DEFINE P_COD_RET              VARCHAR(5);
DEFINE P_MENSAJE              VARCHAR(80);

---VARIABLES PARA QUERYS
DEFINE vsql                   CHAR(610);
DEFINE cSql                   CHAR(2024);
DEFINE vsql2                  CHAR(610);
DEFINE cSql2                  CHAR(2024);


BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        RETURN P_COD_RET;
    END EXCEPTION;

--SET DEBUG FILE TO "/informix/mahr/trc_dir_altycamb.out";
--TRACE ON;

----INICIALIZAN VARIABLES QUE VAN EN LA TABLA
LET cNumCliente =  "";
LET cCteFinal= "";
LET cApellido1= "";
LET cApellido2 = "";
LET cNombre1= "";
LET cNombre2 = "";
LET dFechaNac= DATE(1);
LET cRfc= "";
LET cCurp= "";
LET cSexo= "";
LET cEdoCivil= "";
LET cApellidoCasada= "";
LET sNumDependientes= 0;
LET cNacionalidad= "";
LET cPuesto= "";
LET cActividad= "";
LET cTipoIdentificacion= "";
LET cNumIdentificacion= "";
LET cEmail= "";
LET cEscolaridad= "";
LET cNumEstado= 0;
LET sNumCiudad= 0;
--LET cNomCiudad= "";
--LET cNomMunicipio= "";
LET iNumColonia= 0;
LET iNumCalle= 0;
LET cNumExterior= "";
LET cNumInterior= "";
LET cCodPostal= "";
LET cPuntoCardinal= "";
LET iManzana= 0;
LET iAndador= 0;
LET iEtapa= 0;
LET iLote= 0;
LET iEdificio= 0;
LET iEntrada= 0;
LET cDepartamento= "";
LET cComplemento= "";
LET cEntreCalles= "";
LET cDescripcion= "";
LET sOtros=0;
LET cSituacion= "";
LET dFechaMovtoSit= DATE(1);
LET sCausa= 0;
LET cSector= "";
LET cActividadCte= "";
LET cLugarTrabajo= "";
LET cDescripPermTrabajo= "";
--LET cPuesto= "";
LET mIngresoMensual= 0;
LET sNumCiudadTrab= 0;
--LET cNomCiudadTrab= "";
--LET cNomMunicipioTrab= "";
LET iNumColoniaTrab= 0;
LET iNumCalleTrab= 0;
LET cNumExteriorTrab= "";
LET cNumInteriorTrab= "";
LET cCodPostalTrab= "";
LET cPuntoCardinalTrab= "";
LET iManzanaTrab= 0;
LET iAndadorTrab= 0;
LET iEtapaTrab= 0;
LET iLoteTrab= 0;
LET iEdificioTrab= 0;
LET iEntradaTrab= 0;
LET cDepartamentoTrab= "";
LET cComplementoTrab= "";
LET cEntreCallesTrab= "";
LET sOtrosTrab= 0;
LET cExisteCC= "";
LET cAntigCliente= 0;
LET cSucursalCliente= "";
LET cTipoCasa= "";
LET cTelefonoCasa= "";
LET cCelular= "";
LET cnumpersdomici="" ;
LET cnumperstrab= "";
LET Crumbotrab= "";
LET cTelefonoTrabajo= "";
LET cExtensionTrabajo= "";
LET CreditoAutoriza= 0.00;
LET cClaveMov= "";
LET cSucursalEjecutivo= "";
LET cNomEjecutivo= "";
LET fecha_movto= DATE(1);
LET cNumCte_Coppel= "";

---INICIALIZAN VARIABLES AUXILIARES
--LET dFechaInsertCte= DATE(1);
LET dFechaInsert= DATE(1);
LET cNumClienteInicio="";
LET cEmpresa= "";
LET cNumCredito  = "";
LET cNumSolicitud= "";
LET sElementoRes= 0;
LET Ac= "";
LET Cc= "";
LET iContadorCambios= 0;
LET iContadorAltas= 0;
LET cEvaluacionCC= "";
LET iContadorRegistros= 0;
LET cEmpleadoInsert = "";
LET dFechaMax=DATE(1);
LET cNombreArchivo1= 'DirectorioCtesBancoppel' || LPAD(TRIM(DAY(CURRENT::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';
LET cNombreArchivo2= 'CifrasControlDirectorioCtesBancoppel' || LPAD(TRIM(DAY(CURRENT::DATE)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(CURRENT::DATE)::CHAR(2)),2,'0') ||YEAR(CURRENT::DATE) || '.txt';

---INICIALIZAN VARIABLES PARA QUERYS
LET  vsql="";
LET  cSql="";
LET  vsql2="";
LET  cSql2="";

Let P_cod_ret = "00000";
--  Set debug file to 'directorioaltasycambios.out';
--  trace on;
    DROP TABLE bdicred:sd_directorioaltasycambios;

    create table sd_directorioaltasycambios
    (
         empresa                 CHAR(3) NOT NULL,
         numctebancoppel         CHAR(20) NOT NULL,
         apell_paterno           CHAR(26),
         apell_materno           CHAR(26),
         nombre1                 CHAR(26),
         nombre2                 CHAR(26),
         fecha_nac               DATE,
         rfc                     CHAR(13),
         curp                    CHAR(20),
         sexo                    CHAR(1),
         estado_civil            CHAR(2),
         apell_casada            CHAR(26),
         num_dependientes        SMALLINT,
         nacionalidad            CHAR(15),
         ocupacion_oficio        CHAR(30),
         actividad_gironegocio   CHAR(30),
         identificacion          CHAR(40),
         num_identificacion      CHAR(30),
         correo_electronico      CHAR(60),
         escolaridad             CHAR(2),
         num_estado              integer,
         num_ciudad              SMALLINT,
--       ciudad                  CHAR(15),
--       delegacion_municipio    CHAR(15),
         num_colonia             INTEGER,
         num_calle               INTEGER,
         numeroext               CHAR(10),
         numeroint               CHAR(10),
         cod_postal              CHAR(5),
         punto_cardinal          CHAR(1),
         manzana                 SMALLINT,
         andador                 SMALLINT,
         etapa                   SMALLINT,
         lote                    SMALLINT,
         edificio                SMALLINT,
         entrada                 SMALLINT,
         departamento            CHAR(6),
         complemento             CHAR(80),
         entre_calles            CHAR(40),
         antiguedad_domicilio    VARCHAR(80),
         otros                   SMALLINT,
         situacion_esp           CHAR(1),
         fecha_sit_esp           DATE,
         causa_sit_esp           SMALLINT,
         sector                  CHAR(2),
         actividad_economica     CHAR(45),
         empresa_labora          CHAR(60),
         antiguedad_trabajo      VARCHAR(80),
         puesto                  CHAR(30),
         ingreso_mensual         MONEY,
         num_ciudad_trab         SMALLINT,
--         ciudad_trabajo          CHAR(15),
--         delegacion_municipio_trabajo    CHAR(15),
         num_colonia_trabajo         INTEGER,
         num_calle_trabajo           INTEGER,
         numeroext_trab          CHAR(10),
         numeroint_trab          CHAR(10),
         cod_postal_trab         CHAR(5),
         punto_cardinal_trabajo  CHAR(1),
         manzana_trabajo         SMALLINT,
         andador_trabajo         SMALLINT,
         etapa_trabajo           SMALLINT,
         lote_trabajo            SMALLINT,
         edificio_trabajo        SMALLINT,
         entrada_trabajo         SMALLINT,
         departamento_trabajo    CHAR(6),
         complemento_trabajo     CHAR(80),
         entre_calles_trabajo    CHAR(40),
         otros_trabajo           SMALLINT,
         existenciaCC            char(2),
         antig_cliente           SMALLINT,
         sucursal_cliente        CHAR(4),
         tipo_casa               CHAR(2),
         tel_casa                CHAR(13),
         tel_Celular             CHAR(13),
         num_pers_domici         char(3),
         num_pers_trab           char(3),
         rumbo_trab              char(3),
         tel_trabajo             CHAR(13),
         ext_trab                CHAR(5),
         monto_solicitado        DECIMAL(18,2),
         clave_movimiento        char(1),
         num_sucursal_realizo_movimiento    char(4),
         nombre_empleado_realizo_movimiento char(45),
         fecha_movimiento    date,
         numcte_coppel       CHAR(20)
    ) extent size 6004 next size 8232 lock mode row;

--  SELECT fecha_ant INTO fecha_movto FROM bdicred:sd_fechas;
    set isolation to dirty read;
    set lock mode to wait 3;

    SELECT nvl(MAX(fecha_generacion),date(1)) INTO dFechaMax FROM bdicred:sd_cifracontroldirectorioaltasycambios
    where empresa = '001';


    select numcte,'A' Status
        from bdinteg:si_cliente
        where fecha_insert >= dFechaMax
        and fecha_insert <= current
    into temp clientes_alta with no log;

--    select numcte,'A' Status
--    from bdicred:sd_maecred
--    where fecha_apertura >= dFechaMax - 1
--    group by 1,2
--    into temp clientes_alta with no log;

--    create unique index inx_clientes_alta on clientes_alta (numcte) using btree;

    insert into clientes_alta
    select numcte, 'C' Status
        from bdinteg:si_direcciones_actual
        where tipo_dir = '1'
        and fecha_insert >= dFechaMax
        and fecha_insert <= current
        and numcte not in (select numcte from clientes_alta)
        group by 1;

    create unique index inx_clientes_alta on clientes_alta (numcte) using btree;

    update statistics high for table clientes_alta;

    FOREACH   -- Datos del Cliente
        SELECT
            --nvl(mcr.num_credito,' ') AS numcredito,    -- numero de credito ::CHAR(20)
            nvl(cte.numcte,' ') AS numcte,     --  numero de cliente ::date
            nvl(cte.fecha_insert,' ') as fecha,
            nvl(cte.sucursal,' ') AS sucursal,
            rpad(TRIM(cte.apell_paterno),20,' ') AS apellpaterno,       --apellido 1
            rpad(TRIM(cte.apell_materno),20,' ') AS apellmaterno,     --apellido 2
            rpad(TRIM(cte.nombre1),20,' ') AS nombre1,      -- nombre 1
            rpad(TRIM(cte.nombre2),20,' ') AS nombre2,      -- nombre 2
            nvl(ctepf.fecha_nac,date(1)) AS anionac,    -- año de nacimiento
            rpad(TRIM(cte.rfc),13,' ') as rfc, -- rfc
            rpad(TRIM(ctepf.curp),20,' ') as curp, -- curp
            rpad(TRIM(ctepf.sexo),1,' ') as sexo, -- sexo
            rpad(TRIM(ctepf.estado_civil),2,' ') as edocivil, -- estado civil
            rpad(TRIM(cte.apell_casada),26,' ') as apellcasada, -- apellido de casada
            nvl(ctepf.dependientes,' ') as dependientes, --numero de dependientes
            rpad(TRIM(nac.descripcion),15,' ') as nacionalidad, -- nacionalidad
--            rpad(TRIM(puest.descripcion),30,' ') as puesto, -- descripcion puesto
            lpad(TRIM(actesp.descripcion),45,' ') as actividad, --actividad o giro de negocio
            rpad(TRIM(tipoidentif.descripcion),40,' ') as tipoidentificacion, -- tipo de identificación
            rpad(TRIM(ctepf.numidentifi),30,' ') as numidentificacion, --numero de identificación
--            rpad(TRIM(ctepf.email),60,' ') as email, -- correo electronico--------------------------se cambia por si_correos
            rpad(TRIM(co.correo_elec),60,' ') as correo_elec ,
			nvl(TRIM(ctepf.escolaridad),' ') AS escolaridad, -- escolaridad del cliente
--            rpad(TRIM(edo.nombre),30,' ') as estado, -- descripcion del estado
            rpad(TRIM(dir.estado),30,' ') as estado, -- numero estado
            lpad(dir.numerociudad,4,'0') AS numciudad, -- numero cd
--            rpad(TRIM(ciudad.nombreciudad),25,' ') as ciudad, -- descripcion de la ciudad
--            rpad(TRIM(ciudad.nombreciudad),25,' ') AS municipio,  -- descripcion municipio
            lpad(dir.numerocolonia,4,'0') AS numcolonia,  -- numero de colonia de cliente
            lpad(dir.numerocalle,6,'0') AS numcalle,  -- numero de calle de cliente
            TRIM(dir.numeroextcalle) AS numextcalle,   -- numero exterior
            TRIM(dir.numerointcalle) AS numintecalle,  -- numero interior
            lpad(TRIM(dir.cod_postal),5,'0') AS cod_postal,     -- codigo postal
            rpad(TRIM(dir.puntocardinal),1,' ') AS puntocardinal,   -- punto cardinal
            lpad(dir.manzana,5,'0') AS manzana,     -- manzana
            lpad(dir.andador,5,'0') AS andador,     -- andador
            lpad(dir.etapa,5,'0') AS etapa,     --etapa
            lpad(dir.lote,5,'0') AS lote,       -- lote
            lpad(dir.edificio,5,'0') AS edificio,   --edificio
            lpad(dir.entrada,5,'0') AS entrada,   -- entrada
            rpad(TRIM(dir.departamento),6,' ') AS departamento,     -- departamento
            rpad(TRIM(dir.observaciones),80,' ') AS complemento,  --   complemento
            rpad(TRIM(dir.entre_calles),40,' ') AS entre_calles,    -- entre calles
            lpad(dir.otros,2,'0') AS otros,     -- otros
            rpad(TRIM(cte.sector),2,' ') AS sector, -- sector
            nvl(TRIM(ctepf.actividadogiro),' ') AS ActividadDelCte, -- actividad del cliente
--            nvl(rpad(TRIM(ing.nombre_empresa),25,' '),' ') AS lugartrabajo,    -- lugar de trabajo
--            nvl(ing.ingreso_mensual,' ') AS ingresomensual,     -- ingreso mensual
              --nvl(rpad(TRIM(ctepf.habita_en),2,'0'),' ') AS tipo_casa,
            nvl(TRIM(ctepf.habita_en),'') AS tipo_casa,
--            nvl(rpad(TRIM(dir.telefono1),13,' '),' ') AS tel_casa,   -- telefono casa---------------se cambia por si_telefonos
--            nvl(rpad(TRIM(dir.telefono2),13,' '),' ') AS celular,    -- celular ---------------se cambia por si_telefonos
			nvl(rpad(TRIM(tel1.telefono),13,' '),' ') AS tel_casa,   -- telefono casa
			nvl(rpad(TRIM(tel2.telefono),13,' '),' ') AS celular,    -- celular
			nvl(dir.fecha_insert,' ') AS fecha_insert,
            nvl(rpad(TRIM(dir.user_insert),8,' '),' ') AS empleado_inserto,
            ( case when bdinteg:val_num(nvl(cte.numcte_ref,'')) then cte.numcte_ref else '' end)  AS cliente_coppel
            INTO  --cNumCredito ,
                cNumCliente, dFechaInsertCte, cSucursalCliente, cApellido1,
                cApellido2, cNombre1, cNombre2, dFechaNac, cRfc, cCurp, cSexo, cEdoCivil, cApellidoCasada,
                sNumDependientes, cNacionalidad, --cPuesto,
                cActividad, cTipoIdentificacion, cNumIdentificacion, cEmail,
--                cEscolaridad, cNumEstado, sNumCiudad , cNomCiudad, cNomMunicipio, iNumColonia, iNumCalle, cNumExterior,
                cEscolaridad, cNumEstado, sNumCiudad , iNumColonia, iNumCalle, cNumExterior,
                cNumInterior, cCodPostal, cPuntoCardinal, iManzana, iAndador, iEtapa, iLote, iEdificio, iEntrada,
                cDepartamento, cComplemento, cEntreCalles, sOtros, cSector, cActividadCte, --cLugarTrabajo, mIngresoMensual,
                cTipoCasa, cTelefonoCasa, cCelular,dFechaInsert,cEmpleadoInsert,cNumCte_Coppel
            from bdinteg:si_cliente cte
                INNER JOIN clientes_alta cte_paso ON (cte.numcte = cte_paso.numcte)
                INNER JOIN bdinteg:si_direcciones_actual dir ON (dir.numcte = cte.numcte and dir.tipo_dir = '1')                                                               
--                                                               AND dir.fecha_insert > dFechaMax )
                LEFT OUTER JOIN bdinteg:si_actesp actesp ON (actesp.empresa= cte.empresa and actesp.codigo=cte.actividad_esp)
--                LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
--                LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
                LEFT OUTER JOIN bdinteg:si_ctepf ctepf ON (ctepf.numcte = cte.numcte)
                LEFT OUTER JOIN bdinteg:si_tipoidentif tipoidentif ON (tipoidentif.codidentif=ctepf.codidentifi)
                LEFT OUTER JOIN bdinteg:si_nacion nac ON (nac.nacion=ctepf.nacionalidad)
				left outer join bdinteg:si_correos co on (co.empresa = cte.empresa and co.numcte = cte.numcte)
				left outer join bdinteg:si_telefonos tel1 on (tel1.empresa = cte.empresa and tel1.numcte = cte.numcte and tel1.tipo_tel = 1
															 and tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos
																					where numcte =tel1.numcte and tipo_tel =1))
				left outer join bdinteg:si_telefonos tel2 on(tel2.empresa = cte.empresa and tel2.numcte = cte.numcte and tel2.tipo_tel = 2
															and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos
																					where numcte =tel2.numcte and tipo_tel =2))
--                where sucursal = '0002'
--                where mcr.empresa='001'
--                AND mcr.status_cred in ('AA','BA','BT')
			
			
        -- determina si es credito

        LET cNumCredito = null;
        LET sElementoRes = 0;
        LET cDescripcion = '';
        LET sElemResTrabajo = 0;
        LET cDescripPermTrabajo = '';
        LET CreditoAutoriza = 0.00;
        LET cExisteCC = '';

        select max(num_credito)
            into cNumCredito
            from bdicred:sd_maecred
            where empresa = '001'
            and numcte = cNumCliente;

        if ( cNumCredito is not null) then
        --  Se obtiene el elemento respondido en la pregunta de tiempo de residencia
            SELECT elemento
                INTO sElementoRes
                FROM bdisolic:ss_detalle_scoring
                WHERE num_solicitud= cNumCredito
                AND seccion=2 AND grupo=6;

        -- Se obtiene la descripcion del elemento respondido en la pregunta tiempo de residencia
            SELECT descripcion
                INTO cDescripcion
                FROM bdisolic:ss_scoring_element
                WHERE seccion=2
                AND grupo=6
                AND elemento= sElementoRes;

        --  Se obtiene el elemento respondido en la pregunta Tiempo de permanencia en la ocupacion actual
            SELECT elemento
                INTO sElemResTrabajo
                FROM bdisolic:ss_detalle_scoring
                WHERE num_solicitud= cNumCredito
                AND seccion=2 AND grupo=8 ;

        -- Se obtiene la descripcion del elemento respondido  en la pregunta Tiempo de permanencia en la ocupacion actual
            SELECT descripcion
                INTO cDescripPermTrabajo
                FROM bdisolic:ss_scoring_element
                WHERE seccion=2
                AND grupo=8
                AND elemento= sElemResTrabajo;

                      -- Trae la linea de credito autorizada
            SELECT monto_solicitado
                INTO CreditoAutoriza
                FROM bdisolic:ss_solicitudes
                WHERE empresa='001'
                AND num_solicitud= cNumCredito;

            SELECT resscorfin.evalua_cc,meses_historia --, ingreso_mensual
                INTO cEvaluacionCC,cAntigCliente --, mIngresoMensual
                FROM bdisolic:ss_resum_scor_fin resscorfin
                WHERE empresa= '001'
                AND resscorfin.num_solicitud= cNumCredito;

            IF TRIM(cEvaluacionCC) = '0' OR TRIM(cEvaluacionCC)= '1' THEN
                LET cExisteCC= 'SI';
            ElSE
                LET cExisteCC= 'NO';
            END IF;
        end if;
        
        --- Informacion del Trabajo
        SELECT limit 1
            lpad(dir.numerociudad,4,'0') AS numciudad_trab, -- numero cd  trabajo
--            rpad(TRIM(ciudad.nombreciudad),25,' ') AS ciudad_trab, -- descripcion de la ciudad trabajo
--            rpad(TRIM(ciudad.nombreciudad),25,' ') AS municipio_trab,  -- descripcion municipio trabajo
            lpad(dir.numerocolonia,4,'0') AS numcolonia_trab,  -- numero de colonia de cliente trabajo
            lpad(dir.numerocalle,6,'0') AS numcalle_trab,  -- numero de calle del trabajo
            TRIM(dir.numeroextcalle) AS numextcalle_trab,   -- numero exterior  trabajo
            TRIM(dir.numerointcalle) AS numintecalle_trab,  -- numero interior  trabajo
            lpad(TRIM(dir.cod_postal),5,'0') AS cod_postal_trab,     -- codigo postal trabajo
            rpad(TRIM(dir.puntocardinal),1,' ') AS puntocardinal_trab,   -- punto cardinal trabajo
            lpad(dir.manzana,5,'0') AS manzana_trab,     -- manzana  trabajo
            lpad(dir.andador,5,'0') AS andador_trab,     -- andador trabajo
            lpad(dir.etapa,5,'0') AS etapa_trab,     --etapa trabajo
            lpad(dir.lote,5,'0') AS lote_trab,       -- lote trabajo
            lpad(dir.edificio,5,'0') AS edificio_trab,   --edificio trabajo
            lpad(dir.entrada,5,'0') AS entrada_trab,   -- entrada trabajo
            rpad(TRIM(dir.departamento),6,' ') AS departamento_trab,     -- departamento trabajo
            rpad(TRIM(dir.observaciones),80,' ') AS complemento_trab,  --   complemento trabajo
            rpad(TRIM(dir.entre_calles),40,' ') AS entre_calles_trab,    -- entre calles trabajo
            lpad(dir.otros,2,'0') AS otros,  -- otros trabajo
--            nvl(rpad(TRIM(dir.telefono3),13,' '),' ')  AS tel_trabajo_trab, -- telefono trabajo---------------se cambia por si_telefonos
--            nvl(rpad(TRIM(dir.extension),5,' '),' ')  AS ext_trabajo_trab -- extension trabajo---------------se cambia por si_telefonos
            nvl(rpad(TRIM(tel3.telefono),13,' '),' ')  AS tel_trabajo_trab, -- telefono trabajo
			nvl(rpad(TRIM(tel3.extension),5,' '),' ')  AS ext_trabajo_trab -- extension trabajo
--            INTO sNumCiudadTrab, cNomCiudadTrab, cNomMunicipioTrab, iNumColoniaTrab, iNumCalleTrab,  cNumExteriorTrab,
            INTO sNumCiudadTrab, iNumColoniaTrab, iNumCalleTrab,  cNumExteriorTrab,
                cNumInteriorTrab, cCodPostalTrab, cPuntoCardinalTrab, iManzanaTrab, iAndadorTrab, iEtapaTrab, iLoteTrab, iEdificioTrab,
                iEntradaTrab, cDepartamentoTrab, cComplementoTrab, cEntreCallesTrab, sOtrosTrab,cTelefonoTrabajo, cExtensionTrabajo
            FROM  bdinteg:si_cliente cte
            LEFT OUTER JOIN bdinteg:si_direcciones_actual dir ON (dir.numcte = cNumCliente AND dir.tipo_dir = '2')
			left outer join bdinteg:si_telefonos tel3 on (tel3.empresa = cte.empresa and tel3.numcte = cte.numcte and tel3.tipo_tel = 3
															and tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos
																					where numcte =tel3.numcte and tipo_tel =3))
				
--            LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
            WHERE cte.numcte= cNumCliente;


            -- Informacion de empleo.
        SELECT a.descripcion, b.nombre_empresa,b.ingreso_mensual   INTO cPuesto, cLugarTrabajo, mIngresoMensual
            FROM bdinteg:si_ingresos b
            LEFT OUTER JOIN bdinteg:si_puestos a ON (a.puesto=b.puesto)
            WHERE numcte=cNumCliente
            AND sec_ingreso=(select max(sec_ingreso) from bdinteg:si_ingresos b1 where b1.numcte=cNumCliente and b1.tipo_ingreso = 'T');


            -- Informacion de situacion especial.
        SELECT nvl(ctessit.situacion,' '), nvl(ctessit.causa,' '), nvl(ctessit.fechamovto,' ')
            INTO cSituacion, sCausa, dFechaMovtoSit
            FROM bdisitesp:se_ctessitespcte ctessit
            WHERE ctessit.numcte=cNumCliente;
            --  Condiciones para Generar Informacion Altas y Cambios.
        IF dFechaInsertCte =  dFechaInsert  THEN
            LET cClaveMov= 'A';
            LET iContadorAltas= iContadorAltas +1 ;
            LET Ac= '0';
        ELSE
            LET cClaveMov= 'C';
            LET iContadorCambios= iContadorCambios +1 ;
            LET Cc= '0';
        END IF;

            -- Se obtiene el numero de sucursal y
        SELECT nvl(nombre,' '), nvl(sucursal,' ')
            INTO cNomEjecutivo, cSucursalEjecutivo
            FROM bdinteg:si_ejecut
            WHERE ejecutivo= cEmpleadoInsert;

           --- Se inserta la informacion en la tabla cb_directorioctesbancoppel .
        INSERT INTO sd_directorioaltasycambios (empresa, numctebancoppel,apell_paterno,apell_materno,nombre1,nombre2,fecha_nac,rfc,curp,sexo,estado_civil,apell_casada,
                    num_dependientes,nacionalidad,ocupacion_oficio,actividad_gironegocio,identificacion,num_identificacion,correo_electronico,
--                    escolaridad,estado,num_ciudad,ciudad,delegacion_municipio,colonia,calle,numeroext,numeroint,cod_postal,punto_cardinal,
                    escolaridad,num_estado,num_ciudad,num_colonia,num_calle,numeroext,numeroint,cod_postal,punto_cardinal,
                    manzana,andador,etapa,lote,edificio,entrada,departamento,complemento,entre_calles,antiguedad_domicilio,otros,
                    situacion_esp,fecha_sit_esp,causa_sit_esp,sector,actividad_economica,empresa_labora,antiguedad_trabajo,puesto,
--                    ingreso_mensual,num_ciudad_trab,ciudad_trabajo,delegacion_municipio_trabajo,colonia_trabajo,calle_trabajo,numeroext_trab,
                    ingreso_mensual,num_ciudad_trab,num_colonia_trabajo,num_calle_trabajo,numeroext_trab,
                    numeroint_trab,cod_postal_trab,punto_cardinal_trabajo,manzana_trabajo,andador_trabajo,etapa_trabajo,lote_trabajo,
                    edificio_trabajo,entrada_trabajo,departamento_trabajo,complemento_trabajo,entre_calles_trabajo,otros_trabajo,existenciaCC,
                    antig_cliente,sucursal_cliente,tipo_casa,tel_casa,tel_Celular,num_pers_domici,num_pers_trab,rumbo_trab,tel_trabajo,ext_trab,
                    monto_solicitado,clave_movimiento,num_sucursal_realizo_movimiento,nombre_empleado_realizo_movimiento,fecha_movimiento,numcte_coppel)

            VALUES ('001', nvl ( cNumCliente,' ' ),
                    nvl ( replace ( replace( cApellido1 , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cApellido2 , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cNombre1 , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cNombre2 , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( dFechaNac, date(1) ),
                    nvl ( replace ( replace( cRfc , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cCurp , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( cSexo,' ' ),
                    nvl ( cEdoCivil,' ' ),
                    nvl ( replace ( replace( cApellidoCasada , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( sNumDependientes, 0 ),
                    nvl ( replace ( replace( cNacionalidad , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cPuesto , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cActividad , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cTipoIdentificacion , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cNumIdentificacion , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace(cEmail, '|' , '' ), '\' , ' ' ), ' ' ),
                    nvl ( cEscolaridad,' ' ),
                    nvl ( replace ( replace( cNumEstado , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( sNumCiudad, 0 ),
--                        nvl ( replace ( replace( cNomCiudad , '|' , ' ' ), '\' , ' ' ), ' ' ),
--                        nvl ( replace ( replace( cNomMunicipio , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( iNumColonia, 0 ),
                    nvl ( iNumCalle, 0 ),
                    nvl ( replace ( replace( cNumExterior , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cNumInterior , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cCodPostal , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( cPuntoCardinal,' ' ),
                    nvl ( iManzana, 0 ),
                    nvl ( iAndador, 0 ),
                    nvl ( iEtapa, 0 ),
                    nvl ( iLote, 0 ),
                    nvl ( iEdificio, 0 ),
                    nvl ( iEntrada, 0 ),
                    nvl ( replace ( replace( cDepartamento , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cComplemento , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cEntreCalles , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cDescripcion , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( sOtros, 0 ),
                    nvl ( replace ( replace( cSituacion , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( dFechaMovtoSit, date(1) ),
                    nvl ( sCausa, 0 ),
                    nvl ( replace ( replace( cSector , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cActividadCte , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cLugarTrabajo , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cDescripPermTrabajo , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cPuesto , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( mIngresoMensual, 0 ),
                    nvl ( sNumCiudadTrab, 0 ),
--                    nvl ( replace ( replace( cNomCiudadTrab , '|' , ' ' ), '\' , ' ' ), ' ' ),
--                    nvl ( replace ( replace( cNomMunicipioTrab , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( iNumColoniaTrab, 0 ),
                    nvl ( iNumCalleTrab, 0 ),
                    nvl ( replace ( replace( cNumExteriorTrab , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cNumInteriorTrab , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cCodPostalTrab , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cPuntoCardinalTrab , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( iManzanaTrab, 0 ),
                    nvl ( iAndadorTrab, 0 ),
                    nvl ( iEtapaTrab, 0 ),
                    nvl ( iLoteTrab, 0 ),
                    nvl ( iEdificioTrab, 0 ),
                    nvl ( iEntradaTrab, 0 ),
                    nvl ( replace ( replace( cDepartamentoTrab , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cComplementoTrab , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cEntreCallesTrab , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( sOtrosTrab, 0 ),
                    nvl ( replace ( replace( cExisteCC , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( cAntigCliente, 0 ),
                    nvl ( replace ( replace( cSucursalCliente , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cTipoCasa , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cTelefonoCasa , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cCelular , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cnumpersdomici , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cnumperstrab , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( Crumbotrab , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cTelefonoTrabajo , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cExtensionTrabajo , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( CreditoAutoriza, 0 ),
                    nvl ( replace ( replace( cClaveMov , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cSucursalEjecutivo , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    nvl ( replace ( replace( cNomEjecutivo , '|' , ' ' ), '\' , ' ' ), ' ' ),
                    current,cNumCte_Coppel );

        LET iContadorRegistros= iContadorRegistros+1;
        LET cNumCte_Coppel= "";
    End ForEach;

    update statistics medium for table bdicred:sd_directorioaltasycambios;

    LET cCteFinal=cNumCliente;

    -- insertar tabla si_cifracontroldirectoriocte de cifras.
    INSERT INTO  sd_cifracontroldirectorioaltasycambios (empresa,num_registros,num_altas,num_cambios,fecha_generacion)
    VALUES ('001', iContadorRegistros, iContadorAltas,iContadorCambios,current);

    -- para Generar el archivo de Salida.
    LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/DirectorioCtesBancoppelRegistros.unl''' || ' DELIMITER ' || '''|'''  ||
                   ' SELECT * FROM bdicred:sd_directorioaltasycambios d ' ||
                   ' WHERE d.fecha_movimiento = current::date  ' ||
                   ' " > /resplogifx/archivoscartera/DirectorioCtesBancoppelQuerys.sql';
    SYSTEM cSql;

    LET cSql = '';
    LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/DirectorioCtesBancoppelQuerys.sql';
    SYSTEM cSql;

    LET cSql = '';
    LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/DirectorioCtesBancoppelRegistros.unl > /resplogifx/archivoscartera/paso001.txt ";
    SYSTEM cSql;

    LET cSql = '';
    LET cSql = "sed 's/" || '"' ||  "//g' /resplogifx/archivoscartera/paso001.txt > /resplogifx/archivoscartera/" || trim(cNombreArchivo1);
    SYSTEM cSql;

    LET cSql = '';
    LET cSql = "rm /resplogifx/archivoscartera/DirectorioCtesBancoppelRegistros.unl /resplogifx/archivoscartera/DirectorioCtesBancoppelQuerys.sql /resplogifx/archivoscartera/paso001.txt";
    SYSTEM cSql;

    -- para Generar el archvio de Cifras.
    LET cSql = '';
    LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl''' || ' DELIMITER ' || '''|'''  ||
                ' SELECT * FROM bdicred:sd_cifracontroldirectorioaltasycambios c ' ||
                ' WHERE c.fecha_generacion = current::date  ' ||
                ' " > /resplogifx/archivoscartera/DirectorioCifrasControlQuerys.sql';
    SYSTEM cSql;

    LET cSql = '';
    LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/DirectorioCifrasControlQuerys.sql';
    SYSTEM cSql;

    LET cSql = '';
    LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl > /resplogifx/archivoscartera/" || trim(cNombreArchivo2);
    SYSTEM cSql;

    let cSql = '';
    LET cSql = "rm /resplogifx/archivoscartera/DirectorioCifrasControlRegistros.unl /resplogifx/archivoscartera/DirectorioCifrasControlQuerys.sql";
    SYSTEM cSql;

    RETURN P_COD_RET;

END;
END PROCEDURE;