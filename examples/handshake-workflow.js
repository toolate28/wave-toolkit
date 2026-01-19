#!/usr/bin/env node

/**
 * Example: Full H&&S Protocol Workflow
 * 
 * Demonstrates a complete multi-agent workflow:
 * User -> Grok -> Claude -> Repos
 */

const { HandshakeProtocol } = require('../dist/index');
const fs = require('fs');
const path = require('path');

async function main() {
  console.log('🌊 Wave Toolkit - H&&S Protocol Example\n');

  // Initialize protocol with custom directories
  const protocol = new HandshakeProtocol(
    '.wave-example/handoffs',
    '.wave-example/atom-trail'
  );

  const sessionId = `example-${Date.now()}`;
  console.log(`Session ID: ${sessionId}\n`);

  // Step 1: User initiates task with Grok
  console.log('Step 1: User → Grok (PASS)');
  const step1 = await protocol.createHandoff(
    'user',
    'grok',
    'PASS',
    { 
      task: 'Explore architectural patterns for microservices',
      requirements: ['scalability', 'resilience', 'observability']
    },
    sessionId
  );
  console.log(`  ✓ Created handoff: ${step1.id}`);
  console.log(`  ✓ Context: ${JSON.stringify(step1.context)}\n`);

  // Step 2: Grok completes exploration, passes to Claude with high coherence
  console.log('Step 2: Grok → Claude (WAVE with 88% coherence)');
  const step2 = await protocol.createHandoff(
    'grok',
    'claude',
    'WAVE',
    { 
      insights: [
        'Event-driven architecture for loose coupling',
        'API Gateway pattern for unified interface',
        'Circuit breaker for fault tolerance'
      ],
      recommendedApproach: 'Hybrid synchronous/asynchronous communication'
    },
    sessionId,
    88  // High coherence score
  );
  console.log(`  ✓ Created handoff: ${step2.id}`);
  console.log(`  ✓ Coherence Score: ${step2.coherenceScore}%`);
  console.log(`  ✓ Insights: ${step2.context.insights.length} patterns identified\n`);

  // Step 3: Claude implements and commits
  console.log('Step 3: Claude → Repos (PASS)');
  const step3 = await protocol.createHandoff(
    'claude',
    'repos',
    'PASS',
    { 
      status: 'committed',
      files: [
        'src/gateway/api-gateway.ts',
        'src/services/event-bus.ts',
        'src/middleware/circuit-breaker.ts',
        'tests/integration.test.ts'
      ],
      branch: 'feature/microservices-architecture'
    },
    sessionId
  );
  console.log(`  ✓ Created handoff: ${step3.id}`);
  console.log(`  ✓ Files committed: ${step3.context.files.length}`);
  console.log(`  ✓ Branch: ${step3.context.branch}\n`);

  // Display the complete chain
  console.log('📊 Complete Handoff Chain:');
  console.log('─'.repeat(60));
  const chain = await protocol.getHandoffChain(sessionId);
  chain.forEach((marker, index) => {
    console.log(`${index + 1}. [${new Date(marker.timestamp).toLocaleTimeString()}]`);
    console.log(`   ${marker.fromAgent} --${marker.state}${marker.coherenceScore ? `(${marker.coherenceScore}%)` : ''}-> ${marker.toAgent}`);
  });
  console.log('─'.repeat(60) + '\n');

  // Generate Mermaid visualization
  console.log('📈 Workflow Visualization (Mermaid):');
  console.log('─'.repeat(60));
  const diagram = await protocol.visualizeWorkflow(sessionId);
  console.log(diagram);
  console.log('─'.repeat(60) + '\n');

  // Validate all handoffs
  console.log('✅ Validation Results:');
  for (let i = 0; i < chain.length; i++) {
    const result = await protocol.validateHandoff(chain[i]);
    console.log(`  Step ${i + 1}: ${result.valid ? '✓ Valid' : '✗ Invalid'}`);
    if (result.warnings && result.warnings.length > 0) {
      result.warnings.forEach(warning => {
        console.log(`    ⚠️  ${warning}`);
      });
    }
  }
  console.log('');

  // Show ATOM trail
  console.log('📜 ATOM Trail Entries:');
  console.log('─'.repeat(60));
  const atomFile = path.join('.wave-example/atom-trail', `${sessionId}.atom.jsonl`);
  if (fs.existsSync(atomFile)) {
    const content = fs.readFileSync(atomFile, 'utf-8');
    const entries = content.trim().split('\n').map(line => JSON.parse(line));
    entries.forEach((entry, index) => {
      console.log(`${index + 1}. ${entry.actor} → ${entry.decision}`);
      console.log(`   ${entry.rationale}`);
    });
  }
  console.log('─'.repeat(60) + '\n');

  console.log('✨ Example complete!');
  console.log(`\n💾 Data stored in: .wave-example/`);
  console.log(`   Handoffs: .wave-example/handoffs/${sessionId}.jsonl`);
  console.log(`   ATOM Trail: .wave-example/atom-trail/${sessionId}.atom.jsonl`);
}

// Run the example
main().catch(error => {
  console.error('Error:', error);
  process.exit(1);
});
