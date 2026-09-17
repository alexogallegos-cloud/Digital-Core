CREATE PROCEDURE "informix".sp_obtienereferenciassolicitud_web(pEmpresa CHAR(3), pNumSolicitudActual CHAR(20) ,pNumcte CHAR(20))

--RETORNOS-
RETURNING
	CHAR(5)    AS codigo_ret,
	CHAR(104)  AS Nombre1,
	char(23)   AS Parentesco1,
	CHAR(13)   AS Telefono1,
	CHAR(104)  AS Nombre2,
	char(23)   AS Parentesco2,
	CHAR(13)   AS Telefono2,
	SMALLINT   AS Tp_ingreso,
	SMALLINT   AS Periodicidad,
	char(20)   AS Conyugue;

--DECLARACION DE VARIABLES--
DEFINE cCodret				    CHAR(5);
DEFINE iSql_err				    INTEGER; 
DEFINE iIsamErr                 INTEGER;
DEFINE mIngreso                 MONEY(14,2);
DEFINE cDatosComp               CHAR(80);
DEFINE cRespCte                 CHAR(80);
DEFINE sGrupo                   SMALLINT;
DEFINE sElemento                SMALLINT;
DEFINE cNumSolicitud            CHAR(20);
DEFINe dFechaSolic              DATE;
DEFINE sSeccion                 SMALLINT;
DEFINE iDiasSolicitud           INTEGER;
DEFINE iContador                INTEGER;
DEFINE dFechaActual             DATE;
DEFINE dFechaMinima             DATE;
DEFINE iPaginacionRetorno       INTEGER;
DEFINE iBandera                 INTEGER;
DEFINE iBanderaConyugue         INTEGER;

DEFINE cNombreRef	CHAR(104);
DEFINE cParentesco	CHAR(23);
DEFINE cTelefono	CHAR(13);
DEFINE cNombreRef1	CHAR(104);
DEFINE cParentesco1	CHAR(23);
DEFINE cTelefono1	CHAR(13);
DEFINE cNombreRef2	CHAR(104);
DEFINE cParentesco2	CHAR(23);
DEFINE cTelefono2	CHAR(13);
DEFINE iTp_ingreso	INTEGER;
DEFINE iPeriodo_ingreso	INTEGER;
DEFINE cTel1	    CHAR(13);
DEFINE cTel2	    CHAR(13);
DEFINE cNumcte_ref	CHAR(20);
DEFINE cDescParentesco	CHAR(20);
DEFINE cConyugue	CHAR(20);
DEFINE cCodretSH	CHAR(6);	-- Se utiliza para recibir el codigo de retorno de la ejecucion sp_obtienesolicitudherencia

--INICIALIZACION DE VARIABLES--
LET cCodret            = '00000'; --EJECUCION EXITOSA
LET iIsamErr           = 0 ;
LET iSql_err           = 0 ;  
LET mIngreso           = 0;
LET cDatosComp         = '';
LET cRespCte           = '';
LET sGrupo             = 0;
LET sElemento          = 0;
LET cNumSolicitud      = '';
LET dFechaSolic        = DATE(1);
LET sSeccion           = 0;
LET iDiasSolicitud     = 0;
LET iContador          = 0; --LLEVA EL CONTROL DE CUANTOS REGISTROS VA A IMPRIMIR EN PANTALLA
LET dFechaActual       = DATE(1);
LET dFechaMinima       = DATE(1);
LET iPaginacionRetorno = 0 ;
LET iBandera           = 0 ;
LET iBanderaConyugue   = 0 ;

LET cNombreRef	 = '';
LET cParentesco	 = '';
LET cTelefono	 = '';
LET cNombreRef1	 = '';
LET cParentesco1 = '';
LET cTelefono1	 = '';
LET cNombreRef2	 = '';
LET cParentesco2 = '';
LET cTelefono2	 = '';
LET iTp_ingreso  = 0;
LET iPeriodo_ingreso = 0;
LET cTel1	     = '';
LET cTel2	     = '';
LET cNumcte_ref	 = '';
LET cDescParentesco	 = '';
LET cConyugue	 = '';
LET cCodretSH    = '';

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err , iIsamErr
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN cCodret, cNombreRef1,cParentesco1 ,cTelefono1, cNombreRef2 ,cParentesco2 ,cTelefono2 ,iTp_ingreso, iPeriodo_ingreso,NVL(cConyugue,"");
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/informix/jesus/sp_obtienereferenciassolicitud.out';
	--TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  
	  --CONTROL DE ERRORES POR PARAMETRO--
	 IF NVL(pEmpresa, '' ) = '' OR NVL(pNumSolicitudActual,'')= '' OR  NVL(pNumcte, '') = ''   THEN
		LET cCodret = '00001'; --PROPORCIONE PARAMETROS PARA EJECUTAR EL PROCEDIMIENTO
		RETURN cCodret, cNombreRef1,cParentesco1 ,cTelefono1, cNombreRef2 ,cParentesco2 ,cTelefono2 ,iTp_ingreso, iPeriodo_ingreso,NVL(cConyugue,"");
	 END IF;
	 
	 IF cCodret = '00000' THEN
		EXECUTE PROCEDURE "informix".sp_obtienesolicitudherencia
		 (pEmpresa ,pNumSolicitudActual,pNumcte)
		 INTO cCodretSH, cNumSolicitud;
		 LET cCodret = SUBSTRING (cCodretSH FROM 2 FOR 5);
	END IF;
	------------------------------------------------------------------------------------------------
	-----------------BLOQUE DE CONSULTA DE PREGUNTAS, RESPUESTAS E INGRESO
	IF cCodret = '00000' THEN
		
		SELECT tp_ingreso,  periodo_ingreso 
			INTO iTp_ingreso, iPeriodo_ingreso
		FROM "informix".ss_resum_scor_fin		
		WHERE empresa = pEmpresa
		AND num_solicitud = cNumSolicitud;
		
		FOREACH WITH HOLD			
			
			SELECT nombre_ref, parentesco, telefono_ref,numcte_ref
			INTO cNombreRef,cParentesco, cTelefono,cNumcte_ref
			FROM 	"informix".ss_refpersonales
			WHERE empresa = pEmpresa
			AND num_solicitud = cNumSolicitud
			AND numcte = pNumcte
			ORDER BY ROWID DESC
			
			SELECT descripcion 
			INTO cDescParentesco
			FROM bdinteg:si_parentesco 
			WHERE parentesco = TRIM(cParentesco);
			
			LET cParentesco = TRIM(cParentesco)||" "||TRIM(cDescParentesco);
			
			IF SUBSTR(cParentesco,1,1) = "C" AND TRIM(cNumcte_ref) ='R1' THEN
				CONTINUE FOREACH;
			ELIF SUBSTR(cParentesco,1,1) <> "C" AND TRIM(cNumcte_ref) ='R1' THEN
				LET cNombreRef1 = cNombreRef ;
				LET cParentesco1 = cParentesco ; 
				LET cTelefono1 = cTelefono;	
			ELIF  TRIM(cNumcte_ref) ='R2' THEN
				LET cNombreRef2 = cNombreRef ;
				LET cParentesco2 = cParentesco ; 
				LET cTelefono2 = cTelefono;					
			ELIF SUBSTR(cParentesco,1,1) = "E" THEN
				--LET cNombreRef1 = cNombreRef ;
				LET cParentesco1 = cParentesco ; 			
				LET iBanderaConyugue = 1;
				LET cConyugue = cNumcte_ref;
				
				SELECT TRIM(a.nombre1)||" "||TRIM(a.nombre2)||" "||TRIM(a.apell_paterno)||" "||TRIM(a.apell_materno)
				INTO cNombreRef1
				FROM bdinteg:"informix".si_cliente a
				WHERE EMPRESA = pEmpresa
				AND	a.numcte = cNumcte_ref;
				
				
				-- cuando es casado el telefono se almacena en otra tabla...
				SELECT limit 1 telefono
				INTO cTelefono1
				FROM bdinteg:"informix".si_telefonos_actual
				WHERE numcte = cNumcte_ref
				AND tipo_tel = '1';
				
				 
				IF NVL(cTelefono1,"") = "" THEN
					SELECT limit 1 telefono
					INTO cTelefono1
					FROM bdinteg:"informix".si_telefonos_actual
					WHERE numcte = cNumcte_ref
					AND tipo_tel = '2';
				END IF;		
				IF NVL(cTelefono1,"") = "" THEN
					SELECT limit 1 telefono
					INTO cTelefono1
					FROM bdinteg:"informix".si_telefonos_actual
					WHERE numcte = cNumcte_ref
					AND tipo_tel = '3';
				END IF;					
								
			END IF	
			
			
		END FOREACH;
					
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '00005'; --EL NÚMERO DE SOLICITUD NO TIENE REGISTRADAS Referencias
		END IF;
	END IF;
	RETURN cCodret, cNombreRef1,cParentesco1 ,cTelefono1, cNombreRef2 ,cParentesco2 ,cTelefono2 ,iTp_ingreso, iPeriodo_ingreso,NVL(cConyugue,"");
END;
END PROCEDURE
