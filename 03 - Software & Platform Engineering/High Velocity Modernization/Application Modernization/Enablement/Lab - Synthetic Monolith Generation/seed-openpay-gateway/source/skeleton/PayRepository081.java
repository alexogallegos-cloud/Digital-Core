package com.openpay.api.payments;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : payments
//  LAYER     : REPO                 ACCESS : inquiry (read-only)
//  FAN-IN    : 3    FAN-OUT : 1    LOC approx: 174
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AccountingEntry;
import com.openpay.dto.AuditContext;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.PayEntity;
import com.openpay.dto.PayRequest;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@Repository
public class PayRepository081 {

    // Collaborators (match the graph call edges):
    private final JdbcReadGateway jdbcReadGateway;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
