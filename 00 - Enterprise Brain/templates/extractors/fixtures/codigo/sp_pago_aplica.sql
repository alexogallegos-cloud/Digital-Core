-- Ficticio. Existe para que la suite tenga un arbol con resultado conocido.
CREATE PROCEDURE sp_pago_aplica(p_cuenta INT, p_monto DECIMAL)
    DEFINE v_saldo DECIMAL;
    LET v_saldo = 0;
    CALL sp_saldo_consulta(p_cuenta) RETURNING v_saldo;
    IF v_saldo >= p_monto THEN
        CALL sp_movimiento_registra(p_cuenta, p_monto);
    END IF;
    -- CALL sp_obsoleto_no_llamar(p_cuenta);
    CALL sp_de_otro_sistema(p_cuenta);
END PROCEDURE;
