CREATE PROCEDURE "informix".sp_obtiene_productos_opt(pEmpresa CHAR(3), pSucursal CHAR(4), pEjecutivo CHAR(8), pPuesto_local CHAR(2), pNumcte CHAR(20), 	
												 pCoppel CHAR (1), pPrecalCoppel CHAR(1), pPrecalBco CHAR(1), pDigiDomicilio CHAR(1), pIdentificacion CHAR(1),
												 pOfertaProdCred CHAR(1), pAlta CHAR(1), pUso Integer)	
	RETURNING 	CHAR(6), 
				CHAR(4), 
				CHAR(1), 
				CHAR(40),
				CHAR(2); 


	-- Declaracion de variables
	DEFINE cdescripcion     	VARCHAR(60);
	DEFINE cPrioridad       	CHAR (2);
	DEFINE cProdCop         	CHAR(4);
	DEFINE cprod_final      	CHAR(4);
	DEFINE cnomcte          	CHAR(104);
	DEFINE cedadcte         	SMALLINT;
	DEFINE sql_err          	INTEGER;
	DEFINE isam_err         	INTEGER;
	DEFINE error_info       	VARCHAR(60);
	DEFINE CodRet           	CHAR(6);
	DEFINE cExiste          	CHAR(1);
	DEFINE cSucCajaUnica    	CHAR(1);
	DEFINE cDigiDom         	CHAR(1);
	DEFINE ProdActual       	CHAR(20);
	DEFINE cStatus_sol      	CHAR(2);
	DEFINE cSolcred_tramite 	CHAR(1);
	DEFINE sTotal_productos 	SMALLINT;
	DEFINE cNo_ofrecer      	CHAR(1);
	DEFINE cSolcred_tramite_cop CHAR(1);
	DEFINE cTpSolicitudAct  	CHAR(1);
	DEFINE cTpSolicitudOfr  	CHAR(1);
	DEFINE solApert  			CHAR(1);
	DEFINE cCodret          	CHAR(3);
	--
	DEFINE vdoccuantos      	INTEGER; 
	DEFINE cPuesto          	CHAR(3);
	--
	DEFINE dFechaAlta			DATE;
	DEFINE dFechaHoy			DATE;
	DEFINE dEdadAnioMes			CHAR(5);
	DEFINE dFechaNac			DATE;
	DEFINE iMeses				INTEGER;
	DEFINE dFechaValida			DATE;
	DEFINE cOfertar				CHAR(1);
	DEFINE vactiva_insert   	SMALLINT;
	DEFINE cSexo   				CHAR(1);
	DEFINE iIdentificacion  	INTEGER;
	DEFINE iPrestamosActivos  	INTEGER;
	DEFINE iBanderaInserta  	INTEGER;
	DEFINE solApertPP  			CHAR(1);
	DEFINE solApertRTCPS		CHAR(1);
	DEFINE cStatus_cred  		CHAR(2);
	DEFINE cNum_credito  		CHAR(20);
	DEFINE cPerfilProm 			CHAR(3);
	DEFINE cPerfilActivo 		CHAR(1);
	DEFINE cStatus_cta 		    CHAR(1);
	DEFINE cOfertaNomina		CHAR(1);
	DEFINE cCliente             CHAR(20);
	DEFINE cCteProspecto		CHAR(1);
	-- BCPL Cliente Prospecto Tipo 3
	DEFINE cTipoSol				CHAR(1);
	DEFINE cCteProsp			CHAR(20);
	DEFINE dFechaRespOSCalle	DATE;
	DEFINE cClave				CHAR(1);
	DEFINE cNumsolOs			CHAR(20);
	DEFINE iDiasTrans			INTEGER;
	DEFINE cProductoOfrecer		CHAR(4);
	DEFINE siDiasVigencia		SMALLINT;
	DEFINE inumpPrestamos       SMALLINT;
	DEFINE cStatusSolic       	CHAR(02);
	DEFINE dFechaInsert       	DATE;
	DEFINE iDiasRechazo       	INTEGER;
	DEFINE cVar1       			CHAR(6);
	DEFINE cVar2       			CHAR(20);
	DEFINE cnum_solicitud 		CHAR(20);
	
	
	DEFINE Codret2                   CHAR(6);
	DEFINE iNum_periodos            INTEGER;
	DEFINE dtFecha_cuota            DATE;
	DEFINE dSdo_inicial             MONEY(14,2);
	DEFINE dPago_mensual            MONEY(14,2);
	DEFINE dMto_Interes             MONEY(14,2);
	DEFINE dIva_interes             MONEY(14,2);
	DEFINE dCapital                 MONEY(14,2);
	DEFINE dSdo_final               MONEY(14,2);
	DEFINE sDias_periodo            SMALLINT;
	DEFINE v_diaspromedio           DECIMAL(14,2);
	DEFINE v_salariomin             DECIMAL(14,2);
	DEFINE dMto_min                 DECIMAL(18,2);
	DEFINE dMto_max                 DECIMAL(18,2);		
	DEFINE dtFecha_Aper		        DATE;
	DEFINE cNumMesesPagos           CHAR(3);
	DEFINE iPlazoMax                INTEGER;
	DEFINE cnum_solicitudAux        CHAR(20);
	DEFINE v_capacidad              MONEY(14,2);
	DEFINE v_limite_inferior        DECIMAL(14,2);
	DEFINE v_grupo                  char(01); 
	DEFINE cRFC					CHAR(13);
	DEFINE cCodigoRet 			CHAR(6);
	DEFINE cFechaUltimoPago 	CHAR(13); 
	DEFINE cPrestamoAutorizado 	CHAR(1); 
	DEFINE iMontoAutorizado 	INT8; 
	DEFINE iReprestamo 			INT8; 
	
	DEFINE cSitEsp          	    INTEGER;
--Validacion IFE/INE
    DEFINE B_ife            char(01);
    DEFINE B_valida_ife     char(01);
--Validacion IFE/INE

--Validacion limite cuentas de captacion
	DEFINE cCodErr CHAR(3);
	DEFINE cNumCueCapt CHAR(2);
--Validacion limite cuentas de captacion
	--- Validacion Prestamo Flexible
	DEFINE solApertPPFlex  			CHAR(1);
--jom-26/11/2018
--Verificar que exista como empleado o como cliente Coppel
	DEFINE cTicket				   	CHAR(20); 
	DEFINE cEdo_proceso			   	CHAR(4); 
	DEFINE cNum_men				   	CHAR(3); 
        DEFINE cEmpresaHuella           CHAR(3);
--jom-26/11/2018
	---I---RQM 10 960 TDC GC
	DEFINE solApertTCGC		CHAR(1);
	DEFINE bProspecto		CHAR(1);
	DEFINE CodRetProsp     	CHAR(6);
	---F---RQM 10 960 TDC GC
    DEFINE iTotSolWeb       INTEGER;
	--RQI 23 559
	DEFINE solApertAP 		CHAR(1);
	DEFINE ssDiasVigencia	INTEGER;
	DEFINE iDiasTransApertura	INTEGER;
	--DEFINE solRT			CHAR(1); --comentada jom
    DEFINE cPPFlexCancelado CHAR(1);
	DEFINE cNumSolPPflex	CHAR(20);
	DEFINE pEmp 			CHAR(1);
	DEFINE cValorA CHAR(100);
	DEFINE cValorAa CHAR(100);
	DEFINE cValorMod CHAR(100);
	DEFINE sExiste SMALLINT;
	DEFINE NumcteRelacionado	CHAR(20);
	--RQM 06 806 CUB-CURP
	DEFINE cCurp 		CHAR(20);
	DEFINE cSituacion   CHAR(1);
	DEFINE cCausa       SMALLINT;
	DEFINE cNacionalidad CHAR(3); 
	DEFINE cValidaSitEsp SMALLINT;
	--RQM 10 1458
	DEFINE cMarcaCte		CHAR(1);
	
	--PRODUCTO 5000 
	DEFINE vCuenta          CHAR(20);
	DEFINE vProd			CHAR(2);
	DEFINE vCta_Prod        CHAR(20);
	
	-- Cuenta nomina
	DEFINE vProdComplatiblesCtaNomina 	VARCHAR(255);
	
	DEFINE cStatusSolicitudDud VARCHAR (2);
	DEFINE cNumSolicitudDud varchar(20);
	--RQM 06 818-2
	--DEFINE cActivaValSit109 SMALLINT;
	--DEFINE cSit113			SMALLINT;
	DEFINE iCteExento		INTEGER;
	DEFINE iSecuencia		INTEGER;
	
	-- Asignacion variables
	LET cdescripcion        	= "";
	LET cPrioridad          	= "";
	LET cProdCop            	= "";
	LET cprod_final         	= "";
	LET cnomcte             	= "";
	LET cedadcte            	= 0;
	LET sql_err             	= 0;
	LET isam_err            	= 0;
	LET error_info          	= "";
	LET CodRet              	= '000000';
	LET cExiste             	= "";
	LET cSucCajaUnica       	= "";
	LET cDigiDom            	= '0';
	LET ProdActual          	= "";
	LET cStatus_sol         	= "";
	LET cSolcred_tramite    	= "";
	LET sTotal_productos    	= 0;
	LET cNo_ofrecer         	= "";
	LET cSolcred_tramite_cop   	= "";
	LET cTpSolicitudAct     	= "";
	LET cTpSolicitudOfr     	= "";
	LET solApert     			= "";
	LET cCodret             	= "";
	--
	LET vdoccuantos      		= 0; 
	LET cPuesto             	= "";
	--
	LET dFechaAlta				= '';
	LET dFechaHoy				= '';
	LET iMeses					= 0;
	LET dFechaValida			= '';
	LET cOfertar				= 'N';
	LET vactiva_insert 			= 1;
	LET cSexo 					= "I";
	LET dEdadAnioMes        	= "";
	LET dFechaNac 				= MDY(1,1,1900);
	LET iIdentificacion 		= 0;
	LET iPrestamosActivos 		= 0;
	LET iBanderaInserta 		= 1;
	LET solApertPP 				= '0';
	LET solApertRTCPS 			= '0';
	LET cStatus_cred 			= '';
	LET cNum_credito 			= '';
	LET cPerfilProm 			= '';
	LET cPerfilActivo 			= '';
	LET cStatus_cta 			= '';
	LET cOfertaNomina			= '0';
	LET cCliente                = '';
	LET cCteProspecto			= '';
	-- BCPL Cliente Prospecto Tipo 3
	LET cTipoSol				= '';
	LET cCteProsp				= '';
	LET dFechaRespOSCalle		= MDY(1,1,1900);
	LET cClave					= '';
	LET cNumsolOs				= '';
	LET iDiasTrans				= 0;
	LET cProductoOfrecer		= '';
	LET siDiasVigencia			= 0;
	LET inumpPrestamos          = 0;
	LET cStatusSolic       		= '';
	LET dFechaInsert       		= '';
	LET iDiasRechazo       		= 0;
	LET cVar1       	= '';
	LET cVar2       = '';
	LET cnum_solicitud 			= '';
	LET cnum_solicitudAux 			= '';
	
	LET iNum_periodos           = 0;
	LET dtFecha_cuota           = DATE(1);
	LET dSdo_inicial            = 0;
	LET dPago_mensual           = 0;
	LET dMto_Interes            = 0;
	LET dIva_interes            = 0;
	LET dCapital                = 0;
	LET dSdo_final              = 0;
	LET sDias_periodo           = 0;
	LET v_diaspromedio 			=0;
	LET v_salariomin 			=0;
	LET dMto_min                = 0;
	LET dMto_max                = 0;
	LET Codret2                 = "000000";
	LET dtFecha_Aper            = DATE(1);
	LET v_capacidad             = 0;
	LET iPlazoMax               = 0;
	LET v_limite_inferior       = 0;
	LET v_grupo                 = "";
	LET cRFC =""; 
	LET cCodigoRet ="";
	LET cFechaUltimoPago =""; 
	LET cPrestamoAutorizado =""; 
	LET iMontoAutorizado ="";
	LET iReprestamo ="";
	LET cSitEsp           		= 0;
--Validacion IFE/INE
    LET B_ife                   = '';
    LET B_valida_ife            = '';
--Validacion IFE/INE

--Validacion limite cuentas de captacion
	LET cCodErr = '000';
	LET cNumCueCapt = '0';	
--Validacion limite cuentas de captacion
	---Validacion Prestamo Flexible
	LET solApertPPFlex = '0';
	---I---RQM 10 960 TDC GC
	LET solApertTCGC = '0';
	---F---RQM 10 960 TDC GC
--jom-26/11/2018
--Verificar que exista como empleado o como cliente Coppel
    LET cTicket	       = '';
	LET cEdo_proceso   = '';
	LET cNum_men       = '';
        LET cEmpresaHuella = '';
		
	LET bProspecto	   ='0';
	LET CodRetProsp    ='000000';
--jom-26/11/2018
    LET iTotSolWeb     =0;

	LET	cValorA  = ''; 
	LET	cValorAa  = '';	 
	LET sExiste = 0;
	--RQI 23 559
	LET solApertAP		= '0';
	LET ssDiasVigencia	= 0;
	LET iDiasTransApertura	= 0;
	--LET solRT			= '0'; --comentada jom
    LET  cPPFlexCancelado  = ""; --'0'; 
	LET cNumSolPPflex = '';
	LET pEmp = '';
	LET NumcteRelacionado = '';
	--RQM 06 806 CUB-CURP 
	LET cCurp        	= "";
	LET cSituacion      = "";
	LET cCausa          = "";
	LET cNacionalidad   = "";
	LET cValidaSitEsp   = 0;
	--RQM 10 1458
	LET  cMarcaCte  = "";
	
	--PRODUCTO 5000
	LET vCuenta   = '';
	LET vProd     = '';
	LET vCta_Prod  = '';
	
	-- Cuenta nomina
	LET vProdComplatiblesCtaNomina  = '';
	
	
	LET cStatusSolicitudDud = '';
	LET  cNumSolicitudDud  = '';
	--RQM 06 818-2
	--LET cActivaValSit109   = 0;
	--LET cSit113			   = 0;
	LET iCteExento = 0;
	LET iSecuencia = 0;
	
	BEGIN
		ON EXCEPTION SET sql_err, isam_err, error_info
			DELETE FROM bdisolic:"informix".ss_productos_ofrecer WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo;
			LET CodRet = sql_err;
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END EXCEPTION;


	--SET DEBUG FILE TO "/tmp/anj/sp_obtiene_productos_opt.sql";
	--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		--SELECT valor INTO cActivaValSit109 FROM bdinteg:"informix".si_param WHERE cod_param = '504';
		FOREACH
			SELECT valor INTO cValorA FROM bdinteg:"informix".si_param where cod_param in('467','468')--P110, P111				
			LET cValorAa = SUBSTR(cValorA,2,4);
			
			SELECT COUNT(NUMCTE) INTO sExiste FROM bdisitesp:"informix".se_ctessitespcte WHERE CAUSA IN( cValorAa,'109','113') AND situacion='P' AND NUMCTE= pNumcte; 
			IF sExiste > 0 THEN									
				LET CodRet  = "00005";
					RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
			END IF;
		END FOREACH

		LET sExiste = 0;
		
		SELECT valor INTO cValorMod FROM bdinteg:"informix".si_param where cod_param ='466';
		LET cValorMod = SUBSTR(cValorMod,2,4);
		
---RGH 18122018
        IF pDigiDomicilio = '0' THEN
			LET cDigiDom = '1';
		END IF;
		
        IF pIdentificacion <> '1' THEN
            LET CodRet = "000001";
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;            
---RGH 18122018
	 select NVL(count(numcte),0) into iTotSolWeb from bdisolic:"informix".ss_prospecteo_solicitudes
        where numcte=pNumcte
            and canal_sol=4
                and status_solicitud not in('CN','AP','AN','RT')
				AND estatus <> 'F';

        DELETE FROM bdisolic:"informix".ss_productos_ofrecer WHERE cliente = pNumcte;
		IF iTotSolWeb > 0 THEN 
			FOREACH 
				select ps.num_producto, p.tp_solicitud, d.nombre_prod, 1 
				INTO cprod_final,cTpSolicitudOfr, cdescripcion , cPrioridad
				from 
				bdisolic:"informix".ss_prospecteo_solicitudes ps 
				inner join  bdisolic:"informix".ss_solic_producto  p on ps.num_producto = p.num_producto
				inner join bdicred:"informix".sd_definicion d on ps.num_producto = d.num_producto
				where numcte=pNumcte
				and canal_sol=4
				and status_solicitud not in('CN','AP','AN','RT')
				AND estatus <> 'F'
				
				RETURN CodRetProsp, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'') WITH resume;
				
			END FOREACH
			RETURN;
		END IF;
		IF pSucursal <> '8503' AND iTotSolWeb=0 THEN	--- Sucursal WEB, omitir flujo de prospecteo para solicitudes WEB
		   --EJECUTANDO EL SP DE PROSPECTEO--
			FOREACH
				execute procedure bdisolic:"informix".sp_obtiene_productos_prospecteo(pEmpresa, pSucursal, pEjecutivo, pPuesto_local, pNumcte, pCoppel, pPrecalCoppel, pPrecalBco, pDigiDomicilio, pIdentificacion, pOfertaProdCred)
				INTO CodRetProsp, cprod_final, cTpSolicitudOfr, cdescripcion, cPrioridad

				LET bProspecto = CodRetProsp;
				
				IF cprod_final = '6001' THEN
					LET cdescripcion = 'TARJETA CREDITO BANCOPPEL';
				END IF;
				
				if CodRetProsp::INTEGER = 0 then
					LET bProspecto = 'A';
					RETURN CodRetProsp, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'')  WITH resume;
				end if;    
			END FOREACH
		   --FIN EJECUCION PROSPECTEO 	
	   END IF;
		
	--EJECUTANDO EL SP DE WEB--
    /* ---Para corregir ofertamiento de autosolicitueds 22 jul 22 IPCB 
     IF iTotSolWeb>0 THEN                  
                DELETE FROM bdisolic:"informix".ss_productos_ofrecer WHERE cliente = pNumcte;
                FOREACH
                    execute procedure bdisolic:sp_obtiene_productos_solweb(pEmpresa, pSucursal, pEjecutivo, pPuesto_local, pNumcte, pCoppel, pPrecalCoppel, pPrecalBco, pDigiDomicilio, pIdentificacion, pOfertaProdCred)
                    INTO CodRetProsp, cprod_final, cTpSolicitudOfr, cdescripcion, cPrioridad
    
                    LET bProspecto = 'A';
					
					IF cprod_final = '6001' THEN
						LET cdescripcion = 'TARJETA CREDITO BANCOPPEL';
					END IF;
					
                    if CodRetProsp::INTEGER = 0 then
                        RETURN CodRetProsp, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'')  WITH resume;
                    end if;   
                
                END FOREACH
        --FIN EJECUCION WEB	
	END IF;	*/---Para corregir ofertamiento de autosolicitueds 22 jul 22 IPCB 
		
	IF bProspecto = '0' THEN--PROSPECTEO	25/10/2019		

		SELECT valor::INTEGER INTO iPrestamosActivos FROM bdisolic:"informix".ss_param WHERE secuencia = '365' AND empresa = '001';
		--obtiene la edad del cliente
		EXECUTE PROCEDURE bdinteg:"informix".consedadcte(pEmpresa, pNumcte)
		INTO cCodRet, cnomcte, cedadcte;

		IF NVL(cedadcte,"") = "" THEN
			LET CodRet = '000002';
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;
		
		SELECT puesto
		INTO cPuesto
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo = pEjecutivo;

		IF NVL(cPuesto,"") = "" THEN
				IF (SELECT count(ejecutivo )				
					FROM bdinteg:"informix".si_usuario_movil
					WHERE ejecutivo = pEjecutivo) = 0  THEN
					LET CodRet = '000003';
				END IF;				
			
		ELSE
			--FECHA: 06-04-2011
			--IF cPuesto <> '001' AND  cPuesto <>'003' THEN
			IF NOT EXISTS(SELECT perfilprom FROM  bdinteg:"informix".si_perfilproductos WHERE empresa = pEmpresa AND puesto = cPuesto AND activo = '1') THEN
				LET CodRet = '000012';
			END IF;
		END IF;

		IF CodRet = '000003'OR CodRet = '000012' THEN
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;


---RGH 18122018
        IF pDigiDomicilio = '0' THEN
			LET cDigiDom = '1';
		END IF;
		
        IF pIdentificacion <> '1' THEN
            LET CodRet = "000001";
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;            
---RGH 18122018

		--dsb-17/04/2013
		--Verificar si no cuenta con una relacion coppel en la tabla si_relacion_ctebcplcpl
		--IF pCoppel = '0' THEN
			SELECT NVL(cliente,''), NVL(cliente_prosp,'')
			INTO cCliente, cCteProspecto
			FROM bdinteg:"informix".si_relacion_ctebcplcpl
			WHERE empresa = pEmpresa AND numcte_banco = pNumcte;
			IF cCliente <> '' AND cCteProspecto <> '1' THEN
				LET pCoppel = '1';
            ELSE
                SELECT ticket 
                INTO cTicket
                FROM bdinteg:"informix".si_huella_linea  -- SE OBTIENE EL TICKET CON EL NUM. DE CLIENTE
                WHERE numcte = pNumcte;
		--jom-26/11/2018
		--Verificar que exista como empleado o como cliente Coppel
                IF NVL(cTicket,"") = '' THEN -- SI NO SE ENCUENTRA EN LA si_huella_linea SE BUSCA EN si_huella_linea_hist
                    SELECT ticket 
                    INTO cTicket
                    FROM bdinteg:"informix".si_huella_linea_hist a   
                    WHERE numcte = pNumcte
                        AND fecha_consulta = (SELECT MAX(fecha_consulta)
                                              FROM bdinteg:"informix".si_huella_linea_hist b 
                                              WHERE numcte = pNumcte)
                        AND secuencia = (SELECT MAX(secuencia)
                                         FROM bdinteg:"informix".si_huella_linea_hist c 
                                         WHERE  numcte = pNumcte);
                END IF;
                
                IF NVL(cTicket,"") <> '' THEN		-- Coppel
                    SELECT LIMIT 1 estado_proceso, num_mensaje, empresa
                     INTO cEdo_proceso, cNum_men, cEmpresaHuella
                     FROM bdinteg:"informix".si_huella_linea_resultado 
                     WHERE ticket = cTicket
                         AND estado_proceso = '2'
                         AND empresa IN (4)
                         AND num_mensaje = "602";
						 
					 IF nvl(cNum_Men,'') = '' THEN
						 SELECT LIMIT 1 estado_proceso, num_mensaje, empresa 
						 INTO cEdo_proceso, cNum_men, cEmpresaHuella
						 FROM bdinteg:"informix".si_huella_linea_resultado_hist 
						 WHERE ticket = cTicket
					   	   AND estado_proceso = '2'
						   AND empresa IN (4)
						   AND num_mensaje = "602";
					 END IF;

                     IF NVL(cEdo_proceso,"") <> "" AND NVL(cNum_men,"") <> ""  AND 	NVL(cEmpresaHuella,"") <> "" THEN    
                        LET pCoppel = '1';
                     END IF;
                 END IF;  
				
				IF NVL(cTicket,"") <> '' THEN		-- Empleado
                     SELECT LIMIT 1 estado_proceso, num_mensaje, empresa
                     INTO cEdo_proceso, cNum_men, cEmpresaHuella
                     FROM bdinteg:"informix".si_huella_linea_resultado 
                     WHERE ticket = cTicket
                         AND estado_proceso = '2'
                         AND empresa IN (0,1,2,3)
                         AND num_mensaje = "602";

					--MACM RQM 101584 TDC INFINITE
					--Tabla para desmarcar a cliente como empleado capturado por mesa de control
					SELECT max(secuencia) INTO iSecuencia
					FROM bdisolic:"informix".ss_clientes_exentos_rgc 
					WHERE numcte = pNumcte;
					
					SELECT count(numcte) INTO iCteExento
					FROM bdisolic:"informix".ss_clientes_exentos_rgc 
					WHERE numcte = pNumcte and activo = 'S' and secuencia = iSecuencia;
					
                     IF NVL(cEdo_proceso,"") <> "" AND NVL(cNum_men,"") <> ""  AND 	NVL(cEmpresaHuella,"") <> "" AND iCteExento = 0 THEN    
                        LET pEmp = '1';
                     END IF;
                END IF;
                 
		--jom-26/11/2018
			END IF;
		--END IF;


		DELETE FROM bdisolic:"informix".ss_productos_ofrecer WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo;

		IF cDigiDom = '1' THEN
			FOREACH
				SELECT s.num_producto,s.tp_solicitud
				INTO cProdCop,cTpSolicitudOfr
				FROM bdisolic:"informix".ss_solic_producto s
				INNER JOIN bdinteg:"informix".si_prod_sucursal p ON (p.empresa = s.empresa AND p.num_producto = s.num_producto AND p.sucursal = pSucursal)
				INNER JOIN bdinteg:"informix".si_prod_ejecut e   ON (s.empresa = e.empresa AND s.num_producto = e.num_producto AND e.perfil = pPuesto_local)
				WHERE s.empresa = pEmpresa
				AND s.tp_solicitud = 'C'
				AND s.num_producto NOT IN (	SELECT num_producto
											FROM bdisolic:"informix".ss_solicitudes
											WHERE empresa= pEmpresa
											AND numcte = pNumcte
											AND status_solicitud IN("EA","EE","AT","AP","CC","OA","OS","BC","ST","CE","LC","MC","EC","PA","IN"))--JMAH RQM 09279 / RQM 18 023 CAX INC 25337

				INSERT INTO bdisolic:"informix".ss_productos_ofrecer (cliente,sucursal,ejecutivo,producto_ofr,tp_solicitud_ofr,aplica) VALUES (pNumcte,pSucursal,pEjecutivo,cProdCop,cTpSolicitudOfr,'S');
			END FOREACH
		ELSE
			--RQI 23 559 Obtiene los dias de vigencia
			SELECT valor::INTEGER INTO ssDiasVigencia 
			FROM bdisolic:"informix".ss_param 
			WHERE empresa= pEmpresa AND secuencia = '25';
			
			SELECT fecha_hoy
			INTO dFechaHoy
			FROM bdicred:"informix".sd_fechas
			WHERE empresa = pEmpresa;
		
			-- Obtiene los productos de captacion con los que actualmente cuenta el cliente, se modifica para que se inserte la fecha de alta de la cuenta de captacion
			FOREACH
				SELECT producto, noc.fecha_alta, status_cta, mae.cuenta
				INTO ProdActual, dFechaAlta, cStatus_cta,    vCta_Prod
				FROM bdicheq:"informix".sc_maechq mae
				INNER JOIN bdicheq:"informix".sc_maenoc noc ON (noc.cuenta = mae.cuenta)
				WHERE num_cte = pNumcte
				-- ofertar producto de inversion 
                AND producto <> '1100'

				IF ProdActual = "1300" AND cStatus_cta <> '2' THEN
					LET cOfertaNomina = '1'; -- NO OFERTE EL PRODUCTO 1300 DE NOMINA, YA QUE NO SE ENCUENTRA CANCELADO ACTUALMENTE
				END IF;
				--SI LA CUENTA FUE CONCENTRADA Y ENVIADA A LA BENEFICENCIA SE OBTIENE EL PRODUCTO ORGINAL
				IF  ProdActual = "5000" THEN 
				    SELECT FIRST 1 cuenta
					INTO           vCuenta
                    FROM   bdicheq:sc_maechq
                    WHERE  num_cte  = pNumcte
                    AND    producto = ProdActual
					AND    cuenta   = vCta_Prod;
					
                    -- SE OBTIENE EL PRODUCTO ORIGINAL
				    LET vProd      = SUBSTR(vCuenta,1,2);
                    LET ProdActual = DECODE( vProd, '10', '2000', '12', '1200', '13', '1300', '14', '1400', '15', '1500', '16', '1600', '17', '1700', '18', '1800', 
                                       '19', '1900', '22', '2200', '23', '2300', '24', '2400', '25', '2500', '26', '2600', '27', '2700', '28', '2800' );
				END IF;

				INSERT INTO bdisolic:"informix".ss_productos_ofrecer (cliente,sucursal,ejecutivo,producto_act,fecha_alta) VALUES (pNumcte,pSucursal,pEjecutivo,ProdActual,dFechaAlta);
			END FOREACH

-- Validacion ife/ine ini

            -- Valida identificacion presentada por el cliente IFE/INE

            IF EXISTS (select numcte from bdinteg:"informix".si_ctepf where numcte = pNumcte and  codidentifi = 'A') THEN
            -- Extrae bandera de validacion de IFE
                SELECT nvl(valor,'')
                  INTO B_valida_ife
                  FROM bdisolic:"informix".ss_param
                 WHERE empresa = pEmpresa
                   AND secuencia = 376;
            -- Valida IFE/INE
                IF (B_valida_ife = '1') THEN
                    select nvl(case when upper(resultado) = 'VERDADERO' then '1' else '0' end,'1')
                      into B_ife
                      from bdinteg:"informix".si_bitacora_ife 
                     where numcte = pNumcte and fecha = (select max(fecha) from bdinteg:"informix".si_bitacora_ife where numcte = pNumcte);

                    IF ( B_ife <> '1') THEN
                        LET cSolcred_tramite = '1'; -- No ofrecer productos Credito Banco
                        -- Registra mensaje en bitacora
                        INSERT INTO bdisolic:"informix".ss_bitacora_precal (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
                                                                            causa,motivo,tipo_rechazo,codret,mensaje,saldomuebles,saldoropa,saldoprestamos,causa_solicitud,vencidototalmuebles,
                                                                            vencidototalropa,vencidoprestamos,abonomuebles,abonoropa,abonoprestamos,puntualidad,grupo, saldototalaire, 
																			vencidototalaire, abonomensualaire, saldototalafiliados, vencidototalafiliados, abonomensualafiliados, 
																			saldototalreestructura, vencidototalreestructura, abonomensualreestructura, scorepuntualidad)
                        --VALUES (pEmpresa,today,'6001',pSucursal,cnomcte,pEjecutivo,'Validacion IFE/INE','VIF');
                        VALUES (pEmpresa,today,'6001',pSucursal,cnomcte,'','',pEjecutivo,'0','','0','0','B','','005','Validacion IFE/INE','0','0','0','VIF','0','0','0','0','0','0','','','0','0','0','0','0','0','0','0','0','0');
                    END IF;
                END IF;
            END IF;

-- Validacion ife/ine  FIN
			-- Obtiene los productos de credito con los que cuenta el cliente
			FOREACH
				SELECT num_producto,num_solicitud, status_solicitud, tipo_solicitud
				INTO ProdActual,cnum_solicitud, cStatus_sol,cTpSolicitudAct
				FROM bdisolic:"informix".ss_solicitudes
				WHERE empresa= pEmpresa
				AND numcte= pNumcte
				AND status_solicitud IN ("BC","CC","ST","EA","EE","OA","OS","CE","AT","AP","RT","LC","MC","EC","PA","IN") --JMA RQM 09279/RQM 18 023  CAX INC 25337
				GROUP BY 1,2,3,4

				LET vactiva_insert = 1;

				IF cStatus_sol = "AP" OR cStatus_sol = "RT" THEN
					IF cTpSolicitudAct IN ('T','P') THEN
						--RQI 23 559 validaciones de vigencia T o P en AP (solApert = '1', solApertPP = '1')
						IF cStatus_sol = "AP" and ProdActual <> '7800' THEN
							SELECT LIMIT 1 fecha_insert 
							INTO dFechaInsert
							FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud = cnum_solicitud
							AND status_solicitud = 'AP';
							
							--Calculamos los dias que tiene la solcitud en estatus AP.
							LET iDiasTransApertura = (dFechaHoy - dFechaInsert);

							--Si la soliclitud tiene 90 dias o menos, no se ofertara ningun credito de banco, excepto la TDC Coppel.
							IF iDiasTransApertura <= ssDiasVigencia THEN
								LET solApert = '1';
								LET solApertPP = '1';
								LET solApertAP = '1';
							END IF;
						
						END IF;
					
						IF cStatus_sol = "RT" AND cTpSolicitudAct = 'T' THEN
							LET solApert = '1';
							LET solApertPP = '1';
							IF ProdActual='7800' AND cStatus_sol = "RT" THEN
								LET cSolcred_tramite = '1';
							END IF
						ELIF cStatus_sol = "RT" AND cTpSolicitudAct = 'P' THEN
						--GJEVGJEV --RQM 10 713
						LET solApertRTCPS = '0';
						
						IF ProdActual IN ('6300','7600','7700') THEN
							IF  (
							select count(*) from bdisolic:"informix".ss_autorizacion where num_solicitud = cnum_solicitud
							AND status_solicitud = 'RT'
							AND causa_solicitud = 'CPS') > 0 THEN--capacidad de pago saturada							
							
								LET solApertRTCPS = '1';
								LET cnum_solicitudAux= cnum_solicitud;
							END IF;
							
						END IF;
						--GJEV FIN --RQM 10 713
						LET solApertPP = '1';
							
						END IF;	
						IF cTpSolicitudAct = 'T' THEN
							IF (SELECT COUNT(numcte) FROM bdicred:"informix".sd_maecred
								WHERE empresa = pEmpresa
								AND numcte = pNumcte
								AND status_cred NOT IN ('FC','FF')) > 0 THEN
								
								IF ProdActual ='7800' THEN
									LET solApert = '0';
								ELSE								
									LET solApert = '1';
								END If
								
							ELSE
								IF (SELECT COUNT(a.numcte) FROM bdicred:"informix".sd_maecredcrd a, bdisolic:"informix".ss_solic_producto b
									WHERE a.empresa = pEmpresa
									AND a.empresa = b.empresa
									AND a.num_producto = b.num_producto
									AND numcte = pNumcte
									AND tp_solicitud = 'R'
									AND status_cred <> 'FF') > 0 THEN
									LET solApert = '1';
								ELSE
									LET vactiva_insert = 0;
								END IF;
							END IF;
						END IF;
					ELSE
						IF cTpSolicitudAct = 'A' THEN
							IF (SELECT COUNT(a.numcte) FROM bdicred:"informix".sd_maecredcrd a, bdisolic:"informix".ss_solic_producto b
								WHERE a.empresa = pEmpresa
								AND a.empresa = b.empresa
								AND a.num_producto = b.num_producto
								AND numcte = pNumcte
								AND tp_solicitud = 'R'
								AND status_cred <> 'FF') = 0 THEN
								LET vactiva_insert = 0;
							END IF;
						-- * INC 24 006 (Valida cuando una solicitud esta en status_solicitud = 'AP' no permita oferta el producto
						--      de Tarjeta de Credito Coppel ya que el cliente ya tiene ese producto)
						ELIF cTpSolicitudAct = 'C' THEN
							LET cSolcred_tramite_cop = '1';
							LET vactiva_insert = 0;
						END IF;
					END IF;

						IF vactiva_insert = 1 THEN
							SELECT 1
							INTO cExiste
							FROM bdisolic:"informix".ss_productos_ofrecer
							WHERE cliente = pNumcte
							AND sucursal = pSucursal
							AND ejecutivo = pEjecutivo
							AND producto_act = ProdActual;

								IF NVL(cExiste,'') = '' THEN				
										INSERT INTO bdisolic:"informix".ss_productos_ofrecer (cliente,sucursal,ejecutivo,producto_act) VALUES (pNumcte,pSucursal,pEjecutivo,ProdActual);
								END IF;	
						END IF;
				ELSE
					IF cTpSolicitudAct = 'C' THEN
						IF cStatus_sol <> 'PA' THEN 
							LET cSolcred_tramite_cop = '1';
						END IF
					ELSE
						LET cSolcred_tramite = '1';
					END IF;
				END IF
			END FOREACH

			-- Verifica si el cliente presenta un credito en reestructura
			FOREACH
				SELECT num_producto
				INTO ProdActual
				FROM bdicred:"informix".sd_maecredcrd
				WHERE empresa = pEmpresa
				AND numcte = pNumcte
				AND status_CRED <> 'FF'
				AND num_producto NOT IN (SELECT num_producto 
										FROM bdisolic:"informix".ss_solic_producto
										WHERE tp_solicitud = 'P')

				INSERT INTO bdisolic:"informix".ss_productos_ofrecer(cliente,sucursal,ejecutivo,producto_act) VALUES (pNumcte,pSucursal,pEjecutivo,ProdActual);
			END FOREACH

			-- FMV 22-FEB-11 Verifica si el cliente presenta de Credito Activo, previo a la Solicitud
			FOREACH
				SELECT num_producto,status_cred,num_credito
				INTO ProdActual,cStatus_cred,cNum_credito  
				FROM bdicred:"informix".sd_maecred
				WHERE empresa = pEmpresa
				AND numcte = pNumcte
				AND status_cred NOT IN ('FC')
				AND num_producto NOT IN (SELECT producto_act FROM bdisolic:"informix".ss_productos_ofrecer WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo)

				IF cStatus_cred = "FF"  THEN ---JMAH 11/12/2012
					IF NOT EXISTS ( SELECT num_credito
									FROM bdicred:"informix".sd_cred_can
									WHERE empresa = pEmpresa
									AND num_credito= cNum_credito
									AND motivo_can ='FF2') THEN	
						LET iBanderaInserta =0;
					ELSE
						LET iBanderaInserta =1;
					END IF;
				ELSE
					LET iBanderaInserta =1;
				END IF;
				IF iBanderaInserta = 1 THEN
					INSERT INTO bdisolic:"informix".ss_productos_ofrecer(cliente,sucursal,ejecutivo,producto_act) VALUES (pNumcte,pSucursal,pEjecutivo,ProdActual);
				END IF;
			END FOREACH
			
			SELECT COUNT(num_credito)
			into solApertPPFlex
			FROM bdicred:"informix".sd_maecredcrd
			WHERE empresa = pEmpresa
			AND numcte = pNumcte
			AND num_producto IN ('6800','7100')
			AND status_cred IN ('AA','BA','BT','E1','E2','E3');
			
			IF(solApertPPFlex>0) THEN
				LET solApertPPFlex = '1';
			END IF;

			--RQI 23 559
			IF cprod_final = '6800' THEN
				SELECT limit 1 sd.num_credito INTO cNumSolPPflex --cPPFlexCancelado 
				FROM bdicred:"informix".sd_maecredcrd sd, bdicred:"informix".sd_linea_prestamo sdp
				WHERE sd.num_credito = sdp.num_credito
				AND sd.numcte = pNumcte
				AND sd.num_credito = sdp.num_credito
				AND sd.num_producto = '6800'
				AND fecha_cancela is not null and cancel_pf = '1';
				
				
				IF NVL(cNumSolPPflex,'') = '' THEN		
					LET solApertPPFlex = '1';
				END IF;
			END IF;

			-- FMV
			--JMAH
			-- AAME 20150303 RQM 10 550 Se agregan nuevos productos de prestamo, considerando que se limitaran al numero de prestamos activos que puede tener el cliente sobre prestamo personal actual (6300)  
			SELECT COUNT(num_credito)
            into inumpPrestamos
			FROM bdicred:"informix".sd_maecredcrd
			WHERE empresa = pEmpresa
			AND numcte = pNumcte
			AND num_producto IN ('6300','7600','7700','6800', '7100')
			AND status_cred IN ('AA','BA','BT','E1','E2','E3');

-- EM 2017/05/25
			
			SELECT RFC
				INTO cRFC
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pNumcte;
				
			IF cRFC <> "" THEN

				EXECUTE PROCEDURE bdisolic:"informix".sp_valida_cliente_coppel('3','',cRFC,'','','','','','','','','','','','','','','','','','','','','')
				INTO cCodigoRet, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo;
			
			ELSE
				LET cFechaUltimoPago = '1900-01-01';
				LET cPrestamoAutorizado = '0';
				LET iMontoAutorizado = '0';
				LET iRePrestamo = '0';
				LET cCodigoRet = '000000';	
			END IF;
	
            IF (inumpPrestamos >= iPrestamosActivos) THEN
				--se inserta en la bitacora_precal
                LET solApertPP ='1';
				INSERT INTO bdisolic:"informix".ss_bitacora_precal (empresa,fecha,producto,sucursal,nombre,ejecutivo,mensaje,causa_solicitud)
					VALUES (pEmpresa,today,'6300',pSucursal,cnomcte,pEjecutivo,'El Cliente cuenta con el tope maximo de Prestamos Personales permitidos','RFP',cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo);
			END IF;
			--JMAH
			--JOM VALIDA PRESTAMOS CON LA REGLA DE PAGO SOSTENIDO INI
            IF ( inumpPrestamos > 0 ) THEN
                select count(*) 
                into inumpPrestamos
                from bdicred:"informix".sd_amortiza_creditocrd a
                where empresa = pEmpresa
                  and num_credito = (select max(num_credito) from bdicred:"informix".sd_maecredcrd b
                                    where a.empresa = empresa
                                      and numcte = pNumcte
                                      and fecha_apertura = (select max(fecha_apertura) 
                                                              from bdicred:"informix".sd_maecredcrd 
                                                             where b.empresa = empresa 
                                                               and b.numcte = numcte 
                                                               and status_cred in ('AA','BA','BT','E1','E2','E3')))
                  and num_pago >= (select max(num_pago) from bdicred:"informix".sd_amortiza_creditocrd where a.empresa = empresa and a.num_credito = num_credito and capital_status <> '3') - 3
                  and capital_status = '5'
                  and capital_status_ant = '1';

                IF (inumpPrestamos < 3) THEN 
                    LET solApertPP ='1';
                    --se inserta en la bitacora_precal
                    INSERT INTO bdisolic:"informix".ss_bitacora_precal (empresa,fecha,producto,sucursal,nombre,ejecutivo,mensaje,causa_solicitud,fechaultimopago,prestamoautorizado,montoautorizado,represtamo)
                        VALUES (pEmpresa,today,'6300',pSucursal,cnomcte,pEjecutivo,'El cliente no cumple la regla de pago sostenido','RFP',cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo);
                END IF;
             END IF;
            --JOM VALIDA PRESTAMOS CON LA REGLA DE PAGO SOSTENIDO FIN

			SELECT COUNT(producto_act)
			INTO sTotal_productos
			FROM bdisolic:"informix".ss_productos_ofrecer
			WHERE cliente = pNumcte
			AND sucursal = pSucursal
			AND ejecutivo = pEjecutivo;

			-- Obtiene los productos que un cliente puede solicitar en base a los productos con los que cuenta
			IF sTotal_productos > 0 THEN
				FOREACH
					SELECT b.prod_ofrecer
					INTO cprod_final
					FROM bdisolic:"informix".ss_tramite_productos a
					INNER JOIN bdisolic:"informix".ss_tramite_productos_clasif b	ON (a.empresa = b.empresa AND a.clasificacion = b.clasificacion)
					INNER JOIN bdinteg:"informix".si_prod_sucursal p	ON (p.empresa = b.empresa AND p.sucursal = pSucursal AND p.num_producto = b.prod_ofrecer)
					INNER JOIN bdisolic:"informix".ss_productos_ofrecer c		ON (c.cliente = pNumcte AND c.sucursal = pSucursal AND c.ejecutivo = pEjecutivo AND a.prod_actual = c.producto_act)
					INNER JOIN bdinteg:"informix".si_prod_ejecut e		ON (b.empresa = e.empresa AND b.prod_ofrecer = e.num_producto AND e.perfil = pPuesto_local)
					AND a.empresa= pEmpresa
					AND (edad_min <= cedadcte AND edad_max >= cedadcte)
					AND a.sexo = cSexo --se agrega validacion del sexo
					AND a.prod_actual = c.producto_act
					AND NVL(restriccion_prod,'') NOT IN ( SELECT producto_act
														  FROM bdisolic:"informix".ss_productos_ofrecer
														  WHERE cliente    = pNumcte
														  AND sucursal   = pSucursal
														  AND ejecutivo  = pEjecutivo
														  AND producto_act IS NOT NULL)
					--                 AND b.prod_ofrecer NOT IN ( SELECT prod_ofrecer FROM "informix".ss_tramite_productos_clasif WHERE sistema='06' AND prod_ofrecer = b.prod_ofrecer
					--                 AND restriccion_prod = '6001' or restriccion_prod = '6600')
					SELECT tp_solicitud
					INTO cTpSolicitudOfr
					FROM bdisolic:"informix".ss_solic_producto
					WHERE num_producto = cprod_final;

					IF cTpSolicitudOfr IS NULL THEN
						LET cTpSolicitudOfr = 'D';
					END IF;

					IF cTpSolicitudOfr IN ('T','C') THEN
						SELECT 1
						INTO cNo_ofrecer
						FROM bdisolic:"informix".ss_productos_ofrecer
						WHERE cliente = pNumcte
						AND sucursal = pSucursal
						AND ejecutivo = pEjecutivo
						AND producto_act = cprod_final;
					END IF;

					IF NVL(cNo_ofrecer,'') <> '1' THEN
						SELECT 1
						INTO cExiste
						FROM bdisolic:"informix".ss_productos_ofrecer
						WHERE cliente = pNumcte
						AND sucursal = pSucursal
						AND ejecutivo = pEjecutivo
						AND producto_ofr = cprod_final;

						IF NVL(cExiste,'') = '' THEN
							INSERT INTO bdisolic:"informix".ss_productos_ofrecer (cliente,sucursal,ejecutivo,producto_ofr,tp_solicitud_ofr,aplica) VALUES (pNumcte,pSucursal,pEjecutivo,cprod_final,cTpSolicitudOfr,'S');
						END IF;
					END IF;
					LET cNo_ofrecer ="";
				END FOREACH
			ELSE

				FOREACH
					SELECT b.prod_ofrecer,NVL(tp_solicitud,"D")
					INTO cprod_final,cTpSolicitudOfr
					FROM bdisolic:"informix".ss_tramite_productos a
					INNER JOIN bdisolic:"informix".ss_tramite_productos_clasif b ON (a.empresa = b.empresa AND a.clasificacion = b.clasificacion)
					INNER JOIN bdinteg:"informix".si_prod_sucursal p	ON (p.empresa = a.empresa AND p.sucursal = pSucursal AND p.num_producto = b.prod_ofrecer)
					INNER JOIN bdinteg:"informix".si_prod_ejecut e		ON (b.empresa = e.empresa AND b.prod_ofrecer = e.num_producto AND e.perfil = pPuesto_local)
					LEFT JOIN bdisolic:"informix".ss_solic_producto c			ON (b.empresa = c.empresa AND b.prod_ofrecer = c.num_producto)
					WHERE a.empresa = pEmpresa
					AND (edad_min <= cedadcte AND edad_max >= cedadcte)
					AND prod_actual= ""
					AND a.sexo = cSexo --se agrega validacion del sexo

					SELECT 1
					INTO cExiste
					FROM bdisolic:"informix".ss_productos_ofrecer
					WHERE cliente    = pNumcte
					AND sucursal   = pSucursal
					AND ejecutivo  = pEjecutivo
					AND producto_ofr = cprod_final;

					IF NVL(cExiste,'') = '' THEN
						INSERT INTO bdisolic:"informix".ss_productos_ofrecer (cliente,sucursal,ejecutivo,producto_ofr,tp_solicitud_ofr,aplica) VALUES (pNumcte,pSucursal,pEjecutivo,cprod_final,cTpSolicitudOfr,'S');
					END IF;
				END FOREACH
			END IF;
		END IF;
		
		---I---RQM 10 960 TDC GC
		--cliente: Se valida la fecha alta de la cuenta de nomina (Producto 1300), de no tener o de ser menor a dos anios no se ofrece producto 8500.
        	SELECT fecha_hoy
			INTO dFechaHoy
			FROM bdicred:"informix".sd_fechas
			WHERE empresa = pEmpresa;
        
				SELECT noc.fecha_alta
				INTO dFechaAlta
				FROM bdicheq:"informix".sc_maechq mae
				INNER JOIN bdicheq:"informix".sc_maenoc noc ON (noc.cuenta = mae.cuenta AND mae.producto = '1300')
				WHERE mae.num_cte = pNumcte AND mae.status_cta ='1';
				IF dFechaAlta IS NULL THEN
					LET solApertTCGC = '0';
				  ELSE
					CALL bdicred:"informix".monthadd(dFechaAlta,+24) RETURNING dFechaValida;
					IF dFechaHoy < dFechaValida AND dFechaValida IS NOT NULL THEN
						LET solApertTCGC = '0';
						ELSE
						LET solApertTCGC = '1';
					END IF
				END IF
		---F---RQM 10 960 TDC GC
		
		-- BCPL Se consulta si es Cliente Prospecto, para validar la Respuesta de la OSCalle y obtener que Productos se pueden Ofertar
		SELECT numcte_pros INTO cCteProsp FROM bdiprospectos:"informix".pr_cliente WHERE empresa = pEmpresa AND numcte = pNumcte;

			--Si bandera_os esta activa se aplica vigencia de la OS calle, si la bandera_os esta inactiva no se aplicara la vigencia de la OS calle 
			IF EXISTS (SELECT {+ INDEX (bdicred:sd_definicion)} num_producto FROM bdicred:"informix".sd_definicion WHERE bandera_os='1') THEN		
				FOREACH
					--OBTENER LA MAXIMA SECUENCIA DE LA SOLICITUD INSERTADA EN LA TABLA DE LA OS SS_OSCLIENTESUPERVISAR PARA TITULAR 'T' Y PROSPECTOS 'P'.		
					SELECT LIMIT 1 b.fecharespuesta,b.clave,a.num_solicitud,'T' tipo_sol
					INTO dFechaRespOSCalle, cClave,cNumsolOs, cTipoSol 
					FROM  bdisolic:"informix".ss_solicitudes a
					JOIN bdisolic:"informix".ss_osclientesupervisar b ON (a.num_solicitud = b.num_solicitud)
					WHERE a.empresa = b.empresa AND b.secuencia=(SELECT MAX(d.secuencia) from bdisolic:"informix".ss_osclientesupervisar AS d WHERE d.num_solicitud = b.num_solicitud)
					AND clave IN ('A','R') AND fecharespuesta IS NOT NULL AND a.numcte =pNumcte 
					UNION 
					SELECT fecharespuesta,clave,num_solicitud,'P' tipo_sol
					FROM bdisolic:"informix".ss_osclientesupervisar
					WHERE empresa  = '001' AND num_solicitud  = cCteProsp
					AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud  = cCteProsp)
					ORDER BY fecharespuesta DESC
				END FOREACH;	
			END IF;
		IF NVL(cCteProsp,'') <> '' THEN
			SELECT fecharespuesta, clave INTO dFechaRespOSCalle, cClave
			FROM bdisolic:"informix".ss_osclientesupervisar WHERE empresa = pEmpresa AND num_solicitud = cCteProsp
			AND secuencia = (SELECT MAX(secuencia) FROM bdisolic:"informix".ss_osclientesupervisar WHERE num_solicitud = cCteProsp);
	
		
			IF NVL(cClave,'') = 'R' THEN
				SELECT MAX(fecha_hoy) - MIN(dFechaRespOSCalle) INTO iDiasTrans FROM bdinteg:"informix".si_fechas WHERE  empresa = pEmpresa;

				FOREACH
					SELECT clave_producto INTO cProductoOfrecer FROM bdisolic:"informix".ss_oscalle_vigencia WHERE vigrespos_oferta = 1

					IF EXISTS(SELECT 1 FROM bdisolic:"informix".ss_productos_ofrecer 
						WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND producto_ofr = cProductoOfrecer) THEN
						SELECT dias_vigencia INTO siDiasVigencia FROM bdisolic:"informix".ss_oscalle_plazovigencia 
						WHERE clave_producto = cProductoOfrecer AND resp_oscalle = cClave;

						IF NVL(iDiasTrans,0) <= NVL(siDiasVigencia,0) THEN
							UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' 
								WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND producto_ofr = cProductoOfrecer;
						END IF;
					END IF
				END FOREACH;
			END IF;
			
			-- CONSULTAMOS EL ULTIMO ESTATUS DEL CLIENTE PROSPECTO.
			FOREACH
				SELECT LIMIT 1 status_solicitud, fecha_insert INTO cStatusSolic, dFechaInsert
				FROM bdiprospectos:"informix".pr_autorizacion WHERE num_solicitud = cCteProsp
				ORDER BY fecha_hora DESC
				/*
				-- OBTENEMOS LA FECHA ACTUAL.
				SELECT fecha_hoy
				INTO dFechaHoy
				FROM bdicred:"informix".sd_fechas 
				WHERE empresa = pEmpresa;
				*/
				-- VALIDAMOS SI EL ULTIMO ESTATUS DEL CLIENTE PROSPECTO ES RECHAZADO "RT".
				IF cStatusSolic = "RT" THEN
					
					-- CALCULAMOS LOS DIAS QUE TIENE EL CLIENTE PROSPECTO CON ESTATUS DE SOLICITUD RECHAZADA "RT".
					--LET iDiasRechazo = (dFechaHoy - dFechaInsert);
					
					-- SI LA SOLICITUD TIENE 180 DIAS O MENOS DE RECHAZO NO SE LE OFERTARA TARJETA COPPEL 6500.
					--IF iDiasRechazo <= 180 THEN
						UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo 
						AND producto_ofr = '6500'; --IN ('6001','6500');
				--	END IF
				END IF
			END FOREACH;		
					
		END IF;				
		-- Valida si la sucursal puede ofrecer el producto coppel
		SELECT cajaunica
		INTO cSucCajaUnica
		FROM bditarjcop:"informix".sucursalescajaunica
		WHERE empresa = pEmpresa
		AND cvesucursal = pSucursal;

		IF NVL(cSucCajaUnica,'') = "" THEN
			LET cSucCajaUnica = 'F';
		END IF;

		SELECT numcte_ref
		INTO NumcteRelacionado
		FROM bdinteg:"informix".si_cliente
		WHERE numcte = pNumcte;

		IF NVL(NumcteRelacionado,'') <> "" THEN
			LET cSolcred_tramite_cop = '1';
		ELSE
			SELECT numctecoppel
			INTO NumcteRelacionado
			FROM bdinteg:"informix".si_adiccoppel
			WHERE empresa = pEmpresa
			AND numcte = pNumcte
			AND tipotar = '1';

			IF NVL(NumcteRelacionado,'') <> "" THEN
				LET cSolcred_tramite_cop = '1';
			END IF;
		END IF;
		
		IF iTotSolWeb<1 THEN 
			-- validacion de NO OFERTAMIENTO de una solicitud Coppel de que si se trata de (un cliente con una solicitud coppel ya existente) o (de que si la sucursal pueda ofertar producto coppel) o (de si ya se encuentra en tramite una solicitud coppel)
			IF pCoppel = '1' OR cSucCajaUnica = 'F' OR cSolcred_tramite_cop = '1' THEN
				UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr IN ('C');
			END IF;
		END IF;

		-- RQI 23 559 Validacion de NO OFERTAMIENTO para una solicitud de Banco para cuando (ya se cuenta con una solicitud Banco aperturada)
		--IF solApertAP = '1' OR solRT = '1' THEN
		IF solApertAP = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr IN ('P') and producto_ofr = '6400';
		END IF;
		
		-- Validacion de NO OFERTAMIENTO para una solicitud de Banco para cuando (ya se cuenta con una solicitud Banco rechazada) o (de si ya se cuenta con un credito activo) o (de si ya se cuenta con una reestructura activa)
		IF solApert = '1' THEN
			--JMAH RQM 10 617
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr IN ('T') and producto_ofr <> '7800';      --
		END IF;

		-- Validacion de NO OFERTAMIENTO para productos de credito que cuenten con (malos antecedentes en banco) o (malos antecedentes en coppel)
		IF pPrecalBco = '1'  OR pPrecalCoppel = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr <> 'D';
		END IF;

		IF solApertPPFlex = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr = 'P' AND producto_ofr IN ('6800','7100');
		END IF;
		-- Validacion de NO OFERTAMIENTO para prestamo personal para cuando (ya se cuente con una solicitud rechaza de credito banco) o (ya se cuente con una solicitu de prestamo personal rechaza) AAME 02032015 RQM 10 550 Se agregan nuevos prestamos 7600 y 7700
		IF solApertPP = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr = 'P' AND producto_ofr IN ('6300','7600','7700','6800','7100');
		END IF;
		
		-- Validacion de OFERTAMIENTO para prestamo personal para cuando (ya se cuente con una solicitud rechaza de credito banco) rechazada por capacidad de pago se oferten los productos de 18 y 24
		IF solApertRTCPS = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'S' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr = 'P' AND producto_ofr IN ('7600','7700');
		END IF;
		
		-- validacion de NO OFERTAMIENTO de una solicitud Banco para cuando ya se cuenta con una solicitud Banco en tramite.
		IF cSolcred_tramite = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr IN ('T','P');
		END IF;

		-- validacion de NO OFERTAMIENTO para el producto de nomina si es que ya se encuentra con una cuenta 1300 - PRODUCTO NOMINA EMPLEADOS GC que NO este cancelada
		IF cOfertaNomina = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte  AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr = 'D' AND producto_ofr = '1300';
		END IF;
		
		--valida que no OFERTE PRODUCTOS de CREDITO para la comparacion de huella
		IF pOfertaProdCred = 1 THEN 
			UPDATE bdisolic:"informix".ss_productos_ofrecer  SET aplica= 'N' WHERE cliente    = pNumcte  AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo AND tp_solicitud_ofr IN ('T','P','R','C');
		END IF;
		
		--valida que no OFERTE PRODUCTOS de DEBITO para la comparacion de huella - match cliente coppel con sit esp P - (9,10,13,18,19,21,49,51,55) T-16, V-40
		IF pOfertaProdCred = 2 THEN 
			UPDATE bdisolic:"informix".ss_productos_ofrecer  SET aplica= 'N' WHERE cliente = pNumcte  AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo AND tp_solicitud_ofr = 'D';
		END IF;

		--valida que no OFERTE PRODUCTOS de CREDITO para clientes con situacion especial U-62
		IF EXISTS (SELECT causa FROM bdisitesp:"informix".se_ctessitespcte WHERE numcte=pNumCte AND situacion = "U" AND causa = 62)  THEN 
			UPDATE bdisolic:"informix".ss_productos_ofrecer  SET aplica= 'N' WHERE cliente    = pNumcte  AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo AND tp_solicitud_ofr IN ('T','P','R','C');
		END IF;
		---I---RQM 10 960 TDC GC
		--- Validacion de NO OFERTAMIENTO si la cuenta nomina tiene menos de 24 meses minimo para producto 8500
		IF solApertTCGC = '0' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND producto_ofr IN ('8500');
		END IF;
		---F---RQM 10 960 TDC GC
		
		-- Valida que NO OFERTE producto de prestamo digital si tiene un credito activo: liquidado (FF) pero con vigencia
		LET inumpPrestamos = 0;
		SELECT count(a.num_credito) INTO inumpPrestamos FROM bdicred:"informix".sd_maecredcrd a JOIN bdicred:"informix".sd_linea_prestamo b ON (a.num_credito = b.num_credito and a.num_producto = '6800')  
		 WHERE a.numcte = pNumcte AND b.fecha_cancela IS NULL;
		IF inumpPrestamos > 0 THEN -- existe al menos un credito flexible aun activo sin importar el status FF (liquidado).
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr = 'P' AND producto_ofr = '6800';
		END IF;
		
		--IPCB Agregar la validacion de si es web
		 IF iTotSolWeb>0 THEN       
			UPDATE bdisolic:"informix".ss_productos_ofrecer  SET aplica= 'N' WHERE cliente    = pNumcte  AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo AND tp_solicitud_ofr IN ('T','P','R','C') and  producto_ofr not in ('6001','6500');
			--Verificar que exista la solicitud en PA, para ofertarsela al cliente y pueda concluir con la asignacion en OFI
			IF pCoppel = '1' OR cSucCajaUnica = 'F' OR cSolcred_tramite_cop = '1' THEN
				UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND tp_solicitud_ofr IN ('C');
			END IF;
         END IF;
		
		--RQM 10 1458
		LET cMarcaCte = "";
		IF pAlta = '0' and (pUso = 1 or pUso = 4) then
			SELECT NVL(marca,'') INTO cMarcaCte
			FROM bdisolic:"informix".ss_clienteslargos 
			WHERE numcte = pNumcte;
		END IF;
		
		IF cMarcaCte = 'P' then
			UPDATE bdisolic:"informix".ss_productos_ofrecer  SET aplica= 'N' WHERE cliente = pNumcte  AND sucursal = pSucursal AND ejecutivo  = pEjecutivo AND tp_solicitud_ofr = 'P' and producto_ofr <> '9300'; --producto_ofr = cprod_final;
		END IF;
		--RQM 10 1458
		
		--P-109
		SELECT count(*)
		INTO cSitEsp
		FROM bdisitesp:"informix".se_ctessitespcte
		WHERE numcte=pNumCte AND situacion = "P" AND causa = 109;
		
		
		--valida que no OFERTE PRODUCTOS de CREDITO y DEBITO para clientes con situacion especial P-109
		IF NVL(cSitEsp,0) > 0 THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer  SET aplica= 'N' WHERE cliente    = pNumcte  AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo AND tp_solicitud_ofr IN ('T','P','R','C','D');
		END IF;
		
				
		--valida que no OFERTE PRODUCTOS de CAPTACION para clientes que sobrepase el Limite maximo de cuenta .
		EXECUTE PROCEDURE bdicheq:"informix".sp_limite_cuentas(pNumcte) INTO cCodErr, cNumCueCapt;
		IF cCodErr = '000' AND cNumCueCapt = '1'  THEN 
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica= 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo  = pEjecutivo 
			AND producto_ofr IN( SELECT producto FROM bdicheq:"informix".sc_producto WHERE empresa = pEmpresa AND producto NOT IN( '1100','3000') );
		END IF;


		-- SI TIENE SITUACION ESP P112 LE OFRECE CUENTAS DEBITO Y CREDITO .--420
		SELECT COUNT(CAUSA) INTO sExiste FROM bdisitesp:"informix".se_ctessitespcte WHERE CAUSA = cValorMod AND situacion='P' AND NUMCTE= pNumcte;
		
		IF sExiste > 0 THEN
			update  bdisolic:"informix".ss_productos_ofrecer SET aplica= 'N' WHERE cliente = pNumcte AND sucursal = pSucursal 
			AND ejecutivo  = pEjecutivo and producto_ofr NOT IN( '2000','1400','1800','2400','1300','1900','1700','6600','7000','8100', '6001');
		END IF
		
		LET sExiste = 0;

		-- Valida que NO oferte productos de credito a empleados GC RQM 09 539
		IF pEmp = '1' THEN
			UPDATE bdisolic:"informix".ss_productos_ofrecer SET aplica = 'N' WHERE cliente = pNumcte AND sucursal = pSucursal AND ejecutivo = pEjecutivo AND producto_ofr in (select  {+ INDEX (bdicred:sd_definicion)}num_producto from bdicred:sd_definicion where oferta_emp = '0');
		END IF;

		IF pUso = 4 THEN
			SELECT valor INTO vProdComplatiblesCtaNomina
			FROM bdiadminnomina:"informix".sn_parametros WHERE id = 'PRODUCTOS_NOMINA ';
			
			UPDATE "informix".ss_productos_ofrecer
				SET aplica = 'N'
			 WHERE cliente = pNumcte
				AND sucursal = pSucursal
				AND ejecutivo = pEjecutivo
				AND CHARINDEX (producto_ofr, vProdComplatiblesCtaNomina) = 0;
		END IF;
		
		LET cTpSolicitudOfr = "";
		LET cprod_final     = "";
		
		--Ini RQM 06 806 CUB-CURP
		SELECT valor INTO cValidaSitEsp FROM bdinteg:"informix".si_param WHERE cod_param = 501;
		
		IF cValidaSitEsp = 1 THEN
			SELECT situacion INTO cSituacion FROM bdisitesp:"informix".se_ctessitespcte where numcte = pNumcte;
			SELECT causa INTO cCausa FROM bdisitesp:"informix".se_ctessitespcte where numcte = pNumcte;
			SELECT curp INTO cCurp FROM bdinteg:"informix".si_ctepf where numcte = pNumcte;
			SELECT nacionalidad INTO cNacionalidad FROM bdinteg:"informix".si_ctepf where numcte = pNumcte;
			
			IF NVL(cCurp,"") = "" THEN
				SELECT nombre_prod INTO cdescripcion FROM bdicred:"informix".sd_definicion WHERE empresa = pEmpresa AND num_producto = 6500;
					LET cTpSolicitudOfr = "T";
					LET cprod_final = 6500;
					LET cPrioridad = 1;
				IF cSituacion = "C" AND cCausa = 1 THEN
					LET CodRet = "00013";
					RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
				END IF;    
				IF cSituacion = "C" AND cCausa = 2 THEN
					LET CodRet = "00014";
					RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
				END IF;
				IF cSituacion = "C" AND cCausa = 3 THEN
					LET CodRet = "00015";
					RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
				END IF;
				IF cNacionalidad = "001" THEN
					IF NOT ((cSituacion = "C" AND cCausa = 1) OR (cSituacion = "C" AND cCausa = 2) OR (cSituacion = "C" AND cCausa = 3)) THEN
						LET CodRet = "00016";
						RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
					END IF;
				END IF;
			END IF;
		END IF;
		--Fin RQM 06 806 CUB-CURP

		FOREACH
			SELECT DISTINCT (tp.producto_ofr), tp.tp_solicitud_ofr, t.prioridad, 
				(CASE WHEN t.sistema = '01' THEN
					(SELECT UPPER(p.nombre) FROM bdicheq:"informix".sc_producto p
					WHERE empresa = pEmpresa AND p.producto = tp.producto_ofr)
				ELSE
					(CASE WHEN t.sistema = '03' THEN
						(SELECT UPPER(i.nombre) FROM bdinvers:"informix".sv_instrum i
							WHERE empresa = pEmpresa AND i.cod_instrum = tp.producto_ofr)
					ELSE
						(CASE WHEN t.sistema = '06' THEN
							(CASE WHEN tp.tp_solicitud_ofr = 'C' THEN 
								(SELECT UPPER(descripcion) FROM bdisolic:"informix".ss_tp_solicitud 
								WHERE empresa = pEmpresa AND tp_solicitud = 'C')
							ELSE
								(SELECT UPPER(nombre_prod) FROM bdicred:"informix".sd_definicion d
								WHERE empresa = pEmpresa AND d.num_producto = tp.producto_ofr)                          
							END)
						END)
					END)
				END)
			INTO cprod_final, cTpSolicitudOfr, cPrioridad, cdescripcion
			FROM bdisolic:"informix".ss_productos_ofrecer  tp
			INNER JOIN bdisolic:"informix".ss_tramite_productos_clasif t ON (tp.producto_ofr = t.prod_ofrecer)
			WHERE tp.cliente = pNumcte
			AND tp.sucursal = pSucursal
			AND tp.ejecutivo = pEjecutivo
			AND aplica = 'S'
			ORDER BY t.prioridad

			--Valida si el producto a ofrecer es de credito, para validar la fecha alta en caso que lo requiera.
			IF cprod_final  = '6400' THEN 
				IF EXISTS(SELECT 1 FROM bdisolic:"informix".ss_producto_credcap WHERE num_producto = cprod_final AND meses_alta IS NOT NULL) THEN
					--se valida que debe tener una cuenta con la vigencia valida para ofrecer credinomina.
					--Obtiene meses necesarios de alta para ofrecer el producto
					SELECT fecha_hoy
					INTO dFechaHoy
					FROM bdicred:"informix".sd_fechas 
					WHERE empresa = pEmpresa;

					FOREACH
						SELECT tp2.fecha_alta, cp2.meses_alta
						INTO dFechaAlta, iMeses
						FROM bdisolic:"informix".ss_productos_ofrecer tp2
						INNER JOIN bdisolic:"informix".ss_producto_credcap cp2 ON (cp2.num_producto = cprod_final AND cp2.producto_cap = tp2.producto_act)		
						WHERE tp2.fecha_alta IS NOT NULL
						and tp2.cliente = pNumcte AND tp2.sucursal = pSucursal and tp2.ejecutivo = pEjecutivo --linea agregada
						CALL bdicred:"informix".monthadd(dFechaHoy,-iMeses) RETURNING dFechaValida;	
						IF NOT dFechaAlta <= dFechaValida THEN
							CONTINUE FOREACH;
						END IF;						
						LET cOfertar = "S";
						EXIT FOREACH;						
					END  FOREACH;

					IF cOfertar <> "S" THEN
						CONTINUE FOREACH;
					END  IF;
				END IF;
			END IF;
			
			
			IF cTpSolicitudOfr = 'P' AND cprod_final  <> '6400' AND solApertRTCPS = '1'   THEN--JMAH RQM 09 408-2
				
				SELECT valor_rab, grupo
				INTO v_capacidad,v_grupo		
				FROM bdisolic:"informix".ss_revision_determinacion
				WHERE empresa = pEmpresa
				AND num_solicitud = cnum_solicitudAux;
			
					LET cOfertar ='N';
				LET dPago_mensual=0;
				IF v_capacidad > 0 THEN 	
					SELECT NVL(plazo_max_cred,0)
					INTO iPlazoMax
					FROM bdicred:"informix".sd_definicion
					WHERE empresa = pEmpresa
					AND num_producto = cprod_final;
					   
					SELECT valor::DECIMAL(14,2)
					  INTO v_salariomin -- Salario Minimo Base
					  FROM bdisolic:"informix".ss_param
					 WHERE empresa = pEmpresa
					   AND secuencia = 354;					

					SELECT valor::DECIMAL(14,2)
					  INTO v_diaspromedio -- Salario Minimo Base
					  FROM bdisolic:"informix".ss_param
					 WHERE empresa = pEmpresa
					   AND secuencia = 355;   
					   
					SELECT (sum(round(cant_smb_inf * v_salariomin * v_diaspromedio,-2)))
					INTO v_limite_inferior			
					FROM bdisolic:"informix".ss_scoring_solic
					WHERE empresa = pEmpresa
					AND tp_solicitud = cTpSolicitudOfr
					AND seccion = '2'
					AND activa = '1'
					AND grupo = v_grupo; 
					  
				EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (NVL(v_limite_inferior,3300),iPlazoMax,0,cprod_final,pSucursal,0,0,'',"",1)
					INTO Codret2,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
					dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos;

					IF Codret2 <> "000000" THEN
						CONTINUE FOREACH;
					END IF;	
					IF (  v_capacidad >= dPago_mensual  ) then
						LET cOfertar = "S";					
					END IF;					
				END IF;
				
				
				IF cOfertar <> "S" THEN
						CONTINUE FOREACH;
				END  IF;
					
			END IF;		
			
			
			IF cprod_final  = '7800' THEN --JMAH RQM 10 617
				   LET cOfertar ='N';
			       FOREACH
						EXECUTE PROCEDURE "informix".sp_adn_obtienectas('001', pNumcte)											
						INTO cVar1,cVar2
						IF cVar1::INTEGER = 0 THEN
							LET cOfertar = "S";
							EXIT FOREACH;
						END IF 
					END  FOREACH;

					IF cOfertar <> "S" THEN
						CONTINUE FOREACH;
					END  IF;
				
			END IF;
			
			--Ini RQM 09 547
			If pAlta = '0' then 
				If (pUso = 1 or pUso = 4) then
					IF cprod_final in (Select {+ INDEX (bdisolic:ss_cat_prod_ofrecer idx_ss_cat_prod_ofrecer)} producto from ss_cat_prod_ofrecer where ejecucion = '2') then
						LET cOfertar ='N';
						CONTINUE FOREACH;

					END IF;
				elif pUso = 2 then
					IF cprod_final in (Select {+ INDEX (bdisolic:ss_cat_prod_ofrecer idx_ss_cat_prod_ofrecer)}  producto from ss_cat_prod_ofrecer where ejecucion = '1') then
						LET cOfertar ='N';
						CONTINUE FOREACH;

					END IF;
				elif pUso = 3 then
					IF cprod_final in (Select producto from ss_cat_prod_ofrecer) then
						LET cOfertar ='N';
						CONTINUE FOREACH;
					END IF;	
				End if;
			End if;
			--Fin RQM 09 547
			
			IF cprod_final = '6001' THEN
				LET cdescripcion = 'TARJETA CREDITO BANCOPPEL';
			END IF;
			
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'')  WITH resume;
		END FOREACH;
		
		

		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET CodRet = '000001';
		END IF;

		DELETE FROM bdisolic:"informix".ss_productos_ofrecer  WHERE cliente = pNumcte AND sucursal   = pSucursal AND ejecutivo  = pEjecutivo;

		IF CodRet = '000001' THEN
			RETURN CodRet, NVL(cprod_final,''), NVL(cTpSolicitudOfr,""), NVL(cdescripcion,''), NVL(cPrioridad,'');
		END IF;
	END IF;
	END;
END PROCEDURE
