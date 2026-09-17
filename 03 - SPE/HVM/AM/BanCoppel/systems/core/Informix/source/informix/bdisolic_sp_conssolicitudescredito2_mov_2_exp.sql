CREATE PROCEDURE "informix".sp_conssolicitudescredito2_mov_2_exp(pTipo INTEGER, pEmpresa CHAR(3), pSucursal CHAR(20),
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
	CHAR(100)   AS Descripcin_Causa,   -- Descripción de la causa de solicitud
	INTEGER     AS vigencia,           -- Dias de vigencia de la solicitud en su ultimo estatus
	INTEGER     AS Ejecucion,
	INTEGER     AS Limite,
	SMALLINT    AS CausaSituacion,
	INTEGER     AS iEsCtaCap,
	INTEGER     AS iConsultaSP,
	INTEGER     AS vCantRegPres,
	CHAR(1)     AS SituacionEsp,        -- Valor para identificar si tiene o no cuenta de captación
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
	
	--INICIALIZACION DE VARIABLES
	LET cValRetorno      = "00000";
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

	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/JoseLuis/sp_conssolicitudescredito2.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','';
			END IF;
		END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO  WAIT 3;
		
		
		IF NVL(pEmpresa,'') = '' THEN
			LET cValRetorno = '00001';
			RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
					s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
					iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'');
		ELSE
            IF pTipo = 0 THEN
				--SOLICITUD CREDITO 
				LET iejecucion = pEjecucion;
				LET iConsultaSP = pConsultaSP;
				IF iConsultaSP = 1 THEN
					FOREACH
						EXECUTE PROCEDURE "informix".envia_monitorsol_cjunk_ss(
										  pEmpresa,pSucursal,pCantRegPres,pNumCte,'AT',pNum_producto,3,pFechaIni,pFechaFin)
						INTO  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,
							  s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,
							  cCausaSol,vDescCausaSol,vdias_vigencia

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
						--1757
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
						--
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
				ELSE
					LET vCantReg1 = 12;
				END IF;
					
				IF iConsultaSP = 2 OR vCantReg1 < 11 THEN
					IF pCantRegPres <> 0 AND  iConsultaSP = 2 THEN
						LET sinicio = pCantRegPres;
						LET vCantReg2 = pCantRegPres;
					ELSE
						LET sinicio = 0;
						LET vCantReg2 = 0;
					END IF;

					FOREACH
						EXECUTE PROCEDURE "informix".envia_monitorsol_pp_ss_2(
										  pEmpresa,pSucursal,sinicio,pNumCte,pNum_producto,'AT',11,pFechaIni,pFechaFin)
						INTO  cValRetorno,s_Mensaje_Retorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,
							  s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,
							  s_divisa,s_ingreso,iEsCtaCap,cCuenta_eje,iFrecuencia,iDiaPago,vdias_vigencia

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

						LET vCantReg       = vCantReg + 1;
						LET vCantReg2      = vCantReg2 + 1;
						
						IF vCantReg = pCantRegPres + 12 THEN
							EXIT FOREACH;
						ELSE
							LET iConsultaSP = 2;
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
						--
						IF s_Producto = "6500" THEN 
							LET iConsSPMovil_6500 = 1;
						END IF;
						
						IF s_Producto = "6001" THEN 
							LET iConsSPMovil_6001 = 1;
						END IF;

						RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
								s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
								iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg2,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
					END FOREACH;	
				ELSE
					LET vCantReg2 = 12;
				END IF;
				
				--SOLICITUD MOVIL
					LET iejecucion = pEjecucion;
					LET iConsultaSP = pConsultaSP;
					IF iConsultaSP = 1 THEN
					--IF 0 = 1 THEN
						FOREACH
							EXECUTE PROCEDURE "informix".envia_monitorsol_cjunk_ss_mov_2(
								  pEmpresa,pSucursal,pCantRegPres,pNumCte,'AT',pNum_producto,3,pFechaIni,pFechaFin)
							INTO  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,
								  s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,
								  cCausaSol,vDescCausaSol,vdias_vigencia
						   
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
								
							IF iConsSPMovil_6500 = 0 AND s_Producto = "6500" THEN 
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF;		

							IF iConsSPMovil_6001 = 0 AND s_Producto = "6001" THEN 
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF;		
							
						END FOREACH;
					ELSE
						LET vCantReg1 = 12;
					END IF;

					IF iConsultaSP = 1 OR vCantReg1 < 11 THEN 					
					--IF 0 = 1 THEN 					
						IF pCantRegPres <> 0 AND  iConsultaSP = 2 THEN
							LET sinicio = pCantRegPres;
							LET vCantReg2 = pCantRegPres;
						ELSE
							LET sinicio = 0;
							LET vCantReg2 = 0;
						END IF;
						
						FOREACH
							EXECUTE PROCEDURE "informix".envia_monitorsol_pp_ss_mov_2(
							pEmpresa,pSucursal,sinicio,pNumCte,pNum_producto,'AT',11,pFechaIni,pFechaFin)
							INTO  cValRetorno,s_Mensaje_Retorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,
							s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,
							s_divisa,s_ingreso,iEsCtaCap,cCuenta_eje,iFrecuencia,iDiaPago,vdias_vigencia
							
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

							LET vCantReg       = vCantReg + 1;
							LET vCantReg2      = vCantReg2 + 1;
							
							IF vCantReg = pCantRegPres + 12 THEN
								EXIT FOREACH;
							ELSE
								LET iConsultaSP = 2;
							END IF;
							
							IF iConsSPMovil_6500 = 0 AND s_Producto = "6500" THEN 
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
									s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
									iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg2,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF;		

							IF iConsSPMovil_6001 = 0 AND s_Producto = "6001" THEN 
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
									s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
									iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg2,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF;	
						END FOREACH;
					ELSE
						LET vCantReg2 = 12;
					END IF;

			

            ELIF pTipo = 4 THEN
				--SOLICITUDES CREDITO
				LET iejecucion = pEjecucion;
				LET iConsultaSP = pConsultaSP;
				IF iConsultaSP = 1 THEN
					FOREACH
						EXECUTE PROCEDURE "informix".envia_monitorsol_cjunk_ss(pEmpresa,pSucursal,pCantRegPres,pNumCte,'OA',pNum_producto,3,pFechaIni,pFechaFin)
						INTO  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,
						 s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,
						cCausaSol,vDescCausaSol,vdias_vigencia

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
						--1757
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
				ELSE
					LET vCantReg1 = 12;
				END IF;
				
				IF iConsultaSP = 2 OR vCantReg1 < 11 THEN
					IF pCantRegPres <> 0 AND  iConsultaSP = 2 THEN
						LET sinicio = pCantRegPres;
						LET vCantReg2 = pCantRegPres;
					ELSE
						LET sinicio = 0;
						LET vCantReg2 = 0;
					END IF;

					FOREACH
						EXECUTE PROCEDURE "informix".envia_monitorsol_pp_ss_2(
										  pEmpresa,pSucursal,sinicio,pNumCte,pNum_producto,'OA',11,pFechaIni,pFechaFin)
									INTO  cValRetorno,s_Mensaje_Retorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,
										  s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,
										  s_divisa,s_ingreso,iEsCtaCap,cCuenta_eje,iFrecuencia,iDiaPago,vdias_vigencia

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

						LET vCantReg       = vCantReg + 1;
						LET vCantReg2      = vCantReg2 + 1;
						LET vdias_vigencia = 0;

						IF vCantReg = pCantRegPres + 12 THEN
							EXIT FOREACH;
						ELSE
							LET iConsultaSP = 2;
						END IF;

						--1757
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
						--
						IF s_Producto = "6500" THEN
							LET iConsSPMovil_6500 = 1;
						END IF;
						
						IF s_Producto = "6001" THEN
							LET iConsSPMovil_6001 = 1;
						END IF;

						RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
								s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
								iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg2,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
					END FOREACH;
				ELSE
					LET vCantReg2 = 12;
				END IF;
					
				--SOLICITUDES MOVIL
				IF iConsSPMovil_6500 = 0 OR iConsSPMovil_6001 = 0 THEN
					LET iejecucion = pEjecucion;
					LET iConsultaSP = pConsultaSP;
					IF iConsultaSP = 1 THEN
					--IF 0 = 1 THEN
						FOREACH
							EXECUTE PROCEDURE "informix".envia_monitorsol_cjunk_ss_mov_2(
											  pEmpresa,pSucursal,pCantRegPres,pNumCte,pStatus_solicitud,pNum_producto,3,pFechaIni,pFechaFin)
										INTO  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,
											  s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,
											  cCausaSol,vDescCausaSol,vdias_vigencia
						   
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
						 
							IF iConsSPMovil_6500 = 0 AND s_Producto = "6500" THEN
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
										s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
										iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF;		

							IF iConsSPMovil_6001 = 0 AND s_Producto = "6001" THEN 
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
										s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
										iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF;	
						END FOREACH;
					ELSE
						LET vCantReg1 = 12;
					END IF;
					
					IF iConsultaSP = 2 OR vCantReg1 < 11 THEN 					
					--IF 0 = 2 THEN 					
						IF pCantRegPres <> 0 AND  iConsultaSP = 2 THEN
							LET sinicio = pCantRegPres;
							LET vCantReg2 = pCantRegPres;
						ELSE
							LET sinicio = 0;
							LET vCantReg2 = 0;
						END IF;
						
						FOREACH
							EXECUTE PROCEDURE "informix".envia_monitorsol_pp_ss_mov_2(pEmpresa,pSucursal,sinicio,pNumCte,	   pNum_producto,'OA',11,pFechaIni,pFechaFin)
								INTO  cValRetorno,s_Mensaje_Retorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,
								 s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,iEsCtaCap,cCuenta_eje,iFrecuencia,iDiaPago,vdias_vigencia
							
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
									
							LET vCantReg       = vCantReg + 1;
							LET vCantReg2      = vCantReg2 + 1;
							LET vdias_vigencia = 0;

							IF vCantReg = pCantRegPres + 12 THEN
								EXIT FOREACH;
							ELSE
								LET iConsultaSP = 2;
							END IF;
							
							IF iConsSPMovil_6500 = 0 AND s_Producto = "6500" THEN 
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
										s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
										iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg2,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF;		

							IF iConsSPMovil_6001 = 0 AND s_Producto = "6001" THEN 
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
										s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
										iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg2,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF;	
						END FOREACH;
					ELSE
						LET vCantReg2 = 12;
					END IF;	
					
				END IF;
			

			ELIF pTipo = 1 THEN
				--SOLICITUDES CRÉDITO
				LET iejecucion = pEjecucion;
				LET iConsultaSP = pConsultaSP;
				IF iConsultaSP = 1 THEN
					FOREACH
						EXECUTE PROCEDURE "informix".envia_monitorsol_cjunk_ss(
										  pEmpresa,pSucursal,pCantRegPres,pNumCte,pStatus_solicitud,pNum_producto,pTpo,pFechaIni,pFechaFin)
									INTO  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,
										  s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,
										  cCausaSol,vDescCausaSol,vdias_vigencia

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

						--1757
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
						--
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
				ELSE
					LET vCantReg1 = 12;
				END IF;

				IF iConsultaSP = 2 OR vCantReg1 < 11 THEN
					IF pCantRegPres <> 0 AND  iConsultaSP = 2 THEN
						LET sinicio = pCantRegPres;
						LET vCantReg2 = pCantRegPres;
					ELSE
						LET sinicio = 0;
						LET vCantReg2 = 0;
					END IF;

					FOREACH
						EXECUTE PROCEDURE "informix".envia_monitorsol_pp_ss_2(
										  pEmpresa,pSucursal,sinicio,pNumCte,pNum_producto,pStatus_solicitud,11,pFechaIni,pFechaFin)
									INTO  cValRetorno,s_Mensaje_Retorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,
										  s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,
										  s_divisa,s_ingreso,iEsCtaCap,cCuenta_eje,iFrecuencia,iDiaPago,vdias_vigencia

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

						LET vCantReg       = vCantReg + 1;
						LET vCantReg2      = vCantReg2 + 1;

						IF vCantReg = pCantRegPres + 12 THEN
							EXIT FOREACH;
						ELSE
							LET iConsultaSP = 2;
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
						--
						IF s_Producto = "6500" THEN
							LET iConsSPMovil_6500 = 1;
						END IF;
						
						IF s_Producto = "6001" THEN
							LET iConsSPMovil_6001 = 1;
						END IF;

						RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
								s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
								iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg2,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
					END FOREACH;
				ELSE
					LET vCantReg2 = 12;
				END IF;
				
				--SOLICITUDES MOVIL
				IF iConsSPMovil_6500 = 0 OR iConsSPMovil_6001 = 0 THEN
					LET iejecucion = pEjecucion;
					LET iConsultaSP = pConsultaSP;
					IF iConsultaSP = 1 THEN
					--IF 0 = 1 THEN
						FOREACH
							EXECUTE PROCEDURE "informix".envia_monitorsol_cjunk_ss_mov_2(
											  pEmpresa,pSucursal,pCantRegPres,pNumCte,pStatus_solicitud,pNum_producto,pTpo,pFechaIni,pFechaFin)
										INTO  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,
											  s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,
											  cCausaSol,vDescCausaSol,vdias_vigencia
											  
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
							
							IF iConsSPMovil_6500 = 0 AND s_Producto = "6500" THEN
							RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
									s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
									iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF;		
							
							IF iConsSPMovil_6001 = 0 AND s_Producto = "6001" THEN
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
									s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
									iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF; 		
						END FOREACH;
					ELSE
						LET vCantReg1 = 12;
					END IF;
					
					IF iConsultaSP = 2 OR vCantReg1 < 11 THEN 					
					--IF 0 = 2 THEN
						IF pCantRegPres <> 0 AND  iConsultaSP = 2 THEN
							LET sinicio = pCantRegPres;
							LET vCantReg2 = pCantRegPres;
						ELSE
							LET sinicio = 0;
							LET vCantReg2 = 0;
						END IF;
						
						FOREACH
							EXECUTE PROCEDURE "informix".envia_monitorsol_pp_ss_mov_2(
											  pEmpresa,pSucursal,sinicio,pNumCte,pNum_producto,pStatus_solicitud,11,pFechaIni,pFechaFin)
										INTO  cValRetorno,s_Mensaje_Retorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,
											  s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,
											  s_divisa,s_ingreso,iEsCtaCap,cCuenta_eje,iFrecuencia,iDiaPago,vdias_vigencia
							
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
									
							LET vCantReg       = vCantReg + 1;
							LET vCantReg2      = vCantReg2 + 1;

							IF vCantReg = pCantRegPres + 12 THEN
								EXIT FOREACH;
							ELSE
								LET iConsultaSP = 2;
							END IF;
							
							IF iConsSPMovil_6500 = 0 AND s_Producto = "6500" THEN
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
										s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
										iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg2,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF;		

							IF iConsSPMovil_6001 = 0 AND s_Producto = "6001" THEN
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
										s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
										iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantReg2,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF;			
						END FOREACH;
					ELSE
						LET vCantReg2 = 12;
					END IF;	
			
				END IF;
				
		
			ELIF pTipo = 2 THEN
				--SOLICITUDES CREDITO
				LET iejecucion = pEjecucion;
				IF iejecucion = 0 THEN
					LET s_Limit = 11;
					FOREACH
						EXECUTE PROCEDURE "informix".envia_monitorsol_pp_ss_2(
										  pEmpresa,pSucursal,pSolicitudes,pNumCte,pNum_producto,pStatus_solicitud,s_Limit,pFechaIni,pFechaFin)
									 INTO cValRetorno,s_Mensaje_Retorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,
										  s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,iEsCtaCap,cCuenta_eje,iFrecuencia,iDiaPago,vdias_vigencia

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
						LET vCantReg = vCantReg + 1;

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
						--
						IF s_Producto = "6500" THEN
							LET iConsSPMovil_6500 = 1;
						END IF;
						
						IF s_Producto = "6001" THEN
							LET iConsSPMovil_6001 = 1;
						END IF;
						
						RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,
								s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,iejecucion,
								s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
					END FOREACH;
				END IF;
				
				--SOLICITUDES MOVIL
				IF iConsSPMovil_6500 = 0 OR iConsSPMovil_6001 = 0 THEN
					LET iejecucion = pEjecucion;
					IF iejecucion = 0 THEN
					--IF 1 = 0 THEN
						LET s_Limit = 11;
						
						FOREACH
							EXECUTE PROCEDURE "informix".envia_monitorsol_pp_ss_mov_2(
											  pEmpresa,pSucursal,pSolicitudes,pNumCte,pNum_producto,pStatus_solicitud,s_Limit,pFechaIni,pFechaFin)
										 INTO cValRetorno,s_Mensaje_Retorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,
											  s_ProdDes,s_linea,s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,iEsCtaCap,cCuenta_eje,iFrecuencia,iDiaPago,vdias_vigencia
											  
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
							LET vCantReg = vCantReg + 1;
							

							IF iConsSPMovil_6500 = 0 AND s_Producto = "6500" THEN 
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,
										s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,iejecucion,
										s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF;		

							IF iConsSPMovil_6001 = 0 AND s_Producto = "6001" THEN 
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,s_status,
										s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,iejecucion,
										s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
							END IF;	
						END FOREACH;
					END IF;
					
				END IF; 
				
				
			ELIF pTipo = 3 THEN
				--SOLICITUDES CREDITO
				LET iejecucion = pEjecucion;
				IF iejecucion = 0 THEN
					FOREACH
						EXECUTE PROCEDURE "informix".envia_monitorsol_cjunk_ss(
										  pEmpresa,pSucursal,pSolicitudes,pNumCte,pStatus_solicitud,pNum_producto,pTpo,pFechaIni,pFechaFin)
									 INTO cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,
										  s_linea,s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol, vdias_vigencia
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

						LET vCantReg = vCantReg + 1;

						--1757
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
						
						RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
								s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
								iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
					END FOREACH;
				END IF;

				--SOLICITUDES MOVIL--
					LET iejecucion = pEjecucion;
					IF iejecucion = 1 THEN
					--IF 0 = 1 THEN
						FOREACH
							EXECUTE PROCEDURE "informix".envia_monitorsol_cjunk_ss_mov_2(
											  pEmpresa,pSucursal,pSolicitudes,pNumCte,pStatus_solicitud,pNum_producto,pTpo,pFechaIni,pFechaFin)
										 INTO cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,
											  s_linea,s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol, vdias_vigencia
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
									
							LET vCantReg = vCantReg + 1;
							
								RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
										s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
										iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'') WITH RESUME;
	
						END FOREACH;
					END IF;
					

					
			ELSE
				LET cValRetorno = '00001';
				RETURN  cValRetorno,s_numsol,s_numcte,s_nombre,s_rfc,s_fechasol,s_fechaaut,s_Producto,s_ProdDes,s_linea,
						s_status,s_stdesc,s_comentario,s_diacorte,s_divisa,s_ingreso,cCausaSol,vDescCausaSol,vdias_vigencia,
						iejecucion,s_Limit,v_CausaSitEsp,iEsCtaCap,iConsultaSP,vCantRegPres,cSitEsp,cCuenta_eje,iFrecuencia,iDiaPago,NVL(cTelCasa,''),NVL(cTelOficina,'');
			END IF;
		END IF;
	END
END PROCEDURE
