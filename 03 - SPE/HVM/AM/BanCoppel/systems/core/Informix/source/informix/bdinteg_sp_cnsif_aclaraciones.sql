CREATE PROCEDURE "informix".sp_cnsif_aclaraciones(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(12), cNUMTARJETA CHAR(16),dPERIODOI  DATE, dPERIODOF DATE,pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)     AS Cod_Retorno,
						  CHAR(11)    AS Ticket,
						  CHAR(50)    AS Evento,
						  CHAR(255)   AS Status,
						  MONEY(14,2) AS Importe,
						  MONEY(14,2) AS Abono,
						  DATE        AS Fecha_Captura,
						  DATE        AS Fecha_Solucion,
						  CHAR(04)    AS Sucursal,
						  CHAR(04)    AS Cve_Documento,
						  SMALLINT    AS Secuencia;
										
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
--VARIABLES
DEFINE cTicket	       CHAR(11);
DEFINE cEvento	       CHAR(50);
DEFINE cStatus	       CHAR(255);
DEFINE mImporte		   MONEY(14,2);
DEFINE mAbono		   MONEY(14,2);
DEFINE dFechaCaptura   DATE;
DEFINE dFechaSolucion  DATE;
DEFINE cSucursal       CHAR(04);
DEFINE cCveDoc	       CHAR(04);
DEFINE smallSecuencia  SMALLINT;

DEFINE iFkyCliente      INTEGER;
DEFINE iPkyProducto     INTEGER;
DEFINE iFkyTipoProd     INTEGER;
DEFINE iPkyTipoEvento   INTEGER;
DEFINE iFkyStatusAclara INTEGER;
DEFINE iPkyAclaracion   INTEGER;
DEFINE iPkySucursal     INTEGER;

DEFINE cNumCliente      CHAR(20);
DEFINE cGrupoDoc        CHAR(04);
DEFINE cCodDef          CHAR(04);


DEFINE iCont            INTEGER;

--INICIALIZA VARIABLES
LET  iexiste 		    = 0;
LET cCodRet 	        = "00000";
LET iSql_err 			= 0 ;	

LET cTicket             ="";
LET cEvento 			= "";
LET cStatus				= "";
LET mImporte			= 0;
LET mAbono		        = 0;
LET dFechaCaptura       = "";
LET dFechaSolucion  	= "";
LET cSucursal       	= "";
LET cCveDoc	       		= "";
LET smallSecuencia  	= 0;

LET iFkyCliente      = 0;
LET iPkyProducto     = 0;
LET iFkyTipoProd     = 0;
LET iPkyTipoEvento   = 0;
LET iFkyStatusAclara = 0;
LET iPkyAclaracion   = 0;
LET iPkySucursal     = 0;

LET cNumCliente      = '';
LET cGrupoDoc        = '';
LET cCodDef          = '';

LET iCont            = 0;



BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
		END IF;
	END EXCEPTION;
	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_aclaraciones.out";
	--  TRACE ON;

SET LOCK MODE TO WAIT 3;

	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR (cNUMCUENTA   = '' AND cNUMTARJETA  = '') OR
		dPERIODOI    = ''   OR
		dPERIODOF    = ''   THEN 
		LET cCodRet = "00054";
		RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
	END IF;	
    
    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;					
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
        END IF;
    END IF;    
	--VALIDACION
	IF cNUMCUENTA <> '' THEN
        IF SUBSTR(cNUMCUENTA,1,1)='3' THEN    
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'03','1')
            INTO
            cCodRet;
        ELIF SUBSTR(cNUMCUENTA,1,1)='6' THEN      
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
            INTO
            cCodRet;  
        ELSE
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'11','1')
            INTO
            cCodRet;
        END IF;
	ELSE
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMTARJETA,'11','3')
		INTO
		cCodRet;
	END IF
	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;					
	END IF;
	-- TERMINA VALIDACION		
	SET ISOLATION TO DIRTY READ;
    IF cNUMCUENTA<>'' THEN
        SELECT NVL(COUNT(num_cliente),0) into iexiste FROM bdiaclaracion:acl_producto WHERE numero_cuenta  = cNUMCUENTA;
	ELSE
        SELECT NVL(COUNT(num_cliente),0) into iexiste FROM bdiaclaracion:acl_producto WHERE numero_tarjeta = cNUMTARJETA;
    END IF;
	IF iexiste  = 0 THEN 
        LET cCodRet = "00058";
        RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
    END IF;

    IF cNUMCUENTA<>'' THEN
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT  
            num_cliente,pky_producto,fky_tipo_producto
            INTO 		
            cNumCliente,iPkyProducto,iFkyTipoProd
            FROM bdiaclaracion:acl_producto
            WHERE numero_cuenta = cNUMCUENTA

            SET ISOLATION TO DIRTY READ;
            FOREACH

                SELECT {+INDEX (bdiaclaracion:"informix".acl_aclaracion 132_91)} SKIP pNumRegistro FIRST pRecuperacion
                folio_csuac AS ticket,
                importereclamado AS importe, 
                CASE 
                WHEN fky_estatus_corp_general = 8 THEN importereclamado ELSE null END AS Abono,
                fechacaptura,
                CASE 
                WHEN fecha_dictamen IS NULL THEN null ELSE fecha_dictamen END AS fecha_solucion,
                fky_tipo_evento,
                fky_estatus_aclaracion,
                pky_aclaracion
                INTO
                cTicket,mImporte,mAbono,dFechaCaptura,dFechaSolucion,iPkyTipoEvento,iFkyStatusAclara,iPkyAclaracion
                FROM bdiaclaracion:acl_aclaracion
                WHERE num_cliente = cNumCliente
                AND fky_producto = iPkyProducto
                AND fecha_dictamen::DATE BETWEEN dPERIODOI AND dPERIODOF ORDER BY folio_csuac

                SELECT descripcion,grupo_doc
                INTO cEvento,cGrupoDoc
                FROM bdiaclaracion:acl_tipo_evento
                WHERE pky_tipo_evento = iPkyTipoEvento;


                SELECT FIRST 1 cod_definicion
                INTO cCodDef
                FROM bdidigital@coppelimg_tcp:dg_definicion
                WHERE cod_producto = cGrupoDoc;

                IF LENGTH(cCodDef) = 3 THEN
                    LET cCodDef = '0' || cCodDef;
                END IF

                SELECT descripcion AS Estatus
                INTO cStatus
                FROM bdiaclaracion:acl_estatus_aclaracion
                WHERE pky_estatus_aclaracion = iFkyStatusAclara;

                SELECT --+AVOID_FULL (bdiaclaracion:"informix".acl_movimiento)
				NVL(num_sucursal,'') INTO cSucursal FROM bdiaclaracion:acl_movimiento WHERE fky_aclaracion = iPkyAclaracion;

                SET ISOLATION TO DIRTY READ;
                SELECT cod_docto,secuencia 
                INTO cCveDoc,smallSecuencia
                FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE cliente = cNumCliente
                -- AND empresa = '001'
                AND cuenta = cTicket
                AND cod_docto  = cCodDef
                AND secuencia =(SELECT max(secuencia) FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE cliente = cNumCliente
                --AND empresa = '001'
                AND cuenta = cTicket
                AND cod_docto  = cCodDef);

                LET iCont=iCont+1;

                RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia With Resume;

            END FOREACH;
        END FOREACH;            
    ELSE
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT  
            num_cliente,pky_producto,fky_tipo_producto
            INTO 		
            cNumCliente,iPkyProducto,iFkyTipoProd
            FROM bdiaclaracion:acl_producto
            WHERE numero_tarjeta = cNUMTARJETA

            SET ISOLATION TO DIRTY READ;
            FOREACH

                SELECT {+INDEX (bdiaclaracion:"informix".acl_aclaracion 132_91)} SKIP pNumRegistro FIRST pRecuperacion
                folio_csuac AS ticket,
                importereclamado AS importe, 
                CASE 
                WHEN fky_estatus_corp_general = 8 THEN importereclamado ELSE null END AS Abono,
                fechacaptura,
                CASE 
                WHEN fecha_dictamen IS NULL THEN null ELSE fecha_dictamen END AS fecha_solucion,
                fky_tipo_evento,
                fky_estatus_aclaracion,
                pky_aclaracion
                INTO
                cTicket,mImporte,mAbono,dFechaCaptura,dFechaSolucion,iPkyTipoEvento,iFkyStatusAclara,iPkyAclaracion
                FROM bdiaclaracion:acl_aclaracion
                WHERE num_cliente = cNumCliente
                AND fky_producto = iPkyProducto
                AND fecha_dictamen::DATE BETWEEN dPERIODOI AND dPERIODOF ORDER BY folio_csuac

                SELECT descripcion,grupo_doc
                INTO cEvento,cGrupoDoc
                FROM bdiaclaracion:acl_tipo_evento
                WHERE pky_tipo_evento = iPkyTipoEvento;


                SELECT FIRST 1 cod_definicion
                INTO cCodDef
                FROM bdidigital@coppelimg_tcp:dg_definicion
                WHERE cod_producto = cGrupoDoc;

                IF LENGTH(cCodDef) = 3 THEN
                    LET cCodDef = '0' || cCodDef;
                END IF

                SELECT descripcion AS Estatus
                INTO cStatus
                FROM bdiaclaracion:acl_estatus_aclaracion
                WHERE pky_estatus_aclaracion = iFkyStatusAclara;

                SELECT --+AVOID_FULL (bdiaclaracion:"informix".acl_movimiento)
				NVL(num_sucursal,'') INTO cSucursal FROM bdiaclaracion:acl_movimiento WHERE fky_aclaracion = iPkyAclaracion;

                SET ISOLATION TO DIRTY READ;
                SELECT cod_docto,secuencia 
                INTO cCveDoc,smallSecuencia
                FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE cliente = cNumCliente
                --AND empresa = '001'
                AND cuenta = cTicket
                AND cod_docto  = cCodDef
                AND secuencia =(SELECT max(secuencia) FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE cliente = cNumCliente
                --AND empresa = '001'
                AND cuenta = cTicket
                AND cod_docto  = cCodDef);

                LET iCont=iCont+1;

                RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia With Resume;

            END FOREACH;
        END FOREACH;            
    END IF;
    IF iCont = 0 THEN
        IF pNumRegistro=0 THEN
            LET cCodRet = '00091'; 
        ELSE
            LET cCodRet = '1001'; 
        END IF;
        RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
    END IF 
END

END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de Aclaraciones asociadas a un Cliente. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el Número de Cuenta.",
"FECHA : 23-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".img_sol_rec_clientes(pempresa char(3))
RETURNING    char(5);  

   DEFINE v_codret char(5);
   DEFINE v_cliente char(9);
   DEFINE v_cod_docto char(4);
   DEFINE v_secuencia smallint;
   DEFINE sql_err,isam_err int; 
   define v_cuenta char(20);
   define v_producto char(04);
   define v_tipo_cliente char(01);
   --define v_contador smallint;


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_cliente     = "";
   LET v_cod_docto    = "";
   LET v_secuencia = 0;
   let v_cuenta = "";
   let v_producto = "";
   let v_tipo_cliente = "";
   --let v_contador = 0;


BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;

--SET DEBUG FILE TO '/tmp/img_sol_rec_2';
--TRACE ON;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pempresa is null THEN
    
       -- datos de entrada incompletos
       
       LET v_codret = 110; 
       RETURN v_codret; 
    END IF;

--------------------RGH

	

        FOREACH WITH HOLD

	    SELECT numcte, tipo_cliente
            INTO v_cliente, v_tipo_cliente
            FROM bdidigital@coppelimg_tcp:tmp_cliente 
            WHERE tipo_cliente <> '5'
	

            BEGIN WORK;

            FOREACH WITH HOLD
                SELECT cod_docto,secuencia, cuenta, producto
                INTO v_cod_docto, v_secuencia, v_cuenta, v_producto
                FROM bdidigital@coppelimg_tcp:dg_expediente 
                WHERE cliente = v_cliente
                --WHERE empresa = pempresa

		 --BEGIN WORK;

                    DELETE FROM bdidigital@coppelimg_tcp:dg_expediente_img
                    WHERE empresa = pempresa
                    AND cliente = v_cliente
                    AND cod_docto = v_cod_docto
                    AND secuencia = v_secuencia;

                    DELETE FROM bdidigital@coppelimg_tcp:dg_expediente
                    --WHERE empresa = pempresa
                    WHERE cliente = v_cliente
                    AND cod_docto = v_cod_docto
                    and cuenta = v_cuenta
                    AND producto = v_producto
                    AND secuencia = v_secuencia;
	            
		--COMMIT WORK;

            END FOREACH;

            update bdidigital@coppelimg_tcp:tmp_cliente
            set tipo_cliente = '5'
            where numcte = v_cliente;

            if (v_tipo_cliente = '1') then
                update bdinteg:si_cliente 
                set tipo_cliente = '2'
                where numcte = v_cliente;
            end if;

		COMMIT WORK;

		--LET v_contador = v_contador + 1;
	
		--IF (v_contador <= 100) THEN
			--CONTINUE FOREACH;
		--ELSE 
			--LET v_codret = '000';
			--RETURN v_codret;
		--END IF;
	

	    END FOREACH;


	

END;    

RETURN v_codret;

END PROCEDURE;