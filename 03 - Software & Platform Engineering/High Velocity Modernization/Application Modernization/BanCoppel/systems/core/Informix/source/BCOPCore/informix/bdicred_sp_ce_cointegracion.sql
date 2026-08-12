CREATE PROCEDURE "informix".sp_ce_cointegracion( p_cempresa CHAR(3), p_ccosto_orig CHAR(4), p_cusuario CHAR(8),   p_cfecha_captura DATE,
			                                     p_ccuenta CHAR(4),  p_csubcta CHAR(2),     p_csubsubcta CHAR(2), p_cssubsubcta CHAR(2), 
												 p_csssubsubcta CHAR(2), p_csector CHAR(2), p_cregional CHAR(3),  p_csucursal CHAR(4), 
												 p_cnro_auxiliar CHAR(12), p_cfecha DATE,   p_cmoneda CHAR(2),    p_cnaturaleza CHAR(1),
			                                     p_mimporte MONEY(18,2), p_cconcepto CHAR(80), p_cusuario_int CHAR(8), pIntegra smallint,
                                                 pNumTotal  INTEGER)

    RETURNING CHAR(5)   as codigo_retorno, 
	          CHAR(255) as Mensaje,
			  INTEGER   as Control_poliza;

    DEFINE     	sql_err                 INTEGER;
    DEFINE     	isam_err                INTEGER;
    DEFINE     	error_info              CHAR(40);
    DEFINE     	cod_ret                 CHAR(6);
	DEFINE	   	mensaje_ret				VARCHAR(255);	
	DEFINE	   	vcontrol_poliza			INTEGER;	
	DEFINE	   	vSecuencia				INTEGER;
	DEFINE	   	vCtaContable			CHAR(4);
	DEFINE	   	vSubCtaContable			CHAR(2);
	DEFINE	   	vSSCtaContable			CHAR(2);
	DEFINE	   	vSSSCtaContable			CHAR(2);
	DEFINE	   	vSSSSCtaContable		CHAR(2);
	DEFINE	   	vSector			        CHAR(2);
	DEFINE	   	vAuxiliar		        CHAR(12);
	DEFINE     	vlNumRegistros			INTEGER;
	DEFINE		vlControl				INTEGER;
	DEFINE      vlCifraControl			MONEY;	
	DEFINE		vlNumTotalDp			INTEGER;
	
    LET 	   	cod_ret 				= '00000'; 
	LET 	   	mensaje_ret 			= 'PROCESO EXITOSO';
	LET 	   	vcontrol_poliza 		= 0;
	LET		   	vSecuencia 				= 0;	
	LET	       	vCtaContable			= "";
	LET	   	   	vSubCtaContable			= "";
	LET	       	vSSCtaContable			= "";
	LET	       	vSSSCtaContable			= "";
	LET	       	vSSSSCtaContable		= "";
	LET	       	vSector			        = "";
	LET	       	vAuxiliar		        = "";
	LET 	   	vlNumRegistros		    = 0;
	LET			vlControl				= 0;
	LET			vlCifraControl			= 0.0;
    LET			vlNumTotalDp			= 0;

    BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cod_ret = sql_err;
			LET mensaje_ret =error_info;
            SET DEBUG FILE TO "ErrPoliza.err";
            TRACE sql_err||" * "||isam_err|| " * "||error_info|| mensaje_ret;
            RETURN cod_ret, mensaje_ret, vcontrol_poliza;
        END EXCEPTION;

		SET LOCK MODE TO WAIT 10;
        --*****************************************************************
        --      			--*
        --Debug del Procedure                                			--*        
        --*****************************************************************
		-- set debug file to '../informix/SD/Orion/sp_ce_cointegracion.out';
		-- set debug file to 'sp_ce_cointegracion.out';
		-- trace on;                                                    --*

		if  pIntegra = 1 then 
		  DELETE FROM bdicont:"informix".co_integracion WHERE usuario_int=p_cusuario;		  
		  select limit 1 control_poliza 
		    into vlControl
		  FROM bdicont:"informix".co_detpol 
		  where fecha_captura = p_cfecha_captura 
			   and usuario =p_cusuario 
			   and fecha_valida =p_cfecha; 
		  if vlControl >0 THEN
		    DELETE FROM bdicont:"informix".co_detpol 
			  where fecha_captura = p_cfecha_captura 
			   and usuario =p_cusuario 
			   and fecha_valida =p_cfecha 
			   and control_poliza  = vlControl;
		    DELETE FROM bdicont:"informix".co_poliza 
			 where fecha_captura = p_cfecha_captura  
			  and usuario = p_cusuario 
			  and control_poliza  = vlControl;
		  END IF;	
		end if;
		if  pIntegra = 3 then 
		  select count(control_poliza) 
		    into vlNumTotalDp
		  FROM bdicont:"informix".co_detpol 
		  where fecha_captura = p_cfecha_captura 
			and usuario =p_cusuario 
			and fecha_valida =p_cfecha; 
		  if vlNumTotalDp >0 then
		    select limit 1 control_poliza 
		      into vlControl
		      FROM bdicont:"informix".co_detpol 
		     where fecha_captura = p_cfecha_captura 
			   and usuario =p_cusuario 
			   and fecha_valida =p_cfecha; 
		  
		    select cifra_control
			   into vlCifraControl
   			  from bdicont:"informix".co_poliza 
			 where fecha_captura = p_cfecha_captura  
			  and usuario = p_cusuario 
			  and control_poliza  = vlControl;
		    IF vlCifraControl = p_mimporte THEN
			  LET cod_ret ='00000';
			  LET mensaje_ret = vlCifraControl;			  
			ELSE  
			  LET cod_ret ='00999';
			END IF;
			LET vcontrol_poliza = vlControl;
			RETURN cod_ret, mensaje_ret, vcontrol_poliza;	
		  end if;
		end if;
		--VALIDAR LOS PARAMETROS DE ENTRADA
		IF p_cempresa = '' OR p_ccosto_orig = '' OR p_cusuario = '' OR  p_cfecha_captura = '' THEN
			LET cod_ret = '00001'; 
			LET mensaje_ret = 'Favor de validar los datos Empresa, Centro de Costo, Usuario y Fecha de Captura';
		END IF;

		IF p_ccuenta = '' OR p_csubcta = '' OR p_csubsubcta = '' OR  p_cssubsubcta = '' or p_csssubsubcta = '' THEN
			LET cod_ret = '00002';
			LET mensaje_ret = 'Favor de validar los datos de las cuentas';
		END IF;

		IF  p_csector = '' OR p_cregional = '' OR  p_csucursal = '' THEN
			LET cod_ret = '00003';
			LET mensaje_ret = 'Favor de validar Sector, Region y Sucursal';
		END IF;

		IF p_cfecha = '' OR p_cmoneda = '' OR  p_cnaturaleza = '' THEN
			LET cod_ret = '00004';
			LET mensaje_ret = 'Favor de validar Fecha, Moneda y Naturaleza de la cuenta';
		END IF;

		IF (p_mimporte = '' OR p_mimporte IS NULL) OR (p_cusuario_int = '' OR p_cusuario_int IS NULL) THEN
			LET cod_ret = '00005';	
			LET mensaje_ret = 'Favor de validar el importe y los usuarios';
		END IF;
        
			execute procedure bdicont:sp_co_integracion 
			( p_cempresa,    p_ccosto_orig,  p_cusuario, p_cfecha_captura, p_ccuenta,  p_csubcta,       p_csubsubcta, 
			  p_cssubsubcta, p_csssubsubcta, p_csector,  p_cregional,      p_csucursal,p_cnro_auxiliar, p_cfecha, 
			  p_cmoneda,     p_cnaturaleza,  p_mimporte, p_cconcepto,      p_cusuario_int) 
			into cod_ret, mensaje_ret ;
        if cod_ret <> '000' then
		  execute procedure bdicont:sp_co_erro_integra ( p_cusuario, p_cfecha_captura ) 
		               into vcontrol_poliza, vSecuencia, vCtaContable,
	                        vSubCtaContable	, vSSCtaContable, vSSSCtaContable, vSSSSCtaContable	,vSector,
	                        vAuxiliar, cod_ret; 					   
		  LET cod_ret = lpad (trim(cod_ret), 5,'0');
		else
		  let cod_ret = '00000';
		  if pIntegra = 2 then 
		    select count(*) into vlNumRegistros
			  from bdicont:co_integracion
			 where empresa = p_cempresa
               and ccosto_orig =p_ccosto_orig
               and usuario =p_cusuario
               and fecha_captura =p_cfecha_captura;
			IF vlNumRegistros = pNumTotal THEN   
		      execute procedure bdicont:sp_co_importa ( p_cempresa, p_cusuario, p_cfecha_captura ) 
		                 into cod_ret, vcontrol_poliza,mensaje_ret ;
			ELSE 
			  LET cod_ret = '00006';
			  LET mensaje_ret = 'Numero Total de Registros Enviados no Coincide con Registrados '||vlNumRegistros||' '||pNumTotal;  
			END IF;
		  end if;
		end if;		
		let vAuxiliar = '';
		if cod_ret = 106 then let mensaje_ret = 'Error al Integrar la Poliza, Favor de validar los movimientos'; end if;
		let cod_ret = lpad(trim(cod_ret), 5,'0');
		if trim(cod_ret) = '000' then let cod_ret ='00000'; end if;
		let mensaje_ret = 'EL REGISTRO SE INSERTO CORRECTAMENTE';		-- Cambio 'MENSAJE PRUEBA'
	RETURN cod_ret, mensaje_ret, vcontrol_poliza;	
    END	
END PROCEDURE;