CREATE PROCEDURE "informix".sp_consestatuscaja(pSucursal VARCHAR(5),pStatus VARCHAR(8),pOpcion VARCHAR(1))
RETURNING CHAR(5) AS cCod_Ret,
			CHAR(5) AS cNumsucursal,
			CHAR(80) AS cDescripcion,
			CHAR(12) AS cNumerocaja,
			CHAR(10) AS cFecha,
			CHAR(8) AS cUsuario,
			CHAR(40) AS cNombre,
			CHAR(20) AS cNumeroGuia,
			CHAR(7) AS cEstatus;

DEFINE cCod_Ret			CHAR(5);
DEFINE isqlerr			INTEGER ;
DEFINE cNumsucursal		CHAR(5);
DEFINE cDescripcion		CHAR(80);
DEFINE cNumerocaja		CHAR(12);
DEFINE cFecha			CHAR(10);
DEFINE cUsuario			CHAR(8);
DEFINE cNombre			CHAR(40);
DEFINE cNumeroGuia		CHAR(20);
DEFINE cEstatus			CHAR(7);

LET cCod_Ret		= "001";
LET isqlerr			= 0;
LET cNumsucursal	= '';
LET cNumerocaja		= '';
LET cDescripcion	= '';
LET cNumeroGuia		= '';
LET cEstatus		= '';
LET cFecha			= '';
LET cUsuario		= '';
LET cNombre			= '';

BEGIN
    ON EXCEPTION  SET isqlerr
        IF isqlerr <> 0  THEN
            LET  cCod_Ret  = isqlerr;
            RETURN cCod_Ret,cNumsucursal,cDescripcion,cNumerocaja,cFecha,cUsuario,cNombre,cNumeroGuia,cEstatus;
        END IF;
    END  EXCEPTION;

     --SET DEBUG FILE TO '/tmp/sp_ConsEstatusCaja.out';
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

		IF pOpcion = '1' THEN
	        -- busca por Sucursal y Estatus
			IF pStatus = "Enviada" THEN
				FOREACH
					SELECT TRIM(cajas.numsucursal),TRIM(catpaq.descripcion),TRIM(cajas.numerocaja),cajas.fecha_envio,cajas.usuario_envio,NVL(ejec.nombre,''),NVL(cajas.numeroguia,''),TRIM(cajas.estatus)
					INTO cNumsucursal,cDescripcion,cNumerocaja,cFecha,cUsuario,cNombre,cNumeroGuia,cEstatus
					FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq, bdinteg:"informix".si_ejecut ejec
					WHERE cajas.tipopaquete = catpaq.tipopaquete
					AND cajas.empresa = catpaq.empresa
					AND cajas.empresa = ejec.empresa
					AND cajas.usuario_envio = ejec.ejecutivo
					AND cajas.numsucursal = pSucursal
					AND cajas.estatus = pStatus
					ORDER BY cajas.numerocaja

					LET cCod_Ret= "000";
					RETURN cCod_Ret,NVL(cNumsucursal,''),TRIM(NVL(cDescripcion,'')),NVL(cNumerocaja,''),TRIM(NVL(cFecha,'')),TRIM(NVL(cUsuario,'')),TRIM(NVL(cNombre,'')),NVL(cNumeroGuia,''),TRIM(NVL(cEstatus,'')) WITH RESUME;
				END FOREACH;
			ELIF pStatus = "Cerrada" THEN
				FOREACH
					SELECT  TRIM(cajas.numsucursal),TRIM(catpaq.descripcion),TRIM(cajas.numerocaja),cajas.fecha_cierre,cajas.usuario_cierre,NVL(ejec.nombre,''),NVL(cajas.numeroguia,''),TRIM(cajas.estatus)
					INTO cNumsucursal,cDescripcion,cNumerocaja,cFecha,cUsuario,cNombre,cNumeroGuia,cEstatus
					FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq, bdinteg:"informix".si_ejecut ejec
					WHERE cajas.tipopaquete = catpaq.tipopaquete
					AND cajas.empresa = catpaq.empresa
					AND cajas.empresa = ejec.empresa
					AND cajas.usuario_cierre = ejec.ejecutivo
					AND cajas.numsucursal = pSucursal
					AND cajas.estatus = pStatus
					ORDER BY cajas.numerocaja

					LET cCod_Ret= "000";
					RETURN cCod_Ret,NVL(cNumsucursal,''),TRIM(NVL(cDescripcion,'')),NVL(cNumerocaja,''),TRIM(NVL(cFecha,'')),TRIM(NVL(cUsuario,'')),TRIM(NVL(cNombre,'')),NVL(cNumeroGuia,''),TRIM(NVL(cEstatus,'')) WITH RESUME;
				END FOREACH;
			ELIF pStatus = "Activa" THEN--DSB 15-05-2012
				FOREACH
					SELECT  TRIM(cajas.numsucursal),TRIM(catpaq.descripcion),TRIM(cajas.numerocaja),cajas.fechaalta,cajas.usuarioalta,NVL(ejec.nombre,''),NVL(cajas.numeroguia,''),TRIM(cajas.estatus)
					INTO cNumsucursal,cDescripcion,cNumerocaja,cFecha,cUsuario,cNombre,cNumeroGuia,cEstatus
					FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq, bdinteg:"informix".si_ejecut ejec
					WHERE cajas.tipopaquete = catpaq.tipopaquete
					AND cajas.empresa = catpaq.empresa
					AND cajas.empresa =ejec.empresa
					AND cajas.usuarioalta = ejec.ejecutivo
					AND cajas.numsucursal = pSucursal
					AND cajas.estatus = pStatus
					ORDER BY cajas.numerocaja

					LET cCod_Ret= "000";
					RETURN cCod_Ret,NVL(cNumsucursal,''),TRIM(NVL(cDescripcion,'')),NVL(cNumerocaja,''),TRIM(NVL(cFecha,'')),TRIM(NVL(cUsuario,'')),TRIM(NVL(cNombre,'')),NVL(cNumeroGuia,''),TRIM(NVL(cEstatus,'')) WITH RESUME;
				END FOREACH;
			ELIF pStatus = "Todas" THEN
				FOREACH
					SELECT TRIM(cajas.numsucursal),TRIM(catpaq.descripcion),TRIM(cajas.numerocaja),NVL(cajas.numeroguia,''),TRIM(cajas.estatus)
					INTO cNumsucursal,cDescripcion,cNumerocaja,cNumeroGuia,cEstatus
					FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq
					WHERE cajas.tipopaquete = catpaq.tipopaquete
					AND cajas.empresa = catpaq.empresa
					AND cajas.numsucursal = pSucursal
					AND cajas.estatus IS NOT NULL
					ORDER BY cajas.numerocaja

					IF cEstatus = "Enviada" THEN
						SELECT  cajas.fecha_envio, cajas.usuario_envio, NVL(ejec.nombre,'')
						INTO cFecha,cUsuario,cNombre
						FROM bdisuc:"informix".ss_numcajas cajas, bdinteg:"informix".si_ejecut ejec
						WHERE cajas.empresa = ejec.empresa
						AND cajas.usuario_envio = ejec.ejecutivo
						AND cajas.numsucursal = pSucursal
						AND cajas.numerocaja = cNumerocaja;
					ELIF cEstatus = "Cerrada" THEN
						SELECT  cajas.fecha_cierre, cajas.usuario_cierre, NVL(ejec.nombre,'')
						INTO cFecha,cUsuario,cNombre
						FROM bdisuc:"informix".ss_numcajas cajas, bdinteg:"informix".si_ejecut ejec
						WHERE cajas.empresa = ejec.empresa
						AND cajas.usuario_cierre = ejec.ejecutivo
						AND cajas.numsucursal = pSucursal
						AND cajas.numerocaja = cNumerocaja;
					ELIF cEstatus = "Activa" THEN
						SELECT  cajas.fechaalta, cajas.usuarioalta, NVL(ejec.nombre,'')
						INTO cFecha,cUsuario,cNombre
						FROM bdisuc:"informix".ss_numcajas cajas, bdinteg:"informix".si_ejecut ejec
						WHERE cajas.empresa = ejec.empresa
						AND cajas.usuarioalta = ejec.ejecutivo
						AND cajas.numsucursal = pSucursal
						AND cajas.numerocaja = cNumerocaja;
					END IF

					LET cCod_Ret= "000";
					RETURN cCod_Ret,NVL(cNumsucursal,''),TRIM(NVL(cDescripcion,'')),NVL(cNumerocaja,''),TRIM(NVL(cFecha,'')),TRIM(NVL(cUsuario,'')),TRIM(NVL(cNombre,'')),NVL(cNumeroGuia,''),TRIM(NVL(cEstatus,'')) WITH RESUME;
				END FOREACH;
			END IF;
		ELIF pOpcion = '2' THEN
			-- busca por status
			IF pStatus = "Enviada" THEN
				FOREACH
					SELECT  TRIM(cajas.numsucursal),TRIM(catpaq.descripcion),TRIM(cajas.numerocaja),cajas.fecha_envio,cajas.usuario_envio,NVL(ejec.nombre,''),NVL(cajas.numeroguia,''),TRIM(cajas.estatus)
					INTO cNumsucursal,cDescripcion,cNumerocaja,cFecha,cUsuario,cNombre,cNumeroGuia,cEstatus
					FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq, bdinteg:"informix".si_ejecut ejec
					WHERE cajas.tipopaquete = catpaq.tipopaquete
					AND cajas.empresa = catpaq.empresa
					AND cajas.empresa = ejec.empresa
					AND cajas.usuario_envio = ejec.ejecutivo
					AND cajas.estatus = pStatus
					ORDER BY cajas.numerocaja

					LET cCod_Ret= "000";
					RETURN cCod_Ret,NVL(cNumsucursal,''),TRIM(NVL(cDescripcion,'')),NVL(cNumerocaja,''),TRIM(NVL(cFecha,'')),TRIM(NVL(cUsuario,'')),TRIM(NVL(cNombre,'')),NVL(cNumeroGuia,''),TRIM(NVL(cEstatus,'')) WITH RESUME;
				END FOREACH;
			ELIF pStatus = "Cerrada" THEN
				FOREACH
					SELECT  TRIM(cajas.numsucursal),TRIM(catpaq.descripcion),TRIM(cajas.numerocaja),cajas.fecha_cierre,cajas.usuario_cierre,NVL(ejec.nombre,''),NVL(cajas.numeroguia,''),TRIM(cajas.estatus)
					INTO cNumsucursal,cDescripcion,cNumerocaja,cFecha,cUsuario,cNombre,cNumeroGuia,cEstatus
					FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq, bdinteg:"informix".si_ejecut ejec
					WHERE cajas.tipopaquete = catpaq.tipopaquete
					AND cajas.empresa = catpaq.empresa
					AND cajas.empresa = ejec.empresa
					AND cajas.usuario_cierre = ejec.ejecutivo
					AND cajas.estatus = pStatus
					ORDER BY cajas.numerocaja

					LET cCod_Ret= "000";
					RETURN cCod_Ret,NVL(cNumsucursal,''),TRIM(NVL(cDescripcion,'')),NVL(cNumerocaja,''),TRIM(NVL(cFecha,'')),TRIM(NVL(cUsuario,'')),TRIM(NVL(cNombre,'')),NVL(cNumeroGuia,''),TRIM(NVL(cEstatus,'')) WITH RESUME;
				END FOREACH;
			ELIF pStatus = "Activa" THEN--DSB 15-05-2012
				FOREACH
					SELECT  TRIM(cajas.numsucursal),TRIM(catpaq.descripcion),TRIM(cajas.numerocaja),cajas.fechaalta,cajas.usuarioalta,NVL(ejec.nombre,''),NVL(cajas.numeroguia,''),TRIM(cajas.estatus)
					INTO cNumsucursal,cDescripcion,cNumerocaja,cFecha,cUsuario,cNombre,cNumeroGuia,cEstatus
					FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq, bdinteg:"informix".si_ejecut ejec
					WHERE cajas.tipopaquete = catpaq.tipopaquete
					AND cajas.empresa = catpaq.empresa
					AND cajas.empresa =ejec.empresa
					AND cajas.usuarioalta = ejec.ejecutivo
					AND cajas.estatus = pStatus
					ORDER BY cajas.numerocaja

					LET cCod_Ret= "000";
					RETURN cCod_Ret,NVL(cNumsucursal,''),TRIM(NVL(cDescripcion,'')),NVL(cNumerocaja,''),TRIM(NVL(cFecha,'')),TRIM(NVL(cUsuario,'')),TRIM(NVL(cNombre,'')),NVL(cNumeroGuia,''),TRIM(NVL(cEstatus,'')) WITH RESUME;
				END FOREACH;
			ELIF pStatus = "Todas" THEN
				FOREACH
					SELECT TRIM(cajas.numsucursal),TRIM(catpaq.descripcion),TRIM(cajas.numerocaja),NVL(cajas.numeroguia,''),TRIM(cajas.estatus)
					INTO cNumsucursal,cDescripcion,cNumerocaja,cNumeroGuia,cEstatus
					FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq
					WHERE cajas.tipopaquete = catpaq.tipopaquete
					AND cajas.empresa = catpaq.empresa
					AND cajas.estatus IS NOT NULL
					ORDER BY cajas.numerocaja

					IF cEstatus = "Enviada" THEN
						SELECT  cajas.fecha_envio, cajas.usuario_envio, NVL(ejec.nombre,'')
						INTO cFecha,cUsuario,cNombre
						FROM bdisuc:"informix".ss_numcajas cajas, bdinteg:"informix".si_ejecut ejec
						WHERE cajas.empresa = ejec.empresa
						AND cajas.usuario_envio = ejec.ejecutivo
						AND cajas.numerocaja = cNumerocaja;
					ELIF cEstatus = "Cerrada" THEN
						SELECT  cajas.fecha_cierre, cajas.usuario_cierre, NVL(ejec.nombre,'')
						INTO cFecha,cUsuario,cNombre
						FROM bdisuc:"informix".ss_numcajas cajas, bdinteg:"informix".si_ejecut ejec
						WHERE cajas.empresa = ejec.empresa
						AND cajas.usuario_cierre = ejec.ejecutivo
						AND cajas.numerocaja = cNumerocaja;
					ELIF cEstatus = "Activa" THEN
						SELECT  cajas.fechaalta, cajas.usuarioalta, NVL(ejec.nombre,'')
						INTO cFecha,cUsuario,cNombre
						FROM bdisuc:"informix".ss_numcajas cajas, bdinteg:"informix".si_ejecut ejec
						WHERE cajas.empresa = ejec.empresa
						AND cajas.usuarioalta = ejec.ejecutivo
						AND cajas.numerocaja = cNumerocaja;
					END IF
					LET cCod_Ret= "000";
					RETURN cCod_Ret,NVL(cNumsucursal,''),TRIM(NVL(cDescripcion,'')),NVL(cNumerocaja,''),TRIM(NVL(cFecha,'')),TRIM(NVL(cUsuario,'')),TRIM(NVL(cNombre,'')),NVL(cNumeroGuia,''),TRIM(NVL(cEstatus,'')) WITH RESUME;
				END FOREACH;
			END IF;
		END IF;

		IF cCod_Ret= "001" THEN
			RETURN cCod_Ret,NVL(cNumsucursal,''),TRIM(NVL(cDescripcion,'')),NVL(cNumerocaja,''),TRIM(NVL(cFecha,'')),TRIM(NVL(cUsuario,'')),TRIM(NVL(cNombre,'')),NVL(cNumeroGuia,''),TRIM(NVL(cEstatus,''));
		END IF;
END
END PROCEDURE
DOCUMENT 
'ELABORO: Josue Zepeda',
'FECHA MODIFICACION: 09 Abril del 2012',
'DESCRIPCION: Se crea sp_ConsEstatusCaja para hacer busqueda por caja, sucursal y status',
'VERSION: 20120409.1200',
'BD: BDISUC',
'MODIFICO: Josue Zepeda',
'FECHA MODIFICACION: 15 Mayo del 2012',
'DESCRIPCION: Se agregaron al IF los estatus Activa y Todas',
'VERSION: 20120515.0524',
'BD: BDISUC',
'-----------------------',
'Modifico: Claudio Almodovar',
'Fecha: 14/10/2015',
'Modificacion: se modifican la longuitud de los parametros de salida',
'Folio: 1759';

CREATE PROCEDURE "informix".sp_consulta_doctos_admon(pEmpresa CHAR(3),
												     pSucursal CHAR(4),
												     pNumeroCaja CHAR(10),
												     pFechaInicio DATE,
												     pValor INTEGER) 
--DATOS A REGRESAR---												 
	RETURNING
	CHAR(6)      AS cCodRet,
	CHAR(10)     As cNumeroCaja,
	CHAR(10)     As cFecha,
	CHAR(80)     As cDescripcion,
	CHAR(20)     As cEstatus,
	CHAR(55)     As cUsuarioRegistro,
	CHAR(55)     As cUsuarioAutorizo
		
---DECLARACIONES
DEFINE iSqlErr         	INTEGER;
DEFINE cCodRet         	CHAR(6);
DEFINE cSucursal        CHAR(4);
DEFINE cNumeroCaja      CHAR(10);
DEFINE cNumCaja      	CHAR(10);
DEFINE sTipoDoc         SMALLINT;
DEFINE sTipoDoc2        SMALLINT;
DEFINE cDescripcion     CHAR(80);
DEFINE cEstatus         CHAR(20);
DEFINE cFecha           CHAR(10);
DEFINE cFechaFinal      CHAR(10);
DEFINE cUsuarioRegistro CHAR(55);
DEFINE cUsuarioAutorizo CHAR(55);
DEFINE cEjecutivo 		CHAR(8);
DEFINE cNomEmpleado 	CHAR(45);

---INICIALIZACIONES
LET iSqlErr          = 0;
LET cCodRet          = "000000";
LET cSucursal        = "";
LET cNumeroCaja      = "";
LET cNumCaja         = "";
LET sTipoDoc         = 0;
LET sTipoDoc2        = 0;
LET cDescripcion     = "";
LET cEstatus         = "";
LET cFecha           = "";
LET cFechaFinal      = "";
LET cUsuarioRegistro = "";
LET cUsuarioAutorizo = "";
LET cEjecutivo 		 = "";
LET cNomEmpleado	 = "";

BEGIN
    ON EXCEPTION SET iSqlErr	
	IF 	iSqlErr <> 0 THEN
		LET cCodRet = iSqlErr;
		RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo;
	END IF;
END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/home/tmp/jairo/sp_consulta_doctos_admon.out";
	--TRACE ON;
		
	IF NVL(pEmpresa,"") = "" OR (NVL(pSucursal,"") = "" AND NVL(pNumeroCaja,"") = "" AND (pFechaInicio = "01-01-1900" AND pValor = 0)) THEN
		LET cCodRet = "000222";
		RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo;	
	ELSE	
	
		IF pSucursal <> "" THEN
			SELECT sucursal
			INTO cSucursal
			FROM bdinteg:"informix".si_sucursales
			WHERE empresa = pEmpresa
			AND sucursal = pSucursal;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodRet = "000221";
				RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo;	
			END IF;
		END IF;			
		
		SELECT LIMIT 1 numerocaja
		INTO   cNumCaja
		FROM bdisuc:"informix".ss_documentosadmon
		WHERE empresa = pEmpresa
		AND numerocaja = (CASE WHEN pNumeroCaja <> "" THEN pNumeroCaja ELSE numerocaja END)
		AND	sucursal = (CASE WHEN pSucursal <> "" THEN pSucursal ELSE sucursal END)
		AND	fechainicio = (CASE WHEN pFechaInicio = "01-01-1900" AND pValor = 0 THEN fechainicio ELSE pFechaInicio END);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = "000224";
			RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo;	
		END IF;
		
		IF pNumeroCaja <> "" THEN
				FOREACH
					SELECT cat.tipodocumento, cat.descripcion,
						   CASE WHEN NVL(adm.estatus,'') = '' THEN 'N' ELSE adm.estatus END, 						  
						   NVL(adm.fechainicio,''),
						   adm.fechafinal, adm.sucursal,
						   CASE WHEN NVL(adm.numerocaja,'') = "" THEN pNumeroCaja ELSE adm.numerocaja END, 
						   CASE WHEN NVL(adm.usuarioregistra,'') = "" THEN "" ELSE adm.usuarioregistra END, 
						   CASE WHEN NVL(adm.usuarioautoriza,'') = "" THEN "" ELSE adm.usuarioautoriza END,adm.tipodocumento 

					INTO  sTipoDoc,cDescripcion,
						  cEstatus,cFecha,
						  cFechaFinal,cSucursal,
						  cNumeroCaja,cUsuarioRegistro, 
						  cUsuarioAutorizo,sTipoDoc2

					FROM  bdisuc:"informix".ss_cattipodocumento cat,		
						  OUTER bdisuc:"informix".ss_documentosadmon adm

					WHERE adm.empresa = pEmpresa
					AND cat.empresa = adm.empresa
					AND adm.numerocaja = (CASE WHEN pNumeroCaja <> "" THEN pNumeroCaja ELSE adm.numerocaja END)
					AND	adm.sucursal = (CASE WHEN pSucursal <> "" THEN pSucursal ELSE adm.sucursal END)
					AND	adm.fechainicio = (CASE WHEN pFechaInicio = '01-01-1900' AND pValor = 0 THEN adm.fechainicio ELSE pFechaInicio END)
					AND cat.tipodocumento = adm.tipodocumento
					
					ORDER BY 1,4 ASC
							 
					IF pSucursal <> "" THEN
						IF cSucursal = "" THEN
							LET cCodRet = "000221";
							RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo;
						END IF;
					END IF;
												
					IF pFechaInicio <> '01-01-1900' AND pValor = 0 THEN 
						IF nvl(cFecha,'') = '' THEN
							If sTipoDoc2 <> 0 AND  nvl(cFecha,'') <> pFechaInicio THEN
								CONTINUE FOREACH;
							END IF;					
						END IF;
					END IF;
					
					IF cEstatus <> '' THEN
						IF cEstatus = UPPER("R") THEN
							LET cEstatus = "Registrado";		
						ELIF cEstatus = UPPER("C") THEN
							CONTINUE FOREACH;
						ELIF cEstatus = UPPER("N") THEN
							LET cEstatus = "No Registrado";
						END IF;
					END IF;
										
					IF cUsuarioRegistro <> '' AND cUsuarioAutorizo <> '' THEN
						SELECT ejecutivo, nombre
						INTO cEjecutivo, cNomEmpleado
						FROM bdinteg:"informix".si_ejecut 
						WHERE empresa = pEmpresa 
						AND ejecutivo = cUsuarioRegistro;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = "000223";
							RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo;
						ELSE			
							LET cUsuarioRegistro = cEjecutivo || " - " || cNomEmpleado;			
						END IF;
																		
						SELECT ejecutivo, nombre
						INTO cEjecutivo, cNomEmpleado
						FROM bdinteg:"informix".si_ejecut 
						WHERE empresa = pEmpresa 
						AND ejecutivo = cUsuarioAutorizo;
						
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = "000223";
							RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo;
						ELSE			
							LET cUsuarioAutorizo = cEjecutivo || " - " || cNomEmpleado;			
						END IF;
					END IF;

					RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo WITH RESUME;
			
				END FOREACH;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
					LET cCodRet = "000223";
					RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo;
				END IF;
		ELSE		
				FOREACH
					SELECT cat.tipodocumento, cat.descripcion,
						   adm.estatus,  NVL(adm.fechainicio,''),
						   adm.fechafinal, adm.sucursal,
						   adm.numerocaja, adm.usuarioregistra, 
						   adm.usuarioautoriza

					INTO  sTipoDoc,cDescripcion,
						  cEstatus, cFecha,
						  cFechaFinal, cSucursal,
						  cNumeroCaja, cUsuarioRegistro, 
						  cUsuarioAutorizo

					FROM  bdisuc:"informix".ss_cattipodocumento cat,		
						  bdisuc:"informix".ss_documentosadmon adm

					WHERE adm.empresa = pEmpresa
					AND cat.empresa = adm.empresa
					AND adm.numerocaja = (CASE WHEN pNumeroCaja <> '' THEN pNumeroCaja ELSE adm.numerocaja END)
					AND	adm.sucursal = (CASE WHEN pSucursal <> '' THEN pSucursal ELSE adm.sucursal END)
					AND cat.tipodocumento = adm.tipodocumento
					AND	adm.fechainicio = (CASE WHEN pFechaInicio = '01-01-1900' AND pValor = 0 THEN adm.fechainicio ELSE pFechaInicio END)
					ORDER BY adm.numerocaja, 
							 cat.tipodocumento,
							 adm.fechainicio ASC
							 
					IF pSucursal <> '' THEN
						IF cSucursal = '' THEN
							LET cCodRet = "000221";
							RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo;
						END IF;
					END IF;
					
					IF pFechaInicio <> '01-01-1900' AND pValor = 0 THEN
						IF cFecha = "" THEN
							LET cCodRet = "000223";
							RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo;
						END IF;
					END IF;
					
					IF cEstatus <> "" THEN
						IF cEstatus = UPPER("R") THEN
							LET cEstatus = "Registrado";		
						ELIF cEstatus = UPPER("C") THEN
							CONTINUE FOREACH;
						ELIF cEstatus = UPPER("N") THEN
							LET cEstatus = "No Registrado";
						END IF;
					END IF;
				
					SELECT ejecutivo, nombre
					INTO cEjecutivo, cNomEmpleado
					FROM bdinteg:"informix".si_ejecut 
					WHERE empresa = pEmpresa 
					AND ejecutivo = cUsuarioRegistro;
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = "000223";
						RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo;
					ELSE			
						LET cUsuarioRegistro = cEjecutivo || " - " || cNomEmpleado;			
					END IF;
					
					SELECT ejecutivo, nombre
					INTO cEjecutivo, cNomEmpleado
					FROM bdinteg:"informix".si_ejecut 
					WHERE empresa = pEmpresa 
					AND ejecutivo = cUsuarioAutorizo;
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = "000223";
						RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo;
					ELSE			
						LET cUsuarioAutorizo = cEjecutivo || " - " || cNomEmpleado;			
					END IF;
					
					RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo WITH RESUME;
			
				END FOREACH;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN 
					LET cCodRet = "000223";
					RETURN cCodRet,cNumeroCaja,NVL(cFecha,''),cDescripcion,cEstatus,cUsuarioRegistro,cUsuarioAutorizo;
				END IF;
	
		END IF;
	END IF;	
END;
END PROCEDURE
DOCUMENT
'cCodRet = 000000 Operacion Exitosa.',
'cCodRet = 000221 No se encontro sucursal.',
'cCodRet = 000222 Parametros de entrada invalidos.',
'cCodRet = 000223 No se encontro informacion para la consulta.',
'cCodRet = 000224 No se encontro informacion de la caja.',
'Folio: 1759',
'Autor: 95975071 Jairo Valdez Gonzalez',
'Fecha: 23/10/2015',
'Modificación: Se crea procedimiento almacenado para consultar los documentos administrativos por sucursal, fecha o numero de caja.',
'Sustento: RQM 08 010 Registro y control de documentos administrativos.pdf',
'Solicita: Rodolfo Gomez',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consulta_suc_relacionadas(pEmpresa CHAR(3),pSucursal CHAR(4),pRegistro INTEGER)
--DATOS A REGRESAR---
RETURNING	CHAR(6) AS cCodRet,
			CHAR(4) AS cSucRelacionada,
			CHAR(10) AS cMatriz;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet			CHAR(6);
DEFINE  cSucRelacionada	CHAR(4);
DEFINE  cMatriz			CHAR(10);
DEFINE  iSqlErr			INTEGER;
DEFINE	iConteo			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet			= '000000';
LET cSucRelacionada	= '';
LET cMatriz			= '';
LET iSqlErr			= 0;
LET iConteo			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cSucRelacionada,cMatriz;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/tmp/jairo/sp_consulta_suc_relacionadas.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' THEN

		SELECT sucursal INTO cSucRelacionada
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa AND sucursal = pSucursal;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '001309';
		ELSE
			
				SELECT LIMIT 1 sucursal_matriz INTO cSucRelacionada
				FROM bdisuc:"informix".ss_sucursalesrelacionadas
				WHERE empresa = pEmpresa
				AND sucursal_matriz = pSucursal AND status_relacion = 'A';

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '001309';				
				ELSE
					IF pRegistro = 0 THEN
						LET cMatriz = '';
						LET cMatriz = '(Matriz)';
						RETURN cCodRet,cSucRelacionada,cMatriz WITH RESUME;
					ELSE 
						LET cMatriz = '';
					END IF;			
				END IF;		
			
			LET cMatriz = '';

			FOREACH
				SELECT sucursal_relacionada INTO cSucRelacionada
				FROM bdisuc:"informix".ss_sucursalesrelacionadas
				WHERE empresa = pEmpresa
				AND sucursal_matriz = pSucursal 
				AND status_relacion = 'A'
				ORDER BY sucursal_relacionada ASC

				LET iConteo = iConteo + 1;
				IF iConteo <= pRegistro -1 THEN
					CONTINUE FOREACH;
				END IF;

				IF NVL(cSucRelacionada,'') = pSucursal THEN
					CONTINUE FOREACH;
				END IF;
				RETURN cCodRet,cSucRelacionada,cMatriz WITH RESUME;
			END FOREACH;

			IF iConteo = 0 THEN
				LET cCodRet ='000001';
			END IF;
		END IF;
	ELSE
		LET cCodRet ='001308';
	END IF;

	IF NVL(cCodRet,'') <> '000000' THEN
		RETURN cCodRet,cSucRelacionada,cMatriz;
	END IF;	
END;
END PROCEDURE
DOCUMENT
'000000 - Retorna Sucursales',
'001308 - Parametros Incompletos',
'001309 - No Existe la Sucursal en si_sucursales',
'000001 - No Existe la Sucursal en ss_sucursalesrelacionadas',
'DESCRIPCION: Consulta sucursales relacionadas',
'AUTOR: Claudio Almodovar',
'Folio: 1759',
'Solicita: Rodolfo Gómez',
'FECHA: 16/10/2015',
'BD: bdisuc',
'DESCRIPCION: Se modifica sp para poner en primer lugar la sucursal matriz',
'AUTOR: Jairo Valdez Gonzalez',
'Folio: 1772',
'Solicita: Rodolfo Gómez',
'FECHA: 10/12/2015',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_genera_numcaja(pEmpresa CHAR(3),pSucursal CHAR(4))
--DATOS A REGRESAR---
RETURNING	CHAR(6) AS cCodRet,
			CHAR(10) AS cNuevaCaja,
			CHAR(10) AS cCajaAnt;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet			CHAR(6);
DEFINE  cSuc			CHAR(4);
DEFINE  cNuevaCaja		CHAR(10);
DEFINE  cCajaAnt		CHAR(10);
DEFINE  cFechaHoy		CHAR(10);
DEFINE  cMes			CHAR(2);
DEFINE  cAno			CHAR(2);
DEFINE  cSecuencia		CHAR(2);
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet			= '000000';
LET cSuc			= '';
LET cNuevaCaja		= '';
LET cCajaAnt		= '';
LET cFechaHoy		= '';
LET cMes			= '';
LET cAno			= '';
LET cSecuencia		= '';
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cNuevaCaja,cCajaAnt;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_genera_numcaja.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' THEN

		SELECT sucursal INTO cSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa AND sucursal = pSucursal;

		IF NVL(cSuc,'') = '' THEN
			LET cCodret = '001309';
		ELSE
			SELECT fecha_hoy INTO cFechaHoy
			FROM bdinteg:"informix".si_fechas
			WHERE empresa = pEmpresa;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodret = '001309';
			ELSE
				LET cAno = SUBSTR(cFechaHoy,9,2);
				LET cMes = SUBSTR(cFechaHoy,1,2);

				SELECT MAX(numerocaja) INTO cCajaAnt
				FROM bdisuc:"informix".ss_numcajas
				WHERE numsucursal = pSucursal
				AND SUBSTR(numerocaja,7,2) = cAno
				AND SUBSTR(numerocaja,5,2) = cMes;

				IF NVL(cCajaAnt,'') = '' THEN
					LET cCajaAnt = '';
					LET cSecuencia = '01';
					LET cNuevaCaja = pSucursal || cMes || cAno || cSecuencia;
				ELSE
					LET cSecuencia = SUBSTR(cCajaAnt,9,2);
					LET cSecuencia = LPAD(TRIM(cSecuencia),2,'0');

					IF NVL(cSecuencia,'') = '99' THEN
						LET cCodRet ='001316';
					ELSE
						LET cSecuencia = cSecuencia + 1;
						LET cSecuencia = LPAD(TRIM(cSecuencia),2,'0');
						LET cNuevaCaja = pSucursal || cMes || cAno || cSecuencia;
					END IF;
				END IF;
			END IF;
		END IF;
	ELSE
		LET cCodRet ='001308';
	END IF

	RETURN cCodRet,cNuevaCaja,cCajaAnt;
END;
END PROCEDURE
DOCUMENT
'000000 - Retorna Sucursales',
'001308 - Parametros Incompletos',
'001309 - No Existe la Sucursal en si_sucursales',
'001316 - Cajas llenas para el mes actual',
'DESCRIPCION: Genera l numero de caja',
'AUTOR: Claudio Almodovar',
'Folio: 1759',
'Solicita: Rodolfo Gómez',
'FECHA: 16/10/2015',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_inserta_doctos_admin(pEmpresa CHAR(3),pSucursal CHAR(4),pNumeroCaja CHAR(10),pTipoDocto SMALLINT,pFechaInicio DATE,pFechaFinal DATE,pEstatus CHAR(1),pUsuarioRegistra CHAR(8),pUsuarioAutoriza CHAR(8))
--DATOS A REGRESAR---
RETURNING	CHAR(6) AS cCodRet;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet			CHAR(6);
DEFINE  cSuc			CHAR(4);
DEFINE  cCajaAnt		CHAR(10);
DEFINE  sTipoDoctoT		SMALLINT;
DEFINE  cEstatus		CHAR(10);
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet			= '000000';
LET cSuc			= '';
LET cCajaAnt		= '';
LET sTipoDoctoT		= 0;
LET cEstatus		= '';
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/tmp/jairo/sp_inserta_doctos_admin.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' AND NVL(pNumeroCaja,'') <> '' AND NVL(pTipoDocto,0) <> 0 AND NVL(pFechaInicio,'') <> '' AND NVL(pFechaFinal,'') <> '' AND NVL(pEstatus,'') <> '' AND NVL(pUsuarioRegistra,'') <> '' AND NVL(pUsuarioAutoriza,'') <> '' THEN

		SELECT sucursal INTO cSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa AND sucursal = pSucursal;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '001309';
		ELSE
			SELECT numerocaja,estatus INTO cCajaAnt,cEstatus
			FROM bdisuc:"informix".ss_numcajas 
			WHERE empresa = pEmpresa AND numsucursal = pSucursal
			AND numerocaja = pNumeroCaja;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodret = '001309';
			ELSE
				
				IF cEstatus = 'Cerrada' THEN
					LET cCodret = '001328';
				ELIF cEstatus = 'Enviada' THEN
					LET cCodret = '001329';
				ELIF cEstatus = 'Eliminada' THEN
					LET cCodret = '001330';
				ELIF cEstatus = 'Activa' THEN
					
					SELECT tipodocumento INTO sTipoDoctoT
					FROM bdisuc:"informix".ss_cattipodocumento
					WHERE empresa = pEmpresa AND tipodocumento = pTipoDocto AND estatus = 'a';

					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodret = '001309';
					ELSE
						INSERT INTO bdisuc:"informix".ss_documentosadmon (empresa,numerocaja,tipodocumento,fechainicio,fechafinal,sucursal,estatus,usuarioregistra,usuarioautoriza,fecha_insert) 
						VALUES(pEmpresa,pNumeroCaja,pTipoDocto,pFechaInicio,pFechaFinal,pSucursal,pEstatus,pUsuarioRegistra,pUsuarioAutoriza,CURRENT);
					END IF;					
				END IF;							
			END IF;
		END IF;
	ELSE
		LET cCodRet ='001308';
	END IF
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'000000 - Exito',
'001309 - No Existe la Sucursal en si_sucursales',
'001328 - La caja se encuentra Cerrada.',
'001329 - La caja se encuentra Enviada.',
'001330 - La caja se encuentra Eliminada.',
'DESCRIPCION: Genera l numero de caja',
'AUTOR: Claudio Almodovar',
'Folio: 1759',
'Solicita: Rodolfo Gómez',
'FECHA: 16/10/2015',
'BD: bdisuc',
'DESCRIPCION: Se modifica sp para retornar nuevos codigos cuando los estatus de cajas sean Cerrada,Enviada y Activa.',
'AUTOR: Jairo Valdez Gonzalez',
'Folio: 1772',
'Solicita: Rodolfo Gómez',
'FECHA: 10/12/2015',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_inserta_numcaja(pEmpresa CHAR(3),pSucursal CHAR(4),pNumeroCaja CHAR(10),pUsuario CHAR(8),pSucursalCaja CHAR(4))
--DATOS A REGRESAR---
RETURNING	CHAR(6) AS cCodRet;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet			CHAR(6);
DEFINE  cSuc			CHAR(4);
DEFINE  cCajaAnt		CHAR(10);
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet			= '000000';
LET cSuc			= '';
LET cCajaAnt		= '';
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_inserta_numcaja.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' AND NVL(pNumeroCaja,'') <> '' AND NVL(pUsuario,'') <> '' AND NVL(pSucursalCaja,'') <> '' THEN

		SELECT sucursal INTO cSuc
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa AND sucursal = pSucursal;

		IF NVL(cSuc,'') = '' THEN
			LET cCodret = '001309';
		ELSE
			SELECT sucursal INTO cSuc
			FROM bdinteg:"informix".si_sucursales
			WHERE empresa = pEmpresa AND sucursal = pSucursalCaja;

			IF NVL(cSuc,'') = '' THEN
				LET cCodret = '001309';
			ELSE
				SELECT numerocaja INTO cCajaAnt
				FROM bdisuc:"informix".ss_numcajas WHERE empresa = pEmpresa
				AND numsucursal = pSucursalCaja AND numerocaja = pNumeroCaja;
				
				IF NVL(cCajaAnt,'') <> '' THEN
					LET cCodret = '001312';
				ELSE
					INSERT INTO bdisuc:"informix".ss_numcajas (empresa,numerocaja,numsucursal,numsuc_crea,tipopaquete,fecha_insert,estatus,usuarioalta,fechaalta,numempleado_cajaocupada,fecha_cajaocupada) 
					VALUES (pEmpresa,pNumeroCaja,pSucursalCaja,pSucursal,3,CURRENT,'Activa',pUsuario,CURRENT,pUsuario,CURRENT);					
				END IF;
			END IF;
		END IF;
	ELSE
		LET cCodRet ='001308';
	END IF
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'000000 - Retorna Sucursales',
'001308 - Parametros Incompletos',
'001309 - No Existe la Sucursal en si_sucursales',
'001316 - Cajas llenas para el mes actual',
'DESCRIPCION: Genera l numero de caja',
'AUTOR: Claudio Almodovar',
'Folio: 1759',
'Solicita: Rodolfo Gómez',
'FECHA: 16/10/2015',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_insertaestatuscaja(pvSucursal VARCHAR(5),pvDescrip VARCHAR(80), pvNumCaja VARCHAR(12),pvFecha VARCHAR(10),pvNumEmple VARCHAR(8),pvAutorizo VARCHAR(40),pvCodigoRas VARCHAR(20),pvStatus VARCHAR(7),pvItipo INTEGER)

RETURNING CHAR(5);

--DEFINICION DE VARIABLES
DEFINE cCod_Ret      CHAR(5);
DEFINE isqlerr       INTEGER ;

--INICIALIZACION DE VARIABLES
LET cCod_Ret       = "00001";
LET isqlerr 	   = 0;

BEGIN

    ON EXCEPTION  SET isqlerr
        IF isqlerr <> 0  THEN
            LET  cCod_Ret  = isqlerr;
            RETURN cCod_Ret;
        END IF;
    END  EXCEPTION;
	
	--SET DEBUG FILE TO 'home/tmp/jairo/sp_Insertaestatuscaja.out';
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	
	IF pvItipo = '1' THEN 
		DELETE FROM  bdinteg:"informix".vtmpEstatuscaja;
		LET cCod_Ret  = "00000";
	ELSE	
        IF 	pvNumCaja <> "" THEN 
			INSERT INTO bdinteg:"informix".vtmpestatuscaja(sucursal,descripcion,numero_caja,fecha,numero_empleado,nombre_autorizo,codigo_rastreo,estatus)
			VALUES (pvSucursal,pvDescrip,pvNumCaja,pvFecha,pvNumEmple,pvAutorizo,pvCodigoRas,pvStatus);		
			LET cCod_Ret  = "00000";
		else
		LET cCod_Ret  = "00001";
		END IF		
	END IF;		

	RETURN cCod_Ret;
	
END
END PROCEDURE
DOCUMENT 
'ELABORO: Josue Zepeda',
'DESCRIPCION: Inserta y borra datos de tabla temporal para impresiÃ³n de reporte ',
'para Modulo de autorizaciÃ³n de cierre y enviÃ³ de caja a resguardo,ConsEstCaja',
'FECHA: 24/04/2012',
'BD: BDISUC',
'ELABORO: Jairo Valdez Gonzalez',
'DESCRIPCION: Se realiza modificacion para insertar la informacion consultada de los estatus de las cajas.',
'FECHA: 23/10/2015',
'FOLIO: 1759',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_autenviocaja(pvSucursal VARCHAR(5), pvNumcaja VARCHAR(12),pvStatus VARCHAR(10),pvOpcion VARCHAR(1), psRegistros SMALLINT, pcNumCte CHAR(20))
RETURNING CHAR(5), --CodRet
CHAR(5),           --cNumsucursal
CHAR(12),          --cNumerocaja
CHAR(30),          --cDescripcion
CHAR(10),          --cNumeroguia
CHAR(10),           --cEstatus
SMALLINT;          --sTipoPaquete


DEFINE cCod_Ret      CHAR(5);
DEFINE isqlerr       INTEGER ;
DEFINE cNumsucursal  CHAR(5);
DEFINE cNumerocaja   CHAR(12);
DEFINE cDescripcion  CHAR(30);
DEFINE cNumeroguia   CHAR(10);
DEFINE cEstatus      CHAR(10);
DEFINE sTipoPaquete  SMALLINT;


LET cCod_Ret       = "000";
LET isqlerr 	   = 0;
LET cNumsucursal   = '';
LET cNumerocaja    = '';
LET cDescripcion   = '';
LET cNumeroguia    = 0;
LET cEstatus       = '';
LET sTipoPaquete   = 0;

BEGIN
    
    ON EXCEPTION  SET isqlerr
        IF isqlerr <> 0  THEN
            LET  cCod_Ret  = isqlerr;
            RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
        END IF;
    END  EXCEPTION;

     --SET DEBUG FILE TO '/home/tmp/MireyaR/sp_autenviocaja.out';
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
		--VALIDANDO PARÁMETROS 
		IF pvOpcion = '' OR pvOpcion NOT IN ('1','2','3','4') THEN
		  LET  cCod_Ret  = '002';
		  RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		ELIF pvOpcion = '1' THEN
		  IF pvNumcaja = '' THEN
			LET  cCod_Ret  = '002';
			RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		  END IF
		ELIF pvOpcion = '2' THEN
		  IF pvSucursal = '' THEN
			LET  cCod_Ret  = '002';
			RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		  END IF
		ELIF pvOpcion = '3' THEN
		   IF pvSucursal = '' OR pvStatus = '' THEN
			 LET  cCod_Ret  = '002';
			 RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		   END IF
		ELIF pvOpcion = '4' THEN
			IF pvSucursal = '' OR pvOpcion = '' OR pcNumCte = '' THEN
			 LET  cCod_Ret  = '002';
			 RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		   END IF
		END IF
	
       IF pvOpcion = '1' THEN
	        -- busca por caja	  		
			SELECT TRIM(cajas.numsucursal),TRIM(cajas.numerocaja),TRIM(catpaq.descripcion),cajas.numeroguia,TRIM(cajas.estatus),cajas.tipopaquete
			INTO cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete
			FROM "informix".ss_numcajas cajas, "informix".ss_cattipopaquetes catpaq
			WHERE cajas.tipopaquete = catpaq.tipopaquete
			AND cajas.empresa = catpaq.empresa
			AND cajas.estatus IS NOT NULL
			AND cajas.estatus IN ('Activa','Enviada','Cerrada','Eliminada')
			AND cajas.numerocaja = TRIM(pvNumcaja);			
	   
	        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCod_Ret= "001";
			END IF;	   
	        	
            RETURN cCod_Ret,NVL(cNumsucursal,''),NVL(cNumerocaja,''),TRIM(NVL(cDescripcion,'')),TRIM(NVL(cNumeroguia,'')),NVL(cEstatus,''),NVL(sTipoPaquete,0);  				
				   
	   ELIF pvOpcion = '2' THEN
	        -- busca por Sucursal
			FOREACH WITH HOLD			
				SELECT skip psRegistros LIMIT 11 TRIM(cajas.numsucursal),TRIM(cajas.numerocaja),TRIM(catpaq.descripcion),cajas.numeroguia,TRIM(cajas.estatus),cajas.tipopaquete
				INTO cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete
				FROM "informix".ss_numcajas cajas, "informix".ss_cattipopaquetes catpaq
				WHERE cajas.tipopaquete = catpaq.tipopaquete
				AND cajas.empresa = catpaq.empresa
				--AND cajas.numsucursal = pvSucursal--dsb-31/08/2012
				AND cajas.numsuc_crea = TRIM(pvSucursal)
				AND cajas.estatus IS NOT NULL
				AND cajas.estatus IN ('Activa','Enviada','Cerrada','Eliminada')
				ORDER BY cajas.numerocaja			    
	
				RETURN cCod_Ret,NVL(cNumsucursal,''),NVL(cNumerocaja,''),TRIM(NVL(cDescripcion,'')),TRIM(NVL(cNumeroguia,'')),TRIM(NVL(cEstatus,'')),NVL(sTipoPaquete,0) WITH RESUME;
				
		    END FOREACH; 
		
	   ELIF pvOpcion = '3' THEN
	         -- busca por status
			FOREACH 
				SELECT skip psRegistros LIMIT 11 TRIM(cajas.numsucursal),TRIM(cajas.numerocaja),TRIM(catpaq.descripcion),cajas.numeroguia,TRIM(cajas.estatus),cajas.tipopaquete
				INTO cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete
				FROM "informix".ss_numcajas cajas, "informix".ss_cattipopaquetes catpaq
				WHERE cajas.tipopaquete = catpaq.tipopaquete
				AND cajas.empresa = catpaq.empresa
 				AND cajas.numsuc_crea = TRIM(pvSucursal)
				AND cajas.estatus = TRIM(pvStatus)
				ORDER BY cajas.numerocaja
							
				RETURN cCod_Ret,NVL(cNumsucursal,''),NVL(cNumerocaja,''),TRIM(NVL(cDescripcion,'')),TRIM(NVL(cNumeroguia,'')),TRIM(NVL(cEstatus,'')),NVL(sTipoPaquete,0) WITH RESUME; 
				
		    END FOREACH;
		
	   ELIF pvOpcion = '4' THEN 
			--BUSCA POR CLIENTE
			FOREACH
				SELECT DISTINCT TRIM(cajas.numsucursal),TRIM(cajas.numerocaja),TRIM(catpaq.descripcion),cajas.numeroguia,TRIM(cajas.estatus),cajas.tipopaquete
				INTO cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete 
				FROM "informix".ss_numcajas cajas, "informix".ss_cattipopaquetes catpaq, "informix".ss_expedientesclientes expcte
				WHERE cajas.tipopaquete = catpaq.tipopaquete 
				AND cajas.numerocaja = expcte. numerocaja 
				AND cajas.empresa = catpaq.empresa
				AND cajas.numsucursal = TRIM(pvSucursal)
				AND expcte.numerocliente = TRIM(pcNumCte) 
				AND expcte.estatus <> 'E'
							
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCod_Ret= "001";
				END IF;		
				
				RETURN cCod_Ret,NVL(cNumsucursal,''),NVL(cNumerocaja,''),TRIM(NVL(cDescripcion,'')),TRIM(NVL(cNumeroguia,'')),TRIM(NVL(cEstatus,'')),NVL(sTipoPaquete,0) WITH RESUME; 				
				
			END FOREACH;
	   END IF;  	
	   
	   IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
				LET cCod_Ret = "001";
				RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
	   END IF;	   
         
END
END PROCEDURE
DOCUMENT 
'ELABORO: Josue Zepeda',
'FECHA MODIFICACION: 09 Abril del 2012',
'DESCRIPCION: Se crea sp_AutEnvioCaja para hacer busqueda por caja, sucursal y status',
'VERSION: 20120409.1200',
'BD: BDISUC',
'MODIFICO: Victor Hugo Nuñez',
'FECHA MODIFICACION: 31 Agosto del 2012',
'DESCRIPCION: Se modifica busqueda por sucursal y por estatus para obtener las cajas relacionadas',
'VERSION: 20120831.1900',
'BD: BDISUC',
'MODIFICO: Mireya Reyes',
'FECHA MODIFICACION: 14 Febrero del 2014',
'DESCRIPCION: Se añade nuevo retorno sTipoPaquete con la finalidad de utilizarlo de parámetro de entrada',
'entrada en el sp_actestatuscaja y se agrega validación para la consulta por caja y sucursal contemplando el estatus (Eliminada).',
'VERSION: 20140211.1900',
'BD: BDISUC',
'MODIFICO:	  Ernesto Aguilera',
'FECHA:		  17/10/2014',
'DESCRIPCION: Se agrega nueva busqueda por cliente con parametro de numero de cliente y se retorna los datos de la consulta.',
'VERSION: 20141017.1630',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_autenviocajaras(pvSucursal VARCHAR(5), pvNumcaja VARCHAR(12),pvStatus VARCHAR(10),pvOpcion VARCHAR(1), psRegistros SMALLINT, pcNumCte CHAR(20))

RETURNING CHAR(5), --CodRet
CHAR(5),           --cNumsucursal
CHAR(12),          --cNumerocaja
CHAR(30),          --cDescripcion
CHAR(20),          --cNumeroguia
CHAR(10),          --cEstatus
SMALLINT;          --sTipoPaquete


DEFINE cCod_Ret      CHAR(5);
DEFINE isqlerr       INTEGER ;
DEFINE cNumsucursal  CHAR(5);
DEFINE cNumerocaja   CHAR(12);
DEFINE cDescripcion  CHAR(30);
DEFINE cNumeroguia   CHAR(20);
DEFINE cEstatus      CHAR(10);
DEFINE sTipoPaquete  SMALLINT;


LET cCod_Ret       = "000";
LET isqlerr 	   = 0;
LET cNumsucursal   = '';
LET cNumerocaja    = '';
LET cDescripcion   = '';
LET cNumeroguia    = 0;
LET cEstatus       = '';
LET sTipoPaquete   = 0;

BEGIN
    
    ON EXCEPTION  SET isqlerr
        IF isqlerr <> 0  THEN
            LET  cCod_Ret  = isqlerr;
            RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
        END IF;
    END  EXCEPTION;

     --SET DEBUG FILE TO '/home/tmp/jairo/sp_autenviocaja.out';
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
		--VALIDANDO PARÁMETROS 
		IF pvOpcion = '' OR pvOpcion NOT IN ('1','2','3','4') THEN
		  LET  cCod_Ret  = '002';
		  RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		ELIF pvOpcion = '1' THEN
		  IF pvNumcaja = '' THEN
			LET  cCod_Ret  = '002';
			RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		  END IF
		ELIF pvOpcion = '2' THEN
		  IF pvSucursal = '' THEN
			LET  cCod_Ret  = '002';
			RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		  END IF
		ELIF pvOpcion = '3' THEN
		   IF pvSucursal = '' OR pvStatus = '' THEN
			 LET  cCod_Ret  = '002';
			 RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		   END IF
		ELIF pvOpcion = '4' THEN
			IF pvSucursal = '' OR pvOpcion = '' OR pcNumCte = '' THEN
			 LET  cCod_Ret  = '002';
			 RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		   END IF
		END IF
	
       IF pvOpcion = '1' THEN
	        -- busca por caja	  		
			SELECT TRIM(cajas.numsucursal),TRIM(cajas.numerocaja),TRIM(catpaq.descripcion),cajas.numeroguia,TRIM(cajas.estatus),cajas.tipopaquete
			INTO cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete
			FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq
			WHERE cajas.tipopaquete = catpaq.tipopaquete
			AND cajas.empresa = catpaq.empresa
			AND cajas.estatus IS NOT NULL
			AND cajas.estatus IN ('Activa','Enviada','Cerrada','Eliminada')
			AND cajas.numerocaja = TRIM(pvNumcaja);			
	   
	        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCod_Ret= "001";
			END IF;	   
	        	
            RETURN cCod_Ret,NVL(cNumsucursal,''),NVL(cNumerocaja,''),TRIM(NVL(cDescripcion,'')),TRIM(NVL(cNumeroguia,'')),NVL(cEstatus,''),NVL(sTipoPaquete,0);  				
				   
	   ELIF pvOpcion = '2' THEN
	        -- busca por Sucursal
			FOREACH WITH HOLD			
				SELECT skip psRegistros LIMIT 11 TRIM(cajas.numsucursal),TRIM(cajas.numerocaja),TRIM(catpaq.descripcion),cajas.numeroguia,TRIM(cajas.estatus),cajas.tipopaquete
				INTO cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete
				FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq
				WHERE cajas.tipopaquete = catpaq.tipopaquete
				AND cajas.empresa = catpaq.empresa
				--AND cajas.numsucursal = pvSucursal--dsb-31/08/2012
				AND cajas.numsuc_crea = TRIM(pvSucursal)
				AND cajas.estatus IS NOT NULL
				AND cajas.estatus IN ('Activa','Enviada','Cerrada','Eliminada')
				ORDER BY cajas.numerocaja			    
	
				RETURN cCod_Ret,NVL(cNumsucursal,''),NVL(cNumerocaja,''),TRIM(NVL(cDescripcion,'')),TRIM(NVL(cNumeroguia,'')),TRIM(NVL(cEstatus,'')),NVL(sTipoPaquete,0) WITH RESUME;
				
		    END FOREACH; 
		
	   ELIF pvOpcion = '3' THEN
	         -- busca por status
			FOREACH 
				SELECT skip psRegistros LIMIT 11 TRIM(cajas.numsucursal),TRIM(cajas.numerocaja),TRIM(catpaq.descripcion),cajas.numeroguia,TRIM(cajas.estatus),cajas.tipopaquete
				INTO cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete
				FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq
				WHERE cajas.tipopaquete = catpaq.tipopaquete
				AND cajas.empresa = catpaq.empresa
 				AND cajas.numsuc_crea = TRIM(pvSucursal)
				AND cajas.estatus = TRIM(pvStatus)
				ORDER BY cajas.numerocaja
							
				RETURN cCod_Ret,NVL(cNumsucursal,''),NVL(cNumerocaja,''),TRIM(NVL(cDescripcion,'')),TRIM(NVL(cNumeroguia,'')),TRIM(NVL(cEstatus,'')),NVL(sTipoPaquete,0) WITH RESUME; 
				
		    END FOREACH;
		
	   ELIF pvOpcion = '4' THEN 
			--BUSCA POR CLIENTE
			FOREACH
				SELECT DISTINCT TRIM(cajas.numsucursal),TRIM(cajas.numerocaja),TRIM(catpaq.descripcion),cajas.numeroguia,TRIM(cajas.estatus),cajas.tipopaquete
				INTO cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete 
				FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq, bdisuc:"informix".ss_expedientesclientes expcte
				WHERE cajas.tipopaquete = catpaq.tipopaquete 
				AND cajas.numerocaja = expcte. numerocaja 
				AND cajas.empresa = catpaq.empresa
				AND cajas.numsucursal = TRIM(pvSucursal)
				AND expcte.numerocliente = TRIM(pcNumCte) 
				AND expcte.estatus <> 'E'
							
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCod_Ret= "001";
				END IF;		
				
				RETURN cCod_Ret,NVL(cNumsucursal,''),NVL(cNumerocaja,''),TRIM(NVL(cDescripcion,'')),TRIM(NVL(cNumeroguia,'')),TRIM(NVL(cEstatus,'')),NVL(sTipoPaquete,0) WITH RESUME; 				
				
			END FOREACH;
	   END IF;  	
	   
	   IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
				LET cCod_Ret = "001";
				RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
	   END IF;	   
         
END
END PROCEDURE
DOCUMENT 
'ELABORO: Josue Zepeda',
'FECHA MODIFICACION: 09 Abril del 2012',
'DESCRIPCION: Se crea sp_AutEnvioCaja para hacer busqueda por caja, sucursal y status',
'VERSION: 20120409.1200',
'BD: BDISUC',
'MODIFICO: Victor Hugo Nuñez',
'FECHA MODIFICACION: 31 Agosto del 2012',
'DESCRIPCION: Se modifica busqueda por sucursal y por estatus para obtener las cajas relacionadas',
'VERSION: 20120831.1900',
'BD: BDISUC',
'MODIFICO: Mireya Reyes',
'FECHA MODIFICACION: 14 Febrero del 2014',
'DESCRIPCION: Se añade nuevo retorno sTipoPaquete con la finalidad de utilizarlo de parámetro de entrada',
'entrada en el sp_actestatuscaja y se agrega validación para la consulta por caja y sucursal contemplando el estatus (Eliminada).',
'VERSION: 20140211.1900',
'BD: BDISUC',
'MODIFICO:	  Ernesto Aguilera',
'FECHA:		  17/10/2014',
'DESCRIPCION: Se agrega nueva busqueda por cliente con parametro de numero de cliente y se retorna los datos de la consulta.',
'VERSION: 20141017.1630',
'BD: BDISUC',
'MODIFICO:	  Jairo Valdez Gonzalez',
'FECHA:		  23/10/2015',
'DESCRIPCION: Se modifica parametro de retorno cNumeroguia a CHAR(20) y su respectiva variable.',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_consulta_doctos_admin(pEmpresa CHAR(3),pSucursal CHAR(4),pNumeroCaja CHAR(10),pTipo INTEGER,pRegistro INTEGER)
--DATOS A REGRESAR---
RETURNING	CHAR(6) AS cCodRet,
			SMALLINT AS cTipoDocumento,
			CHAR(80) AS cDocumento,
			CHAR(1) AS cTipoEstatus,
			CHAR(20) AS cEstatus,
			CHAR(10) AS cFechaInicio,
			CHAR(10) AS cFechaFin;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet			CHAR(6);
DEFINE  cTipoEstatus	CHAR(1);
DEFINE  cDocumento		CHAR(80);
DEFINE  cEstatus		CHAR(20);
DEFINE  cFechaInicio	CHAR(10);
DEFINE  cFechaFin		CHAR(10);
DEFINE  cCaja			CHAR(10);
DEFINE  cTipoDistinto   SMALLINT;
DEFINE	iConteo			INTEGER;
DEFINE	cTipoDocumento	SMALLINT;
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet			= '000000';
LET cTipoEstatus	= '';
LET cDocumento		= '';
LET cEstatus		= '';
LET cFechaInicio	= '';
LET cFechaFin		= '';
LET cCaja			= '';
LET cTipoDistinto   = 0;
LET iConteo			= 0;
LET cTipoDocumento	= 0;
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cTipoDocumento,cDocumento,cTipoEstatus,cEstatus,cFechaInicio,cFechaFin;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_consulta_doctos_admin.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pTipo,0) = 1 THEN
		IF NVL(pEmpresa,'') <> '' THEN

			FOREACH
				SELECT tipodocumento,descripcion INTO cTipoDocumento,cDocumento
				FROM bdisuc:"informix".ss_cattipodocumento
				WHERE empresa = pEmpresa

				LET iConteo = iConteo + 1;
				IF iConteo <= pRegistro THEN
					CONTINUE FOREACH;
				END IF;
				LET cTipoEstatus = 'N';
				LET cEstatus = 'No Registrado';

				RETURN cCodRet,cTipoDocumento,cDocumento,cTipoEstatus,cEstatus,cFechaInicio,cFechaFin WITH RESUME;
			END FOREACH;

			IF iConteo = 0 THEN
				LET cCodRet ='001309';
			END IF;
		ELSE
			LET cCodRet ='001308';
		END IF;
	ELIF NVL(pTipo,0) = 2 THEN
		IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' AND NVL(pNumeroCaja,'') <> '' THEN

				
			SELECT numerocaja, tipopaquete INTO cCaja, cTipoDistinto
			FROM bdisuc:"informix".ss_numcajas 
			WHERE empresa = pEmpresa AND numerocaja = pNumeroCaja;

			IF NVL(cCaja,'') = '' THEN
				LET cCodRet ='001320';
			ELIF cTipoDistinto <> 3 THEN
				LET cCodRet ='001334';
			ELSE
				FOREACH
					SELECT cat.tipodocumento,cat.descripcion,adm.estatus,adm.fechainicio,adm.fechafinal
					INTO cTipoDocumento,cDocumento,cTipoEstatus,cFechaInicio,cFechaFin
					FROM bdisuc:"informix".ss_cattipodocumento cat, OUTER bdisuc:"informix".ss_documentosadmon adm
					WHERE adm.numerocaja = pnumerocaja AND adm.sucursal = psucursal
					AND cat.tipodocumento = adm.tipodocumento

					LET iConteo = iConteo + 1;
					IF iConteo <= pRegistro THEN
						CONTINUE FOREACH;
					END IF;

					IF NVL(cTipoEstatus,'') = 'R' THEN
						LET cEstatus ='Registrado';
					ELIF NVL(cTipoEstatus,'') = 'C' THEN
						CONTINUE FOREACH;
					ELIF NVL(cTipoEstatus,'') = 'N' THEN
						LET cEstatus ='No Registrado';
					END IF;

					IF NVL(cFechaInicio,'') = '' THEN
						LET cFechaInicio ='';
					END IF;

					IF NVL(cFechaFin,'') = '' THEN
						LET cFechaFin ='';
					END IF;

					RETURN cCodRet,cTipoDocumento,cDocumento,cTipoEstatus,cEstatus,cFechaInicio,cFechaFin WITH RESUME;
				END FOREACH;

				IF iConteo = 0 THEN
					LET cCodRet ='001309';
				END IF;
			END IF;

		ELSE
			LET cCodRet ='001308';
		END IF;
	END IF;

	IF NVL(cCodRet,'') <> '000000' THEN
		RETURN cCodRet,cTipoDocumento,cDocumento,cTipoEstatus,cEstatus,cFechaInicio,cFechaFin;
	END IF;
END;
END PROCEDURE
DOCUMENT
'000000 - Retorna Sucursales',
'001308 - Parametros Incompletos',
'001309 - No Existe informacion',
'DESCRIPCION: Consulta documentos',
'AUTOR: Claudio Almodovar',
'Folio: 1759',
'Solicita: Rodolfo Gómez',
'FECHA: 16/10/2015',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_altamodificacion_piezas_bym(pOpcion CHAR(1), pIdDenominacion INTEGER,pNumRecibo CHAR(10), pTipoPieza CHAR(1), pSerie CHAR(40), pFolio CHAR(40), pFechaEmision DATE, pNumPiezas INTEGER, pNota CHAR(200), pNumGuia CHAR(12),pFolioBanxico CHAR(40), pDictamenBanxico INTEGER,pNumLoteBanxico CHAR(40), pEstatus INTEGER, pEjecutivo CHAR(8), pIdPieza INTEGER)
RETURNING   CHAR(6) AS CodRet,
            CHAR(80) AS Mensaje ;

-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err        	    INTEGER;
DEFINE iIsamErr        	    INTEGER;
DEFINE cErrorInfo      	    CHAR(30);	
DEFINE cCodRet              CHAR(6);
DEFINE cMensaje             CHAR(80);
DEFINE cMensaje1			CHAR(80);

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET iIsamErr           	= 0;
LET cErrorInfo         	= "";
LET cCodRet             = '000000';
LET cMensaje            ='Ejecución Exitosa';
LET cMensaje1            ="";


SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/informix/sp_altamodificacion_piezas_bym.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err, iIsamErr, cErrorInfo
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			LET cMensaje = cErrorInfo;
			RETURN cCodRet, cMensaje;
		END IF;
	END EXCEPTION; 
	
	IF TRIM(NVL(pOpcion,'')) = '1' OR TRIM(NVL(pOpcion,'')) = '2' OR TRIM(NVL(pOpcion,'')) = '3' OR TRIM(NVL(pOpcion,'')) = '4' OR TRIM(NVL(pOpcion,'')) = '5' THEN
		
		IF TRIM(NVL(pOpcion,'')) = '1' THEN
			IF NVL(pIdDenominacion,0) > 0 AND  TRIM(NVL(pNumRecibo,'')) <> '' AND NVL(pNumPiezas,0) > 0 AND NVL(pEstatus,0) > 0 AND  TRIM(NVL(pTipoPieza,'')) <> '' AND TRIM(NVL(pEjecutivo,'')) <> '' THEN
			
				IF pTipoPieza = '1' THEN
					IF TRIM(NVL(pSerie,'')) = '' OR TRIM(NVL(pFolio,'')) = '' OR TRIM(NVL(pFechaEmision,'')) = '' THEN
						LET cCodRet  = '000001';
						LET cMensaje = 'Parámetros de Entrada Vacíos';
					END IF;
				END IF;
				
				IF cCodRet = '000000' THEN
					INSERT INTO bdisuc:"informix".ss_piezas_bym_falsos (id_denominacion, num_recibo, fecha_recepcion, serie, folio, fecha_emision, num_piezas, nota, estatus, ejecutivo_insert, fecha_insert)
					VALUES (pIdDenominacion, pNumRecibo, CURRENT, Pserie, pFolio, pFechaEmision, pNumPiezas, pNota, pEstatus, pEjecutivo, CURRENT);
				END IF;
			ELSE
				LET cCodRet  = '000001';
				LET cMensaje = 'Parámetros de Entrada Vacíos';
			END IF;
			
		ELIF TRIM(NVL(pOpcion,'')) = '2' THEN
			IF TRIM(NVL(pNumRecibo,'')) <> '' AND TRIM(NVL(pEjecutivo,'')) <> '' AND  NVL(pIdPieza,0) > 0 AND TRIM(NVL(pTipoPieza,''))<>'' THEN
				IF TRIM(NVL(pTipoPieza,''))=1 THEN
					IF TRIM(NVL(pSerie,'')) <> '' AND TRIM(NVL(pFolio,'')) <> '' AND TRIM(NVL(pFechaEmision,'')) <> '' AND TRIM(NVL(pEstatus,'')) <> '' THEN
						UPDATE bdisuc:"informix".ss_piezas_bym_falsos
						SET serie=TRIM(NVL(pSerie,'')), folio=TRIM(NVL(pFolio,'')), fecha_emision=TRIM(NVL(pFechaEmision,'')),
							ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT ,Estatus = pEstatus
						WHERE num_recibo = pNumRecibo 
						AND id_pieza = pIdPieza;
					END IF
				END IF
				IF NVL(pIdDenominacion,0) > 0  THEN
						UPDATE bdisuc:"informix".ss_piezas_bym_falsos
						SET id_denominacion=NVL(pIdDenominacion,0),
						ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
						WHERE num_recibo = pNumRecibo 
						AND id_pieza = pIdPieza;
				END IF
				
				IF NVL(pNumPiezas,0) > 0 THEN
						UPDATE bdisuc:"informix".ss_piezas_bym_falsos
						SET num_piezas=NVL(pNumPiezas,0),
						ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
						WHERE num_recibo = pNumRecibo 
						AND id_pieza = pIdPieza;
				END IF
				IF TRIM(NVL(pFolioBanxico,''))<>'' THEN
						UPDATE bdisuc:"informix".ss_piezas_bym_falsos
						SET folio_banxico=TRIM(NVL(pFolioBanxico,'')),
						ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
						WHERE num_recibo = pNumRecibo 
						AND id_pieza = pIdPieza;
				END IF
				
				IF TRIM(NVL(pNumLoteBanxico,''))<>'' THEN
						UPDATE bdisuc:"informix".ss_piezas_bym_falsos
						SET num_lote_banxico=TRIM(NVL(pNumLoteBanxico,'')),
						ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
						WHERE num_recibo = pNumRecibo 
						AND id_pieza = pIdPieza;
				END IF
				
			ELSE
				LET cCodRet  = '000001';
				LET cMensaje = 'Parámetros de Entrada Vacíos';
			END IF;
		ELIF TRIM(NVL(pOpcion,'')) = '3' THEN
		
			IF TRIM(NVL(pNumRecibo,'')) <> '' AND TRIM(NVL(pNumGuia,'')) <> '' AND TRIM(NVL(pEjecutivo,'')) <> '' THEN
			
				UPDATE bdisuc:"informix".ss_piezas_bym_falsos
				SET num_guia = pNumGuia,
					ejecutivo_update = pEjecutivo,
					fecha_update = CURRENT
				WHERE num_recibo = pNumRecibo
				AND TRIM(NVL(num_guia,''))=''; 
			ELSE
				LET cCodRet  = '000001';
				LET cMensaje = 'Parámetros de Entrada Vacíos';
			END IF;
		ELIF TRIM(NVL(pOpcion,'')) = '4' THEN
			IF TRIM(NVL(pNumRecibo,'')) <> '' AND TRIM(NVL(pEjecutivo,'')) <> '' AND  NVL(pIdPieza,0) > 0 AND NVL(pEstatus,0) > 0  THEN
				UPDATE  bdisuc:"informix".ss_piezas_bym_falsos
				SET estatus=NVL(pEstatus,0), ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
				WHERE num_recibo = pNumRecibo 
				AND id_pieza = pIdPieza;
			ELSE
				LET cCodRet  = '000001';
				LET cMensaje = 'Parámetros de Entrada Vacíos';
			END IF
		ELIF TRIM(NVL(pOpcion,'')) = '5' THEN
			IF TRIM(NVL(pFolioBanxico,''))<>'' AND TRIM(NVL(pNumLoteBanxico,''))<>'' AND NVL(pDictamenBanxico,0)>0 AND NVL(pEstatus,0)>0 AND TRIM(NVL(pEjecutivo,'')) <> '' AND  NVL(pIdPieza,0)>0 THEN
				IF (SELECT COUNT(num_recibo) FROM bdisuc:"informix".ss_piezas_bym_falsos WHERE id_pieza = pIdPieza AND estatus=2 AND empresa='001')>0 THEN
					UPDATE  bdisuc:"informix".ss_piezas_bym_falsos
					SET folio_banxico=TRIM(NVL(pFolioBanxico,'')), num_lote_banxico=TRIM(NVL(pNumLoteBanxico,'')), dictamen_banxico=NVL(pDictamenBanxico,0),
						estatus=NVL(pEstatus,0), ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
					WHERE id_pieza = pIdPieza
					AND empresa='001';
				ELSE
					LET cCodRet  = '000002';
				END IF
			ELSE
				LET cCodRet  = '000001';
				LET cMensaje = 'Parámetros de Entrada Vacíos';
			END IF
		END IF;

	ELSE
		LET cCodRet  = '000001';
		LET cMensaje = 'Parámetros de Entrada Vacíos';
	END IF;
	
	IF TRIM(NVL(pOpcion,''))='2' THEN
		IF cCodRet='000000' THEN
			LET cMensaje="";
			
				SELECT descripcion 
				INTO cMensaje1
				FROM bdinteg:"informix".si_codret WHERE codigo_retorno ='265'
				AND sistema='11';
			
			LET cMensaje= TRIM(cMensaje1);

				SELECT descripcion 
				INTO cMensaje1
				FROM bdinteg:"informix".si_codret WHERE codigo_retorno ='266'
				AND sistema='11';
			LET cMensaje= TRIM(cMensaje)  || ' ' || TRIM(cMensaje1);
		END IF
	ELIF TRIM(NVL(pOpcion,''))='4' THEN
		IF cCodRet='000000' THEN
			SELECT descripcion 
			INTO cMensaje
			FROM bdinteg:"informix".si_codret 
			WHERE codigo_retorno ='263'
			AND sistema='11';
		END IF
	ELIF TRIM(NVL(pOpcion,''))='5' THEN
		IF cCodRet='000000' THEN
			SELECT descripcion 
			INTO cMensaje
			FROM bdinteg:"informix".si_codret 
			WHERE codigo_retorno ='262'
			AND sistema='11';
		ELIF cCodRet='000002' THEN
			SELECT descripcion 
			INTO cMensaje
			FROM bdinteg:"informix".si_codret 
			WHERE codigo_retorno ='264'
			AND sistema='11';
		END IF
	END IF
	RETURN cCodRet,  cMensaje;

END;    
END PROCEDURE
DOCUMENT
'REALIZO: Felipe Urias',
'FECHA: 03/02/2015',
'MODIFICO: Leslie Rendón',
'DESCRIPCION: Guarda y actualiza los datos de la tabla ss_piezas_bym_falsos.',
'FECHA: 03/06/2015',
'MODIFICO: Felipe Urias',
'DESCRIPCION:  se modifica la opcion 5 para que solo se actualizen los registros con estatus 2',
'FECHA: 04/04/2016',
'DESCRIPCION : se modifica la opcion 2 para que actualizen los estatus de capturado a cancelado',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_entrada_salida2_total(eEmpresa    CHAR(3),
                                              eTipo       CHAR(1), 
                                              eSucursal   CHAR(4),
                                              ePlaza      CHAR(3),
                                              eFecInicio  DATE,
                                              eFecFin     DATE,
                                              eMes        CHAR(2),
                                              eAnio       CHAR(4),
                                              eStatus     CHAR(2))
RETURNING CHAR(5)    ,          --CodRet
          INTEGER;              --Total de registros

 DEFINE vCodRet       CHAR(5);
 DEFINE vCajGen       CHAR(1);
 DEFINE vRegistros    INTEGER;


 LET vCodRet       = "000";
 LET ePlaza = ePlaza;
 LET eStatus  = eStatus;
 LET eSucursal  = eSucursal;
 LET ePlaza = ePlaza;
 LET eStatus  = eStatus;
 LET eSucursal  = eSucursal;
 LET vCajGen = 'N';
 LET vRegistros = 0;

-- SET DEBUG FILE TO "/tmp/entrasal.out";
--TRACE ON;

--SET LOCK MODE TO WAIT 4;
SET ISOLATION TO DIRTY READ;

   IF eTipo = 'C' THEN
    LET vCajGen = eTipo;
   END IF;

  IF ePlaza <> '000' AND eSucursal = '0000' AND eStatus = '00'  THEN
	  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
	  INTO  vRegistros
	   FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
							  WHERE a.cod_trans != '0'                      
		AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
								AND a.sucursal IN (SELECT sucursal 
																 FROM bdinteg:"informix".si_sucursales  
																WHERE sucursal != '0' 
							  AND empresa = eEmpresa
																			  AND plaza_cajagen = ePlaza 
																	  AND tpo_sucursal = eTipo)
									AND a.reversado IN ('0','1')
									AND a.folio_oper    = b.folio_oper   
		AND c.cod_proveedor = b.cod_proveedor; 

	  RETURN vcodret, vRegistros;

  ELIF ePlaza <> '000' AND eSucursal <> '0000' AND eStatus = '00'  THEN
	  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
	  INTO  vRegistros
	  FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
							  WHERE a.cod_trans != '0'                      
		AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
								AND a.sucursal = eSucursal
									AND a.reversado IN ('0','1')
									AND a.folio_oper    = b.folio_oper   
		AND c.cod_proveedor = b.cod_proveedor;

	  RETURN vcodret, vRegistros;

  ELIF ePlaza <> '000' AND eSucursal <> '0000' AND eStatus <> '00' THEN
	  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
	  INTO  vRegistros
	  FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
							  WHERE a.cod_trans != '0'                      
		AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
								AND a.sucursal = eSucursal
									AND a.reversado IN ('0','1')
									AND a.folio_oper    = b.folio_oper   
		AND c.cod_proveedor = b.cod_proveedor 
		AND b.status        = eStatus;

	  RETURN vcodret, vRegistros;

  ELIF ePlaza <> '000' AND eSucursal = '0000' AND eStatus <> '00' THEN
	  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
	  INTO  vRegistros
	  FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
							  WHERE a.cod_trans != '0'                      
		AND a.fecha_operacion BETWEEN eFecInicio AND eFecFin 
								AND a.sucursal IN (SELECT sucursal 
																 FROM bdinteg:"informix".si_sucursales  
																WHERE sucursal != '0' 
							  AND empresa = eEmpresa
																			  AND plaza_cajagen = ePlaza 
																	  AND tpo_sucursal = eTipo)
									AND a.reversado IN ('0','1')
									AND a.folio_oper    = b.folio_oper   
		AND c.cod_proveedor = b.cod_proveedor 
		AND b.status        = eStatus;
	  
	  RETURN vcodret, vRegistros;

 ELSE
		IF eMes <> '' AND eAnio <> '' THEN
			  SELECT {+ INDEX(bdisuc:ss_operaciones idx01ss_operaciones)} COUNT(*)
			  INTO  vRegistros
			  FROM bdisuc:"informix".ss_operaciones a, bdisuc:"informix".ss_mae_entradasalida b, bdisuc:"informix".ss_proveedores  c
									  WHERE a.cod_trans != '0'                      
				AND (MONTH(a.fecha_operacion) = eMes AND YEAR(a.fecha_operacion) = eAnio)
										AND a.sucursal IN (SELECT sucursal 
																		 FROM bdinteg:"informix".si_sucursales  
																		WHERE sucursal != '0'
																		  AND empresa = eEmpresa
																			  AND (tpo_sucursal = eTipo OR  tpo_sucursal = vCajGen))
											AND a.reversado IN ('0','1')
											AND a.folio_oper    = b.folio_oper   
				AND c.cod_proveedor = b.cod_proveedor;
			  
			  RETURN vcodret, vRegistros;
		END IF;
  END IF;

END PROCEDURE;