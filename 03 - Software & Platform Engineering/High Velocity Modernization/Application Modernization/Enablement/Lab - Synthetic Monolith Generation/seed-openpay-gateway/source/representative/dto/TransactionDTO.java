package com.openpay.dto;

import java.math.BigDecimal;
import java.util.Date;
import java.util.Map;

/**
 * [PLANTADO · DTO-COUPLING] El "god DTO" del monolito.
 *
 * Acoplamiento por dato — el hairball OCULTO (ground-truth-dto-coupling.md):
 * usado por ~5 dominios (payments, finance, risk-fraud, merchants, terminals).
 * Dos clases que NUNCA se llaman entre si quedan acopladas porque ambas mutan
 * este objeto. Cambiar un campo aqui impacta a decenas de clases a la vez,
 * SIN una sola arista en el call graph que lo delate.
 *
 * Anti-patrones plantados:
 *  - Objeto mutable compartido (setters publicos) pasado entre capas.
 *  - Mezcla responsabilidades de varios bounded contexts en una sola clase.
 *  - `Map<String,Object> extras` = basurero sin contrato → imposible de versionar.
 *  - Acopla el modelo de dominio legacy: impide database-per-service hasta partirlo.
 */
public class TransactionDTO {

    // --- payments ---
    private String transactionId;
    private String merchantId;
    private MoneyAmount amount;          // value object compartido (otro acoplamiento)
    private String cardToken;            // PCI: viene de TokenizationService
    private String binCode;
    private String status;               // AUTH | CAPTURED | DECLINED | REVERSED
    private Date authorizedAt;

    // --- finance (fuga: no deberia vivir aqui) ---
    private MoneyAmount mdrFee;
    private AccountingEntry posting;     // acopla finance a payments via este DTO

    // --- risk-fraud (fuga) ---
    private Integer riskScore;
    private boolean threeDsEnrolled;

    // --- merchants / terminals (fuga) ---
    private String terminalId;
    private MerchantDTO merchantSnapshot;

    // [PLANTADO] basurero sin contrato — lo peor del acoplamiento
    private Map<String, Object> extras;

    // ... getters/setters de TODOS los campos (mutabilidad total) ...
    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String v) { this.transactionId = v; }
    public MoneyAmount getAmount() { return amount; }
    public void setAmount(MoneyAmount v) { this.amount = v; }
    public String getCardToken() { return cardToken; }
    public void setCardToken(String v) { this.cardToken = v; }
    public AccountingEntry getPosting() { return posting; }
    public void setPosting(AccountingEntry v) { this.posting = v; }
    public Map<String, Object> getExtras() { return extras; }
    public void setExtras(Map<String, Object> v) { this.extras = v; }
    // (resto omitido)
}