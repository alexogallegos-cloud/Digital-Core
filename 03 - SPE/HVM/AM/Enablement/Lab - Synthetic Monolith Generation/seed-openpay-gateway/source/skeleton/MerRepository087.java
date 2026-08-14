package com.openpay.dashboard.merchants;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : merchants
//  LAYER     : REPO                 ACCESS : inquiry (read-only)
//  FAN-IN    : 5    FAN-OUT : 1    LOC approx: 102
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.MerResponse;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@Repository
public class MerRepository087 {

    // Collaborators (match the graph call edges):
    private final JdbcReadGateway jdbcReadGateway;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
