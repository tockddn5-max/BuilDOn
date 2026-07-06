# 08_post-change-verification

> 아직 실제 수정 전이다. 이 문서는 검증 계획 및 분석 단계 확인 결과만 기록한다.

## 1. 변경 후 검증 기준

| 검증 항목 | 기준 | 결과 |
|---|---|---|
| 변경 파일 범위 | 승인된 파일만 변경 | 대기 |
| `git diff --check` | 오류 없음 | 대기 |
| Contact 모바일 390px | 제출 플로우와 안내 문구 식별 가능 | 대기 |
| Contact 데스크톱 1280px | 제출 플로우와 안내 문구 식별 가능 | 대기 |
| API 성공 케이스 | 정상 payload에 200 응답 | 대기 |
| API 실패 케이스 | 누락/환경 오류가 의도대로 표시 | 대기 |
| 금지 파일 변경 여부 | 승인 밖 파일 변경 없음 | 대기 |

## 2. 분석 단계 확인 결과

| 항목 | 결과 |
|---|---|
| Contact payload 필드 | `name`, `phone`, `email`, `message` |
| `/api/notify` 필수 필드 | `name`, `phone`, `email`, `message` |
| Supabase 저장 컬럼 | `name`, `phone`, `email`, `message`, `status`, `created_at` |
| 관리자 표시 필드 | `name`, `phone`, `email`, `message`, `created_at`, `status` |
| CSP/connect-src | `'self'`와 Supabase URL 허용 |
| 직접 필드 불일치 | 없음 |
| 주요 리스크 | API/DB 실패가 성공 UX에 가려짐 |

## 3. Git/배포 상태

| 항목 | 결과 |
|---|---|
| 사이트 수정 커밋 | 없음 |
| 문서 커밋 | 없음 |
| push | 없음 |
| 배포 | 없음 |

## 4. 운영 검증

운영 사이트 검증은 아직 수행하지 않았다. 이번 단계는 정적 코드 분석과 문서화만 수행한다.
