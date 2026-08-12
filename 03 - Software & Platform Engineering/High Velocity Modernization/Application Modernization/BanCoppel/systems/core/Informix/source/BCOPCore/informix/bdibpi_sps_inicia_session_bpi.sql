CREATE PROCEDURE "informix".sps_inicia_session_bpi(pEmpresa char(3), pIdUsuario char(11),pIp char(15), pTipoToken char(1))
   returning char(5), char (20), char(26), char(26), char(26), char(26), smallint, integer, char(19),DATETIME YEAR TO SECOND, char(1),VARCHAR(11), char(12);
   
    DEFINE cCod_ret char(5);
    DEFINE iSql_err integer ;
    DEFINE cNumCliente char (20);
    DEFINE sIdStatus smallint ;
    DEFINE cNombre1, cNombre2, cApellPaterno, cApellMaterno char (26);
    DEFINE iIdStatusToken integer;
    DEFINE dFecPrimAcceso date;
    DEFINE dFecUltAcceso char(19);
    DEFINE dFecha  DATETIME YEAR TO SECOND;
    DEFINE cTipo char(1);
	DEFINE cNstoken char(9);
	DEFINE vnstoken char(12);
    DEFINE vUsuario VARCHAR(50);
	DEFINE cPass CHAR(50);
	DEFINE vstatus integer;
    DEFINE vservicio integer;
	DEFINE tipo_token CHAR(1);
	
	--Descripcion: Inicia Session
	--22/04/2015
	--Se agrega validaciÌ?n de token nueva bex
	--11/08/2020
	--Gabriela Aguilar

    LET cCod_ret  = "000";
    LET cNumCliente  = '';
    LET sIdStatus = 0;
    LET cNombre1 = '';
    LET cNombre2  = '';
    LET cApellPaterno  = '';
    LET cApellMaterno  = '';
    LET iIdStatusToken = 0;
    LET dFecUltAcceso = '';
    LET dFecha=null;
    LET cTipo="";
	LET cNstoken='';
	LET vnstoken='';
    LET vUsuario = '';
	LET cPass = '';
	LET vstatus=0;
    LET vservicio =0;
	LET tipo_token= '';

	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sps_inicia_session_bpi3.out";
	--TRACE ON;

	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

  BEGIN

   ON EXCEPTION SET iSql_err
      IF iSql_err <> 0 THEN
            LET cCod_ret = iSql_err;
            RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, iIdStatusToken, dFecUltAcceso,dFecha, cTipo, pIdUsuario,vnstoken;
      END IF ;
   END EXCEPTION ;

		
		
		SELECT numcliente into cNumCliente from bdibpi:"informix".bpi_usuario where id_usuario=pIdUsuario;
		
		SELECT usu.usuario, usu.id_status, usu.fec_primer_acceso, usu.f_ultimo_acceso, usu.pass, tk.id_status_token, tk.tipo_token, tk.ns_token
		INTO vUsuario, sIdStatus, dFecPrimAcceso, dFecUltAcceso, cPass, iIdStatusToken, cTipo, cNstoken
		FROM bdinteg:"informix".si_bpiusuarios usu
		LEFT JOIN bdinteg:"informix".si_bpitoken tk ON tk.num_cliente = usu.numcte AND tk.empresa = pEmpresa
		WHERE usu.empresa = pEmpresa AND usu.numcte = cNumCliente;
				
			
		SELECT id_status,servicio 
		INTO vstatus,vservicio
		FROM bdinteg:si_bpiusuarios WHERE numcte=cNumCliente;
	
		
		--validaciÌ?n de token nueva bex
		
		IF cTipo='1' then
			
			if	iIdStatusToken  in ('120','130') THEN
				let cTipo='1';
				let vnstoken=cNstoken;
				let iIdStatusToken=iIdStatusToken;
			
			ELIF
			
			 iIdStatusToken  in ('140','150','151','152') THEN  
				LET vnstoken = cNstoken;
			else
						let iIdStatusToken='140';
						let cTipo='2';
						let vnstoken='TMTTEMP99999';
			  
					
			End if;	
			
		
		ELIF cTipo='2'  then
				if iIdStatusToken ='140'  THEN
					LET vnstoken = 'TMT' || cNstoken;		
				else					
					let iIdStatusToken='140';
					let cTipo='2';	
					let vnstoken='TMTTEMP99999';
				End if;										
		ELSE
			IF vstatus='30' AND vservicio='2' THEN 
				let iIdStatusToken='140';
				let cTipo='2';
				let vnstoken='TMTTEMP99999';
				
			END IF;
		END IF;
		
		---------------------------------------------------------------------------
		IF dFecUltAcceso is NULL THEN
			LET dFecUltAcceso=substring (current::varchar(23) from 1 for 19);
		Else
			LET dFecUltAcceso=substring (dFecUltAcceso::varchar(23)from 1 for 19);
		END IF;
		----------------------------------------------------------------------------
		
		
		
		IF NVL(vUsuario,'') != '' AND NVL(cPass,'') != '' THEN

                SELECT si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno
                INTO cNombre1, cNombre2, cApellPaterno, cApellMaterno
                FROM bdinteg:"informix".si_cliente si WHERE si.empresa=pEmpresa and si.numcte = cNumCliente; --IREB
                            
                IF sIdStatus = '95' or sIdStatus = '10' THEN
                    LET cCod_ret = '000';  -- Usuario inactivo
                    RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, iIdStatusToken, dFecUltAcceso,dFecha,cTipo,pIdUsuario,vnstoken;
                END IF;

                --Actualiza Ultimo Acceso en si_bpi
                IF sIdStatus = 30 THEN
                        UPDATE bdinteg:"informix".si_bpiusuarios SET f_ultimo_acceso = CURRENT  WHERE numcte = cNumCliente;
                        --Actualiza su primer acceso si es la primera vez que ingresa
                        IF dFecPrimAcceso IS NULL THEN
                            UPDATE bdinteg:"informix".si_bpiusuarios SET fec_primer_acceso = CURRENT  WHERE numcte = cNumCliente;
                        END IF;
                    --OBTIEN DATOS DEL LOGIN 
						LET dFecha=current;  
						
					--ACTUALIZA ULTIMO ACCESO en bpi_usuario
                        IF NVL(dFecha, '') <> '' THEN
								UPDATE bdibpi:"informix".bpi_usuario SET f_ultimo_acceso = TODAY WHERE numcliente = cNumCliente AND st_portal = 'activo';
                                --GRABA EN BITACORA CON CODIGO DE OPERACION INICIO DE SESSION == '1000'
								
                                IF NVL(pTipoToken, '') != '' THEN
                                    INSERT INTO bdibpi:"informix".bpi_bitacora(fecha_oper, id_operacion, sucursal, id_usuario, ipusuario, fecha_aplic, cuenta_origen, destino, monto_oper, sec_transaccion, cgenerico1, cgenerico2, cgenerico3, cgenerico4, cgenerico5, cgenerico6, referencia, folio, tipo_token)
                                    VALUES(CURRENT, '1000', '5003', pIdUsuario, pIp, CURRENT, '', '', 0.00, '1000', '', '', '', '', '', '', '', '', pTipoToken);
                                ELSE   
                                    INSERT INTO bdibpi:"informix".bpi_bitacora(fecha_oper, id_operacion, sucursal, id_usuario, ipusuario, fecha_aplic, cuenta_origen, destino, monto_oper, sec_transaccion, cgenerico1, cgenerico2, cgenerico3, cgenerico4, cgenerico5, cgenerico6, referencia, folio)
                                    VALUES(CURRENT, '1000', '5003', pIdUsuario, pIp, CURRENT, '', '', 0.00, '1000', '', '', '', '', '', '', '', '');
								END IF;		
                                 
                                LET cCod_ret = '000';  -- Sesion iniciada
                        ELSE
                                LET cCod_ret = '001';  
                        END IF;
                END IF;	
        ELSE
				SELECT numcte, id_status INTO cNumCliente, sIdStatus FROM bdinteg:"informix".si_bpiusuarios WHERE empresa = pEmpresa AND usuario = vUsuario;
                LET cCod_ret = '002';  -- Usuario y/o Contrasena incorrecta
        END IF ;

   RETURN cCod_ret, cNumCliente, cNombre1, cNombre2, cApellPaterno, cApellMaterno, sIdStatus, iIdStatusToken, dFecUltAcceso,dFecha,cTipo,pIdUsuario,vnstoken;
   

END
END PROCEDURE;