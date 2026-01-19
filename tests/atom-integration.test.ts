import { ATOMIntegration } from '../src/integrations/ATOMIntegration';
import { HandshakeMarker } from '../src/handshake/types';
import * as fs from 'fs';
import * as path from 'path';

describe('ATOMIntegration', () => {
  let atomIntegration: ATOMIntegration;
  const testAtomDir = '/tmp/wave-test-atom-integration';

  beforeEach(async () => {
    // Clean up test directory
    if (fs.existsSync(testAtomDir)) {
      fs.rmSync(testAtomDir, { recursive: true, force: true });
    }

    atomIntegration = new ATOMIntegration(testAtomDir);
  });

  afterEach(() => {
    // Clean up
    if (fs.existsSync(testAtomDir)) {
      fs.rmSync(testAtomDir, { recursive: true, force: true });
    }
  });

  describe('logHandoff', () => {
    it('should create ATOM entry for handoff', async () => {
      const marker: HandshakeMarker = {
        id: 'test-id',
        timestamp: '2024-01-01T00:00:00.000Z',
        fromAgent: 'claude',
        toAgent: 'grok',
        state: 'WAVE',
        context: { test: 'data' },
        atomTrailId: 'ATOM-123',
        coherenceScore: 95,
        sessionId: 'test-session'
      };

      await atomIntegration.logHandoff(marker);

      const atomFile = path.join(testAtomDir, 'test-session.atom.jsonl');
      expect(fs.existsSync(atomFile)).toBe(true);

      const content = fs.readFileSync(atomFile, 'utf-8');
      const lines = content.trim().split('\n');
      expect(lines.length).toBe(1);

      const entry = JSON.parse(lines[0]);
      expect(entry.actor).toBe('claude');
      expect(entry.decision).toBe('H&&S: WAVE to grok');
      expect(entry.outcome).toBe('success');
      expect(entry.coherenceScore).toBe(95);
    });

    it('should handle marker without coherence score', async () => {
      const marker: HandshakeMarker = {
        id: 'test-id',
        timestamp: '2024-01-01T00:00:00.000Z',
        fromAgent: 'user',
        toAgent: 'system',
        state: 'PASS',
        context: {},
        atomTrailId: 'ATOM-456',
        sessionId: 'test-session-2'
      };

      await atomIntegration.logHandoff(marker);

      const atomFile = path.join(testAtomDir, 'test-session-2.atom.jsonl');
      const content = fs.readFileSync(atomFile, 'utf-8');
      const entry = JSON.parse(content.trim());
      
      expect(entry.coherenceScore).toBeUndefined();
      expect(entry.rationale).toContain('N/A');
    });
  });

  describe('getEntries', () => {
    it('should return empty array for non-existent session', async () => {
      const entries = await atomIntegration.getEntries('non-existent');
      expect(entries).toEqual([]);
    });

    it('should retrieve ATOM entries', async () => {
      const marker1: HandshakeMarker = {
        id: 'test-id-1',
        timestamp: '2024-01-01T00:00:00.000Z',
        fromAgent: 'agent1',
        toAgent: 'agent2',
        state: 'PASS',
        context: {},
        atomTrailId: 'ATOM-1',
        sessionId: 'test-session'
      };

      const marker2: HandshakeMarker = {
        id: 'test-id-2',
        timestamp: '2024-01-01T00:01:00.000Z',
        fromAgent: 'agent2',
        toAgent: 'agent3',
        state: 'WAVE',
        context: {},
        atomTrailId: 'ATOM-2',
        coherenceScore: 88,
        sessionId: 'test-session'
      };

      await atomIntegration.logHandoff(marker1);
      await atomIntegration.logHandoff(marker2);

      const entries = await atomIntegration.getEntries('test-session');
      expect(entries).toHaveLength(2);
      expect(entries[0].actor).toBe('agent1');
      expect(entries[1].actor).toBe('agent2');
      expect(entries[1].coherenceScore).toBe(88);
    });

    it('should handle file read errors', async () => {
      // Create a directory instead of a file to cause a read error
      fs.mkdirSync(testAtomDir, { recursive: true });
      const badFile = path.join(testAtomDir, 'bad-session.atom.jsonl');
      fs.mkdirSync(badFile);

      await expect(atomIntegration.getEntries('bad-session')).rejects.toThrow();
    });
  });
});
