package com.openpay.manager.riskfraud;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Manager (WAR)      DOMAIN : risk-fraud
//  LAYER     : JOB                  ACCESS : inquiry (read-only)
//  FAN-IN    : 0    FAN-OUT : 2    LOC approx: 227
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.MerchantDTO;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.RskEntity;
import com.openpay.dto.TransactionDTO;

@Scheduled
public class RskJob043 {

    // Collaborators (match the graph call edges):
    private final RskService043 rskService043;
    private final RskService231 rskService231;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
