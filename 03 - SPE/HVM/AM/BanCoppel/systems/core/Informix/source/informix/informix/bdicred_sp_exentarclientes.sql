CREATE PROCEDURE "informix".sp_exentarclientes( pcEmpresa 		CHAR(3),
												pcNumCte 		CHAR(20), 
												pcNumCuenta 	CHAR(20), 
												pcNumTarjeta 	CHAR(20),
												piTipo			INTEGER)
RETURNING 	CHAR(5) 	AS CodRet,
			INTEGER   	AS BanderaBonifica;
	
DEFINE cCodRet			CHAR(5);
DEFINE cResultado		CHAR(1);
DEFINE cTarjeta 		CHAR(20);
DEFINE cProductoCred 	CHAR(20);
DEFINE cProMaeCheq	 	CHAR(20);
DEFINE cStatusCred		CHAR(2);
DEFINE cStatusTabla		CHAR(2);
DEFINE iSqlErr          INTEGER;
DEFINE iNumMaecred 		INTEGER;
DEFINE iNumCred 		INTEGER;
DEFINE iNumMaecredCrd 	INTEGER;
DEFINE iIndicador		INTEGER;
DEFINE iIndicador2		INTEGER;
DEFINE iBanderaBonifica INTEGER;
DEFINE iBanderaValido   INTEGER;
DEFINE exenta	 		INTEGER; 
DEFINE bonifica         INTEGER;
DEFINE fecha_liv		DATE;

LET cCodRet   			= '00000';
LET cResultado			= 'S';
LET cTarjeta   			= '';											
LET cProductoCred		= '';												
LET cProMaeCheq			= '';
LET cStatusCred			= '';
LET cStatusTabla		= '';
LET iSqlErr				= 0;
LET iNumMaecred 		= 0;
LET iNumMaecredCrd		= 0;
LET iNumCred 			= 0;	
LET iIndicador			= 0;
LET iIndicador2			= 0;
LET iBanderaBonifica	= 0;
LET iBanderaValido		= 0;
LET exenta	 			= 0;
LET bonifica			= 0;
LET fecha_liv = (SELECT valor FROM sd_param WHERE cod_param='100');


BEGIN

    ON EXCEPTION SET iSqlErr
       IF iSqlErr <> 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet,0;
       END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/tmp/sp_exentarclientes.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF  TRIM(NVL(pcEmpresa, '')) <> '' AND 	TRIM(NVL(pcNumCte,'')) <> '' THEN	
	
		IF  TRIM(NVL(pcNumCuenta,'')) <> '' OR TRIM(NVL(pcNumTarjeta,'')) <> '' THEN
						
			SELECT producto
			INTO cProMaeCheq
			FROM bdicheq:"informix".sc_maechq
			WHERE empresa = pcEmpresa 
			AND num_cte = pcNumCte
			AND cuenta = pcNumCuenta;
			
			IF piTipo = 2 THEN 	
				IF  TRIM(NVL(pcNumCuenta,'')) <> '' AND  TRIM(NVL(pcNumTarjeta,'')) = ''  THEN
					SELECT num_tarjeta 
					INTO cTarjeta
					FROM bdicheq: "informix".sc_tarjeta
					WHERE empresa = pcEmpresa 
					AND numcte = pcNumCte
					AND cuenta = pcNumCuenta
					AND tipo_tarjeta = 'T';
				ELIF TRIM(NVL(pcNumTarjeta,'')) <> '' AND TRIM(NVL(pcNumCuenta,'')) = '' THEN
					SELECT num_tarjeta 
					INTO cTarjeta
					FROM bdicheq: "informix".sc_tarjeta
					WHERE empresa = pcEmpresa 
					AND numcte = pcNumCte
					AND num_tarjeta = pcNumTarjeta
					AND tipo_tarjeta = 'T';
				ELIF TRIM(NVL(pcNumTarjeta,'')) <> '' AND TRIM(NVL(pcNumCuenta,'')) <> '' THEN
					SELECT num_tarjeta 
					INTO cTarjeta
					FROM bdicheq: "informix".sc_tarjeta
					WHERE empresa = pcEmpresa 
					AND numcte = pcNumCte
					AND cuenta = pcNumCuenta
					AND num_tarjeta = pcNumTarjeta
					AND tipo_tarjeta = 'T';
				END IF;
			END IF;
			
			IF NVL(cTarjeta,'')<> '' OR piTipo = 1 THEN

				SELECT COUNT(num_credito )
				INTO iNumMaecred
				FROM bdicred:"informix".sd_maecred
				WHERE empresa = pcEmpresa 
				AND numcte = pcNumCte;
				
				SELECT COUNT(num_credito )
				INTO iNumMaecredCrd
				FROM bdicred:"informix".sd_maecredcrd
				WHERE empresa = pcEmpresa 
				AND numcte = pcNumCte;

				IF NVL(iNumMaecred,0)> 0 OR  NVL(iNumMaecredCrd,0)> 0 THEN
						
						IF  NVL(iNumMaecred,0)> 0  THEN
						
							FOREACH
								SELECT  num_producto, status_cred
								INTO cProductoCred, cStatusCred
								FROM bdicred:"informix".sd_maecred
								WHERE empresa = pcEmpresa 
								AND numcte = pcNumCte
									
									IF cResultado = 'S'  THEN
										LET cResultado = 'N';
										LET iBanderaValido = 0;
										FOREACH
											SELECT indicador,  status
											INTO iIndicador, cStatusTabla
											FROM bdicred:"informix".sd_combproductos
											WHERE producto_credito = cProductoCred
											AND producto_debito = cProMaeCheq
											
																			
											IF cResultado = 'N' THEN
												LET iBanderaValido = 1;
												IF NVL(iIndicador,0) > 0 THEN
													LET exenta =0;
													IF TRIM(cStatusTabla) = TRIM(cStatusCred) AND iIndicador= 1 THEN
														LET cResultado = 'S';
														LET exenta =1;
													END IF;
												END IF;
											END IF;
										END FOREACH;
										
									END IF;
						
							END FOREACH;
							
						END IF;
						
						IF NVL(iNumMaecredCrd,0)> 0 AND cResultado = 'S' THEN
							FOREACH
								SELECT num_producto, status_cred
								INTO cProductoCred,  cStatusCred
								FROM bdicred:"informix".sd_maecredcrd
								WHERE empresa = pcEmpresa 
								AND numcte = pcNumCte
								
								IF cResultado = 'S' OR exenta =1 THEN
									LET cResultado = 'N';
									LET iBanderaValido = 0;
									FOREACH
										SELECT indicador,  status
										INTO iIndicador, cStatusTabla
										FROM bdicred:"informix".sd_combproductos
										WHERE producto_credito = cProductoCred
										AND producto_debito = cProMaeCheq
											
										IF cResultado = 'N' THEN
											LET iBanderaValido = 1;
											IF NVL(iIndicador,0) > 0 THEN 
													
												IF TRIM(cStatusTabla) = TRIM(cStatusCred) AND iIndicador = 1 THEN
													LET cResultado = 'S';
													LET exenta=0;
												END IF;
											END IF;
										END IF;
									END FOREACH;
								END IF;
									
							END FOREACH;
						
						END IF;
						
						IF cResultado = 'N' AND  iBanderaValido = 0 THEN
							IF exenta = 1 THEN 
								LET iBanderaBonifica = 2;
							ELSE 
								LET iBanderaBonifica = 5;
							END IF;
						ELIF cResultado = 'N' AND  iBanderaValido = 1 THEN
							LET iBanderaBonifica = 3;
						ELIF cResultado = 'S'  THEN
							LET iBanderaBonifica = 2;
						END IF;
				ELSE
				
				
					SELECT COUNT(num_solicitud)
					INTO iNumCred
					FROM bdisolic:"informix".ss_solicitudes
					WHERE empresa = pcEmpresa 
					AND numcte = pcNumCte
					AND fecha_insert <= fecha_liv;
					
					IF NVL(iNumCred,0)  > 0 THEN
					
						FOREACH
							SELECT num_producto, status_solicitud
							INTO cProductoCred, cStatusCred
							FROM bdisolic:"informix".ss_solicitudes
							WHERE empresa = pcEmpresa 
							AND numcte = pcNumCte
							AND tipo_solicitud <> 'C'
									
			
								IF cResultado = 'S' AND iIndicador2 = 0 THEN
									LET cResultado = 'N';
									LET iBanderaValido = 0;
									FOREACH
										SELECT indicador,  status
										INTO iIndicador, cStatusTabla
										FROM bdicred:"informix".sd_combproductos
										WHERE producto_credito = cProductoCred
										AND producto_debito = cProMaeCheq
										
										LET	bonifica = 0; 																		
																		
										IF cResultado = 'N' THEN
											LET iBanderaValido = 1;
											IF NVL(iIndicador,0) > 0 THEN
												IF TRIM(cStatusTabla) = TRIM(cStatusCred) THEN
													LET cResultado = 'S';
													IF iIndicador = 3 THEN 
														LET iIndicador2= iIndicador;
													END IF;	
												ELSE 	
													LET bonifica = 1;
												END IF;
											END IF;
										END IF;	
									END FOREACH;
								END IF;
						END FOREACH;
						
						IF cResultado = 'N' AND  iBanderaValido = 0 THEN
							IF bonifica = 1 THEN
								LET iBanderaBonifica = 0;
							ELSE 
								LET iBanderaBonifica = 5;
							END IF;
							
						ELIF cResultado = 'N' AND  iBanderaValido = 1 THEN
							LET iBanderaBonifica = 0;
						ELIF cResultado = 'S'  THEN
							IF iIndicador2 = 3  THEN
								IF bonifica = 1 THEN
									LET iBanderaBonifica = 0;
								ELSE 
									LET iBanderaBonifica = 3;								
								END IF; 	
							ELSE
								IF iNumCred > 0 THEN
									LET iBanderaBonifica = 6;
								ELSE 
									LET iBanderaBonifica = 2;
								END IF;
							END IF
						END IF;
						
					ELSE
						LET iBanderaBonifica = 6;
					END IF;
					
				END IF;
				
			ELSE
				LET iBanderaBonifica = 4;
			END IF;
			
		ELSE
			LET cCodRet = '000002';
		END IF;
	ELSE
		LET cCodRet = '000001';
	END IF;
	
	RETURN cCodRet, iBanderaBonifica;
		
END;
END PROCEDURE
DOCUMENT
'Folio:1583',
'Autor:94972834 Felipe de jesus urias rocha',
'Fecha:20/02/2014',
'Modificación: se crea sp para validar si a de realizarce el cobro de comision de tarjetas de debito',
'Sustento: RQM 10 408-2 Adendum Clientes exentos de cobro de comisión por emisión de TD.pdf  (Pagina 8 a 9)',
'Solicita: Rodolfo Gomez Hernandez',
'Folio:1609',
'Modifico: 94972834 Felipe de jesus urias rocha',
'Fecha:03/06/2014',
'modififcacion: se modifica el flujo para que el cliente con una cuenta o estatus invalido, se le realize',
'el cobro de comision',
'Sustento: RQM 10408Observaciones.doc',
'Solicita: Rodolfo Gomez',
'Modifico: 95671641 Berenice Méndez Rivera',
'Fecha: 05/11/2014',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_status_sol_audexcel(pempresa CHAR(3),psucursal CHAR(4),pfechaini CHAR(10),pfechafin CHAR(10),pstatus CHAR(2))
RETURNING CHAR(5),       -- Codigo de Retorno
		  CHAR(80),      -- Mensaje de Retorno
          CHAR(20),      -- Nro de Solicitud
		  CHAR(20),      -- Nro de Cliente
		  DATE,          -- Fecha Alta
          CHAR(104),     -- Nombre del Cliente
          CHAR(2),       -- Status Solicitud
          MONEY(14,2),   -- Monto Solicitud
		  MONEY(14,2),   -- Monto otorgado
          DATE,          -- Fecha Cambio Status
		  CHAR(45),      -- Nombre del promotor que realizo la alta de solicitud
		  CHAR(45),      -- Nombre del promotor que autorizo la entrega de solicitud
		  CHAR(45),      -- Nombre del promotor que entrega la tarjeta
		  CHAR(45),      -- Nombre del promotor que asigno la tarjeta	  
          CHAR(13),      -- Telefono Particular
		  CHAR(13),      -- Telefono Celular
		  CHAR(13),      -- Telefono Oficina
		  CHAR (4),		 -- Sucursal 
		  CHAR(104),     -- Nombre de la primer referencia
		  CHAR(13),      -- Telefono Particular
		  CHAR(13),      -- Telefono Celular
		  CHAR(13),      -- Telefono Oficina
		  CHAR(104),     -- Nombre de la segunda referencia
		  CHAR(13),      -- Telefono Particular
		  CHAR(13),      -- Telefono Celular
		  CHAR(13);      -- Telefono Oficina

		  
--*************************************************************************
--                         DEFINICION DE VARIABLES
--*************************************************************************
DEFINE cCod_ret CHAR(5);
DEFINE cMen_ret CHAR(80);
DEFINE iSqlerr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cNumSol CHAR(20);
DEFINE cNumcte CHAR(20);
DEFINE cStatus CHAR(2);
DEFINE mMonto MONEY(14,2);
DEFINE mMonto_aut     MONEY(14,2);
DEFINE cNomCte     CHAR(104);
DEFINE cNombre1       CHAR(26);
DEFINE cNombre2       CHAR(26);
DEFINE cApell_paterno CHAR(26);
DEFINE cApell_materno CHAR(26);
DEFINE dtFechaSol     DATE;
DEFINE dtFechaCam DATE;
DEFINE cUsuarioAlta CHAR(10);
DEFINE cNombrePromAlta CHAR(45);
DEFINE cNombrePromAutoriza CHAR(45);
DEFINE cNombrePromEntrega CHAR(45);
DEFINE cNombrePromActiva CHAR(45);
DEFINE cTelCasa CHAR(13);
DEFINE cTelCel CHAR(13);
DEFINE cTelOfi CHAR(13);
DEFINE cTel CHAR(13);
DEFINE cSucursal CHAR(4);
DEFINE sTipoTel SMALLINT;
DEFINE icontador INTEGER;
DEFINE iDiasConsulta INTEGER;
DEFINE iDiasConsultaExcel INTEGER;
DEFINE iConStatus INTEGER;
DEFINE cNomRef1 CHAR(104);
DEFINE cNomRef2 CHAR(104);
DEFINE cTelefonotrabajoRef1 CHAR(13);
DEFINE cTelefonocelularRef1 CHAR(13);
DEFINE cTelefonooficinaRef1 CHAR(13);
DEFINE cTelefonotrabajoRef2 CHAR(13);
DEFINE cTelefonocelularRef2 CHAR(13);
DEFINE cTelefonooficinaRef2 CHAR(13);
DEFINE iSecuencia INTEGER;
DEFINE iSegundaref INTEGER;
DEFINE icontador2 INTEGER;
DEFINE cEstadocivil CHAR(1);

--referencias
DEFINE cNombre 		 CHAR(104);
DEFINE cParentesco   CHAR(2);
DEFINE cTelRef 		CHAR(13);
DEFINE cNumcteRef   CHAR(20);
DEFINE cNombreCong 		CHAR(104);
DEFINE cNombreR1 		CHAR(104);
DEFINE cTelR1 	     	CHAR(13);
DEFINE cNombreR2 		CHAR(104);
DEFINE cTelR2 		    CHAR(13);
-- *************************************************************************
-- *                        ASIGNACION DE VARIABLES
-- **************************************************************************
LET cCod_ret     = "000";
LET cMen_ret     = "Proceso Exitoso";
LET iSqlerr      = 0;
LET iIsamErr      = 0;
LET cNumcte     = "";
LET cNumSol        = "";
LET cStatus        = "";
LET mMonto         = 0;
LET mMonto_aut     = 0;
LET cNomCte     = "";
LET cNombre1       = "";
LET cNombre2       = "";
LET cApell_paterno = "";
LET cApell_materno = "";
LET dtFechaSol     = "";
LET dtFechaCam = "";
LET cUsuarioAlta = "";
LET cNombrePromAlta = "";
LET cNombrePromAutoriza = "";
LET cNombrePromEntrega = "";
LET cNombrePromActiva = "";
LET cTelCasa = "";
LET cTelCel = "";
LET cTelOfi = "";
LET cTel = "";
LET sTipoTel = "";
LET cSucursal = "";
LET icontador = 0;
LET iDiasConsulta = 0;
LET iDiasConsultaExcel = 0;
LET iConStatus = 0;

LET  cNomRef1 = "";
LET  cNomRef2 = "";
LET  cTelefonotrabajoRef1 = "";
LET  cTelefonocelularRef1 = "";
LET  cTelefonooficinaRef1 = "";
LET  cTelefonotrabajoRef2 = "";
LET  cTelefonocelularRef2 = "";
LET  cTelefonooficinaRef2 = "";
LET  iSecuencia = 0;
LET  iSegundaref = 0;
LET  icontador2 = 0;
LET  cEstadocivil = "";

LET cNombre 		= "";
LET cParentesco     = "";
LET cTelRef 		= "";
LET cNumcteRef      = "";
LET cNombreCong 	= "";
LET cNombreR1 		= "";
LET cTelR1 	     	= "";
LET cNombreR2 		= "";
LET cTelR2 		    = "";
-- **********************************************************************
-- *                        CONTROL DE ERRORES
-- ***********************************************************************
BEGIN
ON EXCEPTION SET iSqlerr,iIsamErr,cMen_ret
   IF iSqlerr != 0 THEN
      LET cCod_ret=iSqlerr;
     RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
		NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),'','','','','','','','';	
   END IF;
END EXCEPTION;



 --SET DEBUG FILE TO "/informix/jesus/sp_status_sol_audexcel.out";
 --TRACE ON;
-- **********************************************************************
-- *                        PROGRAMA PRINCIPAL
-- **********************************************************************

    IF NVL(pSucursal, '') = '' THEN
        LET  cCod_ret = '00001';
		LET cMen_ret = 'LA SUCURSAL ES UN DATO REQUERIDO PARA LA EXPORTACION A EXCEL';
		RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
		NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),'','','','','','','','';	
	END IF;
    IF NVL(pStatus, '') = '' THEN
        LET  cCod_ret = '00002';
		LET cMen_ret = 'EL ESTATUS ES UN DATO REQUERIDO PARA LA EXPORTACION A EXCEL';		
		RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
		NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),'','','','','','','','';	
    END IF;


	
	SELECT  COUNT(valor_alfabetico)
	INTO iConStatus
	FROM "informix".sd_param_campania
	WHERE empresa = pempresa
	AND tipo_campania = 65
	AND grupo_parametro ='EXCELAUDI'
	AND TRIM(valor_alfabetico) = pStatus;

	IF iConStatus = 0 THEN
		LET  cCod_ret = '00003';
		LET cMen_ret = 'EL ESTATUS NO ES VALIDO PARA LA EXPORTACION A EXCEL';		
		RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
		NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),'','','','','','','','';	
	END IF;
	--validacion de los dias de consulta
	
	SELECT  valor
	INTO iDiasConsultaExcel
	FROM "informix".sd_param
	WHERE empresa = pempresa
	AND cod_param = '084';
	
	 LET  iDiasConsulta = pFechafin::DATE - pFechaini::DATE ;
	 
	 IF iDiasConsulta > iDiasConsultaExcel THEN
		LET  cCod_ret = '00004';
		LET cMen_ret = 'EL RANGO DE FECHAS NO ES VALIDO PARA LA EXPORTACION A EXCEL';		
		RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
		NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),'','','','','','','','';		 
	 END IF;
	

	FOREACH WITH HOLD

		SELECT a.num_solicitud, a.numcte, a.status_solicitud,nvl(a.monto_solicitado,0),
		nvl(a.monto_autorizado,0),nvl(a.fecha_insert,date(1)), a.sucursal,a.user_insert
		INTO cNumSol,cNumcte,cStatus,mMonto,mMonto_aut,dtFechaSol ,cSucursal,cUsuarioAlta
		FROM bdisolic:"informix".ss_solicitudes  a
		INNER JOIN bdisolic:"informix".ss_anexosol b ON (b.empresa = a.empresa AND b.num_solicitud = a.num_solicitud) 
		WHERE a.empresa = pEmpresa 
		AND a.num_solicitud >=''		
		AND a.fecha_insert BETWEEN pFechaini::DATE AND  pFechafin::DATE
		AND a.status_solicitud = pStatus
		AND  a.sucursal =pSucursal
	
		SELECT pf.estado_civil,TRIM(cte.nombre1) || ' ' || TRIM(cte.nombre2) || ' ' || TRIM(cte.apell_paterno) || ' ' || TRIM(cte.apell_materno)
		INTO cEstadocivil,cNomCte
		FROM bdinteg:"informix".si_cliente cte
		INNER JOIN bdinteg:"informix".si_ctepf pf ON (pf.Empresa = cte.empresa and pf.numcte= cte.numcte)
		WHERE cte.empresa = pEmpresa 
		AND cte.numcte = cNumcte;
  

	--Obtencion de telefonos
		
		FOREACH 
			SELECT telefono,tipo_tel
				INTO cTel,sTipoTel
			FROM bdinteg:"informix".si_telefonos_actual a	 
			WHERE a.empresa = '001' 
			AND a.numcte = cNumcte 
			AND a.tipo_tel IN (1,2,3)		
			AND a.status_tel = 'A'
			
			IF sTipoTel = 1 THEN
				LET cTelCasa =cTel;				
			ELIF sTipoTel = 2 THEN
				LET cTelCel = cTel;				
			ELIF sTipoTel = 3 THEN
				LET cTelOfi = cTel;
			END IF;	
		END FOREACH;
      -----------------------------MONTO AUTORIZADO--------------------------------
         
		IF cStatus='AP' THEN
		
			SELECT LIMIT 1 NVL(eje.nombre,"")--Usuario que dio de alta la solicitud
			INTO cNombrePromAlta
			FROM  bdinteg:"informix".si_ejecut eje 
			WHERE eje.empresa = pEmpresa
			AND eje.ejecutivo = cUsuarioAlta;
			
			SELECT LIMIT 1 NVL(eje.nombre,""),aut.fecha_insert--Usuario que aperturo el crÃ©dito.
			INTO cNombrePromAutoriza,dtFechaCam
			FROM bdisolic:"informix".ss_autorizacion aut
			INNER JOIN bdinteg:"informix".si_ejecut eje ON eje.empresa = pEmpresa AND eje.ejecutivo = aut.ejecutivo_auto
			WHERE aut.empresa=pEmpresa 
			AND aut.num_solicitud=cNumSol
			AND aut.status_solicitud = "AP";
			
			IF SUBSTR(cNumSol,1,2)= "60" THEN
				SELECT monto_otorgado
				INTO mMonto_aut
				FROM bdicred:"informix".sd_maesdos
				WHERE empresa=pEmpresa and num_credito=cNumSol;
				
				SELECT LIMIT 1 NVL(eje.nombre,""),NVL(eje2.nombre,"")--Usuario que aperturo el crÃ©dito.
				INTO cNombrePromEntrega,cNombrePromActiva
				FROM "informix".sd_tarjeta tar
				INNER JOIN "informix".bitacora_activacion act ON (act.numtarjeta =tar.num_tarjeta)
				LEFT JOIN bdinteg:"informix".si_ejecut eje ON (eje.empresa = '001' AND eje.ejecutivo = act.no_empleado_asigna)
				LEFT JOIN bdinteg:"informix".si_ejecut eje2 ON (eje2.empresa = '001' AND eje2.ejecutivo = act.no_empleado_activa)
				WHERE tar.empresa=pEmpresa 
				AND tar.num_credito=cNumSol
				AND tar.secuencia ='1';
			
			END IF;
			IF SUBSTR(cNumSol,1,2)= "65" THEN
				SELECT LIMIT 1 NVL(eje.nombre,"")
				INTO cNombrePromEntrega
				FROM bdinteg:"informix".si_adiccoppel cop
				LEFT JOIN bdinteg:"informix".si_ejecut eje ON (eje.empresa = '001' AND eje.ejecutivo = cop.user_insert)
				WHERE numcte =cNumcte
				AND secuencia = 1
			    AND tipotar ='1';				
			END IF;
			
		END IF;

		
		
		
		
	FOREACH
	
		SELECT NVL(nombre_ref, "" ) , parentesco, NVL(telefono_ref, "") ,numcte_ref
			INTO cNombre,cParentesco, cTelRef,cNumcteRef
		FROM bdisolic:"informix".ss_refpersonales 
		WHERE num_solicitud  = cNumSol				
		
		 IF cParentesco = "E" THEN
			SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
				INTO cNomRef1
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = '001'
			AND numcte = cNumcteRef;
			--Obtencion de telefonos de las referencias
			
		    --Si el nombre lo trae vacio es en los casos en que el cliente se fusiono y es necesario obtener la informacion de las tablas de fusion de clientes
			
			IF NVL(cNomRef1,'') = '' THEN
				SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)
					INTO cNomRef1
				FROM bdinteg:"informix".si_fuscliente
				WHERE empresa = '001'
				AND numcte = cNumcteRef;
				--se cambia el numero de cliente por el cual se fusiono
				FOREACH 
					SELECT telefono,tipo_tel
						INTO cTel,sTipoTel						
					FROM bdinteg:"informix".si_fustelefonos
					WHERE empresa = '001'
					AND numcte = cNumcteRef
					AND tipo_tel IN (1,2,3)		
					AND status_tel = 'A'
					
					
					IF sTipoTel = 1 THEN
						LET cTelefonotrabajoRef1 =cTel;				
					ELIF sTipoTel = 2 THEN
						LET cTelefonocelularRef1 = cTel;				
					ELIF sTipoTel = 3 THEN
						LET cTelefonooficinaRef1 = cTel;
					END IF;	
					
				END FOREACH
			ELSE

				FOREACH 
					SELECT telefono,tipo_tel
						INTO cTel,sTipoTel
					FROM bdinteg:"informix".si_telefonos_actual a	 
					WHERE a.empresa = '001' 
					AND a.numcte = cNumcteRef 
					AND a.tipo_tel IN (1,2,3)		
					AND a.status_tel = 'A'
					
					IF sTipoTel = 1 THEN
						LET cTelefonotrabajoRef1 =cTel;				
					ELIF sTipoTel = 2 THEN
						LET cTelefonocelularRef1 = cTel;				
					ELIF sTipoTel = 3 THEN
						LET cTelefonooficinaRef1 = cTel;
					END IF;				
			END FOREACH;
			END IF
			
			
		 END IF;
		 IF cNumcteRef = "R1" AND  cParentesco <> "E" THEN
			LET cNomRef1 = cNombre;			
			LET cTelefonotrabajoRef1= cTelRef;
		 ELIF cNumcteRef <> "R1" AND  cParentesco <> "E" THEN
			LET cNomRef2 = cNombre;
			LET cTelefonotrabajoRef2= cTelRef;
		 END IF

	END FOREACH;     		
	
		RETURN cCod_ret, cMen_ret,NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
         NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,""),NVL(cNomRef1,""),NVL(cTelefonotrabajoRef1,""),NVL(cTelefonocelularRef1,""),NVL(cTelefonooficinaRef1,""),NVL(cNomRef2,""),NVL(cTelefonotrabajoRef2,""),NVL(cTelefonocelularRef2,""),NVL(cTelefonooficinaRef2,"") WITH RESUME;	
        
		
		
		LET cTelCasa = "";
		LET cTelCel = "";
		LET cTelOfi = "";
		LET mMonto_aut=0;		
		LET  cNomRef1 = "";
		LET  cNomRef2 = "";
		LET  cTelefonotrabajoRef1 = "";
		LET  cTelefonocelularRef1 = "";
		LET  cTelefonooficinaRef1 = "";
		LET  cTelefonotrabajoRef2 = "";
		LET  cTelefonocelularRef2 = "";
		LET  cTelefonooficinaRef2 = "";
		LET cNombrePromAlta = "";
		LET cNombrePromAutoriza = "";
		LET cNombrePromEntrega = "";
		LET cNombrePromActiva = "";
		LET  iSecuencia = 0;
		LET  iSegundaref = 0;
		LET icontador = 1;		
		
		
		END FOREACH;
		
    	IF icontador =0 THEN
		 LET  cCod_ret = '00005';
		 LET cMen_ret = 'NO EXISTE INFORMACION';
		 RETURN cCod_ret,cMen_ret, NVL(cNumSol,""), NVL(cNumcte,""), NVL(dtFechaSol,DATE(1)), NVL(cNomCte,""),
         NVL(cStatus,""), NVL(mMonto,0), NVL(mMonto_aut,0), NVL(dtFechaCam,DATE(1)),NVL(cNombrePromAlta,""),NVL(cNombrePromAutoriza,""),NVL(cNombrePromEntrega,""),NVL(cNombrePromActiva,""),NVL(cTelCasa,""),NVL(cTelCel,""),NVL(cTelOfi,""),NVL(cSucursal,"") ,'','','','','','','','';

		END IF;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para ObtenciÃ³n de datos para el reporte de solicitudes para el area de auditoria.',
'AUTOR: JesÃºs Manuel Aguilar Heredia',
'BD: bdicred ',
'FECHA: FEBERO 2014',
'VERSION: 20140217.1735';

CREATE PROCEDURE "informix".sp_rep_clientes_mora0a1(pEmpresa CHAR(3))

RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;

--GEV Octubre 2014.Reporte de cuentas que pasan de mora 0 a mora 1.

DEFINE pproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE dFechaHoy        DATE;
DEFINE dtFechaFin       DATE;
DEFINE sql_err      	INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(80);
DEFINE pCod_ret         CHAR(6); 
DEFINE pMensaje      	CHAR(80);
DEFINE cRutaArch        CHAR(100);
DEFINE cNomArchivo      CHAR(100);
DEFINE cNomArch         CHAR(100);
DEFINE cNomArch1        CHAR(100);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(2500);
DEFINE cSQL1            CHAR(500);
DEFINE cSQL2            CHAR(1500);
DEFINE cSQL3            CHAR(500);
DEFINE cNum_cte         CHAR(20);
DEFINE cNum_cred        CHAR(20);
DEFINE cNumTel          CHAR(13);
DEFINE sPaso			SMALLINT;
DEFINE cdelimitador         CHAR(1);
DEFINE cNum_mes         CHAR(2);
DEFINE cNum_anio        CHAR(4);
DEFINE cFecha_corte DATE;
DEFINE cFecha_anterior DATE;

--SET DEBUG FILE TO "/INFORMIXDUMP/sp_rep_clientes_mora0a1.out";
--TRACE ON;

LET pproceso        = '3001';
LET cCod_RetIB      = '000000';
LET dFechaHoy       = DATE(0);
LET pMensaje     = 'PROCESO EXITOSO';
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = "";
LET pCod_ret         = '000000';
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cNomArch        = '';
LET cNomArch1       = '';
LET cNomArchEjecSql = '';
LET cSQL            = '';
LET cSQL1           = '';
LET cSQL2           = '';
LET cSQL3           = '';
LET cNum_cte        = '';
LET cNum_cred       = '';
LET cNumTel         = '';
LET sPaso           = 0;
LET cdelimitador            = "";
LET cNum_mes        = '';
LET cNum_anio       = '';
LET cFecha_corte = DATE(0);
LET cFecha_anterior = DATE(0);


BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
	LET pCod_ret = sql_err;
	LET pMensaje = error_info;
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '02')
	Returning cCod_RetIB;
	
		RETURN pCod_ret,pMensaje;
	END EXCEPTION;
	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '01')
	Returning cCod_RetIB;
	
	--select fecha_hoy, fecha_hoy - 1 units month into dFechaHoy, dFechaanterior from bdicred:sd_fechas where empresa = '001';
	
	select fecha_hoy into dFechaHoy from bdicred:sd_fechas where empresa = '001';
	
	--LET cNum_dia = lpad(day(dFechaHoy),2,'0');
    LET cNum_mes =  lpad(month(dFechaHoy),2,'0');
    LET cNum_anio = lpad(year(dFechaHoy),4,'0');
    LET cNum_anio = substr(year(dFechaHoy),3,2);
	LET cFecha_corte =mdy(month(dFechaHoy),'20',year(dFechaHoy));
	LET cFecha_anterior = cFecha_corte - 1 units month;
	
	select trim(valor_alfabetico) into cdelimitador 
		from bdicred:"informix".sd_param_campania where empresa = pempresa and tipo_campania = 61 
	and grupo_parametro = 'ARCHIVOSEP' and num_parametro = 336;
	
	
	select valor_alfabetico into cRutaArch 
		from bdicred:sd_param_campania where tipo_campania = 50 and grupo_parametro = 'CAT_PROMOS' 
	and num_parametro = 2;

	/*select num_credito  from bdicred:sd_maesdoshist where fecha = mdy('06','20','2014') and empresa = '001'
	and mto_fin_ven_trasp = 0
	into temp CreditosVigentes with no log;*/

	select a.num_credito,a.mto_fin_ven_trasp  from bdicred:sd_maesdoshist a where a.fecha = cFecha_corte and a.empresa = '001'
	and a.mto_fin_ven_trasp = 1
	and a.num_credito in (select b.num_credito  from bdicred:sd_maesdoshist b where b.fecha = cFecha_anterior and b.empresa = '001'
	and b.mto_fin_ven_trasp = 0)
	into temp CreditosMora1 with no log;
	
	insert into CreditosMora1
	select c.num_credito,c.mto_fin_ven_trasp  
	from bdicred:sd_maesdoshist c where c.fecha = cFecha_corte and c.empresa = '001'
	and c.mto_fin_ven_trasp > 0
	and c.num_credito in ( select d.num_credito from bdicred:sd_clientes_mora_mensual d 
	 where d.fecha_corte = cFecha_anterior 
	and d.mora > 0)	;
	--into temp CreditosMora2 with no log;
		

	--drop table ClientesCiudadMora1;
	select b.numcte  , a.num_credito,  d.numerociudad, a.mto_fin_ven_trasp
	from CreditosMora1 a, bdicred:sd_maecred b , bdinteg:si_direcciones_actual d
	where a.num_credito = b.num_credito 
	  and b.numcte = d.numcte 
	  and d.tipo_dir = 1
	  and d.numerociudad in ( 286,42,41,186,93,40,64,163,319,24,32,174,67,303,5656,106,170,9)
	into temp ClientesCiudadMora1 with no log;

	insert into "informix".sd_clientes_mora_mensual
	select m1.*, cFecha_corte, (select apell_paterno from bdinteg:si_cliente where numcte = m1.numcte), 
	(  monto_vencido + mto_venc_trasp + moratorio + interes_iva +mensualidad_actual ) sdo_tot_liquid, 
	(select max(telefono) from bdinteg:si_telefonos_actual where tipo_tel = 2 and numcte = m1.numcte  and cofetel = 'V'),
	(select correo_elec from bdinteg:si_correos 
		 where numcte = m1.numcte and secuencia = (select max(secuencia) from bdinteg:si_correos where numcte = m1.numcte   )  )
	from ClientesCiudadMora1 m1, bdicred:sd_sdos_cartera_linea lin
	where m1.num_credito = lin.num_credito;
	

--- Genera archivo para clientes con plastico vencido
	
    LET cNomArch1 =  'Clientes_Mora0a1'|| TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
    LET cNomArch  =  'Clientes_Mora0a1_'|| TRIM(cNum_mes) || TRIM(cNum_anio) || '.txt';
    LET cNomArchEjecSql = 'Rep_clientes_mora.sql';

    LET cSQL = '';
	LET cSQL = ' echo "NÃºmero_de_cliente'|| cdelimitador ||'NÃºmero_de_crÃ©dito'|| cdelimitador ||'NÃºmero_de_ciudad'|| cdelimitador ||'Mora'|| cdelimitador ||
	'Fecha_corte'|| cdelimitador ||'Apellido_paterno'|| cdelimitador ||'Saldo'|| cdelimitador ||
	'NÃºmero_de_celular'|| cdelimitador ||'DirecciÃ³n_de_e-mail'|| cdelimitador ||'"> ' || TRIM(cRutaArch) || TRIM(cNomArch);
	SYSTEM cSQL;

	LET cSQL1 = '';
    LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' DELIMITER ' || ''''|| cdelimitador || ''''||'';

    LET cSQL2 = ''; 
    LET cSQL2 = ' SELECT * FROM "informix".sd_clientes_mora_mensual where fecha_corte = '''||cFecha_corte||'''';
             
    LET cSQL3 = '">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
    SYSTEM cSQL;

    LET cSQL = 'chmod 777 '|| TRIM(cRutaArch)|| TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = '';
    LET cSQL = "sed 's/;$//g' "|| TRIM(cRutaArch) || TRIM(cNomArch1) || " >> " || TRIM(cRutaArch) || TRIM(cNomArch);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArch1) || ' ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;			
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '03')
		Returning cCod_RetIB;

	RETURN pCod_ret,pMensaje;

END
END PROCEDURE;