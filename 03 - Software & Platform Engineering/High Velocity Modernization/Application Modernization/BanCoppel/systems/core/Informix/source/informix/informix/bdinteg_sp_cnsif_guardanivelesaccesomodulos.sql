CREATE PROCEDURE "informix".sp_cnsif_guardanivelesaccesomodulos(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdFuncionC CHAR(8), pIdModulos CHAR(255), pNivelesAcceso CHAR(100))
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNivelAcceso SMALLINT;
	DEFINE iRegsProcesados INTEGER;
	DEFINE iExiste SMALLINT;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNivelAcceso = 0;
	LET iRegsProcesados = 0;
	LET iExiste = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_guardanivelesaccesomodulos.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pIdFuncionC = '' OR pIdModulos = '' OR pNivelesAcceso = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACIÃN DE ACCESO AL PROCEDIMIENTO
		EXECUTE PROCEDURE "informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- Se valida que el usuario no este insertado ya en tabla, en ese caso solo se actualizaran sus niveles de acceso
		SELECT COUNT(id_usuario)
		INTO iExiste
		FROM "informix".si_seg_nivel_acceso_modulo
		WHERE id_usuario = pIdFuncionC;
		
		IF iExiste <> 0 THEN
			LET cCodRet = '00004';
			RETURN cCodRet;
		END IF;
		
		-- Se inserta al usuario en tablas
		INSERT INTO bdinteg:si_seg_nivel_acceso_modulo(id_usuario, id_modulo, nivel_acceso)
		SELECT pIdFuncionC, a.id_modulo, iNivelAcceso
		FROM bdinteg:si_seg_modulos a;
		
		EXECUTE PROCEDURE "informix".sp_cnsif_actualizanivelesaccesomodulos(pIdUsuario, pIdFuncion, pIdFuncionC, pIdModulos, pNivelesAcceso) INTO cCodRet, iRegsProcesados;
		IF cCodRet::INTEGER < 0 THEN
			RAISE EXCEPTION cCodRet::INTEGER, 0, 'ERROR EN SP sp_cnsif_actualizanivelesaccesomodulos';
		END IF;
		
		RETURN cCodRet;
		
	END;
	
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/12/2013",
"DESCRIPCION: Procedimiento que guarda los niveles de acceso para un usuario",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_validaemail(pEmail	Char(100)) 
RETURNING CHAR(5) As Codigo_error,
 CHAR(1) As Valido;

DEFINE vlStrTemp  Char(1);
DEFINE vlContador  Smallint;
DEFINE vlEmail    char(100);
DEFINE vlValidaEmail char(1);
DEFINE sCodRet		char(5);
DEFINE vlPosArroba	smallint;
DEFINE	vlPosPunto	smallint;
DEFINE	vsqlerr		smallint;
DEFINE	vlPosGuionB	smallint;
DEFINE	vlPosGuionA	smallint;

LET vlStrTemp = '';
LET	vlcontador = '';
LET	vlEmail = '';	
LET vlValidaEmail ='V';
LET sCodRet ='00000';
LET vlPosArroba	=0;
LET	vlPosPunto	=0;
LET	vlPosGuionB	=0;
LET	vlPosGuionA	=0;

BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scodret=vsqlerr;
      RETURN scodret,'F';
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "validaemail.out";
--TRACE ON;

  LET vlEmail = trim(pEmail);
  
  let vlContador = 1;
  
  If pEmail = "" Then
    let vlValidaEmail = 'F';
    let scodret =  '00001'; --"No se indicó ninguna dirección de mail para verificar"   
	RETURN scodret,vlValidaEmail;  
  ELIF length(vlEmail) < 7 then
    let vlValidaEmail = 'F';
    let scodret =  '00002'; --"La direccion no es valida favor de verificar"   
	RETURN scodret,vlValidaEmail;
  END IF;	
  
  While vlContador <= length(vlEmail) LOOP
     let vlStrTemp = Substr(vlEmail,vlContador,1);
     if (vlStrTemp not in ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z')) 
	     and
		 (vlStrTemp not in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'))
		 and
		 (vlStrTemp not in ('1','2','3','4','5','6','7','8','9','0'))
		 and 
		 (vlStrTemp not in ('-','.','@','_'))		 
		  then 
	   let sCodRet = '00003'; --La dirección cuenta con un caracter invalido
	   let vlValidaEmail = 'F';
	   RETURN scodret,vlValidaEmail;  
	 elif vlStrTemp in ('-','.','@','_') and (( vlContador = 1) or (vlContador = length(vlEmail) ) ) then
	   let sCodRet = '00004'; --La dirección de email no puede llevar -,.,@,_ ni al principio ni al final 
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;  
	 elif vlStrTemp = ' ' then
	   let sCodRet = '00006'; --La dirección de email no puede llevar espacios vacios
	   let vlValidaEmail = 'F';	     
	   RETURN scodret,vlValidaEmail;  
	 end if;
	 
	 if ((vlPosArroba >0)  and vlStrTemp in ('@') and (vlPosArroba +1 =vlContador) ) then	   
	   let sCodRet = '00008'; --No pueden ir  @@ 
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;  	
	 end if;

	if ((vlPosPunto >0)  and vlStrTemp in ('.') and  (vlPosPunto +1 =vlContador) ) then	   
	   let sCodRet = '00014'; --No pueden ir dos puntos juntos
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;   
	 end if; 	 
	if ((vlPosGuionB >0)  and vlStrTemp in ('_') and  (vlPosGuionB +1 =vlContador) ) then	   
	   let sCodRet = '00015'; --No pueden ir dos guiones bajo juntos
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if; 	 
	if ((vlPosGuionA >0)  and vlStrTemp in ('-') and  (vlPosGuionA +1 =vlContador) ) then	   
	   let sCodRet = '00016'; --No pueden ir dos guiones alto juntos
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if;

	 if vlStrTemp in ('.') then
	   let vlPosPunto = vlContador;
	 end if;
	 if vlStrTemp in ('@') then
	   let vlPosArroba = vlContador;
	 end if;

	if vlStrTemp in ('-') then
	   let vlPosGuionA = vlContador;
	 end if;

	if vlStrTemp in ('_') then
	   let vlPosGuionB = vlContador;
	 end if;


	 if ((vlPosPunto >0)  and (vlPosArroba > 0)) and ( (vlPosPunto +1 =vlPosArroba) or (vlPosPunto -1 = vlPosArroba) ) then	   
	   let sCodRet = '00005'; --No puede ir un punto antes ni despues del arroba
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 	
	 end if;  

	if ((vlPosGuionA >0)  and (vlPosArroba > 0)) and ( (vlPosGuionA +1 =vlPosArroba) or (vlPosGuionA -1 = vlPosArroba) ) then	   
	   let sCodRet = '00009'; --No puede ir un guion alto antes ni despues del arroba
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if;            

     if ((vlPosGuionB >0)  and (vlPosArroba > 0)) and ( (vlPosGuionB +1 =vlPosArroba) or (vlPosGuionB -1 = vlPosArroba) ) then	   
	   let sCodRet = '00010'; --No puede ir un guion bajo antes ni despues del arroba
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if;            
     if ((vlPosGuionB >0)  and (vlPosPunto > 0)) and ( (vlPosGuionB +1 =vlPosPunto) or (vlPosGuionB -1 = vlPosPunto) ) then	   
	   let sCodRet = '00011'; --No puede ir un guion bajo antes ni despues del punto
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail; 
	 end if;            
     if ((vlPosGuionA >0)  and (vlPosPunto > 0)) and ( (vlPosGuionA +1 =vlPosPunto) or (vlPosGuionA -1 = vlPosPunto) ) then	   
	   let sCodRet = '00012'; --No puede ir un guion alto antes ni despues del punto
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;  
	 end if; 
     if ((vlPosGuionA >0)  and (vlPosGuionB > 0)) and ( (vlPosGuionA +1 =vlPosGuionB) or (vlPosGuionA -1 = vlPosGuionB) ) then	   
	   let sCodRet = '00013'; --No puede ir un guion alto antes ni despues del guion bajo
	   let vlValidaEmail = 'F';	   
	   RETURN scodret,vlValidaEmail;  	
	 end if;            

	 LET vlContador = vlContador +1;
  END LOOP;
  RETURN scodret,vlValidaEmail;
END;  
END PROCEDURE;