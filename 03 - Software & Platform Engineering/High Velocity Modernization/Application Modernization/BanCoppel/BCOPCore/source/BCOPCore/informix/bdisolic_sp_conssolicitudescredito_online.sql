CREATE PROCEDURE "informix".sp_conssolicitudescredito_online(pTipo INTEGER, pEmpresa CHAR(3), pSucursal CHAR(20),
pSolicitudes SMALLINT, pNumCte CHAR(20),pStatus_solicitud CHAR(5),pNum_producto CHAR(4),pTpo SMALLINT,
pEjecucion INTEGER,pLimit INTEGER, pConsultaSP INTEGER, pCantRegPres INTEGER,pFechaIni DATE, pFechaFin DATE)
RETURNING
	CHAR(5)     AS Retorno ,           -- Codigo de Retorno
	CHAR(20)    AS Solicitud ,         -- Nro de Solicitud
	CHAR(20)    AS Cliente,            -- Nro de Cliente
	CHAR(120)   AS Nombre,             -- Nombre del Cliente
	CHAR(15)    AS RFC,                -- R.F.C.
	DATE        AS Fecha_solicitud,    -- Fecha de Solicitud
	DATE        AS Fecha_Autorizacion, -- Fecha Autorizacion
	CHAR(4)     AS Producto,           -- Numero de producto
	CHAR(40)    AS NombProd,           -- Nombre Producto
	MONEY(14,2) AS Linea_Otorgada,     -- Linea Otorgada
	CHAR(2)     AS Status,             -- Status de la Solicitud
	CHAR(130)   AS Descripcion_Status, -- Descripcion del Status de la Solicitud --1757
	CHAR(255)   AS Comentario,         -- Comentario
	CHAR(2)     AS Dia_Corte,          -- Dia de Corte
	CHAR(2)     AS Divisa,             -- Divisa
	MONEY(14,2) As v,                  -- Ingreso del Cliente
	CHAR(3)     AS Causa_solicitud,    -- Causa de solicitud
	CHAR(100)   AS Descripcin_Causa,   -- Descripcion de la causa de solicitud
	INTEGER     AS vigencia,           -- Dias de vigencia de la solicitud en su ultimo estatus
	INTEGER     AS Ejecucion,
	INTEGER     AS Limite,
	SMALLINT    AS CausaSituacion,
	INTEGER     AS iEsCtaCap,
	INTEGER     AS iConsultaSP,
	INTEGER     AS vCantRegPres,
	CHAR(1)     AS SituacionEsp,        -- Valor para identificar si tiene o no cuenta de captacion
	CHAR(20)  	AS NumCuenta,		    -- numero de cuenta
	INTEGER		AS FrecuenciaPago,      -- frecuencia de pago de nomina
	INTEGER		AS DiaPago,   -- dias de vigencia
	CHAR(10)	AS telefono_casa,   -- telefono de casa
	CHAR(10)	AS telefono_oficina; -- telefono de Oficina



	-- DEFINICION DE VARIABLES
	DEFINE cValRetorno      CHAR(5);
	DEFINE cValRetorno2     CHAR(5);
	DEFINE iSqlErr          INTEGER;
	DEFINE s_numsol         CHAR(20);
	DEFINE s_numcte         CHAR(20);
	DEFINE s_nombre         CHAR(110);
	DEFINE s_fechaaut       DATE;
	DEFINE  s_fechasol      DATE;
	DEFINE s_linea          MONEY(14,2);
	DEFINE s_status         CHAR(2);
	DEFINE s_stdesc         CHAR(130);
	DEFINE s_comentario     CHAR(255);
	DEFINE s_rfc            CHAR(15);
	DEFINE s_diacorte       CHAR(2);
	DEFINE s_divisa         CHAR(2);
	DEFINE s_ingreso        MONEY(14,2);
	DEFINE v_CausaSitEsp    SMALLINT;
	DEFINE vfecha_hoy       DATE;
	DEFINE vdias_rt         SMALLINT;
	DEFINE vdias_at         SMALLINT;
	DEFINE vdias_vigencia   INTEGER;
	DEFINE cSitEsp          CHAR(1);
	DEFINE cRegistro		CHAR(20);
	DEFINE cDescOA 			CHAR(100);
	--jom ini
	DEFINE r_social         CHAR(40);
	DEFINE nombre1          CHAR(40);
	DEFINE nombre2          CHAR(40);
	DEFINE apellidopaterno  CHAR(40);
	DEFINE apellidomaterno  CHAR(40);
	DEFINE s_eval_min       DECIMAL(10,2);
	DEFINE s_eval_max       DECIMAL(10,2);
	--jom fin
	define sinicio          INTEGER;
	DEFINE cCausaSol        CHAR(3);
	DEFINE vDescCausaSol    CHAR(100);
	DEFINE vCantReg         SMALLINT;
	DEFINE vCantReg1        SMALLINT;
	DEFINE vCantReg2        SMALLINT;
	DEFINE vCantReg3        SMALLINT;
	--pp
	DEFINE s_Mensaje_Retorno CHAR(54);
	DEFINE iEsCtaCap         INTEGER;
	DEFINE s_Producto        CHAR(4);
	DEFINE s_ProdDes         CHAR(40);
	DEFINE s_Solicitud       INTEGER;
	DEFINE s_Limit           SMALLINT;
	DEFINE s_Limit2          SMALLINT;
	DEFINE iejecucion        INTEGER;
	DEFINE iConsultaSP       INTEGER;
	DEFINE vCantRegPres      INTEGER;
	DEFINE pTipoSol			 CHAR(2);
	--VARIABLES PARA CREDINOMINA
	DEFINE cCuenta_eje      CHAR(20);
	DEFINE iFrecuencia      INTEGER;
	DEFINE iDiaPago         INTEGER;
	--VARIABLES DE TELEFONOS
	DEFINE cTelCasa      CHAR(10);
	DEFINE cTelOficina   CHAR(10);

	--VARIABLE CONTADOR
	DEFINE iCont		  		INTEGER;
	DEFINE iConsSPMovil_6500	INTEGER;
	DEFINE iConsSPMovil_6001	INTEGER;
	--INC Indicente Solicitudes de CrÃ©dito
	DEFINE dFechaHoy            DATE;
	DEFINE dFechaServ           DATE;

	--INICIALIZACION DE VARIABLES
	LET cValRetorno      = "000";
	LET cValRetorno2     = "00000";
	--LET cValRetorno    = 0;
	LET s_nombre         = "";
	LET s_numcte         = "";
	LET s_fechaaut       = "";
	LET s_fechasol       = "";
	LET s_status         = "";
	LET s_numsol         = "";
	LET s_comentario     = "";
	LET s_stdesc         = "";
	LET s_rfc            = "";
	LET s_linea          = 0;
	LET s_diacorte       = "";
	LET s_divisa         = "";
	LET v_CausaSitEsp    = 0;
	LET vfecha_hoy       = "";
	LET vdias_rt         = 0;
	LET vdias_at         = 0;
	LET vdias_vigencia   = 0;
	LET s_ingreso        = 0;
	LET cSitEsp          = "";
	LET cRegistro		 = "";
	LET cDescOA          = "";
	-- jom ini
	LET r_social         = "";
	LET nombre1          = "";
	LET nombre2          = "";
	LET apellidopaterno  = "";
	LET apellidomaterno  = "";
	LET s_eval_min       = 0;
	LET s_eval_max       = 0;
	-- jom fin
	let sinicio          = 0;
	LET cCausaSol        = "";
	LET vDescCausaSol    = "";
	LET vCantReg         = pCantRegPres;
	LET pTipoSol		 = '';
	LET vCantReg1        = 0;
	LET vCantReg2        = 0;
	LET vCantReg3        = 0;
	--pp
	LET s_Mensaje_Retorno = "";
	LET iEsCtaCap         = 0;
	LET s_Producto        = "";
	LET s_ProdDes         = "";
	LET s_Solicitud       = 0;
	LET s_Limit           = 0;
	LET s_Limit2          = 0;
	LET iejecucion        = 0;
	LET iConsultaSP       = 0;
	LET vCantRegPres      = 0;
	--VARIABLES PARA CREDINOMINA
	LET cCuenta_eje         = "";
	LET iFrecuencia         = 1;
	LET iDiaPago        	= 0;
	--VARIABLES DE TELEFONOS
	LET cTelCasa      = "";
	LET cTelOficina   = "";

	--VARIABLE CONTADOR
	LET iCont		  =0;
	LET iConsSPMovil_6500 = 0;
	LET iConsSPMovil_6001 = 0;

	---SET DEBUG FILE TO "/informix/sp_conssolicitudescredito_online";
	---TRACE ON;

	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO  WAIT 3;
		
		--INC Indicente Solicitudes de CrÃ©dito
		SELECT fecha_hoy 
		INTO dFechaHoy 
		FROM bdicred:"informix".sd_fechas 
		WHERE empresa = pEmpresa;
	
		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
		INTO dFechaServ
		FROM sysmaster:sysshmvals;

		IF dFechaHoy < dFechaServ THEN
			LET dFechaHoy = dFechaServ;
		END IF;
		
		IF NVL(pEmpresa,'') = '' THEN
			LET cValRetorno = '001';
			RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
					s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
					iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'');

		ELSE

			IF pTpo = 6 THEN

			FOREACH

				SELECT {+INDEX("informix".ss_solicitudes idx_numctesolic)} skip pSolicitudes limit 11
				a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert,
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
				INTO s_numsol, s_numcte, s_status, s_Producto, s_linea, s_fechasol,
					apellidopaterno, apellidomaterno, nombre1, nombre2, r_social, s_rfc,pTipoSol
				FROM "informix".ss_solicitudes a
				INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte)
				WHERE  a.numcte = pNumCte
				AND a.tipo_solicitud = 'T'
				AND a.sucursal = pSucursal
				AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','CM','PC','PA','IN')
				AND a.fecha_insert = dFechaHoy --INC Indicente Solicitudes de CrÃ©dito
				AND a.num_solicitud = (SELECT MAX(h.num_solicitud) FROM "informix".ss_solicitudes h
										WHERE h.empresa = pEmpresa
										and h.numcte = pNumCte
										AND h.sucursal = '8503'
										AND h.fecha_insert = dFechaHoy --INC Indicente Solicitudes de CrÃ©dito
										and h.tipo_solicitud = 'T')
				UNION ALL
				SELECT a.num_solicitud, a.numcte, a.status_solicitud, a.num_producto,
				a.monto_solicitado, a.fecha_insert,
				b.apell_paterno, b.apell_materno, b.Nombre1, b.Nombre2, b.razon_social, b.rfc,
				a.tipo_solicitud
				FROM "informix".ss_solicitudes a
				INNER JOIN bdinteg:"informix".si_cliente b ON (a.numcte  = b.numcte)
				WHERE  a.numcte = pNumCte
				AND a.tipo_solicitud = 'C'
				AND a.sucursal = pSucursal
				AND a.status_solicitud IN ('AT','RT','CC','BC','OS','EE','OA','EA','CE','ST','LC','MC','EC','CM','PC','PA','IN')
				AND a.fecha_insert = dFechaHoy --INC Indicente Solicitudes de CrÃ©dito
				AND a.num_solicitud = (SELECT MAX(h.num_solicitud) FROM "informix".ss_solicitudes h
										WHERE h.empresa         = pEmpresa
										and h.numcte = pNumCte
										and h.tipo_solicitud = 'C')
				ORDER BY b.Nombre1, b.Nombre2, b.apell_paterno, b.apell_materno, a.num_solicitud

				SELECT limit 1  date(e.fecha_entrada),f.num_producto,x.descripcion, NVL(e.causa_solicitud,""),
						NVL(( select  d.descripcion  from "informix".ss_causas_sol d
						where d.empresa = pEmpresa AND d.status_solicitud = s_status
						AND d.causa_solicitud = e.causa_solicitud),''),
						TRIM(NVL(e.comentario, ' ')) || ' ' || TRIM(NVL(c.motivo_cc, ' ')) comentario,
						f.divisa, NVL(c.ingreso_mensual, 0)
				INTO s_fechaaut, s_Producto, s_stdesc,cCausaSol,s_comentario,s_comentario,s_divisa,s_ingreso
				FROM "informix".ss_resum_scor_fin c, "informix".ss_autorizacion e, bdicred:"informix".sd_definicion f ,
					 "informix".ss_status_sol x, "informix".ss_tp_solicitud i
				WHERE c.empresa = pEmpresa
				  AND c.num_solicitud = s_numsol
				  AND e.empresa = c.empresa
				  AND e.num_solicitud = c.num_solicitud
				  AND e.status_solicitud = s_status
				  AND e.fecha_hora = (SELECT MAX(h.fecha_hora)
										FROM "informix".ss_autorizacion h
										WHERE h.empresa         = pEmpresa
										AND h.num_solicitud     = s_numsol
										AND h.status_solicitud  = s_status)
				  AND f.num_producto = s_Producto
				  AND f.empresa = pEmpresa
				  and x.empresa = pEmpresa
				  AND x.status_solicitud= s_status
				  AND i.empresa = pEmpresa
				  AND i.tp_solicitud = pTipoSol;

				LET s_nombre = TRIM(NVL(nombre1,"")) || " " || TRIM(NVL(nombre2,"")) || " " || TRIM(NVL(apellidopaterno,"")) || " " || TRIM(NVL(apellidomaterno,""));

					IF s_fechaaut IS NULL THEN
						LET s_fechaaut = DATE(1);
					END IF;

				LET vdias_vigencia = vfecha_hoy - s_fechaaut;

					IF s_status <> "AT" THEN
						LET s_fechaaut = "";
						LET s_linea = 0;

					END IF;

					SET ISOLATION TO DIRTY READ;
						SELECT dia_cuota
						  INTO s_diacorte
						  FROM bdicred:"informix".sd_definicion
						 WHERE num_producto = s_Producto;

						LET s_status = s_status;
						LET vCantReg = vCantReg + 1;

						IF vCantReg <= pSolicitudes THEN
						   CONTINUE FOREACH;
						END IF;

						IF CAST (cValRetorno AS INTEGER) = 0 THEN
							IF s_status = 'OA' THEN
								EXECUTE PROCEDURE "informix".sp_consulta_ordsup_ss(pEmpresa,pSucursal,s_numsol,s_numcte)
								INTO cValRetorno2,v_CausaSitEsp,cSitEsp;
							ELSE
								LET v_CausaSitEsp = 0;
								LET cSitEsp = "";
							END IF;
						END IF;

						IF s_status = "AT" THEN
							SELECT LIMIT 1 a.telefono
							INTO cTelCasa
							FROM bdinteg:"informix".si_telefonos_actual a
							WHERE a.empresa = '001'
							AND a.numcte = s_numcte
							AND a.tipo_tel = 1
							AND a.status_tel = 'A'
							AND a.cofetel = 'V' ;

							SELECT LIMIT 1  b.telefono
							INTO cTelOficina
							FROM bdinteg:"informix".si_telefonos_actual b
							WHERE b.empresa = '001'
							AND b.numcte = s_numcte
							AND b.tipo_tel = 2
							AND b.status_tel = 'A'
							AND b.cofetel = 'V' ;
						ELSE
							LET cTelCasa      = "";
							LET cTelOficina   = "";
						END IF;

							LET vCantReg  =  vCantReg + 1;
							LET vCantReg1 = vCantReg1 + 1;

						IF vCantReg = pCantRegPres + 12 THEN
							LET vCantReg1 = vCantReg;
							LET vCantReg2 = vCantReg;
							EXIT FOREACH;
						ELSE
							LET iConsultaSP = 1;
						END IF;

						IF s_Producto = "6500" and s_status = "RT" THEN
							SELECT descripcion INTO s_stdesc FROM bdisolic:"informix".ss_status_sol WHERE  status_solicitud = "RT" ;
						ELSE
							SELECT num_solicitud INTO cRegistro FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = s_numsol
							AND secuenciaos in (SELECT MAX(secuenciaos) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = s_numsol)
							AND fecha_solicitud = (SELECT MAX(fecha_solicitud) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = s_numsol);
								IF DBINFO('sqlca.sqlerrd2') = 0 THEN
									SELECT descripcion_no_gen_os INTO s_stdesc FROM bdisolic:"informix".ss_status_sol WHERE status_solicitud = s_status AND empresa = pEmpresa;
								ELSE
									SELECT descripcion_gen_os INTO s_stdesc FROM bdisolic:"informix".ss_status_sol WHERE status_solicitud = s_status AND empresa = pEmpresa;
								END IF;

								IF s_status = "OA" THEN
									SELECT valor INTO cDescOA FROM bdinteg:"informix".si_param WHERE cod_param = '375' AND empresa = pEmpresa;
									LET s_comentario = TRIM(cDescOA) || " " || TRIM(s_comentario);
								END IF;
						END IF;

						IF s_Producto = "6500" THEN
							LET iConsSPMovil_6500 = 1;
						END IF;

						IF s_Producto = "6001" THEN
							LET iConsSPMovil_6001 = 1;
						END IF;

						RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
								s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
								iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;

			END FOREACH;
			END IF;
		END IF;
	END
END PROCEDURE
