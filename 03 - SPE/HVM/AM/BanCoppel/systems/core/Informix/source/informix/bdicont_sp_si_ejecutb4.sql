CREATE PROCEDURE "informix".sp_si_ejecutb4( 
										  pibandera	 	 INTEGER
										, pscve_usuario	 CHAR(10)
										, pspascode		 CHAR(10)
										  )
RETURNING VARCHAR(6)    as Cod_ret
        , VARCHAR(80)   as Men_ret
        , VARCHAR(3)    as vempresa
        , VARCHAR(8)    as vejecutivo
        , VARCHAR(45)   as vnombre
        , VARCHAR(4)    as vsucursal
        , VARCHAR(3)    as vpuesto
        , VARCHAR(3)    as vdepartamento
        , VARCHAR(80)   as vpASsword
        , VARCHAR(80)   as vpAS_cod
        , VARCHAR(20)   as vnombramiento
        , DECIMAL(16,2) as vlimaut_mn
        , DECIMAL(16,2) as vlimaut_dls
        , DATE		    as vvigencia
        , INTEGER	    as vperfil
        , VARCHAR(80)   as vASistente
        , VARCHAR(30)   as vuser_insert
        , DATE 		    as vfecha_insert
		;

	-- Variables de Errores de sistema 
	DEFINE  SQL_ERR             INTEGER;
	DEFINE  ISAM_ERR            INTEGER;
	DEFINE  ERROR_INFO          varchar(80);
	DEFINE  P_COD_RET           VARCHAR(6);
	DEFINE  P_COD_RET2          VARCHAR(6);
	define  P_MENSAJE           varchar(80);
	
	-- Variables locales
	define vsCodRet  			char(5);
	define vsMensaje_Respuesta  char(80);
	define vsempresa			char(3);
	define vsejecutivo          char(8);
	define vsnombre             char(45);
	define vssucursal           char(4);
	define vspuesto             char(3);
	define vsdepartamento       char(3);
	define vspASsword           char(80);
	define vspAS_cod            char(80);
	define vsnombramiento       char(20);
	define vslimaut_mn          DECIMAL(16,2);
	define vslimaut_dls         DECIMAL(16,2);
	define vsvigencia           date;
	define vsperfil             INTEGER;
	define vsASistente          char(80);
	define vsuser_insert        char(45);
	define vsfecha_insert       DATE;
	
	-- InicializaciÃÂ³n de Variables de ciclo
	let	vsCodRet 			 = '00000';
	let	vsMensaje_Respuesta  = 'PROCESO TERMINADO SATISFACTORIAMENTE';
	let vsempresa			 = '';		
	let vsejecutivo          = '';
	let vsnombre             = '';
	let vssucursal           = '';
	let vspuesto             = '';
	let vsdepartamento       = '';
	let vspASsword           = '';
	let vspAS_cod            = '';
	let vsnombramiento       = '';
	let vslimaut_mn          = NULL;
	let vslimaut_dls         = NULL;
	let vsvigencia           = NULL;
	let vsperfil             = NULL;
	let vsASistente          = '';
	let vsuser_insert        = '';
	let vsfecha_insert       = NULL;
	
	BEGIN
	
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		--SET DEBUG FILE TO '/informix/JCQB/sp_analisiscuentas.err';
		--TRACE ON;
		LET P_COD_RET  = SQL_ERR;
		LET P_COD_RET2 = ISAM_ERR;
		LET P_MENSAJE  = ERROR_INFO;
		RETURN P_COD_RET, P_MENSAJE, null, null, null, null     
								   , null, null, null, null      
								   , null, null, null, null     
								   , null, null, null, null;

	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/JCQB/sp_analisiscuentas.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF pibandera = 1 THEN
		FOREACH
			SELECT empresa
				 , ejecutivo
				 , nombre
				 , sucursal
				 , puesto
				 , departamento
				 , password
				 , pass_cod
				 , nombramiento
				 , limaut_mn
				 , limaut_dls
				 , vigencia
				 , perfil
				 , ASistente
				 , user_insert
				 , fecha_insert
			  INTO vsempresa		
				 , vsejecutivo    
				 , vsnombre       
				 , vssucursal     
				 , vspuesto       
				 , vsdepartamento 
				 , vspASsword     
				 , vspAS_cod      
				 , vsnombramiento 
				 , vslimaut_mn    
				 , vslimaut_dls   
				 , vsvigencia     
				 , vsperfil       
				 , vsASistente    
				 , vsuser_insert  
				 , vsfecha_insert 			 
			  FROM bdinteg:"informix".si_ejecut 
			 WHERE ejecutivo = pscve_usuario
			   AND pASs_cod = pspascode
	  
			RETURN vsCodRet, NVL(vsMensaje_Respuesta,''), vsempresa, vsejecutivo, NVL(vsnombre,'') , vssucursal     
														, vspuesto, vsdepartamento, vspASsword, vspAS_cod      
														, vsnombramiento, vslimaut_mn, vslimaut_dls, vsvigencia     
														, vsperfil, vsASistente, vsuser_insert, vsfecha_insert
														WITH RESUME;
			
		END FOREACH;
	ELIF pibandera = 2 THEN

		FOREACH
			SELECT sucursal 
			  INTO vssucursal
			  FROM bdinteg:"informix".si_ejecut 
			 WHERE empresa   = '001' 
			   AND ejecutivo = pscve_usuario

			RETURN vsCodRet, NVL(vsMensaje_Respuesta,''), vsempresa, vsejecutivo, vsnombre , vssucursal     
														, vspuesto, vsdepartamento, vspASsword, vspAS_cod      
														, vsnombramiento, vslimaut_mn, vslimaut_dls, vsvigencia     
														, vsperfil, vsASistente, vsuser_insert, vsfecha_insert
														WITH RESUME;
			   
		END FOREACH;

	ELIF pibandera = 3 THEN

		FOREACH
			SELECT a.perfil
				 , b.sucursal
			  INTO vsperfil
				 , vssucursal
			  FROM bdinteg:si_perfil_ejecut a
				 , bdinteg:"informix".si_ejecut b 
			 WHERE a.perfil    = '703' 
			   AND a.cod_emp   = '001' 
			   AND a.ejecutivo = b.ejecutivo
			   AND a.ejecutivo = pscve_usuario 

			RETURN vsCodRet, NVL(vsMensaje_Respuesta,''), vsempresa, vsejecutivo, vsnombre , vssucursal     
														, vspuesto, vsdepartamento, vspASsword, vspAS_cod      
														, vsnombramiento, vslimaut_mn, vslimaut_dls, vsvigencia     
														, vsperfil, vsASistente, vsuser_insert, vsfecha_insert
														WITH RESUME;			   
		
		END FOREACH;
	ELIF pibandera = 4 THEN

			SELECT nombre 
			  INTO vsnombre
			  FROM bdinteg:"informix".si_ejecut 
			 WHERE empresa   = '001' 
			   AND ejecutivo = pscve_usuario;

			RETURN vsCodRet, NVL(vsMensaje_Respuesta,''), vsempresa, vsejecutivo, vsnombre , vssucursal     
														, vspuesto, vsdepartamento, vspASsword, vspAS_cod      
														, vsnombramiento, vslimaut_mn, vslimaut_dls, vsvigencia     
														, vsperfil, vsASistente, vsuser_insert, vsfecha_insert;

	ELSE
		let	vsCodRet 			 = '00001';
		let	vsMensaje_Respuesta  = 'NO EXISTE LA OPCION';
		let vsempresa			 = '';		
		let vsejecutivo          = '';
		let vsnombre             = '';
		let vssucursal           = '';
		let vspuesto             = '';
		let vsdepartamento       = '';
		let vspASsword           = '';
		let vspAS_cod            = '';
		let vsnombramiento       = '';
		let vslimaut_mn          = NULL;
		let vslimaut_dls         = NULL;
		let vsvigencia           = NULL;
		let vsperfil             = NULL;
		let vsASistente          = '';
		let vsuser_insert        = '';
		let vsfecha_insert       = NULL;
	
			RETURN vsCodRet, NVL(vsMensaje_Respuesta,''), vsempresa, vsejecutivo, vsnombre , vssucursal     
														, vspuesto, vsdepartamento, vspASsword, vspAS_cod      
														, vsnombramiento, vslimaut_mn, vslimaut_dls, vsvigencia     
														, vsperfil, vsASistente, vsuser_insert, vsfecha_insert;
	
	END IF;
	
	END 
	
END PROCEDURE;