# Backend Agent Generation Master Prompt Modules

Thu muc nay la ban modular cua `../backend-agent-generation-master-prompt-workflow-harness.md`.
File o thu muc cha la ban prompt monolith duoc assemble tu cac module; cac file trong thu muc nay la noi nen chinh sua lau dai.

## Cach to chuc

- `manifest.txt`: thu tu ghep cac module thanh prompt hoan chinh mac dinh cho Codex.
- `manifests/`: manifest rieng theo nen tang, vi du `manifests/claude.txt`.
- `platforms/`: noi tach phan phu thuoc nen tang. Hien tai `platforms/codex.md` chua request rieng cho Codex tu file goc.
- `modules/`: noi dung shared, gom rule thiet ke, workflow policy, layer agent, global rules va template.
- `modules/agents/`: catalog agent theo layer.
- `modules/templates/`: template output dung chung.
- `assemble.sh`: ghep prompt tu manifest.
- `verify.sh`: ghep lai va so sanh byte-by-byte voi ban monolith o thu muc cha.

## Cach sua workflow logic

Sua module dung pham vi thay vi regenerate ca file lon:

- Rule thiet ke/runtime: `modules/02-core-design-principles-and-runtime-governance.md`
- Folder output bat buoc: `modules/03-output-folder-structure.md`
- Format moi agent: `modules/04-agent-file-standard.md`
- Execution state: `modules/05-execution-state-template.md`
- Invocation/handoff/review matrix: `modules/06-invocation-handoff-review-matrix.md`
- Agent theo layer: `modules/agents/*.md`
- Global rules: `modules/08-global-rules.md`
- Checklist/final report: `modules/templates/*.md`

## Cach doi sang nen tang moi

1. Tao file adapter moi trong `platforms/`, vi du `platforms/claude.md`.
2. Copy `manifest.txt` thanh manifest rieng neu can, vi du `manifests/<platform>.txt`.
3. Thay dong dong `platforms/codex.md` bang adapter moi. Voi Claude Code, file nay da co san la `manifests/claude.txt`.
4. Ghep prompt:

```bash
./assemble.sh dist/backend-agent-generation-master-prompt-workflow-harness.md manifests/claude.txt
```

Neu chi dung manifest mac dinh:

```bash
./assemble.sh
```

## Kiem tra khong thieu noi dung goc

Manifest mac dinh dang reproduce ban monolith hien tai. Chay:

```bash
./verify.sh
```

Ket qua `OK` nghia la prompt ghep lai trung byte-by-byte voi `../backend-agent-generation-master-prompt-workflow-harness.md`.
