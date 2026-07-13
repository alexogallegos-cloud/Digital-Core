CREATE PROCEDURE "informix".sp_operacion_bpi(pUsuario CHAR(250), ptipo CHAR(5), pComplemento CHAR(250))
    RETURNING CHAR(5),CHAR(516);
	
	--ModificÃÂÃÂ³: Edgar M. Alarcon
	--Actividad: valida si recibe id de usuario o numero de cliente
	--Solicito: Jose de Jesus
	--Fecha: 05-11-15
	--ModificÃÂÃÂ³: MoisÃÂÃÂ©s Soriano
	--Actividad: Se modifica validacion al recibir idUsuario o numCte
	--SolicitÃÂÃÂ³: Alejandro Vazquez
	--Fecha: 18/04/2016
	--ModificÃÂÃÂ³: Gabriela Aguilar
	--Actividad: Se modifica validacion para mancomunidad
	--SolicitÃÂÃÂ³: Alejandro Vazquez
	--Fecha: 28/12/2016
	   
    DEFINE sql_err   INTEGER;
	
	DEFINE vcodret   CHAR(5);
    DEFINE vreturn   CHAR(516);
	DEFINE vIdOper	 INTEGER;
    DEFINE vIdUsuario VARCHAR(11);	
	DEFINE vCount	INTEGER;	

  		
	DEFINE pEmpresa  CHAR(3);
    DEFINE cNumCliente CHAR(20);
	DEFINE cIdUsuario INTEGER;
	DEFINE cPass CHAR(128);	
	DEFINE cPass1 CHAR(128);	
	DEFINE cPass2 CHAR(128);	
	DEFINE cPass3 CHAR(128);	
	DEFINE vPass CHAR(128);	
	DEFINE vPass1 CHAR(128);	
	DEFINE vPass2 CHAR(128);	
	DEFINE vPass3 CHAR(128);	
	DEFINE cUser CHAR(128);	
    DEFINE cIdStatus SMALLINT ;	
	DEFINE cSucVirtual CHAR (4);
	DEFINE cUsuVirtual CHAR(8);
	DEFINE vNumcte CHAR(250);
	DEFINE vTamanioParam CHAR(9);
	
	DEFINE vParam1 CHAR (250);
	DEFINE vParam2 CHAR (5);
	DEFINE vParam3 CHAR (250);

	
	LET vcodret   = '00099';
	LET vreturn   = '';
	LET vPass 	 = '';
	LET vPass1	 = '';
	LET vPass2 	 = '';
	LET vPass3 	 = '';
	LET pEmpresa  = '001';
	LET cSucVirtual = '5003';
	LET cUsuVirtual = 'TransBPI';
	LET cIdUsuario = 0;
	LET vTamanioParam = '';
	LET vCount = 0;

	
	--SET DEBUG FILE TO "/informix/aw/tst/sp_operacion_bpi.out"; --"/home/informix/aw/sp_operacion_bpi.out";
	--TRACE ON;
	
   SET LOCK MODE TO WAIT 3 ;
   SET ISOLATION TO DIRTY READ ;
	
	
	BEGIN	

	ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
			LET vcodret = sql_err;
        RETURN vcodret, vreturn;
       END IF;
	END EXCEPTION;

	IF(pUsuario = '' OR pUsuario IS NULL OR ptipo='' OR ptipo IS NULL) THEN
	    RETURN vcodret, vreturn;
	END IF;
	
	
	LET vParam1 = pUsuario;
	LET vParam2 = ptipo;
	LET vParam3 = pComplemento;
	
	SELECT  id_oper
		INTO vIdOper
	 FROM bdibpi:"informix".bpi_operacion 
	 WHERE status = 't' AND tipo = ptipo;
	
	-- Ejecutar segun el tipo de dato			 
	IF NVL(vIdOper,0) > 0 THEN	
		
		-- BPI
		-- 9301
		IF(vIdOper = 10) THEN
			
			SELECT usr.id_usuario INTO vIdUsuario 
				FROM bdinteg:"informix".si_bpiusuarios bpi 
					INNER JOIN bdibpi:"informix".bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'
				WHERE bpi.usuario = TRIM(pComplemento);
            IF NVL(vIdUsuario,'') <> '' THEN				
				LET vcodret   = '00000';
				LET vreturn   = vIdUsuario;
			END IF;        
			
		-- 9302
		ELIF (vIdOper = 11) THEN	
		
			--SET LOCK MODE TO WAIT 3;
			SELECT bpi.numcte, bpi.pass, bpi.id_status INTO cNumCliente, cPass, cIdStatus
				FROM bdinteg:"informix".si_bpiusuarios bpi 
					INNER JOIN bdibpi:"informix".bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'
				WHERE bpi.empresa = pEmpresa AND usr.id_usuario = TRIM(pUsuario);
					
			LET vreturn   = cIdStatus;
			
			IF NVL(cNumCliente,'') != '' AND TRIM(cPass) = TRIM(pComplemento) THEN
				LET vcodret   = '00000';				
			ELSE	
				LET vcodret   = '00002';
			END IF;       

	 			
			
		-- 9103 -- 9202
		ELIF (vIdOper = 12 OR vIdOper = 17 ) THEN		
		
			LET vTamanioParam = LENGTH(TRIM(pUsuario));
			IF vTamanioParam = 9 THEN  -- pUsuario = numcliente
				LET vNumcte = pUsuario;
			ELIF vTamanioParam >= 5 THEN -- pUsuario = idUsuario
				SELECT numcliente INTO vNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pUsuario AND st_portal = 'activo';
			END IF;
			
			SELECT count(numcte) into vCount FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = vNumcte;
			--IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = vNumcte ) THEN
			IF vCount > 0 THEN 
				LET vcodret   = '00000';
				---SELECT LIMIT 1  trim(NVL(pass,''))||'|'||trim(NVL(pass1,''))||'|'||trim(NVL(pass2,''))||'|'||trim(NVL(pass3,'')) 
				SELECT pass,pass1,pass2,pass3
				  INTO vPass,vPass1,vPass2,vPass3
				  FROM bdinteg:"informix".si_bpiusuarios 
				 WHERE empresa = pEmpresa 
				   AND numcte = vNumcte;
				   
				   LET vreturn = trim(NVL(vPass,''))||'|'||trim(NVL(vPass1,''))||'|'||trim(NVL(vPass2,''))||'|'||trim(NVL(vPass3,''));
			ELSE	
				LET vcodret   = '00001';
			END IF;
		
		-- 9101
		ELIF (vIdOper = 13) THEN
			SELECT COUNT(numcte) into vCount FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = pUsuario;
			--IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = pUsuario ) THEN
			IF vCount > 0 THEN 			
				LET vcodret   = '00000';
				UPDATE bdinteg:"informix".si_bpiusuarios SET usuario = pComplemento 
				WHERE numcte = pUsuario;
			ELSE	
				LET vcodret   = '00001';
			END IF;

		-- 9102
		ELIF (vIdOper = 14) THEN		
			SELECT COUNT(numcte) into vCount FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = pUsuario;
			--IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios  WHERE empresa = pEmpresa AND numcte = pUsuario ) THEN
			IF vCount > 0 THEN 					
				LET vcodret   = '00000';
				UPDATE bdinteg:"informix".si_bpiusuarios SET pass = TRIM(pComplemento), f_pass = current 
				WHERE numcte = pUsuario;
			ELSE	
				LET vcodret   = '00001';
			END IF;
			
		-- 9401
		ELIF (vIdOper = 34) THEN
		
			--SET LOCK MODE TO WAIT 3;
			SELECT bpi.usuario INTO vreturn
				FROM bdinteg:"informix".si_bpiusuarios bpi 
					INNER JOIN bdibpi:"informix".bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'
				WHERE bpi.empresa = pEmpresa AND usr.id_usuario = TRIM(pUsuario);
				
			IF NVL(vreturn,'') <> '' THEN				
				LET vcodret   = '00000';				
			ELSE
				LET vreturn   = '';
				LET vcodret   = '00002';							
			END IF;        
					
		-- 9402
		ELIF (vIdOper = 15) THEN
		
		SELECT COUNT(bpi.numcte) INTO vCount FROM bdinteg:"informix".si_bpiusuarios bpi 
			INNER JOIN bdibpi:"informix".bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'
			WHERE bpi.empresa = pEmpresa AND usr.id_usuario = pUsuario AND bpi.pass = pComplemento;
		/*	 IF EXISTS (SELECT bpi.numcte FROM bdinteg:"informix".si_bpiusuarios bpi 
						INNER JOIN bdibpi:"informix".bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'
					WHERE bpi.empresa = pEmpresa AND usr.id_usuario = pUsuario AND bpi.pass = pComplemento ) THEN*/
			IF vCount > 0 THEN 			
			   LET vcodret = '00000'; 			
			 ELSE
			   LET vcodret = '00001';
			 END IF ;
		
		-- 9403
		ELIF (vIdOper = 16) THEN

			SELECT bpi.numcte INTO cNumCliente
				FROM bdinteg:"informix".si_bpiusuarios bpi 
					INNER JOIN bdibpi:"informix".bpi_usuario usr ON usr.numcliente=bpi.numcte AND usr.st_portal='activo'
				WHERE bpi.empresa = pEmpresa AND usr.id_usuario = pUsuario;
				
				LET cPass = TRIM(pComplemento);
				IF (cPass <>'' AND cNumCliente<>'') THEN
					SELECT COUNT(numcte) INTO vCount FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = cNumCliente AND pass = cPass;
					--IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = cNumCliente AND pass = cPass) THEN
					IF vCount > 0 THEN 	
						 LET vcodret = '00001';  -- Ya existe el pass
					ELSE
						SELECT COUNT(numcte) INTO vCount FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = cNumCliente AND pass1 = cPass;
						--IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = cNumCliente AND pass1 = cPass) THEN
						IF vCount > 0 THEN 								 
							 LET vcodret = '00001';  -- Ya existe el pass
						ELSE
							SELECT COUNT(numcte) INTO vCount FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = cNumCliente AND pass2 = cPass;
							--IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = cNumCliente AND pass2 = cPass) THEN
							IF vCount > 0 THEN 							
								LET vcodret = '00001';  -- Ya existe el pass
							ELSE
								SELECT COUNT(numcte) INTO vCount FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = cNumCliente AND pass3 = cPass;
								--IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = cNumCliente AND pass3 = cPass) THEN
								IF vCount > 0 THEN 	
									LET vcodret = '00001';  -- Ya existe el pass
								ELSE
									LET vcodret = '00000';  -- Pass modificado
									UPDATE bdinteg:"informix".si_bpiusuarios SET pass3 = TRIM(pass2), f_pass3 = current WHERE empresa = pEmpresa AND numcte = cNumCliente;
									UPDATE bdinteg:"informix".si_bpiusuarios SET pass2 = TRIM(pass1), f_pass2 = current WHERE empresa = pEmpresa AND numcte = cNumCliente;
									UPDATE bdinteg:"informix".si_bpiusuarios SET pass1 = TRIM(pass), f_pass1 = current WHERE empresa = pEmpresa AND numcte = cNumCliente;
									UPDATE bdinteg:"informix".si_bpiusuarios SET pass = TRIM(cPass), f_pass = current WHERE empresa = pEmpresa AND numcte = cNumCliente;
								END IF;
							END IF;
						END IF;
					END IF;	
				ELSE
					LET vcodret = '00002'; 
				END IF;

		-- 9203
		ELIF (vIdOper = 18) THEN
		
				LET vTamanioParam = LENGTH(TRIM(pUsuario));
				IF vTamanioParam = 9 THEN  -- pUsuario = numcliente
					LET vNumcte = pUsuario;
				ELIF vTamanioParam >= 5 THEN -- pUsuario = idUsuario
					SELECT numcliente INTO vNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pUsuario AND st_portal = 'activo';
				END IF;
				SELECT COUNT(numcte) INTO vCount FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = vNumcte;
				--IF EXISTS ( SELECT numcte FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = vNumcte ) 	THEN
                IF vCount > 0 THEN 	
				
					UPDATE bdinteg:"informix".si_bpiusuarios SET pass3 = pass2, pass2 = pass1, pass1 = pass, f_pass3 = f_pass2,                                                                                                                                      
							f_pass2 = f_pass1, f_pass1 = f_pass, pass = pComplemento, f_pass = current, f_actualizacion = current                                                                                                                        
						WHERE  empresa = pEmpresa AND numcte = vNumcte;
										
					SELECT id_status INTO vIdUsuario FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND numcte = vNumcte;                                                                                                                             
					
					IF vIdUsuario = 40 OR  vIdUsuario = 90 THEN                                                                                                                                                                                 
						INSERT INTO bdinteg:"informix".si_cambiostcte  (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)  VALUES (vNumcte,vIdUsuario,30, null ,current, cSucVirtual, cUsuVirtual);						
						UPDATE bdinteg:"informix".si_bpiusuarios SET id_status = 30, f_status = current WHERE empresa = pEmpresa AND numcte = vNumcte;                                                                                                                                                                                                                                                                                                                                         
					END IF ;                                                                                                                                                                                                              
                        --Se modifica el insert, para que al grabar en tabla la hora tenga un segundo mas, evitando el problema de cambio de servicio bÃÂÃÂ¡sico a avanzado                                                                                                                                                                                                               
					INSERT INTO bdinteg:"informix".si_cambiostcte (numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio) VALUES (vNumcte,35,vIdUsuario, null ,current + 1 units second,cSucVirtual,cUsuVirtual);             
					LET vcodret = '00000';                                          
				ELSE
					LET vcodret = '00001'; 
				END IF;
		-- BEI
		-- 9701 [Validar] Ok
		ELIF (vIdOper = 19) THEN

				--SET LOCK MODE TO WAIT 3;

				SELECT usr.num_cliente,usr.id_usuario INTO cNumCliente ,cIdUsuario
					FROM bdibei:"informix".bei_usuario as usr
					WHERE usr.usuario_bei = TRIM(pComplemento);
				
				IF(cIdUsuario IS NULL) OR (NVL(cIdUsuario,0)=0) THEN
					LET vcodret = '00002';  -- Usuario NO EXISTE
				ELSE
					LET vcodret = '00000';
					LET vreturn   = cIdUsuario||'-'||cNumCliente;					
				END IF;

			
		-- 9702 [Validar] Ok
		ELIF (vIdOper = 20) THEN
		
				--SET LOCK MODE TO WAIT 4;
				SELECT usu.id_status, usu.num_cliente INTO cIdStatus, cNumCliente
					FROM bdibei:"informix".bei_usuario  usu
					 INNER JOIN bdibei:"informix".bei_datos_usuario dusr ON dusr.id_usuario = usu.id_usuario
					WHERE  usu.id_usuario  = pUsuario	AND   usu.pass=TRIM(pComplemento);
		
				IF NVL(cNumCliente,'') != ''  THEN
					LET vcodret = '00000';  -- Sesion iniciada
				ELSE
					LET vcodret = '00002';  -- Sesion iniciada
				END IF;
		
		-- 9803
		ELIF (vIdOper = 21) THEN
		
				SELECT num_cliente, pass, pass1, pass2, pass3 INTO cNumCliente, cPass, cPass1, cPass2, cPass3 
					FROM bdibei:"informix".bei_usuario
					WHERE id_usuario=pUsuario;
 
				IF NVL(cNumCliente, '') <> '' THEN
					IF(cPass=pComplemento)THEN
						LET vcodret = '00041'; -- PASSWORD Repetido
					ELIF(cPass1=pComplemento)THEN
						LET vcodret = '00041'; -- PASSWORD Repetido
					ELIF(cPass2=pComplemento)THEN
						LET vcodret = '00041'; -- PASSWORD Repetido
					ELIF(cPass3=pComplemento)THEN
						LET vcodret = '00041'; -- PASSWORD Repetido
					ELSE 	
						UPDATE bdibei:"informix".bei_usuario SET pass3 = TRIM(pass2), f_pass3 = current WHERE id_usuario = pUsuario;
						UPDATE bdibei:"informix".bei_usuario SET pass2 = TRIM(pass1), f_pass2 = current WHERE id_usuario = pUsuario;
						UPDATE bdibei:"informix".bei_usuario SET pass1 = TRIM(pass), f_pass1 = current WHERE id_usuario = pUsuario;
						UPDATE bdibei:"informix".bei_usuario SET pass = TRIM(pPass), f_pass = current WHERE id_usuario = pUsuario;
						LET vcodret = '00000';
					END IF;		
				ELSE
					LET vcodret = '00002';
				END IF;
				
		-- 9513
		--ELIF (vIdOper = 22) THEN

				--IF NVL(pComplemento,'') == '' THEN
					--LET vcodret = '00002'; -- No mando Nombre de Usuario Valido
				
				--ELSE

					--SELECT COUNT(*)	INTO cIdUsuario
						--FROM bdibei:"informix".bei_usuario  usu
						--WHERE  usu.usuario_bei  = TRIM(pComplemento);

					--LET vreturn   = cIdUsuario;
					--LET vcodret = '00000'; -- No mando Nombre de Usuario Valido
				
				--END IF;
		
		-- 9511
		ELIF (vIdOper = 23) THEN

			SELECT COUNT(num_cliente) INTO vCount  FROM bdibei:"informix".bei_usuario  WHERE id_usuario = pUsuario;
				--IF EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_usuario  WHERE id_usuario = pUsuario ) THEN
				IF vCount > 0 THEN
					LET vcodret   = '00000';
					UPDATE bdibei:"informix".bei_usuario SET usuario_bei=pComplemento
					WHERE id_usuario = pUsuario;
				ELSE	
					LET vcodret   = '00001';
				END IF;
						
		-- 9512
		ELIF (vIdOper = 24) THEN

			SELECT COUNT(num_cliente) INTO vCount  FROM bdibei:"informix".bei_usuario  WHERE id_usuario = pUsuario;
				--IF EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_usuario  WHERE id_usuario = pUsuario ) THEN
				IF vCount > 0 THEN
					LET vcodret   = '00000';
					UPDATE bdibei:"informix".bei_usuario SET pass=pComplemento,f_pass=CURRENT YEAR TO DAY 
					WHERE id_usuario = pUsuario;
				ELSE	
					LET vcodret   = '00001';
				END IF;
			
		-- 9503
		ELIF (vIdOper = 25) THEN
		
				--SET LOCK MODE TO WAIT ;
				--SET ISOLATION DIRTY READ ;
				--SELECT usuario.usuario_bei, trim(NVL(usuario.pass,''))||'|'||trim(NVL(usuario.pass1,''))||'|'||trim(NVL(usuario.pass2,''))||'|'||trim(NVL(usuario.pass3,''))
				SELECT usuario.usuario_bei, usuario.pass, usuario.pass1, usuario.pass2, usuario.pass3
					INTO cUser, vPass,vPass1, vPass2, vPass3
					FROM bdibei:"informix".bei_usuario AS usuario
				--		INNER JOIN bdibei:"informix".bei_servicio AS servicio ON usuario.id_usuario = servicio.id_usuario AND usuario.num_cliente = servicio.num_cliente
					WHERE -- usuario.usuario_bei = pComplemento	AND 
					usuario.id_usuario = pUsuario;

					 LET vreturn = trim(NVL(vPass,''))||'|'||trim(NVL(vPass1,''))||'|'||trim(NVL(vPass2,''))||'|'||trim(NVL(vPass3,''));
					
				IF(cUser IS NULL) THEN
					LET vcodret = '00001'; --No existe cliente					
					LET vreturn   = '';
				ELSE 
					LET vcodret = '00000';
				END IF;
		
		-- 9501
		ELIF (vIdOper = 26) THEN
		
				--SET LOCK MODE TO WAIT ;
				--SET ISOLATION DIRTY READ ;

				SELECT id_usuario INTO cIdUsuario FROM bdibei:"informix".bei_usuario WHERE usuario_bei = pComplemento;

				IF NVL(cIdUsuario, 0) = 0 THEN
					UPDATE bdibei:"informix".bei_usuario SET usuario_bei=pComplemento
					WHERE id_usuario = pUsuario;
					--AND num_cliente = pUsuario;
					
					LET vcodret = '00000'; 
				ELSE
					LET vcodret = '00001'; -- Nombre de Usuario ya registrado
				END IF;
		
		-- 9502
		ELIF (vIdOper = 27) THEN

				--SET LOCK MODE TO WAIT ;
				--SET ISOLATION DIRTY READ ;

				SELECT num_cliente INTO cNumCliente FROM bdibei:"informix".bei_usuario WHERE id_usuario = pUsuario;

				IF NVL(cNumCliente, 0) = 0 THEN
					LET vcodret = '00001'; -- Nombre de Usuario ya registrado
				ELSE
					UPDATE bdibei:"informix".bei_usuario SET  pass = TRIM(pComplemento), f_pass = CURRENT
					WHERE id_usuario = pUsuario
					AND num_cliente = cNumCliente;
					
					LET vcodret = '00000'; 
				END IF;
		
		-- 9601
		ELIF (vIdOper = 28) THEN
		
				--SET LOCK MODE TO WAIT ;
				--SET ISOLATION DIRTY READ ;

				SELECT usuario.usuario_bei INTO vreturn 
					FROM bdibei:"informix".bei_usuario AS usuario
					WHERE usuario.id_usuario = pUsuario;
					--AND usuario.num_cliente = pUsuario;
				IF NVL(vreturn, "") <> "" THEN	
					LET vcodret   = '00000';
				ELSE
					LET vcodret   = '00001';
					LET vreturn   = '';
				END IF;

		-- 9604
		ELIF (vIdOper = 35) THEN
		
				----SET LOCK MODE TO WAIT ;
				--SET ISOLATION DIRTY READ ;

				SELECT usuario.pass INTO vreturn 
					FROM bdibei:"informix".bei_usuario AS usuario
					WHERE usuario.id_usuario = pUsuario;
					--AND usuario.num_cliente = pUsuario;
				IF NVL(vreturn, "") <> "" THEN	
					LET vcodret   = '00000';
				ELSE
					LET vcodret   = '00001';
					LET vreturn   = '';
				END IF;

		-- 9602
		ELIF (vIdOper = 29) THEN

				--SET LOCK MODE TO WAIT ;
				--SET ISOLATION DIRTY READ ;
					
				--SELECT usuario.usuario_bei, trim(NVL(usuario.pass,''))||'|'||trim(NVL(usuario.pass1,''))||'|'||trim(NVL(usuario.pass2,''))||'|'||trim(NVL(usuario.pass3,'')) 
				SELECT usuario.usuario_bei, usuario.pass,usuario.pass1,usuario.pass2,usuario.pass3
					INTO cUser, vPass,vPass1,vPass2,vPass3
					FROM bdibei:"informix".bei_usuario AS usuario
					--	INNER JOIN bdibei:"informix".bei_servicio AS servicio ON usuario.id_usuario = servicio.id_usuario AND usuario.num_cliente = servicio.num_cliente
					WHERE usuario.id_usuario = pUsuario;
					--AND usuario.num_cliente = pUsuario;
					
					 LET vreturn = trim(NVL(vPass,''))||'|'||trim(NVL(vPass1,''))||'|'||trim(NVL(vPass2,''))||'|'||trim(NVL(vPass3,''));
					
				IF(cUser IS NULL) THEN
					LET vcodret = '00001'; --No existe cliente					
					LET vreturn   = '';
				ELSE 
					LET vcodret = '00000';
				END IF;
		
		-- 9603
		ELIF (vIdOper = 30) THEN

				SELECT id_status  INTO cIdStatus
					FROM bdibei:"informix".bei_usuario
					WHERE id_usuario = pUsuario;

				IF (cIdStatus IS NULL) THEN
					LET vcodret = '00001'; --NO EXISTE CLIENTE
				ELSE
					--SET LOCK MODE TO WAIT 4;
					--SET ISOLATION DIRTY READ;
					
					UPDATE bdibei:"informix".bei_usuario
					SET pass3 = pass2, pass2 = pass1, pass1 = pass, f_pass3 = f_pass2,
						f_pass2 = f_pass1, f_pass1 = f_pass, pass = pComplemento, 
						f_pass = current, f_actualizacion = current
					WHERE id_usuario = pUsuario;
					
					LET vcodret = '00000';
					
				END IF;

		-- 9802
		ELIF (vIdOper = 31) THEN

				--SET LOCK MODE TO WAIT ;
				--SET ISOLATION DIRTY READ ;
				SELECT COUNT(num_cliente) INTO vCount FROM bdibei:"informix".bei_usuario  WHERE id_usuario = pUsuario AND pass = pComplemento;
				--IF EXISTS (SELECT num_cliente FROM bdibei:"informix".bei_usuario  WHERE id_usuario = pUsuario AND pass = pComplemento ) THEN
				IF vCount > 0 THEN 
					LET vcodret = '00000';  -- Sesion iniciada
				ELSE
					LET vcodret = '00001';  -- Usuario y/o ContraseÃÂÃÂ±a incorrecta
				END IF ;

		-- 9804
		ELIF (vIdOper = 32) THEN

			--SET LOCK MODE TO WAIT ;
			--SET ISOLATION DIRTY READ ;
			
			SELECT num_cliente INTO cNumCliente
				FROM bdibei:"informix".bei_usuario WHERE id_usuario = pUsuario;
			
			IF NVL(cNumCliente,'') != '' AND TRIM(pComplemento) != '' THEN
	  		    SELECT COUNT(num_cliente) INTO vCount FROM bdibei:"informix".bei_usuario WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND pass = pComplemento;
				--IF EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_usuario WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND pass = pComplemento) THEN
				IF vCount > 0 THEN 
					LET vcodret = '00001';  -- Ya existe el pass
				ELSE
					SELECT  COUNT(num_cliente) INTO vCount FROM bdibei:"informix".bei_usuario WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND pass1 = pComplemento;
					--IF EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_usuario WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND pass1 = pComplemento) THEN
					IF vCount > 0 THEN 
						LET vcodret = '00001';  -- Ya existe el pass
					ELSE
						SELECT COUNT(num_cliente) INTO vCount FROM bdibei:"informix".bei_usuario WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND pass2 = pComplemento;
						--IF EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_usuario WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND pass2 = pComplemento) THEN
						IF vCount > 0 THEN
							LET vcodret = '00001';  -- Ya existe el pass
						ELSE
							SELECT COUNT(num_cliente) INTO vCount FROM bdibei:"informix".bei_usuario WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND pass3 = pComplemento;
							--IF EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_usuario WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND pass3 = pComplemento) THEN
							IF vCount > 0 THEN
								LET vcodret = '00001';  -- Ya existe el pass
							ELSE
								UPDATE bdibei:"informix".bei_usuario SET pass3 = TRIM(pass2), f_pass3 = current WHERE id_usuario = pIdUsuario AND num_cliente = cNumCliente;
								UPDATE bdibei:"informix".bei_usuario SET pass2 = TRIM(pass1), f_pass2 = current WHERE id_usuario = pIdUsuario AND num_cliente = cNumCliente;
								UPDATE bdibei:"informix".bei_usuario SET pass1 = TRIM(pass), f_pass1 = current WHERE id_usuario = pIdUsuario AND num_cliente = cNumCliente;
								UPDATE bdibei:"informix".bei_usuario SET pass = TRIM(pComplemento), f_pass = current WHERE id_usuario = pIdUsuario AND num_cliente = cNumCliente;

								LET vcodret = '00000';  -- Pass modificado
							END IF;
						END IF;
					END IF;
				END IF;
			ELSE
				LET vcodret = '00002';  -- No existe el Cliente
			END IF ;
				
		
		-- 9111	(9511 REGISTRA USUARIO)
		ELIF (vIdOper = 36) THEN
			
			--SET LOCK MODE TO WAIT ;
			--SET ISOLATION DIRTY READ ;
		    SELECT COUNT(usuario_bei) INTO vCount FROM bdibei:"informix".bei_admin_manco_temp WHERE id_admin_manco=pUsuario;
			--IF EXISTS ( SELECT  usuario_bei FROM bdibei:"informix".bei_admin_manco_temp WHERE id_admin_manco=pUsuario ) THEN
			IF vCount > 0 THEN
				LET vcodret   = '00000';
				UPDATE  bdibei:"informix".bei_admin_manco_temp SET usuario_bei=pComplemento 
					WHERE id_admin_manco=pUsuario;
			ELSE	
					LET vcodret   = '00001';
			END IF;	
			
		
		-- 9112  (9512 REGISTRA PASS )
		ELIF (vIdOper = 37) THEN
			SELECT  COUNT(pass) INTO vCount FROM bdibei:"informix".bei_admin_manco_temp WHERE id_admin_manco=pUsuario;
			--IF EXISTS ( SELECT  pass FROM bdibei:"informix".bei_admin_manco_temp WHERE id_admin_manco=pUsuario) THEN
			IF vCount > 0 THEN 
				LET vcodret   = '00000';
				UPDATE bdibei:"informix".bei_admin_manco_temp SET pass=pComplemento 
					WHERE id_admin_manco=pUsuario;
			ELSE	
				LET vcodret   = '00001';
			END IF;		
		


		-- 9113	(9604--CONSULTA PASS)
		ELIF (vIdOper = 38) THEN
		
			--SET LOCK MODE TO WAIT ;
			--SET ISOLATION DIRTY READ ;
				
			SELECT usuario_bei INTO    vreturn     
				FROM bdibei:"informix".bei_admin_manco_temp WHERE id_admin_manco=pUsuario;
					IF NVL(vreturn, "") <> "" THEN	
					LET vcodret   = '00000';
			ELSE
					LET vcodret   = '00001';
					LET vreturn   = '';
				END IF;
				
		
				
				
		-- 9513
		ELIF (vIdOper = 22) THEN

				IF NVL(pComplemento,'') == '' THEN
					LET vcodret = '00002';
				
				ELSE

					SELECT COUNT(usuario_bei)	INTO cIdUsuario
						FROM bdibei:"informix".bei_usuario  usu
						WHERE  usu.usuario_bei  = TRIM(pComplemento);
					
					if cIdUsuario = 0 then
					
						SELECT COUNT(usuario_bei)	INTO cIdUsuario
						FROM bdibei:"informix".bei_admin_manco_temp usu
						WHERE  usu.tipo_oper=1 and usu.tipo_mov IN (1,3)and usu.usuario_bei = TRIM(pComplemento);
					end if;
					
								
										
					LET vreturn   = NVL (cIdUsuario,0);
					LET vcodret = '00000';
				
				END IF;
		--8101 --Bancoppel Express
		ELIF (vIdOper = 39) THEN
		
		
			--SET LOCK MODE TO WAIT 3;
			SELECT num_cliente,contrasenia, estatus_servicio
				INTO cNumCliente, cPass, cIdStatus
				FROM bdibpi:"informix".bpi_registro_bex WHERE id_usuario = TRIM(pUsuario) AND servicio = 'activo';
			
			LET vreturn   = cNumCliente;
			
			IF NVL(cNumCliente,'') != '' AND TRIM(cPass) = TRIM(pComplemento) AND cIdStatus IN ('1','3') THEN
				LET vcodret   = '00000';				
			ELSE	
				IF NVL(cNumCliente,'') != '' AND TRIM(cPass) = TRIM(pComplemento) AND cIdStatus = '4'THEN
				LET vcodret   = '00003';
				ELSE 
				LET vcodret   = '00002';
				END IF;   
			END IF;   
			
		--8102
		ELIF (vIdOper = 40) THEN
		SELECT COUNT(num_cliente) INTO vCount FROM bdibpi:"informix".bpi_registro_bex  WHERE id_usuario = pUsuario AND estatus_servicio = '1';
			--IF EXISTS ( SELECT num_cliente FROM bdibpi:"informix".bpi_registro_bex  WHERE id_usuario = pUsuario AND estatus_servicio = '1') THEN
			IF vCount > 0 THEN 
				LET vcodret   = '00000';
				UPDATE bdibpi:"informix".bpi_registro_bex SET contrasenia = TRIM(pComplemento), fecha_modificada = current 
				 WHERE id_usuario = pUsuario;
			ELSE	
				LET vcodret   = '00001';
			END IF;
		
		--8103
		ELIF (vIdOper = 41) THEN
		
			SELECT num_cliente INTO vNumCte FROM bdibpi:"informix".bpi_registro_bex WHERE id_usuario = pUsuario AND servicio = 'activo';
			SELECT COUNT(num_cliente) INTO vCount FROM bdibpi:"informix".bpi_registro_bex  WHERE num_cliente = vNumcte AND id_usuario = pUsuario AND servicio = 'activo';
			
			--IF EXISTS (SELECT num_cliente FROM bdibpi:"informix".bpi_registro_bex  WHERE num_cliente = vNumcte AND id_usuario = pUsuario AND servicio = 'activo') THEN
			IF vCount > 0 THEN
				
				LET vcodret   = '00000';
				--SELECT LIMIT 1  trim(NVL(contrasenia,''))||'|'||trim(NVL(contrasenia1,''))||'|'||trim(NVL(contrasenia2,'')) 
				SELECT LIMIT 1  contrasenia,contrasenia1,contrasenia2 
				  INTO vPass,vPass1,vPass2
				  FROM bdibpi:"informix".bpi_registro_bex 
				 WHERE num_cliente = vNumcte
				 AND servicio = 'activo'
				 AND id_usuario = pUsuario;
				 
				 LET vreturn = trim(NVL(vPass,''))||'|'||trim(NVL(vPass1,''))||'|'||trim(NVL(vPass2,''));
			ELSE	
				LET vcodret   = '00001';
			END IF;
		
		--8104
		ELIF (vIdOper = 42) THEN
		
			----SET LOCK MODE TO WAIT ;
			--SET ISOLATION DIRTY READ ;
			
			SELECT num_cliente INTO cNumCliente
				FROM bdibpi:"informix".bpi_registro_bex WHERE id_usuario = pUsuario and servicio = 'activo';
			
			IF NVL(cNumCliente,'') != '' AND TRIM(pComplemento) != '' THEN
				SELECT COUNT(num_cliente) INTO vCount FROM bdibpi:"informix".bpi_registro_bex WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND contrasenia = pComplemento and servicio = 'activo';
				--IF EXISTS ( SELECT num_cliente FROM bdibpi:"informix".bpi_registro_bex WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND contrasenia = pComplemento and servicio = 'activo') THEN
				IF vCount > 0 THEN
					LET vcodret = '00001';  -- Ya existe el pass
				ELSE
					SELECT num_cliente INTO vCount FROM bdibpi:"informix".bpi_registro_bex WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND contrasenia1 = pComplemento and servicio = 'activo';
					--IF EXISTS ( SELECT num_cliente FROM bdibpi:"informix".bpi_registro_bex WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND contrasenia1 = pComplemento and servicio = 'activo') THEN
					IF vCount > 0 THEN
						LET vcodret = '00001';  -- Ya existe el pass
					ELSE
						SELECT num_cliente INTO vCount FROM bdibpi:"informix".bpi_registro_bex WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND contrasenia2 = pComplemento and 	servicio = 'activo';
						--IF EXISTS ( SELECT num_cliente FROM bdibpi:"informix".bpi_registro_bex WHERE id_usuario = pUsuario AND num_cliente = cNumCliente AND contrasenia2 = pComplemento and servicio = 'activo') THEN
						IF vCount > 0 THEN
							LET vcodret = '00001';  -- Ya existe el pass
						ELSE
								UPDATE bdibpi:"informix".bpi_registro_bex SET contrasenia2 = TRIM(contrasenia1) WHERE id_usuario = pUsuario AND num_cliente = cNumCliente and servicio = 'activo';
								UPDATE bdibpi:"informix".bpi_registro_bex SET contrasenia1 = TRIM(contrasenia)WHERE id_usuario = pUsuario AND num_cliente = cNumCliente and servicio = 'activo';
								UPDATE bdibpi:"informix".bpi_registro_bex SET contrasenia = TRIM(pComplemento), fecha_modificada = current WHERE id_usuario = pUsuario AND num_cliente = cNumCliente and servicio = 'activo';

								LET vcodret = '00000';  -- Pass modificado
						END IF;
					END IF;
				END IF;
			ELSE
				LET vcodret = '00002';  -- No existe el Cliente
			END IF ;
			
			
		-- 0000	
		ELSE
			LET vcodret   = '00098';
		END IF; 
		END IF;
			
		
	END;		
	RETURN	vcodret, vreturn;	
	
END PROCEDURE;