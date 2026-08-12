CREATE PROCEDURE "informix".sp_consulta_rechazos_os(pEmpresa CHAR(3), pSucursal CHAR(20),pNumCte CHAR(20),pStatus_solicitud CHAR(5),
													pFInicial Date, pFFinal Date, pCantRegPres INTEGER )
RETURNING
	CHAR(5)     AS Retorno ,           -- Codigo de Retorno
	CHAR(4)     AS Sucursal ,          -- Numero de Sucursal
	CHAR(4)     AS Producto,           -- Numero de producto	
	CHAR(20)    AS Solicitud ,         -- Nro de Solicitud		
	CHAR(20)    AS Cliente,            -- Nro de Cliente	
	CHAR(120)   AS Nombre,             -- Nombre del Cliente
	DATE        AS Fecha_solicitud,    -- Fecha de Solicitud
	CHAR(60)    AS Descripcion_Status, -- Descripcion del Status de la Solicitud
	CHAR(100)   AS Descripcin_Causa,   -- Descripción de la causa de solicitud
	CHAR(10)    AS Causa_solicitud,    -- Situacion y Causa
	DATE        AS Fecha_Autorizacion, -- Fecha Autorizacion	
	CHAR(10)    AS EmpleadoAutoriza,   -- Dia de Corte
	MONEY(14,2) As MontoAutoriza,      -- Ingreso del Cliente
	CHAR(13)    AS RFC,                -- R.F.C.	
	---CHAR(40)    AS NombProd,           -- Nombre Producto
	---MONEY(14,2) AS Linea_Otorgada,     -- Linea Otorgada
	---CHAR(2)     AS Status,             -- Status de la Solicitud	
	CHAR(255)   AS Comentario;         -- Comentario
	
	/*CHAR(2)     AS Divisa,             -- Divisa
	INTEGER     AS vigencia,           -- Dias de vigencia de la solicitud en su ultimo estatus
	INTEGER     AS Ejecucion,
	INTEGER     AS Limite,
	SMALLINT    AS CausaSituacion,
	INTEGER     AS iEsCtaCap,
	INTEGER     AS iConsultaSP,
	INTEGER     AS vCantRegPres,
	CHAR(1)     AS SituacionEsp,        -- Valor para identificar si tiene o no cuenta de captación
	CHAR(20)  	AS NumCuenta,		    -- numero de cuenta
	INTEGER		AS FrecuenciaPago,      -- frecuencia de pago de nomina
	INTEGER		AS DiaPago;*/

	-- DEFINICION DE VARIABLES
	DEFINE cValRetorno      CHAR(5);
	DEFINE iSqlErr          INTEGER;
	DEFINE	vlRetorno	CHAR(5);           		 -- Codigo de Retorno
	DEFINE	vlSucursal  CHAR(4);       			 -- Numero de Sucursal
	DEFINE	vlProducto  CHAR(4);         	 	 -- Numero de producto	
	DEFINE	vlSolicitud CHAR(20);        		 -- Nro de Solicitud		
	DEFINE	vlCliente   CHAR(20);         		 -- Nro de Cliente	
	DEFINE	vlNombre    CHAR(120);         		 -- Nombre del Cliente
	DEFINE	vlFecha_solicitud  DATE;  		 	 -- Fecha de Solicitud
	DEFINE	vlDescripcion_Status 	CHAR(60);	 -- Descripcion del Status de la Solicitud
	DEFINE	vlDescripcin_Causa		CHAR(100);   -- Descripción de la causa de solicitud
	DEFINE	vlCausa_solicitud		CHAR(10);    -- Situacion y Causa
	DEFINE	vlFecha_Autorizacion	DATE;        -- Fecha Autorizacion	
	DEFINE	vlEmpleadoAutoriza		CHAR(10);    -- Dia de Corte
	DEFINE	vlMontoAutoriza			MONEY(14,2); -- Ingreso del Cliente
	DEFINE	vlRFC					CHAR(15);    -- R.F.C.	
	DEFINE	vlNombProd				CHAR(40);    -- Nombre Producto
	DEFINE	vlLinea_Otorgada		MONEY(14,2); -- Linea Otorgada
	DEFINE	vlStatus				CHAR(2);     -- Status de la Solicitud	
	DEFINE	vlComentario			CHAR(255);   -- Comentario					
	
	DEFINE vCantReg         SMALLINT;	
	DEFINE vCantReg2        SMALLINT;


	--INICIALIZACION DE VARIABLES
	LET cValRetorno      = "00000";
	---LET cValRetorno2     = "00000";
	
	LET	vlRetorno	='00000';
	LET	vlSucursal  ='';
	LET	vlProducto  ='';
	LET	vlSolicitud ='';
	LET	vlCliente   ='';
	LET	vlNombre    ='';
	LET	vlFecha_solicitud  = DATE(0);
	LET	vlDescripcion_Status 	='';
	LET	vlDescripcin_Causa		='';
	LET	vlCausa_solicitud		='';
	LET	vlFecha_Autorizacion	= DATE(0);
	LET	vlEmpleadoAutoriza		='';
	LET	vlMontoAutoriza			= 0;
	LET	vlRFC					='';
	LET	vlNombProd				='';
	LET	vlLinea_Otorgada		= 0;
	LET	vlStatus				='';
	LET	vlComentario			='';
	
	LET  vCantReg         = 0;
	LET  vCantReg2        = 0;
	
	--SET DEBUG FILE TO "/informix/mahr/sp_consulta_rechazos_os.out";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO wait 3;
	
    BEGIN
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                RETURN iSqlErr,'','','','','','','','','','','','','','';
            END IF;
        END EXCEPTION;
	
        IF NVL(pEmpresa,'') = '' THEN
            LET cValRetorno = '00001';
			RETURN  	vlRetorno,	vlSucursal,	vlProducto,	vlSolicitud,	vlCliente,	vlNombre,	vlFecha_solicitud,
						vlDescripcion_Status,	vlDescripcin_Causa,	vlCausa_solicitud,	vlFecha_Autorizacion,
						vlEmpleadoAutoriza,	vlMontoAutoriza,	vlRFC,	--vlNombProd,	vlLinea_Otorgada,	vlStatus,
						vlComentario;
        ELSE
            IF pStatus_solicitud <> 'AT'  Then

                FOREACH
                	select  skip pCantRegPres limit 11 
							sol.sucursal, sol.num_producto, sol.num_solicitud, sol.numcte, 
                            Trim(cte.nombre1)||' ' ||Trim(cte.nombre2)||' ' ||Trim(cte.apell_paterno)||' ' ||Trim(cte.apell_materno) Nombre, 
                            sol.fecha_insert, ( select  descripcion  from bdisolic:ss_status_sol where status_solicitud =sol.status_solicitud ) status, 
                            motivo_cc, situacionespecialrespuesta  ||' ' ||causasituacionespecialrespuesta,        
                            decode(tipo_solicitud,'T',monto_solicitado, Monto_autorizado) MontoAutorizado, RFC        						
                        into 
                            vlSucursal,	vlProducto,	vlSolicitud,	vlCliente,	vlNombre,	vlFecha_solicitud,
                            vlDescripcion_Status,vlDescripcin_Causa,	vlCausa_solicitud,	vlMontoAutoriza,	vlRFC ---,	vlComentario
                    from bdisolic:ss_solicitudes sol, bdinteg:si_cliente cte,
                         bdisolic:ss_resum_scor_fin  res, 
                         bdisolic:ss_solicitud_os solos  
                    where cte.numcte = sol.numcte
					  and res.num_solicitud = sol.num_solicitud  
					  and res.empresa = sol.empresa
					  and sol.status_solicitud = pStatus_solicitud
					  and sol.tipo_solicitud <> 'C'
					  and (sol.sucursal = pSucursal or pSucursal = '')
					  and (sol.numcte = pNumCte or pNumCte = '')
					  and res.evalua_cc = '0'
					  and sol.num_solicitud = solos.num_solicitud
					  and sol.empresa = solos.empresa 
					  and solos.status = 'R'						
                      and solos.fecha_solicitud = (select max(fecha_solicitud) from bdisolic:ss_solicitud_os 
                                                   where empresa = '001' and num_solicitud = sol.num_solicitud ) 
												   
					LET vCantReg       = vCantReg + 1;
					LET vCantReg2      = vCantReg2 + 1;
						
					IF vCantReg <= pCantRegPres  THEN
                        CONTINUE FOREACH;
                    END IF;
						
					RETURN  vlRetorno,	vlSucursal,	vlProducto,	vlSolicitud,	vlCliente,	vlNombre,	vlFecha_solicitud,
                            vlDescripcion_Status,	vlDescripcin_Causa,	vlCausa_solicitud,	vlFecha_Autorizacion,
							vlEmpleadoAutoriza,	vlMontoAutoriza,	vlRFC,	--vlNombProd,	vlLinea_Otorgada,	vlStatus,
							vlComentario WITH RESUME;
                END FOREACH;

            ELSE 	
                FOREACH
                    SELECT skip pCantRegPres limit 11 
						sol.sucursal, sol.num_producto, sol.num_solicitud, sol.numcte, 
						Trim(cte.nombre1)||' ' ||Trim(cte.nombre2)||' ' ||Trim(cte.apell_paterno)||' ' ||Trim(cte.apell_materno) Nombre, 
						sol.fecha_insert,  ( select  descripcion  from bdisolic:ss_status_sol 
											  where status_solicitud =sol.status_solicitud ) status, 
						situacionespecialrespuesta  ||' ' ||causasituacionespecialrespuesta, 
						decode(tipo_solicitud,'T',monto_solicitado, Monto_autorizado) MontoAutorizado, RFC, ejecutivo_auto, 
						fecha_entrada , -- comentario 
						( select a.descripcion from "informix".ss_causas_sol a  where a.status_solicitud = pStatus_solicitud  
						  and aut.causa_solicitud = a.causa_solicitud )
                    INTO
						vlSucursal,	vlProducto,	vlSolicitud, vlCliente,	vlNombre, vlFecha_solicitud,vlDescripcion_Status,
						vlCausa_solicitud,	vlMontoAutoriza,	vlRFC ,	vlEmpleadoAutoriza ,vlFecha_Autorizacion, vlDescripcin_Causa 
                    from bdisolic:ss_solicitudes sol, bdinteg:si_cliente cte  ,     
						 bdisolic:ss_solicitud_os solos  ,  
						 bdisolic:ss_autorizacion aut
                    where cte.numcte = sol.numcte
                      and sol.status_solicitud in ('AT','AP')   
					  and sol.fecha_insert >=  pFInicial and  sol.fecha_insert <=  pFFinal
					  and sol.tipo_solicitud <> 'C'
					  and (sol.sucursal = pSucursal or pSucursal = '')
                      and (sol.numcte = pNumCte or pNumCte = '')
					  and solos.num_solicitud =sol.num_solicitud 
					  and solos.empresa= sol.empresa  
					  and solos.fecha_solicitud = (select max(fecha_solicitud) from bdisolic:ss_solicitud_os where empresa = '001' and num_solicitud = sol.num_solicitud ) 
					  and aut.empresa= sol.empresa  
				      and aut.num_solicitud = sol.num_solicitud 
                      and aut.status_solicitud = pStatus_solicitud    
                      and aut.causa_solicitud in ( 'CCE','CGA','CCR','CIC','GCC','CNO'  )
                    

				  /*select ejecutivo_auto, fecha_entrada, comentario into vlEmpleadoAutoriza ,vlFecha_Autorizacion, vlComentario
				    from bdisolic:ss_autorizacion 
					where empresa = pEmpresa and num_solicitud =  vlSolicitud
					  and status_solicitud = pStatus_solicitud and causa_solicitud ;*/
				  	LET vlComentario = vlDescripcin_Causa;					
                    LET vCantReg       = vCantReg + 1;
                    LET vCantReg2      = vCantReg2 + 1;
						
                    IF vCantReg <= pCantRegPres  THEN
                        CONTINUE FOREACH;
                    END IF;	
						
                    RETURN  vlRetorno,	vlSucursal,	vlProducto,	vlSolicitud,	vlCliente,	vlNombre,	vlFecha_solicitud,
                            vlDescripcion_Status,	vlDescripcin_Causa,	vlCausa_solicitud,	vlFecha_Autorizacion,
                            vlEmpleadoAutoriza,	vlMontoAutoriza,	vlRFC,	--vlNombProd,	vlLinea_Otorgada,	vlStatus,
                            vlComentario WITH RESUME;

                END FOREACH;
            END IF;
        END IF;		
	END
END PROCEDURE
