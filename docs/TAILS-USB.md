# T(ai)LS USB - Privacy-First Portable AI

*Tails meets local inference. Anonymous computing with embedded intelligence.*

[![SpiralSafe](https://img.shields.io/badge/🌀_SpiralSafe-Ecosystem-purple?style=flat-square)](https://github.com/toolate28/SpiralSafe)
[![Wave Toolkit](https://img.shields.io/badge/🌊_Wave_Toolkit-Main-0066FF?style=flat-square)](../README.md)
[![Status](https://img.shields.io/badge/Status-Concept-yellow?style=flat-square)](#)

> **Part of the [SpiralSafe Ecosystem](https://github.com/toolate28/SpiralSafe)**

---

## The Concept

**Tails** = The Amnesic Incognito Live System - boots from USB, leaves no trace, routes all traffic through Tor.

**T(ai)LS** = Tails + embedded local AI inference. Same privacy guarantees, but with onboard intelligence that never phones home.

---

## Why This Matters

Standard AI usage leaks:
- Your prompts (sent to cloud)
- Your context (stored on servers)
- Your identity (API keys, IP addresses)
- Your patterns (usage analytics)

T(ai)LS eliminates all of this. AI runs locally, offline, amnesically.

---

## Technical Architecture

### Base Layer: Tails 7 (Debian-based)
- Tor routing for any network traffic
- RAM-only operation (amnesic)
- Persistent encrypted storage (optional)
- LUKS encryption for USB partition

### AI Layer: Offline LLM Stack
```
┌─────────────────────────────────────────┐
│  User Interface (Wave Terminal / CLI)   │
├─────────────────────────────────────────┤
│  Ollama / llama.cpp / vLLM              │
├─────────────────────────────────────────┤
│  Quantized Models (4-bit GGUF)          │
│  - Phi-3 Mini (3.8B) - 2.4GB            │
│  - Qwen2.5 3B - 2GB                     │
│  - Llama 3.2 3B - 2GB                   │
│  - Gemma 2 2B - 1.5GB                   │
├─────────────────────────────────────────┤
│  Tails 7 (Tor + Amnesia)                │
└─────────────────────────────────────────┘
```

### Hardware Requirements
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| USB Drive | 32GB | 64GB+ (for models) |
| RAM | 8GB | 16GB+ |
| CPU | x86_64 | AVX2 support |
| GPU | Not required | Integrated OK |

---

## Cutting-Edge Techniques (2025 Research)

### KV Caching
- Caches attention key-value pairs between tokens
- Reduces O(n²) to ~O(n) for inference
- Critical for responsive local AI
- Cache pruning for memory-constrained devices

### Quantization Stack
- INT4/INT8 quantization reduces model size 4-8x
- GGUF format optimized for CPU inference
- Quality loss <5% on most benchmarks
- Enables 7B models on 8GB RAM

### Prompt-Lookup Decoding
- Cache frequent prompt completions locally
- Sub-100ms responses for common queries
- Essential for offline interactive use

### FlashAttention v2.1
- SIMD-accelerated attention on CPU/NPU
- 2-3x speedup over naive implementation
- Works without GPU

---

## T(ai)LS Build Recipe

### 1. Base Tails Image
```bash
# Download Tails 7 ISO
wget https://tails.net/install/download/tails-amd64-7.0.iso

# Create bootable USB with persistence
# Use Tails Installer or:
dd if=tails-amd64-7.0.iso of=/dev/sdX bs=4M status=progress
```

### 2. Persistent Storage Setup
```bash
# Configure encrypted persistent partition
# Store models + Ollama in persistent volume
/live/persistence/TailsData_unlocked/
├── ollama/
│   └── models/
├── .cache/
└── wave-toolkit/
```

### 3. Ollama Installation (Persistent)
```bash
# In persistent terminal session
curl -fsSL https://ollama.com/install.sh | sh

# Pull lightweight models
ollama pull phi3:mini
ollama pull qwen2.5:3b
ollama pull gemma2:2b
```

### 4. Wave Terminal (Optional)
```bash
# For the full "Office" experience
# Wave provides the split-pane AI collab interface
wget https://github.com/wavetermdev/waveterm/releases/latest/download/waveterm-linux-amd64.deb
sudo dpkg -i waveterm-linux-amd64.deb
```

---

## Operational Modes

### Mode 1: Full Amnesia (Default)
- RAM-only operation
- Models loaded fresh each boot
- Zero persistence
- Maximum privacy

### Mode 2: Persistent Models
- Encrypted partition stores models
- Faster boot (no model download)
- Session data still amnesic
- Balance of privacy + usability

### Mode 3: Selective Persistence
- Models + toolkit persistent
- Conversation logs encrypted
- Manual secure deletion
- "Office" mode

---

## Security Model

### What's Protected
- Prompts never leave device
- No API keys required
- No network telemetry
- Host machine untouched
- RAM cleared on shutdown

### What's NOT Protected
- Physical access to running system
- Cold boot attacks (mitigate: quick shutdown)
- Compromised USB manufacturing

### Threat Model
T(ai)LS protects against:
- Mass surveillance
- Cloud provider data harvesting
- API logging and analytics
- Network-level monitoring
- Host machine forensics

---

## Comparison

| Feature | Cloud AI | Local AI | T(ai)LS |
|---------|----------|----------|---------|
| Privacy | None | Partial | Full |
| Offline | No | Yes | Yes |
| Portable | No | No | Yes |
| Amnesic | No | No | Yes |
| Tor routed | No | No | Yes |
| Model quality | Best | Good | Good |

---

## Roadmap

### Phase 1: Proof of Concept
- [ ] Build Tails 7 + Ollama image
- [ ] Test with Phi-3 Mini
- [ ] Measure boot time and inference speed
- [ ] Document persistence setup

### Phase 2: Integration
- [ ] Add Wave Terminal
- [ ] Pre-load wave-toolkit
- [ ] Create "Office" boot profile
- [ ] Test multi-model switching

### Phase 3: Distribution
- [ ] Create reproducible build script
- [ ] Sign images
- [ ] Document verification process
- [ ] Share on GitHub

---

## Sources

- [Edge LLM Deployment 2025](https://kodekx-solutions.medium.com/edge-llm-deployment-on-small-devices-the-2025-guide-2eafb7c59d07)
- [KV Caching & Quantization](https://medium.com/@tommyadeliyi/deploying-llms-in-low-resource-environments-edge-ai-kv-caching-and-model-quantization-a119c2df7716)
- [Local LLM Hosting Guide 2025](https://medium.com/@rosgluk/local-llm-hosting-complete-2025-guide-ollama-vllm-localai-jan-lm-studio-more-f98136ce7e4a)
- [Edge Deployment Review](https://www.rohan-paul.com/p/edge-deployment-of-llms-and-ml-models)
- [On-Device AI Roadmap](https://datasciencedojo.com/blog/on-device-ai/)
- [Tails OS + Tor Merger](https://techcrunch.com/2024/09/26/the-tor-project-merges-with-tails-a-linux-based-portable-os-focused-on-privacy/)
- [Tails Privacy Guide](https://www.androidpolice.com/what-is-tails/)

---

*Privacy is not about having something to hide. It's about having the freedom to think.*
