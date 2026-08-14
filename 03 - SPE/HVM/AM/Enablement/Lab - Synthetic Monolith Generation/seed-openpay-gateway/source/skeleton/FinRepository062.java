package com.openpay.manager.finance;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : finance
//  LAYER     : REPO                 ACCESS : update (writes)
//  FAN-IN    : 8    FAN-OUT : 2    LOC approx: 149
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.FinResponse;
import com.openpay.dto.MoneyAmount;
import com.openpay.dto.ResponseEnvelope;

@Repository
public class FinRepository062 {

    // Collaborators (match the graph call edges):
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
