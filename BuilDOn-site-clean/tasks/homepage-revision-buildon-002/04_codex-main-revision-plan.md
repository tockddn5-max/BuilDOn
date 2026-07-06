# 04_codex-main-revision-plan

## 현재 단계

Contact-only 수정 방향 확정. 실제 수정 허용 파일은 `BuilDOn-site-clean/contact/index.html` 하나뿐이다.

## 확정 주제

Contact 제출 실패 처리 및 사용자 안내 개선.

## 확정 분석 결과

- Contact 폼 payload와 `/api/notify.js`의 필드 정합성은 문제 없음.
- Contact 폼은 `{ name, phone, email, message }`를 전송한다.
- `/api/notify.js`도 같은 4개 필드를 요구한다.
- Supabase 테이블 및 관리자 화면도 현재 구조와 맞다.
- 핵심 리스크는 API/DB 실패 시에도 사용자가 "문의가 접수되었습니다"로 오인할 수 있는 점이다.

## 후보 분류

| ID | 난이도 | 후보 | 예상 변경 파일 | 수정 이유 | 리스크 | 검증 방법 | 현재 판단 |
|---|---:|---|---|---|---|---|---|
| C-01 | S0 | Contact payload와 `/api/notify` 필드 계약 확인 | 없음 | `name`, `phone`, `email`, `message`가 양쪽에서 일치하는지 확인 | 없음 | 코드 정적 확인 | 완료, 불일치 없음 |
| C-02 | S1 | API 응답 실패를 UI에서 감지 | `BuilDOn-site-clean/contact/index.html` | 현재 fetch 400/500이 성공 UI에 가려짐 | UX 문구/전환 흐름 변경 가능 | 로컬/API mock, 390px/1280px 화면 확인 | 이번 Contact-only 수정 범위 |
| C-03 | S1 | Supabase insert 실패 감지 | `BuilDOn-site-clean/contact/index.html` | DB 저장 실패도 성공 UI에 가려짐 | 네트워크 지연 시 UX 변경 | Supabase 실패 mock, 성공/실패 화면 확인 | 이번 Contact-only 수정 범위 |
| C-04 | S2 | `/api/notify` 환경변수 누락 방어 | `BuilDOn-site-clean/api/notify.js` | `RESEND_API_KEY`, `ADMIN_NOTIFY_EMAIL` 누락 시 500만 발생 | 서버/API 로직 변경 | API 단위 요청, env 누락 테스트 | 별도 승인 필요 |
| C-05 | S2 | Contact 추가 필드를 구조화해서 저장/전송 | `contact/index.html`, `api/notify.js`, `supabase_setup.sql`, `admin-x7k2.html` | 회사명/예산/참고 URL 등을 message가 아닌 컬럼으로 관리 가능 | DB/Admin/API 영향 큼 | DB migration, 관리자 화면, 이메일 내용 검증 | 별도 revision 권장 |
| C-06 | S1 | README/HOMEPAGE-GUIDE SQL 예시와 실제 setup SQL 차이 정리 | 문서 파일 | generic SQL 예시와 실제 `supabase_setup.sql` 컬럼이 다름 | 사이트 영향 없음 | 문서 diff 확인 | 낮은 우선순위 |

## 이번 수정 범위

`contact/index.html` 내부에서만 처리한다.

- 기존 payload 구조 `{ name, phone, email, message }` 유지
- Supabase insert 결과 확인
- `/api/notify` fetch 응답 상태 확인
- 둘 중 하나라도 실패하면 성공 박스를 표시하지 않음
- 실패 시 폼을 유지하고 "접수 확인이 지연되고 있습니다" 또는 "잠시 후 다시 시도해 주세요" 수준의 안내 표시
- 기존 디자인 톤과 모바일 UX 유지

## 성공/실패 조건

| 조건 | 처리 |
|---|---|
| Supabase insert 성공 + `/api/notify` 2xx 응답 | "문의가 접수되었습니다" 성공 메시지 표시 |
| Supabase client 없음 또는 insert error | 실패 안내 표시, 폼 유지, 제출 버튼 재활성화 |
| `/api/notify` 네트워크 오류 또는 non-2xx 응답 | 실패 안내 표시, 폼 유지, 제출 버튼 재활성화 |

## 별도 revision으로 분리할 항목

- C-04: `/api/notify` 환경변수 검증 및 서버 응답 개선
- C-05: payload 구조화, DB 컬럼 확장, 관리자 화면 표시 변경
- 배포 환경변수 확인 또는 Vercel 설정 변경

## 지금 바로 수정하지 말아야 할 항목

- `api/notify.js`: 이번 사용자 지시에서 수정 금지
- `vercel.json`: 배포/CSP 설정 수정 금지
- 관리자 파일: 관리자 경로/화면은 수정 금지
- Supabase 스키마: DB 구조 변경은 별도 승인 필요

## 권장 진행 순서

1. `contact/index.html` 제출 흐름 최소 수정
2. `git diff --name-only`로 수정 범위 확인
3. `git diff --check` 확인
4. Contact 모바일/데스크톱 플로우 확인
5. API/DB 성공/실패 조건 검증 가능 여부 기록
