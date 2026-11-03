CREATE PROCEDURE sp_saldo_consulta(p_cuenta INT)
    DEFINE v_saldo DECIMAL;
    SELECT saldo INTO v_saldo FROM cuentas WHERE id = p_cuenta;
    RETURN v_saldo;
END PROCEDURE;
