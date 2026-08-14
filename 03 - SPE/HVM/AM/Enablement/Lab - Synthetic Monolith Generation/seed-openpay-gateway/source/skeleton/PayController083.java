package com.openpay.api.payments;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : payments
//  LAYER     : WEB                  ACCESS : inquiry (read-only)
//  FAN-IN    : 0    FAN-OUT : 3    LOC approx: 257
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AccountingEntry;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.PayResponse;
import com.openpay.dto.ResponseEnvelope;

@RestController
public class PayController083 {

    // Collaborators (match the graph call edges):
    private final PayService084 payService084;
    private final PayService118 payService118;
    private final PayService134 payService134;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
