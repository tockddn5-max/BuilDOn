# AGENTS.md — Worker 역할 요약 (Codex CLI 자동 로드용)

> 이 파일은 `codex-main`/`codex-critic`(Codex CLI)가 cwd(`tasks/<task>/` 또는 `target_repo`)에서 자동으로 읽는 컨텍스트다.
> 역할·승인·쓰기 정책의 정본은 `CLAUDE.md`와 `_shared/routing.md`이며, 이 파일은 그 요약이다. 상세는 두 문서를 참조할 것 — 여기서 중복 서술하지 않는다.

## Worker 역할 (BuilDOn 홈페이지 제작 기준)

| Worker | 역할 | 호출 방식 |
|---|---|---|
| **claude-main** | 전체 기획, (인터뷰 결과 기반) 섹션 구조·카피 방향, 우선순위 설계 | Claude Code Task tool (`.claude/agents/claude-main.md`) |
| **codex-main** | 실제 코드 구현, 컴포넌트/스타일/반응형 수정, Supabase·Resend 연동, 배포 커맨드 | `mcp__codex__codex` (이 파일을 읽는 주체) |
| **codex-critic** | 코드 리뷰 — 과한 추상화 제거, 접근성, 반응형, 유지보수성, 보안(Phase 5 관리자 페이지 필수) | `mcp__codex__codex` (`sandbox: read-only`) |
| **gemini** | 기획/UX/카피/경쟁사 관점 검토 — **선택 워커, 명시적 요청 시에만** | `_shared/adapters/call_worker.sh` |

인터뷰(Phase 1)는 Orchestrator(Claude Code 세션)가 직접 수행하며 claude-main에는 위임하지 않는다 — 근거: `CLAUDE.md` "BuilDOn 홈페이지 제작 프로세스".

## codex-main / codex-critic 필수 준수

- **쓰기 범위**: brief의 `target_repo` + `write_scope`를 벗어나지 않는다. 기본은 `tasks/<task>/` 내부만. 외부 repo(`BuilDOn-site-clean/` 등) 쓰기는 `CLAUDE.md` "Worker 파일 쓰기 정책"의 4조건이 전부 충족된 경우만 허용.
- `_shared/`, `_templates/`, 다른 작업 폴더는 어떤 경우에도 쓰지 않는다.
- codex-critic은 `sandbox: read-only` 고정 — 리뷰만, 수정 금지.
- 결과는 brief의 `output_format`대로, 불확실한 점은 숨기지 말고 result의 Issues/Caveats에 표면화한다 (`_templates/worker-result.md`).

## 홈페이지 제작 절차·품질 기준

Phase별 절차, 인터뷰 질문표, 안티-제너릭 가드레일, Supabase/Resend/Vercel 연동, 보안 체크리스트는 `HOMEPAGE-GUIDE.md` 참조.

## BuilDOn 홈페이지 revision 작업 규칙

- 기존 BuilDOn 홈페이지 수정 요청은 `HOMEPAGE-GUIDE.md`의 "Revision Auto-Workflow"를 따른다.
- revision 문서는 반드시 `BuilDOn-site-clean/tasks/<revision-id>/`에 생성한다. repo 밖 `buildon 수정/tasks/...`, repo 루트 `tasks/...`, `.gitignore` 대상 경로는 금지한다.
- 새 revision은 기존 `homepage-revision-buildon-###` 폴더를 확인해 다음 번호를 사용한다. revision-001은 완료되었으므로 다음 기본값은 `homepage-revision-buildon-002`다.
- 실제 사이트 파일 수정 전, revision 문서에 요청 원문·수정 목표·허용/금지 파일·예상 변경 파일·검증 기준·롤백 기준을 먼저 기록한다.
- API/배포 설정/관리자 경로/에셋/의존성/환경변수/보안 헤더 변경은 별도 revision 후보로 분리한다.
- 커밋이 필요한 경우 `git add .`를 쓰지 말고 허용 파일만 선별 stage한다. 사이트 수정 커밋과 문서 마감 커밋은 분리한다.
