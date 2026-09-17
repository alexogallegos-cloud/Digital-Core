CREATE PROCEDURE "informix".sp_rep_faltsob_pana2(vfecha_ini DATE, vfecha_fin DATE, vtransaccion CHAR(4),pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING  CHAR(4),CHAR(16), MONEY, MONEY, MONEY,DATE, CHAR(4), char(50);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  vcodret CHAR(4);
DEFINE  mensaje char(50);
DEFINE  vsucursal CHAR(4);
DEFINE  vnum_papeleta CHAR(16);
DEFINE  vmonto MONEY;
DEFINE  vmnto_suc MONEY;
DEFINE  vmto_diferencia MONEY;
DEFINE  vfecha_dif DATE;
DEFINE  vfecha DATE;
DEFINE  vfecha1 DATE;



-- ***************************
-- * CONTROL DE ERRORES          *
-- ***************************
BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET mensaje  = ERROR_INFO;
      RETURN   vsucursal, vnum_papeleta, vmonto,  vmnto_suc, vmto_diferencia, vfecha_dif, vcodret, mensaje;
   END EXCEPTION;

-- SET DEBUG FILE TO '/tmp/mfinis/sp_rep_faltsob_pana2.out';
-- TRACE ON;
   
LET vcodret = "0000"; 
LET vsucursal ='';
LET vnum_papeleta ='';
LET vmonto = 0;
LET vmnto_suc = 0;
LET vmto_diferencia = 0;
LET vfecha_dif = '01/01/1900';
LET     vfecha = vfecha_ini;
LET vfecha1 = vfecha_fin;
let mensaje='';



set isolation to dirty read;

        foreach
                SELECT {+INDEX("informix".ss_diferenciadot_suc idx01_ss_diferenciasuc)}  
                SKIP pRegistros FIRST pRecuperacion sucursal, num_folio, mnto_solicitado,  mnto_suc, monto_diferencia,fecha_dif
                INTO  vsucursal, vnum_papeleta, vmonto,  vmnto_suc, vmto_diferencia, vfecha_dif
                FROM "informix".ss_diferenciadot_suc 
                WHERE fecha_dif between vfecha and vfecha1  
                AND  transs = vtransaccion
        
                RETURN  vsucursal, vnum_papeleta, vmonto,  vmnto_suc, vmto_diferencia, vfecha_dif, vcodret, mensaje WITH RESUME;

        end foreach;
        
end;                                            
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 28/06/2016',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: FALTANTES/SOBRANTES PANAM',
'DESCRIPCION:Se agregaron los parÃ¡metros de paginaciÃ³n',
'BD:bdisuc';

CREATE PROCEDURE "informix".sp_valida_suc2(vsucursal char(4))

RETURNING char(4), char(50),char(30) ;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  vcodret 		 CHAR(4);
DEFINE vmensaje 		 CHAR(50);
DEFINE vsucursal2  		 CHAR(4);
DEFINE cNombreSucursal   CHAR(30);
DEFINE iNoRegistros      INTEGER;

LET vcodret 		= '0000';
LET vsucursal2		= vsucursal;
LET vmensaje 		='';
LET cNombreSucursal	='';
LET iNoRegistros 	= 0;
 
BEGIN

   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET vmensaje  = ERROR_INFO;
      RETURN vcodret, vmensaje,cNombreSucursal;
   END EXCEPTION;
   
 -- set debug file to "valida.out";
 --TRACE ON;

SET ISOLATION TO dirty READ;

SELECT nom_suc 
INTO   cNombreSucursal
FROM bdisuc:"informix".ss_acceso_sucursales
WHERE sucursal = vsucursal2;

LET iNoRegistros = DBINFO('sqlca.sqlerrd2');

IF iNoRegistros = 0 THEN
	LET vcodret='0001';  --No existe   
	LET vmensaje = 'Sucursal no existe favor de validar';  
END IF;

RETURN vcodret, vmensaje,cNombreSucursal;
        
END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 23/06/2016',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: HORARIO DOTACION SUCURSAL',
'DESCRIPCION: Se agrega parametro de salida nombre de sucursal',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_accesodot(vsucursal char(4))

RETURNING char(4), char(50) ;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  vcodret CHAR(4);
DEFINE mensaje CHAR(50);
DEFINE vsucursal2  CHAR(4);

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET mensaje  = ERROR_INFO;
      RETURN vcodret, mensaje;
   END EXCEPTION;
 
LET vcodret = "0000";
LET vsucursal2= vsucursal;

set isolation to dirty read;

update "informix".ss_acceso_sucursales
set acceso = 'V' 
where sucursal = vsucursal2;

LET mensaje='PROCESO EXITOSO';

RETURN vcodret, mensaje;
end;						
END PROCEDURE;