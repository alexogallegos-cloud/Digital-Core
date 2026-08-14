package com.openpay.api.riskfraud;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : API (WAR)      DOMAIN : risk-fraud
//  LAYER     : REPO                 ACCESS : update (writes)
//  FAN-IN    : 6    FAN-OUT : 1    LOC approx: 67
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.RskRequest;
import com.openpay.dto.RskResponse;

@Repository
public class RskRepository038 {

    // Collaborators (match the graph call edges):
    private final JdbcWriteGateway jdbcWriteGateway;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
