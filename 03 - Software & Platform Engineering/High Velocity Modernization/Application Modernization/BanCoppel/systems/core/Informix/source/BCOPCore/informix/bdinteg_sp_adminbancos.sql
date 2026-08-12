CREATE PROCEDURE "informix".sp_adminbancos(
											pintcvebanco      			CHAR(5),      -- clave de banco
											pvchrnombre       			CHAR(60),     -- nombre banco
											pvchrnombrecorto  			CHAR(20),     -- nombre corto
											pdatfecha         			CHAR(10), 	  -- fecha operacion
											pchroperacion     			CHAR(1),	  -- tipo de operacion (ABC)
											pusuario          			CHAR(9),      -- usuario en sesion
											pspei						CHAR(1),	  -- indicador SPEI
											pcheques					CHAR(1),	  -- indicador CHEQUES
											pnomina						CHAR(1),	  -- indicador NOMINA
											ptefrecibe		  			CHAR(1),	  -- indicador TEF Recibe
											ptefpresentador		  		CHAR(1),	  -- indicador TEF Presenta
											pdomirecibe		  			CHAR(1),	  -- indicador DOMI Recibe
											pdomipresentador		  	CHAR(1)		  -- indicador DOMI Presenta
											)             

	RETURNING  CHAR(5);   -- codigo retorno
    
	DEFINE vCodRet  		CHAR(5);
	DEFINE vCodRet2			CHAR(5);
	DEFINE vSqlErr          INTEGER;
	DEFINE vIsamErr			INTEGER;
	
	DEFINE vintindice		INTEGER;
	DEFINE vintcvebanco		CHAR(5);
	DEFINE vvchrnombre		CHAR(60);		
	DEFINE vvchrnombrecorto	CHAR(20);
	DEFINE vchroperacion	CHAR(1);
	DEFINE vpdatfecha		DATE;
	DEFINE vusuario			CHAR(9);
	DEFINE vintcvesif       CHAR(3);
	DEFINE vexitebanco		CHAR(1);
	DEFINE vreqfechaspei	CHAR(1);
	DEFINE vfechahoy        DATE;
    
    
	LET vCodRet       = "000";
    LET vCodRet2      = "000";
    LET vSqlErr       = 0;
    LET vIsamErr      = 0;
	
	LET vintindice=0;
	LET vintcvebanco=TRIM(pintcvebanco);
	LET vvchrnombre=TRIM(pvchrnombre);
	LET vvchrnombrecorto=TRIM(pvchrnombrecorto);
	LET vchroperacion=TRIM(pchroperacion);
	LET vpdatfecha=date(pdatfecha);
	LET vusuario=TRIM(pusuario);
	LET vintcvesif=SUBSTR(vintcvebanco,3,3);
	LET vexitebanco='0';
	LET vreqfechaspei='0';
	LET vFechaHoy = date(current);
    	
    --SET DEBUG FILE TO "/informix/Jess/sp_adminbancos2.out";
    --TRACE ON;

    BEGIN
	
		
		ON EXCEPTION SET vSqlErr, vIsamErr
			--SET DEBUG FILE TO "/informix/Jess/sp_adminbancos.out";
			--TRACE ON;
			IF vSqlErr != 0 THEN
				LET vCodRet = vSqlErr;
				LET vCodRet2 = vIsamErr;
            RETURN vCodRet; 
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		IF (LENGTH(vchroperacion) != 0) THEN
		
		    -- Valida que tenga fecha operacion si tiene canal spei y que sea valida
			/*IF (pspei = '1') THEN
				IF (LENGTH(pdatfecha) > 0) THEN
					IF (vpdatfecha > vfechahoy) OR (vpdatfecha = vfechahoy)  THEN
						LET vreqfechaspei=0;  -- fecha correcta
					ELSE
						LET vreqfechaspei= 2; -- fecha correcta, solo aplica si es una modificacion
						LET pdatfecha=vfechahoy;
					END IF;
				ELSE
					LET vreqfechaspei=1;
				END IF;
			ELSE
			    LET vreqfechaspei=3;  -- no tiene canal spei
				LET pdatfecha=vfechahoy;
			END IF;
	        */

		    -- Revisa si existe el banco
			IF /*EXISTS(SELECT cvecesif FROM bdispei:tblbanco WHERE cvecesif=vintcvebanco) or*/  
            EXISTS(SELECT cvecesif FROM "informix".si_bancos WHERE cvecesif=vintcvebanco or banco=vintcvesif) THEN
				LET vexitebanco='1';
			ELSE
			    LET vexitebanco='0';
			END IF;
			

		    IF vchroperacion = '1' THEN  -- ALTA
				IF vexitebanco = '1' THEN
					LET vCodRet='002'; -- ya existe la clave banco
				ELSE

						IF (LENGTH(vintcvebanco) != 0) AND (LENGTH(vvchrnombre) != 0) AND (LENGTH(vvchrnombrecorto) != 0)   THEN

							INSERT INTO "informix".si_bancos(banco, descripcion, pais, estado, ciudad, swift, telex, tp_banco, convenio, user_insert, fecha_insert, cvecesif, vchrnombrecorto, flg_domi_r, flg_domi_p, flg_tef_r, flg_tef_p, flg_spei, flg_cheq, flg_nomi, fecha_opera)
							VALUES(vintcvesif, vvchrnombre, '001', '01', '001', 'x', 'x', 'D', 'S', vusuario, current, vintcvebanco, vvchrnombrecorto, pdomirecibe, pdomipresentador, ptefrecibe, ptefpresentador, pspei, pcheques, pnomina, pdatfecha);
						 
								
							IF pspei = '1' THEN  -- Si tiene seleccionado canal SPEI
							
								LET vintindice='-' || vintcvebanco; 
                                IF EXISTS(SELECT cvecesif FROM bdispei:tblbanco WHERE cvecesif=vintcvebanco) THEN
									UPDATE bdispei:tblbanco SET chredobco='A', vchrnombrecorto=vvchrnombrecorto, vchrnombre=vvchrnombre WHERE cvecesif=vintcvebanco;
								ELSE
									INSERT INTO bdispei:tblbanco(cvecesif, vchrnombrecorto, intindice, vchrnombre, chredobco, chrbcoreceptivo, intcvebsi, chrhabilitarprom)
									VALUES(vintcvebanco, vvchrnombrecorto, vintindice, vvchrnombre, 'A', 'R', 0, '1');
								END IF;
							    
						    END IF;
								
							LET vCodRet='000';
							

						ELSE
							-- falta informacion de banco
							LET vCodRet='003';	
							
						END IF;
				END IF;
				
		    ELIF vchroperacion = '2' THEN   -- ACTUALIZA 
			
				IF vexitebanco = '0' THEN
					LET vCodRet='005'; -- No existe la clave banco
				ELSE

						IF (LENGTH(vintcvebanco) != 0) AND (LENGTH(vvchrnombre) != 0) AND (LENGTH(vvchrnombrecorto) != 0) THEN	
						
							 IF pspei='1' THEN   -- Tiene canal SPEI
								UPDATE "informix".si_bancos SET descripcion=vvchrnombre, vchrnombrecorto=vvchrnombrecorto, user_insert=vusuario, flg_domi_r=pdomirecibe, 
								flg_domi_p=pdomipresentador, flg_tef_r=ptefrecibe, flg_tef_p=ptefpresentador, flg_spei=pspei, flg_cheq=pcheques, flg_nomi=pnomina, fecha_opera=pdatfecha
								WHERE cvecesif=vintcvebanco;
							 ELSE
							    UPDATE "informix".si_bancos SET descripcion=vvchrnombre, vchrnombrecorto=vvchrnombrecorto, user_insert=vusuario, flg_domi_r=pdomirecibe, 
								flg_domi_p=pdomipresentador, flg_tef_r=ptefrecibe, flg_tef_p=ptefpresentador, flg_spei=pspei, flg_cheq=pcheques, flg_nomi=pnomina, fecha_opera=vFechaHoy
								WHERE cvecesif=vintcvebanco;
							 END IF;
								
								-- Verifica si el banco ya opera con canal spei.
								IF EXISTS(SELECT cvecesif FROM bdispei:tblbanco WHERE cvecesif=vintcvebanco) THEN
								
									IF pspei = '0' THEN  -- No tiene seleccionado canal SPEI

										UPDATE bdispei:tblbanco SET chredobco='B' WHERE cvecesif=vintcvebanco;
										
									ELSE
									   
									    UPDATE bdispei:tblbanco SET chredobco='A', vchrnombrecorto=vvchrnombrecorto, vchrnombre=vvchrnombre WHERE cvecesif=vintcvebanco;
									
									END IF;
									
									LET vCodRet='000';

						        ELSE
								
									IF pspei = '1' THEN  -- Si tiene canal SPEI
										LET vintindice='-' || vintcvebanco; 
										INSERT INTO bdispei:tblbanco(cvecesif, vchrnombrecorto, intindice, vchrnombre, chredobco, chrbcoreceptivo, intcvebsi, chrhabilitarprom)
										VALUES(vintcvebanco, vvchrnombrecorto, vintindice, vvchrnombre, 'A', 'R', 0, '1');
								   
									END IF;

								    LET vCodRet='000';
									
								END IF;

						ELSE
							-- falta informacion de banco
							LET 	vCodRet='003';	
						END IF;
				END IF;
		    ELSE
				-- tipo de operacion no valida
				LET 	vCodRet='004';
            END IF;
		   
		ELSE
			-- no esta definida la operacion
           LET 	vCodRet='001';	
		END IF;
		
	END;
   RETURN vCodRet;	
END PROCEDURE;