CREATE PROCEDURE "informix".arr_movhis(pfechahoy_paso date)

DEFINE vfolio CHAR(16);
DEFINE vref2  CHAR(50);
DEFINE vnum_credito  CHAR(20);
DEFINE vfecha_mov  date;
define v_cod_retorno char(05);

DEFINE  vNumCredito     CHAR(20);
DEFINE  vMonto          DECIMAL(18,2)  ;
DEFINE  vFolioSuc       CHAR(16);
DEFINE  vReferencia     VARCHAR(23,1);
DEFINE pempresa CHAR (3);

let v_cod_retorno = '';
LET pempresa = '001';

    let pfechahoy_paso = pfechahoy_paso - 1 units month;
    let pfechahoy_paso = pfechahoy_paso + 1 units day;

-- Agrega monedas
    execute procedure updtraspcred801(pfechahoy_paso) INTO v_cod_retorno;

end procedure;