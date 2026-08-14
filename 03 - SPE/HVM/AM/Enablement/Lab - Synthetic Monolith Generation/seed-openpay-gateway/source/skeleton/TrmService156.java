package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 1    FAN-OUT : 5    LOC approx: 668
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;
import com.openpay.dto.TrmEntity;
import com.openpay.dto.TrmRequest;
import com.openpay.dto.TrmResponse;

@Service
public class TrmService156 {

    // Collaborators (match the graph call edges):
    private final JdbcReadGateway jdbcReadGateway;
    private final JsonUtils jsonUtils;
    private final RskService231 rskService231;
    private final StringUtils stringUtils;
    private final TrmRepository008 trmRepository008;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
