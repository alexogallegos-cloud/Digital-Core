CREATE PROCEDURE "informix".sp_obt_parametro_admtoken(pIdParametro smallint, pOrigen char(1))
   returning char(5), char(50), char(100);

--------------------------------------------------------------------------------------------
-- Realizó: Pedro Enrique Zavala Valdez
-- Actividad: Obtiene el valor y descripcion del parametro del Admtoken
-- Solicitó: Mauricio León
-- Fecha de Solicitud: 02/12/2009
-- Modificó: Pedro Enrique Zavala Valdez
-- Fecha de Modificación: 26/01/2010
-- Modificación: Se valida si se consulta a la tabla de parametros de token o a central
---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
	DEFINE cod_ret               char(5);
	DEFINE sql_err                integer;
	DEFINE vValor                  char(50);
	DEFINE vDescripcion     char(100);
	
-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret               = '000';
   LET vValor                  = '';
   LET vDescripcion     = '';

BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vValor,vDescripcion;
      END IF ;
   END EXCEPTION ;
		
    IF(pOrigen IS NULL OR pOrigen = '') THEN
    
        LET cod_ret  = '002';
    
    ELIF(pOrigen = '1') THEN
    --Consulta a la tabla de parametros del admtoken

        SELECT valor, descripcion INTO vValor, vDescripcion FROM bdibpi:tkn_parametros WHERE id_param = pIdParametro;

        IF(vValor IS NULL OR vDescripcion = '') THEN
            LET vValor = '';
            LET vDescripcion = '';
            LET cod_ret = '001';

        END IF;

    ELIF(pOrigen = '2') THEN
    --Consulta a la tabla de parametros del central
        SELECT valor, descripcion INTO vValor, vDescripcion FROM bdinteg:si_param WHERE cod_param = pIdParametro;

        IF(vValor IS NULL OR vDescripcion = '') THEN
        
            LET vValor = '';
            LET vDescripcion = '';
            LET cod_ret = '001';

        END IF;

    END IF;

    RETURN cod_ret, vValor,vDescripcion;

END

END PROCEDURE ;