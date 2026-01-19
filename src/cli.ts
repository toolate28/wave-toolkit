#!/usr/bin/env node

import { HandshakeProtocol } from './handshake/protocol';
import { HandoffState } from './handshake/types';
import * as fs from 'fs';

/**
 * CLI for H&&S Protocol
 */

const args = process.argv.slice(2);

if (args.length === 0) {
  printHelp();
  process.exit(0);
}

const command = args[0];

async function main() {
  const protocol = new HandshakeProtocol();

  try {
    switch (command) {
      case 'handoff':
        await handleHandoff(args.slice(1), protocol);
        break;
      case 'help':
      case '--help':
      case '-h':
        printHelp();
        break;
      default:
        console.error(`Unknown command: ${command}`);
        printHelp();
        process.exit(1);
    }
  } catch (error: any) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

async function handleHandoff(args: string[], protocol: HandshakeProtocol) {
  const subcommand = args[0];

  switch (subcommand) {
    case 'create':
      await handleCreate(args.slice(1), protocol);
      break;
    case 'validate':
      await handleValidate(args.slice(1), protocol);
      break;
    case 'chain':
      await handleChain(args.slice(1), protocol);
      break;
    case 'viz':
      await handleVisualize(args.slice(1), protocol);
      break;
    default:
      console.error(`Unknown handoff subcommand: ${subcommand}`);
      printHandoffHelp();
      process.exit(1);
  }
}

async function handleCreate(args: string[], protocol: HandshakeProtocol) {
  let fromAgent = '';
  let toAgent = '';
  let state: HandoffState = 'PASS';
  let context: Record<string, any> = {};
  let sessionId = 'default';
  let coherenceScore: number | undefined;

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--from':
        fromAgent = args[++i];
        break;
      case '--to':
        toAgent = args[++i];
        break;
      case '--state':
        state = args[++i] as HandoffState;
        break;
      case '--context':
        context = JSON.parse(args[++i]);
        break;
      case '--session':
        sessionId = args[++i];
        break;
      case '--score':
        coherenceScore = parseFloat(args[++i]);
        break;
    }
  }

  if (!fromAgent || !toAgent) {
    console.error('Error: --from and --to are required');
    process.exit(1);
  }

  const marker = await protocol.createHandoff(
    fromAgent,
    toAgent,
    state,
    context,
    sessionId,
    coherenceScore
  );

  console.log('Handoff created successfully:');
  console.log(JSON.stringify(marker, null, 2));
}

async function handleValidate(args: string[], protocol: HandshakeProtocol) {
  const markerId = args[0];

  if (!markerId) {
    console.error('Error: marker ID is required');
    process.exit(1);
  }

  const storage = (protocol as any).storage;
  const marker = await storage.findMarkerById(markerId);

  if (!marker) {
    console.error(`Marker not found: ${markerId}`);
    process.exit(1);
  }

  const result = await protocol.validateHandoff(marker);

  console.log('Validation result:');
  console.log(`Valid: ${result.valid}`);
  
  if (result.errors && result.errors.length > 0) {
    console.log('\nErrors:');
    result.errors.forEach(error => console.log(`  - ${error}`));
  }

  if (result.warnings && result.warnings.length > 0) {
    console.log('\nWarnings:');
    result.warnings.forEach(warning => console.log(`  - ${warning}`));
  }

  process.exit(result.valid ? 0 : 1);
}

async function handleChain(args: string[], protocol: HandshakeProtocol) {
  const sessionId = args[0] || 'default';

  const chain = await protocol.getHandoffChain(sessionId);

  if (chain.length === 0) {
    console.log(`No handoffs found for session: ${sessionId}`);
    return;
  }

  console.log(`Handoff chain for session: ${sessionId}`);
  console.log(`Total handoffs: ${chain.length}\n`);

  chain.forEach((marker, index) => {
    console.log(`${index + 1}. [${marker.timestamp}]`);
    console.log(`   ${marker.fromAgent} --${marker.state}--> ${marker.toAgent}`);
    if (marker.coherenceScore !== undefined) {
      console.log(`   Coherence: ${marker.coherenceScore}%`);
    }
    console.log(`   Context: ${JSON.stringify(marker.context)}`);
    console.log('');
  });
}

async function handleVisualize(args: string[], protocol: HandshakeProtocol) {
  let sessionId = 'default';
  let outputFile: string | null = null;

  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--output') {
      outputFile = args[++i];
    } else {
      sessionId = args[i];
    }
  }

  const diagram = await protocol.visualizeWorkflow(sessionId);

  if (outputFile) {
    await fs.promises.writeFile(outputFile, diagram, 'utf-8');
    console.log(`Workflow diagram written to: ${outputFile}`);
  } else {
    console.log('Workflow diagram (Mermaid format):');
    console.log(diagram);
  }
}

function printHelp() {
  console.log(`
Wave Toolkit - H&&S Protocol CLI

Usage: wave-toolkit <command> [options]

Commands:
  handoff create    Create a new handoff marker
  handoff validate  Validate a handoff marker
  handoff chain     Display handoff chain for a session
  handoff viz       Visualize workflow as Mermaid diagram

Examples:
  wave-toolkit handoff create --from claude --to grok --state PASS --context '{"phase":"exploration"}'
  wave-toolkit handoff validate <marker-id>
  wave-toolkit handoff chain <session-id>
  wave-toolkit handoff viz <session-id> --output workflow.mmd

Options:
  --help, -h        Show this help message
  `);
}

function printHandoffHelp() {
  console.log(`
Handoff subcommands:

  create    Create a new handoff marker
    --from <agent>      Source agent (required)
    --to <agent>        Target agent (required)
    --state <state>     Handoff state (WAVE|PASS|BLOCK|HOLD|PUSH, default: PASS)
    --context <json>    Context object (default: {})
    --session <id>      Session ID (default: 'default')
    --score <number>    Coherence score (0-100, optional)

  validate <marker-id>  Validate a handoff marker

  chain [session-id]    Display handoff chain (default session: 'default')

  viz [session-id]      Generate Mermaid diagram
    --output <file>     Output file (optional, prints to stdout if not specified)
  `);
}

main().catch(error => {
  console.error('Unexpected error:', error);
  process.exit(1);
});
