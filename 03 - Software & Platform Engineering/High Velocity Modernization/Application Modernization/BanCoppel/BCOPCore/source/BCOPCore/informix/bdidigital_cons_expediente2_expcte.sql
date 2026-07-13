CREATE PROCEDURE "informix".cons_expediente2_expcte(pEmpresa CHAR(3),
                pCliente    CHAR(20),
                pNum_regs   SMALLINT)
            RETURNING
            CHAR(5),CHAR(20),CHAR(40),CHAR(4),DATE,
            CHAR(3),CHAR(30),CHAR(35),CHAR(30),
            CHAR(1),SMALLINT,CHAR(1);


DEFINE cCodret          CHAR(5);
DEFINE cCodret2         CHAR(5);
DEFINE cCuenta          CHAR(20);
DEFINE cProd_nombre     CHAR(40);
DEFINE cCod_docto       CHAR(4);
DEFINE dFecha_alta      DATE;
DEFINE dtFechaAnt      DATE;
DEFINE cCod_grupo       CHAR(3);
DEFINE cDescrip_gpo     CHAR(30);
DEFINE cDescrip_docto   CHAR(35);
DEFINE cDescrip2        CHAR(30);
DEFINE cMulti_img       CHAR(1);
DEFINE siSecuencia      SMALLINT;
DEFINE siContador       SMALLINT;
DEFINE iSql_err         INT;
DEFINE iIsam_err        INT;
DEFINE cIma_esnula      CHAR(1);
DEFINE iDias 		INTEGER;
DEFINE cTipoCons 		CHAR(1);

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

LET cCodret            = "000";
LET cCodret2           = "000";
LET cCuenta            = " ";
LET cProd_nombre       = " ";
LET cCod_docto         = " ";
LET dFecha_alta        = today;
LET dtFechaAnt        = today;
LET cCod_grupo         = " ";
LET cDescrip_gpo       = " ";
LET cDescrip_docto     = " ";
LET cDescrip2          = " ";
LET cMulti_img         = " ";
LET siSecuencia        = 0;
LET siContador         = 0;
LET cIma_esnula        = "0";
LET iDias =  0;
LET cTipoCons =  '';
-- set debug file to "/dbexportb/cons_expediente2.out";
-- trace on;

BEGIN
   ON EXCEPTION SET iSql_err,iIsam_err
      IF iSql_err <> 0 OR iIsam_err <> 0 THEN
         LET cCodret = iSql_err;
         RETURN cCodret,cCuenta,cProd_nombre,cCod_docto,dFecha_alta,
            cCod_grupo, cDescrip_gpo,cDescrip_docto,cDescrip2,
            cMulti_img,siSecuencia,cIma_esnula;
      END IF;
   END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pEmpresa IS NULL OR
        pCliente IS NULL OR
        pNum_regs IS NULL THEN

       -- datos de entrada incompletos

       LET cCodret = "110";
       RETURN cCodret,cCuenta,cProd_nombre,cCod_docto,dFecha_alta,
          cCod_grupo,cDescrip_gpo,cDescrip_docto,cDescrip2,
          cMulti_img,siSecuencia,cIma_esnula;
    END IF;


 SELECT valor
	INTO iDias
	FROM bdicred:"informix".sd_param
	WHERE empresa = pEmpresa
	AND cod_param ='087';

	CALL  bdicred:'informix'.monthadd (today,- iDias) RETURNING dtFechaAnt;
-- ****************************************************************************
-- obtener registros
-- ****************************************************************************
	FOREACH--para los que quiero solo los ultimos

        --reemplazar coppelimg_tcp por coppelimg_app
        SELECT  ex.cuenta,ex.producto || ' ' || ex.prod_nombre,
                ex.cod_docto,ex.fecha_alta,gd.cod_grupo,
                gd.descripcion,td.descripcion,td.multi_imagen,
                ex.secuencia,nvl(ex.descrip2," "),rev.tipo_consulta
        INTO    cCuenta,cProd_nombre,cCod_docto,dFecha_alta,
                cCod_grupo,cDescrip_gpo,cDescrip_docto,
                cMulti_img,siSecuencia,cDescrip2,cTipoCons
        FROM    bdidigital@coppelimg_crx:"informix".dg_expediente ex,
                bdidigital@coppelimg_crx:"informix".dg_grupodocto gd,
                bdidigital@coppelimg_crx:"informix".dg_tipodocumento td,
				bdidigital@coppelimg_crx:"informix".dg_revision_expediente_cte rev
        WHERE   ex.cod_docto       = td.cod_docto
                AND td.cod_grupo   = gd.cod_grupo
				AND rev.cod_grupo   = gd.cod_grupo
				AND rev.cod_docto       = td.cod_docto
				AND rev.tipo_consulta IN ('0','2')
                -- AND ex.empresa     = pEmpresa
                AND ex.cliente     = pCliente
                AND ex.descrip2    <> 'firma_borra_da'
				AND ex.secuencia in(SELECT max(ex2.secuencia)
                                FROM   bdidigital@coppelimg_crx:"informix".dg_expediente ex2,
                                       bdidigital@coppelimg_crx:"informix".dg_grupodocto gd2,
                                       bdidigital@coppelimg_crx:"informix".dg_tipodocumento td2,
                                       bdidigital@coppelimg_crx:"informix".dg_revision_expediente_cte rev2
                                WHERE    ex2.cod_docto       = ex2.cod_docto
										AND ex2.cod_docto       = td2.cod_docto
										AND td2.cod_grupo   = gd2.cod_grupo
										AND td.cod_grupo   = gd2.cod_grupo
										AND rev2.cod_grupo   = gd2.cod_grupo
										AND rev2.cod_docto       = td2.cod_docto
										AND rev2.tipo_consulta IN ('0','2')
                                      --  AND ex2.empresa     = pEmpresa
										AND ex2.cliente     = pCliente
                                        AND ex2.descrip2    <> 'firma_borra_da'
										AND ex2.secuencia = ex.secuencia)
        ORDER BY ex.fecha_alta,ex.cuenta,ex.cod_docto

		IF (dFecha_alta <  dtFechaAnt) AND cTipoCons ='0'  THEN
			CONTINUE FOREACH;
		END IF

        LET siContador = siContador + 1;

        IF siContador < pNum_regs THEN
                CONTINUE FOREACH;
        END IF;

       EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".cons_imgnula(pEmpresa,pCliente,cCod_docto,siSecuencia)
       INTO cCodret2,cIma_esnula;


        RETURN  cCodret,cCuenta,cProd_nombre,cCod_docto,
            dFecha_alta,cCod_grupo,cDescrip_gpo,
            cDescrip_docto,cDescrip2,cMulti_img,
            siSecuencia,cIma_esnula
            WITH resume;

    END FOREACH

    FOREACH---todos los demas

        --reemplazar coppelimg_tcp por coppelimg_app
        SELECT  ex.cuenta,ex.producto || ' ' || ex.prod_nombre,
                ex.cod_docto,ex.fecha_alta,gd.cod_grupo,
                gd.descripcion,td.descripcion,td.multi_imagen,
                ex.secuencia,nvl(ex.descrip2," ")
        INTO    cCuenta,cProd_nombre,cCod_docto,dFecha_alta,
                cCod_grupo,cDescrip_gpo,cDescrip_docto,
                cMulti_img,siSecuencia,cDescrip2
        FROM    bdidigital@coppelimg_crx:"informix".dg_expediente ex,
                bdidigital@coppelimg_crx:"informix".dg_grupodocto gd,
                bdidigital@coppelimg_crx:"informix".dg_tipodocumento td,
				bdidigital@coppelimg_crx:"informix".dg_revision_expediente_cte rev
        WHERE   ex.cod_docto       = td.cod_docto
                AND td.cod_grupo   = gd.cod_grupo
				AND rev.cod_grupo   = gd.cod_grupo
				AND rev.cod_docto       = td.cod_docto
				AND rev.tipo_consulta = '1'
              --  AND ex.empresa     = pEmpresa
                AND ex.cliente     = pCliente
				AND ex.fecha_alta > dtFechaAnt
                AND ex.descrip2    <> 'firma_borra_da'
        ORDER BY ex.fecha_alta,ex.cuenta,ex.cod_docto


        LET siContador = siContador + 1;

        IF siContador < pNum_regs THEN
                CONTINUE FOREACH;
        END IF;

       EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".cons_imgnula(pEmpresa,pCliente,cCod_docto,siSecuencia)
       INTO cCodret2,cIma_esnula;


        RETURN  cCodret,cCuenta,cProd_nombre,cCod_docto,
            dFecha_alta,cCod_grupo,cDescrip_gpo,
            cDescrip_docto,cDescrip2,cMulti_img,
            siSecuencia,cIma_esnula
            WITH resume;

    END FOREACH


END;
END PROCEDURE
DOCUMENT
'---------------------------------',
'DSB 09/06/2014',
'Autor: Jesus Aguilar',
'SP creado a partir de cons_expediente. Consulta el expediente de documentos del cliente.',
'---------------------------------';

CREATE PROCEDURE "informix".cons_expediente2_mib(pEmpresa CHAR(3),
                pCliente    CHAR(20),
                pNum_regs   SMALLINT)
            RETURNING
            CHAR(5),CHAR(20),CHAR(40),CHAR(4),DATE,
            CHAR(3),CHAR(30),CHAR(35),CHAR(30),
            CHAR(1),SMALLINT,CHAR(1);


   DEFINE cCodret          CHAR(5);
   DEFINE cCodret2         CHAR(5);
   DEFINE cCuenta          CHAR(20);
   DEFINE cProd_nombre     CHAR(40);
   DEFINE cCod_docto       CHAR(4);
   DEFINE dFecha_alta      DATE;
   DEFINE cCod_grupo       CHAR(3);
   DEFINE cDescrip_gpo     CHAR(30);
   DEFINE cDescrip_docto   CHAR(35);
   DEFINE cDescrip2        CHAR(30);
   DEFINE cMulti_img       CHAR(1);
   DEFINE siSecuencia      SMALLINT;
   DEFINE siContador       SMALLINT;
   DEFINE iSql_err         INT;
   DEFINE iIsam_err        INT;
   DEFINE cIma_esnula      CHAR(1);


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

        LET cCodret            = "000";
        LET cCodret2           = "000";
        LET cCuenta            = " ";
        LET cProd_nombre       = " ";
        LET cCod_docto         = " ";
        LET dFecha_alta        = today;
        LET cCod_grupo         = " ";
        LET cDescrip_gpo       = " ";
        LET cDescrip_docto     = " ";
        LET cDescrip2          = " ";
        LET cMulti_img         = " ";
        LET siSecuencia        = 0;
        LET siContador         = 0;
        LET cIma_esnula        = "0";

-- set debug file to "/dbexportb/cons_expediente2.out";
-- trace on;

BEGIN
   ON EXCEPTION SET iSql_err,iIsam_err
      IF iSql_err <> 0 OR iIsam_err <> 0 THEN
         LET cCodret = iSql_err;
         RETURN cCodret,cCuenta,cProd_nombre,cCod_docto,dFecha_alta,
            cCod_grupo, cDescrip_gpo,cDescrip_docto,cDescrip2,
            cMulti_img,siSecuencia,cIma_esnula;
      END IF;
   END EXCEPTION;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pEmpresa IS NULL OR
        pCliente IS NULL OR
        pNum_regs IS NULL THEN

       -- datos de entrada incompletos

       LET cCodret = "110";
       RETURN cCodret,cCuenta,cProd_nombre,cCod_docto,dFecha_alta,
          cCod_grupo,cDescrip_gpo,cDescrip_docto,cDescrip2,
          cMulti_img,siSecuencia,cIma_esnula;
    END IF;


-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

    FOREACH


        SELECT  ex.cuenta,ex.producto || ' ' || ex.prod_nombre,
                ex.cod_docto,ex.fecha_alta,gd.cod_grupo,
                gd.descripcion,td.descripcion,td.multi_imagen,
                ex.secuencia,nvl(ex.descrip2," ")
        INTO    cCuenta,cProd_nombre,cCod_docto,dFecha_alta,
                cCod_grupo,cDescrip_gpo,cDescrip_docto,
                cMulti_img,siSecuencia,cDescrip2
        FROM    bdidigital@coppelimg_crx:"informix".dg_expediente ex,
                bdidigital@coppelimg_crx:"informix".dg_grupodocto gd,
                bdidigital@coppelimg_crx:"informix".dg_tipodocumento td
        WHERE   ex.cod_docto       = td.cod_docto
                AND td.cod_grupo   = gd.cod_grupo
                AND ex.empresa     = pEmpresa
                AND ex.cliente     = pCliente
                AND ex.descrip2    <> 'firma_borra_da'
                                AND ex.cod_docto NOT IN('0137')
        ORDER BY ex.fecha_alta,ex.cuenta,ex.cod_docto


        LET siContador = siContador + 1;

        IF siContador < pNum_regs THEN
                CONTINUE FOREACH;
        END IF;

       EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".cons_imgnula(pEmpresa,pCliente,cCod_docto,siSecuencia)
       INTO cCodret2,cIma_esnula;


        RETURN  cCodret,cCuenta,cProd_nombre,cCod_docto,
            dFecha_alta,cCod_grupo,cDescrip_gpo,
            cDescrip_docto,cDescrip2,cMulti_img,
            siSecuencia,cIma_esnula
            WITH resume;

    END FOREACH

END;
END PROCEDURE
DOCUMENT
'---------------------------------',
'DSB 07/07/2011',
'Autor: Roberto Aguilar',
'SP creado a partir de cons_expediente. Consulta el expediente de documentos del cliente.',
'---------------------------------';

CREATE PROCEDURE "informix".cons_expediente2(pEmpresa CHAR(3),
                pCliente    CHAR(20),
                pNum_regs   SMALLINT)
            RETURNING
            CHAR(5),CHAR(20),CHAR(40),CHAR(4),DATE,
            CHAR(3),CHAR(30),CHAR(35),CHAR(30),
            CHAR(1),SMALLINT,CHAR(1);


   DEFINE cCodret          CHAR(5);
   DEFINE cCodret2         CHAR(5);
   DEFINE cCuenta          CHAR(20);
   DEFINE cProd_nombre     CHAR(40);
   DEFINE cCod_docto       CHAR(4);
   DEFINE dFecha_alta      DATE;
   DEFINE cCod_grupo       CHAR(3);
   DEFINE cDescrip_gpo     CHAR(30);
   DEFINE cDescrip_docto   CHAR(35);
   DEFINE cDescrip2        CHAR(30);
   DEFINE cMulti_img       CHAR(1);
   DEFINE siSecuencia      SMALLINT;
   DEFINE siContador       SMALLINT;
   DEFINE iSql_err         INT;
   DEFINE iIsam_err        INT;
   DEFINE cIma_esnula      CHAR(1);


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

        LET cCodret            = "000";
        LET cCodret2           = "000";
        LET cCuenta            = " ";
        LET cProd_nombre       = " ";
        LET cCod_docto         = " ";
        LET dFecha_alta        = today;
        LET cCod_grupo         = " ";
        LET cDescrip_gpo       = " ";
        LET cDescrip_docto     = " ";
        LET cDescrip2          = " ";
        LET cMulti_img         = " ";
        LET siSecuencia        = 0;
        LET siContador         = 0;
        LET cIma_esnula        = "0";

-- set debug file to "/dbexportb/cons_expediente2.out";
-- trace on;

BEGIN
   ON EXCEPTION SET iSql_err,iIsam_err
      IF iSql_err <> 0 OR iIsam_err <> 0 THEN
         LET cCodret = iSql_err;
         RETURN cCodret,cCuenta,cProd_nombre,cCod_docto,dFecha_alta,
            cCod_grupo, cDescrip_gpo,cDescrip_docto,cDescrip2,
            cMulti_img,siSecuencia,cIma_esnula;
      END IF;
   END EXCEPTION;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pEmpresa IS NULL OR
        pCliente IS NULL OR
        pNum_regs IS NULL THEN

       -- datos de entrada incompletos

       LET cCodret = "110";
       RETURN cCodret,cCuenta,cProd_nombre,cCod_docto,dFecha_alta,
          cCod_grupo,cDescrip_gpo,cDescrip_docto,cDescrip2,
          cMulti_img,siSecuencia,cIma_esnula;
    END IF;


-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

    FOREACH


        SELECT  ex.cuenta,ex.producto || ' ' || ex.prod_nombre,
                ex.cod_docto,ex.fecha_alta,gd.cod_grupo,
                gd.descripcion,td.descripcion,td.multi_imagen,
                ex.secuencia,nvl(ex.descrip2," ")
        INTO    cCuenta,cProd_nombre,cCod_docto,dFecha_alta,
                cCod_grupo,cDescrip_gpo,cDescrip_docto,
                cMulti_img,siSecuencia,cDescrip2
        FROM    bdidigital@coppelimg_crx:"informix".dg_expediente ex,
                bdidigital@coppelimg_crx:"informix".dg_grupodocto gd,
                bdidigital@coppelimg_crx:"informix".dg_tipodocumento td
        WHERE   ex.cod_docto       = td.cod_docto
                AND td.cod_grupo   = gd.cod_grupo
                AND ex.empresa     = pEmpresa
                AND ex.cliente     = pCliente
                AND ex.descrip2    <> 'firma_borra_da'
                                AND ex.cod_docto NOT IN('0137')
        ORDER BY ex.fecha_alta,ex.cuenta,ex.cod_docto


        LET siContador = siContador + 1;

        IF siContador < pNum_regs THEN
                CONTINUE FOREACH;
        END IF;

       EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".cons_imgnula(pEmpresa,pCliente,cCod_docto,siSecuencia)
       INTO cCodret2,cIma_esnula;


        RETURN  cCodret,cCuenta,cProd_nombre,cCod_docto,
            dFecha_alta,cCod_grupo,cDescrip_gpo,
            cDescrip_docto,cDescrip2,cMulti_img,
            siSecuencia,cIma_esnula
            WITH resume;

    END FOREACH

END;
END PROCEDURE
DOCUMENT
'---------------------------------',
'DSB 07/07/2011',
'Autor: Roberto Aguilar',
'SP creado a partir de cons_expediente. Consulta el expediente de documentos del cliente.',
'---------------------------------';

create procedure "informix".inserta_reg_expediente(
                       pempresa     char(3),
                       pcliente     char(20),
                       pcuenta      char(20),
                       pproducto    char(4), 
                       pcod_docto   char(4),
                       psecuencia   smallint,
                       pprod_nombre char(40),
                       pdescrip2    char(30),
                       puser_insert char(8))
                       RETURNING    char(5);  

   DEFINE v_codret char(5);
   DEFINE v_fecha date;
   DEFINE v_existe char(1);
   DEFINE sql_err,isam_err int;   



-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_fecha     = today;
   LET v_existe    = "";


set isolation to dirty read;
set lock mode to wait 3;
BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;




-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pempresa        is null or
        pcliente        is null or
        pcuenta         is null or
        pproducto       is null or
        pcod_docto      is null or
        psecuencia      is null or
        pprod_nombre    is null or 
        puser_insert    is null THEN
    
       -- datos de entrada incompletos
       
       LET v_codret = 110; 
       RETURN v_codret; 
    END IF;

   
    
-- ****************************************************************************
-- insertar registro en dg_expediente
-- ****************************************************************************
    select 1 
    into v_existe 
    from bdidigital@coppelimg_crx:dg_expediente
    -----where empresa = pempresa
    where cliente = pcliente
    and cuenta = pcuenta
    and producto = pproducto
    and cod_docto = pcod_docto
    and secuencia = psecuencia
    and prod_nombre = pprod_nombre;
    --and descrip2 = pdescrip2;

    IF  v_existe = '1' THEN 
    RETURN v_codret; 
    END IF;

    insert into     bdidigital@coppelimg_crx:dg_expediente 
                    (empresa,cliente,cuenta,
                    producto,cod_docto,secuencia,prod_nombre,descrip2,
                    usuario_alta,fecha_alta) 
    values          (pempresa,pcliente,pcuenta,pproducto,pcod_docto,
                    psecuencia,pprod_nombre,pdescrip2,puser_insert,
                    v_fecha);

END;    

RETURN v_codret;

END PROCEDURE;