package com.openpay.api.riskfraud;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : risk-fraud
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 12    FAN-OUT : 7    LOC approx: 749
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.ResponseEnvelope;

@Service
public class RskService131 {

    // Collaborators (match the graph call edges):
    private final FinService292 finService292;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final RskRepository011 rskRepository011;
    private final RskRepository071 rskRepository071;
    private final RskService032 rskService032;
    private final StringUtils stringUtils;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
