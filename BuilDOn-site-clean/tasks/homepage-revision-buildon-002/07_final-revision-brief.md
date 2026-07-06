# 07_final-revision-brief

> 수정 후보 정리용 초안. revision-002는 아직 실제 수정, 커밋, push, 배포를 진행하지 않았다.

## Revision 요약

| 항목 | 내용 |
|---|---|
| revision id | `homepage-revision-buildon-002` |
| 주제 | Contact 폼 제출 payload와 `/api/notify` 정합성 점검 |
| 상태 | analysis draft |
| 생성일 | 2026-07-06 |
| 실제 사이트 수정 | 없음 |
| 커밋 | 없음 |
| push | 없음 |
| 배포 | 없음 |

## 분석 결론 초안

현재 Contact 폼의 `/api/notify` payload는 `{ name, phone, email, message }`이고, `api/notify.js`도 동일한 4개 필드를 필수로 요구한다. Supabase `consultations` 테이블과 관리자 화면도 같은 필드 구조를 사용하므로, 직접적인 payload/API/DB/Admin 필드 불일치는 확인되지 않았다.

수정 후보는 필드명 불일치가 아니라 실패 처리 UX와 운영 방어에 있다.

## 수정 필요 후보

| 우선순위 | 후보 | 이유 | 분리 여부 |
|---|---|---|---|
| 높음 | API/DB 실패 시 성공 UI를 즉시 보여주는 구조 검토 | 사용자는 접수 성공으로 보지만 이메일/DB 저장이 실패할 수 있음 | Contact-only 수정 가능 |
| 중간 | `/api/notify` 환경변수 누락 방어 | 운영 환경변수 누락 시 500 발생 가능 | API 수정 별도 승인 필요 |
| 중간 | 추가 필드 구조화 저장 | 회사명/예산/참고 URL을 검색/관리하기 어렵다 | DB/Admin/API 포함 별도 revision 권장 |
| 낮음 | 문서 SQL 예시 정리 | guide 예시와 실제 setup SQL이 다름 | 문서 revision 가능 |

## 수정 제외

이번 분석 단계에서는 아래 파일을 수정하지 않았다.

- `BuilDOn-site-clean/contact/index.html`
- `BuilDOn-site-clean/api/notify.js`
- `BuilDOn-site-clean/vercel.json`
- 관리자 파일
- 에셋 파일
- 의존성 파일

## 다음 단계 초안

사용자가 실제 수정을 원하면 먼저 범위를 선택해야 한다.

1. Contact-only: 실패 응답을 감지하고 사용자 안내를 조정
2. API 포함: `/api/notify` 환경변수/오류 응답을 명확히 개선
3. DB/Admin 포함: 추가 필드를 구조화해 저장하고 관리자 화면에 표시
