# 06_change-log

| 일시 | 구분 | 내용 |
|---|---|---|
| 2026-07-06 | START | `homepage-revision-buildon-002` 시작 |
| 2026-07-06 | SCOPE | 작업 주제를 Contact 폼 제출 payload와 `/api/notify` 정합성 점검으로 확정 |
| 2026-07-06 | ANALYSIS | `contact/index.html`, `api/notify.js`, `supabase_setup.sql`, `admin-x7k2.html`, `vercel.json`, `README.md` 확인 |
| 2026-07-06 | FINDING | Contact payload와 `/api/notify` 필수 필드가 직접 일치함을 확인 |
| 2026-07-06 | FINDING | API/DB 실패가 성공 UI에 가려지는 운영 리스크 확인 |
| 2026-07-06 | GUARD | 실제 사이트 파일, API, 배포 설정, Git stage/commit/push 미수행 |
| 2026-07-06 | SCOPE | 수정 방향을 Contact-only로 확정. 허용 파일은 `BuilDOn-site-clean/contact/index.html` |
| 2026-07-06 | PLAN | 성공 조건을 Supabase insert 성공 + `/api/notify` 2xx 응답으로 확정 |
| 2026-07-06 | GUARD | `api/notify.js`, `vercel.json`, `supabase_setup.sql`, 관리자 파일, README, HOMEPAGE-GUIDE, 에셋, 의존성 수정 금지 유지 |
| 2026-07-06 | RISK | Supabase 저장 성공 후 `/api/notify` 실패 시 사용자 재시도로 중복 row가 생길 수 있음을 별도 리스크로 기록 |
| 2026-07-06 | VERIFICATION | Contact 인라인 스크립트 문법은 확인했으나 실제 브라우저 제출/API/DB/이메일 실행 검증은 아직 미수행 |
