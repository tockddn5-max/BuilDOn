# Result — [worker-role] / [작업명]

<!-- 이 파일은 worker 응답을 받은 후 생성. brief 작성과 동시에 미리 생성하지 말 것. -->

```yaml
worker: claude-main | codex-main | codex-critic | gemini
task: [작업명]
status: draft | complete | failed
completed_at: <YYYY-MM-DD HH:MM>   # date +"%Y-%m-%d %H:%M"
verdict: PASS | CHANGES_NEEDED | N/A   # 리뷰어(codex-critic/gemini) 필수. 생성계열은 N/A
tokens_used: (선택)
```

## Summary

한 문장. 무엇을 했는가.

## Findings (리뷰어 공통 포맷 — Fan-in 기계 병합용)

<!-- codex-critic·gemini는 아래 표 형식으로 통일해 출력. 생성계열 워커는 생략 가능. -->

| severity | file:line (또는 대상) | 문제 | 개선안(1줄) |
|---|---|---|---|
| Critical/Major/Minor | index.html:216 | 무엇이·왜 | 어떻게 |

<!-- verdict 규칙: Critical 또는 Major가 하나라도 있으면 CHANGES_NEEDED. Minor만이면 PASS. -->

## Output

<!-- 실제 결과물. 코드는 코드 블록, 문서는 Markdown, 분석은 섹션으로. -->
<!-- 대용량 산출물은 artifacts/에 저장하고 경로만 기록. -->
<!-- 변경한 파일이 있다면 파일별로 "무엇을·왜" 한 줄씩 남길 것. -->

## Verification Checklist

- [ ] output_format과 일치
- [ ] 파일 경로 실존 확인
- [ ] task.md constraints 충족
- [ ] Do NOT 항목 위반 없음
- [ ] 가정·불일치가 Issues/Caveats에 표면화됨
- [ ] 변경 검증용 명령어 제안됨 (실행 가능한 커맨드로)

## Issues / Caveats

<!-- 결과에 포함된 불확실성, 한계, 후속 확인 필요 사항 -->

## Artifacts

```
# 별도 파일로 저장된 산출물
tasks/<task-name>/artifacts/<file>
```
