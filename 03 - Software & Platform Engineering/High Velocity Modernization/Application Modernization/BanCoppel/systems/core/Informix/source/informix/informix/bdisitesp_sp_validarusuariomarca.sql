CREATE PROCEDURE "informix".sp_validarusuariomarca(
																				pEmpresa 		CHAR(3),
																				pUsuario 			CHAR(8),
																				pSE				CHAR(1),
																				pCausa			SMALLINT,
																				pTipoMovimiento CHAR (1)
																				 )
RETURNING CHAR(6);

--Declaración  de variables
DEFINE v_codret CHAR(6);
DEFINE v_sqlerr INTEGER;
DEFINE cDepartamento CHAR (3);
DEFINE iArea INTEGER;

--Inicializacion de variables
LET v_codret = "000";
LET v_sqlerr = 0;
LET cDepartamento = '';
LET iArea = 0;
LET pTipoMovimiento = UPPER(pTipoMovimiento);


--25-08-2009
--Elaboro: Armida Pazos
--Valida si el usuario tiene derechos para marcar, eliminar y sustituir



BEGIN
	ON EXCEPTION SET v_sqlerr
		IF v_sqlerr != 0 THEN
			LET v_codret = v_sqlerr;
			RETURN v_codret;
	    End If;
    END EXCEPTION;

        -- Set debug file to '/tmp/sp_ValidaUsuarioSE.out';
        -- trace on;

	If pEmpresa is null or pEmpresa = '' OR
	pUsuario is null or pUsuario = '' OR
	pSE is null or pSE = '' OR
	pCausa is null or pCausa = 0 OR
	pTipoMovimiento is null or pTipoMovimiento = ''	then

		let v_codret = '004';
		return v_codret;
	End If;
	
	If pTipoMovimiento in ('M', 'E', 'S') THEN
	
	

	        ---Verifica que exista el departamento
		If Exists ( SELECT departamento  FROM bdinteg:si_ejecut  Where ejecutivo = Trim(pUsuario) ) THEN

	            SELECT departamento  INTO cDepartamento FROM bdinteg:si_ejecut  Where ejecutivo = Trim(pUsuario);

				---Verifica que el departamento corresponda a un area.
				If Exists (SELECT  idarea FROM bdisitesp:se_areas  where departamento = Trim (cDepartamento) ) THEN
	                            
								SELECT LIMIT 1 idarea INTO iArea FROM bdisitesp:se_areas  where departamento = Trim (cDepartamento);

	                            --Verifica que el area exista .
	                            If Exists (SELECT idarea FROM bdisitesp:se_logicaacceso
								where idarea= iArea and empresa = trim (pEmpresa) and situacion = trim (pSE)
								and causa = pCausa and idtipomov = pTipoMovimiento ) THEN

						return v_codret;
					else
						let v_codret = '001'; --usuario no autorizado para el marcaje
					End If;
				else
					let v_codret = '002'; -- departamento no tiene area
				End If;
		else
			let v_codret = '003'; -- no existe el usuario.
		End If;
	ELSE 
		let v_codret = '005'; -- Tipo de movimiento no valido		
	End if
return v_codret;
End

End PROCEDURE;