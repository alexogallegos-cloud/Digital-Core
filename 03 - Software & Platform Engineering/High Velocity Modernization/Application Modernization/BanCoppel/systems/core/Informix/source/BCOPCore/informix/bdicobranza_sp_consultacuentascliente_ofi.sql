CREATE PROCEDURE "informix".sp_consultacuentascliente_ofi(
                                            pEmpresa char (3),
                                            pTipoBusqueda char(1),
                                            pNumero char (20),
                                            pIndice char (3),
                                            pFecha date
                                            )

RETURNING
            char(5), --cod retorno
            char(20), --numero de cliente
            char(26), --apellido paterno
            char(26), --apellido materno
            char(26), --nombre1
            char(26), --nombre2
            char(20), --numero de la referencia cliente
            char(13), --numero de telefono
            char(20), --numero de credito
            char(40), --descripcion del credito
            char(30), --Situacion especial
            char(30), --Causa
            char(30), --Saldo actual
            char(30), --Tipo convenio

            char(30), --Numero de dias vencidos
            char(30), --Numero de pagos vencidos
            char(30), --Pago minimo vencido
            char(30), --proximo pago por vencer
            char(30), --fecha ultimo abono
            char(30), --importe ultimo abono
            char(30), --fecha ultimo convenio
            char(30), --importe convenio
            char(3), --cumplio convenio
            char(3), --origen convenio
            decimal(14,2); -- monto mínimo a negociar; 


define v_codret char(5);
define v_numcte char(20);
define v_apaterno char (26);
define v_amaterno char (26);
define v_nombre1 char (26);
define v_nombre2 char (26);
define v_numcteref char(20);
define v_telefono char(13);
define v_numcredito char (20);
define v_descripcioncred char(40);
define v_situacionespecial char(30);
define v_causa char(30);
define v_saldoactual decimal (16,2);
define v_tipoconvenio char (30);

define v_numdiasvencidos char(30);
define v_numpagovencidos char(30);
define v_pagominvencido char(30);
define v_proxpagoporvencer char(30);
define v_fechaultabono char(30);
define v_importeultabono char(30);
define v_fechaultconvenio date;
define v_importeconvenio decimal(14);
define v_cumplioconvenio char(3);
define v_origenconvenio smallint;
DEFINE dMtoNegociar DECIMAL(14,2);

define v_sqlerr integer;
define v_isamerr integer;


let v_codret = "";
let v_numcte = "";
let v_apaterno = "";
let v_amaterno = "";
let v_nombre1 = "";
let v_nombre2 = "";
let v_numcteref = "";
let v_telefono = "";
let v_numcredito = "";
let v_descripcioncred = "";
let v_situacionespecial = "";
let v_causa = "";
let v_saldoactual = "";
let v_tipoconvenio = "";

let v_numdiasvencidos = "";
let v_numpagovencidos = "";
let v_pagominvencido = "";
let v_proxpagoporvencer = "";
let v_fechaultabono = "";
let v_importeultabono = "";
let v_fechaultconvenio = "";
let v_importeconvenio = "";
let v_cumplioconvenio = "";
let v_origenconvenio = "";
LET dMtoNegociar  = 0;

let v_sqlerr = 0;
let v_isamerr = 0;


--SET DEBUG FILE TO "/home/sysifx/viridiana/sp_consultacuentascliente_ofi.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET v_sqlerr, v_isamerr
        IF v_sqlerr != 0 THEN
            let v_codret=v_sqlerr;
            --ROLLBACK WORK;
            RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                    v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                    v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar;
        END IF;
    END EXCEPTION;

	FOREACH EXECUTE PROCEDURE sp_consultacuentascliente(
                                                pEmpresa,
                                                pTipoBusqueda,  
                                                pNumero,
                                                pIndice,
                                                pFecha
                                                )
     INTO  v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
          v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
          v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar 


            RETURN v_codret, v_numcte, v_apaterno, v_amaterno, v_nombre1, v_nombre2, v_numcteref, v_telefono, v_numcredito, v_descripcioncred,
                    v_situacionespecial, v_causa, v_saldoactual, v_tipoconvenio,v_numdiasvencidos, v_numpagovencidos, v_pagominvencido, v_proxpagoporvencer,
                    v_fechaultabono, v_importeultabono,v_fechaultconvenio, v_importeconvenio, v_cumplioconvenio, v_origenconvenio,dMtoNegociar WITH RESUME;

	END FOREACH;		  
END;
END PROCEDURE;