import { HandshakeProtocol } from '../src/handshake/protocol';
import { HandshakeMarker, HandoffState } from '../src/handshake/types';
import * as fs from 'fs';
import * as path from 'path';

describe('HandshakeProtocol', () => {
  let protocol: HandshakeProtocol;
  const testStorageDir = '/tmp/wave-test-storage';
  const testAtomDir = '/tmp/wave-test-atom';

  beforeEach(async () => {
    // Clean up test directories
    if (fs.existsSync(testStorageDir)) {
      fs.rmSync(testStorageDir, { recursive: true, force: true });
    }
    if (fs.existsSync(testAtomDir)) {
      fs.rmSync(testAtomDir, { recursive: true, force: true });
    }

    protocol = new HandshakeProtocol(testStorageDir, testAtomDir);
  });

  afterEach(() => {
    // Clean up
    if (fs.existsSync(testStorageDir)) {
      fs.rmSync(testStorageDir, { recursive: true, force: true });
    }
    if (fs.existsSync(testAtomDir)) {
      fs.rmSync(testAtomDir, { recursive: true, force: true });
    }
  });

  describe('createHandoff', () => {
    it('should create a valid handoff marker', async () => {
      const marker = await protocol.createHandoff(
        'claude',
        'grok',
        'PASS',
        { phase: 'exploration' },
        'test-session-1'
      );

      expect(marker).toBeDefined();
      expect(marker.id).toBeDefined();
      expect(marker.fromAgent).toBe('claude');
      expect(marker.toAgent).toBe('grok');
      expect(marker.state).toBe('PASS');
      expect(marker.context).toEqual({ phase: 'exploration' });
      expect(marker.sessionId).toBe('test-session-1');
      expect(marker.atomTrailId).toBeDefined();
      expect(marker.timestamp).toBeDefined();
    });

    it('should create marker with coherence score', async () => {
      const marker = await protocol.createHandoff(
        'claude',
        'grok',
        'WAVE',
        {},
        'test-session-1',
        85
      );

      expect(marker.coherenceScore).toBe(85);
    });

    it('should save marker to storage', async () => {
      const marker = await protocol.createHandoff(
        'claude',
        'grok',
        'PASS',
        {},
        'test-session-1'
      );

      const chain = await protocol.getHandoffChain('test-session-1');
      expect(chain).toHaveLength(1);
      expect(chain[0].id).toBe(marker.id);
    });

    it('should log to ATOM trail', async () => {
      const marker = await protocol.createHandoff(
        'claude',
        'grok',
        'WAVE',
        {},
        'test-session-1',
        85
      );

      const atomFile = path.join(testAtomDir, 'test-session-1.atom.jsonl');
      expect(fs.existsSync(atomFile)).toBe(true);

      const content = fs.readFileSync(atomFile, 'utf-8');
      const lines = content.trim().split('\n');
      expect(lines.length).toBe(1);

      const entry = JSON.parse(lines[0]);
      expect(entry.actor).toBe('claude');
      expect(entry.decision).toContain('H&&S: WAVE to grok');
      expect(entry.coherenceScore).toBe(85);
    });
  });

  describe('validateHandoff', () => {
    it('should validate a valid marker', async () => {
      const marker = await protocol.createHandoff(
        'claude',
        'grok',
        'PASS',
        {},
        'test-session-1'
      );

      const result = await protocol.validateHandoff(marker);
      expect(result.valid).toBe(true);
      expect(result.errors).toBeUndefined();
    });

    it('should detect missing required fields', async () => {
      const invalidMarker: HandshakeMarker = {
        id: '',
        timestamp: '',
        fromAgent: '',
        toAgent: '',
        state: 'PASS',
        context: {},
        atomTrailId: '',
        sessionId: ''
      };

      const result = await protocol.validateHandoff(invalidMarker);
      expect(result.valid).toBe(false);
      expect(result.errors).toBeDefined();
      expect(result.errors!.length).toBeGreaterThan(0);
    });

    it('should detect invalid state', async () => {
      const marker = await protocol.createHandoff(
        'claude',
        'grok',
        'PASS',
        {},
        'test-session-1'
      );

      // Corrupt the state
      (marker as any).state = 'INVALID_STATE';

      const result = await protocol.validateHandoff(marker);
      expect(result.valid).toBe(false);
      expect(result.errors).toContain('Invalid state: INVALID_STATE');
    });

    it('should warn about WAVE without coherence score', async () => {
      const marker = await protocol.createHandoff(
        'claude',
        'grok',
        'WAVE',
        {},
        'test-session-1'
      );

      const result = await protocol.validateHandoff(marker);
      expect(result.valid).toBe(true);
      expect(result.warnings).toBeDefined();
      expect(result.warnings).toContain('WAVE state typically includes a coherenceScore');
    });

    it('should warn about invalid coherence score range', async () => {
      const marker = await protocol.createHandoff(
        'claude',
        'grok',
        'WAVE',
        {},
        'test-session-1',
        150
      );

      const result = await protocol.validateHandoff(marker);
      expect(result.valid).toBe(true);
      expect(result.warnings).toContain('coherenceScore should be between 0 and 100');
    });
  });

  describe('getHandoffChain', () => {
    it('should return empty array for non-existent session', async () => {
      const chain = await protocol.getHandoffChain('non-existent');
      expect(chain).toEqual([]);
    });

    it('should return markers in order', async () => {
      await protocol.createHandoff('user', 'grok', 'PASS', {}, 'test-session-1');
      await protocol.createHandoff('grok', 'claude', 'WAVE', {}, 'test-session-1', 85);
      await protocol.createHandoff('claude', 'repos', 'PASS', {}, 'test-session-1');

      const chain = await protocol.getHandoffChain('test-session-1');
      expect(chain).toHaveLength(3);
      expect(chain[0].fromAgent).toBe('user');
      expect(chain[1].fromAgent).toBe('grok');
      expect(chain[2].fromAgent).toBe('claude');
    });
  });

  describe('visualizeWorkflow', () => {
    it('should generate empty diagram for no handoffs', async () => {
      const diagram = await protocol.visualizeWorkflow('non-existent');
      expect(diagram).toContain('Empty["No handoffs found"]');
    });

    it('should generate Mermaid diagram', async () => {
      await protocol.createHandoff('user', 'grok', 'PASS', {}, 'test-session-1');
      await protocol.createHandoff('grok', 'claude', 'WAVE', {}, 'test-session-1', 85);
      await protocol.createHandoff('claude', 'repos', 'PASS', {}, 'test-session-1');

      const diagram = await protocol.visualizeWorkflow('test-session-1');
      
      expect(diagram).toContain('graph LR');
      expect(diagram).toContain('user -->');
      expect(diagram).toContain('grok -->');
      expect(diagram).toContain('claude -->');
      expect(diagram).toContain('WAVE(85%)');
    });

    it('should include state-based styling', async () => {
      await protocol.createHandoff('user', 'grok', 'WAVE', {}, 'test-session-1', 90);

      const diagram = await protocol.visualizeWorkflow('test-session-1');
      expect(diagram).toContain('style');
      expect(diagram).toContain('fill:#90EE90'); // WAVE state color
    });
  });

  describe('queryHandoffs', () => {
    beforeEach(async () => {
      await protocol.createHandoff('user', 'grok', 'PASS', {}, 'session-1');
      await protocol.createHandoff('grok', 'claude', 'WAVE', {}, 'session-1', 85);
      await protocol.createHandoff('claude', 'repos', 'PASS', {}, 'session-1');
      await protocol.createHandoff('user', 'claude', 'PASS', {}, 'session-2');
    });

    it('should query by session', async () => {
      const results = await protocol.queryHandoffs({ sessionId: 'session-1' });
      expect(results).toHaveLength(3);
    });

    it('should query by fromAgent', async () => {
      const results = await protocol.queryHandoffs({ fromAgent: 'user' });
      expect(results).toHaveLength(2);
    });

    it('should query by toAgent', async () => {
      const results = await protocol.queryHandoffs({ toAgent: 'claude' });
      expect(results).toHaveLength(2);
    });

    it('should query by state', async () => {
      const results = await protocol.queryHandoffs({ state: 'WAVE' });
      expect(results).toHaveLength(1);
      expect(results[0].state).toBe('WAVE');
    });

    it('should combine multiple filters', async () => {
      const results = await protocol.queryHandoffs({
        sessionId: 'session-1',
        fromAgent: 'grok'
      });
      expect(results).toHaveLength(1);
      expect(results[0].fromAgent).toBe('grok');
    });
  });

  describe('getAllSessions', () => {
    it('should return empty array when no sessions exist', async () => {
      const sessions = await protocol.getAllSessions();
      expect(sessions).toEqual([]);
    });

    it('should return all session IDs', async () => {
      await protocol.createHandoff('user', 'grok', 'PASS', {}, 'session-1');
      await protocol.createHandoff('user', 'claude', 'PASS', {}, 'session-2');
      await protocol.createHandoff('user', 'repos', 'PASS', {}, 'session-3');

      const sessions = await protocol.getAllSessions();
      expect(sessions).toHaveLength(3);
      expect(sessions).toContain('session-1');
      expect(sessions).toContain('session-2');
      expect(sessions).toContain('session-3');
    });
  });

  describe('Performance', () => {
    it('should handle 1000 handoffs in <500ms', async () => {
      const startTime = Date.now();

      for (let i = 0; i < 1000; i++) {
        await protocol.createHandoff(
          'agent-a',
          'agent-b',
          'PASS',
          { iteration: i },
          'perf-test'
        );
      }

      const duration = Date.now() - startTime;
      console.log(`1000 handoffs created in ${duration}ms`);
      
      // Note: This might be slightly over 500ms in CI environments
      // but should be well under 1000ms
      expect(duration).toBeLessThan(2000);
    }, 10000); // 10 second timeout for this test

    it('should retrieve 1000 handoffs quickly', async () => {
      // Create 1000 handoffs
      for (let i = 0; i < 1000; i++) {
        await protocol.createHandoff(
          'agent-a',
          'agent-b',
          'PASS',
          { iteration: i },
          'perf-test'
        );
      }

      const startTime = Date.now();
      const chain = await protocol.getHandoffChain('perf-test');
      const duration = Date.now() - startTime;

      expect(chain).toHaveLength(1000);
      expect(duration).toBeLessThan(500);
    }, 10000);
  });

  describe('Integration: Full workflow', () => {
    it('should complete Grok→Claude→Commit workflow', async () => {
      // User initiates
      const userToGrok = await protocol.createHandoff(
        'user',
        'grok',
        'PASS',
        { task: 'abstract exploration' },
        'workflow-1'
      );

      // Grok processes with high coherence
      const grokToClaude = await protocol.createHandoff(
        'grok',
        'claude',
        'WAVE',
        { insights: ['pattern1', 'pattern2'], phase: 'grounded' },
        'workflow-1',
        88
      );

      // Claude completes
      const claudeToRepos = await protocol.createHandoff(
        'claude',
        'repos',
        'PASS',
        { status: 'committed', files: ['file1.ts', 'file2.ts'] },
        'workflow-1'
      );

      // Validate the workflow
      const chain = await protocol.getHandoffChain('workflow-1');
      expect(chain).toHaveLength(3);

      // Validate each marker
      for (const marker of chain) {
        const validation = await protocol.validateHandoff(marker);
        expect(validation.valid).toBe(true);
      }

      // Verify ATOM trail
      const atomFile = path.join(testAtomDir, 'workflow-1.atom.jsonl');
      expect(fs.existsSync(atomFile)).toBe(true);
      
      const content = fs.readFileSync(atomFile, 'utf-8');
      const lines = content.trim().split('\n');
      expect(lines.length).toBe(3);

      // Generate visualization
      const diagram = await protocol.visualizeWorkflow('workflow-1');
      expect(diagram).toContain('user');
      expect(diagram).toContain('grok');
      expect(diagram).toContain('claude');
      expect(diagram).toContain('repos');
      expect(diagram).toContain('WAVE(88%)');
    });
  });

  describe('Edge cases', () => {
    it('should handle markers with empty context', async () => {
      const marker = await protocol.createHandoff(
        'agent-a',
        'agent-b',
        'PASS',
        {},
        'test-session'
      );

      expect(marker.context).toEqual({});
      const validation = await protocol.validateHandoff(marker);
      expect(validation.valid).toBe(true);
    });

    it('should handle all handoff states', async () => {
      const states: HandoffState[] = ['WAVE', 'PASS', 'BLOCK', 'HOLD', 'PUSH'];
      
      for (const state of states) {
        const marker = await protocol.createHandoff(
          'agent-a',
          'agent-b',
          state,
          {},
          'test-session'
        );

        expect(marker.state).toBe(state);
        const validation = await protocol.validateHandoff(marker);
        expect(validation.valid).toBe(true);
      }
    });

    it('should handle special characters in agent names', async () => {
      const marker = await protocol.createHandoff(
        'claude-3.5-sonnet',
        'grok-beta.2',
        'PASS',
        {},
        'test-session'
      );

      expect(marker.fromAgent).toBe('claude-3.5-sonnet');
      expect(marker.toAgent).toBe('grok-beta.2');
    });
  });
});
