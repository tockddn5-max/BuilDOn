-- BuildOn 상담 문의 테이블 생성 (Supabase SQL Editor에서 실행)
-- 여러 번 실행해도 안전하도록 작성되어 있습니다 (이미 존재하면 건너뛰거나 재생성).

CREATE TABLE IF NOT EXISTS consultations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'done')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE consultations ENABLE ROW LEVEL SECURITY;

-- 누구나(방문자) 문의를 등록(INSERT)할 수 있음
DROP POLICY IF EXISTS "anon_can_insert" ON consultations;
CREATE POLICY "anon_can_insert" ON consultations
  FOR INSERT WITH CHECK (true);

-- 로그인한 관리자만 목록 조회 가능
DROP POLICY IF EXISTS "authenticated_can_select" ON consultations;
CREATE POLICY "authenticated_can_select" ON consultations
  FOR SELECT TO authenticated USING (true);

-- 로그인한 관리자만 상태 변경 가능
DROP POLICY IF EXISTS "authenticated_can_update" ON consultations;
CREATE POLICY "authenticated_can_update" ON consultations
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

-- 삭제 정책은 만들지 않음 -> 누구도 삭제 불가

-- 실행 후 아래 쿼리로 정책이 3개 잘 생성됐는지 확인할 수 있어요
-- SELECT policyname, cmd FROM pg_policies WHERE tablename = 'consultations';
