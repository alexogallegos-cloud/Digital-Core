CREATE PROCEDURE "informix".sp_administradorespm( pNumCteEmp CHAR(9), pNumCteAdmin CHAR(9), pAdminTipo CHAR(3), pIdAdmin CHAR(30), pApellidoPater CHAR(30), pApellidoMater CHAR(30), pNombre1 CHAR(30), pNombre2 CHAR(30), pRepLegal CHAR(1))

RETURNING CHAR(6) AS cCodRet,
		  CHAR(100) AS Mensaje,
		  CHAR(20) AS NUMERO_CLIENTE,		
		  CHAR(12) AS FOLIO_TOKEN;


--****************************************************************************************************
-- Objetivo:Spl que agrega los administradores a la tabla bei_servicio. Se ejecuta una o dos veces 
-- por empresa segun corresponda.
-- Autor: Berenice Noriega
-- FECHA : 07/11/2013
-- SOLICITO : Ismael Hernandez
-- BD: bdibei
--***************************************************************************************************



--DEFINICIONES
DEFINE iSql_Err                     INTEGER;
DEFINE cCodRet         			    CHAR(6);
DEFINE cMensaje                     CHAR(50);
DEFINE cFolioSolToken    			CHAR(12);
--DEFINE cServicioId                  CHAR(20);
DEFINE cMancomunado					SMALLINT;
DEFINE vOper_no_token               smallint;

            
--INICIALIZACIONES			  
    LET iSql_Err           	= 0;
    LET cCodRet           	= '000000';
    LET cMensaje          	= 'SE EJECUTO CORRECTAMENTE';
	LET cFolioSolToken      ='';
    --LET cServicioId         ='';
	LET cMancomunado		= 0;
    LET vOper_no_token      = 0;
BEGIN

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        LET cMensaje = '';
        RETURN 	 cCodRet,cMensaje,pNumCteEmp,cFolioSolToken;
    END EXCEPTION;

	--SET DEBUG FILE TO "/resplogifx/conciliachq/sp_administradorespm.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	
	IF TRIM(NVL(pNumCteEmp,'')) = '' THEN
		LET cCodRet = '00001';
		LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCION';
		RETURN 	 cCodRet,cMensaje,pNumCteEmp,cFolioSolToken;
	END IF;
		
	IF TRIM(pNumCteAdmin) <> '' THEN   ---se buscan los datos del administrador por ser firmante
		SELECT TRIM(apell_paterno), TRIM(apell_materno), TRIM(nombre1), TRIM(nombre2)
		INTO pApellidoPater, pApellidoMater, pNombre1, pNombre2
		FROM bdinteg:"informix".si_cliente 
		WHERE numcte = pNumCteAdmin;
	END IF;
			
		--EJECUTA SPL QUE GENERA EL FOLIO DE LA SOLICITUD
		
    EXECUTE PROCEDURE bdinteg:"informix".sp_generafoliosolicitudtoken()  INTO cCodRet,cFolioSolToken;

	IF cCodRet <> '000000' THEN
		LET cMensaje = 'ERROR EN LA GENERACION DEL FOLIO DE ACTIVACION';
		LET pNumCteEmp = '';
		RETURN 	 cCodRet,cMensaje,pNumCteEmp,cFolioSolToken;
	END IF;
	
	--	REGISTRA LOS ADIMISTRADORES
		INSERT INTO bdibei:"informix".bei_servicio (num_cliente, id_servicio, 
	                folio_contrato, folio_activa, id_status, codidentif, identificacion_admin, f_status, f_registro, f_unico_reg, 
		            status_manco,f_reg_manco,apell_paterno, apell_materno, nombre1, nombre2, es_replegal)
        VALUES  ( TRIM(pNumCteEmp),(SELECT LPAD(CAST(NVL(MAX((id_servicio) + 1),0000000001)  AS INTEGER), 10, '0') FROM bdibei:"informix".bei_servicio), 
		           '', TRIM(cFolioSolToken), '10', TRIM(pAdminTipo), TRIM(pIdAdmin), TODAY, TODAY, CURRENT, 
				   cMancomunado, TODAY, pApellidoPater, pApellidoMater, pNombre1, pNombre2, pRepLegal);
			   
		--   LET cServicioId = (SELECT LPAD(CAST(MAX((id_servicio)) AS INTEGER), 10, '0') FROM bdibei:"informix".bei_servicio WHERE num_cliente = pNumCte);
		 --  cFolioSolToken
 
 	--VALIDA SI EXISTE YA ALGUN ADMINISTRADOR PARA CAMBIAR MANCOMUNIDAD
	IF (SELECT COUNT(*) FROM bdibei:bei_servicio WHERE num_cliente = pNumCteEmp ) > 1 THEN
		UPDATE bdibei:"informix".bei_servicio
		  SET status_manco = 1, f_mod_manco = TODAY
		WHERE num_cliente = TRIM(pNumCteEmp);  
	END IF;
   
 
  		--SE RETORNA INFORMACION.
		
	RETURN 	 cCodRet,cMensaje,pNumCteEmp,cFolioSolToken;
  END;
       
END PROCEDURE
DOCUMENT
'DESCRIPCION: Recibe el número de administradores',
'AUTOR:  Rosa Castro',
'FECHA DE CREACION: 13 de Agosto del 2013',
'FECHA MODIFICACION: 13 de Marzo del 2012',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consulta_oper_manco_bei(
												pNumCliente CHAR(9),
												pIdUser integer,
												pNoReg integer,
												pRegIni integer)
   returning
   CHAR(5),
    INTEGER,
    INTEGER,
    CHAR(50),
    INTEGER,
    CHAR(50),
    SMALLINT,
    DATE,
    SMALLINT,
    SMALLINT,
    CHAR(5),
    INTEGER;




    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER ;

    DEFINE iTotalReg INTEGER ;
    DEFINE iTotalReg1 INTEGER ;
    DEFINE iTotalReg2 INTEGER ;

   DEFINE sIdManco INTEGER;
    DEFINE sIdUsuario INTEGER;
    DEFINE sUserNom CHAR(50);

    DEFINE sIdUserAdmin INTEGER;
    DEFINE sUserNomAdmin CHAR(50);


    DEFINE sIdStatusAut SMALLINT;
    DEFINE sFechaAut DATE ;

    DEFINE sIdTipoOper SMALLINT;
    DEFINE sIdTipoMov SMALLINT;
	DEFINE id_status_token CHAR(5);
    DEFINE id_status_user INTEGER ;

	LET sIdManco=0;
    LET  iTotalReg1=0;
    LET  iTotalReg=0;
    LET  iTotalReg2=0;
    LET cod_ret  = "00000";

    LET sIdUsuario = 0;
    LET sUserNom  = '';

    LET sIdUserAdmin = 0;
    LET sUserNomAdmin = '';

    LET sIdStatusAut = 0;
    LET sFechaAut = 0;

    LET sIdTipoOper=0;
    LET sIdTipoMov=0;
	
	LET id_status_token = '';
    LET id_status_user=0;




--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LAS OPERACION MANCOMUNADAS DE LOS USUARIOS OPERADOR
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
             RETURN cod_ret, iTotalReg,  NVL(sIdUsuario,-1),NVL(sUserNom,''),NVL(sIdUserAdmin,-1),sUserNomAdmin,sIdStatusAut,sFechaAut,sIdTipoOper,sIdTipoMov,id_status_token,id_status_user;
      END IF ;
   END EXCEPTION ;


--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE USUARIOS
--**************************************************************************************************************



        		SELECT COUNT(*)
           		INTO iTotalReg1
            	FROM bdibei:"informix".bei_admin_manco_temp  usu
            	WHERE  usu.num_cliente_admin  = pNumCliente
            	AND usu.id_usuario_admin=pIdUser;

            	SELECT COUNT(*)
           		INTO iTotalReg2
            	FROM bdibei:"informix".bei_admin_manco_temp_hist  usu
            	WHERE  usu.num_cliente_admin  = pNumCliente
            	AND usu.id_usuario_admin=pIdUser;


        LET iTotalReg=iTotalReg1+iTotalReg2;
     SET LOCK MODE TO WAIT 4;

     IF iTotalReg == 0 THEN
          LET cod_ret = '00002'; -- No ay Registros
            RETURN cod_ret, iTotalReg,  NVL(sIdUsuario,-1),NVL(sUserNom,''),NVL(sIdUserAdmin,-1),sUserNomAdmin,sIdStatusAut,sFechaAut,sIdTipoOper,sIdTipoMov,id_status_token,id_status_user;
      END IF ;


--**************************************************************************************************************
--OBTIENES DATOS DE USUARIO
--**************************************************************************************************************

         	FOREACH
                 SELECT SKIP pRegIni FIRST pNoReg  tb.id_admin_manco,tb.id_usuario,tb.id_usuario_admin,tb.usuario_bei_admin,tb.estatus,tb.fecha_aut,tb.tipo_oper,tb.tipo_mov,tb.usuario_bei,tb.id_status_token,tb.id_status
                    INTO   sIdManco,sIdUsuario    ,sIdUserAdmin    ,sUserNomAdmin , sIdStatusAut,sFechaAut    ,sIdTipoOper  ,sIdTipoMov,sUserNom,id_status_token,id_status_user
                FROM(
                    SELECT tmp.id_admin_manco,tmp.id_usuario,tmp.id_usuario_admin,decode(tmp.tipo_mov,1, us.usuario_bei,us.usuario_bei) as usuario_bei_admin,4 as estatus ,DATE(CURRENT) as fecha_aut,tmp.tipo_oper,tmp.tipo_mov,tmp.usuario_bei,tmp.id_status_token,tmp.id_status                  
                    FROM bdibei:"informix".bei_admin_manco_temp  tmp
                    LEFT JOIN  bdibei:"informix".bei_usuario us ON  us.id_usuario=tmp.id_usuario_admin
                    WHERE  tmp.num_cliente_admin  = pNumCliente
                    AND tmp.id_usuario_admin=pIdUser
                    
					UNION
                    SELECT hist.id_admin_manco,hist.id_usuario,hist.id_usuario_admin,decode(hist.tipo_mov,1,us.usuario_bei,us.usuario_bei) as usuario_bei_admin,hist.status_aut as estatus,hist.fecha_aut,hist.tipo_oper,hist.tipo_mov,hist.usuario_bei,hist.id_status_token,hist.id_status
                    FROM bdibei:"informix".bei_admin_manco_temp_hist  hist
                    LEFT JOIN  bdibei:"informix".bei_usuario us ON  us.id_usuario=hist.id_usuario_admin
                    WHERE  hist.num_cliente_admin  = pNumCliente
                    AND hist.id_usuario_admin=pIdUser
                ) tb
                ORDER BY tb.id_admin_manco desc,tb.fecha_aut DESC


                
                IF NVL(sUserNom,'') == '' THEN
                     SELECT usuario_bei
                     INTO sUserNom
                     FROM  bdibei:"informix".bei_usuario
                     WHERE id_usuario = NVL(sIdUsuario,-1);
                END IF;

            	 RETURN cod_ret, iTotalReg,  NVL(sIdUsuario,-1),NVL(sUserNom,''),NVL(sIdUserAdmin,-1),sUserNomAdmin,sIdStatusAut,sFechaAut,sIdTipoOper,sIdTipoMov, id_status_token,id_status_user WITH RESUME;
         	END FOREACH;


END
END PROCEDURE;