# 05_risk-and-verification

## 리스크 요약

| 리스크 | 수준 | 설명 | 현재 대응 |
|---|---:|---|---|
| Contact payload/API 필드 불일치 | 낮음 | 현재 `name`, `phone`, `email`, `message`로 일치 | 수정 불필요 |
| API 실패가 사용자에게 보이지 않음 | 중간 | fetch 실패/500/400이 성공 UI에 가려짐 | Contact-only 수정 범위 |
| Supabase 저장 실패가 사용자에게 보이지 않음 | 중간 | insert 실패를 무시하고 성공 UI 표시 | Contact-only 수정 범위 |
| Resend 환경변수 누락 | 중간 | `RESEND_API_KEY`, `ADMIN_NOTIFY_EMAIL` 누락 시 발송 실패 가능 | 운영/env 확인 또는 API 개선 후보 |
| Supabase 저장 성공 후 `/api/notify` 실패 시 중복 제출 | 중간 | DB row는 생성됐지만 사용자에게 실패 안내가 표시되어 재시도 시 중복 row가 생길 수 있음 | API/DB 구조 변경 없이 문서 리스크로 기록 |
| 회사명/예산 등 구조화 부족 | 낮음~중간 | 추가 항목이 `message` 문자열에 묶여 관리됨 | 별도 revision 후보 |
| CSP 차단 | 낮음 | `connect-src 'self'`와 Supabase URL이 있어 현재 호출 허용 | 현 상태 유지 |

## 검증 기준

실제 수정 전 분석 단계:

- [x] `contact/index.html` payload 생성 확인
- [x] `/api/notify` required fields 확인
- [x] Supabase setup SQL 컬럼 확인
- [x] 관리자 조회 필드 확인
- [x] `vercel.json` connect-src 확인
- [x] 실제 사이트 파일 미수정

실제 수정 단계로 넘어갈 경우:

- [ ] `git diff --name-only`가 승인된 파일만 포함
- [ ] `git diff --check` 통과
- [ ] Contact 390px 모바일 제출 플로우 확인
- [ ] Contact 1280px 데스크톱 제출 플로우 확인
- [ ] 정상 payload `{ name, phone, email, message }` 유지 확인
- [ ] Supabase insert 성공 + `/api/notify` 2xx 응답일 때만 성공 메시지 표시
- [ ] Supabase insert 실패 시 성공 메시지를 표시하지 않고 실패 안내 표시
- [ ] `/api/notify` 네트워크 오류 또는 non-2xx 응답 시 성공 메시지를 표시하지 않고 실패 안내 표시
- [ ] 실패 시 폼이 유지되고 제출 버튼이 다시 활성화됨
- [ ] `api/notify.js`, `vercel.json`, `supabase_setup.sql`, 관리자 파일 변경 없음

## Rollback 기준

실제 수정 단계에서 아래 상황이 발생하면 커밋/배포하지 않고 중단한다.

- 승인되지 않은 파일 변경
- API 요청이 정상 payload에서도 400/500 반환
- Contact 성공 UX가 모바일에서 깨짐
- 개인정보 동의 또는 필수값 검증이 우회됨
- Supabase 저장 또는 이메일 알림 중 하나라도 의도와 다르게 동작

## Contact-only 검증 기준

| 케이스 | 기대 결과 |
|---|---|
| 정상 저장 + 정상 알림 | 성공 박스 표시 |
| Supabase client 로드 실패 | 실패 안내 표시, 폼 유지 |
| Supabase insert error | 실패 안내 표시, 폼 유지 |
| `/api/notify` 400/500 | 실패 안내 표시, 폼 유지 |
| `/api/notify` 네트워크 오류 | 실패 안내 표시, 폼 유지 |
| 필수값 누락/이메일 형식 오류 | 기존 Step 1 validation 유지 |
| 개인정보 미동의 | 기존 동의 오류 유지 |

## 남은 리스크

Contact-only 범위에서는 `/api/notify` 실패 시 이미 저장된 Supabase row를 되돌리거나 중복을 방지하지 않는다. 따라서 Supabase insert 성공 후 알림 API만 실패하면 사용자가 재시도할 때 동일 문의가 중복 저장될 수 있다. 이 문제를 완전히 줄이려면 클라이언트 idempotency key, 서버/API 중재, DB 중복 방지 정책 중 하나가 필요하므로 별도 API/DB revision으로 분리한다.

## 현재 검증 결과

정적 코드 기준으로 payload/API/DB/Admin의 필드 계약은 일치한다. Contact-only 수정 후 인라인 스크립트 문법은 확인했지만, 실제 브라우저 제출, Supabase insert 성공/실패, `/api/notify` 성공/실패, 운영 환경변수, 실제 이메일 발송은 아직 실행 검증하지 않았다.
