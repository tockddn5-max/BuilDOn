# 03_current-code-state

## 확인 일시

2026-07-06

## 확인한 코드 파일

| 파일 | 확인 내용 |
|---|---|
| `BuilDOn-site-clean/contact/index.html` | Contact 폼 필드, 2단계 전환, 개인정보 동의, payload 생성, Supabase insert, `/api/notify` fetch |
| `BuilDOn-site-clean/api/notify.js` | POST method 제한, required field 검증, Resend 발송 payload |
| `BuilDOn-site-clean/supabase_setup.sql` | `consultations` 테이블 컬럼 및 RLS 정책 |
| `BuilDOn-site-clean/admin-x7k2.html` | 관리자 조회 컬럼과 상태 변경 로직 |
| `BuilDOn-site-clean/vercel.json` | CSP `connect-src`, rewrites, 보안 헤더 |
| `BuilDOn-site-clean/README.md` | API 환경변수 및 Supabase 설정 안내 |
| `HOMEPAGE-GUIDE.md` | 일반 Supabase 예시 SQL과 revision-002 후보 기록 |

## Contact 폼 현재 상태

`contact/index.html`의 폼은 아래 입력을 받는다.

- `company`: 회사 / 단체명, 필수
- `name`: 직책 / 성함, 필수
- `phone`: 연락처, 필수
- `email`: 이메일, 필수
- `intro`: 회사 및 비즈니스 소개
- `budget`: 사용 가능한 예산
- `refUrl`: 참고 URL
- `reason`: 의뢰 사유
- `agree`: 개인정보 동의

제출 시 Step 1 필수값과 개인정보 동의를 검증한 뒤 `message` 문자열을 조립한다.

```js
var message =
  '[회사/단체] ' + g('company') + '\n' +
  '[소개] ' + g('intro') + '\n' +
  '[예산] ' + g('budget') + '\n' +
  '[참고 URL] ' + g('refUrl') + '\n' +
  '[의뢰 사유] ' + g('reason');
var payload = { name: g('name'), phone: g('phone'), email: g('email'), message: message };
```

이후 동일 `payload`를 Supabase와 `/api/notify`에 사용한다.

## `/api/notify` 현재 상태

`api/notify.js`는 POST 요청만 허용하고 `req.body`에서 아래 필드를 읽는다.

- `name`
- `phone`
- `email`
- `message`

하나라도 비어 있으면 `400 Missing required fields`를 반환한다. 필드가 있으면 `RESEND_API_KEY`, `ADMIN_NOTIFY_EMAIL` 환경변수를 사용해 Resend 이메일을 보낸다.

## Supabase 저장 상태

`supabase_setup.sql`의 `consultations` 테이블은 현재 payload와 직접 맞는 컬럼을 가진다.

- `name TEXT NOT NULL`
- `phone TEXT NOT NULL`
- `email TEXT NOT NULL`
- `message TEXT NOT NULL`
- `status TEXT NOT NULL DEFAULT 'pending'`
- `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`

관리자 화면도 `name`, `phone`, `email`, `message`, `created_at`, `status`를 조회/표시한다.

## vercel/CSP 상태

`vercel.json`의 `connect-src`는 `'self'`와 Supabase URL을 허용한다. 따라서 현재 정적 Contact 페이지에서 같은 origin의 `/api/notify` 호출과 Supabase 호출 모두 정책상 허용되는 구조다.

## 정합성 1차 결론

Contact 폼 제출 payload와 `/api/notify`의 직접 필드 계약은 일치한다. Supabase 테이블과 관리자 조회 화면도 현재 payload 구조와 일치한다.

다만 제출 성공 UI는 Supabase insert와 `/api/notify`의 실제 성공 여부를 기다리지 않고 즉시 표시한다. 따라서 이메일 발송 실패, 환경변수 누락, API 500, DB insert 실패가 사용자에게 보이지 않는 운영 리스크가 있다.
