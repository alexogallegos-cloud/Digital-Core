CREATE PROCEDURE "informix".sp_sol_altamasiva_token(pUsrAtiende CHAR(9),pTipoEjec INTEGER, pTipoSol CHAR (1))
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);
DEFINE  dFechaini        DATE;
DEFINE  vFechaVieja 	 DATE;
DEFINE  vToken           VARCHAR(10);
DEFINE  iNumToken        INTEGER; 
DEFINE  vNumToken        VARCHAR(10);
DEFINE  iStatus          INTEGER; 
DEFINE  vSolicitud       VARCHAR(10);
--Guias
DEFINE vCteBco		CHAR(15);
DEFINE vCtePred		CHAR(15);
DEFINE vPeso		CHAR(5);
DEFINE vContenido	CHAR(20);
DEFINE vTipo		CHAR(10);
DEFINE vSecuencia	SMALLINT;
DEFINE vValor		INTEGER;
DEFINE vCcBco		CHAR(10);
DEFINE vFlg			CHAR(1);

DEFINE v_NumCte 	CHAR(9);
DEFINE v_SecDom 	SMALLINT;
DEFINE vEstado  	CHAR(30);
DEFINE vCiudad 		CHAR(60);
DEFINE vMunicipio 	CHAR(25);
DEFINE vColonia 	CHAR(30);
DEFINE vCalle 		CHAR(30);
DEFINE vCalleCom 	CHAR(30);
DEFINE vEmail 		CHAR(100);
DEFINE vNumExterior CHAR(10);
DEFINE vNumInterior CHAR(10);
DEFINE vTelefono 	CHAR(22);
DEFINE vCodPostal 	CHAR(5);

DEFINE vManzana 		CHAR(6);
DEFINE vAndador 		CHAR(6);
DEFINE vEtapa   		CHAR(6);
DEFINE vLote    		CHAR(6);
DEFINE vEdificio 		CHAR(6);
DEFINE vEntrada			CHAR(6);
DEFINE vOtros			CHAR(6);
DEFINE vObservaciones 	CHAR(80);
DEFINE vid_estado       char(5);

--------------------------------------------------------------------------------------------
-- Realizó: Manuel Osuna Valencia
-- Fecha de Solicitud: 21/01/2011
-- Actividad: Asignacion de token a solicitudes de forma masiva atravez del 
-- la aplicacion web del token manager
---------------------------------------------------------------------------------------------
-- Modificó: José de Jesús Nevarez
-- Fecha: 29-08-2011
-- Actividad: Asignación de token a solicitudes de forma masiva para personas morales a traves
-- de la aplicación web del token manager
---------------------------------------------------------------------------------------------
-- Modificó: José de Jesús Nevarez
-- Fecha: 30-09-2011
-- Actividad: Actualiza número de token al cliente en tabla bdinteg: si_bpitokenpm para el uso de la EmpresaNet.
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- Modificó: Juan Daniel Lazalde
-- Fecha: 21-11-2013
-- Actividad: Agregar el tipo 6 para las solicitudes renovadas con estatus recibida (200)
--            Validar que no guarde en si_bpitoken porque no se actualiza token y estatus para solicitudes renovadas
---------------------------------------------------------------------------------------------
--Modifico: Ilse Jazmín Gómez Pérez
--Actividad: Se modifica para que solo realize el cambio de estatus a 110 en la tabla bpi_tokensolicitud y 
--no realize la asignacion y cambio de estatus de token.
--Fecha: 08-08-2014
--Solilcitó: Jose de Jesus Nevarez
---------------------------------------------------------------------------------------------
--Modifico: Ilse Jazmín Gómez Pérez
--Actividad: Se modifica para que no inserte en la tabla bdibpi:tkn_guias
--Fecha: 08-09-2014
--Solilcitó: Jose de Jesus Nevarez
---------------------------------------------------------------------------------------------
-- Realizó: Héctor Ramón Moreno Moreno
-- Actividad: Se amplia campo Email a 100 caracteres.
-- Solicitó: Gabriela Aguilar.
-- Fecha de Solicitud: 13/09/2016
---------------------------------------------------------------------------------------------

---SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET LOCK MODE TO WAIT 3;

BEGIN

   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;
      
   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
   LET vCteBco		= '';
   LET vCtePred		= '';
   LET vPeso		= '';
   LET vContenido	= '';
   LET vTipo		= '';
   LET vSecuencia	= 0;
   LET vValor		= 0;
   LET vCcBco		= '';
   LET vFlg			= '';

  LET v_NumCte = '';
  LET v_SecDom = 0;
  LET vEstado  = '';
  LET vCiudad = '';
  LET vMunicipio = '';
  LET vColonia = '';
  LET vCalle = '';
  LET vCalleCom = '';
  LET vEmail = '';
  LET vNumExterior = '';
  LET vNumInterior = '';
  LET vTelefono = '';
  LET vCodPostal = '';
  
  LET vManzana = '';
  LET vAndador = '';
  LET vEtapa = '';
  LET vLote = '';
  LET vEdificio = '';
  LET vEntrada = '';
  LET vOtros = '';
  LET vObservaciones = '';
  LET vid_estado='';


  -- SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_sol_altamasiva_token.out";
  -- TRACE ON;
   
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
			DELETE FROM bdibpi:"informix".tkn_solprocesadas  where solicitud <> '0000000000' and cliente <> '000000000';
			
			
			LET vFechaVieja = CURRENT - Interval(30) day TO day;
			
	--Seleciona las Solicitudes a Procesar
			IF (pTipoEjec = 1) THEN -- Es el Proceso Masivo
			
				DELETE FROM bdibpi:"informix".tkn_tmpsolproceso where solicitud <> '0000000000' and numcte <> '000000000';
				
				--Si solicitud es Nueva ó Nueva Rnv
				IF (pTipoSol =='1' OR pTipoSol =='6') THEN
					INSERT INTO  bdibpi:"informix".tkn_tmpsolproceso ( solicitud,numcte, id_status,tipo,sucursal,f_solicitud,usr_solicita,
							sec_domicilio,comentarios,nombre1,nombre2,apell_paterno,apell_materno,razon_social,destinatario, id)
					SELECT tk.solicitud, tk.numcte, tk.id_status::CHAR(5), tk.tipo::CHAR(5),tk.sucursal,tk.f_solicitud::CHAR(50),
					tk.usr_solicita, tk.sec_domicilio, tk.comentarios,si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno, si.razon_social, '', 1			
					FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si
					WHERE tk.tipo::CHAR(5) MATCHES ('*' || pTipoSol)
					AND vFechaVieja  < date(tk.f_solicitud) 
					AND tk.id_status in (100,200) --Estatus recibidas
					AND si.numcte = tk.numcte
					AND si.empresa = tk.empresa;
				ELSE 
					INSERT INTO  bdibpi:"informix".tkn_tmpsolproceso ( solicitud,numcte, id_status,tipo,sucursal,f_solicitud,usr_solicita,
							sec_domicilio,comentarios,nombre1,nombre2,apell_paterno,apell_materno,razon_social,destinatario, id)
					SELECT tk.solicitud, tk.numcte, tk.id_status::CHAR(5), tk.tipo::CHAR(5),tk.sucursal,tk.f_solicitud::CHAR(50),
					tk.usr_solicita, tk.sec_domicilio, tk.comentarios,si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno, si.razon_social, pm.usuario_aut, 1			
					FROM bdibpi:"informix".bpi_tokensolicitud tk, bdinteg:"informix".si_cliente si, bdinteg:"informix".si_bpiusuariospm pm
					WHERE tk.tipo::CHAR(5) MATCHES ('*' || pTipoSol)
					AND vFechaVieja  < date(tk.f_solicitud) 
					AND tk.id_status = 100	
					AND si.numcte = tk.numcte
					AND tk.numcte = pm.num_cliente
					AND si.empresa = tk.empresa
					AND tk.empresa = pm.empresa;
				END IF;
			END IF;
						
	--Cambia status de la solicitud de 100 ó 200 a 110
			UPDATE bdibpi:"informix".bpi_tokensolicitud SET id_status = 110, f_atencion = CURRENT, usr_atiende = pUsrAtiende 
			WHERE solicitud IN (SELECT  {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_solicitud)}  solicitud FROM bdibpi:"informix".tkn_tmpsolproceso);
			
	--Registrar en bitacora cuales solicitudes cambiaron		
			--INSERT INTO bdibpi:"informix".tkn_stasolicitud (solicitud,anterior,actual,f_registro) 
			--SELECT  solicitud,id_status,'110',CURRENT FROM bdibpi:"informix".tkn_tmpsolproceso;
			
	--Consulta las direciones de los clientes	
			INSERT INTO  bdibpi:"informix".tkn_tmpsolproceso ( id,solicitud,numcte, id_status,tipo,sucursal,f_solicitud,usr_solicita,sec_domicilio,
			comentarios,nombre1,nombre2,apell_paterno,apell_materno,razon_social, destinatario)
			      SELECT 2,tk.solicitud,tk.numcte, tk.id_status,tk.tipo,tk.sucursal,tk.f_solicitud,tk.usr_solicita,tk.sec_domicilio,
			      tk.comentarios,tk.nombre1,tk.nombre2,tk.apell_paterno,tk.apell_materno,tk.razon_social, tk.destinatario
			       FROM bdinteg:"informix".si_cliente a, bdibpi:"informix".tkn_tmpsolproceso tk
			       WHERE a.numcte = tk.numcte
			       AND id = 1;	

--se consulta la ultima secuencia del domicilio				
			FOREACH 
			    SELECT numcte,sec_domicilio 
			    INTO v_NumCte,v_SecDom
			    FROM bdibpi:"informix".tkn_tmpsolproceso
			    WHERE id = 1

			    EXECUTE PROCEDURE bdibpi:"informix".sp_obt_dir_admtoken(TRIM(v_NumCte), v_SecDom)
			    INTO P_COD_RET, v_NumCte, vEstado, vCiudad, vMunicipio, vColonia, vCalle,
			        vCalleCom, vEmail, vNumExterior, vNumInterior, vTelefono, vCodPostal,vManzana,vAndador,vEtapa,vLote,vEdificio,vEntrada,vOtros,vObservaciones,vid_estado;

				UPDATE bdibpi:"informix".tkn_tmpsolproceso SET 
				        estado = NVL(TRIM(vEstado),''), ciudad = NVL(TRIM(vCiudad),''), municipio = NVL(TRIM(vMunicipio),''),
				        colonia = NVL(TRIM(vColonia),''), calle = NVL(TRIM(vCalle),''), calle_com = NVL(TRIM(vCalleCom),''),
				        email = NVL(TRIM(vEmail),''), numextcalle = NVL(TRIM(vNumExterior),''), numintecalle = NVL(TRIM(vNumInterior),''),
				        telefono = NVL(TRIM(vTelefono),''), cod_postal = NVL(TRIM(vCodPostal),'')
				        WHERE numcte = v_NumCte;	

			END FOREACH;							
									
	--Separar token que no tienen direcion
			INSERT INTO bdibpi:"informix".tkn_solprocesadas (solicitud,cliente,fecha,dispositivo,estatus_sol,error_desc)
			SELECT {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_id)}
			solicitud ,numcte,f_solicitud[1,10],token_asig,1,'No se encontró Domicilio'  
			FROM bdibpi:"informix".tkn_tmpsolproceso 
			WHERE id = '1' AND solicitud not IN (SELECT {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_id)} solicitud  FROM  bdibpi:"informix".tkn_tmpsolproceso WHERE id = '2');
			
			DELETE  FROM bdibpi:"informix".tkn_tmpsolproceso WHERE id = '1';					
			
				
	--Contabilizar solicitudes a entregar
			SELECT   COUNT(*) INTO iNumToken FROM bdibpi:"informix".tkn_tmpsolproceso WHERE ID=2;
				
	--Asignacion de Token	
			FOREACH token WITH HOLD FOR 
				SELECT {+INDEX(bdibpi:"informix".tkn_nseries idx_idstatus)}
				LIMIT iNumToken ns_token::VARCHAR(10),id_status
				INTO vNumToken,iStatus
				FROM bdibpi:"informix".tkn_nseries
				WHERE id_status = '105'
				 
				IF (vNumToken IS NOT NULL OR vNumToken <> '') THEN
					FOREACH sol_proc WITH HOLD FOR 
						SELECT {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_id)}
						LIMIT 1  solicitud
						INTO vSolicitud
						FROM bdibpi:"informix".tkn_tmpsolproceso
						WHERE token_asig = ''
						AND id = 2
						
						UPDATE bdibpi:"informix".tkn_tmpsolproceso SET token_asig = vNumToken WHERE CURRENT OF sol_proc;	
						
					END FOREACH;							
													
					--UPDATE bdibpi:"informix".tkn_nseries SET id_status = '110', f_status = CURRENT ,canal='04' WHERE CURRENT OF token;	
					
					--INSERT INTO bdibpi:"informix".tkn_status_token (ns_token,anterior,actual,f_cambio_status, usr_cambio_status,canal) 
					--VALUES(vNumToken, iStatus, '110', CURRENT, pUsrAtiende,'04');				
				ELSE
					EXIT FOREACH;				
				END IF;
									
			END FOREACH;
			
			
	--Separar token no asignados						
			INSERT INTO bdibpi:"informix".tkn_solprocesadas (solicitud,cliente,fecha,dispositivo,estatus_sol,error_desc)
			SELECT {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_id)}
			solicitud ,numcte,f_solicitud[1,10],token_asig,1,'No se Asignó Token'  
			FROM bdibpi:"informix".tkn_tmpsolproceso WHERE id = '2' AND token_asig = '';	
			
			DELETE {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_id)} FROM bdibpi:"informix".tkn_tmpsolproceso WHERE id = '2' AND token_asig = '';	
				
	--Actualiza el token asignado
			/*
			UPDATE bdibpi:"informix".bpi_tokensolicitud 
			SET ns_token =( SELECT token_asig   FROM bdibpi:"informix".tkn_tmpsolproceso tmp WHERE id = '2' AND token_asig <> '' AND 
			bdibpi:"informix".bpi_tokensolicitud.solicitud = tmp.solicitud  AND bdibpi:"informix".bpi_tokensolicitud.numcte = tmp.numcte)
			WHERE solicitud IN (SELECT solicitud  FROM bdibpi:"informix".tkn_tmpsolproceso tmp WHERE id = '2' AND token_asig <> '' AND 
			bdibpi:"informix".bpi_tokensolicitud.solicitud = tmp.solicitud  AND bdibpi:"informix".bpi_tokensolicitud.numcte = tmp.numcte);
			*/
	--Agendar los clientes actualiza si ya existen los cliente 
	--Solitudes Nuevas ó Nuevas rnv
	IF (pTipoSol =='1' OR pTipoSol =='6') THEN
		/*
		IF (pTipoSol!='6') THEN --Validar que sea distinto a tipo 6 porque no se actualiza token y estatus en si_bpitoken para solicitudes renovadas
				--Actualiza número de token al cliente para el uso de la banca 
				UPDATE bdinteg:"informix".si_bpitoken
				SET (ns_token,id_status_token) = (( SELECT token_asig  FROM bdibpi:"informix".tkn_tmpsolproceso tmp WHERE id = '2' AND token_asig <> '' AND bdinteg:"informix".si_bpitoken.num_cliente = tmp.numcte),'110')
				WHERE  num_cliente IN ( SELECT tmp.numcte FROM bdibpi:"informix".tkn_tmpsolproceso tmp WHERE id = '2' AND token_asig <> '' AND bdinteg:"informix".si_bpitoken.num_cliente = tmp.numcte);
		END IF;
		*/
				UPDATE bdibpi:"informix".tkn_agendacte SET (razon_social, direccion, dir_com, colonia, del_mpio, cp, tel_cte, 
		  destinatario, email, tipo_cp, envio_mail,f_registro) = 
		  ( (
			    SELECT  nombre,
			    CASE WHEN  LENGTH (TRIM(calle)  || ext  || INT )  <= 30 THEN (TRIM(calle)  || ext  || INT )
				     WHEN  LENGTH (TRIM(calle) || ext )  <= 30 THEN (TRIM(calle) || ext )
				     ELSE  calle END   AS direccion,   
			    CASE   WHEN  LENGTH (TRIM(calle) || ext )  > 30 THEN ( ext  || INT  )                                                                   
				        WHEN LENGTH (TRIM(calle)  || ext  || INT )  > 30 THEN   INT ELSE''        
			    END   AS complemento,colonia,municipio,cod_postal,telefono,nombre, email,'N','F',CURRENT
			     FROM table (multiset(
								SELECT  numcte, TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno) AS nombre,
									colonia,municipio,cod_postal,telefono,email,calle,
									CASE   WHEN  numextcalle <> ''    THEN  ( ' #'  || TRIM(numextcalle))  ELSE '' END AS ext,
									CASE   WHEN  numintecalle <> ''  THEN  ( ' i'  || TRIM(numintecalle)) ELSE '' END AS INT
								FROM  bdibpi:"informix".tkn_tmpsolproceso tk
								WHERE   bdibpi:"informix".tkn_agendacte.numcte  = tk.numcte AND tk.id='2'))
		  ))
		   WHERE numcte IN (SELECT {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_numcte)} tk3.numcte FROM bdibpi:"informix".tkn_tmpsolproceso tk3 
								  WHERE tk3.id = '2' AND bdibpi:"informix".tkn_agendacte.numcte  = tk3.numcte );

				--Agendar los clientes insercion de lo clientes nuevos
				INSERT INTO bdibpi:"informix".tkn_agendacte (numcte,razon_social, direccion, dir_com, colonia, del_mpio, 
				cp, tel_cte, destinatario, email, tipo_cp, envio_mail, f_registro)
				SELECT   numcte,nombre,
			    CASE WHEN  LENGTH (TRIM(calle)  || ext  || INT )  <= 30 THEN (TRIM(calle)  || ext  || INT )
				     WHEN  LENGTH (TRIM(calle) || ext )  <= 30 THEN (TRIM(calle) || ext )
				     ELSE  calle END   AS direccion,   
			    CASE   WHEN  LENGTH (TRIM(calle) || ext )  > 30 THEN ( ext  || INT  )                                                                   
				        WHEN LENGTH (TRIM(calle)  || ext  || INT )  > 30 THEN   INT ELSE''        
			    END   AS complemento,colonia,municipio,cod_postal,telefono,nombre, email,'N','F',CURRENT
			     FROM table (multiset(
			    SELECT  numcte, TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno) AS nombre,
									colonia,municipio,cod_postal,telefono,email,calle,
				CASE   WHEN  numextcalle <> ''    THEN  ( ' #'  || TRIM(numextcalle))  ELSE '' END AS ext,
			    CASE   WHEN  numintecalle <> ''  THEN  ( ' i'  || TRIM(numintecalle)) ELSE '' END AS INT
				FROM  bdibpi:"informix".tkn_tmpsolproceso tk 
				WHERE tk.solicitud not  IN ( SELECT {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_numcte)} solicitud FROM bdibpi:"informix".tkn_tmpsolproceso tk2,bdibpi:"informix".tkn_agendacte ag
				WHERE  ag.numcte  = tk2.numcte AND tk2.id='2') AND tk.id='2'));
	
	ELSE
	
				--Actualiza numero de token al cliente para el uso de la EmpresaNet.
				UPDATE bdinteg:"informix".si_bpitokenpm
					SET (ns_token,id_status_token) = (( SELECT {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_id)}token_asig  FROM bdibpi:"informix".tkn_tmpsolproceso tmp WHERE id = '2' AND token_asig <> '' AND 
				bdinteg:"informix".si_bpitokenpm.num_cliente = tmp.numcte),'110')
				WHERE  num_cliente IN ( SELECT {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_id)}   tmp.numcte  FROM bdibpi:"informix".tkn_tmpsolproceso tmp WHERE id = '2' AND token_asig <> '' AND 
				bdinteg:"informix".si_bpitokenpm.num_cliente = tmp.numcte);
				
			
				UPDATE bdibpi:"informix".tkn_agendacte SET (razon_social, direccion, dir_com, colonia, del_mpio, cp, tel_cte, 
		  destinatario, email, tipo_cp, envio_mail,f_registro) = 
		  ( (
			    SELECT  {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_id)} razon_social,
			    CASE WHEN  LENGTH (TRIM(calle)  || ext  || INT )  <= 30 THEN (TRIM(calle)  || ext  || INT )
				     WHEN  LENGTH (TRIM(calle) || ext )  <= 30 THEN (TRIM(calle) || ext )
				     ELSE  calle END   AS direccion,   
			    CASE   WHEN  LENGTH (TRIM(calle) || ext )  > 30 THEN ( ext  || INT  )                                                                   
				        WHEN LENGTH (TRIM(calle)  || ext  || INT )  > 30 THEN   INT ELSE''        
			    END   AS complemento,colonia,municipio,cod_postal,telefono,destinatario, email,'N','F',CURRENT
			     FROM table (multiset(
								SELECT  numcte, razon_social, colonia,municipio,cod_postal,telefono,destinatario,email,calle,
									CASE   WHEN  numextcalle <> ''    THEN  ( ' #'  || TRIM(numextcalle))  ELSE '' END AS ext,
									CASE   WHEN  numintecalle <> ''  THEN  ( ' i'  || TRIM(numintecalle)) ELSE '' END AS INT
								FROM  bdibpi:"informix".tkn_tmpsolproceso tk
								WHERE bdibpi:"informix".tkn_agendacte.numcte  = tk.numcte AND tk.id='2'))
		  ))
		   WHERE numcte IN (SELECT {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_id)} tk3.numcte FROM bdibpi:"informix".tkn_tmpsolproceso tk3 
								  WHERE tk3.id = '2' AND bdibpi:"informix".tkn_agendacte.numcte  = tk3.numcte );
				

				--Agendar los clientes insercion de lo clientes nuevos
				INSERT INTO bdibpi:"informix".tkn_agendacte (numcte,razon_social, direccion, dir_com, colonia, del_mpio, 
				cp, tel_cte, destinatario, email, tipo_cp, envio_mail, f_registro)
				SELECT {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_id)} numcte,razon_social,
			    CASE WHEN  LENGTH (TRIM(calle)  || ext  || INT )  <= 30 THEN (TRIM(calle)  || ext  || INT )
				     WHEN  LENGTH (TRIM(calle) || ext )  <= 30 THEN (TRIM(calle) || ext )
				     ELSE  calle END   AS direccion,   
			    CASE   WHEN  LENGTH (TRIM(calle) || ext )  > 30 THEN ( ext  || INT  )                                                                   
				        WHEN LENGTH (TRIM(calle)  || ext  || INT )  > 30 THEN   INT ELSE''        
			    END   AS complemento,colonia,municipio,cod_postal,telefono,destinatario, email,'N','F',CURRENT
			     FROM table (multiset(
			    SELECT  {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_id)} numcte, razon_social, colonia,municipio,cod_postal,telefono,destinatario,email,calle,
							CASE   WHEN  numextcalle <> ''    THEN  ( ' #'  || TRIM(numextcalle))  ELSE '' END AS ext,
			    CASE   WHEN  numintecalle <> ''  THEN  ( ' i'  || TRIM(numintecalle)) ELSE '' END AS INT
				FROM  bdibpi:"informix".tkn_tmpsolproceso tk 
				WHERE tk.solicitud not  IN ( SELECT {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_id)} solicitud FROM bdibpi:"informix".tkn_tmpsolproceso tk2,bdibpi:"informix".tkn_agendacte ag
				WHERE  ag.numcte  = tk2.numcte AND tk2.id='2') AND tk.id='2'));
	END IF;
		
	--Informe de solicitudes procesadas
			INSERT INTO bdibpi:"informix".tkn_solprocesadas (solicitud,cliente,fecha,dispositivo,estatus_sol,error_desc)
			SELECT {+INDEX(bdibpi:"informix".tkn_tmpsolproceso idx_id)} solicitud ,numcte,f_solicitud[1,10],token_asig,0,'Token Asignado con Éxito'  
			FROM bdibpi:"informix".tkn_tmpsolproceso WHERE id = '2';		
	
	--Para las solicitudes renovadas cancelar las solicitudes anteriores
	--Hacer un recorrido de las
		
	RETURN P_COD_RET,P_MENSAJE;
END;
END PROCEDURE;