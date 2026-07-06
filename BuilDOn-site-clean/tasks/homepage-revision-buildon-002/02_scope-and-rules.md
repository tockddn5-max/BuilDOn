# 02_scope-and-rules

## 작업 범위

이번 revision의 우선 범위는 분석과 문서화다.

- Contact 폼 제출 payload 확인
- `/api/notify` 요청 body 요구사항 확인
- Supabase `consultations` 테이블 컬럼과 저장 payload 확인
- 관리자 화면 조회 필드 확인
- CSP/connect-src 및 Vercel API 경로 영향 확인
- 수정 필요 여부와 후속 단계 제안

## 수정 허용 파일

이번 단계에서는 문서 파일만 생성한다.

- `BuilDOn-site-clean/tasks/homepage-revision-buildon-002/*.md`

## 수정 금지 파일

- `BuilDOn-site-clean/contact/index.html`
- `BuilDOn-site-clean/api/notify.js`
- `BuilDOn-site-clean/vercel.json`
- `BuilDOn-site-clean/index.html`
- 관리자 화면/관리자 경로 관련 파일
- 이미지/영상/로고 등 에셋 파일
- `package.json`, lock 파일, 의존성 파일
- 배포 설정 파일

## Git/배포 금지

- `git add` 금지
- 커밋 금지
- push 금지
- 배포 금지
- Vercel 설정 변경 금지

## 수정 전 중단 조건

아래 항목이 필요하다고 판단되면 실제 수정 전 사용자 승인과 별도 작업 범위를 확정한다.

- `/api/notify` 서버 로직 수정
- Resend 환경변수 검증 로직 추가
- Contact 폼 제출 UX 변경
- Supabase 저장 payload 구조 변경
- 관리자 화면 표시 컬럼 변경
- CSP 또는 `vercel.json` 변경

## Rollback 기준

이번 단계는 문서 생성만 수행하므로 사이트 rollback 대상은 없다. 단, 문서 위치가 고정 경로가 아니거나 실제 사이트 파일 diff가 발생하면 즉시 중단한다.
