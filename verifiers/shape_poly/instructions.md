# Shape Polymorphism In-Memory Refinement & Parallel Compilation Verifier

## Core Objective
Validate the end-to-end shape polymorphism pipeline:
1. Export a JAX model once symbolically with polymorphic dimension specifications using `jax.export.export`.
2. Keep the portable artifact strictly in memory (zero disk I/O, no filesystem round-trip).
3. Concurrently specialize / refine the in-memory module across discrete target prefill buckets (e.g. 128, 256, 512, 1024, 2048, 4096).
4. Lower and compile each specialized bucket in parallel via a worker thread pool.
5. Verify bit-for-bit numerical, op-level, and shape parity against direct evaluation on both synthetic transformers and real production Gemini v5m serving models (`//learning/gemini/prod/serving/jet_engine/gemini5:gemax_prod_serving_gemini_v5m_1m_unified_cheap_gf_wiz_cpu_parallel_export_guitar_smoke_test_test`).

## Real Gemini v5m StableHLO Parity Evidence
- **HEAD Concrete StableHLO**: `testdata/real_gemini_v5m_head_prefill_step_4k.mlir` (25,827 lines, 14.5 MB, 24,719 ops, 0 dynamic dims)
- **Polymorphic StableHLO**: `testdata/real_gemini_v5m_poly_prefill_step_s.mlir` (25,827 lines, 14.5 MB, 24,719 ops, 7,973 dynamic `?` dims)
- **Specialized StableHLO**: `testdata/real_gemini_v5m_specialized_prefill_step_4k.mlir` (25,827 lines, 14.5 MB, 24,719 ops, 0 dynamic dims)
- **Equivalence Result**: All 24,719 ops, 14,515 `sdy.sharding` annotations, 163 `mhlo.layout_mode` attributes, and MPMD named computations are 100% bit-for-bit identical.

## Webdiffs (go/mdiff)
- **Real Gemini v5m Smoke Test (4k Bucket)**: [Real Gemini v5m HEAD vs Specialized 4k Webdiff](http://go/mdiff?s=6Ch38GB6U1)
- **Real Gemini v5m Symbolic Poly vs HEAD**: [Real Gemini v5m HEAD vs Symbolic Shape Poly Webdiff](http://go/mdiff?s=Mk8veQur7D)
- **Prototype AOT Bucket 128**: [HEAD vs Specialized StableHLO (128)](http://go/mdiff?s=1BBag3Q1yq)
- **Prototype AOT Bucket 1024**: [HEAD vs Specialized StableHLO (1024)](http://go/mdiff?s=X3vUZC1nxc)
- **Prototype AOT Symbolic Poly**: [HEAD vs Symbolic Shape Poly StableHLO](http://go/mdiff?s=o5DaffpK2L)

## Commands
- `verify doctor`: check environment dependencies (`laze`) and shape-poly / PartIR-Shardy workspace files.
- `verify compile`: build `//prototypes/gdm/users/dsuo/jax/aot/...` and `//prototypes/gdm/deployment/poly_config_export:{poly_prefill_test,mpmd_refine_main,fragment_compile_main}`.
- `verify test`: execute `poly_refine_compile_test`, `poly_prefill_test`, and `partir_shardy_poly_transformer_test` (2-stage × 2D `(data, model)` Shardy + PartIR 4-layer Transformer with RoPE, SwiGLU, donated KV cache, cross-mesh transfers, single symbolic partition -> per-bucket `mpmd_refine` + `realias` across `64, 128, 256` -> 0 `?` dims -> XLA HLO & 8-device PJRT numerical parity).
- `verify mutants`: run injected shape-refinement, aliasing, and HLO/numerical oracle sensitivity checks.
- `verify compare`: execute `./compare.sh` for full StableHLO equivalence & static shape verification.
