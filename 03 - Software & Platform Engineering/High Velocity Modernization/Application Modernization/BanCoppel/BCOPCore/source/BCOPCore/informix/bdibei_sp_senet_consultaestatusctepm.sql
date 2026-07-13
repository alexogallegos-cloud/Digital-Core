CREATE PROCEDURE "informix".sp_senet_consultaestatusctepm( pNumCte CHAR(20) )
	
	RETURNING CHAR(6) 		AS CodRet,
			  CHAR(20)		AS NumCte,
			  CHAR(60)		AS RazonSocial,
		      CHAR(100) 	AS Mensaje,
			  CHAR(3) 		AS Estatus;

	--DEFINICIONES DE VARIABLES.
	DEFINE cCodRet         			CHAR(6);
	DEFINE iSqlErr        			INTEGER;
	DEFINE iIsamErr        			INTEGER;
	DEFINE cDescErr        			CHAR(100);
	DEFINE cMensaje        			CHAR(100);
	DEFINE cEstatus        			CHAR(3);
	DEFINE cNumCte	       			CHAR(20);
	DEFINE cRazonsocial				CHAR(60);
	    	
	--INICIALIZACIONES DE VARIABLES.
	LET cCodRet         			= '000';
	LET iSqlErr         			= 0;
	LET iIsamErr         			= 0;
	LET cDescErr        			= '';
	LET cMensaje        			= 'VALIDACION TERMINADA';
	LET cEstatus        			= '';
	LET cNumCte         			= '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr,iIsamErr,cDescErr
			LET cCodRet = iSqlErr;
			LET cMensaje = cDescErr;
			RETURN cCodRet, cNumCte, cRazonsocial, cMensaje,cEstatus;
		END EXCEPTION;

--SET DEBUG FILE TO "/home/informix/BereniceOut/sp_senet_consultaestatusctepm_bdibei_Ch.out";
--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	  --Valida los parametros de entrada.		
		
		IF NVL(pNumCte, '') = '' THEN
		   LET cCodRet = '002';
		   LET cMensaje = 'EL CLIENTE ESTA VACIO';
		   RETURN cCodRet, cNumCte, cRazonsocial, cMensaje,cEstatus;
		END IF;
				   
		---SE OBTIENEN LOS DATOS DE LA EMPRESA 
		SELECT NVL(a.numcte,''), TRIM(NVL(a.razon_social,''))
		  INTO cNumCte,cRazonsocial
		FROM bdinteg:"informix".si_cliente  a, bdinteg:"informix".si_ctepm  b
		WHERE a.empresa = '001'
		AND a.numcte = pNumCte AND b.numcte = a.numcte;
	    
	-- valida si la cuenta es de una persona moral	
		IF cRazonsocial = '' THEN
			LET cCodRet = '005';
			LET cMensaje = 'EL CLIENTE NO PERTENECE A UNA PERSONA MORAL';
		    RETURN cCodRet, cNumCte, cRazonsocial, cMensaje,cEstatus;
		END IF;
		
	  -- Consulta el estatus que tiene asignado el cliente.
		SELECT status_contrato
			INTO cEstatus
		FROM bdibei:bei_contratacion
		WHERE num_cliente = cNumCte;	
		 
	  -- Valida si el estatus es NULL o Vacio.		
		IF NVL(cEstatus,'') = '' THEN
		   LET cCodRet = '004';
		   LET cEstatus = '';
		   LET cMensaje = 'EMPRESA NO A SIDO DADA DE ALTA EN EL SERVICIO DE EMPRESA NET';		   
		   RETURN cCodRet, cNumCte, cRazonsocial, cMensaje,cEstatus;
		END IF
						
	  -- Valida el estatus obtenido en la consulta.
		IF cEstatus = '0' THEN
  		  LET cCodRet = '000';
 		  LET cMensaje = 'EL PROCESO DE ALTA SE DETUVO EN LA GENERACIÓN DEL CODIGO DE SOLICITUD DEL TOKEN';
		ELIF cEstatus = '1' THEN
	      LET cCodRet =  '000';
		  LET cMensaje = 'EL PROCESO DE ALTA SE DETUVO POR PROBLEMAS EN LA DIGITALIZACIÓN';
		ELIF cEstatus = '2' THEN
		  LET cCodRet = '000';
		  LET cMensaje = 'EL PROCESO DE ALTA SE DETUVO POR PROBLEMAS EN LAS AFECTACIONES A TABLAS';
		ELIF cEstatus = '10' THEN		
		  LET cCodRet = '000';
		  LET cMensaje = 'EL CLIENTE MORAL YA CUENTA CON EL SERVICIO DE EMPRESANET ACTIVO EN CENTRAL';
		ELIF cEstatus = '30' THEN
		  LET cCodRet = '000';
		  LET cMensaje = 'EL CLIENTE MORAL YA CUENTA CON EL SERVICIO DE EMPRESANET ACTIVO EN EL PORTAL';
		ELSE
		  LET cCodRet = '001';
		  LET cMensaje = 'ESTATUS NO VALIDO PARA EL PROCESO DE ALTA DE EMPRESA NET';
		END IF 
		
		RETURN cCodRet, cNumCte, cRazonsocial, cMensaje,cEstatus;
	END;
	
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento que obtiene el estatus del cliente en cuestion al servicio de EmpresaNet.',
'AUTOR:  Valentin Lopez',
'FECHA DE CREACION: 27 de Septiembre del 2011',
'DESCRIPCION MODIFICACION: Cambiar el tamaño de la variable cIdentificacion a char(30) ya que cambio en el tamaño de la tabla y', 
'						   se cambiaron todos los mensajes a mayuscula,se agrego consulta para obtener cDescripIdenfOficial, se',
'						   agrego validacion para el estatus 30, se cambio el orden de retorno para que fuera primero cMensaje y',
'						   despues cEstatus',
'FECHA MODIFICACION: 13 de Marzo del 2012',
'AUTOR MODIFICACION: Guadalupe Payan',
'VERSION: 20120313.1626',
'BD: bdinteg',
'DESCRIPCION: Procedimiento que obtiene el estatus del cliente en cuestion al servicio de EmpresaNet.';

CREATE PROCEDURE "informix".sp_val_pass_exis_bei(pIdUsuario INTEGER,
pPass CHAR(50))
 returning char(5);

    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

	DEFINE sPass                   	CHAR(50);
   	DEFINE sFpass                   	DATE;
   	DEFINE sPass1                    CHAR(50);
   	DEFINE sFpass1                  	DATE;
   	DEFINE sPass2                    CHAR(50);
   	DEFINE sFpass2                  	DATE;
   	DEFINE sPass3                    CHAR(50);
   	DEFINE sFpass3                  	DATE;

    LET cod_ret  = "00000";

--****************************************************************************************************
-- DESCRIPCION:  Actualiza usuario Bei
-- AUTOR : Irving Guzman Salas /SOLSER
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :BanCoppel
-- Liberado a produccion: Mayo 2014
--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           -- ROLLBACK WORk;
          RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

     SET LOCK MODE TO WAIT 4;

     IF NVL(pIdUsuario,'') =='' THEN
	 	  LET cod_ret = '00001'; -- No contiene Dato de Id Usuario
       RETURN cod_ret;
	END IF;

	IF NVL(pPass,'') == '' THEN
	 	  LET cod_ret = '00000'; -- No contiene Password
    ELSE

    	SELECT pass,f_pass,pass1,f_pass1,pass2,f_pass2,pass3,f_pass3
    	INTO sPass,sFpass,sPass1,sFpass1,sPass2,sFpass2,sPass3,sFpass3
    	FROM bdibei:"informix".bei_usuario
    	WHERE id_usuario=pIdUsuario;

    	IF(sPass==pPass)THEN
    	  	LET cod_ret = '00041'; -- PASSWORD Repetido
    	ELIF(sPass1==pPass)THEN
    	  	LET cod_ret = '00041'; -- PASSWORD Repetido
    	ELIF(sPass2==pPass)THEN
    	  	LET cod_ret = '00041'; -- PASSWORD Repetido
    	ELIF(sPass3==pPass)THEN
    	  	LET cod_ret = '00041'; -- PASSWORD Repetido
    	END IF;

		IF(cod_ret<>'00041')THEN

    		LET sPass3=sPass2;
    		LET sFpass3=sFpass2;

    		LET sPass2=sPass1;
    		LET sFpass2=sFpass1;

    		LET sPass1=sPass;
    		LET sFpass1=sFpass;

    		LET sPass=pPass;    	  
		ELSE
			--	ROLLBACK WORk;
		 RETURN cod_ret;
		END IF;

	END IF;

  RETURN cod_ret;
END;
END PROCEDURE;