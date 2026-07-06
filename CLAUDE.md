# MultiAgent Orchestration — Operating Rules

## Architecture

```
Orchestrator (Claude Code session, internal reasoning)
└── Worker Pool (모두 외부 호출 — 승인 필요)
    ├── claude-main    메인 코딩 · 디버깅 · 설계 · 아키텍처 · 전략
    ├── codex-main     보조 구현 · 코드 분석 · 테스트 · diff · 로컬 검증 · 이미지 생성
    ├── codex-critic   산출물 리뷰·비평 (Codex의 주된 역할)
    └── gemini         멀티모달 · 긴 문서 · 제3자 시각의 검토
```

**중요**: Orchestrator의 내부 추론은 worker가 아님. claude-main worker 호출은 별도 모델 호출이므로 승인·쿼터 대상.

## BuilDOn 홈페이지 제작 프로세스

"홈페이지 만들어줘" 요청은 아래 5-Phase 순서로 진행한다. 상세 절차·인터뷰 질문표·코드·SQL·체크리스트는 **`HOMEPAGE-GUIDE.md`가 정본**이며, 여기서는 각 Phase의 담당(누가 하는가)과 아키텍처 정합성만 규정한다.

```
Phase 1: 기획 (인터뷰)     → Orchestrator(직접) → claude-main(구조화·카피)
Phase 2: 프론트엔드 개발    → codex-main
Phase 3: 백엔드 연동       → codex-main (Supabase/Resend)
Phase 4: 배포             → codex-main (실행 커맨드는 사용자 승인 후)
Phase 5: 관리자 페이지(선택) → codex-main → codex-critic (보안 리뷰 필수)
```

**각 Phase 완료 후 사용자에게 확인받고 다음 Phase로 진행한다.**

### BuilDOn 홈페이지 수정 revision lifecycle

BuilDOn 홈페이지의 기존 사이트를 수정하는 요청은 신규 제작 Phase와 분리해 **revision 단위**로 운영한다. 상세 절차와 체크리스트는 `HOMEPAGE-GUIDE.md`의 "Revision Auto-Workflow"가 정본이다.

- 새 revision은 기존 `homepage-revision-buildon-###` 폴더를 확인한 뒤 다음 번호를 사용한다. revision-001은 완료되었으므로 다음 기본값은 `homepage-revision-buildon-002`다.
- revision 작업 문서는 반드시 `BuilDOn-site-clean/tasks/<revision-id>/` 아래에 만든다.
- 금지 경로: repo 밖 `buildon 수정/tasks/...`, repo 루트 `tasks/...`, `.gitignore`에 걸리는 경로.
- 시작 시 revision 문서 8종을 만들고, 수정 전 요청 원문·범위·허용/금지 파일·예상 변경 파일·검증/롤백 기준을 먼저 기록한다.
- API, 배포 설정, 관리자 경로, 에셋, 의존성, 환경변수, 보안 헤더/CSP 변경은 명확한 요청과 별도 범위가 없으면 실제 수정 전 중단하고 별도 revision 후보로 분리한다.
- 사이트 수정 커밋과 문서 마감 커밋은 분리한다. `git add .` 금지, 허용 파일만 선별 add한다.
- push/Vercel 배포 확인 후 `07_final-revision-brief.md`, `08_post-change-verification.md`를 완료 상태로 갱신하고 문서만 별도 커밋한다.

### Phase 1 담당 원칙 (중요 — one-shot 워커 제약과 직결)

`HOMEPAGE-GUIDE.md`의 "고객 인터뷰"는 **claude-main이 아니라 Orchestrator(이 세션)가 `AskUserQuestion`으로 직접 수행**한다. claude-main은 `_templates/worker-brief.md` 고정 블록에 명시된 대로 one-shot/headless 워커라 사용자와의 실시간 대화 채널이 없기 때문이다(승인·쿼터 대상도 아님 — 내부 추론).

인터뷰 결과는 `context.md`에 기록하고, 필요 시에만 claude-main에게 "인터뷰 결과 기반 섹션 구조·카피 방향 설계"를 브리프로 위임한다(승인 필요, `_shared/routing.md` 최소 worker set 원칙 적용).

### 홈페이지 프로덕션 규칙 (아래 "운영 원칙"과 별개 층위)

`HOMEPAGE-GUIDE.md`의 안티-제너릭 가드레일(`transition-all` 금지, Tailwind 기본 blue/indigo 금지, 버튼 4상태 필수 등)과 보안 체크리스트는 **BuilDOn 홈페이지라는 결과물의 품질 기준**이다. 아래 "운영 원칙"(Karpathy 4원칙)은 **코딩 작업 방식** 기준으로, 서로 다른 층위이므로 섞어 적용하지 말 것 — 결과물 기준 위반 여부는 codex-critic 리뷰에서, 작업 방식 위반 여부는 Verification Checklist에서 각각 확인한다.

## 운영 원칙 (Operating Principles)

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

**층별 적용**: 위 4원칙 풀버전은 Orchestrator(이 세션) 전용이다. 워커층 규약의 유일 정본은 `_templates/worker-brief.md`의 "Worker 행동 규약" 고정 블록 — ②단순함·③외과수술식은 그대로, ①은 번역형(워커는 one-shot/headless라 사용자 질문 채널 없음 → 가정을 명시하고 불확실·불일치를 result.md Issues/Caveats에 표면화), ④ loop은 Orchestrator만(Verification Checklist 루프와 결합). 워커 brief나 agent 정의에 "사용자에게 질문" 지시를 넣지 말 것. agent 정의에 규약 중복 금지.

> 출처: [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) (MIT) — adapted. 상세는 `NOTICE` 참조.

## Task Lifecycle

1. `tasks/<task-name>/task.md` 작성 (status: pending)
2. `_shared/routing.md` 참조 → 최소 worker set 결정
3. **target_repo 확인** (외부 산출물 작업인 경우):
   - codex-main이 planned_workers에 포함되거나 코드·문서·이미지를 만드는 작업이면 사용자에게 `target_repo` 경로를 묻는다
   - 사용자가 "없음"이라고 답하거나 분석·리뷰·요약·기획만 하는 작업이면 묻지 않고 `tasks/<task>/artifacts/`에 diff·patch로 산출
   - 사용자가 자연어 요청에 이미 경로를 포함했으면 다시 묻지 않음
4. 모든 worker(claude-main 포함) 사용 시 `task.md`의 `workers_approved`에 명시적 기록 필요
5. 각 worker의 brief를 **정확히 `tasks/<task>/workers/<role>/brief.md`** 에 작성 (≤ 1200자 한글 / 240단어 영문). 워커별 폴더로 분리할 것 — `<role>_brief.md`처럼 납작하게 만들지 말 것
6. worker 실행 → 원문을 **`tasks/<task>/workers/<role>/result.md`** 에 저장 (같은 워커별 폴더)
7. `result.md`의 Verification Checklist 실행
8. 검증 결과를 `log.md`에 append (`[VERIFICATION]` 태그). 작업이 끝나면 `task.md`의 `status`를 `done`으로 갱신
9. 완료 후 교훈 추가 (분류): **시스템 운영 자체**에 대한 일반 교훈 → `_shared/learnings.md`(추적·공개). **특정 외부 프로젝트 한정**(mat·hwpx 등) → `_local/learnings.md`(git 추적 안 함, 없으면 생성). `_local/learnings.md`는 명시 요청 없이는 로드하지 않는다.

> **기존 작업 재개 시**(새 세션 포함)는 1번부터가 아니라 `_shared/orchestrator-rules.md` §3 **재진입 프로토콜**을 먼저 따른다 (재정박 → 분기 → 에러 후 진행).

## Context Rules

| 파일 | 제한 (측정 가능 기준) | 목적 |
|------|------------------|------|
| `context.md` | ≤ 1500자 (한글) / ≤ 300단어 (영문) | 현재 스냅샷만. 히스토리 아님 |
| `brief.md` | ≤ 1200자 (한글) / ≤ 240단어 (영문) | worker가 실행에 필요한 것만 |
| `sources/` | 무제한 | 원본 자료. 경로로만 참조 |
| `artifacts/` | 무제한 | worker 산출물 원본 |

**측정 명령어**:
```bash
wc -m tasks/<task>/context.md   # 한글 글자수 (UTF-8 multi-byte)
wc -w tasks/<task>/context.md   # 영문 단어수
```

**context.md 초과 시**: 핵심만 남기고 나머지는 `log.md`에 append 후 초기화.  
**brief 작성 원칙**: 파일 내용을 inline 금지. 경로만 전달.

## Approval Gate

- `workers_approved`에 없는 worker 호출 금지 (claude-main 포함 전체 worker pool 적용)
- 작업당 첫 호출 전 사용자에게 확인 후 `task.md` 업데이트
- 예외: Orchestrator의 내부 추론은 worker 호출이 아니므로 승인 불필요

## Verification (결과물 수락 전 필수)

각 worker `result.md`에 포함된 Verification Checklist를 실행하고, 결과를 `log.md`에 `[VERIFICATION]` 태그로 기록.

기본 항목:
- [ ] output이 `brief.md`의 `output_format`과 일치
- [ ] 파일 경로가 실제 존재하는지 확인
- [ ] `task.md`의 constraints 충족
- [ ] Do NOT 항목 위반 없음

## log.md 규칙

- append-only. 수정/삭제 금지
- 형식: `[YYYY-MM-DD HH:MM] [ACTION] 내용`
- 기록 대상: worker 호출, 주요 결정, verification 결과, 에러

## Worker 파일 쓰기 정책

| Worker | 기본 쓰기 권한 | 외부 repo 쓰기 |
|--------|------------|--------------|
| claude-main | ❌ Orchestrator 경유 | ❌ |
| codex-main | ✅ `tasks/<task>/` 내부 산출물·diff | ⚠️ 조건부 (아래 참조) |
| codex-critic | ❌ Orchestrator 경유 | ❌ |
| gemini | ❌ MCP 응답을 Orchestrator가 기록 | ❌ |

### `write_scope` 값 정의

- `none` — 쓰기 금지 (codex-critic 등 read-only 기본값)
- `tasks-only` — `tasks/<task>/` 내부만 쓰기 (codex-main 기본 동작. 외부 repo는 안 건드림)
- `"src/**, tests/**"` 같은 경로 패턴 — 외부 repo의 해당 경로만. 아래 4조건 모두 충족 시에만 유효

### codex-main 외부 repo 쓰기 조건 (모두 충족 필수)

1. `brief.md`에 `target_repo: <절대 경로>` 명시
2. `brief.md`에 `write_scope: <허용 경로 패턴>` 명시 (예: `src/**`, `tests/**`)
3. `task.md`의 `workers_approved`에 해당 worker 항목이 있고, `write_scope`도 함께 승인됨
4. `log.md`에 `[APPROVAL]` 태그로 외부 쓰기 승인 별도 기록

위 4개 중 하나라도 누락 → `tasks/<task>/` 내부에만 산출물 작성 (diff·patch 형태 권장, 사용자가 직접 적용).

직접 쓰기 가능한 worker도 `_shared/`, `_templates/`, 다른 작업 폴더는 쓰지 말 것.

## CLAUDE.md 적용 범위

이 파일은 **Claude Code를 `<설치한-폴더>/` 또는 그 하위에서 실행**할 때만 적용됨.

```bash
cd <설치한-폴더> && claude
```

다른 디렉토리에서 실행 시 적용 안 됨 (의도된 격리).  
전역 `~/.claude/CLAUDE.md`에 포함하지 말 것 — orchestration 규칙이 다른 프로젝트로 새어나감.
