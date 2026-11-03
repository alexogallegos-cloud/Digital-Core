CREATE PROCEDURE sp_movimiento_registra(p_cuenta INT, p_monto DECIMAL)
    INSERT INTO movimientos VALUES (p_cuenta, p_monto);
    CALL sp_saldo_consulta(p_cuenta);
END PROCEDURE;
