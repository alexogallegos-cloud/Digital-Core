package com.openpay.shared;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * [PLANTADO · HUB] Utileria estatica de fan-in altisimo (ground-truth-hubs.md).
 *
 * Llamada por cientos de clases de TODOS los dominios. Tocar este metodo = maximo
 * blast radius. En el grafo aparece con borde blanco (utility hub). Es el tipo de
 * nodo que un Strangler Fig debe envolver primero o congelar, nunca tocar a la ligera.
 *
 * Anti-patrones plantados:
 *  - Estado/constantes hardcoded de negocio en una utileria tecnica (reglas congeladas).
 *  - Singleton estatico → imposible de inyectar/mockear → frena el testing de extraccion.
 */
public final class MoneyUtils {

    private MoneyUtils() {}

    // [PLANTADO · HARDCODED] regla de negocio congelada en una util tecnica.
    // Deberia venir de ConfigService (parametria) — RN-003 del answer key.
    private static final BigDecimal IVA_MX            = new BigDecimal("0.16");
    private static final BigDecimal MDR_DEFAULT       = new BigDecimal("0.029"); // 2.9%
    private static final BigDecimal HIGH_RISK_CEILING = new BigDecimal("500000"); // MXN

    public static BigDecimal applyMdr(BigDecimal amount) {
        // [PLANTADO] tasa fija; en realidad depende de MCC + esquema + acquirer
        return amount.multiply(MDR_DEFAULT).setScale(2, RoundingMode.HALF_UP);
    }

    public static BigDecimal withIva(BigDecimal amount) {
        return amount.multiply(BigDecimal.ONE.add(IVA_MX)).setScale(2, RoundingMode.HALF_UP);
    }

    public static boolean isHighRisk(BigDecimal amount) {
        // [PLANTADO · HARDCODED] umbral 500,000 MXN clavado — regla regulatoria implicita
        return amount.compareTo(HIGH_RISK_CEILING) > 0;
    }

    public static String format(MoneyAmount m) {
        return m.getCurrency() + " " + m.getValue().setScale(2, RoundingMode.HALF_UP);
    }
}