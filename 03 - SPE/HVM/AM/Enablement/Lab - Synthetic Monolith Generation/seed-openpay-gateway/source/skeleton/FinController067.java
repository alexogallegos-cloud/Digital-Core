package com.openpay.manager.finance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : finance
//  LAYER     : WEB                  ACCESS : inquiry (read-only)
//  FAN-IN    : 0    FAN-OUT : 2    LOC approx: 95
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AccountingEntry;
import com.openpay.dto.AuditContext;
import com.openpay.dto.FinRequest;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;

@RestController
public class FinController067 {

    // Collaborators (match the graph call edges):
    private final ChnService162 chnService162;
    private final SecService281 secService281;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
