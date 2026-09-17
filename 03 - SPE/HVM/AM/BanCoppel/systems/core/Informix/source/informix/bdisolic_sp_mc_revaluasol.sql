CREATE PROCEDURE "informix".sp_mc_revaluasol ( pEmpresa CHAR (3),pNumSol CHAR (20),pNumcte CHAR (20), pBandera CHAR(1))
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(80) AS DESCRIPCION,
	CHAR (1) AS cBanderaMC;
---DECLARACIONES
DEFINE iSqlErr			INTEGER;
DEFINE iIsamErr			INTEGER;
--DEFINE iSecuencia       INTEGER;
DEFINE cErrorInfo		CHAR(80);
DEFINE cCodRet			CHAR(6);
DEFINE cMensajeRet		CHAR(80);

--- Motor Evaluacion de Credito
DEFINE cBanderaMC		CHAR(1);
----------------------------------
DEFINE sNum_producto           	CHAR(4);
DEFINE 	v_sucursal         		CHAR(4);
DEFINE v_SituacionPagoCoppel  DECIMAL(5,2);
DEFINE v_meses                SMALLINT;
DEFINE  vsituacion_especial    	CHAR(1); 
DEFINE	vcausa_situacion		SMALLINT;
DEFINE 	o_vencidoropa    INTEGER;
DEFINE 	o_vencidomuebles INTEGER;
DEFINE 	o_vencidoprestamos INTEGER;
DEFINE 	o_abonoropa      INTEGER;
DEFINE 	o_saldomuebles   INTEGER;
DEFINE 	o_saldoropa      INTEGER;
DEFINE 	o_saldoprestamos INTEGER;
DEFINE 	o_ultimacompra   DATE;
DEFINE 	o_abonomuebles	 INTEGER;
DEFINE 	o_abonoprestamos INTEGER;
DEFINE	vlNombre				CHAR(104);	
DEFINE	vlClienteRef			CHAR(20);
DEFINE p_cod_ret		CHAR(6);
DEFINE cMensaje		CHAR(80);
DEFINE pStatusFin		CHAR(2);
DEFINE analista_mc		CHAR(10);
DEFINE pComentario CHAR(500);
DEFINE cNombreejecutivo CHAR(100);
DEFINE ptipogrupo 			CHAR(2); 
DEFINE phit 				CHAR(6); 	

--- Motor Evaluacion de Credito
LET cBanderaMC = '0';
----------------------------------

----- Reevaluacion
LET sNum_producto = '';
LET v_sucursal= "";
LET v_SituacionPagoCoppel = 0;
LET v_meses               = 0;
LET vsituacion_especial = '';
LET o_vencidomuebles =0;
LET o_vencidoropa    =0;
LET o_vencidoprestamos =0;
LET o_abonomuebles	 =0;
LET o_abonoprestamos =0;
LET o_abonoropa      =0;
LET o_saldomuebles   =0;
LET o_saldoropa      =0;
LET o_saldoprestamos =0;
LET o_ultimacompra   = date(1);
LET vcausa_situacion = 0;
LET vlNombre= '';
LET vlClienteRef ='';
LET p_cod_ret = '000000'; 
LET cMensaje = '';
LET pStatusFin = '';
LET analista_mc = '';
LET pComentario = '';
LET cNombreejecutivo    = '';
LET ptipogrupo = '';
LET phit = '';
---INICIALIZACIONES
LET iSqlErr				= 0;
LET iIsamErr			= 0;
--LET iSecuencia			= 0;
LET cErrorInfo			= '';
LET cCodRet				= '000000';
LET cMensajeRet			= 'Proceso Exitoso';


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet, cMensajeRet, cBanderaMC;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/ulises/SOC_Precalif/sp_mc_revaluasol.out";
	--TRACE ON;
	
	IF NVL(pEmpresa,"") = "" AND NVL(pNumSol,"") = "" OR nvl(pBandera,"") = "" THEN
	
		LET cCodRet = "000001";
		LET cMensajeRet = "PARAMETROS DE ENTRADA INVALIDOS.";
	  
	ELSE	
		--- Motor Evaluacion de Credito
		 IF pBandera = 1 THEN  -- Validacion de parametro bandera proveniente de MC

			SELECT a.status_solicitud,b.ejecutivo_atiende
				INTO pStatusFin, analista_mc
				FROM bdisolic:ss_solicitudes a
				JOIN  bdisolic:ss_solicitudes_mc b on (a.num_solicitud = b.num_solicitud)
				WHERE a.empresa = pEmpresa AND a.num_solicitud = pNumSol;
				
				
			SELECT nombre INTO cNombreejecutivo 
				FROM bdinteg:si_ejecut 
				WHERE ejecutivo= analista_mc 
				AND empresa = pEmpresa;   			
				
			IF pStatusFin = "AT" Then       
				LET pComentario = "Autorizada por MC " || TRIM(NVL(cNombreejecutivo,'')) ;
			ELIF pStatusFin = "RT" Then                       
				LET pComentario = "Rechazada por MC " || TRIM(NVL(cNombreejecutivo,'')) ;
			ELIF  pStatusFin = "OS" Then                  
				LET pComentario = "Enviada a orden de supervision por MC " ||TRIM(NVL(cNombreejecutivo,''));
			ELIF  pStatusFin = "EE" THEN
				LET pComentario = "Revisada en MC por " ||TRIM(NVL(cNombreejecutivo,''));
			ELSE
				LET pComentario = "Cambio por MC " ||TRIM(NVL(cNombreejecutivo,''));
			END IF		

			UPDATE bdisolic:ss_solicitudes_mc 
				SET revalua ='S',status_fin = pStatusFin, ejecutivo_atiende = analista_mc,
					ejecutivo_autoriza = 'Sistema',observaciones = pComentario,
					revisado = 'S', fecha_determinacion = TODAY
			WHERE empresa = pEmpresa  AND num_solicitud = pNumSol;

		 ELSE
			SELECT sol.num_producto,sol.sucursal
			INTO sNum_producto,v_sucursal
			FROM bdisolic:ss_solicitudes sol 
			LEFT JOIN bdisolic:"informix".ss_solicitudes_movil mov on (mov.empresa = sol.empresa and mov.num_solicitud = sol.num_solicitud AND status <> '3')
			WHERE sol.empresa = pEmpresa
				AND sol.num_solicitud = pNumSol;
			
			
			SELECT situacion_pago,     meses_historia,
				situacion_credito,   causa,   vencidoropa, 	 vencidomuebles,    
				vencidoprestamos,      abonomensualropa,  abonomensualmuebles,   
				abonomensualprestamos, saldoropa,         saldomuebles,saldoprestamos, 
				fecha_ultima_compra
			INTO v_SituacionPagoCoppel,v_meses,  
				vsituacion_especial, vcausa_situacion, o_vencidoropa,o_vencidomuebles,
				o_vencidoprestamos , o_abonoropa ,	o_abonomuebles,
				o_abonoprestamos ,   o_saldoropa ,		o_saldomuebles ,o_saldoprestamos ,
				o_ultimacompra
			FROM bdisolic:ss_resum_scor_fin WHERE empresa=pEmpresa AND num_solicitud=pNumSol;	  
			
			select numcte_ref, trim(nombre1) ||' ' || trim(nombre2) ||' ' || trim(apell_paterno) ||' ' || trim(apell_materno) 
				into vlClienteRef, vlNombre
			from bdinteg:si_cliente 
			where numcte = pNumcte;
			
			
				IF v_SituacionPagoCoppel IS NULL THEN
					LET v_SituacionPagoCoppel= 0;
				END IF;
			
					-- clientes coppel sin compras, se le da tratamiento de cliente nuevo
					IF v_SituacionPagoCoppel < 0 THEN
						LET v_meses = 0;
						LET v_SituacionPagoCoppel = 0;			
					END IF;
					
			-----  Reevaluacion Tienda
		
			CALL bdisolic:situacion_pago_tienda_cjunk_precal(pEmpresa, pNumcte,sNum_producto,v_sucursal,
				user, decode(v_SituacionPagoCoppel,0,-1,v_SituacionPagoCoppel) ,vsituacion_especial,vcausa_situacion,vlClienteRef,vlNombre,vlNombre,
				v_meses,o_vencidomuebles ,o_vencidoropa    ,o_vencidoprestamos ,o_abonomuebles	 ,
				o_abonoropa ,o_abonoprestamos ,o_saldomuebles ,o_saldoropa ,o_saldoprestamos ,o_ultimacompra   )
				RETURNING p_cod_ret, cMensaje;
				
			IF p_cod_ret <> '000' THEN 
			
				LET cMensaje='Rechazado por estar fuera de politicas';	
				LET p_cod_ret= '00008'; -- Rechazado por estar fuera de politicas
				EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol (pEmpresa, 'SISTEMA',pNumSol, 'RT','RDO', cMensaje) INTO cCodRet;

			END IF;	

				IF p_cod_ret ::INTEGER = 0 then
				
				
				 call "informix".sp_obtienegrupo (pNumSol)RETURNING cCodRet,ptipogrupo,phit;

				  --- Motor Evaluacion de Credito
				    IF EXISTS(SELECT * FROM bdicred:"informix".sd_productos_motor WHERE numproducto = sNum_producto) THEN --- Valida si es producto motor
					  LET cBanderaMC = 1;					
					  RETURN cCodRet, cMensajeRet, cBanderaMC;
				    ELSE																			--- Si no es producto motor continua el proceso normal
					  EXECUTE PROCEDURE bdisolic:califica_scoring2_cjunk(pEmpresa, pNumSol)	INTO p_cod_ret;	

						IF p_cod_ret != 0 THEN
							  INSERT INTO bdisolic:ax_paso values ("bdisolic:sp_mc_revaluasol", p_cod_ret, CURRENT ||' sol '||TRIM(pNumSol));
						END IF				
						
					  LET cCodRet = "000000";
				    END IF;	
			   END IF;
			
			SELECT a.status_solicitud,b.ejecutivo_atiende
			INTO pStatusFin, analista_mc
			FROM bdisolic:ss_solicitudes a
			JOIN  bdisolic:ss_solicitudes_mc b on (a.num_solicitud = b.num_solicitud)
			WHERE a.empresa = pEmpresa AND a.num_solicitud = pNumSol;
			
			
			SELECT nombre INTO cNombreejecutivo 
			FROM bdinteg:si_ejecut 
			WHERE ejecutivo= analista_mc 
			AND empresa = pEmpresa;   			
			
			IF pStatusFin = "AT" Then       
				LET pComentario = "Autorizada por MC " || TRIM(NVL(cNombreejecutivo,'')) ;
			ELIF pStatusFin = "RT" Then                       
				LET pComentario = "Rechazada por MC " || TRIM(NVL(cNombreejecutivo,'')) ;
			ELIF  pStatusFin = "OS" Then                  
				LET pComentario = "Enviada a orden de supervision por MC " ||TRIM(NVL(cNombreejecutivo,''));
			ELIF  pStatusFin = "EE" THEN
				LET pComentario = "Revisada en MC por " ||TRIM(NVL(cNombreejecutivo,''));
			ELSE
				LET pComentario = "Cambio por MC " ||TRIM(NVL(cNombreejecutivo,''));
			END IF				
			
				UPDATE "informix".ss_solicitudes_mc 
					SET revalua ='S',status_fin = pStatusFin, ejecutivo_atiende = analista_mc,
						ejecutivo_autoriza = 'Sistema',observaciones = pComentario,
						revisado = 'S', fecha_determinacion = TODAY
				WHERE empresa = pEmpresa  AND num_solicitud = pNumSol;
			
		 END IF;
	END IF;
	RETURN cCodRet, cMensajeRet, cBanderaMC; --- Se evnia bandera distintiva si es o no producto motor
END
END PROCEDURE
