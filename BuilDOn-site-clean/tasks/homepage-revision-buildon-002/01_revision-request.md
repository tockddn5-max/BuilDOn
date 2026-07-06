# 01_revision-request

## Metadata

| 항목 | 내용 |
|---|---|
| revision id | `homepage-revision-buildon-002` |
| status | analysis |
| created | 2026-07-06 |
| updated | 2026-07-06 |
| customer | BuilDOn |
| topic | Contact 폼 제출 payload와 `/api/notify` 정합성 점검 |
| document path | `BuilDOn-site-clean/tasks/homepage-revision-buildon-002/` |

## 사용자 요청 원문

homepage-revision-buildon-002를 새 revision lifecycle 규칙에 따라 시작한다.

작업 주제:
Contact 폼 제출 payload와 `/api/notify` 정합성 점검

우선 진행 범위:

- 문서 8종 생성
- 현재 코드 상태 분석
- 리스크/검증 기준 정리
- 수정 필요 여부 판단

주의:

- 실제 사이트 파일 수정 금지
- `api/notify.js` 수정 금지
- `vercel.json` 수정 금지
- `git add` 금지
- 커밋 금지
- push 금지

## 수정 요청 배경

revision-001에서 `api/notify.js`는 기능/API 리스크가 있어 수정 제외되었고, Contact 폼/API 정합성 점검은 후속 revision 후보로 분리되었다. revision-002는 실제 수정 전 현재 구현의 payload/API/DB/Admin 연결 상태를 먼저 확인하는 분석 revision이다.

## 수정 목표

실제 사이트 파일을 수정하기 전에 Contact 폼 제출 payload, `/api/notify` 필수 필드, Supabase 저장 컬럼, 관리자 조회 화면의 필드 정합성을 확인하고 수정 필요 여부를 판단한다.

## 현재 판단

현재 코드 기준으로 Contact 폼이 `/api/notify`에 보내는 직접 payload와 API가 요구하는 필드는 일치한다. 다만 제출 성공 UX가 API/DB 실패를 사용자에게 노출하지 않는 구조라 운영상 리스크가 있다. 실제 수정은 아직 진행하지 않는다.

## 변경 이력

| 일시 | 작성자 | 변경 내용 |
|---|---|---|
| 2026-07-06 | Codex | revision-002 시작 및 요청/목표 정리 |
